`timescale 1ns/1ps

module tb_control_data;

    reg clk;
    wire [7:0] out_write;
    wire ld_write;
    reg [9:0] in_adc0;
    reg em_adc0;
    wire pp_adc0;
    reg [9:0] in_adc1;
    reg em_adc1;
    wire pp_adc1;
    reg [9:0] in_cadc0;
    reg em_cadc0;
    wire pp_cadc0;
    reg [9:0] in_cadc1;
    reg em_cadc1;
    wire pp_cadc1;
    reg [7:0] in_din;
    reg em_din;
    wire pp_din;
    reg rst_n;

    // Instantiate the control_data module
    control_data uut (
        .clk(clk),
        .out_write(out_write),
        .ld_write(ld_write),
        .in_adc0(in_adc0),
        .em_adc0(em_adc0),
        .pp_adc0(pp_adc0),
        .in_adc1(in_adc1),
        .em_adc1(em_adc1),
        .pp_adc1(pp_adc1),
        .in_cadc0(in_cadc0),
        .em_cadc0(em_cadc0),
        .pp_cadc0(pp_cadc0),
        .in_cadc1(in_cadc1),
        .em_cadc1(em_cadc1),
        .pp_cadc1(pp_cadc1),
        .in_din(in_din),
        .em_din(em_din),
        .pp_din(pp_din),
        .rst_n(rst_n)
    );

    localparam CLOCK_PERIOD = 80;
    localparam CLOCK_SEMIPERIOD = CLOCK_PERIOD / 2;

    // Clock generation
    initial begin
        clk = 1;
        forever #(CLOCK_SEMIPERIOD) clk = ~clk; // 80ns period
    end

    initial begin
        $dumpfile("tb_control_data.vcd");
        $dumpvars(0, tb_control_data);
    end

    // Test sequence
    initial begin
        // Initialize inputs
        rst_n = 0;
        in_adc0 = 10'b0;
        em_adc0 = 1;
        in_adc1 = 10'b0;
        em_adc1 = 1;
        in_cadc0 = 10'b0;
        em_cadc0 = 1;
        in_cadc1 = 10'b0;
        em_cadc1 = 1;
        in_din = 8'b0;
        em_din = 1;

        // Apply reset
        #(CLOCK_PERIOD) rst_n = 1;

        // Apply some test vectors
        #(CLOCK_PERIOD) em_din = 0; in_din = 8'b10101010; // Example data for DIN queue
        #(CLOCK_PERIOD) em_din = 1;

        #(CLOCK_PERIOD) em_adc0 = 0; in_adc0 = 10'b1100110011; // Example data for ADC0 queue
        #(CLOCK_PERIOD) em_adc0 = 1;

        #(CLOCK_PERIOD) em_adc1 = 0; in_adc1 = 10'b1111000011; // Example data for ADC1 queue
        #(CLOCK_PERIOD) em_adc1 = 1;

        #(CLOCK_PERIOD) em_cadc0 = 0; in_cadc0 = 10'b0000111100; // Example data for CADC0 queue
        #(CLOCK_PERIOD) em_cadc0 = 1;

        #(CLOCK_PERIOD) em_cadc1 = 0; in_cadc1 = 10'b0011001100; // Example data for CADC1 queue
        #(CLOCK_PERIOD) em_cadc1 = 1;

        // More test vectors can be added here...

        // Finish simulation
        #200 $finish;
    end

    

endmodule
