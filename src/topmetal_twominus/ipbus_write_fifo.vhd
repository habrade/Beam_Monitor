---------------------------------------------------------------------------------
-- Generic IPBus "write FIFO interface" slave V2.0
--
--
-- This design implements an slave interface to a write FIFO,which can transfer data from IPbus to slave.

-- Attention: 
-- The write FIFO is FWFT(first word fall through) FIFO, 
--   and the "More Accurate Data Counts" option has been set!

-- Default FIFO depth is 512, considering the MTU length of 1500
-- But we can draw the conclusion from the test that
--      the max write length  in one ethernet packet is 255 after separated by software!

-- If you want to change the depth of the inner FIFO, you SHOULD change WRFIFO_ADD_NUM and regenerate fwft_fifo_32_512 core!
-- 
-- Attention: all the operations to this slave will complete successfully from the view of the master, which means NO Time out state will happens.
--  for the situation of writing to a full FIFO, the extra data will be lost!
--  The number of  the successful write will be recorded in registers.
--
-- This design use 3 address
-- loc 0: WFIFO_DATA: write port
-- loc 1: WFIFO_LEN: data length can be writen to write fifo (read it before write operation if needed)
-- loc 2: WVALID_LEN: successful(valid) words from last read from this port (read after write operation if needed)
--
-- For WVALID_LEN, the format is:
-- bit 31: '1' : there are valid data in the previous operation, 
--         '0' : the previous operation has finished, but nothing was read from /write to FIFO
-- bit [8:0] : the number of the successfully transferred words
--
-- We can perform "SAFE" write operation in two methods:
-- 1. read the data length register at first, then start write based on the results
-- 2. do block write at first, then check if the data is valid
-- If the request/response is fast enough(all response will come in 255 ipbus clock cycle), the check of the register is not needed.
--
-- Junfeng Yang, <yangjf@ustc.edu.cn>   03/07/2015
--
-- Update:
--  07/09/2015: change the RVALID_LEN/WVALID_LEN to length from last read
--  30/09/2015: use component instant instead of "entity work." instant
--  17/11/2015: devide the write fifo and read fifo into two slaves for multiply instantiation.

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
--use work.ipbus_new.all;
use work.ipbus.all;
use work.ipbus_reg_types.all;
use work.ipbus_reg_types_new.all;

entity ipbus_write_fifo is
  port(
    clk       : in  std_logic;
    reset     : in  std_logic;
    ipbus_in  : in  ipb_wbus;
    ipbus_out : out ipb_rbus;

    -- write FIFO
    wfifo_rd_clk        : in  std_logic;
    wfifo_rd_en         : in  std_logic;
    wfifo_valid         : out std_logic;
    wfifo_empty         : out std_logic;
    wfifo_prog_full     : out std_logic;
    wfifo_wr_data_count : out std_logic_vector(17 downto 0);
    wfifo_rd_dout       : out std_logic_vector(31 downto 0);
    debug               : out std_logic
    );

end ipbus_write_fifo;

architecture rtl of ipbus_write_fifo is

  component fwft_fifo_32_512
    port (
      rst           : in  std_logic;
      wr_clk        : in  std_logic;
      rd_clk        : in  std_logic;
      din           : in  std_logic_vector(31 downto 0);
      wr_en         : in  std_logic;
      rd_en         : in  std_logic;
      dout          : out std_logic_vector(31 downto 0);
      full          : out std_logic;
      empty         : out std_logic;
      valid         : out std_logic;
      rd_data_count : out std_logic_vector(17 downto 0);
      wr_data_count : out std_logic_vector(17 downto 0);
      prog_full     : out std_logic;
      wr_rst_busy   : out std_logic;
      rd_rst_busy   : out std_logic
      );
  end component;

--  component fwft_fifo_32_512 is
--    port (
--      rst           : in  std_logic;
--      wr_clk        : in  std_logic;
--      rd_clk        : in  std_logic;
--      din           : in  std_logic_vector(31 downto 0);
--      wr_en         : in  std_logic;
--      rd_en         : in  std_logic;
--      dout          : out std_logic_vector(31 downto 0);
--      full          : out std_logic;
--      empty         : out std_logic;
--      valid         : out std_logic;
--      rd_data_count : out std_logic_vector(9 downto 0);
--      wr_data_count : out std_logic_vector(9 downto 0)
--      );
--  end component fwft_fifo_32_512;

