`include "timescale.v"

	module sja1000 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 16

		// Parameters of Axi Slave Bus Interface S_AXI_INTR
		/*
		parameter integer C_S_AXI_INTR_DATA_WIDTH	= 32,
		parameter integer C_S_AXI_INTR_ADDR_WIDTH	= 5,
		parameter integer C_NUM_OF_INTR	= 1,
		parameter  C_INTR_SENSITIVITY	= 32'hFFFFFFFF,
		parameter  C_INTR_ACTIVE_STATE	= 32'hFFFFFFFF,
		parameter integer C_IRQ_SENSITIVITY	= 1,
		parameter integer C_IRQ_ACTIVE_STATE	= 1
		*/
	)
	(
		// Users to add ports here
		input  wire can_clk,
		input  wire can_rx,
		output wire can_tx,
		output wire bus_off_on,

		output wire [31:0] dbg_ports_o,
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready,

		output wire  irq
	);
	wire reg_we;
	wire reg_cs;
	wire reg_rst;
	wire [7:0] reg_data_in;
	wire [7:0] reg_data_out;
	wire [7:0] reg_addr_read;
	wire [7:0] reg_addr_write;
	
	wire irq_n;
	assign irq = ~irq_n;

// Instantiation of Axi Bus Interface S00_AXI
	can_ifc_axi_sync_duplex # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) can_ifc_axi_inst (
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready),
		
		//.clk_i(can_clk),
		.reg_rst_o(reg_rst),
		.reg_re_o(reg_re),
		.reg_we_o(reg_we),
		.reg_addr_read_o(reg_addr_read),
		.reg_addr_write_o(reg_addr_write),
		.reg_data_in_o(reg_data_in),
		.reg_data_out_i(reg_data_out)
	);

	//assign reg_data_out = reg_addr_read; // DBG
	can_top_raw can_top_raw_inst (
		.reg_we_i(reg_we),
		.reg_re_i(reg_re),
		.reg_data_in(reg_data_in),
		.reg_data_out(reg_data_out),
		.reg_addr_read_i(reg_addr_read),
		.reg_addr_write_i(reg_addr_write),
		.reg_rst_i(reg_rst),

		.clk_i(can_clk),
		.rx_i(can_rx),
		.tx_o(can_tx),
		.bus_off_on(bus_off_on),
		.irq_on(irq_n),
		.clkout_o()
	);

	// Add user logic here
	/*
	// Interesting BSP signals:
input         hard_sync;
reg           rx_idle;
reg           rx_id1;
reg           rx_rtr1;
reg           rx_ide;
reg           rx_id2;
reg           rx_rtr2;
reg           rx_r1;
reg           rx_r0;
reg           rx_dlc;
reg           rx_data;
reg           rx_crc;
reg           rx_crc_lim;
reg           rx_ack;
reg           rx_ack_lim;
reg           rx_eof;
reg           rx_inter;
reg           go_early_tx_latched;
reg           rtr1;
reg           ide;
reg           rtr2;
reg           transmitting;
reg           error_frame;
reg           arbitration_lost;
reg           need_to_tx;   // When the CAN core has something to transmit and a dominant bit is sampled at the third bit
reg           transmitter;
reg           bus_free;
reg           waiting_for_bus_free;
reg           node_error_passive;
reg           node_bus_off;
reg           suspend;
reg           fdf_r;
wire          fd_fall_edge_lstbtm; // Fall edge detected inside preceding bittime
wire          fd_fall_edge_raw;
reg           go_rx_skip_fdf; // async
wire          fd_skip_finished;
wire          bit_de_stuff;
wire          bit_de_stuff_tx;
wire          go_rx_idle;
wire          go_rx_id1;
wire          go_rx_rtr1;
wire          go_rx_ide;
wire          go_rx_id2;
wire          go_rx_rtr2;
wire          go_rx_r1;
wire          go_rx_r0;
wire          go_rx_dlc;
wire          go_rx_data;
wire          go_rx_crc;
wire          go_rx_crc_lim;
wire          go_rx_ack;
wire          go_rx_ack_lim;
wire          go_rx_eof;
wire          go_rx_inter;
wire          last_bit_of_inter;
wire          go_crc_enable;
wire          go_early_tx;
wire          form_err;
wire          error_frame_ended;
wire          overload_frame_ended;
wire          bit_err;
wire          ack_err;
wire          stuff_err;
wire          err;
	*/
    assign dbg_ports_o[ 0] = can_top_raw_inst.i_can_bsp.rx_sync_i;
    assign dbg_ports_o[ 1] = can_top_raw_inst.i_can_bsp.rx_eof;
    assign dbg_ports_o[ 2] = can_top_raw_inst.i_can_bsp.rx_inter;
    assign dbg_ports_o[ 3] = can_top_raw_inst.i_can_bsp.rx_ack;
    assign dbg_ports_o[ 4] = can_top_raw_inst.i_can_bsp.rx_idle;
    assign dbg_ports_o[ 5] = can_top_raw_inst.i_can_bsp.rx_id1;
    assign dbg_ports_o[ 6] = can_top_raw_inst.i_can_bsp.go_early_tx_latched;
    assign dbg_ports_o[ 7] = can_top_raw_inst.i_can_bsp.transmitting;
    assign dbg_ports_o[ 8] = can_top_raw_inst.i_can_bsp.error_frame;
    assign dbg_ports_o[ 9] = can_top_raw_inst.i_can_bsp.bus_free;
    assign dbg_ports_o[10] = can_top_raw_inst.i_can_bsp.waiting_for_bus_free;
    assign dbg_ports_o[11] = can_top_raw_inst.i_can_bsp.node_error_passive;
    assign dbg_ports_o[12] = can_top_raw_inst.i_can_bsp.node_bus_off;
    assign dbg_ports_o[13] = can_top_raw_inst.i_can_bsp.suspend;
    assign dbg_ports_o[14] = can_top_raw_inst.i_can_bsp.fdf_r;
    assign dbg_ports_o[15] = can_top_raw_inst.i_can_bsp.fd_fall_edge_lstbtm;
    assign dbg_ports_o[16] = can_top_raw_inst.i_can_bsp.fd_fall_edge_raw;
    assign dbg_ports_o[17] = can_top_raw_inst.i_can_bsp.go_rx_skip_fdf;
    assign dbg_ports_o[18] = can_top_raw_inst.i_can_bsp.fd_skip_finished;
    assign dbg_ports_o[19] = can_top_raw_inst.i_can_bsp.bit_de_stuff;
    assign dbg_ports_o[20] = can_top_raw_inst.i_can_bsp.bit_de_stuff_tx;
    assign dbg_ports_o[21] = can_top_raw_inst.i_can_bsp.go_rx_idle;
    assign dbg_ports_o[22] = can_top_raw_inst.i_can_bsp.go_rx_id1;
    assign dbg_ports_o[23] = can_top_raw_inst.i_can_bsp.go_rx_ack;
    assign dbg_ports_o[24] = can_top_raw_inst.i_can_bsp.go_rx_ack_lim;
    assign dbg_ports_o[25] = can_top_raw_inst.i_can_bsp.go_rx_eof;
    assign dbg_ports_o[26] = can_top_raw_inst.i_can_bsp.go_rx_inter;
    assign dbg_ports_o[27] = can_top_raw_inst.i_can_bsp.last_bit_of_inter;
    assign dbg_ports_o[28] = can_top_raw_inst.i_can_bsp.go_early_tx;
    assign dbg_ports_o[29] = can_top_raw_inst.i_can_bsp.go_tx;
    assign dbg_ports_o[30] = can_top_raw_inst.i_can_bsp.error_frame_ended;
    assign dbg_ports_o[31] = can_top_raw_inst.i_can_bsp.err;

endmodule
