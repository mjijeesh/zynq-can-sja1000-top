#
#  MicroZed CAN-BENCH Carrier Card RevA I/O Pin Assignment
#
#     Net names are not allowed to contain hyphen characters '-' since this
#     is not a legal VHDL87 or Verilog character within an identifier.  
#     HDL net names are adjusted to contain no hyphen characters '-' but 
#     rather use underscore '_' characters.  Comment net name with the hyphen 
#     characters will remain in place since these are intended to match the 
#     schematic net names in order to better enable schematic search.
#
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
#    User LEDs (Bank 35)
# ------------------------------------------------------------------------------
set_property PACKAGE_PIN J20 [get_ports {LED[0]}]; # JX2_LVDS_17_P
set_property PACKAGE_PIN H20 [get_ports {LED[1]}]; # JX2_LVDS_17_N
set_property PACKAGE_PIN H15 [get_ports {LED[2]}]; # JX2_LVDS_19_P
set_property PACKAGE_PIN G15 [get_ports {LED[3]}]; # JX2_LVDS_19_N
set_property PACKAGE_PIN L14 [get_ports {LED[4]}]; # JX2_LVDS_21_P
set_property PACKAGE_PIN L15 [get_ports {LED[5]}]; # JX2_LVDS_21_N
set_property PACKAGE_PIN K16 [get_ports {LED[6]}]; # JX2_LVDS_23_P
set_property PACKAGE_PIN J16 [get_ports {LED[7]}]; # JX2_LVDS_23_N

set_property DIRECTION OUT [get_ports [list {LED[0]} {LED[1]} {LED[2]} {LED[3]} {LED[4]} {LED[5]} {LED[6]} {LED[7]}]];

# ------------------------------------------------------------------------------
#    User KEYs (Bank 35)
# ------------------------------------------------------------------------------
set_property PACKAGE_PIN G17 [get_ports {KEY[0]}]; # JX2_LVDS_14_P
set_property PACKAGE_PIN G20 [get_ports {KEY[1]}]; # JX2_LVDS_16_N
set_property PACKAGE_PIN J14 [get_ports {KEY[2]}]; # JX2_LVDS_18_N
set_property PACKAGE_PIN M14 [get_ports {KEY[3]}]; # JX2_LVDS_22_P

set_property DIRECTION IN [get_ports [list {KEY[0]} {KEY[1]} {KEY[2]} {KEY[3]}]];

# ------------------------------------------------------------------------------
#    User DIP SWs (Bank 35)
# ------------------------------------------------------------------------------
set_property PACKAGE_PIN H16 [get_ports {SW[0]}];  # JX2_LVDS_12_P
set_property PACKAGE_PIN H17 [get_ports {SW[1]}];  # JX2_LVDS_12_N
set_property PACKAGE_PIN G18 [get_ports {SW[2]}];  # JX2_LVDS_14_N
set_property PACKAGE_PIN G19 [get_ports {SW[3]}];  # JX2_LVDS_16_P
set_property PACKAGE_PIN K14 [get_ports {SW[4]}];  # JX2_LVDS_18_P
set_property PACKAGE_PIN N15 [get_ports {SW[5]}];  # JX2_LVDS_20_P
set_property PACKAGE_PIN N16 [get_ports {SW[6]}];  # JX2_LVDS_20_N
set_property PACKAGE_PIN M15 [get_ports {SW[7]}];  # JX2_LVDS_22_N

set_property DIRECTION IN [get_ports [list {SW[0]} {SW[1]} {SW[2]} {SW[3]} {SW[4]} {SW[5]} {SW[6]} {SW[7]}]];

# ------------------------------------------------------------------------------
#    CAN interfaces (Bank 35)
# ------------------------------------------------------------------------------
set_property PACKAGE_PIN B19 [get_ports {CAN1_RXD}]; # JX2_LVDS_1_P
set_property PACKAGE_PIN A20 [get_ports {CAN1_TXD}]; # JX2_LVDS_1_N
set_property PACKAGE_PIN D19 [get_ports {CAN2_RXD}]; # JX2_LVDS_3_P
set_property PACKAGE_PIN D20 [get_ports {CAN2_TXD}]; # JX2_LVDS_3_N
set_property PACKAGE_PIN F16 [get_ports {CAN3_RXD}]; # JX2_LVDS_5_P
set_property PACKAGE_PIN F17 [get_ports {CAN3_TXD}]; # JX2_LVDS_5_N
set_property PACKAGE_PIN M19 [get_ports {CAN4_RXD}]; # JX2_LVDS_7_P
set_property PACKAGE_PIN M20 [get_ports {CAN4_TXD}]; # JX2_LVDS_7_N

