library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity polyphase_FIR is
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
end polyphase_FIR;

architecture rtl of polyphase_FIR is

type array_signed is array (0 to size_ROM-1) of signed(15 downto 0);
type array_vector is array (0 to size_pipeline_delay) of std_logic_vector(15 downto 0);
signal products_array: array_signed;
signal multiplier: signed(31 downto 0);
signal accumulator: signed(31 downto 0);

signal ROM_coeff: array_signed;

CONSTANT coeff1                         : signed(15 DOWNTO 0) := to_signed(-3, 16); -- sfix16_En15
CONSTANT coeff2                         : signed(15 DOWNTO 0) := to_signed(4, 16); -- sfix16_En15
CONSTANT coeff3                         : signed(15 DOWNTO 0) := to_signed(-6, 16); -- sfix16_En15
CONSTANT coeff4                         : signed(15 DOWNTO 0) := to_signed(9, 16); -- sfix16_En15
CONSTANT coeff5                         : signed(15 DOWNTO 0) := to_signed(-13, 16); -- sfix16_En15
CONSTANT coeff6                         : signed(15 DOWNTO 0) := to_signed(18, 16); -- sfix16_En15
CONSTANT coeff7                         : signed(15 DOWNTO 0) := to_signed(-24, 16); -- sfix16_En15
CONSTANT coeff8                         : signed(15 DOWNTO 0) := to_signed(31, 16); -- sfix16_En15
CONSTANT coeff9                         : signed(15 DOWNTO 0) := to_signed(-39, 16); -- sfix16_En15
CONSTANT coeff10                        : signed(15 DOWNTO 0) := to_signed(48, 16); -- sfix16_En15
CONSTANT coeff11                        : signed(15 DOWNTO 0) := to_signed(-57, 16); -- sfix16_En15
CONSTANT coeff12                        : signed(15 DOWNTO 0) := to_signed(67, 16); -- sfix16_En15
CONSTANT coeff13                        : signed(15 DOWNTO 0) := to_signed(-77, 16); -- sfix16_En15
CONSTANT coeff14                        : signed(15 DOWNTO 0) := to_signed(87, 16); -- sfix16_En15
CONSTANT coeff15                        : signed(15 DOWNTO 0) := to_signed(-95, 16); -- sfix16_En15
CONSTANT coeff16                        : signed(15 DOWNTO 0) := to_signed(102, 16); -- sfix16_En15
CONSTANT coeff17                        : signed(15 DOWNTO 0) := to_signed(-107, 16); -- sfix16_En15
CONSTANT coeff18                        : signed(15 DOWNTO 0) := to_signed(108, 16); -- sfix16_En15
CONSTANT coeff19                        : signed(15 DOWNTO 0) := to_signed(-106, 16); -- sfix16_En15
CONSTANT coeff20                        : signed(15 DOWNTO 0) := to_signed(99, 16); -- sfix16_En15
CONSTANT coeff21                        : signed(15 DOWNTO 0) := to_signed(-87, 16); -- sfix16_En15
CONSTANT coeff22                        : signed(15 DOWNTO 0) := to_signed(69, 16); -- sfix16_En15
CONSTANT coeff23                        : signed(15 DOWNTO 0) := to_signed(-45, 16); -- sfix16_En15
CONSTANT coeff24                        : signed(15 DOWNTO 0) := to_signed(12, 16); -- sfix16_En15
CONSTANT coeff25                        : signed(15 DOWNTO 0) := to_signed(28, 16); -- sfix16_En15
CONSTANT coeff26                        : signed(15 DOWNTO 0) := to_signed(-76, 16); -- sfix16_En15
CONSTANT coeff27                        : signed(15 DOWNTO 0) := to_signed(132, 16); -- sfix16_En15
CONSTANT coeff28                        : signed(15 DOWNTO 0) := to_signed(-197, 16); -- sfix16_En15
CONSTANT coeff29                        : signed(15 DOWNTO 0) := to_signed(269, 16); -- sfix16_En15
CONSTANT coeff30                        : signed(15 DOWNTO 0) := to_signed(-349, 16); -- sfix16_En15
CONSTANT coeff31                        : signed(15 DOWNTO 0) := to_signed(435, 16); -- sfix16_En15
CONSTANT coeff32                        : signed(15 DOWNTO 0) := to_signed(-526, 16); -- sfix16_En15
CONSTANT coeff33                        : signed(15 DOWNTO 0) := to_signed(622, 16); -- sfix16_En15
CONSTANT coeff34                        : signed(15 DOWNTO 0) := to_signed(-721, 16); -- sfix16_En15
CONSTANT coeff35                        : signed(15 DOWNTO 0) := to_signed(821, 16); -- sfix16_En15
CONSTANT coeff36                        : signed(15 DOWNTO 0) := to_signed(-921, 16); -- sfix16_En15
CONSTANT coeff37                        : signed(15 DOWNTO 0) := to_signed(1018, 16); -- sfix16_En15
CONSTANT coeff38                        : signed(15 DOWNTO 0) := to_signed(-1112, 16); -- sfix16_En15
CONSTANT coeff39                        : signed(15 DOWNTO 0) := to_signed(1200, 16); -- sfix16_En15
CONSTANT coeff40                        : signed(15 DOWNTO 0) := to_signed(-1280, 16); -- sfix16_En15
CONSTANT coeff41                        : signed(15 DOWNTO 0) := to_signed(1351, 16); -- sfix16_En15
CONSTANT coeff42                        : signed(15 DOWNTO 0) := to_signed(-1411, 16); -- sfix16_En15
CONSTANT coeff43                        : signed(15 DOWNTO 0) := to_signed(1460, 16); -- sfix16_En15
CONSTANT coeff44                        : signed(15 DOWNTO 0) := to_signed(-1495, 16); -- sfix16_En15
CONSTANT coeff45                        : signed(15 DOWNTO 0) := to_signed(1516, 16); -- sfix16_En15
CONSTANT coeff46                        : signed(15 DOWNTO 0) := to_signed(31244, 16); -- sfix16_En15
CONSTANT coeff47                        : signed(15 DOWNTO 0) := to_signed(1516, 16); -- sfix16_En15
CONSTANT coeff48                        : signed(15 DOWNTO 0) := to_signed(-1495, 16); -- sfix16_En15
CONSTANT coeff49                        : signed(15 DOWNTO 0) := to_signed(1460, 16); -- sfix16_En15
CONSTANT coeff50                        : signed(15 DOWNTO 0) := to_signed(-1411, 16); -- sfix16_En15
CONSTANT coeff51                        : signed(15 DOWNTO 0) := to_signed(1351, 16); -- sfix16_En15
CONSTANT coeff52                        : signed(15 DOWNTO 0) := to_signed(-1280, 16); -- sfix16_En15
CONSTANT coeff53                        : signed(15 DOWNTO 0) := to_signed(1200, 16); -- sfix16_En15
CONSTANT coeff54                        : signed(15 DOWNTO 0) := to_signed(-1112, 16); -- sfix16_En15
CONSTANT coeff55                        : signed(15 DOWNTO 0) := to_signed(1018, 16); -- sfix16_En15
CONSTANT coeff56                        : signed(15 DOWNTO 0) := to_signed(-921, 16); -- sfix16_En15
CONSTANT coeff57                        : signed(15 DOWNTO 0) := to_signed(821, 16); -- sfix16_En15
CONSTANT coeff58                        : signed(15 DOWNTO 0) := to_signed(-721, 16); -- sfix16_En15
CONSTANT coeff59                        : signed(15 DOWNTO 0) := to_signed(622, 16); -- sfix16_En15
CONSTANT coeff60                        : signed(15 DOWNTO 0) := to_signed(-526, 16); -- sfix16_En15
CONSTANT coeff61                        : signed(15 DOWNTO 0) := to_signed(435, 16); -- sfix16_En15
CONSTANT coeff62                        : signed(15 DOWNTO 0) := to_signed(-349, 16); -- sfix16_En15
CONSTANT coeff63                        : signed(15 DOWNTO 0) := to_signed(269, 16); -- sfix16_En15
CONSTANT coeff64                        : signed(15 DOWNTO 0) := to_signed(-197, 16); -- sfix16_En15
CONSTANT coeff65                        : signed(15 DOWNTO 0) := to_signed(132, 16); -- sfix16_En15
CONSTANT coeff66                        : signed(15 DOWNTO 0) := to_signed(-76, 16); -- sfix16_En15
CONSTANT coeff67                        : signed(15 DOWNTO 0) := to_signed(28, 16); -- sfix16_En15
CONSTANT coeff68                        : signed(15 DOWNTO 0) := to_signed(12, 16); -- sfix16_En15
CONSTANT coeff69                        : signed(15 DOWNTO 0) := to_signed(-45, 16); -- sfix16_En15
CONSTANT coeff70                        : signed(15 DOWNTO 0) := to_signed(69, 16); -- sfix16_En15
CONSTANT coeff71                        : signed(15 DOWNTO 0) := to_signed(-87, 16); -- sfix16_En15
CONSTANT coeff72                        : signed(15 DOWNTO 0) := to_signed(99, 16); -- sfix16_En15
CONSTANT coeff73                        : signed(15 DOWNTO 0) := to_signed(-106, 16); -- sfix16_En15
CONSTANT coeff74                        : signed(15 DOWNTO 0) := to_signed(108, 16); -- sfix16_En15
CONSTANT coeff75                        : signed(15 DOWNTO 0) := to_signed(-107, 16); -- sfix16_En15
CONSTANT coeff76                        : signed(15 DOWNTO 0) := to_signed(102, 16); -- sfix16_En15
CONSTANT coeff77                        : signed(15 DOWNTO 0) := to_signed(-95, 16); -- sfix16_En15
CONSTANT coeff78                        : signed(15 DOWNTO 0) := to_signed(87, 16); -- sfix16_En15
CONSTANT coeff79                        : signed(15 DOWNTO 0) := to_signed(-77, 16); -- sfix16_En15
CONSTANT coeff80                        : signed(15 DOWNTO 0) := to_signed(67, 16); -- sfix16_En15
CONSTANT coeff81                        : signed(15 DOWNTO 0) := to_signed(-57, 16); -- sfix16_En15
CONSTANT coeff82                        : signed(15 DOWNTO 0) := to_signed(48, 16); -- sfix16_En15
CONSTANT coeff83                        : signed(15 DOWNTO 0) := to_signed(-39, 16); -- sfix16_En15
CONSTANT coeff84                        : signed(15 DOWNTO 0) := to_signed(31, 16); -- sfix16_En15
CONSTANT coeff85                        : signed(15 DOWNTO 0) := to_signed(-24, 16); -- sfix16_En15
CONSTANT coeff86                        : signed(15 DOWNTO 0) := to_signed(18, 16); -- sfix16_En15
CONSTANT coeff87                        : signed(15 DOWNTO 0) := to_signed(-13, 16); -- sfix16_En15
CONSTANT coeff88                        : signed(15 DOWNTO 0) := to_signed(9, 16); -- sfix16_En15
CONSTANT coeff89                        : signed(15 DOWNTO 0) := to_signed(-6, 16); -- sfix16_En15
CONSTANT coeff90                        : signed(15 DOWNTO 0) := to_signed(4, 16); -- sfix16_En15
CONSTANT coeff91                        : signed(15 DOWNTO 0) := to_signed(-3, 16); -- sfix16_En15


