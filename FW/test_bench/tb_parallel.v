`default_nettype none

module tb_parallel;
reg [11:0]in;
reg ck, ld;
wire [11:0]out;

parallel parallel_obj(in, ld, out, ck);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) ck=~ck;

initial begin
	$dumpfile("tb_parallel.vcd");
	$dumpvars(0, tb_parallel);
end

initial begin
	$monitor("[$monitor] time=%0t, in=%0d, ld=%0d, out=%0d", $time, in, ld, out);

	ck = 1'b0;
	ld = 1'b0;
	in = 12'b0;

	#(CLK_PERIOD) ld = 1'b1;
	in = 12'b10;

	#(CLK_PERIOD) ld = 1'b1;
	in = 12'b100;

	#(CLK_PERIOD) ld = 1'b1;
	in = 12'b1000;

	#(CLK_PERIOD) $finish;
end

endmodule
`default_nettype wire