set_property PACKAGE_PIN J15 [get_ports {CAN_STBY}]; # JX2_SE_1

set_property DIRECTION IN [get_ports [list CAN1_RXD CAN2_RXD CAN3_RXD CAN4_RXD ]];
set_property DIRECTION OUT [get_ports [list CAN1_TXD CAN2_TXD CAN3_TXD CAN4_TXD CAN_STBY ]];

# ------------------------------------------------------------------------------
#    Screw terminal JX (Bank 34)
# ------------------------------------------------------------------------------
set_property PACKAGE_PIN N17 [get_ports {JX2}]; # JX1_LVDS_22_P
set_property PACKAGE_PIN P18 [get_ports {JX1}]; # JX1_LVDS_22_N
set_property PACKAGE_PIN P15 [get_ports {JX4}]; # JX1_LVDS_23_P
set_property PACKAGE_PIN P16 [get_ports {JX3}]; # JX1_LVDS_23_N

# ------------------------------------------------------------------------------
#    PMOD JA (Bank 34)
# ------------------------------------------------------------------------------
set_property PACKAGE_PIN V15 [get_ports {JA7_8_P}];  # JX1_LVDS_9_P
set_property PACKAGE_PIN W15 [get_ports {JA7_8_N}];  # JX1_LVDS_9_N
set_property PACKAGE_PIN U18 [get_ports {JA1_2_P}];  # JX1_LVDS_11_P
set_property PACKAGE_PIN U19 [get_ports {JA1_2_N}];  # JX1_LVDS_11_N
set_property PACKAGE_PIN N20 [get_ports {JA3_4_P}];  # JX1_LVDS_13_P
set_property PACKAGE_PIN P20 [get_ports {JA3_4_N}];  # JX1_LVDS_13_N
set_property PACKAGE_PIN V20 [get_ports {JA9_10_P}]; # JX1_LVDS_15_P
set_property PACKAGE_PIN W20 [get_ports {JA9_10_N}]; # JX1_LVDS_15_N

# ------------------------------------------------------------------------------
#    PMOD JB (Bank 34)
# ------------------------------------------------------------------------------
set_property PACKAGE_PIN T12 [get_ports {JB7_8_P}];  # JX1_LVDS_1_P
set_property PACKAGE_PIN U12 [get_ports {JB7_8_N}];  # JX1_LVDS_1_N
set_property PACKAGE_PIN V12 [get_ports {JB1_2_P}];  # JX1_LVDS_3_P
set_property PACKAGE_PIN W13 [get_ports {JB1_2_N}];  # JX1_LVDS_3_N
set_property PACKAGE_PIN P14 [get_ports {JB3_4_P}];  # JX1_LVDS_5_P
set_property PACKAGE_PIN R14 [get_ports {JB3_4_N}];  # JX1_LVDS_5_N
set_property PACKAGE_PIN W14 [get_ports {JB9_10_P}]; # JX1_LVDS_7_P
set_property PACKAGE_PIN Y14 [get_ports {JB9_10_N}]; # JX1_LVDS_7_N

