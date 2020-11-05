----------------------------------------------------------------------------------
-- Company: VSB-TUO
-- Engineer: 
-- 
-- Create Date:    09:41:26 06/19/2009 
-- Design Name: 
-- Module Name:    mux_7seg_char - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mux_7seg_char is port (
	rst			: in std_logic ; 			-- asynchronn reset
	clk			: in std_logic ; 			-- CLOCK input
	DIN3,DIN2,DIN1,DIN0 : in character ;			 -- std_logic_vector(15 downto 0);		-- data input
	digit			: out std_logic_vector(3 downto 0);		-- digit drivers
	seg_out		: out std_logic_vector(7 downto 0));	-- segment drivers

end mux_7seg_char ;

architecture arch_mux_7seg_char of mux_7seg_char is

signal akt_znak		: character ;	-- aktualni pismeno
signal cd		: std_logic_vector(1 downto 0) ;	-- digit
signal seg		: std_logic_vector(7 downto 0);	-- segmenty


begin

process (CLK, rst)
begin
if rst = '1' then
	digit <= (others => '1') ;
	cd <= (others => '0') ;
	akt_znak <= ' ';
elsif CLK'event and CLK = '0' then
		cd(1 downto 0) <= cd(1 downto 0) + 1 ;
	case cd(1 downto 0) is 
		when "00" =>   akt_znak <= DIN0 ;   digit <= "1110" ; 
		when "01" =>   akt_znak <= DIN1 ;   digit <= "1101" ; 
		when "10" =>   akt_znak <= DIN2 ;   digit <= "1011" ; 
		when others => akt_znak <= DIN3 ;   digit <= "0111" ; 
	end case ;
end if ;
end process ;

--      0
--     ---  
--  5 |   | 1
--     ---   <- 6
--  4 |   | 2
--     ---
--      3
   
  with akt_znak SELect
  seg <= "11111001" when '1',   
         "10100100" when '2',   
         "10110000" when '3',   
         "10011001" when '4',   
         "10010010" when '5',   
         "10000010" when '6',   
         "11111000" when '7',   
         "10000000" when '8',   
         "10010000" when '9',   
			"11000000" when '0',	 
         "10001000" when 'a',   
         "10000011" when 'b',   
         "11000110" when 'c',   
         "10100001" when 'd',   
         "10000110" when 'e',   
         "10001110" when 'f',   
			"11000010" when 'g',
			"10001001" when 'h',
			"11111001" when 'i',
			"11100001" when 'j',
			"11000111" when 'l',
			"10101011" when 'n',
			"11000000" when 'o',
			"10001100" when 'p',
			"10101111" when 'r',
			"10010010" when 's',
			"10000111" when 't',
			"11000001" when 'u',
			"10010001" when 'y',
			"10100100" when 'z',
			"10111111" when '-',
         "11111111" when others;   -- space
 
  seg_out <= seg;
 
end arch_mux_7seg_char;


   