library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.RAM_definitions_PK.all;

entity median_filter_tb is
end median_filter_tb;

architecture Behavioral of median_filter_tb is
    component median_filter is
        generic(
            MASK : integer;                -- velicina maske za filtriranje
            G_IMAGE_WIDTH : integer;      
            G_IMAGE_HEIGHT : integer;
            G_PIXEL_SIZE : integer;
            G_RAM_PERFORMANCE : string;
            G_INIT_FILENAME : string
        );
    
        Port ( 
            input : in std_logic;
            reset : in std_logic;
            clk : in std_logic;
        
            filtered : out std_logic; -- oznacava kraj filtriranja
            dout : out std_logic_vector(G_PIXEL_SIZE-1 downto 0);
            read : out std_logic
            
        );
    end component median_filter;
    
    constant Tclk : time := 4ns;
    
    signal input : std_logic := '0';
    signal reset : std_logic := '1';
    signal clk : std_logic := '1';
    
    signal read : std_logic;
    signal filtered : std_logic; 
    signal dout : std_logic_vector(7 downto 0);
begin
    
    DUT: median_filter generic map(
            MASK => 3,
            G_IMAGE_WIDTH => 8,
            G_IMAGE_HEIGHT => 8,
            G_PIXEL_SIZE => 8,
            G_RAM_PERFORMANCE => "LOW_LATENCY",
            G_INIT_FILENAME => "init.dat"
        )
        port map(
            input => input,
            reset => reset,
            clk => clk,
            filtered => filtered,
            read => read,
            dout => dout
        );
   
    clk <= not clk after Tclk/2;
    
    stimulus: process
    begin
        wait for Tclk;
        reset <= '0';
        wait for 10 ns;
        input <= '1';
        wait for 5*Tclk;
        input <= '0';
        wait;
    end process;
end Behavioral;
