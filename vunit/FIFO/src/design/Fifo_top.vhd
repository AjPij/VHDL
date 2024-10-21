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
library user_arith_lib;
use user_arith_lib.User_arith_pkg.all;

library memtype_lib;
use memtype_lib.REG_MEM.all;
use memtype_lib.LUT_MEM.all;

library memlogic_lib;
use memlogic_lib.fifo_logic.all;

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
        FIFO_TOP_DEPTH      : natural := 32;
        FIFO_TOP_WIDTH      : natural := 8;        
        FIFO_TOP_AE_AF_LVL  : natural := 4;
        
        USE_LUT_MEM         : boolean := true; -- only one mem type can be used at one point       
        USE_REG_MEM         : boolean := false;
        USE_OTHERTYPE_MEM   : boolean := false; -- depending on meomory type change placeholder "OTHERTYPE"
        
        MEM_RD_LAT          : natural := 1 -- determined by type of memory or by memory datasheet, reg and lut have 0 clock cycle latency
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
    --signal FIFO_TOP_EMPTY_reg       : std_logic;
    signal FIFO_TOP_RD_VALID_temp   : std_logic;        
    --signal FIFO_TOP_RD_VALID_reg    : std_logic;
       
    
    constant REG_MEM_RD_LAT   : natural := 0;
    constant LUT_MEM_RD_LAT   : natural := 0;
    
     --USE_REG_OR_LUT_MEM : boolean;   
begin     

    
    
    MEM_LOGIC_INST: entity memlogic_lib.fifo_logic
    generic map(
        FIFO_DEPTH          => FIFO_TOP_DEPTH,
        FIFO_WIDTH          => FIFO_TOP_WIDTH,
        FIFO_AE_AF_LVL      => FIFO_TOP_AE_AF_LVL,
        USE_REG_OR_LUT_MEM  => USE_REG_MEM or USE_LUT_MEM,
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
        REG_MEM_INST: entity memtype_lib.REG_MEM
        generic map(
            MEM_DEPTH           => FIFO_TOP_DEPTH,
            MEM_WIDTH           => FIFO_TOP_WIDTH            
        )
        
        port map(
            CLK                 => FIFO_TOP_CLK,
            RST                 => FIFO_TOP_RST,
            
            -- mem write interface
            
            WR_EN               => FIFO_TOP_WR_EN,
            WR_DATA             => FIFO_TOP_WR_DATA,
            WR_ADDR             => FIFO_TOP_WR_ADDR_temp,
    
            
            -- mem read interface
            
            RD_EN               => FIFO_TOP_RD_EN,
            RD_DATA             => FIFO_TOP_RD_DATA,
            RD_ADDR             => FIFO_TOP_RD_ADDR_temp,
            
            RD_VALID            => FIFO_TOP_RD_VALID_temp                                                    
        );                   
    end generate;
    
    SELECT_MEM_TYPE2 : 
    if USE_LUT_MEM generate        
    begin
        LUT_MEM_INST : entity memtype_lib.LUT_MEM
        generic map(
            MEM_DEPTH => FIFO_TOP_DEPTH,
            MEM_WIDTH => FIFO_TOP_WIDTH               
        )
        port map(
            CLK => FIFO_TOP_CLK,            
            -- mem write interface
            WR_EN => FIFO_TOP_WR_EN,
            WR_DATA => FIFO_TOP_WR_DATA,
            WR_ADDR => FIFO_TOP_WR_ADDR_temp,
        
            -- mem read interface
            RD_EN => FIFO_TOP_RD_EN,
            RD_DATA => FIFO_TOP_RD_DATA,
            RD_ADDR => FIFO_TOP_RD_ADDR_temp,
            RD_VALID => FIFO_TOP_RD_VALID_temp
        );

    end generate;
    

            FIFO_TOP_RD_VALID <= FIFO_TOP_RD_VALID_temp;            

    

        

    
    
                  
end Behavioral;
