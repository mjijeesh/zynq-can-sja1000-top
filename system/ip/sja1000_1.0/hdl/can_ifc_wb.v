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
////       Martin Jerabek                                         ////
////       jerabma7@fel.cvut.cz                                   ////
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

module can_ifc_wb
(
  clk_i,
  reg_rst_o,
  reg_cs_o,
  reg_we_o,
  reg_addr_o,
  reg_data_in_o,
  reg_data_out_i,

  wb_clk_i,
  wb_rst_i,
  wb_dat_i,
  wb_dat_o,
  wb_cyc_i,
  wb_stb_i,
  wb_we_i,
  wb_adr_i,
  wb_ack_o,
);

parameter Tp = 1;


  input        wb_clk_i;
  input        wb_rst_i;
  input  [7:0] wb_dat_i;
  output [7:0] wb_dat_o;
  input        wb_cyc_i;
  input        wb_stb_i;
  input        wb_we_i;
  input  [7:0] wb_adr_i;
  output       wb_ack_o;

  input        clk_i;
  output       reg_rst_o;
  output       reg_cs_o;
  output       reg_we_o;
  output [7:0] reg_data_in_o;
  input  [7:0] reg_data_out_i;

  reg          wb_ack_o;
  reg          cs_sync1;
  reg          cs_sync2;
  reg          cs_sync3;
  
  reg          cs_ack1;
  reg          cs_ack2;
  reg          cs_ack3;
  reg          cs_sync_rst1;
  reg          cs_sync_rst2;
  wire         cs_can_i;

  assign cs_can_i = 1'b1;

  // Combining wb_cyc_i and wb_stb_i signals to cs signal. Than synchronizing to clk_i clock domain. 
  always @ (posedge clk_i or posedge rst)
  begin
    if (rst)
      begin
        cs_sync1     <= 1'b0;
        cs_sync2     <= 1'b0;
        cs_sync3     <= 1'b0;
        cs_sync_rst1 <= 1'b0;
        cs_sync_rst2 <= 1'b0;
      end
    else
      begin
        cs_sync1     <=#Tp wb_cyc_i & wb_stb_i & (~cs_sync_rst2) & cs_can_i;
        cs_sync2     <=#Tp cs_sync1            & (~cs_sync_rst2);
        cs_sync3     <=#Tp cs_sync2            & (~cs_sync_rst2);
        cs_sync_rst1 <=#Tp cs_ack3;
        cs_sync_rst2 <=#Tp cs_sync_rst1;
      end
  end
  
  
  assign reg_cs_o = cs_sync2 & (~cs_sync3);
  
  
  always @ (posedge wb_clk_i)
  begin
    cs_ack1 <=#Tp cs_sync3;
    cs_ack2 <=#Tp cs_ack1;
    cs_ack3 <=#Tp cs_ack2;
  end
  
  
  
  // Generating acknowledge signal
  always @ (posedge wb_clk_i)
  begin
    wb_ack_o <=#Tp (cs_ack2 & (~cs_ack3));
  end


  assign reg_rst_o      = wb_rst_i;
  assign reg_we_o       = wb_we_i;
  assign reg_addr_o     = wb_adr_i;
  assign reg_data_in_o  = wb_dat_i;
  assign wb_dat_o       = reg_data_out_i;

endmodule
