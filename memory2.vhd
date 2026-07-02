library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memory2 is
    Port (
        clka   : in  std_logic;
        wea    : in  std_logic_vector(0 downto 0);     -- write enable
        addra  : in  std_logic_vector(15 downto 4);    -- 12-bit address
        dina   : in  std_logic_vector(15 downto 0);    -- data in
        douta  : out std_logic_vector(15 downto 0)     -- data out
    );
end memory2;
architecture Behavioral of memory2 is
    type ram_type is array (0 to 4095) of std_logic_vector(15 downto 0);
    signal RAM : ram_type := (
        0  => x"0064",  1  => x"0072",  2  => x"0086",  3  => x"0084",
        4  => x"400f",  5  => x"001e",  6  => x"0002",  7  => x"0003",
        8  => x"0000",  9  => x"0000", 10  => x"0000", 11  => x"0000",
        12 => x"0000", 13 => x"0000", 14 => x"0000", 15 => x"0000",
        16 => x"0000", 17 => x"0000", 18 => x"0000", 19 => x"0000",
        20 => x"0000", 21 => x"0000", 22 => x"0000", 23 => x"0000",
        24 => x"0000", 25 => x"0000", 26 => x"0000", 27 => x"0000",
        28 => x"0000", 29 => x"0000",
        others => (others => '0')  -- kalanları sıfırla
    );
    signal dout_reg : std_logic_vector(15 downto 0);
begin

    process(clka)
    begin
        if rising_edge(clka) then
            if wea(0) = '1' then
                RAM(to_integer(unsigned(addra))) <= dina;
            end if;
            dout_reg <= RAM(to_integer(unsigned(addra)));
        end if;
    end process;

    douta <= dout_reg;

end Behavioral;