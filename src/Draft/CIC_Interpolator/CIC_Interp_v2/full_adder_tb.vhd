library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity full_adder_tb is
end full_adder_tb;

architecture tb of full_adder_tb is

component full_adder is
	generic(N : integer);
	port(	a 		: in  std_logic_vector (N-1 downto 0);
		b 		: in  std_logic_vector (N-1 downto 0);
		carry_in 	: in  std_logic;
		s 		: out std_logic_vector (N-1 downto 0);
		carry_out 	: out std_logic);
end component;

signal input1, input2: std_logic_vector(15 downto 0);
signal carry_in_tb, carry_out_tb: std_logic;
signal output_tb: std_logic_vector(15 downto 0);

begin

	UUT: full_adder
	generic map( N => 16)
	port map( a => input1 , b => input2 , carry_in => carry_in_tb, s => output_tb, carry_out => carry_out_tb);

	process
	begin
		carry_in_tb <= '0';
		input1 <= "1111111111111111";
		input2 <= "0101010101010101";
		wait for 5 ns;
		carry_in_tb <= '0';
		input1 <= "1011111111111111";
		input2 <= "1101010101010101";
		wait for 5 ns;
		carry_in_tb <= '1';
		input1 <= "1111111111111111";
		input2 <= "0101010101010101";
		wait for 5 ns;
		carry_in_tb <= '1';
		input1 <= "1011111111111111";
		input2 <= "1101010101010101";
		wait for 5 ns;
	end process;

end architecture;
		
