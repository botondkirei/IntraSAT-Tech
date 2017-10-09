use work.MAC_pack.all;

package MLME_ASSOCIATE is
	-- use the primitive declarations in MAC_pack
	type MLME_ASSOCIATE_t is protected
		procedure request(variable macPIB: out macPIB_t; TimerAsync : inout TimerAsync_t; MLME_ASSOCIATE_REQUEST : in  MLME_ASSOCIATE_REQUEST_t; Association_request_frame : inout Association_request_frame_t);
		procedure response(variable macPIB: out macPIB_t; MLME_ASSOCIATE_RESPONE : in  MLME_ASSOCIATE_RESPONE_t; Association_response_frame : inout Association_response_frame_t);
		function indication ( Association_request_frame : inout Association_request_frame_t) return is  MLME_ASSOCIATE_INDICATION_t;
		function confirm is return MLME_ASSOCIATE_CONFIRM_t;
		impure function is_associating return boolean;
		--impure function confirm return Status_t;
	end protected;
end package;

package body MLME_ASSOCIATE  is
	
	type MLME_ASSOCIATE_t is protected body
		variable associating : boolean;
		variable CurrentChannel : integer;
		procedure request(variable macPIB: out macPIB_t; TimerAsync : inout TimerAsync_t; MLME_ASSOCIATE_REQUEST : in  MLME_ASSOCIATE_REQUEST_t;Association_request_frame : inout Association_request_frame_t ) is
		begin
			report "Association requets!" severity note;
			mac_PIB.macPANId  := MLME_ASSOCIATE_REQUEST.CoordPANId;
			mac_PIB.macCoordShortAddress  := MLME_ASSOCIATE_REQUEST.CoordAddress;
			associating := TRUE;
			TimerAsync.set_timers_enable(TRUE);
			current_channel := MLME_ASSOCIATE_REQUEST.LogicalChannel;
			Association_request_frame.create_association_request_cmd(MLME_ASSOCIATE_REQUEST);
		end procedure;

		procedure response(MLME_ASSOCIATE_RESPONE : in  MLME_ASSOCIATE_RESPONE_t; Association_response_frame : inout Association_response_frame_t) is
		begin
			report "Association response!" severity note;	
			Association_response_frame.create_association_response_cmd(MLME_ASSOCIATE_RESPONE);
		end procedure;
		
		function indication ( Association_request_frame : inout Association_request_frame_t) return is  MLME_ASSOCIATE_INDICATION_t is
		begin
		end function;
		
		function confirm is return MLME_ASSOCIATE_CONFIRM_t is
		begin
			
		end function;

		
		impure function is_associating return boolean is
		begin
			return associating;
		end function;
	end protected body;
end package body;