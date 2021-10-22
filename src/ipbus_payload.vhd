library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.ipbus.all;
use work.ipbus_reg_types.all;
use work.ipbus_decode_payload.all;

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

    -- AD9512
    AD9512_CLK  : in  std_logic;
    AD9512_RST  : in  std_logic;
    AD9512_BUSY : in  std_logic;
    AD9512_WE   : out std_logic;
    AD9512_DATA : out std_logic_vector(31 downto 0);

    -- Two minus
    tm_start_scan : out std_logic;
    tm_reset_scan : out std_logic;
    
    ad9252_soft_rst : out std_logic;
    ad9252_soft_path_rst : out std_logic;
    ad9252_soft_pack_start : out std_logic;
    ad9252_busy : in std_logic;
    

		resync: out std_logic;
		data_type:  out std_logic_vector(15 downto 0);
		time_high: out std_logic_vector(15 downto 0);
		time_mid: out std_logic_vector(15 downto 0);
		time_low: out std_logic_vector(15 downto 0);
		time_usec:  out std_logic_vector(31 downto 0);
		chip_cnt:  out std_logic_vector(15 downto 0);

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

    -- SPI Master
    ss   : out std_logic_vector(N_SS - 1 downto 0);
    mosi : out std_logic;
    miso : in  std_logic;
    sclk : out std_logic;

    spi_trans_end : out std_logic
    -- DEBUG

    );

end ipbus_payload;

architecture rtl of ipbus_payload is

  signal ipbw : ipb_wbus_array(N_SLAVES - 1 downto 0);
  signal ipbr : ipb_rbus_array(N_SLAVES - 1 downto 0);


  signal spi_rst  : std_logic;          -- from ipbus control module
  signal rst_spi  : std_logic;          -- to SPI module
  signal spi_busy : std_logic;

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

      clk => AD9512_CLK,
      rst => AD9512_RST,

      AD9512_BUSY => AD9512_BUSY,
      AD9512_WE   => AD9512_WE,
      AD9512_DATA => AD9512_DATA
      );


  rst_spi <= spi_rst or ipb_rst;
  slave2 : entity work.ipbus_spi
    generic map(
      N_SS => N_SS
      )
    port map(
      clk           => ipb_clk,
      rst           => rst_spi,
      ipb_in        => ipbw(N_SLV_SPI),
      ipb_out       => ipbr(N_SLV_SPI),
      spi_busy      => spi_busy,
      spi_trans_end => spi_trans_end,
      ss            => ss,
      mosi          => mosi,
      miso          => miso,
      sclk          => sclk
      );


  slave3 : entity work.ipbus_twominus_device
    port map(
      ipb_clk => ipb_clk,
      ipb_rst => ipb_rst,
      ipb_in  => ipbw(N_SLV_TWOMINUS),
      ipb_out => ipbr(N_SLV_TWOMINUS),

      clk => clk,
      rst => rst,

      spi_rst  => spi_rst,
      spi_busy => spi_busy,

      -- Two minus
      start_scan => tm_start_scan,
      reset_scan => tm_reset_scan,
      
      -- ad9252
     	ad9252_soft_rst				=>	ad9252_soft_rst, 
			ad9252_soft_path_rst 		=>		ad9252_soft_path_rst,
			ad9252_soft_pack_start	=>		ad9252_soft_pack_start, 

						ad9252_busy	=>		ad9252_busy, 

			resync	=>		resync, 
      data_type            => data_type,
      time_high            => time_high,
      time_mid            => time_mid,
      time_low            => time_low,
      time_usec            => time_usec,
      chip_cnt            => chip_cnt,
    
			

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
      data_fifo_wr_din             => data_fifo_wr_din
      );

end rtl;

