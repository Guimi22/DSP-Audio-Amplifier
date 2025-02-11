library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity Latch_D is
port(	clk, rst, En, D: in std_logic;
		Q: out std_logic
	);
end Latch_D;

architecture BEH of Latch_D is
begin
	Latch: process(clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				Q <= '0';
			elsif En = '1' then
				Q <= D;
			end if;
		end if;
	end process;
				
end BEH;