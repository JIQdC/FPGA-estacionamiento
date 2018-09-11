LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY MovDetectTest IS
END MovDetectTest;
 
ARCHITECTURE behavior OF MovDetectTest IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT MovDetect
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         a : IN  std_logic;
         b : IN  std_logic;
         inc : OUT  std_logic;
         dec : OUT  std_logic;
         errFSM : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal a : std_logic := '0';
   signal b : std_logic := '0';

 	--Outputs
   signal inc : std_logic;
   signal dec : std_logic;
   signal errFSM : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: MovDetect PORT MAP (
          clk => clk,
          reset => reset,
          a => a,
          b => b,
          inc => inc,
          dec => dec,
          errFSM => errFSM
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
      reset <= '1';
      wait for 50 ns;
		reset <= '0';
		
		wait until (falling_edge(clk));
		wait for clk_period*2;

      --al principio deberia estar todo apagado
		assert ((inc = '0') and (dec = '0') and (errFSM = '0')) report "hay algo prendido desp del reset" severity failure;
		
		
		--secuencia de auto de entrada
		a <= '1'; b <= '0';
		wait for clk_period*2;
		a <= '1'; b <= '1';
		wait for clk_period*2;
		a <= '0'; b <= '1';
		wait for clk_period*2;
		a <= '0'; b <= '0';
		wait for clk_period;
		assert (inc = '1') report "no detecta auto de entrada" severity failure;
		assert ((dec = '0') and (errFSM = '0')) report "dec o errFSM se prenden desp de auto de entrada" severity failure;
		wait for clk_period;
		assert ((inc = '0') and (dec = '0') and (errFSM = '0')) report "no vuelve a estado de reposo desp de auto de entrada" severity failure;
		wait for clk_period;
		
		--secuencia de auto de salida
		b <= '1'; a <= '0';
		wait for clk_period*2;
		b <= '1'; a <= '1';
		wait for clk_period*2;
		b <= '0'; a <= '1';
		wait for clk_period*2;
		b <= '0'; a <= '0';
		wait for clk_period;
		assert (dec = '1') report "no detecta auto de salida" severity failure;
		assert ((inc = '0') and (errFSM = '0')) report "inc o errFSM se prenden desp de auto de salida" severity failure;
		wait for clk_period;
		assert ((inc = '0') and (dec = '0') and (errFSM = '0')) report "no vuelve a estado de reposo desp de auto de salida" severity failure;
		wait for clk_period;
		
		--secuencia erronea en salida
		b <= '1'; a <= '0';
		wait for clk_period*2;
		b <= '1'; a <= '1';
		wait for clk_period*2;
		b <= '0'; a <= '0'; --esto es un error
		wait for clk_period;
		assert (errFSM = '1') report "no detecta error en salida" severity failure;
		assert ((inc = '0') and (dec = '0')) report "suma o resta con error en salida" severity failure;
		wait for clk_period;
		assert ((inc = '0') and (dec = '0') and (errFSM = '0')) report "no vuelve a estado de reposo desp de error en salida" severity failure;
		wait for clk_period;
		
		--secuencia erronea en entrada
		a <= '1'; b <= '0';
		wait for clk_period*2;
		a <= '1'; b <= '1';
		wait for clk_period*2;
		a <= '0'; b <= '0'; --esto es un error
		wait for clk_period;
		assert (errFSM = '1') report "no detecta error en entrada" severity failure;
		assert ((inc = '0') and (dec = '0')) report "suma o resta con error en entrada" severity failure;
		wait for clk_period;
		assert ((inc = '0') and (dec = '0') and (errFSM = '0')) report "no vuelve a estado de reposo desp de error en entrada" severity failure;
		wait for clk_period;

		--secuencia interrumpida de salida
		b <= '1'; a <= '0';
		wait for clk_period*2;
		b <= '1'; a <= '1';
		wait for clk_period*2;
		b <= '1'; a <= '0';
		wait for clk_period*2;
		b <= '0'; a <= '0';
		wait for clk_period*2;
		assert ((inc = '0') and (dec = '0') and (errFSM = '0')) report "no vuelve a estado de reposo desp de sec interrumpida de salida" severity failure;
		
		--secuencia interrumpida de entrada
		a <= '1'; b <= '0';
		wait for clk_period*2;
		a <= '1'; b <= '1';
		wait for clk_period*2;
		a <= '0'; b <= '1';
		wait for clk_period*2;
		a <= '1'; b <= '1';
		wait for clk_period*2;
		a <= '1'; b <= '0';
		wait for clk_period*2;
		a <= '0'; b <= '0';
		wait for clk_period*2;
		assert ((inc = '0') and (dec = '0') and (errFSM = '0')) report "no vuelve a estado de reposo desp de sec interrumpida de entrada" severity failure;
		
		--todo bien
		assert false report "todo bien :D" severity failure;		
		
      wait;
   end process;

END;
