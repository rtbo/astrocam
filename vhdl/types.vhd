library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library astrocam;
use astrocam.icx282.all;

package types is

  subtype h_count_t is integer range 0 to H_CLK_COUNT - 1;    -- integer to store the horizontal counter
  subtype h_count_bus_t is unsigned(H_CLK_BITS - 1 downto 0); -- signal bus to store the horizontal counter

  type h_drive_bus_t is record
    RG  : std_logic;
    H1A : std_logic;
    H1B : std_logic;
    H2A : std_logic;
    H2B : std_logic;
  end record h_drive_bus_t;

  type v_drive_bus_t is record
    XV1  : std_logic;
    XV1A : std_logic;
    XV1B : std_logic;
    XV1C : std_logic;
    XV2  : std_logic;
    XV3A : std_logic;
    XV3B : std_logic;
    XV3C : std_logic;
    XV4  : std_logic;
  end record v_drive_bus_t;

  -- subtype h_count_bus_t is unsigned; -- signal bus to store the horizontal counter
  type v_seq_t is (Reg, SeqA, SeqB, SeqC, SeqD); -- the different sequences in the vertical driver

end package;
