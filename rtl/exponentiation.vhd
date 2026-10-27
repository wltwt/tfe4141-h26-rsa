library ieee;
use ieee.std_logic_1164.all;

entity exponentiation is
	generic (
		C_block_size : integer := 256
	);
	port (
		--input controll
		valid_in	: in STD_LOGIC;
		ready_in	: out STD_LOGIC;

		--input data
		message 	: in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
		key 		: in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );

		--ouput controll
		ready_out	: in STD_LOGIC;
		valid_out	: out STD_LOGIC;

		--output data
		result 		: out STD_LOGIC_VECTOR(C_block_size-1 downto 0);

		--modulus
		modulus 	: in STD_LOGIC_VECTOR(C_block_size-1 downto 0);

		--utility
		clk 		: in STD_LOGIC;
		reset_n 	: in STD_LOGIC;
		
		-- temporary inputs until arm-interface is up and running
		r_mod_n  	: in std_logic_vector(C_block_size-1 downto 0);
		r2_mod_n 	: in std_logic_vector(C_block_size-1 downto 0)
	);
end exponentiation;


architecture expBehave of exponentiation is
	
	-- controller states
	type state_t is (
		ST_IDLE,
		ST_PREPARE,
		ST_MP_START,
		ST_MP_WAIT,
		ST_BASE_READY,
		ST_SQUARE_READY,
		ST_NEXT_BIT,
		ST_HOLD_RESULT
	);

	signal state 		: state_t;
	signal return_state : state_t;
	signal bit_index : integer range 0 to C_block_size-1;

	-- input registers
	signal message_reg 	: std_logic_vector(C_block_size-1 downto 0);
	signal exponent_reg : std_logic_vector(C_block_size-1 downto 0);
	signal modulus_reg	: std_logic_vector(C_block_size-1 downto 0);
	signal acc_reg		: std_logic_vector(C_block_size-1 downto 0);

	-- montgomery registers/signals
	signal mp_a      : std_logic_vector(C_block_size-1 downto 0);
	signal mp_b      : std_logic_vector(C_block_size-1 downto 0);

	signal mp_result : std_logic_vector(C_block_size-1 downto 0);

	-- captured Montgomery result for the continuation state
	signal product_reg : std_logic_vector(C_block_size-1 downto 0);

	signal mp_start  : std_logic;
	signal mp_ready  : std_logic;
	signal mp_done   : std_logic;

begin


	-- port map montgomery unit
	i_montgomery : entity work.montgomery_core
		generic map (
			C_WIDTH => C_block_size
		)
		port map (
			clk     => clk,
			reset_n => reset_n,

			start   => mp_start,
			ready   => mp_ready,
			done    => mp_done,

			a       => mp_a,
			b       => mp_b,
			n       => modulus_reg,
			result  => mp_result
		);

	-- control signals --

	-- visible to RSA-core / signals whether core can accept new messages or not
	ready_in <= '1' when state = ST_IDLE and reset_n = '1' else '0';
	--result <= message xor modulus;
	--ready_in <= ready_out;
	valid_out <= '1' when state = ST_HOLD_RESULT and reset_n = '1'
				else '0';

	result <= product_reg;


	controller : process(clk)
	begin
		if rising_edge(clk) then
			if reset_n = '0' then
				state 			<= ST_IDLE;
				message_reg 	<= (others => '0');
				exponent_reg 	<= (others => '0');
				modulus_reg 	<= (others => '0');
				product_reg 	<= (others => '0');
				bit_index <= C_block_size-1;
				mp_start <= '0';
			else
				mp_start <= '0';
				case state is
					when ST_IDLE => -- handshake and load registers
						if valid_in = '1' and ready_in = '1' then
							message_reg 	<= message;
							exponent_reg 	<= key;
							modulus_reg 	<= modulus;
							state <= ST_PREPARE;
						end if;

					when ST_PREPARE => -- initialize message conversion
						acc_reg <= r_mod_n;
						mp_a 	<= message_reg;
						mp_b	<= r2_mod_n;
						
						-- set states
						return_state 	<= ST_BASE_READY;
						state 			<= ST_MP_START;
					
					when ST_MP_START => -- request montgomery work
						if mp_ready = '1' then
							mp_start <= '1';
							
							-- go to waiting state
							state <= ST_MP_WAIT;
						end if;
					
					when ST_MP_WAIT => -- wait for response from mp
						if mp_done = '1' then
							product_reg <= mp_result;
							state <= return_state;
						end if;

					when ST_BASE_READY => -- first montgomery operation completed
						message_reg <= product_reg;
						bit_index <= C_block_size-1;
						mp_a <= acc_reg;
						mp_b <= acc_reg;
						return_state <= ST_SQUARE_READY;
						state <= ST_MP_START;

					when ST_SQUARE_READY => -- continue square
						if exponent_reg(bit_index) = '1' then
							mp_a <= product_reg;
							mp_b <= message_reg;
							return_state <= ST_NEXT_BIT;
							state <= ST_MP_START;
						else
							state <= ST_NEXT_BIT;
						end if;

					when ST_NEXT_BIT => -- iterate bits in the exponent sequence
						acc_reg <= product_reg;
						mp_a <= product_reg;
						if bit_index = 0 then
							mp_b <= (0 => '1', others => '0');
							return_state <= ST_HOLD_RESULT;
						else
							bit_index <= bit_index - 1;
							mp_b <= product_reg;
							return_state <= ST_SQUARE_READY;
						end if;
						state <= ST_MP_START;

					when ST_HOLD_RESULT => -- hold the final result until the output handshake
						if ready_out = '1' then
							state <= ST_IDLE;
						end if;
				end case;
			end if;
		end if;
	end process controller;


end expBehave;
