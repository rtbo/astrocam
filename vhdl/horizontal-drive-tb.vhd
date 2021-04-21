library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library astrocam;
use astrocam.icx282.all;
use astrocam.types.all;

use std.textio.all;
use std.env.finish;

entity horizontal_drive_tb is
end horizontal_drive_tb;

architecture sim of horizontal_drive_tb is

  constant clk_hz     : integer := 22500e3;
  constant clk_period : time    := 1 sec / clk_hz;

  signal clk : std_logic := '1';
  signal rst : std_logic := '1';
  signal drive: h_drive_bus_t;
  signal counter : h_count_bus_t;

  component horizontal_drive is
    port (
      clk     : in std_logic;
      rst     : in std_logic;
      drive   : out h_drive_bus_t;
      counter : out h_count_bus_t
    );
  end component;

begin

  clk <= not clk after clk_period / 2;

  DUT : horizontal_drive port map(
    clk     => clk,
    rst     => rst,
    drive => drive,
    counter => counter
  );

  SEQUENCER_PROC : process
  begin
    wait for clk_period * 2;

    assert counter = 0 severity failure;

    rst <= '0';

    wait for clk_period * 10;
    assert counter = 9 severity failure;

    wait for clk_period * (H_CLK_COUNT - 10);
    assert counter = H_CLK_COUNT-1 severity failure;

    wait for clk_period;
    assert counter = 0 severity failure;

    wait for clk_period * 10;
    assert counter = 10 severity failure;

    wait for clk_period * (H_CLK_COUNT - 11);
    assert counter = H_CLK_COUNT-1 severity failure;

    wait for clk_period;
    assert counter = 0 severity failure;

    wait for clk_period * 10;
    rst <= '1';
    wait for clk_period;
    assert counter = 0 severity failure;

    report "simulation successful";
    finish;
  end process;

end architecture;
