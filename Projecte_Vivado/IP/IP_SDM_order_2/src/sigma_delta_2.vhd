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
signal reg_a1, reg_a, x1, reg_a2, reg_b, x2, y_out: signed(N-1+8 downto 0) := (others => '0');
signal y: std_logic := '0';

begin
	
	process(clk)
	variable delta1: signed(N-1+8 downto 0) := (others => '0');
	variable delta2: signed(N-1+8 downto 0) := (others => '0');
	variable sigma1: signed(N-1+8 downto 0) := (others => '0');
	variable sigma2: signed(N-1+8 downto 0) := (others => '0');
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				x_in <= (others => '0');
				--reg_a1 <= (others => '0');
				reg_a <= (others => '0');
				x1 <= (others => '0');
				--reg_a2 <= (others => '0');
				reg_b <= (others => '0');
				x2 <= (others => '0');
				y_out <= (others => '0');
				y <= '0';
				delta1 := (others => '0');
				delta2 := (others => '0');
				sigma1 := (others => '0');
				sigma2 := (others => '0');
			else
				if sample_freq = '1' then
					x_in <= input;
--					reg_a1 <= x_in - y_out;
--					reg_a <= shift_right(reg_a1,1);
--					x1 <= x1 + reg_a;
					delta1 := x_in - y_out;
					sigma1 := x1 + shift_right(delta1,1);
					delta2 := x1 - y_out;
					sigma2 := x2 + shift_right(delta2,1);
					--x1 <= x1 + shift_right(x_in - y_out,1);
--					reg_a2 <= x1 - y_out;
--					reg_b <= shift_right(reg_a2,1);
--					x2 <= x2 + reg_b;
					--x2 <= x2 + shift_right(x1 - y_out,1);
--					if x2 < 0 then
--						y <= '0';
--					else
--						y <= '1';
--					end if;
					if sigma2 >= 0 then
						y_out <= to_signed(2**(M-1)-1,N+8);	--131071
					else
						y_out <= to_signed(-2**(M-1),N+8); --131072
					end if;
					x1 <= sigma1;
					--reg_a <= delta1;
					x2 <= sigma2;
					--reg_b <= delta2;
					y <= not y_out(N-1);
				end if;
			end if;
		end if;
	end process;
	
	output <= y;
	
end architecture;	