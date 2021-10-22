-- Address decode logic for ipbus fabric
-- 
-- This file has been AUTOGENERATED from the address table - do not hand edit
-- 
-- We assume the synthesis tool is clever enough to recognise exclusive conditions
-- in the if statement.
-- 
-- Dave Newbold, February 2011

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

package ipbus_decode_payload is

  constant IPBUS_SEL_WIDTH        :    positive := 3;  -- Should be enough for now?
  subtype ipbus_sel_t is std_logic_vector(IPBUS_SEL_WIDTH - 1 downto 0);
  function ipbus_sel_payload(addr : in std_logic_vector(31 downto 0)) return ipbus_sel_t;

-- START automatically  generated VHDL the Thu May  3 15:36:57 2018 
  constant N_SLV_GLOBAL   : integer := 0;
  constant N_SLV_AD9512   : integer := 1;
  constant N_SLV_SPI      : integer := 2;
  constant N_SLV_TWOMINUS : integer := 3;
  constant N_SLAVES       : integer := 4;
-- END automatically generated VHDL


end ipbus_decode_payload;

package body ipbus_decode_payload is

  function ipbus_sel_payload(addr : in std_logic_vector(31 downto 0)) return ipbus_sel_t is
    variable sel : ipbus_sel_t;
  begin

    if std_match(addr, "000-----------------------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_GLOBAL, IPBUS_SEL_WIDTH));
    elsif std_match(addr, "001-----------------------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_AD9512, IPBUS_SEL_WIDTH));
    elsif std_match(addr, "010-----------------------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_SPI, IPBUS_SEL_WIDTH));
    elsif std_match(addr, "011-----------------------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_TWOMINUS, IPBUS_SEL_WIDTH));
    else
      sel := ipbus_sel_t(to_unsigned(N_SLAVES, IPBUS_SEL_WIDTH));
    end if;

    return sel;

  end function ipbus_sel_payload;

end ipbus_decode_payload;

