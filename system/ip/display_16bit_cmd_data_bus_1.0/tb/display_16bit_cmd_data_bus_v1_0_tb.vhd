library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display_16bit_cmd_data_bus_tb is
end display_16bit_cmd_data_bus_tb;

architecture arch_imp of display_16bit_cmd_data_bus_tb is

	component display_16bit_cmd_data_bus_v1_0_io_fsm is
	generic (
		data_width	: integer	:= 32;
		lcd_io_width	: integer	:= 16;
		lcd_bus_clkdiv	: integer	:= 1
	);
	port (
		reset_in   	: in std_logic;

		clk_in   	: in std_logic;
		clk_en   	: in std_logic;

		lcd_res_n       : out std_logic;
		lcd_cs_n        : out std_logic;
		lcd_wr_n        : out std_logic;
		lcd_rd_n        : out std_logic;
		lcd_dc          : out std_logic;
		lcd_data	: inout std_logic_vector(lcd_io_width-1 downto 0);

		data_out	: in std_logic_vector(data_width-1 downto 0);
		dc_out		: in std_logic;

		trasfer_rq	: in std_logic;
		trasfer_rq_dbl	: in std_logic;
		ready_for_rq	: out std_logic
	);
	end component;

	constant clk_period : time := 10 ns;

	signal clk : std_logic := '0';
	signal rst : std_logic := '1';

	signal	lcd_res_n : std_logic;
	signal	lcd_cs_n : std_logic;
	signal	lcd_wr_n : std_logic;
	signal	lcd_rd_n : std_logic;
	signal	lcd_dc : std_logic;
	signal	lcd_data : std_logic_vector(15 downto 0);

	signal	data_out : std_logic_vector(31 downto 0);
	signal	dc_out : std_logic;

	signal	trasfer_rq : std_logic;
	signal	trasfer_rq_dbl : std_logic;
	signal	ready_for_rq : std_logic;

begin

	-- Instantiate the Unit Under Test (UUT)
   uut: display_16bit_cmd_data_bus_v1_0_io_fsm
	generic map (
		data_width     => 32,
		lcd_io_width   => 16,
		lcd_bus_clkdiv => 1
	)
	port map (
		reset_in => rst,
		clk_in => clk,
		clk_en => '1',

		lcd_res_n => lcd_res_n,
		lcd_cs_n => lcd_cs_n,
		lcd_wr_n => lcd_wr_n,
		lcd_rd_n => lcd_rd_n,
		lcd_dc => lcd_dc,
		lcd_data => lcd_data,

		data_out => data_out,
		dc_out => dc_out,

		trasfer_rq => trasfer_rq,
		trasfer_rq_dbl => trasfer_rq_dbl,
		ready_for_rq => ready_for_rq
	);

	data_out <= "10110001111111111011000100000000";

	clk_process :process
	begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
	end process;

	test_process :process
	begin
		trasfer_rq <= '0';
		trasfer_rq_dbl <= '0';
		dc_out <= '1';
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		rst <= '0';
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		trasfer_rq <= '1';
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		trasfer_rq <= '0';
		dc_out <= '0';
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		trasfer_rq <= '1';
		trasfer_rq_dbl <= '1';
		wait until rising_edge (clk);
		trasfer_rq <= '0';
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
	end process;

end arch_imp;
