-- CCD driving signal generation
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library astrocam;
use astrocam.icx282.all;
use astrocam.types.all;

entity ccd_drive is

  port (
    clk     : in std_logic;
    rst     : in std_logic;
    h_drive : out h_drive_bus_t;
    v_drive : out v_drive_bus_t
  );
end ccd_drive;

architecture structural of ccd_drive is

  signal h_en      : std_logic;
  signal h_counter : h_count_bus_t;

  component horizontal_drive is
    port (
      clk     : in std_logic;
      rst     : in std_logic;
      en      : in std_logic;
      drive   : out h_drive_bus_t;
      counter : out h_count_bus_t
    );
  end component horizontal_drive;

  component vertical_drive is
    port (
      clk     : in std_logic;
      rst     : in std_logic;
      h_count : in h_count_t;
      drive   : out v_drive_bus_t
    );
  end component vertical_drive;

begin

  H_DRV_COMP : horizontal_drive
  port map(
    clk     => clk,
    rst     => rst,
    en      => h_en,
    drive   => h_drive,
    counter => h_counter
  );

  V_DRV_COMP : vertical_drive
  port map(
    clk       => clk,
    rst       => rst,
    h_counter => h_counter,
    drive     => v_drive
  );

end architecture structural;
