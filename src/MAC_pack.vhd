-- Author: Botond Sandor Kirei
-- Emloyer: Technical University of Cluj Napoca
-- Scope: IEEE 802.15.4 MAC implementation
use work.C_like_type_def.all;

package MAC_pack is
	-- Type definitions
	
	-- constants
	-- command types
	constant TYPE_BEACON : uint8_t := 0;
	constant TYPE_DATA : uint8_t := 1;
	constant TYPE_ACK : uint8_t := 2;
	constant TYPE_CMD : uint8_t := 3;
	-- address lengths
	constant SHORT_ADDRESS : uint8_t := 2;
	constant LONG_ADDRESS : uint8_t := 3;
	constant RESERVED_ADDRESS : uint8_t := 1;

	--MAC specific type_defs
	type impl_req is (mandatory, optional);
	type SrcAddrMode_t is (NO_ADDRESS, ADDRESS, EXTENDED_ADDRESS); --The source addressing mode for this MPDU.
	--attribute enumaretion_encoding of SrcAddrMode_t : type is "1 2 3";
	type DstAddrMode_t is (NO_ADDRESS, ADDRESS, EXTENDED_ADDRESS); --The destination addressing mode for this MPDU.
	subtype DstPANId_t is uint16_t ;  --The PAN identifier of the entity to which the MSDU is being transferred.
	type DstAddr_t is range 0 to 10 ; -- to be completed - page 117
-- primitive definitions
	constant aMaxPHYPacketSize : integer := 127;
	constant aMinMPDUOverhead: integer := 9;
	constant aMaxBeaconOverhead: integer := 75;
	--constant aMaxMACPayloadSize : integer := aMaxPHYPacketSize - aMaxMACPayloadSize;
	constant aMaxMACPayloadSize : integer;
	constant aMaxBeaconPayloadLength : integer;
	type UWBPRF_t is (PRF_OFF, NOMINAL_4_M, NOMINAL_16_M, NOMINAL_64_M);
	type Ranging is (NON_RANGING, ALL_RANGING, PHY_HEADER_ONLY);
	subtype UWBPreambleSymbolRepetitions_t is integer ;-- possible values(0, 16, 64, 1024, 4096);
	type KeySource_t is record
	--to be completed;
		dummy : boolean;
	end record KeySource_t;
	type Ranging_t is record
	--to be completed;
		dummy : boolean;	
	end record Ranging_t;
	type MCPS_DATA_request_t is record
		SrcAddrMode : SrcAddrMode_t;
		DstAddrMode:DstAddrMode_t;
		DstPANId : DstPANId_t;
		DsrAddr : integer; -- to be implemeneted pg. 117
		--msduLength: integer := aMaxMACPayloadSize;
		msduLength: integer;
		-- msdu : 
		msduHandle : uint8_t;
		AckTX : boolean;
		GTSTX : boolean;
		IndirectTX : boolean;
		SecurityLevel : uint32_t;
		KeyIdMode : integer;
		KeySource : KeySource_t;
		KeyIndex : natural range 16#01# to 16#FF#;
		UWBPRF :UWBPRF_t;
		Ranging : Ranging_t;
		UWBPreambleSymbolRepetitions : UWBPreambleSymbolRepetitions_t;
		DataRate : integer range 0 to 4;
	end record MCPS_DATA_request_t;
	
	type MCPS_DATA_confirm_t is record
		dummy: boolean ;-- to be completed
	end record MCPS_DATA_confirm_t;
	type MCPS_DATA_indication_t is record
		dummy: boolean ;-- to be completed
		-- to be completed
	end record MCPS_DATA_indication_t;
	
	type MCPS_DATA_t is record
		request : MCPS_DATA_request_t;
		confirm : MCPS_DATA_confirm_t;
		inidcation : MCPS_DATA_indication_t;
	end record MCPS_DATA_t;
	type macPIB is record
		dummy: boolean ;-- to be completed
		-- to be completed
	end record macPIB;
	
