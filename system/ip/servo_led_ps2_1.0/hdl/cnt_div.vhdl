--
-- * Counter - divider *
--
-- part of LXPWR motion control board (c) PiKRON Ltd
-- idea by Pavel Pisa PiKRON Ltd <ppisa@pikron.com>
--
-- license: BSD
--
-- This file is used in "RPI PMS motor control" as frequency divider - divides by 6

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cnt_div is
	generic (
		cnt_width_g : natural := 4
	);
	port
	(
		clk_i     : in std_logic;				--clk to divide
		en_i      : in std_logic;				--enable bit?
		reset_i   : in std_logic;				--asynch. reset
		ratio_i   : in std_logic_vector(cnt_width_g-1 downto 0);--initial value
		q_out_o   : out std_logic				--generates puls when counter underflows
	);
end cnt_div;

architecture behavioral of cnt_div is
	signal cnt_val_s : natural range 0 to (2**cnt_width_g - 1);	--counter value before DFF
	signal cnt_val_r : natural range 0 to (2**cnt_width_g - 1);	--counter value after DFF
begin

comb: process (reset_i, en_i, ratio_i, cnt_val_r)
	begin
		if reset_i = '1' then --reset detection
			cnt_val_s <= to_integer(unsigned(ratio_i));  	--set initial value
			q_out_o   <= '0';				--reset output	
		else
			if en_i = '0' then				--stop-state
				cnt_val_s <= cnt_val_r;			--hold the value
				q_out_o   <= '0';			--reset output
			else
				if cnt_val_r <= 1 then			--counter underflows
					cnt_val_s <= to_integer(unsigned(ratio_i)); --set initial value
					q_out_o   <= '1';		--set output
				else
					cnt_val_s <= cnt_val_r - 1;	--decrement counter
					q_out_o   <= '0';		--reset output
				end if;
			end if;
		end if;
	end process;

seq: process
	begin
		wait until clk_i'event and clk_i = '1';
		cnt_val_r <= cnt_val_s;
	end process;

end behavioral;

