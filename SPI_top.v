module spi_top (
    input  wire clk,
    input  wire rst_n,
    input  wire start,
    input  wire [7:0] master_data,
    input  wire [7:0] slave_data,
    output wire [7:0] master_out,
    output wire [7:0] slave_out
);

    // Internal SPI wires
    wire sclk, mosi, miso, cs_n;

    // Master Instance
    spi_master u_master (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .mosi_data(master_data),
        .miso_data(master_out),
        .busy(),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .cs_n(cs_n)
    );

    // Slave Instance
    spi_slave u_slave (
        .sclk(sclk),
        .cs_n(cs_n),
        .mosi(mosi),
        .miso(miso),
        .tx_data(slave_data),
        .rx_data(slave_out)
    );

endmodule
