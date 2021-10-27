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
--  dac_config_done  : out std_logic;
  ad_9252_done     : out std_logic;
  ad_9512_done     : out std_logic;
  topmetal_working : out std_logic;

  -- AD9512
--  ad9512_sclk     : out std_logic;
--  ad9512_sdio     : out std_logic;
--  ad9512_csb      : out std_logic;
  ad9512_function : out std_logic;
--  -- SPI Master
  ss   : out std_logic_vector(0 downto 0);
  mosi : out std_logic;
  miso : in  std_logic;
  sclk : out std_logic
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


  -- ad9252
  signal ad9252_soft_rst        : std_logic;
  signal ad9252_soft_path_rst   : std_logic;
  signal ad9252_soft_pack_start : std_logic;

  signal ad9252_resync : std_logic;
  signal ad_test_mode  : std_logic;
  signal ad9252_busy   : std_logic;

  -- ad9252 ipbus
  signal device_rst    : std_logic;
  signal ad9252_start  : std_logic;
  signal pulse_ad      : std_logic;
  signal ad9252_switch : std_logic_vector(2 downto 0);
  signal data_aligned  : std_logic;
  signal adc_restart   : std_logic;

  signal resync : std_logic;

  signal data_type : std_logic_vector(15 downto 0);
  signal time_high : std_logic_vector(15 downto 0);
  signal time_mid  : std_logic_vector(15 downto 0);
  signal time_low  : std_logic_vector(15 downto 0);
  signal time_usec : std_logic_vector(31 downto 0);
  signal chip_cnt  : std_logic_vector(15 downto 0);

  signal dp_status    : std_logic_vector(8 downto 0);
  signal adc_dco_done : std_logic;

  -- not used
  signal current_s : std_logic_vector(4 downto 0);



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
  
  constant N_SS: positive := 1;   -- Number of SPI Slaves


  -- DEBUG
  attribute mark_debug : string;


	signal adc_fclk: std_logic;

  signal clk_div : std_logic_vector(N_CLK -1 downto 0);


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

--  OBUF_RX_CLK : OBUF
--    generic map (
--      DRIVE      => 12,
--      IOSTANDARD => "DEFAULT",
--      SLEW       => "SLOW")
--    port map (
--      O => RX_FPGA,      -- Buffer output (connect directly to top-level port)
--      I => rx_fpga_tmp2                 -- Buffer input 
--      );

--  BUFGMUX_CTRL_inst : BUFGMUX_CTRL
--    port map (
--      O  => rx_fpga_tmp1,               -- 1-bit output: Clock output
--      I0 => clk_fpga,                   -- 1-bit input: Clock input (S=0)
--      I1 => clk_sys,                    -- 1-bit input: Clock input (S=1)
--      S  => sel_chip_clk                -- 1-bit input: Clock select
--      );

--  BUFGCE_inst : BUFGCE
--    port map (
--      O  => rx_fpga_tmp2,               -- 1-bit output: Clock output
--      CE => rx_fpga_oe,    -- 1-bit input: Clock enable input for I0
--      I  => rx_fpga_tmp1                -- 1-bit input: Primary clock
--      );

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
      clk => clk_100m,
      rst => clk_100m_rst,

      -- Global
      nuke     => nuke,
      soft_rst => soft_rst,


      -- twominus
      tm_start_scan => tm_start_scan,
      tm_reset_scan => tm_reset_scan,

      -- ad9252
      ad9252_soft_rst        => ad9252_soft_rst,
      ad9252_soft_path_rst   => ad9252_soft_path_rst,
      ad9252_soft_pack_start => ad9252_soft_pack_start,

      ad9252_busy => ad9252_busy,

      resync    => resync,
      data_type => data_type,
      time_high => time_high,
      time_mid  => time_mid,
      time_low  => time_low,
      time_usec => time_usec,
      chip_cnt  => chip_cnt,

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
      
--	AD9512_BUSY <= not AD9512_RDY;
--  ad9512_refresh : entity work.ad9512_refresh
--    port map(
--      clk => clk_200m,
--      rst => global_rst or clk_200m_rst,

--      din     => AD9512_DATA,
--      din_vld => AD9512_WE,
--      din_rdy => AD9512_RDY,

--      ad9512_sclk => ad9512_sclk,
--      ad9512_sdio => ad9512_sdio,
--      ad9512_csb  => ad9512_csb
--      );

  ad9252_control : entity work.ad9252_control
    port map(
      reset            => device_rst,
      start            => ad9252_start,
      clk_spi          => clk_10m,
      ch               => ch,
--      pulse_da         => '0',
      pulse_ad         => pulse_ad,
      adc_restart      => adc_restart,
--      dac_datain       => open,
      switch           => ad9252_switch,
      --adc_datain                                       => config_reg(47 downto 32],
      data_aligned     => data_aligned,
      ad_csb           => ad9252_csb,
--      da_sync          => da_sync,
--      da_sclk          => da_sclk,
--      da_done          => dac_done,
--      da_sdata         => da_sdata,
      ad_sclk          => ad9252_sclk,
      ad_sdio          => ad9252_sdio,
      spi_9252_done    => ad_9252_done,
      ad_test_cfg_done => ad_test_mode,

      state_9_1 => current_s,

      busy_9252 => ad9252_busy
      );


  tm_marker_a <= (tm_marker & tm_marker & tm_marker & tm_marker);

  ad_data_module : entity work.ad_data_module
    generic map(
      ADC_CHANEL => 4
      )
    port map(

      clk_200m => clk_200m,
      clk_100m => clk_100m,
      clk_10m  => clk_10m,
      reset    => global_rst,

      marker_a => tm_marker_a,

      soft_rst        => ad9252_soft_rst,
      soft_path_rst   => ad9252_soft_path_rst,
      soft_pack_start => ad9252_soft_pack_start,

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
      resync       => ad9252_resync,
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

      data_fifo_rst    => data_fifo_rst,
      data_fifo_wr_clk => data_fifo_wr_clk,
      data_fifo_wr_en  => data_fifo_wr_en,
--      data_fifo_full               => data_fifo_full,
--      data_fifo_almost_full        => data_fifo_almost_full,
      data_fifo_wr_din => data_fifo_wr_din,
      
      adc_fclk_o => adc_fclk

      );

  adc_data_aligned <= data_aligned;


	tm_clk_o <= clk_10m;
  twominus_scan : entity work.twominus_scan
    port map(
      clk        => tm_clk_o,
      rst        => global_rst,
      start_scan => tm_start_scan,
      reset_scan => tm_reset_scan,
      speak      => tm_speak_o,
      start      => tm_start,
      rst_out    => tm_reset
      );

  topmetal_working <= tm_speak_o;


  freq_div : entity work.freq_ctr_div
    generic map(
      N_CLK => N_CLK
      )
    port map(
      clk    => tm_clk_o & adc_fclk & data_fifo_wr_clk,
      clkdiv => clk_div
      );


end rtl;
