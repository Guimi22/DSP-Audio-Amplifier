library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity counter is
generic( N: integer );
port( 	clk, rst, Trigger, En: in std_logic;	--counter starts with pulse at Trigger
		count_flag: out std_logic -- '1' when counter has overflown
	);
end counter;

architecture BEH of counter is

signal count: integer range 0 to N := 0;
signal start_count: std_logic;
signal count_out_OF: std_logic;

begin
	
	Pulse_det_EN: process(clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				start_count <= '0';
			elsif En = '1' and Trigger = '1' then
				start_count <= '1';		--latch of internal enable when detected pulse at Trigger input
			elsif En = '1' and count_out_OF = '1' then
				start_count <= '0';
			end if;
		end if;
	end process;
	
	count_N: process(clk)
	begin
		if clk'event and clk = '1' then
			if rst = '1' then
				count <= 0;
          		elsif En = '1' and start_count = '1' then
				if count = N then
		      			count <= 0;  
				else
					count <= count + 1;
				end if;
			end if;
		end if;
	end process;
	
	with count select
		count_out_OF <=	'1' when N,
				'0' when others;
				
	count_flag <= count_out_OF;

end BEH;