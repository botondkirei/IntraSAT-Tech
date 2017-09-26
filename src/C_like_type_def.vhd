-- Author: Botond Sandor Kirei
-- Emloyer: Technical University of Cluj Napoca
-- Scope: IEEE 802.15.4 MAC implementation

package C_like_type_def is
	-- general type_defs
	subtype uint8_t is natural range 16#00# to 16#FF#;
	subtype uint16_t is natural range 16#0000# to 16#FFFF#;
	subtype uint32_t is natural ;
end package;

