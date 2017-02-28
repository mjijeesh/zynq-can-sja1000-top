#
#  MicroZed APO Carrier Card RevA I/O Pin Assignment
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
#    SPI connected LEDs and incremental encoders (Bank 34)
# ------------------------------------------------------------------------------

# Data are changed and falling edge and captured at rising one
# LEDCS is active low
# RESET high level disables all LED ouputs and sends reset signal
# to the cameras as well

set_property PACKAGE_PIN T19 [get_ports {RESET}]; # JX1_SE_1 (34)
set_property PACKAGE_PIN U18 [get_ports {LEDCLK}]; # JX1_LVDS_11_P (34)
set_property PACKAGE_PIN U19 [get_ports {LEDCS}]; # JX1_LVDS_11_N (34)
set_property PACKAGE_PIN W14 [get_ports {LEDDATA}]; # JX1_LVDS_7_P (34)
set_property PACKAGE_PIN Y14 [get_ports {ENCDATA}]; # JX1_LVDS_7_N (34)

set_property DIRECTION OUT [get_ports [list {RESET} {LEDCLK} {LEDCS} {LEDDATA}]];
set_property DIRECTION IN [get_ports [list {ENCDATA}]];

# ------------------------------------------------------------------------------
#    CAN transceivers connection
# ------------------------------------------------------------------------------

set_property PACKAGE_PIN R14 [get_ports {CAN1_RXD}]; # JX1_LVDS_5_N (34)
set_property PACKAGE_PIN P14 [get_ports {CAN1_TXD}]; # JX1_LVDS_5_P (34)
set_property PACKAGE_PIN W15 [get_ports {CAN2_RXD}]; # JX1_LVDS_9_N (34)
set_property PACKAGE_PIN V15 [get_ports {CAN2_TXD}]; # JX1_LVDS_9_P (34)

set_property DIRECTION OUT [get_ports [list {CAN1_TXD} {CAN2_TXD}]];
set_property DIRECTION IN [get_ports [list {CAN1_RXD} {CAN2_RXD}]];

# ------------------------------------------------------------------------------
#    Servo and direct LEDs and PS2 combined outputs
# ------------------------------------------------------------------------------

set_property PACKAGE_PIN T12 [get_ports {SERVO1}]; # JX1_LVDS_1_P (34)
set_property PACKAGE_PIN U12 [get_ports {SERVO2}]; # JX1_LVDS_1_N (34)
set_property PACKAGE_PIN V12 [get_ports {SERVO3}]; # PS2CLK JX1_LVDS_1_P (34)
set_property PACKAGE_PIN W13 [get_ports {SERVO4}]; # PS2DATA JX1_LVDS_1_N (34)

set_property DIRECTION OUT [get_ports [list {SERVO1} {SERVO2} {SERVO3}]];
set_property DIRECTION INOUT [get_ports [list {SERVO4}]];

# ------------------------------------------------------------------------------
#    Speaker output
# ------------------------------------------------------------------------------

set_property PACKAGE_PIN R19 [get_ports {SPEAKER}]; # JX1_SE_0 (34)

set_property DIRECTION OUT [get_ports [list {SPEAKER}]];

# ------------------------------------------------------------------------------
#    FPGA IO connector and PMOD1 and 2
# ------------------------------------------------------------------------------

set_property PACKAGE_PIN N18 [get_ports {FPGA_IO_A[1]}]; # JX1_LVDS_12_P (34)
set_property PACKAGE_PIN P19 [get_ports {FPGA_IO_A[2]}]; # JX1_LVDS_12_N (34)
set_property PACKAGE_PIN T11 [get_ports {FPGA_IO_A[3]}]; # JX1_LVDS_0_P (34)
set_property PACKAGE_PIN T10 [get_ports {FPGA_IO_A[4]}]; # JX1_LVDS_0_N (34)
set_property PACKAGE_PIN U13 [get_ports {FPGA_IO_A[5]}]; # JX1_LVDS_2_P (34)
set_property PACKAGE_PIN V13 [get_ports {FPGA_IO_A[6]}]; # JX1_LVDS_2_N (34)
set_property PACKAGE_PIN T14 [get_ports {FPGA_IO_A[7]}]; # JX1_LVDS_4_P (34)
set_property PACKAGE_PIN T15 [get_ports {FPGA_IO_A[8]}]; # JX1_LVDS_4_N (34)
set_property PACKAGE_PIN Y16 [get_ports {FPGA_IO_A[9]}]; # JX1_LVDS_6_P (34)
set_property PACKAGE_PIN Y17 [get_ports {FPGA_IO_A[10]}]; # JX1_LVDS_6_N (34)

