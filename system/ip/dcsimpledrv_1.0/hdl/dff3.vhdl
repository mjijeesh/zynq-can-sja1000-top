library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- D circuit (filtered)

entity dff3 is
  port
	(
    clk_i   : in std_logic;
    d_i     : in std_logic;
    q_o     : out std_logic
  );
end dff3;

architecture behavioral of dff3 is
	signal d_3r   : std_logic;
	signal d_2r   : std_logic;
	signal d_r    : std_logic;
	signal data_s : std_logic;

	-- XST attributes
	--potlaceni duplikace klupnych obvodu ve fazi optimalizace
	attribute REGISTER_DUPLICATION : string;
	attribute REGISTER_DUPLICATION of d_3r : signal is "NO";
	attribute REGISTER_DUPLICATION of d_2r : signal is "NO";
	attribute REGISTER_DUPLICATION of d_r  : signal is "NO";
	
	attribute syn_keep : boolean;
	attribute syn_keep of d_3r : signal is true;
	attribute syn_keep of d_2r : signal is true;
	attribute syn_keep of d_r : signal is true;
	
begin
  q_o <= data_s;

seq:
	process
	begin
    wait until clk_i'event and clk_i = '1';
		if d_3r = d_2r and d_2r = d_r then
			data_s <= d_3r;
		end if;

		d_3r <= d_2r;
		d_2r <= d_r;
		d_r  <= d_i;
  end process;

end behavioral;
