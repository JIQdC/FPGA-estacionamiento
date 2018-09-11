LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY LedErrSelectTest IS
END LedErrSelectTest;
 
ARCHITECTURE behavior OF LedErrSelectTest IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT LedErrSelect
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         errFSM : IN  std_logic;
         errcont : IN  std_logic;
         continue : IN  std_logic;
         ledFSM : OUT  std_logic_vector(1 downto 0);
         ledcont : OUT  std_logic_vector(1 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal errFSM : std_logic := '0';
   signal errcont : std_logic := '0';
   signal continue : std_logic := '0';

 	--Outputs
   signal ledFSM : std_logic_vector(1 downto 0);
   signal ledcont : std_logic_vector(1 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: LedErrSelect PORT MAP (
          clk => clk,
          reset => reset,
          errFSM => errFSM,
          errcont => errcont,
          continue => continue,
          ledFSM => ledFSM,
          ledcont => ledcont
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin
      -- hold reset state for 50 ns.
		reset <= '1';
      wait for 50 ns;
		reset <= '0';
		
      wait for clk_period*3;
		
		--sincronizo con el falling edge del clock
		wait until (falling_edge(clk));
		wait for clk_period;
		
		--primero chequeo que este todo apagado
		assert (ledFSM = "00") report "ledFSM prende desp de reset" severity failure;
		assert (ledcont = "00") report "ledcont prende desp de reset"  severity failure;
		
		--chequeo el ledFSM
		errFSM <= '1';
		wait for 2*clk_period;
		assert (ledFSM = "11") report "ledFSM no prende con errFSM"  severity failure;
		assert (ledcont = "00") report "ledcont prende con errFSM"  severity failure;
		errFSM <= '0';
		
		--deberia seguir prendido
		wait for 2*clk_period;
		assert (ledFSM = "11") report "ledFSM no sigue prendido desp de errFSM"  severity failure;
		assert (ledcont = "00") report "ledcont no sigue prendido desp de errFSM"  severity failure;
		
		--volvamos al estado de reposo activando el continue
		wait for clk_period;
		continue <= '1';
		wait for clk_period;
		assert (ledFSM = "00") report "ledFSM no se apaga desp de continue desp de errFSM" severity failure;
		assert (ledcont = "00") report "ledcont no se apaga desp de continue desp de errFSM" severity failure;
		continue <= '0';

		--chequeo el ledcont
		errcont <= '1';
		wait for 2*clk_period;
		assert (ledFSM = "00") report "ledFSM prende con errcont"  severity failure;
		assert (ledcont = "11") report "ledcont no prende con errcont"  severity failure;
		errcont <= '0';
		
		--deberia seguir prendido
		wait for 2*clk_period;
		assert (ledFSM = "00") report "ledFSM no sigue prendido desp de errcont"  severity failure;
		assert (ledcont = "11") report "ledcont no sigue prendido desp de errcont"  severity failure;
		
		--volvamos al estado de reposo activando el continue
		wait for clk_period;
		continue <= '1';
		wait for clk_period;
		assert (ledFSM = "00") report "ledFSM no se apaga desp de continue desp de errcont" severity failure;
		assert (ledcont = "00") report "ledcont no se apaga desp de continue desp de errcont" severity failure;
		continue <= '0';
		
		--chequeo error general
		errcont <= '1'; errFSM <= '1';
		wait for 2*clk_period;
		assert (ledFSM = "11") report "ledFSM no prende con err general"  severity failure;
		assert (ledcont = "11") report "ledcont no prende con err general"  severity failure;
		
		--deberia seguir prendido
		wait for 2*clk_period;
		assert (ledFSM = "11") report "ledFSM no sigue prendido desp de err general"  severity failure;
		assert (ledcont = "11") report "ledcont no sigue prendido desp de err general"  severity failure;
		
		--volvamos al estado de reposo activando el continue
		wait for clk_period;
		continue <= '1';
		wait for clk_period;
		assert (ledFSM = "00") report "ledFSM no se apaga desp de continue desp de err general" severity failure;
		assert (ledcont = "00") report "ledcont no se apaga desp de continue desp de err general" severity failure;
		continue <= '0';

		--todo bien
		assert false report "todo bien :D" severity failure;

      wait;
   end process;

END;
