`timescale 1ns / 1ps

module uart_top #(
    parameter NBYTES    = 128,
    parameter CLK_FREQ  = 125_000_000,
    parameter BAUD_RATE = 115_200
  )  
  (
    input  wire iClk, iRst,
    input  wire iRx,
    output wire oTx
  );
  
  // Buffer to store received bytes
  reg [NBYTES*8-1:0] rBuffer;
  
  // Operands for Addition
  wire [511:0] opA;
  wire [511:0] opB;
  
  assign opA = rBuffer[1023:512];
  assign opB = rBuffer[511:0];
  
  // State definition  
  localparam s_IDLE        = 4'b0000;
  localparam s_WAIT_RX     = 4'b0001;
  localparam s_START_ADD   = 4'b0010;
  localparam s_WAIT_ADD    = 4'b0011;
  localparam s_TX          = 4'b0100;
  localparam s_WAIT_TX     = 4'b0101;
  localparam s_DONE        = 4'b0110;
  localparam s_TX_COUNT    = 4'b0111;
  localparam s_WAIT_TX_COUNT = 4'b1000;

  reg [3:0]    rFSM; 
  reg [7:0]    rCnt;
  reg [31:0]   rLatencyCnt;
  reg [7:0]    rCountToSend [0:3];

  // --- UART TX Signals ---
  reg          rTxStart;
  reg [7:0]    rTxByte;
  wire         wTxBusy;
  wire         wTxDone;
  
  // MP Adder signals
  wire [512:0] wResult;
  wire         wAddDone;
  reg          rAddStart;
  reg [512:0]  rResultBuffer;
        
  uart_tx #( .CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE) )
  UART_TX_INST (
    .iClk(iClk), .iRst(iRst),
    .iTxStart(rTxStart), .iTxByte(rTxByte),
    .oTxSerial(oTx), .oTxBusy(wTxBusy), .oTxDone(wTxDone)
  );

  // --- UART RX Signals ---
  wire [7:0] wRxByte;
  wire       wRxDone;

  uart_rx #( .CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE) )
  UART_RX_INST (
    .iClk(iClk), .iRst(iRst),
    .iRxSerial(iRx), .oRxByte(wRxByte), .oRxDone(wRxDone)
  );
  
  // --- MP ADDER ---
  mp_adder #(
        .OPERAND_WIDTH(512),
        .ADDER_WIDTH(16)
        ) MP_ADDER_INST (
        .iClk   (iClk),
        .iRst   (iRst),
        .iStart (rAddStart),
        .iOpA   (opA),
        .iOpB   (opB),
        .oRes   (wResult),
        .oDone  (wAddDone)
    );
    
  always @(posedge iClk) begin
    if (iRst) begin
      rFSM <= s_IDLE;
      rTxStart <= 0;
      rCnt <= 0;
      rTxByte <= 0;
      rBuffer <= 0;
      rAddStart <= 0;
      rResultBuffer <= 0;
      rLatencyCnt <= 0;
    end else begin
      case (rFSM)
        s_IDLE : begin
          rCnt <= 0;
          rFSM <= s_WAIT_RX;
        end

        s_WAIT_RX : begin
          if (wRxDone) begin 
            rBuffer <= {rBuffer[(NBYTES-1)*8-1:0], wRxByte};
            if (rCnt == NBYTES - 1) begin
              rCnt <= 0;
              rFSM <= s_START_ADD;
            end else begin
              rCnt <= rCnt + 1;
            end
          end
        end

        s_START_ADD : begin
          rAddStart <= 1;
          rLatencyCnt <= 0;
          rFSM <= s_WAIT_ADD;
        end

        s_WAIT_ADD : begin
          rAddStart <= 0;
          rLatencyCnt <= rLatencyCnt + 1;
          if (wAddDone) begin
            rResultBuffer <= wResult;
            rCountToSend[0] <= rLatencyCnt[31:24];
            rCountToSend[1] <= rLatencyCnt[23:16];
            rCountToSend[2] <= rLatencyCnt[15:8];
            rCountToSend[3] <= rLatencyCnt[7:0];
            rCnt <= 0;
            rFSM <= s_TX;
          end
        end

        s_TX : begin
          if (rCnt < 65) begin
            if (!wTxBusy) begin
              rTxStart <= 1;
              rTxByte <= rResultBuffer[512:505];
              rResultBuffer <= {rResultBuffer[504:0], 8'b0};
              rCnt <= rCnt + 1;
              rFSM <= s_WAIT_TX;
            end
          end else begin
            rCnt <= 0;
            rFSM <= s_TX_COUNT;
          end
        end

        s_WAIT_TX : begin
          rTxStart <= 0;
          if (wTxDone) rFSM <= s_TX;
        end

        s_TX_COUNT : begin
          if (rCnt < 4) begin
            if (!wTxBusy) begin
              rTxStart <= 1;
              rTxByte <= rCountToSend[rCnt];
              rCnt <= rCnt + 1;
              rFSM <= s_WAIT_TX_COUNT;
            end
          end else begin
            rFSM <= s_DONE;
          end
        end

        s_WAIT_TX_COUNT : begin
          rTxStart <= 0;
          if (wTxDone) rFSM <= s_TX_COUNT;
        end

        s_DONE : rFSM <= s_IDLE;
        
        default : rFSM <= s_IDLE;
      endcase
    end
  end
endmodule
