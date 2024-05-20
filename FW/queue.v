module queue
	#(parameter PTBITS = 6,
			 	NBITS = 8)
	(in, ck, ld, pp, rst_n, em, out);

input [NBITS-1:0] in;
input ck, ld, pp, rst_n;

output em;
output [NBITS-1:0] out;

localparam SIZE = 2**PTBITS;

reg [NBITS-1:0] fifo [SIZE];
reg [PTBITS-1:0] read_pt = {PTBITS{1'b0}};
reg [PTBITS-1:0] write_pt = {PTBITS{1'b0}};

assign em = (read_pt == write_pt);
assign out = fifo[read_pt];

always @(posedge ck or negedge rst_n) begin
	if (rst_n == 1'b0) begin
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