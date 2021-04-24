library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package counter is

  -- a counter down to zero type
  type counter_t is record
    c  : unsigned;
    en : std_logic;
  end record counter_t;

  function counter_init (val : unsigned) return counter_t;

end package counter;

package body counter is

  function counter_init (val : unsigned) return counter_t is
  begin
    return (c => val, en => '1');
  end function counter_init;

end package body counter;
