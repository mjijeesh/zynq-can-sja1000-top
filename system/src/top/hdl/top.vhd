--Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2015.4 (lin64) Build 1412921 Wed Nov 18 09:44:32 MST 2015
--Date        : Thu Mar 24 18:53:38 2016
--Host        : majernb running 64-bit Gentoo Base System release 2.2
--Command     : generate_target top.bd
--Design      : top
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity s00_couplers_imp_12VJW4O is
  port (
    M_ACLK : in STD_LOGIC;
    M_ARESETN : in STD_LOGIC_VECTOR ( 0 to 0 );
    M_AXI_araddr : out STD_LOGIC;
    M_AXI_arburst : out STD_LOGIC;
    M_AXI_arcache : out STD_LOGIC;
    M_AXI_arid : out STD_LOGIC;
    M_AXI_arlen : out STD_LOGIC;
    M_AXI_arlock : out STD_LOGIC;
    M_AXI_arprot : out STD_LOGIC;
    M_AXI_arqos : out STD_LOGIC;
    M_AXI_arready : in STD_LOGIC;
    M_AXI_arsize : out STD_LOGIC;
    M_AXI_arvalid : out STD_LOGIC;
    M_AXI_awaddr : out STD_LOGIC;
    M_AXI_awburst : out STD_LOGIC;
    M_AXI_awcache : out STD_LOGIC;
    M_AXI_awid : out STD_LOGIC;
    M_AXI_awlen : out STD_LOGIC;
    M_AXI_awlock : out STD_LOGIC;
    M_AXI_awprot : out STD_LOGIC;
    M_AXI_awqos : out STD_LOGIC;
    M_AXI_awready : in STD_LOGIC;
    M_AXI_awsize : out STD_LOGIC;
    M_AXI_awvalid : out STD_LOGIC;
    M_AXI_bid : in STD_LOGIC;
    M_AXI_bready : out STD_LOGIC;
    M_AXI_bresp : in STD_LOGIC;
    M_AXI_bvalid : in STD_LOGIC;
    M_AXI_rdata : in STD_LOGIC;
    M_AXI_rid : in STD_LOGIC;
    M_AXI_rlast : in STD_LOGIC;
    M_AXI_rready : out STD_LOGIC;
    M_AXI_rresp : in STD_LOGIC;
    M_AXI_rvalid : in STD_LOGIC;
    M_AXI_wdata : out STD_LOGIC;
    M_AXI_wid : out STD_LOGIC;
    M_AXI_wlast : out STD_LOGIC;
    M_AXI_wready : in STD_LOGIC;
    M_AXI_wstrb : out STD_LOGIC;
    M_AXI_wvalid : out STD_LOGIC;
    S_ACLK : in STD_LOGIC;
    S_ARESETN : in STD_LOGIC_VECTOR ( 0 to 0 );
    S_AXI_araddr : in STD_LOGIC;
    S_AXI_arburst : in STD_LOGIC;
    S_AXI_arcache : in STD_LOGIC;
    S_AXI_arid : in STD_LOGIC;
    S_AXI_arlen : in STD_LOGIC;
    S_AXI_arlock : in STD_LOGIC;
    S_AXI_arprot : in STD_LOGIC;
    S_AXI_arqos : in STD_LOGIC;
    S_AXI_arready : out STD_LOGIC;
    S_AXI_arsize : in STD_LOGIC;
    S_AXI_arvalid : in STD_LOGIC;
    S_AXI_awaddr : in STD_LOGIC;
    S_AXI_awburst : in STD_LOGIC;
    S_AXI_awcache : in STD_LOGIC;
    S_AXI_awid : in STD_LOGIC;
    S_AXI_awlen : in STD_LOGIC;
    S_AXI_awlock : in STD_LOGIC;
    S_AXI_awprot : in STD_LOGIC;
    S_AXI_awqos : in STD_LOGIC;
    S_AXI_awready : out STD_LOGIC;
    S_AXI_awsize : in STD_LOGIC;
    S_AXI_awvalid : in STD_LOGIC;
    S_AXI_bid : out STD_LOGIC;
    S_AXI_bready : in STD_LOGIC;
    S_AXI_bresp : out STD_LOGIC;
    S_AXI_bvalid : out STD_LOGIC;
    S_AXI_rdata : out STD_LOGIC;
    S_AXI_rid : out STD_LOGIC;
    S_AXI_rlast : out STD_LOGIC;
    S_AXI_rready : in STD_LOGIC;
    S_AXI_rresp : out STD_LOGIC;
    S_AXI_rvalid : out STD_LOGIC;
    S_AXI_wdata : in STD_LOGIC;
    S_AXI_wid : in STD_LOGIC;
    S_AXI_wlast : in STD_LOGIC;
    S_AXI_wready : out STD_LOGIC;
    S_AXI_wstrb : in STD_LOGIC;
    S_AXI_wvalid : in STD_LOGIC
  );
end s00_couplers_imp_12VJW4O;

architecture STRUCTURE of s00_couplers_imp_12VJW4O is
  signal s00_couplers_to_s00_couplers_ARADDR : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_ARBURST : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_ARCACHE : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_ARID : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_ARLEN : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_ARLOCK : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_ARPROT : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_ARQOS : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_ARREADY : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_ARSIZE : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_ARVALID : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_AWADDR : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_AWBURST : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_AWCACHE : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_AWID : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_AWLEN : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_AWLOCK : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_AWPROT : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_AWQOS : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_AWREADY : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_AWSIZE : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_AWVALID : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_BID : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_BREADY : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_BRESP : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_BVALID : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_RDATA : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_RID : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_RLAST : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_RREADY : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_RRESP : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_RVALID : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_WDATA : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_WID : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_WLAST : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_WREADY : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_WSTRB : STD_LOGIC;
  signal s00_couplers_to_s00_couplers_WVALID : STD_LOGIC;
