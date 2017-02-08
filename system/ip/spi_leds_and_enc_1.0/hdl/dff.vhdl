library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity dff is
  port (
    clock: in std_logic;
    d: in std_logic;
    q: out std_logic
  );
end dff;

architecture behavioral of dff is
  signal data: std_logic := '0';
begin
  q <= data;

  process
  begin
    wait until clock'event and clock = '1';
    data <= d;
  end process;

end behavioral;