set_property PACKAGE_PIN T16 [get_ports {FPGA_IO_B[13]}]; # JX1_LVDS_8_P (34)
set_property PACKAGE_PIN U17 [get_ports {FPGA_IO_B[14]}]; # JX1_LVDS_8_N (34)
set_property PACKAGE_PIN U14 [get_ports {FPGA_IO_B[15]}]; # JX1_LVDS_10_P (34)
set_property PACKAGE_PIN U15 [get_ports {FPGA_IO_B[16]}]; # JX1_LVDS_10_N (34)
set_property PACKAGE_PIN T20 [get_ports {FPGA_IO_B[17]}]; # JX1_LVDS_14_P (34)
set_property PACKAGE_PIN U20 [get_ports {FPGA_IO_B[18]}]; # JX1_LVDS_14_N (34)
set_property PACKAGE_PIN Y18 [get_ports {FPGA_IO_B[19]}]; # JX1_LVDS_16_P (34)
set_property PACKAGE_PIN Y19 [get_ports {FPGA_IO_B[20]}]; # JX1_LVDS_16_N (34)
set_property PACKAGE_PIN R16 [get_ports {FPGA_IO_B[21]}]; # JX1_LVDS_18_P (34)
set_property PACKAGE_PIN R17 [get_ports {FPGA_IO_B[22]}]; # JX1_LVDS_18_N (34)
set_property PACKAGE_PIN V17 [get_ports {FPGA_IO_B[23]}]; # PMOD1[6] JX1_LVDS_20_P (34)
set_property PACKAGE_PIN V18 [get_ports {FPGA_IO_B[24]}]; # PMOD1[7] JX1_LVDS_20_N (34)
set_property PACKAGE_PIN N17 [get_ports {FPGA_IO_B[25]}]; # PMOD1[4] JX1_LVDS_22_P (34)
set_property PACKAGE_PIN P18 [get_ports {FPGA_IO_B[26]}]; # PMOD1[5] JX1_LVDS_22_N (34)
set_property PACKAGE_PIN P15 [get_ports {FPGA_IO_B[27]}]; # PMOD2[2] JX1_LVDS_23_P (34)
set_property PACKAGE_PIN P16 [get_ports {FPGA_IO_B[28]}]; # PMOD2[3] JX1_LVDS_23_N (34)

set_property PACKAGE_PIN W18 [get_ports {FPGA_IO_C[31]}]; # PMOD2[0] JX1_LVDS_21_P (34)
set_property PACKAGE_PIN W19 [get_ports {FPGA_IO_C[32]}]; # PMOD2[2] JX1_LVDS_21_N (34)
set_property PACKAGE_PIN T17 [get_ports {FPGA_IO_C[33]}]; # PMOD2[4] JX1_LVDS_19_P (34)
set_property PACKAGE_PIN R18 [get_ports {FPGA_IO_C[34]}]; # PMOD2[5] JX1_LVDS_19_N (34)
set_property PACKAGE_PIN V16 [get_ports {FPGA_IO_C[35]}]; # PMOD2[6] JX1_LVDS_17_P (34)
set_property PACKAGE_PIN W16 [get_ports {FPGA_IO_C[36]}]; # PMOD2[7] JX1_LVDS_17_N (34)
set_property PACKAGE_PIN V20 [get_ports {FPGA_IO_C[37]}]; # PMOD1[2] JX1_LVDS_15_P (34)
set_property PACKAGE_PIN W20 [get_ports {FPGA_IO_C[38]}]; # PMOD1[3] JX1_LVDS_15_N (34)
set_property PACKAGE_PIN N20 [get_ports {FPGA_IO_C[39]}]; # PMOD1[0] JX1_LVDS_13_P (34)
set_property PACKAGE_PIN P20 [get_ports {FPGA_IO_C[40]}]; # PMOD1[1] JX1_LVDS_13_N (34)

# ------------------------------------------------------------------------------
#    Camera 1 pins
# ------------------------------------------------------------------------------

