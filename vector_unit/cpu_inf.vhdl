
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Local package to define custom types


use work.cpu_inf_pkg.all;

entity cpu_inf is
    generic (
        DMEM_ADDR_WIDTH : integer := 14
    );
    port (
        clk          : in  std_logic;
        reset        : in  std_logic;
        ADDR_IN      : in  std_logic_vector (31 downto 0);
        DMEM_DATA_RD : in  op_array;
        VREG_DATA_RD : in  op_array;
        WE_IN        : in  std_logic;
        vs1          : out std_logic_vector (4 downto 0);
        vd           : out std_logic_vector (4 downto 0);
        mem_addr     : out std_logic_vector (DMEM_ADDR_WIDTH-1 downto 0);
        DMEM_WE      : out done_array;
        VREG_WE      : out done_array;
        dout         : out std_logic_vector (31 downto 0)
    );
end cpu_inf;

architecture Behavioral of cpu_inf is
    signal reg_bank_sel     : std_logic_vector(2 downto 0);
    signal mem_bank_sel     : std_logic_vector(2 downto 0);
    signal mem_bank_sel_reg : std_logic_vector(2 downto 0);

    signal dmem_cs          : std_logic;        -- Active high Chip Select for Vector Data memory
    signal dmem_cs_reg      : std_logic;        -- Delayed Chip Select for Vector Data memory read
    signal vreg_cs          : std_logic;        -- Active high Chip Select for Vector Registers  

    signal vreg_dout        : std_logic_vector(31 downto 0);
    signal vreg_dout_reg    : std_logic_vector(31 downto 0);
    signal dmem_dout        : std_logic_vector(31 downto 0);

    constant DMEM_START     : unsigned(31 downto 0) := x"00100000";
    constant DMEM_END       : unsigned(31 downto 0) := x"0017FFFC";
    constant VREG_START     : unsigned(31 downto 0) := x"00180000";
    constant VREG_END       : unsigned(31 downto 0) := x"001803FC";

