library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sigma_delta_2 is
	generic(N: in integer;
		M: in integer);
	port(	clk, rst: in std_logic;
		sample_freq: in std_logic;
		input: in signed(N-1 downto 0);
		output: out std_logic
		);
end sigma_delta_2;

architecture beh of sigma_delta_2 is

signal x_in: signed(N-1 downto 0) := (others => '0');
signal x1, x2, y_out: signed(N-1 downto 0) := (others => '0');

begin
	
	process(clk)
	variable delta1: signed(N-1 downto 0) := (others => '0');
	variable delta2: signed(N-1 downto 0) := (others => '0');
	variable sigma1: signed(N-1 downto 0) := (others => '0');
	variable sigma2: signed(N-1 downto 0) := (others => '0');
	variable y_value: signed(N-1 downto 0):= (others => '0');
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				x_in <= (others => '0');
				x1 <= (others => '0');
				x2 <= (others => '0');
				y_out <= (others => '0');
				output <= '0';
				delta1 := (others => '0');
				delta2 := (others => '0');
				sigma1 := (others => '0');
				sigma2 := (others => '0');
				y_value := (others => '0');
			else
				if sample_freq = '1' then
					x_in <= input;
					delta1 := x_in - y_out;
					sigma1 := shift_right(delta1,1)+ x1;
					delta2 := x1 - y_out;
					sigma2 := shift_right(delta2,1)+ x2;
					if sigma2 >= 0 then
						y_value := to_signed(2**(M-1)-1,N);
					else
						y_value := to_signed(-2**(M-1),N); 
					end if;
					x1 <= sigma1;
					x2 <= sigma2;
					output <= not y_value(N-1);
					y_out <= y_value; 
				end if;
			end if;
		end if;
	end process;
	
end architecture;	