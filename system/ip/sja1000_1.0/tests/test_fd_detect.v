module test_fd_detect();

reg rst;
reg clk;
reg  [31:0] cnt;

parameter integer N = 19;
//  test name:               int  set+    rst concurr
reg [0:N-1]  iv_fe       = 'b0000x01000100000010;
reg [0:N-1]  iv_sp       = 'b0000x00000000100010;
reg [0:N-1]  iv_rst      = 'b1000100000000000000;
reg [0:N-1]  ev_felstbtm = 'b0000000111111100000;

wire sample_point;
wire fall_edge_raw;
wire felstbtm;
wire fdd_rst;

assign sample_point = iv_sp[cnt];
assign fall_edge_raw = iv_fe[cnt];
assign fdd_rst = iv_rst[cnt];
assign fdd_rst = iv_rst[cnt];

can_fd_detect i_can_fd_detect (
  .rst(fdd_rst),
  .clk(clk),
  .sample_point_i(sample_point),
  .fall_edge_i(fall_edge_raw),
  .fall_edge_lstbtm_ro(felstbtm)
);

initial begin
    $dumpfile("test_fd_detect.vcd");
    $dumpvars;
    rst = 1'b1;
    clk = 1'b1;
    #27 rst = 1'b0;
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

wire exp_felstbtm;
assign exp_felstbtm = ev_felstbtm[cnt];

always @(posedge clk)
begin
    if (~rst)
      begin
        if (exp_felstbtm != felstbtm)
          $display("#%d: felstbtm: expected %b, got %b", cnt, exp_felstbtm, felstbtm);
      end
end

endmodule
