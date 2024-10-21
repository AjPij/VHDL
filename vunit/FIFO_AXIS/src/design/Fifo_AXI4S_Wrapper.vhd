----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/13/2023 04:01:32 PM
-- Design Name: 
-- Module Name: Fifo_AXI4S_Wrapper - Behavioral
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

-- Uncomment the following library declaration if usings
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Fifo_AXI4S_Wrapper is
    generic(
	-- axis generics		
        TDATA_WIDTH         : natural := 1; -- data bus width in BYTES, must be an integer number of BYTES, recommended: 1,2,4,8,16,32,64 or 128 bytes (8,16,32,64,128,256,512 or 1024 bits) 
        --TUSER_WIDTH         : natural := 1;  -- user data bus width in bits, recommended number of bits is an integer multiple of TDATA_WIDTH[bits]/8 or integer multiple of TDATA_WIDTH[bytes]
        BUFF_DEPTH			: natural := 1; -- buffer depth in number of words each size of TDATA_WIDTH 
                        
	-- memory generics                
        USE_LUT_M           : boolean := true;
        USE_REG_M           : boolean := false;        
        USE_OTHERTYPE_M     : boolean := false;        
        MEM_RD_LAT          : natural := 1; -- latency in clock cycles to determine level for AE flag
		MEM_WR_LAT			: natural := 1  -- latency in clock cycles to determine level for AF flag
    );
    port (
    -- AXI4S global signals
        ACLK    : in std_logic; -- source: Clock source
        ARESETn : in std_logic; -- source: Reset source, active low
                     
    -- AXI4S SLAVE interface signals
        S_AXIS_TVALID   : in std_logic;
        S_AXIS_TREADY   : out std_logic; -- TREADY = '1' if FIFO is not full, no write latency is present
        S_AXIS_TDATA    : in std_logic_vector((TDATA_WIDTH - 1) downto 0);
      	S_AXIS_TLAST    : in std_logic;
      --S_AXIS_TUSER    : in std_logic_vector(TUSER_WIDTH -1 downto 0 );
      --S_AXIS_TKEEP    : in std_logic_vector(TDATA_WIDTH - 1 downto 0);                
        S_AXIS_TSTRB    : in std_logic_vector(TDATA_WIDTH/8 - 1 downto 0); -- it is generaly not needed to use both TKEEP and TSTRB                                    
        
    -- AXI4S MASTER interface signals
        M_AXIS_TVALID   : out std_logic;                                                                                          
        M_AXIS_TREADY   : in std_logic;                                                                                         
        M_AXIS_TDATA    : out std_logic_vector((TDATA_WIDTH - 1) downto 0);                                                     
      	M_AXIS_TLAST    : out std_logic;                                                                                          
      --M_AXIS_TUSER    : out std_logic_vector(TUSER_WIDTH -1 downto 0 );                                                         
      --M_AXIS_TKEEP    : out std_logic_vector(TDATA_WIDTH - 1 downto 0)                                                         
        M_AXIS_TSTRB    : out std_logic_vector(TDATA_WIDTH/8 - 1 downto 0) -- it is generaly not needed to use both TKEEP and TSTRB            
    );
    
end Fifo_AXI4S_Wrapper;

architecture Behavioral of Fifo_AXI4S_Wrapper is
    signal FIFO_RST                 : std_logic; 
           
    signal FIFO_FULL                : std_logic;
    signal FIFO_AF                  : std_logic;
    
    signal FIFO_EMPTY               : std_logic;        
    signal FIFO_AE                  : std_logic; 
       
    signal FIFO_RD_VALID            : std_logic;                
    
    signal FIFO_WR_EN               : std_logic;        
    signal FIFO_RD_EN               : std_logic := '0';
	
	signal buff_in_data					: std_logic_vector(TDATA_WIDTH + TDATA_WIDTH/8 downto 0);
	signal buff_out_data				: std_logic_vector(TDATA_WIDTH + TDATA_WIDTH/8 downto 0);

	signal m_tvalid_temp				: std_logic := '0';
