`timescale 100ps/10ps

module testbench;

parameter CLK_FREQUENCY = 40_000_000;
parameter CLK_PERIOD    = 250;         // 1_000_000_000_000 / CLK_FREQUENCY / 100; 25ns, frequency 40_000_000 MHz
parameter BITRATE       = 115200;
parameter W_DATA        = 8;

parameter BIT_PERIOD = CLK_FREQUENCY / BITRATE;


logic clk;
logic arstn;

logic                  tx_ready;
logic [W_DATA - 1 : 0] tx_data;
logic                  tx_busy;
logic                  tx;

uart_tx #(
  .CLK_FREQUENCY (CLK_FREQUENCY),
  .BITRATE       (BITRATE),
  .W_PACKAGE     (10),
  .W_DATA        (W_DATA)
) DUT0 (
  .clk      (clk),
  .arstn    (arstn),
  .tx_ready (tx_ready),
  .data     (tx_data),
  .tx_busy  (tx_busy),
  .tx       (tx)
);

logic                  data_valid;
logic [W_DATA - 1 : 0] rx_data;

uart_rx #(
  .CLK_FREQUENCY (CLK_FREQUENCY),
  .BITRATE       (BITRATE),
  .W_PACKAGE     (10),
  .W_DATA        (W_DATA)
) DUT1 (
  .clk        (clk),
  .arstn      (arstn),
  .rx         (tx),
  .data_valid (data_valid),
  .data       (rx_data)
);


initial begin
  $dumpfile("dump.vcd");
  $dumpvars();
end


initial begin
  clk <= 0;
  forever begin
    #(CLK_PERIOD/2); clk <= ~clk;
  end
end


initial begin
  arstn <= 0;
  #(CLK_PERIOD*4);
  arstn <= 1;
end


initial begin
  tx_data <= 8'b01101011;
  wait(tx_busy);
  @(posedge clk);
  tx_data <= 8'b10010100;
end


initial begin
  tx_ready <= 0;
  wait (arstn);
  repeat (5) begin
    tx_ready <= 1;
    #(CLK_PERIOD * 2);
    tx_ready <= 0;
    #(CLK_PERIOD * 20_000);
  end
  $finish();
end


endmodule