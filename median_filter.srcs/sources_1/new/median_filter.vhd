library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.RAM_definitions_PK.all;
use work.median_filter_pkg.all;

entity median_filter is
  generic(
    MASK : integer := 3;                -- velicina maske za filtriranje
    G_IMAGE_WIDTH : integer := 256;      
    G_IMAGE_HEIGHT : integer := 256;
    G_PIXEL_SIZE : integer := 8;
    G_RAM_PERFORMANCE : string := "LOW_LATENCY";
    G_INIT_FILENAME : string := "lenaCorrupted.dat"
  );

  Port ( 
    input : in std_logic;
    reset : in std_logic;
    clk : in std_logic;
    
    
    dout : out std_logic_vector(G_PIXEL_SIZE-1 downto 0);
    
    
    filtered : out std_logic; -- oznacava kraj filtriranja
    read : out std_logic  
  );
end median_filter;

architecture Behavioral of median_filter is

    type state_type is (idle, filtering, reading, finished);
    signal state_reg, next_state : state_type;
    
    constant CLOCK_NUMBERS : integer := G_IMAGE_WIDTH*G_IMAGE_HEIGHT-1;
    signal cnt : integer range 0 to CLOCK_NUMBERS;
    
    component im_ram is
    generic (
        G_RAM_WIDTH : integer;            		    
        G_RAM_DEPTH : integer; 				        
        G_RAM_PERFORMANCE : string;    
        G_INIT_FILENAME : string
    );
    port (
        addra : in std_logic_vector((clogb2(G_RAM_DEPTH)-1) downto 0);     
        addrb : in std_logic_vector((clogb2(G_RAM_DEPTH)-1) downto 0);     
        dina  : in std_logic_vector(G_RAM_WIDTH-1 downto 0);		  
        clk  : in std_logic;                       			  
        wea   : in std_logic;                       			  
        enb   : in std_logic;                       			  
        rstb  : in std_logic;                       			  
        regceb: in std_logic;                       			  
        doutb : out std_logic_vector(G_RAM_WIDTH-1 downto 0) 		  
    );
    end component im_ram;
    
    -- INTERNI SIGNALI ZA RAM
    signal ram_rd_addr : std_logic_vector(clogb2(G_IMAGE_WIDTH*G_IMAGE_HEIGHT)-1 downto 0);
    signal ram_wr_addr : std_logic_vector(clogb2(G_IMAGE_WIDTH*G_IMAGE_HEIGHT)-1 downto 0);
    signal ram_din  : std_logic_vector(G_PIXEL_SIZE-1 downto 0);
    signal ram_we : std_logic;
    signal ram_en : std_logic;
    signal ram_dout : std_logic_vector(G_PIXEL_SIZE-1 downto 0);
    
    component ram_fifo is
        generic (
            G_DATAWIDTH : natural;
            G_FIFODEPTH : natural;
            G_FIFO_PERFORMANCE : string
        );
        port (
            clk : in std_logic;
            reset : in std_logic;
            fifo_wr : in std_logic;
            din : in std_logic_vector(G_DATAWIDTH-1 downto 0);
            fifo_rd : in std_logic;
            dout : out std_logic_vector(G_DATAWIDTH-1 downto 0)
        );
    end component ram_fifo;
    
    -- Interni signali za fifo ram
    signal fifo_rst : std_logic;
    signal fifo_we : std_logic_vector(0 to MASK-2);
    signal fifo_en : std_logic_vector(0 to MASK-2);
    signal fifo_dout : pixel_array(0 to MASK-2);
    
    component systolic_MedianSorter is
        Generic (N : integer);
        Port (
            clk : in std_logic; 
            arr : in pixel_array(0 to N-1);
            median : out std_logic_vector(7 downto 0)
        );
    end component systolic_MedianSorter;
    
    -- regisitri iz kojih se izdvaja medijana
    signal pixel_regs : pixel_array(0 to MASK*MASK-1);
    
    signal ram_dout_reg : std_logic_vector(7 downto 0); -- izlazni registar za citanje podataka iz rama
    
    signal waiting_flag : std_logic := '0';
    
