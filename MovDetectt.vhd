--Implementacion de una FSM para la deteccion de entrada/salida
--de autos a un estacionamiento, utilizando dos sensores en el
--acceso al mismo.
--
-----------------------
--
--- - - - - - - - - - -
--
-----------------------
--		|		|
--		|		|-Sensor a
--		|		|
--		|		|
--		|		|-Sensor b
--		|		|
--		|		|
----------------------
--							|
--	Estacionamiento	|
--							|
--							|
--							
--Para que una entrada/salida se compute como valida, debe completarse
--una secuencia de 4 pasos. Si esto sucede, se activan senales que
--indican el movimiento que se produjo.
--
--Si sucede una secuencia invalida, se notifica el error a traves de una
--senal de error.
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MovDetect is
	port(
		clk, reset: in std_logic;
		a,b: in std_logic;
		inc, dec: out std_logic;
		errFSM: out std_logic
		);
end MovDetect;

architecture arch of MovDetect is
	type state_type is (rep,sal1,sal2,sal3,salf,ent1,ent2,ent3,entf,error);
	signal state_reg, state_next: state_type;
begin
	--state register
	process(clk, reset)
	begin
		if (reset = '1') then
			state_reg <= rep;
		elsif (rising_edge(clk)) then
			state_reg <= state_next;
		end if;
	end process;
	
	--next state logic
	process(state_reg,a,b)
	begin
		state_next <= error;

		case state_reg is
			--los casos no previstos son error
		
			--estado de reposo
			when rep =>
				--no cambio
				if (a = '0' and b = '0') then
					state_next <= rep;
				--auto entrando pasa al estado ent1
				elsif (a = '1' and b = '0') then
					state_next <= ent1;
				--auto saliendo pasa al estado sal1
				elsif (a = '0' and b = '1') then
					state_next <= sal1;
				--cualquier otro estado es un error de deteccion
--				else
--					state_next <= error;
				end if;
				
			--estado ent1
			when ent1 =>
				--no cambio
				if (a = '1' and b = '0') then
					state_next <= ent1;
				--si se apagan todos los sensores, vuelve a reposo
				elsif (a = '0' and b = '0') then
					state_next <= rep;
				--si sigue entrando, pasa a ent2
				elsif (a = '1' and b = '1') then
					state_next <= ent2;
				--cualquier otro estado es un error de deteccion
--				else
--					state_next <= error;	
				end if;
				
			--estado ent2
			when ent2 =>
				--no cambio
				if (a = '1' and b = '1') then
					state_next <= ent2;
				--si se apaga el sensor b, vuelve al estado ent1
				elsif (a = '1' and b = '0') then
					state_next <= ent1;
				--si sigue avanzando, se apaga el sensor a, y pasa al estado ent3
				elsif (a = '0' and b = '1') then
					state_next <= ent3;
				--cualquier otro estado es un error de deteccion
--				else
--					state_next <= error;
				end if;
					
			--estado ent3
			when ent3 =>
				--no cambio
				if (a = '0' and b = '1') then
					state_next <= ent3;
				--si se apagan todos los sensores, pasa al estado final entf
				elsif (a = '0' and b = '0') then
					state_next <= entf;
				--si se prende a, vuelve al estado anterior
				elsif (a = '1' and b = '1') then
					state_next <= ent2;
				--cualquier otro estado es un error de deteccion
--				else
--					state_next <= error;
				end if;
					
			--estado entf
			when entf =>
				--el estado entf se alcanza cuando ya completo el proceso de entrada.
				--por lo tanto, vuelvo a estado de reposo
				state_next <= rep;

			--estado sal1
			when sal1 =>
				--no cambio
				if (a = '0' and b = '1') then
					state_next <= sal1;
				--si se apagan todos los sensores, vuelve a reposo
				elsif (a = '0' and b = '0') then
					state_next <= rep;
				--si sigue saliendo, pasa a sal2
				elsif (a = '1' and b = '1') then
					state_next <= sal2;
				--cualquier otro estado es un error de deteccion
--				else
--					state_next <= error;
				end if;
					
			--estado sal2
			when sal2 =>
				--no cambio
				if (a = '1' and b = '1') then
					state_next <= sal2;
				--si se apaga el sensor a, vuelve al estado sal1
				elsif (a = '0' and b = '1') then
					state_next <= sal1;
				--si sigue avanzando, se apaga el sensor b, y pasa al estado sal3
				elsif (a = '1' and b = '0') then
					state_next <= sal3;
				--cualquier otro estado es un error de deteccion
--				else
--					state_next <= error;
				end if;
					
			--estado sal3
			when sal3 =>
				if (a = '1' and b = '0') then
					state_next <= sal3;
				--si se apagan todos los sensores, pasa al estado final salf
				elsif (a = '0' and b = '0') then
					state_next <= salf;
				--si se prende b, vuelve al estado anterior
				elsif (a = '1' and b = '1') then
					state_next <= sal2;
				--cualquier otro estado es un error de deteccion
--				else
--					state_next <= error;
				end if;
					
			--estado salf
			when salf =>
				--el estado salf se alcanza cuando ya completo el proceso de salida.
				--por lo tanto, vuelvo a estado de reposo
				state_next <= rep;
				
			--estado de error
			when error =>
				--el estado de error se produce al detectar una secuencia invalida de encendido de sensores
				--pasa al estado de reposo
				state_next <= rep;
				
		end case;
	end process;
	
	--Moore output logic
	process(state_reg)
	begin
		case state_reg is
			--si entro un auto, activo inc
			when entf =>
				inc <= '1';
				dec <= '0';
				errFSM <= '0';
			--si salio un auto, activo dec
			when salf =>
				inc <= '0';
				dec <= '1';
				errFSM <= '0';
			--si estoy en un error, prendo el 
			when error =>
				inc <= '0';
				dec <= '0';
				errFSM <= '1';
			--en cualquier otro caso, ambas salidas estan apagadas
			when others =>
				inc <= '0';
				dec <= '0';
				errFSM <= '0';
		end case;
	end process;
		
end arch;