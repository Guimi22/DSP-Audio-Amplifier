library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Integrator_tb is
end Integrator_tb;

architecture tb of Integrator_tb is

component Integrator is
	generic(N: in integer);
	port(	clk, rst: in std_logic;
		sample_freq: in std_logic;
		carry_in: in std_logic;
		input: in std_logic_vector(N-1 downto 0);
		carry_output: out std_logic;
		output: out std_logic_vector(N-1 downto 0)
		);
end component;

signal clock_period: time := 10 ns;
signal sample_period: time := 30 ns;
signal input1, output_tb: std_logic_vector(15 downto 0);
signal clk_tb, rst_tb, fsample, carry_in_tb, carry_out_tb: std_logic;

begin

	UUT: Integrator
	generic map( N => 16)
	port map( clk => clk_tb, rst => rst_tb, sample_freq => fsample, carry_in => carry_in_tb, input => input1, carry_output => carry_out_tb, output => output_tb);

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
		fsample <= '0';
		wait for clock_period;
		fsample <= '1';
		wait for sample_period - clock_period;
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
	
	process
	begin
		carry_in_tb <= '0';
		wait for 4*sample_period;
		carry_in_tb <= '1';
		wait for 4*sample_period;
	end process;

end architecture;
