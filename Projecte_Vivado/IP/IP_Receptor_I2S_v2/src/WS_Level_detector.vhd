library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity WS_level_detector is
port(	clk, rst, En, WS_in: in std_logic;
	WSD, WS_Pulse: out std_logic
	);
end WS_level_detector;

architecture STRUCTURAL of WS_level_detector is
signal WSD_s: std_logic;
signal FF_out: std_logic;

component Latch_D is
port(	clk, rst, En, D: in std_logic;
		Q: out std_logic
	);
end component;

begin
	
	FF1: Latch_D
	port map(clk => clk, rst => rst, En => En, D => WS_in, Q => WSD_s);

	WSD <= WSD_s;
	
	FF2: Latch_D
	port map(clk => clk, rst => rst, En => En, D => WSD_s, Q => FF_out);
	
	WS_Pulse <= WSD_s xor FF_out;
	
end STRUCTURAL;
