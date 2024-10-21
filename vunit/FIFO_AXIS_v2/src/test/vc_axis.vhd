-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2014-2023, Lars Asplund lars.anders.asplund@gmail.com

library ieee;
context ieee.ieee_std_context;

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.vc_context;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;
	
entity vc_axis is
  generic (
    m_axis : axi_stream_master_t;
    s_axis : axi_stream_slave_t;
    data_width : natural := 32;
    fifo_depth : natural := 4
  );
  port (
    clk, rstn: in std_logic
  );
end entity;

architecture arch of vc_axis is

  signal m_valid, m_ready, m_last, s_valid, s_ready, s_last : std_logic;
  signal m_data, s_data : std_logic_vector(data_length(m_axis)-1 downto 0);

	--constant TUSER		  		 : natural := 1;	
	constant USE_REG_MEM 		 : boolean := false;
	constant USE_LUT_MEM 		 : boolean := true;
	constant USE_OTHERTYPE_MEM	 : boolean  := false;
--	constant MEM_RD_LAT	 		 : natural := 1;
	constant MEM_WR_LAT	 		 : natural := 1;
---------------------------------------------------
	constant MEM_RD_LAT	 		 : natural := 1;
---------------------------------------------------

begin

  vunit_axism: entity vunit_lib.axi_stream_master
  generic map (
    master => m_axis
  )
  port map (
    aclk   => clk,
    tvalid => m_valid,
    tready => m_ready,
    tdata  => m_data,
    tlast  => m_last
  );

  vunit_axiss: entity vunit_lib.axi_stream_slave
  generic map (
    slave => s_axis
  )
  port map (
    aclk   => clk,
    tvalid => s_valid,
    tready => s_ready,
    tdata  => s_data,
    tlast  => s_last
  );

--
	uut: entity work.Fifo_AXI4S_Wrapper
  	generic map (

		-- axis generics
		TDATA_WIDTH  		=> data_width,  
		--TUSER_WIDTH   	=> TUSER,
		BUFF_DEPTH			=> fifo_depth,	

		--memory generics  
		USE_LUT_M 			=> USE_LUT_MEM,     
		USE_REG_M      		=> USE_REG_MEM, 
		USE_OTHERTYPE_M 	=> USE_OTHERTYPE_MEM,
		MEM_RD_LAT    		=> MEM_RD_LAT,  
		MEM_WR_LAT			=> MEM_WR_LAT	
		
	)
  	port map ( 		
  -- AXI4S global signals
     ACLK    => clk, -- source: Clock source
     ARESETn => rstn, -- source: Reset source, active low
                   
  -- AXI4S SLAVE interface signals
     S_AXIS_TVALID   => m_valid ,
     S_AXIS_TREADY   => m_ready ,
     S_AXIS_TDATA    => m_data ,
     S_AXIS_TLAST    => m_last,
   --S_AXIS_TUSER    : in std_logic_vector(TUSER_WIDTH -1 downto 0 );
   --S_AXIS_TKEEP    : in std_logic_vector(TDATA_WIDTH - 1 downto 0);                
     S_AXIS_TSTRB    => "1111",
      
  -- AXI4S MASTER interface signals
     M_AXIS_TVALID   => s_valid,
     M_AXIS_TREADY   => s_ready,
     M_AXIS_TDATA    => s_data,
     M_AXIS_TLAST    => s_last,
   --M_AXIS_TUSER    : out std_logic_vector(TUSER_WIDTH -1 downto 0 );                                                         
   --M_AXIS_TKEEP    : out std_logic_vector(TDATA_WIDTH - 1 downto 0)                                                         
     M_AXIS_TSTRB    => open
  	);

end architecture;
