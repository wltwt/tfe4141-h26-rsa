----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/28/2026 07:31:32 PM
-- Design Name: 
-- Module Name: tb_montgomery_core - Behavioral
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

entity tb_montgomery_core is
end tb_montgomery_core;

architecture Behavioral of tb_montgomery_core is
    constant W : integer := 4; 
    constant CLK_PERIOD : time := 10 ns; 
    
    signal clk : std_logic := '0'; 
    signal reset_n : std_logic := '0'; 
    signal start : std_logic := '0'; 
    signal ready : std_logic; 
    signal done : std_logic; 
    signal a, b, n : std_logic_vector(W-1 downto 0) := (others => '0'); 
    signal result : std_logic_vector(W-1 downto 0); 
   
begin

--clock 
clk <= not clk after CLK_PERIOD/2; 

-- DUT
dut : entity work.montgomery_core
    generic map ( C_WIDTH => W)
    port map (
        clk => clk, 
        reset_n => reset_n, 
        start => start,
        ready => ready, 
        done => done, 
        a => a, 
        b => b, 
        n => n, 
        result => result
        ); 

-- Stimulus 
stim : process
    variable errors : integer := 0; 
    
    -- test 1: apply input, pulse start, wait for done, compare
    procedure run_test(ta, tb, tn, texp : integer) is 
    begin 
        wait until rising_edge(clk) and ready = '1'; 
        a <= std_logic_vector(TO_UNSIGNED(ta,W)); 
        b <= std_logic_vector(TO_UNSIGNED(tb,W)); 
        n <= std_logic_vector(TO_UNSIGNED(tn,W)); 
        start <= '1'; 
        wait until rising_edge(clk); 
        start <= '0'; 
        wait until rising_edge(clk) and done = '1';
        
        if TO_INTEGER(unsigned(result)) /= texp then
            errors := errors + 1; 
        end if;
        assert TO_INTEGER(unsigned(result)) = texp
            report "FAIL: a=" & integer'image(ta) & " b=" & integer'image(tb) &
                   " n=" & integer'image(tn) & " got " & 
                   integer'image(TO_INTEGER(unsigned(result))) &
                   " expected " & integer'image(texp)
            severity error; 
        end procedure;
        
        
     begin 
        -- reset for a few cycle 
        reset_n <= '0'; 
        wait for 3 * CLK_PERIOD; 
        reset_n <= '1'; 
        
        -- expected = a*b*16^-1 mod 13   (R = 2^W = 16)   
        run_test(7,  3, 13, 7);   -- trace example: S = 8, 12, 14, 7
        run_test(0,  5, 13, 0);   -- a = 0 -> 0
        run_test(1,  1, 13, 9);   -- 16^-1 mod 13 = 9
        run_test(12, 12, 13, 9);  -- largest b (n-1)
        run_test(15, 12, 13, 8);  -- a uses all 4 bits
        run_test(5,  1, 13, 6);   -- like "convert out": MonPro(x, 1)
    
        report "Done: " & integer'image(errors) & " error(s)" severity note;
        std.env.finish;
      end process;

end Behavioral;
