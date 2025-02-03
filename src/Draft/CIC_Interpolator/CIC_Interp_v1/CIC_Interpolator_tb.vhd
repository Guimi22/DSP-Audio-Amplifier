library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CIC_Interpolator_tb is
end CIC_Interpolator_tb;

architecture tb of CIC_Interpolator_tb is

component CIC_Interpolator is
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
signal input1, output_tb: std_logic_vector(15 downto 0);
signal clk_tb, rst_tb, fsample, fupsample: std_logic;

begin

	UUT: CIC_Interpolator
	generic map( size_in => 16, extension_bits => 4, size_out => 16, gain_cic_bits => 8, D => 1, R => 16, order => 2)
	port map( clk => clk_tb, rst => rst_tb, sample_freq => fsample, upsample_freq => fupsample, data_in => input1, data_out => output_tb);

	rst_tb <= '0'; 	

	process
	begin
		clk_tb <= '1';
		wait for clock_period/2;
		clk_tb <= '0';
		wait for clock_period/2;
	end process;
	
	process
	begin
		fsample <= '1';
		wait for clock_period;
		fsample <= '0';
		wait for sample_period - clock_period;
	end process;

	process
	begin
		fupsample <= '1';
		wait for clock_period;
		fupsample <= '0';
		wait for sample_period/16 - clock_period;
	end process;

	process
	begin
		input1 <= "1111111111111111";
		wait for sample_period;
		input1 <= "0000000000000001";
		wait for sample_period;
		input1 <= "1000000000000001";
		wait for sample_period;
		input1 <= "0111111111111111";
		wait for sample_period;
	end process;

end architecture;
