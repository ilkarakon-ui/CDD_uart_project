`timescale 1ns / 1ps

module Full_Adder(
input wire iA, iB, iCarry,
output wire oSum, oCarry
);

wire a, s, c;

Half_Adder h01(iA, iB, s, c);
Half_Adder h02(s, iCarry, oSum, a);

assign oCarry = (s & iCarry) || (iA & iB);
     
<<<<<<< HEAD
endmodule
=======
endmodule
>>>>>>> temp-branch
