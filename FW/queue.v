module queue(in, ck, ld, pp, rst, em, out);

parameter SIZE = 16,
			 PTBITS = 4,
			 NBITS = 8;

input [NBITS-1:0] in;
input ck, ld, pp, rst;

output em;
output [NBITS-1:0] out;

reg [NBITS-1:0] fifo [SIZE];
reg [PTBITS-1:0] read_pt;
reg [PTBITS-1:0] write_pt;

assign em = (read_pt == write_pt);
assign out = fifo[read_pt];

always @(posedge ck or negedge rst) begin
	if (rst == 1'b0) begin
		read_pt = 0;
		write_pt = 0;
	end else begin
		if (ld == 1'b1) begin
			fifo[write_pt] = in;
			write_pt = write_pt + 1'b1;
		end
		if (em == 1'b0 && pp == 1'b1) begin
			read_pt = read_pt + 1'b1;
		end
	end
end

endmodule