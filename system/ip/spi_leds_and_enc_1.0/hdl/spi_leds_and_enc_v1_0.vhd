library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_leds_and_enc_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 6
	);
	port (
		-- Users to add ports here
		spi_led_reset	: out std_logic;
		spi_led_clk   	: out std_logic;
		spi_led_cs   	: out std_logic;
		spi_led_data   	: out std_logic;
		spi_led_encin  	: in std_logic;
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end spi_leds_and_enc_v1_0;

architecture arch_imp of spi_leds_and_enc_v1_0 is

	-- component declaration
	component spi_leds_and_enc_v1_0_S00_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 6
		);
		port (
		output_led_line : out std_logic_vector(31 downto 0);
		output_led_rgb1 : out std_logic_vector(23 downto 0);
		output_led_rgb2 : out std_logic_vector(23 downto 0);
		output_led_direct : out std_logic_vector(7 downto 0);
		output_kbd_direct : out std_logic_vector(3 downto 0);

		in_enc_direct : in std_logic_vector(8 downto 0);
		in_kbd_direct : in std_logic_vector(3 downto 0);
		in_enc_8bit : in std_logic_vector(23 downto 0);
		in_enc_buttons : in std_logic_vector(2 downto 0);

		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component spi_leds_and_enc_v1_0_S00_AXI;

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

	component dff3cke is
		port (
		clk_i    : in std_logic;
		clk_en   : in std_logic;
		d_i      : in std_logic;
		q_o      : out std_logic;
		ch_o     : out std_logic;
		ch_1ck_o : out std_logic
		);
	end component;

	component qcounter_nbit is
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
	end component;

	component cnt_div is
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
	end component;

	component pulse_gen is
		generic (
		duration_width_g : natural := 4
		);
		port (
		clk_i      : in std_logic;				--clk to divide
		en_i       : in std_logic;				--enable bit?
		reset_i    : in std_logic;				--asynch. reset
		trigger_i  : in std_logic;				--start to generate pulse
		duration_i : in std_logic_vector(duration_width_g-1 downto 0);--duration/interval of the pulse
		q_out_o    : out std_logic				--generates pulse for given duration
		);
	end component;

	constant spi_data_width : integer := 48;
	constant spi_clk_div : integer := 10;
	constant enc_number : integer := 3;
	constant pwm_width : integer := 8;
	constant pwm_ratio : std_logic_vector(pwm_width-1 downto 0) :=
	                     std_logic_vector(to_unsigned(2 ** pwm_width - 1, pwm_width));

	signal fsm_clk : std_logic;
	signal fsm_rst : std_logic;
	signal spi_rx_data : std_logic_vector(spi_data_width-1 downto 0);
	signal spi_tx_data : std_logic_vector(spi_data_width-1 downto 0);
	signal spi_transfer_ready : std_logic;

	signal spi_out_rgb1 : std_logic_vector(2 downto 0);
	signal spi_out_rgb2 : std_logic_vector(2 downto 0);

	signal spi_out_led3 : std_logic;
	signal spi_out_led4 : std_logic;

	signal output_led_line : std_logic_vector(31 downto 0);
	signal output_led_rgb1 : std_logic_vector(23 downto 0);
	signal output_led_rgb2 : std_logic_vector(23 downto 0);
	signal output_led_direct : std_logic_vector(7 downto 0);
	signal output_kbd_direct : std_logic_vector(3 downto 0);

	signal in_enc_direct : std_logic_vector(8 downto 0);
	signal in_kbd_direct : std_logic_vector(3 downto 0);
	signal in_enc_8bit : std_logic_vector(23 downto 0);
	signal in_enc_buttons : std_logic_vector(2 downto 0);

	signal enc_cha : std_logic_vector(enc_number downto 1);
	signal enc_chb : std_logic_vector(enc_number downto 1);
	signal enc_sw : std_logic_vector(enc_number downto 1);

	signal enc_cha_filt : std_logic_vector(enc_number downto 1);
	signal enc_chb_filt : std_logic_vector(enc_number downto 1);
	signal enc_sw_filt : std_logic_vector(enc_number downto 1);
	signal enc_sw_changed : std_logic_vector(enc_number downto 1);
	signal enc_pos_changed : std_logic_vector(enc_number downto 1);

	signal pwm_cycle_start : std_logic;
	signal pwm_rgb1_sig : std_logic_vector(2 downto 0);
	signal pwm_rgb2_sig : std_logic_vector(2 downto 0);

begin

-- Instantiation of Axi Bus Interface S00_AXI
spi_leds_and_enc_v1_0_S00_AXI_inst : spi_leds_and_enc_v1_0_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
		output_led_line => output_led_line,
		output_led_rgb1 => output_led_rgb1,
		output_led_rgb2 => output_led_rgb2,
		output_led_direct => output_led_direct,
		output_kbd_direct => output_kbd_direct,

		in_enc_direct => in_enc_direct,
		in_kbd_direct => in_kbd_direct,
		in_enc_8bit => in_enc_8bit,
		in_enc_buttons => in_enc_buttons,

		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready
	);

	-- Add user logic here

spi_leds_and_enc_v1_0_spi_fsm_inst: spi_leds_and_enc_v1_0_spi_fsm
	generic map (
		data_width => spi_data_width,
		spi_clkdiv => spi_clk_div
	)
	port map (
		reset_in => fsm_rst,
		clk_in => fsm_clk,
		clk_en => '1',

		spi_clk => spi_led_clk,
		spi_cs => spi_led_cs,
		spi_mosi => spi_led_data,
		spi_miso => spi_led_encin,

		tx_data => spi_tx_data,
		rx_data => spi_rx_data,

		trasfer_rq => '1',
		transfer_ready => spi_transfer_ready
	);

