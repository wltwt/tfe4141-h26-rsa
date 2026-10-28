--------------------------------------------------------------------------------
-- Author       : Oystein Gjermundnes
-- Organization : Norwegian University of Science and Technology (NTNU)
--                Department of Electronic Systems
--                https://www.ntnu.edu/ies
-- Course       : TFE4141 Design of digital systems 1 (DDS1)
-- Year         : 2018-2019
-- Project      : RSA accelerator
-- License      : This is free and unencumbered software released into the
--                public domain (UNLICENSE)
--------------------------------------------------------------------------------
-- Purpose:
--   RSA encryption core template. This core currently computes
--   C = M xor key_n
--
--   Replace/change this module so that it implements the function
--   C = M**key_e mod key_n.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity RSA_core is
	generic (
		-- Users to add parameters here
		C_BLOCK_SIZE          : integer := 256
	);
	port (
		-----------------------------------------------------------------------------
		-- Clocks and reset
		-----------------------------------------------------------------------------
		clk                    :  in std_logic;
		reset_n                :  in std_logic;

		-----------------------------------------------------------------------------
		-- Slave msgin interface
		-----------------------------------------------------------------------------
		-- Message that will be sent out is valid
		msgin_valid             : in std_logic;
		-- Slave ready to accept a new message
		msgin_ready             : out std_logic;
		-- Message that will be sent out of the rsa_msgin module
		msgin_data              :  in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
		-- Indicates boundary of last packet
		msgin_last              :  in std_logic;

		-----------------------------------------------------------------------------
		-- Master msgout interface
		-----------------------------------------------------------------------------
		-- Message that will be sent out is valid
		msgout_valid            : out std_logic;
		-- Slave ready to accept a new message
		msgout_ready            :  in std_logic;
		-- Message that will be sent out of the rsa_msgin module
		msgout_data             : out std_logic_vector(C_BLOCK_SIZE-1 downto 0);
		-- Indicates boundary of last packet
		msgout_last             : out std_logic;

		-----------------------------------------------------------------------------
		-- Interface to the register block
		-----------------------------------------------------------------------------
		key_e_d                 :  in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
		key_n                   :  in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
		rsa_status              : out std_logic_vector(31 downto 0)
	
		
	  

	);
end RSA_core;

architecture rtl of RSA_core is

    signal exp_msgout_valid : std_logic;
    signal exp_msgout_data  : std_logic_vector(C_BLOCK_SIZE-1 downto 0);

    signal ready_int : std_logic;

    signal last_reg : std_logic;
    signal busy     : std_logic;

begin

    ------------------------------------------------------------------
    -- Exponentiation engine
    ------------------------------------------------------------------
    i_exponentiation : entity work.exponentiation
        generic map (
            C_block_size => C_BLOCK_SIZE
        )
        port map (
            message   => msgin_data,
            key       => key_e_d,

            valid_in  => msgin_valid,
            ready_in  => ready_int,

            ready_out => msgout_ready,
            valid_out => exp_msgout_valid,

            result    => exp_msgout_data,

            modulus   => key_n,

            clk       => clk,
            reset_n   => reset_n
        );

    ------------------------------------------------------------------
    -- Connect handshake
    ------------------------------------------------------------------
    msgin_ready <= ready_int;

    ------------------------------------------------------------------
    -- Store msgin_last
    ------------------------------------------------------------------
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            last_reg <= '0';

        elsif rising_edge(clk) then

            if msgin_valid = '1' and ready_int = '1' then
                last_reg <= msgin_last;
            end if;

        end if;
    end process;

    ------------------------------------------------------------------
    -- Outputs
    ------------------------------------------------------------------
    msgout_valid <= exp_msgout_valid;
    msgout_data  <= exp_msgout_data;
    msgout_last  <= last_reg;

    ------------------------------------------------------------------
    -- Status register
    ------------------------------------------------------------------
    busy <= not ready_int;

    rsa_status <= (31 downto 1 => '0') & busy;

end rtl;
