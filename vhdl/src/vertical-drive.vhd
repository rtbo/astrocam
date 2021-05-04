-- vertical_drive entity deals with generating vertical driving signals.
-- These signals follow several distinct modes:
--  * Main line mode (VModeLine)
--      In this mode, there is a sequence to transfer the pixel data from the bottom of register to the horizontal register
--      This transfer happens between line clk 62 and 270, while the horizontal transfer is inactive (what I call sync sequence - HD is low).
--      The vertical signals are then static during the rest of the line.
--  * "a" sequence (VModeSeqA)
--      In the sequence, there is a sequence similar to the main one during the sync sequence, with additional 15V readout pulse
--      (driven by the V[1|3][A-C] signals) that transfer the odd lines charges to their vertical registers.
--  * "b" sequence (VModeSeqB)
--      Similar to the "a" sequence but for the even lines.
--  * "c" sequence (VModeSeqC)
--      Special sequence that drains the vertical registers before the odd pixel readout. This sequence is consists
--      of 1970 (the number of lines) interleaved pulses that carries down the charges (I guess they get lost somewhere in the substrate).
--  * "d" sequence (VModeSeqD)
--      Sequence similar to "c" after the odd lines have been read and before the even lines readout to the vertical registers.
--      As only the even lines must be drained, the sequence is done for 986 lines only.
--
--  A full frame readout consist of the the following:
--  * (exposure)
--  * Sequence "c" (vertical register cleanup)
--  * Sequence "a" (odd lines readout to the vertical register)
--  * Main line mode x 986 (odd lines reading)
--  * Sequence "d" (vertical register cleanup)
--  * Sequence "b" (even lines readout to the vertical register)
--  * Main line mode x 986 (even lines reading)
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.counter.all;
use work.icx282.all;
use work.types.all;

entity vertical_drive is
  port (
    -- main clock
    clk : in std_logic;
    -- reset
    rst : in std_logic;
    -- horizontal counter (increment on each clk)
    h_counter : in h_count_bus_t;
    -- the HD flag from the horizontal driver
    h_HD : in std_logic;
    -- whether to reinitialize the bus at H=0
    mode : in v_mode_t;
    -- the vertical driving signal output
    drive : out v_drive_bus_t := DEFAULT_VDRIVE
  );
end entity vertical_drive;

architecture rtl of vertical_drive is

  -- count number of pulses in the "c" and "d" sequences
  signal cd_counter : counter_t(c(12 downto 0));
  -- count number of clk per pulse in the "c" and "d" sequences for V1 and V3
  signal cd_width_counter13 : counter_t(c(5 downto 0));
  -- count number of clk per pulse in the "c" and "d" sequences for V2 and V4
  signal cd_width_counter24 : counter_t(c(5 downto 0));

  -- how many pulses in the "c" sequence
  constant c_pulses : integer := 1970;
  -- pulse witdh in the "c" sequence
  constant c_width : integer := 26;
  -- how many pulses in the "d" sequence
  constant d_pulses : integer := 986;
  -- pulse witdh in the "d" sequence
  constant d_width : integer := 18;

begin

  DRIVE_PROC : process (clk, rst) is
    variable hcount : integer;

    -- procedure that define behavior of c and d
    procedure cd_procedure(
      constant hcnt : integer;
      constant pulses : integer;
      constant width  : integer) is
    begin
      if hcnt = 62 and not counter_enabled(cd_counter) then
        -- each pulse is 4 times the width, we step the pulse counter every half period
        counter_enable(cd_counter, pulses * 4-1);
        drive.XV1 <= '0';
        drive.XV3 <= '1';
        -- intialize the 2 counter with T/4 = width offset and start countdown
        counter_enable(cd_width_counter13, 2 * width - 1);
        counter_enable(cd_width_counter24, width - 1);

      elsif counter_enabled(cd_counter) and not counter_done(cd_counter) then

        if counter_done(cd_width_counter13) then
          drive.XV1 <= not drive.XV1;
          drive.XV3 <= not drive.XV3;
          counter_enable(cd_width_counter13, 2 * width - 1);
          counter_step(cd_counter);
        else
          counter_step(cd_width_counter13);
        end if;

        if counter_done(cd_width_counter24) then
          drive.XV2 <= not drive.XV2;
          drive.XV4 <= not drive.XV4;
          counter_enable(cd_width_counter24, 2 * width - 1);
          counter_step(cd_counter);
        else
          counter_step(cd_width_counter24);
        end if;

      end if;
    end procedure cd_procedure;

  begin
    if rst then

      drive <= DEFAULT_VDRIVE;
      counter_disable(cd_counter);
      counter_disable(cd_width_counter13);
      counter_disable(cd_width_counter24);

    elsif rising_edge(clk) then

      hcount := to_integer(h_counter);

      if mode = VModeLine or mode = VModeSeqA or mode = VModeSeqB then
        -- reset c and d counter
        counter_disable(cd_counter);

        -- assignments common to main, a and b in the sync sequence
        case hcount is
          when 62     => drive.XV3  <= '1';
          when 89     => drive.XV1  <= '0';
          when 115    => drive.XV4 <= '1';
          when 141    => drive.XV2 <= '0';
          when 166    => drive.XV1 <= '1';
          when 193    => drive.XV3 <= '0';
          when 219    => drive.XV2 <= '1';
          when others => null;
        end case;
      end if;

      -- assignments sepcific to Line mode
      if mode = VModeLine then
        if hcount = 245 then
          drive.XV4 <= '0';
        end if;
      end if;

      -- assignments sepcific to SeqA mode
      if mode = VModeSeqA then
        if hcount = 1380 then
          drive.XV1A <= '1';
          drive.XV1B <= '1';
          drive.XV1C <= '1';
        elsif hcount = 1410 then
          drive.XV4 <= '0';
        elsif hcount = 1440 then
          drive.XV1A <= '0';
          drive.XV1B <= '0';
          drive.XV1C <= '0';
          drive.XV3  <= '1';
        elsif hcount = 1470 then
          drive.XV1 <= '0';
        end if;
      end if;

      -- assignments sepcific to SeqB mode
      if mode = VModeSeqB then
        if hcount = 245 then
          drive.XV4 <= '0';
        elsif hcount = 270 then
          drive.XV3 <= '1';
        elsif hcount = 297 then
          drive.XV1 <= '0';
        elsif hcount = 323 then
          drive.XV4 <= '1';
        elsif hcount = 1530 then
          drive.XV3A <= '1';
          drive.XV3B <= '1';
          drive.XV3C <= '1';
        elsif hcount = 1560 then
          drive.XV2 <= '0';
        elsif hcount = 1590 then
          drive.XV3A <= '0';
          drive.XV3B <= '0';
          drive.XV3C <= '0';
        elsif hcount = 1620 then
          drive.XV1 <= '1';
        elsif hcount = 1650 then
          drive.XV3 <= '0';
        elsif hcount = 1680 then
          drive.XV2 <= '1';
        elsif hcount = 1710 then
          drive.XV4 <= '0';
        end if;
      end if;

      -- sequence "c"
      if mode = VModeSeqC then
        cd_procedure(hcount, c_pulses, c_width);
      end if;

      -- sequence "d"
      if mode = VModeSeqD then
        cd_procedure(hcount, d_pulses, d_width);
      end if;

    end if;
  end process;

end architecture rtl;
