library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CIC_Interpolator_v2_tb is
end CIC_Interpolator_v2_tb;

architecture tb of CIC_Interpolator_v2_tb is

component CIC_Interpolator_v2 is
	generic(size_in: in integer;
		extension_bits: in integer;
		size_out: in integer;
		gain_cic_bits: in integer;
		D: in integer;
		R: in integer;
		order: in integer);
	port(	clk, rst: in std_logic;
		sample_freq: in std_logic;
		upsample_freq: in std_logic;
		data_in: in std_logic_vector(size_in-1 downto 0);
		data_out: out std_logic_vector(size_out-1 downto 0)
		);
end component;

signal clock_period: time := 10 ns;
signal sample_period: time := 640 ns;
signal input1, output_tb: std_logic_vector(15 downto 0) := (others => '0');
signal clk_tb, rst_tb, fsample, fupsample: std_logic;

type sine_lut_type is array (0 to 99) of integer;
constant sine_lut_10khz : sine_lut_type := (
0,2707,4008,3677,2849,3067,4982,7802,9955,10404,9519,8758,9444,11647,14128,15371,14859,13503,12876,13892,16032,17783,17907,16477,14817,14392,15571,17323,18080,17056,14905,13177,13012,14188,15307,14971,12958,10411,8879,9021,10051,10405,9054,6374,3831,2754,3222,4001,3583,1458,-1458,-3583,-4001,-3222,-2754,-3831,-6374,-9054,-10405,-10051,-9021,-8879,-10411,-12958,-14971,-15307,-14188,-13012,-13177,-14905,-17056,-18080,-17323,-15571,-14392,-14817,-16477,-17907,-17783,-16032,-13892,-12876,-13503,-14859,-15371,-14128,-11647,-9444,-8758,-9519,-10404,-9955,-7802,-4982,-3067,-2849,-3677,-4008,-2707,0
);

signal sample_index    : integer := 0;

begin

	UUT: CIC_Interpolator_v2
	generic map( size_in => 16, extension_bits => 8, size_out => 16, gain_cic_bits => 12, D => 1, R => 16, order => 2)
	port map( clk => clk_tb, rst => rst_tb, sample_freq => fsample, upsample_freq => fupsample, data_in => input1, data_out => output_tb);

	rst_tb <= '0'; 	

	process
	begin
		clk_tb <= '0';
		wait for clock_period/2;
		clk_tb <= '1';
		wait for clock_period/2;
	end process;
	
	process
	begin
		fsample <= '0';
		wait for clock_period;
		fsample <= '1';
		wait for sample_period - clock_period;
	end process;

	process
	begin
		fupsample <= '1';
		wait for clock_period;
		fupsample <= '0';
		wait for sample_period/16 - clock_period;
	end process;

--	process
--	begin
--		input1 <= "1111111111111111";
--		wait for sample_period;
--		input1 <= "0000000000000001";
--		wait for sample_period;
--		input1 <= "1000000000000001";
--		wait for sample_period;
--		input1 <= "0111111111111111";
--		wait for sample_period;
--	end process;

    -- Signal generation process: 10 kHz signal with 150 kHz noise
    	stim_proc: process
        	variable sine_wave       : integer;
        	--variable noise_wave      : integer;
    	begin

        -- Generate sampled composite signal for each clock cycle
        	while true loop
            -- Retrieve sinusoidal components from LUTs
            	sine_wave := sine_lut_10khz(sample_index mod 100);  -- 10kHz component

            -- Convert to fixed-point representation for data_in
		wait until fsample = '1';
		input1 <= std_logic_vector(to_signed(sine_wave, 16));

            -- Increment sample index
            	sample_index <= sample_index + 1;

            -- Wait for the next clock period
            	wait for sample_period;
        	end loop;

        	wait;
    	end process;

end architecture;
