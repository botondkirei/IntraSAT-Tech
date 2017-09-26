-- Author: Botond Sandor Kirei
-- Emloyer: Technical University of Cluj Napoca
-- Scope: IEEE 802.15.4 MAC implementation

use work.MAC_pack.all;

package MAC is
	procedure init_MacPIB (signal mac_PIB:inout macPIB);
	function min ( v1,v2: uint8_t) return uint8_t;
	procedure init_MacCon (signal PANCoordinator : out uint8_t);
	procedure signal_loss (signal path_to_MLME_SYNC_LOSS_inidication : out uint8_t);
	function set_frame_control (frame_type:in uint8_t;
								security: in uint8_t;
								frame_pending: in uint8_t;
								ack_request: in uint8_t;
								intra_pan: in uint8_t;
								dest_addr_mode: in uint8_t;
								source_addr_mode: in uint8_t) return uint16_t;
	function set_MHR_AddressingFields (mac_PIB : in macPIB_t)
		return AddressingFields_t;
	procedure create_data_request_cmd ( mac_PIB : inout macPIB_t;
										SendBuffer : out SendBuffer_t) ;
	procedure create_beacon_request_cmd (mac_PIB : inout macPIB_t;
										SendBuffer : out SendBuffer_t);
	
	procedure create_gts_request_cmd (mac_PIB : inout macPIB_t;
										gts_characteristics : uint8_t ;
										SendBuffer : out SendBuffer_t);
										
	procedure build_ack(sequence : uint8_t ;
						frame_pending : uint8_t );
						
	procedure create_data_frame(DataFrame : DataFrame_t;
								endBuffer : out SendBuffer_t );
	
	--Association commands
	
	procedure create_association_request_cmd( CoordAddrMode: uint8_t;
											CoordPANId : uint16_t;
											CoordAddress : uint32_t
											 CapabilityInformation : uint8_t;
											SendBuffer : out SendBuffer_t );
											

	function create_association_response_cmd( DeviceAddress: uint32_t
											 shortaddress: uint16_t;
											 status : uint8_t;
											 SendBuffer : out SendBuffer_t) 
											 return error_t;
											 
	procedure create_disassociation_notification_cmd( DeviceAddress: uint32_t;
													 disassociation_reason : uint8_t
													  SendBuffer : out SendBuffer_t);
	
	procedure process_dissassociation_notification(MPDU: MPDU_t);
	
	-- Syncornization functions

	-- GTS functions
	
	procedure process_gts_request(MPDU : MPDU_t);	
	procedure init_available_gts_index(SendBuffer : out SendBuffer_t);
	procedure start_coordinator_gts_send(SendBuffer : out SendBuffer_t);
	
	
	--GTS FUNCTIONS
	function remove_gts_entry( DevAddressType : DevAddressType_t) return error_t;
	function add_gts_entry( gts_length : uint8_t;
							direction : boolean;
							DevAddressType : DevAddressType_t) return error_t;
	function add_gts_null_entry(gts_length : uint8_t;
							direction : boolean;
							DevAddressType : DevAddressType_t) return error_t;
	
	--increment the idle GTS for GTS deallocation purposes, not fully implemented yet
	
	procedure increment_gts_null;
	
	procedure start_gts_send;
	
	
	
	--initialization functions
	procedure init_gts_slot_list();
	procedure init_GTS_null_db();
	
	procedure init_GTS_db();


	function calculate_gts_expiration return uint32_t;
	procedure check_gts_expiration;

	-- scan functions
	
	procedure data_channel_scan_indication;
	
	-- CSMA functions
	
	function check_csma_ca_backoff_send_conditions( delay_backoffs : uint32_t) return uint8_t;
	
	procedure init_csma_ca( slotted : boolean);
	procedure perform_csma_ca;
	procedure perform_csma_ca_unslotted();
	procedure perform_csma_ca_slotted();
	
	-- indirect transmission commands
	--function used to initialize the indirect transmission buffer
	procedure init_indirect_trans_buffer;
	--function used to search and send an existing indirect transmission message
	procedure send_ind_trans_addr( DeviceAddress : uint32_t);
	--function used to remove an existing indirect transmission message
	function remove_indirect_trans( handler : uint8_t) return error_t;
	--function used to increment the transaction persistent time on each message
	--if the transaction time expires the messages are discarded
	procedure increment_indirect_trans;

	-- receive buffer commands
	
	procedure data_indication();
	
	procedure indication_cmd(	MPDU : MPDU_t; ppduLinkQuality : uint8_t );
	procedure indication_ack(	MPDU : MPDU_t; ppduLinkQuality : uint8_t );
	procedure indication_data(	MPDU : MPDU_t; ppduLinkQuality : uint8_t );
	
	--- reception and transmission
	
	procedure send_frame_csma;
	
	function check_csma_ca_send_conditions( frame_length : uint8_t ;
											 frame_control1 : uint8_t) return uint8_t;

	function check_gts_send_conditions( frame_length : uint8_t) return uint8_t;
	
	function calculate_ifs( pk_length : uint8_t) return uint8_t;

	-- beacon management functions
	
	--function to create the beacon
	procedure create_beacon();
	--function to process the beacon information
	procedure  process_beacon(PDU : MPDU_t; ppduLinkQuality : uint8_t );

	-- fault tolerance commands
	
		
	procedure create_coordinator_realignment_cmd( device_extended0 : uint32_t;
												 device_extended1 : uint32_t;
												  device_short_address :uint16_t);
	procedure create_orphan_notification;
	procedure process_coordinator_realignment(MPDU_ptr : access MPDU_t);


										
										
	function DeserializeFrameControl_t (Val : uint16_t) return FrameControl_t ;
	function SerializeFrameControl_t (Frame : FrameControl_t) return uint16_t ;
										
	component MAC_core is
		generic (FFD_not_RFD: boolean := TRUE);
		port ( MCPS_DATA : inout MCPS_DATA_t);
	end component MAC_core;

	
