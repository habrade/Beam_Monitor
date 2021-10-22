----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/09/2020 11:31:01 PM
-- Design Name: 
-- Module Name: ipbus_global_device - behv
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


entity ipbus_global_device is
  port (
    ipb_clk  : in  std_logic;
    ipb_rst  : in  std_logic;
    ipb_in   : in  ipb_wbus;
    ipb_out  : out ipb_rbus;
    -- Global
    nuke     : out std_logic;
    soft_rst : out std_logic
    );

end ipbus_global_device;

architecture behv of ipbus_global_device is

  constant N_STAT     : integer := 1;
  constant N_CTRL     : integer := 1;
  signal stat         : ipb_reg_v(N_STAT-1 downto 0);
  signal ctrl         : ipb_reg_v(N_CTRL-1 downto 0);
  signal ctrl_reg_stb : std_logic_vector(N_CTRL - 1 downto 0);


begin

  inst_ipbus_slave : entity work.ipbus_ctrlreg_v
    generic map(
      N_CTRL     => N_STAT,
      N_STAT     => N_CTRL,
      SWAP_ORDER => true
      )
    port map(
      clk       => ipb_clk,
      reset     => ipb_rst,
      ipbus_in  => ipb_in,
      ipbus_out => ipb_out,
      d         => stat,
      q         => ctrl,
      stb       => ctrl_reg_stb
      );


  sync_ctrl_signals : process(ipb_clk)
  begin
    if rising_edge(ipb_clk) then
      if ctrl_reg_stb(0) = '1' then
        nuke     <= ctrl(0)(0);
        soft_rst <= ctrl(0)(1);
      else
        nuke     <= '0';
        soft_rst <= '0';
      end if;
    end if;
  end process;

end behv;
