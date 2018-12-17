library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package helpers is
	function sll_int(a : natural; b : natural) return natural;
end package;

package body helpers is
	function sll_int(a : natural; b : natural) return natural is
	    variable res : natural;
	    variable i : natural;
	begin
		res := a;
		for i in 0 to b-1 loop
		    res := res * 2;
		end loop;
		return res;
	end function;
end package body;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.helpers.all;

entity demux is
    generic(
        BITS    : natural;
        DEFVAL : std_logic
    );
    port (
        sel     : in std_logic_vector(BITS-1 downto 0);
        din     : in std_logic;
        dout    : out std_logic_vector(sll_int(1, BITS)-1 downto 0)
    );
end entity;

architecture rtl of demux is
begin
    p_demux: process(sel, din)
    begin
        dout <= (others => DEFVAL);
        dout(to_integer(unsigned(sel))) <= din;
    end process;
end architecture;
-- -----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.helpers.all;

entity mux is
    generic(
        BITS : natural
    );
    port (
        sel  : in std_logic_vector(BITS-1 downto 0);
        din  : in std_logic_vector(sll_int(1, BITS)-1 downto 0);
        dout : out std_logic
    );
end entity;

architecture rtl of mux is
begin
    dout <= din(to_integer(unsigned(sel)));
end architecture;
-- -----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.helpers.all;

entity simplex_crossbar is
    generic (
        NSRC       : natural;
        LOG_NLINES : natural;
        NDST       : natural
    );
    port (
        src          : in  std_logic_vector(NSRC-1 downto 0);
        dst          : out std_logic_vector(NDST-1 downto 0);

        sel_src_line : in std_logic_vector(NSRC*LOG_NLINES-1 downto 0);
        sel_dst_line : in std_logic_vector(NDST*LOG_NLINES-1 downto 0)
    );
end entity;

architecture rtl of simplex_crossbar is
    constant NLINES : natural := sll_int(1, LOG_NLINES);
    signal lines : std_logic_vector(NLINES-1 downto 0);

    type onehot_arr_t is array(0 to NSRC-1) of std_logic_vector(NLINES-1 downto 0);
    signal onehot : onehot_arr_t;
begin
    gsrc: for i in 0 to NSRC-1 generate
        i_src_demux: entity work.demux
            generic map(
                BITS => LOG_NLINES,
                DEFVAL => '1'
            )
            port map (
                din => src(i),
                dout => onehot(i),
                sel => sel_src_line((i+1)*LOG_NLINES-1 downto i*LOG_NLINES)
            );
    end generate;

    psrcand: process(onehot)
        variable tmp : std_logic;
    begin
        for iline in 0 to NLINES-1 loop
            tmp := '1';
            for isrc in 0 to NSRC-1 loop
                tmp := tmp and onehot(isrc)(iline);
            end loop;
            lines(iline) <= tmp;
        end loop;
    end process;

    gdst: for i in 0 to NDST-1 generate
        i_dst_mux: entity work.mux
            generic map(
                BITS => LOG_NLINES
            )
            port map (
                din => lines,
                dout => dst(i),
                sel => sel_dst_line((i+1)*LOG_NLINES-1 downto i*LOG_NLINES)
            );
    end generate;
end architecture;
-- -----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity can_crossbar is
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
end entity;

architecture rtl of can_crossbar is
    signal int_bus_rx       : std_logic_vector(NBUSES-1 downto 0);
    signal int_bus_tx       : std_logic_vector(NBUSES-1 downto 0);
begin
    i_rx: entity work.simplex_crossbar
        generic map (
            NSRC => NBUSES,
            NDST => NCONTROLLERS,
            LOG_NLINES => LOG_NLINES
        )
        port map (
            src => int_bus_rx,
            dst => controller_rx,
            sel_src_line => sel_bus_line,
            sel_dst_line => sel_controller_line
        );
    i_tx: entity work.simplex_crossbar
        generic map (
            NSRC => NCONTROLLERS,
            NDST => NBUSES,
            LOG_NLINES => LOG_NLINES
        )
        port map (
            src => controller_tx,
            dst => int_bus_tx,
            sel_src_line => sel_controller_line,
            sel_dst_line => sel_bus_line
        );

    g_oe: for i in 0 to NBUSES-1 generate
        int_bus_rx(i) <= bus_rx(i) when bus_oe(i) = '1' else int_bus_tx(i);
        bus_tx(i) <= int_bus_tx(i) when bus_oe(i) = '1' else '1';
    end generate;
end architecture;
