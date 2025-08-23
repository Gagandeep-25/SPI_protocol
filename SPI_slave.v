module spi_slave (
    input  wire       sclk,
    input  wire       cs_n,
    input  wire       mosi,
    output reg        miso,
    input  wire [7:0] tx_data,   // Data to send
    output reg [7:0] rx_data     // Data received
);

    reg [7:0] shift_reg_tx, shift_reg_rx;
    reg [2:0] bit_cnt;

    always @(negedge cs_n) begin
        shift_reg_tx <= tx_data;  // Load data when CS goes low
        bit_cnt <= 3'd7;
    end

    always @(posedge sclk) begin
        if (!cs_n) begin
            // Sample MOSI on rising edge
            shift_reg_rx <= {shift_reg_rx[6:0], mosi};
        end
    end

    always @(negedge sclk) begin
        if (!cs_n) begin
            // Shift MISO on falling edge
            miso <= shift_reg_tx[7];
            shift_reg_tx <= {shift_reg_tx[6:0], 1'b0};
            if (bit_cnt == 0) rx_data <= shift_reg_rx;
            else bit_cnt <= bit_cnt - 1;
        end
    end
endmodule
