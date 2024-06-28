module tb_control;
reg clk;
reg rst_n;

control c
(
    .rst_n (rst_n),
    .clk (clk)
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk=~clk;

initial begin
    $dumpfile("tb_control.vcd");
    $dumpvars(0, tb_control);
end

initial begin
    

    $finish;
end

endmodule