library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.median_filter_pkg.all;

entity systolic_MedianSorter_tb is
    generic(N : integer := 25); -- ovde unesite broj elemenata niza za izdvajanje medijane (9, 25, 49)
end systolic_MedianSorter_tb;

architecture Behavioral of systolic_MedianSorter_tb is
    
    component systolic_MedianSorter is
      Generic (N : integer);
      Port (
        clk : in std_logic; 
        arr : in pixel_array(N-1 downto 0);
        median : out std_logic_vector(7 downto 0)
      );
    end component systolic_MedianSorter;
    
    signal clk: std_logic := '0';
    signal arr: pixel_array(0 to N-1);
    signal median: std_logic_vector(7 downto 0);
    
    constant Tclk : time := 10ns;
begin
    
    DUT: systolic_MedianSorter generic map(N => N) port map(clk => clk, arr=>arr, median => median);
    clk <= not clk after Tclk/2;
    
--    stimulus: process
--    begin
--        arr <= (x"00", x"01", x"02", x"03", x"04", x"05", x"06", x"07", x"08"); -- 04
--        wait for TClk;
--        arr <= (x"0a", x"21", x"02", x"f3", x"09", x"05", x"20", x"07", x"f2"); -- 0a
--        wait for Tclk;
--        arr <= (x"02", x"51", x"f2", x"f3", x"60", x"05", x"0c", x"07", x"54"); -- 51
--        wait for Tclk;
--        arr <= (x"89", x"51", x"25", x"04", x"60", x"05", x"0c", x"07", x"54"); -- 25
--        wait for Tclk;
--        arr <= (x"00", x"01", x"02", x"03", x"05", x"04", x"06", x"07", x"08"); -- 04
--        wait for 2*Tclk;
--        arr <= (x"14", x"24", x"02", x"00", x"ff", x"31", x"11", x"07", x"08"); -- 11
--        wait for Tclk;
--        arr <= (x"14", x"b3", x"02", x"00", x"62", x"de", x"11", x"58", x"a2"); -- 58
--        wait for Tclk;
--        arr <= (x"a0", x"89", x"02", x"00", x"ff", x"31", x"11", x"07", x"30"); -- 30
--        wait for Tclk;
--        arr <= (x"14", x"24", x"02", x"12", x"ff", x"31", x"11", x"07", x"08"); -- 12
--        wait;
--    end process;
    --arr <= (x"", x"", x"", x"", x"", x"", x"", x"", x"", x"", x"", x"", x"", x"", x"", x"", x"", x"", x"", x"", x"", x"", x"", x"", x"");
    stimulus: process
    begin
        arr <= (x"23", x"45", x"78", x"01", x"13", x"a4", x"7a", x"31", x"27", x"b4", x"e5", x"c3", x"97", x"10", x"02", x"65", x"47", x"d2", x"de", x"e7", x"f5", x"c4", x"00", x"3c", x"47");
        wait for Tclk;
        arr <= (x"64", x"45", x"78", x"01", x"13", x"a4", x"7a", x"31", x"27", x"b4", x"e5", x"c3", x"97", x"10", x"02", x"23", x"47", x"d2", x"de", x"e7", x"f5", x"c4", x"00", x"3c", x"47");
        wait for Tclk;
        arr <= (x"45", x"62", x"78", x"01", x"13", x"a4", x"7a", x"31", x"27", x"b4", x"e5", x"c3", x"97", x"10", x"02", x"23", x"47", x"d2", x"de", x"e7", x"f5", x"c4", x"00", x"3c", x"47");
        wait for Tclk;
        arr <= (x"78", x"45", x"61", x"01", x"13", x"a4", x"7a", x"31", x"27", x"b4", x"e5", x"c3", x"97", x"10", x"02", x"23", x"47", x"d2", x"de", x"e7", x"f5", x"c4", x"00", x"3c", x"47");
        wait for Tclk;
        arr <= (x"01", x"45", x"78", x"67", x"13", x"a4", x"7a", x"31", x"27", x"b4", x"e5", x"c3", x"97", x"10", x"02", x"23", x"47", x"d2", x"de", x"e7", x"f5", x"c4", x"00", x"3c", x"47");
        wait for Tclk;
        arr <= (x"13", x"45", x"78", x"01", x"6a", x"a4", x"7a", x"31", x"27", x"b4", x"e5", x"c3", x"97", x"10", x"02", x"23", x"47", x"d2", x"de", x"e7", x"f5", x"c4", x"00", x"3c", x"47");
        wait for Tclk;
        arr <= (x"a4", x"45", x"78", x"01", x"13", x"6c", x"7a", x"31", x"27", x"b4", x"e5", x"c3", x"97", x"10", x"02", x"23", x"47", x"d2", x"de", x"e7", x"f5", x"c4", x"00", x"3c", x"47");
        wait for 2*Tclk;
        arr <= (x"7a", x"45", x"78", x"01", x"13", x"a4", x"6f", x"31", x"27", x"b4", x"e5", x"c3", x"97", x"10", x"02", x"23", x"47", x"d2", x"de", x"e7", x"f5", x"c4", x"00", x"3c", x"47");
        wait for Tclk;
        arr <= (x"31", x"45", x"78", x"01", x"13", x"a4", x"7a", x"70", x"27", x"b4", x"e5", x"c3", x"97", x"10", x"02", x"23", x"47", x"d2", x"de", x"e7", x"f5", x"c4", x"00", x"3c", x"47");
        wait for 3*Tclk;
        arr <= (x"27", x"45", x"78", x"01", x"13", x"a4", x"7a", x"31", x"77", x"b4", x"e5", x"c3", x"97", x"10", x"02", x"23", x"47", x"d2", x"de", x"e7", x"f5", x"c4", x"00", x"3c", x"47");
        wait for Tclk;
        arr <= (x"b4", x"45", x"78", x"01", x"13", x"a4", x"7a", x"31", x"27", x"78", x"e5", x"c3", x"97", x"10", x"02", x"23", x"47", x"d2", x"de", x"e7", x"f5", x"c4", x"00", x"3c", x"47");
        wait for Tclk;
        arr <= (x"e5", x"45", x"78", x"01", x"13", x"a4", x"7a", x"31", x"27", x"b4", x"50", x"c3", x"97", x"10", x"02", x"23", x"47", x"d2", x"de", x"e7", x"f5", x"c4", x"00", x"3c", x"47");
    wait;    
    end process;

end Behavioral;