-- frame formats
	type uint8x2_t is  array (0 to 1) of uint8_t;
	type uint8x4_t is  array (0 to 3) of uint8_t;
	type uint8x5_t is  array (0 to 4) of uint8_t;
	type uint8x6_t is  array (0 to 4) of uint8_t;
	type uint8x8_t is  array (0 to 7) of uint8_t;
	type uint8x10_t is  array (0 to 9) of uint8_t;
	type uint8x14_t is  array (0 to 13) of uint8_t;
	type uint8x128_t is  array (0 to 127) of uint8_t;
	
	type PANIndetifier_t is record
		none : boolean;
		short : uint8x2_t;
	end record PANIndetifier_t;
	type Address_t is record
		none: boolean;
		short: uint8x2_t;
		long: uint8x8_t;
	end record Address_t;

	type AuxiliarySecurityHeader_t is record 
			none: boolean;
			x5 : uint8x5_t;
			x6 : uint8x6_t;
			x10 : uint8x10_t;
			x14 : uint8x14_t;
		end record;
	type AddressingFields_t is record
		DestinationPANIndetifier : PANIndetifier_t;
		DestinationAddress: Address_t;
		SourcePANIndetifier : PANIndetifier_t;
		SourceAddress : Address_t;
	end record;
	
	type FrameControl_t is record
		FrameType: integer range 0 to 7;
		SecEn: integer range 0 to 1;
		FramePending: integer range 0 to 1;
		AR: integer range 0 to 1;
		PANIdCompression: integer range 0 to 1;
		Reserved : integer range 0 to 7;
		DestAddrMode : integer range 0 to 3;
		FrameVer : integer range 0 to 3;
		SrcAddrMode : integer range 0 to 3;
	end record FrameControl_t;
	
	type MHR_t is record
		FrameControl : uint16_t;
		--frame_control_2 : uint8_t;
		SequenceNumber : uint8_t;
		AddressingFields:AddressingFields_t;
		AuxiliarySecurityHeader : AuxiliarySecurityHeader_t;
		--data : uint8x128_t;
	end record MHR_t;
	
	type MPDU_t is record
		MHR : MHR_t;
		MACPayload : uint8x128_t;
		MFR : uint16_t;
	end record;

	type GTSinfoEntryType is record
		GTS_id : uint8_t;
		starting_slot : uint8_t;
		len : uint8_t;
		direction :uint8_t;
		DevAddrType : uint32_t;
	end record;
	
	type GTSinfoEntryType_null is record
		GTS_id : uint8_t;
		starting_slot : uint8_t;
		len : uint8_t;
		DevAddrType : uint32_t;
		persistencetime : uint8_t;
	end record;
	
	type gts_slot_element is record
		element_count : uint8_t;
		element_in : uint8_t;
		element_out : uint8_t;
	end record;
	
	type indirect_transmission_element is record
		handler : uint8_t;
		transaction_persistent_time : uint16_t;
		-- MPDU frame;
		frame : uint8x128_t;
	end record;

	
	constant GTS_db_size : integer :=  7;
	
	--type FrameControl_o is protected
	--	function set_frame_control (frame_type:in uint8_t;
	--				source_addr_mode: in uint8_t) return uint16_t;
	--end protected;
	
	type Status_t is (
		SUCCESS,
		READ_ONLY,
		UNSUPPORTED_ATTRIBUTE,
		TRANSACTION_OVERFLOW,
		TRANSACTION_EXPIRED,
		CHANNEL_ACCESS_FAILURE,
		NO_ACK,
		INVALID_PARAMETER,
		UNSUPPORTED_SECURITY,
		FRAME_TOO_LONG,
		COUNTER_ERROR,
		UNAVAILABLE_KEY,
		NO_SHORT_ADDRESS,
		SUPERFRAME_OVERLAP,
		TRACKING_OFF,
		INVALID_PARAMETER,
		COUNTER_ERROR,
		FRAME_TOO_LONG,
		UNSUPPORTED_SECURITY,
		CHANNEL_ACCESS_FAILURE
	);
	
	
	subtype IEEE_address_t is uint8x8_t;
	
	type PIBAttr_t is (
		macExtendedAddress,
		macAckWaitDuration,
		macAssociatedPANCoord,
		macAssociationPermit,
		macAutoRequest,
		macBattLifeExt,
		macBattLifeExtPeriods,
		macBeaconPayload,
		macBeaconPayloadLength,
		macBeaconOrder,
		macBeaconTxTime,
		macBSN,
		macCoordExtendedAddress,
		macCoordShortAddress,
		macDSN,
		macGTSPermit,
		macMaxBE,
		macMaxCSMABackoffs,
		macMaxFrameTotalWaitTime,
		macMaxFrameRetries,
		macMinBE,
		macLIFSPeriod,
		macSIFSPeriod,
		macPANId,
		macPromiscuousMode,
		macRangingSupported,
		macResponseWaitTime,
		macRxOnWhenIdle,
		macSecurityEnabled,
		macShortAddress,
		macSuperframeOrder,
		macSyncSymbolOffset,
		macTimestampSupported,
		macTransactionPersistenceTime,
		macTxControlActiveDuration,
		macTxControlPauseDuration,
		macTxTotalDuration);
