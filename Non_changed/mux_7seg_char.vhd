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
	rst			: in std_logic ; 			-- asynchronní reset
	clk			: in std_logic ; 			-- CLOCK input
	DIN3,DIN2,DIN1,DIN0 : in character ;			 -- std_logic_vector(15 downto 0);		-- data input
	DPIN			: in std_logic_vector(3 downto 0);		-- dot-point inputs
	digit			: out std_logic_vector(3 downto 0);		-- digit drivers
	seg_out		: out std_logic_vector(7 downto 0));	-- segment drivers

end mux_7seg_char ;

architecture arch_mux_7seg_char of mux_7seg_char is

signal akt_znak		: character ;	-- aktuálnì svítící znak
signal cd		: std_logic_vector(1 downto 0) ;	-- aktuálnì svítící èíslicovka
signal seg		: std_logic_vector(6 downto 0);	-- aktuální stav segmentù
signal dp		: std_logic ;							-- dot-point


begin

process (CLK, rst)
begin
if rst = '1' then
	digit <= (others => '1') ;
	cd <= (others => '0') ;
	akt_znak <= ' ';
elsif CLK'event and CLK = '1' then
		cd(1 downto 0) <= cd(1 downto 0) + 1 ;
	case cd(1 downto 0) is 
		when "00" =>   akt_znak <= DIN0 ;   digit <= "1110" ; 
		when "01" =>   akt_znak <= DIN1 ;   digit <= "1101" ; 
		when "10" =>   akt_znak <= DIN2 ;   digit <= "1011" ; 
		when others => akt_znak <= DIN3 ;   digit <= "0111" ; 
	end case ;
end if ;
end process ;

dp <= DPIN(conv_integer(cd(1 downto 0)));

--      0
--     ---  
--  5 |   | 1
--     ---   <- 6
--  4 |   | 2
--     ---
--      3
   
  with akt_znak SELect
  seg <= "1111001" when '1',   
         "0100100" when '2',   
         "0110000" when '3',   
         "0011001" when '4',   
         "0010010" when '5',   
         "0000010" when '6',   
         "1111000" when '7',   
         "0000000" when '8',   
         "0010000" when '9',   
			"1000000" when '0',	 
         "0001000" when 'a',   
         "0000011" when 'b',   
         "1000110" when 'c',   
         "0100001" when 'd',   
         "0000110" when 'e',   
         "0001110" when 'f',   
			"1000010" when 'g',
			"0001001" when 'h',
			"1111001" when 'i',
			"1100001" when 'j',
			"1000111" when 'l',
			"0101011" when 'n',
			"1000000" when 'o',
			"0001100" when 'p',
			"0101111" when 'r',
			"0010010" when 's',
			"0000111" when 't',
			"1000001" when 'u',
			"0010001" when 'y',
			"0100100" when 'z',
			"0111111" when '-',
         "1111111" when others;   -- space
 
  seg_out <= DP & seg;
 
end arch_mux_7seg_char;


   