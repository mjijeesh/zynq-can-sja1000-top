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

module can_ifc_axi_sync
#(
  // Width of S_AXI data bus
  parameter integer C_S_AXI_DATA_WIDTH = 32,
  // Width of S_AXI address bus
  parameter integer C_S_AXI_ADDR_WIDTH = 8
)
(
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

  output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
  output reg  [1:0]                      S_AXI_RRESP,
  output reg                             S_AXI_RVALID,
  input wire                             S_AXI_RREADY
);

  reg req;
  reg oack;
  wire ack_i;
  wire read_active;
  wire write_active;
  rw_arbiter rw_arbiter_inst
  (
    .S_AXI_ACLK(S_AXI_ACLK),
    .S_AXI_ARESETN(S_AXI_ARESETN),
    .read_pending(),
    .read_active(read_active),
    .write_pending(),
    .write_active(write_active),
    .read_active_edge(read_active_edge),
    .write_active_edge(write_active_edge),

    .read_finished(S_AXI_RVALID && S_AXI_RREADY),
    .write_finished(S_AXI_BVALID && S_AXI_BREADY),

    .ready_read_i(S_AXI_ARVALID),
    .ready_write_i(S_AXI_AWVALID & S_AXI_WVALID)
  );


  //assign reg_addr_o <= write ? axi_waddr : axi_raddr;
  // assign reg_addr_o - asynchronous, synchronized by protocols expectations
  // should not synthesise any regs or latches
  assign reg_addr_o = write_active ? S_AXI_AWADDR :
                      read_active  ? S_AXI_ARADDR :
                      8'bxxxxxxxx;

  always @(negedge S_AXI_ARESETN or posedge S_AXI_ACLK)
  begin
    if (~S_AXI_ARESETN)
      begin
        S_AXI_BRESP <= 2'b00; // OKAY
        S_AXI_BVALID <= 1'b0;
        S_AXI_WREADY <= 1'b0;
        S_AXI_AWREADY <= 1'b0;
        S_AXI_RRESP <= 0;
      end else
      begin
        if (read_active)
        begin
          if (S_AXI_RREADY && S_AXI_RVALID)
          begin
            S_AXI_RVALID <= 1'b0;
            S_AXI_ARREADY <= 1'b0;
          end
          else if (~S_AXI_RVALID)
          begin
            S_AXI_RVALID <= 1'b1;
            S_AXI_ARREADY <= 1'b1;
            S_AXI_RRESP <= 2'b00; // OKAY
          end
        end else if (write_active)
        begin
          if (S_AXI_BREADY && S_AXI_BVALID)
          begin
            S_AXI_BVALID <= 1'b0;
            S_AXI_WREADY <= 1'b0;
            S_AXI_AWREADY <= 1'b0;
          end
          else if (~S_AXI_BVALID)
          begin
            S_AXI_BRESP <= 2'b00; // OKAY
            S_AXI_BVALID <= 1'b1;
            S_AXI_WREADY <= 1'b1;
            S_AXI_AWREADY <= 1'b1;
          end
        end
      end
     end

  assign reg_rst_o       = ~S_AXI_ARESETN;
  assign reg_we_o        = write_active;
  assign reg_data_in_o   = S_AXI_WDATA[7:0];
  assign S_AXI_RDATA[7:0]= reg_data_out_i;
  assign S_AXI_RDATA[C_S_AXI_DATA_WIDTH-1 : 8] = 0;
  assign reg_cs_o        = read_active | write_active;
endmodule
