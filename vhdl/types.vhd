library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.icx282.all;

package types is

  -- integer to store the horizontal counter
  subtype h_count_t is integer range 0 to H_CLK_COUNT - 1;
  -- signal bus to store the horizontal counter
  subtype h_count_bus_t is unsigned(H_CLK_BITS - 1 downto 0);

  -- output bus for the horizontal driver
  type h_drive_bus_t is record
    RG  : std_logic;
    H1A : std_logic;
    H1B : std_logic;
    H2A : std_logic;
    H2B : std_logic;
  end record h_drive_bus_t;

  -- the different sequences in the vertical driver
  -- refer to ICX282 datasheet
  type v_seq_t is (
    LineDrv, -- regular line driving pattern
    SeqA,    -- sequence "a" readout (transfer odd lines in vertical registers)
    SeqB,    -- sequence "b" readout (transfer even lines in vertical registers)
    SeqC,    -- sequence "c" driving pattern
    SeqD     -- sequence "d" driving pattern
  );

  subtype v_sync_count_t is integer range 0 to H_VSYNC;
  subtype v_sync_count_bus_t is unsigned(H_VSYNC_BITS - 1 downto 0);

  type v_drive_bus_t is record
    XV1  : std_logic;
    XV2  : std_logic;
    XV3  : std_logic;
    XV4  : std_logic;
    XV1A : std_logic;
    XV1B : std_logic;
    XV1C : std_logic;
    XV3A : std_logic;
    XV3B : std_logic;
    XV3C : std_logic;
  end record v_drive_bus_t;

end package;