set_property PACKAGE_PIN E19 [get_ports {CAM1_D[0]}]; # JX2_LVDS_4_N (35)
set_property PACKAGE_PIN E18 [get_ports {CAM1_D[1]}]; # JX2_LVDS_4_P (35)
set_property PACKAGE_PIN L20 [get_ports {CAM1_D[2]}]; # JX2_LVDS_6_N (35)
set_property PACKAGE_PIN L19 [get_ports {CAM1_D[3]}]; # JX2_LVDS_6_P (35)
set_property PACKAGE_PIN M18 [get_ports {CAM1_D[4]}]; # JX2_LVDS_8_N (35)
set_property PACKAGE_PIN M17 [get_ports {CAM1_D[5]}]; # JX2_LVDS_8_P (35)
set_property PACKAGE_PIN L17 [get_ports {CAM1_D[6]}]; # JX2_LVDS_10_N (35)
set_property PACKAGE_PIN L16 [get_ports {CAM1_D[7]}]; # JX2_LVDS_10_P (35)
set_property PACKAGE_PIN G18 [get_ports {CAM1_D[8]}]; # JX2_LVDS_14_N (35)
set_property PACKAGE_PIN G17 [get_ports {CAM1_D[9]}]; # JX2_LVDS_14_P (35)
set_property PACKAGE_PIN G20 [get_ports {CAM1_HSYNC}]; # JX2_LVDS_16_N (35)
set_property PACKAGE_PIN H16 [get_ports {CAM1_PCLK}]; # JX2_LVDS_12_P (35)
set_property PACKAGE_PIN K14 [get_ports {CAM1_SCL}]; # JX2_LVDS_18_P (35)
set_property PACKAGE_PIN J14 [get_ports {CAM1_SDA}]; # JX2_LVDS_18_N (35)
set_property PACKAGE_PIN G19 [get_ports {CAM1_VSYNC}]; # JX2_LVDS_16_P (35)
set_property PACKAGE_PIN H17 [get_ports {CAM1_XCLK}]; # JX2_LVDS_12_N (35)

set_property DIRECTION OUT [get_ports [list {CAM1_XCLK}]];
set_property DIRECTION IN [get_ports [list {CAM1_PCLK} {CAM1_VSYNC} {CAM1_HSYNC}]];

set_property DIRECTION IN [get_ports [list {CAM1_D[0]} {CAM1_D[1]}]];
set_property DIRECTION IN [get_ports [list {CAM1_D[2]} {CAM1_D[3]} {CAM1_D[4]} {CAM1_D[5]}]];
set_property DIRECTION IN [get_ports [list {CAM1_D[6]} {CAM1_D[7]} {CAM1_D[8]} {CAM1_D[9]}]];

# ------------------------------------------------------------------------------
#    Camera 2 pins
# ------------------------------------------------------------------------------

set_property PACKAGE_PIN N16 [get_ports {CAM2_D[2]}]; # JX2_LVDS_20_N (35)
set_property PACKAGE_PIN N15 [get_ports {CAM2_D[3]}]; # JX2_LVDS_20_P (35)
set_property PACKAGE_PIN M15 [get_ports {CAM2_D[4]}]; # JX2_LVDS_22_N (35)
set_property PACKAGE_PIN M14 [get_ports {CAM2_D[5]}]; # JX2_LVDS_22_P (35)
set_property PACKAGE_PIN K18 [get_ports {CAM2_D[6]}]; # JX2_LVDS_11_N (35)
set_property PACKAGE_PIN K17 [get_ports {CAM2_D[7]}]; # JX2_LVDS_11_P (35)
set_property PACKAGE_PIN J16 [get_ports {CAM2_D[8]}]; # JX2_LVDS_23_N (35)
set_property PACKAGE_PIN K16 [get_ports {CAM2_D[9]}]; # JX2_LVDS_23_P (35)
set_property PACKAGE_PIN L15 [get_ports {CAM2_HREF}]; # JX2_LVDS_21_N (35)
set_property PACKAGE_PIN J18 [get_ports {CAM2_PCLK}]; # JX2_LVDS_13_P (35)
set_property PACKAGE_PIN H15 [get_ports {CAM2_SCL}]; # JX2_LVDS_19_P (35)
set_property PACKAGE_PIN G15 [get_ports {CAM2_SDA}]; # JX2_LVDS_19_N (35)
set_property PACKAGE_PIN L14 [get_ports {CAM2_VSYNC}]; # JX2_LVDS_21_P (35)
set_property PACKAGE_PIN H18 [get_ports {CAM2_XCLK}]; # JX2_LVDS_13_N (35)

