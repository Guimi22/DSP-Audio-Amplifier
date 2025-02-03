library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity truncate_shift is
	generic(MSB_nLSB: in integer range 0 to 1;
		size_in: in integer;
		shift_bits: in integer;
		truncate_bits: in integer);
	port(	input: in std_logic_vector(size_in-1 downto 0);
		clk, rst: in std_logic;
		output: out std_logic_vector(truncate_bits-1 downto 0)
		);
end truncate_shift;

architecture beh of truncate_shift is

signal truncated_out: std_logic_vector(truncate_bits-1 downto 0);
signal shifted_signal: std_logic_vector(size_in-1 downto 0);
signal zeros: std_logic_vector(shift_bits-1 downto 0);
signal ones: std_logic_vector(shift_bits-1 downto 0);

begin

	zeros_generate: for i in 0 to shift_bits-1 generate
		zeros(i) <= '0';
	end generate zeros_generate;

	one_vector: for i in 0 to shift_bits-1 generate
		ones(i) <= '1';
	end generate one_vector;
	
	with input(size_in-1) select
		shifted_signal <=	zeros & input(size_in-1 downto shift_bits) when '0',
					ones & input(size_in-1 downto shift_bits) when others;
--
--	process(input)
--	begin
--		if MSB_nLSB = 1 then
--			truncated_out <= shifted_signal(size_in-1 downto size_in-truncate_bits);
--		elsif MSB_nLSB = 0 then
--			truncated_out <= shifted_signal(truncate_bits-1 downto 0);
--		end if;
--	end process;

--	shifted_signal <= zeros & input(size_in-1 downto shift_bits);

	process(clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				output <= (others => '0');
			else
				if MSB_nLSB = 1 then
					output <= shifted_signal(size_in-1 downto size_in-truncate_bits);
				else
					output <= shifted_signal(truncate_bits-1 downto 0);
				end if;
			end if;
		end if;
	end process;

--	with MSB_nLSB select 
--		output <= 	shifted_signal(size_in-1 downto size_in-truncate_bits) when 1,
--				shifted_signal(truncate_bits-1 downto 0) when others;

end architecture;
