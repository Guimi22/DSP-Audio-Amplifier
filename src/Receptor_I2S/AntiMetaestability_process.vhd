library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity AntiMetaestability_process is
port(	clk, rst, En, signal_in: in std_logic;
		signal_out: out std_logic
	);
end AntiMetaestability_process;

architecture STRUCTURAL of AntiMetaestability_process is
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
	
	signal_out <= FF_out;
	
end STRUCTURAL;