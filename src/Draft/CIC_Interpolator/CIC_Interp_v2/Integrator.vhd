library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Integrator is
	generic(N: in integer);
	port(	clk, rst: in std_logic;
		sample_freq: in std_logic;
		carry_in: in std_logic;
		input: in std_logic_vector(N-1 downto 0);
		carry_output: out std_logic;
		output: out std_logic_vector(N-1 downto 0)
		);
end Integrator;

architecture structural of Integrator is

component full_adder is
	generic(N : integer);
	port(	a 		: in  std_logic_vector (N-1 downto 0);
		b 		: in  std_logic_vector (N-1 downto 0);
		carry_in 	: in  std_logic;
		s 		: out std_logic_vector (N-1 downto 0);
		carry_out 	: out std_logic
		);
end component;

component truncate_shift is
	generic(MSB_nLSB: in integer range 0 to 1;
		size_in: in integer;
		shift_bits: in integer;
		truncate_bits: in integer);
	port(	input: in std_logic_vector(size_in-1 downto 0);
		clk, rst: in std_logic;
		output: out std_logic_vector(truncate_bits-1 downto 0)
		);
end component;

type Delay_Register is array(0 downto 0) of std_logic_vector(N-1 downto 0);
signal Delay_Register1: Delay_Register := (others => (others => '0'));
signal output_adder: std_logic_vector(N-1 downto 0) := (others => '0');
signal carry_out_adder: std_logic := '0';
signal count: integer range 0 to 1 := 0;
signal input_reg: std_logic_vector(N-1 downto 0) := (others => '0');
signal output_truncated: std_logic_vector(N-1 downto 0) := (others => '0');

begin

	process(clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				Delay_Register1 <= (others => (others => '0'));
			else
				if sample_freq = '1' then
					Delay_Register1(0) <= output_adder;
--					input_reg <= output_adder;
				end if;
			end if;
		end if;
	end process;

	--input_reg <= output_adder;

	Adder1_Integrator: full_adder
	generic map( N => N)
	port map( a => input , b => Delay_Register1(0) , carry_in => carry_in, s => output_adder, carry_out => carry_out_adder);

--	trunc_and_shift: convergent_rounding
--	generic map( MSB_nLSB => 0, size_in => N, shift_bits => 1, truncate_bits => N)
--	port map( input => output_adder, clk => clk, rst => rst, output => output_truncated);

	trunc_and_shift: truncate_shift
	generic map( MSB_nLSB => 0, size_in => N, shift_bits => 1, truncate_bits => N)
	port map( input => output_adder, clk => clk, rst => rst, output => output_truncated);

	output <= output_truncated;
	carry_output <= carry_out_adder;

--	process(clk)
--	begin
--		if clk'event and clk = '1' then
--			if rst = '1' then
--				output <= (others => '0');
--				carry_output <= '0';
--			else
--				output <= output_adder;
--				carry_output <= carry_out_adder;
--			end if;
--		end if;
--	end process;

end architecture;
