`timescale 1ns / 1ps

module uart_rx #(
    parameter   CLK_FREQ      = 125_000_000,
    parameter   BAUD_RATE     = 115_200,
    parameter   CLKS_PER_BIT  = CLK_FREQ / BAUD_RATE
  )
  (
    input wire        iClk, iRst,
    input wire        iRxSerial,
    output wire [7:0] oRxByte, 
    output wire       oRxDone
   );

  // State definitions
  localparam sIDLE         = 3'b000;
  localparam sRX_START     = 3'b001; // Align to middle of start bit
  localparam sRX_DATA      = 3'b010; // Sample 8 data bits
  localparam sRX_STOP      = 3'b011; // Validate stop bit
  localparam sDONE         = 3'b100; // Pulse Done signal

  // Registers for FSM and Sampling
  reg [2:0] rFSM_Current, wFSM_Next;
  reg [$clog2(CLKS_PER_BIT):0] rCnt_Current, wCnt_Next;
  reg [2:0] rBit_Current, wBit_Next;
  reg [7:0] rRxData_Current, wRxData_Next;

  // Double-registering to prevent metastability
  reg rRx1, rRx2;
  always @(posedge iClk) begin
    rRx1 <= iRxSerial;
    rRx2 <= rRx1;
  end

  // Register Update Block
  always @(posedge iClk) begin
    if (iRst) begin
      rFSM_Current    <= sIDLE;
      rCnt_Current    <= 0;
      rBit_Current    <= 0;
      rRxData_Current <= 0;
    end else begin
      rFSM_Current    <= wFSM_Next;
      rCnt_Current    <= wCnt_Next;
      rBit_Current    <= wBit_Next;
      rRxData_Current <= wRxData_Next;
    end
  end

  // Next State Logic
  always @(*) begin
    // Default assignments to avoid latches
    wFSM_Next    = rFSM_Current;
    wCnt_Next    = rCnt_Current;
    wBit_Next    = rBit_Current;
    wRxData_Next = rRxData_Current;

    case (rFSM_Current)
      sIDLE: begin
        wCnt_Next = 0;
        wBit_Next = 0;
        if (rRx2 == 0) // Start bit detected (line goes Low)
          wFSM_Next = sRX_START;
      end

      sRX_START: begin
        // Wait until we reach the MIDDLE of the start bit
        if (rCnt_Current == (CLKS_PER_BIT-1)/2) begin
          if (rRx2 == 0) begin // Verify it's still low
            wFSM_Next = sRX_DATA;
            wCnt_Next = 0;
          end else
            wFSM_Next = sIDLE; // Was just a noise glitch
        end else begin
          wCnt_Next = rCnt_Current + 1;
        end
      end

      sRX_DATA: begin
        if (rCnt_Current < CLKS_PER_BIT - 1) begin
          wCnt_Next = rCnt_Current + 1;
        end else begin
          wCnt_Next = 0;
          // SAMPLE BIT: Shift the current bit into the MSB of our register
          wRxData_Next = {rRx2, rRxData_Current[7:1]};
          
          if (rBit_Current < 7)
            wBit_Next = rBit_Current + 1;
          else
            wFSM_Next = sRX_STOP;
        end
      end

      sRX_STOP: begin
        // Wait one full bit period for the Stop bit (should be High)
        if (rCnt_Current < CLKS_PER_BIT - 1) begin
          wCnt_Next = rCnt_Current + 1;
        end else begin
          wFSM_Next = sDONE;
          wCnt_Next = 0;
        end
      end

      sDONE: begin
        wFSM_Next = sIDLE;
      end

      default: wFSM_Next = sIDLE;
    endcase
  end

  // Output Logic
  assign oRxByte = rRxData_Current;
  assign oRxDone = (rFSM_Current == sDONE);

endmodule