`timescale 100ps/10ps

module testbench;

parameter CLK_PERIOD = 250;

logic clk;
logic arstn;
logic tx_ready;
logic tx_busy;
logic tx;
logic [7:0] message;

//logic tx1;
//logic flag;

uart_tx #(
  .CLK_FREQUENCY (40_000_000),
  .BITRATE       ( 1_000_000),
  .W_PACKAGE     (        10),
  .W_MESSAGE     (         8)
) DUT0(
  .clk      (clk),
  .arstn    (arstn),
  .tx_ready (tx_ready),
  .message  (message),
  .tx_busy  (tx_busy),
  .tx       (tx)
);

//tx DUT1(
//  .clk_fpga(clk),
//  .clk_uart(clk),
//  .data    (message),
//  .tx      (tx1),
//  .flag    (flag)
//);

initial begin
  $dumpfile("dump.vcd");
  $dumpvars(0, testbench);
end

initial begin
  clk <= 0;
  forever begin
    #(CLK_PERIOD/2); clk <= ~clk;
  end
end

initial begin
  arstn <= 0;
  #(CLK_PERIOD*20);
  arstn <= 1;
end

initial begin
  message <= 8'b11100101;
end

initial begin
  tx_ready <= 0;
  wait (arstn);
  tx_ready <= 1;
  repeat (8) begin
    message <= 8'b00011010;
    #(1000*CLK_PERIOD);
    tx_ready <= 0;
    message <= 8'b11010110;
    #(1000*CLK_PERIOD);
    tx_ready <= 1;
    #(CLK_PERIOD*250);
  end
  $finish();
end

endmodule