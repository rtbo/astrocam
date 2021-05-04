-- Top level interface for CCD clock generation
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.icx282.all;
use work.types.all;
use work.horizontal_drive;
use work.vertical_drive;

entity ccd_drive is

  port (
    clk       : in std_logic;      -- main driving clock
    rst       : in std_logic;      -- global reset
    en        : inout std_logic;   -- enabled flag to indicate when a frame is being processed
    sht_drive : out std_logic;     -- shutter signal driver
    h_drive   : out h_drive_bus_t; -- horizontal signal driver
    v_drive   : out v_drive_bus_t  -- vertical signal driver
  );

end ccd_drive;

architecture structural of ccd_drive is

  signal h_counter : h_count_bus_t;
  signal v_mode    : v_mode_t;

begin

  H_DRV_COMP : entity horizontal_drive(rtl)
    port map(
      clk     => clk,
      rst     => rst,
      counter => h_counter,
      drive   => h_drive
    );

  V_DRV_COMP : entity vertical_drive(rtl)
    port map(
      clk       => clk,
      rst       => rst,
      h_counter => h_counter,
      mode      => v_mode,
      drive     => v_drive
    );

end architecture structural;
