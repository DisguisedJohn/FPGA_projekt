----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:32:23 11/25/2009 
-- Design Name: 
-- Module Name:    php11 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity php11 is port (
   clk	: in STD_LOGIC; --- Clock 100kHz
   btnd	: in STD_LOGIC;
	
	
	an		: out std_logic_vector(3 downto 0);		-- an drivers
	seg		: out std_logic_vector(7 downto 0);		-- segment drivers
	led 		: out std_logic_vector(1 downto 0)
	);
end php11;
 
architecture Behavioral of php11 is
-- Pripojeni entity displeje z m7seg
 component mux_7seg_char is port (
	rst			: in std_logic ; 			-- asynchronous reset
	clk			: in std_logic ; 			-- CLOCK input
	DIN3,DIN2,DIN1,DIN0 : in character ;			 -- std_logic_vector(15 downto 0);		-- data input
	digit			: out std_logic_vector(3 downto 0);		-- an drivers
	seg_out		: out std_logic_vector(7 downto 0));	-- segment drivers
 end component mux_7seg_char ;

 constant introtxt : string := "soso ";
 
 -- Timer signals
 signal clk1kHz: STD_LOGIC;		--timer output
 signal countA	: STD_LOGIC_VECTOR (27 downto 0);	-- timer modulo
 signal countB	: integer;
 signal countC : STD_LOGIC_VECTOR (27 downto 0);
 signal countD : STD_LOGIC_VECTOR (27 downto 0);
 signal countE : STD_LOGIC_VECTOR (27 downto 0);
 
 signal clkA : std_logic := '1';
 
 signal CHAR3, CHAR2, CHAR1, CHAR0 : character;

 signal CHAR3_p : integer := 1;
 signal CHAR2_p : integer := 2;
 signal CHAR1_p : integer := 3;
 signal CHAR0_p : integer := 4;

 signal SEQ : STD_LOGIC_VECTOR (2 downto 0) := "000";
 signal M_CHAR : character := ' ';
 signal M_CHAR_p: integer:= 1;
 signal CHAR_T0 : STD_LOGIC_VECTOR (1 downto 0);
 signal CHAR_T1 : STD_LOGIC_VECTOR (2 downto 0);
 signal CHAR_T2 : STD_LOGIC_VECTOR (3 downto 0);
 signal CHAR_T3 : STD_LOGIC_VECTOR (3 downto 0);
 signal space : STD_LOGIC ;
 signal blik : STD_LOGIC := '0' ;
 

 signal CNT1K	 	: STD_LOGIC_VECTOR(9 downto 0);
 signal CNTTXT		: integer;
 alias rst		: std_logic is btnd;	-- RESET
 
begin
	
	m7seg: mux_7seg_char port map
	 (	rst	=>	rst,
		clk	=> 	clk1kHz, 
		DIN3	=>	CHAR3,
		DIN2	=>	CHAR2,
		DIN1	=>	CHAR1,
		DIN0	=>	CHAR0,
		digit	=> an,
		seg_out => seg );
		
------------------------------------------
-- TIMERS ---------------------------------
 
timer : process (clk)
 begin
 if Rising_Edge (clk) then	-- reakce na nabeznou hranu
		
     	if countA = 9999999 then		-- modulo timeru
	   	countA <= (others => '0');	-- vynuluj count
	  	 clkA <= not clkA;		-- a invertuj hodnotu 
	  	 else								
	 	   countA <= countA + 1;	-- inkrementuj count
	end if;
	  
	if countD = 99999 then
		countD <= (others => '0');
		clk1kHz <= not clk1kHz;
		else
		 countD <= countD + 1;
    	end if;
	  
 end if;
end process timer;
	
----------------------------------------
-- POSUN TEXTU NA DISPLEJI
----------------------------------------
	 
text_movement: process (clk)
	begin
	if Rising_Edge (clk) then
	  if countC = 99999999 then
		 countC <= (others => '0');
		 
	  CHAR3 <= introtxt(CHAR3_p); -- Zapis znaku na displej
	  CHAR2 <= introtxt(CHAR2_p);
	  CHAR1 <= introtxt(CHAR1_p);
	  CHAR0 <= introtxt(CHAR0_p);

		-- Posouvani oken disleje
	
		if CHAR3_p = introtxt'length then 	-- Pokud dojede na konec slova, zacne od 1 
		  CHAR3_p <= 1;
		 else 
		  CHAR3_p <= CHAR3_p + 1;
		end if;
		
		if CHAR2_p = introtxt'length then
		  CHAR2_p <= 1;
		 else 
		  CHAR2_p <= CHAR2_p + 1;
		end if;
		
		if CHAR1_p = introtxt'length then
		  CHAR1_p <= 1;
		 else 
		  CHAR1_p <= CHAR1_p + 1;
		end if;
		
		if CHAR0_p = introtxt'length then
		  CHAR0_p <= 1;
		 else 
		  CHAR0_p <= CHAR0_p + 1;
		end if;
		
	  else
		  countC <= countC + 1;
	  
     end if;
	 end if;
	
	end process text_movement;
