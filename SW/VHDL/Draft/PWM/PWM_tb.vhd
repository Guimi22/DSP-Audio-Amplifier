library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PWM_tb is
end PWM_tb;

architecture behavior of PWM_tb is
    -- Component Declaration
--component PWM_unit is
--	generic(size_audio_in: integer;
--		size_timer: integer
--		);
--	port(	clk: in std_logic;
--		rst: in std_logic;
--		sample_in: in std_logic;
--		data_in: in signed(size_audio_in-1 downto 0);
--		pwm_out: out std_logic
--		);
--end component;

--component PWM_halfbridge is
--	generic(size_audio_in: integer;
--		size_timer: integer;
--		deadtime_delay: integer
--		);
--	port(	clk: in std_logic;
--		rst: in std_logic;
--		sample_in: in std_logic;
--		data_in: in signed(size_audio_in-1 downto 0);
--		pwm_p_out: out std_logic;
--		pwm_n_out: out std_logic
--		);
--end component;

component PWM_fullbridge is
	generic(size_audio_in: integer;
		size_timer: integer;
		deadtime_delay: integer
		);
	port(	clk: in std_logic;
		rst: in std_logic;
		sample_in: in std_logic;
		data_in: in signed(size_audio_in-1 downto 0);
		pwm_p_out1: out std_logic;
		pwm_n_out1: out std_logic;
		pwm_p_out2: out std_logic;
		pwm_n_out2: out std_logic	
		);
end component;
    
    -- Signals
	signal clk             	: std_logic := '0';
    	signal rst             	: std_logic := '1';
    	signal data_in_signal   : signed(15 downto 0) := (others => '0');
    
    -- Clock period definition
    	constant clk_period    	: time := 10 ns;
	constant sample_period	: time := 11 us;  
    
    -- LUT for sine wave (15 kHz)
    	type sine_lut_type is array (0 to 99) of integer;
    	constant sine_lut_15khz : sine_lut_type := (
        -- values for a 15 kHz sine wave sampled at 88.2 kHz (100 samples per cycle)
	0,  28203,  28713,   1029, -27666, -29195,  -2057,  27100,  29648,   3083,
 	-26509, -30072,  -4106,  25891,  30465,   5125, -25247, -30829,  -6139,  24578,
  	31163,   7147, -23886, -31465,  -8148,  23169,  31737,   9141, -22430, -31977,
 	-10125,  21669,  32186,  11099, -20886, -32363, -12062,  20083,  32508,  13013,
 	-19259, -32621, -13951,  18417,  32702,  14875, -17557, -32750, -15785,  16679,
  	32767,  16679, -15785, -32750, -17557,  14875,  32702,  18417, -13951, -32621,
 	-19259,  13013,  32508,  20083, -12062, -32363, -20886,  11099,  32186,  21669,
 	-10125, -31977, -22430,   9141,  31737,  23169,  -8148, -31465, -23886,   7147,
  	31163,  24578,  -6139, -30829, -25247,   5125,  30465,  25891,  -4106, -30072,
 	-26509,   3083,  29648,  27100,  -2057, -29195, -27666,   1029,  28713,  28203
    	);

    -- Sample index for signal generation
    	signal sample_index: integer := 0;
	constant size_data: integer := 16;
	signal pwm_p_out1_tb: std_logic;
	signal pwm_n_out1_tb: std_logic;
	signal pwm_p_out2_tb: std_logic;
	signal pwm_n_out2_tb: std_logic;
	signal sample_ready: std_logic;

begin
    -- Instantiate the Unit Under Test (UUT)
--    UUT: PWM_unit
--	generic map( size_audio_in => size_data)
--	port map( clk => clk, rst => rst, sample_in => sample_ready , data_in => data_in_signal, pwm_out => pwm_out_tb);
        
--	UUT: PWM_halfbridge
--	generic map( size_data, 10, 4)
--	port map( clk, rst, sample_ready, data_in_signal, pwm_p_out_tb, pwm_n_out_tb);

	UUT: PWM_fullbridge
	generic map( size_data, 10, 4)
	port map( clk, rst, sample_ready, data_in_signal, pwm_p_out1_tb, pwm_n_out1_tb, pwm_p_out2_tb, pwm_n_out2_tb);

    -- Clock process
    	clk_process: process
    	begin
        	clk <= '0';
        	wait for clk_period / 2;
        	clk <= '1';
        	wait for clk_period / 2;
    	end process;

    -- Signal generation process: 10 kHz signal with 150 kHz noise
    	stim_proc: process
        	variable combined_signal : integer;
        	variable sine_wave       : integer;
        	variable noise_wave      : integer;
    	begin
        -- Reset and initialization
        	wait for clk_period * 10;
        	rst <= '0';

        -- Generate sampled composite signal for each clock cycle
        	while true loop
		sample_ready <= '1';
            -- Retrieve sinusoidal components from LUTs
            	sine_wave := sine_lut_15khz(sample_index);  -- 15kHz component

            -- Convert to fixed-point representation for data_in
            	data_in_signal <= to_signed(sine_wave, 16);

            -- Increment sample index
            	sample_index <= sample_index + 1;
		
		wait for clk_period;
		sample_ready <= '0';
            -- Wait for the next clock period
            	wait for sample_period-clk_period;
        	end loop;
		wait;
    	end process;
    
end behavior;
