use work.MAC_pack.all;

package MLME_SET is
	-- use the primitive declarations in MAC_pack
	type MLME_SET_t is protected
		procedure request(variable macPIB: inout macPIB_t; PIBAttr : PIBAttr_t; PIBAttrVal : IEEE_address_t);
		procedure request(variable macPIB: inout macPIB_t; PIBAttr : PIBAttr_t; PIBAttrVal : integer);
		procedure request(variable macPIB: inout macPIB_t; PIBAttr : PIBAttr_t; PIBAttrVal : boolean);
		procedure request(variable macPIB: inout macPIB_t; PIBAttr : PIBAttr_t; PIBAttrVal : macBeaconPayload_t);	
		impure function confirm return MLME_SET_CONFIRM_t;
	end protected;
end package;

package body MLME_SET  is
	
	type MLME_SET_t is protected body
		variable MLME_SET_CONFIRM : MLME_SET_CONFIRM_t;
		procedure request(variable macPIB: inout macPIB_t; PIBAttr : PIBAttr_t; PIBAttrVal : IEEE_address_t) is
		begin
			-- declare IEEE_address_t in MAC_pack
			MLME_SET_CONFIRM.Status := SUCCESS;
			MLME_SET_CONFIRM.PIBAttr := PIBAttr;			
			case PIBAttr is
				when  macExtendedAddress  => MLME_SET_CONFIRM.Status := READ_ONLY; --macPIB.macExtendedAddress			 := PIBAttrVal;
				when  macCoordExtendedAddress  => macPIB.macCoordExtendedAddress :=  PIBAttrVal;
				when others => MLME_SET_CONFIRM.Status := UNSUPPORTED_ATTRIBUTE;
		end case;

		end procedure;
		procedure request(variable macPIB: inout macPIB_t; PIBAttr : PIBAttr_t; PIBAttrVal : integer) is
		begin
			MLME_SET_CONFIRM.Status := SUCCESS;
			MLME_SET_CONFIRM.PIBAttr := PIBAttr;			
			case PIBAttr is
				when macAckWaitDuration                 => MLME_SET_CONFIRM.Status := READ_ONLY; --macPIB.macAckWaitDuration			:=PIBAttrVal;	
				when macBattLifeExtPeriods              => macPIB.macBattLifeExtPeriods         := PIBAttrVal;
				when macBeaconPayloadLength             => macPIB.macBeaconPayloadLength        := PIBAttrVal;
				when macBeaconOrder                     => macPIB.macBeaconOrder                := PIBAttrVal;
				when macBeaconTxTime                    => MLME_SET_CONFIRM.Status := READ_ONLY; --macPIB.macBeaconTxTime               :=PIBAttrVal;
				when macBSN                             => macPIB.macBSN                        := PIBAttrVal;
				when macCoordShortAddress               => macPIB.macCoordShortAddress          := PIBAttrVal;
				when macDSN                             => macPIB.macDSN                        := PIBAttrVal;
				when macMaxBE                           => macPIB.macMaxBE                      := PIBAttrVal;
				when macMaxCSMABackoffs                 => macPIB.macMaxCSMABackoffs            := PIBAttrVal;
				when macMaxFrameTotalWaitTime           => macPIB.macMaxFrameTotalWaitTime      := PIBAttrVal;
				when macMaxFrameRetries                 => macPIB.macMaxFrameRetries            := PIBAttrVal;
				when macMinBE                           => macPIB.macMinBE                      := PIBAttrVal;
				when macLIFSPeriod                      => MLME_SET_CONFIRM.Status := READ_ONLY; --macPIB.macLIFSPeriod                 :=PIBAttrVal;
				when macSIFSPeriod                      => MLME_SET_CONFIRM.Status := READ_ONLY; --macPIB.macSIFSPeriod                 :=PIBAttrVal;
				when macPANId                           => macPIB.macPANId                      := PIBAttrVal;
				when macResponseWaitTime                => macPIB.macResponseWaitTime           := PIBAttrVal;
				when macShortAddress                    => macPIB.macShortAddress               := PIBAttrVal;
				when macSuperframeOrder                 => MLME_SET_CONFIRM.Status := READ_ONLY; --macPIB.macSuperframeOrder            :=PIBAttrVal;
				when macSyncSymbolOffset                => MLME_SET_CONFIRM.Status := READ_ONLY; --macPIB.macSyncSymbolOffset           :=PIBAttrVal;
				when macTransactionPersistenceTime      => macPIB.macTransactionPersistenceTime := PIBAttrVal;
				when macTxControlActiveDuration         => macPIB.macTxControlActiveDuration    := PIBAttrVal;
				when macTxControlPauseDuration          => macPIB.macTxControlPauseDuration     := PIBAttrVal;
				when macTxTotalDuration                 => macPIB.macTxTotalDuration            := PIBAttrVal;
				when others => MLME_SET_CONFIRM.Status := UNSUPPORTED_ATTRIBUTE;
			end case;
			
		end procedure;
		procedure request(variable macPIB: inout macPIB_t; PIBAttr : PIBAttr_t; PIBAttrVal : boolean) is
		begin
			MLME_SET_CONFIRM.Status := SUCCESS;
			MLME_SET_CONFIRM.PIBAttr := PIBAttr;			
			case PIBAttr is
				when  macAssociatedPANCoord => macPIB.macAssociatedPANCoord :=  PIBAttrVal;
				when  macAssociationPermit  => macPIB.macAssociationPermit  :=  PIBAttrVal;
				when  macAutoRequest        => macPIB.macAutoRequest        :=  PIBAttrVal;
				when  macBattLifeExt        => macPIB.macBattLifeExt        :=  PIBAttrVal;
				when  macGTSPermit          => MLME_SET_CONFIRM.Status := READ_ONLY; --macPIB.macGTSPermit          := PIBAttrVal;		
				when  macPromiscuousMode    => macPIB.macPromiscuousMode    :=  PIBAttrVal;
				when  macRangingSupported   => MLME_SET_CONFIRM.Status := READ_ONLY; --macPIB.macRangingSupported   := PIBAttrVal;
				when  macRxOnWhenIdle       => macPIB.macRxOnWhenIdle       :=  PIBAttrVal;
				when  macSecurityEnabled    => macPIB.macSecurityEnabled    :=  PIBAttrVal;
				when  macTimestampSupported => macPIB.macTimestampSupported :=  PIBAttrVal;
				when others => MLME_SET_CONFIRM.Status := UNSUPPORTED_ATTRIBUTE;
			end case;
		end procedure;
		procedure request(variable macPIB: inout macPIB_t; PIBAttr : PIBAttr_t; PIBAttrVal : macBeaconPayload_t) is
		begin
			MLME_SET_CONFIRM.Status := SUCCESS;
			MLME_SET_CONFIRM.PIBAttr := PIBAttr;			
			macPIB.macBeaconPayload :=  PIBAttrVal;
		end procedure;
		impure function confirm return MLME_SET_CONFIRM_t is
		begin
			return MLME_SET_CONFIRM;
		end function;
	end protected body;
end package body;