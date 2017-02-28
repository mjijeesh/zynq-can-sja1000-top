--
-- * Raspberry Pi BLDC/PMSM motor control design for RPi-MI-1 board *
-- SPI connected multichannel current ADC read and averaging
--
-- (c) 2015 Martin Prudek <prudemar@fel.cvut.cz>
-- Czech Technical University in Prague
--
-- Project supervision and original project idea
-- idea by Pavel Pisa <pisa@cmp.felk.cvut.cz>
--
-- Related RPi-MI-1 hardware is designed by Petr Porazil,
-- PiKRON Ltd  <http://www.pikron.com>
--
-- license: GNU LGPL and GPLv3+
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc_reader is
port (
	clk: in std_logic;					--synchronous master clk
	divided_clk : in std_logic;				--divided clk - value suitable to sourcing voltage
	adc_reset: in std_logic;				--synchronous reset on rising edge
	
	adc_miso: in std_logic;					--spi master in slave out
	adc_sclk: out std_logic; 				--spi clk
	adc_scs: out std_logic;					--spi slave select
	adc_mosi: out std_logic;				--spi master out slave in
	
	adc_channels: out std_logic_vector (71 downto 0);	--consistent data of 3 channels
	measur_count: out std_logic_vector(8 downto 0)		--number of accumulated measurments
	
);
end adc_reader;


architecture behavioral of adc_reader is
	
	
	type state_type is (f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12,f13,f14,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,f15,r15,reset,rst_wait);
	signal state : state_type;
	
	type channel_type is (ch0, ch1, ch2);
	
	signal adc_data: std_logic_vector(11 downto 0); 
	signal adc_rst_prev : std_logic;
	signal adc_address: std_logic_vector(2 downto 0);
	signal cumul_data: std_logic_vector(71 downto 0);	--unconsistent data, containing different amounts of measurments
	signal prepared_data: std_logic_vector(71 downto 0);	--consistent data, waiting for clk sync to propagate to output
	signal m_count_sig: std_logic_vector(8 downto 0);	--measurments count waiting for clk to propagate to output
	signal first_pass: std_logic;
