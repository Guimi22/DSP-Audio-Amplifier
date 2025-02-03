library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity zero_insertion is
	generic(size_in: in integer;
		R: in integer);
	port(	sample_in: in std_logic_vector(size_in-1 downto 0);
		clk, rst: in std_logic;
		sample_freq: in std_logic;
		sample_out: out std_logic_vector(size_in-1 downto 0)
		);
end zero_insertion;

architecture beh of zero_insertion is

signal count: integer range 0 to R-1;

begin

	process(clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				sample_out <= (others => '0');
				count <= 0;
			else
				if sample_freq = '1' and count < R-1 then
					sample_out <= (others => '0');
					count <= count + 1;
				elsif sample_freq = '1' and count = R-1 then
					sample_out <= sample_in;
					count <= 0;
				end if;
			end if;
		end if;
	end process;			
	
end architecture;
