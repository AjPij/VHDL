----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/06/2023 08:42:22 AM
-- Design Name: 
-- Module Name: reg_mem_generic - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library USER_ARITH_lib;
use USER_ARITH_lib.User_arith_pkg.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- LogBase2Func returns binary logarithm of the given argument, round up to higher value, e.g. argument = 33, log2(33) =  5.044,
-- function will return 6  beacuse function is written to tell how many bits is nedeed to write the number that is argument

-- write address (WR_ADDR) is the number whose highest value is 1 less than of the number that represents the depth of memory
-- e.g. memory depth is 100 words, thus highest address is 99
-- to write number 99 in binary we need log2(99) = 6.63 => round up to 7
-- so we need 7 bits to write down binary number 99, that is std_logic_vector((7-1) downto 0)    


entity REG_MEM is
 generic(
    MEM_DEPTH           : natural := 32; -- number of words for memory depth (highest address = MEM_DEPTH - 1)
    MEM_WIDTH           : natural := 8 -- number of bits for width of memory    
    -- register memory by default does not need a latency, here it is implemented just as an example 
 );  
  Port (
  
    CLK         : in std_logic;
    RST         : in std_logic; -- RST is signal to create a register memory, without RST memory would be LUT
    
    -- memory write inteface
    
    WR_EN       : in std_logic ;
    WR_DATA     : in std_logic_vector(MEM_WIDTH - 1 downto 0);
    WR_ADDR     : in std_logic_vector( (LogBase2Func(MEM_DEPTH-1)-1) downto 0);  -- avoid integer   
     
    -- memory read interface
    
    RD_EN       : in std_logic;
    RD_DATA     : out std_logic_vector(MEM_WIDTH - 1 downto 0);    
    RD_ADDR     : in std_logic_vector( (LogBase2Func(MEM_DEPTH-1)-1) downto 0); -- avoid integer 
    
    RD_VALID    : in std_logic                                      
   );
end REG_MEM;

architecture Behavioral of REG_MEM is         
    
    type t_FIFO_DATA    is array (0 to MEM_DEPTH - 1) of std_logic_vector(MEM_WIDTH - 1 downto 0);
    signal r_FIFO_DATA  : t_FIFO_DATA; -- := (others => (others => '0')); -- memory    
    signal reg_RD_DATA    : std_logic_vector (MEM_WIDTH - 1 downto 0);
    
                                                                                                
begin        
                                                        
    WRITE_READ_MEM : process(CLK, RST)
    begin
        if( RST = '1' )then -- asynchronous reset 
            r_FIFO_DATA <= (others => (others => '0'));
        else
            if( rising_edge(CLK) )then        
                -- writing to memory                                                                                                                                
                if( WR_EN = '1' )then -- dual port memory (R/W can be simoultaneous)
                    r_FIFO_DATA( conv_integer(WR_ADDR) ) <= WR_DATA; -- if write is enabled write data to buffer                    
                end if;                
                -- reading from memory
                if( RD_EN = '1' )then -- if read is enabled read data from buffer, memory is stupid it does not know if read is valid, in fifo logic read address is not suposed to increment untill read valid = '1'
                    reg_RD_DATA <= r_FIFO_DATA(conv_integer(RD_ADDR));                
                end if;               
            end if;
        end if;
    end process WRITE_READ_MEM ;
       
    RD_DATA <= reg_RD_DATA;
    
end Behavioral;
