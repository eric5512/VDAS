`default_nettype none

module tb_uart_tx;
reg clk;
reg rst_n;

uart_tx UART_TX_INST
(.i_Clock(r_Clock),
    .i_Tx_DV(r_Tx_DV),
    .i_Tx_Byte(r_Tx_Byte),
    .o_Tx_Active(),
    .o_Tx_Serial(),
    .o_Tx_Done(w_Tx_Done)
    );

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk=~clk;

initial begin
    $dumpfile("tb_uart_tx.vcd");
    $dumpvars(0, tb_uart_tx);
end

initial begin
    #1 rst_n<=1'bx;clk<=1'bx;
    #(CLK_PERIOD*3) rst_n<=1;
    #(CLK_PERIOD*3) rst_n<=0;clk<=0;
    repeat(5) @(posedge clk);
    rst_n<=1;
    @(posedge clk);
    repeat(2) @(posedge clk);
    $finish(2);
end

endmodule
`default_nettype wire