library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CIC_Interpolator is
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
end CIC_Interpolator;

architecture structural of CIC_Interpolator is

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

component zero_holder is
	generic(N: in integer;
		R: in integer);
	port(	sample_in: in std_logic_vector(N-1 downto 0);
		clk, rst: in std_logic;
		sample_freq: in std_logic;
		upsample_freq: in std_logic;
		sample_out: out std_logic_vector(N-1 downto 0)
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

signal input_extended: std_logic_vector(size_in+extension_bits-1 downto 0);
type array_signals is array(order-2 downto 0) of std_logic_vector(size_in+extension_bits-1 downto 0);
signal output_combs: array_signals;
signal carry_combs: std_logic_vector(order-2 downto 0);
signal output_integrators: array_signals;
signal carry_integrators: std_logic_vector(order-2 downto 0);
signal zero_stuff_out: std_logic_vector(size_in+extension_bits-1 downto 0);
signal output_truncated: std_logic_vector(size_out-1 downto 0);

begin
	
	extension_in: sign_extension
	generic map( size_in => size_in, extension_bits => extension_bits)
	port map(data_in => data_in, data_out => input_extended);
	
	Comb1: Comb
	generic map( N => size_in+extension_bits, D => D)
	port map( clk => clk, rst => rst, sample_freq => sample_freq, carry_in => '0', input => input_extended, carry_output => carry_combs(0) , output => output_combs(0));
	
	if_Comb_section: if order > 2 generate
		Comb_section: for i in 1 to order-2 generate
			Comb2: Comb
			generic map( N => size_in+extension_bits, D => D)
			port map( clk => clk, rst => rst, sample_freq => sample_freq, carry_in => carry_combs(i-1), input => output_combs(i-1), carry_output => carry_combs(i) , output => output_combs(i));
		end generate Comb_section;
	end generate if_Comb_section;

	Zero_holder1: zero_holder
	generic map( N => size_in+extension_bits, R => R)
	port map( sample_in => output_combs(order-2), clk => clk, rst => rst, sample_freq => sample_freq, upsample_freq => upsample_freq, sample_out => zero_stuff_out);

	Integrator1: Integrator
	generic map( N => size_in+extension_bits)
	port map( clk => clk, rst => rst, sample_freq => upsample_freq, carry_in => carry_combs(order-2), input => zero_stuff_out, carry_output => carry_integrators(0) , output => output_integrators(0));
	
	if_Integrator_section: if order > 2 generate
		Integrator_section: for i in 1 to order-2 generate
			Integrator2: Integrator
			generic map( N => size_in+extension_bits)
			port map( clk => clk, rst => rst, sample_freq => upsample_freq, carry_in => carry_integrators(i-1), input => output_integrators(i-1), carry_output => carry_integrators(i) , output => output_integrators(i));
		end generate Integrator_section;
	end generate if_Integrator_section;

	trunc_and_shift: truncate_shift
	generic map( MSB_nLSB => 0, size_in => size_in+extension_bits, shift_bits => gain_cic_bits, truncate_bits => size_out)
	port map( input => output_integrators(order-2), clk => clk, rst => rst, output => output_truncated);

	data_out <= output_truncated;

end architecture;
