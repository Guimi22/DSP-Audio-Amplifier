library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SDM_CIFF_tb is
end SDM_CIFF_tb;

architecture structural of SDM_CIFF_tb is

component SDM_order5_CIFF is
	generic(N: in integer;
		M: in integer);
	port(	clk, rst: in std_logic;
		sample_freq: in std_logic;
		input: in signed(N-1 downto 0);
		output: out std_logic
		);
end component;

component SDM_order3_CIFF is
	generic(N: in integer;
		M: in integer);
	port(	clk, rst: in std_logic;
		sample_freq: in std_logic;
		input: in signed(N-1 downto 0);
		output: out std_logic
		);
end component;

signal clock_period: time := 10 ns;
signal sample_period: time := 300 ns;
signal input1: signed(23 downto 0);
signal output_tb: std_logic;
signal clk_tb, fsample: std_logic;
signal rst_tb: std_logic := '0';

type sine_lut_type is array (0 to 99) of integer;
constant sine_lut_10khz : sine_lut_type := (
0,5335,10231,14402,17810,20675,23387,26363,29889,34013,38522,43014,47035,50243,52520,54018,55092,56175,57616,59553,61858,64184,66086,67179,67279,66462,65043,63458,62109,61221,60758,60444,59859,58592,56395,53274,49488,45460,41630,38300,35530,33119,30684,27804,24175,19723,14641,9321,4222,-294,-4079,-7255,-10157,-13210,-16768,-20985,-25748,-30716,-35435,-39499,-42686,-45039,-46839,-48506,-50438,-52866,-55770,-58877,-61759,-63987,-65277,-65596,-65168,-64393,-63704,-63409,-63578,-64023,-64360,-64154,-63072,-61008,-58120,-54780,-51436,-48462,-46019,-44007,-42100,-39873,-36952,-33161,-28585,-23548,-18499,-13857,-9867,-6516,-3544,-544
);

signal sample_index    : integer := 0;
signal rst_loop: integer := 0;

begin

	UUT: SDM_order5_CIFF
	generic map( N => 24, M => 18)
	port map( clk => clk_tb, rst => rst_tb, sample_freq => fsample, input => input1, output => output_tb);	

	process
	begin
		clk_tb <= '1';
		wait for sample_period/2;
		clk_tb <= '0';
		wait for sample_period/2;
	end process;
	
	process
	begin
		fsample <= '1';
		wait for clock_period;
		fsample <= '0';
		wait for sample_period - clock_period;
	end process;
	
	stim_proc: process
	variable sine_wave       : integer;
	begin
		while true loop
			sine_wave := sine_lut_10khz(sample_index mod 100);  
			input1 <= to_signed(sine_wave, 24);
			wait until fsample = '1';
			sample_index <= sample_index + 1;
			wait for sample_period;
		end loop;
		wait;
	end process;

end architecture;