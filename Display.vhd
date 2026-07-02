library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Display is
    port(
        clk      : in  std_logic;
        an       : out std_logic_vector(3 downto 0);
        seg      : out std_logic_vector(6 downto 0);
        disp_in  : in  std_logic_vector(15 downto 0)  -- tek 16-bit giriş
    );
end Display;

architecture Behavioral of Display is
    signal refresh_counter : unsigned(15 downto 0) := (others => '0');
    signal digit_selector  : std_logic_vector(1 downto 0) := "00";
    signal digit_data      : std_logic_vector(3 downto 0) := (others => '0');
begin

    -- Clock bölücü: yavaşlatılmış refresh clock
    process(clk)
    begin
        if rising_edge(clk) then
            refresh_counter <= refresh_counter + 1;
            if refresh_counter = 49999 then  -- yaklaşık 1ms
                refresh_counter <= (others => '0');
                digit_selector <= std_logic_vector(unsigned(digit_selector) + 1);
            end if;
        end if;
    end process;

    -- Hangi hane aktif? Hangi 4 bit gösterilecek?
    process(digit_selector, disp_in)
    begin
        case digit_selector is
            when "00" =>
                an <= "1110";  -- Display 0 aktif
                digit_data <= disp_in(3 downto 0);
            when "01" =>
                an <= "1101";  -- Display 1 aktif
                digit_data <= disp_in(7 downto 4);
            when "10" =>
                an <= "1011";  -- Display 2 aktif
                digit_data <= disp_in(11 downto 8);
            when others =>
                an <= "0111";  -- Display 3 aktif
                digit_data <= disp_in(15 downto 12);
        end case;
    end process;

    -- BCD to 7-segment decoder (aktif düşük)
    with digit_data select
        seg <= "0000001" when "0000",  -- 0
               "1001111" when "0001",  -- 1
               "0010010" when "0010",  -- 2
               "0000110" when "0011",  -- 3
               "1001100" when "0100",  -- 4
               "0100100" when "0101",  -- 5
               "0100000" when "0110",  -- 6
               "0001111" when "0111",  -- 7
               "0000000" when "1000",  -- 8
               "0000100" when "1001",  -- 9
               "0000010" when "1010",  -- A
               "1100000" when "1011",  -- b
               "0110001" when "1100",  -- C
               "1000010" when "1101",  -- d
               "0110000" when "1110",  -- E
               "0111000" when "1111",  -- F
               "1111111" when others;  -- boş

end Behavioral;