signal delay_pipeline: array_vector;

signal conv_trig: std_logic;
signal index: integer range 0 to size_ROM := 0;
signal index_pipeline: integer range 0 to size_pipeline_delay := 0;

signal audio_filtered: std_logic;


begin
 
	ROM_coeff(0) <= coeff1;
	ROM_coeff(1) <= coeff2;
	ROM_coeff(2) <= coeff3;
	ROM_coeff(3) <= coeff4;
	ROM_coeff(4) <= coeff5;
	ROM_coeff(5) <= coeff6;
	ROM_coeff(6) <= coeff7;
	ROM_coeff(7) <= coeff8;
	ROM_coeff(8) <= coeff9;
	ROM_coeff(9) <= coeff10;
	ROM_coeff(10) <= coeff11;
	ROM_coeff(11) <= coeff12;
	ROM_coeff(12) <= coeff13;
	ROM_coeff(13) <= coeff14;
	ROM_coeff(14) <= coeff15;
	ROM_coeff(15) <= coeff16;
	ROM_coeff(16) <= coeff17;
	ROM_coeff(17) <= coeff18;
	ROM_coeff(18) <= coeff19;
	ROM_coeff(19) <= coeff20;
	ROM_coeff(20) <= coeff21;
	ROM_coeff(21) <= coeff22;
	ROM_coeff(22) <= coeff23;
	ROM_coeff(23) <= coeff24;
	ROM_coeff(24) <= coeff25;
	ROM_coeff(25) <= coeff26;
	ROM_coeff(26) <= coeff27;
	ROM_coeff(27) <= coeff28;
	ROM_coeff(28) <= coeff29;
	ROM_coeff(29) <= coeff30;
	ROM_coeff(30) <= coeff31;
	ROM_coeff(31) <= coeff32;
	ROM_coeff(32) <= coeff33;
	ROM_coeff(33) <= coeff34;
	ROM_coeff(34) <= coeff35;
	ROM_coeff(35) <= coeff36;
	ROM_coeff(36) <= coeff37;
	ROM_coeff(37) <= coeff38;
	ROM_coeff(38) <= coeff39;
	ROM_coeff(39) <= coeff40;
	ROM_coeff(40) <= coeff41;
	ROM_coeff(41) <= coeff42;
	ROM_coeff(42) <= coeff43;
	ROM_coeff(43) <= coeff44;
	ROM_coeff(44) <= coeff45;
	ROM_coeff(45) <= coeff46;
	ROM_coeff(46) <= coeff47;
    	ROM_coeff(47) <= coeff48;
   	ROM_coeff(48) <= coeff49;
    ROM_coeff(49) <= coeff50;
    ROM_coeff(50) <= coeff51;
    ROM_coeff(51) <= coeff52;
    ROM_coeff(52) <= coeff53;
    ROM_coeff(53) <= coeff54;
    ROM_coeff(54) <= coeff55;
    ROM_coeff(55) <= coeff56;
    ROM_coeff(56) <= coeff57;
    ROM_coeff(57) <= coeff58;
    ROM_coeff(58) <= coeff59;
    ROM_coeff(59) <= coeff60;
    ROM_coeff(60) <= coeff61;
    ROM_coeff(61) <= coeff62;
    ROM_coeff(62) <= coeff63;
    ROM_coeff(63) <= coeff64;
    ROM_coeff(64) <= coeff65;
    ROM_coeff(65) <= coeff66;
    ROM_coeff(66) <= coeff67;
    ROM_coeff(67) <= coeff68;
    ROM_coeff(68) <= coeff69;
    ROM_coeff(69) <= coeff70;
    ROM_coeff(70) <= coeff71;
    ROM_coeff(71) <= coeff72;
    ROM_coeff(72) <= coeff73;
    ROM_coeff(73) <= coeff74;
    ROM_coeff(74) <= coeff75;
    ROM_coeff(75) <= coeff76;
    ROM_coeff(76) <= coeff77;
    ROM_coeff(77) <= coeff78;
    ROM_coeff(78) <= coeff79;
    ROM_coeff(79) <= coeff80;
    ROM_coeff(80) <= coeff81;
    ROM_coeff(81) <= coeff82;
    ROM_coeff(82) <= coeff83;
    ROM_coeff(83) <= coeff84;
    ROM_coeff(84) <= coeff85;
    ROM_coeff(85) <= coeff86;
    ROM_coeff(86) <= coeff87;
    ROM_coeff(87) <= coeff88;
    ROM_coeff(88) <= coeff89;
    ROM_coeff(89) <= coeff90;
    ROM_coeff(90) <= coeff91;


	Delay_Pipeline_process : process (clk)
		begin
			if clk'event and clk = '1' then
				if rst = '1' then
					delay_pipeline(0 to size_pipeline_delay) <= (others => (others => '0'));
				elsif sclk_edge_flag = '1' then
					delay_pipeline(1 to size_pipeline_delay) <= delay_pipeline(0 to size_pipeline_delay-1);
					delay_pipeline(0) <= data_in;
				end if;
			end if;
		end process Delay_Pipeline_process;
	
	
	-- MAC convolution
	Convolution_trigger: process(clk)
		begin
			if clk'event and clk = '1' then
				if rst = '1' then
					conv_trig <= '0';
				elsif sclk_edge_flag = '1' then
					conv_trig <= '1';
					audio_filtered <= '0';
				elsif index = size_ROM - 1 or index = size_ROM then
					conv_trig <= '0';
					audio_filtered <= '1';
				end if;
			end if;
		end process;
		
	audio_conv <= audio_filtered;

	Index_control: process(clk)
		begin
			if clk'event and clk = '1' then
				if rst = '1' then
					index <= 0;
					index_pipeline <= 0;
				elsif index = size_ROM - 1 or index = size_ROM or index_pipeline = size_pipeline_delay then
					index <= 0;
					index_pipeline <= 0;
				elsif conv_trig = '1' then
					if even_odd = '0' then
						index <= index + 2;
					elsif even_odd = '1' then
						if index = 0 then
							index <= 1;
						else
							index <= index + 2;
						end if;
					end if;
					index_pipeline <= index_pipeline + 1;
				end if;
			end if;
		end process;
	
	MAC_process: process(clk)
		begin
			if clk'event and clk = '1' then
				if rst = '1' then
					accumulator <= to_signed(0,32);
					multiplier <= to_signed(0,32);
				elsif conv_trig = '1' then
					multiplier <= ROM_coeff(index) * signed(delay_pipeline(index_pipeline));
					accumulator <= accumulator + multiplier;
				end if;
			end if;
		end process;
	
--	for_products: for i in 0 to size_ROM-1 generate
--		products_array(i) <= resize(ROM_coeff(i) * signed(delay_pipeline(i)), 16) when (even_odd = '0') and (i mod 2 = 0) 
--		else resize(ROM_coeff((size_ROM - 1) - i) * signed(delay_pipeline(i)), 16) when (even_odd /= '0') and (i mod 2 /= 0) 
--		else to_signed(0, 16);
--	end generate for_products;
--		
--	for_adders: for i in 0 to size_ROM-1 generate
--		adder_convolution <= resize(adder_convolution + products_array(i),16);
--	end generate for_adders;
	
	audio_out <= resize(accumulator,16);

end rtl;