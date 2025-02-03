library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SDM_order5_CRFB is
	generic(N: in integer;
		M: in integer);
	port(	clk, rst: in std_logic;
		sample_freq: in std_logic;
		input: in signed(N-1 downto 0);
		output: out std_logic
		);
end SDM_order5_CRFB;

architecture beh of SDM_order5_CRFB is

signal x_in: signed(N-1 downto 0) := (others => '0');
signal x1, x2, x3, x4, x5, y_out: signed(N-1 downto 0) := (others => '0');
signal y: std_logic := '0';
--signal coef_a1, coef_a2, coef_a3, coef_a4, coef_a5, coef_b1, coef_b2, coef_b3, coef_b4, coef_b5, coef_b6: signed(N-1 downto 0) := (others => '0');

begin

	process(clk)
	variable delta1: signed(N-1 downto 0) := (others => '0');
	variable delta2: signed(N-1 downto 0) := (others => '0');
	variable delta3: signed(N-1 downto 0) := (others => '0');
	variable delta4: signed(N-1 downto 0) := (others => '0');
	variable delta5: signed(N-1 downto 0) := (others => '0');
	variable sigma1: signed(N-1 downto 0) := (others => '0');
	variable sigma2: signed(N-1 downto 0) := (others => '0');
	variable sigma3: signed(N-1 downto 0) := (others => '0');
	variable sigma4: signed(N-1 downto 0) := (others => '0');
	variable sigma5: signed(N-1 downto 0) := (others => '0');
	variable adder_out: signed(N-1 downto 0) := (others => '0');
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
			else
				if sample_freq = '1' then
					x_in <= input;
					delta1 := shift_right(x_in, 11) - shift_right(y_out, 11);
					sigma1 := x1 + delta1;
					delta2 := x1 + shift_right(x_in, 7) - shift_right(y_out, 7);
					sigma2 := x2 + delta2;
					delta3 := sigma2 + shift_right(x_in, 5) - shift_right(y_out, 5);
					sigma3 := x3 + delta3;
					delta4 := x3 + shift_right(x_in, 2) - shift_right(y_out, 2);
					sigma4 := x4 + delta4;
					delta5 := sigma4 + shift_right(x_in, 1) - shift_right(y_out, 1);
					sigma5 := x5 + delta5;
					adder_out := x5 + x_in;
					if adder_out >= 0 then
						y_out <= to_signed(2**(M-1)-1,N);	--131071
					else
						y_out <= to_signed(-2**(M-1),N); --131072
					end if;
					x1 <= sigma1;
					x2 <= sigma2;
					x3 <= sigma3;
					x4 <= sigma4;
					x5 <= sigma5;
					y <= not y_out(N-1);
				end if;
			end if;
		end if;
	end process;
	
	output <= y;
	
end architecture;	
