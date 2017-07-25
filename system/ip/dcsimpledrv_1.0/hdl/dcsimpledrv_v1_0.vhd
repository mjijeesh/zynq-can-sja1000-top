library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dcsimpledrv_v1_0 is
    generic (
        -- Users to add parameters here

        -- User parameters ends
        -- Do not modify the parameters beyond this line


        -- Parameters of Axi Slave Bus Interface S00_AXI
        C_S00_AXI_DATA_WIDTH    : integer    := 32;
        C_S00_AXI_ADDR_WIDTH    : integer    := 5
    );
    port (
        -- Users to add ports here
        PWM_A          : out std_logic;
        PWM_B          : out std_logic;
        IRC_A          : in std_logic;
        IRC_B          : in std_logic;
        IRC_IRQ        : in std_logic;

        IRC_A_MON      : out std_logic;
        IRC_B_MON      : out std_logic;
        IRC_IRQ_MON    : out std_logic;
        IRC_CHG_MON    : out std_logic;
        -- User ports ends
        -- Do not modify the ports beyond this line


        -- Ports of Axi Slave Bus Interface S00_AXI
        s00_axi_aclk   : in std_logic;
        s00_axi_aresetn: in std_logic;
        s00_axi_awaddr : in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
        s00_axi_awprot : in std_logic_vector(2 downto 0);
        s00_axi_awvalid: in std_logic;
        s00_axi_awready: out std_logic;
        s00_axi_wdata  : in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        s00_axi_wstrb  : in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
        s00_axi_wvalid : in std_logic;
        s00_axi_wready : out std_logic;
        s00_axi_bresp  : out std_logic_vector(1 downto 0);
        s00_axi_bvalid : out std_logic;
        s00_axi_bready : in std_logic;
        s00_axi_araddr : in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
        s00_axi_arprot : in std_logic_vector(2 downto 0);
        s00_axi_arvalid: in std_logic;
        s00_axi_arready: out std_logic;
        s00_axi_rdata  : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        s00_axi_rresp  : out std_logic_vector(1 downto 0);
        s00_axi_rvalid : out std_logic;
        s00_axi_rready : in std_logic
    );
end dcsimpledrv_v1_0;

