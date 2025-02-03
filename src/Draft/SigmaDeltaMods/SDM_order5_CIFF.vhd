library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SDM_order5_CIFF is
	generic(N: in integer;
		M: in integer);
	port(	clk, rst: in std_logic;
		sample_freq: in std_logic;
		input: in signed(N-1 downto 0);
		output: out std_logic
		);
end SDM_order5_CIFF;

architecture beh of SDM_order5_CIFF is

signal x_in: signed(N-1 downto 0) := (others => '0');
signal x1, x2, x3, x4, x5, y_out: signed(N-1+8 downto 0) := (others => '0');
signal y: std_logic := '0';
signal coef_a1, coef_a2, coef_a3, coef_a4, coef_a5: signed(23 downto 0) := (others => '0');

begin

	coef_a1 <= to_signed(105866, 24);
	coef_a2 <= to_signed(41484, 24);
	coef_a3 <= to_signed(9686, 24);
	coef_a4 <= to_signed(1337, 24);
	coef_a5 <= to_signed(92, 24);
	
	process(clk)
	variable delta1: signed(N-1+8 downto 0) := (others => '0');
	variable delta2: signed(N-1+8 downto 0) := (others => '0');
	variable delta3: signed(N-1+8 downto 0) := (others => '0');
	variable delta4: signed(N-1+8 downto 0) := (others => '0');
	variable delta5: signed(N-1+8 downto 0) := (others => '0');
	variable sigma1: signed(N-1+8 downto 0) := (others => '0');
	variable sigma2: signed(N-1+8 downto 0) := (others => '0');
	variable sigma3: signed(N-1+8 downto 0) := (others => '0');
	variable sigma4: signed(N-1+8 downto 0) := (others => '0');
	variable sigma5: signed(N-1+8 downto 0) := (others => '0');
	variable adder_out: signed(N-1+8 downto 0) := (others => '0');
	variable reg_a1: signed(N+24-1+8 downto 0) := (others => '0');
	variable reg_a2: signed(N+24-1+8 downto 0) := (others => '0');
	variable reg_a3: signed(N+24-1+8 downto 0) := (others => '0');
	variable reg_a4: signed(N+24-1+8 downto 0) := (others => '0');
	variable reg_a5: signed(N+24-1+8 downto 0) := (others => '0');
	variable y_value: signed(N-1+8 downto 0):= (others => '0');
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				x_in <= (others => '0');
				x1 <= (others => '0');
				x2 <= (others => '0');
				x3 <= (others => '0');
				x4 <= (others => '0');
				x5 <= (others => '0');
				y_out <= (others => '0');
				y <= '0';
				delta1 := (others => '0');
				delta2 := (others => '0');
				delta3 := (others => '0');
				delta4 := (others => '0');
				delta5 := (others => '0');
				sigma1 := (others => '0');
				sigma2 := (others => '0');
				sigma3 := (others => '0');
				sigma4 := (others => '0');
				sigma5 := (others => '0');
				reg_a1 := (others => '0');
				reg_a2 := (others => '0');
				reg_a3 := (others => '0');
				reg_a4 := (others => '0');
				reg_a5 := (others => '0');
				y_value := (others => '0');
			else
				if sample_freq = '1' then
					x_in <= input;
					delta1 := x_in - y_out;
					sigma1 := x1 + delta1;
					delta2 := x1;
					sigma2 := x2 + delta2;
					delta3 := x2;
					sigma3 := x3 + delta3;
					delta4 := x3;
					sigma4 := x4 + delta4;
					delta5 := x4;
					sigma5 := x5 + delta5;
					reg_a1 := coef_a1*x1;
					reg_a2 := coef_a2*x2;
					reg_a3 := coef_a3*x3;
					reg_a4 := coef_a4*x4;
					reg_a5 := coef_a5*x5;
					adder_out := x_in + reg_a1(N-1+8 downto 0) + reg_a2(N-1+8 downto 0) + reg_a3(N-1+8 downto 0) + reg_a4(N-1+8 downto 0) + reg_a5(N-1+8 downto 0);
					if adder_out >= 0 then
						y_value := to_signed(2**(M-1)-1,N+8);
					else
						y_value := to_signed(-2**(M-1),N+8); 
					end if;
					x1 <= sigma1;
					x2 <= sigma2;
					x3 <= sigma3;
					x4 <= sigma4;
					x5 <= sigma5;
					output <= not y_value(N-1);
					y_out <= y_value;
				end if;
			end if;
		end if;
	end process;
	
end architecture;	
