use work.C_like_type_def.all;
use work.MAC_pack.all;
use work.MLME_SET.all;
use work.MLME_GET.all;
use work.MLME_RESET.all;
use work.MLME_START.all;
use work.MLME_ASSOCIATE.all;
use work.FIFO.all;

package MAC_t is

	type memory_t is array (0 to 4095) of uint8_t;
	type MAC_type is protected
		-- ASSCOSIATE interface wrapper methods
		procedure MLME_ASSOCIATE_request(MLME_START_REQUEST : in MLME_START_REQUEST_t);
		impure function MLME_ASSOCIATE_confirm return Status_t;
		-- START interface wrapper methods
		procedure MLME_START_request(MLME_START_REQUEST : in MLME_START_REQUEST_t);
		impure function MLME_START_confirm return Status_t;
		-- RESET interface wrapper methods
		procedure MLME_RESET_request(SetDefaultPIB : in boolean);
		impure function MLME_RESET_confirm return Status_t;
		-- SET interface wrapper methods
		procedure MLME_SET_request(PIBAttr : PIBAttr_t; PIBAttrVal : IEEE_address_t);
		procedure MLME_SET_request(PIBAttr : PIBAttr_t; PIBAttrVal : integer);
		procedure MLME_SET_request(PIBAttr : PIBAttr_t; PIBAttrVal : boolean);
		procedure MLME_SET_request(PIBAttr : PIBAttr_t; PIBAttrVal : macBeaconPayload_t);	
		impure function MLME_SET_confirm return MLME_SET_CONFIRM_t;
		-- GET interface wrapper methods
		procedure MLME_GET_request(PIBAttr : in PIBAttr_t);
		procedure MLME_GET_confirm(Status : out STATUS_t; PIBAttr : out PIBAttr_t; PIBAttrVal : out IEEE_address_t);
		procedure MLME_GET_confirm(Status : out STATUS_t; PIBAttr : out PIBAttr_t; PIBAttrVal : out integer);
		procedure MLME_GET_confirm(Status : out STATUS_t; PIBAttr : out PIBAttr_t; PIBAttrVal : out boolean);
		procedure MLME_GET_confirm(Status : out STATUS_t; PIBAttr : out PIBAttr_t; PIBAttrVal : out macBeaconPayload_t);
		-- SendBuffer interface wrapper methods
		procedure SendBuffer_push(element : in uint8_t);
		impure function SendBuffer_pull return uint8_t;
		impure function SendBuffer_isempty return boolean;
		impure function SendBuffer_isfull return boolean;
		-- ReceiveBuffer interface wrapper methods
		procedure ReceiveBuffer_push(element : in uint8_t);
		impure function ReceiveBuffer_pull return uint8_t;
		impure function ReceiveBuffer_isempty return boolean;
		impure function ReceiveBuffer_isfull return boolean;
	end protected;
end package MAC_t;

