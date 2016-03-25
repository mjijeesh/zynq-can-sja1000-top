library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity can_merge is
    Port ( can_rx : out STD_LOGIC;
           can_tx1 : in STD_LOGIC := '1';
           can_tx2 : in STD_LOGIC := '1';
           can_tx3 : in STD_LOGIC := '1');
end can_merge;

architecture Behavioral of can_merge is
begin
    can_rx <= can_tx1 and can_tx2 and can_tx3;
end Behavioral;