begin
	
	
	process 
		variable channel: channel_type;
		variable reset_re: std_logic:='0';
		variable reset_count: std_logic_vector (3 downto 0);
	begin
		wait until (clk'event and clk='1');
		
		--rising edge detection of reset signal
		adc_rst_prev<=adc_reset;
		if (adc_rst_prev='0') and (adc_reset='1') then
			reset_re:='1';
		end if;
		
		if (divided_clk='1') then --instead of divide, single puls is now detected
		
		case state is
			when reset=>
				reset_re:='0'; 			--clear reset flag
				adc_scs<='1'; 			--active-low SS
				adc_sclk<='0'; 			--lower clock
				first_pass<='1'; 		--mark data as unprepared
				channel:=ch0;			--prepare channel0
				adc_data<=(others=>'0');	--null working data
				cumul_data<=(others=>'0');	--null working data
				prepared_data<=(others=>'0');	--null the output
				adc_channels<=(others=>'0');	--null the output
				measur_count<=(others=>'0');	--null the count
				m_count_sig<=(others=>'0');	--null the count
				adc_address<="001";		--set its address
				reset_count:="0000";
				state<=rst_wait;
			when rst_wait=>
				if (reset_count/="1111") then
					reset_count:=std_logic_vector(unsigned(reset_count)+1);
					--give the adc some time to prepare before transfer
					adc_scs<=not reset_count(3); 
				else
					state<=f1;
				end if;
			when f1=> --1st 'fallin edge' - its not falling edge in any case-if rst clock is low before  
				adc_sclk<='0'; --clk
				adc_mosi<='1'; --start bit
				state<=r1; --next state
			when r1=> 	--1st rising edge (adc gets the start bit, we get date..)
				adc_sclk<='1'; 
				adc_data(5)<=adc_miso;
				state<=f2;
			when f2=> --2nd falling edge
				adc_sclk<='0';
				adc_mosi<=adc_address(2); --A2 address
				state<=r2;
			when r2=> --2nd rising edge (adc gets A2 address)
				adc_sclk<='1';
				adc_data(4)<=adc_miso;
				state<=f3;
			when f3=> --3rd falling edge 
				adc_sclk<='0';
				adc_mosi<=adc_address(1); --A1 address
				state<=r3;
			when r3=> --rising edge
				adc_sclk<='1';
				adc_data(3)<=adc_miso;
				state<=f4;	
			when f4=> --4th falling edge
				adc_sclk<='0';
				adc_mosi<=adc_address(0); --A0 address 
				state<=r4;
			when r4=> --rising edge
				adc_sclk<='1';
				adc_data(2)<=adc_miso;
				state<=f5;	
			when f5=> --5th falling edge
				adc_sclk<='0';
				adc_mosi<='0'; --MODE (LOW -12bit)
				state<=r5;
			when r5=> --rising edge
				adc_sclk<='1';
				adc_data(1)<=adc_miso;
				state<=f6;	
			when f6=> --6th falling edge
				adc_sclk<='0';
				adc_mosi<='1'; --SGL/DIF (HIGH - SGL=Single Ended)
				state<=r6;
			when r6=> --6th rising edge (we read last bit of conversion, adc gets SGL/DIF)
				adc_sclk<='1';
				adc_data(0)<=adc_miso;
				state<=f7;		
			when f7=> -- 7th falling edge
				adc_sclk<='0';
				adc_mosi<='0'; --PD1 (power down - PD1=PD0=0 -> power down between conversion)
				state<=r7;
			when r7=> --7th rising edge, data ready
				adc_sclk<='1';
				if (first_pass='0') then
					--add the current current to sum and shift the register
					cumul_data(71 downto 0)<=
						std_logic_vector(unsigned(cumul_data(47 downto 24))
							+unsigned(adc_data(11 downto 0)))
						& cumul_data(23 downto 0)
						& cumul_data(71 downto 48);
				end if;
				state<=f8;
			when f8=> --8th falling edge
				adc_sclk<='0';
				adc_mosi<='0'; --PD0
				if (first_pass='0') then
					case channel is
						when ch0=>
							adc_address<="101";	--ch1 address
							channel:=ch1;		--next channel code
						when ch1=>
							adc_address<="010";	--ch2 address
							channel:=ch2;		--next channel code
						when ch2=>
							--data order schould be: ch2 downto ch0 downto ch1
							prepared_data(71 downto 0)<=cumul_data(71 downto 0);
							m_count_sig<=std_logic_vector(unsigned(m_count_sig)+1);
							adc_address<="001";	--ch0 address
							channel:=ch0;		--next channel code
					end case;
				end if;
				state<=r8;
			when r8=> --8th rising edge (adc gets PD0), we propagate our results to output
				adc_sclk<='1';
				adc_channels <= prepared_data;		--data
				measur_count <= m_count_sig;		--count of measurments
				first_pass<='0';			--data in next cycle are usable
				state<=f9;
			when f9=> --9th falling edge busy state between conversion (we write nothing)
				adc_sclk<='0';
				state<=r9;
			when r9=>  --9th rising edge (we nor ads get nothing)
				adc_sclk<='1';
				state<=f10;
			when f10=> --10th falling edge
				adc_sclk<='0';
				state<=r10;
			when r10=>  --10th rising edge (we read 1. bit of new conversion)
				adc_sclk<='1';
				adc_data(11)<=adc_miso;
				state<=f11;
			when f11=>
				adc_sclk<='0';
				state<=r11;
			when r11=>  --11th rising edge
				adc_sclk<='1';
				adc_data(10)<=adc_miso;
				state<=f12;
			when f12=>
				adc_sclk<='0';
				state<=r12;
			when r12=>  --12th rising edge
				adc_sclk<='1';
				adc_data(9)<=adc_miso;
				state<=f13;
			when f13=>
				adc_sclk<='0';
				state<=r13;
			when r13=>  --13th rising edge
				adc_sclk<='1';
				adc_data(8)<=adc_miso;
				state<=f14;
			when f14=>
				adc_sclk<='0';
				state<=r14;
			when r14=>  --14th rising edge
				adc_sclk<='1';
				adc_data(7)<=adc_miso;
				state<=f15;
			when f15=>
				adc_sclk<='0';
				state<=r15;
			when r15=> --15th rising edge
				adc_sclk<='1';
				adc_data(6)<=adc_miso;
				if (reset_re='1') then --we check rising edge of reset 
					state<=reset;
				else
					state<=f1;
				end if;
		end case;
		
		end if;
		
	end process;
			
	
		
end behavioral;

