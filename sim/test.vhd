use work.MAC_pack.all;

package trial is

	type SourceAddress_o is protected
		--type SourceAddress : SourceAddress_t;
		procedure set_address(addr : uint8x2_t);
		procedure set_address(addr : uint8x8_t);
		impure function get_address return uint8x2_t;
		impure function get_address return uint8x8_t;
	end protected SourceAddress_o;
	
	type beacon_frame_o is protected
		--variable addr : SourceAddress_o;
		procedure set_address (a : uint8x2_t);
		procedure set_address (a : uint8x8_t);
	end protected beacon_frame_o;
	
end package;

package body trial  is

	type SourceAddress_o is protected body 
		variable SourceAddress : SourceAddress_t;
		procedure set_address(addr : uint8x2_t) is
		begin
			SourceAddress.short := addr;
		end procedure;
		procedure set_address(addr : uint8x8_t) is
		begin
			SourceAddress.long := addr;
		end procedure;
		impure function get_address return uint8x2_t is
		begin	
			return SourceAddress.short;
		end function;
		impure function get_address return uint8x8_t is
		begin	
			return SourceAddress.long;
		end function;
	end protected body;

	type beacon_frame_o is protected body
		variable addr : SourceAddress_o;
		procedure set_address (a : uint8x2_t) is
		begin
			addr.set_address(a);
		end procedure;
		procedure set_address (a : uint8x8_t) is
		begin
			addr.set_address(a);
		end procedure;
	end protected body beacon_frame_o;

end package body;

use work.trial.all;
use work.MAC_pack.all;

entity test is
end entity;

architecture trial of test is

	
	signal saddr : uint8x2_t := (10,10);
	signal laddr : uint8x8_t := (10,10,10,10,10,10,10,10);
	
begin
	--frame_control <= set_frame_control(1,1,1,1,1,1,1);
	process 
		variable beacon_frame : beacon_frame_o;
	begin
		beacon_frame.set_address(saddr);
		beacon_frame.set_address(laddr);
		wait;
	end process;
end architecture;
