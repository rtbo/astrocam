-- A simple countdown cnt module
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package counter is

  -- a cnt down to zero type
  type counter_t is record
    c  : unsigned;
    en : std_logic;
  end record counter_t;

  -- enable a counter with a starting count
  procedure counter_enable(signal cnt : out counter_t; val : integer);

  -- disable a counter
  procedure counter_disable(signal cnt : out counter_t);

  -- check whether the counter is enabled
  function counter_enabled(signal cnt : counter_t) return boolean;

  -- check whether the counter has remaining steps
  function counter_done (signal cnt : counter_t) return boolean;

  -- step a counter and return whether the countdown reached 0
  procedure counter_step(
    signal cnt : inout counter_t;
    steps          : integer := 1
  );

end package counter;

package body counter is

  procedure counter_enable(signal cnt : out counter_t; val : integer) is
  begin
    cnt <= (c => to_unsigned(val, cnt.c'length), en => '1');
  end procedure counter_enable;

  procedure counter_disable(signal cnt : out counter_t) is
  begin
    cnt <= (c => to_unsigned(0, cnt.c'length), en => '0');
  end procedure counter_disable;

  function counter_enabled(signal cnt : counter_t) return boolean is
  begin
    return cnt.en = '1';
  end function counter_enabled;

  function counter_done (signal cnt : counter_t) return boolean is
  begin
    return cnt.c = 0;
  end function;

  procedure counter_step(
    signal cnt : inout counter_t;
    steps          : integer:=1) is
  begin
    assert cnt.en = '1' report "step on disabled cnt" severity failure;
    assert cnt.c >= steps report "cnt step higher than the remaining count" severity failure;
    cnt.c <= cnt.c - steps;
  end procedure counter_step;

end package body counter;
