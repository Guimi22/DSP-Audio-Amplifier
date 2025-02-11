library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity upsampler_frequency_2x is
	generic( module: integer := 2
		);
	port(	clk: in std_logic;
		rst: in std_logic;
		sclk_flag: in std_logic;
		fs_up1 : out std_logic := '0';
		fs_up2 : out std_logic := '0';
		fs_up3 : out std_logic := '0';
		fs_up4 : out std_logic := '0';
		fs_up5 : out std_logic := '0';
		fs_up6 : out std_logic := '0';
		fs_up7 : out std_logic := '0';
		fs_up8 : out std_logic := '0';
		fs_up9 : out std_logic := '0';
		fs_up10: out std_logic := '0'
		);
end upsampler_frequency_2x;

architecture rtl of upsampler_frequency_2x is

signal count: integer;
signal count_trigger: std_logic;

begin

	counter_trigger: process(clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				count_trigger <= '0';
			elsif sclk_flag = '1' then
				count_trigger <= '1';
			end if;
		end if;
	end process;
	
	counter_mod1000: process(clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				count <= 0;
			elsif count = module then
				count <= 0;
			elsif sclk_flag = '1' then 
				count <= 0;
			elsif count_trigger = '1' then
				count <= count + 1;
			end if;
		end if;
	end process;
	
    fs_up1 <= '1' when ((count mod 2 = 0 or count = 0) and count >= 2 and module = 2) else '0';
    fs_up2 <= '1' when ((count mod 4 = 0 or count = 0) and count >= 4 and module = 4) else '0';
    fs_up3 <= '1' when ((count mod 8 = 0 or count = 0) and count >= 8 and module = 8) else '0';
    fs_up4 <= '1' when ((count mod 16 = 0 or count = 0) and count >= 16 and module = 16) else '0';
    fs_up5 <= '1' when ((count mod 32 = 0 or count = 0) and count >= 32 and module = 32) else '0';
    fs_up6 <= '1' when ((count mod 64 = 0 or count = 0) and count >= 64 and module = 64) else '0';
    fs_up7 <= '1' when ((count mod 128 = 0 or count = 0) and count >= 128 and module = 128) else '0';
    fs_up8 <= '1' when ((count mod 256 = 0 or count = 0) and count >= 256 and module = 256) else '0';
    fs_up9 <= '1' when ((count mod 512 = 0 or count = 0) and count >= 512 and module = 512) else '0';
    fs_up10 <= '1' when ((count mod 1024 = 0 or count = 0) and count >= 1024 and module = 1024) else '0';

end rtl;