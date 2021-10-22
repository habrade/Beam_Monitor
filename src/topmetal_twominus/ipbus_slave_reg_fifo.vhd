----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/16/2020 10:56:40 PM
-- Design Name: 
-- Module Name: ipbus_slave_reg_fifo - behv
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
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.ipbus.all;
use work.ipbus_reg_types.all;
use work.ipbus_reg_types_new.all;


entity ipbus_slave_reg_fifo is
  generic(
    SYNC_REG_ENA : boolean := false;
    N_STAT       : integer := 1;
    N_CTRL       : integer := 1;
    N_WFIFO      : integer := 1;
    N_RFIFO      : integer := 1
    );
  port(
    ipb_clk : in  std_logic;
    ipb_rst : in  std_logic;
    ipb_in  : in  ipb_wbus;
    ipb_out : out ipb_rbus;

    clk : in std_logic;
    rst : in std_logic;

    ctrl         : out ipb_reg_v(integer_max(N_CTRL, 1)-1 downto 0);
    ctrl_reg_stb : out std_logic_vector(integer_max(N_CTRL, 1)-1 downto 0);
    stat         : in  ipb_reg_v(integer_max(N_STAT, 1)-1 downto 0);
    stat_reg_stb : out std_logic_vector(integer_max(N_STAT, 1)-1 downto 0);

    -- for write FIFO
    wfifo_rst           : in  std_logic                                               := '0';
    wfifo_rd_clk        : in  std_logic_vector(integer_max(N_WFIFO, 1)-1 downto 0)    := (others => '0');
    wfifo_rd_en         : in  std_logic_vector(integer_max(N_WFIFO, 1)-1 downto 0)    := (others => '0');
    wfifo_valid         : out std_logic_vector(integer_max(N_WFIFO, 1)-1 downto 0)    := (others => '0');
    wfifo_empty         : out std_logic_vector(integer_max(N_WFIFO, 1)-1 downto 0)    := (others => '0');
    wfifo_prog_full     : out std_logic_vector(integer_max(N_WFIFO, 1)-1 downto 0)    := (others => '0');
    wfifo_wr_data_count : out std_logic_vector(18*integer_max(N_WFIFO, 1)-1 downto 0) := (others => '0');
    wfifo_rd_dout       : out std_logic_vector(32*integer_max(N_WFIFO, 1)-1 downto 0) := (others => '0');

    --for read  FIFO
    rfifo_rst         : in  std_logic                                               := '0';
    rfifo_wr_clk      : in  std_logic_vector(integer_max(N_RFIFO, 1)-1 downto 0)    := (others => '0');
    rfifo_wr_en       : in  std_logic_vector(integer_max(N_RFIFO, 1)-1 downto 0)    := (others => '0');
    rfifo_wr_din      : in  std_logic_vector(32*integer_max(N_RFIFO, 1)-1 downto 0) := (others => '0');
    rfifo_full        : out std_logic_vector(integer_max(N_RFIFO, 1)-1 downto 0)    := (others => '0');
    rfifo_almost_full : out std_logic_vector(integer_max(N_RFIFO, 1)-1 downto 0)    := (others => '0');

    debug : out std_logic_vector(N_WFIFO+N_RFIFO+7 downto 0)
    );
end ipbus_slave_reg_fifo;

architecture behv of ipbus_slave_reg_fifo is

  constant REG_NSLV : integer  := reg_slave_num(N_STAT, N_CTRL);
  constant NSLV     : positive := REG_NSLV+N_WFIFO+N_RFIFO;

  signal ipbw : ipb_wbus_array(NSLV-1 downto 0);
  signal ipbr : ipb_rbus_array(NSLV-1 downto 0);

  signal wfifo_dout : ipb_reg_v(N_WFIFO - 1 downto 0);
  signal rfifo_din  : ipb_reg_v(N_RFIFO - 1 downto 0);

  signal rst_r                : std_logic;
  signal rst_wfifo, rst_rfifo : std_logic;

