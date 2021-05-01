-- A registry entity that is meant to receive some config options from a mcu.
-- The MCU communicates through a SPI slave.
-- The SPI only receive data, wont send any.
-- When SS is low, a bit will be sampled on each spi_clk rising edge.
-- Groups of 16 bits are expected. 8 bit of address and 8 bit of data.
-- Registers larger than 8 bits will span over the next addresses, with LSB first and MSB last
-- The provided registers are the following
--  address   register  width     Description
--  0x00      SHT_PULS  8 bits    Amount of electronic shutter pulses before start of exposure - default 20
--  0x01      EXP_MS    24 bits   Exposure duration in ms (LSB) - default 100
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.SPI_SLAVE;

entity registry is
  port (
    clk : in std_logic; -- Main system clock
    rst : in std_logic; -- Reset

    spi_clk  : in std_logic;  -- SPI clock issued by master
    spi_cs   : in std_logic;  -- SPI chip select (active low)
    spi_mosi : in std_logic;  -- mosi line from the master
    spi_miso : out std_logic; -- miso line to the master

    SHT_PULS : out unsigned(7 downto 0); -- address 0x00
    EXP_MS   : out unsigned(23 downto 0) -- address 0x01 to 0x03
  );
end registry;

architecture rtl of registry is

  signal spi_miso_msg : std_logic_vector(15 downto 0);
  signal spi_miso_vld : std_logic;
  signal spi_miso_rdy : std_logic;
  signal spi_mosi_msg : std_logic_vector(15 downto 0);
  signal spi_mosi_vld : std_logic;

  signal registry_content : unsigned(31 downto 0);

begin

  SPI_SLAVE_COMP : entity SPI_SLAVE(RTL)
    generic map(
      WORD_SIZE => 16
    )
    port map(
      CLK      => clk,
      RST      => rst,
      SCLK     => spi_clk,
      CS_N     => spi_cs,
      MOSI     => spi_mosi,
      MISO     => spi_miso,
      DIN      => spi_miso_msg,
      DIN_VLD  => spi_miso_vld,
      DIN_RDY  => spi_miso_rdy,
      DOUT     => spi_mosi_msg,
      DOUT_VLD => spi_mosi_vld
    );

  CONTENT_PROC : process (clk)
    variable address : integer;
  begin
    if rst then
      registry_content(7 downto 0)  <= to_unsigned(20, 8);
      registry_content(31 downto 8) <= to_unsigned(100, 8);
    elsif rising_edge(clk) and spi_mosi_vld = '1' then
      address := to_integer(unsigned(spi_mosi_msg(7 downto 0))) * 8;
      if address < 4 then
        registry_content(address + 7 downto address) <= unsigned(spi_mosi_msg(15 downto 8));
      end if;
    end if;
  end process;

  SHT_PULS <= registry_content(7 downto 0);
  EXP_MS   <= registry_content(31 downto 8);

end architecture;
