`timescale 1ns/1ps
module tb_spi;

    reg clk, rst_n;
    wire sclk, mosi, miso, cs_n;
    reg [7:0] master_tx;
    wire [7:0] master_rx;
    reg [7:0] slave_tx;
    wire [7:0] slave_rx;
    wire done;

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        #50;
        rst_n = 1;
    end

    spi_master U_MASTER (
        .clk(clk),
        .rst_n(rst_n),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .cs_n(cs_n),
        .tx_data(master_tx),
        .rx_data(master_rx),
        .done(done)
    );

    spi_slave U_SLAVE (
        .sclk(sclk),
        .cs_n(cs_n),
        .mosi(mosi),
        .miso(miso),
        .tx_data(slave_tx),
        .rx_data(slave_rx)
    );

    initial begin
        master_tx = 8'hA5;
        slave_tx  = 8'h3C;

        wait(rst_n);
        #2000;

        if (master_rx == slave_tx)
            $display("PASS: Master received %h from slave", master_rx);
        else
            $display("FAIL: Master received %h, expected %h", master_rx, slave_tx);

        if (slave_rx == master_tx)
            $display("PASS: Slave received %h from master", slave_rx);
        else
            $display("FAIL: Slave received %h, expected %h", slave_rx, master_tx);
 $finish;
    end

endmodule
