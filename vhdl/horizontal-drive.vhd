library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library astrocam;
use astrocam.icx282.all;
use astrocam.types.all;

entity horizontal_drive is
  port (
    clk     : in std_logic;
    rst     : in std_logic;
    drive   : out h_drive_bus_t;
    counter : out h_count_bus_t
  );
end horizontal_drive;

architecture rtl of horizontal_drive is

begin

  COUNTER_PROC : process (clk, rst) is
    variable current_count : h_count_t := 0;
  begin
    if rst then
      current_count := 0;
    elsif rising_edge(clk) then
      current_count := (current_count + 1) mod H_CLK_COUNT;
    end if;
    counter <= to_unsigned(current_count, H_CLK_BITS);
  end process COUNTER_PROC;

end architecture;
