module control(
    input wire clk,
    // Read queue
    input wire [7:0] in_read,
    input wire em_read,
    output reg pp_read,
    // Write queue
    output reg [7:0] out_write,
    output reg ld_write,
    // ADC0 queue
    input wire [9:0] in_adc0,
    input wire em_adc0,
    output reg pp_adc0,
    // ADC1 queue
    input wire [9:0] in_adc1,
    input wire em_adc1,
    output reg pp_adc1,
    // CADC0 queue
    input wire [9:0] in_cadc0,
    input wire em_cadc0,
    output reg pp_cadc0,
    // CADC1 queue
    input wire [9:0] in_cadc1,
    input wire em_cadc1,
    output reg pp_cadc1,
    // DIN queue
    input wire [7:0] in_din,
    input wire em_din,
    output reg pp_din,
    // Output signals
    output reg [4:0] activemods, // [DoX, ADCX, CurrentADCX]
    output reg [7:0] dout,
    output reg [11:0] aout0,
    output reg [11:0] aout1,
    output [9:0] pre,
    // RST signal
    input wire rst_n
);

    control_ins ins (
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

    control_data data (
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

endmodule
