library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity Rising_edge_detector is
port(	clk, rst, En, signal_in: in std_logic;
		rising_edge_flag: out std_logic
	);
end Rising_edge_detector;

architecture STRUCTURAL of Rising_edge_detector is
signal D2_in: std_logic;
signal FF_out: std_logic;

component Latch_D is
port(	clk, rst, En, D: in std_logic;
		Q: out std_logic
	);
end component;

begin
	
	FF1: Latch_D
	port map(clk => clk, rst => rst, En => En, D => signal_in, Q => D2_in);
	
	FF2: Latch_D
	port map(clk => clk, rst => rst, En => En, D => D2_in, Q => FF_out);
	
	rising_edge_flag <= D2_in and not FF_out;
	
end STRUCTURAL;