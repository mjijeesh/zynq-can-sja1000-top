library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- D circuit (filtered)

entity dff3cke is
  port
	(
    clk_i    : in std_logic;
    clk_en   : in std_logic;
    d_i      : in std_logic;
    q_o      : out std_logic;
    ch_o     : out std_logic;
    ch_1ck_o : out std_logic
  );
end dff3cke;

architecture behavioral of dff3cke is
	signal d_3r   : std_logic;
	signal d_2r   : std_logic;
	signal d_r    : std_logic;
	signal data_s : std_logic;

	-- XST attributes
	--potlaceni duplikace klupnych obvodu ve fazi optimalizace
	--attribute REGISTER_DUPLICATION : string;
	--attribute REGISTER_DUPLICATION of d_3r : signal is "NO";
	--attribute REGISTER_DUPLICATION of d_2r : signal is "NO";
	--attribute REGISTER_DUPLICATION of d_r  : signal is "NO";
	
	attribute syn_keep : boolean;
	attribute syn_keep of d_3r : signal is true;
	attribute syn_keep of d_2r : signal is true;
	attribute syn_keep of d_r : signal is true;
	
begin
  q_o <= data_s;

seq:
    process
    begin
    wait until rising_edge (clk_i);
      if clk_en = '1' then 
        if d_3r = d_2r and d_2r = d_r then
          if data_s /= d_3r then
            ch_1ck_o <= '1';
            ch_o <= '1';
          else
            ch_1ck_o <= '0';
            ch_o <= '0';
          end if;
          data_s <= d_3r;
        else
          ch_1ck_o <= '0';
          ch_o <= '0';
	    end if;

	    d_3r <= d_2r;
	    d_2r <= d_r;
	    d_r  <= d_i;
	  else
        ch_1ck_o <= '0';
      end if;
    end process;

end behavioral;
