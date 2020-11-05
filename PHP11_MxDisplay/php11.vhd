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
	
	
	an			: out std_logic_vector(3 downto 0);		-- an drivers
	seg		: out std_logic_vector(7 downto 0)		-- segment drivers
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

 constant introtxt : string := "dinosaurus ";
 constant CNT1MAX	 : STD_LOGIC_VECTOR(9 downto 0) := "0111111111";	-- 511
 
 -- Timer signals
 signal clk4Hz, clk1kHz : STD_LOGIC;		--timer output
 signal countA	: STD_LOGIC_VECTOR (24 downto 0);	-- timer modulo
 signal countB	: STD_LOGIC_VECTOR (24 downto 0);
 

 signal CHAR3, CHAR2, CHAR1, CHAR0 : character;
 signal CNT1K	 	: STD_LOGIC_VECTOR(9 downto 0);
 signal CNTTXT		: integer;
 alias rst			: std_logic is btnd;	-- RESET
 
-- constant CNT_WIDTH : integer := 17;
-- 
-- signal CNT : std_logic_vector (CNT_WIDTH-1 downto 0);
 
begin
	
	m7seg: mux_7seg_char port map
	 (	rst	=>	rst,
		clk	=> clk1kHz, 
		DIN3	=>	CHAR3,
		DIN2	=>	CHAR2,
		DIN1	=>	CHAR1,
		DIN0	=>	CHAR0,
		digit	=> an,
		seg_out => seg );

------------------------------------------		
-- COUNTERS ------------------------------

--  text_pointer: process (clk)
--	begin
--	 if clk'event and clk = '1' then
--	   COUNT <= COUNT + 1;
--	 end if;>D
--	end process text_pointer;
--	
--	ce1kHz <= '1' when COUNT = x"FFFF" else
--				 '0';

------------------------------------------
-- TIMERS ---------------------------------
 
  timer : process (clk)
	begin
	 if Rising_Edge (clk) then	-- reakce na nabeznou hranu
     if countA = 24999999 then	-- modulo timeru 25mil > 100k / 25k
	   countA <= (others => '0');	-- vynuluj count
	   clk4Hz <= not clk4Hz;		-- a invertuj hodnotu clk4Hz
	   else								-- jinak
	    countA <= countA + 1;			-- inkrementuj count
	  end if;
	  
	  if countB = 99999 then
		countB <= (others => '0');
		clk1kHz <= not clk1kHz;
		else
		 countB <= countB + 1;
     end if;
	 end if;
   end process timer;
	
		



------------------------------------------					 
  text_refresh: process (clk4Hz)
   begin
	 if Rising_Edge (clk4Hz) then
	  if  rst = '1' then
	   CNTTXT <= 0;
	  else
	   if CNTTXT >= (introtxt'length - 5) then
		  CNTTXT <= 0;
		else  
	     CNTTXT <= CNTTXT + 1;
		end if;  
	  end if;
	 end if; 
	end process text_refresh;
  
  CHAR3 <= introtxt(CNTTXT);
  CHAR2 <= introtxt(CNTTXT+1);
  CHAR1 <= introtxt(CNTTXT+2);
  CHAR0 <= introtxt(CNTTXT+3);

-- counter: process (CLK)
--	begin
--	 if CLK'event and CLK = '1' then
--	   if rst = '1' then
--	     CNT <= (others => '0');
--	   else
--		  CNT <= CNT + 1;
--	   end if;
--	  end if;	
--	end process counter; 	

end Behavioral;


