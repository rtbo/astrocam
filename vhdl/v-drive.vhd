library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library astrocam;
use astrocam.icx282.all;

entity VerticalDrive is
  port (
    clk     : in std_logic;
    rst     : in std_logic;
    h_count : in h_count_t;
    seq_a   : in std_logic;
    seq_b   : in std_logic;
    seq_c   : in std_logic;
    seq_d   : in std_logic
  );
end entity VerticalDrive;

architecture rtl of VerticalDrive is
begin

end architecture rtl;