begin    

   
    
    RAM: im_ram
      generic map(
        G_RAM_WIDTH => G_PIXEL_SIZE,
        G_RAM_DEPTH => G_IMAGE_WIDTH * G_IMAGE_HEIGHT,
        G_RAM_PERFORMANCE => G_RAM_PERFORMANCE,
        G_INIT_FILENAME => G_INIT_FILENAME
      )
      port map(
        clk    => clk,
        addra  => ram_wr_addr,
        dina   => ram_din,
        wea    => ram_we,
        
        -- umesto ram_rd_addr i ram_en:
        addrb  => ram_rd_addr,
        enb    => ram_en,
        
        rstb   => '0',
        regceb => '1',
        doutb  => ram_dout
      );
    
    FIFO: for i in 0 to MASK-2 generate
        fifo_i: ram_fifo generic map(
            G_FIFO_PERFORMANCE => "LOW_LATENCY",
            G_DATAWIDTH => G_PIXEL_SIZE,
            G_FIFODEPTH => G_IMAGE_WIDTH - MASK
        )
        port map(
            clk => clk,
            reset => fifo_rst,
            fifo_wr => fifo_we(i),
            fifo_rd => fifo_en(i),
            din => pixel_regs(i*MASK + MASK - 1),
            dout => fifo_dout(i)
        );
     end generate;
     
    MEDIAN_SORTER: systolic_MedianSorter generic map(N => MASK*MASK) 
    port map(
        clk => clk, 
        arr => pixel_regs, 
        median => ram_din
    );

    -- povezivanje registara koji idu u mrezu za soritranje    
    PIXEL_REGS_PROC: process(clk) is
        variable i : natural;
        variable j : natural;
    begin
        if(rising_edge(clk)) then
            if(state_reg = filtering) then
                for i in 0 to MASK-1 loop
                    for j in 0 to MASK-1 loop
                        if(j = 0) then
                            if(i = 0) then
                                pixel_regs(0) <= ram_dout;
                            else    
                                pixel_regs(i * MASK) <= fifo_dout(i-1);
                            end if;
                        else
                            pixel_regs(i*MASK+j) <= pixel_regs(i*MASK+j-1);
                        end if;
                    end loop;
                end loop;
            end if;    
        end if; 
    end process;
    
    STATE_TRANSITION: process(clk) is
    begin
        if(rising_edge(clk)) then
            if(reset = '1') then
                state_reg <= idle;
            else
                state_reg <= next_state;
            end if;
        end if; 
    end process STATE_TRANSITION;


    NEXT_STATE_LOGIC: process(input, waiting_flag, ram_wr_addr, state_reg) is
    begin
        case state_reg is
            when idle =>
                if(input = '1') then
                    next_state <= filtering;
                else
                    next_state <= idle;
                end if;
                
            when filtering =>
                if (unsigned(ram_wr_addr) = CLOCK_NUMBERS - (MASK/2)*(G_IMAGE_WIDTH+1)) then
                    next_state <= reading;
                else
                    next_state <= filtering;
                end if;
            when reading =>
                if(waiting_flag = '1') then
                    next_state <= finished;
                else
                    next_state <= reading;
                end if;
            when finished =>
                next_state <=idle;
         end case;
    end process NEXT_STATE_LOGIC;
    
    CNT_PROCESS: process(clk) is
    begin
        if(rising_edge(clk)) then
            if(state_reg = filtering) then
                if(cnt < CLOCK_NUMBERS) then
                    cnt <= cnt + 1;
                end if;
            else
                cnt <= 0;
            end if;
        end if;
    end process;
    
    -- podesavanje adresa i enable signala za citanje i upis
    RAM_WR_RD_GEN: process(clk) is
        constant LATENCY : integer := MASK*MASK+1; --propagacija piksela kroz mrezu za sortiranje
    begin
        if(rising_edge(clk)) then
            if(next_state = filtering) then
                -- citanje
                if(cnt < CLOCK_NUMBERS) then
                    ram_en <= '1';
                    ram_rd_addr <= std_logic_vector(unsigned(ram_rd_addr)+1);
                else
                    ram_en <= '0';
                    ram_rd_addr <= (others => '0');
                end if;
                
                -- upis
                if(cnt >= (MASK-1)*G_IMAGE_WIDTH + MASK + LATENCY) then
                    if((unsigned(ram_wr_addr)+MASK/2+1) mod G_IMAGE_WIDTH > MASK/2 ) then
                        ram_we <= '1';
                        ram_wr_addr <= std_logic_vector(unsigned(ram_wr_addr)+1);                                   
                    else
                        ram_we <= '0';
                        ram_wr_addr <= std_logic_vector(unsigned(ram_wr_addr)+1);                                  
                    end if;
                end if;
                
                if(unsigned(ram_wr_addr) = CLOCK_NUMBERS - (MASK/2)*(G_IMAGE_WIDTH+1)-1) then
                    ram_en <= '1';
                end if;
                
            elsif(next_state = reading) then
                if(unsigned(ram_rd_addr) < CLOCK_NUMBERS) then
                    ram_en <= '1';
                    ram_rd_addr <= std_logic_vector(unsigned(ram_rd_addr)+1);
                    ram_we <= '0';
                else
                    ram_en <= '0';
                    waiting_flag <= '1';
                end if;
            else
                ram_rd_addr <= (others => '1');
                ram_wr_addr <= std_logic_vector(to_unsigned((MASK/2)*G_IMAGE_WIDTH + MASK/2 - 1, clogb2(G_IMAGE_WIDTH*G_IMAGE_HEIGHT))); 
                ram_we <= '0';
                ram_en <= '0';
                waiting_flag <= '0';
            end if;
            
        end if;
    end process;

    FIFO_WR_RD_GEN: process(clk) is
    begin
        if rising_edge(clk) then
            if(next_state = filtering) then
                fifo_rst <= '0';
                
                for i in 0 to MASK-2 loop
                    if(cnt >= i * G_IMAGE_WIDTH + MASK) then
                        fifo_we(i) <= '1';
                    else
                        fifo_we(i) <= '0';
                    end if;
    
                    if(cnt >= G_IMAGE_WIDTH * (i+1) - 1) then
                        fifo_en(i) <= '1';
                    else
                        fifo_en(i) <= '0';
                    end if;
                end loop;
                
            else
                fifo_rst <= '1';
                fifo_we <= (others => '0');
                fifo_en <= (others => '0');
            end if;
        end if;
    end process;
    
    RAM_RD_PROC: process(clk) is
    begin
        if(rising_edge(clk)) then
            if(state_reg = reading) then
                ram_dout_reg <= ram_dout;
            end if;
        end if;    
    end process;
    
    dout <= ram_dout_reg;
    
    OUTPUT_LOGIC: process(state_reg, ram_rd_addr) is
    begin
        case state_reg is
            when idle =>
                read <= '0';
                filtered <= '0';
            when filtering =>
                read <= '0';
                filtered <= '0';
            when reading =>
                if(unsigned(ram_rd_addr) > 1) then
                    read <= '1';
                else
                    read <= '0';
                end if;
                filtered <= '0';
            when finished =>
                read <= '1';
                filtered <= '1';
        end case;
    end process;
    
end Behavioral;