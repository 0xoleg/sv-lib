`timescale 10us/100ns

module testbench;

parameter CLK_PERIOD = 2;
parameter BIT_LENGTH = 2*CLK_PERIOD;

enum logic[7:0] {
  TRASH,
  PATTERN1 = 8'b01001100,
  PATTERN2 = 8'b00101101
} UART_msg;

struct packed {
  logic      start;
  logic[7:0] data;
  logic      parity;
  logic[1:0] stop;
} uart_transmitter;

logic clk;
logic arstn;

logic uart_tx;

initial begin
  $dumpfile("dump.vcd");
  $dumpvars(0, testbench);
end

initial begin
  clk <= 0;
  forever begin
    #(CLK_PERIOD);
    clk <= ~clk;
  end
end

initial begin
  arstn <= 0;
  #(CLK_PERIOD);
  arstn <= 1;
end

initial begin
  uart_tx <= 0;
  wait (arstn);
  uart_tx <= 1;

  UART_msg = PATTERN1;
  #(5*CLK_PERIOD);
  for ( int i = 0; i < 10; i++ ) begin
    @(posedge clk);
         if ( i == 0 ) uart_tx <= 0;
    else if ( i == 9 ) uart_tx <= 1;
    else               uart_tx <= UART_msg[7-(i-1)];
  end

  UART_msg = PATTERN1;
  #(5*CLK_PERIOD);
  for ( int i = 0; i < 10; i++ ) begin
    @(posedge clk);
         if ( i == 0 ) uart_tx <= 0;
    else if ( i == 9 ) uart_tx <= 1;
    else               uart_tx <= UART_msg[7-(i-1)];
  end

  UART_msg = PATTERN2;
  #(5*CLK_PERIOD);
  for ( int i = 0; i < 10; i++ ) begin
    @(posedge clk);
         if ( i == 0 ) uart_tx <= 0;
    else if ( i == 9 ) uart_tx <= 1;
    else               uart_tx <= UART_msg[7-(i-1)];
  end

  UART_msg = PATTERN1;
  #(5*CLK_PERIOD);
  for ( int i = 0; i < 10; i++ ) begin
    @(posedge clk);
         if ( i == 0 ) uart_tx <= 0;
    else if ( i == 9 ) uart_tx <= 1;
    else               uart_tx <= UART_msg[7-(i-1)];
  end
  
  $stop();
end

endmodule