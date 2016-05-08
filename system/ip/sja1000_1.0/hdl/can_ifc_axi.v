//////////////////////////////////////////////////////////////////////
////                                                              ////
////  can_top.v                                                   ////
////                                                              ////
////                                                              ////
////  This file is part of the CAN Protocol Controller            ////
////  http://www.opencores.org/projects/can/                      ////
////                                                              ////
////                                                              ////
////  Author(s):                                                  ////
////       Igor Mohor                                             ////
////       igorm@opencores.org                                    ////
////                                                              ////
////                                                              ////
////  All additional information is available in the README.txt   ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2002, 2003, 2004 Authors                       ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//// The CAN protocol is developed by Robert Bosch GmbH and       ////
//// protected by patents. Anybody who wants to implement this    ////
//// CAN IP core on silicon has to obtain a CAN protocol license  ////
//// from Bosch.                                                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "can_defines.v"

module can_ifc_async
(
  input wire clk_i,
  input wire rstn_i,
  output wire reg_cs_o,

  input wire req_i,
  output wire ack_o
);
  reg oreq;
  reg ack;

  assign ack_o = ack;
  assign reg_cs_o = oreq != req_i;

  always @(posedge clk_i or negedge rstn_i)
  begin
    if (~rstn_i)
    begin
      ack <= 1'b0;
      oreq <= 1'b0;
    end else begin
      if (oreq != req_i)
      begin
        // we is already set from axi side and is stable
        // data_in is already set from axi side and is stable
        // data_out is set from reg in this cycle
        ack <= ~ack;
        oreq <= ~oreq;
      end
    end
  end
endmodule

