library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity tb_transceiver_I2S is
end tb_transceiver_I2S;

architecture tb of tb_transceiver_I2S is

signal clk_tb, sclk_tb, rst_tb, SD_tb, WS_tb, sample_out_tb: std_logic := '0';
signal audio_out_tb, audio_out_tb2, input1: std_logic_vector(15 downto 0) := (others => '0');
signal clk_period: time := 10 ns;
signal sclk_period: time := 50 ns;
type sample_values is array (0 to 4) of integer;
signal sample: sample_values := (32767,32768,-1,0,65535);
signal value_index, sample_index: integer := 0;
signal count: std_logic := '0';

component top is
port( 	clk, sclk, rst, SD, WS: in std_logic;
	WS_level_flag: out std_logic;
	audio_out: out std_logic_vector(15 downto 0)
	);
end component;

begin

	UUT: top
	port map( clk => clk_tb, sclk => sclk_tb, rst => rst_tb, SD => SD_tb, WS => WS_tb, WS_level_flag => sample_out_tb, audio_out => audio_out_tb);	
	
	clk_testbench: process
	begin
		clk_tb <= '1';
		wait for clk_period/2;
		clk_tb <= '0';
		wait for clk_period/2;
	end process;
	
	sclk_testbench: process
	begin
		sclk_tb <= '1';
		wait for sclk_period/2;
		sclk_tb <= '0';
		wait for sclk_period/2;
	end process;
	
	WS_testbench: process
	begin
		wait until sclk_tb = '0';
		WS_tb <= '1';
		wait for sclk_period;
		for i in 15 downto 0 loop
			SD_tb <= input1(i);
			wait for sclk_period;
		end loop;
		SD_tb <= '0';
		wait for 16*sclk_period;
		WS_tb <= '0';
		wait for sclk_period;
		for i in 15 downto 0 loop
			SD_tb <= input1(i);
			wait for sclk_period;
		end loop;
		SD_tb <= '0';
		wait for 16*sclk_period;
	end process;

	stim_proc: process
        variable sample_val: integer;
    	begin
        	while true loop
            	sample_val := sample(sample_index mod 5);
		input1 <= std_logic_vector(to_signed(sample_val, 16));
		wait for 32*sclk_period;
            	sample_index <= sample_index + 1;
        	end loop;
    	end process;
	
end tb;	