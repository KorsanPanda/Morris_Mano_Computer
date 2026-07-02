library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BasicComputer is
    Port (
        clk        : in  std_logic;
		  ps2_clk : in std_logic;
		  ps2_data : in  std_logic;
		  ps2_code : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		  ps2_code_new : OUT STD_LOGIC;
        reset      : in  std_logic;
		  --fgi        : out  std_logic;
        INPR       : in  std_logic_vector(7 downto 0);
        OUTR       : out std_logic_vector(7 downto 0);
        timeCount  : out std_logic_vector(3 downto 0);
		  kontrol : out std_logic;
		  seg : out std_logic_vector(6 downto 0);
		  an : out std_logic_vector(3 downto 0)
    );
end BasicComputer;

architecture Behavioral of BasicComputer is

    component memory2
        Port (
            clka  : in  std_logic;
            wea   : in  std_logic_vector(0 downto 0);
            addra : in  std_logic_vector(15 downto 4);
            dina  : in  std_logic_vector(15 downto 0);
            douta : out std_logic_vector(15 downto 0)
        );
    end component;
	 
	 component ps2_keyboard_to_ascii
        generic (
        clk_freq                  : integer := 50000000;
        ps2_debounce_counter_size : integer := 8
		  );
		  port (
			  clk        : in  std_logic;
			  ps2_clk    : in  std_logic;
			  ps2_data   : in  std_logic;
			  ascii_new  : out std_logic;
			  ascii_code : out std_logic_vector(7 downto 0)
		  );
    end component;
	 
	 component clock_divider_1hz is
    Port (
        clk      : in  std_logic;  -- 50 MHz input clock
        reset    : in  std_logic;
        clk_out  : out std_logic   -- 1 Hz output clock
    );
	 end component;
	 
	 component Display  is
    port (
        disp_in : in std_logic_vector(15 downto 0) ; 
        clk : in std_logic; --50Mhz 
        seg : out std_logic_vector(6 downto 0);
        an : out std_logic_vector(3 downto 0) 

    );
	end component;


    signal IR, DR, AC : std_logic_vector(15 downto 0) := (others => '0');
    --signal TR         : std_logic_vector(11 downto 0) := (others => '0');
    signal AR     : std_logic_vector(11 downto 0) := (others => '0');
	 signal PC     : std_logic_vector(11 downto 0) := (others => '0');
    signal OUTR_reg   : std_logic_vector(7 downto 0) := (others => '0');
    signal TR_backup  : std_logic_vector(11 downto 0) := (others => '0');

    signal ien        : std_logic := '0';
    signal interrupt  : std_logic := '0';
    signal interrupt_state : std_logic_vector(1 downto 0) := (others => '0');
--    signal fgi        : std_logic := '0';	 
    signal fgi_int    : std_logic := '0';
    signal fgo        : std_logic := '0';
    signal S          : std_logic := '1';

    signal mem_wait   : std_logic_vector(1 downto 0) := (others => '0');
    signal I          : std_logic := '0';
    signal E          : std_logic := '0';

    signal mem_addr   : std_logic_vector(15 downto 4);
    signal mem_din    : std_logic_vector(15 downto 0);
    signal mem_we     : std_logic_vector(0 downto 0) := (others => '0');
    signal mem_dout   : std_logic_vector(15 downto 0);
    signal timeCount_reg : std_logic_vector(3 downto 0) := (others => '0');
	 
	 --signal ps2_clk_sig, ps2_data_sig : std_logic;
	 signal ascii_new_sig             : std_logic;
	 signal ascii_code_sig            : std_logic_vector(7 downto 0);
	 --signal kontrol_s : std_logic;
	 signal clk_1Hz : std_logic;


