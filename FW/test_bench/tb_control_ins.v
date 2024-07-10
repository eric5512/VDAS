`timescale 1ns/1ps

module tb_control_ins;

    reg clk;
    reg [7:0] in_read;
    reg em_read;
    wire pp_read;
    wire [4:0] activemods;
    wire [7:0] dout;
    wire [11:0] aout0;
    wire [11:0] aout1;
    wire [9:0] pre;
    reg rst_n;

    reg lopp;

    // Instantiate the control_ins module
    control_ins uut (
        .clk(clk),
        .in_read(in_read),
        .em_read(em_read),
        .pp_read(pp_read),
        .activemods(activemods),
        .dout(dout),
        .aout0(aout0),
        .aout1(aout1),
        .pre(pre),
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
        $dumpfile("tb_control_ins.vcd");
        $dumpvars(0, tb_control_ins);
    end

    // Test sequence
    initial begin
        // Initialize inputs
        rst_n = 0;
        in_read = 8'b0;
        em_read = 1;

        // Apply reset
        #(CLOCK_PERIOD) rst_n = 1;

        // Apply some test vectors
        #(CLOCK_PERIOD*4) em_read = 0; in_read = 8'b00100110; // Example instruction for SETDIGITAL_I

          // Example instruction for SETANALOG_I 
        #(CLOCK_PERIOD) em_read = 0; in_read = 8'b01010101;
        #(CLOCK_PERIOD) em_read = 0; in_read = 8'b01010101; // Example instruction for SETANALOG_I

        #(CLOCK_PERIOD) em_read = 0; in_read = 8'b00000000; // Example instruction for ACTIVATE_I
        #(CLOCK_PERIOD) em_read = 1;

        // Finish simulation
        #(CLOCK_PERIOD*5) $finish;
    end

endmodule
