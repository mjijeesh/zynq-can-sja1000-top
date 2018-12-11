library ieee;
use ieee.std_logic_1164.all;

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
        FPGA_IO_A : inout STD_LOGIC_VECTOR ( 10 downto 1 );
        FPGA_IO_B : inout STD_LOGIC_VECTOR ( 28 downto 13 );
        FPGA_IO_C : inout STD_LOGIC_VECTOR ( 40 downto 31 )
    );
end entity;

architecture structure of top_hdl is
    component CTU_CAN_FD_v1_0 is
        generic(
            use_logger       : boolean                := true;
            rx_buffer_size   : natural range 4 to 512 := 128;
            use_sync         : boolean                := true;
            sup_filtA        : boolean                := true;
            sup_filtB        : boolean                := true;
            sup_filtC        : boolean                := true;
            sup_range        : boolean                := true;
            logger_size      : natural range 0 to 512 := 8
        );
        port(
            aclk             : in  std_logic;
            arstn            : in  std_logic;

            irq              : out std_logic;
            CAN_tx           : out std_logic;
            CAN_rx           : in  std_logic;
            time_quanta_clk  : out std_logic;
            timestamp        : in std_logic_vector(63 downto 0);

            -- Ports of APB4
            s_apb_paddr      : in  std_logic_vector(31 downto 0);
            s_apb_penable    : in  std_logic;
            s_apb_pprot      : in  std_logic_vector(2 downto 0);
            s_apb_prdata     : out std_logic_vector(31 downto 0);
            s_apb_pready     : out std_logic;
            s_apb_psel       : in  std_logic;
            s_apb_pslverr    : out std_logic;
            s_apb_pstrb      : in  std_logic_vector(3 downto 0);
            s_apb_pwdata     : in  std_logic_vector(31 downto 0);
            s_apb_pwrite     : in  std_logic
      );
    end component CTU_CAN_FD_v1_0;

    component sja1000 is
        port(
            can_rx        : in  std_logic;
            can_tx        : out std_logic;
            bus_off_on    : out std_logic;

            aclk          : in  std_logic;
            arstn         : in  std_logic;

            s_apb_paddr   : in  std_logic_vector(31 downto 0);
            s_apb_penable : in  std_logic;
            s_apb_pprot   : in  std_logic_vector(2 downto 0);
            s_apb_prdata  : out std_logic_vector(31 downto 0);
            s_apb_pready  : out std_logic;
            s_apb_psel    : in  std_logic;
            s_apb_pslverr : out std_logic;
            s_apb_pstrb   : in  std_logic_vector(3 downto 0);
            s_apb_pwdata  : in  std_logic_vector(31 downto 0);
            s_apb_pwrite  : in  std_logic;

            irq           : out std_logic
        );
    end component;

    component zlogan_capt_v1_0 is
        generic(
            la_n_inp: natural := 4; -- number of input wires
            la_b_out: natural := 4; -- output FIFO width (4 or 8 [bytes])
            C_M00_AXIS_TDATA_WIDTH  : integer  := 32;
            C_M00_AXIS_START_COUNT  : integer  := 32
        );
        port(
            la_inp               : in std_logic_vector (la_n_inp-1 downto 0);

            fifo_data_count_i    : in std_logic_vector(31 downto 0);
            fifo_wr_data_count_i : in std_logic_vector(31 downto 0);
            fifo_rd_data_count_i : in std_logic_vector(31 downto 0);

            fifo_reset_n         : out std_logic;

            timestamp            : in  std_logic_vector(C_M00_AXIS_TDATA_WIDTH-1 downto 0);

            -- Ports of APB Interface
            aclk                 : in  std_logic;
            arstn                : in  std_logic;
            s_apb_paddr          : in  std_logic_vector(31 downto 0);
            s_apb_penable        : in  std_logic;
            s_apb_pprot          : in  std_logic_vector(2 downto 0);
            s_apb_prdata         : out std_logic_vector(31 downto 0);
            s_apb_pready         : out std_logic;
            s_apb_psel           : in  std_logic;
            s_apb_pslverr        : out std_logic;
            s_apb_pstrb          : in  std_logic_vector(3 downto 0);
            s_apb_pwdata         : in  std_logic_vector(31 downto 0);
            s_apb_pwrite         : in  std_logic;

            -- Ports of Axi Master Bus Interface M00_AXIS
            m00_axis_aclk        : in std_logic;
            m00_axis_aresetn     : in std_logic;
            m00_axis_tvalid      : out std_logic;
            m00_axis_tdata       : out std_logic_vector(C_M00_AXIS_TDATA_WIDTH-1 downto 0);
            m00_axis_tstrb       : out std_logic_vector((C_M00_AXIS_TDATA_WIDTH/8)-1 downto 0);
            m00_axis_tlast       : out std_logic;
            m00_axis_tready      : in std_logic
        );
    end component zlogan_capt_v1_0;

    -- vivado is a bitch and generates a vector of (0 downto 0) instead of plain std_logic
    type apb_t is record
        paddr   : std_logic_vector(31 downto 0);   -- in
        penable : std_logic;                       -- in
        pprot   : std_logic_vector(2 downto 0);    -- in
        prdata  : std_logic_vector(31 downto 0);   -- out
        pready  : std_logic_vector(0 downto 0);    -- out
        psel    : std_logic_vector(0 downto 0);    -- in
        pslverr : std_logic_vector(0 downto 0);    -- out
        pstrb   : std_logic_vector(3 downto 0);    -- in
        pwdata  : std_logic_vector(31 downto 0);   -- in
        pwrite  : std_logic;                       -- in
    end record;

    -- this retarded order is kept for backward compatibility with device tree
    type irqs_e is (
        IRQ_SJA1000_0,
        IRQ_CTUCANFD_0,
        IRQ_CTUCANFD_1,
        IRQ_SJA1000_1
    );

    type apbs_e is (
        APB_CTUCANFD_0,
        APB_CTUCANFD_1,
        APB_SJA1000_0,
        APB_SJA1000_1,
        APB_ZLOGAN
    );

    type can_e is (
        CAN_CTUCANFD_0,
        CAN_CTUCANFD_1,
        CAN_SJA1000_0,
        CAN_SJA1000_1
    );

    type apb_arr_t is array(apbs_e) of apb_t;
    type irq_arr_t is array(irqs_e) of std_logic;
    type can_tx_arr_t is array(can_e) of std_logic;

    --signal apbs : apb_arr_t;
    signal can_tx : can_tx_arr_t;
    signal can_rx : std_logic;
    signal irqs : irq_arr_t;
    signal aclk : std_logic;
    signal arstn : std_logic;
    signal timestamp : std_logic_vector(63 downto 0);

    signal la_inp : std_logic_vector(31 downto 0);
    signal irq_f2p : std_logic_vector(3 downto 0);
begin
    can_rx <= and(std_logic_vector(can_tx));

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
        FPGA_IO_A(10 downto 1)    => FPGA_IO_A(10 downto 1),
        FPGA_IO_B(28 downto 13)   => FPGA_IO_B(28 downto 13),
        FPGA_IO_C(40 downto 31)   => FPGA_IO_C(40 downto 31),
        can_rx                    => can_rx,
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
        TIMESTAMP                 => timestamp
    );

    la_inp(0) <= can_rx;
    la_inp(1) <= can_tx(CAN_SJA1000_0);
    la_inp(2) <= can_tx(CAN_SJA1000_1);
    la_inp(3) <= can_tx(CAN_CTUCANFD_0);
    la_inp(4) <= can_tx(CAN_CTUCANFD_1);
    la_inp(5) <= irqs(IRQ_CTUCANFD_0);
    la_inp(6) <= irqs(IRQ_CTUCANFD_1);
    la_inp(7) <= irqs(IRQ_SJA1000_0);
    la_inp(8) <= irqs(IRQ_SJA1000_1);
    la_inp(la_inp'left downto 9) <= (others => '0');
end architecture;
