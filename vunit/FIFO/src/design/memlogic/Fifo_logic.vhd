----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/06/2023 08:42:22 AM
-- Design Name: 
-- Module Name:  - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- This module is used to implement FIFO logic, it is used with FIFO_top.vhd to keep track of adresses, word counts, full, empty, almost full and almost empty flags
-- inputs: clock (CLK)
--         reset(RST)
--         write enable (FIFO_WR_EN)
--         read enable (FIFO_RD_EN)
--         read vaild (FIFO_RD_VALID)

-- outputs: all outputs need to be registered
--          fifo full (FIFO_FULL)
--          fifo empty (FIFO_EMPTY)
--          fifo almost full (FIFO_AF)
--          fifo almost empty (FIFO_AE)
--          write address (FIFO_WR_ADDR), use std_logic_vector
--          read address (FIFO_RD_ADDR), use std_logic_vector
-- FIFO logic does not need a RD_VALID signal (as input) because RD_VALID comes from memory and it is
-- just passed out on Fifo_top,current logic does not use information about RD_VALID  
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity FIFO_logic is
generic(
    FIFO_DEPTH          : natural := 32;
    FIFO_WIDTH          : natural := 8;
    FIFO_AE_AF_LVL      : natural := 4;         
    USE_REG_OR_LUT_MEM  : boolean := true;
    RD_REQ_to_RD_VALID  : natural := 0
    );
    
  Port (
    FIFO_CLK        : in std_logic;
    FIFO_RST        : in std_logic; -- based on rst we know weather is it a LUT or register memory 
    
    -- FIFO write interface
    FIFO_WR_EN      : in std_logic;
    FIFO_WR_ADDR    : out std_logic_vector((LogBase2Func(FIFO_DEPTH-1)-1) downto 0);  -- avoid integer
    FIFO_FULL       : out std_logic;
    FIFO_AF         : out std_logic;
    
    
    -- FIFO read interface
    FIFO_RD_EN      : in std_logic;
    FIFO_RD_ADDR    : out std_logic_vector((LogBase2Func(FIFO_DEPTH-1)-1) downto 0);  -- avoid integer
    FIFO_EMPTY      : out std_logic;
    FIFO_AE         : out std_logic;    
    FIFO_RD_VALID   : out std_logic 
                                            
   );
end Fifo_logic;

architecture Behavioral of Fifo_logic is
    
    signal c_AF_CNT     : natural := (FIFO_DEPTH - FIFO_AE_AF_LVL);
    signal c_AE_CNT     : natural := FIFO_AE_AF_LVL;
    
    signal r_FIFO_COUNT_PREV    : std_logic_vector(LogBase2Func(FIFO_DEPTH-1) downto 0);
    signal r_FIFO_COUNT_CURR    : std_logic_vector(LogBase2Func(FIFO_DEPTH-1) downto 0); -- counter for total number of words in the FIFO
    -- counter should be able to count to number = FIFO_DEPTH, e.g. 32 words in FIFO, log2(32-1) = 4.94 => 5     
        
    -- FIFO write interface
    signal reg_FIFO_FULL        : std_logic;
    signal reg_FIFO_AF          : std_logic;
    signal reg_FIFO_WR_ADDR     : std_logic_vector( LogBase2Func(FIFO_DEPTH-1)-1 downto 0 );   
    
    -- FIFO read interface
    signal reg_FIFO_EMPTY       : std_logic;
    signal reg_FIFO_AE          : std_logic;
    signal reg_FIFO_RD_ADDR     : std_logic_vector( LogBase2Func(FIFO_DEPTH-1)-1 downto 0 );
    
    --signal FIFO_RD_VALID_reg   : std_logic;
    
    -- shift register related signals
    
    -- SR1
    signal r_SR_REG_LUT_MEM     : std_logic_vector( RD_REQ_to_RD_VALID downto 0) := (others => '0'); -- shift register for RD_VALID
    -- SR2
    signal r_SR_OTHER_MEM_TYP   : std_logic_vector( RD_REQ_to_RD_VALID - 1 downto 0) := (others => '0'); -- shift register for RD_VALID
    
    --signal reg_FIFO_RD_VALID    : std_logic;
    signal FIFO_RD_VALID_temp   : std_logic;           
               
