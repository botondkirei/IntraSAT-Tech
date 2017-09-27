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
											CoordAddress : uint32_t;
											CapabilityInformation : uint8_t;
											SendBuffer : out SendBuffer_t );
											

	function create_association_response_cmd( DeviceAddress: uint32_t;
											 shortaddress: uint16_t;
											 status : uint8_t;
											 SendBuffer : out SendBuffer_t) 
											 return error_t;
											 
	procedure create_disassociation_notification_cmd( DeviceAddress: uint32_t;
													 disassociation_reason : uint8_t;
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
	procedure init_gts_slot_list;
	procedure init_GTS_null_db(GTS_null_db : inout array (0 to GTS_db_size) of GTSinfoEntryType);;
	
	procedure init_GTS_db(GTS_db : inout array (0 to GTS_db_size) of GTSinfoEntryType);;


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
	procedure init_indirect_trans_buffer(indirect_trans_count : out uint8_t;
										indirect_trans_queue : out array (0 to INDIRECT_BUFFER_SIZE) of indirect_transmission_element);
	--function used to search and send an existing indirect transmission message
	procedure send_ind_trans_addr( DeviceAddress : uint32_t);
	--function used to remove an existing indirect transmission message
	function remove_indirect_trans( handler : uint8_t) return error_t;
	--function used to increment the transaction persistent time on each message
	--if the transaction time expires the messages are discarded
	procedure increment_indirect_trans;

	-- receive buffer commands
	
	procedure data_indication;
	
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
	
		--Association commands implementations
	
	procedure create_association_request_cmd( CoordAddrMode: uint8_t;
											CoordPANId : uint16_t;
											CoordAddress : uint32_t;
											CapabilityInformation : uint8_t;
											SendBuffer : out SendBuffer_t );
											

	function create_association_response_cmd( DeviceAddress: uint32_t;
											 shortaddress: uint16_t;
											 status : uint8_t;
											 SendBuffer : out SendBuffer_t) 
											 return error_t;
											 
	procedure create_disassociation_notification_cmd( DeviceAddress: uint32_t;
													 disassociation_reason : uint8_t;
													  SendBuffer : out SendBuffer_t);
	
	procedure process_dissassociation_notification(MPDU: MPDU_t)
		signal cmd_disassociation_notification  : cmd_disassociation_notification_t;
	begin
		-- extract de values from the data frame and pass it to the indication primitive
		cmd_disassociation_notification <= MPDU.data;
		MLME_DISASSOCIATE.indication(cmd_disassociation_notification);
	end procedure;
	
	
	
	
	
	-- Syncornization functions implementations

	-- GTS function implementations
	
	procedure process_gts_request(MPDU : MPDU_t);	
		signal gts_characteristics : uint8_t;
		signal source_address : uint8_t;
	begin
		gts_characteristics <= MPDU.data.gts_characteristics; -- get gts cara from packet
		source_address <= MPDU.data.source_address;
		if (get_characteristic_type(gts_characteristics) = 1 ) then
			--allocation
			--process the gts request
			status <= add_gts_entry(get_gts_length(ts_characteristics),get_gts_direction(gts_characteristics),source_address);
		else
			--dealocation
			status <= remove_gts_entry(source_address);
		end if;
		MLME_GTS.indication(source_address, gts_characteristics, 0, 0);
		
		
	end procedure;
	
	
	
	
	
	
	procedure init_available_gts_index( available_gts_index_count  : uint8_t;
										available_gts_index : array (0 to GTS_SEND_BUFFER_SIZE) of uint8_t);
		variable i : integer :=0;
	begin
		available_gts_index_count  := GTS_SEND_BUFFER_SIZE;
		for i in 0 to GTS_SEND_BUFFER_SIZE loop
			available_gts_index[i] := i;
		end loop;
	end procedure;
	-- procedure start_coordinator_gts_send(SendBuffer : out SendBuffer_t);
	
	
	--GTS FUNCTIONS
	-- function remove_gts_entry( DevAddressType : DevAddressType_t) return error_t;
	-- function add_gts_entry( gts_length : uint8_t;
							-- direction : boolean;
							-- DevAddressType : DevAddressType_t) return error_t;
	-- function add_gts_null_entry(gts_length : uint8_t;
							-- direction : boolean;
							-- DevAddressType : DevAddressType_t) return error_t;
	
	-- --increment the idle GTS for GTS deallocation purposes, not fully implemented yet
	
	-- procedure increment_gts_null;
	
	-- procedure start_gts_send;
	
	
	
	-- --initialization functions
	procedure init_gts_slot_list(gts_slot_list : inout array (0 to GTS_db_size ) of gts_slot_element);
		variable i: integer:=0;
	begin
		for i in 0 to GTS_db_size loop
			gts_slot_list[i].element_count :=16#00#;
			gts_slot_list[i].element_in :=16#00#;
			gts_slot_list[i].element_out :=16#00#;
		end loop;
	end procedure;		
	 
	procedure init_GTS_null_db(GTS_db_null : inout array (0 to GTS_db_size) of GTSinfoEntryType_null);
		variable i: integer:=0;
	begin
		for i in 0 to GTS_db_size loop
			GTS_db_null[i].gts_id:=16#00#;
			GTS_db_null[i].starting_slot:=16#00#;
			GTS_db_null[i].len:=16#00#;
			GTS_db_null[i].DevAddressType:=16#0000#;
			GTS_db_null[i].persistencetime := 16#00#;
		end loop;
	end procedure;	
	procedure init_GTS_db (GTS_db : inout array (0 to GTS_db_size) of GTSinfoEntryType);
		variable i: integer:=0;
	begin
		for i in 0 to GTS_db_size loop
			GTS_db[i].gts_id:=16#00#;
			GTS_db[i].starting_slot:=16#00#;
			GTS_db[i].len:=16#00#;
			GTS_db[i].direction:=16#00#;
			GTS_db[i].DevAddressType:=16#0000#;
		end loop;
	end procedure;


	-- function calculate_gts_expiration return uint32_t;
	-- procedure check_gts_expiration;

	-- -- scan functions
	
	-- procedure data_channel_scan_indication;
	
	-- -- CSMA functions
	
	-- function check_csma_ca_backoff_send_conditions( delay_backoffs : uint32_t) return uint8_t;
	
	-- procedure init_csma_ca( slotted : boolean);
	-- procedure perform_csma_ca;
	-- procedure perform_csma_ca_unslotted();
	-- procedure perform_csma_ca_slotted();
	
	-- -- indirect transmission commands
	-- --function used to initialize the indirect transmission buffer
	procedure init_indirect_trans_buffer (indirect_trans_count : out uint8_t;
											indirect_trans_queue : out array (0 to INDIRECT_BUFFER_SIZE) of indirect_transmission_element);
		variable i: integer;
	begin

		for i in 0 to INDIRECT_BUFFER_SIZE loop
			indirect_trans_queue[i].handler :=16#00#;
			indirect_trans_count:=0;
		end loop;
		
	end procedure;

	-- --function used to search and send an existing indirect transmission message
	-- procedure send_ind_trans_addr( DeviceAddress : uint32_t);
	-- --function used to remove an existing indirect transmission message
	-- function remove_indirect_trans( handler : uint8_t) return error_t;
	-- --function used to increment the transaction persistent time on each message
	-- --if the transaction time expires the messages are discarded
	-- procedure increment_indirect_trans;

	-- -- receive buffer commands
	
	 procedure data_indication()
		signal link_qual : uint8_t ;
	 begin
		link_qual <= link_quality;
		--Although the receiver of the device is enabled during the channel assessment portion of this algorithm, the
		--device shall discard any frames received during this time.
		--////////////printfUART("performing_csma_ca: %i\n",performing_csma_ca);
		if (performing_csma_ca = 1) then
			--////////////printfUART("REJ CSMA\n","");
			buffer_count <= buffer_count - 1;
			current_msg_out <= current_msg_out + 1;
			if ( current_msg_out = RECEIVE_BUFFER_SIZE )then
				current_msg_out <= 0;
			end if;
			
			return;
		end if;
		if ( scanning_channels = 1) then
			buffer_count <= buffer_count - 1;
			current_msg_out <= current_msg_out + 1;
			if ( current_msg_out = RECEIVE_BUFFER_SIZE )then
				current_msg_out <= 0;
			end if;
			return;
		end if;
		
		--//////printfUART("data ind %x %x %i\n",buffer_msg[current_msg_out].frame_control1,buffer_msg[current_msg_out].frame_control2,(buffer_msg[current_msg_out].frame_control2 & 0x7));
		
		--check the frame type of the received packet
		case( (buffer_msg[current_msg_out].frame_control1 & 0x7) )
			
				when TYPE_DATA=> --////printfUART("rd %i\n",buffer_msg[current_msg_out].seq_num);
								indication_data(&buffer_msg[current_msg_out],link_qual);
								
				when TYPE_ACK=> --////printfUART("ra\n","");
								--//ack_received = 1;
								indication_ack(&buffer_msg[current_msg_out],link_qual);
							
				when TYPE_CMD=> -- ////printfUART("rc\n","");
								indication_cmd(&buffer_msg[current_msg_out],link_qual);
			
				when TYPE_BEACON=>
								
								--//printfUART("rb %i\n",buffer_msg[current_msg_out].seq_num);
								if (mac_PIB.macShortAddress = 0x0000) then
									buffer_count <= buffer_count - 1;
								else
									process_beacon(&buffer_msg[current_msg_out],link_qual);
								end if;
				others=> 
							atomic buffer_count <= atomic buffer_count-1;
							--//////printfUART("Invalid frame type\n","");

			end case;
		current_msg_out <= current_msg_out +1;
		if ( current_msg_out = RECEIVE_BUFFER_SIZE )	then
			current_msg_out <= 0;
		end if;
		
	end procedure;
	

	
	 procedure indication_cmd(	MPDU : MPDU_t; ppduLinkQuality : uint8_t );
		signal  cmd_type : uint8_t;
		signal addressing_fields_length : uint8_t :=0;
		
		signal  SrcAddr : array (0 to 1) of uint32_t;
		
		--frame control variables
		signal source_address		: uint8_t :=0;
		signal destination_address	: uint8_t :=0;
	
		--not translated into vhdl !!!
		--source_short *source_short_ptr;
		--source_long *source_long_ptr;
		
		--dest_short *dest_short_ptr;
		--dest_long *dest_long_ptr;
	begin
	
		destination_address <=get_fc2_dest_addr(pdu.frame_control2);
		source_address<=get_fc2_source_addr(pdu.frame_control2);
		
		--decrement buffer count
		buffer_count <= buffer_count -1;
		
		case (destination_address)
			when LONG_ADDRESS=> addressing_fields_length <= DEST_LONG_LEN;
								dest_long_ptr <= (dest_long *) &pdu->data[0];
								if(dest_long_ptr->destination_address0 !=aExtendedAddress0 and dest_long_ptr->destination_address1 !=aExtendedAddress1) then
									--//printfUART("NOT FOR ME","");
									return;
								end if;
			when SHORT_ADDRESS=> addressing_fields_length = DEST_SHORT_LEN;
								dest_short_ptr<= (dest_short *) &pdu->data[0];
								--destination command not for me
								if (dest_short_ptr->destination_address != mac_PIB.macShortAddress and dest_short_ptr->destination_address !=0xffff) then
									--//printfUART("NOT FOR ME","");
									--////////////printfUART("NOT FOR ME %x me %e\n", dest_short_ptr->destination_address,mac_PIB.macShortAddress); 
									return;
								end if;
		end case;
		
		case (source_address)
			when LONG_ADDRESS=> addressing_fields_length <= addressing_fields_length + SOURCE_LONG_LEN;
			when SHORT_ADDRESS=> addressing_fields_length <= addressing_fields_length + SOURCE_SHORT_LEN;
		end case
		
		cmd_type <= pdu->data[addressing_fields_length];
		
		case (cmd_type)
			when CMD_ASSOCIATION_REQUEST=> 	
									--check if association is allowed, if not discard the frame		
									
									--////////printfUART("CMD_ASSOCIATION_REQUEST \n", "");
									
										
											if (mac_PIB.macAssociationPermit = 0 ) then
											
												--////////////printfUART("Association not alowed\n", "");
												if ( get_fc1_ack_request(pdu->frame_control1) = 1 ) then
													build_ack(pdu->seq_num,0);
												end if
												return;
											end if;
											
											if ( PANCoordinator= 0 ) then
												--////////////printfUART("i�m not a pan\n", ""); 
												return;
											end if;
									
											source_long_ptr <= (source_long *) &pdu->data[DEST_SHORT_LEN];
											
											SrcAddr[1] <=source_long_ptr->source_address0;
											SrcAddr[0] <=source_long_ptr->source_address1;
											
											MLME_ASSOCIATE.indication(SrcAddr, pdu->data[addressing_fields_length+1] , 0, 0);

											if ( get_fc1_ack_request(pdu->frame_control1) = 1 ) then
												build_ack(pdu->seq_num,1);
											end if;

		
			when CMD_ASSOCIATION_RESPONSE=> 
												--printfUART("CMD_ASSOCIATION_RESPONSE\n", ""); 
												
												associating <=0;
												T_ResponseWaitTime.stop();
												
												if ( get_fc1_ack_request(pdu->frame_control1) = 1 ) then 
													build_ack(pdu->seq_num,0);
												end if;
											
												MLME_ASSOCIATE.confirm((uint16_t)(pdu->data[addressing_fields_length+1] + (pdu->data[addressing_fields_length+2] << 8)), pdu->data[addressing_fields_length+3]);

			when CMD_DISASSOCIATION_NOTIFICATION=> 	--////////////printfUART("Received CMD_DISASSOCIATION_NOTIFICATION\n", ""); 
												
												if ( get_fc1_ack_request(pdu->frame_control1) = 1 ) then
													build_ack(pdu->seq_num,0);
												end if;
												
												process_dissassociation_notification(pdu);

			when CMD_DATA_REQUEST=>
									--////printfUART("CMD_DATA_REQUEST\n", ""); 
									--////////printfUART("DR\n", "");
									if ( get_fc1_ack_request(pdu->frame_control1) = 1 ) then

										--TODO
										--Problems with consecutive reception of messages
										--
										--build_ack(pdu->seq_num,0);
									end if;
									
									--cmd_data_request_0_3_reception = (cmd_data_request_0_3 *) pdu->data;
									
									source_long_ptr <= (source_long *) &pdu->data[0];
											
									SrcAddr[1] <=source_long_ptr->source_address0;
									SrcAddr[0] <=source_long_ptr->source_address1;
									
									send_ind_trans_addr(SrcAddr);

			when CMD_PANID_CONFLICT=>

								
			when CMD_ORPHAN_NOTIFICATION=>
									--////printfUART("CMD_ORPHAN_NOTIFICATION\n", ""); 
									
									source_long_ptr <= (source_long *) &pdu->data[DEST_SHORT_LEN];
											
									SrcAddr[1] <=source_long_ptr->source_address0;
									SrcAddr[0] <=source_long_ptr->source_address1;
									
									MLME_ORPHAN.indication(SrcAddr, 0x00,0x00);
								
			when CMD_BEACON_REQUEST=>

			when CMD_COORDINATOR_REALIGNMENT=>
									--printfUART("CMD_COORDINATOR_REALIGNMENT\n", ""); 
									
									process_coordinator_realignment(pdu);

			when CMD_GTS_REQUEST=>
								--//////////////printfUART("Received CMD_GTS_REQUEST\n", ""); 
								if ( get_fc1_ack_request(pdu->frame_control1) = 1 ) then
									build_ack(pdu->seq_num,0);
								end if;
								process_gts_request(pdu);
		end case;
		
		
	end procedure;
	
	
		
	procedure indication_ack(	MPDU : MPDU_t; ppduLinkQuality : uint8_t );
	begin
		buffer_count <= buffer_count -1;
		if (send_ack_check = 1 and ack_sequence_number_check = pdu->seq_num) then
			--transmission SUCCESS
			T_ackwait.stop();
			
			send_buffer_count <= send_buffer_count-1;
			send_buffer_msg_out<=send_buffer_msg_out+1;
			
			--failsafe
			if(send_buffer_count > SEND_BUFFER_SIZE) then
				send_buffer_count <=0;
				send_buffer_msg_out<=0;
				send_buffer_msg_in<=0;
			end if;
			
			if (send_buffer_msg_out = SEND_BUFFER_SIZE) then
				send_buffer_msg_out<=0;
			end if;
			
			--received an ack for the association request
			if( associating = 1 and association_cmd_seq_num = pdu->seq_num ) then
				--////////////printfUART("ASSOC ACK\n",""); 
				T_ResponseWaitTime.startOneShot(response_wait_time);
				--call T_ResponseWaitTime.start(TIMER_ONE_SHOT, response_wait_time);
			end if;
			
			if (gts_request = 1 and gts_request_seq_num = pdu->seq_num) then
        
				T_ResponseWaitTime.startOneShot(response_wait_time);
				//call T_ResponseWaitTime.start(TIMER_ONE_SHOT, response_wait_time);
			end if;
			
			--////////////printfUART("TRANSMISSION SUCCESS\n",""); 
        
			if (send_indirect_transmission > 0 ) then
				--the message send was indirect
				--remove the message from the indirect transmission queue
				indirect_trans_queue[send_indirect_transmission-1].handler<=0x00;
				indirect_trans_count--;
				--////////////printfUART("SU id:%i ct:%i\n", send_indirect_transmission,indirect_trans_count);
			end if;
			
			send_ack_check <=0;
			retransmit_count <=0;
			ack_sequence_number_check <=0;
			
			
			if (send_buffer_count > 0) then
				post send_frame_csma();
			end if;
			
		end if;

		if (get_fc1_frame_pending(pdu->frame_control1) = 1 anf pending_request_data =1) then --// && associating == 1
				--////////////printfUART("Frame_pending\n",""); 
				pending_request_data<=0;
				create_data_request_cmd();
		end if;
		
		--GTS mechanism, after the confirmation of the GTS request, must check if the beacon has the gts
		-- /*
		-- if (gts_ack == 1)
		-- {
			-- gts_ack=0;
			-- gts_confirm=1;
			-- call T_ResponseWaitTime.stop();
		-- }
		-- */
		if(gts_send_pending_data=1) then
			post start_gts_send();
		end if;
		
		if(coordinator_gts_send_pending_data=1 and coordinator_gts_send_time_slot = number_time_slot) then
			post start_coordinator_gts_send();
		end if;
				
	end process;
	
	procedure indication_data(	MPDU : MPDU_t; ppduLinkQuality : uint8_t );
		signal  data_len : uint8_t;
		
		signal payload		: array (0 to 79) of uint8_t;
		signal msdu_length	: uint8_t :=0;
		
		signal SrcAddr : array (0 to 1) of uint32_t := (0,0);
		signal DstAddr : array (0 to 1) of uint32_t := (0,0);
		
		
		--frame control variables
		signal source_address		: uint8_t :=0;
		signal destination_address	: uint8_t :=0;
		
		-- not translated into vhdl !!!
		--source_short *source_short_ptr;
		--source_long *source_long_ptr;
		
		--dest_short *dest_short_ptr;
		--dest_long *dest_long_ptr;

	begin
		source_address<=get_fc2_source_addr(pdu.frame_control2);
		destination_address<=get_fc2_dest_addr(pdu.frame_control2);
		buffer_count <= buffer_count -1;
		if ( get_fc1_intra_pan(pdu.frame_control1)=  0 ) then
		--INTRA PAN
			if (destination_address > 1 and source_address > 1) then
				-- Destination LONG - Source LONG	
				if (destination_address = LONG_ADDRESS and source_address = LONG_ADDRESS) then
					dest_long_ptr <= (dest_long *) &pdu->data[0];
					source_long_ptr <= (source_long *) &pdu->data[DEST_LONG_LEN];
					
					--If a short destination address is included in the frame, it shall match either macShortAddress or the
					--broadcast address (0 x ffff). Otherwise, if an extended destination address is included in the frame, it
					--shall match aExtendedAddress.
					if ( dest_long_ptr->destination_address0 !=aExtendedAddress0 and dest_long_ptr->destination_address1 !=aExtendedAddress1 ) then
						--////////////printfUART("data rejected, ext destination not for me\n", ""); 
						return;
					end if;
					--If a destination PAN identifier is included in the frame, it shall match macPANId or shall be the
					--broadcast PAN identifier (0 x ffff).
					if(dest_long_ptr->destination_PAN_identifier != 0xffff and dest_long_ptr->destination_PAN_identifier != mac_PIB.macPANId ) then
						--////////////printfUART("data rejected, wrong destination PAN\n", ""); 
						return;
					end if;
					data_len <= 20;
					
					
					DstAddr[1] <= dest_long_ptr->destination_address0;
					DstAddr[0] <=dest_long_ptr->destination_address1;
					
					SrcAddr[1] <=source_long_ptr->source_address0;
					SrcAddr[0] <=source_long_ptr->source_address1;
					
					msdu_length <= pdu->length - data_len;

					--memcpy(&payload,&pdu->data[data_len],msdu_length * sizeof(uint8_t));
					
					MCPS_DATA.indication((uint16_t)source_address, (uint16_t)source_long_ptr->source_PAN_identifier, SrcAddr,(uint16_t)destination_address, (uint16_t)dest_long_ptr->destination_PAN_identifier, DstAddr, (uint16_t)msdu_length, payload, (uint16_t)ppduLinkQuality, 0x0000,0x0000);  
					
				end if;
				
				-- Destination SHORT - Source LONG
				if ( destination_address = SHORT_ADDRESS and source_address = LONG_ADDRESS ) then
					dest_short_ptr <= (dest_short *) &pdu->data[0];
					source_long_ptr <= (source_long *) &pdu->data[DEST_SHORT_LEN];
					
					--If a short destination address is included in the frame, it shall match either macShortAddress or the
					--broadcast address (0 x ffff). Otherwise, if an extended destination address is included in the frame, it
					--shall match aExtendedAddress.
					if ( dest_short_ptr->destination_address != 0xffff and dest_short_ptr->destination_address != mac_PIB.macShortAddress) then
						--////////////printfUART("data rejected, short destination not for me\n", ""); 
						return;
					end if;
					--If a destination PAN identifier is included in the frame, it shall match macPANId or shall be the
					--broadcast PAN identifier (0 x ffff).
					if(dest_short_ptr->destination_PAN_identifier != 0xffff && dest_short_ptr->destination_PAN_identifier != mac_PIB.macPANId )
						--////////////printfUART("data rejected, wrong destination PAN\n", ""); 
						return;
					end if
					
					data_len <= 14;
					
					DstAddr[0] <=dest_short_ptr->destination_address;
					
					SrcAddr[1] <=source_long_ptr->source_address0;
					SrcAddr[0] <=source_long_ptr->source_address1;
					
					msdu_length <= pdu->length - data_len;

					--memcpy(&payload,&pdu->data[data_len],msdu_length * sizeof(uint8_t));
					
					MCPS_DATA.indication((uint16_t)source_address, (uint16_t)source_long_ptr->source_PAN_identifier, SrcAddr,(uint16_t)destination_address, (uint16_t)dest_short_ptr->destination_PAN_identifier, DstAddr, (uint16_t)msdu_length, payload, (uint16_t)ppduLinkQuality, 0x0000,0x0000);  

				end if;
				-- Destination LONG - Source SHORT
				if ( destination_address = LONG_ADDRESS && source_address = SHORT_ADDRESS ) then
					dest_long_ptr = (dest_long *) &pdu->data[0];
					source_short_ptr = (source_short *) &pdu->data[DEST_LONG_LEN];
					
					--If a short destination address is included in the frame, it shall match either macShortAddress or the
					--broadcast address (0 x ffff). Otherwise, if an extended destination address is included in the frame, it
					--shall match aExtendedAddress.
					if ( dest_long_ptr->destination_address0 !=aExtendedAddress0 and dest_long_ptr->destination_address1 !=aExtendedAddress1 ) then
						--////////////printfUART("data rejected, ext destination not for me\n", ""); 
						return;
					end if;
					--If a destination PAN identifier is included in the frame, it shall match macPANId or shall be the
					--broadcast PAN identifier (0 x ffff).
					if(dest_long_ptr->destination_PAN_identifier != 0xffff and  dest_long_ptr->destination_PAN_identifier != mac_PIB.macPANId ) then
						--////////////printfUART("data rejected, wrong destination PAN\n", ""); 
						return;
					end if;
					
					data_len <= 14;
					
					DstAddr[1] <= dest_long_ptr->destination_address0;
					DstAddr[0] <= dest_long_ptr->destination_address1;
					
					
					SrcAddr[0] <= source_short_ptr->source_address;
					
					msdu_length <= pdu->length - data_len;

					--memcpy(&payload,&pdu->data[data_len],msdu_length * sizeof(uint8_t));
					
					MCPS_DATA.indication((uint16_t)source_address, (uint16_t)source_short_ptr->source_PAN_identifier, SrcAddr,(uint16_t)destination_address, (uint16_t)dest_long_ptr->destination_PAN_identifier, DstAddr, (uint16_t)msdu_length, payload, (uint16_t)ppduLinkQuality, 0x0000,0x0000);  

				end if;
				
				
				--Destination SHORT - Source SHORT
				if ( destination_address = SHORT_ADDRESS and source_address = SHORT_ADDRESS )then
					dest_short_ptr <= (dest_short *) &pdu->data[0];
					source_short_ptr <= (source_short *) &pdu->data[DEST_SHORT_LEN];
					
					--If a short destination address is included in the frame, it shall match either macShortAddress or the
					--broadcast address (0 x ffff). Otherwise, if an extended destination address is included in the frame, it
					--shall match aExtendedAddress.
					if ( dest_short_ptr->destination_address != 0xffff and dest_short_ptr->destination_address != mac_PIB.macShortAddress) then
						--////printfUART("data rejected, short destination not for me\n", ""); 
						return;
					end if;
					--If a destination PAN identifier is included in the frame, it shall match macPANId or shall be the
					--broadcast PAN identifier (0 x ffff).
					if(dest_short_ptr->destination_PAN_identifier != 0xffff and dest_short_ptr->destination_PAN_identifier != mac_PIB.macPANId ) then
						--////printfUART("SH SH data rejected, wrong destination PAN %x\n",mac_PIB.macPANId ); 
						return;
					end if;
					
					data_len <= 8;
					
					if ( get_fc1_ack_request(pdu->frame_control1) = 1 ) then
						build_ack(pdu->seq_num,0);
					enf if;
					
					DstAddr[0] <=dest_short_ptr->destination_address;
					
					SrcAddr[0] <=source_short_ptr->source_address;
					
					msdu_length <= (pdu->length - 5) - data_len;
					
					
					--memcpy(&payload,&pdu->data[data_len],msdu_length * sizeof(uint8_t));
				
					MCPS_DATA.indication((uint16_t)source_address, (uint16_t)source_short_ptr->source_PAN_identifier, SrcAddr,(uint16_t)destination_address, (uint16_t)dest_short_ptr->destination_PAN_identifier, DstAddr, (uint16_t)msdu_length,payload, (uint16_t)ppduLinkQuality, 0x0000,0x0000);  

				end if;
			end if;
			
			--/*********NO DESTINATION ADDRESS PRESENT ****************/
			
			if ( destination_address = 0 && source_address > 1 ) then
				if (source_address = LONG_ADDRESS) then
					--Source LONG
					source_long_ptr <= (source_long *) &pdu->data[0];
					
					--If only source addressing fields are included in a data or MAC command frame, the frame shall be
					--accepted only if the device is a PAN coordinator and the source PAN identifier matches macPANId.
					if ( PANCoordinator==0 or source_long_ptr->source_PAN_identifier != mac_PIB.macPANId ) then
						--////////////printfUART("data rejected, im not pan\n", ""); 
						return;
					end if;
					
					data_len <= 10;
					
					SrcAddr[1] <=source_long_ptr->source_address0;
					SrcAddr[0] <=source_long_ptr->source_address1;
					
					msdu_length <= pdu->length - data_len;

					--memcpy(&payload,&pdu->data[data_len],msdu_length * sizeof(uint8_t));
					
					MCPS_DATA.indication((uint16_t)source_address,(uint16_t)source_long_ptr->source_PAN_identifier, SrcAddr,(uint16_t)destination_address, 0x0000, DstAddr, (uint16_t)msdu_length, payload, (uint16_t)ppduLinkQuality, 0x0000,0x0000);  
				else
					--Source SHORT

					source_short_ptr <= (source_short *) &pdu->data[0];
					--If only source addressing fields are included in a data or MAC command frame, the frame shall be
					--accepted only if the device is a PAN coordinator and the source PAN identifier matches macPANId.
					if ( PANCoordinator==0 or source_short_ptr->source_PAN_identifier != mac_PIB.macPANId ) then
						--////////////printfUART("data rejected, im not pan\n", ""); 
						return;
					end if;
					
					data_len <= 4;

					
					SrcAddr[0] <=source_short_ptr->source_address;
					
					msdu_length <= pdu->length - data_len;

					--memcpy(&payload,&pdu->data[data_len],msdu_length * sizeof(uint8_t));
					
					MCPS_DATA.indication((uint16_t)source_address, (uint16_t)source_short_ptr->source_PAN_identifier, SrcAddr,(uint16_t)destination_address, 0x0000, DstAddr, (uint16_t)msdu_length, payload, (uint16_t)ppduLinkQuality, 0x0000,0x0000);  

				end if;
			end if
			/*********NO SOURCE ADDRESS PRESENT ****************/
			
			if ( destination_address > 1 && source_address = 0 ) then
				if (destination_address = LONG_ADDRESS) then
					--Destination LONG
					dest_long_ptr <= (dest_long *) &pdu->data[0];
					
					--If a short destination address is included in the frame, it shall match either macShortAddress or the
					--broadcast address (0 x ffff). Otherwise, if an extended destination address is included in the frame, it
					--shall match aExtendedAddress.
					if ( dest_long_ptr->destination_address0 !=aExtendedAddress0 and dest_long_ptr->destination_address1 !=aExtendedAddress1 ) then
						--////////////printfUART("data rejected, ext destination not for me\n", ""); 
						return;
					end if;
					--If a destination PAN identifier is included in the frame, it shall match macPANId or shall be the
					--broadcast PAN identifier (0 x ffff).
					if(dest_long_ptr->destination_PAN_identifier != 0xffff and dest_long_ptr->destination_PAN_identifier != mac_PIB.macPANId ) then
						--////////////printfUART("data rejected, wrong destination PAN\n", ""); 
						return;
					end if;
					
					data_len <= 10;
					
					DstAddr[1] <= dest_long_ptr->destination_address0;
					DstAddr[0] <=dest_long_ptr->destination_address1;
					
					msdu_length <= pdu->length - data_len;

					--memcpy(&payload,&pdu->data[data_len],msdu_length * sizeof(uint8_t));
				
					MCPS_DATA.indication((uint16_t)source_address,0x0000, SrcAddr,(uint16_t)destination_address, (uint16_t)dest_long_ptr->destination_PAN_identifier, DstAddr, (uint16_t)msdu_length, payload, (uint16_t)ppduLinkQuality, 0x0000,0x0000);  

				else
					--Destination SHORT
					dest_short_ptr <= (dest_short *) &pdu->data[0];
					
					--If a short destination address is included in the frame, it shall match either macShortAddress or the
					--broadcast address (0 x ffff). Otherwise, if an extended destination address is included in the frame, it
					--shall match aExtendedAddress.
					if ( dest_short_ptr->destination_address != 0xffff and dest_short_ptr->destination_address != mac_PIB.macShortAddress) then
						--////////////printfUART("data rejected, short destination not for me\n", ""); 
						return;
					end if;
					--If a destination PAN identifier is included in the frame, it shall match macPANId or shall be the
					--broadcast PAN identifier (0 x ffff).
					if(dest_short_ptr->destination_PAN_identifier != 0xffff and  dest_short_ptr->destination_PAN_identifier != mac_PIB.macPANId ) then
						--////////////printfUART("data rejected, wrong destination PAN\n", ""); 
						return;
					end if;
					
					data_len <= 4;
					
					DstAddr[0] <=dest_short_ptr->destination_address;
					
					msdu_length <= pdu->length - data_len;

					--memcpy(&payload,&pdu->data[data_len],msdu_length * sizeof(uint8_t));
					
					
					MCPS_DATA.indication((uint16_t)source_address,0x0000, SrcAddr,(uint16_t)destination_address, (uint16_t)dest_short_ptr->destination_PAN_identifier, DstAddr, (uint16_t)msdu_length, payload, (uint16_t)ppduLinkQuality, 0x0000,0x0000);  

					--data_len = 4;
				end if;
			end if;
		else
		--intra_pan == 1
		end if;
	end procedure;
	
	
		
	 
	
	-- --- reception and transmission
	
	-- procedure send_frame_csma;
	
	-- function check_csma_ca_send_conditions( frame_length : uint8_t ;
											 -- frame_control1 : uint8_t) return uint8_t;

	-- function check_gts_send_conditions( frame_length : uint8_t) return uint8_t;
	
	-- function calculate_ifs( pk_length : uint8_t) return uint8_t;

	-- -- beacon management functions
	
	-- --function to create the beacon
	-- procedure create_beacon();
	-- --function to process the beacon information
	 procedure  process_beacon(packet : MPDU_t; ppduLinkQuality : uint8_t );
		-- ORGANIZE THE PROCESS BEACON FUNCION AS FOLLOWS.
		-- 1- GET THE BEACON ORDER
		-- 2- GET THE SUPERFRAME ORDER
		-- 3- GET THE FINAL CAP SLOT
		-- 4 - COMPUTE SD, BI, TS, BACKOFF PERIOD IN MILLISECONDS
		
		-- 4- SYNCHRONIZE THE NODE BY DOING THE FOLLOWING
			-- - SET A TIMER IN MS FOR THE FINAL TIME SLOT (SUPERFRAME DURATION) : IT EXPRIES AFTER SD - TX TIME - PROCESS TIME
			-- - SET A TIMER IN MS FOR THE GTS IF ANY EXIST IT EXPRIES AFTER GTS_NBR * TIME_SLOT - TX TIME - PROCESS TIME 
		signal SO_EXPONENT : uint32_t ;
		signal BO_EXPONENT : uint32_t ;
		signal i : integer :=0;
		signal gts_descriptor_addr : uint16_t;
		signal data_count : uint8_t;
		signal gts_directions: uint8_t;
		signal gts_des_count : uint8_t;
		signal gts_ss	:  uint8_t;
		signal gts_l	:  uint8_t;
		signal dir		:  uint8_t;
		signal dir_mask	:  uint8_t;	
		--function that processes the received beacon
		signal  beacon_ptr : access beacon_addr_short;
		signal  pan_descriptor : PANDescriptor;
		--pending frames
		signal short_addr_pending	: uint8_t :=0;
		signal long_addr_pending	: uint8_t :=0;
	begin
		--used in the track beacon
		beacon_processed <= 1;
		missed_beacons <=0;
		
		--initializing pointer to data structure
		beacon_ptr = (beacon_addr_short*) (packet->data);
		
		
		--decrement buffer count
		buffer_count <= buffer_count -1;
		
		-- drop packet if not in PAN
		--////printfUART("Received Beacon\n","");
		--////printfUART("rb panid: %x %x \n",beacon_ptr->source_address,mac_PIB.macCoordShortAddress);
		--////////printfUART("My macPANID: %x\n",mac_PIB.macPANId);
		
		if( beacon_ptr->source_address != mac_PIB.macCoordShortAddress) then
			return;
		end if;
		
		-- /**********************************************************************************/
		-- /*					PROCESSING THE SUPERFRAME STRUCTURE							  */
		-- /**********************************************************************************/
		
		if (PANCoordinator = 0) then
			mac_PIB.macBeaconOrder := get_beacon_order(beacon_ptr->superframe_specification);
			mac_PIB.macSuperframeOrder := get_superframe_order(beacon_ptr->superframe_specification);
			
			--mac_PIB.macCoordShortAddress = beacon_ptr->source_address;
			
			--////printfUART("BO,SO:%i %i\n",mac_PIB.macBeaconOrder,mac_PIB.macSuperframeOrder);
			
			--//mac_PIB.macPANId = beacon_ptr->source_PAN_identifier;
			
			--//beacon order check if it changed
			if (mac_PIB.macSuperframeOrder = 0) then
				SO_EXPONENT <= 1;
			else
				SO_EXPONENT <= powf(2,mac_PIB.macSuperframeOrder);
			end if;
			
			if ( mac_PIB.macBeaconOrder =0) then
				BO_EXPONENT <=1;
			else
					BO_EXPONENT <= powf(2,mac_PIB.macBeaconOrder);
			end if;
			BI <= aBaseSuperframeDuration * BO_EXPONENT; 
			SD <= aBaseSuperframeDuration * SO_EXPONENT; 
			
			--backoff_period
			backoff <= aUnitBackoffPeriod;
			time_slot <= SD / NUMBER_TIME_SLOTS;
			
			TimerAsync.set_bi_sd(BI,SD);
		end if;	
		
		--/**********************************************************************************/
		--/*							PROCESS GTS CHARACTERISTICS							  */
		--/**********************************************************************************/
		allow_gts <=1;
	
		--initializing the gts variables
		s_GTSss<=0;
		s_GTS_length<=0;
		
		r_GTSss<=0;
		r_GTS_length<=0;
		

		final_CAP_slot <= 15;


		gts_des_count <= (packet->data[8] & 0x0f);
		
		data_count <= 9;
		
		final_CAP_slot <= 15 - gts_des_count;
		
		if (gts_des_count > 0 ) then
			data_count <= 10; --position of the current data count
			--process descriptors
		
			gts_directions <= packet->data[9];
			
			--////printfUART("gts_directions:%x\n",gts_directions);
			
			for i in 0 to gts_des_count loop
				gts_descriptor_addr <= (uint16_t) packet->data[data_count];
					
				--////printfUART("gts_des_addr:%x mac short:%x\n",gts_descriptor_addr,mac_PIB.macShortAddress);
				
				data_count <= data_count+2;
				--check if it concerns me
				if (gts_descriptor_addr = mac_PIB.macShortAddress) then
					-- //confirm the gts request
					-- //////////////printfUART("packet->data[data_count]: %x\n",packet->data[data_count]);
					-- //gts_ss = 15 - get_gts_descriptor_ss(packet->data[data_count]);
					gts_ss <= get_gts_descriptor_ss(packet->data[data_count]);
					gts_l <= get_gts_descriptor_len(packet->data[data_count]);

					if ( i = 0 ) then
						dir_mask <= 1;
					else
							dir_mask = powf(2,i);
					end if;
					--//////////////printfUART("dir_mask: %x i: %x gts_directions: %x \n",dir_mask,i,gts_directions);
					dir <= ( gts_directions & dir_mask);
					if (dir = 0) then
						s_GTSss<=gts_ss;
						s_GTS_length<=gts_l;
					else
						r_GTSss=gts_ss;
						r_GTS_length=gts_l;
					end if;
					
					--////printfUART("PB gts_ss: %i gts_l: %i dir: %i \n",gts_ss,gts_l,dir);
					--//////////////printfUART("PB send_s_GTSss: %i send_s_GTS_len: %i\n",send_s_GTSss,send_s_GTS_len);
					
					if ( gts_l = 0 ) then
						allow_gts<=0;
					end if;

					if (gts_confirm = 1 and gts_l != 0) then
						--signal ok
						--///printfUART("gts confirm \n","");
						gts_confirm <=0;
						MLME_GTS.confirm(GTS_specification,MAC_SUCCESS);
					else
						--//signal not ok
						--//////////////printfUART("gts not confirm \n","");
						gts_confirm <=0;
						MLME_GTS.confirm(GTS_specification,MAC_DENIED);
					end if;
					
				end if;
				data_count <= data_count +1;	
			end loop;
		end if;
		
		--/**********************************************************************************/
		--/*							PROCESS PENDING ADDRESSES INFORMATION				  */
		--/**********************************************************************************/	
		--//this should pass to the network layer
		
		
		short_addr_pending<=get_number_short(packet->data[data_count]);
		long_addr_pending<=get_number_extended(packet->data[data_count]);
		
		--////////////printfUART("ADD COUNT %i %i\n",short_addr_pending,long_addr_pending);
		
		data_count <= data_count +1;
		
		if(short_addr_pending > 0) then
		{
			for i in 0 to short_addr_pending loop
				--////////////printfUART("PB %i %i\n",(uint16_t)packet->data[data_count],short_addr_pending);
				
				--//if(packet->data[data_count] == (uint8_t)mac_PIB.macShortAddress && packet->data[data_count+1] == (uint8_t)(mac_PIB.macShortAddress >> 8) )
				if((uint16_t)packet->data[data_count] = mac_PIB.macShortAddress) then
					create_data_request_cmd();
				end if;
				data_count = data_count + 2;
			end loop;
		end if;
		if(long_addr_pending > 0) then
			for i in 0 to long_addr_pending loop
				if((uint32_t)packet->data[data_count] == aExtendedAddress0 && (uint32_t)packet->data[data_count + 4] == aExtendedAddress1) then	
					data_count = data_count + 8;
				end if;
			end loop;
		end if;
			
		--**********************************************************************************/
		--*				BUILD the PAN descriptor of the COORDINATOR						  */
		--**********************************************************************************/
			
		
	   --Beacon NOTIFICATION
	   --BUILD the PAN descriptor of the COORDINATOR
		--assuming that the adress is short
		pan_descriptor.CoordAddrMode <= SHORT_ADDRESS;
		pan_descriptor.CoordPANId <= 16#0000#;--beacon_ptr->source_PAN_identifier;
		pan_descriptor.CoordAddress0<=16#00000000#;
		pan_descriptor.CoordAddress1<=mac_PIB.macCoordShortAddress;
		pan_descriptor.LogicalChannel<=current_channel;
		--superframe specification field
		pan_descriptor.SuperframeSpec <= beacon_ptr->superframe_specification;
		
		pan_descriptor.GTSPermit<=mac_PIB.macGTSPermit;
		pan_descriptor.LinkQuality<=16#00#;
		pan_descriptor.TimeStamp<=16#000000#;
		pan_descriptor.SecurityUse<=0;
		pan_descriptor.ACLEntry<=16#00#;
		pan_descriptor.SecurityFailure=>16#00#;
	   
		--I_AM_IN_CAP = 1;
	   
		--/**********************************************************************************/
		--/*								SYNCHRONIZING									  */
		--/**********************************************************************************/
		--
		if(PANCoordinator == 0) then
			I_AM_IN_CAP <= 1;
			I_AM_IN_IP <= 0;
			
			
			if(findabeacon = 1) then
				--////printfUART("findabeacon\n", "");
				TimerAsync.set_timers_enable(1);
				findabeacon =0;
			end if;
			
			-- //#ifdef PLATFORM_MICAZ
			-- //number_time_slot = call TimerAsync.reset_start(start_reset_ct+process_tick_counter+52);// //SOBI=3 52 //SOBI=0 15
			-- //#else
			
			-- //call TimerAsync.reset();
			
			number_time_slot <=  TimerAsync.reset_start(75);   --95 old val sem print
					
			-- // +process_tick_counter+52 //SOBI=3 52 //SOBI=0 
			-- //#endif
			on_sync<=1;
			
			--////printfUART("sED\n", "");
		end if;	
		MLME_BEACON_NOTIFY.indication((uint8_t)packet->seq_num,pan_descriptor,0, 0, mac_PIB.macBeaconPayloadLenght, packet->data);
			
	end procedure;
	
	
	
	
	-- -- fault tolerance commands
	
		
	-- procedure create_coordinator_realignment_cmd( device_extended0 : uint32_t;
												 -- device_extended1 : uint32_t;
												  -- device_short_address :uint16_t);
	-- procedure create_orphan_notification;
	procedure process_coordinator_realignment(MPDU_ptr : access MPDU_t);
	
	begin
		--cmd_coord_realignment *cmd_realignment = 0;
	
		--dest_long *dest_long_ptr=0;
		--source_short *source_short_ptr=0;

		--cmd_realignment = (cmd_coord_realignment*) &pdu->data[DEST_LONG_LEN + SOURCE_SHORT_LEN];
		
		--//creation of a pointer the addressing structures
		--dest_long_ptr = (dest_long *) &pdu->data[0];
		--source_short_ptr = (source_short *) &pdu->data[DEST_LONG_LEN];
			
		--mac_PIB.macCoordShortAddress = ((cmd_realignment->coordinator_short_address0 << 8) | cmd_realignment->coordinator_short_address0 );
		--mac_PIB.macShortAddress = cmd_realignment->short_address;
		
		
		--printfUART("PCR %i %i\n",mac_PIB.macCoordShortAddress,mac_PIB.macShortAddress); 
	end procedure;

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
		signal findabeacon : boolean := FALSE;
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
		-- GTS_db : array (0 to GTS_db_size) of GTSinfoEntryType ;
		-- signal GTS_descriptor_count : uint8_t :=0;
		-- signal GTS_startslot : uint8_t :=16;
		-- signal GTS_id : uint8_t :=16#01#;


		-- //null gts descriptors
		--  GTS_null_db : array (0 to GTS_db_size) of GTSinfoEntryType_null;
		
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
		-- gts_slot_list:  array (0 to GTS_db_size) of gts_slot_element;
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
		type ACK_ptr is access ACK_t
		signal  mac_ack : ACK_t;
		signal  mac_ack_ptr :  ACK_ptr;
		
		-- signal gts_expiration : uint32_t;

		signal I_AM_IN_CAP	: uint8_t :=0;
		-- signal I_AM_IN_CFP	: uint8_t :=0;
		signal I_AM_IN_IP	: uint8_t :=0;
		
		-- beacon management signal and variables
		type MPDU_ptr is access MPDU_t;
		signal  mac_beacon_txmpdu : MPDU_t;
		signal  mac_beacon_txmpdu_ptr : access MPDU_ptr;
		
		-- signal send_beacon_frame_ptr : access uint8_t;
		-- signal send_beacon_length : uint8_t;
		                                  

	 begin
		-- MCPS_DATA.request.SrcAddrMode <= NO_ADDRESS;
		
		reset : process
		begin
			init_MacPIB();
			init_GTS_db();
			init_GTS_null_db();
			init_gts_slot_list();
			init_available_gts_index();
			aExtendedAddress0=TOS_NODE_ID;
			aExtendedAddress1=TOS_NODE_ID;
			AddressFilter.set_address(mac_PIB.macShortAddress, aExtendedAddress0, aExtendedAddress1);
			AddressFilter.set_coord_address(mac_PIB.macCoordShortAddress, mac_PIB.macPANId);
			init_indirect_trans_buffer();
			mac_beacon_txmpdu_ptr := new MPDU_t'(mac_beacon_txmpdu);
			mac_ack_ptr := new ACK_t'(mac_ack);
			ackwait_period := ((mac_PIB.macAckWaitDuration * 4.0 ) / 250.0) * 3;
			response_wait_time := ((aResponseWaitTime * 4.0) / 250.0) * 2;
		
			BI := aBaseSuperframeDuration * powf(2,mac_PIB.macBeaconOrder);
			SD := aBaseSuperframeDuration * powf(2,mac_PIB.macSuperframeOrder);
			
			
			--backoff_period
			backoff := aUnitBackoffPeriod;
			--backoff_period_boundary
			
			time_slot := SD / NUMBER_TIME_SLOTS;
			
			TimerAsync.set_enable_backoffs(1);	
			TimerAsync.set_backoff_symbols(backoff);
			TimerAsync.set_bi_sd(BI,SD);
			TimerAsync.start();
			wait;
		end process;
		
		TimerAsync_before_bi_fired : process (TimerAsync.before_bi_fired)
		begin
		
			if (mac_PIB.macBeaconOrder != mac_PIB.macSuperframeOrder ) then
				if ( Beacon_enabled_PAN = 1 ) then
					trx_status <= PHY_TX_ON;
					PLME_SET_TRX_STATE.request(PHY_TX_ON);
				else
					trx_status = PHY_RX_ON;
					PLME_SET_TRX_STATE.request(PHY_RX_ON);
				end if;
			end if;
			findabeacon <= TRUE;
		end process;
		
		TimerAsync_bi_fired : process ( TimerAsync.bi_fired)
		begin
			I_AM_IN_CAP <= 1;
			I_AM_IN_IP <= 0;
			if ( Beacon_enabled_PAN = 1 ) then
				PD_DATA.request(send_beacon_length,send_beacon_frame_ptr);
			end if;
			number_backoff <=0;
			number_time_slot<=0;
			if (TrackBeacon == 1) then
				if (beacon_processed=1) then
					beacon_processed <=0;
				else 
					on_sync =0;
					beacon_loss_reason = MAC_BEACON_LOSS;
					--TODO
					--post signal_loss();
				end if;
			end if;
		send_frame_csma();					
		end process;
		
		TimerAsync_sd_fired process(TimerAsync.sd_fired);
		begin
			I_AM_IN_CFP <= 0;
			I_AM_IN_IP <= 1;
			
			
			number_backoff <=0;
			number_time_slot <=0;
			
			
			if (PANCoordinator = 0 and TYPE_DEVICE == ROUTER) then
				trx_status = PHY_RX_ON;
				PLME_SET_TRX_STATE.request(PHY_RX_ON);
			else
				trx_status = PHY_RX_ON;
				PLME_SET_TRX_STATE.request(PHY_RX_ON);
			end if;
			
			if (mac_PIB.macShortAddress=0xffff and TYPE_DEVICE == END_DEVICE) then
				trx_status = PHY_RX_ON;
				PLME_SET_TRX_STATE.request(PHY_RX_ON);
			end if;
			
			if (PANCoordinator = 1) then
				--increment the gts_null descriptors
						--if (GTS_null_descriptor_count > 0) post increment_gts_null();
						--if (GTS_descriptor_count >0 ) post check_gts_expiration();
						--if (indirect_trans_count > 0) increment_indirect_trans();
						--creation of the beacon
						create_beacon();
			
				--trx_status = PHY_TRX_OFF;
				--post set_trx();
			
			else
			--temporariamente aqui //aten��o quando for para o cluster-tree � preciso mudar para fora
			--e necessario destinguir ZC de ZR (que tem que manter a sync com o respectivo pai)
				if (on_sync = 0) then
				--sync not ok
				--findabeacon=1;
					if (missed_beacons = aMaxLostBeacons) then
						--out of sync
						 signal_loss();
					end if;
					missed_beacons <= missed_beacons + 1;
				else
					--sync ok
					missed_beacons <=0;
					on_sync <=0;
				end if;
			end if;
		end process;
		
		TimerAsync_before_time_slot_fired : process (TimerAsync.before_time_slot_fired);
		begin 
			on_s_GTS <=0;
			on_r_GTS <=0;
			
			if (next_on_s_GTS = 1) then	
				on_s_GTS <=1;
				next_on_s_GTS <=0;
				trx_status <= PHY_TX_ON;
				PLME_SET_TRX_STATE.request(PHY_TX_ON);
				--post set_trx();
			end if;
			
			if (next_on_r_GTS = 1) then
				on_r_GTS <=1;
				next_on_r_GTS <=0;
				trx_status <= PHY_RX_ON;
				PLME_SET_TRX_STATE.request(PHY_RX_ON);
				--post set_trx();
			end if;
		end process;
			
		TimerAsync_time_slot_fired : process (TimerAsync.time_slot_fired);
		begin
			--reset the backoff counter and increment the slot boundary
			number_backoff <=0;
			number_time_slot <= number_time_slot;
			--verify is there is data to send in the GTS, and try to send it
			if (PANCoordinator = 1 and GTS_db[15-number_time_slot].direction = 1 and GTS_db[15-number_time_slot].gts_id != 0) then
				--COORDINATOR SEND DATA
				start_coordinator_gts_send();
			else
				--DEVICE SEND DATA
				if (number_time_slot = s_GTSss and gts_send_buffer_count > 0 and on_sync == 1) then --(send_s_GTSss-send_s_GTS_len) 
				
						--current_time = call TimerAsync.get_total_tick_counter();
						start_gts_send();
				end if	
			end if;
	
			next_on_r_GTS <=0;
			next_on_s_GTS <=0;
			
	
			--verification if the time slot is entering the CAP
			--GTS FIELDS PROCESSING
			
			if ((number_time_slot + 1) >= final_CAP_slot and (number_time_slot + 1) < 16) then
				I_AM_IN_CAP <= 0;
				I_AM_IN_CFP <= 1;
			
				--verification of the next time slot
				if(PANCoordinator = 1 and number_time_slot < 15) then

				--COORDINATOR verification of the next time slot
					if(GTS_db[14-number_time_slot].gts_id != 0x00 and GTS_db[14-number_time_slot].DevAddressType != 0x0000) then	
						if(GTS_db[14-number_time_slot].direction = 1 ) -- device wants to receive
							next_on_s_GTS <=1; --PAN coord mode
						else
							next_on_r_GTS<=1; --PAN coord mode
						end if;
					end if;	
				else
				--device verification of the next time slot
					if( (number_time_slot +1) = s_GTSss or (number_time_slot +1) = r_GTSss )
						if((number_time_slot + 1) = s_GTSss)
							next_on_s_GTS <=1;
							s_GTS_length <= s_GTS_length -1;
							if (s_GTS_length != 0 ) then
								s_GTSss <= s_GTSss +1;
							end if;
						else			
							next_on_r_GTS <=1;
							r_GTS_length <= r_GTS_length -1;
							if (r_GTS_length != 0 ) then
								r_GTSss <= r_GTSss+1;
							end if;
						end if				
					else
						--idle
						next_on_s_GTS <=0;
						next_on_r_GTS <=0;
					end if;
				end if;
			end if;
		end process;
		
		TimerAsync_backoff_fired : process (TimerAsync.backoff_fired)
		begin
			if( csma_locate_backoff_boundary = 1 ) then
				csma_locate_backoff_boundary <=0;
				
				--post start_csma_ca_slotted();
				
				--DEFERENCE CHANGE
				if (backoff_deference = 0) then
					---normal situation
					delay_backoff_period := (call Random.rand16() & ((uint8_t)(powf(2,BE)) - 1));
					
					if (check_csma_ca_backoff_send_conditions((uint32_t) delay_backoff_period) = 1) then
						backoff_deference <= 1;
					end if;
				else
					backoff_deference <= 0;
				end if;
				
				csma_delay <=1;
			end if;
			if( csma_cca_backoff_boundary = 1 ) then
				perform_csma_ca_slotted();
			end if;
			if(csma_delay = 1 ) then
				if (delay_backoff_period = 0) then
					if(csma_slotted = 0) then
						perform_csma_ca_unslotted();
					else
						--CSMA/CA SLOTTED
						csma_delay <=0;
						csma_cca_backoff_boundary<=1;
					end if;
				end if;
				delay_backoff_period<=delay_backoff_period-1;
			end if;
			number_backoff++;
		end process;
		
		T_ackwait_fired : process (T_ackwait.fired)
		begin
			if (send_ack_check = 1) then
				retransmit_count <= retransmit_count + 1;
				if (retransmit_count = aMaxFrameRetries or send_indirect_transmission > 0) then
						--check the type of data being send
						-- /*
						-- if (associating == 1)
						-- {
							-- //printfUART("af ack\n", "");
							-- associating=0;
							-- signal MLME_ASSOCIATE.confirm(0x0000,MAC_NO_ACK);
						-- }
						-- */
						

						--stardard procedure, if fail discard the packet
						send_buffer_count <= send_buffer_count -1;
						send_buffer_msg_out <=  send_buffer_msg_out +1;
					
						--failsafe
						if(send_buffer_count > SEND_BUFFER_SIZE) then
							
							send_buffer_count <=0;
							send_buffer_msg_out <=0;
							send_buffer_msg_in <=0;
							
						end if;
						
						
						if (send_buffer_msg_out = SEND_BUFFER_SIZE) then
							send_buffer_msg_out <=0;
						end if;
						
						if (send_buffer_count > 0) then
							send_frame_csma();
						end if;
							
						send_ack_check <=0;
						retransmit_count <=0;
						ack_sequence_number_check <=0;
	
				end if;
				--retransmissions
				send_frame_csma();
			end if;
		end process;
		
		T_ResponseWaitTime_fired : process (T_ResponseWaitTime.fired)
		begin
			if (associating = 1) then
				associating<=0;
				MLME_ASSOCIATE.confirm(0x0000,MAC_NO_DATA);
			end if;
		end process;
		
		PD_DATA_indication : process (PD_DATA.indication) -- the indication will pass (uint8_t psduLenght,uint8_t* psdu, int8_t ppduLinkQuality)
		begin
			if (buffer_count > RECEIVE_BUFFER_SIZE) then
				--mo place in rec buffer -> some error may accure
			else
				--memcpy(&buffer_msg[current_msg_in],psdu,sizeof(MPDU));
				current_msg_in <=current_msg_in+1;
				if ( current_msg_in = RECEIVE_BUFFER_SIZE ) then
					current_msg_in <= 0;
				end if;
				buffer_count <=  buffer_count +1;
				link_quality = ppduLinkQuality;
				if (scanning_channels =1) then
					data_channel_scan_indication();
				else 
					data_indication();
				end if;
			end if;
		end process;
		
		
		
		
	 end architecture MAC_core;

end MAC;

	