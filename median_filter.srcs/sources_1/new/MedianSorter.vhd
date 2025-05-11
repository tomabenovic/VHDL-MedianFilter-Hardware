library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.median_filter_pkg.all;


entity MedianSorter is
  Generic (N : integer := 9);
  Port (
    clk : in std_logic; 
    arr : in pixel_array(0 to N-1);
    median : out std_logic_vector(7 downto 0)
  );
end MedianSorter;

architecture Behavioral of MedianSorter is
    
    signal arr_input_reg : pixel_array(N-1 downto 0);
    
    signal arr_reg_stage1 : pixel_array(N-1 downto 0);
    signal arr_reg_stage2 : pixel_array(N-1 downto 0);
    signal arr_reg_stage3 : pixel_array(N-1 downto 0);
    signal arr_reg_stage4 : pixel_array(N-1 downto 0);
    signal arr_reg_stage5 : pixel_array(N-1 downto 0);
    signal arr_reg_stage6 : pixel_array(N-1 downto 0);
    signal arr_reg_stage7 : pixel_array(N-1 downto 0);
    signal arr_reg_stage8 : pixel_array(N-1 downto 0);
    
    signal output_reg : std_logic_vector(7 downto 0);
begin
    
    INPUT_REG: process(clk) is
    begin
        if(rising_edge(clk)) then
            arr_input_reg <= arr;
        end if;
    end process;

    STAGE1: process(clk) is
    begin
        if(rising_edge(clk)) then
            if(arr_input_reg(0) < arr_input_reg(1)) then
                arr_reg_stage1(0) <= arr_input_reg(0);
                arr_reg_stage1(1) <= arr_input_reg(1);
            else
                arr_reg_stage1(0) <= arr_input_reg(1);
                arr_reg_stage1(1) <= arr_input_reg(0);
            end if;
        
            if(arr_input_reg(2) < arr_input_reg(3)) then
                arr_reg_stage1(2) <= arr_input_reg(2);
                arr_reg_stage1(3) <= arr_input_reg(3);
            else
                arr_reg_stage1(2) <= arr_input_reg(3);
                arr_reg_stage1(3) <= arr_input_reg(2);
            end if;
            
            if(arr_input_reg(4) < arr_input_reg(5)) then
                arr_reg_stage1(4) <= arr_input_reg(4);
                arr_reg_stage1(5) <= arr_input_reg(5);
            else
                arr_reg_stage1(4) <= arr_input_reg(5);
                arr_reg_stage1(5) <= arr_input_reg(4);
            end if;
            
            if(arr_input_reg(6) < arr_input_reg(7)) then
                arr_reg_stage1(6) <= arr_input_reg(6);
                arr_reg_stage1(7) <= arr_input_reg(7);
            else
                arr_reg_stage1(6) <= arr_input_reg(7);
                arr_reg_stage1(7) <= arr_input_reg(6);
            end if;
            
            arr_reg_stage1(8) <= arr_input_reg(8);
        end if;
    end process;
    
    STAGE2_i: for i in 0 to (N/4)-1 generate
    begin
        STAGE2_j: for j in 0 to 1 generate
            STAGE2_proc: process(clk)
            begin
                if(rising_edge(clk)) then
                   if(arr_reg_stage1(i*4 + j) < arr_reg_stage1(i*4 + j + 2)) then
                        arr_reg_stage2(i*4 + j) <= arr_reg_stage1(i*4 + j);
                        arr_reg_stage2(i*4 + j + 2) <= arr_reg_stage1(i*4 + j + 2);
                   else
                        arr_reg_stage2(i*4 + j) <= arr_reg_stage1(i*4 + j + 2);
                        arr_reg_stage2(i*4 + j + 2) <= arr_reg_stage1(i*4 + j);
                   end if;
                end if;
            end process;
        end generate;
    end generate;
    
    STAGE2_pass_through: process(clk) is
    begin
        if(rising_edge(clk)) then
            arr_reg_stage2(N-1) <= arr_reg_stage1(N-1);
        end if;
    end process;
    
    STAGE3: process(clk) is
    begin
        if(rising_edge(clk)) then
            arr_reg_stage3(0) <= arr_reg_stage2(0);
            
            if(arr_reg_stage2(1) < arr_reg_stage2(2)) then
                arr_reg_stage3(1) <= arr_reg_stage2(1);
                arr_reg_stage3(2) <= arr_reg_stage2(2);
            else
                arr_reg_stage3(1) <= arr_reg_stage2(2);
                arr_reg_stage3(2) <= arr_reg_stage2(1);
            end if;
            
            arr_reg_stage3(3) <= arr_reg_stage2(3);
            arr_reg_stage3(4) <= arr_reg_stage2(4);
            
            if(arr_reg_stage2(5) < arr_reg_stage2(6)) then
                arr_reg_stage3(5) <= arr_reg_stage2(5);
                arr_reg_stage3(6) <= arr_reg_stage2(6);
            else
                arr_reg_stage3(5) <= arr_reg_stage2(6);
                arr_reg_stage3(6) <= arr_reg_stage2(5);
            end if;
            
            arr_reg_stage3(7) <= arr_reg_stage2(7);
            arr_reg_stage3(8) <= arr_reg_stage2(8);
            
        end if;
    end process;
   
    STAGE4: for i in 0 to (N/2)-1 generate
    begin
        STAGE4_proc: process(clk)
        begin
            if rising_edge(clk) then
                if(arr_reg_stage3(i) < arr_reg_stage3(i+4)) then
                    arr_reg_stage4(i) <= arr_reg_stage3(i);
                    arr_reg_stage4(i+4) <= arr_reg_stage3(i+4);
                else
                    arr_reg_stage4(i) <= arr_reg_stage3(i+4);
                    arr_reg_stage4(i+4) <= arr_reg_stage3(i);
                end if;
            end if;
        end process;
    end generate;
    
    STAGE4_pass_through: process(clk) is
    begin
        if(rising_edge(clk)) then
            arr_reg_stage4(N-1) <= arr_reg_stage3(N-1);
        end if;
    end process;
    
    STAGE5: process(clk) is
    begin
        if(rising_edge(clk)) then
            arr_reg_stage5(0) <= arr_reg_stage4(0);
            arr_reg_stage5(1) <= arr_reg_stage4(1);
            
            if(arr_reg_stage4(2) < arr_reg_stage4(4)) then
                arr_reg_stage5(2) <= arr_reg_stage4(2);
                arr_reg_stage5(4) <= arr_reg_stage4(4);
            else
                arr_reg_stage5(2) <= arr_reg_stage4(4);
                arr_reg_stage5(4) <= arr_reg_stage4(2);
            end if;
            
            if(arr_reg_stage4(3) < arr_reg_stage4(5)) then
                arr_reg_stage5(3) <= arr_reg_stage4(3);
                arr_reg_stage5(5) <= arr_reg_stage4(5);
            else
                arr_reg_stage5(3) <= arr_reg_stage4(5);
                arr_reg_stage5(5) <= arr_reg_stage4(3);
            end if;
            
            arr_reg_stage5(6) <= arr_reg_stage4(6);
            arr_reg_stage5(7) <= arr_reg_stage4(7);
            arr_reg_stage5(8) <= arr_reg_stage4(8);
        end if;
    end process;
    
    STAGE6: process(clk) is
    begin
        if(rising_edge(clk)) then
            
            if(arr_reg_stage5(0) < arr_reg_stage5(8)) then
                arr_reg_stage6(0) <= arr_reg_stage5(0);
                arr_reg_stage6(8) <= arr_reg_stage5(8);
            else
                arr_reg_stage6(0) <= arr_reg_stage5(8);
                arr_reg_stage6(8) <= arr_reg_stage5(0);
            end if;
            
            if(arr_reg_stage5(1) < arr_reg_stage5(2)) then
                arr_reg_stage6(1) <= arr_reg_stage5(1);
                arr_reg_stage6(2) <= arr_reg_stage5(2);
            else
                arr_reg_stage6(1) <= arr_reg_stage5(2);
                arr_reg_stage6(2) <= arr_reg_stage5(1);
            end if;
            
            if(arr_reg_stage5(3) < arr_reg_stage5(4)) then
                arr_reg_stage6(3) <= arr_reg_stage5(3);
                arr_reg_stage6(4) <= arr_reg_stage5(4);
            else
                arr_reg_stage6(3) <= arr_reg_stage5(4);
                arr_reg_stage6(4) <= arr_reg_stage5(3);
            end if;
            
            if(arr_reg_stage5(5) < arr_reg_stage5(6)) then
                arr_reg_stage6(5) <= arr_reg_stage5(5);
                arr_reg_stage6(6) <= arr_reg_stage5(6);
            else
                arr_reg_stage6(5) <= arr_reg_stage5(6);
                arr_reg_stage6(6) <= arr_reg_stage5(5);
            end if;
            
            arr_reg_stage6(7) <= arr_reg_stage5(7);
            
        end if;
    end process;

    STAGE7: process(clk)
    begin
        if rising_edge(clk) then
            arr_reg_stage7(0) <= arr_reg_stage6(0);
            arr_reg_stage7(1) <= arr_reg_stage6(1);
            arr_reg_stage7(2) <= arr_reg_stage6(2);
            arr_reg_stage7(3) <= arr_reg_stage6(3);
            arr_reg_stage7(5) <= arr_reg_stage6(5);
            arr_reg_stage7(6) <= arr_reg_stage6(6);
            arr_reg_stage7(7) <= arr_reg_stage6(7);
    
            if arr_reg_stage6(4) < arr_reg_stage6(8) then
                arr_reg_stage7(4) <= arr_reg_stage6(4);
                arr_reg_stage7(8) <= arr_reg_stage6(8);
            else
                arr_reg_stage7(4) <= arr_reg_stage6(8);
                arr_reg_stage7(8) <= arr_reg_stage6(4);
            end if;
        end if;
    end process;
    
    STAGE8: process(clk) is
    begin
        if(rising_edge(clk)) then
            arr_reg_stage8(0) <= arr_reg_stage7(0);
            arr_reg_stage8(1) <= arr_reg_stage7(1);
            
            if(arr_reg_stage7(2) < arr_reg_stage7(4)) then
                arr_reg_stage8(2) <= arr_reg_stage7(2);
                arr_reg_stage8(4) <= arr_reg_stage7(4);
            else
                arr_reg_stage8(2) <= arr_reg_stage7(4);
                arr_reg_stage8(4) <= arr_reg_stage7(2);
            end if;
            
            if(arr_reg_stage7(3) < arr_reg_stage7(5)) then
                arr_reg_stage8(3) <= arr_reg_stage7(3);
                arr_reg_stage8(5) <= arr_reg_stage7(5);
            else
                arr_reg_stage8(3) <= arr_reg_stage7(5);
                arr_reg_stage8(5) <= arr_reg_stage7(3);
            end if;
            
            arr_reg_stage8(6) <= arr_reg_stage7(6);
            arr_reg_stage8(7) <= arr_reg_stage7(7);
            arr_reg_stage8(8) <= arr_reg_stage7(8);
        end if;
    end process;
    
    STAGE9: process(clk) is
    begin
        if(rising_edge(clk)) then
            if(arr_reg_stage8(3) < arr_reg_stage8(4)) then
                output_reg <= arr_reg_stage8(4);
            else
                output_reg <= arr_reg_stage8(3);
            end if;
            
        end if;
    end process;
    
    median <= output_reg;

end Behavioral;