begin

  rst_r     <= ipb_rst or rst;
  rst_wfifo <= ipb_rst or wfifo_rst;
  rst_rfifo <= ipb_rst or rfifo_rst;

  inst_device_fabric : entity work.ipbus_fabric_inside_device
    generic map(
      N_CTRL  => N_CTRL,                --the control register number
      N_STAT  => N_STAT,                --the status register number
      N_WFIFO => N_WFIFO,
      N_RFIFO => N_RFIFO
      )
    port map(
      ipb_in          => ipb_in,
      ipb_out         => ipb_out,
      ipb_to_slaves   => ipbw,
      ipb_from_slaves => ipbr,
      debug           => debug(7 downto 0)
      );


  gen_reg : if REG_NSLV = 1 generate
    reg_gen_0 : if SYNC_REG_ENA = true generate
      inst_ipbus_slave_0 : entity work.ipbus_ctrlreg_v
        generic map(
          N_CTRL     => N_CTRL,
          N_STAT     => N_STAT,
          SWAP_ORDER => true
          )
        port map(
          clk       => ipb_clk,
          reset     => rst_r,
          ipbus_in  => ipbw(0),
          ipbus_out => ipbr(0),
          d         => stat,
          q         => ctrl,
          stb       => ctrl_reg_stb
          );
    end generate;

    reg_gen_1 : if SYNC_REG_ENA = false generate
      inst_ipbus_slave_1 : entity work.ipbus_syncreg_v
        generic map(
          N_CTRL     => N_CTRL,
          N_STAT     => N_STAT,
          SWAP_ORDER => true
          )
        port map (
          clk     => ipb_clk,
          rst     => rst_r,
          ipb_in  => ipbw(0),
          ipb_out => ipbr(0),
          slv_clk => clk,
          d       => stat,
          q       => ctrl,
          stb     => ctrl_reg_stb(N_CTRL-1 downto 0),
          rstb    => stat_reg_stb(N_STAT-1 downto 0)
          );
    end generate;
  end generate;

  wfifo : if N_WFIFO > 0 generate
    wfifo_gen : for i in N_WFIFO-1 downto 0 generate
      wfifo_i : entity work.ipbus_write_fifo
        port map(
          clk       => ipb_clk,
          reset     => rst_wfifo,
          ipbus_in  => ipbw(REG_NSLV+i),
          ipbus_out => ipbr(REG_NSLV+i),

          wfifo_rd_clk        => wfifo_rd_clk(i),
          wfifo_rd_en         => wfifo_rd_en(i),
          wfifo_valid         => wfifo_valid(i),
          wfifo_empty         => wfifo_empty(i),
          wfifo_prog_full     => wfifo_prog_full(i),
          wfifo_wr_data_count => wfifo_wr_data_count(18*(i+1)-1 downto 18*i),
          wfifo_rd_dout       => wfifo_rd_dout(32*(i+1)-1 downto 32*i),
          debug               => debug(i+8)
          );
    end generate;
  end generate;

  rfifo : if N_RFIFO > 0 generate
    rfifo_gen : for i in N_RFIFO-1 downto 0 generate
      rfifo_i : entity work.ipbus_read_fifo
        port map(
          clk       => ipb_clk,
          reset     => rst_rfifo,
          ipbus_in  => ipbw(REG_NSLV+N_WFIFO+i),
          ipbus_out => ipbr(REG_NSLV+N_WFIFO+i),

          rfifo_wr_clk      => rfifo_wr_clk(i),
          rfifo_wr_en       => rfifo_wr_en(i),
          rfifo_full        => rfifo_full(i),
          rfifo_almost_full => rfifo_almost_full(i),
          rfifo_wr_din      => rfifo_wr_din(32*(i+1)-1 downto 32*i),
          debug             => debug(i+N_WFIFO+8)
          );
    end generate;
  end generate;



end behv;
