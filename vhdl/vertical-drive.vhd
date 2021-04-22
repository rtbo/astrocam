library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library astrocam;
use astrocam.icx282.all;
use astrocam.types.all;

entity vertical_drive is
  port (
    clk     : in std_logic;
    rst     : in std_logic;
    h_count : in h_count_t;
    drive   : out v_drive_bus_t
  );
end entity vertical_drive;

architecture rtl of vertical_drive is
begin

end architecture rtl;
