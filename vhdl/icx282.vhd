-- Constants and types related to the ICX282 CCD sensor.
-- This sensor is driven by horizontal and vertical signals.
-- Horizontal is more or less always the same and each cycle correspond to one line of pixels
-- Vertical is more complex and determine the read out mode
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package icx282 is
    constant H_PIXELS    : integer := 2658; -- total number of horizontal pixels
    constant H_IGN_LEFT  : integer := 16;   -- how many pixels to ignore on the left
    constant H_IGN_RIGHT : integer := 62;   -- how many pixels to ignore on the right
    constant H_DUMMY     : integer := 28;   -- amount of dummy bits (non-reading pulses per line)
    constant H_VSYNC     : integer := 208;  -- number of hor. clk cycles during the vertical sync (once every line)

    constant V_PIXELS     : integer := 1970; -- total number of vertical pixels (lines)
    constant V_IGN_BOTTOM : integer := 16;   -- how many pixels to ignore on the bottom
    constant V_IGN_TOP    : integer := 10;   -- how many pixels to ignore on the top
    constant V_DUMMY      : integer := 1;

    constant H_EFF_PIXELS : integer := H_PIXELS - H_IGN_LEFT - H_IGN_RIGHT;
    constant V_EFF_PIXELS : integer := V_PIXELS - V_IGN_BOTTOM - V_IGN_TOP;

    constant H_CLK_COUNT : integer := H_PIXELS + H_DUMMY + H_VSYNC;           -- number of clock cycles per line
    constant H_CLK_BITS  : integer := integer(ceil(log2(real(H_CLK_COUNT)))); -- number of bits to hold the horizontal counter

    subtype h_count_t is integer range 0 to H_CLK_COUNT - 1;            -- integer to store the horizontal counter
    subtype h_count_bus_t is unsigned(H_CLK_BITS - 1 downto 0); -- signal bus to store the horizontal counter
    -- subtype h_count_bus_t is unsigned; -- signal bus to store the horizontal counter


    type v_seq_t is (Reg, SeqA, SeqB, SeqC, SeqD); -- the different sequences in the vertical driver
end package;
