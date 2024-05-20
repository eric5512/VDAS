module tb_queue;
reg ck, ld, pp, rst_n;
reg [7:0] in;

wire [7:0] out;
wire em;

queue queue_obj(in, ck, ld, pp, rst_n, em, out);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) ck=~ck;

initial begin
    $dumpfile("tb_queue.vcd");
    $dumpvars(0, queue_obj);
end

initial begin
    $monitor("[$monitor] time=%0t, in=%0d, ld=%0d, pp=%0d, rst_n=%0d, em=%0d, out=%0d", $time, in, ld, pp, rst_n, em, out);
    ck = 1'b0;
    ld = 1'b0;
    pp = 1'b0;
    rst_n = 1'b0;

    #(CLK_PERIOD) rst_n = 1'b1;

    ld = 1'b1;
    in = 8'h10;
    #(CLK_PERIOD) in = 8'h09;
    #(CLK_PERIOD) in = 8'h0A;

    #(CLK_PERIOD) ld = 1'b0;

    pp = 1'b1;

    #(CLK_PERIOD*4) $finish;
end

endmodule
`default_nettype wire