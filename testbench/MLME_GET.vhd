use work.MAC_pack.all;

package MLME_GET is

	type MLME_GET_t is protected
		procedure request(PIBAttr : in PIBAttr_t);
		procedure confirm(variable macPIB: in macPIB_t; Status : out STATUS_t; PIBAttr : out PIBAttr_t; PIBAttrVal : out IEEE_address_t);
		procedure confirm(variable macPIB: in macPIB_t; Status : out STATUS_t; PIBAttr : out PIBAttr_t; PIBAttrVal : out integer);
		procedure confirm(variable macPIB: in macPIB_t; Status : out STATUS_t; PIBAttr : out PIBAttr_t; PIBAttrVal : out boolean);
		procedure confirm(variable macPIB: in macPIB_t; Status : out STATUS_t; PIBAttr : out PIBAttr_t; PIBAttrVal : out macBeaconPayload_t);
	end protected;
end package;

package body MLME_GET  is

	
	type MLME_GET_t  is protected body
		variable PIBAttr_p : PIBAttr_t;
		procedure request(PIBAttr : in PIBAttr_t) is
		begin
			PIBAttr_p := PIBAttr;
		end procedure;
		
		procedure confirm(variable macPIB: in macPIB_t; Status : out  STATUS_t; PIBAttr : out PIBAttr_t; PIBAttrVal : out IEEE_address_t) is
		begin
			Status := SUCCESS;
			PIBAttr := PIBAttr_p;
			case (PIBAttr_p) is
				when macExtendedAddress  => PIBAttrVal := macPIB.macExtendedAddress;
				when macCoordExtendedAddress  => PIBAttrVal := macPIB.macCoordExtendedAddress;
				when others => Status := UNSUPPORTED_ATTRIBUTE;
			end case;
		end procedure;
		procedure confirm(variable macPIB: in macPIB_t; Status : out  STATUS_t; PIBAttr : out PIBAttr_t; PIBAttrVal : out integer) is
		begin
			Status := SUCCESS;
			PIBAttr := PIBAttr_p;
			case PIBAttr_p is
				when macAckWaitDuration              => PIBAttrVal := macPIB.macAckWaitDuration			;	
				when macBattLifeExtPeriods           => PIBAttrVal := macPIB.macBattLifeExtPeriods        ;
				when macBeaconPayloadLength          => PIBAttrVal := macPIB.macBeaconPayloadLength       ;
				when macBeaconOrder                  => PIBAttrVal := macPIB.macBeaconOrder               ;
				when macBeaconTxTime                 => PIBAttrVal := macPIB.macBeaconTxTime              ;
				when macBSN                          => PIBAttrVal := macPIB.macBSN                       ;
				when macCoordShortAddress            => PIBAttrVal := macPIB.macCoordShortAddress         ;
				when macDSN                          => PIBAttrVal := macPIB.macDSN                       ;
				when macMaxBE                        => PIBAttrVal := macPIB.macMaxBE                     ;
				when macMaxCSMABackoffs              => PIBAttrVal := macPIB.macMaxCSMABackoffs           ;
				when macMaxFrameTotalWaitTime        => PIBAttrVal := macPIB.macMaxFrameTotalWaitTime     ;
				when macMaxFrameRetries              => PIBAttrVal := macPIB.macMaxFrameRetries           ;
				when macMinBE                        => PIBAttrVal := macPIB.macMinBE                     ;
				when macLIFSPeriod                   => PIBAttrVal := macPIB.macLIFSPeriod                ;
				when macSIFSPeriod                   => PIBAttrVal := macPIB.macSIFSPeriod                ;
				when macPANId                        => PIBAttrVal := macPIB.macPANId                     ;
				when macResponseWaitTime             => PIBAttrVal := macPIB.macResponseWaitTime          ;
				when macShortAddress                 => PIBAttrVal := macPIB.macShortAddress              ;
				when macSuperframeOrder              => PIBAttrVal := macPIB.macSuperframeOrder           ;
				when macSyncSymbolOffset             => PIBAttrVal := macPIB.macSyncSymbolOffset          ;
				when macTransactionPersistenceTime   => PIBAttrVal := macPIB.macTransactionPersistenceTime;
				when macTxControlActiveDuration      => PIBAttrVal := macPIB.macTxControlActiveDuration   ;
				when macTxControlPauseDuration       => PIBAttrVal := macPIB.macTxControlPauseDuration    ;
				when macTxTotalDuration              => PIBAttrVal := macPIB.macTxTotalDuration           ;
				when others => Status := UNSUPPORTED_ATTRIBUTE;
			end case;
		
		end procedure;
		
		procedure confirm(variable macPIB: in macPIB_t; Status : out  STATUS_t; PIBAttr : out PIBAttr_t; PIBAttrVal : out boolean) is
		begin
			Status := SUCCESS;
			PIBAttr := PIBAttr_p;
			case PIBAttr_p is
				when  macAssociatedPANCoord => PIBAttrVal := macPIB.macAssociatedPANCoord;
				when  macAssociationPermit  => PIBAttrVal := macPIB.macAssociationPermit ;
				when  macAutoRequest        => PIBAttrVal := macPIB.macAutoRequest       ;
				when  macBattLifeExt        => PIBAttrVal := macPIB.macBattLifeExt       ;
				when  macGTSPermit          => PIBAttrVal := macPIB.macGTSPermit         ;		
				when  macPromiscuousMode    => PIBAttrVal := macPIB.macPromiscuousMode   ;
				when  macRangingSupported   => PIBAttrVal := macPIB.macRangingSupported  ;
				when  macRxOnWhenIdle       => PIBAttrVal := macPIB.macRxOnWhenIdle      ;
				when  macSecurityEnabled    => PIBAttrVal := macPIB.macSecurityEnabled   ;
				when  macTimestampSupported => PIBAttrVal := macPIB.macTimestampSupported;
				when others => Status := UNSUPPORTED_ATTRIBUTE;
			end case;
		end procedure;
		
		procedure confirm(variable macPIB: in macPIB_t; Status : out STATUS_t; PIBAttr : out PIBAttr_t; PIBAttrVal : out macBeaconPayload_t) is
		begin
			Status := SUCCESS;
			PIBAttr := PIBAttr_p;
			PIBAttrVal := macPIB.macBeaconPayload;
		end procedure;

	end protected body;
	
end package body;