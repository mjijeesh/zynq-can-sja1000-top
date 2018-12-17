library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library vunit_lib;
context vunit_lib.vunit_context;
library osvvm;
use osvvm.RandomPkg.all;

entity tb_can_crossbar is
    generic (
        runner_cfg : string
    );
end entity;

architecture tb of tb_can_crossbar is
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

    signal controller_rx        : std_logic_vector(7 downto 0);
    signal controller_tx        : std_logic_vector(7 downto 0);
    signal bus_rx               : std_logic_vector(3 downto 0);
    signal bus_tx               : std_logic_vector(3 downto 0);

    signal btx_expected         : std_logic_vector(bus_rx'range);
    signal crx_expected         : std_logic_vector(controller_rx'range);

    signal sel_controller_line  : std_logic_vector(15 downto 0);
    signal sel_bus_line         : std_logic_vector(7 downto 0);
    signal bus_oe               : std_logic_vector(3 downto 0);

    type sel_controller_t is array (0 to 7) of natural range 0 to 3;
    type sel_bus_t is array (0 to 3) of natural range 0 to 3;
    signal sel_controller : sel_controller_t;
    signal sel_bus : sel_bus_t;
begin
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
    g_ctrl: for i in sel_controller'range generate
        sel_controller_line((i+1)*2-1 downto i*2) <= std_logic_vector(to_unsigned(sel_controller(i), 2));
    end generate;
    g_bus: for i in sel_bus'range generate
        sel_bus_line((i+1)*2-1 downto i*2) <= std_logic_vector(to_unsigned(sel_bus(i), 2));
    end generate;

    p_main:process
        variable rnd : RandomPType;
        variable i : integer;
        variable ctx : std_logic_vector(controller_tx'range);
        variable brx : std_logic_vector(bus_rx'range);
    begin
        test_runner_setup(runner, runner_cfg);
        set_stop_level(failure);
        while test_suite loop
            if run("output enabled") then
                sel_controller <= (0, 1, 2, 3, 0, 1, 2, 3);
                sel_bus <= (0, 1, 2, 3);
                bus_oe <= (others => '1');
                for i in 0 to 10000 loop
                    ctx := rnd.RandSlv(ctx'length);
                    brx := rnd.RandSlv(brx'length);
                    controller_tx <= ctx;
                    bus_rx <= brx;
                    btx_expected <= ctx(3 downto 0) and ctx(7 downto 4);
                    crx_expected <= brx & brx;
                    wait for 10 ns;
                    check_equal(bus_tx, btx_expected);
                    check_equal(controller_rx, crx_expected);
                end loop;
            elsif run("output disabled") then
                sel_controller <= (0, 1, 2, 3, 0, 1, 2, 3);
                sel_bus <= (0, 1, 2, 3);
                bus_oe <= (others => '0');
                for i in 0 to 10000 loop
                    ctx := rnd.RandSlv(ctx'length);
                    brx := rnd.RandSlv(brx'length);
                    controller_tx <= ctx;
                    bus_rx <= brx;
                    btx_expected <= (others => '1');
                    crx_expected <= (ctx(3 downto 0) and ctx(7 downto 4)) & (ctx(3 downto 0) and ctx(7 downto 4));
                    wait for 10 ns;
                    check_equal(bus_tx, btx_expected);
                    check_equal(controller_rx, crx_expected);
                end loop;
            end if;
        end loop;
        test_runner_cleanup(runner, false);
    end process;
end architecture;
