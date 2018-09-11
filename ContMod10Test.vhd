LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY ContMod10Test IS
END ContMod10Test;
 
ARCHITECTURE behavior OF ContMod10Test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ContMod10
    PORT(
         up : IN  std_logic;
         en : IN  std_logic;
         clk : IN  std_logic;
         reset : IN  std_logic;
         q : OUT  std_logic_vector(3 downto 0);
         max_tick : OUT  std_logic;
         min_tick : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal up : std_logic := '0';
   signal en : std_logic := '0';
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal q : std_logic_vector(3 downto 0);
   signal max_tick : std_logic;
   signal min_tick : std_logic;

   constant clk_period : time := 10 ns;
	constant max : std_logic_vector(3 downto 0) := "1001";
	constant zeros: std_logic_vector(3 downto 0) := "0000";
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ContMod10 PORT MAP (
          up => up,
          en => en,
          clk => clk,
          reset => reset,
          q => q,
          max_tick => max_tick,
          min_tick => min_tick
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
      -- hold reset state for 100 ns.
		reset <= '1';
      wait for 100 ns;
		reset <= '0';

      wait for clk_period*5;
		
		--me sincronizo al falling edge del clk
		wait until (falling_edge(clk));

      --primero me fijo si esta todo en cero
		assert (q = zeros) report "al principio no da cero" severity failure;
		assert (min_tick = '1' and max_tick = '0') report "los ticks no funcionan desp de resetear" severity failure;
		
		--ahora contemos hasta nueve
		en <= '1'; up <= '1';
		for i in 1 to 9 loop
			wait for clk_period;
			assert (q = std_logic_vector(to_unsigned(i,4))) report "no suma bien" severity failure;
			if (not(i=9)) then
				assert (min_tick = '0' and max_tick = '0') report "los ticks prenden mientras estoy sumando" severity failure;
			end if;
		end loop;
		
		--en este punto el max tick deberia estar prendido
		assert (min_tick = '0' and max_tick = '1') report "el max tick no prende en 9" severity failure;
		
		--si espero un clock, el q deberia ir a 0 y el min tick deberia prenderse
		wait for clk_period;
		assert (q = zeros) report "no pasa a 0 desp de 9" severity failure;
		assert (min_tick = '1' and max_tick = '0') report "los ticks despues de reciclear de 9 a 0 no funcan" severity failure;
		
		--ahora restemos
		up <= '0';
		wait for clk_period;
		assert (q = max) report "no pasa a 9 desp de 0" severity failure;
		assert (min_tick = '0' and max_tick = '1') report "los ticks despues de reciclear de 0 a 9 no funcan" severity failure;
		
		--sigamos restando
		for j in -8 to 0 loop
			wait for clk_period;
			assert (q = std_logic_vector(to_unsigned(abs(j),4))) report "no resta bien" severity failure;
			if (not(j=0)) then
				assert (min_tick = '0' and max_tick = '0') report "los ticks prenden mientras estoy restando" severity failure;
			end if;
		end loop;
		
		--en este punto el min tick deberia esta prendido
		assert (min_tick = '1' and max_tick = '0') report "el min tick no prende en 000" severity failure;
		
		--todo en orden
		assert false report "todo bien :D" severity failure;
		

      wait;
   end process;

END;
