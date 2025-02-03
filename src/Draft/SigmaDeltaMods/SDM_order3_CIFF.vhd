library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SDM_order3_CIFF is
	generic(N: in integer;
		M: in integer);
	port(	clk, rst: in std_logic;
		sample_freq: in std_logic;
		input: in signed(N-1 downto 0);
		output: out std_logic
		);
end SDM_order3_CIFF;

architecture beh of SDM_order3_CIFF is

signal x_in: signed(N-1 downto 0) := (others => '0');
signal x1, x2, x3, y_out: signed(N-1+20 downto 0) := (others => '0');
signal y: std_logic := '0';
signal coef_a1, coef_a2, coef_a3, coef_a4, coef_a5, coef_b1, coef_b2, coef_b3, coef_b4, coef_b5, coef_b6: signed(23 downto 0) := (others => '0');

begin

	coef_a2 <= to_signed(26214, 24);

	process(clk)
	variable delta1: signed(N-1+20 downto 0) := (others => '0');
	variable delta2: signed(N-1+20 downto 0) := (others => '0');
	variable delta3: signed(N-1+20 downto 0) := (others => '0');
	variable sigma1: signed(N-1+20 downto 0) := (others => '0');
	variable sigma2: signed(N-1+20 downto 0) := (others => '0');
	variable sigma3: signed(N-1+20 downto 0) := (others => '0');
	variable adder_out: signed(N+20-1 downto 0) := (others => '0');
	variable reg_a2: signed(N+24+20-1 downto 0) := (others => '0');
	variable y_value: signed(N+20-1 downto 0):= (others => '0');
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				x_in <= (others => '0');
				x1 <= (others => '0');
				x2 <= (others => '0');
				x3 <= (others => '0');
				y_out <= (others => '0');
				y <= '0';
				delta1 := (others => '0');
				delta2 := (others => '0');
				delta3 := (others => '0');
				sigma1 := (others => '0');
				sigma2 := (others => '0');
				sigma3 := (others => '0');
				reg_a2 := (others => '0');
				y_value := (others => '0');
			else
				if sample_freq = '1' then
					x_in <= input;
					delta1 := x_in - y_out;
					sigma1 := x1 + shift_right(delta1,1);
					delta2 := x1;
					reg_a2 := coef_a2*delta2;
					sigma2 := x2 + reg_a2(N+24+20-1 downto 24);
					delta3 := sigma2;
					sigma3 := x3 + shift_right(delta3,1);
					adder_out := x_in + x1 + sigma2 + sigma3;
					if adder_out >= 0 then
						y_value := to_signed(2**(M-1)-1,N+20);	--131071
					else
						y_value := to_signed(-2**(M-1),N+20); --131072
					end if;
					x1 <= sigma1;
					x2 <= sigma2;
					x3 <= sigma3;
					y <= not y_value(N-1);
					y_out <= y_value; 
				end if;
			end if;
		end if;
	end process;
	
	output <= y;
	
end architecture;	
