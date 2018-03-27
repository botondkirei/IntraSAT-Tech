-- Wisat2 board setup for Wisat2 project
-- Company : UTCN
-- Employee : Kirei Botond
-- Rev - 0.01 -file created

--including standard libraries
library IEEE;
use IEEE.std_logic_1164.all;

--including utils library (type declarations, definition of spacewire interface, etc)
library work;
use work.utils.all;

entity Wisat2_setup is
	port ( SpW : inout SpWIO;
			Antenna : inout Antenna);
end entity;

architecture board_level_modeling of Wisat2_setup is
	signal FMC : FMCIO;
	signal FPGA_RadIO : RadIO;
begin
	SpW_FMC_board : entity work.SpW_FMC port map (SpW => SpW, FMC => FMC); 
	ZC706_board: entity work.ZC706 port map (FMC => FMC, FPGA_Radio => FPGA_RadIO);
	VN360_board : entity work.VN360 port map ( RadIO => FPGA_RadIO , Antenna => Antenna);
end architecture;