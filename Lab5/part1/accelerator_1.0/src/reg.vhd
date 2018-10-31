library ieee;
use ieee.std_logic_1164.all;

entity reg is
  generic(
    width : positive := 8);
  port(
    clk : in std_logic;
    rst : in std_logic;
    input : in std_logic;
    output  : out std_logic);
end reg;

architecture BHV of reg is
begin
  process(clk,rst)
  begin
    if (rst = '1') then
      output <= '0';
    elsif (clk'event and clk = '1') then
      output <= input;
    end if;
  end process;
end BHV;
