-- Wisat2 test setup, Wisat_setup in instatiated to close a transmission/reception chain
-- Company : UTCN
-- Employee : Kirei Botond
-- Rev - 0.01 -file created

library work;
use work.utils.all;

entity test_setup is
end entity;

architecture testbench of test_setup is
	signal SpWTX, SpWRX : SpWIO;
	signal Channel : Antenna;
begin
	Generator : entity Spw_packet_gen port map (SpW => SpWTX)
	TX_setup: entity work.wisat2_board (SpW => SpWTX, Antenna => Channel);
	Rx_setup entity work.wisat2_board  (SpW => SpWRX, Antenna => Channel);
	Receiver : entity work.SpW_packet_check (SpW => SpWRX);
end architecture;

