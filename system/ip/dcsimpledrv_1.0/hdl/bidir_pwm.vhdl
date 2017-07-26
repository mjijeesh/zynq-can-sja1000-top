--
-- * Simple PWM generator for bidirectional DC motor control *
-- The comparisons are not optimized from inequality
-- to simple match to allow asynchronous period and duty
-- changes without need to wait for previously exhaustive
-- set period to finish

-- (c) 2017 Pavel Pisa <pisa@cmp.felk.cvut.cz>
--
-- license: BSD
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bidir_pwm is
generic (
    pwm_width: integer := 30
);
port (
    clock: in std_logic;
    reset: in std_logic;
    pwm_period: in std_logic_vector (pwm_width - 1 downto 0);
    pwm_duty: in std_logic_vector (pwm_width - 1 downto 0);
    dir_a, dir_b: in std_logic;
    pwm_a, pwm_b: out std_logic
);
end bidir_pwm;

architecture behavioral of bidir_pwm is
    signal cnt_val_s : natural range 0 to (2**pwm_width - 1);
    signal cnt_val_r : natural range 0 to (2**pwm_width - 1);

    signal pwm_a_gen_s : std_logic;
    signal pwm_a_gen_r : std_logic;
    signal pwm_b_gen_s : std_logic;
    signal pwm_b_gen_r : std_logic;
begin

comb: process (reset, cnt_val_r, pwm_a_gen_r, pwm_b_gen_r, dir_a, dir_b, pwm_period, pwm_duty)
    begin
        if reset = '1' then
            cnt_val_s <= 0;
            pwm_a_gen_s <= '0';
            pwm_b_gen_s <= '0';
        else
            if cnt_val_r + 1 >= to_integer(unsigned(pwm_period)) then
                cnt_val_s <= 0;
            else
                cnt_val_s <= cnt_val_r + 1;
            end if;

            if to_integer(unsigned(pwm_duty)) <= cnt_val_r then
                pwm_a_gen_s <= '0';
                pwm_b_gen_s <= '0';
            elsif cnt_val_r = 0 then
                pwm_a_gen_s <= dir_a;
                pwm_b_gen_s <= dir_b;
            else
                pwm_a_gen_s <= pwm_a_gen_r and dir_a;
                pwm_b_gen_s <= pwm_b_gen_r and dir_b;
            end if;
        end if;
    end process;

seq: process
    begin
        wait until clock'event and clock = '1';
        cnt_val_r <= cnt_val_s;
        pwm_a_gen_r <= pwm_a_gen_s;
        pwm_b_gen_r <= pwm_b_gen_s;
    end process;

    pwm_a <= pwm_a_gen_r and not reset;
    pwm_b <= pwm_b_gen_r and not reset;

end behavioral;