# ------------------------------------------------------------------------------
#    Raspberry Pi GPIO Header (Bank 34)
# ------------------------------------------------------------------------------
set_property PACKAGE_PIN T11 [get_ports {JP_GPIO21}];      # JX1_LVDS_0_P
set_property PACKAGE_PIN T10 [get_ports {JP_GPIO26}];      # JX1_LVDS_0_N
set_property PACKAGE_PIN U13 [get_ports {JP_GPIO20}];      # JX1_LVDS_2_P
set_property PACKAGE_PIN V13 [get_ports {JP_GPIO19}];      # JX1_LVDS_2_N
set_property PACKAGE_PIN T14 [get_ports {JP_GPIO16}];      # JX1_LVDS_4_P
set_property PACKAGE_PIN T15 [get_ports {JP_GPIO13}];      # JX1_LVDS_4_N
set_property PACKAGE_PIN Y16 [get_ports {JP_GPIO6}];       # JX1_LVDS_6_P
set_property PACKAGE_PIN Y17 [get_ports {JP_GPIO12}];      # JX1_LVDS_6_N
set_property PACKAGE_PIN T16 [get_ports {JP_GPIO5}];       # JX1_LVDS_8_P
set_property PACKAGE_PIN U17 [get_ports {JP_ID_SD}];       # JX1_LVDS_8_N
set_property PACKAGE_PIN U14 [get_ports {JP_ID_SC}];       # JX1_LVDS_10_P
set_property PACKAGE_PIN U15 [get_ports {JP_GPIO7_CE1}];   # JX1_LVDS_10_N
set_property PACKAGE_PIN N18 [get_ports {JP_GPIO11_SCLK}]; # JX1_LVDS_12_P
set_property PACKAGE_PIN P19 [get_ports {JP_GPIO8_CE0}];   # JX1_LVDS_12_N
set_property PACKAGE_PIN T20 [get_ports {JP_GPIO9_MISO}];  # JX1_LVDS_14_P
set_property PACKAGE_PIN U20 [get_ports {JP_GPIO25}];      # JX1_LVDS_14_N
set_property PACKAGE_PIN Y18 [get_ports {JP_GPIO22}];      # JX1_LVDS_16_P
set_property PACKAGE_PIN Y19 [get_ports {JP_GPIO23}];      # JX1_LVDS_16_N
set_property PACKAGE_PIN R16 [get_ports {JP_GPIO18_PWM}];  # JX1_LVDS_18_P
set_property PACKAGE_PIN R17 [get_ports {JP_GPIO15_RXD}];  # JX1_LVDS_18_N
set_property PACKAGE_PIN V17 [get_ports {JP_GPIO3_SCL}];   # JX1_LVDS_20_P
set_property PACKAGE_PIN V18 [get_ports {JP_GPIO2_SDA}];   # JX1_LVDS_20_N
set_property PACKAGE_PIN V16 [get_ports {JP_GPIO10_MOSI}]; # JX1_LVDS_17_P
set_property PACKAGE_PIN W16 [get_ports {JP_GPIO24}];      # JX1_LVDS_17_N
set_property PACKAGE_PIN T17 [get_ports {JP_GPIO27}];      # JX1_LVDS_19_P
set_property PACKAGE_PIN R18 [get_ports {JP_GPIO17}];      # JX1_LVDS_19_N
set_property PACKAGE_PIN W18 [get_ports {JP_GPIO4}];       # JX1_LVDS_21_P
set_property PACKAGE_PIN W19 [get_ports {JP_GPIO14_TXD}];  # JX1_LVDS_21_N

# ------------------------------------------------------------------------------
#    Unused ports
# ------------------------------------------------------------------------------
#set_property PACKAGE_PIN T19 [get_ports {JX1_SE_1}];
#set_property PACKAGE_PIN R19 [get_ports {JX1_SE_0}];

#set_property PACKAGE_PIN C20 [get_ports {JX2_LVDS_0_P}];
#set_property PACKAGE_PIN B20 [get_ports {JX2_LVDS_0_N}];
#set_property PACKAGE_PIN E17 [get_ports {JX2_LVDS_2_P}];
#set_property PACKAGE_PIN D18 [get_ports {JX2_LVDS_2_N}];
#set_property PACKAGE_PIN E18 [get_ports {JX2_LVDS_4_P}];
#set_property PACKAGE_PIN E19 [get_ports {JX2_LVDS_4_N}];
#set_property PACKAGE_PIN L19 [get_ports {JX2_LVDS_6_P}];
#set_property PACKAGE_PIN L20 [get_ports {JX2_LVDS_6_N}];
#set_property PACKAGE_PIN M17 [get_ports {JX2_LVDS_8_P}];
#set_property PACKAGE_PIN M18 [get_ports {JX2_LVDS_8_N}];
#set_property PACKAGE_PIN L16 [get_ports {JX2_LVDS_10_P}];
#set_property PACKAGE_PIN L17 [get_ports {JX2_LVDS_10_N}];
#set_property PACKAGE_PIN K19 [get_ports {JX2_LVDS_9_P}];
#set_property PACKAGE_PIN J19 [get_ports {JX2_LVDS_9_N}];
#set_property PACKAGE_PIN K17 [get_ports {JX2_LVDS_11_P}];
#set_property PACKAGE_PIN K18 [get_ports {JX2_LVDS_11_N}];
#set_property PACKAGE_PIN J18 [get_ports {JX2_LVDS_13_P}];
#set_property PACKAGE_PIN H18 [get_ports {JX2_LVDS_13_N}];
#set_property PACKAGE_PIN F19 [get_ports {JX2_LVDS_15_P}];
#set_property PACKAGE_PIN F20 [get_ports {JX2_LVDS_15_N}];
#set_property PACKAGE_PIN G14 [get_ports {JX2_SE_0}];


# Set the bank voltage for IO Bank 34 to 3.3V by default.
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 34]];

# Set the bank voltage for IO Bank 35 to 3.3V by default.
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 35]];
