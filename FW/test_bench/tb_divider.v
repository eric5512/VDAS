module tb_divider;
    reg clk;
    reg clk_out;
    reg [5:0] pre;

    divider d
    (
        .clk_out (clk_out),
        .clk (clk),
        .pre (pre)
    );

    localparam CLK_PERIOD = 10;
    always #(CLK_PERIOD/2) clk=~clk;

    initial begin
        $dumpfile("tb_divider.vcd");
        $dumpvars(0, tb_divider);
    end

    initial begin
        clk = 1'b0;
        pre = 6'd10;

        #500;

        $finish;
    end

endmodule