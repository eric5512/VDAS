module queue
    #(parameter PTBITS = 8,
                NBITS = 8)
    (input [NBITS-1:0] in,
     input ck, ld, pp, rst_n,
     output em,
     output reg [NBITS-1:0] out);

localparam SIZE = 2**PTBITS;

reg [NBITS-1:0] fifo [SIZE-1:0];
reg [PTBITS-1:0] read_pt = {PTBITS{1'b0}};
reg [PTBITS-1:0] write_pt = {PTBITS{1'b0}};

assign em = (read_pt == write_pt);

always @(posedge ck or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        read_pt <= 0;
        write_pt <= 0;
    end else begin
        if (ld == 1'b1) begin
            fifo[write_pt] <= in;
            write_pt <= write_pt + 1'b1;
        end
        if (em == 1'b0 && pp == 1'b1) begin
            out <= fifo[read_pt];
            read_pt <= read_pt + 1'b1;
        end
    end
end

endmodule