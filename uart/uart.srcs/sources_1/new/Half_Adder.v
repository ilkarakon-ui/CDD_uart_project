`timescale 1ns / 1ps

module Half_Adder(
input wire iA, iB,
output wire oSum, oCarry
    );

assign oSum = iA ^ iB;
assign oCarry = iA & iB;
endmodule
