module spi_master (
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire [7:0] tx_data,
    output reg  [7:0] rx_data,
    output reg sclk,
    output reg mosi,
    input  wire miso,
    output reg cs_n,
    output reg done
);

    reg [7:0] shift_reg_tx, shift_reg_rx;
    reg [2:0] bit_cnt;
    reg [1:0] state;

    localparam IDLE = 2'b00, LOAD = 2'b01, TRANSFER = 2'b10, DONE = 2'b11;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sclk <= 0; cs_n <= 1; done <= 0; mosi <= 0;
            shift_reg_tx <= 0; shift_reg_rx <= 0; rx_data <= 0; bit_cnt <= 0; state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0; cs_n <= 1; sclk <= 0;
                    if (start) state <= LOAD;
                end
                LOAD: begin
                    shift_reg_tx <= tx_data; bit_cnt <= 3'd7; cs_n <= 0; state <= TRANSFER;
                end
                TRANSFER: begin
                    sclk <= ~sclk;
                    if (sclk) begin
                        shift_reg_rx <= {shift_reg_rx[6:0], miso};
                    end else begin
                        mosi <= shift_reg_tx[7];
                        shift_reg_tx <= {shift_reg_tx[6:0], 1'b0};
                        if (bit_cnt == 0) state <= DONE;
                        else bit_cnt <= bit_cnt - 1;
                    end
                end
                DONE: begin
                    rx_data <= shift_reg_rx; cs_n <= 1; done <= 1; state <= IDLE;
                end
            endcase
        end
    end
endmodule
