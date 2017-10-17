-- Author: Botond Sandor Kirei
-- Emloyer: Technical University of Cluj Napoca
-- Scope: IEEE 802.15.4 MAC implementation
-- Description: emulate the behavior of the TimerMilli circuit

use work.C_like_type_def.all;

package TimerMilli is 

	
	type TimerMilli_t is protected
	
		procedure stop;
		procedure startOneShot;

	end protected;
	
	component AsyncTimerMilli is
	end component;
	
end package;

package body TimerMilli is 

		
	type TimerMilli_t is protected body
		 fired : uint32_t;
		 
		procedure stop;
		begin
			enabled := FALSE;
		end procedure;
		
		procedure startOneShot;
		begin
			ticks_counter := 0;
			enabled := TRUE;
		end procedure;
		
	end protected body;
	
	entity AsyncTimerMilli is
	end entity;
	
	architecture functional of AsyncTimerMilli is
		constant period : time := 1/32768;
		signal clock32kHz : std_logic := '0';
		variable TTimerMilli : TimerMilli_t;
	begin
		clock_gen: process 
		begin
			wait for period/2;
			clock32kHz <= '1';
			wait for period/2;
			clock32kHz <= '0';
		end process;
		fire : process (rising_edge(clock32kHz))
		begin
			TTimerMilli.fired;
		end process;
	end architecture;
	

end package body;
