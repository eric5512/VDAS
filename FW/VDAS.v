module VDAS(adc0, adc1, curr0, curr1, dac0, dac1, ser);
input [9:0]adc0;
input [9:0]adc1;
input [11:0]curr0;
input [11:0]curr1;
inout [1:0]ser;
output [11:0]dac0;
output [11:0]dac1;

assign dac0 = 12'd0;
assign dac1 = 12'd0;


endmodule