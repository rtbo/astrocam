-- CCD driving signal generation
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library astrocam;
use astrocam.icx282.all;
use astrocam.types.all;

entity ccd_drive is

  port (
    clk         : in std_logic;
    rst         : in std_logic;
    h_drive: out h_drive_bus_t;
    v_drive : out v_drive_bus_t
  );
end ccd_drive;

architecture rtl of ccd_drive is
begin

end architecture rtl;
