library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.icx282.all;
use work.types.all;

entity vertical_drive is
  port (
    -- main clock
    clk : in std_logic;
    -- reset
    rst : in std_logic;
    -- horizontal counter (increment on each pixel)
    h_counter : in h_count_bus_t;
    -- the HD flag from the horizontal driver
    h_HD : in std_logic;
    -- the vertical driving sequence to perform
    seq : in v_seq_t;
    -- the vertical driving signal output
    drive : out v_drive_bus_t
  );
end entity vertical_drive;

architecture rtl of vertical_drive is
  -- signal that determines when vertical drive is following
  -- its usual pattern
  -- here unusual is the first part of sequence "c" and "d"
  signal VD : std_logic;

  -- the count within the vertical sync sequence (hor clk from 62 to 270)
  -- this counts the clock cycles when HD is low.
  signal sync_count : v_sync_count_bus_t;
begin

  VD         <= '1';
  drive.XV1A <= '0';
  drive.XV1B <= '0';
  drive.XV1C <= '0';
  drive.XV3A <= '0';
  drive.XV3B <= '0';
  drive.XV3C <= '0';

  SYNC_COUNT_PROC : process (clk) is
  begin
    if rst then
      sync_count <= (others => '0');
    elsif rising_edge(clk) then
      sync_count <= (others => '0') when h_HD else
        sync_count + 1;
    end if;
  end process SYNC_COUNT_PROC;

  VSYNC_PROC : process (clk) is
  begin
    if rising_edge(clk) then
      if VD = '1' and h_HD = '1' then
        drive.XV1 <= '1';
        drive.XV2 <= '1';
        drive.XV3 <= '0';
        drive.XV4 <= '0';
      elsif VD = '1' and h_HD = '0' then
        drive.XV1 <= '0' when sync_count >= 27 and sync_count < 104 else
        '1';
        drive.XV2 <= '0' when sync_count >= 79 and sync_count < 157 else
        '1';
        drive.XV3 <= '1' when sync_count < 131 else
        '0';
        drive.XV4 <= '1' when sync_count >= 53 and sync_count < 183 else
        '0';
      else
        drive.XV1 <= '0';
        drive.XV2 <= '0';
        drive.XV3 <= '0';
        drive.XV4 <= '0';
      end if;
    end if;
  end process;

end architecture rtl;
