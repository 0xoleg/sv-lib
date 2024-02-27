module uart_rx #(
  parameter CLK_FREQUENCY,
  parameter BITRATE,
  parameter  W_PACKAGE = 10,
  parameter W_DATA     = 8
)
(
  input                         clk,
  input                         arstn,
  input                         rx,
  output logic                  data_valid,
  output logic [W_DATA - 1 : 0] data
);

localparam BIT_PERIOD = CLK_FREQUENCY / BITRATE;

// SB      - detect start bit edge and counting
//           to middle of first data bit (counting 3/2 of bit period)
// RECEIVE - counting bits of data
enum logic [1:0] {
  IDLE,
  SB,
  RECEIVE
} cur_state, next_state;


//logic [         W_PACKAGE - 1 : 0] buffer;
logic [$clog2(BIT_PERIOD * 3 / 2) - 1 : 0] clk_in_bit_cnt_load;
logic [$clog2(BIT_PERIOD * 3 / 2) - 1 : 0] clk_in_bit_cnt;
logic [            $clog2(W_DATA) - 1 : 0] bit_cnt_load;
logic [                    W_DATA - 1 : 0] bit_cnt;

// Synchronize start bit edge with clk
logic rx_sync;

always_ff @(posedge clk or negedge arstn) begin
  if ( !arstn ) rx_sync <= 1;
  else          rx_sync <= rx;
end

assign start_bit_edge = rx_sync & ~rx;


logic  bit_valid_prev;
assign bit_valid = ( clk_in_bit_cnt == clk_in_bit_cnt_load );

always_ff @(posedge clk or negedge arstn) begin
  bit_valid_prev <= bit_valid;
end


always_ff @(posedge clk or negedge arstn) begin
       if ( !arstn )                                clk_in_bit_cnt <= 0;
  else if ( bit_valid ) clk_in_bit_cnt <= 0;
  else                                              clk_in_bit_cnt <= clk_in_bit_cnt + 1;
end

always_ff @(posedge clk or negedge arstn) begin
       if ( !arstn )                                bit_cnt <= 0;
  else if ( bit_cnt == bit_cnt_load && bit_valid)   bit_cnt <= 0;
  else if ( bit_valid )                             bit_cnt <= bit_cnt + 1;
end


always_ff @(posedge clk or negedge arstn) begin
  if ( !arstn ) cur_state <= IDLE;
  else          cur_state <= next_state;
end

always_comb begin
  next_state = cur_state;
  case (cur_state)
  IDLE:    if (start_bit_edge)           next_state = SB;
  SB:      if (bit_valid)                next_state = RECEIVE;
  RECEIVE: if (bit_cnt == bit_cnt_load && bit_valid) next_state = IDLE;
  endcase
end

always_ff @(posedge clk or negedge arstn)begin
  if ( !arstn ) begin
    data_valid          <= 1;
    clk_in_bit_cnt_load <= 0;
    bit_cnt_load        <= 0;
    data                <= 8'hFF;
  end
  case(next_state)
  SB: begin
    data_valid          <= 0;
    clk_in_bit_cnt_load <= BIT_PERIOD / 2 * 3 - 1;
    bit_cnt_load        <= 0;
    data                <= data;
  end
  RECEIVE: begin
    data_valid          <= 0;
    clk_in_bit_cnt_load <= BIT_PERIOD - 1;
    bit_cnt_load        <= W_DATA - 1;
    
    if ( bit_valid_prev ) data[bit_cnt] <= rx;
  end
  IDLE: begin
    data_valid <= 1;
    clk_in_bit_cnt_load <= 0;
    bit_cnt_load        <= 0;
    data                <= data;
  end
  endcase
end


endmodule