-------------------------------------------------------------------------------
-- Title      : Beam monitor top module
-- Project    : 
-------------------------------------------------------------------------------
-- File       : Beam_Monitor.vhd
-- Author     : sdong  <sdong@sdong-ubuntu>
-- Company    : 
-- Created    : 2021-10-28
-- Last update: 2021-11-05
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
use IEEE.NUMERIC_STD.all;

library UNISIM;
use UNISIM.vcomponents.all;

use work.ipbus.all;
use work.drp_decl.all;

use work.global_defines.all;
use work.twominus_defines.all;


entity Beam_Monitor is port(
  sysclk_p     : in  std_logic;
  sysclk_n     : in  std_logic;
  hard_reset   : in  std_logic;
  leds         : out std_logic_vector(2 downto 0);  -- status LEDs
  dip_sw       : in  std_logic_vector(3 downto 0);  -- switches
  gmii_gtx_clk : out std_logic;
  gmii_tx_en   : out std_logic;
  gmii_tx_er   : out std_logic;
  gmii_txd     : out std_logic_vector(7 downto 0);
  gmii_rx_clk  : in  std_logic;
  gmii_rx_dv   : in  std_logic;
  gmii_rx_er   : in  std_logic;
  gmii_rxd     : in  std_logic_vector(7 downto 0);
  phy_rst      : out std_logic;

  -- Topmetal 2 minus
  tm_marker : in std_logic;

  tm_speak : out std_logic;
  tm_clk   : out std_logic;
  tm_reset : out std_logic;
  tm_start : out std_logic;

  -- AD9252
  adc_data_p : in std_logic_vector(3 downto 0);
  adc_data_n : in std_logic_vector(3 downto 0);
  adc_DCO_p  : in std_logic;
  adc_DCO_n  : in std_logic;
  adc_FCO_p  : in std_logic;
  adc_FCO_n  : in std_logic;

  ad9252_sclk : out std_logic;
  ad9252_sdio : out std_logic;
  ad9252_csb  : out std_logic;

  -- show some status
  adc_data_aligned : out std_logic;
  ad_9252_done     : out std_logic;
  ad_9512_done     : out std_logic;
  topmetal_working : out std_logic;

  ad9512_function : out std_logic;
--  -- SPI Master
  ss              : out std_logic_vector(0 downto 0);
  mosi            : out std_logic;
  miso            : in  std_logic;
  sclk            : out std_logic
  );
end Beam_Monitor;

architecture rtl of Beam_Monitor is


  signal sysclk     : std_logic;
  signal sysclk_i   : std_logic;
  signal global_rst : std_logic;


  signal sys_mmcm_locked : std_logic;

  signal clk_200m, clk_50m, clk_100m, clk_10m                 : std_logic;
  signal clk_200m_rst, clk_50m_rst, clk_100m_rst, clk_10m_rst : std_logic;

  -- IPbus
  signal clk_ipb, rst_ipb, clk_125M, clk_aux, rst_aux, locked_ipbus_mmcm, nuke, soft_rst, phy_rst_e, userled : std_logic;
  signal mac_addr                                                                                            : std_logic_vector(47 downto 0);
  signal ip_addr                                                                                             : std_logic_vector(31 downto 0);
  signal ipb_out                                                                                             : ipb_wbus;
  signal ipb_in                                                                                              : ipb_rbus;


  -- AD9512

  signal AD9512_BUSY : std_logic;
  signal AD9512_RDY  : std_logic;
  signal AD9512_WE   : std_logic;
  signal AD9512_DATA : std_logic_vector(31 downto 0);

  -- Two minus
  signal tm_clk_o      : std_logic;
  signal tm_speak_o    : std_logic;
  signal tm_start_scan : std_logic;
  signal tm_reset_scan : std_logic;

  signal tm_marker_a : std_logic_vector(3 downto 0);


  -- AD9252
  signal data_soft_rst        : std_logic;
  signal data_soft_path_rst   : std_logic;
  signal data_soft_pack_start : std_logic;

  signal data_resync    : std_logic;
  signal device_rst     : std_logic;
  signal ad9252_start   : std_logic;
  signal ad9252_restart : std_logic;


  signal ad_test_mode : std_logic;

  signal ad9252_busy : std_logic;
  signal current_s   : std_logic_vector(4 downto 0);

  signal data_aligned : std_logic;

  signal data_type : std_logic_vector(15 downto 0);
  signal time_high : std_logic_vector(15 downto 0);
  signal time_mid  : std_logic_vector(15 downto 0);
  signal time_low  : std_logic_vector(15 downto 0);
  signal time_usec : std_logic_vector(31 downto 0);
  signal chip_cnt  : std_logic_vector(15 downto 0);

  signal dp_status    : std_logic_vector(8 downto 0);
  signal adc_dco_done : std_logic;

  -- FIFOs
  signal data_fifo_rst                : std_logic;
  signal slow_ctrl_fifo_rd_en         : std_logic;
  signal slow_ctrl_fifo_valid         : std_logic;
  signal slow_ctrl_fifo_empty         : std_logic;
  signal slow_ctrl_fifo_prog_full     : std_logic;
  signal slow_ctrl_fifo_wr_data_count : std_logic_vector(17 downto 0);
  signal slow_ctrl_fifo_rd_dout       : std_logic_vector(31 downto 0);
  signal data_fifo_wr_clk             : std_logic;
  signal data_fifo_wr_en              : std_logic;
  signal data_fifo_wr_din             : std_logic_vector(31 downto 0);
  signal data_fifo_full               : std_logic;
  signal data_fifo_almost_full        : std_logic;


  -- Readout

  -- SPI 
