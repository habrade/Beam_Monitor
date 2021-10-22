-------------------------------------------------------------------------------
-- Title      : twominus device
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ipbus_twominus_device.vhd
-- Author     : sdong  <sdong@sdong-ubuntu>
-- Company    : 
-- Created    : 2021-10-22
-- Last update: 2021-10-22
-- Platform   : 
-- Standard   : VHDL2008
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.ipbus.all;
use work.ipbus_reg_types.all;

use work.twominus_defines.all;

entity ipbus_twominus_device is
  port(
    ipb_clk : in  std_logic;
    ipb_rst : in  std_logic;
    ipb_in  : in  ipb_wbus;
    ipb_out : out ipb_rbus;

    clk : in std_logic;
    rst : in std_logic;

    -- SPI Reset
    spi_rst  : out std_logic;
    spi_busy : in  std_logic;

    -- Chip config fifo
    start_scan : out std_logic;
    reset_scan : out std_logic;

    ad9252_soft_rst        : out std_logic;
    ad9252_soft_path_rst   : out std_logic;
    ad9252_soft_pack_start : out std_logic;

    ad9252_busy : in std_logic;

    resync    : out std_logic;
    data_type : out std_logic_vector(15 downto 0);
    time_high : out std_logic_vector(15 downto 0);
    time_mid  : out std_logic_vector(15 downto 0);
    time_low  : out std_logic_vector(15 downto 0);
    time_usec : out std_logic_vector(31 downto 0);
    chip_cnt  : out std_logic_vector(15 downto 0);


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
    data_fifo_almost_full        : out std_logic
    );
end ipbus_twominus_device;

architecture behv of ipbus_twominus_device is
  -- IPbus reg
  constant SYNC_REG_ENA               : boolean := false;
  constant N_STAT                     : integer := 2;
  constant N_CTRL                     : integer := 5;
  constant N_WFIFO                    : integer := 0;
  constant N_RFIFO                    : integer := 1;
  signal stat                         : ipb_reg_v(N_STAT-1 downto 0);
  signal ctrl                         : ipb_reg_v(N_CTRL-1 downto 0);
  signal ctrl_reg_stb, ctrl_reg_stb_r : std_logic_vector(N_CTRL-1 downto 0);
  signal stat_reg_stb, stat_reg_stb_r : std_logic_vector(N_STAT-1 downto 0);

  --IPbus slave fifo
  signal cfg_fifo_rst : std_logic;

  signal rfifo_wr_din                                             : std_logic_vector(32*integer_max(N_RFIFO, 1)-1 downto 0);
  signal rfifo_wr_clk, rfifo_wr_en, rfifo_full, rfifo_almost_full : std_logic_vector(integer_max(N_RFIFO, 1)-1 downto 0);

  signal wfifo_rd_clk, wfifo_rd_en, wfifo_valid, wfifo_empty, wfifo_prog_full : std_logic_vector(integer_max(N_WFIFO, 1)-1 downto 0);
  signal wfifo_wr_data_count                                                  : std_logic_vector(18*integer_max(N_WFIFO, 1)-1 downto 0);

  signal wfifo_rd_dout : std_logic_vector(32*integer_max(N_WFIFO, 1)-1 downto 0);

  -- chip
  signal start_scan_tmp : std_logic;
  signal reset_scan_tmp : std_logic;

  -- ad9252
  signal ad9252_soft_rst_tmp        : std_logic;
  signal ad9252_soft_path_rst_tmp   : std_logic;
  signal ad9252_soft_pack_start_tmp : std_logic;

  signal resync_tmp : std_logic;

  signal data_type_tmp : std_logic_vector(15 downto 0);
  signal time_high_tmp : std_logic_vector(15 downto 0);
  signal time_mid_tmp  : std_logic_vector(15 downto 0);
  signal time_low_tmp  : std_logic_vector(15 downto 0);
  signal time_usec_tmp : std_logic_vector(31 downto 0);
  signal chip_cnt_tmp  : std_logic_vector(15 downto 0);


  signal rst_rfifo : std_logic := '0';

  -- IPbus drp
--  signal ram_rst : std_logic_vector(N_FIFO-1 downto 0);

  -- DEBUG
  attribute mark_debug : string;
--  attribute mark_debug of load_soft       : signal is "true";

