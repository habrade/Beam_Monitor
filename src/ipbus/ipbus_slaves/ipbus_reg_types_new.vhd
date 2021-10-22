library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.ipbus_reg_types.all;

package ipbus_reg_types_new is

--      type ipb_reg_v is array(natural range <>) of std_logic_vector(31 downto 0);

-- Useful functions - compile-time only

--      function calc_width(n: integer) return integer;
--      function integer_max(left, right: integer) return integer;
  function reg_slave_num(control, status                                        : integer) return integer;
  function max_port_addr_width(ctrl_reg_num, stat_reg_num, wfifo_num, rfifo_num : integer) return integer;


end package ipbus_reg_types_new;

package body ipbus_reg_types_new is

--      function calc_width(n: integer) return integer is
--      begin
--              for i in 0 to 31 loop
--                      if(2 ** i >= n) then
--                              return(i);
--                      end if;
--              end loop;
--              return(0);
--      end function calc_width;

--      function integer_max(left, right: integer) return integer is
--    begin
--    if left > right then
--        return left;
--    else
--        return right;
--    end if;
--    end function integer_max;

  function reg_slave_num(control, status : integer) return integer is
  begin
    if (control > 0 or status > 0) then
      return 1;
    else
      return 0;
    end if;
  end function reg_slave_num;

  function max_port_addr_width(ctrl_reg_num, stat_reg_num, wfifo_num, rfifo_num : integer) return integer is
    variable reg_address_width, fifo_address_width : integer := 0;
  begin
    reg_address_width  := calc_width(integer_max(ctrl_reg_num, stat_reg_num))+1;
    fifo_address_width := calc_width(wfifo_num + rfifo_num)+2;
    if ctrl_reg_num = 0 and stat_reg_num = 0 then
      return fifo_address_width;
    else
      return integer_max(reg_address_width, fifo_address_width)+1;
    end if;
  end function max_port_addr_width;

end package body ipbus_reg_types_new;

