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
		reset_n 	: in STD_LOGIC
	);
end exponentiation;


architecture expBehave of exponentiation is
	type state_t is (IDLE, PREPARE);
	signal state : state_t;

	signal message_reg 	: std_logic_vector(C_block_size-1 downto 0);
	signal exponent_reg : std_logic_vector(C_block_size-1 downto 0);
	signal modulus_reg	: std_logic_vector(C_block_size-1 downto 0);

	signal mp_a      : std_logic_vector(C_block_size-1 downto 0);
	signal mp_b      : std_logic_vector(C_block_size-1 downto 0);

	signal mp_result : std_logic_vector(C_block_size-1 downto 0);

	signal mp_start  : std_logic;
	signal mp_ready  : std_logic;
	signal mp_done   : std_logic;

begin

	-- stuff
	ready_in <= '1' when state = IDLE and reset_n = '1' else '0';
	result <= message xor modulus;
	--ready_in <= ready_out;
	valid_out <= valid_in;


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



	controller : process(clk)
	begin
		if rising_edge(clk) then
			if reset_n = '0' then
				state 			<= IDLE;
				message_reg 	<= (others => '0');
				exponent_reg 	<= (others => '0');
				modulus_reg 	<= (others => '0');
			else
				case state is
					when IDLE => -- load registers
						if valid_in = '1' and ready_in = '1' then
							message_reg 	<= message;
							exponent_reg 	<= key;
							modulus_reg 	<= modulus;
							state <= PREPARE;
						end if;

					when PREPARE =>
						null;
				end case;
			end if;
		end if;
	end process controller;


end expBehave;