cnt_div_inst: cnt_div
	generic map (
		cnt_width_g => pwm_width
	)
	port map (
		clk_i => fsm_clk,
		en_i => spi_transfer_ready,
		reset_i => fsm_rst,
		ratio_i => pwm_ratio,
		q_out_o => pwm_cycle_start
	);

irc_block: for i in enc_number downto 1 generate
    filt_cha: dff3cke
      port map (
          clk_i => fsm_clk,
          clk_en => spi_transfer_ready,
          d_i => enc_cha(i),
          q_o => enc_cha_filt(i),
          ch_o => open,
          ch_1ck_o => open
        );
    filt_chb: dff3cke
      port map (
          clk_i => fsm_clk,
          clk_en => spi_transfer_ready,
          d_i => enc_chb(i),
          q_o => enc_chb_filt(i),
          ch_o => open,
          ch_1ck_o => open
        );
    filt_sw: dff3cke
      port map (
          clk_i => fsm_clk,
          clk_en => spi_transfer_ready,
          d_i => enc_sw(i),
          q_o => enc_sw_filt(i),
          ch_o => open,
          ch_1ck_o => enc_sw_changed(i)
        );
    qcounter: qcounter_nbit
      generic map (
          bitwidth => 8
        )
      port map (
          clock => fsm_clk,
          reset => fsm_rst,
          a0 => enc_cha_filt(i),
          b0 => enc_chb_filt(i),
          qcount => in_enc_8bit((3 - i) * 8 + 7 downto (3 - i) * 8),
          a_rise => open,
          a_fall => open,
          b_rise => open,
          b_fall => open,
          ab_event => enc_pos_changed(i),
          ab_error => open
        );
  end generate;

pwm_rgb1_block: for i in 2 downto 0 generate
    pwm_rgb1: pulse_gen
      generic map (
          duration_width_g => pwm_width
      )
      port map (
          clk_i => fsm_clk,
          en_i => spi_transfer_ready,
          reset_i => fsm_rst,
          trigger_i => pwm_cycle_start,
          duration_i => output_led_rgb1(i * 8 + 7 downto i * 8),
          q_out_o => pwm_rgb1_sig(i)
      );
  end generate;

pwm_rgb2_block: for i in 2 downto 0 generate
    pwm_rgb2: pulse_gen
      generic map (
          duration_width_g => pwm_width
      )
      port map (
          clk_i => fsm_clk,
          en_i => spi_transfer_ready,
          reset_i => fsm_rst,
          trigger_i => pwm_cycle_start,
          duration_i => output_led_rgb2(i * 8 + 7 downto i * 8),
          q_out_o => pwm_rgb2_sig(i)
      );
  end generate;

	fsm_clk <= s00_axi_aclk;
	fsm_rst <= not s00_axi_aresetn;

data_logic_process :process
	begin
		wait until rising_edge (fsm_clk);
		if fsm_rst = '1' then
			spi_led_reset <= '1';
		elsif spi_transfer_ready = '1' then
			spi_led_reset <= '0';
		end if;
	end process;

	spi_tx_data(47) <= '0';
	spi_tx_data(46 downto 44) <= spi_out_rgb1;
	spi_tx_data(43 downto 42) <= (others => '0');
	spi_tx_data(41) <= spi_out_led4;
	spi_tx_data(40) <= spi_out_led3;
	spi_tx_data(39 downto 8) <= output_led_line;
	spi_tx_data(7) <= '0';
	spi_tx_data(6 downto 3) <= not output_kbd_direct;
	spi_tx_data(2 downto 0) <= spi_out_rgb2;

	enc_chb(1) <= not spi_rx_data(4);
	enc_sw(1) <= not spi_rx_data(5);
	enc_cha(1) <= not spi_rx_data(6);

	enc_chb(2) <= not spi_rx_data(11);
	enc_sw(2) <= not spi_rx_data(12);
	enc_cha(2) <= not spi_rx_data(13);

	enc_chb(3) <= not spi_rx_data(8);
	enc_sw(3) <= not spi_rx_data(9);
	enc_cha(3) <= not spi_rx_data(10);

	in_kbd_direct <= not spi_rx_data(3 downto 0);

	in_enc_buttons(2) <= enc_sw_filt(1);
	in_enc_buttons(1) <= enc_sw_filt(2);
	in_enc_buttons(0) <= enc_sw_filt(3);

	-- in_enc_8bit <= (others => '0');

	in_enc_direct <= (8 => enc_sw(1), 7 => enc_chb(1), 6 => enc_cha(1),
	                  5 => enc_sw(2), 4 => enc_chb(2), 3 => enc_cha(2),
	                  2 => enc_sw(3), 1 => enc_chb(3), 0 => enc_cha(3));

	-- output_led_rgb1 : out std_logic_vector(23 downto 0);
	-- output_led_rgb2 : out std_logic_vector(23 downto 0);
	-- output_led_direct : out std_logic_vector(7 downto 0);

	spi_out_rgb1 <= output_led_direct(2 downto 0) or pwm_rgb1_sig;
	spi_out_rgb2 <= output_led_direct(5 downto 3) or pwm_rgb2_sig;
	spi_out_led3 <= output_led_direct(6);
	spi_out_led4 <= output_led_direct(7);

	-- User logic ends

end arch_imp;
