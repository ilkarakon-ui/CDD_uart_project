//`timescale 1ns / 1ps

//module uart_top #(
//    parameter   NBYTES        = 128,
//    parameter   CLK_FREQ      = 125_000_000,
//    parameter   BAUD_RATE     = 115_200
//  )  
//  (
//    input  wire   iClk, iRst,
//    input  wire   iRx,
//    output wire   oTx
//  );
  
//  // Buffer to store received bytes and then transmit them
//  reg [NBYTES*8-1:0] rBuffer;
  
  
//  // Operands for Addition
//  wire [511:0] opA;
//  wire [511:0] opB;
  
//  assign opA = rBuffer[1023:512];
//  assign opB = rBuffer[511:0];
  
//  // State definition  
//  localparam s_IDLE        = 3'b000;
//localparam s_WAIT_RX     = 3'b001;
//localparam s_START_ADD   = 3'b010;
//localparam s_WAIT_ADD    = 3'b011;
//localparam s_TX          = 3'b100;
//localparam s_WAIT_TX     = 3'b101;
//localparam s_DONE        = 3'b110;
   
//  reg [2:0]   rFSM;  
//  reg [$clog2(NBYTES):0] rCnt;

//  // --- UART TX Signals ---
//  reg         rTxStart;
//  reg [7:0]   rTxByte;
//  wire        wTxBusy;
//  wire        wTxDone;
  
//  // MP Adder stuff
//  wire [512:0] wResult;
//  wire wAddDone;
//  reg rAddStart;
//  reg [512:0] rResultBuffer;
       
//  uart_tx #( .CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE) )
//  UART_TX_INST (
//    .iClk(iClk), .iRst(iRst),
//    .iTxStart(rTxStart), .iTxByte(rTxByte),
//    .oTxSerial(oTx), .oTxBusy(wTxBusy), .oTxDone(wTxDone)
//  );

//  // --- UART RX Signals ---
//  wire [7:0] wRxByte;
//  wire       wRxDone;

//  uart_rx #( .CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE) )
//  UART_RX_INST (
//    .iClk(iClk), .iRst(iRst),
//    .iRxSerial(iRx), .oRxByte(wRxByte), .oRxDone(wRxDone)
//  );
  
//  // --- MP ADDER ---
//  mp_adder #(
//        .OPERAND_WIDTH(512),
//        .ADDER_WIDTH(16)
//        ) MP_ADDER_INST (
//        .iClk   (iClk),
//        .iRst   (iRst),
//        .iStart (rAddStart),
//        .iOpA   (opA),
//        .iOpB   (opB),
//        .oRes   (wResult),
//        .oDone  (wAddDone)
//    );
    
//    always @(posedge iClk)
//begin
//  if (iRst == 1) begin
//    rFSM <= s_IDLE;
//    rTxStart <= 0;
//    rCnt <= 0;
//    rTxByte <= 0;
//    rBuffer <= 0;
//    rAddStart <= 0;
//    rResultBuffer <= 0;
//  end 
//  else begin
//    case (rFSM)

//      // -------------------------
//      // IDLE
//      // -------------------------
//      s_IDLE : begin
//        rCnt <= 0;
//        rFSM <= s_WAIT_RX;
//      end

//      // -------------------------
//      // RECEIVE 128 BYTES
//      // -------------------------
//      s_WAIT_RX : begin
//        if (wRxDone) begin 
//          rBuffer <= {rBuffer[(NBYTES-1)*8-1:0], wRxByte};

//          if (rCnt == NBYTES - 1) begin
//            rCnt <= 0;
//            rFSM <= s_START_ADD;   // ? CHANGED
//          end else begin
//            rCnt <= rCnt + 1;
//          end
//        end
//      end

//      // -------------------------
//      // START ADDER (1 cycle pulse)
//      // -------------------------
//      s_START_ADD : begin
//        rAddStart <= 1;           // pulse start
//        rFSM <= s_WAIT_ADD;
//      end

//      // -------------------------
//      // WAIT FOR ADDER
//      // -------------------------
//      s_WAIT_ADD : begin
//        rAddStart <= 0;

//        if (wAddDone) begin
//          rResultBuffer <= wResult; // store result
//          rCnt <= 0;
//          rFSM <= s_TX;
//        end
//      end

//      // -------------------------
//      // TRANSMIT RESULT (65 bytes)
//      // -------------------------
//      s_TX : begin
//        if (rCnt < 65) begin   // 513 bits = 65 bytes
//          if (!wTxBusy) begin
//            rTxStart <= 1;
//            rTxByte <= rResultBuffer[512:505]; // top byte

//            rResultBuffer <= {rResultBuffer[504:0], 8'b0};
//            rCnt <= rCnt + 1;

//            rFSM <= s_WAIT_TX;
//          end
//        end 
//        else begin
//          rFSM <= s_DONE;
//        end
//      end

