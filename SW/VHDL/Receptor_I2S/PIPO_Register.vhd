library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity PIPO_Register is
generic(N: integer );
port(	clk, rst, Wr: in std_logic; 
	Data_in: in std_logic_vector(N-1 downto 0);
	Data_out: out std_logic_vector(N-1 downto 0)
	);
end PIPO_Register;

architecture STRUCTURAL of PIPO_Register is

signal parallel_in: std_logic_vector(N-1 downto 0) := (others => '0');
signal parallel_out: std_logic_vector(N-1 downto 0) := (others => '0');
signal sync_sclk: std_logic;

component Latch_D
port(	clk, rst, En, D: in std_logic;
	Q: out std_logic
	);
end component;

begin
	parallel_in <= Data_in;
	Data_out <= parallel_out;

	PIPO_reg:for i in 0 to N-1 generate
			FF: Latch_D 
			port map(clk => clk, rst => rst, En => Wr, D => parallel_in(i), Q => parallel_out(i));
	end generate PIPO_reg;

end STRUCTURAL;

	