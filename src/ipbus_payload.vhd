-------------------------------------------------------------------------------
-- Title      : ipbus payload top
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ipbus_payload.vhd
-- Author     : sdong  <sdong@sdong-ubuntu>
-- Company    : 
-- Created    : 2021-10-28
-- Last update: 2021-11-01
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2021 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2021-10-28  1.0      sdong   Created
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.ipbus.all;
use work.ipbus_reg_types.all;
use work.ipbus_decode_payload.all;

use work.global_defines.all;
use work.twominus_defines.all;


entity ipbus_payload is
  generic(
    N_SS : positive := 8
    );
  port(
    ipb_clk : in  std_logic;
    ipb_rst : in  std_logic;
    ipb_in  : in  ipb_wbus;
    ipb_out : out ipb_rbus;

    -- Chip System Clock
    clk : in std_logic;
    rst : in std_logic;

    -- Global
    nuke     : out std_logic;
    soft_rst : out std_logic;

    -- Two minus
    tm_start_scan : out std_logic;
    tm_reset_scan : out std_logic;

    data_type : out std_logic_vector(15 downto 0);
    time_high : out std_logic_vector(15 downto 0);
    time_mid  : out std_logic_vector(15 downto 0);
    time_low  : out std_logic_vector(15 downto 0);
    time_usec : out std_logic_vector(31 downto 0);
    chip_cnt  : out std_logic_vector(15 downto 0);

    data_resync : out std_logic;

    dp_status : in std_logic_vector(8 downto 0);


    -- AD9252
    data_soft_rst        : out std_logic;
    data_soft_path_rst   : out std_logic;
    data_soft_pack_start : out std_logic;

    device_rst     : out std_logic;
    ad9252_start   : out std_logic;
    ad9252_restart : out std_logic;
    pulse_ad       : out std_logic;
    ad_test_mode   : out std_logic;

    ad9252_busy : in std_logic;
    current_s   : in std_logic_vector(4 downto 0);


    -- FIFO
    slow_ctrl_fifo_rd_clk        : in  std_logic;
    slow_ctrl_fifo_rd_en         : in  std_logic;
    slow_ctrl_fifo_valid         : out std_logic;
    slow_ctrl_fifo_empty         : out std_logic;
    slow_ctrl_fifo_prog_full     : out std_logic;
    slow_ctrl_fifo_wr_data_count : out std_logic_vector(17 downto 0);
    slow_ctrl_fifo_rd_dout       : out std_logic_vector(31 downto 0);
    data_fifo_rst                : in  std_logic;
    data_fifo_wr_clk             : in  std_logic;
    data_fifo_wr_en              : in  std_logic;
    data_fifo_wr_din             : in  std_logic_vector(31 downto 0);
    data_fifo_full               : out std_logic;
    data_fifo_almost_full        : out std_logic;
    
    data_lost_counter : in  std_logic_vector(31 downto 0);

    -- SPI Master
    ss   : out std_logic_vector(N_SS - 1 downto 0);
    mosi : out std_logic;
    miso : in  std_logic;
    sclk : out std_logic;

    ad9512_function : out std_logic;

    -- FREQ CTR
    clk_ctr_in : in std_logic_vector(N_CLK-1 downto 0)

    );

end ipbus_payload;

architecture rtl of ipbus_payload is

  signal ipbw : ipb_wbus_array(N_SLAVES - 1 downto 0);
  signal ipbr : ipb_rbus_array(N_SLAVES - 1 downto 0);


  signal spi_rst : std_logic;           -- from ipbus control module
  signal rst_spi : std_logic;           -- to SPI module

  --Debug
  attribute mark_debug         : string;
  attribute mark_debug of ss   : signal is "true";
  attribute mark_debug of mosi : signal is "true";
  attribute mark_debug of miso : signal is "true";
  attribute mark_debug of sclk : signal is "true";

  attribute mark_debug of data_fifo_rst         : signal is "true";
  attribute mark_debug of data_fifo_wr_clk      : signal is "true";
  attribute mark_debug of data_fifo_wr_en       : signal is "true";
  attribute mark_debug of data_fifo_wr_din      : signal is "true";
  attribute mark_debug of data_fifo_full        : signal is "true";
  attribute mark_debug of data_fifo_almost_full : signal is "true";

begin