package body MAC_t is

	type MAC_type is protected body
		variable macPIB: macPIB_t;
		variable memory : memory_t;
		variable MLME_GET : MLME_GET_t;
		variable MLME_SET : MLME_SET_t;	
		variable MLME_RESET : MLME_RESET_t;
		variable MLME_START : MLME_START_t;
		variable MLME_ASSOCIATE : MLME_ASSOCIATE_t;
		variable SendBuffer : FIFO_t;
		variable ReceiveBuffer : FIFO_t;
		-- ASSCOSIATE interface wrapper methods
		procedure MLME_ASSOCIATE_request(MLME_ASSOCIATE_request : in MLME_ASSOCIATE_request_t) is
		begin
			MLME_ASSOCIATE.request(MLME_ASSOCIATE_request);
		end procedure;
		impure function MLME_ASSOCIATE_confirm return Status_t is
		begin
			return MLME_ASSOCIATE_confirm;
		end function;
		-- START interface wrapper methods
		procedure MLME_START_request(MLME_START_REQUEST : in MLME_START_REQUEST_t) is
		begin
			MLME_START.request(macPIB,MLME_START_REQUEST);
		end procedure;
		impure function MLME_START_confirm return Status_t is
		begin
			return MLME_START.confirm;
		end procedure;
		-- RESET interface wrapper methods
		procedure MLME_RESET_request(SetDefaultPIB : in boolean) is
		begin
			MLME_RESET.request(macPIB,SetDefaultPIB);
		end procedure;
		impure function MLME_RESET_confirm return Status_t is
		begin	
			return MLME_RESET.confirm ;
		end function;
		-- SET interface wrapper methods
		procedure MLME_SET_request(PIBAttr : PIBAttr_t; PIBAttrVal : IEEE_address_t) is
		begin
			MLME_SET.request(macPIB, PIBAttr, PIBAttrVal);
		end procedure;
		procedure MLME_SET_request(PIBAttr : PIBAttr_t; PIBAttrVal : integer) is
		begin
			MLME_SET.request(macPIB, PIBAttr, PIBAttrVal);
		end procedure;
		procedure MLME_SET_request(PIBAttr : PIBAttr_t; PIBAttrVal : boolean) is
		begin
			MLME_SET.request(macPIB, PIBAttr, PIBAttrVal);
		end procedure;
		procedure MLME_SET_request(PIBAttr : PIBAttr_t; PIBAttrVal : macBeaconPayload_t) is
		begin
			MLME_SET.request(macPIB, PIBAttr, PIBAttrVal);
		end procedure;
		impure function MLME_SET_confirm return MLME_SET_CONFIRM_t is
		begin
			return MLME_SET.confirm;
		end function;
		-- GET interface wrapper methods
		procedure MLME_GET_request(PIBAttr : in PIBAttr_t) is
		begin
			MLME_GET.request(PIBAttr);
		end procedure;
		procedure MLME_GET_confirm(Status : out STATUS_t; PIBAttr : out PIBAttr_t; PIBAttrVal : out IEEE_address_t) is
		begin
			MLME_GET.confirm(macPiB,Status,PIBAttr,PIBAttrVal);
		end procedure;
		procedure MLME_GET_confirm(Status : out STATUS_t; PIBAttr : out PIBAttr_t; PIBAttrVal : out integer) is 
		begin
			MLME_GET.confirm(macPiB,Status,PIBAttr,PIBAttrVal);
		end procedure;
		procedure MLME_GET_confirm(Status : out STATUS_t; PIBAttr : out PIBAttr_t; PIBAttrVal : out boolean) is
		begin
			MLME_GET.confirm(macPiB,Status,PIBAttr,PIBAttrVal);
		end procedure;
		procedure MLME_GET_confirm(Status : out STATUS_t; PIBAttr : out PIBAttr_t; PIBAttrVal : out macBeaconPayload_t) is
		begin
			MLME_GET.confirm(macPiB,Status,PIBAttr,PIBAttrVal);
		end procedure;
		
		-- SendBuffer interface wrapper methods
		procedure SendBuffer_push(element : in uint8_t) is
		begin
			SendBuffer.push(element);
		end procedure;
		impure function SendBuffer_pull return uint8_t is
		begin
			return SendBuffer.pull;
		end function;
		impure function SendBuffer_isempty return boolean is
		begin
			return SendBuffer.isempty;
		end function;
		impure function SendBuffer_isfull return boolean is
		begin
			return SendBuffer.isfull;
		end function;
		
		-- ReceiveBuffer interface wrapper methods
		procedure ReceiveBuffer_push(element : in uint8_t) is
		begin
			ReceiveBuffer.push(element);
		end procedure;
		impure function ReceiveBuffer_pull return uint8_t is
		begin
			return ReceiveBuffer.pull;
		end function;
		impure function ReceiveBuffer_isempty return boolean is
		begin
			return ReceiveBuffer.isempty;
		end function;
		impure function ReceiveBuffer_isfull return boolean is
		begin
			return ReceiveBuffer.isfull;
		end function;
	end protected body;
				

	
end package body;
