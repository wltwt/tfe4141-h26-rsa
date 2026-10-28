----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/28/2026 06:03:06 PM
-- Design Name: 
-- Module Name: exponentiation_tb - Behavioral
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

entity exponentiation_tb is
--  Port ( );


end exponentiation_tb;


architecture Behavioral of exponentiation_tb is
    constant WIDTH : positive := 8;

    -- Signals declared before begin.
    signal clk       : std_logic := '0';
    signal reset_n   : std_logic := '0';

    signal valid_in  : std_logic := '0';
    signal ready_in  : std_logic;

    signal ready_out : std_logic := '1';
    signal valid_out : std_logic;

    signal message, key, modulus :
        std_logic_vector(WIDTH-1 downto 0) := (others => '0');

    signal r_mod_n, r2_mod_n :
        std_logic_vector(WIDTH-1 downto 0) := (others => '0');

    signal result : std_logic_vector(WIDTH-1 downto 0);

begin
    -- setup dut
    dut : entity work.exponentiation
        generic map (
            C_block_size => WIDTH
        )
        port map (
            clk       => clk,
            reset_n   => reset_n,

            valid_in  => valid_in,
            ready_in  => ready_in,
            message   => message,
            key       => key,
            modulus   => modulus,

            r_mod_n   => r_mod_n,
            r2_mod_n  => r2_mod_n,

            ready_out => ready_out,
            valid_out => valid_out,
            result    => result
        );

    -- clock gen
    clk <= not clk after 5 ns;
    

    modulus <= std_logic_vector(to_unsigned(13, WIDTH));
    
    -- precomputed values simplified testbench thing
    r_mod_n  <= std_logic_vector(to_unsigned(9, WIDTH));
    r2_mod_n <= std_logic_vector(to_unsigned(3, WIDTH));
            

    stim : process
    begin
        -- release reset
        wait for 100 ns;
        reset_n <= '1';
        wait for 50 ns;

        -- setup test values for test 1
        message <= std_logic_vector(to_unsigned(5, WIDTH));
        key     <= std_logic_vector(to_unsigned(3, WIDTH));
        
        -- start handshake
        valid_in <= '1';

        -- wait for the clock edge where the DUT accepts it
        wait until rising_edge(clk) and ready_in = '1';
        valid_in <= '0';

        -- wait for the answer
        wait until rising_edge(clk) and valid_out = '1'
            for 100 us;

        assert valid_out = '1'
            report "Timeout: no result received"
            severity failure;

        assert result = std_logic_vector(to_unsigned(8, WIDTH))
            report "FAIL: expected 5^3 mod 13 = 8"
            severity failure;

        report "Test 1 PASS: Received expected result" severity note;
        report "Next Test: 5^0 mod 13" severity note;
        

        
        -- reset
        reset_n <= '0';
        
        -- release reset
        wait for 100 ns;
        reset_n <= '1';
        wait for 50 ns;

        -- test 5^0 mod 13
        key     <= std_logic_vector(to_unsigned(0, WIDTH));
        message <= std_logic_vector(to_unsigned(5, WIDTH));

        -- start handshake again
        valid_in <= '1';

        -- let it do its job
        wait until rising_edge(clk) and ready_in = '1';
        valid_in <= '0';

        -- wait for the answer
        wait until rising_edge(clk) and valid_out = '1'
            for 100 us;

        assert valid_out = '1'
            report "Timeout: no result received"
            severity failure;

        assert result = std_logic_vector(to_unsigned(1, WIDTH))
            report "FAIL: expected 5^0 mod 13 = 1"
            severity failure;

        report "Test 2 PASS: Received expected result" severity note;
        report "Next Test: 5^1 mod 13" severity note;

        -- reset
        reset_n <= '0';
        
        -- release reset
        wait for 100 ns;
        reset_n <= '1';
        wait for 50 ns;

        -- test 5^1 mod 13
        key     <= std_logic_vector(to_unsigned(1, WIDTH));
        message <= std_logic_vector(to_unsigned(5, WIDTH));

        -- start handshake again
        valid_in <= '1';
        
        -- let it do its job
        wait until rising_edge(clk) and ready_in = '1';
        valid_in <= '0';

        -- wait for the answer
        wait until rising_edge(clk) and valid_out = '1'
            for 100 us;

        assert valid_out = '1'
            report "Timeout: no result received"
            severity failure;

        assert result = std_logic_vector(to_unsigned(5, WIDTH))
            report "FAIL: expected 5^1 mod 13 = 5"
            severity failure;

        report "Test 3 PASS: Received expected result" severity note;
        report "Next Test: 5^3 mod 13" severity note;

        -- reset
        reset_n <= '0';
        
        -- release reset
        wait for 100 ns;
        reset_n <= '1';
        wait for 50 ns;

        -- test 7^3 mod 13
        message <= std_logic_vector(to_unsigned(7, WIDTH));
        key     <= std_logic_vector(to_unsigned(3, WIDTH));

        -- start handshake again
        valid_in <= '1';
        
        -- let it do its job
        wait until rising_edge(clk) and ready_in = '1';
        valid_in <= '0';

        -- wait for the answer
        wait until rising_edge(clk) and valid_out = '1'
            for 100 us;

        assert valid_out = '1'
            report "Timeout: no result received"
            severity failure;

        assert result = std_logic_vector(to_unsigned(5, WIDTH))
            report "FAIL: expected 7^3 mod 13 = 5"
            severity failure;

        report "Test 4 PASS: Received expected result" severity note;
        std.env.stop;
        wait;
    end process;

end Behavioral;