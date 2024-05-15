module parallel(in, out, ck);

parameter NBITS = 12;

input [NBITS-1:0]in;
input ck;
output reg [NBITS-1:0]out;

always @(posedge ck)
	if (ck == 1'b1) out <= in;

endmodule