library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity servo_led_ps2_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 5
	);
	port (
		-- Users to add ports here
		SERVO1		: out std_logic;
		SERVO2		: out std_logic;
		SERVO3		: out std_logic;
		SERVO4		: inout std_logic;
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
end servo_led_ps2_v1_0;

architecture arch_imp of servo_led_ps2_v1_0 is

	-- component declaration
	component servo_led_ps2_v1_0_S00_AXI is
		generic (
		servo_pwm_width		: integer	:= 24;
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 5
		);
		port (
		S_REG0		: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		servo_pwm_period: out std_logic_vector(servo_pwm_width-1 downto 0);
		servo1_pwm_duty: out std_logic_vector(servo_pwm_width-1 downto 0);
		servo2_pwm_duty: out std_logic_vector(servo_pwm_width-1 downto 0);
		servo3_pwm_duty: out std_logic_vector(servo_pwm_width-1 downto 0);
		servo4_pwm_duty: out std_logic_vector(servo_pwm_width-1 downto 0);

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
	end component servo_led_ps2_v1_0_S00_AXI;

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

	constant servo_pwm_width : integer := 24;

	signal servo_pwm_period: std_logic_vector(servo_pwm_width-1 downto 0);
	signal servo1_pwm_duty: std_logic_vector(servo_pwm_width-1 downto 0);
	signal servo2_pwm_duty: std_logic_vector(servo_pwm_width-1 downto 0);
	signal servo3_pwm_duty: std_logic_vector(servo_pwm_width-1 downto 0);
	signal servo4_pwm_duty: std_logic_vector(servo_pwm_width-1 downto 0);

	signal fsm_clk : std_logic;
	signal fsm_rst : std_logic;

	signal pwm_cycle_start : std_logic;

	signal s_reg0	: std_logic_vector(32-1 downto 0);

	signal servo1_pwm: std_logic;
	signal servo2_pwm: std_logic;
	signal servo3_pwm: std_logic;
	signal servo4_pwm: std_logic;
begin

-- Instantiation of Axi Bus Interface S00_AXI
servo_led_ps2_v1_0_S00_AXI_inst : servo_led_ps2_v1_0_S00_AXI
	generic map (
		servo_pwm_width		=> servo_pwm_width,
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
		S_REG0		=> s_reg0,
		servo_pwm_period => servo_pwm_period,
		servo1_pwm_duty => servo1_pwm_duty,
		servo2_pwm_duty => servo2_pwm_duty,
		servo3_pwm_duty => servo3_pwm_duty,
		servo4_pwm_duty => servo4_pwm_duty,

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
cnt_div_inst: cnt_div
	generic map (
		cnt_width_g => servo_pwm_width
	)
	port map (
		clk_i => fsm_clk,
		en_i => '1',
		reset_i => fsm_rst,
		ratio_i =>servo_pwm_period,
		q_out_o => pwm_cycle_start
	);

servo1_pwm_inst: pulse_gen
	generic map (
		duration_width_g => servo_pwm_width
	)
	port map (
		clk_i => fsm_clk,
		en_i => '1',
		reset_i => fsm_rst,
		trigger_i => pwm_cycle_start,
		duration_i => servo1_pwm_duty,
		q_out_o => servo1_pwm
	);

servo2_pwm_inst: pulse_gen
	generic map (
		duration_width_g => servo_pwm_width
	)
	port map (
		clk_i => fsm_clk,
		en_i => '1',
		reset_i => fsm_rst,
		trigger_i => pwm_cycle_start,
		duration_i => servo2_pwm_duty,
		q_out_o => servo1_pwm
	);

servo3_pwm_inst: pulse_gen
	generic map (
		duration_width_g => servo_pwm_width
	)
	port map (
		clk_i => fsm_clk,
		en_i => '1',
		reset_i => fsm_rst,
		trigger_i => pwm_cycle_start,
		duration_i => servo3_pwm_duty,
		q_out_o => servo1_pwm
	);

servo4_pwm_inst: pulse_gen
	generic map (
		duration_width_g => servo_pwm_width
	)
	port map (
		clk_i => fsm_clk,
		en_i => '1',
		reset_i => fsm_rst,
		trigger_i => pwm_cycle_start,
		duration_i => servo4_pwm_duty,
		q_out_o => servo1_pwm
	);

	SERVO1 <= s_reg0(0) xor servo1_pwm;
	SERVO2 <= s_reg0(1) xor servo2_pwm;
	SERVO3 <= s_reg0(2) xor servo3_pwm;
	SERVO4 <= s_reg0(3) xor servo4_pwm when s_reg0(8) = '1'
	          else 'Z';

	fsm_clk <= s00_axi_aclk;
	fsm_rst <= not s00_axi_aresetn;
	-- User logic ends

end arch_imp;
