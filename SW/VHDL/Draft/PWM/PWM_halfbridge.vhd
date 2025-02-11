library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PWM_halfbridge is
	generic(size_audio_in: integer;
		size_timer: integer;
		deadtime_delay: integer
		);
	port(	clk: in std_logic;
		rst: in std_logic;
		sample_in: in std_logic;
		data_in: in signed(size_audio_in-1 downto 0);
		pwm_p_out: out std_logic;
		pwm_n_out: out std_logic
		);
end PWM_halfbridge;

architecture beh of PWM_halfbridge is

signal timer_pwm: std_logic_vector(size_timer-1 downto 0);

signal offset_datain: signed(size_audio_in-1 downto 0);

signal count: std_logic_vector(size_timer-1 downto 0);

signal deadtime_flag: std_logic;

signal pwm_cntflag: std_logic;

signal pwm_p: std_logic;

signal pwm_n: std_logic;

signal count_delay: integer;

type FSM is (S1, S2, S3, S4, idle);
signal PWM_FSM: FSM := S1;

begin

	offset_datain <= data_in + "0111111111111111";
	
	timer_pwm <= std_logic_vector(offset_datain(size_audio_in-1 downto size_audio_in-size_timer));
	
	FSM_process: process(clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				PWM_FSM <= idle;
			else
				if sample_in = '1' then
					PWM_FSM <= S1;
				elsif PWM_FSM = S1 and deadtime_flag = '1' then
					PWM_FSM <= S2;
				elsif PWM_FSM = S2 and pwm_cntflag = '1' then
					PWM_FSM <= S3;
				elsif PWM_FSM = S3 and deadtime_flag = '1' then
					PWM_FSM <= S4;
				end if;
			end if;
		end if;
	end process;
	
	deadtime_delay_process: process(clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				count_delay <= 0;
			elsif count_delay = deadtime_delay then
				deadtime_flag <= '1';
				count_delay <= 0;
			elsif (PWM_FSM = S1 or PWM_FSM = S3) and (count_delay < deadtime_delay) then
				count_delay <= count_delay + 1;
			else 
				deadtime_flag <= '0';
			end if;
		end if;
	end process;
	
	pwm_p_process: process(clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				count <= (others => '0');
				pwm_p <= '0';
				pwm_cntflag <= '0';
			elsif PWM_FSM = S2 then
				pwm_p <= '1';
				if count = timer_pwm then
					pwm_cntflag <= '1';
					count <= (others => '0');
				elsif count < timer_pwm then
					count <= count + 1;
					pwm_cntflag <= '0';
				end if;
			else
				pwm_p <= '0';
				pwm_cntflag <= '0';
			end if;
		end if;
	end process;

	pwm_n_process: process(clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				pwm_n <= '0';
			elsif PWM_FSM = S4 then
				pwm_n <= '1';
			else 
				pwm_n <= '0';
			end if;
		end if;
	end process;
	
	pwm_p_out <= pwm_p;
	pwm_n_out <= pwm_n;
	
end beh;
