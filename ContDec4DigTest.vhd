LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY ContDec4DigTest IS
END ContDec4DigTest;
 
ARCHITECTURE behavior OF ContDec4DigTest IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ContDec4Dig
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         inc : IN  std_logic;
         dec : IN  std_logic;
         dig : OUT  std_logic_vector(15 downto 0);
         conterror : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal inc : std_logic := '0';
   signal dec : std_logic := '0';

 	--Outputs
   signal dig : std_logic_vector(15 downto 0);
   signal conterror : std_logic;

   constant clk_period : time := 10 ns;
	constant zero : std_logic_vector(15 downto 0) := (others => '0');
	constant max : std_logic_vector(15 downto 0) := "1001" & "1001" & "1001" & "1001";
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ContDec4Dig PORT MAP (
          clk => clk,
          reset => reset,
          inc => inc,
          dec => dec,
          dig => dig,
          conterror => conterror
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
		--hold reset state for 100ns
      reset <= '1';
      wait for 100 ns;	
		reset <= '0';
      wait for clk_period*2;

		--sincronizo con el falling edge
		wait until (falling_edge(clk));
		
      --chequeo que todo este en 0
		assert (dig = zero) report "no esta en cero desp de resetear" severity failure;
		assert (conterror = '0') report "el tick de error esta prendido desp de resetear" severity failure;
		
		--si intento restar, no deberia cambiar nada, y deberia prenderme el tick de error
		dec <= '1';
		wait for 2*clk_period;
		assert (dig = zero) report "esta restando en 0" severity failure;
		assert (conterror = '1') report "el tick de error no prende" severity failure;
		dec <= '0';
		
		inc <= '1';
		--ahora contemos con un CUADRUPLE LOOP!! (espero que no explote....)
		for i in 0 to 9 loop
			for j in 0 to 9 loop
				for k in 0 to 9 loop
					for l in 0 to 9 loop
						assert (dig = std_logic_vector(to_unsigned(i,4)) & std_logic_vector(to_unsigned(j,4)) & std_logic_vector(to_unsigned(k,4))
						& std_logic_vector(to_unsigned(l,4))) report "no suma bien" severity failure;
						if ((not(dig=max)) and (not(dig=zero))) then
							assert(conterror = '0') report "el tick de error prende mientras suma" severity failure;
						end if;
						wait for clk_period;
					end loop;
				end loop;
			end loop;
		end loop;
		
		--en este momento deberia estar prendido el contador de error
		assert(conterror = '1') report "el contador de error no ta prendido" severity failure;
		--y si intento seguir sumando, no deberia pasar nada
		wait for 2*clk_period;
		assert(dig=max) report "esta sumando en max" severity failure;
		
		--dejemos de sumar
		inc <= '0';
		
		--ahora restemos con OTRO CUADRUPLE LOOP!!
		dec <= '1';
		for i in -9 to 0 loop
			for j in -9 to 0 loop
				for k in -9 to 0 loop
					for l in -9 to 0 loop
						assert (dig = std_logic_vector(to_unsigned(abs(i),4)) & std_logic_vector(to_unsigned(abs(j),4)) & std_logic_vector(to_unsigned(abs(k),4))
						& std_logic_vector(to_unsigned(abs(l),4))) report "no resta bien" severity failure;
						if ((not(dig=max)) and (not(dig=zero))) then
							assert(conterror = '0') report "el tick de error prende mientras resta" severity failure;
						end if;
						wait for clk_period;
					end loop;
				end loop;
			end loop;
		end loop;
		
		--todo bien
		assert false report "todo bien :D" severity failure;
   end process;

END;
