-- Author: Botond Sandor Kirei
-- Emloyer: Technical University of Cluj Napoca
-- Scope: IEEE 802.15.4 MAC implementation
-- Description: emulate the behavior of the timer circuit

use work.C_like_type_def.all;

package Timer is 

	constant BEFORE_BI_INTERVAL  : integer := 100;
	constant BEFORE_BB_INTERVAL   : integer := 5;
	constant SO_EQUAL_BO_DIFFERENCE    : integer := 2;
	constant NUMBER_TIME_SLOTS     : integer := 16;
	
	type Timer_t is protected
	
		procedure start;
		procedure stop;
		procedure reset;
		procedure set_bi_sd( bi_symbols : uint32_t;
							 sd_symbols : uint32_t);
		procedure set_backoff_symbols (Backoff_Duration_Symbols : uint8_t);
		procedure set_enable_backoffs (enable : boolean);
		procedure set_timers_enable ( timer : uint8_t);
		procedure reset_process_frame_tick_counter;
		function reset_start(start_ticks:	uint32_t) return uint8_t;
		--time before BI
		function before_bi_fired return boolean;
		function sd_fired return boolean;
		function bi_fired return boolean;
		--backoff fired
		function backoff_fired return boolean;
		--backoff boundary fired
		function	time_slot_fired			return boolean;
		function	before_time_slot_fired	return boolean;
		function	sfd_fired				return boolean;
		
		function get_current_ticks return uint32_t;
		function get_sd_ticks return uint32_t;
		function get_bi_ticks return uint32_t;
		function get_backoff_ticks return uint32_t;
		function get_time_slot_ticks return uint32_t;
		function get_current_number_backoff return uint32_t;
		function get_time_slot_backoff_periods return uint32_t;
		function get_current_time_slot return uint32_t;
		function get_current_number_backoff_on_time_slot return uint32_t;
		function get_total_tick_counter return uint32_t;
		function get_process_frame_tick_counter return uint32_t;
	end protected;
	
	component AsyncTimer is
	end component;
	
end package;

