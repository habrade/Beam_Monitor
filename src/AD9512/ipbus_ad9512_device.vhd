-------------------------------------------------------------------------------
-- Title      : ad9512 config
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ipbus_ad9512_device.vhd
-- Author     : sdong  <sdong@sdong-ubuntu>
-- Company    : 
-- Created    : 2021-10-21
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
-- 2021-10-21  1.0      sdong   Created
-------------------------------------------------------------------------------


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

entity ipbus_ad9512_device is
  port (
    ipb_clk : in  std_logic;
    ipb_rst : in  std_logic;
    ipb_in  : in  ipb_wbus;
    ipb_out : out ipb_rbus;

    clk : in std_logic;
    rst : in std_logic;
    
    ad9512_function : out std_logic;

--    spi_busy : in  std_logic;
    spi_rst: out std_logic

    );
end ipbus_ad9512_device;



architecture behv of ipbus_ad9512_device is
  constant N_STAT       : integer := 1;
  constant N_CTRL       : integer := 1;
  constant SYNC_REG_ENA : boolean := false;

  constant REG_NSLV : integer  := reg_slave_num(N_STAT, N_CTRL);
  constant NSLV     : positive := REG_NSLV;

  signal stat         : ipb_reg_v(N_STAT-1 downto 0);
  signal ctrl         : ipb_reg_v(N_CTRL-1 downto 0);

  signal ctrl_reg_stb, ctrl_reg_stb_r : std_logic_vector(N_CTRL-1 downto 0);
  signal stat_reg_stb, stat_reg_stb_r : std_logic_vector(N_STAT-1 downto 0);

  signal rst_r : std_logic;
  
  signal ad9512_function_tmp : std_logic;
  signal spi_rst_tmp : std_logic;

begin

  rst_r <= ipb_rst or rst;

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
          ipbus_in  => ipb_in,
          ipbus_out => ipb_out,
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
          ipb_in  => ipb_in,
          ipb_out => ipb_out,
          slv_clk => clk,
          d       => stat,
          q       => ctrl,
          stb     => ctrl_reg_stb(N_CTRL-1 downto 0),
          rstb    => stat_reg_stb(N_STAT-1 downto 0)
          );
    end generate;
  end generate;


  process(clk)
  begin
    if rising_edge(clk) then
      spi_rst_tmp   <= ctrl(0)(0);
      ad9512_function_tmp   <= ctrl(0)(1);
      
			ctrl_reg_stb_r <= ctrl_reg_stb;
			stat_reg_stb_r <= stat_reg_stb;
    end if;
  end process;


  sync_ctrl_signals : process(clk)
  begin
    if rising_edge(clk) then

      if ?? ctrl_reg_stb_r(0) then
        spi_rst <= spi_rst_tmp;
        ad9512_function <= ad9512_function_tmp;
      else
        spi_rst <= '0';
        ad9512_function <= '1';
      end if;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      stat(0)(0) <= '0';
    end if;
  end process;


end behv;
