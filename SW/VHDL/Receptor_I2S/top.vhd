library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity top is
port( 	clk, sclk, rst, SD, WS: in std_logic;
	WS_level_flag: out std_logic;
	audio_out: out std_logic_vector(15 downto 0)
	);
end top;

architecture STRUCTURAL of top is
signal sclk_stb, SD_stb, WS_stb: std_logic;	--input signals after metastability delay
signal Q_out: std_logic;
signal sclk_rising_edge_En: std_logic; 	
signal data_register_out: std_logic_vector(16 downto 0);
signal WSP,WSD: std_logic;	--pulse generated when WS changes levels
signal en_buffer: std_logic;
signal audio_out_vector: std_logic_vector(15 downto 0);

component AntiMetaestability_process is
port(	clk, rst, En, signal_in: in std_logic;
	signal_out: out std_logic
	);
end component;

component Rising_edge_detector is
port(	clk, rst, En, signal_in: in std_logic;
	rising_edge_flag: out std_logic
	);
end component;

component SIPO_Register is
generic( N: integer );
port(	clk, rst, En, Data_in: in std_logic; 
	Data_out: out std_logic_vector(N-1 downto 0)
	);
end component;

component WS_level_detector is
port(	clk, rst, En, WS_in: in std_logic;
	WSD, WS_Pulse: out std_logic
	);
end component;

component counter is
generic( N: integer );
port( 	clk, rst, Trigger, En: in std_logic;	--counter starts with pulse at Trigger
	count_flag: out std_logic -- '1' when counter has overflown
	);
end component;

component PIPO_Register is
generic(N: integer );
port(	clk, rst, Wr: in std_logic; 
	Data_in: in std_logic_vector(N-1 downto 0);
	Data_out: out std_logic_vector(N-1 downto 0)
	);
end component;

begin
	Sclk_stable: AntiMetaestability_process
	port map(clk => clk, rst => rst, En => '1', signal_in => sclk, signal_out => sclk_stb);

	WS_stable: AntiMetaestability_process
	port map(clk => clk, rst => rst, En => '1', signal_in => WS, signal_out => WS_stb);

	SD_stable: AntiMetaestability_process
	port map(clk => clk, rst => rst, En => '1', signal_in => SD, signal_out => SD_stb);

	Sclk_syn: Rising_edge_detector
	port map(clk => clk, rst => rst, En => '1', signal_in => sclk_stb, rising_edge_flag => sclk_rising_edge_En);	
	
	WS_edge: WS_level_detector 
	port map(clk => clk, rst => rst, En => sclk_rising_edge_En, WS_in => WS_stb, WSD => WSD, WS_Pulse => WSP);
	
	audio_word_bit_counter: counter
	generic map(N => 16)
	port map(clk => clk, rst => rst, Trigger => WSP, En => sclk_rising_edge_En, count_flag => en_buffer);

	Register1: SIPO_Register
	generic map(N => 17)
	port map(clk => clk, rst => rst , En => sclk_rising_edge_En, Data_in => SD_stb, Data_out => data_register_out);
	
	PIPO_reg1: PIPO_register
	generic map(N => 16)
	port map(clk => clk, rst => rst, Wr => en_buffer, Data_in => data_register_out(16 downto 1), Data_out => audio_out); 
	
	WS_level_flag <= WSP;

end STRUCTURAL;