begin

    OUTR <= OUTR_reg;
    timeCount <= timeCount_reg;
	 ps2_code_new <= ascii_new_sig;
	 ps2_code <= ascii_code_sig;
	 kontrol <= clk_1Hz;

    mem_inst : memory2
        port map (
            clka  => clk,
            wea   => mem_we,
            addra => mem_addr,
            dina  => mem_din,
            douta => mem_dout
        );
		  
	 ps2_inst : ps2_keyboard_to_ascii
    generic map (
        clk_freq => 50000000,
        ps2_debounce_counter_size => 8
    )
    port map (
        clk        => clk,
        ps2_clk    => ps2_clk,
        ps2_data   => ps2_data,
        ascii_new  => ascii_new_sig,
        ascii_code => ascii_code_sig
    );
	 
	 clock_divider :  clock_divider_1hz

    Port map (
        clk      => clk,
        reset    => reset,
        clk_out  => clk_1Hz
    );
	 
	 disp : Display
    port map (
        disp_in => IR,
        clk => clk,
		  seg => seg,
        an => an

    );

    process(clk_1Hz)
        variable temp_sum : unsigned(16 downto 0);
    begin
        if rising_edge(clk_1Hz) then
            if reset = '1' then
                PC <= "000000000000";
                S <= '0';
                timeCount_reg <= (others => '0');
                ien <= '0';
                interrupt <= '0';
                fgi_int <= '0';
                I <= '0';
                E <= '0';
                AC <= (others => '0');
                AR <= (others => '0');
                DR <= (others => '0');
                IR <= (others => '0');
                --TR <= (others => '0');
                OUTR_reg <= (others => '0');
				else if S = '0' then
					 PC <= "000000000000";
                S <= '1';
                timeCount_reg <= (others => '0');
                ien <= '0';
                interrupt <= '0';
                fgi_int <= '0';
                I <= '0';
                E <= '0';
                AC <= (others => '0');
                AR <= (others => '0');
                DR <= (others => '0');
                IR <= (others => '0');
                --TR <= (others => '0');
                OUTR_reg <= (others => '0');
            else
                mem_we <= "0";
                if unsigned(mem_wait) < 2 then
                    mem_wait <= std_logic_vector(unsigned(mem_wait) + 1);
                else
                    mem_wait <= (others => '0');
                    if ascii_new_sig = '1' then
                        fgi_int <= '1';
                    end if;
                    if ien = '1' and (fgi_int = '1' or fgo = '1') and interrupt = '0' and not (timeCount_reg = "0000" or timeCount_reg = "0001" or timeCount_reg = "0010") then
                        interrupt <= '1';
                    end if;

                    if interrupt = '1' or interrupt_state /= "00" then
                        case interrupt_state is
                            when "00" => AR <= (others => '0'); TR_backup <= PC; interrupt_state <= "01";
                            when "01" => mem_addr <= AR; mem_din <= (others => '0');
                                mem_din(15 downto 4) <= TR_backup; mem_we <= "1"; PC <= (others => '0'); interrupt_state <= "10";
                            when "10" => PC <= std_logic_vector(unsigned(PC) + 1); ien <= '0'; interrupt <= '0'; interrupt_state <= "00"; timeCount_reg <= (others => '0');
                            when others => null;
                        end case;
                    elsif timeCount_reg = "0000" then AR <= PC; timeCount_reg <= "0001";
                    elsif timeCount_reg = "0001" then mem_addr <= AR; PC <= std_logic_vector(unsigned(PC) + 1); timeCount_reg <= "0010";
                    elsif timeCount_reg = "0010" then IR <= mem_dout; AR <= mem_dout(15 downto 4); I <= mem_dout(0); timeCount_reg <= "0011";
						  elsif timeCount_reg = "0011" then mem_addr <= AR; timeCount_reg <= "0100";
                    elsif timeCount_reg = "0100" then if IR(3 downto 1) /= "111" and I = '1' then AR <= mem_dout(15 downto 4); timeCount_reg <= "0101"; else timeCount_reg <= "0101"; end if;
                    else
                        if IR(3 downto 1) = "111" then
                            if I = '1' then
                                if AR(11) = '1' then AC(11 downto 4) <= INPR; fgi_int <= '0'; timeCount_reg <= (others => '0');
                                elsif AR(10) = '1' then OUTR_reg <= AC(11 downto 4); fgo <= '0'; timeCount_reg <= (others => '0');
                                elsif AR(9) = '1' then if fgi_int = '1' then PC <= std_logic_vector(unsigned(PC) + 1); end if; timeCount_reg <= (others => '0');
                                elsif AR(8) = '1' then if fgo = '1' then PC <= std_logic_vector(unsigned(PC) + 1); end if; timeCount_reg <= (others => '0');
                                elsif AR(7) = '1' then ien <= '1'; timeCount_reg <= (others => '0');
                                elsif AR(6) = '1' then ien <= '0'; timeCount_reg <= (others => '0');
                                end if;
                            else
                                if AR(11) = '1' then AC <= (others => '0'); timeCount_reg <= (others => '0');
                                elsif AR(10) = '1' then E <= '0'; timeCount_reg <= (others => '0');
                                elsif AR(9) = '1' then AC <= not AC; timeCount_reg <= (others => '0');
                                elsif AR(8) = '1' then E <= not E; timeCount_reg <= (others => '0');
                                elsif AR(7) = '1' then AC <= E & AC(14 downto 0); E <= AC(15); timeCount_reg <= (others => '0');
                                elsif AR(6) = '1' then AC <= AC(15 downto 1) & E; E <= AC(0); timeCount_reg <= (others => '0');
                                elsif AR(5) = '1' then AC <= std_logic_vector(unsigned(AC) + 1); timeCount_reg <= (others => '0');
                                elsif AR(4) = '1' then if AC(15) = '0' then PC <= std_logic_vector(unsigned(PC) + 1); end if; timeCount_reg <= (others => '0');
                                elsif AR(3) = '1' then if AC(15) = '1' then PC <= std_logic_vector(unsigned(PC) + 1); end if; timeCount_reg <= (others => '0');
                                elsif AR(2) = '1' then if AC = x"0000" then PC <= std_logic_vector(unsigned(PC) + 1); end if; timeCount_reg <= (others => '0');
                                elsif AR(1) = '1' then if E = '0' then PC <= std_logic_vector(unsigned(PC) + 1); end if; timeCount_reg <= (others => '0');
                                else S <= '0'; timeCount_reg <= (others => '0');
                                end if;
                            end if;
                        elsif IR(3 downto 1) = "000" then -- AND
                            if timeCount_reg = "0101" then mem_addr <= AR; timeCount_reg <= "0110";
                            elsif timeCount_reg = "0110" then DR <= mem_dout; timeCount_reg <= "0111";
                            else AC <= AC and DR; timeCount_reg <= (others => '0');
                            end if;
                        elsif IR(3 downto 1) = "001" then -- ADD
                            if timeCount_reg = "0101" then mem_addr <= AR; timeCount_reg <= "0110";
                            elsif timeCount_reg = "0110" then DR <= mem_dout; timeCount_reg <= "0111";
                            else temp_sum := unsigned('0' & AC) + unsigned(DR); E <= temp_sum(16); AC <= std_logic_vector(temp_sum(15 downto 0)); timeCount_reg <= (others => '0');
                            end if;
                        elsif IR(3 downto 1) = "010" then -- LDA
                            if timeCount_reg = "0101" then mem_addr <= AR; timeCount_reg <= "0110";
                            elsif timeCount_reg = "0110" then DR <= mem_dout; timeCount_reg <= "0111";
                            else AC <= DR; timeCount_reg <= (others => '0');
                            end if;
                        elsif IR(3 downto 1) = "011" then -- STA
                            mem_addr <= AR; mem_din <= AC; mem_we <= "1"; timeCount_reg <= (others => '0');
                        elsif IR(3 downto 1) = "100" then -- BUN
                            PC <= AR; timeCount_reg <= (others => '0');
                        elsif IR(3 downto 1 ) = "101" then -- BSA
                            if timeCount_reg = "0101" then mem_addr <= AR; mem_din <= (others => '0'); mem_din(15 downto 4) <= PC; mem_we <= "1"; AR <= std_logic_vector(unsigned(AR) + 1); timeCount_reg <= "0110";
                            else PC <= AR; timeCount_reg <= (others => '0');
                            end if;
                        elsif IR(3 downto 1) = "110" then -- ISZ
                            if timeCount_reg = "0101" then mem_addr <= AR; timeCount_reg <= "0110";
                            elsif timeCount_reg = "0110" then DR <= std_logic_vector(unsigned(mem_dout) + 1); timeCount_reg <= "0111";
                            else mem_din <= DR; mem_we <= "1"; if DR = x"0000" then PC <= std_logic_vector(unsigned(PC) + 1); end if; timeCount_reg <= (others => '0');
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;
		  end if;
    end process;

end Behavioral;