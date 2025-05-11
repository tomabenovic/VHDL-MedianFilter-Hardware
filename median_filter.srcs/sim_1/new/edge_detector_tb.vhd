
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity edge_detector_tb is
end edge_detector_tb;

architecture Behavioral of edge_detector_tb is
    component edge_detector is
      Port ( 
        input : in std_logic;
        clk : in std_logic;
        rst : in std_logic;
        
        edge : out std_logic
      );
    end component edge_detector;
    
    signal input : std_logic := '0';
    signal clk : std_logic := '1';
    signal rst : std_logic := '1';
    
    signal edge : std_logic;
    
    constant Tclk : time := 10ns;
begin
    
    DUT: edge_detector port map(clk => clk, rst => rst, input => input, edge => edge);
    
    clk <= not clk after Tclk/2;
    
    STIMULUS: process is
    begin
        wait for 3ns;
        input <= '1';
        wait for 11*Tclk;
        input <= '0';
        wait for 5 ns;
        rst <= '0';
        wait for 3*Tclk;
        input <= '1';
        wait for 5*Tclk;
        input <= '0';
        wait for 2*Tclk;
        input <= '1';
        wait for 15*Tclk;
        input <= '0';
        wait for 5 ns;
        rst <= '1';
        
        wait;
    end process;

end Behavioral;
