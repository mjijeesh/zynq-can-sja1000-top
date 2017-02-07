library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_leds_and_enc_tb is
end spi_leds_and_enc_tb;

architecture arch_imp of spi_leds_and_enc_tb is

	component spi_leds_and_enc_v1_0_spi_fsm is
		generic (
			data_width	: integer	:= 32;
			spi_clkdiv	: integer	:= 10
		);
		port (
			reset_in   	: in std_logic;

			clk_in   	: in std_logic;
			clk_en   	: in std_logic;

			spi_clk   	: out std_logic;
			spi_cs   	: out std_logic;
			spi_mosi   	: out std_logic;
			spi_miso  	: in std_logic;

			tx_data		: in std_logic_vector(data_width-1 downto 0);
			rx_data		: out std_logic_vector(data_width-1 downto 0);

			trasfer_rq	: in std_logic;
			transfer_ready	: out std_logic
		);
	end component;

	constant clk_period : time := 10 ns;

	signal clk : std_logic := '0';
	signal rst : std_logic := '1';
	signal spi_clk : std_logic;
	signal spi_cs : std_logic;
	signal spi_mosi : std_logic;
	signal spi_miso : std_logic;
	signal rx_data : std_logic_vector(7 downto 0);
	signal tx_data : std_logic_vector(7 downto 0);
	signal transfer_ready : std_logic;

begin

	-- Instantiate the Unit Under Test (UUT)
   uut: spi_leds_and_enc_v1_0_spi_fsm
	generic map (
		data_width => 8,
		spi_clkdiv => 2
	)
	port map (
		reset_in => rst,
		clk_in => clk,
		clk_en => '1',

		spi_clk => spi_clk,
		spi_cs => spi_cs,
		spi_mosi => spi_mosi,
		spi_miso => spi_miso,

		tx_data => tx_data,
		rx_data => rx_data,

		trasfer_rq => '1',
		transfer_ready => transfer_ready
	);

	spi_miso <= spi_mosi;
	tx_data <= "10110001";

	clk_process :process
	begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
	end process;

	test_process :process
	begin
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		wait until rising_edge (clk);
		rst <= '0';
	end process;

end arch_imp;
