library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.median_filter_pkg.all;

entity MedianSorter_tb is
end MedianSorter_tb;

architecture Behavioral of MedianSorter_tb is
    
    component MedianSorter is
      Generic (N : integer := 9);
      Port (
        clk : in std_logic; 
        arr : in pixel_array(N-1 downto 0);
        median : out std_logic_vector(7 downto 0)
      );
    end component MedianSorter;
    
    signal clk: std_logic := '1';
    signal arr: pixel_array(8 downto 0);
    signal median: std_logic_vector(7 downto 0);
    
    constant Tclk : time := 10ns;
begin
    
    DUT: MedianSorter port map(clk => clk, arr=>arr, median => median);
    clk <= not clk after Tclk/2;
    
    stimulus: process
    begin
        --wait for Tclk;
        arr <= (x"00", x"01", x"02", x"03", x"04", x"05", x"06", x"07", x"08"); -- 04
        wait for TClk;
        arr <= (x"0a", x"21", x"02", x"f3", x"09", x"05", x"20", x"07", x"f2"); -- 0a
        wait for Tclk;
        arr <= (x"02", x"51", x"f2", x"f3", x"60", x"05", x"0c", x"07", x"54"); -- 51
        wait for Tclk;
        arr <= (x"89", x"51", x"25", x"04", x"60", x"05", x"0c", x"07", x"54"); -- 25
        wait for Tclk;
        arr <= (x"00", x"01", x"02", x"03", x"05", x"04", x"06", x"07", x"08"); -- 04
        wait for 2*Tclk;
        arr <= (x"14", x"24", x"02", x"00", x"ff", x"31", x"11", x"07", x"08"); -- 11
        wait for Tclk;
        arr <= (x"14", x"b3", x"02", x"00", x"62", x"de", x"11", x"58", x"a2"); -- 58
        wait for Tclk;
        arr <= (x"a0", x"89", x"02", x"00", x"ff", x"31", x"11", x"07", x"30"); -- 30
        wait for Tclk;
        arr <= (x"14", x"24", x"02", x"12", x"ff", x"31", x"11", x"07", x"08"); -- 12
        wait;
    end process;

end Behavioral;