//      // -------------------------
//      // WAIT TX DONE
//      // -------------------------
//      s_WAIT_TX : begin
//        rTxStart <= 0;
//        if (wTxDone) begin
//          rFSM <= s_TX;
//        end
//      end

//      // -------------------------
//      // DONE
//      // -------------------------
//      s_DONE : begin
//        rFSM <= s_IDLE;
//      end

//      default : rFSM <= s_IDLE;

//    endcase
//  end
//end

//endmodule

`timescale 1ns / 1ps

module uart_top #(
<<<<<<< HEAD
    parameter   NBYTES        = 128,
    parameter   CLK_FREQ      = 125_000_000,
    parameter   BAUD_RATE     = 115_200
=======
    parameter    NBYTES        = 128,
    parameter    CLK_FREQ      = 125_000_000,
    parameter    BAUD_RATE     = 115_200
>>>>>>> temp-branch
  )  
  (
    input  wire    iClk, iRst,
    input  wire    iRx,
    output wire    oTx
  );
  
  // Buffer to store received bytes and then transmit them
  reg [NBYTES*8-1:0] rBuffer;
  
<<<<<<< HEAD
  
=======
>>>>>>> temp-branch
  // Operands for Addition
  wire [511:0] opA;
  wire [511:0] opB;
  
  assign opA = rBuffer[1023:512];
  assign opB = rBuffer[511:0];
  
  // State definition  
<<<<<<< HEAD
  localparam s_IDLE        = 3'b000;
localparam s_WAIT_RX     = 3'b001;
localparam s_START_ADD   = 3'b010;
localparam s_WAIT_ADD    = 3'b011;
localparam s_TX          = 3'b100;
localparam s_WAIT_TX     = 3'b101;
localparam s_DONE        = 3'b110;
   
  reg [2:0]   rFSM;  
  reg [$clog2(NBYTES):0] rCnt;

  // --- UART TX Signals ---
  reg         rTxStart;
  reg [7:0]   rTxByte;
  wire        wTxBusy;
  wire        wTxDone;
  
  // MP Adder stuff
  wire [512:0] wResult;
  wire wAddDone;
  reg rAddStart;
  reg [512:0] rResultBuffer;
=======
  localparam s_IDLE          = 3'b000;
  localparam s_WAIT_RX       = 3'b001;
  localparam s_START_ADD     = 3'b010;
  localparam s_WAIT_ADD      = 3'b011;
  localparam s_TX            = 3'b100;
  localparam s_WAIT_TX       = 3'b101;
  localparam s_DONE          = 3'b110;
  // Added states for cycle count transmission
  localparam s_TX_COUNT      = 3'b111; 
  localparam s_WAIT_TX_COUNT = 3'b111; // Note: reuse states if you have spare bits or expand FSM width

  reg [3:0]    rFSM; // Expanded to 4 bits to accommodate more states
  reg [7:0]    rCnt;
  reg [31:0]   rLatencyCnt;
  reg [7:0]    rCountToSend [0:3];

  // --- UART TX Signals ---
  reg          rTxStart;
  reg [7:0]    rTxByte;
  wire         wTxBusy;
  wire         wTxDone;
  
  // MP Adder stuff
  wire [512:0] wResult;
  wire         wAddDone;
  reg          rAddStart;
  reg [512:0]  rResultBuffer;
>>>>>>> temp-branch
       
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
    
<<<<<<< HEAD
    always @(posedge iClk)
begin
=======
  always @(posedge iClk) begin
>>>>>>> temp-branch
  if (iRst == 1) begin
    rFSM <= s_IDLE;
    rTxStart <= 0;
    rCnt <= 0;
    rTxByte <= 0;
    rBuffer <= 0;
    rAddStart <= 0;
    rResultBuffer <= 0;
<<<<<<< HEAD
  end 
  else begin
    case (rFSM)

      // -------------------------
      // IDLE
      // -------------------------
      s_IDLE : begin
        rCnt <= 0;
        rFSM <= s_WAIT_RX;
      end

      // -------------------------
      // RECEIVE 128 BYTES
      // -------------------------
      s_WAIT_RX : begin
        if (wRxDone) begin 
          rBuffer <= {rBuffer[(NBYTES-1)*8-1:0], wRxByte};

          if (rCnt == NBYTES - 1) begin
            rCnt <= 0;
            rFSM <= s_START_ADD;   // ? CHANGED
=======
    rLatencyCnt <= 0;
  end 
  else begin
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
>>>>>>> temp-branch
          end else begin
            rCnt <= rCnt + 1;
          end
        end
      end

<<<<<<< HEAD
      // -------------------------
      // START ADDER (1 cycle pulse)
      // -------------------------
      s_START_ADD : begin
        rAddStart <= 1;           // pulse start
        rFSM <= s_WAIT_ADD;
      end

      // -------------------------
      // WAIT FOR ADDER
      // -------------------------
      s_WAIT_ADD : begin
        rAddStart <= 0;

        if (wAddDone) begin
          rResultBuffer <= wResult; // store result
=======
      s_START_ADD : begin
        rAddStart <= 1;
        rLatencyCnt <= 0; // Start counting
        rFSM <= s_WAIT_ADD;
      end

      s_WAIT_ADD : begin
        rAddStart <= 0;
        rLatencyCnt <= rLatencyCnt + 1; // Increment counter
        if (wAddDone) begin
          rResultBuffer <= wResult;
          // Split count into bytes
          rCountToSend[0] <= rLatencyCnt[31:24];
          rCountToSend[1] <= rLatencyCnt[23:16];
          rCountToSend[2] <= rLatencyCnt[15:8];
          rCountToSend[3] <= rLatencyCnt[7:0];
>>>>>>> temp-branch
          rCnt <= 0;
          rFSM <= s_TX;
        end
      end

<<<<<<< HEAD
      // -------------------------
      // TRANSMIT RESULT (65 bytes)
      // -------------------------
      s_TX : begin
        if (rCnt < 65) begin   // 513 bits = 65 bytes
          if (!wTxBusy) begin
            rTxStart <= 1;
            rTxByte <= rResultBuffer[512:505]; // top byte

            rResultBuffer <= {rResultBuffer[504:0], 8'b0};
            rCnt <= rCnt + 1;

            rFSM <= s_WAIT_TX;
          end
        end 
        else begin
=======
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
          rFSM <= 4'b111; // s_TX_COUNT
        end
      end

      s_WAIT_TX : begin
        rTxStart <= 0;
        if (wTxDone) rFSM <= s_TX;
      end

      // State to send the 4 bytes of rLatencyCnt
      4'b111 : begin
        if (rCnt < 4) begin
          if (!wTxBusy) begin
            rTxStart <= 1;
            rTxByte <= rCountToSend[rCnt];
            rCnt <= rCnt + 1;
            rFSM <= 4'b1000; // s_WAIT_TX_COUNT
          end
        end else begin
>>>>>>> temp-branch
          rFSM <= s_DONE;
        end
      end

<<<<<<< HEAD
      // -------------------------
      // WAIT TX DONE
      // -------------------------
      s_WAIT_TX : begin
        rTxStart <= 0;
        if (wTxDone) begin
          rFSM <= s_TX;
        end
      end

      // -------------------------
      // DONE
      // -------------------------
      s_DONE : begin
        rFSM <= s_IDLE;
      end

      default : rFSM <= s_IDLE;

    endcase
  end
end
  
  
//  always @(posedge iClk)
//  begin
//    if (iRst == 1) begin
//      rFSM <= s_IDLE;
//      rTxStart <= 0;
//      rCnt <= 0;
//      rTxByte <= 0;
//      rBuffer <= 0;
//    end 
//    else begin
//      case (rFSM)

//        s_IDLE : begin
//          rCnt <= 0;
//          rFSM <= s_WAIT_RX;
//        end
          
//        s_WAIT_RX : begin
//  // Check the signal coming FROM the uart_rx module
//  if (wRxDone == 1'b1) begin 
    
//    // Shift the new byte into the buffer
//    // We take the current buffer, shift it left by 8 bits, 
//    // and put the new byte (wRxByte) at the end.
//    rBuffer <= {rBuffer[(NBYTES-1)*8-1:0], wRxByte};
    
//    // Keep track of how many bytes we have collected
//    if (rCnt == NBYTES - 1) begin
//      rFSM <= s_TX;  // Once we have 12 bytes, go to transmit state
//      rCnt <= 0;     // Reset counter for the next phase
//    end else begin
//      rCnt <= rCnt + 1;
//    end
//  end
//  // If wRxDone is 0, we just stay in this state and wait
//end
             
//        s_TX : begin
//          if (rCnt < NBYTES) begin
//            if (!wTxBusy) begin
//                rFSM <= s_WAIT_TX;
//                rTxStart <= 1; 
//                // Send the leftmost (oldest received) byte first
//                rTxByte <= rBuffer[NBYTES*8-1:NBYTES*8-8];        
//                // Shift the buffer left to prepare the next byte
//                rBuffer <= {rBuffer[(NBYTES-1)*8-1:0], 8'h00};    
//                rCnt <= rCnt + 1;
//            end
//          end 
//          else begin
//            rFSM <= s_DONE;
//          end
//        end 
            
//        s_WAIT_TX : begin
//          rTxStart <= 0; // Pulse start only for one cycle
//          if (wTxDone) begin
//            rFSM <= s_TX;
//          end
//        end 
              
//        s_DONE : begin
//          // Return to IDLE to allow a new string to be sent
//          rFSM <= s_IDLE;
//        end 

//        default : rFSM <= s_IDLE;
//      endcase
//    end
//  end       
    
=======
      4'b1000 : begin
        rTxStart <= 0;
        if (wTxDone) rFSM <= 4'b111;
      end

      s_DONE : rFSM <= s_IDLE;
      default : rFSM <= s_IDLE;
    endcase
  end
end
>>>>>>> temp-branch
endmodule