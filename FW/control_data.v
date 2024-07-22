module control_data(
    input wire clk,
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
    // RST signals
    input wire rst_n
);

localparam INIT_RV = 3'd0;
localparam SEND_SOURCE_RV = 3'd1;
localparam SEND_RV = 3'd2;
localparam COLLECT_RV = 3'd3;

localparam DIN_T = 3'b001;
localparam ADC0_T = 3'b010;
localparam ADC1_T = 3'b011;
localparam CADC0_T = 3'b100;
localparam CADC1_T = 3'b101;

reg [2:0] curr_state = INIT_RV;
reg [2:0] next_state = INIT_RV;
reg [1:0] substate_send;
reg [9:0] data_buffer;
reg [2:0] sending;

// Coordinate the reception and emission of data
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pp_adc0 <= 1'b0;
        pp_adc1 <= 1'b0;
        pp_cadc0 <= 1'b0;
        pp_cadc1 <= 1'b0;
        pp_din <= 1'b0;
        ld_write <= 1'b0;
        out_write <= 8'b00000000;
        substate_send <= 2'b00;
        data_buffer <= 10'b0;
    end else begin
        curr_state = next_state;
        case (curr_state)
            COLLECT_RV: begin
                if (!em_din) begin
                    ld_write <= 1'b1;
                    out_write <= 1'b0;
                    sending <= DIN_T;
                    data_buffer[7:0] <= in_din;
                    pp_din <= 1'b1;
                end else if (!em_adc0) begin
                    ld_write <= 1'b1;
                    out_write <= 1'b0;
                    sending <= ADC0_T;
                    data_buffer <= in_adc0;
                    pp_adc0 <= 1'b1;
                end else if (!em_adc1) begin
                    ld_write <= 1'b1;
                    out_write <= 1'b0;
                    sending <= ADC1_T;
                    data_buffer <= in_adc1;
                    pp_adc1 <= 1'b1;
                end else if (!em_cadc0) begin
                    ld_write <= 1'b1;
                    out_write <= 1'b0;
                    sending <= CADC0_T;
                    data_buffer <= in_cadc0;
                    pp_cadc0 <= 1'b1;
                end else if (!em_cadc1) begin
                    ld_write <= 1'b1;
                    out_write <= 1'b0;
                    sending <= CADC1_T;
                    data_buffer <= in_cadc1;
                    pp_cadc1 <= 1'b1;
                end else begin
                    sending <= 3'b000;
                    ld_write <= 1'b0;
                end
            end

            SEND_SOURCE_RV: begin
                ld_write <= 1'b1;
                out_write <= {5'b0, sending};
                pp_adc0 <= 1'b0;
                pp_adc1 <= 1'b0;
                pp_cadc0 <= 1'b0;
                pp_cadc1 <= 1'b0;
                pp_din <= 1'b0;
                if (sending == DIN_T) substate_send <= 2'b10; else substate_send <= 2'b01;
            end


            SEND_RV: begin
                ld_write <= 1'b1;
                // Send actual data
                case (sending)
                    DIN_T: begin // DIN queue
                        out_write <= in_din;
                        pp_din <= 1'b0;
                        substate_send <= 2'b00;
                    end
                    ADC0_T, ADC1_T, CADC0_T, CADC1_T: begin // ADC and CADC queues
                        if (substate_send == 2'b01) begin
                            out_write <= data_buffer[7:0];
                            substate_send <= 2'b10;
                        end else if (substate_send == 2'b10) begin
                            out_write <= {6'b000000, data_buffer[9:8]};
                            substate_send <= 2'b00;
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
        INIT_RV: next_state = COLLECT_RV;
        COLLECT_RV: if (sending != 3'b000) next_state = SEND_SOURCE_RV; else next_state = COLLECT_RV;
        SEND_SOURCE_RV: next_state = SEND_RV;
        SEND_RV: if (substate_send == 2'b00) next_state = COLLECT_RV; else next_state = SEND_RV;
        default: next_state = INIT_RV;
    endcase
end

endmodule
