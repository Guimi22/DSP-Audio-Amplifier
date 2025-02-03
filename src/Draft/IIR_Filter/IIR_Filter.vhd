library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity IIR_Filter is
	port(	clk: in std_logic;
		rst: in std_logic;
		data_in: in signed(15 downto 0);
		sample_freq: in std_logic;
		oversampling_freq: in std_logic;
		a1: in signed(15 downto 0);
		a2: in signed(15 downto 0);
		audio_out: out signed(15 downto 0)
		);
end IIR_Filter;

architecture rtl of IIR_Filter is

type A_REG is array (1 downto 0) of signed(17 downto 0);
type B_REG is array (1 downto 0) of signed(15 downto 0);
type D_REG is array (0 downto 0) of signed(17 downto 0);
type M_REG is array (0 downto 0) of signed(33 downto 0);
type P_REG is array (0 downto 0) of signed(33 downto 0);

signal A_Register1: A_REG;
signal B_Register1: B_REG;
signal D_Register1: D_REG;
signal M_Register1: M_REG;
signal P_Register1: P_REG;

signal A_Register2: A_REG;
signal B_Register2: B_REG;
--signal D_Register2: D_REG;
signal M_Register2: M_REG;
signal P_Register2: P_REG;

signal pre_adder_out: signed(17 downto 0);
signal pre_adder_sel: std_logic;

signal gain: signed(15 downto 0) := "0110010111010111"; -- 1.591309

signal feedback_in: signed(17 downto 0);

signal regfeedfwd_wr: std_logic := '0';

signal regfeedback_wr: std_logic := '0';

signal audio_in: signed(15 downto 0) := (others => '0');

signal feedfwd_output: signed(17 downto 0);

signal feedback_output: signed(17 downto 0);

signal signal_audio: signed(33 downto 0);

type FSM_feedbck is (S1, S2, S3, S4, idle);

signal convolution_FSM: FSM_feedbck := idle;

begin

-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
--	IIR FILTER COEFFICIENTS

--	The Transfer function denominator coefficients are stored in B Register 2 from the equivalent 
--	register in the DSP48E1 slices, where this Biquad IIR Filter is implented in Artix-7 FPGA.
--	Also, in order to simplify the convolution process, Lowest Common Multiple of the filter 
--	Transfer function numerator is stored in B Register 1.

	B_Register1(0) <= "0010000010110101"; --0.8132223/1.591309 = 0.5110398

	B_Register2(0) <= a1;--a1 value
	B_Register2(1) <= a2; --a2 value

-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
--	CONVOLUTION FSM

