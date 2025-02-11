library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity SIPO_Register is
generic( N: integer );
port(	clk, rst, En, Data_in: in std_logic; 
		Data_out: out std_logic_vector(N-1 downto 0)
	);
end SIPO_Register;

architecture STRUCTURAL of SIPO_Register is
signal serial_in: std_logic_vector(N downto 0) := (others => '0');
signal sync_sclk: std_logic;

component Latch_D
port(	clk, rst, En, D: in std_logic;
		Q: out std_logic
	);
end component;

begin
	serial_in(0) <= Data_in;
	Data_out <= serial_in(N downto 1);
	for1:	for i in 0 to N-1 generate
				FF: Latch_D 
				port map(clk => clk, rst => rst, En => En, D => serial_in(i), Q => serial_in(i+1));
	end generate for1;

end STRUCTURAL;