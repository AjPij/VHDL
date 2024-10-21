----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/14/2023 12:37:11 PM
-- Design Name: 
-- Module Name: Fifo_top - Behavioral
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
library lib;
use lib.User_arith_pkg.all;



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Fifo_top is
    generic(
		-- fifo generics
		FIFO_TOP_DEPTH      : natural;
        FIFO_TOP_WIDTH      : natural;        		
        FIFO_TOP_AE_LVL  	: natural;
        FIFO_TOP_AF_LVL  	: natural;
		-- memory generics
        USE_LUT_MEM         : boolean;
        USE_REG_MEM         : boolean;
        USE_OTHERTYPE_MEM   : boolean; -- currently unsuported
		
		MEM_RD_LAT			: natural;
		MEM_WR_LAT			: natural
				                        		         
    );
        
      Port (
        FIFO_TOP_CLK         : in std_logic;
        FIFO_TOP_RST         : in std_logic; -- based on rst LUT mem can be differed from non LUT mem
               
        -- FIFO write interface
        
        FIFO_TOP_WR_EN       : in std_logic ;
        FIFO_TOP_WR_DATA     : in std_logic_vector((FIFO_TOP_WIDTH - 1) downto 0);
        FIFO_TOP_FULL        : out std_logic;
        FIFO_TOP_AF          : out std_logic;  
        
        -- FIFO read interface
        
        FIFO_TOP_RD_EN      : in std_logic;
        FIFO_TOP_RD_DATA    : out std_logic_vector((FIFO_TOP_WIDTH - 1) downto 0);
        FIFO_TOP_EMPTY      : out std_logic;  
        FIFO_TOP_AE         : out std_logic;
        
        FIFO_TOP_RD_VALID   : out std_logic
          
    );
end Fifo_top;

architecture Behavioral of Fifo_top is
                                                
    signal FIFO_TOP_WR_ADDR_temp    : std_logic_vector((LogBase2Func(FIFO_TOP_DEPTH-1)-1) downto 0);                                              
    signal FIFO_TOP_RD_ADDR_temp    : std_logic_vector((LogBase2Func(FIFO_TOP_DEPTH-1)-1) downto 0);                    
    signal FIFO_TOP_RD_VALID_temp   : std_logic;        
    
           
    
     
begin     

    
    
    FIFO_LOGIC_INST: entity work.Fifo_logic
    generic map(
        FIFO_DEPTH          => FIFO_TOP_DEPTH,
        FIFO_WIDTH          => FIFO_TOP_WIDTH,
        FIFO_AE_LVL      	=> FIFO_TOP_AE_LVL,
		FIFO_AF_LVL      	=> FIFO_TOP_AF_LVL,
        RD_REQ_to_RD_VALID  => MEM_RD_LAT     
        
    )
     
    port map(
        FIFO_CLK            => FIFO_TOP_CLK,
        FIFO_RST            => FIFO_TOP_RST,
        
        --FIFO write interface
        FIFO_WR_EN          => FIFO_TOP_WR_EN,
        FIFO_WR_ADDR        => FIFO_TOP_WR_ADDR_temp,
        FIFO_FULL           => FIFO_TOP_FULL,
        FIFO_AF             => FIFO_TOP_AF,
        
        
        --FIFO read interface
        FIFO_RD_EN          => FIFO_TOP_RD_EN,
        FIFO_RD_ADDR        => FIFO_TOP_RD_ADDR_temp,
        FIFO_EMPTY          => FIFO_TOP_EMPTY,
        FIFO_AE             => FIFO_TOP_AE,                
        FIFO_RD_VALID       => FIFO_TOP_RD_VALID_temp
    );        
    

                                                                                                                                                                                                                   
    SELECT_MEM_TYPE1 : 
    if USE_REG_MEM  generate         
    begin
        REG_MEM_INST: entity work.REG_MEM
        generic map(
            MEM_DEPTH   => FIFO_TOP_DEPTH,
            MEM_WIDTH   => FIFO_TOP_WIDTH            
        )        
        port map(
            CLK         => FIFO_TOP_CLK,
            RST         => FIFO_TOP_RST,            
            -- mem write interface            
            WR_EN       => FIFO_TOP_WR_EN,
            WR_DATA     => FIFO_TOP_WR_DATA,
            WR_ADDR     => FIFO_TOP_WR_ADDR_temp,
                
            -- mem read interface            
            RD_EN       => FIFO_TOP_RD_EN,
            RD_DATA     => FIFO_TOP_RD_DATA,
            RD_ADDR     => FIFO_TOP_RD_ADDR_temp,
            
            RD_VALID    => FIFO_TOP_RD_VALID_temp                                                    
        );                   
    end generate;
    
    SELECT_MEM_TYPE2 : 
    if USE_LUT_MEM generate        
    begin
        LUT_MEM_INST : entity work.LUT_MEM
        generic map(
            MEM_DEPTH 	=> FIFO_TOP_DEPTH,
            MEM_WIDTH 	=> FIFO_TOP_WIDTH               
        )
        port map(
            CLK 		=> FIFO_TOP_CLK,            
            -- mem write interface
            WR_EN 		=> FIFO_TOP_WR_EN,
            WR_DATA 	=> FIFO_TOP_WR_DATA,
            WR_ADDR 	=> FIFO_TOP_WR_ADDR_temp,
        
            -- mem read interface
            RD_EN 		=> FIFO_TOP_RD_EN,
            RD_DATA 	=> FIFO_TOP_RD_DATA,
            RD_ADDR 	=> FIFO_TOP_RD_ADDR_temp,
            RD_VALID 	=> FIFO_TOP_RD_VALID_temp
        );

    end generate;    

            FIFO_TOP_RD_VALID <= FIFO_TOP_RD_VALID_temp;            
                                      
end Behavioral;