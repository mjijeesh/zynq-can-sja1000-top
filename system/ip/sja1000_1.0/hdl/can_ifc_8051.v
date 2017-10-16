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

module can_ifc_8051
(
  clk_i,
  reg_rst_o,
  reg_cs_o,
  reg_we_o,
  reg_addr_o,
  reg_data_in_o,
  reg_data_out_i,

  rst_i,
  ale_i,
  rd_i,
  wr_i,
  port_0_io,
  cs_can_i,
);

parameter Tp = 1;

  input        clk_i;
  output       reg_rst_o;
  output       reg_cs_o;
  output       reg_we_o;
  output [7:0] reg_addr_o;
  output [7:0] reg_data_in_o;
  input  [7:0] reg_data_out_i;


  input        rst_i;
  input        ale_i;
  input        rd_i;
  input        wr_i;
  inout  [7:0] port_0_io;
  input        cs_can_i;
  
  reg    [7:0] addr_latched;
  reg          wr_i_q;
  reg          rd_i_q;

  // Latching address
  always @ (posedge clk_i or posedge rst_i)
  begin
    if (rst_i)
      addr_latched <= 8'h0;
    else if (ale_i)
      addr_latched <=#Tp port_0_io;
  end


  // Generating delayed wr_i and rd_i signals
  always @ (posedge clk_i or posedge rst_i)
  begin
    if (rst_i)
      begin
        wr_i_q <= 1'b0;
        rd_i_q <= 1'b0;
      end
    else
      begin
        wr_i_q <=#Tp wr_i;
        rd_i_q <=#Tp rd_i;
      end
  end


  assign reg_cs_o = ((wr_i & (~wr_i_q)) | (rd_i & (~rd_i_q))) & cs_can_i;


  assign reg_rst_o       = rst_i;
  assign reg_we_o        = wr_i;
  assign reg_addr_o      = addr_latched;
  assign reg_data_in_o   = port_0_io;
  assign port_0_io       = (cs_can_i & rd_i)? reg_data_out_i : 8'hz;

endmodule
