--
-- * motion-control PWM *
--  PWM controller with failsafe input
--
-- part of LXPWR motion control board (c) PiKRON Ltd
-- idea by Pavel Pisa PiKRON Ltd <ppisa@pikron.com>
-- code by Marek Peca <hefaistos@gmail.com>
-- 01/2013
--
-- license: GNU LGPL and GPLv3+
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mcpwm is
  generic (
    pwm_width: natural := 12
  );
  port (
    -- reset: in std_logic;
    clock: in std_logic;
    sync: in std_logic; --flag that counter "restarts-overflows"
    data_valid:in std_logic; --indicates data is consistent
    failsafe: in std_logic; --failmode turn off both transistors
    en_p, en_n: in std_logic; --enable positive & enable inverse
    match: in std_logic_vector (pwm_width-1 downto 0); --posion of counter when we swap output logic
    count: in std_logic_vector (pwm_width-1 downto 0); --do we use external counter?
    
    out_p, out_n: out std_logic --pwm outputs
  );
end mcpwm;

architecture behavioral of mcpwm is
  signal match_reg, next_match_reg: std_logic_vector (match'range);
  signal en_p_reg, en_n_reg : std_logic;  --enable positive + inverse output
  signal next_en_p_reg, next_en_n_reg: std_logic; --enable - next value
  signal q, next_q: std_logic; --logic value(level) of output
begin

 -- setting the output (q holds the logic value)
  out_p <= q and en_p_reg and not failsafe; 
  -- out_n <= not q and en_n_reg and not failsafe; --Use this line when using "not inteligent" half-H bridge
  out_n <= en_n_reg or failsafe; --switch off both transistors. Use this line when "inteligent" half-H bridge is at use
  
  --set next values - use old or new values
  reg: process (data_valid, failsafe, match, match_reg,
                en_p, en_n, en_p_reg, en_n_reg)
  begin
  --when theres no new data & failsafe is unset - use old values
    next_match_reg <= match_reg;
    next_en_p_reg <= en_p_reg;
    next_en_n_reg <= en_n_reg;
    
    --when failsafe is set disable both directions
    if failsafe = '1' then --
      --
      -- little paranoia, costs nothing
      --
      next_en_p_reg <= '0';
      next_en_n_reg <= '0';
      --if theres no failsafe flag & data is valid, we can set next values
    elsif data_valid = '1' then
      next_match_reg <= match;
      next_en_p_reg <= en_p;
      next_en_n_reg <= en_n;
    end if;
  end process;

  --swaping output logic when counter counts to match
  rs: process (sync, count, match_reg, q) 		--if theres event on sync(the counter "restarts") or count 
  begin
    if count = match_reg then 		--when the counter counts to match, we swap the signals (~middle of duty cycle)
      next_q <= '0';
    elsif sync = '1' then 			--syncing signal (start of duty cycle)
      next_q <= '1';
    else
      next_q <= q;
    end if;
  end process;

  seq: process
  begin
  --set actual -> shift next registers
    wait until clock'event and clock = '1';
    match_reg <= next_match_reg;
    en_p_reg <= next_en_p_reg;
    en_n_reg <= next_en_n_reg;
    q <= next_q;
  end process;
end behavioral;