--	This IIR Filter is structured as a Polyphase filter, meaning no L zero samples are required to 
--	include between every sample. Instead, every L * Ts period, only one branch is computed, avoiding
--	redundant computations of zero samples. In order to implement this, the signal pre_adder_sel selects
--	the feedforward coefficients every oversampling cycle (L * Ts). 
--	The computations required to interpolate the input signal are controlled by the Convolution FSM.
--	The FSM is designed so the feedforward and feedback convolution are done in parallel and one 
--	operation per state is computed so logic gates have enough time to propagate the logic signal.

	Convolution_FSM_process: process(clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				convolution_FSM <= idle;
				pre_adder_sel <= '0';
			elsif oversampling_freq = '1' then
				convolution_FSM <= S1;
			else
				if convolution_FSM = S1 then
					convolution_FSM <= S2;
				elsif convolution_FSM = S2 then
					convolution_FSM <= S3;
				elsif convolution_FSM = S3 then 
					convolution_FSM <= S4;
				elsif convolution_FSM = S4 then
					convolution_FSM <= idle;
					pre_adder_sel <= not pre_adder_sel;
				else 
					convolution_FSM <= idle;
				end if;
			end if;
		end if;
	end process;

-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
--	FEEDFORWARD CONVOLUTION

--	The feedforward computation is implemented in one DSP48E1 slice and uses the Registers A, B,
--	D, M & P and the Pre-adder, the multiplier and the Adder from the DSP unit.
--	Both Register A & D are the pipeline input Registers used to store previous input samples, 
--	uptaded every Ts period.
--	Every L * Ts period, an addition of the numerator's Transfer equation is done and stored in the
--	pre_adder_out signal and later the product of the value stored in the B Register 1, times the 
--	pre_adder_out.
--	After all of this computations are processed, the result value is stored in the P Register 1 and
--	truncated in order to match the 16 bits of the ouput sample.  
				
	Write_Reg_Pipeline: process(clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				regfeedfwd_wr <= '0';
			elsif sample_freq = '1' then
				regfeedfwd_wr <= '1';
			else 
				regfeedfwd_wr <= '0';
			end if;
		end if;
	end process;
				
	Pipeline_input_reg: process(clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				A_Register1 <= (others => (others => '0'));
				D_Register1 <= (others => (others => '0'));
				audio_in <= (others => '0');
			elsif regfeedfwd_wr = '1' then
				A_Register1(1) <= A_Register1(0);
				A_Register1(0) <= "00" & audio_in;
				D_Register1(0) <= "00" & audio_in; 
				audio_in <= data_in;			
			end if;
		end if;
	end process;
	
	Feed_forward_convolution: process(clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				pre_adder_out <= (others => '0');
				M_Register1 <= (others => (others => '0'));
				P_Register1 <= (others => (others => '0'));
			elsif convolution_FSM = S2 then
				if pre_adder_sel = '0' then
					pre_adder_out <= A_Register1(1) + audio_in;
				else
					pre_adder_out <= A_Register1(0) + D_Register1(0);
				end if;
			elsif convolution_FSM = S3 then
				M_Register1(0) <= B_Register1(0) * pre_adder_out;
			elsif convolution_FSM = S4 then
				P_Register1(0) <=  M_Register1(0);
			else
				P_Register1(0) <= P_Register1(0);
			end if;
		end if;
	end process;

	feedfwd_output <= P_Register1(0)(33 downto 16);

-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
--	FEEDBACK CONVOLUTION

--	The feedback computation is implemented in one DSP48E1 slice and uses the Registers A, B,
--	M & P, the Multiplier and the Adder from the DSP unit.
--	The Register A is the pipeline output Registers used to store previous output samples, uptaded
--	every L * Ts period.
--	Every L * Ts period, the convolution of the feedback value is computed.
--	After all of the computations are processed, the result value is stored in the P Register 2 and
--	truncated in order to match the 16 bits of the ouput sample.  

	Pipeline_write: process(clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				regfeedback_wr <= '0';
			elsif convolution_FSM = S4 then
				regfeedback_wr <= '1';
			else 
				regfeedback_wr <= '0';
			end if;
		end if;
	end process;

	Pipeline_output_reg: process(clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				A_Register2 <= (others => (others => '0'));
			elsif regfeedback_wr = '1' then
				A_Register2(1) <= A_Register2(0);
				A_Register2(0) <= "00" & signal_audio(33 downto 18);	
			end if;
		end if;
	end process;

	Feed_back_convolution: process(clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				M_Register2 <= (others => (others => '0'));
				P_Register2 <= (others => (others => '0'));
			elsif convolution_FSM = S1 then
				P_Register2 <= (others => (others => '0'));
				M_Register2(0) <= B_Register2(0) * A_Register2(0);
				--sign_conv1 <= B_Register2(0)(17) or A_Register2(0)(15);
			elsif convolution_FSM = S2 then
				P_Register2(0) <= M_Register2(0) + P_Register2(0);
			elsif convolution_FSM = S3 then
				M_Register2(0) <= B_Register2(1) * A_Register2(1);
				--sign_conv2 <= B_Register2(1)(17) or A_Register2(1)(15);
			elsif convolution_FSM = S4 then
				P_Register2(0) <= P_Register2(0) + M_Register2(0);
			else
				P_Register2(0) <= P_Register2(0);
			end if;
		end if;
	end process;
	
	--sign_mux <= sign_conv1 & sign_conv2;

	--aux <= to_unsigned(to_integer(P_Register2(0)(40 downto 40)), 1);
	
--	with sign_mux select
--		sign_feedback <= 	to_unsigned(0,1) when "00",
--					to_unsigned(1,1) when "11",
--					P_Register2(0)(40 downto 40) when others;

	feedback_output <= P_Register2(0)(33 downto 16); --sign_feedback & P_Register2(0)(30 downto 16); --P_Register2(0)(42) & P_Register2(0)(41) & P_Register2(0)(38 downto 25);

-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-- 	OUTPUT

--	After the feedforward and the feedback convolution results are calculated, to find the new
--	sample, both values are added and later multiplied by the gain to restore the output sample to
--	the corresponding value.
--	The ouput port audio_out is assigned the signal_audio truncated ignoring the 2 MSB, as it is 
--	empirically checked that these bits are never filled.

	Output_register_write: process(clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				feedback_in <= (others => '0');
			elsif convolution_FSM = idle then
				feedback_in <= feedfwd_output + feedback_output;
			else
				feedback_in <= feedback_in;
			end if;
		end if;
	end process;
	
	signal_audio <= gain * feedback_in;

	audio_out <= signal_audio(33 downto 18);

-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------	

end architecture;
				