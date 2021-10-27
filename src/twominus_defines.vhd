-------------------------------------------------------------------------------
-- Title      : project defines
-- Project    : 
-------------------------------------------------------------------------------
-- File       : twominus_defines.vhd
-- Author     : sdong  <sdong@sdong-ubuntu>
-- Company    : 
-- Created    : 2021-10-21
-- Last update: 2021-10-21
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: project defines
-------------------------------------------------------------------------------
-- Copyright (c) 2021 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2021-10-21  1.0      sdong	Created
-------------------------------------------------------------------------------




library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

--use IEEE.MATH_REAL.ALL;
--use ieee.std_logic_arith.all;

package TWOMINUS_DEFINES is


--  constant ADC9512_SPI_PERIOD      : real := 10.0;  -- unit: ns
--  constant JADEPIX_SYS_PERIOD : real := 12.0;  -- unit: ns
--  constant JADEPIX_REF_PERIOD : real := 25.0;  -- unit: ns

  -- IPbus reg fifo slave
  constant WFIFO_ADDR_SLOW_CTRL_CMD : integer := 0;
  constant RFIFO_ADDR_DATA_FIFO     : integer := 0;
  
  constant RFIFO_WIDTH : integer := 16;

end TWOMINUS_DEFINES;