set_property DIRECTION OUT [get_ports [list {CAM2_XCLK}]];
set_property DIRECTION IN [get_ports [list {CAM2_PCLK} {CAM2_VSYNC} {CAM2_HSYNC}]];

set_property DIRECTION IN [get_ports [list {CAM2_D[2]} {CAM2_D[3]} {CAM2_D[4]} {CAM2_D[5]}]];
set_property DIRECTION IN [get_ports [list {CAM2_D[6]} {CAM2_D[7]} {CAM2_D[8]} {CAM2_D[9]}]];

# ------------------------------------------------------------------------------
#    LCD display pins
# ------------------------------------------------------------------------------

set_property PACKAGE_PIN E17 [get_ports {LCD_CS}]; # JX2_LVDS_2_P (35)
set_property PACKAGE_PIN C20 [get_ports {LCD_RS}]; # JX2_LVDS_0_P (35)
set_property PACKAGE_PIN D18 [get_ports {LCD_RST}]; # JX2_LVDS_2_N (35)
set_property PACKAGE_PIN B20 [get_ports {LCD_WR}]; # JX2_LVDS_0_N (35)
set_property PACKAGE_PIN G14 [get_ports {LCD_D[0]}]; # JX2_SE_0 (35)
set_property PACKAGE_PIN J15 [get_ports {LCD_D[1]}]; # JX2_SE_1 (35)
set_property PACKAGE_PIN B19 [get_ports {LCD_D[2]}]; # JX2_LVDS_1_P (35)
set_property PACKAGE_PIN A20 [get_ports {LCD_D[3]}]; # JX2_LVDS_1_N (35)
set_property PACKAGE_PIN D19 [get_ports {LCD_D[4]}]; # JX2_LVDS_3_P (35)
set_property PACKAGE_PIN D20 [get_ports {LCD_D[5]}]; # JX2_LVDS_3_N (35)
set_property PACKAGE_PIN F16 [get_ports {LCD_D[6]}]; # JX2_LVDS_5_P (35)
set_property PACKAGE_PIN F17 [get_ports {LCD_D[7]}]; # JX2_LVDS_5_N (35)
set_property PACKAGE_PIN H20 [get_ports {LCD_D[8]}]; # JX2_LVDS_17_N (35)
set_property PACKAGE_PIN J20 [get_ports {LCD_D[9]}]; # JX2_LVDS_17_P (35)
set_property PACKAGE_PIN F20 [get_ports {LCD_D[10]}]; # JX2_LVDS_15_N (35)
set_property PACKAGE_PIN F19 [get_ports {LCD_D[11]}]; # JX2_LVDS_15_P (35)
set_property PACKAGE_PIN J19 [get_ports {LCD_D[12]}]; # JX2_LVDS_9_N (35)
set_property PACKAGE_PIN K19 [get_ports {LCD_D[13]}]; # JX2_LVDS_9_P (35)
set_property PACKAGE_PIN M20 [get_ports {LCD_D[14]}]; # JX2_LVDS_7_N (35)
set_property PACKAGE_PIN M19 [get_ports {LCD_D[15]}]; # JX2_LVDS_7_P (35)

set_property DIRECTION OUT [get_ports [list {LCD_CS} {LCD_RS} {LCD_RST} {LCD_WR}]];
set_property DIRECTION INOUT [get_ports [list LCD_D[0] LCD_D[1] LCD_D[2] LCD_D[3]]];
set_property DIRECTION INOUT [get_ports [list LCD_D[4] LCD_D[5] LCD_D[6] LCD_D[7]]];
set_property DIRECTION INOUT [get_ports [list LCD_D[8] LCD_D[9] LCD_D[10] LCD_D[11]]];
set_property DIRECTION INOUT [get_ports [list LCD_D[12] LCD_D[13] LCD_D[14] LCD_D[15]]];

# ------------------------------------------------------------------------------
#    Unused ports
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
#    Configuration
# ------------------------------------------------------------------------------

# Set the bank voltage for IO Bank 34 to 3.3V by default.
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 34]];

# Set the bank voltage for IO Bank 35 to 3.3V by default.
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 35]];
