-------------------------------------------------------------------------------
-- Title      : gen_test_clocks
-- Project    : 
-------------------------------------------------------------------------------
-- File       : gen_test_clocks.vhd
-- Author     : cee-test  <cee@HulinDesk>
-- Company    : 
-- Created    : 2021-11-03
-- Last update: 2021-11-03
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2021 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2021-11-03  1.0      cee     Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity gen_test_clocks is
  port(
    clk    : in  std_logic;
    rst    : in  std_logic;
    clkout : out std_logic
    );
end entity;

architecture behv of gen_test_clocks is
  signal cnt : integer range 0 to 80 := 0;

begin

  process(all) 
  begin
    if rising_edge(clk) then
      if ?? rst then
        cnt    <= 0;
        clkout <= '0';
      else
        if cnt = 79 then
          cnt    <= 0;
          clkout <= not clkout;
        else
          cnt <= cnt + 1;
        end if;
      end if;
    end if;
  end process;

end behv;



