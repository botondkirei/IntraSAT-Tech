-- Author: Botond Sandor Kirei
-- Emloyer: Technical University of Cluj Napoca
-- Scope: IEEE 802.15.4 MAC implementation
--use work.C_like_type_def.all;

package MAC_pack is
	-- Type definitions
	-- general type_defs
	
	subtype uint8_t is natural range 16#00# to 16#FF#;
	subtype uint16_t is natural range 16#0000# to 16#FFFF#;
	subtype uint32_t is natural ;
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
	type SrcAddrMode_t is (NO_ADDRESS, SHORT_ADDRESS, EXTENDED_ADDRESS); --The source addressing mode for this MPDU.
	type DstAddrMode_t is (NO_ADDRESS, SHORT_ADDRESS, EXTENDED_ADDRESS); --The destination addressing mode for this MPDU.
	subtype DstPANId_t is uint16_t ;  --The PAN identifier of the entity to which the MSDU is being transferred.
	type DstAddr_t is range 0 to 10 ; -- to be completed - page 117
-- primitive definitions
	constant aMaxPHYPacketSize : integer := 127;
	constant aMinMPDUOverhead: integer := 9;
	constant aMaxMACPayloadSize : integer := aMaxPHYPacketSize - aMaxMACPayloadSize;
	type UWBPRF_t is (PRF_OFF, NOMINAL_4_M, NOMINAL_16_M, NOMINAL_64_M);
	type Ranging is (NON_RANGING, ALL_RANGING, PHY_HEADER_ONLY);
	type UWBPreambleSymbolRepetitions_t is (0, 16, 64, 1024, 4096);
	type MCPS_DATA_request_t is record
		SrcAddrMode : SrcAddrMode_t;
		DstAddrMode:DstAddrMode_t;
		DstPANId : DstPANId_t;
		DsrAddr : integer; -- to be implemeneted pg. 117
		msduLength: integer := aMaxMACPayloadSize;
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
	
	type MCPS_DATA_confirm is record
		dummy: boolean ;-- to be completed
	end record MCPS_DATA_confirm;
	type MCPS_DATA_indication is record
		dummy: boolean ;-- to be completed
		-- to be completed
	end record MCPS_DATA_indication;
	
	type MCPS_DATA_t is record
		request : MCPS_DATA_request_t;
		confirm : MCPS_DATA_confirm;
		inidcation : MCPS_DATA_indication;
	end record MCPS_DATA_t;
	type macPIB is record
		dummy: boolean ;-- to be completed
		-- to be completed
	end record macPIB;
	
-- frame formats
	type uint8x2_t is  array (0 to 1) of uint8_t;
	type uint8x4_t is  array (0 to 3) of uint8_t;
	type uint8x5_t is  array (0 to 4) of uint8_t;
	type uint8x8_t is  array (0 to 7) of uint8_t;
	type uint8x10_t is  array (0 to 9) of uint8_t;
	type uint8x14_t is  array (0 to 13) of uint8_t;
	type uint8x128_t is  array (0 to 127) of uint8_t;
	type DestinationPANIndetifier_t is record
		none : boolean;
		short : uint8x2_t;
	end record DestinationPANIndetifier_t;
	type DestinationAddress_t is record
		none: boolean;
		short: uint8x2_t;
		long: uint8x8_t;
	end record DestinationAddress_t;
	type SourcePANIndetifier_t is record
		none : boolean;
		short : uint8x2_t;
	end record SourcePANIndetifier_t;
	type SourceAddress_t is record
		none: boolean;
		short: uint8x2_t;
		long: uint8x8_t;
	end record SourceAddress_t;

	type AuxiliarySecurityHeader_t is record 
			none: boolean;
			x5 : uint8x5_t;
			x6 : uint8x6_t;
			x10 : uint8x10_t;
			x14 : uint8x14_t;
		end record;
	type AddressingFields_t is record
		DestinationPANIndetifier : DestinationPANIndetifier_t;
		DestinationAddress: DestinationAddress_t;
		SourcePANIndetifier : SourcePANIndetifier_t;
		SourcePANIndetifie : SourcePANIndetifier_t;
		
	end record;
	
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
	
end package;