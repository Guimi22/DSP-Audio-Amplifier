library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity IIR_Filter_tb is
end IIR_Filter_tb;

architecture behavior of IIR_Filter_tb is

component IIR_Filter is
	port(	clk: in std_logic;
		rst: in std_logic;
		data_in: in signed(15 downto 0);
		sample_freq: in std_logic;
		oversampling_freq: in std_logic;
		a1: in signed(15 downto 0);
		a2: in signed(15 downto 0);
		audio_out: out signed(15 downto 0)
		);
end component;

component Rising_edge_detector is
port(	clk, rst, En, signal_in: in std_logic;
		rising_edge_flag: out std_logic
	);
end component;

component frequency_upsampler is
	generic( module: in integer);
	port(	clk: in std_logic;
		rst: in std_logic;
		fs_in: in std_logic;
		upsample_freq: out std_logic
		);
end component;

signal clk: std_logic := '0';
signal sclk_tb: std_logic := '0';
signal rst: std_logic := '1';
signal data_in: signed(15 downto 0);
signal data_out: signed(15 downto 0);
signal fs_up: std_logic;

constant clk_period: time := 10 ns;  
constant sclk_period: time := 1 us; -- 1 MHz sampling rate

type sine_lut_type is array (0 to 99) of integer;
constant sine_lut_10khz: sine_lut_type := (
0,2707,4008,3677,2849,3067,4982,7802,9955,10404,9519,8758,9444,11647,14128,15371,14859,13503,12876,13892,16032,17783,17907,16477,14817,14392,15571,17323,18080,17056,14905,13177,13012,14188,15307,14971,12958,10411,8879,9021,10051,10405,9054,6374,3831,2754,3222,4001,3583,1458,-1458,-3583,-4001,-3222,-2754,-3831,-6374,-9054,-10405,-10051,-9021,-8879,-10411,-12958,-14971,-15307,-14188,-13012,-13177,-14905,-17056,-18080,-17323,-15571,-14392,-14817,-16477,-17907,-17783,-16032,-13892,-12876,-13503,-14859,-15371,-14128,-11647,-9444,-8758,-9519,-10404,-9955,-7802,-4982,-3067,-2849,-3677,-4008,-2707,0
);
signal sample_index: integer := 0;
signal edge_flag: std_logic;

begin

	UUT: IIR_Filter
	port map(
		clk => clk,
            	rst => rst,
            	data_in => data_in,
		sample_freq => edge_flag,
		oversampling_freq => fs_up,	
		a1 => "1100000000000000", -- -1.591309/1.591309 = -1
		a2 => "1001101010011101", -- -0.661681/1.591309 = -0.415809
            	audio_out => data_out
		);
	
	freq_upsample: frequency_upsampler
	generic map( module => 45)
	port map( clk => clk, rst => rst, fs_in => edge_flag, upsample_freq => fs_up);

	Ris_edge: Rising_edge_detector
	port map(clk => clk, rst => rst, En => '1', signal_in => sclk_tb, rising_edge_flag => edge_flag );
        
	clk_process: process
	begin
		clk <= '0';
		wait for clk_period / 2;
		clk <= '1';
		wait for clk_period / 2;
	end process;
	
	sclk_process: process
	begin
		sclk_tb <= '0';
		wait for sclk_period / 2;
		sclk_tb <= '1';
		wait for sclk_period / 2;
	end process;

	stim_proc: process
	variable combined_signal : integer;
	variable sine_wave       : integer;
	begin
		wait for clk_period * 10;
		rst <= '0';
		while true loop
			sine_wave := sine_lut_10khz(sample_index mod 100);  -- 10kHz component
			combined_signal := sine_wave;
			wait until sclk_tb = '1';
			data_in <= to_signed(combined_signal, 16);
			sample_index <= sample_index + 1;
			wait for sclk_period;
		end loop;
		wait;
	end process;
    
end behavior;
