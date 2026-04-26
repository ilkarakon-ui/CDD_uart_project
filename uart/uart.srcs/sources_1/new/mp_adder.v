`timescale 1ns / 1ps

module mp_adder #(
    parameter OPERAND_WIDTH = 512,
    parameter ADDER_WIDTH   = 32 // The testbench forces this to 32
)(
    input  wire                     iClk,
    input  wire                     iRst,
    input  wire                     iStart,
    input  wire [OPERAND_WIDTH-1:0] iOpA,
    input  wire [OPERAND_WIDTH-1:0] iOpB,
    output reg  [OPERAND_WIDTH:0]   oRes,
    output reg                      oDone
);

    // -----------------------------------------
    // CSA Dynamic Scaling
    // We accept ADDER_WIDTH=32, but we process 64 bits per cycle!
    // -----------------------------------------
    localparam PROCESS_WIDTH = ADDER_WIDTH * 2; // 64 bits
    localparam N_BLOCKS      = OPERAND_WIDTH / PROCESS_WIDTH; // 512 / 64 = 8 loops!

    // Shift registers for Operands
    reg [OPERAND_WIDTH-1:0] regA;
    reg [OPERAND_WIDTH-1:0] regB;
    reg [3:0]               block_cnt; 
    reg                     carry_reg; 

    localparam IDLE = 1'b0,
               CALC = 1'b1;
    reg state;

    // -----------------------------------------
    // Carry-Select Combinational Logic (Instantiating the BK trees)
    // -----------------------------------------
    wire [ADDER_WIDTH-1:0] sum_lower;
    wire                   cout_lower;

    wire [ADDER_WIDTH-1:0] sum_upper_0, sum_upper_1;
    wire                   cout_upper_0, cout_upper_1;

    // 1. Lower 32 bits (Calculates using the actual Carry-In from the flip-flop)
    brent_kung_32 bk_lower (
        .A    (regA[ADDER_WIDTH-1:0]),
        .B    (regB[ADDER_WIDTH-1:0]),
        .Cin  (carry_reg),
        .Sum  (sum_lower),
        .Cout (cout_lower)
    );

    // 2. Upper 32 bits (Pre-computes assuming Carry-In will be 0)
    brent_kung_32 bk_upper_0 (
        .A    (regA[PROCESS_WIDTH-1:ADDER_WIDTH]),
        .B    (regB[PROCESS_WIDTH-1:ADDER_WIDTH]),
        .Cin  (1'b0), 
        .Sum  (sum_upper_0),
        .Cout (cout_upper_0)
    );

    // 3. Upper 32 bits (Pre-computes assuming Carry-In will be 1)
    brent_kung_32 bk_upper_1 (
        .A    (regA[PROCESS_WIDTH-1:ADDER_WIDTH]),
        .B    (regB[PROCESS_WIDTH-1:ADDER_WIDTH]),
        .Cin  (1'b1), 
        .Sum  (sum_upper_1),
        .Cout (cout_upper_1)
    );

    // 4. The MUX: Instantly select the correct upper sum and carry based on the lower chunk's reality
    wire [ADDER_WIDTH-1:0] final_sum_upper = cout_lower ? sum_upper_1  : sum_upper_0;
    wire                   final_cout      = cout_lower ? cout_upper_1 : cout_upper_0;
    
    // Combine the lower and chosen upper chunks into a single 64-bit result block
    wire [PROCESS_WIDTH-1:0] combined_sum = {final_sum_upper, sum_lower};

    // -----------------------------------------
    // Iterative FSM (8-Cycle Loop)
    // -----------------------------------------
    always @(posedge iClk) begin
        if (iRst) begin
            state     <= IDLE;
            block_cnt <= 0;
            oDone     <= 0;
            oRes      <= 0;
            carry_reg <= 0;
            regA      <= 0;
            regB      <= 0;
        end else begin
            case (state)
                IDLE: begin
                    oDone <= 1'b0;
                    if (iStart) begin
                        regA      <= iOpA;
                        regB      <= iOpB;
                        block_cnt <= 0;
                        carry_reg <= 1'b0;
                        state     <= CALC;
                    end
                end

                CALC: begin
                    // 1. Shift the massive 64-bit combined sum into the Result register
                    oRes[OPERAND_WIDTH-1:0] <= {combined_sum, oRes[OPERAND_WIDTH-1:PROCESS_WIDTH]};
                    
                    // 2. Capture final 64th-bit carry out
                    carry_reg <= final_cout;

                    // 3. Shift the data down by 64 bits (PROCESS_WIDTH)
                    regA <= regA >> PROCESS_WIDTH;
                    regB <= regB >> PROCESS_WIDTH;

                    // 4. Loop Logic
                    if (block_cnt == N_BLOCKS - 1) begin
                        oRes[OPERAND_WIDTH] <= final_cout; // Place the very last carry at bit 512
                        oDone <= 1'b1;
                        state <= IDLE;
                    end else begin
                        block_cnt <= block_cnt + 1;
                    end
                end
            endcase
        end
    end

endmodule