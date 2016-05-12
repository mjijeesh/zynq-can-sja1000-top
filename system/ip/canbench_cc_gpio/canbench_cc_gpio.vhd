library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity canbench_cc_gpio is
    Port ( GPIO_I : out STD_LOGIC_VECTOR(63 downto 0);
           GPIO_O : in  STD_LOGIC_VECTOR(63 downto 0);
--           GPIO_T : inout STD_LOGIC_VECTOR(63 downto 0);
           LED : out STD_LOGIC_VECTOR(7 downto 0);
           KEY : in  STD_LOGIC_VECTOR(3 downto 0);
           SW  : in  STD_LOGIC_VECTOR(7 downto 0)
         );
end canbench_cc_gpio;

architecture rtl of canbench_cc_gpio is

begin
    GPIO_I(7 downto 0) <= SW;
    GPIO_I(11 downto 8) <= KEY;
    GPIO_I(63 downto 12) <= (others => '0');

    LED <= (not SW) and (KEY & KEY);--GPIO_O(7 downto 0);
end rtl;
