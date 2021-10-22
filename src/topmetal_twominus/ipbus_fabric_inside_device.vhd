----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/23/2020 06:41:46 PM
-- Design Name: 
-- Module Name: ipbus_fabric_inside_device - behv
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


-- The ipbus bus fabric, address select logic, data multiplexers
--
-- The address table is encoded in ipbus_addr_decode package - no need to change
-- anything in this file.
--
-- Dave Newbold, February 2011

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use work.ipbus.all;
use work.ipbus_reg_types.all;
use work.ipbus_reg_types_new.all;


entity ipbus_fabric_inside_device is
  generic(
    N_CTRL  : integer := 1;             --the control register number ;
    N_STAT  : integer := 1;             --the status register number
    N_WFIFO : integer := 1;
    N_RFIFO : integer := 1
    );
  port(
    ipb_in          : in  ipb_wbus;
    ipb_out         : out ipb_rbus;
    ipb_to_slaves   : out ipb_wbus_array(reg_slave_num(N_CTRL, N_STAT)+N_WFIFO+N_RFIFO-1 downto 0);
    ipb_from_slaves : in  ipb_rbus_array(reg_slave_num(N_CTRL, N_STAT)+N_WFIFO+N_RFIFO-1 downto 0);
    debug           : out std_logic_vector(7 downto 0)
    );

end ipbus_fabric_inside_device;

architecture behv of ipbus_fabric_inside_device is

  constant REG_SLV_NUM : integer := reg_slave_num(N_CTRL, N_STAT);
  constant NSLV        : integer := REG_SLV_NUM+N_WFIFO+N_RFIFO;

  constant MAX_ADDR_NUM : integer := max_port_addr_width(N_CTRL, N_STAT, N_WFIFO, N_RFIFO);

  signal ipb_reg_strobe   : std_logic;
  signal ipb_wfifo_strobe : std_logic_vector(N_WFIFO-1 downto 0);
  signal ipb_rfifo_strobe : std_logic_vector(N_RFIFO-1 downto 0);


  signal sel                : integer := 99;
  signal ored_ack, ored_err : std_logic_vector(NSLV downto 0);
  signal qstrobe            : std_logic;

  --Debug
  attribute mark_debug        : string;
  attribute mark_debug of sel : signal is "false";

begin

  ored_ack(NSLV) <= '0';
  ored_err(NSLV) <= '0';
  qstrobe        <= ipb_in.ipb_strobe;


  busgen : for i in NSLV-1 downto 0 generate
  begin
    ipb_to_slaves(i).ipb_addr   <= ipb_in.ipb_addr;
    ipb_to_slaves(i).ipb_wdata  <= ipb_in.ipb_wdata;
    ipb_to_slaves(i).ipb_write  <= ipb_in.ipb_write;
    ipb_to_slaves(i).ipb_strobe <= qstrobe when sel = i else '0';
    ored_ack(i)                 <= ored_ack(i+1) or ipb_from_slaves(i).ipb_ack;
    ored_err(i)                 <= ored_err(i+1) or ipb_from_slaves(i).ipb_err;
  end generate;

--    ipb_out.ipb_rdata <= ipb_from_slaves(sel).ipb_rdata when sel /= 99 else (others => '0');
  ipb_out.ipb_rdata <= ipb_from_slaves(sel).ipb_rdata when sel < NSLV else (others => '0');
  ipb_out.ipb_ack   <= ored_ack(0);
  ipb_out.ipb_err   <= ored_err(0);

  -- set sel
  process(ipb_in.ipb_addr)
  begin
    if ipb_in.ipb_addr(MAX_ADDR_NUM-1) = '0' and REG_SLV_NUM = 1 then
      sel <= 0;
    elsif REG_SLV_NUM = 0 then
      sel <= to_integer(unsigned(ipb_in.ipb_addr(MAX_ADDR_NUM-1 downto 2)));
    elsif ipb_in.ipb_addr(MAX_ADDR_NUM-1) = '1' and (N_WFIFO > 0 or N_RFIFO > 0) then
      sel <= to_integer(unsigned(ipb_in.ipb_addr(MAX_ADDR_NUM-2 downto 2))) + REG_SLV_NUM;
    else
      sel <= 99;
    end if;
  end process;

  debug <= std_logic_vector(to_unsigned(sel, 8));

end behv;

