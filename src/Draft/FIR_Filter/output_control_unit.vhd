library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity output_control_unit is
	port(	clk: in std_logic;
		rst: in std_logic;
		filter1: in signed(15 downto 0);
		filter2: in signed(15 downto 0);
		audio_conv1: in std_logic;
		audio_conv2: in std_logic;
		fs_in: in std_logic;
		audio_out: out signed(15 downto 0)
		);
end output_control_unit;

architecture beh of output_control_unit is

type estat is (NP,P0,P1);
signal FSM: estat := NP;
signal audio_out_signal: signed(15 downto 0) := to_signed(0,16);

begin
	
	FSM_inst:process (CLK)				-- maquina d'estats
	begin
		if (CLK = '1' and CLK'event) then
			if (RST = '1') then
				FSM <= NP;
			else
				case FSM is
					when NP =>
						if fs_in = '1' then
							FSM <= P0;
						end if;
					when P0 => 
						if fs_in = '1' then
							FSM <= P1;
						end if;
					when P1 => 
						if fs_in = '1' then
							FSM <= P0;
						end if;
				end case;
			end if;
		end if;
	end process;
	
	process(clk)
	begin
		if (CLK = '1' and CLK'event) then
			if (RST = '1') then	
				audio_out_signal <= to_signed(0,16);
			elsif FSM = P0 then
				if audio_conv1 = '1' then
					audio_out_signal <= filter1;
				end if;
			elsif FSM = P1 then 
				if audio_conv2 = '1' then
					audio_out_signal <= filter2;
				end if;
			end if;
		end if;
	end process;

	audio_out <= audio_out_signal;
	
end beh;