begin

    -------------------------------------------------------------------------------------------------------------------------
    SELECT_SR1:
    if USE_REG_OR_LUT_MEM generate
    begin
        SR_PROC : process(FIFO_CLK,FIFO_RST)
        begin
            if( FIFO_RST = '1' )then
                r_SR_REG_LUT_MEM <= (others => '0');
            else
                if( rising_edge(FIFO_CLK) )then
                    r_SR_REG_LUT_MEM <= r_SR_REG_LUT_MEM(r_SR_REG_LUT_MEM'high - 1 downto r_SR_REG_LUT_MEM'low) & FIFO_RD_EN;
                end if;        
            end if;
        end process SR_PROC;
        
        FIFO_RD_VALID_temp <= r_SR_REG_LUT_MEM(r_SR_REG_LUT_MEM'high);
                        
    end generate;

    -------------------------------------------------------------------------------------------------------------------------
    
    SELECT_SR2:
    if (not USE_REG_OR_LUT_MEM) generate -- if not using register or lut memory, corresponding shift register is used
        SR_PROC : process(FIFO_CLK,FIFO_RST)
        begin
            if( FIFO_RST = '1' )then
                r_SR_OTHER_MEM_TYP <= (others => '0');
            else
                if( rising_edge(FIFO_CLK) )then
                    r_SR_OTHER_MEM_TYP <= r_SR_OTHER_MEM_TYP(r_SR_OTHER_MEM_TYP'high - 1 downto r_SR_OTHER_MEM_TYP'low) & FIFO_RD_EN;
                end if;        
            end if;
        end process SR_PROC;
        
        FIFO_RD_VALID_temp <= r_SR_OTHER_MEM_TYP(r_SR_OTHER_MEM_TYP'high);
                       
    end generate;
          
    -------------------------------------------------------------------------------------------------------------------------        

    FIFO_COUNT_HANDLE : process(FIFO_CLK, FIFO_RST)
    begin                    
        if( FIFO_RST = '1' )then                                   
            r_FIFO_COUNT_CURR   <= ( others => '0' );                                            
        else
            if( rising_edge(FIFO_CLK))then
            
                if( FIFO_WR_EN = '1' and FIFO_RD_EN /= '1')then
                    r_FIFO_COUNT_CURR <= r_FIFO_COUNT_CURR + '1';
                    if( conv_integer(r_FIFO_COUNT_CURR) > (FIFO_DEPTH - 1) )then -- overflow condition
                        r_FIFO_COUNT_CURR <= r_FIFO_COUNT_CURR; 
                    end if;                                                                                                                  
--                end if;              
            -----------------------------------------------------------------------------------------------------
                elsif( FIFO_RD_EN = '1' and FIFO_WR_EN /= '1' )then
                    r_FIFO_COUNT_CURR <= r_FIFO_COUNT_CURR - '1';                    
                    if( conv_integer(r_FIFO_COUNT_CURR) = 0 )then
                        r_FIFO_COUNT_CURR <= r_FIFO_COUNT_CURR;
                    end if;                                                                        
--                end if;
                
                elsif( FIFO_WR_EN = '1' and FIFO_RD_EN = '1' )then
                    r_FIFO_COUNT_CURR <= r_FIFO_COUNT_CURR;                        
                end if;                                                                                                                                                                                          
            end if;                 
        end if;
    end process FIFO_COUNT_HANDLE;
        
    -------------------------------------------------------------------------------------------------------------------------
    -- process to handle:        
    -- almost empty flag: reg_FIFO_AE
    -- full flag: reg_FIFO_FULL
    -- almost full flag: reg_FIFO_AF
    FLAGS_HANDLE : process(FIFO_CLK, FIFO_RST)
    begin
        if( FIFO_RST = '1' )then                        
            reg_FIFO_FULL   <= '0';
            reg_FIFO_AF     <= '0';
            reg_FIFO_EMPTY  <= '1';  
            reg_FIFO_AE     <= '1';
        else
            if( rising_edge(FIFO_CLK) )then
                
                if( FIFO_WR_EN = '1' )then
                    reg_FIFO_EMPTY <= '0';                        
                end if;
                
                if(FIFO_RD_EN = '1' and FIFO_WR_EN = '0')then   
                    reg_FIFO_FULL <= '0';        
                end if;
                                
                if( (r_FIFO_COUNT_CURR > r_FIFO_COUNT_PREV) and r_FIFO_COUNT_CURR >= (FIFO_AE_AF_LVL)  )then
                    reg_FIFO_AE <= '0';    
                end if;
                
                if( (r_FIFO_COUNT_CURR < r_FIFO_COUNT_PREV) and r_FIFO_COUNT_CURR <= (FIFO_AE_AF_LVL + 1)  )then
                    reg_FIFO_AE <= '1';    
                end if;
                
                if( (r_FIFO_COUNT_CURR > r_FIFO_COUNT_PREV) and r_FIFO_COUNT_CURR >= (FIFO_DEPTH - FIFO_AE_AF_LVL - 1) )then
                    reg_FIFO_AF <= '1';
                end if;
            
                if( (r_FIFO_COUNT_CURR > r_FIFO_COUNT_PREV) and r_FIFO_COUNT_CURR >= (FIFO_DEPTH - 1) )then
                    reg_FIFO_FULL <= '1';
                end if;
                            
                if( (r_FIFO_COUNT_CURR < r_FIFO_COUNT_PREV) and r_FIFO_COUNT_CURR <= (FIFO_DEPTH - FIFO_AE_AF_LVL) )then
                    reg_FIFO_AF <= '0';
                end if;
                
                if( (r_FIFO_COUNT_CURR < r_FIFO_COUNT_PREV) and r_FIFO_COUNT_CURR <= 1 )then
                    reg_FIFO_EMPTY <= '1';    
                end if;
                                                                         
            end if;                                                                                          
        end if;
    end process FLAGS_HANDLE;
    
    -------------------------------------------------------------------------------------------------------------------------
                
    -- process to handle read and write addresses
    RW_ADDR_HANDLE : process(FIFO_CLK, FIFO_RST)
    begin
        if( FIFO_RST = '1' )then
            reg_FIFO_RD_ADDR <= (others => '0');
            reg_FIFO_WR_ADDR <= (others => '0');           
        else
            if( rising_edge(FIFO_CLK))then
            -------------------------------------------------------
                if( FIFO_RD_EN = '1' )then -- if read is enabled  
                    reg_FIFO_RD_ADDR <= reg_FIFO_RD_ADDR + '1';
                    if( conv_integer(reg_FIFO_RD_ADDR) >= FIFO_DEPTH - 1 )then -- overflow condition
                        reg_FIFO_RD_ADDR <= (others => '0'); -- reset addr                                                                
                    end if;
                end if;
            
            -------------------------------------------------------
                if( FIFO_WR_EN = '1'  )then                
                    reg_FIFO_WR_ADDR <= reg_FIFO_WR_ADDR + '1';                   
                    if( conv_integer(reg_FIFO_WR_ADDR) >= FIFO_DEPTH - 1 )then -- overflow condition
                        reg_FIFO_WR_ADDR <= (others => '0');                                            
                    end if;          
                end if;
            ------------------------------------------------------- 
--                elsif( FIFO_RD_EN = '1' and FIFO_WR_EN = '1' )then
--                    reg_FIFO_RD_ADDR <= reg_FIFO_RD_ADDR + '1';
--                    if( conv_integer(reg_FIFO_RD_ADDR) >= FIFO_DEPTH - 1 )then -- overflow condition
--                        reg_FIFO_RD_ADDR <= (others => '0'); -- reset addr                                                                
--                    end if;

--                    reg_FIFO_WR_ADDR <= reg_FIFO_WR_ADDR + '1';                   
--                    if( conv_integer(reg_FIFO_WR_ADDR) >= FIFO_DEPTH - 1 )then -- overflow condition
--                        reg_FIFO_WR_ADDR <= (others => '0');                                            
--                    end if;                
--                end if;                                                                                     
            end if;
        end if;                            
    end process RW_ADDR_HANDLE ;
    
    -------------------------------------------------------------------------------------------------------------------------
    
    PREV_COUNT : process(FIFO_CLK, FIFO_RST)
    begin
        if(FIFO_RST = '1')then
            r_FIFO_COUNT_PREV <= (others => '0');
        else
            if(rising_edge(FIFO_CLK))then
                r_FIFO_COUNT_PREV <= r_FIFO_COUNT_CURR;
            end if;            
        end if;                    
    end process PREV_COUNT;
    
    -------------------------------------------------------------------------------------------------------------------------    
          
                                                 
    FIFO_FULL       <= reg_FIFO_FULL;
    FIFO_EMPTY      <= reg_FIFO_EMPTY;
    FIFO_AF         <= reg_FIFO_AF;
    FIFO_AE         <= reg_FIFO_AE;
    FIFO_WR_ADDR    <= reg_FIFO_WR_ADDR;
    FIFO_RD_ADDR    <= reg_FIFO_RD_ADDR;
    FIFO_RD_VALID   <= FIFO_RD_VALID_temp;
    
end Behavioral;
