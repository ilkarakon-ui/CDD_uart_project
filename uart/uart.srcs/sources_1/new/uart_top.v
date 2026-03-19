`timescale 1ns / 1ps

module uart_top #(
    parameter   NBYTES        = 12,
    parameter   CLK_FREQ      = 125_000_000,
    parameter   BAUD_RATE     = 115_200
  )  
  (
    input  wire   iClk, iRst,
    input  wire   iRx,
    output wire   oTx
  );
  
  // Buffer to store received bytes and then transmit them
  reg [NBYTES*8-1:0] rBuffer;
  
  // State definition  
  localparam s_IDLE          = 3'b000;
  localparam s_WAIT_RX       = 3'b001; // Collect NBYTES from laptop
  localparam s_TX            = 3'b010; // Prepare to send byte
  localparam s_WAIT_TX       = 3'b011; // Wait for TX to finish one byte
  localparam s_DONE          = 3'b100; // Finish sequence
   
  reg [2:0]   rFSM;  
  reg [$clog2(NBYTES):0] rCnt;

  // --- UART TX Signals ---
  reg         rTxStart;
  reg [7:0]   rTxByte;
  wire        wTxBusy;
  wire        wTxDone;
       
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
  
  always @(posedge iClk)
  begin
    if (iRst == 1) begin
      rFSM <= s_IDLE;
      rTxStart <= 0;
      rCnt <= 0;
      rTxByte <= 0;
      rBuffer <= 0;
    end 
    else begin
      case (rFSM)

        s_IDLE : begin
          rCnt <= 0;
          rFSM <= s_WAIT_RX;
        end
          
        s_WAIT_RX : begin
  // Check the signal coming FROM the uart_rx module
  if (wRxDone == 1'b1) begin 
    
    // Shift the new byte into the buffer
    // We take the current buffer, shift it left by 8 bits, 
    // and put the new byte (wRxByte) at the end.
    rBuffer <= {rBuffer[(NBYTES-1)*8-1:0], wRxByte};
    
    // Keep track of how many bytes we have collected
    if (rCnt == NBYTES - 1) begin
      rFSM <= s_TX;  // Once we have 12 bytes, go to transmit state
      rCnt <= 0;     // Reset counter for the next phase
    end else begin
      rCnt <= rCnt + 1;
    end
  end
  // If wRxDone is 0, we just stay in this state and wait
end
             
        s_TX : begin
          if (rCnt < NBYTES) begin
            if (!wTxBusy) begin
                rFSM <= s_WAIT_TX;
                rTxStart <= 1; 
                // Send the leftmost (oldest received) byte first
                rTxByte <= rBuffer[NBYTES*8-1:NBYTES*8-8];        
                // Shift the buffer left to prepare the next byte
                rBuffer <= {rBuffer[(NBYTES-1)*8-1:0], 8'h00};    
                rCnt <= rCnt + 1;
            end
          end 
          else begin
            rFSM <= s_DONE;
          end
        end 
            
        s_WAIT_TX : begin
          rTxStart <= 0; // Pulse start only for one cycle
          if (wTxDone) begin
            rFSM <= s_TX;
          end
        end 
              
        s_DONE : begin
          // Return to IDLE to allow a new string to be sent
          rFSM <= s_IDLE;
        end 

        default : rFSM <= s_IDLE;
      endcase
    end
  end       
    
endmodule