library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity top is
port( 	clk: in std_logic;
	rst: in std_logic;
	sclk: in std_logic;
	audio_in: in std_logic_vector(15 downto 0);
	fs_upsample: out std_logic;
	audio_out: out signed(15 downto 0)
	);
end top;

architecture STRUCTURAL of top is

constant size_pipeline: integer := 45;
constant size_coeff: integer := 91;
--type array_signed is array (0 to size_coeff-1) of signed(15 downto 0);
--type array_vector is array (0 to size_pipeline) of std_logic_vector(15 downto 0);
--signal buffer_array: array_vector;
--signal coeff_array: array_signed;
signal audio_out_fir1: signed(15 downto 0);
signal audio_out_fir2: signed(15 downto 0);
signal frequency_in_2x: std_logic;
signal not_used1: std_logic;
signal not_used2 : std_logic;
signal not_used3 : std_logic;
signal not_used4 : std_logic;
signal not_used5 : std_logic;
signal not_used6 : std_logic;
signal not_used7 : std_logic;
signal not_used8 : std_logic;
signal not_used9 : std_logic;
signal audio_filtered1: std_logic;
signal audio_filtered2: std_logic;
signal sclk_edge_flag: std_logic;

component polyphase_FIR is
	generic(size_ROM: integer := 91;
		size_pipeline_delay: integer := 45);
	port(	data_in: in std_logic_vector(15 downto 0);
		even_odd: in std_logic;
		clk: in std_logic;
		sclk_edge_flag: in std_logic;
		rst: in std_logic;
		audio_out: out signed(15 downto 0);
		audio_conv: out std_logic
		);
end component;

component upsampler_frequency_2x is
	generic( module: integer := 2
		);
	port(	clk: in std_logic;
		rst: in std_logic;
		sclk_flag: in std_logic;
		fs_up1 : out std_logic;
		fs_up2 : out std_logic;
		fs_up3 : out std_logic;
		fs_up4 : out std_logic;
		fs_up5 : out std_logic;
		fs_up6 : out std_logic;
		fs_up7 : out std_logic;
		fs_up8 : out std_logic;
		fs_up9 : out std_logic;
		fs_up10: out std_logic
		);
end component;

component output_control_unit is
	port(	clk: in std_logic;
		rst: in std_logic;
		filter1: in signed(15 downto 0);
		filter2: in signed(15 downto 0);
		audio_conv1: in std_logic;
		audio_conv2: in std_logic;
		fs_in: in std_logic;
		audio_out: out signed(15 downto 0)
		);
end component;

component Rising_edge_detector is
port(	clk, rst, En, signal_in: in std_logic;
		rising_edge_flag: out std_logic
	);
end component;

begin

	sclk_enable: Rising_edge_detector
	port map(clk => clk, rst => rst, En => '1', signal_in => sclk, rising_edge_flag => sclk_edge_flag);	

	freq_upsample: upsampler_frequency_2x
	generic map( module => 64)
	port map( clk => clk, rst => rst, sclk_flag => sclk_edge_flag, fs_up1 => not_used5, fs_up2 => not_used1, fs_up3 => not_used2, fs_up4 => not_used3, fs_up5 => not_used4, fs_up6 => frequency_in_2x, fs_up7 => not_used6, fs_up8 => not_used7, fs_up9 => not_used8, fs_up10 => not_used9);	

	polyphase_filter1: polyphase_FIR
	generic map( size_ROM => size_coeff, size_pipeline_delay => size_pipeline)
	port map( data_in => audio_in, even_odd => '0', clk => clk, sclk_edge_flag => sclk_edge_flag, rst => rst, audio_out => audio_out_fir1, audio_conv => audio_filtered1);
	
	polyphase_filter2: polyphase_FIR
	generic map( size_ROM => size_coeff, size_pipeline_delay => size_pipeline)
	port map( data_in => audio_in, even_odd => '1', clk => clk, sclk_edge_flag => sclk_edge_flag, rst => rst, audio_out => audio_out_fir2, audio_conv => audio_filtered2);
	
	output_CU: output_control_unit
	port map( clk => clk, rst => rst, filter1 => audio_out_fir1, filter2 => audio_out_fir2, audio_conv1 => audio_filtered1, audio_conv2 => audio_filtered2, fs_in => frequency_in_2x, audio_out => audio_out);

	fs_upsample <= frequency_in_2x;

end STRUCTURAL;
