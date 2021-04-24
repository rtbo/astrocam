-- vertical_drive_LineAB entity deals with vertical driving signals
-- in the main line mode as well as sequences A and B that have
-- a lot in common with the main line.
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
    -- whether to reinitialize the bus at H=0
    mode : in v_mode_t;
    -- the vertical driving signal output
    drive : out v_drive_bus_t := DEFAULT_VDRIVE
  );
end entity vertical_drive;

architecture rtl of vertical_drive is
begin

  DRIVE_PROC : process (clk, rst) is
    variable counter : integer;
  begin
    if rst then

      drive <= DEFAULT_VDRIVE;

    elsif rising_edge(clk) then

      counter := to_integer(h_counter);

      -- common assignments
      if mode = VModeLine or mode = VModeSeqA or mode = VModeSeqB then
        case counter is
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
        if counter = 245 then
          drive.XV4 <= '0';
        end if;
      end if;

      -- assignments sepcific to SeqA mode
      if mode = VModeSeqA then
        if counter = 1380 then
          drive.XV1A <= '1';
          drive.XV1B <= '1';
          drive.XV1C <= '1';
        elsif counter = 1410 then
          drive.XV4 <= '0';
        elsif counter = 1440 then
          drive.XV1A <= '0';
          drive.XV1B <= '0';
          drive.XV1C <= '0';
          drive.XV3  <= '1';
        elsif counter = 1470 then
          drive.XV1 <= '0';
        end if;
      end if;

      -- assignments sepcific to SeqB mode
      if mode = VModeSeqB then
        if counter = 245 then
          drive.XV4 <= '0';
        elsif counter = 270 then
          drive.XV3 <= '1';
        elsif counter = 297 then
          drive.XV1 <= '0';
        elsif counter = 323 then
          drive.XV4 <= '1';
        elsif counter = 1530 then
          drive.XV3A <= '1';
          drive.XV3B <= '1';
          drive.XV3C <= '1';
        elsif counter = 1560 then
          drive.XV2 <= '0';
        elsif counter = 1590 then
          drive.XV3A <= '0';
          drive.XV3B <= '0';
          drive.XV3C <= '0';
        elsif counter = 1620 then
          drive.XV1 <= '1';
        elsif counter = 1650 then
          drive.XV3 <= '0';
        elsif counter = 1680 then
          drive.XV2 <= '1';
        elsif counter = 1710 then
          drive.XV4 <= '0';
        end if;
      end if;

    end if;
  end process;

end architecture rtl;
