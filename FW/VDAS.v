module VDAS(clk, din, adc0, adc1, curr0, curr1, dout, dac0, dac1, ser_rx, ser_tx);
input clk;
input [7:0] din;
input [9:0] adc0;
input [9:0] adc1;
input [11:0] curr0;
input [11:0] curr1;
input ser_rx;
output ser_tx;
output [11:0] dac0;
output [11:0] dac1;
output [7:0] dout;

wire rst_n;
wire [11:0] activemods;
wire [9:0] pre;

wire [7:0] in_rx;
wire [7:0] out_rx;
wire ld_rx;
wire pp_rx;
wire em_rx;

wire [7:0] in_tx;
wire [7:0] out_tx;
wire ld_tx;
wire pp_tx;
wire em_tx;

wire clk_din;
wire clk_adc0;
wire clk_adc1;
wire clk_curr0;
wire clk_curr1;

wire [7:0] out_din;
wire pp_din;
wire rst_n;
wire em_din;

wire [11:0] in_adc0;
wire [11:0] out_adc0;
wire pp_adc0;
wire em_adc0;

wire [11:0] in_adc1;
wire [11:0] out_adc1;
wire pp_adc1;
wire em_adc1;

wire [11:0] in_curr0;
wire [11:0] out_curr0;
wire pp_curr0;
wire em_curr0;

wire [11:0] in_curr1;
wire [11:0] out_curr1;
wire pp_curr1;
wire em_curr1;

control cont(
    .clk(clk),

    .in_read(in_rx),
    .em_read(em_rx),
    .pp_read(pp_rx),

    .out_write(out_tx),
    .ld_write(ld_tx),

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

    .activemods(activemods), 
    .dout(dout),
    .aout0(aout0),
    .aout1(aout1),
    .pre(pre),

    .rst_n(rst_n),
    .rst_out(rst_out)
);

uart_rx rx (
    .i_Clock(clk),
    .i_Rx_Serial(ser_rx),
    .o_Rx_DV(pp_rx),
    .o_Rx_Byte(in_rx)
);
uart_tx tx (
    .i_Clock(clk),
    .i_Tx_DV(!em_tx),
    .i_Tx_Byte(out_tx), 
    .o_Tx_Active(1'b1),
    .o_Tx_Serial(ser_tx),
    .o_Tx_Done(ld_tx)
);

queue rx_queue (
    .in(in_rx), 
    .ck(clk), 
    .ld(ld_rx), 
    .pp(pp_rx), 
    .rst_n(rst_n), 
    .em(em_rx), 
    .out(out_rx)
);
queue tx_queue (
    .in(in_tx), 
    .ck(clk), 
    .ld(ld_tx), 
    .pp(pp_tx), 
    .rst_n(rst_n), 
    .em(em_tx), 
    .out(out_tx)
);

divider din_clk (
    .clk(clk), 
    .pre(pre), 
    .clk_out(clk_din) 
);

queue din_queue (
    .in(din), 
    .ck(clk_din), 
    .ld(activemods[11]), 
    .pp(pp_din), 
    .rst_n(rst_n), 
    .em(em_din), 
    .out(out_din)
);

divider adc0_clk (
    .clk(clk), 
    .pre(pre), 
    .clk_out(clk_adc0)
);
divider adc1_clk (
    .clk(clk), 
    .pre(pre), 
    .clk_out(clk_adc1)
);

queue adc0_queue (
    .in(in_adc0), 
    .ck(clk_adc0), 
    .ld(activemods[3]), 
    .pp(pp_adc0), 
    .rst_n(rst_n), 
    .em(em_adc0), 
    .out(out_adc0)
);
queue adc1_queue (
    .in(in_adc1), 
    .ck(clk_adc1), 
    .ld(activemods[2]), 
    .pp(pp_adc1), 
    .rst_n(rst_n), 
    .em(em_adc1), 
    .out(out_adc1)
);

divider curr0_clk (
    .clk(clk), 
    .pre(pre), 
    .clk_out(clk_curr0)
);
divider curr1_clk (
    .clk(clk), 
    .pre(pre), 
    .clk_out(clk_curr1)
);

deltasigma curr0_i (
    .rst_n(rst_n), 
    .in(curr0), 
    .clk(clk), 
    .dclk(clk_curr0), 
    .out()
);
deltasigma curr1_i (
    .rst_n(rst_n), 
    .in(curr1), 
    .clk(clk), 
    .dclk(clk_curr1), 
    .out()
);

queue curr0_queue (
    .in(in_curr0), 
    .ck(clk_curr0), 
    .ld(activemods[1]), 
    .pp(pp_curr0), 
    .rst_n(rst_n), 
    .em(em_curr0), 
    .out(out_curr0)
);
queue curr1_queue (
    .in(in_curr1), 
    .ck(clk_curr1), 
    .ld(activemods[0]), 
    .pp(pp_curr1), 
    .rst_n(rst_n), 
    .em(em_curr1), 
    .out(out_curr1)
);

AWG dac0_i (
    .in(in_dac0), 
    .ld(),
    .addr(),
    .rst_n(rst_n), 
    .pre(pre),
    .sel(1'b0), 
    .out(dac0), 
    .ck(clk)
);
AWG dac1_i (
    .in(in_dac1), 
    .ld(), 
    .addr(), 
    .rst_n(rst_n), 
    .pre(pre), 
    .sel(1'b0), 
    .out(dac1), 
    .ck(clk)
);


endmodule