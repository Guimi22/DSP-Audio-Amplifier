library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity convergent_rounding is
	generic(MSB_nLSB: in integer range 0 to 1;
		size_in: in integer;
		shift_bits: in integer;
		truncate_bits: in integer);
	port(	input: in std_logic_vector(size_in-1 downto 0);
		clk, rst: in std_logic;
		output: out std_logic_vector(truncate_bits-1 downto 0)
		);
end convergent_rounding;

architecture beh of convergent_rounding is

component full_adder is
	generic(N : integer);
	port(	a 		: in  std_logic_vector (N-1 downto 0);
		b 		: in  std_logic_vector (N-1 downto 0);
		carry_in 	: in  std_logic;
		s 		: out std_logic_vector (N-1 downto 0);
		carry_out 	: out std_logic
		);
end component;

signal zeros_offset: std_logic_vector(truncate_bits-1 downto 0) := (others => '0');
signal zeros: std_logic_vector(shift_bits-1 downto 0) := (others => '0');
signal ones: std_logic_vector(shift_bits-1 downto 0) := (others => '0');
signal shifted_signal: std_logic_vector(size_in-1 downto 0) := (others => '0');
signal zeros_rnd: std_logic_vector(size_in-truncate_bits-2 downto 0) := (others => '0');
signal ones_rnd: std_logic_vector(size_in-truncate_bits-2 downto 0) := (others => '0');
signal offset: std_logic_vector(size_in-1 downto 0) := (others => '0');
signal output_adder: std_logic_vector(size_in-1 downto 0) := (others => '0');
signal carry_out_adder: std_logic := '0';

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

	zeros_offset_generate: for i in 0 to truncate_bits-1 generate
		zeros_offset(i) <= '0';
	end generate zeros_offset_generate;
	
	zeros_rnd_bit_generate: for i in 0 to size_in-truncate_bits-2 generate
		zeros_rnd(i) <= '0';
	end generate zeros_rnd_bit_generate;

	ones_rnd_bit_generate: for i in 0 to size_in-truncate_bits-2 generate
		ones_rnd(i) <= '1';
	end generate ones_rnd_bit_generate;

--	process(input)
--	begin
--		for i in 0 to size_in-truncate_bits-2 loop 
--			not_rnd_bit(i) <= not input(size_in-truncate_bits);
--		end loop;
--	end process;

	with input(size_in-truncate_bits) select
		offset <= 	zeros_offset & input(size_in-truncate_bits) & ones_rnd when '0',
				zeros_offset & input(size_in-truncate_bits) & zeros_rnd when others;

	Adder1_comb: full_adder
	generic map( N => size_in)
	port map( a => shifted_signal , b => offset , carry_in => '0', s => output_adder, carry_out => carry_out_adder);

	process(clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				output <= (others => '0');
			else
				if MSB_nLSB = 1 then
					output <= output_adder(size_in-1 downto size_in-truncate_bits);
				else
					output <= output_adder(truncate_bits-1 downto 0);
				end if;
			end if;
		end if;
	end process;

end architecture;