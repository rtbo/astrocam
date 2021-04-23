-- CCD driving signal generation
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.icx282.all;
use work.types.all;
use work.horizontal_drive;
use work.vertical_drive;

entity ccd_drive is

  port (
    clk     : in std_logic;
    rst     : in std_logic;
    v_seq   : in v_seq_t;
    h_drive : out h_drive_bus_t;
    v_drive : out v_drive_bus_t
  );
end ccd_drive;

architecture structural of ccd_drive is

  signal h_HD      : std_logic;
  signal h_counter : h_count_bus_t;

begin

  H_DRV_COMP : entity horizontal_drive(rtl)
    port map(
      clk     => clk,
      rst     => rst,
      counter => h_counter,
      HD      => h_HD,
      drive   => h_drive
    );

  V_DRV_COMP : entity vertical_drive(rtl)
    port map(
      clk       => clk,
      rst       => rst,
      h_counter => h_counter,
      h_HD      => h_HD,
      seq       => v_seq,
      drive     => v_drive
    );

end architecture structural;
