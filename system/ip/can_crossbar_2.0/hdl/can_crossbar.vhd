library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity can_crossbar_apb is
    port (
        aclk                 : in  std_logic;
        arstn                : in  std_logic;

        controller_rx        : out std_logic_vector(7 downto 0);
        controller_tx        : in  std_logic_vector(7 downto 0);
        bus_rx               : in  std_logic_vector(3 downto 0);
        bus_tx               : out std_logic_vector(3 downto 0);

        s_apb_paddr          : in  std_logic_vector(31 downto 0);
        s_apb_penable        : in  std_logic;
        s_apb_pprot          : in  std_logic_vector(2 downto 0);
        s_apb_prdata         : out std_logic_vector(31 downto 0);
        s_apb_pready         : out std_logic;
        s_apb_psel           : in  std_logic;
        s_apb_pslverr        : out std_logic;
        s_apb_pstrb          : in  std_logic_vector(3 downto 0);
        s_apb_pwdata         : in  std_logic_vector(31 downto 0);
        s_apb_pwrite         : in  std_logic
    );
end entity;

architecture rtl of can_crossbar_apb is
    component can_crossbar is
        generic (
            NCONTROLLERS : natural;
            LOG_NLINES : natural;
            NBUSES : natural
        );
        port (
            controller_rx       : out std_logic_vector(NCONTROLLERS-1 downto 0);
            controller_tx       : in  std_logic_vector(NCONTROLLERS-1 downto 0);
            bus_rx              : in  std_logic_vector(NBUSES-1 downto 0);
            bus_tx              : out std_logic_vector(NBUSES-1 downto 0);

            sel_controller_line : in std_logic_vector(NCONTROLLERS*LOG_NLINES-1 downto 0);
            sel_bus_line        : in std_logic_vector(NBUSES*LOG_NLINES-1 downto 0);
            bus_oe              : in std_logic_vector(NBUSES-1 downto 0)
        );
    end component;

    signal sel_controller_line : std_logic_vector(15 downto 0);
    signal sel_bus_line : std_logic_vector(7 downto 0);
    signal bus_oe : std_logic_vector(3 downto 0);
    -- End of crossbar

    signal slv_reg0  : std_logic_vector(31 downto 0);

    signal reg_addr  : std_logic_vector(7 downto 0);
    signal apb_prdata_reg         : std_logic_vector(31 downto 0);
    signal apb_pslverr_reg        : std_logic;

    function apply_be(constant reg      : in  std_logic_vector(31 downto 0);
                      constant wrsignal : in  std_logic_vector(31 downto 0);
                      constant be       : in  std_logic_vector(3 downto 0))
                      return std_logic_vector is
        variable res : std_logic_vector(31 downto 0);
    begin
        res := reg;
        for i in be'range loop
            if be(i) = '1' then
                res((i+1)*8-1 downto i*8) := wrsignal((i+1)*8-1 downto i*8);
            end if;
        end loop;
        return res;
    end function apply_be;
begin
    s_apb_prdata  <= apb_prdata_reg;
    s_apb_pslverr <= apb_pslverr_reg;
    s_apb_pready  <= '1';

    apb_pslverr_reg <= '0';

    -- aligned
    reg_addr <= s_apb_paddr(reg_addr'left+2 downto 2);

    p_write:process(aclk, arstn)
    begin
        if arstn = '0' then
            slv_reg0 <= (others => '0');
        elsif rising_edge(aclk) then
            if s_apb_psel = '1' and s_apb_penable = '0' and s_apb_pwrite = '1' then
                case reg_addr is
                    when x"00" => slv_reg0 <= apply_be(slv_reg0, s_apb_pwdata, s_apb_pstrb);
                    when others =>  --set error?
                end case;
            end if;
        end if;
    end process;

    p_read:process(aclk, arstn)
    begin
        if arstn = '0' then
            apb_prdata_reg <= (others => '0');
        elsif rising_edge(aclk) then
            if s_apb_psel = '1' and s_apb_penable = '0' and s_apb_pwrite = '0' then
                case reg_addr is
                    when x"00" => apb_prdata_reg <= slv_reg0;
                    when others=> apb_prdata_reg <= (others => '0'); --set error?
                end case;
            end if;
        end if;
    end process;

    -- instance
    sel_controller_line <= slv_reg0(15 downto 0);
    sel_bus_line        <= slv_reg0(23 downto 16);
    bus_oe              <= slv_reg0(27 downto 24);

    i_xbar: can_crossbar
        generic map (
            LOG_NLINES => 2,
            NCONTROLLERS => 8,
            NBUSES => 4
        )
        port map (
            controller_rx => controller_rx,
            controller_tx => controller_tx,
            bus_rx => bus_rx,
            bus_tx => bus_tx,
            sel_controller_line => sel_controller_line,
            sel_bus_line => sel_bus_line,
            bus_oe => bus_oe
        );
end architecture rtl;
