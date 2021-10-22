-------------------------------------------------------------------------------
-- Title      : generate top clocks
-- Project    : 
-------------------------------------------------------------------------------
-- File       : twominus_clock_gen.vhd
-- Author     : sdong  <sdong@sdong-ubuntu>
-- Company    : 
-- Created    : 2021-10-21
-- Last update: 2021-10-21
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2021 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2021-10-21  1.0      sdong	Created
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

--use work.twominus_defines.all;


entity twominus_clock_gen is
  generic(
    CLK_FR_FREQ  : real := 200.0;       -- 200MHz reference
    CLK_VCO_FREQ : real := 1000.0       -- VCO freq 1000M
    );
  port (
    sysclk       : in  std_logic;
    clk_out0     : out std_logic;
    clk_out1     : out std_logic;
    clk_out2     : out std_logic;
    clk_out3     : out std_logic;
    clk_out0_rst : out std_logic;
    clk_out1_rst : out std_logic;
    clk_out2_rst : out std_logic;
    clk_out3_rst : out std_logic;
    locked       : out std_logic
    );
end twominus_clock_gen;


architecture behv of twominus_clock_gen is

  signal clkfb                                      : std_logic;
  signal clkout0_i, clkout1_i, clkout2_i, clkout3_i : std_logic;
  signal mmcm_locked                                : std_logic;
  signal rst                                        : std_logic;

begin

  mmcm : MMCME2_BASE
    generic map (
      BANDWIDTH          => "OPTIMIZED",  -- Jitter programming (OPTIMIZED, HIGH, LOW)
      CLKFBOUT_MULT_F    => CLK_VCO_FREQ / CLK_FR_FREQ,  -- Multiply value for all CLKOUT (2.000-64.000).
      CLKFBOUT_PHASE     => 0.0,  -- Phase offset in degrees of CLKFB (-360.000-360.000).
      CLKIN1_PERIOD      => 1000.0 / CLK_FR_FREQ,  -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
      CLKOUT1_DIVIDE     => integer(CLK_VCO_FREQ / (1000.0 / 10)),  -- Divide amount for CLKOUT1 (1.000-128.000).
      CLKOUT2_DIVIDE     => integer(CLK_VCO_FREQ / (1000.0 / 100)),  -- Divide amount for CLKOUT2 (1.000-128.000).
      CLKOUT3_DIVIDE     => integer(CLK_VCO_FREQ / (1000.0 / 5)),  -- Divide amount for CLKOUT2 (1.000-128.000).
      CLKOUT0_DIVIDE_F   => CLK_VCO_FREQ / (1000.0 / 20),  -- Divide amount for CLKOUT0 (1.000-128.000).
      -- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
      CLKOUT0_DUTY_CYCLE => 0.5,
      CLKOUT1_DUTY_CYCLE => 0.5,
      CLKOUT2_DUTY_CYCLE => 0.5,
      CLKOUT3_DUTY_CYCLE => 0.5,
      CLKOUT4_DUTY_CYCLE => 0.5,
      CLKOUT6_DUTY_CYCLE => 0.5,
      -- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase clkout2offset for each CLKOUT (-360.000-360.000).
      CLKOUT0_PHASE      => 0.0,
      CLKOUT1_PHASE      => 0.0,
      CLKOUT2_PHASE      => 0.0,
      CLKOUT4_CASCADE    => false,  -- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
      DIVCLK_DIVIDE      => 1,          -- Master division value (1-106)
      REF_JITTER1        => 0.0,  -- Reference input jitter in UI (0.000-0.999).
      STARTUP_WAIT       => false  -- Delays DONE until MMCM is locked (FALSE, TRUE)
      )
    port map (
      -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
      CLKOUT0  => clkout0_i,            -- 1-bit output: CLKOUT0
      CLKOUT0B => open,                 -- 1-bit output: CLKOUT0
      CLKOUT1  => clkout1_i,            -- 1-bit output: CLKOUT1
      CLKOUT2  => clkout2_i,            -- 1-bit output: CLKOUT2
      CLKOUT3  => clkout3_i,            -- 1-bit output: CLKOUT2
      -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
      CLKFBOUT => clkfb,                -- 1-bit output: Feedback clock
      -- Status Ports: 1-bit (each) output: MMCM status ports
      LOCKED   => mmcm_locked,          -- 1-bit output: LOCK
      -- Clock Inputs: 1-bit (each) input: Clock input
      CLKIN1   => sysclk,               -- 1-bit input: Clock
      -- Control Ports: 1-bit (each) input: MMCM control ports
      PWRDWN   => '0',                  -- 1-bit input: Power-down
      RST      => '0',                  -- 1-bit input: Reset
      -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
      CLKFBIN  => clkfb                 -- 1-bit input: Feedback clock
      );

  bufg0 : BUFG port map(
    i => clkout0_i,
    o => clk_out0
    );

  bufg1 : BUFG port map(
    i => clkout1_i,
    o => clk_out1
    );

  bufg2 : BUFG port map(
    i => clkout2_i,
    o => clk_out2
    );

  bufg3 : BUFG port map(
    i => clkout3_i,
    o => clk_out3
    );


  rst <= not mmcm_locked;

  process(clkout0_i)
  begin
    if rising_edge(clkout0_i) then
      clk_out0_rst <= rst;
    end if;
  end process;

  process(clkout1_i)
  begin
    if rising_edge(clkout1_i) then
      clk_out1_rst <= rst;
    end if;
  end process;

  process(clkout2_i)
  begin
    if rising_edge(clkout2_i) then
      clk_out2_rst <= rst;
    end if;
  end process;

  process(clkout3_i)
  begin
    if rising_edge(clkout3_i) then
      clk_out3_rst <= rst;
    end if;
  end process;

  locked <= mmcm_locked;

end behv;
