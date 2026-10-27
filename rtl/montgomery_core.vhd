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
use IEEE.NUMERIC_STD.ALL;

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
        result : out std_logic_vector(C_WIDTH-1 downto 0)
        );
     
end montgomery_core;

architecture Behavioral of montgomery_core is

-- FSM state

type state_t is (IDLE, ADD_B, ADD_N, SUB_N, DONE_ST); 
signal state, state_nxt : state_t; 

-- Registers 

signal A_reg, B_reg, n_reg : unsigned(C_WIDTH-1 downto 0); 
signal S_reg : unsigned(C_WIDTH+1 downto 0); 
signal cnt : unsigned(7 downto 0); 

-- Control signals

type op_sel_t is (OP_ZERO, OP_B, OP_N);
signal op_sel    : op_sel_t; 
signal sub       : std_logic;   -- add or subtract
signal res_shift : std_logic;   -- SUM or SUM>>1
signal load_in   : std_logic;   -- load a, b, n + clear S and cnt
signal load_s    : std_logic;   -- S_reg <= res_mux 
signal shift_a   : std_logic;   -- A_reg >> 1
signal cnt_inc   :  std_logic;  -- cnt +1 

-- Datapath wires

signal op        : unsigned(C_WIDTH+1 downto 0);   -- output
signal sum       : unsigned(C_WIDTH+2 downto 0);  -- output  
signal borrow    : std_logic;                     -- output -> FSM
signal res_mux   : unsigned(C_WIDTH+1 downto 0);  -- output -> S_reg

begin

-- operand mux 

with op_sel select 
    op <= (others => '0') when OP_ZERO,
        "00" & B_reg when OP_B, 
        "00" & n_reg when OP_N; 

-- adder / subtractor 
-- sum = S +/- op, extra MSB = borrow
sum <= ('0' & S_reg) + ('0' & op) when sub = '0'
    else ('0' & S_reg) - ('0' & op);

borrow <= sum(sum'high); -- top bit = 1 means S < n in SUB_N


-- result mux: res-mux -> res_mux 
res_mux <= sum(C_WIDTH+2 downto 1) when res_shift = '1' -- sum >> 1
      else sum(C_WIDTH+1 downto 0);                         -- sum 


-- FSM 

 fsm_comb : process(all)
  begin
    -- defaults
    state_nxt <= state;
    op_sel    <= OP_ZERO;
    sub       <= '0';
    res_shift <= '0';
    load_in   <= '0';
    load_s    <= '0';
    shift_a   <= '0';
    cnt_inc   <= '0';

    case state is
          when IDLE =>
        if start = '1' then
          load_in   <= '1';
          state_nxt <= ADD_B;
        end if;

      when ADD_B =>
        if A_reg(0) = '1' then
          op_sel <= OP_B;
        end if;
        load_s    <= '1';
        state_nxt <= ADD_N;

      when ADD_N =>
        if S_reg(0) = '1' then
          op_sel <= OP_N;
        end if;
        res_shift <= '1';                -- store (S + n or 0) / 2
        load_s    <= '1';
        shift_a   <= '1';                -- next bit of A into position 0
        cnt_inc   <= '1';
        if cnt = to_unsigned(C_WIDTH-1, cnt'length) then
          state_nxt <= SUB_N;            -- last round done
        else
          state_nxt <= ADD_B;
        end if;

      when SUB_N =>
        op_sel    <= OP_N;
        sub       <= '1';                -- S - n
        load_s    <= not borrow;         -- keep S if S < n
        state_nxt <= DONE_ST;

      when DONE_ST =>
        state_nxt <= IDLE;
    end case;
  end process;


  -- Registers  
  
  regs : process(clk, reset_n)
  begin
    if reset_n = '0' then
      state <= IDLE;
      A_reg <= (others => '0');
      B_reg <= (others => '0');
      n_reg <= (others => '0');
      S_reg <= (others => '0');
      cnt   <= (others => '0');
    elsif rising_edge(clk) then
      state <= state_nxt;

      if load_in = '1' then
        A_reg <= unsigned(a);
        B_reg <= unsigned(b);
        n_reg <= unsigned(n);
        S_reg <= (others => '0');
        cnt   <= (others => '0');
      end if;

      if load_s = '1' then
        S_reg <= res_mux;
      end if;

      if shift_a = '1' then
        A_reg <= '0' & A_reg(C_WIDTH-1 downto 1);
      end if;

      if cnt_inc = '1' then
        cnt <= cnt + 1;
      end if;
    end if;
  end process;

 
  -- Outputs  
  
  result <= std_logic_vector(S_reg(C_WIDTH-1 downto 0));
  ready  <= '1' when state = IDLE    else '0';
  done   <= '1' when state = DONE_ST else '0';

end Behavioral;