--  attribute black_box : string;
--  attribute black_box of fifo_with_count: component is "yes";


  constant WRFIFO_ADD_NUM : natural := 17;  -- the depth of the write fifo is 2**WRFIFO_ADD_NUM

  constant DUMMY_DATA    : std_logic_vector(31 downto 0) := X"00000000";
  constant TIMEOUT_COUNT : integer                       := 32;

  signal ipb_wr_ack, wr_addr_match, rd_reg_ack : std_logic;
  signal wr_clk, wr_en, full                   : std_logic;
  signal wr_dout                               : std_logic_vector(31 downto 0);
  signal wr_data_count                         : std_logic_vector(WRFIFO_ADD_NUM downto 0);
                                                                         -- the address width for FWFT FIFO with "More Accurate Data Counts" option is WRFIFO_ADD_NUM+1 !        
  signal valid_wdata_count                     : unsigned(16 downto 0);  -- Acturally, Only 255 words will be used in IPBus software
  signal valid_wdata_en                        : std_logic;
  signal valid_wdata_port                      : std_logic_vector(31 downto 0);

  signal timeout                : unsigned(7 downto 0);
  signal dummy_ack, dummy_ack_b : std_logic;

  signal ipb_strobe_d, ipb_write_d : std_logic := '0';
  signal ipb_addr_d                : std_logic_vector(1 downto 0);

begin

  ipbus_out.ipb_ack <= ipb_wr_ack or rd_reg_ack or dummy_ack;
  ipbus_out.ipb_err <= '0';

  wr_clk        <= clk;
  wr_addr_match <= '1' when ipbus_in.ipb_addr(1 downto 0) = "00" else '0';
  ipb_wr_ack    <= (ipbus_in.ipb_strobe and ipbus_in.ipb_write and (not full)) and wr_addr_match and not dummy_ack;
  wr_en         <= ipb_wr_ack;
  wr_dout       <= ipbus_in.ipb_wdata;

  rd_reg_ack <= (ipbus_in.ipb_strobe and not ipbus_in.ipb_write) when ipbus_in.ipb_addr(1 downto 0) /= "00" else '0';

  process(clk)
  begin
    if rising_edge(clk) then
      ipb_strobe_d <= ipbus_in.ipb_strobe;
      ipb_write_d  <= ipbus_in.ipb_write;
      ipb_addr_d   <= ipbus_in.ipb_addr(1 downto 0);
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        valid_wdata_count <= (others => '0');
        valid_wdata_en    <= '0';
      elsif ipbus_in.ipb_strobe = '0' and ipb_strobe_d = '1' and ipb_write_d = '0' and ipb_addr_d = "10" then
        valid_wdata_en    <= '0';
        valid_wdata_count <= (others => '0');
      elsif ipb_wr_ack = '1' and dummy_ack = '0' then
        valid_wdata_en    <= '1';
        valid_wdata_count <= valid_wdata_count + 1;
      end if;
    end if;
  end process;


  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        valid_wdata_port <= X"00000000";
      elsif ipbus_in.ipb_strobe = '0' and ipb_strobe_d = '1' then
        if ipb_write_d = '1' then
          valid_wdata_port <= valid_wdata_en & std_logic_vector(to_unsigned(0, 31 - WRFIFO_ADD_NUM)) & std_logic_vector(valid_wdata_count);
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if ipbus_in.ipb_strobe = '0' or ipb_wr_ack = '1' or rd_reg_ack = '1' then
        timeout <= (others => '0');
      else
        if timeout /= TIMEOUT_COUNT then
          timeout <= timeout+1;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if timeout = TIMEOUT_COUNT then
        dummy_ack_b <= '1';
      else
        dummy_ack_b <= '0';
      end if;
    end if;
  end process;

  dummy_ack <= dummy_ack_b and ipbus_in.ipb_strobe;



  ipbus_out.ipb_rdata <= std_logic_vector(to_unsigned(0, 31 - WRFIFO_ADD_NUM)) & wr_data_count(WRFIFO_ADD_NUM) & not wr_data_count(WRFIFO_ADD_NUM-1 downto 0)
                         when ipbus_in.ipb_addr(1 downto 0) = "01"
                         else valid_wdata_port when ipbus_in.ipb_addr(1 downto 0) = "10"
                         else DUMMY_DATA       when dummy_ack = '1'
                         else X"00000000";

  debug <= full;

  fifo_down : fwft_fifo_32_512
    port map(
      rst           => reset,
      wr_clk        => wr_clk,
      rd_clk        => wfifo_rd_clk,
      din           => wr_dout,
      wr_en         => wr_en,
      rd_en         => wfifo_rd_en,
      dout          => wfifo_rd_dout,
      full          => full,
      empty         => wfifo_empty,
      valid         => wfifo_valid,
      prog_full     => wfifo_prog_full,
      wr_data_count => wfifo_wr_data_count
      );

end rtl;
