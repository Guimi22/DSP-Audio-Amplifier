library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CIC_Interpolator_v2 is
	generic(size_in: in integer;
		extension_bits: in integer;
		size_out: in integer;
		gain_cic_bits: in integer;
		D: in integer;
		R: in integer;
		order: in integer);
	port(	clk, rst: in std_logic;
		sample_freq: in std_logic;
		upsample_freq: in std_logic;
		data_in: in std_logic_vector(size_in-1 downto 0);
		data_out: out std_logic_vector(size_out-1 downto 0)
		);
end CIC_Interpolator_v2;

architecture structural of CIC_Interpolator_v2 is

component sign_extension is
	generic(size_in: in integer;
		extension_bits: in integer);
	port(	data_in: in std_logic_vector(size_in-1 downto 0);
		data_out: out std_logic_vector(size_in+extension_bits-1 downto 0)
		);
end component;

component Comb is
	generic(N: in integer;
		D: in integer);
	port(	clk, rst: in std_logic;
		sample_freq: in std_logic;
		carry_in: in std_logic;
		input: in std_logic_vector(N-1 downto 0);
		carry_output: out std_logic;
		output: out std_logic_vector(N-1 downto 0)
		);
end component;

component Integrator is
	generic(N: in integer);
	port(	clk, rst: in std_logic;
		sample_freq: in std_logic;
		carry_in: in std_logic;
		input: in std_logic_vector(N-1 downto 0);
		carry_output: out std_logic;
		output: out std_logic_vector(N-1 downto 0)
		);
end component;

component zero_insertion is
	generic(size_in: in integer;
		R: in integer);
	port(	sample_in: in std_logic_vector(size_in-1 downto 0);
		clk, rst: in std_logic;
		sample_freq: in std_logic;
		sample_out: out std_logic_vector(size_in-1 downto 0)
		);
end component;

--component truncate_shift is
--	generic(MSB_nLSB: in integer range 0 to 1;
--		size_in: in integer;
--		shift_bits: in integer;
--		truncate_bits: in integer);
--	port(	input: in std_logic_vector(size_in-1 downto 0);
--		clk, rst: in std_logic;
--		output: out std_logic_vector(truncate_bits-1 downto 0)
--		);
--end component;

component convergent_rounding is
	generic(MSB_nLSB: in integer range 0 to 1;
		size_in: in integer;
		shift_bits: in integer;
		truncate_bits: in integer);
	port(	input: in std_logic_vector(size_in-1 downto 0);
		clk, rst: in std_logic;
		output: out std_logic_vector(truncate_bits-1 downto 0)
		);
end component;

signal input_extended: std_logic_vector(size_in+extension_bits-1 downto 0);
type array_signals is array(order-1 downto 0) of std_logic_vector(size_in+extension_bits-1 downto 0);
signal output_combs: array_signals := (others => (others => '0'));
signal carry_combs: std_logic_vector(order-1 downto 0) := (others => '0');
signal output_integrators: array_signals := (others => (others => '0'));
signal carry_integrators: std_logic_vector(order-1 downto 0) := (others => '0');
signal zero_stuff_out: std_logic_vector(size_in+extension_bits-1 downto 0) := (others => '0');
signal output_truncated: std_logic_vector(size_out-1 downto 0) := (others => '0');

begin
	
	extension_in: sign_extension
	generic map( size_in => size_in, extension_bits => extension_bits)
	port map(data_in => data_in, data_out => input_extended);
	
	Comb_section: for i in 0 to order-2 generate
		Comb1: Comb
		generic map( N => size_in+extension_bits, D => D)
		port map( clk => clk, rst => rst, sample_freq => sample_freq, carry_in => carry_combs(i), input => output_combs(i), carry_output => carry_combs(i+1) , output => output_combs(i+1));
	end generate Comb_section;

	carry_combs(0) <= '0';
	output_combs(0) <= input_extended;

	Zero_insertion1: zero_insertion
	generic map( size_in => size_in+extension_bits, R => R)
	port map( sample_in => output_combs(order-1), clk => clk, rst => rst, sample_freq => upsample_freq, sample_out => zero_stuff_out);

	output_integrators(0) <= zero_stuff_out;
	carry_integrators(0) <= carry_combs(order-1);

	Integrator_section: for i in 0 to order-2 generate
		Integrator1: Integrator
		generic map( N => size_in+extension_bits)
		port map( clk => clk, rst => rst, sample_freq => upsample_freq, carry_in => carry_integrators(i), input => output_integrators(i), carry_output => carry_integrators(i+1) , output => output_integrators(i+1));
	end generate Integrator_section;

--	trunc_and_shift: truncate_shift
--	generic map( MSB_nLSB => 0, size_in => size_in+extension_bits, shift_bits => gain_cic_bits, truncate_bits => size_out)
--	port map( input => output_integrators(order-1), clk => clk, rst => rst, output => output_truncated);

	trunc_and_shift: convergent_rounding
	generic map( MSB_nLSB => 0, size_in => size_in+extension_bits, shift_bits => gain_cic_bits, truncate_bits => size_out)
	port map( input => output_integrators(order-1), clk => clk, rst => rst, output => output_truncated);

	data_out <= output_truncated;
--	data_out <= output_integrators(order-1);

end architecture;
