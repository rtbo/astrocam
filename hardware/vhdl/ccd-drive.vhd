-- CCD driving signal generation
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library astrocam;
use astrocam.icx282.all;

entity ccd_drive is
  port (
    clk     : in std_logic;
    rst     : in std_logic;
    h_count : out h_count_bus_t
  );
end ccd_drive;

architecture rtl of ccd_drive is
begin

  COUNT_H : process (clk, rst) is
    variable h_counter : h_count_t :=0;
  begin
    if rst then
      h_counter := 0;
    elsif rising_edge(clk) then
      h_counter := (h_counter + 1) mod H_CLK_COUNT;
    end if;
    h_count <= to_unsigned(h_counter, H_CLK_BITS);
  end process COUNT_H;


end architecture rtl;
