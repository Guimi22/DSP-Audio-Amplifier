library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PWM_unit is
	generic(size_audio_in: integer;
		size_timer: integer);
	port(	clk: in std_logic;
		rst: in std_logic;
		sample_in: in std_logic;
		data_in: in std_logic_vector(size_audio_in-1 downto 0);
		pwm_out: out std_logic
		);
end PWM_unit;

architecture beh of PWM_unit is

signal timer_pwm: std_logic_vector(size_timer-1 downto 0);
signal offset_datain: std_logic_vector(size_audio_in-1 downto 0);
signal data_in_unsign: std_logic_vector(size_audio_in-1 downto 0);
signal count: std_logic_vector(size_timer-1 downto 0);
signal pwm_out_signal: std_logic;

begin

	offset_datain(size_audio_in-1) <= '0';
	
	offset_for: for i in 0 to size_audio_in-2 generate
		offset_datain(i) <= '1';
	end generate offset_for;

	data_in_unsign <= data_in + offset_datain;
	
	timer_pwm <= data_in_unsign(size_audio_in-1 downto size_audio_in-size_timer);
	
	pwm_unit: process(clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				count <= (others => '0');
				pwm_out_signal <= '0';
			elsif sample_in = '1' then
				count <= (others => '0');
				pwm_out_signal <= '1';
			elsif count = timer_pwm and sample_in = '0' then
				count <= (others => '0');
				pwm_out_signal <= '0'; 
			elsif count < timer_pwm and pwm_out_signal = '1' and sample_in = '0' then
				count <= count + 1;
			end if;
		end if;
	end process;

	pwm_out <= pwm_out_signal;
	
end beh;
	
	