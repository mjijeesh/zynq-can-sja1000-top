--
-- * pulse generator *
--
-- based on code from LXPWR motion control board (c) PiKRON Ltd
-- idea by Pavel Pisa PiKRON Ltd <ppisa@pikron.com>
--
-- license: BSD
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pulse_gen is
	generic (
		duration_width_g : natural := 4
	);
	port
	(
		clk_i      : in std_logic;				--clk to divide
		en_i       : in std_logic;				--enable bit?
		reset_i    : in std_logic;				--asynch. reset
		trigger_i  : in std_logic;				--start to generate pulse
		duration_i : in std_logic_vector(duration_width_g-1 downto 0);--duration/interval of the pulse
		q_out_o    : out std_logic				--generates pulse for given duration
	);
end pulse_gen;

architecture behavioral of pulse_gen is
	signal cnt_val_s : natural range 0 to (2**duration_width_g - 1);	--counter value before DFF
	signal cnt_val_r : natural range 0 to (2**duration_width_g - 1);	--counter value after DFF
begin

comb: process (reset_i, en_i, duration_i, trigger_i, cnt_val_r)
	begin
		if reset_i = '1' then --reset detection
			cnt_val_s <= 0;		--set defined value
			q_out_o   <= '0';				--reset output
		else
			if en_i = '0' then				--stop-state
				cnt_val_s <= cnt_val_r;			--hold the value
			else
				if trigger_i = '1' then			--trigger pulse generator
					if to_integer(unsigned(duration_i)) = 0 then
						q_out_o   <= '0';
					else
						q_out_o   <= '1';
					end if;
					cnt_val_s <= to_integer(unsigned(duration_i)); --set initial value
				elsif cnt_val_r = 0 then			--pulse finished
					cnt_val_s <= cnt_val_r;
					q_out_o   <= '0';		--set output
				else
					cnt_val_s <= cnt_val_r - 1;	--decrement counter
					q_out_o   <= '1';		--reset output
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

