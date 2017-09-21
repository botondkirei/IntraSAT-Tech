-- Author: Botond Sandor Kirei
-- Emloyer: Technical University of Cluj Napoca
-- Scope: IEEE 802.15.4 MAC implementation

use work.MAC_pack.all;

entity MAC is
	generic (FFD_not_RFD: boolean := TRUE);
	port ( MCPS_DATA : inout MCPS_DATA_t);
end entity;

architecture behavioral of MAC is
	signal aExtendedAddress0 : uint32_t;
	signal aExtendedAddress1 : uint32_t;
	signal mac_PIB : macPIB;
	signal PANCoordinator : boolean := FALSE; -- flag to indicate if the device is a oordinator or not
	signal Beacon_enabled_PAN : boolean := FALSE; -- flag to indicate beacon or non-beacon coordinated PANCoordinator
	signal SecurityEnable : boolean := FALSE; --flag to indicate security on or off
	signal pending_reset : boolean := FALSE ; -- to be deleted
	signal trx_status : uint8_t;
	signal beacon_enabled : boolean := FALSE;
	
	procedure init_MacPIB (signal mac_PIB:inout macPIB)is
	begin
		mac_PIB.dummy <= FALSE;
	end procedure;
	
	function min ( v1,v2: uint8_t) return uint8_t is
	begin
		if (v1<v2) then
			return v1;
		else
			return v2;
		end if;
	end function;
	
	procedure init_MacCon (signal PANCoordinator : out uint8_t) is
	begin 
		PANCoordinator <= 0;
	end procedure;
	
	procedure signal_loss (signal path_to_MLME_SYNC_LOSS_inidication : out uint8_t) is 
	begin
		--to be implemented
		path_to_MLME_SYNC_LOSS_inidication <= 0; //beacon_loss_reason
	end procedure;
	
	--build MPDU frame control field
	function set_frame_control (frame_type:in uint8_t;
								security: in uint8_t;
								frame_pending: in uint8_t;
								ack_request: in uint8_t;
								intra_pan: in uint8_t;
								dest_addr_mode: in uint8_t;
								source_addr_mode: in uint8_t) return uint16_t is 
		variable fc_b1 : uint8_t;
		variable fc_b2 : uint8_t;
	begin

  	  fc_b1 := ( (intra_pan * 2**6) + (ack_request * 2**5) + (frame_pending * 2**4) +
 	   		  (security  * 2**3) + (frame_type) );				  
	  fc_b2 := ( (source_addr_mode  * 2**6) + (dest_addr_mode  * 2**2));
	  return ( (fc_b2 * 2**8 ) + (fc_b1) );

	end function set_frame_control;


	
	procedure create_data_request_cmd ( mac_PIB : inout macPIB_t;
										SendBuffer : out SendBuffer_t) is
		--variable source_long_ptr : source_long;
		signal frame_pkt : MPDU_t;
		
	begin
		frame_pkt.frame_control := set_frame_control(TYPE_CMD,0,0,1,1,0,LONG_ADDRESS);
		frame_pkt.sequence_number := mac_PIB.macDSN;
		mac_PIB.macDSN := mac_PIB.macDSN;
		
begin

	MCPS_DATA.request.SrcAddrMode <= NO_ADDRESS;

end architecture;


	