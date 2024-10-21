----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/29/2023 11:06:09 AM
-- Design Name: 
-- Module Name: Fifo_top_tb - Behavioral
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

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.vc_context;

library fifo_lib;

library user_arith_lib;
use user_arith_lib.User_arith_pkg.all;



entity Fifo_top_tb is
    generic(
    	runner_cfg : string
    );
end Fifo_top_tb;

architecture Behavioral of Fifo_top_tb is
    constant DEPTH_tb           :natural := 32;
    constant WIDTH_tb           :natural := 8;
    constant AE_AF_LVL_tb       :natural := 4;   
    
    signal CLK_tb       : std_logic := '0';
    signal RST_tb       : std_logic := '0';
    
    -- write interface
    
    signal WR_EN_tb     : std_logic := '0';
    signal WR_DATA_tb   : std_logic_vector((WIDTH_tb - 1) downto 0) := X"0A";
    signal FULL_tb      : std_logic := '0';
    signal AF_tb        : std_logic := '0';
    
    -- read interface
    
    signal RD_EN_tb     : std_logic := '0';
    signal RD_DATA_tb   : std_logic_vector((WIDTH_tb - 1) downto 0 ) := X"00";
    signal EMPTY_tb     : std_logic := '1';
    signal AE_tb        : std_logic := '1';
    signal RD_VALID_tb  : std_logic := '0';
         
begin
    	    	 
    main: process
    begin
        test_runner_setup(runner, runner_cfg);				
        
        wait for 20 ns;
   	    RST_tb <= '1';
   	    wait for 15 ns;
   	    RST_tb <= '0'; 
       
   	    --wait for 3 ns;
 	    --WR_EN_tb <= '1';        
        --RD_EN_tb <= '0';
        
		--wait for 10 ns;			                
		--WR_EN_tb <= '1';
		
		wr_data_loop : for k in 1 to 200 loop
	        wait until CLK_tb = '0';        
	        WR_DATA_tb <= std_logic_vector(TO_UNSIGNED(k,WR_DATA_tb'length));
	        if( k = 1 )then
	       		wait until CLK_tb = '1' for 2 ns;
	       		WR_EN_tb <= '1';	       	
	        end if;       
	        
	        if( k = 32 )then
	        	waituntil CLK_tb = '1' for 2 ns;
	       		WR_EN_tb <= '0';	       		        	
	       		RD_EN_tb <= '1';
	        end if;
	        
	        
			
		end loop;
				       
--       	load_data_loop_1: for k in 1 to 300 loop
--	       	wait until CLK_tb = '1';                           
--        	WR_DATA_tb <= std_logic_vector(TO_UNSIGNED(k,WR_DATA_tb'length));
--        	if(k = 1) then
--	        	wait for  9 ns;
--	        	WR_EN_tb <= '1';
--			end if;
			
--	       	if(k = 2)then
--	        	wait for 4 ns;
--	        	WR_EN_tb <= '0';
--	       	end if;	        	

--		end loop load_data_loop_1;       	
		       
        test_runner_cleanup(runner);        
  		wait;
   	end process;
   	
    CLK_tb <= not CLK_tb after 5 ns;
   	
   	    dut: entity fifo_lib.Fifo_top
    generic map(
        FIFO_TOP_DEPTH      => DEPTH_tb, 
        FIFO_TOP_WIDTH      => WIDTH_tb,  
        FIFO_TOP_AE_AF_LVL  => AE_AF_LVL_tb         
    )
    
    port map(
        FIFO_TOP_CLK => CLK_tb,     
        FIFO_TOP_RST => RST_tb,    
                         
        -- write interface
                         
        FIFO_TOP_WR_EN      => WR_EN_tb,  
        FIFO_TOP_WR_DATA    => WR_DATA_tb,
        FIFO_TOP_FULL       => FULL_tb,    
        FIFO_TOP_AF         => AF_tb,     
                         
        -- read interface
                         
        FIFO_TOP_RD_EN      => RD_EN_tb,  
        FIFO_TOP_RD_DATA    => RD_DATA_tb,
        FIFO_TOP_EMPTY      => EMPTY_tb,   
        FIFO_TOP_AE         => AE_tb,     
        FIFO_TOP_RD_VALID   => RD_VALID_tb      
    );    
end Behavioral;
