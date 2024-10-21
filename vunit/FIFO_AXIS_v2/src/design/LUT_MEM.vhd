----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/30/2023 10:16:17 AM
-- Design Name: 
-- Module Name: LUT_MEM - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- LUT based memory, width and depth of memory is set by generic values 

-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library lib;
use lib.User_arith_pkg.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity LUT_MEM is
  generic(
    MEM_DEPTH : natural := 32; -- number of words in memory
    MEM_WIDTH : natural := 8 -- number of bits for the width of the word   
  );
  Port (
    CLK : in std_logic;    
    
    -- memory write interface
    WR_EN : in std_logic;
    WR_DATA : in std_logic_vector(MEM_WIDTH - 1 downto 0);
    WR_ADDR : in std_logic_vector( (LogBase2Func(MEM_DEPTH-1)-1) downto 0 );
    
    -- memory read interface
    RD_EN : in std_logic;
    RD_DATA : out std_logic_vector( MEM_WIDTH - 1 downto 0 );
    RD_ADDR : in std_logic_vector( (LogBase2Func(MEM_DEPTH-1)-1) downto 0 );
    
    RD_VALID : in std_logic
  );
end LUT_MEM;

architecture Behavioral of LUT_MEM is
    
    type t_LUT_DATA is array (0 to MEM_DEPTH - 1) of std_logic_vector(MEM_WIDTH - 1 downto 0);
    signal reg_LUT_DATA : t_LUT_DATA ;    
    signal reg_RD_DATA : std_logic_vector(MEM_WIDTH-1 downto 0);
-----------------------------------------------------------------
	signal reg2_RD_DATA : std_logic_vector(MEM_WIDTH-1 downto 0);
-----------------------------------------------------------------
	signal reg3_RD_DATA : std_logic_vector(MEM_WIDTH-1 downto 0);
-----------------------------------------------------------------
	signal reg4_RD_DATA : std_logic_vector(MEM_WIDTH-1 downto 0);
-----------------------------------------------------------------
                              
begin
    
    -- process to handle memory (writing and reading)
    WRITE_READ_MEM : process(CLK)
    begin 
        if( rising_edge(CLK) )then
            -- writing to memory
            if( WR_EN = '1' )then
                reg_LUT_DATA(conv_integer(WR_ADDR)) <= WR_DATA;
            end if;
            
            -- reading from memory
            if( RD_EN = '1' )then
                reg_RD_DATA <= reg_LUT_DATA(conv_integer(RD_ADDR));
            end if;            
        end if;
    end process WRITE_READ_MEM;
			
RD_DATA <= reg_RD_DATA;
				
---------------------------------------------------------------
--	data_reg2: process(CLK)				
--	begin
--		if(rising_edge(CLK))then
--			reg2_RD_DATA <= reg_RD_DATA;
--		end if;					
--	end process data_reg2;
--			
--	RD_DATA <= reg2_RD_DATA;		
---------------------------------------------------------------	
--	data_reg3: process(CLK)				
--	begin
--		if(rising_edge(CLK))then
--			reg3_RD_DATA <= reg2_RD_DATA;
--		end if;					
--	end process data_reg3;
--			
--	RD_DATA <= reg3_RD_DATA;		
-----------------------------------------------------------------
--	data_reg4: process(CLK)				
--	begin
--		if(rising_edge(CLK))then
--			reg4_RD_DATA <= reg3_RD_DATA;
--		end if;					
--	end process data_reg4;
--			
--	RD_DATA <= reg4_RD_DATA;		
---------------------------------------------------------------			

end Behavioral;
