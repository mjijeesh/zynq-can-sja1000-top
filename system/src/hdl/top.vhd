library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_hdl is
    port (
        DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
        DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
        DDR_cas_n : inout STD_LOGIC;
        DDR_ck_n : inout STD_LOGIC;
        DDR_ck_p : inout STD_LOGIC;
        DDR_cke : inout STD_LOGIC;
        DDR_cs_n : inout STD_LOGIC;
        DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
        DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
        DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
        DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
        DDR_odt : inout STD_LOGIC;
        DDR_ras_n : inout STD_LOGIC;
        DDR_reset_n : inout STD_LOGIC;
        DDR_we_n : inout STD_LOGIC;
        FIXED_IO_ddr_vrn : inout STD_LOGIC;
        FIXED_IO_ddr_vrp : inout STD_LOGIC;
        FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
        FIXED_IO_ps_clk : inout STD_LOGIC;
        FIXED_IO_ps_porb : inout STD_LOGIC;
        FIXED_IO_ps_srstb : inout STD_LOGIC;
        CAN1_RXD : in std_logic;
        CAN2_RXD : in std_logic;
        CAN1_TXD : out std_logic;
        CAN2_TXD : out std_logic
    );
end entity;

architecture structure of top_hdl is
    -- this retarded order is kept for backward compatibility with device tree
    type irqs_e is (
        IRQ_SJA1000_0,
        IRQ_CTUCANFD_0,
        IRQ_CTUCANFD_1,
        IRQ_SJA1000_1
    );

    type can_e is (
        CAN_CTUCANFD_0,
        CAN_CTUCANFD_1,
        CAN_SJA1000_0,
        CAN_SJA1000_1
    );

    type irq_arr_t is array(irqs_e) of std_logic;
    type can_tx_arr_t is array(can_e) of std_logic;

    --signal apbs : apb_arr_t;
    signal can_tx : can_tx_arr_t;
    signal can_rx : can_tx_arr_t;
    signal irqs : irq_arr_t;
    signal aclk : std_logic;
    signal arstn : std_logic;
    signal timestamp : std_logic_vector(63 downto 0);

    signal la_inp : std_logic_vector(31 downto 0);
    signal irq_f2p : std_logic_vector(3 downto 0);

    signal can_bus_tx              : std_logic_vector(3 downto 0);
    signal can_bus_rx              : std_logic_vector(3 downto 0);
    signal can_controller_tx       : std_logic_vector(7 downto 0);
    signal can_controller_rx       : std_logic_vector(7 downto 0);
begin
    CAN1_TXD <= can_bus_tx(0);
    CAN2_TXD <= can_bus_tx(1);

    can_bus_rx(0) <= CAN1_RXD;
    can_bus_rx(1) <= CAN2_RXD;
    can_bus_rx(can_bus_rx'left downto 2) <= (others => '1');

    process(can_tx)
        variable i : can_e;
    begin
        can_controller_tx <= (others => '1');
        for i in can_e loop
            can_controller_tx(can_e'pos(i)) <= can_tx(i);
        end loop;
    end process;

    g_canrx: for i in can_e generate
        can_rx(i) <= can_controller_rx(can_e'pos(i));
    end generate;


    -- beware of concatenation and to/downto
    irq_f2p(0) <= irqs(IRQ_SJA1000_0);
    irq_f2p(1) <= irqs(IRQ_CTUCANFD_0);
    irq_f2p(2) <= irqs(IRQ_CTUCANFD_1);
    irq_f2p(3) <= irqs(IRQ_SJA1000_1);

    i_top: entity work.top_wrapper
    port map (
        DDR_addr(14 downto 0)     => DDR_addr(14 downto 0),
        DDR_ba(2 downto 0)        => DDR_ba(2 downto 0),
        DDR_cas_n                 => DDR_cas_n,
        DDR_ck_n                  => DDR_ck_n,
        DDR_ck_p                  => DDR_ck_p,
        DDR_cke                   => DDR_cke,
        DDR_cs_n                  => DDR_cs_n,
        DDR_dm(3 downto 0)        => DDR_dm(3 downto 0),
        DDR_dq(31 downto 0)       => DDR_dq(31 downto 0),
        DDR_dqs_n(3 downto 0)     => DDR_dqs_n(3 downto 0),
        DDR_dqs_p(3 downto 0)     => DDR_dqs_p(3 downto 0),
        DDR_odt                   => DDR_odt,
        DDR_ras_n                 => DDR_ras_n,
        DDR_reset_n               => DDR_reset_n,
        DDR_we_n                  => DDR_we_n,
        FIXED_IO_ddr_vrn          => FIXED_IO_ddr_vrn,
        FIXED_IO_ddr_vrp          => FIXED_IO_ddr_vrp,
        FIXED_IO_mio(53 downto 0) => FIXED_IO_mio(53 downto 0),
        FIXED_IO_ps_clk           => FIXED_IO_ps_clk,
        FIXED_IO_ps_porb          => FIXED_IO_ps_porb,
        FIXED_IO_ps_srstb         => FIXED_IO_ps_srstb,
        sja1000_0_can_tx          => can_tx(CAN_SJA1000_0),
        sja1000_1_can_tx          => can_tx(CAN_SJA1000_1),
        ctu_can_fd_0_can_tx       => can_tx(CAN_CTUCANFD_0),
        ctu_can_fd_1_can_tx       => can_tx(CAN_CTUCANFD_1),
        sja1000_0_irq             => irqs(IRQ_SJA1000_0),
        sja1000_1_irq             => irqs(IRQ_SJA1000_1),
        ctu_can_fd_0_irq          => irqs(IRQ_CTUCANFD_0),
        ctu_can_fd_1_irq          => irqs(IRQ_CTUCANFD_1),
        FCLK_CLK0_0               => aclk,
        FCLK_RESET0_N_0           => arstn,
        IRQ_F2P                   => irq_f2p,
        LA_INP                    => la_inp,
        TIMESTAMP                 => timestamp,
        can_bus_tx                => can_bus_tx,
        can_bus_rx                => can_bus_rx,
        can_controller_tx         => can_controller_tx,
        can_controller_rx         => can_controller_rx
    );

    la_inp( 0) <= can_rx(CAN_SJA1000_0);
    la_inp( 1) <= can_rx(CAN_SJA1000_1);
    la_inp( 2) <= can_rx(CAN_CTUCANFD_0);
    la_inp( 3) <= can_rx(CAN_CTUCANFD_1);
    la_inp( 4) <= can_tx(CAN_SJA1000_0);
    la_inp( 5) <= can_tx(CAN_SJA1000_1);
    la_inp( 6) <= can_tx(CAN_CTUCANFD_0);
    la_inp( 7) <= can_tx(CAN_CTUCANFD_1);
    la_inp( 8) <= irqs(IRQ_CTUCANFD_0);
    la_inp( 9) <= irqs(IRQ_CTUCANFD_1);
    la_inp(10) <= irqs(IRQ_SJA1000_0);
    la_inp(11) <= irqs(IRQ_SJA1000_1);
    la_inp(la_inp'left downto 12) <= (others => '0');
end architecture;