begin
  M_AXI_araddr <= s00_couplers_to_s00_couplers_ARADDR;
  M_AXI_arburst <= s00_couplers_to_s00_couplers_ARBURST;
  M_AXI_arcache <= s00_couplers_to_s00_couplers_ARCACHE;
  M_AXI_arid <= s00_couplers_to_s00_couplers_ARID;
  M_AXI_arlen <= s00_couplers_to_s00_couplers_ARLEN;
  M_AXI_arlock <= s00_couplers_to_s00_couplers_ARLOCK;
  M_AXI_arprot <= s00_couplers_to_s00_couplers_ARPROT;
  M_AXI_arqos <= s00_couplers_to_s00_couplers_ARQOS;
  M_AXI_arsize <= s00_couplers_to_s00_couplers_ARSIZE;
  M_AXI_arvalid <= s00_couplers_to_s00_couplers_ARVALID;
  M_AXI_awaddr <= s00_couplers_to_s00_couplers_AWADDR;
  M_AXI_awburst <= s00_couplers_to_s00_couplers_AWBURST;
  M_AXI_awcache <= s00_couplers_to_s00_couplers_AWCACHE;
  M_AXI_awid <= s00_couplers_to_s00_couplers_AWID;
  M_AXI_awlen <= s00_couplers_to_s00_couplers_AWLEN;
  M_AXI_awlock <= s00_couplers_to_s00_couplers_AWLOCK;
  M_AXI_awprot <= s00_couplers_to_s00_couplers_AWPROT;
  M_AXI_awqos <= s00_couplers_to_s00_couplers_AWQOS;
  M_AXI_awsize <= s00_couplers_to_s00_couplers_AWSIZE;
  M_AXI_awvalid <= s00_couplers_to_s00_couplers_AWVALID;
  M_AXI_bready <= s00_couplers_to_s00_couplers_BREADY;
  M_AXI_rready <= s00_couplers_to_s00_couplers_RREADY;
  M_AXI_wdata <= s00_couplers_to_s00_couplers_WDATA;
  M_AXI_wid <= s00_couplers_to_s00_couplers_WID;
  M_AXI_wlast <= s00_couplers_to_s00_couplers_WLAST;
  M_AXI_wstrb <= s00_couplers_to_s00_couplers_WSTRB;
  M_AXI_wvalid <= s00_couplers_to_s00_couplers_WVALID;
  S_AXI_arready <= s00_couplers_to_s00_couplers_ARREADY;
  S_AXI_awready <= s00_couplers_to_s00_couplers_AWREADY;
  S_AXI_bid <= s00_couplers_to_s00_couplers_BID;
  S_AXI_bresp <= s00_couplers_to_s00_couplers_BRESP;
  S_AXI_bvalid <= s00_couplers_to_s00_couplers_BVALID;
  S_AXI_rdata <= s00_couplers_to_s00_couplers_RDATA;
  S_AXI_rid <= s00_couplers_to_s00_couplers_RID;
  S_AXI_rlast <= s00_couplers_to_s00_couplers_RLAST;
  S_AXI_rresp <= s00_couplers_to_s00_couplers_RRESP;
  S_AXI_rvalid <= s00_couplers_to_s00_couplers_RVALID;
  S_AXI_wready <= s00_couplers_to_s00_couplers_WREADY;
  s00_couplers_to_s00_couplers_ARADDR <= S_AXI_araddr;
  s00_couplers_to_s00_couplers_ARBURST <= S_AXI_arburst;
  s00_couplers_to_s00_couplers_ARCACHE <= S_AXI_arcache;
  s00_couplers_to_s00_couplers_ARID <= S_AXI_arid;
  s00_couplers_to_s00_couplers_ARLEN <= S_AXI_arlen;
  s00_couplers_to_s00_couplers_ARLOCK <= S_AXI_arlock;
  s00_couplers_to_s00_couplers_ARPROT <= S_AXI_arprot;
  s00_couplers_to_s00_couplers_ARQOS <= S_AXI_arqos;
  s00_couplers_to_s00_couplers_ARREADY <= M_AXI_arready;
  s00_couplers_to_s00_couplers_ARSIZE <= S_AXI_arsize;
  s00_couplers_to_s00_couplers_ARVALID <= S_AXI_arvalid;
  s00_couplers_to_s00_couplers_AWADDR <= S_AXI_awaddr;
  s00_couplers_to_s00_couplers_AWBURST <= S_AXI_awburst;
  s00_couplers_to_s00_couplers_AWCACHE <= S_AXI_awcache;
  s00_couplers_to_s00_couplers_AWID <= S_AXI_awid;
  s00_couplers_to_s00_couplers_AWLEN <= S_AXI_awlen;
  s00_couplers_to_s00_couplers_AWLOCK <= S_AXI_awlock;
  s00_couplers_to_s00_couplers_AWPROT <= S_AXI_awprot;
  s00_couplers_to_s00_couplers_AWQOS <= S_AXI_awqos;
  s00_couplers_to_s00_couplers_AWREADY <= M_AXI_awready;
  s00_couplers_to_s00_couplers_AWSIZE <= S_AXI_awsize;
  s00_couplers_to_s00_couplers_AWVALID <= S_AXI_awvalid;
  s00_couplers_to_s00_couplers_BID <= M_AXI_bid;
  s00_couplers_to_s00_couplers_BREADY <= S_AXI_bready;
  s00_couplers_to_s00_couplers_BRESP <= M_AXI_bresp;
  s00_couplers_to_s00_couplers_BVALID <= M_AXI_bvalid;
  s00_couplers_to_s00_couplers_RDATA <= M_AXI_rdata;
  s00_couplers_to_s00_couplers_RID <= M_AXI_rid;
  s00_couplers_to_s00_couplers_RLAST <= M_AXI_rlast;
  s00_couplers_to_s00_couplers_RREADY <= S_AXI_rready;
  s00_couplers_to_s00_couplers_RRESP <= M_AXI_rresp;
  s00_couplers_to_s00_couplers_RVALID <= M_AXI_rvalid;
  s00_couplers_to_s00_couplers_WDATA <= S_AXI_wdata;
  s00_couplers_to_s00_couplers_WID <= S_AXI_wid;
  s00_couplers_to_s00_couplers_WLAST <= S_AXI_wlast;
  s00_couplers_to_s00_couplers_WREADY <= M_AXI_wready;
  s00_couplers_to_s00_couplers_WSTRB <= S_AXI_wstrb;
  s00_couplers_to_s00_couplers_WVALID <= S_AXI_wvalid;
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity top_processing_system7_0_axi_periph_0 is
  port (
    ACLK : in STD_LOGIC;
    ARESETN : in STD_LOGIC_VECTOR ( 0 to 0 );
    M00_ACLK : in STD_LOGIC;
    M00_ARESETN : in STD_LOGIC_VECTOR ( 0 to 0 );
    M00_AXI_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M00_AXI_arready : in STD_LOGIC;
    M00_AXI_arvalid : out STD_LOGIC;
    M00_AXI_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M00_AXI_awready : in STD_LOGIC;
    M00_AXI_awvalid : out STD_LOGIC;
    M00_AXI_bready : out STD_LOGIC;
    M00_AXI_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_bvalid : in STD_LOGIC;
    M00_AXI_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M00_AXI_rready : out STD_LOGIC;
    M00_AXI_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_rvalid : in STD_LOGIC;
    M00_AXI_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M00_AXI_wready : in STD_LOGIC;
    M00_AXI_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_wvalid : out STD_LOGIC;
    S00_ACLK : in STD_LOGIC;
    S00_ARESETN : in STD_LOGIC_VECTOR ( 0 to 0 );
    S00_AXI_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S00_AXI_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_arid : in STD_LOGIC_VECTOR ( 11 downto 0 );
    S00_AXI_arlen : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_arlock : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_arready : out STD_LOGIC;
    S00_AXI_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_arvalid : in STD_LOGIC;
    S00_AXI_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S00_AXI_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_awid : in STD_LOGIC_VECTOR ( 11 downto 0 );
    S00_AXI_awlen : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_awlock : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_awready : out STD_LOGIC;
    S00_AXI_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_awvalid : in STD_LOGIC;
    S00_AXI_bid : out STD_LOGIC_VECTOR ( 11 downto 0 );
    S00_AXI_bready : in STD_LOGIC;
    S00_AXI_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_bvalid : out STD_LOGIC;
    S00_AXI_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S00_AXI_rid : out STD_LOGIC_VECTOR ( 11 downto 0 );
    S00_AXI_rlast : out STD_LOGIC;
    S00_AXI_rready : in STD_LOGIC;
    S00_AXI_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_rvalid : out STD_LOGIC;
    S00_AXI_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S00_AXI_wid : in STD_LOGIC_VECTOR ( 11 downto 0 );
    S00_AXI_wlast : in STD_LOGIC;
    S00_AXI_wready : out STD_LOGIC;
    S00_AXI_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_wvalid : in STD_LOGIC
  );
end top_processing_system7_0_axi_periph_0;

