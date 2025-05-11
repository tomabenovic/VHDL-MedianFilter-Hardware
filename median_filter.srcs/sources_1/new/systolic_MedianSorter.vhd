library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.median_filter_pkg.all;


entity systolic_MedianSorter is
  generic(N : integer := 9);
  Port ( 
    clk : in std_logic;
    arr : in pixel_array(0 to N-1);
    
    median : out std_logic_vector(7 downto 0)
  );
end systolic_MedianSorter;
    
    
architecture Behavioral of systolic_MedianSorter is
    
    type pixel_matrix is array(0 to N) of pixel_array(0 to N);
    signal regs : pixel_matrix;
    
begin
    
    INPUT_REGS_PROC: process(clk) is
    variable input_regs : pixel_array(0 to N);
    begin
        if(rising_edge(clk)) then
            input_regs(0) := (others => '0');
            input_regs(1 to N) := arr;
            regs(0) <= input_regs;
        end if;
    end process;
    
    
    STAGE_i: for i in 0 to N-1 generate

        EVEN_STAGE: if(i mod 2 = 0) generate 
        begin
            COMPARATORS_GEN_EVEN: for j in 0 to N/2 generate 
                PROPAGATE: process(clk) is
                begin
                    if(rising_edge(clk)) then
                        
                        if(regs(i)(2*j) > regs(i)(2*j+1)) then
                            
                            regs(i+1)(2*j) <= regs(i)(2*j+1);
                            regs(i+1)(2*j+1) <= regs(i)(2*j);
                            
                        else
                        
                            regs(i+1)(2*j) <= regs(i)(2*j);
                            regs(i+1)(2*j+1) <= regs(i)(2*j+1);
                            
                        end if;
                        
                    end if;
                end process;
                
            end generate;    
        end generate;

        ODD_STAGE: if(i mod 2 = 1) generate 
        begin
            COMPARATORS_GEN_ODD: for j in 1 to N/2 generate 
                PROPAGATE: process(clk) is
                begin
                    if(rising_edge(clk)) then
                        regs(i+1)(0) <= regs(i)(0);
                        
                        if(regs(i)(2*j-1) > regs(i)(2*j)) then
                            
                            regs(i+1)(2*j-1) <= regs(i)(2*j);
                            regs(i+1)(2*j) <= regs(i)(2*j-1);
                            
                        else
                            
                            regs(i+1)(2*j-1) <= regs(i)(2*j-1);
                            regs(i+1)(2*j) <= regs(i)(2*j);
                                
                        end if;
                        
                        regs(i+1)(N) <= regs(i)(N);                       
                    end if;
                end process;              
            end generate;    
        end generate;
        

    end generate;
    
    median <= regs(N)(N/2+1);
    
end Behavioral;