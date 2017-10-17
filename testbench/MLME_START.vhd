use work.MAC_pack.all;

package MLME_START is
	-- use the primitive declarations in MAC_pack
	type MLME_START_t is protected
		procedure request(variable macPIB: out macPIB_t; MLME_START_REQUEST : in  MLME_START_REQUEST_t);
		impure function confirm return Status_t;
	end protected;
end package;

package body MLME_START  is
	
	type MLME_START_t is protected body
		variable Status : Status_t;
		procedure request(variable macPIB: out macPIB_t; variable Beacon_enabled_PAN: inout Beacon_enabled_PAN; variable TimerAsync : inout TimerAsync_t; variable PLME_SET: inout PLME_SET_t; MLME_START_REQUEST : in  MLME_START_REQUEST_t) is
			variable BO_EXPONENT : uint32_t ;
			variable SO_EXPONENT : uint32_t ;		
		begin


	
			if MLME_START_REQUEST.PANCoordinator then
			Beacon_enabled_PAN :=1;
            
            
			if ( macPIB.macShortAddress = 0xffff)
			
				Status := MAC_NO_SHORT_ADDRESS;
			else
				macPIB.macBeaconOrder = beacon_order;
				
				if (MLME_START_REQUEST.beacon_order == 15) 
					macPIB.macSuperframeOrder = 15;
				else
					macPIB.macSuperframeOrder = MLME_START_REQUEST.superframe_order;
				end if;
			
				--PANCoordinator is set to TRUE
				if (MLME_START_REQUESTpan_coodinator == 1)
					macPIB.macPANId = MLME_START_REQUESTPANId;
					PLME_SET.request(MLME_START_REQUEST.PHYCURRENTCHANNEL,MLME_START_REQUEST.LogicalChannel);
				end if
				if MLME_START_REQUEST.CoordRealignment then --//generates and broadcasts a coordinator realignment command containing the new PANId and LogicalChannels
					-- coordinator reallignment command frame
					-- wait for ack
					if ACK then
						macPIB.BeaconOrder 	 := MLME_START_REQUEST.BeaconOrder 	    ;
						macPIB.SuperframeOrder  := MLME_START_REQUEST.SuperframeOrder  ;
						macPIB.PANId            := MLME_START_REQUEST.PANId            ;
						macPIB.ChannelPage      := MLME_START_REQUEST.ChannelPage      ;
						macPIB.ChannelNumber    := MLME_START_REQUEST.ChannelNumber    ;
						Status := SUCCESS;
					else
						Status := CHANNEL_ACCESS_FAILURE;
					end if;
				else 
					macPIB.BeaconOrder 	 := MLME_START_REQUEST.BeaconOrder 	    ;
					macPIB.SuperframeOrder  := MLME_START_REQUEST.SuperframeOrder  ;
					macPIB.PANId            := MLME_START_REQUEST.PANId            ;
					macPIB.ChannelPage      := MLME_START_REQUEST.ChannelPage      ;
					macPIB.ChannelNumber    := MLME_START_REQUEST.ChannelNumber    ;
				end if;
					
				if (MLME_START_REQUEST.securityenable) then
					--to do security options
				end if;
`			end if;
			
			if (macPIB.macSuperframeOrder = 0) then
				SO_EXPONENT := 1;
			else
				SO_EXPONENT := powf(2,macPIB.macSuperframeOrder);
            
			if ( macPIB.macBeaconOrder = 0) then
				BO_EXPONENT := 1;
			else
				BO_EXPONENT := powf(2,macPIB.macBeaconOrder);
			
			
			BI = aBaseSuperframeDuration * BO_EXPONENT; 
				
			SD = aBaseSuperframeDuration * SO_EXPONENT; 
			--backoff_period
			backoff = aUnitBackoffPeriod;

			
			time_slot := SD / NUMBER_TIME_SLOTS;

			TimerAsync.set_backoff_symbols(backoff);
			TimerAsync.set_bi_sd(BI,SD);
			TimerAsync.set_timers_enable(0x01);
			TimerAsync.reset();
				
			Status := SUCESS
		end procedure;

		impure function confirm return Status_t is
		begin
			return Status;
		end function;
	end protected body;
end package body;