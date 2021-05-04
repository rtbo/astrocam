library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.finish;

use work.icx282.all;
use work.types.all;
use work.horizontal_drive;
use work.vertical_drive;

entity vertical_drive_SeqC_tb is
end vertical_drive_SeqC_tb;

architecture sim of vertical_drive_SeqC_tb is

  signal clk : std_logic := '1';
  signal rst : std_logic := '1';

  signal h_counter : h_count_bus_t;
  signal h_HD      : std_logic;
  signal h_drv     : h_drive_bus_t;

  signal mode  : v_mode_t := VModeSeqC;
  signal drive : v_drive_bus_t;

  -- concatenation of XV1, XV2, XV3, XV4
  signal XV : std_logic_vector(1 to 4);
  -- concatenation of XV1A, XV1B, XV1C, XV3A, XV3B, XV3C
  signal XV13Z : std_logic_vector(1 to 6);

  constant T : time := CLK_PERIOD;

begin

  clk <= not clk after T / 2;
  rst <= '1', '0' after T / 2;

  XV    <= drive.XV1 & drive.XV2 & drive.XV3 & drive.XV4;
  XV13Z <= drive.XV1A & drive.XV1B & drive.XV1C & drive.XV3A & drive.XV3B & drive.XV3C;

  HD : entity horizontal_drive(rtl)
    port map(
      clk     => clk,
      rst     => rst,
      counter => h_counter,
      HD      => h_HD,
      drive   => h_drv
    );

  DUT : entity vertical_drive(rtl)
    port map(
      clk       => clk,
      rst       => rst,
      h_counter => h_counter,
      h_HD      => h_HD,
      mode      => mode,
      drive     => drive
    );

  SEQUENCER_PROC : process is
  begin
    wait for T + T / 100; -- ensure first edge + a bit to get established signals

    -- skip first with undefined signal
    wait for T;

    -- #2 through #62 included
    for i in 1 to 61 loop
      assert XV = "1100" report "XV should be 1100 but is " & to_string(XV) severity failure;
      wait for T;
    end loop;

    for i in 1 to 1970 loop

      for j in 1 to 26 loop
        assert XV = "0110" report "XV should be 0110 but is " & to_string(XV) severity failure;
        wait for T;
      end loop;

      for j in 1 to 26 loop
        assert XV = "0011" report "XV should be 0011 but is " & to_string(XV) severity failure;
        wait for T;
      end loop;

      for j in 1 to 26 loop
        assert XV = "1001" report "XV should be 1001 but is " & to_string(XV) severity failure;
        wait for T;
      end loop;

      for j in 1 to 26 loop
        assert XV = "1100" report "XV should be 1100 but is " & to_string(XV) severity failure;
        wait for T;
      end loop;

    end loop;

    while h_counter /= 0 loop
      assert XV = "1100" report "XV should be 1100 but is " & to_string(XV) severity failure;
      wait for T;
    end loop;

    finish;
  end process;

  -- XV1Z and XV3Z must all be 0
  XV13Z_CHECK_PROC : process is
  begin
    wait for T / 100; -- offset a bit to get established signals
    for i in 1 to H_CLK_COUNT loop
      assert XV13Z = "000000" severity failure;
      wait for T;
    end loop;
  end process XV13Z_CHECK_PROC;

end architecture sim;
