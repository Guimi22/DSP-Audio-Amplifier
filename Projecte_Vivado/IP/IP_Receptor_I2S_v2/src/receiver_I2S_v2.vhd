library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity receiver_I2S_v2 is
port( 	clk, sclk, rst, SD, WS: in std_logic;
	WS_level_flag: out std_logic;
	audio_out: out std_logic_vector(15 downto 0)
--	audio_out_R, audio_out_L: out std_logic_vector(15 downto 0)
	);
end receiver_I2S_v2;

architecture STRUCTURAL of receiver_I2S_v2 is
signal sclk_stb, SD_stb, WS_stb: std_logic;	--input signals after metastability delay
signal Q_out: std_logic;
signal sclk_rising_edge_En: std_logic; 	
signal data_register_out: std_logic_vector(15 downto 0);
signal WSP: std_logic;	--pulse generated when WS changes levels
signal en_buffer_R, en_buffer_L: std_logic;
signal audio_out_vector: std_logic_vector(15 downto 0);
signal read_EN: std_logic_vector(15 downto 0);
signal WSD_s: std_logic;
signal serial_in: std_logic_vector(16 downto 0);
signal parallel_out: std_logic_vector(15 downto 0);
type SD_delay is array(0 to 1) of std_logic;
signal SD_reg: SD_delay;

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

component Latch_D
port(	clk, rst, En, D: in std_logic;
		Q: out std_logic
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
	port map(clk => clk, rst => rst, En => sclk_rising_edge_En, WS_in => WS_stb, WSD => WSD_s, WS_Pulse => WSP);

	serial_in(0) <= WSP;
	FF1: Latch_D 
	port map(clk => clk, rst => rst, En => sclk_rising_edge_En, D => serial_in(0), Q => serial_in(1));

	for_EN_PIPO:	for i in 1 to 15 generate
			FF: Latch_D 
			port map(clk => clk, rst => WSP, En => sclk_rising_edge_En, D => serial_in(i), Q => serial_in(i+1));
	end generate for_EN_PIPO;

	process(clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				read_EN <= (others => '0');
				SD_reg <= (others => ('0'));
			else
				if sclk_rising_edge_En = '1' then
					SD_reg(1) <= SD_reg(0);
					SD_reg(0) <= SD_stb;
					for i in 16 downto 1 loop
						read_EN(16-i) <= serial_in(i);
					end loop;
					--read_EN <= serial_in(16 downto 1);
				end if;
			end if;
		end if;
	end process;

	for_PIPO_SD:	for i in 0 to 15 generate
			FF: Latch_D 
			port map(clk => clk, rst => rst, En => read_EN(i), D => SD_reg(1), Q => parallel_out(i));
	end generate for_PIPO_SD;

	PIPO_reg1: PIPO_register
	generic map(N => 16)
	port map(clk => clk, rst => rst, Wr => WSP, Data_in => parallel_out, Data_out => audio_out); 
	

--	en_buffer_R <= WSP and WSD_s;
--	en_buffer_L <= WSP and not WSD_s;
--
--	PIPO_reg1: PIPO_register
--	generic map(N => 16)
--	port map(clk => clk, rst => rst, Wr => en_buffer_R, Data_in => parallel_out, Data_out => audio_out_R); 
--	
--	PIPO_reg2: PIPO_register
--	generic map(N => 16)
--	port map(clk => clk, rst => rst, Wr => en_buffer_L, Data_in => parallel_out, Data_out => audio_out_L); 
--	
	WS_level_flag <= WSP;

end STRUCTURAL;
