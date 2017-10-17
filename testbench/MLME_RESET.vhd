use work.MAC_pack.all;

package MLME_RESET is
	-- use the primitive declarations in MAC_pack
	type MLME_RESET_t is protected
		procedure request(variable macPIB: out macPIB_t; SetDefaultPIB : in boolean);
		impure function confirm return Status_t;
	end protected;
end package;

package body MLME_RESET  is
	
	type MLME_RESET_t is protected body
		variable Status : Status_t;
		procedure request(variable macPIB: out macPIB_t; SetDefaultPIB : in boolean) is
		begin
			Status := SUCCESS;
			macPIB.macExtendedAddress  :=  (0,0,0,0,0,0,0,0);
			macPIB.macAckWaitDuration  :=  0;
			macPIB.macAssociatedPANCoord:=  FALSE;
			macPIB.macAssociationPermit:=  FALSE;
			macPIB.macAutoRequest:=  FALSE;
			macPIB.macBattLifeExt:=  FALSE;
			macPIB.macBattLifeExtPeriods  :=  0;
			macPIB.macBeaconPayload :=  (others => 0);
			macPIB.macBeaconPayloadLength  :=  0;
			macPIB.macBeaconOrder  :=  0;
			macPIB.macBeaconTxTime  :=  0;
			macPIB.macBSN  :=  0;
			macPIB.macCoordExtendedAddress :=  (0,0,0,0,0,0,0,0);
			macPIB.macCoordShortAddress	 :=  0;
			macPIB.macDSN	 :=  0;
			macPIB.macGTSPermit:=  FALSE;
			macPIB.macMaxBE  :=  0;
			macPIB.macMaxCSMABackoffs  :=  0;
			macPIB.macMaxFrameTotalWaitTime  :=  0;
			macPIB.macMaxFrameRetries  :=  0;
			macPIB.macMinBE  :=  0;
			macPIB.macLIFSPeriod  :=  0;
			macPIB.macSIFSPeriod  :=  0;
			macPIB.macPANId  :=  0;
			macPIB.macPromiscuousMode:=  FALSE;
			macPIB.macRangingSupported:=  FALSE;
			macPIB.macResponseWaitTime  :=  0;
			macPIB.macRxOnWhenIdle:=  FALSE;
			macPIB.macSecurityEnabled:=  FALSE;
			macPIB.macShortAddress  :=  0;
			macPIB.macSuperframeOrder  :=  0;
			macPIB.macSyncSymbolOffset  :=  0;
			macPIB.macTimestampSupported :=  FALSE;
			macPIB.macTransactionPersistenceTime  :=  0;
			macPIB.macTxControlActiveDuration :=  0;
			macPIB.macTxControlPauseDuration :=  0;
			macPIB.macTxTotalDuration :=  0;
		end procedure;

		impure function confirm return Status_t is
		begin
			return Status;
		end function;
	end protected body;
end package body;