--  signal spi_trans_end : std_logic;

  -- constant
  constant ch          : std_logic_vector := X"FF";
  constant chip_number : std_logic_vector := X"0";

  constant N_SS : positive := 1;        -- Number of SPI Slaves


  -- DEBUG
  attribute mark_debug : string;

  signal adc_fclk : std_logic;

  signal clk_div : std_logic_vector(N_CLK -1 downto 0);

  signal data_lost_counter : std_logic_vector(31 downto 0);


begin


  OBUFDS_TM_CLK : OBUF
    generic map (
      DRIVE      => 12,
      IOSTANDARD => "DEFAULT",
      SLEW       => "SLOW")
    port map (
      O => tm_clk,   -- Buffer output (connect directly to top-level port)
      I => tm_clk_o                     -- Buffer input 
      );


  IBUFDS_inst : IBUFDS
    generic map (
      DIFF_TERM    => false,            -- Differential Termination
      IBUF_LOW_PWR => false,  -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD   => "DEFAULT"
      )
    port map (
      O  => sysclk_i,                   -- Buffer output
      I  => sysclk_p,  -- Diff_p buffer input (connect directly to top-level port)
      IB => sysclk_n  -- Diff_n buffer input (connect directly to top-level port)
      );

  BUFG_inst : BUFG
    port map (
      I => sysclk_i,
      O => sysclk
      );


  twominus_clocks : entity work.twominus_clock_gen
    port map(
      sysclk       => sysclk,
      clk_out0     => clk_50m,
      clk_out1     => clk_100m,
      clk_out2     => clk_10m,
      clk_out3     => clk_200m,
      clk_out0_rst => clk_50m_rst,
      clk_out1_rst => clk_100m_rst,
      clk_out2_rst => clk_10m_rst,
      clk_out3_rst => clk_200m_rst,
      locked       => sys_mmcm_locked
      );

  global_rst <= not sys_mmcm_locked or hard_reset;


  ipbus_infra : entity work.ipbus_gmii_infra
    generic map(
      CLK_AUX_FREQ => 50.0
      )
    port map(
      sysclk       => sysclk,
      clk_ipb_o    => clk_ipb,
      rst_ipb_o    => rst_ipb,
      clk_125_o    => clk_125M,
      rst_125_o    => phy_rst_e,
      clk_aux_o    => clk_aux,
      rst_aux_o    => rst_aux,
      locked_o     => locked_ipbus_mmcm,
      nuke         => nuke,
      soft_rst     => soft_rst,
      leds         => leds(1 downto 0),
      gmii_gtx_clk => gmii_gtx_clk,
      gmii_txd     => gmii_txd,
      gmii_tx_en   => gmii_tx_en,
      gmii_tx_er   => gmii_tx_er,
      gmii_rx_clk  => gmii_rx_clk,
      gmii_rxd     => gmii_rxd,
      gmii_rx_dv   => gmii_rx_dv,
      gmii_rx_er   => gmii_rx_er,
      mac_addr     => mac_addr,
      ip_addr      => ip_addr,
      ipb_in       => ipb_in,
      ipb_out      => ipb_out
      );

  leds(2) <= sys_mmcm_locked;
  phy_rst <= not phy_rst_e;

  mac_addr <= X"020ddba1151" & dip_sw;  -- Careful here, arbitrary addresses do not always work
  ip_addr  <= X"c0a8021" & dip_sw;      -- 192.168.2.16+n (n:0-15)

