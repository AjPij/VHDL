----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/20/2023 01:24:05 PM
-- Design Name: 
-- Module Name: FIFO_logic_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- Testbench .vhd file for Fifo_logic.vhd 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FIFO_logic_tb is
--  Port ( );
end FIFO_logic_tb;

architecture Behavioral of FIFO_logic_tb is
    constant FIFO_DEPTH_tb : natural := 32;
    constant FIFO_WIDTH_tb : natural := 8;
    constant FIFO_AE_AF_LVL_tb : natural := 4;
    
    signal FIFO_CLK_tb : std_logic := '0';
    signal FIFO_RST_tb : std_logic := '0';
    
    -- FIFO write interface
    signal FIFO_WR_ADDR_tb : std_logic_vector((LogBase2Func(FIFO_DEPTH_tb-1)-1) downto 0) := (others => '0');
    signal FIFO_FULL_tb : std_logic := '0';    
    signal FIFO_AF_tb : std_logic := '0';
    signal FIFO_WR_EN_tb : std_logic := '0';
    
    -- FIFO read interface
    signal FIFO_RD_ADDR_tb : std_logic_vector((LogBase2Func(FIFO_DEPTH_tb-1)-1) downto 0) := (others => '0');
    signal FIFO_EMPTY_tb : std_logic := '0';
    signal FIFO_AE_tb : std_logic := '0';
    signal FIFO_RD_EN_tb : std_logic := '0';
    signal FIFO_RD_VALID_tb : std_logic := '0';

begin
    MODULE_FIFO_LOGIC_INST: entity xil_defaultlib.Fifo_logic
    generic map(
        FIFO_DEPTH => FIFO_DEPTH_tb,
        FIFO_WIDTH => FIFO_WIDTH_tb,
        FIFO_AE_AF_LVL => FIFO_AE_AF_LVL_tb         
    )
        
    port map(
        FIFO_CLK => FIFO_CLK_tb,
        FIFO_RST => FIFO_RST_tb,
        
        --FIFO write interface
        FIFO_WR_ADDR => FIFO_WR_ADDR_tb,
        FIFO_FULL => FIFO_FULL_tb,
        FIFO_AF => FIFO_AF_tb,
        FIFO_WR_EN => FIFO_WR_EN_tb,
        
        -- FIFO read interface
        FIFO_RD_ADDR => FIFO_RD_ADDR_tb,
        FIFO_EMPTY => FIFO_EMPTY_tb,
        FIFO_AE => FIFO_AE_tb,
        FIFO_RD_EN => FIFO_RD_EN_tb,
        FIFO_RD_VALID => FIFO_RD_VALID_tb
    );
    
    FIFO_CLK_tb <= not FIFO_CLK_tb after 5 ns;
    
    p_TEST : process is
    begin
        FIFO_RD_VALID_tb <= '1';
        FIFO_RST_tb <= '1';
        wait for 10 ns;
        FIFO_RST_tb <= '0';
        wait for 10 ns;
        FIFO_WR_EN_tb <= '1';
        wait for 320 ns;
        FIFO_WR_EN_tb <= '0';
        
        FIFO_RD_EN_tb <= '1';
        wait for 320 ns;
        FIFO_RD_EN_tb <= '0';
        wait;        
    end process;
    
end Behavioral;
