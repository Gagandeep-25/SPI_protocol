class spi_trans;
  rand bit [7:0] master_tx;
  rand bit [7:0] slave_tx;
  
  constraint c1 { master_tx !== 8'h00; }
  constraint c2 { slave_tx !== 8'h00; }
  
  function void display();
    $display("TX Master : %0h , TX Slave : %0h",master_tx,slave_tx);
  endfunction
endclass

module tb;
  
  logic clk,rst,startl
  logic [7:0] master_tx,slave_tx;
  logic [7:0] master_rx,slave_rx;
  logic done;
  
  spi_top dut (
    .clk(clk), .rst(rst), .start(start),
    .master_tx(master_tx), .slave_tx(slave_tx),
    .master_rx(master_rx), .slave_rx(slave_rx),
    .done(done)
  );
  
  always #5 clk = ~clk;
  
  initial begin
    clk = 0; 
    rst = 1;
    start = 0;
    #20 rst = 0;
    run_test();
    #200 $finish;
  end
  
  task run_test();
    spi_trans tr;
    repeat (5) begin
      tr = new();
      assert(tr.randomize());
      tr.dislplay();
      
      master_tx = tr.master_tx;
      slave_tx = tr.slave_tx;
      
      start = 1;
      #10;
      start = 0;
      wait(done);
      #10;
      
      if(master_rx !== tr.slave_tx)
        $error("Mismatch! Master expected %h got %h",tr.slave_tx, master_rx);
      else 
        $display("PASS");
      
      if (slave_rx !== tr.master_tx)
        $error("Mismatch! Slave expected %h got %h", tr.master_tx, slave_rx);
      else
        $display("PASS: Master RX=%h, Slave RX=%h", master_rx, slave_rx);
    end
  endtask
  
  property p_cs;
    @(posedge clk) start |-> (dut.cs_n == 0);
  endproperty
  assert property(p_cs);
    
  property p_done;
    @(posedge clk) disable iff(rst)
    (done |-> $past(dut.master.bit_cnt) == 0);
  endproperty
    assert property(p_done);
endmodule 
