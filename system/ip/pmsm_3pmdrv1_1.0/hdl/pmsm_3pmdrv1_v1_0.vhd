--
-- * BLDC/PMSM motor control design for 3p-motor-driver board *
-- The toplevel component file
--
-- Design for Zynq platform
-- (c) 2017 Pavel Pisa <ppisa@pikron.com>
--
-- Partially based on VHDL design providing
-- Raspberry Pi BLDC/PMSM motor control for RPi-MI-1 board by
-- (c) 2015 Martin Prudek <prudemar@fel.cvut.cz>
--
-- Initial project supervision and original project idea
-- idea by Pavel Pisa <pisa@cmp.felk.cvut.cz>
--
-- Related RPi-MI-1 hardware is designed by Petr Porazil,
-- PiKRON Ltd  <http://www.pikron.com>
--
-- VHDL design reuses some components and concepts from
-- LXPWR motion power stage board and LX_RoCoN system
-- developed at PiKRON Ltd with base code implemented
-- by Marek Peca <hefaistos@gmail.com>
--
-- license: GNU LGPL and GPLv3+
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pmsm_3pmdrv1_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 6;

		-- Parameters of Axi Slave Bus Interface S_AXI_INTR
		C_S_AXI_INTR_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_INTR_ADDR_WIDTH	: integer	:= 5;
		C_NUM_OF_INTR	: integer	:= 1;
		C_INTR_SENSITIVITY	: std_logic_vector	:= x"FFFFFFFF";
		C_INTR_ACTIVE_STATE	: std_logic_vector	:= x"FFFFFFFF";
		C_IRQ_SENSITIVITY	: integer	:= 1;
		C_IRQ_ACTIVE_STATE	: integer	:= 1
	);
	port (
		-- Users to add ports here
        PWM_OUT : out std_logic_vector(1 to 3);
        PWM_SHDN : out std_logic_vector(1 to 3);
        PWM_STAT : in std_logic_vector(1 to 3);

        HAL_SENS : in std_logic_vector(1 to 3);

        ADC_SCLK: out std_logic;
        ADC_SCS: out std_logic;
        ADC_MOSI: out std_logic;
        ADC_MISO: in std_logic;

        PWR_STAT: in std_logic;

        IRC_CHA: in std_logic;
        IRC_CHB: in std_logic;
        IRC_IDX: in std_logic;
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
		s00_axi_rready	: in std_logic;

		-- Ports of Axi Slave Bus Interface S_AXI_INTR
		s_axi_intr_aclk	: in std_logic;
		s_axi_intr_aresetn	: in std_logic;
		s_axi_intr_awaddr	: in std_logic_vector(C_S_AXI_INTR_ADDR_WIDTH-1 downto 0);
		s_axi_intr_awprot	: in std_logic_vector(2 downto 0);
		s_axi_intr_awvalid	: in std_logic;
		s_axi_intr_awready	: out std_logic;
		s_axi_intr_wdata	: in std_logic_vector(C_S_AXI_INTR_DATA_WIDTH-1 downto 0);
		s_axi_intr_wstrb	: in std_logic_vector((C_S_AXI_INTR_DATA_WIDTH/8)-1 downto 0);
		s_axi_intr_wvalid	: in std_logic;
		s_axi_intr_wready	: out std_logic;
		s_axi_intr_bresp	: out std_logic_vector(1 downto 0);
		s_axi_intr_bvalid	: out std_logic;
		s_axi_intr_bready	: in std_logic;
		s_axi_intr_araddr	: in std_logic_vector(C_S_AXI_INTR_ADDR_WIDTH-1 downto 0);
		s_axi_intr_arprot	: in std_logic_vector(2 downto 0);
		s_axi_intr_arvalid	: in std_logic;
		s_axi_intr_arready	: out std_logic;
		s_axi_intr_rdata	: out std_logic_vector(C_S_AXI_INTR_DATA_WIDTH-1 downto 0);
		s_axi_intr_rresp	: out std_logic_vector(1 downto 0);
		s_axi_intr_rvalid	: out std_logic;
		s_axi_intr_rready	: in std_logic;
		irq	: out std_logic
	);
end pmsm_3pmdrv1_v1_0;