architecture arch_imp of dcsimpledrv_v1_0 is

    -- component declaration
    component dcsimpledrv_v1_0_S00_AXI is
        generic (
        C_S_AXI_DATA_WIDTH    : integer    := 32;
        C_S_AXI_ADDR_WIDTH    : integer    := 5
        );
        port (
        irc_pos         : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        irc_a_mon       : in std_logic;
        irc_b_mon       : in std_logic;
        irc_irq_mon     : in std_logic;

        irc_reset   : out std_logic;
        pwm_direct_a: out std_logic;
        pwm_direct_b: out std_logic;
        pwm_enable  : out std_logic;

        pwm_period  : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        pwm_duty    : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);

        S_AXI_ACLK      : in std_logic;
        S_AXI_ARESETN   : in std_logic;
        S_AXI_AWADDR    : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_AWPROT    : in std_logic_vector(2 downto 0);
        S_AXI_AWVALID   : in std_logic;
        S_AXI_AWREADY   : out std_logic;
        S_AXI_WDATA     : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_WSTRB     : in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
        S_AXI_WVALID    : in std_logic;
        S_AXI_WREADY    : out std_logic;
        S_AXI_BRESP     : out std_logic_vector(1 downto 0);
        S_AXI_BVALID    : out std_logic;
        S_AXI_BREADY    : in std_logic;
        S_AXI_ARADDR    : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_ARPROT    : in std_logic_vector(2 downto 0);
        S_AXI_ARVALID   : in std_logic;
        S_AXI_ARREADY   : out std_logic;
        S_AXI_RDATA     : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_RRESP     : out std_logic_vector(1 downto 0);
        S_AXI_RVALID    : out std_logic;
        S_AXI_RREADY    : in std_logic
        );
    end component dcsimpledrv_v1_0_S00_AXI;

    component dff3 is
        port(
        clk_i   : in std_logic;
        d_i     : in std_logic;
        q_o     : out std_logic
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

    constant irc_bits_n:  natural := 32;

    signal irc_pos_act: std_logic_vector(irc_bits_n-1 downto 0);

    signal irc_a_dff3:   std_logic;
    signal irc_b_dff3:   std_logic;
    signal irc_irq_dff3: std_logic;
    signal irc_event:    std_logic;

    signal fsm_clk : std_logic;
    signal fsm_rst : std_logic;
    signal irc_reset_bit : std_logic;
    signal irc_reset_rq  : std_logic;

    signal pwm_direct_a  : std_logic;
    signal pwm_direct_b  : std_logic;
    signal pwm_enable    : std_logic;

    signal pwm_period : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
    signal pwm_duty   : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
begin

-- Instantiation of Axi Bus Interface S00_AXI
dcsimpledrv_v1_0_S00_AXI_inst : dcsimpledrv_v1_0_S00_AXI
    generic map (
        C_S_AXI_DATA_WIDTH    => C_S00_AXI_DATA_WIDTH,
        C_S_AXI_ADDR_WIDTH    => C_S00_AXI_ADDR_WIDTH
    )
    port map (
        irc_pos       => irc_pos_act,
        irc_a_mon     => irc_a_dff3,
        irc_b_mon     => irc_b_dff3,
        irc_irq_mon   => irc_irq_dff3,

        irc_reset     => irc_reset_bit,
        pwm_direct_a  => pwm_direct_a,
        pwm_direct_b  => pwm_direct_b,
        pwm_enable    => pwm_enable,

        pwm_period    => pwm_period,
        pwm_duty      => pwm_duty,

        S_AXI_ACLK    => s00_axi_aclk,
        S_AXI_ARESETN => s00_axi_aresetn,
        S_AXI_AWADDR  => s00_axi_awaddr,
        S_AXI_AWPROT  => s00_axi_awprot,
        S_AXI_AWVALID => s00_axi_awvalid,
        S_AXI_AWREADY => s00_axi_awready,
        S_AXI_WDATA   => s00_axi_wdata,
        S_AXI_WSTRB   => s00_axi_wstrb,
        S_AXI_WVALID  => s00_axi_wvalid,
        S_AXI_WREADY  => s00_axi_wready,
        S_AXI_BRESP   => s00_axi_bresp,
        S_AXI_BVALID  => s00_axi_bvalid,
        S_AXI_BREADY  => s00_axi_bready,
        S_AXI_ARADDR  => s00_axi_araddr,
        S_AXI_ARPROT  => s00_axi_arprot,
        S_AXI_ARVALID => s00_axi_arvalid,
        S_AXI_ARREADY => s00_axi_arready,
        S_AXI_RDATA   => s00_axi_rdata,
        S_AXI_RRESP   => s00_axi_rresp,
        S_AXI_RVALID  => s00_axi_rvalid,
        S_AXI_RREADY  => s00_axi_rready
    );

    -- Add user logic here

dff3_a: dff3
    port map(
        clk_i => fsm_clk,
        d_i   => IRC_A,
        q_o   => irc_a_dff3
    );

dff3_b: dff3
    port map(
        clk_i => fsm_clk,
        d_i   => IRC_B,
        q_o   => irc_b_dff3
    );

dff3_i: dff3
    port map(
        clk_i => fsm_clk,
        d_i   => IRC_IRQ,
        q_o   => irc_irq_dff3
    );

qcounter_nbit_inst:     qcounter_nbit
    generic map (
        bitwidth => irc_bits_n
     )
     port map (
        clock => fsm_clk,
        reset => irc_reset_rq,
        a0 =>  irc_a_dff3,
        b0 =>  irc_b_dff3,
        qcount => irc_pos_act,
        a_rise => open,
        a_fall => open,
        b_rise => open,
        b_fall => open,
        ab_event => irc_event,
        ab_error => open
    );

    fsm_clk <= s00_axi_aclk;
    fsm_rst <= not s00_axi_aresetn;

    irc_reset_rq <= irc_reset_bit or fsm_rst; 

    PWM_A          <= pwm_direct_a;
    PWM_B          <= pwm_direct_b;

    IRC_A_MON      <= irc_a_dff3;
    IRC_B_MON      <= irc_b_dff3;
    IRC_IRQ_MON    <= irc_irq_dff3;
    IRC_CHG_MON    <= irc_event;

    -- User logic ends

end arch_imp;
