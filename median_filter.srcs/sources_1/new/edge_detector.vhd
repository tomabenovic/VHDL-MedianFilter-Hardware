library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity edge_detector is
  Port ( 
    input : in std_logic;
    clk : in std_logic;
    rst : in std_logic;
    
    edge : out std_logic
  );
end edge_detector;

architecture Behavioral of edge_detector is
    
    constant DEBOUNCE_C : integer := 10;
    type state_type is (idle, count, check, detected, hold);
    signal state_reg, next_state : state_type;
    signal cnt : integer := 0;
begin
    
    STATE_TRANSITON: process(clk) is
    begin
        if(rising_edge(clk)) then
            if(rst = '1') then
                state_reg <= idle;
            else
                state_reg <= next_state;
            end if;
        end if;
    end process;
    
    CNT_PROC: process(clk) is
    begin
        if(rising_edge(clk)) then
            if(state_reg = count and input = '1') then 
                cnt <= cnt + 1;
            else
                cnt <= 0;
            end if;
        end if;
    end process;

    NEXT_STATE_LOGIC: process(state_reg, input, cnt) is
    begin
        edge <= '0';
        case state_reg is
            when idle =>    
                if(input = '1') then    
                    next_state <= count;
                else
                    next_state <= idle;
                end if;
            when count =>   
                if(cnt = DEBOUNCE_C) then
                    next_state <= check;
                else
                    next_state <= count;
                end if;
            when check =>
                if(input = '1') then
                    next_state <= detected;
                else
                    next_state <= idle;
                end if;
            when detected =>
                next_state <= hold;
                edge <= '1';
            when hold =>
                if(input = '1') then
                    next_state <= idle;
                else
                    next_state <= hold;
                end if;
        end case;    
    end process;
    
end Behavioral;
