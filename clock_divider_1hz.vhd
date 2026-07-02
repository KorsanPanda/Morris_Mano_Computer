library IEEE;

use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;



entity clock_divider_1hz is

    Port (

        clk      : in  std_logic;  -- 50 MHz input clock

        reset    : in  std_logic;

        clk_out  : out std_logic   -- 1 Hz output clock

    );

end clock_divider_1hz;



architecture Behavioral of clock_divider_1hz is

    constant DIVISOR : integer := 12_500_000;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                

    signal counter   : integer range 0 to DIVISOR-1 := 0;

    signal clk_reg   : std_logic := '0';

begin



    process(clk, reset)

    begin

        if reset = '1' then

            counter <= 0;

            clk_reg <= '0';

        elsif rising_edge(clk) then

            if counter = DIVISOR/2 - 1 then

                clk_reg <= not clk_reg;

                counter <= 0;

            else

                counter <= counter + 1;

            end if;

        end if;

    end process;



    clk_out <= clk_reg;



end Behavioral;