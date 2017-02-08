--
-- * Quadrature Signal Decoder *
-- Used for IRC sensor interfacing
--
-- (c) 2010 Marek Peca <hefaistos@gmail.com>
--
-- Updated for generic size
--     2016 Pavel Pisa <pisa@cmp.felk.cvut.cz>
--
-- license: GNU LGPL and GPLv3+
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity qcounter_nbit is
generic (
	bitwidth: integer := 32
);
port (
	clock: in std_logic;
	reset: in std_logic;
	a0, b0: in std_logic;
	qcount: out std_logic_vector (bitwidth - 1 downto 0);
	a_rise, a_fall, b_rise, b_fall, ab_event: out std_logic;
	ab_error: out std_logic
);
end qcounter_nbit;

architecture behavioral of qcounter_nbit is
	component dff
	port (
		clock: in std_logic;
		d: in std_logic;
		q: out std_logic
	);
	end component;

	subtype std_logic4 is std_logic_vector (3 downto 0);
	signal a, b, a_prev, b_prev: std_logic;
	signal count_prev: std_logic_vector (bitwidth - 3 downto 0)
		:= (others => '0');
	signal count: std_logic_vector (bitwidth - 3 downto 0);
begin
	-- stabilize signal a between clock ticks
	-- active on rising edge of the clock signal
	dff_a: dff
	port map (
		clock => clock,
		d => a0,
		q => a
	);
	
	-- stabilize signal b between clock ticks
	-- active on rising edge of the clock signal
	dff_b: dff
	port map (
		clock => clock,
		d => b0,
		q => b
	);
 
	-- the first two bits are combinational logic only
	qcount(0) <= a xor b;
	qcount(1) <= b;
	qcount(bitwidth - 1 downto 2) <= count;
 
	-- purpose of this process is only to propagate signals to the pins
	comb_event: process (a_prev, b_prev, a, b)
	begin
		a_rise <= '0';
		a_fall <= '0';
		b_rise <= '0';
		b_fall <= '0';
		ab_event <= '0';
		ab_error <= '0';
		if ((a xor a_prev) and (b xor b_prev)) = '1' then -- a i b se zmenily zaroven
			-- forbidden double transition
			ab_error <= '1';
		else
			a_rise <= (a xor a_prev) and a; -- a rising
			a_fall <= (a xor a_prev) and not a; -- a falling
			b_rise <= (b xor b_prev) and b; -- b rissing
			b_fall <= (b xor b_prev) and not b; -- b falling
			ab_event <= (a xor a_prev) or (b xor b_prev); --a or b changed
		end if;
	end process;

	-- carry to the third bit (binary)
	comb_count: process (a_prev, b_prev, a, b, count,count_prev)
	begin
		if (a_prev = '0') and (b_prev = '1') and (a = '0') and (b = '0') then --posun dopredu 
			count <= count_prev + 1;
		elsif (a_prev = '0') and (b_prev = '0') and (a = '0') and (b = '1') then --posun dozadu
			count <= count_prev - 1;
		else
			count <= count_prev;
		end if;
	end process;

	-- all state update is done at clock signal rising edge
	-- reset count_prev register, it propagates to combinational count
	-- results automatically
	seq: process
	begin
		wait until clock'event and clock = '1';
		if reset = '1' then
			count_prev <= (others => '0');
		else
			count_prev <= count;
		end if;
		a_prev <= a;
		b_prev <= b;
	end process;
	
end behavioral;
