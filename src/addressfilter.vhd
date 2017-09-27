-- Author: Botond Sandor Kirei
-- Emloyer: Technical University of Cluj Napoca
-- Scope: IEEE 802.15.4 MAC implementation
-- Description: emulate the behavior of the timer circuit

use work.C_like_type_def.all;

package AddressFilter is 

	type AddressFilter_t is protected
		procedure set_address		(mac_short_address: uint16_t;   mac_extended0, mac_extended1 :uint32_t	);
		procedure set_coord_address	(mac_coord_address: uint16_t;   mac_panid : uint16_t);
		procedure enable_address_decode (enable : boolean);
	end protected;
	
end package;

package body AddressFilter is 

	type AddressFilter_t is body
	
		procedure set_address		(mac_short_address: uint16_t;   mac_extended0, mac_extended1 :uint32_t	);
		begin
		end procedure;
		procedure set_coord_address	(mac_coord_address: uint16_t;   mac_panid : uint16_t);
		begin
		end procedure;
		procedure enable_address_decode (enable : boolean);
		begin
		end procedure;

	end protected body;

end package body;
