module uart_tx #(
  parameter CLK_FREQUENCY,  // Hz
  parameter BITRATE,        // bit/s
  parameter W_PACKAGE,
  parameter W_DATA
)
(
    input                  clk,
    input                  arstn,
    input                  tx_ready,
    input [W_DATA - 1 : 0] data,
    output                 tx_busy,
    output                 tx
);

localparam BIT_PERIOD = CLK_FREQUENCY / BITRATE;


logic [$clog2(BIT_PERIOD) - 1 : 0] bit_period_cnt;

logic [$clog2(W_PACKAGE)  - 1 : 0] bit_cnt;
logic [W_PACKAGE          - 1 : 0] tx_buffer;    

// Synchronize tx_ready with clk
logic tx_ready_sync;
always_ff @(posedge clk or negedge arstn) begin
  if ( !arstn ) tx_ready_sync <= 0;
  else          tx_ready_sync <= tx_ready;
end

// TODO: Think about always_ff vs always_comb
always_ff @(posedge clk or negedge arstn) begin
       if ( !arstn )   tx_buffer <= {'1,   8'hFF, '0};
  else if ( !tx_busy ) tx_buffer <= {'1, data, '0};
end

always_ff @(posedge clk or negedge arstn) begin
  if ( !arstn )                                bit_period_cnt <= 0;
  else if ( bit_period_cnt == BIT_PERIOD - 1 ) bit_period_cnt <= 0;
  else if ( tx_busy )                          bit_period_cnt <= bit_period_cnt + 1;
end

always_ff @(posedge clk or negedge arstn) begin
  if ( !arstn ) bit_cnt <= 0;

  else if ( bit_period_cnt == BIT_PERIOD - 1)
  begin
    if (bit_cnt == W_PACKAGE-1) bit_cnt <= 0;
    else                        bit_cnt <= bit_cnt + 1;
  end
end

assign tx_busy = tx_ready_sync || ( bit_cnt != 0 ) || ( bit_period_cnt != 0 );

assign tx = tx_buffer[bit_cnt] || !tx_busy;


endmodule