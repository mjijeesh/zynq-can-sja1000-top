library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display_16bit_cmd_data_bus_v1_0_io_fsm is
	generic (
		data_width	: integer	:= 32;
		lcd_io_width	: integer	:= 16;
		lcd_bus_clkdiv	: integer	:= 1
	);
	port (
		reset_in   	: in std_logic;

		clk_in   	: in std_logic;
		clk_en   	: in std_logic;

		lcd_res_n       : out std_logic;
		lcd_cs_n        : out std_logic;
		lcd_wr_n        : out std_logic;
		lcd_rd_n        : out std_logic;
		lcd_dc          : out std_logic;
		lcd_data	: inout std_logic_vector(lcd_io_width-1 downto 0);

		data_out	: in std_logic_vector(data_width-1 downto 0);
		dc_out		: in std_logic;

		trasfer_rq	: in std_logic;
		trasfer_rq_dbl	: in std_logic;
		ready_for_rq	: out std_logic
	);
end display_16bit_cmd_data_bus_v1_0_io_fsm;

architecture arch_imp of display_16bit_cmd_data_bus_v1_0_io_fsm is

	type	io_states	is (is_iddle, is_wrini, is_wr0, is_wr1,
			            is_wr2, is_wrfin);
	signal	io_state_r	: io_states;
	signal	trasfer_rq_dbl_r : std_logic;

	signal	div_cnt		: natural range 0 to lcd_bus_clkdiv-1;
	signal	data_out_r	: std_logic_vector(data_width-1 downto 0);
	signal	dc_out_r	: std_logic;

begin

	process is
	begin
	  wait until rising_edge (clk_in);
	  if ( reset_in = '1' ) then
	    div_cnt   <= lcd_bus_clkdiv-1;
	    ready_for_rq <= '0';
	    io_state_r  <= is_iddle;
	    lcd_res_n   <= '0';
	    lcd_cs_n    <= '1';
	    lcd_wr_n    <= '1';
	    lcd_rd_n    <= '1';
	    lcd_dc      <= '1';
	    lcd_data	<= (others => 'Z');
	  elsif (clk_en = '1') then
	    lcd_res_n  <= '1';
	    if trasfer_rq = '1' and io_state_r = is_iddle then
	      data_out_r  <= data_out;
	      dc_out_r  <= dc_out;
	      trasfer_rq_dbl_r <= trasfer_rq_dbl;
	      io_state_r  <= is_wrini;
	    end if;
	    if (div_cnt /= 0) then
	      div_cnt <= div_cnt - 1;
	    else
	      div_cnt   <= lcd_bus_clkdiv-1;
	      case io_state_r is

	      when is_iddle =>
	        if trasfer_rq = '1' then
	          ready_for_rq <= '0';
	          io_state_r <= is_wr0;
	          lcd_data   <= data_out(lcd_io_width-1 downto 0);
	          lcd_dc     <= dc_out;
	          lcd_cs_n   <= '0';
	          lcd_wr_n   <= '1';
	          lcd_rd_n   <= '1';
	        else
	          ready_for_rq <= '1';
	          lcd_data   <= (others => 'Z');
	          lcd_cs_n   <= '1';
	          lcd_wr_n   <= '1';
	          lcd_rd_n   <= '1';
	        end if;
	      when is_wrini =>
	        ready_for_rq <= '0';
	        io_state_r <= is_wr0;
	        lcd_data   <= data_out_r(lcd_io_width-1 downto 0);
	        lcd_dc     <= dc_out_r;
	        lcd_cs_n   <= '0';
	        lcd_wr_n   <= '1';
	        lcd_rd_n   <= '1';
	      when is_wr0 =>
	        ready_for_rq <= '0';
	        io_state_r <= is_wr1;
	        lcd_data   <= data_out_r(lcd_io_width-1 downto 0);
	        lcd_dc     <= dc_out_r;
	        lcd_cs_n   <= '0';
	        lcd_wr_n   <= '0';
	      when is_wr1 =>
	        ready_for_rq <= '0';
	        io_state_r <= is_wr2;
	        lcd_data   <= data_out_r(lcd_io_width-1 downto 0);
	        lcd_dc     <= dc_out_r;
	        lcd_cs_n   <= '0';
	        lcd_wr_n   <= '0';
	      when is_wr2 =>
	        ready_for_rq <= '0';
	        io_state_r <= is_wrfin;
	        lcd_data   <= data_out_r(lcd_io_width-1 downto 0);
	        lcd_dc     <= dc_out_r;
	        lcd_cs_n   <= '0';
	        lcd_wr_n   <= '1';
	      when is_wrfin =>
	        lcd_data   <= data_out_r(lcd_io_width-1 downto 0);
	        lcd_dc     <= dc_out_r;
	        if trasfer_rq_dbl_r = '1' then
	          ready_for_rq <= '0';
	          io_state_r <= is_wrini;
	          data_out_r(lcd_io_width-1 downto 0) <=
	               data_out_r(2 * lcd_io_width-1 downto lcd_io_width);
	          trasfer_rq_dbl_r <= '0';
	          lcd_cs_n   <= '0';
	          lcd_wr_n   <= '1';
	        else
	          ready_for_rq <= '1';
	          io_state_r <= is_iddle;
	          lcd_data     <= (others => 'Z');
	          lcd_cs_n   <= '0';
	          lcd_wr_n   <= '1';
	          lcd_cs_n   <= '0';
	          lcd_wr_n   <= '1';
	        end if;
	      end case;
	    end if;
	  end if;
	end process;

end arch_imp;