----------------------------------------------------------------------------------------------	
-- Prevod na morse kod
------------------------
	morse_select: process (clkA)
	 begin 
	 	if rising_edge(clkA) then
		 
		 if rst = '1' then	-- V pripade resetu zmenit ukazatel na 1 charakter
			M_CHAR_p <= 1;
		 end if;
		 
		 if seq = "000" then -- 1. stav stavoveho automatu, ve kterem dochazi k dekodovani charakteru na tecky a carky
		 CHAR_T3 <= "1110"; -- Resetovani dekoderu na charaktery o 4 znacich (tecky, carky)
		 CHAR_T2 <= "1000"; -- Resetovani dek. na char. o 3 znacich
		 CHAR_T1 <= "100";  -- Resetovani dek. na char o 2
		 CHAR_T0 <= "10"; -- Resetovani dek. na char o 1 znaku
		 
		 M_CHAR <= introtxt(M_CHAR_p);
				 case M_CHAR is
					           	     when 'b' => CHAR_T3 <= "1000";
							     when 'c' => CHAR_T3 <= "1010";
							     when 'f' => CHAR_T3 <= "0010";
							     when 'h' => CHAR_T3 <= "0000";
							     when 'j' => CHAR_T3 <= "0111";
							     when 'l' => CHAR_T3 <= "0100";
							     when 'p' => CHAR_T3 <= "0110";
			 				     when 'q' => CHAR_T3 <= "1101";
							     when 'v' => CHAR_T3 <= "0001";
							     when 'x' => CHAR_T3 <= "1001";
							     when 'y' => CHAR_T3 <= "1011";
							     when 'z' => CHAR_T3 <= "1100";
							     when others => CHAR_T3 <= "1110";
				  end case;
				  
					if CHAR_T3 /= "1110" then -- Pokud charakter patri do T3 prechod na stav b001 
						countB <= 3;
						space <= '1';
						seq <= "001";
					else			-- Pokud charakter nepatri do T3 prechod na T2
						case M_CHAR is	
									     when 'd' => CHAR_T2 <= "1100"; 
									     when 'g' => CHAR_T2 <= "1110";
									     when 'k' => CHAR_T2 <= "1101";
									     when 'o' => CHAR_T2 <= "1111";
									     when 'r' => CHAR_T2 <= "1010";
									     when 's' => CHAR_T2 <= "0000";
									     when 'u' => CHAR_T2 <= "1001";
									     when 'w' => CHAR_T2 <= "1011";
									     when others  => CHAR_T2 <= "1000";
						end case;
						
						 if CHAR_T2 /= "1000" then -- Pokud charakter patri do T2 prechod na stav b010 
							 countB <= 2; 
							 space <= '1';
							 seq <= "010";
						 else 			-- Pokud charakter nepatri do T2 prechod na T1	 
							case M_CHAR is
											  when 'a' => CHAR_T1 <= "001";
											  when 'i' => CHAR_T1 <= "000";
											  when 'm' => CHAR_T1 <= "011";
											  when 'n' => CHAR_T1 <= "010";
											  when others => CHAR_T1 <= "100";
							end case;
							 if CHAR_T1 /= "100" then -- Pokud charakter patri do T1 prechod na stav b011 
								 countB <= 1; 
								 space <= '1';
								 seq <= "011";
							 else 			-- Pokud charakter nepatri do T1 prechod na T0	 
								  case M_CHAR is
											       when 'e' => CHAR_T0 <= "00"; 
										 	       when 't' => CHAR_T0 <= "01"; 
											       when others  => CHAR_T0 <= "10"; 
								  end case;
									 countB <= 0;
									 space <= '1';
									 seq <= "100";
						    end if;
						  end if;
						end if;
						
				if M_CHAR_p = introtxt'length then	-- Pokud ukazatel na charakter dojede na konec zacne od znova
					M_CHAR_p <= 1;
				else
					M_CHAR_p <= M_CHAR_p + 1;
				end if;
				
--------------------------------------------------------				  
			elsif seq = "001" then  -- Stav automatu b001
				if countB >= 0 then	-- Ukazatel na znak, ktery se ma zobrazit. Pokud dojde do -1 prechod na hlavni stav
					if space = '0' then	-- Pokud nasleduje mezera zobrazi mezeru
						if CHAR_T3(countB) = '1' then	-- Pokud je znak carka, rozsivit dve ledky
							led <= "11";
						else 
							led <= "01";		-- Pokud tecka rozsviti jednu
						end if;
						space <= '1';			-- Po zobrazeni znaku zaradi mezeru
						countB <= countB - 1;		-- Posun ukazatele na znak
					else
						led <= "00";			--- Mezera
						space <= '0';			-- Reset indikace mezery
					end if;
				else
				seq <= "000";					-- Prechod na hlavni stav
				end if;
			
			
			
			elsif seq = "010" then
				if countB >= 0 then
					if space = '0' then
						if CHAR_T2(countB) = '1' then
							led <= "11";
						else 
							led <= "01";
						end if;
						space <= '1';
						countB <= countB - 1;
					else
						led <= "00";
						space <= '0';
					end if;
				else
				seq <= "000";
				end if;
			
				
				
			elsif seq = "011" then
				if countB >= 0 then
					if space = '0' then
						if CHAR_T1(countB) = '1' then
							led <= "11";
						else
							led <= "01";
						end if;
						space <= '1';
						countB <= countB - 1;
					else
						led <= "00";
						space <= '0';
					end if;
				else
				seq <= "000";
				end if;
			
			
			
			elsif seq = "100" then
				if space = '0' then
			    if CHAR_T0 = "10" then		-- Pokud charakter dojde az zde, jedna se o neznamy znak nebo mezeru, dojde k zobrazeni mezery
				  led <= "00";
				  space <= '1';
				  else
					if CHAR_T0(0) = '1' then
						led <= "11";
					else
						led <= "01";
					end if;
					  space <= '1';
				  end if;				  
				else
					led <= "00";
					seq <= "000";
				end if;

-- Nekonecka testovaci smycka pro debug ... za chodu nenastane 
			elsif seq = "111" then
				led <= blik & blik;
				blik <= not blik;
--------------------------------
					
		end if;
	end if;
end process morse_select;
------------------------------------------	

end Behavioral;