begin
  --------------------------------------------------------------
  -- fifo signals and registers
  --------------------------------------------------------------

  wfifo_rd_clk(WFIFO_ADDR_SLOW_CTRL_CMD) <= slow_ctrl_fifo_rd_clk;
  wfifo_rd_en(WFIFO_ADDR_SLOW_CTRL_CMD)  <= slow_ctrl_fifo_rd_en;
  slow_ctrl_fifo_valid                   <= wfifo_valid(WFIFO_ADDR_SLOW_CTRL_CMD);
  slow_ctrl_fifo_empty                   <= wfifo_empty(WFIFO_ADDR_SLOW_CTRL_CMD);
  slow_ctrl_fifo_prog_full               <= wfifo_prog_full(WFIFO_ADDR_SLOW_CTRL_CMD);
  slow_ctrl_fifo_wr_data_count           <= wfifo_wr_data_count((WFIFO_ADDR_SLOW_CTRL_CMD+1)*18-1 downto WFIFO_ADDR_SLOW_CTRL_CMD*18);
  slow_ctrl_fifo_rd_dout                 <= wfifo_rd_dout((WFIFO_ADDR_SLOW_CTRL_CMD+1)*32-1 downto WFIFO_ADDR_SLOW_CTRL_CMD*32);

  rfifo_wr_clk(RFIFO_ADDR_DATA_FIFO)                                         <= data_fifo_wr_clk;
  rfifo_wr_en(RFIFO_ADDR_DATA_FIFO)                                          <= data_fifo_wr_en;
  data_fifo_full                                                             <= rfifo_full(RFIFO_ADDR_DATA_FIFO);
  data_fifo_almost_full                                                      <= rfifo_almost_full(RFIFO_ADDR_DATA_FIFO);
  rfifo_wr_din((RFIFO_ADDR_DATA_FIFO+1)*32-1 downto RFIFO_ADDR_DATA_FIFO*32) <= data_fifo_wr_din;

  ipbus_slave_reg_fifo : entity work.ipbus_slave_reg_fifo
    generic map(
      SYNC_REG_ENA => SYNC_REG_ENA,
      N_STAT       => N_STAT,
      N_CTRL       => N_CTRL,
      N_WFIFO      => N_WFIFO,
      N_RFIFO      => N_RFIFO
      )
    port map(

      ipb_clk => ipb_clk,
      ipb_rst => ipb_rst,
      ipb_in  => ipb_in,
      ipb_out => ipb_out,

      clk => clk,
      rst => rst,

      -- control/state registers
      ctrl         => ctrl,
      ctrl_reg_stb => ctrl_reg_stb,
      stat         => stat,
      stat_reg_stb => open,

      -- FIFO
      wfifo_rst           => cfg_fifo_rst,
      wfifo_rd_clk        => wfifo_rd_clk,
      wfifo_rd_en         => wfifo_rd_en,
      wfifo_valid         => wfifo_valid,
      wfifo_empty         => wfifo_empty,
      wfifo_prog_full     => wfifo_prog_full,
      wfifo_wr_data_count => wfifo_wr_data_count,
      wfifo_rd_dout       => wfifo_rd_dout,
      rfifo_rst           => data_fifo_rst or rst_rfifo,
      rfifo_wr_clk        => rfifo_wr_clk,
      rfifo_wr_en         => rfifo_wr_en,
      rfifo_full          => rfifo_full,
      rfifo_almost_full   => rfifo_almost_full,
      rfifo_wr_din        => rfifo_wr_din
      );

  -- control
  process(clk)
  begin
    if rising_edge(clk) then
      start_scan_tmp             <= ctrl(0)(0);
      reset_scan_tmp             <= ctrl(0)(1);
      ad9252_soft_rst_tmp        <= ctrl(0)(2);
      ad9252_soft_path_rst_tmp   <= ctrl(0)(3);
      ad9252_soft_pack_start_tmp <= ctrl(0)(4);

      resync_tmp <= ctrl(0)(5);

      data_type_tmp <= ctrl(1)(15 downto 0);
      time_high_tmp <= ctrl(1)(31 downto 16);
      time_mid_tmp <= ctrl(2)(15 downto 0);
      time_low_tmp <= ctrl(2)(31 downto 16);
      time_usec_tmp <= ctrl(3);
      chip_cnt_tmp <= ctrl(4)(15 downto 0);


      ctrl_reg_stb_r <= ctrl_reg_stb;
      stat_reg_stb_r <= stat_reg_stb;
    end if;
  end process;


  sync_ctrl_signals : process(clk)
  begin
    if rising_edge(clk) then

      if ctrl_reg_stb_r(0) = '1' then
        start_scan             <= start_scan_tmp;
        reset_scan             <= reset_scan_tmp;
        ad9252_soft_rst        <= ad9252_soft_rst_tmp;
        ad9252_soft_path_rst   <= ad9252_soft_path_rst_tmp;
        ad9252_soft_pack_start <= ad9252_soft_pack_start_tmp;
        resync                 <= resync_tmp;
        data_type              <= data_type_tmp;
        time_high              <= time_high_tmp;
        time_mid               <= time_mid_tmp;
        time_low               <= time_low_tmp;
        time_usec              <= time_usec_tmp;
        chip_cnt               <= chip_cnt_tmp;
      else
        start_scan <= '0';
        reset_scan <= '0';
        resync     <= '0';
        data_type <= (others => '0');
        time_high <= (others => '0');
        time_mid  <= (others => '0');
        time_low  <= (others => '0');
        time_usec <= (others => '0');
        chip_cnt  <= (others => '0');
      end if;
    end if;
  end process;


  -- status
  process(clk)
  begin
    if rising_edge(clk) then
      stat(0)(0) <= spi_busy;
      stat(0)(1) <= ad9252_busy;

      stat(1)(0)           <= wfifo_empty(WFIFO_ADDR_SLOW_CTRL_CMD);
      stat(1)(1)           <= wfifo_prog_full(WFIFO_ADDR_SLOW_CTRL_CMD);
      stat(1)(19 downto 2) <= wfifo_wr_data_count((WFIFO_ADDR_SLOW_CTRL_CMD+1)*18-1 downto WFIFO_ADDR_SLOW_CTRL_CMD*18);

    end if;
  end process;


end behv;
