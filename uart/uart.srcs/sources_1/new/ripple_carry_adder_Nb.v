`timescale 1ns / 1ps

module ripple_carry_adder_Nb#(
parameter N = 4
)(
input wire[N-1:0] iA, iB,
input wire iCarry,
output wire[N-1:0] oSum,
output wire oCarry
    );
  wire[N:0] c, s;
  assign c[0] = iCarry;
genvar i;
generate
for (i=0; i<N; i = i+1)
begin
Full_Adder f01(iA[i],iB[i], c[i], oSum[i], c[i+1]);
end
endgenerate
assign oCarry = c[N];
<<<<<<< HEAD
endmodule
=======
endmodule
>>>>>>> temp-branch
