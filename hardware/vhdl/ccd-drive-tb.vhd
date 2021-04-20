library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library astrocam;
use astrocam.icx282.all;

use std.textio.all;
use std.env.finish;

entity ccd_drive_tb is
end ccd_drive_tb;

architecture sim of ccd_drive_tb is

  constant clk_hz     : integer := 22500e3;
  constant clk_period : time    := 1 sec / clk_hz;

  signal clk : std_logic := '1';
  signal rst : std_logic := '1';
  signal h_count : h_count_bus_t;

  component ccd_drive is
    port (
      clk     : in std_logic;
      rst     : in std_logic;
      h_count : out h_count_bus_t
    );
  end component;

begin

  clk <= not clk after clk_period / 2;

  DUT : ccd_drive port map(
    clk     => clk,
    rst     => rst,
    h_count => h_count
  );

  SEQUENCER_PROC : process
  begin
    wait for clk_period * 2;

    assert h_count = 0 severity failure;

    rst <= '0';

    wait for clk_period * 10;
    assert h_count = 9 severity failure;

    wait for clk_period * (H_CLK_COUNT - 10);
    assert h_count = H_CLK_COUNT-1 severity failure;

    wait for clk_period;
    assert h_count = 0 severity failure;

    wait for clk_period * 10;
    assert h_count = 10 severity failure;

    wait for clk_period * (H_CLK_COUNT - 11);
    assert h_count = H_CLK_COUNT-1 severity failure;

    wait for clk_period;
    assert h_count = 0 severity failure;

    wait for clk_period * 10;
    rst <= '1';
    wait for clk_period;
    assert h_count = 0 severity failure;

    report "simulation successful";
    finish;
  end process;

end architecture;