--type macBeaconPayload_t is array (0 to aMaxBeaconPayloadLength) of uint8_t;
	type macBeaconPayload_t is array (0 to 75) of uint8_t;

	
	type macPIB_t is record
		macExtendedAddress : IEEE_address_t;
		macAckWaitDuration : integer;
		macAssociatedPANCoord : Boolean;
		macAssociationPermit : Boolean;
		macAutoRequest : Boolean;
		macBattLifeExt : Boolean;
		macBattLifeExtPeriods : integer;
		macBeaconPayload : macBeaconPayload_t;
		macBeaconPayloadLength : integer;
		macBeaconOrder : integer;
		macBeaconTxTime : integer;
		macBSN : integer;
		macCoordExtendedAddress : IEEE_address_t;
		macCoordShortAddress	: integer;
		macDSN	: integer;
		macGTSPermit : boolean;
		macMaxBE : integer;
		macMaxCSMABackoffs : integer;
		macMaxFrameTotalWaitTime : integer;
		macMaxFrameRetries : integer;
		macMinBE : integer;
		macLIFSPeriod : integer;
		macSIFSPeriod : integer;
		macPANId : integer;
		macPromiscuousMode : boolean;
		macRangingSupported : boolean;
		macResponseWaitTime : integer;
		macRxOnWhenIdle : boolean;
		macSecurityEnabled : boolean;
		macShortAddress : integer;
		macSuperframeOrder : integer;
		macSyncSymbolOffset : integer;
		macTimestampSupported : boolean;
		macTransactionPersistenceTime : integer;
		macTxControlActiveDuration: integer;
		macTxControlPauseDuration: integer;
		macTxTotalDuration: integer;
	
	end record;

	
	
	type MLME_SET_CONFIRM_t is record
		Status : Status_t;
		PIBAttr : PIBAttr_t;
	end record;

	
	
end package;

package body MAC_pack is
	constant aMaxMACPayloadSize : integer := aMaxPHYPacketSize - aMinMPDUOverhead;
	constant aMaxBeaconPayloadLength : integer := aMaxPHYPacketSize - aMaxBeaconOverhead;

	-- type FrameControl_o body is
		-- variable FrameControl : FrameControl_t;
			-- --build MPDU frame control field
		-- impure function set_frame_control (frame_type:in uint8_t;
									-- security: in uint8_t;
									-- frame_pending: in uint8_t;
									-- ack_request: in uint8_t;
									-- intra_pan: in uint8_t;
									-- dest_addr_mode: in uint8_t;
									-- source_addr_mode: in uint8_t) return uint16_t is 
			-- variable fc_b1 : uint8_t;
			-- variable fc_b2 : uint8_t;
		-- begin

		  -- fc_b1 := ( (intra_pan * 2**6) + (ack_request * 2**5) + (frame_pending * 2**4) +
				  -- (security  * 2**3) + (frame_type) );				  
		  -- fc_b2 := ( (source_addr_mode  * 2**6) + (dest_addr_mode  * 2**2));
		  -- return ( (fc_b2 * 2**8 ) + (fc_b1) );

		-- end function set_frame_control;
		
	-- end protected body;


end package body MAC_pack;