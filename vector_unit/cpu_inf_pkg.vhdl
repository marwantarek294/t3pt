library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package cpu_inf_pkg is
    type op_array is array (0 to 7) of std_logic_vector(31 downto 0);
    type done_array is array (0 to 7) of std_logic;
end package cpu_inf_pkg;
