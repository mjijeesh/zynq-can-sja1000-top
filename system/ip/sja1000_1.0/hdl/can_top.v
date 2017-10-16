/**
	Compatibility module. Should not be used in new designs.
	Use can_top_raw with appropriate interface (can_ifc_*).
*/

`include "timescale.v"
`include "can_defines.v"

module can_top
(
  `ifdef CAN_WISHBONE_IF
    wb_clk_i,
    wb_rst_i,
    wb_dat_i,
    wb_dat_o,
    wb_cyc_i,
    wb_stb_i,
    wb_we_i,
    wb_adr_i,
    wb_ack_o,
  `else
    rst_i,
    ale_i,
    rd_i,
    wr_i,
    port_0_io,
    cs_can_i,
  `endif
  clk_i,
  rx_i,
  tx_o,
  bus_off_on,
  irq_on,
  clkout_o

  // Bist
`ifdef CAN_BIST
  ,
  // debug chain signals
  mbist_si_i,       // bist scan serial in
  mbist_so_o,       // bist scan serial out
  mbist_ctrl_i        // bist chain shift control
`endif
);

input        clk_i;
input        rx_i;
output       tx_o;
output       bus_off_on;
output       irq_on;
output       clkout_o;

wire       reg_rst;
wire       reg_cs;
wire       reg_we;
wire [7:0] reg_addr;
wire [7:0] reg_data_in;
wire [7:0] reg_data_out;

// Bist
`ifdef CAN_BIST
  input   mbist_si_i;       // bist scan serial in
  output  mbist_so_o;       // bist scan serial out
  input [`CAN_MBIST_CTRL_WIDTH - 1:0] mbist_ctrl_i;       // bist chain shift control
`endif

can_top_raw #(
) can_top_raw_inst (
  .reg_we_i(reg_we),
  .reg_re_i(reg_re),
  .reg_data_in(reg_data_in),
  .reg_data_out(reg_data_out),
  .reg_addr_read_i(reg_addr),
  .reg_addr_write_i(reg_addr),
  .reg_rst_i(reg_rst),

  .clk_i(clk_i),
  .rx_i(rx_i),
  .tx_o(tx_o),
  .bus_off_on(bus_on_off),
  .irq_on(irq_on),
  .clkout_o(clkout_o)

  // Bist
`ifdef CAN_BIST
  // debug chain signals
  .mbist_si_i(mbist_si_i),       // bist scan serial in
  .mbist_so_o(mbist_so_o),       // bist scan serial out
  .mbist_ctrl_i(mbist_ctrl_i)    // bist chain shift control
`endif
);

`ifdef CAN_WISHBONE_IF
  input        wb_clk_i;
  input        wb_rst_i;
  input  [7:0] wb_dat_i;
  output [7:0] wb_dat_o;
  input        wb_cyc_i;
  input        wb_stb_i;
  input        wb_we_i;
  input  [7:0] wb_adr_i;
  output       wb_ack_o;

  can_ifc_wb #(
  ) can_ifc_wb_inst (
    .clk_i(clk_i),
    .reg_rst_o(reg_rst),
    .reg_cs_o(reg_cs),
    .reg_we_o(reg_we),
    .reg_addr_o(reg_addr),
    .reg_data_in_o(reg_data_in),
    .reg_data_out_i(reg_data_out),
  
    .wb_clk_i(wb_clk_i),
    .wb_rst_i(wb_rst_i),
    .wb_dat_i(wb_dat_i),
    .wb_dat_o(wb_dat_o),
    .wb_cyc_i(wb_cyc_i),
    .wb_stb_i(wb_stb_i),
    .wb_we_i(wb_we_i),
    .wb_adr_i(wb_adr_i),
    .wb_ack_o(wb_ack_o)
  );
`else
  input        rst_i;
  input        ale_i;
  input        rd_i;
  input        wr_i;
  inout  [7:0] port_0_io;
  input        cs_can_i;

  wire       ale;
  wire       rd;
  wire       wr;
  wire [7:0] port_0;
  wire       cs_can;
  can_ifc_8051 #(
  ) can_ifc_wb_inst (
    .clk_i(clk_i),
    .reg_rst_o(reg_rst),
    .reg_cs_o(reg_cs),
    .reg_we_o(reg_we),
    .reg_addr_o(reg_addr),
    .reg_data_in_o(reg_data_in),
    .reg_data_out_i(reg_data_out),
  
    .rst_i(rst_i),
    .ale_i(ale),
    .rd_i(rd),
    .wr_i(wr),
    .port_0_io(port_0),
    .cs_can_i(cs_can)
    );
`endif
endmodule
