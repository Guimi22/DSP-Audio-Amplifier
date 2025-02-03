library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity full_adder is
	generic(N : integer);
	port(	a 		: in  std_logic_vector (N-1 downto 0);
		b 		: in  std_logic_vector (N-1 downto 0);
		carry_in 	: in  std_logic;
		s 		: out std_logic_vector (N-1 downto 0);
		carry_out 	: out std_logic);
end full_adder;

architecture beh of full_adder is

begin
	
--	for i in 0 to N-1 generate
--		s(i) <= a(i) xor b(i) xor carry;
--      carry <= (a(i) and b(i)) or (a(i) and carry) or (b(i) and carry);
--	end generate
	
	SUM: process(a,b,carry_in)
	variable C: std_logic;
    	begin
		C := carry_in;
        	for i in 0 to N-1 loop
			s(i) <= a(i) xor b(i) xor C;
			C := (a(i) and b(i)) or (a(i) and C) or (b(i) and C);
		end loop;
		carry_out <= C;
	end process;

end architecture;