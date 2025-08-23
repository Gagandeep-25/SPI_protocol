odule spi_top (
  input  wire clk, rst, start,
  input  wire [7:0] master_tx, slave_tx,
  output reg [7:0] master_rx, slave_rx,
  output reg done
);
  wire mosi, miso, sclk, cs_n;

  spi_master master (
    .clk(clk), .rst(rst), .start(start),
    .tx_data(master_tx), .rx_data(master_rx),
    .done(done), .mosi(mosi), .miso(miso),
    .sclk(sclk), .cs_n(cs_n)
  );

  spi_slave slave (
    .clk(clk), .rst(rst), .sclk(sclk), .cs_n(cs_n),
    .mosi(mosi), .miso(miso),
    .tx_data(slave_tx), .rx_data(slave_rx)
  );
endmodule
