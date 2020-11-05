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
   clk	: in STD_LOGIC;
   btnd	: in STD_LOGIC;
	an			: out std_logic_vector(3 downto 0);		-- an drivers
	seg		: out std_logic_vector(7 downto 0)		-- segment drivers
	);
end php11;

architecture Behavioral of php11 is
 component mux_7seg_char is port (
	rst			: in std_logic ; 			-- asynchronous reset
	clk			: in std_logic ; 			-- CLOCK input
	DIN3,DIN2,DIN1,DIN0 : in character ;			 -- std_logic_vector(15 downto 0);		-- data input
	DPIN			: in std_logic_vector(3 downto 0);		-- dot-point inputs
	digit			: out std_logic_vector(3 downto 0);		-- an drivers
	seg_out		: out std_logic_vector(7 downto 0));	-- segment drivers
 end component mux_7seg_char ;

 constant introtxt : string := "     dobry den toto je led displej na desce se spartan-6 fpga ";
 constant CNT1MAX	 : STD_LOGIC_VECTOR(9 downto 0) := "0111111111";	-- 511

 signal T3, T2, T1, T0 : character;
 signal ce1kHz, ce2Hz	: STD_LOGIC;
 signal DP			: std_logic_vector(3 downto 0);
 signal COUNT			: std_logic_vector(15 downto 0);
 signal CNT1K	 	: STD_LOGIC_VECTOR(9 downto 0);
 signal CNTTXT		: integer;
 alias rst			: std_logic is btnd;	-- RESET
 
 constant CNT_WIDTH : integer := 17;
 
 signal CNT : std_logic_vector (CNT_WIDTH-1 downto 0);
 
begin

	
	m7seg: mux_7seg_char port map
	 (	rst	=>	rst,
		clk	=> CNT(16), 
		DIN3	=>	T3,
		DIN2	=>	T2,
		DIN1	=>	T1,
		DIN0	=>	T0,
		DPIN	=> DP,
		digit	=> an,
		seg_out => seg );

------------------------------------------		
-- COUNTERS ------------------------------

  counter1kHz: process (clk)
	begin
	 if clk'event and clk = '1' then
	   COUNT <= COUNT + 1;
	 end if;
	end process;
	
	ce1kHz <= '1' when COUNT = x"FFFF" else
				 '0';
				 
  counter1Hz: process (clk)
	begin
	 if clk'event and clk = '1' then
	  if ce1kHz = '1' then
	   if CNT1K = CNT1MAX then
		  CNT1K <= (others => '0');
		else  
	     CNT1K <= CNT1K + 1;
		end if;  
	  end if;	 
	 end if;
	end process;
	
	ce2Hz <= '1' when CNT1K = CNT1MAX and ce1kHz = '1' else
				'0';
------------------------------------------					 
  txtcounter: process (clk)
   begin
	 if clk'event and clk = '1' then
	  if  rst = '1' then
	   CNTTXT <= 0;
	  elsif ce2Hz = '1' then
	   if CNTTXT >= (introtxt'length - 5) then
		  CNTTXT <= 0;
		else  
	     CNTTXT <= CNTTXT + 1;
		end if;  
	  end if;
	 end if; 
	end process;
  
  DP <= "1111"; -- PWM(11 downto 8);
  T3 <= introtxt(CNTTXT);
  T2 <= introtxt(CNTTXT+1);
  T1 <= introtxt(CNTTXT+2);
  T0 <= introtxt(CNTTXT+3);

 counter: process (CLK)
	begin
	 if CLK'event and CLK = '1' then
	   if rst = '1' then
	     CNT <= (others => '0');
	   else
		  CNT <= CNT + 1;
	   end if;
	  end if;	
	end process counter; 	

end Behavioral;


