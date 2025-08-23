module spi_master (
    input  wire       clk,        // System clock
    input  wire       rst_n,      // Active-low reset
    input  wire       start,      // Start transaction
    input  wire [7:0] mosi_data,  // Data to send
    output reg  [7:0] miso_data,  // Data received from slave
    output reg        busy,       // Busy flag

    // SPI signals
    output reg        sclk,       // SPI Clock
    output reg        mosi,       // Master Out
    input  wire       miso,       // Master In
    output reg        cs_n        // Active-low chip select
);

    reg [2:0] bit_cnt;
    reg [7:0] shift_reg_tx, shift_reg_rx;
    reg [1:0] state;

    localparam IDLE = 2'b00, LOAD = 2'b01, TRANSFER = 2'b10, DONE = 2'b11;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= IDLE;
            cs_n        <= 1'b1;
            sclk        <= 1'b0;
            busy        <= 1'b0;
            bit_cnt     <= 3'd0;
            mosi        <= 1'b0;
            miso_data   <= 8'h00;
        end else begin
            case (state)
                IDLE: begin
                    cs_n <= 1'b1;
                    sclk <= 1'b0;
                    busy <= 1'b0;
                    if (start) begin
                        shift_reg_tx <= mosi_data;
                        shift_reg_rx <= 8'h00;
                        bit_cnt      <= 3'd7;
                        state        <= LOAD;
                        busy         <= 1'b1;
                    end
                end

                LOAD: begin
                    cs_n <= 1'b0;  // Select slave
                    mosi <= shift_reg_tx[7]; // Send MSB first
                    state <= TRANSFER;
                end

                TRANSFER: begin
                    sclk <= ~sclk;  // Toggle clock
                    if (sclk == 1'b1) begin
                        // Sample MISO on rising edge
                        shift_reg_rx <= {shift_reg_rx[6:0], miso};
                    end else begin
                        // Shift MOSI on falling edge
                        shift_reg_tx <= {shift_reg_tx[6:0], 1'b0};
                        mosi <= shift_reg_tx[6];
                        if (bit_cnt == 0) state <= DONE;
                        else bit_cnt <= bit_cnt - 1;
                    end
                end

                DONE: begin
                    cs_n      <= 1'b1;
                    miso_data <= shift_reg_rx;
                    busy      <= 1'b0;
                    state     <= IDLE;
                end
            endcase
        end
    end
endmodule
