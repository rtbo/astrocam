library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.icx282.all;
use work.types.all;

entity horizontal_drive is
  port (
    -- main clock
    clk     : in std_logic;
    -- reset
    rst     : in std_logic;
    -- pixel counter that restart at 0 on each line
    counter : out h_count_bus_t;
    -- whether we are in the HD enabled part of the line
    -- refer to datasheet. HD is enabled always but from 62 to 270.
    HD: out std_logic;
    -- output bus to drive the CCD
    drive   : out h_drive_bus_t
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
    HD      <= '0' when current_count >= 62 and current_count < 270 else '1';
  end process COUNTER_PROC;

  RG_PROC : drive.RG <= clk when rst = '0' else '0';

  H1_PROC : process (clk, HD) is
  begin
    drive.H1A <= clk when HD else '1';
    drive.H1B <= clk when HD else '1';
  end process H1_PROC;

  H2_PROC : process (clk, HD) is
  begin
    drive.H2A <= not clk when HD else '0';
    drive.H2B <= not clk when HD else '0';
  end process H2_PROC;

end architecture;