-- ipbus slaves live in the entity below, and can expose top-level ports
-- The ipbus fabric is instantiated within.

  ipbus_payload : entity work.ipbus_payload
    generic map(
      N_SS => N_SS
      )
    port map(
      ipb_clk => clk_ipb,
      ipb_rst => rst_ipb,
      ipb_in  => ipb_out,
      ipb_out => ipb_in,

      -- Chip system clock
      clk => tm_clk_o,
      rst => clk_200m_rst,

      -- Global
      nuke     => nuke,
      soft_rst => soft_rst,

      -- twominus
      tm_start_scan => tm_start_scan,
      tm_reset_scan => tm_reset_scan,

      data_type => data_type,
      time_high => time_high,
      time_mid  => time_mid,
      time_low  => time_low,
      time_usec => time_usec,
      chip_cnt  => chip_cnt,

      data_resync => data_resync,
      dp_status   => dp_status,

      -- ad9252
      data_soft_rst        => data_soft_rst,
      data_soft_path_rst   => data_soft_path_rst,
      data_soft_pack_start => data_soft_pack_start,


      ad9252_sclk => ad9252_sclk,
      ad9252_sdio => ad9252_sdio,
      ad9252_csb  => ad9252_csb,


--      device_rst     => device_rst,
--      ad9252_start   => ad9252_start,
--      pulse_ad       => open,
--      ad9252_restart => ad9252_restart,

      ad9252_busy => ad9252_busy,
      current_s   => current_s,

      -- FIFOs
      slow_ctrl_fifo_rd_clk        => '0',
      slow_ctrl_fifo_rd_en         => '0',
      slow_ctrl_fifo_valid         => slow_ctrl_fifo_valid,
      slow_ctrl_fifo_empty         => slow_ctrl_fifo_empty,
      slow_ctrl_fifo_rd_dout       => slow_ctrl_fifo_rd_dout,
      slow_ctrl_fifo_prog_full     => slow_ctrl_fifo_prog_full,
      slow_ctrl_fifo_wr_data_count => slow_ctrl_fifo_wr_data_count,

      data_fifo_rst         => data_fifo_rst,
      data_fifo_wr_clk      => data_fifo_wr_clk,
      data_fifo_wr_en       => data_fifo_wr_en,
      data_fifo_full        => data_fifo_full,
      data_fifo_almost_full => data_fifo_almost_full,
      data_fifo_wr_din      => data_fifo_wr_din,

      data_lost_counter => data_lost_counter,

      -- ipbus SPI master
      ss   => ss,
      mosi => mosi,
      miso => miso,
      sclk => sclk,

      ad9512_function => ad9512_function,

--      spi_trans_end => spi_trans_end,

      -- FREQ CTR
      clk_ctr_in => clk_div

      );


--  ad9252_control : entity work.ad9252_control
--    port map(
--      reset       => device_rst or global_rst or soft_rst,
--      start       => ad9252_start,
--      clk_spi     => clk_10m,
--      ch          => ch,
--      adc_restart => ad9252_restart,

--      data_aligned => data_aligned,
--      ad_csb       => ad9252_csb,

--      ad_sclk          => ad9252_sclk,
--      ad_sdio          => ad9252_sdio,
--      spi_9252_done    => ad_9252_done,
--      ad_test_cfg_done => ad_test_mode,

--      state_9_1 => current_s,

--      busy_9252 => ad9252_busy
--      );


  tm_marker_a <= (tm_marker & tm_marker & tm_marker & tm_marker);

  ad_data_module : entity work.ad_data_module
    generic map(
      ADC_CHANEL => 4
      )
    port map(

      clk_200m => clk_200m,
      clk_100m => clk_100m,
      clk_10m  => clk_10m,
      reset    => global_rst or soft_rst,

      marker_a => tm_marker_a,

      soft_rst        => data_soft_rst,
      soft_path_rst   => data_soft_path_rst,
      soft_pack_start => data_soft_pack_start,

      adc_data_p => adc_data_p,
      adc_data_n => adc_data_n,
      adc_DCO_p  => adc_DCO_p,
      adc_DCO_n  => adc_DCO_n,
      adc_FCO_p  => adc_FCO_p,
      adc_FCO_n  => adc_FCO_n,

      ad_test_mode => ad_test_mode,
      board_number => dip_sw,
--      ctrl_rd_req  => ctrl_rd_req,
--      ctrl_rd_clk  => ctrl_rd_clk,
--      empty_ctrl   => empty_ctrl,
      chip_number  => chip_number,
      resync       => data_resync,
      data_type    => data_type,
      time_high    => time_high,
      time_mid     => time_mid,
      time_low     => time_low,
      time_usec    => time_usec,
      chip_cnt     => chip_cnt,
      --i
      --.fco_pattern                    =>      fco_pattern,
      dp_status    => dp_status,
      --
      adc_dco_done => adc_dco_done,
      data_aligned => data_aligned,
--      data_bus     => adc_data_bus

      data_fifo_rst        => data_fifo_rst,
      data_fifo_wr_clk     => data_fifo_wr_clk,
      data_fifo_wr_en      => data_fifo_wr_en,
      final_data_fifo_full => data_fifo_full,
--      data_fifo_almost_full        => data_fifo_almost_full,
      data_fifo_wr_din     => data_fifo_wr_din,

      adc_fclk_o => adc_fclk,

      data_lost_counter => data_lost_counter

      );

  adc_data_aligned <= data_aligned;


--  tm_clk_o <= clk_10m;
  twominus_scan : entity work.twominus_scan
    port map(
      clk        => tm_clk_o,
      rst        => global_rst or soft_rst,
      start_scan => tm_start_scan,
      reset_scan => tm_reset_scan,
      speak      => tm_speak_o,
      start      => tm_start,
      rst_out    => tm_reset
      );

  topmetal_working <= tm_speak_o;
  tm_speak         <= tm_speak_o;


  freq_div : entity work.freq_ctr_div
    generic map(
      N_CLK => N_CLK
      )
    port map(
      clk    => tm_clk_o & adc_fclk & data_fifo_wr_clk,
      clkdiv => clk_div
      );


  gen_test_clocks : entity work.gen_test_clocks
    port map(
      clk    => clk_200m,
      rst    => clk_200m_rst,
      clkout => tm_clk_o
      );

end rtl;
