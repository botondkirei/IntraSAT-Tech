use work.C_like_type_def.all;
package FIFO is 

	constant FIFO_SIZE : integer := 4096;
	type unit8_array_t is array (integer range <>) of uint8_t;

	type FIFO_t is protected
		procedure push(element : in uint8_t);
		impure function pull return uint8_t;
		impure function isempty return boolean;
		impure function isfull return boolean;
	end protected;
	
end package;

package body FIFO is 

		
	type FIFO_t is protected body
		variable counter : integer;
		variable empty : boolean := TRUE;
		variable full : boolean :=  FALSE;
		variable stack : unit8_array_t (0 to FIFO_SIZE);

		procedure push(element : in uint8_t) is
		begin
			counter := counter + 1;
			stack(counter) := element;
			empty := FALSE;
			if counter = FIFO_SIZE then full := TRUE;
			end if;
		end procedure;


		impure function pull return uint8_t is
			variable element : uint8_t;
		begin
			element := stack(counter);
			counter := counter - 1;
			full := FALSE;
			if counter = 0 then empty := TRUE;
			end if;
			return element;
		end function;
		impure function isempty return boolean is
		begin
			return empty;
		end function;
		
		impure function isfull return boolean is		
		begin
			return full;
		end function;		
		
	end protected body;

end package body;
