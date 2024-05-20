`default_nettype none

module tb_AWG;

reg ld, sel, ck, rst_n;
reg [3:0] pre;
reg [11:0] in;
reg [9:0] addr;

wire [11:0] out;

AWG AWG_obj(in, ld, addr, rst_n, pre, sel, out, ck);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) ck=~ck;

initial begin
    $dumpfile("tb_AWG.vcd");
    $dumpvars(0, tb_AWG);
end

integer i;

initial begin
    ck = 1'b0;
    pre = 4'd1;
    ld = 1'b1;
    sel = 1'b0;
    rst_n = 1'b1;
    for (i = 0; i < 2**8; i = i + 1) begin
        in = i;
        addr = i;
        #(CLK_PERIOD);
    end

    ld = 1'b0;
    rst_n = 1'b0;
    sel = 1'b1;
    #(CLK_PERIOD) rst_n = 1'b1;

    repeat(20) #(CLK_PERIOD);

    pre = 4'd2;

    repeat(20) #(CLK_PERIOD);

    pre = 4'b1111;

    repeat(20) #(CLK_PERIOD);

    in = 12'hAE;
    sel = 1'b0;

    repeat(2) #(CLK_PERIOD);

    $finish;
end

endmodule
`default_nettype wire