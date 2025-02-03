library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity frequency_upsampler is
	generic(N: in integer);
	port(	clk: in std_logic;
		rst: in std_logic;
		sclk: in std_logic;
		upsample_freq: out std_logic
		);
end frequency_upsampler;

architecture beh of frequency_upsampler is

signal upsampling_freq: std_logic;
signal count: integer := 0;

begin

	count_process: process(clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				count <= 0;
			elsif sclk = '1' then
				count <= 0;
			elsif count = N then
				count <= 0;
			else 
				count <= count + 1;
			end if;
		end if;
	end process;

	with count select
		upsampling_freq <= 	'1' when N, --1130
					'0' when others;
	
	upsample_freq <= upsampling_freq;

end architecture;
