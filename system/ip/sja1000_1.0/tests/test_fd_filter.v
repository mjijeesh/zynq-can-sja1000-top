module test_fd_filter();

reg rst;
reg clk;
reg  [31:0] cnt;

wire  fd_fall_edge_raw;
wire  sample_point;
wire  rx;
wire  fdd_rst;

parameter integer N = 52;
//  test name:          idle      busy      bi        undefined  last-min*
reg [0:N-1]  iv_rx  = 'b1111111111x000000000x0001110000x010101010x0010001101x;
reg [0:N-1]  iv_rst = 'b10000000001000000000100000000001000000000100000000001;
reg [0:N-1]  ev_frx = 'b11111111111111000000111100011101111111111111111100001;
reg [0:N-1]  ev_fe  = 'b00000000000001000000000100000100000000000000000100000;
/*
    Notes:
    1. The initial RX state is 1, thus there is implicit edge when the test starts with 0.
    2. FE detection is 1 cycle early - see notes in module impl.
*/

assign rx = iv_rx[cnt];
assign fdd_rst = iv_rst[cnt];

can_fd_filter #(
    .NSAMPLES(3)
) i_can_fd_detect (
  .rst(fdd_rst),
  .clk(clk),
  .rx_sync_i(rx),
  .filteredrx_ro(filtered_rx),
  .fall_edge_o(fd_fall_edge_raw)
);

initial begin
    $dumpfile("test_fd_filter.vcd");
    $dumpvars;
    rst = 1'b1;
    clk = 1'b1;
    #47 rst = 1'b0;
end

always #5 clk = ~clk;

always @(posedge clk or posedge rst)
begin
    if (rst)
      cnt <= 32'b0;
    else if (cnt < N-1)
      cnt <= cnt + 1;
end

// must be delayed by 1 cycle
always @(posedge clk or posedge rst)
begin
    if (cnt == N-1)
      $finish;
end

wire exp_filtered_rx;
wire exp_fd_fall_edge_raw;
assign exp_filtered_rx = ev_frx[cnt];
assign exp_fd_fall_edge_raw = ev_fe[cnt];

always @(posedge clk)
begin
    if (~rst)
      begin
        if (exp_filtered_rx != filtered_rx)
          $display("#%d: filtered_rx: expected %b, got %b", cnt, exp_filtered_rx, filtered_rx);
        if (exp_fd_fall_edge_raw != fd_fall_edge_raw)
          $display("#%d: fd_fall_edge_o: expected %b, got %b", cnt, exp_fd_fall_edge_raw, fd_fall_edge_raw);
      end
end

endmodule