architecture arch_imp of pmsm_3pmdrv1_v1_0 is

	-- component declaration
	component pmsm_3pmdrv1_v1_0_S00_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 6
		);
		port (

        pwm1 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        pwm2 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        pwm3 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);

        pwm_update : out std_logic;
        pwm_timeout_disable : out std_logic;

        irc_pos : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        irc_idx_pos : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);

        adc_sqn_stat : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);

        adc1 : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        adc2 : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        adc3 : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);

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
	end component pmsm_3pmdrv1_v1_0_S00_AXI;

	component pmsm_3pmdrv1_v1_0_S_AXI_INTR is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 5;
		C_NUM_OF_INTR	: integer	:= 1;
		C_INTR_SENSITIVITY	: std_logic_vector	:= x"FFFFFFFF";
		C_INTR_ACTIVE_STATE	: std_logic_vector	:= x"FFFFFFFF";
		C_IRQ_SENSITIVITY	: integer	:= 1;
		C_IRQ_ACTIVE_STATE	: integer	:= 1
		);
		port (
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
		S_AXI_RREADY	: in std_logic;
		irq	: out std_logic
		);
	end component pmsm_3pmdrv1_v1_0_S_AXI_INTR;

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

	component mcpwm is
	generic (
		pwm_width: natural
	);
	port (
		clock: in std_logic;
		sync: in std_logic; 				--flag that counter "restarts-overflows"
		data_valid:in std_logic; 			--indicates data is consistent
		failsafe: in std_logic; 			--turn off both transistors
		en_p, en_n: in std_logic; 			--enable positive & enable shutdown
		match: in std_logic_vector (pwm_width-1 downto 0); --posion of counter when we swap output logic
		count: in std_logic_vector (pwm_width-1 downto 0); --we use an external counter
		out_p, out_n: out std_logic 			--pwm outputs: positive & shutdown
		--TODO add the rest of pwm signals, swap match to pwm_word
	);
	end component;

	component adc_reader is
    port (
        clk: in std_logic;                    --input clk
        divided_clk : in std_logic;                --divided clk - value suitable to sourcing voltage
        adc_reset: in std_logic;
        adc_miso: in std_logic;                    --spi master in slave out
        adc_sclk: out std_logic;                 --spi clk
        adc_scs: out std_logic;                    --spi slave select
        adc_mosi: out std_logic;                --spi master out slave in

        adc_channels: out std_logic_vector (71 downto 0);    --consistent data of 3 channels
        measur_count: out std_logic_vector(11 downto 0)      --number of accumulated measurments
    );
    end component;

    component dff3 is
    port(
        clk_i   : in std_logic;
        d_i     : in std_logic;
        q_o     : out std_logic
    );
    end component;

	--pwm signals
    constant pwm_n: natural := 3;                    --number of pwm outputs

	--irc
    constant irc_bits_n: natural := 32;                    --number of pwm outputs

    constant pwm_width: natural := 14;
    constant pwm_timeout_width: natural := 7;

    signal fsm_clk : std_logic;
    signal fsm_rst : std_logic;

    signal clk_4MHz : std_logic;

	signal adc_channels: std_logic_vector(71 downto 0);
	signal adc_m_count: std_logic_vector(11 downto 0);

	--filetered irc signals
	signal irc_a_dff3: std_logic;
	signal irc_b_dff3: std_logic;
	signal irc_idx_dff3: std_logic;

    signal irc_pos_act: std_logic_vector(irc_bits_n-1 downto 0);

	--number of ticks per pwm cycle
	constant pwm_period : std_logic_vector (pwm_width-1 downto 0) :=
	                   std_logic_vector(to_unsigned(5000, pwm_width));

	type pwm_match_type is array(1 to 3) of std_logic_vector (pwm_width-1 downto 0);

	signal pwm_match: pwm_match_type;					--point of reversion of pwm output, 0 to 2047
	signal pwm_count: std_logic_vector (pwm_width-1 downto 0); 	--counter, 0 to 2047
	signal pwm_sync_at_next: std_logic;
	signal pwm_sync: std_logic;
	signal pwm_en_p: std_logic_vector(1 to 3);
	signal pwm_en_n: std_logic_vector(1 to 3);
	signal pwm_sig: std_logic_vector(1 to 3);
	signal shdn_sig: std_logic_vector (1 to 3);

    signal pwm1 : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
    signal pwm2 : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
    signal pwm3 : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);

    signal pwm_update : std_logic;
    signal pwm_timeout_disable : std_logic;

    constant pwm_timeout_reload : std_logic_vector (pwm_timeout_width-1 downto 0) :=
                   std_logic_vector(to_unsigned(127, pwm_timeout_width));
    signal pwm_timeout_count: std_logic_vector (pwm_timeout_width-1 downto 0);

    signal failsafe : std_logic;

    signal irc_pos : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
    signal irc_idx_pos : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);

    signal adc_sqn_stat : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);

    signal adc1 : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
    signal adc2 : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
    signal adc3 : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
