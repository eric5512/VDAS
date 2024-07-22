module control_ins(
    input wire clk,
    // Read queue
    input wire [7:0] in_read,
    input wire em_read,
    output reg pp_read,
    // Output signals
    output reg [4:0] activemods, // [Do, ADCX, CurrentADCX]
    output reg [7:0] dout,
    output reg [11:0] aout0,
    output reg [11:0] aout1,
    output [9:0] pre,
    // RST signals
    input wire rst_n
);

localparam INIT_RV = 2'd0;
localparam RECV_RV = 2'd1;
localparam EXEC_RV = 2'd2;

localparam ACTIVATE_I = 3'b000;
localparam SETDIGITAL_I = 3'b001;
localparam SETANALOG_I = 3'b010;

reg [2:0] curr_state = INIT_RV;
reg [2:0] next_state = INIT_RV;
reg [15:0] instruction;
reg instr_size;
reg instr_count = 1'b0;
reg [1:0] substate_send;
reg [9:0] data_buffer;
reg [2:0] sending;

assign pre = 10'b1111111111;
// assign pre = 10'b0000001111;

// Coordinate the reception and emission of data
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pp_read <= 1'b0;
        instruction <= 8'b0;
        instr_size <= 1'b0;
        aout0 <= 10'b0;
        aout1 <= 10'b0;
        dout <= 8'b0;
        activemods <= 5'b0;
    end else begin
        curr_state <= next_state;
        case (curr_state)
            RECV_RV: begin
                if (!em_read) begin
                    pp_read <= 1'b1; // Pop data from queue
                    
                    if (instr_count)
                        instruction <= instruction | (in_read << 8);
                    else
                        instruction <= in_read;

                    instr_count <= instr_count + 1'b1;
                    
                    // Determine instruction size based on the first 3 bits of the instruction
                    if (instr_count) case (in_read[7:5])
                        ACTIVATE_I: instr_size <= 1'd0;
                        SETDIGITAL_I: instr_size <= 1'd0;
                        SETANALOG_I: instr_size <= 1'd1;
                        default: instr_size <= 1'd0;
                    endcase
                end else begin
                    pp_read <= 1'b0;
                end
            end

            EXEC_RV: begin
                pp_read <= 1'b0;
                instr_count <= 1'b0;

                // Prepare to read from the appropriate queue
                case (instruction[7:5])
                    ACTIVATE_I: begin
                        activemods <= activemods | (1'b1 << instruction[3:1]);
                    end
                    SETDIGITAL_I: begin
                        if (instruction[1]) begin
                            dout <= dout | (1'b1 << instruction[4:2]);
                        end else begin
                            dout <= dout & ~(1'b1 << instruction[4:2]);
                        end
                    end
                    SETANALOG_I: begin
                        if (instruction[4]) begin
                            aout1 <= {instruction[3:0],instruction[15:8]};
                        end else begin
                            aout0 <= {instruction[3:0],instruction[15:8]};
                        end
                    end
                endcase
            end
        endcase
    end
end

// Change to next state
always @(negedge clk or negedge rst_n) begin
    if (!rst_n)
        next_state = INIT_RV;
    else case (curr_state)
        INIT_RV: next_state = RECV_RV;
        RECV_RV: if (instr_count >= instr_size && !em_read) next_state = EXEC_RV; else next_state = RECV_RV;
        EXEC_RV: next_state = RECV_RV;
        default: next_state = INIT_RV;
    endcase
end

endmodule
