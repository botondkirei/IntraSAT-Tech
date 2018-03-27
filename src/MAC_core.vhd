use work.C_like_type_def.all;
use work.MAC_pack.all;
use work.MLME_SET.all;
use work.MLME_GET.all;
use work.MLME_RESET.all;
use work.FIFO.all;

	entity MAC_core is
		generic (FFD_not_RFD: boolean := TRUE);
		port ( 	--CLK: in std_logic;
				--WR_EN : in std_logic;
				--ADDR : in std_logic_vector;
				--DATA : inout std_logic_vector;
				--SendBuffer : out Buffer_t;
				--ReceiveBuffer : in Buffer_t
		);
	end entity MAC_core;

	architecture behavioral of MAC_core is

					
	begin

		
	end architecture;


use work.C_like_type_def.all;
use work.MAC_pack.all;
use work.MLME_SET.all;
use work.MLME_GET.all;
use work.MLME_RESET.all;
use work.MLME_START.all;
use work.MLME_ASSOCIATE.all;
use work.FIFO.all;
use work.MAC_t.all;
	
	entity MAC_test is
	end entity;
	
	architecture test of MAC_test is
		shared variable MAC0, MAC1 : MAC_type;
	begin

		
		initialize : process
			--variable macPIB: macPIB_t;
			variable MLME_SET_CONFIRM : MLME_SET_CONFIRM_t;		 
			variable status: STATUS_t;
			variable PIBAttr : PIBAttr_t;
			variable PIBAttrVal : boolean;		
			
		begin
			wait for 100 ns;
			--MAC0.MLME_SET_IFACE.request(MAC0.macPIB,macAutoRequest, TRUE);
			MAC0.MLME_SET_request(macAutoRequest, TRUE);
			MLME_SET_CONFIRM := MAC0.MLME_SET_confirm;
			wait for 100 ns;
			MAC0.MLME_GET_request(macAutoRequest);
			MAC0.MLME_GET_confirm(status, PIBAttr, PIBAttrVal);
			assert PIBAttrVal report "macAutoRequest not set to TRUE" severity error;
			wait for 100 ns;
			MAC0.MLME_RESET_request(TRUE);
			MAC0.MLME_GET_request(macAutoRequest);
			MAC0.MLME_GET_confirm(status, PIBAttr, PIBAttrVal);
			assert (PIBAttr /= macAutoRequest or PIBAttrVal /= FALSE) report "macAutoRequest not set to FALSE" severity error;
			wait;
		end process;
		
		transmit : process
			variable byte : uint8_t;
		begin
			if (not MAC0.SendBuffer_isempty) then
				byte := MAC0.SendBuffer_pull;
				MAC1.ReceiveBuffer_push(byte);
			end if;
			if (not MAC1.SendBuffer_isempty) then
				byte := MAC1.SendBuffer_pull;
				MAC0.ReceiveBuffer_push(byte);
			end if;
			wait for 10 ns;
		end process;
		
		startPAN : process
		begin
			MAC0.MLME_RESET_request(TRUE);
			while not MAC0.MLME_RESET_confirm loop
			end loop;
			MAC0.MLME_SET_request(panID, 0x01);
			while MAC0.MLME_SET_confirm /= SUCCESS loop
			end loop;
			MAC0.MLME_SCAN_request; -- active scan
			while MAC0.MLME_SCAN_request /= SUCCESS loop
			end loop;	
			MAC0.MLME_SCAN_request; -- energy detection
			while MAC0.MLME_SCAN_request /= SUCCESS loop
			end loop;
			--select PANID Short Address Channel
			MAC0.MLME_SET_request(ShortAddress, 0x01);
			while not MAC0.MLME_RESET_confirm loop
			end loop;
			MAC0.MLME_START_request;
			while not MAC0.MLME_START_confirm loop
			end loop;			
		end process;
		
		association : process
		begin
			wait 400 ns;
			MAC0.MLME_RESET_request(TRUE);
			MAC0.MLME_SCAN_request()
			wait;
		end process;
	end architecture;
		
				