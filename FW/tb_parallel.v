module tb_parallel;

reg [11:0]in;
reg ck;
wire [11:0]out;

parallel p0(in, out, ck);

always #10 ck = ~ck;

initial begin
	$monitor ("Output (Time=%0t): in=0x%0d out=0x%0d", $time, in, out);
	
	ck = 0;
	in = 12'b111111000000;
	
	#20 in = 12'b000000111111;

	#20 $finish;
end

endmodule