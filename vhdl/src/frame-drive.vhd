-- the frame_drive entity drives the complete frame, from the trigger pulse to the end of the readout
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity frame_drive is
  port (
    clk       : in std_logic; -- Main system clock
    rst       : in std_logic; -- Main system reset
    trig      : in std_logic; -- the trigger signal
    h_counter : in h_count_bus_t;
    reg       : in registry_bus_t;
    sht       : out shutter_drive_bus_t
  );
end frame_drive;

architecture rtl of frame_drive is

  signal phase        : frame_phase_t;
  signal trigger      : std_logic; -- trigger signal
  signal hstart       : std_logic; --high at start of line scan
  signal esht_counter : esht_count_t;
  signal esht_now     : std_logic; -- high when it is the period of electronic-shutter
  signal exp_counter  : exp_lines_count_t;

begin

  hstart <= '1' when h_counter = 0 else '0';

  TRIGGER_PROC : process (clk, rst)
  begin
    if rst = '1' then
      trigger <= '0';
    elsif rising_edge(clk) then
      -- debouncing trigger as long it is on until the next line starts
      if trig then
        trigger <= '1';
      elsif hstart then
        trigger <= '0';
      end if;
    end if;
  end process;

  PHASE_PROC : process (clk, rst)
  begin
    if rst then
      phase <= PhaseIdle;
    elsif rising_edge(clk) then
      -- shifting phase only at line start
      if hstart then
        if trigger = '1' and phase = PhaseIdle then
          phase <= PhaseSht;
        elsif phase = PhaseSht and esht_counter = 0 then
          phase <= PhaseExposure;
        elsif phase = PhaseExposure and exp_counter = 0 then
          phase <= PhaseReadout;
          -- FIXME: back to idle after readout completion
        end if;
      end if;
    end if;
  end process;

  -- esht_now is high when it is the time of the line to activate the e-shutter (SUB pin)
  -- refer to datasheet of ICX282
  ESHT_NOW_PROC : process (clk, rst)
    variable hc : integer;
  begin
    if rst then
      esht_now <= '0';
    elsif rising_edge(clk) then
      hc := to_integer(h_counter);
      case hc is
        when 176    => esht_now <= '1'; -- 62 + 114
        when 234    => esht_now <= '0'; -- 62 + 114 + 58
        when others => null;
      end case;
    end if;
  end process;

  -- driving the shutter
  sht.SUB <= '1' when phase = PhaseSht and esht_now = '1' else '0';
  sht.MECH <= '1' when phase = PhaseReadout else '0';
  sht.SUBC <= '1' when phase /= PhaseIdle else '0';

end architecture;
