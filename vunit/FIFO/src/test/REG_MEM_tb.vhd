----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/16/2023 04:01:23 PM
-- Design Name: 
-- Module Name: REG_MEM_tb - Behavioral
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
library xil_defaultlib;
use xil_defaultlib.User_arith_pkg.all;

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

entity REG_MEM_tb is
--  Port ( );
end REG_MEM_tb;
    
architecture Behavioral of REG_MEM_tb is
    constant MEM_DEPTH_tb : natural := 32;
    constant MEM_WIDTH_tb : natural := 8;
    constant RD_REQ_to_RD_VALID_tb : natural := 0;
    
    signal CLK_tb : std_logic := '0';
    signal RST_tb : std_logic := '0';

    -- memory write interface

    signal WR_EN_tb   : std_logic := '0';
    signal WR_DATA_tb : std_logic_vector((MEM_WIDTH_tb - 1) downto 0) := X"DE" ;
    signal WR_ADDR_tb : std_logic_vector(  (LogBase2Func(MEM_DEPTH_tb-1)-1) downto 0 ) := (others => '0');
                
    -- memory read interface
    
    signal RD_EN_tb : std_logic := '0';
    signal RD_DATA_tb : std_logic_vector(MEM_WIDTH_tb - 1 downto 0) := X"00";
    signal RD_ADDR_tb : std_logic_vector( (LogBase2Func(MEM_DEPTH_tb-1)-1) downto 0) := (others => '0');
    
    signal RD_VALID_tb : std_logic;
--    component COMP_REG_MEM_tb is
--        generic(
            
--        );
--    end component COMP_REG_MEM_tb;
    
begin
    MODULE_REG_MEM_INST : entity xil_defaultlib.REG_MEM
    generic map(
        MEM_DEPTH => MEM_DEPTH_tb,
        MEM_WIDTH => MEM_WIDTH_tb,
        RD_REQ_to_RD_VALID => RD_REQ_to_RD_VALID_tb   
        )
     
    port map(
        CLK => CLK_tb,
        RST => RST_tb,
        
        WR_EN => WR_EN_tb,
        WR_DATA => WR_DATA_tb,
        WR_ADDR => WR_ADDR_tb,
        
        RD_EN => RD_EN_tb,
        RD_DATA => RD_DATA_tb,
        RD_ADDR => RD_ADDR_tb,
        
        RD_VALID => RD_VALID_tb
        );
        
        CLK_tb <= not CLK_tb after 5 ns;
        
        p_TEST : process is
        begin
            RST_tb <= '1';      
            wait for 10 ns;
            RST_tb <= '0';
            WR_EN_tb <= '1';
            RD_EN_tb <= '0';
            wait for 142 ns;     
            WR_EN_tb <= '0';
            RD_EN_tb <= '1';
            wait for 100 ns;
            WR_EN_tb <= '0';
            RD_EN_tb <= '0';
            wait for 100 ns;
            RD_EN_tb <= '1';                        
            wait for 100 ns;
            RD_EN_tb <= '0';                                             
            wait;
        end process;
        
end Behavioral;
