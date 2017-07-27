library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity can4x_to_pmod12_pins is
    Port ( FPGA_IO_A : inout std_logic_vector(10 downto 1);
           FPGA_IO_B : inout std_logic_vector(28 downto 13);
           FPGA_IO_C : inout std_logic_vector(40 downto 31);

           CAN1_TX   : in std_logic;
           CAN2_TX   : in std_logic;
           CAN3_TX   : in std_logic;
           CAN4_TX   : in std_logic;

           CAN1_RX    : out std_logic;
           CAN2_RX    : out std_logic;
           CAN3_RX    : out std_logic;
           CAN4_RX    : out std_logic
         );

end can4x_to_pmod12_pins;

architecture rtl of can4x_to_pmod12_pins is

begin
    FPGA_IO_C(39) <= CAN1_TX;  -- PMOD1[0] N20 X1_LVDS_13_P (34
    FPGA_IO_C(40) <= CAN2_TX;  -- PMOD1[1] P20 JX1_LVDS_13_N (34)
    CAN1_RX <= FPGA_IO_C(37);  -- PMOD1[2] V20 JX1_LVDS_15_P (34)
    CAN2_RX <= FPGA_IO_C(38);  -- PMOD1[3] W20 JX1_LVDS_15_N (34
    -- FPGA_IO_B(25)           -- PMOD1[4] N17 JX1_LVDS_22_P (34)
    -- FPGA_IO_B(26)           -- PMOD1[5] P18 JX1_LVDS_22_N (34)
    -- FPGA_IO_B(23)           -- PMOD1[6] V17 X1_LVDS_20_P (34)
    -- FPGA_IO_B(24)           -- PMOD1[7] V18 JX1_LVDS_20_N (34)

    FPGA_IO_C(31) <= CAN3_TX;  -- PMOD2[0] W18 JX1_LVDS_21_P (34)
    FPGA_IO_C(32) <= CAN4_TX;  -- PMOD2[1] W19 JX1_LVDS_21_N (34)
    CAN3_RX <= FPGA_IO_B(27);  -- PMOD2[2] P15 JX1_LVDS_23_P (34)
    CAN4_RX <= FPGA_IO_B(28);  -- PMOD2[3] P16 JX1_LVDS_23_N (34)
    -- FPGA_IO_C(33)           -- PMOD2[4] T17 JX1_LVDS_19_P (34)
    -- FPGA_IO_C(34)           -- PMOD2[5] R18 JX1_LVDS_19_N (34)
    -- FPGA_IO_C(35)           -- PMOD2[6] V16 JX1_LVDS_17_P (34)
    -- FPGA_IO_C(36)           -- PMOD2[7] W16 JX1_LVDS_17_N (34)

    FPGA_IO_A(10 downto 1) <= (others => 'Z');
    FPGA_IO_B(26 downto 13) <= (others => 'Z');
    FPGA_IO_C(36 downto 33) <= (others => 'Z');
end rtl;
