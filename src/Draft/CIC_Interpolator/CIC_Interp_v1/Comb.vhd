library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Comb is
	generic(N: in integer;
		D: in integer);
	port(	clk, rst: in std_logic;
		sample_freq: in std_logic;
		carry_in: in std_logic;
		input: in std_logic_vector(N-1 downto 0);
		carry_output: out std_logic;
		output: out std_logic_vector(N-1 downto 0)
		);
end Comb;

architecture structural of Comb is

component full_adder is
	generic(N : integer);
	port(	a 		: in  std_logic_vector (N-1 downto 0);
		b 		: in  std_logic_vector (N-1 downto 0);
		carry_in 	: in  std_logic;
		s 		: out std_logic_vector (N-1 downto 0);
		carry_out 	: out std_logic
		);
end component;

component two_complement is
	generic(N: in integer);
	port(	input: in std_logic_vector(N-1 downto 0);
		output: out std_logic_vector(N-1 downto 0)
		);
end component;

type Delay_Register is array(D-1 downto 0) of std_logic_vector(N-1 downto 0);
signal Delay_Register1: Delay_Register;
signal signed_input: std_logic_vector(N-1 downto 0);
signal input_reg: std_logic_vector(N-1 downto 0);
signal count: integer range 0 to 1;
signal count2: integer range 0 to 1;
signal output_adder: std_logic_vector(N-1 downto 0);
signal carry_out_adder: std_logic;

begin

	two_complement_comb: two_complement
	generic map( N => N)
	port map( input => input , output => signed_input);

	process(clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				Delay_Register1 <= (others => (others => '0'));
			else
				if sample_freq = '1' then
					if D >= 2 then
						if count < 1 then
							Delay_Register1(D-1 downto 1) <= (others => (others => '0'));
							Delay_Register1(0) <= signed_input;
							count <= 1;
						else
							Delay_Register1(D-1 downto 1) <= Delay_Register1(D-2 downto 0);
							Delay_Register1(0) <= signed_input;
						end if;
					else
						if count < 1 then
							Delay_Register1(0) <= (others => '0');
							count <= 1;
						else
							Delay_Register1(0) <= input_reg;
--						input_reg <= signed_input;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;

	input_reg <= signed_input;

	Adder1_comb: full_adder
	generic map( N => N)
	port map( a => input , b => Delay_Register1(D-1) , carry_in => carry_in, s => output_adder, carry_out => carry_out_adder);

	process(clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				output <= (others => '0');
				carry_output <= '0';
			else
				if count2 < 1 then
					output <= (others => '0');
					carry_output <= '0';
					count2 <= 1;
				else
					output <= output_adder;
					carry_output <= carry_out_adder;
				end if;
			end if;
		end if;
	end process;

end architecture;
		