begin

    -- Chip Select Logic
    dmem_cs <= '1' when (unsigned(ADDR_IN) >= DMEM_START and unsigned(ADDR_IN) <= DMEM_END) else '0';
    vreg_cs <= '1' when (unsigned(ADDR_IN) >= VREG_START and unsigned(ADDR_IN) <= VREG_END) else '0';

    -- Bank Select Logic
    reg_bank_sel <= ADDR_IN(4 downto 2) when vreg_cs = '1' else (others => '1'); -- Default bank 7
    mem_bank_sel <= ADDR_IN(4 downto 2) when dmem_cs = '1' else (others => '1'); -- Default Bank 7 

    -- Address and Register Signals
    vs1      <= ADDR_IN(9 downto 5);
    vd       <= ADDR_IN(9 downto 5);
    mem_addr <= ADDR_IN(DMEM_ADDR_WIDTH+4 downto 5); -- Each 4 Bytes x 8 banks = 32 ; log(32)=5

    -- DMEM Write Enable Generation
    DMEM_WE_gen: process(ADDR_IN, WE_IN, dmem_cs, mem_bank_sel)
    begin
        if dmem_cs = '1' then
            case mem_bank_sel is
                when "000" => 
                    for j in 0 to 7 loop
                        if j = 0 then
                            DMEM_WE(j) <= WE_IN;
                        else
                            DMEM_WE(j) <= '0';
                        end if;
                    end loop;
                when "001" => 
                    for j in 0 to 7 loop
                        if j = 1 then
                            DMEM_WE(j) <= WE_IN;
                        else
                            DMEM_WE(j) <= '0';
                        end if;
                    end loop;
                when "010" => 
                    for j in 0 to 7 loop
                        if j = 2 then
                            DMEM_WE(j) <= WE_IN;
                        else
                            DMEM_WE(j) <= '0';
                        end if;
                    end loop;
                when "011" => 
                    for j in 0 to 7 loop
                        if j = 3 then
                            DMEM_WE(j) <= WE_IN;
                        else
                            DMEM_WE(j) <= '0';
                        end if;
                    end loop;
                when "100" => 
                    for j in 0 to 7 loop
                        if j = 4 then
                            DMEM_WE(j) <= WE_IN;
                        else
                            DMEM_WE(j) <= '0';
                        end if;
                    end loop;
                when "101" => 
                    for j in 0 to 7 loop
                        if j = 5 then
                            DMEM_WE(j) <= WE_IN;
                        else
                            DMEM_WE(j) <= '0';
                        end if;
                    end loop;
                when "110" => 
                    for j in 0 to 7 loop
                        if j = 6 then
                            DMEM_WE(j) <= WE_IN;
                        else
                            DMEM_WE(j) <= '0';
                        end if;
                    end loop;
                when "111" => 
                    for j in 0 to 7 loop
                        if j = 7 then
                            DMEM_WE(j) <= WE_IN;
                        else
                            DMEM_WE(j) <= '0';
                        end if;
                    end loop;
                when others =>
                    for j in 0 to 7 loop
                        DMEM_WE(j) <= '0';
                    end loop;
            end case;
        else
            for j in 0 to 7 loop
                DMEM_WE(j) <= '0';
            end loop;
        end if;
    end process DMEM_WE_gen;

    -- VREG Write Enable Generation
    VREG_WE_gen: process(ADDR_IN, WE_IN, vreg_cs, reg_bank_sel)
    begin
        if vreg_cs = '1' then
            case reg_bank_sel is
                when "000" => 
                    for j in 0 to 7 loop
                        if j = 0 then
                            VREG_WE(j) <= WE_IN;
                        else
                            VREG_WE(j) <= '0';
                        end if;
                    end loop;
                when "001" => 
                    for j in 0 to 7 loop
                        if j = 1 then
                            VREG_WE(j) <= WE_IN;
                        else
                            VREG_WE(j) <= '0';
                        end if;
                    end loop;
                when "010" => 
                    for j in 0 to 7 loop
                        if j = 2 then
                            VREG_WE(j) <= WE_IN;
                        else
                            VREG_WE(j) <= '0';
                        end if;
                    end loop;
                when "011" => 
                    for j in 0 to 7 loop
                        if j = 3 then
                            VREG_WE(j) <= WE_IN;
                        else
                            VREG_WE(j) <= '0';
                        end if;
                    end loop;
                when "100" => 
                    for j in 0 to 7 loop
                        if j = 4 then
                            VREG_WE(j) <= WE_IN;
                        else
                            VREG_WE(j) <= '0';
                        end if;
                    end loop;
                when "101" => 
                    for j in 0 to 7 loop
                        if j = 5 then
                            VREG_WE(j) <= WE_IN;
                        else
                            VREG_WE(j) <= '0';
                        end if;
                    end loop;
                when "110" => 
                    for j in 0 to 7 loop
                        if j = 6 then
                            VREG_WE(j) <= WE_IN;
                        else
                            VREG_WE(j) <= '0';
                        end if;
                    end loop;
                when "111" => 
                    for j in 0 to 7 loop
                        if j = 7 then
                            VREG_WE(j) <= WE_IN;
                        else
                            VREG_WE(j) <= '0';
                        end if;
                    end loop;
                when others =>
                    for j in 0 to 7 loop
                        VREG_WE(j) <= '0';
                    end loop;
            end case;
        else
            for j in 0 to 7 loop
                VREG_WE(j) <= '0';
            end loop;
        end if;
    end process VREG_WE_gen;

    -- Delay the Memory Bank Selects (Bank Select and Chip Select) One Clock Cycle
    MEM_BANK_SEL_REGISTER: process(clk, reset)
    begin
        if reset = '1' then
            mem_bank_sel_reg <= (others => '0');
            dmem_cs_reg      <= '0';
        elsif rising_edge(clk) then
            mem_bank_sel_reg <= mem_bank_sel;
            dmem_cs_reg      <= dmem_cs;
        end if;
    end process MEM_BANK_SEL_REGISTER;

    -- Data Memory Read Data Selector
    DMEM_SELECTOR: process(DMEM_DATA_RD, mem_bank_sel_reg)
    begin
        case mem_bank_sel_reg is
            when "000" => dmem_dout <= DMEM_DATA_RD(0); 
            when "001" => dmem_dout <= DMEM_DATA_RD(1); 
            when "010" => dmem_dout <= DMEM_DATA_RD(2); 
            when "011" => dmem_dout <= DMEM_DATA_RD(3); 
            when "100" => dmem_dout <= DMEM_DATA_RD(4); 
            when "101" => dmem_dout <= DMEM_DATA_RD(5); 
            when "110" => dmem_dout <= DMEM_DATA_RD(6); 
            when "111" => dmem_dout <= DMEM_DATA_RD(7); 
            when others => dmem_dout <= DMEM_DATA_RD(7);
        end case;
    end process DMEM_SELECTOR;

    -- Vector Register Read Data Selector
    VREG_SELECTOR: process(VREG_DATA_RD, reg_bank_sel)
    begin
        case reg_bank_sel is
            when "000" => vreg_dout <= VREG_DATA_RD(0); 
            when "001" => vreg_dout <= VREG_DATA_RD(1); 
            when "010" => vreg_dout <= VREG_DATA_RD(2); 
            when "011" => vreg_dout <= VREG_DATA_RD(3); 
            when "100" => vreg_dout <= VREG_DATA_RD(4); 
            when "101" => vreg_dout <= VREG_DATA_RD(5); 
            when "110" => vreg_dout <= VREG_DATA_RD(6); 
            when "111" => vreg_dout <= VREG_DATA_RD(7); 
            when others => vreg_dout <= VREG_DATA_RD(7);
        end case;
    end process VREG_SELECTOR;

    -- Delay the Register Data by One Clock Cycle
    VREG_DOUT_REGISTER: process(clk, reset)
    begin
        if reset = '1' then
            vreg_dout_reg <= (others => '0');
        elsif rising_edge(clk) then
            vreg_dout_reg <= vreg_dout;
        end if;
    end process VREG_DOUT_REGISTER;

    -- Output Data Selector
    READ_DATA_SELECTOR: process(dmem_dout, vreg_dout_reg, dmem_cs_reg)
    begin
        if dmem_cs_reg = '1' then
            dout <= dmem_dout;
        else
            dout <= vreg_dout_reg;
        end if;
    end process READ_DATA_SELECTOR;

end Behavioral;