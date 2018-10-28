library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.config_pkg.all;
use work.user_pkg.all;
--input address generator

--read address generator is 0, write address generator is 1
entity address_generator is
  port(
    mode : in std_logic; --0 for reading, 1 for writing
    clk : in std_logic;
    rst : in std_logic;
    en : in std_logic; --to count up
    input : in std_logic_vector(C_MMAP_ADDR_WIDTH - 1 downto 0);
    max_value : in std_logic_vector(C_MMAP_ADDR_WIDTH - 1 downto 0);
    go : in std_logic;
    valid : in std_logic;
    done : out std_logic;
    output : out std_logic_vector(C_MMAP_ADDR_WIDTH -1 downto 0);
    read_en : out std_logic;--used as valid in for data path
    write_en : out std_logic
  );
end address_generator;

architecture PROC1 of address_generator is
    type STATE_TYPE is (INIT_S, WAIT_S, COUNT_IS, DONE_S,
                        CHECK_OS);
    signal state, next_state   : STATE_TYPE;
    signal count : unsigned(C_MMAP_ADDR_WIDTH - 1 downto 0);
  --  signal read_en_reg : std_logic_vector;
  begin
    process(clk, rst)
    begin
      if(rst = '1') then
        state <= INIT_S;
        count <= (others => '0');
  --      done <= '0';
        read_en <= '0';
    --    read_en_reg <= '0';
    --    write_en <= '0';
    elsif(rising_edge(clk)) then
    --    read_en <= read_en_reg;
        write_en <= '0';
        done <= '0';
        case state is
          when INIT_S =>
          --  done <= '0';
            count <= (others => '0');
            state <= WAIT_S;
--            read_en_reg <= '0';
          when WAIT_S =>
            if(go = '0') then
              state <= WAIT_S;
            else
              if(mode = '0') then --read address generator, go to proper set of states
                state <= COUNT_IS;
              else
                state <= CHECK_OS; --write address generator, go to proper set of states
              end if;
            end if;
          when COUNT_IS =>
            if(unsigned(count) <= unsigned(max_value)) then
              count <= count + 1;
              state <= COUNT_IS;
              read_en <= '1';
            else
              state <= DONE_S;
            end if;

          when CHECK_OS =>
            if(valid = '1') then
              write_en <= '1';
              if(unsigned(count) <= unsigned(max_value)) then
                count <= count + 1;
                state <= CHECK_OS; --stay in this state
              else
                state <= DONE_S;
              end if;
            else
              state <= CHECK_OS;
            end if;
          when DONE_S =>
            done <= '1';
            if(go = '1') then
              state <= DONE_S;
            else
              state <= INIT_S;
            end if;
          end case;
        end if;
    end process;

    output <= std_logic_vector(count);


  end PROC1;