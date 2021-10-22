-------------------------------------------------------------------------------
-- Title      : ad9512 refresh
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ad9512_refresh.vhd
-- Author     : sdong  <sdong@sdong-ubuntu>
-- Company    : 
-- Created    : 2021-10-22
-- Last update: 2021-10-22
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2021 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2021-10-22  1.0      sdong   Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library UNISIM;
use UNISIM.vcomponents.all;



entity ad9512_refresh is
  port (
    clk : in std_logic;
    rst : in std_logic;

    -- Config data
    din     : in  std_logic_vector(31 downto 0);
    din_vld : in  std_logic;
    din_rdy : out std_logic;

    -- SPI port

    ad9512_sclk : out std_logic;
    ad9512_sdio : out std_logic;
    ad9512_csb  : out std_logic
    );


end entity ad9512_refresh;



architecture behv of ad9512_refresh is
begin

  spi_master_i : entity work.SPI_MASTER
    generic map(
      CLK_FREQ    => 200e6,
      SCLK_FREQ   => 10e6,
      WORD_SIZE   => 32,
      SLAVE_COUNT => 1
      )
    port map (
      CLK      => clk,
      RST      => rst,
      -- SPI MASTER INTERFACE
      SCLK     => ad9512_sclk,
      CS_N(0)  => ad9512_csb,
      MOSI     => ad9512_sdio,
      MISO     => '0',
      -- USER INTERFACE
      DIN_ADDR => (others => '0'),
      DIN      => din,
      DIN_LAST => '1',
      DIN_VLD  => din_vld,
      DIN_RDY  => din_rdy,
      DOUT     => open,
      DOUT_VLD => open
      );


end behv;