--	signal fr_flag						: std_logic;
	
	signal ae_lat						: std_logic; -- copy of FIFO_AE 1 clock cycle late
	signal rd_v_lat						: std_logic; -- copy of FIFO_RD_VALID  1 clock cycle late
	signal rd_val_re					: std_logic; -- rising edge of rd valid active 1 clock
	signal rd_val_fe					: std_logic; -- falling edge of rd valid active 1 clock
	
	signal rd_flag						: std_logic;
	signal rd_en_temp					: std_logic;
	
	signal m_valid						: std_logic;
begin
    
    FIFO_RST <= not ARESETn;
    
    FIFO_INST: entity work.Fifo_top
    generic map(
        FIFO_TOP_DEPTH      => BUFF_DEPTH,
        FIFO_TOP_WIDTH      => TDATA_WIDTH + TDATA_WIDTH/8 + 1, -- data + tstrb +tlast
		
        FIFO_TOP_AE_LVL  	=> MEM_RD_LAT,        
        FIFO_TOP_AF_LVL  	=> MEM_WR_LAT,        
		
        USE_LUT_MEM         => USE_LUT_M,
        USE_REG_MEM         => USE_REG_M,
        USE_OTHERTYPE_MEM   => USE_OTHERTYPE_M,
		
		MEM_RD_LAT			=> MEM_RD_LAT,
		MEM_WR_LAT			=> MEM_WR_LAT
    ) 
    port map(
        FIFO_TOP_CLK        => ACLK,
        FIFO_TOP_RST        => FIFO_RST,
        
        FIFO_TOP_WR_EN      => FIFO_WR_EN,
        FIFO_TOP_WR_DATA    => buff_in_data,
        FIFO_TOP_FULL       => FIFO_FULL,
        FIFO_TOP_AF         => FIFO_AF,
        
        FIFO_TOP_RD_EN      => FIFO_RD_EN,
        FIFO_TOP_RD_DATA    => buff_out_data,
        FIFO_TOP_EMPTY      => FIFO_EMPTY,
        FIFO_TOP_AE         => FIFO_AE,
        FIFO_TOP_RD_VALID   => FIFO_RD_VALID 
    );


        
    --AXIS SLAVE
    S_AXIS_TREADY <= not FIFO_FULL;
    FIFO_WR_EN <= S_AXIS_TVALID and (not FIFO_FULL);      

	buff_in_data  <= S_AXIS_TDATA & S_AXIS_TSTRB & S_AXIS_TLAST;-- input data to fifo


--	-- AE reg
--	ae_reg: process(ACLK)
--	begin
--		if( rising_edge(ACLK) )then
--			ae_lat <= FIFO_AE;	
--		end if;
--	end process ae_reg;	
--    -- RD_VALID reg
--	
	rd_val_reg: process(ACLK,ARESETn)
	begin
		if( ARESETn = '0' )then
			rd_v_lat <= '0';
		elsif( rising_edge(ACLK) )then
			rd_v_lat <= FIFO_RD_VALID;
		end if;
	end process rd_val_reg;

	rd_val_re <= (not rd_v_lat) and FIFO_RD_VALID;		
	rd_val_fe <= rd_v_lat and (not FIFO_RD_VALID);		
    --AXIS MASTER
--    FIFO_RD_EN <= not FIFO_AE and (ae_lat or M_AXIS_TREADY );      	
	
		
--	tvalid: process(ACLK)				
--	begin
--		if( ARESETn = '0')then
--			m_tvalid_temp 	<= '0';			
--		elsif(rising_edge(ACLK))then
--			if( FIFO_RD_VALID = '1')then
--				m_tvalid_temp <= '1';
--			else
--				m_tvalid_temp <= '0';
--			end if;		
--		end if;					
--	end process tvalid;

--	FIFO_RD_EN <=(not FIFO_EMPTY and not rd_flag) ;--or M_AXIS_TREADY ; 

