library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library astrocam;
use astrocam.icx282.all;
use astrocam.types.all;
use astrocam.horizontal_drive;

use std.textio.all;
use std.env.finish;

entity horizontal_drive_tb is
end horizontal_drive_tb;

architecture sim of horizontal_drive_tb is

  signal clk     : std_logic := '1';
  signal rst     : std_logic := '1';
  signal counter : h_count_bus_t;
  signal HD      : std_logic;
  signal drive   : h_drive_bus_t;

  constant T : time := CLK_PERIOD;

begin

  clk <= not clk after T / 2;

  DUT : entity horizontal_drive(rtl)
    port map(
      clk     => clk,
      rst     => rst,
      counter => counter,
      HD      => HD,
      drive   => drive
    );

  COUNTER_PROC : process is
  begin
    rst <= '0';
    wait for T / 100; -- shift for ensuring signal established
    assert counter = 0 severity failure;

    wait for T * 10;
    assert counter = 10 severity failure;

    wait for T * (H_CLK_COUNT - 11);
    assert counter = H_CLK_COUNT - 1 severity failure;

    wait for T;
    assert counter = 0 severity failure;

    wait for T * 10;
    assert counter = 10 severity failure;

    wait for T * (H_CLK_COUNT - 11);
    assert counter = H_CLK_COUNT - 1 severity failure;

    wait for T;
    assert counter = 0 severity failure;

    wait for T * 10;
    rst <= '1';
    wait for T;
    assert counter = 0 severity failure;

    report "simulation successful";
    finish;
  end process COUNTER_PROC;

  H12AB_PROC : process is
  begin
    wait for T / 100; -- small shift to wait signal established

    for i in 1 to 62 loop
      assert HD = '1' severity failure;
      assert drive.H1A = '1' and drive.H2A = '0' severity failure;
      assert drive.H1B = '1' and drive.H2B = '0' severity failure;
      wait for T / 2; -- wait clock low
      assert HD = '1' severity failure;
      assert drive.H1A = '0' and drive.H2A = '1' severity failure;
      assert drive.H1B = '0' and drive.H2B = '1' severity failure;
      wait for T / 2; -- wait clock high
    end loop;

    for i in 1 to 208 loop
      assert HD = '0' severity failure;
      assert drive.H1A = '1' and drive.H2A = '0' severity failure;
      assert drive.H1B = '1' and drive.H2B = '0' severity failure;
      wait for T / 2; -- wait clock low
      assert HD = '0' severity failure;
      assert drive.H1A = '1' and drive.H2A = '0' severity failure;
      assert drive.H1B = '1' and drive.H2B = '0' severity failure;
      wait for T / 2; -- wait clock high
    end loop;

    for i in 1 to H_CLK_COUNT - 270 loop
      assert HD = '1' severity failure;
      assert drive.H1A = '1' and drive.H2A = '0' severity failure;
      assert drive.H1B = '1' and drive.H2B = '0' severity failure;
      wait for T / 2; -- wait clock low
      assert HD = '1' severity failure;
      assert drive.H1A = '0' and drive.H2A = '1' severity failure;
      assert drive.H1B = '0' and drive.H2B = '1' severity failure;
      wait for T / 2; -- wait clock high
    end loop;

    wait for H_CLK_COUNT * T;
    finish;
  end process H12AB_PROC;

end architecture;
