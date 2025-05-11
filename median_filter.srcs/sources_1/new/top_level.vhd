library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity top_level is
    
-- ovde zadajete parametre medijan filtera
  generic(
    MASK : integer := 3;                -- velicina maske za filtriranje
    
    -- velicina slike
    G_IMAGE_WIDTH : integer := 256;          
    G_IMAGE_HEIGHT : integer := 256;
    G_PIXEL_SIZE : integer := 8;
    
    -- memorija
    G_RAM_PERFORMANCE : string := "LOW_LATENCY";
    G_INIT_FILENAME : string := "lenaCorrupted.dat"; -- inicijalizacioni fajl
    
    -- uart 
    CLK_FREQ	: integer := 200;		-- Main frequency (MHz)
	SER_FREQ	: integer := 115200		-- Baud rate (bps)
  );
    

  Port ( 
    clk : in std_logic;
    rst : in std_logic;
    
    button : in std_logic;
    
    led : out std_logic -- dioda koja ce oznaciti kraj celokupnog procesa
  );
end top_level;

architecture Behavioral of top_level is

begin


end Behavioral;
