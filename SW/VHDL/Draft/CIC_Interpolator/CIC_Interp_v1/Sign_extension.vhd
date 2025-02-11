library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sign_extension is
	generic(size_in: in integer;
		extension_bits: in integer);
	port(	data_in: in std_logic_vector(size_in-1 downto 0);
		data_out: out std_logic_vector(size_in+extension_bits-1 downto 0)
		);
end sign_extension;

architecture beh of sign_extension is

signal zeros: std_logic_vector(extension_bits-1 downto 0);
signal ones: std_logic_vector(extension_bits-1 downto 0);
signal data_output: std_logic_vector(size_in+extension_bits-1 downto 0);

begin

	zero_vector: for i in 0 to extension_bits-1 generate
		zeros(i) <= '0';
	end generate zero_vector;

	one_vector: for i in 0 to extension_bits-1 generate
		ones(i) <= '1';
	end generate one_vector;

	with data_in(size_in-1) select
		data_output <=	zeros & data_in when '0',
				ones & data_in when others;

	data_out <= data_output;

end architecture;
