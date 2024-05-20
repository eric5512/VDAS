module parallel
	#(parameter NBITS = 12)
	(in, ld, out, ck);

input [NBITS-1:0]in;
input ld, ck;
output reg [NBITS-1:0]out;

always @(posedge ck)
	if (ld == 1'b1) out <= in;

endmodule