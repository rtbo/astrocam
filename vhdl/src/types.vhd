library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.icx282.all;
use work.counter.all;

package types is

  -- main driving phase
  type frame_phase_t is (
    PhaseIdle,     -- nothing to do
    PhaseSht,      -- first phase after trigger during which the electronic shutter is pulsed
    PhaseExposure, -- exposure phase - photons are collected in the pixels
    PhaseReadout   -- pixel reading phase
  );

  -- shutter drive output bus
  type shutter_drive_bus_t is record
    -- substrate pulses (electronic shutter)
    SUB : std_logic;
    -- substracte control
    SUBC : std_logic;
    -- mechanical shutter
    MECH : std_logic;
  end record shutter_drive_bus_t;

  -- count the number e-shutter pulses
  subtype esht_count_t is unsigned(7 downto 0);
  -- count the number of lines scan during the exposure
  subtype exp_lines_count_t is unsigned(23 downto 0);

  -- registry bus
  type registry_bus_t is record
    ESHT_PULS : esht_count_t;
    EXP_LINES : exp_lines_count_t;
  end record registry_bus_t;

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

  -- the different modes in the vertical driver
  -- refer to ICX282 datasheet
  type v_mode_t is (
    VModeLine, -- regular line driving pattern
    VModeSeqA, -- sequence "a" readout (transfer odd lines in vertical registers)
    VModeSeqB, -- sequence "b" readout (transfer even lines in vertical registers)
    VModeSeqC, -- sequence "c" driving pattern
    VModeSeqD  -- sequence "d" driving pattern
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

  constant DEFAULT_VDRIVE : v_drive_bus_t := (
    XV1    => '1',
    XV2    => '1',
    others => '0'
  );

  type v_drive_counter_t is record
    XV1 : counter_t;
    XV2 : counter_t;
    XV3 : counter_t;
    XV4 : counter_t;
  end record v_drive_counter_t;

end package;