--	rd_en_temp <= FIFO_EMPTY nand rd_flag; 

--	rd: process(ACLK,ARESETn)				
--	begin
--		if( ARESETn = '0')then			
--			rd_flag			<= '0';
--		elsif(rising_edge(ACLK))then
--			if( m_tvalid_temp = '0' )then -- no valid data on TDATA
--				if(not FIFO_EMPTY )then -- fifo not empty											
--					if(M_AXIS_TREADY = '0' and FIFO_RD_EN = '1')then -- tready deasserted rd_en previously asserted
--						rd_flag	<= '1'; -- deassert read																							
--					end if;															
--				end if;
--			elsif( m_tvalid_temp = '1' )then -- valid data present on bus
--				if(M_AXIS_TREADY = '1' and FIFO_RD_EN = '0')then
--					rd_flag	<= '0'; -- assert read
--				elsif(M_AXIS_TREADY = '0')then 
--					rd_flag	<= '1'; -- deassert read
--				end if;					 				
--			end if;
--		end if;					
--	end process rd;

	FIFO_RD_EN <= (not FIFO_EMPTY) and ((not M_AXIS_TREADY ) nand  m_valid) ;
	
--	rd: process(ACLK,ARESETn)				
--	begin
--		if( ARESETn = '0')then			
--			rd_flag	<= '0';
--		elsif(rising_edge(ACLK))then
--			if( (m_tvalid_temp or FIFO_RD_VALID) = '0' )then -- no valid data on TDATA, first read																				
--				rd_flag <= '1'; -- assert read
--			elsif( (m_tvalid_temp or FIFO_RD_VALID) = '1' )then -- valid data present on bus
--				rd_flag <= '0'; -- deassert read
--			
--				
--			end if;
--		end if;					
--	end process rd;

--	valid: process(ACLK,ARESETn)			
--	begin
--		if(ARESETn = '0')then
--			m_tvalid_temp 	<= '0';
--		elsif( rising_edge(ACLK) )then
--			if( M_AXIS_TREADY = '0' )then
--				if( FIFO_RD_VALID = '1' )then
--					m_tvalid_temp <= '1';
--				else
--					m_tvalid_temp <= m_tvalid_temp ;
--				end if;
--			elsif(M_AXIS_TREADY = '1' and FIFO_RD_EN = '0')then					
--				m_tvalid_temp <= '0';
--			elsif(M_AXIS_TREADY = '1' and FIFO_RD_EN = '1')then										
--				m_tvalid_temp <= '1';
--				
--			elsif(M_AXIS_TREADY = '1' and FIFO_AE = '1' and FIFO_RD_EN = '0')then
--				if( FIFO_RD_VALID = '1' )then
--					m_tvalid_temp <= '0';
--
--				end if;				
--			end if;
--		end if;
--	end process valid;
			
	valid: process(ACLK,ARESETn)			
	begin
		if(ARESETn = '0')then
			m_tvalid_temp 	<= '0';
		elsif( rising_edge(ACLK) )then
			if( rd_val_re = '1' )then
				m_tvalid_temp <= '1';
			else
				m_tvalid_temp <= m_tvalid_temp;
			end if;
				
			if( FIFO_EMPTY = '1' )then
				m_tvalid_temp <= '0';
			else					
				--m_tvalid_temp <= m_tvalid_temp;
			end if;
		end if;
	end process valid;				

	m_valid <=	FIFO_RD_VALID or m_tvalid_temp ;	
  	M_AXIS_TVALID <= m_valid ; 			
			
--- buff_out_data = ddddddddddddddddddddddddddddddddssssl 32bit example
																
	M_AXIS_TLAST <= buff_out_data(buff_out_data'right); -- migth need to use (buff_in_data)
	M_AXIS_TSTRB <= buff_out_data(TDATA_WIDTH/8 downto buff_out_data'right + 1);
	M_AXIS_TDATA <= buff_out_data(buff_out_data'left downto (TDATA_WIDTH/8 + 1) );
								  
end Behavioral;
