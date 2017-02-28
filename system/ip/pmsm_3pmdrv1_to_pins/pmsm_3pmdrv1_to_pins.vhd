library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pmsm_3pmdrv1_to_pins is
    Port ( FPGA_IO_A : inout std_logic_vector(10 downto 1);
           FPGA_IO_B : inout std_logic_vector(28 downto 13);
           FPGA_IO_C : inout std_logic_vector(40 downto 31);

           PWM_OUT : in std_logic_vector(1 to 3);
           PWM_SHDN : in std_logic_vector(1 to 3);
           PWM_STAT : out std_logic_vector(1 to 3);

           HAL_SENS : out std_logic_vector(1 to 3);

           ADC_SCLK: in std_logic;
           ADC_SCS: in std_logic;
           ADC_MOSI: in std_logic;
           ADC_MISO: out std_logic;

           PWR_STAT: out std_logic;

           IRC_CHA: out std_logic;
           IRC_CHB: out std_logic;
           IRC_IDX: out std_logic
         );
end pmsm_3pmdrv1_to_pins;

architecture rtl of pmsm_3pmdrv1_to_pins is

begin
    FPGA_IO_A(1) <= PWM_SHDN(1);
    FPGA_IO_A(3) <= PWM_OUT(1);
    FPGA_IO_A(5) <= PWM_SHDN(2);
    FPGA_IO_A(7) <= PWM_OUT(2);
    FPGA_IO_A(9) <= PWM_SHDN(3);
    FPGA_IO_B(13) <= PWM_OUT(3);

    PWM_STAT(1) <= FPGA_IO_B(15);
    PWM_STAT(2) <= FPGA_IO_B(17);
    PWM_STAT(3) <= FPGA_IO_B(19);

    PWR_STAT <= FPGA_IO_B(21);

    ADC_MISO <= FPGA_IO_B(22);
    FPGA_IO_B(23) <= ADC_MOSI;
    FPGA_IO_B(24) <= ADC_SCLK;
    FPGA_IO_B(25) <= ADC_SCS;

    IRC_CHA <= FPGA_IO_B(27);
    IRC_CHB <= FPGA_IO_C(31);
    IRC_IDX <= FPGA_IO_C(33);

    HAL_SENS(1) <= FPGA_IO_C(35);
    HAL_SENS(2) <= FPGA_IO_C(37);
    HAL_SENS(3) <= FPGA_IO_C(39);
end rtl;
