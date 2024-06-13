`timescale 1ns/1ns
module tb_deltasigma;
    // Inputs
    reg in;
    reg rst_n;
    reg adc_clk;
    reg clk;

    // Outputs
    wire [19:0] out;

    // Instantiate the deltasigma module
    deltasigma ds (
        .in(in),
        .rst_n(rst_n),
        .clk(adc_clk),
        .dclk(clk),
        .out(out)
    );

    localparam CLK_PERIOD = 40;
    localparam OSR = 3;
    localparam FACTOR = 2**OSR;

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

// module tb_deltasigma;
//     // Inputs
//     reg in;
//     reg rst_n;
//     reg [1:0] osr;
//     reg clk;
//     reg clk_out;

//     // Outputs
//     wire [19:0] out;

//     // Instantiate the deltasigma module
//     deltasigma ds (
//         .in(in),
//         .rst_n(rst_n),
//         .osr(osr),
//         .clk(clk),
//         .out(out)
//         // .clk_out(clk_out)
//     );
//     localparam CLK_PERIOD = 40;
//     localparam OSR = 4;
//     localparam FACTOR = 2**OSR;

//     always #(CLK_PERIOD/2) clk = ~clk;

//     initial begin
//         $dumpfile("tb_deltasigma.vcd");
//         $dumpvars(0, tb_deltasigma);
//     end

//     // Test stimulus
//     initial begin
//         osr = 2'b10;
//         clk = 1'b0;
//         in = 1'b0;
//         rst_n = 1'b0;

//         #20 rst_n = 1'b1;


//         for (integer i = 0; i < 11; i = i + 1) begin
//             #((CLK_PERIOD/2*FACTOR)) in = ~in;
//         end


//         in = 1'b0;
//         #((CLK_PERIOD/2*FACTOR)*11);
//         in = 1'b1;

//         #((CLK_PERIOD/2*FACTOR)*11);

//         $finish;

//         // End simulation
//         $finish;
//     end

// endmodule