architecture STRUCTURE of top_processing_system7_0_axi_periph_0 is
  signal S00_ACLK_1 : STD_LOGIC;
  signal S00_ARESETN_1 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal processing_system7_0_axi_periph_ACLK_net : STD_LOGIC;
  signal processing_system7_0_axi_periph_ARESETN_net : STD_LOGIC_VECTOR ( 0 to 0 );
  signal processing_system7_0_axi_periph_to_s00_couplers_ARADDR : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal processing_system7_0_axi_periph_to_s00_couplers_ARBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal processing_system7_0_axi_periph_to_s00_couplers_ARCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal processing_system7_0_axi_periph_to_s00_couplers_ARID : STD_LOGIC_VECTOR ( 11 downto 0 );
  signal processing_system7_0_axi_periph_to_s00_couplers_ARLEN : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal processing_system7_0_axi_periph_to_s00_couplers_ARLOCK : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal processing_system7_0_axi_periph_to_s00_couplers_ARPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal processing_system7_0_axi_periph_to_s00_couplers_ARQOS : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal processing_system7_0_axi_periph_to_s00_couplers_ARREADY : STD_LOGIC;
  signal processing_system7_0_axi_periph_to_s00_couplers_ARSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal processing_system7_0_axi_periph_to_s00_couplers_ARVALID : STD_LOGIC;
  signal processing_system7_0_axi_periph_to_s00_couplers_AWADDR : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal processing_system7_0_axi_periph_to_s00_couplers_AWBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal processing_system7_0_axi_periph_to_s00_couplers_AWCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal processing_system7_0_axi_periph_to_s00_couplers_AWID : STD_LOGIC_VECTOR ( 11 downto 0 );
  signal processing_system7_0_axi_periph_to_s00_couplers_AWLEN : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal processing_system7_0_axi_periph_to_s00_couplers_AWLOCK : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal processing_system7_0_axi_periph_to_s00_couplers_AWPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal processing_system7_0_axi_periph_to_s00_couplers_AWQOS : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal processing_system7_0_axi_periph_to_s00_couplers_AWREADY : STD_LOGIC;
  signal processing_system7_0_axi_periph_to_s00_couplers_AWSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal processing_system7_0_axi_periph_to_s00_couplers_AWVALID : STD_LOGIC;
  signal processing_system7_0_axi_periph_to_s00_couplers_BID : STD_LOGIC;
  signal processing_system7_0_axi_periph_to_s00_couplers_BREADY : STD_LOGIC;
  signal processing_system7_0_axi_periph_to_s00_couplers_BRESP : STD_LOGIC;
  signal processing_system7_0_axi_periph_to_s00_couplers_BVALID : STD_LOGIC;
  signal processing_system7_0_axi_periph_to_s00_couplers_RDATA : STD_LOGIC;
  signal processing_system7_0_axi_periph_to_s00_couplers_RID : STD_LOGIC;
  signal processing_system7_0_axi_periph_to_s00_couplers_RLAST : STD_LOGIC;
  signal processing_system7_0_axi_periph_to_s00_couplers_RREADY : STD_LOGIC;
  signal processing_system7_0_axi_periph_to_s00_couplers_RRESP : STD_LOGIC;
  signal processing_system7_0_axi_periph_to_s00_couplers_RVALID : STD_LOGIC;
  signal processing_system7_0_axi_periph_to_s00_couplers_WDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal processing_system7_0_axi_periph_to_s00_couplers_WID : STD_LOGIC_VECTOR ( 11 downto 0 );
  signal processing_system7_0_axi_periph_to_s00_couplers_WLAST : STD_LOGIC;
  signal processing_system7_0_axi_periph_to_s00_couplers_WREADY : STD_LOGIC;
  signal processing_system7_0_axi_periph_to_s00_couplers_WSTRB : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal processing_system7_0_axi_periph_to_s00_couplers_WVALID : STD_LOGIC;
  signal s00_couplers_to_processing_system7_0_axi_periph_ARADDR : STD_LOGIC;
  signal s00_couplers_to_processing_system7_0_axi_periph_ARREADY : STD_LOGIC;
  signal s00_couplers_to_processing_system7_0_axi_periph_ARVALID : STD_LOGIC;
  signal s00_couplers_to_processing_system7_0_axi_periph_AWADDR : STD_LOGIC;
  signal s00_couplers_to_processing_system7_0_axi_periph_AWREADY : STD_LOGIC;
  signal s00_couplers_to_processing_system7_0_axi_periph_AWVALID : STD_LOGIC;
  signal s00_couplers_to_processing_system7_0_axi_periph_BREADY : STD_LOGIC;
  signal s00_couplers_to_processing_system7_0_axi_periph_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal s00_couplers_to_processing_system7_0_axi_periph_BVALID : STD_LOGIC;
  signal s00_couplers_to_processing_system7_0_axi_periph_RDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal s00_couplers_to_processing_system7_0_axi_periph_RREADY : STD_LOGIC;
  signal s00_couplers_to_processing_system7_0_axi_periph_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal s00_couplers_to_processing_system7_0_axi_periph_RVALID : STD_LOGIC;
  signal s00_couplers_to_processing_system7_0_axi_periph_WDATA : STD_LOGIC;
  signal s00_couplers_to_processing_system7_0_axi_periph_WREADY : STD_LOGIC;
  signal s00_couplers_to_processing_system7_0_axi_periph_WSTRB : STD_LOGIC;
  signal s00_couplers_to_processing_system7_0_axi_periph_WVALID : STD_LOGIC;
  signal NLW_s00_couplers_M_AXI_arburst_UNCONNECTED : STD_LOGIC;
  signal NLW_s00_couplers_M_AXI_arcache_UNCONNECTED : STD_LOGIC;
  signal NLW_s00_couplers_M_AXI_arid_UNCONNECTED : STD_LOGIC;
  signal NLW_s00_couplers_M_AXI_arlen_UNCONNECTED : STD_LOGIC;
  signal NLW_s00_couplers_M_AXI_arlock_UNCONNECTED : STD_LOGIC;
  signal NLW_s00_couplers_M_AXI_arprot_UNCONNECTED : STD_LOGIC;
  signal NLW_s00_couplers_M_AXI_arqos_UNCONNECTED : STD_LOGIC;
  signal NLW_s00_couplers_M_AXI_arsize_UNCONNECTED : STD_LOGIC;
  signal NLW_s00_couplers_M_AXI_awburst_UNCONNECTED : STD_LOGIC;
  signal NLW_s00_couplers_M_AXI_awcache_UNCONNECTED : STD_LOGIC;
  signal NLW_s00_couplers_M_AXI_awid_UNCONNECTED : STD_LOGIC;
  signal NLW_s00_couplers_M_AXI_awlen_UNCONNECTED : STD_LOGIC;
  signal NLW_s00_couplers_M_AXI_awlock_UNCONNECTED : STD_LOGIC;
  signal NLW_s00_couplers_M_AXI_awprot_UNCONNECTED : STD_LOGIC;
  signal NLW_s00_couplers_M_AXI_awqos_UNCONNECTED : STD_LOGIC;
  signal NLW_s00_couplers_M_AXI_awsize_UNCONNECTED : STD_LOGIC;
  signal NLW_s00_couplers_M_AXI_wid_UNCONNECTED : STD_LOGIC;
  signal NLW_s00_couplers_M_AXI_wlast_UNCONNECTED : STD_LOGIC;
