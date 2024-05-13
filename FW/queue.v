module queue(in, ck, ld, pp, rst, em, out);

parameter SIZE = 16,
			 PTBITS = 4,
			 NBITS = 8;

input [NBITS-1:0] in;
input ck, ld, pp, rst;

output reg em, out;

reg [NBITS-1:0] fifo [SIZE];
reg [PTBITS-1:0] read_pt;
reg [PTBITS-1:0] write_pt;

always @(posedge ck or negedge rst) begin
	em = 1'b0;
	if (rst == 1'b0) begin
		read_pt = 0;
		write_pt = 0;
	end else
		if (ld == 1'b1) begin
			fifo[write_pt] = in;
			write_pt = write_pt + 1'b1;
		end else if (read_pt == write_pt)
			em = 1'b1;
		else if (pp == 1'b1) begin
			read_pt = read_pt + 1'b1;
		end
	out = fifo[read_pt];
end

endmodule