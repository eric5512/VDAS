module tb_deltasigma;
    reg in;
    reg rst_n;
    reg adc_clk;
    reg clk;

    wire [19:0] out;

    deltasigma ds (
        .in(in),
        .rst_n(rst_n),
        .clk(adc_clk),
        .dclk(clk),
        .out(out)
    );

    localparam CLK_PERIOD = 40;
    localparam FACTOR = 5'b01111;

    always #(CLK_PERIOD/2) adc_clk = ~adc_clk;
    always #(CLK_PERIOD/2*FACTOR) clk = ~clk;

    initial begin
        $dumpfile("tb_deltasigma.vcd");
        $dumpvars(0, tb_deltasigma);
    end

    initial begin
        adc_clk = 1'b0;
        clk = 1'b0;
        in = 1'b0;
        rst_n = 1'b0;

        #20 rst_n = 1'b1;

        for (integer i = 0; i < 11; i = i + 1) begin
            #(CLK_PERIOD/2*FACTOR) in = ~in;
        end

        in = 1'b0;
        #((CLK_PERIOD/2*FACTOR)*11);
        in = 1'b1;

        #((CLK_PERIOD/2*FACTOR)*11);

        $finish;
    end

endmodule