begin
  M00_AXI_araddr(31) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(30) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(29) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(28) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(27) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(26) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(25) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(24) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(23) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(22) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(21) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(20) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(19) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(18) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(17) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(16) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(15) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(14) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(13) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(12) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(11) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(10) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(9) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(8) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(7) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(6) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(5) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(4) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(3) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(2) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(1) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_araddr(0) <= s00_couplers_to_processing_system7_0_axi_periph_ARADDR;
  M00_AXI_arvalid <= s00_couplers_to_processing_system7_0_axi_periph_ARVALID;
  M00_AXI_awaddr(31) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(30) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(29) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(28) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(27) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(26) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(25) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(24) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(23) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(22) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(21) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(20) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(19) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(18) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(17) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(16) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(15) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(14) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(13) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(12) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(11) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(10) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(9) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(8) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(7) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(6) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(5) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(4) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(3) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(2) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(1) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awaddr(0) <= s00_couplers_to_processing_system7_0_axi_periph_AWADDR;
  M00_AXI_awvalid <= s00_couplers_to_processing_system7_0_axi_periph_AWVALID;
  M00_AXI_bready <= s00_couplers_to_processing_system7_0_axi_periph_BREADY;
  M00_AXI_rready <= s00_couplers_to_processing_system7_0_axi_periph_RREADY;
  M00_AXI_wdata(31) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(30) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(29) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(28) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(27) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(26) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(25) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(24) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(23) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(22) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(21) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(20) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(19) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(18) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(17) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(16) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(15) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(14) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(13) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(12) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(11) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(10) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(9) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(8) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(7) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(6) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(5) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(4) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(3) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(2) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(1) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wdata(0) <= s00_couplers_to_processing_system7_0_axi_periph_WDATA;
  M00_AXI_wstrb(3) <= s00_couplers_to_processing_system7_0_axi_periph_WSTRB;
  M00_AXI_wstrb(2) <= s00_couplers_to_processing_system7_0_axi_periph_WSTRB;
  M00_AXI_wstrb(1) <= s00_couplers_to_processing_system7_0_axi_periph_WSTRB;
  M00_AXI_wstrb(0) <= s00_couplers_to_processing_system7_0_axi_periph_WSTRB;
  M00_AXI_wvalid <= s00_couplers_to_processing_system7_0_axi_periph_WVALID;
  S00_ACLK_1 <= S00_ACLK;
  S00_ARESETN_1(0) <= S00_ARESETN(0);
  S00_AXI_arready <= processing_system7_0_axi_periph_to_s00_couplers_ARREADY;
  S00_AXI_awready <= processing_system7_0_axi_periph_to_s00_couplers_AWREADY;
  S00_AXI_bid(11) <= processing_system7_0_axi_periph_to_s00_couplers_BID;
  S00_AXI_bid(10) <= processing_system7_0_axi_periph_to_s00_couplers_BID;
  S00_AXI_bid(9) <= processing_system7_0_axi_periph_to_s00_couplers_BID;
  S00_AXI_bid(8) <= processing_system7_0_axi_periph_to_s00_couplers_BID;
  S00_AXI_bid(7) <= processing_system7_0_axi_periph_to_s00_couplers_BID;
  S00_AXI_bid(6) <= processing_system7_0_axi_periph_to_s00_couplers_BID;
  S00_AXI_bid(5) <= processing_system7_0_axi_periph_to_s00_couplers_BID;
  S00_AXI_bid(4) <= processing_system7_0_axi_periph_to_s00_couplers_BID;
  S00_AXI_bid(3) <= processing_system7_0_axi_periph_to_s00_couplers_BID;
  S00_AXI_bid(2) <= processing_system7_0_axi_periph_to_s00_couplers_BID;
  S00_AXI_bid(1) <= processing_system7_0_axi_periph_to_s00_couplers_BID;
  S00_AXI_bid(0) <= processing_system7_0_axi_periph_to_s00_couplers_BID;
  S00_AXI_bresp(1) <= processing_system7_0_axi_periph_to_s00_couplers_BRESP;
  S00_AXI_bresp(0) <= processing_system7_0_axi_periph_to_s00_couplers_BRESP;
  S00_AXI_bvalid <= processing_system7_0_axi_periph_to_s00_couplers_BVALID;
  S00_AXI_rdata(31) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(30) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(29) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(28) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(27) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(26) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(25) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(24) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(23) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(22) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(21) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(20) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(19) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(18) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(17) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(16) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(15) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(14) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(13) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(12) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(11) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(10) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(9) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(8) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(7) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(6) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(5) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(4) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(3) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(2) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(1) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rdata(0) <= processing_system7_0_axi_periph_to_s00_couplers_RDATA;
  S00_AXI_rid(11) <= processing_system7_0_axi_periph_to_s00_couplers_RID;
  S00_AXI_rid(10) <= processing_system7_0_axi_periph_to_s00_couplers_RID;
  S00_AXI_rid(9) <= processing_system7_0_axi_periph_to_s00_couplers_RID;
  S00_AXI_rid(8) <= processing_system7_0_axi_periph_to_s00_couplers_RID;
  S00_AXI_rid(7) <= processing_system7_0_axi_periph_to_s00_couplers_RID;
  S00_AXI_rid(6) <= processing_system7_0_axi_periph_to_s00_couplers_RID;
  S00_AXI_rid(5) <= processing_system7_0_axi_periph_to_s00_couplers_RID;
  S00_AXI_rid(4) <= processing_system7_0_axi_periph_to_s00_couplers_RID;
  S00_AXI_rid(3) <= processing_system7_0_axi_periph_to_s00_couplers_RID;
  S00_AXI_rid(2) <= processing_system7_0_axi_periph_to_s00_couplers_RID;
  S00_AXI_rid(1) <= processing_system7_0_axi_periph_to_s00_couplers_RID;
  S00_AXI_rid(0) <= processing_system7_0_axi_periph_to_s00_couplers_RID;
  S00_AXI_rlast <= processing_system7_0_axi_periph_to_s00_couplers_RLAST;
  S00_AXI_rresp(1) <= processing_system7_0_axi_periph_to_s00_couplers_RRESP;
  S00_AXI_rresp(0) <= processing_system7_0_axi_periph_to_s00_couplers_RRESP;
  S00_AXI_rvalid <= processing_system7_0_axi_periph_to_s00_couplers_RVALID;
  S00_AXI_wready <= processing_system7_0_axi_periph_to_s00_couplers_WREADY;
  processing_system7_0_axi_periph_ACLK_net <= M00_ACLK;
  processing_system7_0_axi_periph_ARESETN_net(0) <= M00_ARESETN(0);
  processing_system7_0_axi_periph_to_s00_couplers_ARADDR(31 downto 0) <= S00_AXI_araddr(31 downto 0);
  processing_system7_0_axi_periph_to_s00_couplers_ARBURST(1 downto 0) <= S00_AXI_arburst(1 downto 0);
  processing_system7_0_axi_periph_to_s00_couplers_ARCACHE(3 downto 0) <= S00_AXI_arcache(3 downto 0);
  processing_system7_0_axi_periph_to_s00_couplers_ARID(11 downto 0) <= S00_AXI_arid(11 downto 0);
  processing_system7_0_axi_periph_to_s00_couplers_ARLEN(3 downto 0) <= S00_AXI_arlen(3 downto 0);
  processing_system7_0_axi_periph_to_s00_couplers_ARLOCK(1 downto 0) <= S00_AXI_arlock(1 downto 0);
  processing_system7_0_axi_periph_to_s00_couplers_ARPROT(2 downto 0) <= S00_AXI_arprot(2 downto 0);
  processing_system7_0_axi_periph_to_s00_couplers_ARQOS(3 downto 0) <= S00_AXI_arqos(3 downto 0);
  processing_system7_0_axi_periph_to_s00_couplers_ARSIZE(2 downto 0) <= S00_AXI_arsize(2 downto 0);
  processing_system7_0_axi_periph_to_s00_couplers_ARVALID <= S00_AXI_arvalid;
  processing_system7_0_axi_periph_to_s00_couplers_AWADDR(31 downto 0) <= S00_AXI_awaddr(31 downto 0);
  processing_system7_0_axi_periph_to_s00_couplers_AWBURST(1 downto 0) <= S00_AXI_awburst(1 downto 0);
  processing_system7_0_axi_periph_to_s00_couplers_AWCACHE(3 downto 0) <= S00_AXI_awcache(3 downto 0);
  processing_system7_0_axi_periph_to_s00_couplers_AWID(11 downto 0) <= S00_AXI_awid(11 downto 0);
  processing_system7_0_axi_periph_to_s00_couplers_AWLEN(3 downto 0) <= S00_AXI_awlen(3 downto 0);
  processing_system7_0_axi_periph_to_s00_couplers_AWLOCK(1 downto 0) <= S00_AXI_awlock(1 downto 0);
  processing_system7_0_axi_periph_to_s00_couplers_AWPROT(2 downto 0) <= S00_AXI_awprot(2 downto 0);
  processing_system7_0_axi_periph_to_s00_couplers_AWQOS(3 downto 0) <= S00_AXI_awqos(3 downto 0);
  processing_system7_0_axi_periph_to_s00_couplers_AWSIZE(2 downto 0) <= S00_AXI_awsize(2 downto 0);
  processing_system7_0_axi_periph_to_s00_couplers_AWVALID <= S00_AXI_awvalid;
  processing_system7_0_axi_periph_to_s00_couplers_BREADY <= S00_AXI_bready;
  processing_system7_0_axi_periph_to_s00_couplers_RREADY <= S00_AXI_rready;
  processing_system7_0_axi_periph_to_s00_couplers_WDATA(31 downto 0) <= S00_AXI_wdata(31 downto 0);
  processing_system7_0_axi_periph_to_s00_couplers_WID(11 downto 0) <= S00_AXI_wid(11 downto 0);
  processing_system7_0_axi_periph_to_s00_couplers_WLAST <= S00_AXI_wlast;
  processing_system7_0_axi_periph_to_s00_couplers_WSTRB(3 downto 0) <= S00_AXI_wstrb(3 downto 0);
  processing_system7_0_axi_periph_to_s00_couplers_WVALID <= S00_AXI_wvalid;
  s00_couplers_to_processing_system7_0_axi_periph_ARREADY <= M00_AXI_arready;
  s00_couplers_to_processing_system7_0_axi_periph_AWREADY <= M00_AXI_awready;
  s00_couplers_to_processing_system7_0_axi_periph_BRESP(1 downto 0) <= M00_AXI_bresp(1 downto 0);
  s00_couplers_to_processing_system7_0_axi_periph_BVALID <= M00_AXI_bvalid;
  s00_couplers_to_processing_system7_0_axi_periph_RDATA(31 downto 0) <= M00_AXI_rdata(31 downto 0);
  s00_couplers_to_processing_system7_0_axi_periph_RRESP(1 downto 0) <= M00_AXI_rresp(1 downto 0);
  s00_couplers_to_processing_system7_0_axi_periph_RVALID <= M00_AXI_rvalid;
  s00_couplers_to_processing_system7_0_axi_periph_WREADY <= M00_AXI_wready;