module can_ifc_axi
#(
  // Width of S_AXI data bus
  parameter integer C_S_AXI_DATA_WIDTH = 32,
  // Width of S_AXI address bus
  parameter integer C_S_AXI_ADDR_WIDTH = 8
)
(
  input wire clk_i,
  output wire reg_rst_o,
  output wire reg_cs_o,
  output wire reg_we_o,
  output wire [7:0] reg_addr_o,
  output wire [7:0] reg_data_in_o,
  input wire  [7:0] reg_data_out_i,

	input wire  S_AXI_ACLK,
	input wire  S_AXI_ARESETN,

	input wire  [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
	input wire  [2:0]                      S_AXI_AWPROT,
	input wire                             S_AXI_AWVALID,
	output reg                             S_AXI_AWREADY,

	input wire [C_S_AXI_DATA_WIDTH-1 : 0]     S_AXI_WDATA,
	input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
	input wire                                S_AXI_WVALID,
	output reg                                S_AXI_WREADY,

	output reg [1:0]                       S_AXI_BRESP,
	output reg                             S_AXI_BVALID,
	input wire                             S_AXI_BREADY,

	input wire  [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
	input wire  [2:0]                      S_AXI_ARPROT,
	input wire                             S_AXI_ARVALID,
	output reg                             S_AXI_ARREADY,

	output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA, // TODO: reg
	output reg  [1:0]                      S_AXI_RRESP,
	output reg                             S_AXI_RVALID,
	input wire                             S_AXI_RREADY
);

parameter Tp = 1;
/*
input        clk_i;
output       reg_rst_o;
output       reg_cs_o;
output       reg_we_o;
output [7:0] reg_data_in_o;
input  [7:0] reg_data_out_i;
*/


    reg write_pending;
    reg write_active;
    reg read_pending;
    reg read_active;

    reg  [1:0] ready_read_hist;
    reg  [1:0] ready_write_hist;
    wire ready_read_edge;
    wire ready_write_edge;
    assign ready_read_edge = ready_read_hist[0] ^ ready_read_hist[1];
    assign ready_write_edge = ready_write_hist[0] ^ ready_write_hist[1];
    
    wire read_finished;
    wire write_finished;
    
    reg read_active_edge;
    reg write_active_edge;

    reg req;
    reg oack;
    wire ack_i;

    assign read_finished = S_AXI_RVALID;
    assign write_finished = S_AXI_BVALID;

    // read/write arbitration
    always @ (posedge S_AXI_ACLK or negedge S_AXI_RST)
    begin
      if (~S_AXI_RST)
      begin
        write_pending <= 1'b0;
        write_active <= 1'b0;
        read_pending <= 1'b0;
        read_active <= 1'b0;
        ready_read_hist <= 2'b00;
        ready_write_hist <= 2'b00;
      end
      else
      begin
        ready_read_hist <= {ready_read_hist[0], S_AXI_ARVALID};
        ready_write_hist <= {ready_write_hist[0], S_AXI_AWVALID & S_AXI_WVALID /*& (S_AXI_WSTRB == 4'b1111)*/};

        /*
        if(S_AXI_AWVALID & S_AXI_WVALID & (S_AXI_WSTRB != 4'b1111))
        begin
          S_AXI_BVALID <= 1;
          S_AXI_BRESP <= ...;
        end
        */

        if (write_active_edge)
          write_active_edge = 0;
        if (read_active_edge)
          read_active_edge = 0;

        if (ready_write_edge)
        begin
          if (read_active & ~read_finished)
            write_pending <= 1;
          else
          begin
            write_active <= 1;
            write_active_edge = 1;
          end
        end

        if (ready_read_edge)
        begin
          if (write_active & ~write_finished)
            read_pending <= 1;
          else
          begin
            read_active <= 1;
            read_active_edge = 1;
          end
        end

        // read finished in previous cycle
        if (read_finished)
        begin
          read_active <= 1'b0;
          if (write_pending)
          begin
            write_active <= 1;
            write_pending <= 0;
          end
        end

        // write finished in previous cycle
        if (write_finished)
        begin
          write_active <= 1'b0;
          if (read_pending)
          begin
            read_active <= 1;
            read_pending <= 0;
          end
        end
      end
    end

    //assign reg_addr_o <= write ? axi_waddr : axi_raddr;
    // assign reg_addr_o - asynchronous, synchronized by protocols expectations
    // should not synthesise any regs or latches
    assign reg_addr_o = write_active ? S_AXI_AWADDR :
                        read_active  ? S_AXI_ARADDR :
                        8'bxxxxxxxx;

    /*
    // latch read response data
    always @(posedge S_AXI_ACLK)
    begin
      if (read_active)
        latched_data <= reg_data_out_i;
    end
    */

    always @(negedge S_AXI_RST or posedge S_AXI_ACLK)
    begin
      if (~S_AXI_RST)
      begin
        oack <= 1'b0;
        //S_AXI_RDATA <=#C_S_AXI_DATA_WIDTH 0;
        S_AXI_BRESP <= 0;
        S_AXI_BVALID <= 1'b0;
        S_AXI_WREADY <= 1'b0;
        S_AXI_AWREADY <= 1'b0;
      end else
      begin
        // no synchronization necessary
        if (read_active_edge | write_active_edge)
          req <= ~req;
        if (oack != ack_i)
        begin
          if (read_active)
          begin
            //S_AXI_RDATA <= reg_data_out_i; // TODO: should be allright, the address is stable ...
            // read_active will be deasserted after asserting S_AXI_RVALID, so this will execute only 2x
            S_AXI_RVALID <= ~S_AXI_RVALID;
            S_AXI_ARREADY <= ~S_AXI_ARREADY;
          end else if (write_active)
          begin
            S_AXI_BRESP <= 2'b00; // TODO: value?
            // write_active will be deasserted after asserting S_AXI_RVALID, so this will execute only 2x
            S_AXI_BVALID <= ~S_AXI_BVALID;
            S_AXI_WREADY <= ~S_AXI_WREADY;
            S_AXI_AWREADY <= ~S_AXI_AWREADY;
          end
          oack <= ~oack;
        end
      end
     end

  assign reg_rst_o       = ~S_AXI_RST;
  assign reg_we_o        = write_active;
  assign reg_addr_o      = S_AXI_AWADDR; // TODO: latch?
  assign reg_data_in_o   = S_AXI_WDATA;
  assign S_AXI_RDATA     = reg_data_out_i; // TODO: latch?

  can_ifc_async CAN_IFC_ASYNC
  (
    .clk_i(clk_i),
    .rstn_i(S_AXI_RST),
    .reg_cs_o(reg_cs_o),
    .req_i(req),
    .ack_o(ack)
  );
endmodule
