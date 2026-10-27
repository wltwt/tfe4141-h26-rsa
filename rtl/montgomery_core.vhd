----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/27/2026 01:27:06 PM
-- Design Name: 
-- Module Name: montgomery_core - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity montgomery_core is
    generic ( C_WIDTH : integer := 256 ); 
    port ( 
        clk : in std_logic; 
        reset_n : in std_logic; 
        
        -- control 
        start : in std_logic; 
        ready : out std_logic; 
        done : out std_logic; 
        
        --operands
        a : in std_logic_vector(C_WIDTH-1 downto 0);
        b : in std_logic_vector(C_WIDTH-1 downto 0);
        n : in std_logic_vector(C_WIDTH-1 downto 0);
        reset : in std_logic_vector(C_WIDTH-1 downto 0)
        );
     
end montgomery_core;

architecture Behavioral of montgomery_core is

-- FSM state
type state_t is (IDLE, ADD_B, ADD_N, SUB_N, DONE); 
signal state, state_nxt : state_t; 

-- Registers 


begin


end Behavioral;
