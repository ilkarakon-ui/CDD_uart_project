`timescale 1ns / 1ps

module brent_kung_32 (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire        Cin,
    output wire [31:0] Sum,
    output wire        Cout
);
    // 2D arrays to hold propagate and generate signals across all 9 logic levels
    wire [31:0] p [0:9];
    wire [31:0] g [0:9];

    // Level 0: Base bitwise Propagate and Generate
    assign p[0] = A ^ B;
    assign g[0] = A & B;

    genvar i;
    generate
        // -----------------------------------------
        // FORWARD TREE
        // -----------------------------------------
        
        // Level 1: Distance 1 (Targets: 1, 3, 5... 31)
        for (i = 0; i < 32; i = i + 1) begin : L1
            if (i % 2 == 1) begin
                assign p[1][i] = p[0][i] & p[0][i-1];
                assign g[1][i] = g[0][i] | (p[0][i] & g[0][i-1]);
            end else begin
                assign p[1][i] = p[0][i];
                assign g[1][i] = g[0][i];
            end
        end

        // Level 2: Distance 2 (Targets: 3, 7, 11... 31)
        for (i = 0; i < 32; i = i + 1) begin : L2
            if ((i + 1) % 4 == 0) begin
                assign p[2][i] = p[1][i] & p[1][i-2];
                assign g[2][i] = g[1][i] | (p[1][i] & g[1][i-2]);
            end else begin
                assign p[2][i] = p[1][i];
                assign g[2][i] = g[1][i];
            end
        end

        // Level 3: Distance 4 (Targets: 7, 15, 23, 31)
        for (i = 0; i < 32; i = i + 1) begin : L3
            if ((i + 1) % 8 == 0) begin
                assign p[3][i] = p[2][i] & p[2][i-4];
                assign g[3][i] = g[2][i] | (p[2][i] & g[2][i-4]);
            end else begin
                assign p[3][i] = p[2][i];
                assign g[3][i] = g[2][i];
            end
        end

        // Level 4: Distance 8 (Targets: 15, 31)
        for (i = 0; i < 32; i = i + 1) begin : L4
            if ((i + 1) % 16 == 0) begin
                assign p[4][i] = p[3][i] & p[3][i-8];
                assign g[4][i] = g[3][i] | (p[3][i] & g[3][i-8]);
            end else begin
                assign p[4][i] = p[3][i];
                assign g[4][i] = g[3][i];
            end
        end

        // Level 5: Distance 16 (Target: 31)
        for (i = 0; i < 32; i = i + 1) begin : L5
            if ((i + 1) % 32 == 0) begin
                assign p[5][i] = p[4][i] & p[4][i-16];
                assign g[5][i] = g[4][i] | (p[4][i] & g[4][i-16]);
            end else begin
                assign p[5][i] = p[4][i];
                assign g[5][i] = g[4][i];
            end
        end

        // -----------------------------------------
        // INVERSE TREE
        // -----------------------------------------
        
        // Level 6: Distance 8 (Target: 23)
        for (i = 0; i < 32; i = i + 1) begin : L6
            if (i == 23) begin
                assign p[6][i] = p[5][i] & p[5][i-8];
                assign g[6][i] = g[5][i] | (p[5][i] & g[5][i-8]);
            end else begin
                assign p[6][i] = p[5][i];
                assign g[6][i] = g[5][i];
            end
        end

        // Level 7: Distance 4 (Targets: 11, 19, 27)
        for (i = 0; i < 32; i = i + 1) begin : L7
            if (i == 11 || i == 19 || i == 27) begin
                assign p[7][i] = p[6][i] & p[6][i-4];
                assign g[7][i] = g[6][i] | (p[6][i] & g[6][i-4]);
            end else begin
                assign p[7][i] = p[6][i];
                assign g[7][i] = g[6][i];
            end
        end

        // Level 8: Distance 2 (Targets: 5, 9, 13, 17, 21, 25, 29)
        for (i = 0; i < 32; i = i + 1) begin : L8
            if (i == 5 || i == 9 || i == 13 || i == 17 || i == 21 || i == 25 || i == 29) begin
                assign p[8][i] = p[7][i] & p[7][i-2];
                assign g[8][i] = g[7][i] | (p[7][i] & g[7][i-2]);
            end else begin
                assign p[8][i] = p[7][i];
                assign g[8][i] = g[7][i];
            end
        end

        // Level 9: Distance 1 (Targets: All even bits except 0)
        for (i = 0; i < 32; i = i + 1) begin : L9
            if (i % 2 == 0 && i != 0) begin
                assign p[9][i] = p[8][i] & p[8][i-1];
                assign g[9][i] = g[8][i] | (p[8][i] & g[8][i-1]);
            end else begin
                assign p[9][i] = p[8][i];
                assign g[9][i] = g[8][i];
            end
        end
    endgenerate

    // -----------------------------------------
    // Final Sum and Carry Logic
    // -----------------------------------------
    wire [32:0] C;
    assign C[0] = Cin;
    
    generate
        for (i = 0; i < 32; i = i + 1) begin : FINAL
            assign C[i+1] = g[9][i] | (p[9][i] & Cin);
            assign Sum[i] = p[0][i] ^ C[i];
        end
    endgenerate

    assign Cout = C[32];

endmodule