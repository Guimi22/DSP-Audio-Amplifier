library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity Latch_D is
port(	clk, rst, En, D: in std_logic;
		Q: out std_logic
	);
end Latch_D;

architecture BEH of Latch_D is

signal Q_out: std_logic := '0';

begin
	Latch: process(clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				Q_out <= '0';
			elsif En = '1' then
				Q_out <= D;
			end if;
		end if;
	end process;

	Q <= Q_out;
				
end BEH;