begin

-- Instantiation of Axi Bus Interface S00_AXI
pmsm_3pmdrv1_v1_0_S00_AXI_inst : pmsm_3pmdrv1_v1_0_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
	    pwm1 => pwm1,
	    pwm2 => pwm2,
	    pwm3 => pwm3,

	    pwm_update => pwm_update,
	    pwm_timeout_disable => pwm_timeout_disable,

        irc_pos => irc_pos,
        irc_idx_pos => irc_idx_pos,

        adc_sqn_stat => adc_sqn_stat,

        adc1 => adc1,
        adc2 => adc2,
        adc3 => adc3,

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

-- Instantiation of Axi Bus Interface S_AXI_INTR
pmsm_3pmdrv1_v1_0_S_AXI_INTR_inst : pmsm_3pmdrv1_v1_0_S_AXI_INTR
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S_AXI_INTR_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S_AXI_INTR_ADDR_WIDTH,
		C_NUM_OF_INTR	=> C_NUM_OF_INTR,
		C_INTR_SENSITIVITY	=> C_INTR_SENSITIVITY,
		C_INTR_ACTIVE_STATE	=> C_INTR_ACTIVE_STATE,
		C_IRQ_SENSITIVITY	=> C_IRQ_SENSITIVITY,
		C_IRQ_ACTIVE_STATE	=> C_IRQ_ACTIVE_STATE
	)
	port map (
		S_AXI_ACLK	=> s_axi_intr_aclk,
		S_AXI_ARESETN	=> s_axi_intr_aresetn,
		S_AXI_AWADDR	=> s_axi_intr_awaddr,
		S_AXI_AWPROT	=> s_axi_intr_awprot,
		S_AXI_AWVALID	=> s_axi_intr_awvalid,
		S_AXI_AWREADY	=> s_axi_intr_awready,
		S_AXI_WDATA	=> s_axi_intr_wdata,
		S_AXI_WSTRB	=> s_axi_intr_wstrb,
		S_AXI_WVALID	=> s_axi_intr_wvalid,
		S_AXI_WREADY	=> s_axi_intr_wready,
		S_AXI_BRESP	=> s_axi_intr_bresp,
		S_AXI_BVALID	=> s_axi_intr_bvalid,
		S_AXI_BREADY	=> s_axi_intr_bready,
		S_AXI_ARADDR	=> s_axi_intr_araddr,
		S_AXI_ARPROT	=> s_axi_intr_arprot,
		S_AXI_ARVALID	=> s_axi_intr_arvalid,
		S_AXI_ARREADY	=> s_axi_intr_arready,
		S_AXI_RDATA	=> s_axi_intr_rdata,
		S_AXI_RRESP	=> s_axi_intr_rresp,
		S_AXI_RVALID	=> s_axi_intr_rvalid,
		S_AXI_RREADY	=> s_axi_intr_rready,
		irq	=> irq
	);

	-- Add user logic here

dff3_a: dff3
	port map(
		clk_i => fsm_clk,
		d_i   => IRC_CHA,
		q_o   => irc_a_dff3
	);

dff3_b: dff3
	port map(
		clk_i => fsm_clk,
		d_i   => IRC_CHB,
		q_o   => irc_b_dff3
	);

dff3_i: dff3
	port map(
		clk_i => fsm_clk,
		d_i   => IRC_IDX,
		q_o   => irc_idx_dff3
	);

qcounter_nbit_inst:	qcounter_nbit
    generic map (
        bitwidth => irc_bits_n
     )
     port map (
        clock => fsm_clk,
        reset => fsm_rst,
        a0 =>  irc_a_dff3,
        b0 =>  irc_b_dff3,
        qcount => irc_pos_act,
        a_rise => open,
        a_fall => open,
        b_rise => open,
        b_fall => open,
        ab_event => open,
        ab_error => open
    );

div12_map: cnt_div
	generic map (
		cnt_width_g => 5
	)
	port map(
		clk_i  => fsm_clk,
		en_i   =>'1',
		reset_i   =>'0',
		ratio_i   => "11001", -- 100 / 25
		q_out_o   => clk_4MHz
	);

	-- ADC needs 3.2 MHz clk when powered from +5V Vcc
	--	     2.0 MHz clk when +2.7V Vcc
	-- on the input is 4.0Mhz
	-- this frequency is divided inside adc_reader by 2 to 2.0 Mhz,
	--        while we use +3.3V Vcc
	adc_reader_map: adc_reader
	port map(
		clk => fsm_clk,
		divided_clk => clk_4MHz,
		adc_reset => fsm_rst,
		adc_miso => adc_miso,
		adc_channels => adc_channels,
		adc_sclk => adc_sclk,
		adc_scs => adc_scs,
		adc_mosi => adc_mosi,
		measur_count => adc_m_count
	);

