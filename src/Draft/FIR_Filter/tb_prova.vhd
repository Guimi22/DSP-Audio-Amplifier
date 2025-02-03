library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_tb is
end top_tb;

architecture behavior of top_tb is
    -- Component Declaration
component top is
port( 	clk: in std_logic;
	rst: in std_logic;
	sclk: in std_logic;
	audio_in: in std_logic_vector(15 downto 0);
	fs_upsample: out std_logic;
	audio_out: out signed(15 downto 0)
	);
end component;
    
--component polyphase_fir_filter
--        generic (
--            DATA_WIDTH      : integer := 16;
--            COEFF_WIDTH     : integer := 16;
--            NUM_TAPS        : integer := 91;
--            PHASES          : integer := 2
--        );
--        port (
--            clk             : in  std_logic;
--            rst             : in  std_logic;
--            data_in         : in  std_logic_vector(15 downto 0);
--            data_valid_in   : in  std_logic;
--            data_out        : out std_logic_vector(31 downto 0);
--            data_valid_out  : out std_logic
--        );
--    end component;
    
    -- Signals
	signal clk             	: std_logic := '0';
	signal sclk_tb		: std_logic := '0';
    	signal rst             	: std_logic := '1';
    	signal data_in         	: std_logic_vector(15 downto 0) := (others => '0');
    	signal data_out        	: signed(15 downto 0);
    	signal fs_up  		: std_logic;
    
    -- Clock period definition
    	constant clk_period    	: time := 5 ns;  
	constant sclk_period	: time := 640 ns; -- 1 MHz sampling rate
    
    -- LUT for sine wave (10 kHz) and noise (150 kHz)
    type sine_lut_type is array (0 to 99) of integer;
    constant sine_lut_10khz : sine_lut_type := (
        -- values for a 10kHz sine wave sampled at 1MHz (100 samples per cycle)
        0, 2052, 4097, 6126, 8130, 10102, 12034, 13918, 15746, 17511, 
        19207, 20826, 22362, 23809, 25161, 26412, 27557, 28591, 29509, 30307,
        30980, 31526, 31942, 32226, 32377, 32393, 32274, 32020, 31631, 31109,
        30455, 29671, 28761, 27727, 26574, 25306, 23927, 22442, 20857, 19176,
        17406, 15553, 13624, 11626, 9574, 7474, 5334, 3162, 974, -1221,
        -3413, -5586, -7731, -9841, -11907, -13922, -15877, -17764, -19575, -21303,
        -22942, -24484, -25924, -27256, -28474, -29573, -30547, -31392, -32103, -32676,
        -33108, -33396, -33538, -33533, -33378, -33075, -32622, -32021, -31273, -30379,
        -29341, -28163, -26847, -25398, -23820, -22118, -20296, -18360, -16314, -14164,
        -11916, -9585, -7176, -4694, -2155, 0, 2155, 4694, 7176, 9585
    );

    constant sine_lut_150khz : sine_lut_type := (
        -- values for a 150kHz sine wave sampled at 1MHz (100 samples per cycle)
        0, 18773, 32767, 40038, 40038, 32767, 18773, 0, -18773, -32767,
        -40038, -40038, -32767, -18773, 0, 18773, 32767, 40038, 40038, 32767,
        18773, 0, -18773, -32767, -40038, -40038, -32767, -18773, 0, 18773,
        32767, 40038, 40038, 32767, 18773, 0, -18773, -32767, -40038, -40038,
        -32767, -18773, 0, 18773, 32767, 40038, 40038, 32767, 18773, 0,
        -18773, -32767, -40038, -40038, -32767, -18773, 0, 18773, 32767, 40038,
        40038, 32767, 18773, 0, -18773, -32767, -40038, -40038, -32767, -18773,
        0, 18773, 32767, 40038, 40038, 32767, 18773, 0, -18773, -32767,
        -40038, -40038, -32767, -18773, 0, 18773, 32767, 40038, 40038, 32767,
        18773, 0, -18773, -32767, -40038, -40038, -32767, -18773, 0, 18773
    );

    -- Sample index for signal generation
    signal sample_index    : integer := 0;

begin
    -- Instantiate the Unit Under Test (UUT)
    UUT: top
        port map (
            	clk => clk,
            	rst => rst,
            	sclk => sclk_tb,	
		audio_in => data_in,
            	fs_upsample => fs_up,
            	audio_out => data_out
        );
        
    -- Clock process
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
            -- Retrieve sinusoidal components from LUTs
            	sine_wave := sine_lut_10khz(sample_index mod 100);  -- 10kHz component
            	noise_wave := sine_lut_150khz(sample_index mod 100); -- 150kHz component

            -- Combine the signals
            	combined_signal := sine_wave + noise_wave;

            -- Convert to fixed-point representation for data_in
            	data_in <= std_logic_vector(to_signed(combined_signal, 16));

            -- Increment sample index
            	sample_index <= sample_index + 1;

            -- Wait for the next clock period
            	wait for sclk_period;
        	end loop;

        	wait;
    	end process;
    
end behavior;

