module AWG #(
    parameter NBITS=12, 
              PTBITS=10
) (
    in, ld, addr, rst_n, pre, sel, out, ck
);
    input ld, sel, ck, rst_n;
    input [3:0] pre;
    input [PTBITS-1:0] addr;
    input [NBITS-1:0] in;

    output reg [NBITS-1:0] out;

    localparam SIZE = 2**NBITS;

    reg [3:0] cnt = 4'b0000;
    reg [PTBITS-1:0] raddr = {PTBITS{1'b0}};
	 reg [PTBITS-1:0] waddr;
    reg [NBITS-1:0] buff[SIZE];
	 
	 
    always @(posedge ck or negedge rst_n) begin
			if (rst_n == 1'b0) begin
				cnt = 4'b0000;
				raddr = {PTBITS{1'b0}};
			end else begin
			  if (sel == 1'b0)
					out <= in;
			  else begin
					cnt = cnt + 1'b1;
					if (cnt >= pre) begin
						 raddr <= raddr + 1'b1;
						 cnt <= 4'b0000;
					end
					out <= buff[raddr];
			  end

			  if (ld == 1'b1) begin
					waddr <= addr;
					buff[waddr] <= in;
			  end
			end
    end
endmodule