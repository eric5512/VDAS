module control(
    input wire clk,
    // Read queue
    input wire [7:0] in_read,
    input wire em_read,
    output reg pp_read,
    // Write queue
    output reg [7:0] out_write,
    output reg ld_write,
    // ADC0 queue
    input wire [9:0] in_adc0,
    input wire em_adc0,
    output reg pp_adc0,
    // ADC1 queue
    input wire [9:0] in_adc1,
    input wire em_adc1,
    output reg pp_adc1,
    // CADC0 queue
    input wire [9:0] in_cadc0,
    input wire em_cadc0,
    output reg pp_cadc0,
    // CADC1 queue
    input wire [9:0] in_cadc1,
    input wire em_cadc1,
    output reg pp_cadc1,
    // DIN queue
    input wire [7:0] in_din,
    input wire em_din,
    output reg pp_din,
    // Output signals
    output reg [11:0] activemods, // [DoX, ADCX, CurrentADCX]
    output reg [7:0] dout,
    output reg [11:0] aout0,
    output reg [11:0] aout1,
    output [9:0] pre,
    // RST signals
    input wire rst_n,
    output reg rst_out
);

localparam INIT_RV = 3'd0;
localparam RECV_RV = 3'd1;
localparam EXEC_RV = 3'd2;
localparam SEND_ZERO_RV = 3'd3;
localparam SEND_RV = 3'd4;
localparam COLLECT_RV = 3'd5;
localparam SEND_SOURCE_RV = 3'd6;

localparam ACTIVATE_I = 3'b000;
localparam SETDIGITAL_I = 3'b001;
localparam SETANALOG_I = 3'b010;

localparam DIN_T = 3'b001;
localparam ADC0_T = 3'b010;
localparam ADC1_T = 3'b011;
localparam CADC0_T = 3'b100;
localparam CADC1_T = 3'b101;

reg [2:0] curr_state = INIT_RV;
reg [2:0] next_state = INIT_RV;
reg [15:0] instruction;
reg instr_size;
reg instr_count = 1'b0;
reg [1:0] substate_send;
reg [11:0] data_buffer;
reg [2:0] sending;

assign pre = 10'b0000001111;

// Change the state every clock cycle
always @(posedge clk) begin
curr_state <= next_state;
end

// Coordinate the reception and emission of data
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rst_out <= 1'b0;
        pp_read <= 1'b0;
        pp_adc0 <= 1'b0;
        pp_adc1 <= 1'b0;
        pp_cadc0 <= 1'b0;
        pp_cadc1 <= 1'b0;
        pp_din <= 1'b0;
        ld_write <= 1'b0;
        out_write <= 8'b00000000;
        instruction <= 8'b0;
        instr_size <= 1'b0;
        substate_send <= 2'b00;
        data_buffer <= 12'b0;
    end else begin
        case (curr_state)
            INIT_RV: begin
                rst_out <= 1'b0;
            end

            RECV_RV: begin
                rst_out <= 1'b1;
                if (!em_read) begin
                    pp_read <= 1'b1; // Pop data from queue
                    
                    if (instr_count)
                        instruction <= in_read << 8;
                    else
                        instruction <= in_read;

                    instr_count <= instr_count + 1'b1;
                    
                    // Determine instruction size based on the first 3 bits of the instruction
                    if (instr_count == 1'b0) case (in_read[7:5])
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
                rst_out <= 1'b1;
                pp_read <= 1'b0;
                instr_count <= 1'b0;

                // Prepare to read from the appropriate queue
                case (instruction[7:5])
                    ACTIVATE_I: begin
                        activemods <= activemods | (1'b1 << instruction[4:1]);
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

            COLLECT_RV: begin
                rst_out <= 1'b1;
                if (!em_din) begin
                    ld_write <= 1'b1;
                    out_write <= {DIN_T, 5'b00000};
                    sending <= DIN_T;
                    data_buffer[7:0] <= in_din;
                    pp_din <= 1'b1;
                end else if (!em_adc0) begin
                    ld_write <= 1'b1;
                    out_write <= {ADC0_T, 5'b00000};
                    sending <= ADC0_T;
                    data_buffer <= in_adc0;
                    pp_adc0 <= 1'b1;
                end else if (!em_adc1) begin
                    ld_write <= 1'b1;
                    out_write <= {ADC1_T, 5'b00000};
                    sending <= ADC1_T;
                    data_buffer <= in_adc1;
                    pp_adc1 <= 1'b1;
                end else if (!em_cadc0) begin
                    ld_write <= 1'b1;
                    out_write <= {CADC0_T, 5'b00000};
                    sending <= CADC0_T;
                    data_buffer <= in_cadc0;
                    pp_cadc0 <= 1'b1;
                end else if (!em_cadc1) begin
                    ld_write <= 1'b1;
                    out_write <= {CADC1_T, 5'b00000};
                    sending <= CADC1_T;
                    data_buffer <= in_cadc1;
                    pp_cadc1 <= 1'b1;
                end else begin
                    sending <= 3'b000;
                    ld_write <= 1'b0;
                end
            end

            SEND_ZERO_RV: begin
                ld_write <= 1'b1;
                out_write <= 8'b00000000;
                rst_out <= 1'b1;
                if (sending == DIN_T) substate_send <= 2'b10; else substate_send <= 2'b01;
                pp_din <= 1'b0;
                pp_adc0 <= 1'b0;
                pp_adc1 <= 1'b0;
                pp_cadc0 <= 1'b0;
                pp_cadc1 <= 1'b0;
            end

            SEND_RV: begin
                ld_write <= 1'b1;
                // Send actual data
                case (sending)
                    DIN_T: begin // DIN queue
                        out_write <= in_din;
                        pp_din <= 1'b0;
                    end
                    ADC0_T, ADC1_T, CADC0_T, CADC1_T: begin // ADC and CADC queues
                        if (substate_send == 2'b01) begin
                            out_write <= {4'b0000, data_buffer[11:8]};
                            substate_send <= 2'b10;
                        end else if (substate_send == 2'b10) begin
                            out_write <= data_buffer[7:0];
                            substate_send <= 2'b00;
                        end
                    end
                endcase
                rst_out <= 1'b1;
            end

            default: begin
                rst_out <= 1'b0;
            end
        endcase
    end
end

// Change to next state
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        next_state = INIT_RV;
    else case (curr_state)
        INIT_RV: next_state = RECV_RV;
        RECV_RV: if (instr_count == instr_size) next_state = EXEC_RV; else next_state = RECV_RV;
        EXEC_RV: next_state = COLLECT_RV;
        COLLECT_RV: if (sending != 3'b000) next_state = SEND_ZERO_RV; else next_state = RECV_RV;
        SEND_ZERO_RV: next_state = SEND_RV;
        SEND_RV: if (substate_send == 2'b00) next_state = RECV_RV; else next_state = SEND_RV;
        default: next_state = INIT_RV;
    endcase
end

endmodule
