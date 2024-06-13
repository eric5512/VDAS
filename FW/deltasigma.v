module deltasigma (rst_n, in, clk, dclk, out);
    input rst_n, in, clk, dclk;
    output reg [19:0] out;

    reg [20:0] buff, diff1, diff2, diff3;
    reg [20:0] int1, int2, sub1, sub2;
    reg [20:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 21'd0;
        end else if (in) begin
            cnt <= cnt + 1;
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
        out = (sub2 - diff3) >> 1;
    end
endmodule

// module deltasigma (rst_n, in, clk, osr, out, rdy);
//     input rst_n, in, clk, dclk;
//     input [1:0] osr;
//     output reg [19:0] out;
//     output rdy;

//     reg [20:0] buff, diff1, diff2, diff3;
//     reg [20:0] int1, int2, sub1, sub2;
//     reg [20:0] cnt;

//     reg [10:0] osr_cnt;

//     always @(posedge clk or negedge rst_n) begin
//         if (!rst_n) begin
//             cnt <= 21'd0;
//         end else if (in) begin
//             cnt <= cnt + 1;
//         end
//     end

//     always @(posedge clk or negedge rst_n) begin
//         if (!rst_n) begin
//             int1 <= 21'd0;
//             int2 <= 21'd0;
//         end else begin
//             int1 <= int1 + cnt;
//             int2 <= int2 + int1;
//         end
//     end

//     always @(posedge clk or negedge rst_n) begin
//         if (!rst_n) begin
//             buff <= 21'd0;
//             diff1 <= 21'd0;
//             diff2 <= 21'd0;
//             diff3 <= 21'd0;

//             osr_cnt <= 1'b0;
//         end else if (osr_cnt < (1'b1 << (osr+2))) begin
//             osr_cnt <= osr_cnt + 1'b1;
//         end else begin
//             osr_cnt <= 1'b0;

//             buff <= int2;
//             diff1 <= buff;
//             diff2 <= sub1;
//             diff3 <= sub2;
//         end
//     end

//     always @(*) begin
//         sub1 = buff - diff1;
//         sub2 = sub1 - diff2;
//         out = (sub2 - diff3) >> 1;
//     end
// endmodule