package body Timer is 

		
	type Timer_t is protected body
		variable ticks_counter : uint32_t;

		--BEACON INTERVAL VARIABLES
		variable bi_ticks			: uint32_t ;
		variable bi_backoff_periods	: uint32_t ;
		variable before_bi_ticks		: uint32_t ;
		variable sd_ticks			: uint32_t ;

		--number of backoff periods
		variable time_slot_backoff_periods : uint32_t;

		--number of ticks in the timeslot
		variable time_slot_ticks				: uint32_t ;
		variable before_time_slot_ticks		: uint32_t ;
		variable time_slot_tick_next_fire	: uint32_t ;

		--BACKOFF VARIABLES
		variable backoff_symbols : uint32_t;

		--number of ticks in the backoff
		variable backoff_ticks: uint32_t := 5;

		--COUNTER VARIABLES
		variable backoff_ticks_counter : uint32_t :=0;

		--give the current time slot number
		variable current_time_slot : uint8_t :=0;
		--counts the current number of time slots of each time slot
		variable current_number_backoff_on_time_slot : uint32_t :=0;
		--count the total number of backoffs
		 current_number_backoff : uint32_t := 0;

		--OTHER
		variable backoffs : boolean := FALSE;
		variable enable_backoffs : boolean :=FALSE;

		variable previous_sfd: uint8_t :=0;
		variable current_sfd : uint8_t :=0;

		variable process_frame_tick_counter: uint32_t :=0;

		variable total_tick_counter : uint32_t :=0;

		variable timers_enable : uint8_t :=0x01;	

		variable clock : std_logic := '0';
		
		variable enabled : boolean :=FALSE;
		
		procedure start is
		begin
			enabled := TRUE;
		end procedure;
		
		procedure stop is
		begin
			enabled := FALSE;
		end procedure;
		
		procedure reset is
		begin
			ticks_counter := 0;
			enabled := TRUE;
		end procedure;
		
		procedure set_bi_sd( bi_symbols : uint32_t;
							 sd_symbols : uint32_t) is
		begin
			time_slot_backoff_periods := (sd_symbols / NUMBER_TIME_SLOTS) / backoff_symbols;
			time_slot_ticks := time_slot_backoff_periods * backoff_ticks;
			time_slot_tick_next_fire := time_slot_ticks;
			before_time_slot_ticks := time_slot_ticks - BEFORE_BB_INTERVAL;
			sd_ticks := time_slot_ticks * NUMBER_TIME_SLOTS;

			if (bi_symbols == sd_symbols ) then
			begin
				--in order not to have the same time for both BI and SI
				sd_ticks := sd_ticks - SO_EQUAL_BO_DIFFERENCE;
			end if;
			
			bi_backoff_periods := bi_symbols/ backoff_symbols;
			bi_ticks := bi_backoff_periods * backoff_ticks;
			
			before_bi_ticks := bi_ticks - BEFORE_BI_INTERVAL;
		end procedure;
		
		procedure set_backoff_symbols (Backoff_Duration_Symbols : uint8_t) is
		begin
			backoff_symbols := Backoff_Duration_Symbols;
			backoff_ticks :=  1;
		end procedure;
		
		procedure set_enable_backoffs (enable : boolean) is
		begin
			enable_backoffs := enable;
		end procedure;
		
		procedure set_timers_enable ( timer : uint8_t) is
		begin
			timers_enable := timer;
		end procedure;
		
		procedure reset_process_frame_tick_counter is
		begin
			process_frame_tick_counter :=0;
		end procedure;
		
		function reset_start(start_ticks:	uint32_t) return uint8_t is
		begin
			current_time_slot := start_ticks / time_slot_ticks;
			
			if (current_time_slot = 0) then
				time_slot_tick_next_fire := time_slot_ticks;
				current_number_backoff := start_ticks / backoff_ticks;
				current_number_backoff_on_time_slot := current_number_backoff;
			else
				time_slot_tick_next_fire :=  ((current_time_slot+1) * time_slot_ticks);
				current_number_backoff := start_ticks / backoff_ticks;
				current_number_backoff_on_time_slot := current_number_backoff - (current_time_slot * time_slot_backoff_periods);
			end if;
			
			backoff_ticks_counter :=0;
			backoffs :=1;
			--on_sync = 1;
			
			total_tick_counter := total_tick_counter + start_ticks;
			ticks_counter := start_ticks;
			return current_time_slot;
		end procedure;
		
		procedure fired is
		begin
			if(timers_enable = 16#01#) then
			
				ticks_counter := ticks_counter + 1;
				process_frame_tick_counter := process_frame_tick_counter + 1;
				
				total_tick_counter := total_tick_counter + 1;
				
				if (ticks_counter = before_bi_ticks) then
					before_bi_fired;	
				end if
				
				if (ticks_counter = bi_ticks) then 

					ticks_counter := 0;
					current_time_slot :=0;
					backoff_ticks_counter :=0;
					time_slot_tick_next_fire:=time_slot_ticks;
					backoffs:=1;
					enable_backoffs := 1;
					current_number_backoff :=0;
					bi_fired;
				end if;
				
				if (ticks_counter = sd_ticks) then 
					backoffs :=0;
					sd_fired();
				end if;
		
				if ((enable_backoffs = 1) and (backoffs = 1)) then
					backoff_ticks_counter := backoff_ticks_counter + 1;
					
					if (backoff_ticks_counter = backoff_ticks) then

						backoff_ticks_counter:=0;
						current_number_backoff := current_number_backoff + 1;
						current_number_backoff_on_time_slot := current_number_backoff_on_time_slot +1;
						backoff_fired;
					end if;
					
					--before time slot boundary
					if (ticks_counter = before_time_slot_ticks) then 
						before_time_slot_fired;
					end if;
					
					--time slot fired
					if (ticks_counter = time_slot_tick_next_fire) then 
						time_slot_tick_next_fire := time_slot_tick_next_fire + time_slot_ticks;
						before_time_slot_ticks := time_slot_tick_next_fire - BEFORE_BB_INTERVAL;
						backoff_ticks_counter :=0;
						current_number_backoff_on_time_slot :=0;
						current_time_slot := current_time_slot + 1;
						
						if ((current_time_slot > 0) and (current_time_slot < 16) ) then
							time_slot_fired;
						end if;						
					end if;
				end if;
			end if;
		end procedure;
		
		--time before BI
		function before_bi_fired return boolean is
			variable flag : boolean := FALSE;
		begin
			if flag then
				flag := FALSE;
			else 
				flag := TRUE;
			end if;
			return flag;
		end function;
		
		function sd_fired return boolean is
			variable flag : boolean := FALSE;
		begin
			if flag then
				flag := FALSE;
			else 
				flag := TRUE;
			end if;
			return flag;
		end function;
		
		function bi_fired return boolean is
			variable flag : boolean := FALSE;
		begin
			if flag then
				flag := FALSE;
			else 
				flag := TRUE;
			end if;
			return flag;
		end function;
		--backoff fired
		function backoff_fired return boolean is
			variable flag : boolean := FALSE;
		begin
			if flag then
				flag := FALSE;
			else 
				flag := TRUE;
			end if;
			return flag;
		end function;
		--backoff boundary fired
		function	time_slot_fired			return boolean is
			variable flag : boolean := FALSE;
		begin
			if flag then
				flag := FALSE;
			else 
				flag := TRUE;
			end if;
			return flag;
		end function;
		
		function	before_time_slot_fired	return boolean is
			variable flag : boolean := FALSE;
		begin
			if flag then
				flag := FALSE;
			else 
				flag := TRUE;
			end if;
			return flag;
		end function;
		
		function	sfd_fired				return boolean is
			variable flag : boolean := FALSE;
		begin
			if flag then
				flag := FALSE;
			else 
				flag := TRUE;
			end if;
			return flag;
		end function;
		
		function get_current_ticks return uint32_t is
		begin
			return ticks_counter;
		end function;
		
		function get_sd_ticks return uint32_t is
		begin
			return time_slot_ticks * NUMBER_TIME_SLOTS;
		end function;
		
		function get_bi_ticks return uint32_t is
		begin
			return bi_ticks;
		end function;

		function get_backoff_ticks return uint32_t is
		begin
			return backoff_ticks;
		end function;

		function get_time_slot_ticks return uint32_t is
		begin
			return time_slot_ticks;
		end function;		
		
		function get_current_number_backoff return uint32_t is
		begin
			return current_number_backoff;
		end function;		
		
		function get_time_slot_backoff_periods return uint32_t is
		begin
			return time_slot_backoff_periods;
		end function;		
		
		function get_current_time_slot return uint32_t is
		begin
			return current_time_slot;
		end function;		

		function get_current_number_backoff_on_time_slot return uint32_t is
		begin
			return current_number_backoff_on_time_slot;
		end function;			

		function get_total_tick_counter return uint32_t is
		begin
			return total_tick_counter;
		end function;		

		function get_process_frame_tick_counter return uint32_t is
		begin
			return process_frame_tick_counter;
		end function;				
	end protected body;
	
	entity AsyncTimer is
	end entity;
	
	architecture functional of AsyncTimer is
		constant period : time := 1/32768;
		signal clock32kHz : std_logic := '0';
		variable TTimer : Timer_t;
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
			TTimer.fired;
		end process;
	end architecture;
	

end package body;
