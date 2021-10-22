----------------------------------------------------------------------------------
-- Generic IPBus "read FIFO interface" slave V2.0
--
--
-- This design implements an slave interface to a read FIFO,which can transfer data from slave to IPbus.

-- Attention: 
-- The read FIFO is FWFT(first word fall through) FIFO, 
--   and the "More Accurate Data Counts" option has been set!

-- Default FIFO depth is 512, considering the MTU length of 1500
-- But we can draw the conclusion from the test that
--      the max read length in one ethernet packet is 255 after separated by software!

-- If you want to change the depth of the inner FIFO, you SHOULD change RDFIFO_ADD_NUM and regenerate fwft_fifo_32_512 core.
-- 
-- Attention: all the operations to this slave will complete successfully from the view of the master, which means NO Time out state will happens.
--  for the situation of reading from an empty FIFO, the dummy data will be filled
--  The number of  the successful read will be recorded in registers.
--
-- This design use 3 address
-- loc 0: RFIFO_DATA: read port
-- loc 1: RFIFO_LEN: data length can be read from read fifo ( read it before read operation if needed)
-- loc 2: RVALID_LEN: successful(valid) words from last read from this port (read after read operation if needed)
--
-- For RVALID_LEN, the format is:
-- bit 31: '1' : there are valid data in the previous operation, 
--         '0' : the previous operation has finished, but nothing was read from to FIFO
-- bit [8:0] : the number of the successfully transferred words
--
-- We can perform "SAFE" read operation in two methods:
-- 1. read the data length register at first, then start read/write based on the results
-- 2. do block read at first, then check if the data is valid
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


entity ipbus_read_fifo is
  port(
    clk       : in  std_logic;
    reset     : in  std_logic;
    ipbus_in  : in  ipb_wbus;
    ipbus_out : out ipb_rbus;

    --read  FIFO
    rfifo_wr_clk      : in  std_logic;
    rfifo_wr_en       : in  std_logic;
    rfifo_wr_din      : in  std_logic_vector(31 downto 0);
    rfifo_full        : out std_logic;
    rfifo_almost_full : out std_logic;
    debug             : out std_logic
    );

end ipbus_read_fifo;

architecture rtl of ipbus_read_fifo is

  constant RDFIFO_ADD_NUM : natural := 17;  -- the depth of the read fifo is 2**RDFIFO_ADD_NUM

  component fwft_fifo_32_2048 is
    port (
      rst           : in  std_logic;
      wr_clk        : in  std_logic;
      rd_clk        : in  std_logic;
      din           : in  std_logic_vector(31 downto 0);
      wr_en         : in  std_logic;
      rd_en         : in  std_logic;
      dout          : out std_logic_vector(31 downto 0);
      full          : out std_logic;
      almost_full   : out std_logic;
      empty         : out std_logic;
      valid         : out std_logic;
      rd_data_count : out std_logic_vector(RDFIFO_ADD_NUM downto 0);
      wr_data_count : out std_logic_vector(RDFIFO_ADD_NUM downto 0)
      );
  end component fwft_fifo_32_2048;



  constant DUMMY_DATA    : std_logic_vector(31 downto 0) := X"FFFFFFFF";
  constant TIMEOUT_COUNT : integer                       := 32;

  signal ipb_rd_ack, rd_addr_match   : std_logic;
  signal rd_reg_ack                  : std_logic;
  signal rd_clk, rd_en, valid, empty : std_logic;
  signal rd_din                      : std_logic_vector(31 downto 0);
  signal rd_data_count               : std_logic_vector(RDFIFO_ADD_NUM downto 0);
                                        -- the address width for FWFT FIFO with "More Accurate Data Counts" option is WRFIFO_ADD_NUM+1 !        
  signal valid_rdata_count           : unsigned(RDFIFO_ADD_NUM-1 downto 0);
  signal valid_rdata_en              : std_logic;
  signal valid_rdata_port            : std_logic_vector(31 downto 0);

  signal timeout                : unsigned(7 downto 0) := (others => '0');
  signal dummy_ack, dummy_ack_b : std_logic;

  signal ipb_strobe_d, ipb_write_d : std_logic := '0';
  signal ipb_addr_d                : std_logic_vector(1 downto 0);

  -- DEBUG
  attribute mark_debug                      : string;
  attribute mark_debug of rfifo_wr_en       : signal is "true";
  attribute mark_debug of rfifo_wr_din      : signal is "true";
  attribute mark_debug of ipb_rd_ack        : signal is "true";
  attribute mark_debug of rd_addr_match     : signal is "true";
  attribute mark_debug of rd_en             : signal is "true";
  attribute mark_debug of valid             : signal is "true";
  attribute mark_debug of empty             : signal is "true";
  attribute mark_debug of rd_data_count     : signal is "true";
  attribute mark_debug of valid_rdata_count : signal is "true";
  attribute mark_debug of valid_rdata_en    : signal is "true";
  attribute mark_debug of valid_rdata_port  : signal is "true";

begin

  ipbus_out.ipb_ack <= ipb_rd_ack or rd_reg_ack or dummy_ack;
  ipbus_out.ipb_err <= '0';

  rd_clk        <= clk;
  rd_addr_match <= '1' when (ipbus_in.ipb_addr(1 downto 0) = "00") else '0';
  rd_en         <= ipb_rd_ack;
  --  ipb_rd_ack <= valid and ipbus_in.ipb_strobe and (not ipbus_in.ipb_write) and not dummy_ack;
  ipb_rd_ack    <= ipbus_in.ipb_strobe and (not ipbus_in.ipb_write) and valid and rd_addr_match and not dummy_ack;

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
        valid_rdata_count <= (others => '0');
        valid_rdata_en    <= '0';
      elsif ipbus_in.ipb_strobe = '0' and ipb_strobe_d = '1' and ipb_write_d = '0' and ipb_addr_d = "10" then
        valid_rdata_en    <= '0';
        valid_rdata_count <= (others => '0');
      elsif ipb_rd_ack = '1' and dummy_ack = '0' and ipbus_in.ipb_addr(1 downto 0) = "00" then
        valid_rdata_en    <= '1';
        valid_rdata_count <= valid_rdata_count + 1;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        valid_rdata_port <= X"00000000";
      elsif ipbus_in.ipb_strobe = '0' and ipb_strobe_d = '1' then
        if ipb_write_d = '0' then
          valid_rdata_port <= valid_rdata_en & std_logic_vector(to_unsigned(0, 31 - RDFIFO_ADD_NUM)) & std_logic_vector(valid_rdata_count);
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if ipbus_in.ipb_strobe = '0' or ipb_rd_ack = '1' or rd_reg_ack = '1' then
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



  ipbus_out.ipb_rdata <= std_logic_vector(to_unsigned(0, 31 - RDFIFO_ADD_NUM)) & rd_data_count when ipbus_in.ipb_addr(1 downto 0) = "01"
                         else valid_rdata_port when ipbus_in.ipb_addr(1 downto 0) = "10"
                         else DUMMY_DATA       when dummy_ack = '1'
                         else rd_din;

  debug <= empty;

  fifo_up : fwft_fifo_32_2048
    port map(
      rst           => reset,
      wr_clk        => rfifo_wr_clk,
      rd_clk        => rd_clk,
      din           => rfifo_wr_din,
      wr_en         => rfifo_wr_en,
      rd_en         => rd_en,
      dout          => rd_din,
      full          => rfifo_full,
      almost_full   => rfifo_almost_full,
      empty         => empty,
      valid         => valid,
      rd_data_count => rd_data_count
      );

end rtl;

