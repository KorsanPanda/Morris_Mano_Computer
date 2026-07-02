library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BasicComputer_tb is
end BasicComputer_tb;

architecture sim of BasicComputer_tb is

    component BasicComputer
        Port (
            clk        : in  std_logic;
            ps2_clk    : in  std_logic;
            ps2_data   : in  std_logic;
            ps2_code   : out std_logic_vector(7 downto 0);
            ps2_code_new : out std_logic;
            reset      : in  std_logic;
            INPR       : in  std_logic_vector(7 downto 0);
            OUTR       : out std_logic_vector(7 downto 0);
            timeCount  : out std_logic_vector(3 downto 0);
            kontrol    : out std_logic;
            seg        : out std_logic_vector(6 downto 0);
            an         : out std_logic_vector(3 downto 0)
        );
    end component;

    signal clk        : std_logic := '0';
    signal ps2_clk    : std_logic := '1';
    signal ps2_data   : std_logic := '1';
    signal ps2_code   : std_logic_vector(7 downto 0);
    signal ps2_code_new : std_logic;
    signal reset      : std_logic := '1';
    signal INPR       : std_logic_vector(7 downto 0) := (others => '0');
    signal OUTR       : std_logic_vector(7 downto 0);
    signal timeCount  : std_logic_vector(3 downto 0);
    signal kontrol    : std_logic;
    signal seg        : std_logic_vector(6 downto 0);
    signal an         : std_logic_vector(3 downto 0);

begin

    -- Clock generation (50 MHz)
    clk_process : process
    begin
        while true loop
            clk <= '0'; wait for 10 ns;
            clk <= '1'; wait for 10 ns;
        end loop;
    end process;

    -- PS2 clock generation (simulated)
    ps2_clk_process : process
    begin
        while true loop
            ps2_clk <= '0'; wait for 50 us;
            ps2_clk <= '1'; wait for 50 us;
        end loop;
    end process;

    -- DUT
    uut: BasicComputer
        port map (
            clk         => clk,
            ps2_clk     => ps2_clk,
            ps2_data    => ps2_data,
            ps2_code    => ps2_code,
            ps2_code_new => ps2_code_new,
            reset       => reset,
            INPR        => INPR,
            OUTR        => OUTR,
            timeCount   => timeCount,
            kontrol     => kontrol,
            seg         => seg,
            an          => an
        );

    stimulus : process
    begin
        -- Initial reset
        wait for 100 ns;
        reset <= '0';

        -- Simulate normal operation for some time
        wait for 1 ms;

        -- Simulate some input
        INPR <= "01010101";
        wait for 100 us;

        -- Continue simulation for a bit longer
        wait for 10 ms;

        -- Finish simulation
        assert false report "Simulation Ended" severity failure;
    end process;

end sim;
