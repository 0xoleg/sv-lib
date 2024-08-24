`timescale 1us/100ns

module ADC_model(
  output logic CLK,
  output logic SS,
  output logic SDO
);

localparam ICLK_PERIOD = 2;  // Source clock period
localparam RESET_TIME = 2;

localparam CLK_IDLE_STATE = 0;
localparam SS_IDLE_STATE = 1;
localparam SDO_IDLE_STATE = 0;

localparam SS_SET = 3*ICLK_PERIOD;  // The time after the CS line set to the active state before the transmission of the first packet begins (in iclk period)
localparam SS_HOLD = 4*ICLK_PERIOD;  // The time after last packet ends before the CS line set to the idle state (in iclk period)
localparam CLK_PERIOD = 2*ICLK_PERIOD;  // Master clock period (in iclk  period)
localparam PACKET_SIZE = 8;  // (in bits)
localparam TIME_BETWEEN_PACKETS = 6*ICLK_PERIOD;  // (in iclk period)

localparam MESSAGE_SIZE = 15;
localparam TIME_BETWEEN_MESSAGES = 7*ICLK_PERIOD; // (in iclk period)

logic iclk;  // Source clock
logic reset;

logic master_clock;
logic slave_select;
logic dout;
logic [PACKET_SIZE-1 : 0] message [MESSAGE_SIZE-1 : 0];

initial begin
  iclk <= '0;
  forever begin
    #(ICLK_PERIOD/2); iclk <= ~iclk;
  end
end

initial begin
  reset = '1;
  #(RESET_TIME);
  reset = '0;
end

initial begin
  master_clock = CLK_IDLE_STATE;
  slave_select = SS_IDLE_STATE;
  dout = SDO_IDLE_STATE;

  message <= {42, 8, 12, 5, 17, 10, 118, 119, 7, 11, 29, 75, 21, 0, 126};
  repeat (30) begin
    wait (!reset);

    @(posedge iclk);
    for (int i = 0; i < MESSAGE_SIZE; i+=1) begin
      #(TIME_BETWEEN_MESSAGES);

      slave_select = ~slave_select;
      #(SS_SET);

      for (int j = 0; j < PACKET_SIZE; j+=1) begin
        master_clock = ~master_clock;
        dout = message[MESSAGE_SIZE - 1 - i][PACKET_SIZE - 1 - j];
        #(CLK_PERIOD/2);
        master_clock = ~master_clock;
        #(CLK_PERIOD/2);
      end
      
      #(SS_HOLD);
      slave_select = ~slave_select;
    end
  end

  $stop();
end

assign CLK = master_clock;
assign SS = slave_select;
assign SDO = dout;

endmodule