s00_couplers: entity work.s00_couplers_imp_12VJW4O
     port map (
      M_ACLK => processing_system7_0_axi_periph_ACLK_net,
      M_ARESETN(0) => processing_system7_0_axi_periph_ARESETN_net(0),
      M_AXI_araddr => s00_couplers_to_processing_system7_0_axi_periph_ARADDR,
      M_AXI_arburst => NLW_s00_couplers_M_AXI_arburst_UNCONNECTED,
      M_AXI_arcache => NLW_s00_couplers_M_AXI_arcache_UNCONNECTED,
      M_AXI_arid => NLW_s00_couplers_M_AXI_arid_UNCONNECTED,
      M_AXI_arlen => NLW_s00_couplers_M_AXI_arlen_UNCONNECTED,
      M_AXI_arlock => NLW_s00_couplers_M_AXI_arlock_UNCONNECTED,
      M_AXI_arprot => NLW_s00_couplers_M_AXI_arprot_UNCONNECTED,
      M_AXI_arqos => NLW_s00_couplers_M_AXI_arqos_UNCONNECTED,
      M_AXI_arready => s00_couplers_to_processing_system7_0_axi_periph_ARREADY,
      M_AXI_arsize => NLW_s00_couplers_M_AXI_arsize_UNCONNECTED,
      M_AXI_arvalid => s00_couplers_to_processing_system7_0_axi_periph_ARVALID,
      M_AXI_awaddr => s00_couplers_to_processing_system7_0_axi_periph_AWADDR,
      M_AXI_awburst => NLW_s00_couplers_M_AXI_awburst_UNCONNECTED,
      M_AXI_awcache => NLW_s00_couplers_M_AXI_awcache_UNCONNECTED,
      M_AXI_awid => NLW_s00_couplers_M_AXI_awid_UNCONNECTED,
      M_AXI_awlen => NLW_s00_couplers_M_AXI_awlen_UNCONNECTED,
      M_AXI_awlock => NLW_s00_couplers_M_AXI_awlock_UNCONNECTED,
      M_AXI_awprot => NLW_s00_couplers_M_AXI_awprot_UNCONNECTED,
      M_AXI_awqos => NLW_s00_couplers_M_AXI_awqos_UNCONNECTED,
      M_AXI_awready => s00_couplers_to_processing_system7_0_axi_periph_AWREADY,
      M_AXI_awsize => NLW_s00_couplers_M_AXI_awsize_UNCONNECTED,
      M_AXI_awvalid => s00_couplers_to_processing_system7_0_axi_periph_AWVALID,
      M_AXI_bid => '0',
      M_AXI_bready => s00_couplers_to_processing_system7_0_axi_periph_BREADY,
      M_AXI_bresp => s00_couplers_to_processing_system7_0_axi_periph_BRESP(0),
      M_AXI_bvalid => s00_couplers_to_processing_system7_0_axi_periph_BVALID,
      M_AXI_rdata => s00_couplers_to_processing_system7_0_axi_periph_RDATA(0),
      M_AXI_rid => '0',
      M_AXI_rlast => '0',
      M_AXI_rready => s00_couplers_to_processing_system7_0_axi_periph_RREADY,
      M_AXI_rresp => s00_couplers_to_processing_system7_0_axi_periph_RRESP(0),
      M_AXI_rvalid => s00_couplers_to_processing_system7_0_axi_periph_RVALID,
      M_AXI_wdata => s00_couplers_to_processing_system7_0_axi_periph_WDATA,
      M_AXI_wid => NLW_s00_couplers_M_AXI_wid_UNCONNECTED,
      M_AXI_wlast => NLW_s00_couplers_M_AXI_wlast_UNCONNECTED,
      M_AXI_wready => s00_couplers_to_processing_system7_0_axi_periph_WREADY,
      M_AXI_wstrb => s00_couplers_to_processing_system7_0_axi_periph_WSTRB,
      M_AXI_wvalid => s00_couplers_to_processing_system7_0_axi_periph_WVALID,
      S_ACLK => S00_ACLK_1,
      S_ARESETN(0) => S00_ARESETN_1(0),
      S_AXI_araddr => processing_system7_0_axi_periph_to_s00_couplers_ARADDR(0),
      S_AXI_arburst => processing_system7_0_axi_periph_to_s00_couplers_ARBURST(0),
      S_AXI_arcache => processing_system7_0_axi_periph_to_s00_couplers_ARCACHE(0),
      S_AXI_arid => processing_system7_0_axi_periph_to_s00_couplers_ARID(0),
      S_AXI_arlen => processing_system7_0_axi_periph_to_s00_couplers_ARLEN(0),
      S_AXI_arlock => processing_system7_0_axi_periph_to_s00_couplers_ARLOCK(0),
      S_AXI_arprot => processing_system7_0_axi_periph_to_s00_couplers_ARPROT(0),
      S_AXI_arqos => processing_system7_0_axi_periph_to_s00_couplers_ARQOS(0),
      S_AXI_arready => processing_system7_0_axi_periph_to_s00_couplers_ARREADY,
      S_AXI_arsize => processing_system7_0_axi_periph_to_s00_couplers_ARSIZE(0),
      S_AXI_arvalid => processing_system7_0_axi_periph_to_s00_couplers_ARVALID,
      S_AXI_awaddr => processing_system7_0_axi_periph_to_s00_couplers_AWADDR(0),
      S_AXI_awburst => processing_system7_0_axi_periph_to_s00_couplers_AWBURST(0),
      S_AXI_awcache => processing_system7_0_axi_periph_to_s00_couplers_AWCACHE(0),
      S_AXI_awid => processing_system7_0_axi_periph_to_s00_couplers_AWID(0),
      S_AXI_awlen => processing_system7_0_axi_periph_to_s00_couplers_AWLEN(0),
      S_AXI_awlock => processing_system7_0_axi_periph_to_s00_couplers_AWLOCK(0),
      S_AXI_awprot => processing_system7_0_axi_periph_to_s00_couplers_AWPROT(0),
      S_AXI_awqos => processing_system7_0_axi_periph_to_s00_couplers_AWQOS(0),
      S_AXI_awready => processing_system7_0_axi_periph_to_s00_couplers_AWREADY,
      S_AXI_awsize => processing_system7_0_axi_periph_to_s00_couplers_AWSIZE(0),
      S_AXI_awvalid => processing_system7_0_axi_periph_to_s00_couplers_AWVALID,
      S_AXI_bid => processing_system7_0_axi_periph_to_s00_couplers_BID,
      S_AXI_bready => processing_system7_0_axi_periph_to_s00_couplers_BREADY,
      S_AXI_bresp => processing_system7_0_axi_periph_to_s00_couplers_BRESP,
      S_AXI_bvalid => processing_system7_0_axi_periph_to_s00_couplers_BVALID,
      S_AXI_rdata => processing_system7_0_axi_periph_to_s00_couplers_RDATA,
      S_AXI_rid => processing_system7_0_axi_periph_to_s00_couplers_RID,
      S_AXI_rlast => processing_system7_0_axi_periph_to_s00_couplers_RLAST,
      S_AXI_rready => processing_system7_0_axi_periph_to_s00_couplers_RREADY,
      S_AXI_rresp => processing_system7_0_axi_periph_to_s00_couplers_RRESP,
      S_AXI_rvalid => processing_system7_0_axi_periph_to_s00_couplers_RVALID,
      S_AXI_wdata => processing_system7_0_axi_periph_to_s00_couplers_WDATA(0),
      S_AXI_wid => processing_system7_0_axi_periph_to_s00_couplers_WID(0),
      S_AXI_wlast => processing_system7_0_axi_periph_to_s00_couplers_WLAST,
      S_AXI_wready => processing_system7_0_axi_periph_to_s00_couplers_WREADY,
      S_AXI_wstrb => processing_system7_0_axi_periph_to_s00_couplers_WSTRB(0),
      S_AXI_wvalid => processing_system7_0_axi_periph_to_s00_couplers_WVALID
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity top is
  port (
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_cas_n : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC
  );
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of top : entity is "top,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=top,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=5,numReposBlks=3,numNonXlnxBlks=1,numHierBlks=2,maxHierDepth=0,da_axi4_cnt=1,da_ps7_cnt=2,synth_mode=Global}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of top : entity is "top.hwdef";
end top;

architecture STRUCTURE of top is
  component top_processing_system7_0_1 is
  port (
    CAN0_PHY_TX : out STD_LOGIC;
    CAN0_PHY_RX : in STD_LOGIC;
    CAN1_PHY_TX : out STD_LOGIC;
    CAN1_PHY_RX : in STD_LOGIC;
    TTC0_WAVE0_OUT : out STD_LOGIC;
    TTC0_WAVE1_OUT : out STD_LOGIC;
    TTC0_WAVE2_OUT : out STD_LOGIC;
    USB0_PORT_INDCTL : out STD_LOGIC_VECTOR ( 1 downto 0 );
    USB0_VBUS_PWRSELECT : out STD_LOGIC;
    USB0_VBUS_PWRFAULT : in STD_LOGIC;
    M_AXI_GP0_ARVALID : out STD_LOGIC;
    M_AXI_GP0_AWVALID : out STD_LOGIC;
    M_AXI_GP0_BREADY : out STD_LOGIC;
    M_AXI_GP0_RREADY : out STD_LOGIC;
    M_AXI_GP0_WLAST : out STD_LOGIC;
    M_AXI_GP0_WVALID : out STD_LOGIC;
    M_AXI_GP0_ARID : out STD_LOGIC_VECTOR ( 11 downto 0 );
    M_AXI_GP0_AWID : out STD_LOGIC_VECTOR ( 11 downto 0 );
    M_AXI_GP0_WID : out STD_LOGIC_VECTOR ( 11 downto 0 );
    M_AXI_GP0_ARBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_GP0_ARLOCK : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_GP0_ARSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXI_GP0_AWBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_GP0_AWLOCK : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_GP0_AWSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXI_GP0_ARPROT : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXI_GP0_AWPROT : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXI_GP0_ARADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXI_GP0_AWADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXI_GP0_WDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXI_GP0_ARCACHE : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_GP0_ARLEN : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_GP0_ARQOS : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_GP0_AWCACHE : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_GP0_AWLEN : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_GP0_AWQOS : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_GP0_WSTRB : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_GP0_ACLK : in STD_LOGIC;
    M_AXI_GP0_ARREADY : in STD_LOGIC;
    M_AXI_GP0_AWREADY : in STD_LOGIC;
    M_AXI_GP0_BVALID : in STD_LOGIC;
    M_AXI_GP0_RLAST : in STD_LOGIC;
    M_AXI_GP0_RVALID : in STD_LOGIC;
    M_AXI_GP0_WREADY : in STD_LOGIC;
    M_AXI_GP0_BID : in STD_LOGIC_VECTOR ( 11 downto 0 );
    M_AXI_GP0_RID : in STD_LOGIC_VECTOR ( 11 downto 0 );
    M_AXI_GP0_BRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_GP0_RRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_GP0_RDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    FCLK_CLK0 : out STD_LOGIC;
    FCLK_RESET0_N : out STD_LOGIC;
    MIO : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    DDR_CAS_n : inout STD_LOGIC;
    DDR_CKE : inout STD_LOGIC;
    DDR_Clk_n : inout STD_LOGIC;
    DDR_Clk : inout STD_LOGIC;
    DDR_CS_n : inout STD_LOGIC;
    DDR_DRSTB : inout STD_LOGIC;
    DDR_ODT : inout STD_LOGIC;
    DDR_RAS_n : inout STD_LOGIC;
    DDR_WEB : inout STD_LOGIC;
    DDR_BankAddr : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_Addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_VRN : inout STD_LOGIC;
    DDR_VRP : inout STD_LOGIC;
    DDR_DM : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_DQ : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_DQS_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_DQS : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    PS_SRSTB : inout STD_LOGIC;
    PS_CLK : inout STD_LOGIC;
    PS_PORB : inout STD_LOGIC
  );
  end component top_processing_system7_0_1;
  component top_rst_processing_system7_0_100M_0 is
  port (
    slowest_sync_clk : in STD_LOGIC;
    ext_reset_in : in STD_LOGIC;
    aux_reset_in : in STD_LOGIC;
    mb_debug_sys_rst : in STD_LOGIC;
    dcm_locked : in STD_LOGIC;
    mb_reset : out STD_LOGIC;
    bus_struct_reset : out STD_LOGIC_VECTOR ( 0 to 0 );
    peripheral_reset : out STD_LOGIC_VECTOR ( 0 to 0 );
    interconnect_aresetn : out STD_LOGIC_VECTOR ( 0 to 0 );
    peripheral_aresetn : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component top_rst_processing_system7_0_100M_0;
  component top_can_merge_0_1 is
  port (
    can_rx : out STD_LOGIC;
    can_tx1 : in STD_LOGIC;
    can_tx2 : in STD_LOGIC;
    can_tx3 : in STD_LOGIC
  );
  end component top_can_merge_0_1;
  signal can_merge_0_can_rx : STD_LOGIC;
  signal processing_system7_0_CAN0_PHY_TX : STD_LOGIC;
  signal processing_system7_0_CAN1_PHY_TX : STD_LOGIC;
  signal processing_system7_0_DDR_ADDR : STD_LOGIC_VECTOR ( 14 downto 0 );
  signal processing_system7_0_DDR_BA : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal processing_system7_0_DDR_CAS_N : STD_LOGIC;
  signal processing_system7_0_DDR_CKE : STD_LOGIC;
  signal processing_system7_0_DDR_CK_N : STD_LOGIC;
  signal processing_system7_0_DDR_CK_P : STD_LOGIC;
  signal processing_system7_0_DDR_CS_N : STD_LOGIC;
  signal processing_system7_0_DDR_DM : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal processing_system7_0_DDR_DQ : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal processing_system7_0_DDR_DQS_N : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal processing_system7_0_DDR_DQS_P : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal processing_system7_0_DDR_ODT : STD_LOGIC;
  signal processing_system7_0_DDR_RAS_N : STD_LOGIC;
  signal processing_system7_0_DDR_RESET_N : STD_LOGIC;
  signal processing_system7_0_DDR_WE_N : STD_LOGIC;
  signal processing_system7_0_FCLK_CLK0 : STD_LOGIC;
  signal processing_system7_0_FCLK_RESET0_N : STD_LOGIC;
  signal processing_system7_0_FIXED_IO_DDR_VRN : STD_LOGIC;
  signal processing_system7_0_FIXED_IO_DDR_VRP : STD_LOGIC;
  signal processing_system7_0_FIXED_IO_MIO : STD_LOGIC_VECTOR ( 53 downto 0 );
  signal processing_system7_0_FIXED_IO_PS_CLK : STD_LOGIC;
  signal processing_system7_0_FIXED_IO_PS_PORB : STD_LOGIC;
  signal processing_system7_0_FIXED_IO_PS_SRSTB : STD_LOGIC;
  signal processing_system7_0_M_AXI_GP0_ARADDR : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal processing_system7_0_M_AXI_GP0_ARBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal processing_system7_0_M_AXI_GP0_ARCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal processing_system7_0_M_AXI_GP0_ARID : STD_LOGIC_VECTOR ( 11 downto 0 );
  signal processing_system7_0_M_AXI_GP0_ARLEN : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal processing_system7_0_M_AXI_GP0_ARLOCK : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal processing_system7_0_M_AXI_GP0_ARPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal processing_system7_0_M_AXI_GP0_ARQOS : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal processing_system7_0_M_AXI_GP0_ARREADY : STD_LOGIC;
  signal processing_system7_0_M_AXI_GP0_ARSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal processing_system7_0_M_AXI_GP0_ARVALID : STD_LOGIC;
  signal processing_system7_0_M_AXI_GP0_AWADDR : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal processing_system7_0_M_AXI_GP0_AWBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal processing_system7_0_M_AXI_GP0_AWCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal processing_system7_0_M_AXI_GP0_AWID : STD_LOGIC_VECTOR ( 11 downto 0 );
  signal processing_system7_0_M_AXI_GP0_AWLEN : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal processing_system7_0_M_AXI_GP0_AWLOCK : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal processing_system7_0_M_AXI_GP0_AWPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal processing_system7_0_M_AXI_GP0_AWQOS : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal processing_system7_0_M_AXI_GP0_AWREADY : STD_LOGIC;
  signal processing_system7_0_M_AXI_GP0_AWSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal processing_system7_0_M_AXI_GP0_AWVALID : STD_LOGIC;
  signal processing_system7_0_M_AXI_GP0_BID : STD_LOGIC_VECTOR ( 11 downto 0 );
  signal processing_system7_0_M_AXI_GP0_BREADY : STD_LOGIC;
  signal processing_system7_0_M_AXI_GP0_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal processing_system7_0_M_AXI_GP0_BVALID : STD_LOGIC;
  signal processing_system7_0_M_AXI_GP0_RDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal processing_system7_0_M_AXI_GP0_RID : STD_LOGIC_VECTOR ( 11 downto 0 );
  signal processing_system7_0_M_AXI_GP0_RLAST : STD_LOGIC;
  signal processing_system7_0_M_AXI_GP0_RREADY : STD_LOGIC;
  signal processing_system7_0_M_AXI_GP0_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal processing_system7_0_M_AXI_GP0_RVALID : STD_LOGIC;
  signal processing_system7_0_M_AXI_GP0_WDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal processing_system7_0_M_AXI_GP0_WID : STD_LOGIC_VECTOR ( 11 downto 0 );
  signal processing_system7_0_M_AXI_GP0_WLAST : STD_LOGIC;
  signal processing_system7_0_M_AXI_GP0_WREADY : STD_LOGIC;
  signal processing_system7_0_M_AXI_GP0_WSTRB : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal processing_system7_0_M_AXI_GP0_WVALID : STD_LOGIC;
  signal rst_processing_system7_0_100M_interconnect_aresetn : STD_LOGIC_VECTOR ( 0 to 0 );
  signal rst_processing_system7_0_100M_peripheral_aresetn : STD_LOGIC_VECTOR ( 0 to 0 );
  signal NLW_processing_system7_0_TTC0_WAVE0_OUT_UNCONNECTED : STD_LOGIC;
  signal NLW_processing_system7_0_TTC0_WAVE1_OUT_UNCONNECTED : STD_LOGIC;
  signal NLW_processing_system7_0_TTC0_WAVE2_OUT_UNCONNECTED : STD_LOGIC;
  signal NLW_processing_system7_0_USB0_VBUS_PWRSELECT_UNCONNECTED : STD_LOGIC;
  signal NLW_processing_system7_0_USB0_PORT_INDCTL_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_processing_system7_0_axi_periph_M00_AXI_arvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_processing_system7_0_axi_periph_M00_AXI_awvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_processing_system7_0_axi_periph_M00_AXI_bready_UNCONNECTED : STD_LOGIC;
  signal NLW_processing_system7_0_axi_periph_M00_AXI_rready_UNCONNECTED : STD_LOGIC;
  signal NLW_processing_system7_0_axi_periph_M00_AXI_wvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_processing_system7_0_axi_periph_M00_AXI_araddr_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_processing_system7_0_axi_periph_M00_AXI_awaddr_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_processing_system7_0_axi_periph_M00_AXI_wdata_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_processing_system7_0_axi_periph_M00_AXI_wstrb_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_rst_processing_system7_0_100M_mb_reset_UNCONNECTED : STD_LOGIC;
  signal NLW_rst_processing_system7_0_100M_bus_struct_reset_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
  signal NLW_rst_processing_system7_0_100M_peripheral_reset_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
begin
can_merge_0: component top_can_merge_0_1
     port map (
      can_rx => can_merge_0_can_rx,
      can_tx1 => processing_system7_0_CAN0_PHY_TX,
      can_tx2 => processing_system7_0_CAN1_PHY_TX,
      can_tx3 => '1'
    );
processing_system7_0: component top_processing_system7_0_1
     port map (
      CAN0_PHY_RX => can_merge_0_can_rx,
      CAN0_PHY_TX => processing_system7_0_CAN0_PHY_TX,
      CAN1_PHY_RX => can_merge_0_can_rx,
      CAN1_PHY_TX => processing_system7_0_CAN1_PHY_TX,
      DDR_Addr(14 downto 0) => DDR_addr(14 downto 0),
      DDR_BankAddr(2 downto 0) => DDR_ba(2 downto 0),
      DDR_CAS_n => DDR_cas_n,
      DDR_CKE => DDR_cke,
      DDR_CS_n => DDR_cs_n,
      DDR_Clk => DDR_ck_p,
      DDR_Clk_n => DDR_ck_n,
      DDR_DM(3 downto 0) => DDR_dm(3 downto 0),
      DDR_DQ(31 downto 0) => DDR_dq(31 downto 0),
      DDR_DQS(3 downto 0) => DDR_dqs_p(3 downto 0),
      DDR_DQS_n(3 downto 0) => DDR_dqs_n(3 downto 0),
      DDR_DRSTB => DDR_reset_n,
      DDR_ODT => DDR_odt,
      DDR_RAS_n => DDR_ras_n,
      DDR_VRN => FIXED_IO_ddr_vrn,
      DDR_VRP => FIXED_IO_ddr_vrp,
      DDR_WEB => DDR_we_n,
      FCLK_CLK0 => processing_system7_0_FCLK_CLK0,
      FCLK_RESET0_N => processing_system7_0_FCLK_RESET0_N,
      MIO(53 downto 0) => FIXED_IO_mio(53 downto 0),
      M_AXI_GP0_ACLK => processing_system7_0_FCLK_CLK0,
      M_AXI_GP0_ARADDR(31 downto 0) => processing_system7_0_M_AXI_GP0_ARADDR(31 downto 0),
      M_AXI_GP0_ARBURST(1 downto 0) => processing_system7_0_M_AXI_GP0_ARBURST(1 downto 0),
      M_AXI_GP0_ARCACHE(3 downto 0) => processing_system7_0_M_AXI_GP0_ARCACHE(3 downto 0),
      M_AXI_GP0_ARID(11 downto 0) => processing_system7_0_M_AXI_GP0_ARID(11 downto 0),
      M_AXI_GP0_ARLEN(3 downto 0) => processing_system7_0_M_AXI_GP0_ARLEN(3 downto 0),
      M_AXI_GP0_ARLOCK(1 downto 0) => processing_system7_0_M_AXI_GP0_ARLOCK(1 downto 0),
      M_AXI_GP0_ARPROT(2 downto 0) => processing_system7_0_M_AXI_GP0_ARPROT(2 downto 0),
      M_AXI_GP0_ARQOS(3 downto 0) => processing_system7_0_M_AXI_GP0_ARQOS(3 downto 0),
      M_AXI_GP0_ARREADY => processing_system7_0_M_AXI_GP0_ARREADY,
      M_AXI_GP0_ARSIZE(2 downto 0) => processing_system7_0_M_AXI_GP0_ARSIZE(2 downto 0),
      M_AXI_GP0_ARVALID => processing_system7_0_M_AXI_GP0_ARVALID,
      M_AXI_GP0_AWADDR(31 downto 0) => processing_system7_0_M_AXI_GP0_AWADDR(31 downto 0),
      M_AXI_GP0_AWBURST(1 downto 0) => processing_system7_0_M_AXI_GP0_AWBURST(1 downto 0),
      M_AXI_GP0_AWCACHE(3 downto 0) => processing_system7_0_M_AXI_GP0_AWCACHE(3 downto 0),
      M_AXI_GP0_AWID(11 downto 0) => processing_system7_0_M_AXI_GP0_AWID(11 downto 0),
      M_AXI_GP0_AWLEN(3 downto 0) => processing_system7_0_M_AXI_GP0_AWLEN(3 downto 0),
      M_AXI_GP0_AWLOCK(1 downto 0) => processing_system7_0_M_AXI_GP0_AWLOCK(1 downto 0),
      M_AXI_GP0_AWPROT(2 downto 0) => processing_system7_0_M_AXI_GP0_AWPROT(2 downto 0),
      M_AXI_GP0_AWQOS(3 downto 0) => processing_system7_0_M_AXI_GP0_AWQOS(3 downto 0),
      M_AXI_GP0_AWREADY => processing_system7_0_M_AXI_GP0_AWREADY,
      M_AXI_GP0_AWSIZE(2 downto 0) => processing_system7_0_M_AXI_GP0_AWSIZE(2 downto 0),
      M_AXI_GP0_AWVALID => processing_system7_0_M_AXI_GP0_AWVALID,
      M_AXI_GP0_BID(11 downto 0) => processing_system7_0_M_AXI_GP0_BID(11 downto 0),
      M_AXI_GP0_BREADY => processing_system7_0_M_AXI_GP0_BREADY,
      M_AXI_GP0_BRESP(1 downto 0) => processing_system7_0_M_AXI_GP0_BRESP(1 downto 0),
      M_AXI_GP0_BVALID => processing_system7_0_M_AXI_GP0_BVALID,
      M_AXI_GP0_RDATA(31 downto 0) => processing_system7_0_M_AXI_GP0_RDATA(31 downto 0),
      M_AXI_GP0_RID(11 downto 0) => processing_system7_0_M_AXI_GP0_RID(11 downto 0),
      M_AXI_GP0_RLAST => processing_system7_0_M_AXI_GP0_RLAST,
      M_AXI_GP0_RREADY => processing_system7_0_M_AXI_GP0_RREADY,
      M_AXI_GP0_RRESP(1 downto 0) => processing_system7_0_M_AXI_GP0_RRESP(1 downto 0),
      M_AXI_GP0_RVALID => processing_system7_0_M_AXI_GP0_RVALID,
      M_AXI_GP0_WDATA(31 downto 0) => processing_system7_0_M_AXI_GP0_WDATA(31 downto 0),
      M_AXI_GP0_WID(11 downto 0) => processing_system7_0_M_AXI_GP0_WID(11 downto 0),
      M_AXI_GP0_WLAST => processing_system7_0_M_AXI_GP0_WLAST,
      M_AXI_GP0_WREADY => processing_system7_0_M_AXI_GP0_WREADY,
      M_AXI_GP0_WSTRB(3 downto 0) => processing_system7_0_M_AXI_GP0_WSTRB(3 downto 0),
      M_AXI_GP0_WVALID => processing_system7_0_M_AXI_GP0_WVALID,
      PS_CLK => FIXED_IO_ps_clk,
      PS_PORB => FIXED_IO_ps_porb,
      PS_SRSTB => FIXED_IO_ps_srstb,
      TTC0_WAVE0_OUT => NLW_processing_system7_0_TTC0_WAVE0_OUT_UNCONNECTED,
      TTC0_WAVE1_OUT => NLW_processing_system7_0_TTC0_WAVE1_OUT_UNCONNECTED,
      TTC0_WAVE2_OUT => NLW_processing_system7_0_TTC0_WAVE2_OUT_UNCONNECTED,
      USB0_PORT_INDCTL(1 downto 0) => NLW_processing_system7_0_USB0_PORT_INDCTL_UNCONNECTED(1 downto 0),
      USB0_VBUS_PWRFAULT => '0',
      USB0_VBUS_PWRSELECT => NLW_processing_system7_0_USB0_VBUS_PWRSELECT_UNCONNECTED
    );
processing_system7_0_axi_periph: entity work.top_processing_system7_0_axi_periph_0
     port map (
      ACLK => processing_system7_0_FCLK_CLK0,
      ARESETN(0) => rst_processing_system7_0_100M_interconnect_aresetn(0),
      M00_ACLK => processing_system7_0_FCLK_CLK0,
      M00_ARESETN(0) => rst_processing_system7_0_100M_peripheral_aresetn(0),
      M00_AXI_araddr(31 downto 0) => NLW_processing_system7_0_axi_periph_M00_AXI_araddr_UNCONNECTED(31 downto 0),
      M00_AXI_arready => '0',
      M00_AXI_arvalid => NLW_processing_system7_0_axi_periph_M00_AXI_arvalid_UNCONNECTED,
      M00_AXI_awaddr(31 downto 0) => NLW_processing_system7_0_axi_periph_M00_AXI_awaddr_UNCONNECTED(31 downto 0),
      M00_AXI_awready => '0',
      M00_AXI_awvalid => NLW_processing_system7_0_axi_periph_M00_AXI_awvalid_UNCONNECTED,
      M00_AXI_bready => NLW_processing_system7_0_axi_periph_M00_AXI_bready_UNCONNECTED,
      M00_AXI_bresp(1 downto 0) => B"00",
      M00_AXI_bvalid => '0',
      M00_AXI_rdata(31 downto 0) => B"00000000000000000000000000000000",
      M00_AXI_rready => NLW_processing_system7_0_axi_periph_M00_AXI_rready_UNCONNECTED,
      M00_AXI_rresp(1 downto 0) => B"00",
      M00_AXI_rvalid => '0',
      M00_AXI_wdata(31 downto 0) => NLW_processing_system7_0_axi_periph_M00_AXI_wdata_UNCONNECTED(31 downto 0),
      M00_AXI_wready => '0',
      M00_AXI_wstrb(3 downto 0) => NLW_processing_system7_0_axi_periph_M00_AXI_wstrb_UNCONNECTED(3 downto 0),
      M00_AXI_wvalid => NLW_processing_system7_0_axi_periph_M00_AXI_wvalid_UNCONNECTED,
      S00_ACLK => processing_system7_0_FCLK_CLK0,
      S00_ARESETN(0) => rst_processing_system7_0_100M_peripheral_aresetn(0),
      S00_AXI_araddr(31 downto 0) => processing_system7_0_M_AXI_GP0_ARADDR(31 downto 0),
      S00_AXI_arburst(1 downto 0) => processing_system7_0_M_AXI_GP0_ARBURST(1 downto 0),
      S00_AXI_arcache(3 downto 0) => processing_system7_0_M_AXI_GP0_ARCACHE(3 downto 0),
      S00_AXI_arid(11 downto 0) => processing_system7_0_M_AXI_GP0_ARID(11 downto 0),
      S00_AXI_arlen(3 downto 0) => processing_system7_0_M_AXI_GP0_ARLEN(3 downto 0),
      S00_AXI_arlock(1 downto 0) => processing_system7_0_M_AXI_GP0_ARLOCK(1 downto 0),
      S00_AXI_arprot(2 downto 0) => processing_system7_0_M_AXI_GP0_ARPROT(2 downto 0),
      S00_AXI_arqos(3 downto 0) => processing_system7_0_M_AXI_GP0_ARQOS(3 downto 0),
      S00_AXI_arready => processing_system7_0_M_AXI_GP0_ARREADY,
      S00_AXI_arsize(2 downto 0) => processing_system7_0_M_AXI_GP0_ARSIZE(2 downto 0),
      S00_AXI_arvalid => processing_system7_0_M_AXI_GP0_ARVALID,
      S00_AXI_awaddr(31 downto 0) => processing_system7_0_M_AXI_GP0_AWADDR(31 downto 0),
      S00_AXI_awburst(1 downto 0) => processing_system7_0_M_AXI_GP0_AWBURST(1 downto 0),
      S00_AXI_awcache(3 downto 0) => processing_system7_0_M_AXI_GP0_AWCACHE(3 downto 0),
      S00_AXI_awid(11 downto 0) => processing_system7_0_M_AXI_GP0_AWID(11 downto 0),
      S00_AXI_awlen(3 downto 0) => processing_system7_0_M_AXI_GP0_AWLEN(3 downto 0),
      S00_AXI_awlock(1 downto 0) => processing_system7_0_M_AXI_GP0_AWLOCK(1 downto 0),
      S00_AXI_awprot(2 downto 0) => processing_system7_0_M_AXI_GP0_AWPROT(2 downto 0),
      S00_AXI_awqos(3 downto 0) => processing_system7_0_M_AXI_GP0_AWQOS(3 downto 0),
      S00_AXI_awready => processing_system7_0_M_AXI_GP0_AWREADY,
      S00_AXI_awsize(2 downto 0) => processing_system7_0_M_AXI_GP0_AWSIZE(2 downto 0),
      S00_AXI_awvalid => processing_system7_0_M_AXI_GP0_AWVALID,
      S00_AXI_bid(11 downto 0) => processing_system7_0_M_AXI_GP0_BID(11 downto 0),
      S00_AXI_bready => processing_system7_0_M_AXI_GP0_BREADY,
      S00_AXI_bresp(1 downto 0) => processing_system7_0_M_AXI_GP0_BRESP(1 downto 0),
      S00_AXI_bvalid => processing_system7_0_M_AXI_GP0_BVALID,
      S00_AXI_rdata(31 downto 0) => processing_system7_0_M_AXI_GP0_RDATA(31 downto 0),
      S00_AXI_rid(11 downto 0) => processing_system7_0_M_AXI_GP0_RID(11 downto 0),
      S00_AXI_rlast => processing_system7_0_M_AXI_GP0_RLAST,
      S00_AXI_rready => processing_system7_0_M_AXI_GP0_RREADY,
      S00_AXI_rresp(1 downto 0) => processing_system7_0_M_AXI_GP0_RRESP(1 downto 0),
      S00_AXI_rvalid => processing_system7_0_M_AXI_GP0_RVALID,
      S00_AXI_wdata(31 downto 0) => processing_system7_0_M_AXI_GP0_WDATA(31 downto 0),
      S00_AXI_wid(11 downto 0) => processing_system7_0_M_AXI_GP0_WID(11 downto 0),
      S00_AXI_wlast => processing_system7_0_M_AXI_GP0_WLAST,
      S00_AXI_wready => processing_system7_0_M_AXI_GP0_WREADY,
      S00_AXI_wstrb(3 downto 0) => processing_system7_0_M_AXI_GP0_WSTRB(3 downto 0),
      S00_AXI_wvalid => processing_system7_0_M_AXI_GP0_WVALID
    );
rst_processing_system7_0_100M: component top_rst_processing_system7_0_100M_0
     port map (
      aux_reset_in => '1',
      bus_struct_reset(0) => NLW_rst_processing_system7_0_100M_bus_struct_reset_UNCONNECTED(0),
      dcm_locked => '1',
      ext_reset_in => processing_system7_0_FCLK_RESET0_N,
      interconnect_aresetn(0) => rst_processing_system7_0_100M_interconnect_aresetn(0),
      mb_debug_sys_rst => '0',
      mb_reset => NLW_rst_processing_system7_0_100M_mb_reset_UNCONNECTED,
      peripheral_aresetn(0) => rst_processing_system7_0_100M_peripheral_aresetn(0),
      peripheral_reset(0) => NLW_rst_processing_system7_0_100M_peripheral_reset_UNCONNECTED(0),
      slowest_sync_clk => processing_system7_0_FCLK_CLK0
    );
end STRUCTURE;
