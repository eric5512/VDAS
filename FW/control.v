module control(clk, recv, send, read, write, exec_end, rst_n);

input clk, rst_n;
input recvd, init_send, init_read;
output write, ready_read;
input exec_end;

localparam INIT = 2'd0;
localparam RECV = 2'd1;
localparam SEND = 2'd2;
localparam EXEC = 2'd3;

reg [2:0] curr_state = INIT;
reg [2:0] next_state = INIT;

// Change the state every clock cycle
always @(posedge clk or negedge rst_n) begin 
    if (rst_n == 1'b0) begin
        curr_state = INIT;
        next_state = INIT;
    end else
        curr_state = next_state;
end

// Coordinate the reception and emmission of data
always @(posedge clk) begin
    case (curr_state)
        RECV: begin
            
        end
        SEND: begin
            
        end 
        EXEC: begin
            
        end 
    endcase
end

// Change to next state
always @(posedge clk) begin
    case (curr_state)
        INIT: next_state = RECV;
        RECV: if (exec == 1'b0) next_state = SEND; else next_state = EXEC;
        SEND: if (send == 1'b0) next_state = RECV; else next_state = SEND;
        EXEC: next_state = RECV;
    endcase
end


endmodule