-- ipbus address decode
  fabric : entity work.ipbus_fabric_sel
    generic map(
      NSLV      => N_SLAVES,
      SEL_WIDTH => IPBUS_SEL_WIDTH)
    port map(
      ipb_in          => ipb_in,
      ipb_out         => ipb_out,
      sel             => ipbus_sel_payload(ipb_in.ipb_addr),
      ipb_to_slaves   => ipbw,
      ipb_from_slaves => ipbr
      );

  slave0 : entity work.ipbus_global_device
    port map(
      ipb_clk  => ipb_clk,
      ipb_rst  => ipb_rst,
      ipb_in   => ipbw(N_SLV_GLOBAL),
      ipb_out  => ipbr(N_SLV_GLOBAL),
      nuke     => nuke,
      soft_rst => soft_rst
      );

  slave1 : entity work.ipbus_ad9512_device
    port map(
      ipb_clk => ipb_clk,
      ipb_rst => ipb_rst,
      ipb_in  => ipbw(N_SLV_AD9512),
      ipb_out => ipbr(N_SLV_AD9512),

      clk => ipb_clk,
      rst => ipb_rst,

      ad9512_function => ad9512_function,

      spi_rst => spi_rst
      );


  rst_spi <= spi_rst or ipb_rst;
  slave2 : entity work.ipbus_spi
    generic map(
      N_SS => N_SS
      )
    port map(
      clk     => ipb_clk,
      rst     => rst_spi,
      ipb_in  => ipbw(N_SLV_SPI),
      ipb_out => ipbr(N_SLV_SPI),
      ss      => ss,
      mosi    => mosi,
      miso    => miso,
      sclk    => sclk
      );


  slave3 : entity work.ipbus_twominus_device
    port map(
      ipb_clk => ipb_clk,
      ipb_rst => ipb_rst,
      ipb_in  => ipbw(N_SLV_TWOMINUS),
      ipb_out => ipbr(N_SLV_TWOMINUS),

      clk => clk,
      rst => rst,

      -- Two minus
      start_scan => tm_start_scan,
      reset_scan => tm_reset_scan,

      -- ad9252
      data_soft_rst        => data_soft_rst,
      data_soft_path_rst   => data_soft_path_rst,
      data_soft_pack_start => data_soft_pack_start,

      data_resync => data_resync,

      data_type => data_type,
      time_high => time_high,
      time_mid  => time_mid,
      time_low  => time_low,
      time_usec => time_usec,
      chip_cnt  => chip_cnt,

      dp_status => dp_status,

      --FIFO
      slow_ctrl_fifo_rd_clk        => slow_ctrl_fifo_rd_clk,
      slow_ctrl_fifo_rd_en         => slow_ctrl_fifo_rd_en,
      slow_ctrl_fifo_valid         => slow_ctrl_fifo_valid,
      slow_ctrl_fifo_empty         => slow_ctrl_fifo_empty,
      slow_ctrl_fifo_prog_full     => slow_ctrl_fifo_prog_full,
      slow_ctrl_fifo_wr_data_count => slow_ctrl_fifo_wr_data_count,
      slow_ctrl_fifo_rd_dout       => slow_ctrl_fifo_rd_dout,
      data_fifo_rst                => data_fifo_rst,
      data_fifo_wr_clk             => data_fifo_wr_clk,
      data_fifo_wr_en              => data_fifo_wr_en,
      data_fifo_full               => data_fifo_full,
      data_fifo_almost_full        => data_fifo_almost_full,
      data_fifo_wr_din             => data_fifo_wr_din,
      
      data_lost_counter => data_lost_counter
      );


  slave4 : entity work.ipbus_freq_ctr
    generic map(
      N_CLK => N_CLK
      )
    port map(
      clk     => ipb_clk,
      rst     => ipb_rst,
      ipb_in  => ipbw(N_SLV_FREQ_CTR),
      ipb_out => ipbr(N_SLV_FREQ_CTR),
      clkdiv  => clk_ctr_in
      );

  slave5 : entity work.ipbus_ad9252_device
    port map(
      ipb_clk => ipb_clk,
      ipb_rst => ipb_rst,
      ipb_in  => ipbw(N_SLV_AD9252),
      ipb_out => ipbr(N_SLV_AD9252),

      clk => clk,                       -- 10 MHz
      rst => rst,

      device_rst     => device_rst,
      ad9252_start   => ad9252_start,
      pulse_ad       => pulse_ad,
      ad9252_restart => ad9252_restart,

      ad9252_busy => ad9252_busy,
      current_s   => current_s
      );


end rtl;

