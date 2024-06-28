module deltasigma (rst_n, in, clk, dclk, out);
    input rst_n, in, clk, dclk;
    output reg [19:0] out;

    reg [20:0] buff, diff1, diff2, diff3;
    reg [20:0] int1, int2, sub1, sub2;
    reg [20:0] cnt;
	 reg [20:0] aux;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 21'd0;
        end else if (in) begin
            cnt <= cnt + 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            int1 <= 21'd0;
            int2 <= 21'd0;
        end else begin
            int1 <= int1 + cnt;
            int2 <= int2 + int1;
        end
    end

    always @(posedge dclk or negedge rst_n) begin
        if (!rst_n) begin
            buff <= 21'd0;
            diff1 <= 21'd0;
            diff2 <= 21'd0;
            diff3 <= 21'd0;
        end else begin
            buff <= int2;
            diff1 <= buff;
            diff2 <= sub1;
            diff3 <= sub2;
        end
    end

    always @(*) begin
        sub1 = buff - diff1;
        sub2 = sub1 - diff2;
		  aux = (sub2 - diff3) >> 1;
        out = aux[19:0];
    end
endmodule