end package;

package body MAC is

	procedure init_MacPIB (signal mac_PIB:inout macPIB) is
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
		path_to_MLME_SYNC_LOSS_inidication <= 0; --beacon_loss_reason
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

	
	function set_MHR_AddressingFields (mac_PIB : in macPIB_t)
		return AddressingFields_t is
	begin
	end function set_MHR_AddressingFields;
	
	procedure create_data_request_cmd ( mac_PIB : inout macPIB_t;
										SendBuffer : out SendBuffer_t) is
		--variable source_long_ptr : source_long;
		variable frame_pkt : MPDU_t;
		
	begin
		frame_pkt.MHR.FrameControl := set_frame_control(TYPE_CMD,0,0,1,1,0,LONG_ADDRESS);
		frame_pkt.MHR.SequenceNumber := mac_PIB.macDSN;
		mac_PIB.macDSN := mac_PIB.macDSN + 1;
		frame_pkt.MHR.AddressingFields := set_MHR_AddressingFields(mac_PIB);
		frame_pkt.MACPayload := DATA_REQ_FRAME;
		frame_pkt.add_to_fifo(SendBuffer);
		send_frame_csma;
	end procedure;
	
	procedure create_beacon_request_cmd (mac_PIB : inout macPIB_t;
										SendBuffer : out SendBuffer_t) is
		variable frame_pkt : MPDU_t;
	begin

	end procedure create_beacon_request_cmd;
	
	


	function SerializeFrameControl_t (Frame : FrameControl_t) return uint16_t is
		variable RetVal : uint16_t :=0;
		variable pow : integer := 1;
	begin
		RetVal:=RetVal + Frame.FrameType * pow;
		--pow:=pow sl;
		--to be completed

	end function;
	
	function DeserializeFrameControl_t (Val : uint16_t) return FrameControl_t is
	begin
		--to be completed
	end function;
	type MHR_t is record
		FrameControl : uint16_t;
		--frame_control_2 : uint8_t;
		SequenceNumber : uint8_t;
		AddressingFields:AddressingFields_t;
		AuxiliarySecurityHeader : AuxiliarySecurityHeader_t;
		--data : uint8x128_t;
	end record MHR_t;



	-- entity MAC_core is
		-- generic (FFD_not_RFD: boolean := TRUE);
		-- port ( MCPS_DATA : inout MCPS_DATA_t);
	-- end entity MAC_core;

	-- architecture behavioral of MAC is
		-- signal aExtendedAddress0 : uint32_t;
		-- signal aExtendedAddress1 : uint32_t;
		-- signal mac_PIB : macPIB;
		-- signal PANCoordinator : boolean := FALSE; -- flag to indicate if the device is a oordinator or not
		-- signal Beacon_enabled_PAN : boolean := FALSE; -- flag to indicate beacon or non-beacon coordinated PANCoordinator
		-- signal SecurityEnable : boolean := FALSE; --flag to indicate security on or off
		-- signal pending_reset : boolean := FALSE ; -- to be deleted
		-- signal trx_status : uint8_t;
		-- signal beacon_enabled : boolean := FALSE;
		
		
		--  association variables
		-- signal associating : uint8_t := 0;
		-- signal association_cmd_seq_num : uint8_t :=0;
		
		-- /*association parameters*/
		
		-- signal a_LogicalChannel : uint8_t;
		-- signal a_CoordAddrMode : uint8_t;
		-- signal a_CoordPANId : uint16_t;
		-- signal a_CoordAddress[2] : uint32_t;
		-- signal a_CapabilityInformation : uint8_t;
		-- signal a_securityenable : boolean;		
		
		-- syncronization variables
		-- //(SYNC)the device will try to track the beacon ie enable its receiver just before the espected time of each beacon
		-- signal TrackBeacon : bool :=0;
		-- signal beacon_processed : bool :=0;
		-- //beacon loss indication
		-- signal beacon_loss_reason : uint8_t;
		
		-- //(SYNC)the device will try to locate one beacon
		-- signal findabeacon : bool :=0;
		-- //(SYNC)number of beacons lost before sending a Beacon-Lost indication comparing to aMaxLostBeacons
		-- signal missed_beacons : uint8_t :=0;
		-- //boolean variable stating if the device is synchonized with the beacon or not
		-- signal on_sync : uint8_t :=0;
		
		--  parent_offset : uint32_t :=16#00000000#;
		
		-- gts signals
	
		--  signal gts_request : uint8_t :=0;
		--  signal gts_request_seq_num : uint8_t :=0;
		     
		--  signal gts_confirm : boolean;
		     
		--  signal GTS_specification : uint8_t;
		--  signal GTSCapability : boolean :=1;
		     
		--  signal final_CAP_slot : uint8_t :=15;
		
		-- //GTS descriptor variables, coordinator usage only
		-- GTSinfoEntryType GTS_db[7];
		-- signal GTS_descriptor_count : uint8_t :=0;
		-- signal GTS_startslot : uint8_t :=16;
		-- signal GTS_id : uint8_t :=16#01#;


		-- //null gts descriptors
		-- GTSinfoEntryType_null GTS_null_db[7];
		
		--  GTS_null_descriptor_count : uint8_t :=0;
		-- //uint8_t GTS_null_id=0x01;
		
		-- //node GTS variables
		-- // 1 GTS for transmit
		-- signal s_GTSss : uint8_t :=0;           //send gts start slot
		-- signal s_GTS_length : uint8_t :=0;		 //send gts length
		-- //1 GTS for receive
		-- signal r_GTSss : uint8_t :=0;			 //receive gts start slot
		-- signal r_GTS_length : uint8_t :=0;		 //receive gts lenght
		
		-- //used to state that the device is on its transmit slot
		-- signal on_s_GTS : uint8_t :=0;
		-- //used to state that the device is on its receive slot
		-- signal on_r_GTS : uint8_t :=0;
		
		-- //used to determine if the next time slot is used for transmission
		-- signal next_on_s_GTS : uint8_t :=0;
		-- //used to determine if the next time slot is used for reception
		-- signal next_on_r_GTS : uint8_t :=0;
		
		-- //variable stating if the coordinator allow GTS allocations
		-- signal allow_gts : uint8_t :=1;
		
		-- //COORDINATOR GTS BUFFER 	
		-- gts_slot_element gts_slot_list[7];
		-- uint8_t available_gts_index[GTS_SEND_BUFFER_SIZE];
		-- signal available_gts_index_count : uint8_t;
		
		-- signal coordinator_gts_send_pending_data: uint8_t :=0;
		-- signal coordinator_gts_send_time_slot   : uint8_t :=0;
		
		-- //gts buffer used to store the gts messages both in COORDINATOR and NON COORDINATOR
		-- norace MPDU gts_send_buffer[GTS_SEND_BUFFER_SIZE];
		
		-- //NON PAN COORDINATOR BUFFER
		-- //buffering for sending
		-- signal gts_send_buffer_count		: uint8_t :=0;
		-- signal gts_send_buffer_msg_in	: uint8_t :=0;
		-- signal gts_send_buffer_msg_out	: uint8_t :=0;
		-- signal gts_send_pending_data		: uint8_t :=0;
		
		--channel scan variables 

		-- //current_channel
		-- signal current_channel : uint8_t :=0;

		-- /***************Variables*************************/
		-- //ED-SCAN variables
		
		--  scanning_channels : boolean;
		
		-- signal channels_to_scan : uint32_t;
		-- signal current_scanning : uint8_t :=0;
		-- //uint8_t scan_count=0;
		-- signal scanned_values : array (0 to 16) of uint8_t ;
		-- signal scan_type : uint8_t;
		
		-- signal scan_pans : array of (0 to 16) of SCAN_PANDescriptor;
		
		-- signal scan_duration : uint16_t;
		
		-- timer signal and variables
		
		-- signal response_wait_time : uint32_t;
		-- constant BI : uint32_t ; //Beacon Interval
		-- constant SD : uint32_t ; -- see sepcs  //Superframe duration
		
		-- //timer variables
		-- signal time_slot	: uint32_t; //backoff boundary timer
		-- signal backoff	: uint32_t;  //backoff timer
		
		-- //current number of backoffs in the active period
		-- signal number_backoff	: uint8_t :=1;
		-- signal number_time_slot	: uint8_t :=0;
		
		-- signal csma_slotted : bool :=0;
		
		-- CSMA signals and variables:
		
		--signal cca_deference 		: uint8_t := 0;
		--signal backoff_deference 	: uint8_t := 0;
		
		--  delay_backoff_period : uint8_t;
		-- signal csma_delay					: bool :=0;
		-- signal csma_locate_backoff_boundary	: bool :=0;
		-- signal csma_cca_backoff_boundary		: bool :=0;
		
		-- //Although the receiver of the device is enabled during the channel assessment portion of this algorithm, the
		-- //device shall discard any frames received during this time.
		-- signal performing_csma_ca : bool :=0;
		
		-- //CSMA-CA variables
		-- constant BE : uint8_t; -- see specs //backoff exponent
		-- constant CW : uint8_t; -- see specs //contention window (number of backoffs to clear the channel)
		-- constant NB : uint8_t; -- see specs //number of backoffs

		-- indirect transmission  signals and variables
		--indirect transmission buffer
		-- signal  indirect_trans_queue : array (0 to INDIRECT_BUFFER_SIZE) of indirect_transmission_element ;
		--indirect transmission message counter
		-- signal indirect_trans_count : uint8_t  :=0;
		
		-- receive buffer signals and variables

		-- signal  buffer_msg : array (0 to RECEIVE_BUFFER_SIZE) of MPDU;
		-- signal current_msg_in	: integer :=0;
		-- signal current_msg_out	: integer :=0;
		-- signal buffer_count		: integer :=0;	

		--reception and transmission
		--buffering for sending
		-- signal send_buffer : array (0 to SEND_BUFFER_SIZE ) of MPDUBuffer;
		-- signal send_buffer_count		: uint8_t :=0;
		-- signal send_buffer_msg_in	: uint8_t :=0;
		-- signal send_buffer_msg_out	: uint8_t :=0;
		
		-- //retransmission information
		-- signal send_ack_check				: uint8_t ;--ack requested in the transmitted frame
		-- signal retransmit_count				: uint8_t ;--retransmission count
		-- signal ack_sequence_number_check		: uint8_t ;--transmission sequence number
		-- signal send_retransmission			: uint8_t ;
		-- signal send_indirect_transmission	: uint8_t ;

		-- signal pending_request_data: uint8_t:=0;
		
		-- signal ackwait_period : uint8_t;
		
		-- signal link_quality : uint8_t;
		
		-- signal  mac_ack : ACK;
		-- signal  mac_ack_ptr : access ACK;
		
		-- signal gts_expiration : uint32_t;

		-- signal I_AM_IN_CAP	: uint8_t :=0;
		-- signal I_AM_IN_CFP	: uint8_t :=0;
		-- signal I_AM_IN_IP	: uint8_t :=0;
		
		-- beacon management signal and variables
		
		-- signal  mac_beacon_txmpdu : MPDU;
		-- signal  mac_beacon_txmpdu_ptr : access MPDU;
		
		-- signal send_beacon_frame_ptr : access uint8_t;
		-- signal send_beacon_length : uint8_t;
		                                  

	-- begin
		-- MCPS_DATA.request.SrcAddrMode <= NO_ADDRESS;
	-- end architecture MAC_core;

end MAC;

	