pwm_block: for i in pwm_n downto 1 generate
		pwm_map: mcpwm
		generic map (
			pwm_width => pwm_width
		)
		port map (
			clock => fsm_clk, 				--100 Mhz clk from gpclk on raspberry
			sync => pwm_sync,				--counter restarts
			data_valid => pwm_sync_at_next,
			failsafe => failsafe,
			--
			-- pwm config bits & match word
			--
			en_n => pwm_en_n(i),				--enable positive pwm
			en_p => pwm_en_p(i),				--enable "negative" ->activate shutdown
			match => pwm_match(i),
			count => pwm_count,
			-- outputs
			out_p => pwm_sig(i),				--positive signal
			out_n => shdn_sig(i) 				--reverse signal is in shutdown mode
		);
	end generate;

	process
	begin
        wait until rising_edge (fsm_clk);
		if fsm_rst = '1' then
			failsafe <= '1';
			pwm_timeout_count <= (others=>'0');
		else
			if (pwm_update = '1') or (pwm_timeout_disable = '1') then
				failsafe <= '0';
				pwm_timeout_count <= pwm_timeout_reload;
			end if;

			if pwm_count = std_logic_vector(unsigned(pwm_period) - 1) then
				--end of period nearly reached
				--fetch new pwm match data
				pwm_sync_at_next <= '1';
			else
				pwm_sync_at_next <= '0';
			end if;

			if pwm_sync_at_next='1' then
				--end of period reached
				pwm_count <= (others=>'0');      --reset counter
				pwm_sync <= '1';       				-- inform PWM logic about new period start
				if unsigned(pwm_timeout_count) = 0  then
					failsafe <= '1';
				else
					pwm_timeout_count <= std_logic_vector(unsigned(pwm_timeout_count)-1);
				end if;

			else  							--end of period not reached
				pwm_count <= std_logic_vector(unsigned(pwm_count)+1);		--increment counter
				pwm_sync <= '0';
			end if;
		end if;
	end process;

    fsm_clk <= s00_axi_aclk;
    fsm_rst <= not s00_axi_aresetn;

	pwm_out <= pwm_sig;
	pwm_shdn <= shdn_sig;

	irc_pos <= irc_pos_act;

	process
	begin
        wait until rising_edge (fsm_clk);
		if irc_idx_dff3 = '1' then
           irc_idx_pos <= irc_pos_act;
		end if;
	end process;

	pwm_en_n(1) <= pwm1(31);	--enable positive pwm
    pwm_en_p(1) <= pwm1(30);	--enable "negative" ->activate shutdown
	pwm_match(1) <= pwm1(pwm_width-1 downto 0);

	pwm_en_n(2) <= pwm2(31);	--enable positive pwm
    pwm_en_p(2) <= pwm2(30);	--enable "negative" ->activate shutdown
	pwm_match(2) <= pwm2(pwm_width-1 downto 0);

	pwm_en_n(3) <= pwm3(31);	--enable positive pwm
    pwm_en_p(3) <= pwm3(30);	--enable "negative" ->activate shutdown
	pwm_match(3) <= pwm3(pwm_width-1 downto 0);

    adc_sqn_stat(11 downto 0) <= adc_m_count;
    adc_sqn_stat(15 downto 12) <= (others => '0');

    adc_sqn_stat(16) <= HAL_SENS(1);
    adc_sqn_stat(17) <= HAL_SENS(2);
    adc_sqn_stat(18) <= HAL_SENS(3);
    adc_sqn_stat(19) <= '0';

    adc_sqn_stat(20) <= PWM_STAT(1);
    adc_sqn_stat(21) <= PWM_STAT(2);
    adc_sqn_stat(22) <= PWM_STAT(3);
    adc_sqn_stat(23) <= '0';

    adc_sqn_stat(24) <= PWR_STAT;
    adc_sqn_stat(31 downto 25) <= (others => '0');

    adc1(23 downto 0) <= adc_channels(23 downto 0);
    adc1(31 downto 24) <= (others => '0');
    adc2(23 downto 0) <= adc_channels(47 downto 24);
    adc2(31 downto 24) <= (others => '0');
    adc3(23 downto 0) <= adc_channels(71 downto 48);
    adc3(31 downto 24) <= (others => '0');

	-- User logic ends

end arch_imp;
