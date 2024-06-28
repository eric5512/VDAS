module divider (clk, pre, clk_out);
    input clk;
    input [9:0] pre;
    output clk_out;

    reg [9:0] cnt = 6'd0;

    always @(posedge clk) begin
        cnt <= cnt + 1;
        if (cnt >= pre - 1) begin
            cnt <= 10'd0;
        end
    end

    assign clk_out = (cnt < (pre >> 1))? 1'b0 : 1'b1;
endmodule