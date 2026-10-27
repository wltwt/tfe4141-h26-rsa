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

signal A_reg, B_reg, n_reg : unsigned(C_WIDTH-1 downto 0); 
signal S_reg : unsigned(C_WIDTH+1 downto 0); 
signal cnt : unsigned(7 downto 0); 

-- Control signals

type op_sel_t is (OP_ZERO, OP_B, OP_N);
signal op sel    : op_sel_t; 
signal sub       : std_logic;   -- add or subtract
signal res_shift : std_logic;   -- SUM or SUM>>1
signal load_in   : std_logic;   -- load a, b, n + clear S and cnt
signal load_s    : std_logic;   -- S_reg <= res_mux 
signal shift_a   : std_logic;   -- A_reg >> 1
signal cnt_inc   :  std_logic;  -- cnt +1 

-- Datapath wires

signal op        : unsigned(C_WIDTH+1 downto 0)   -- output
signal sum       : unsigned(C_WIDTH+2 downto 0);  -- output  
signal borrow    : std_logic;                     -- output -> FSM
signal res_mux   : unsigned(C_WIDTH+1 downto 0):  -- output -> S_reg

begin

-- operand mux 

with op_sel select 
    op <= (others => '0') when OP_ZERO,
        "00" & B_reg when OP_B, 
        "00" & n_reg when OP_N; 

-- adder / subtractor 
-- sum = S +/- op, extra MSB = borrow
borrow <= sum(sum'high); -- top bit = 1 means S < n in SUB_N


-- result mux: res-mux -> res_mux 
res_mux <= sum(C_WIDTH+2 downto 1) when res res_shift = '1' -- sum >> 1
      else sum(C_WIDTH+1 downto 0);                         -- sum 


-- FSM 

fsm_comb: process(all) 

end Behavioral;
