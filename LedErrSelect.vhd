library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity LedErrSelect is
	port(
		clk, reset: in std_logic;
		errFSM, errcont: in std_logic;
		continue: in std_logic;
		ledFSM, ledcont: out std_logic_vector(1 downto 0)
		);
end LedErrSelect;

architecture arch of LedErrSelect is
	type state_type is (ok, fsm, contador, general);
	signal state_reg, state_next: state_type;
begin

	--state register
	process(clk, reset)
	begin
		if(reset = '1') then
			state_reg <= ok;
		elsif(rising_edge(clk)) then
			state_reg <= state_next;
		end if;
	end process;
	
	--next state logic
	process(state_reg,errFSM, errcont,continue)
	begin
		case state_reg is
			--estado OK
			when ok =>
				if (errFSM = '0' and errcont = '0') then
					state_next <= ok;
				elsif (errFSM = '1' and errcont = '0') then
					state_next <= fsm;
				elsif (errFSM = '0' and errcont = '1') then
					state_next <= contador;
				elsif (errFSM = '1' and errcont = '1') then
					state_next <= general;
				else
					state_next <= ok;
				end if;
			--estado de error de la fsm
			when fsm =>
				if (continue = '1') then
					state_next <= ok;
				elsif (errFSM = '0' and errcont = '1') then
					state_next <= contador;
				elsif (errFSM = '1' and errcont = '1') then
					state_next <= general;
				else
					state_next <= fsm;
				end if;
			--estado de error del contador
			when contador =>
				if (continue = '1') then
					state_next <= ok;
				elsif (errFSM = '1' and errcont = '1') then
					state_next <= general;
				elsif (errFSM = '1' and errcont = '0') then
					state_next <= fsm;
				else
					state_next <= contador;
				end if;
			--estado de error general
			when general =>
				if (continue = '1') then
					state_next <= ok;
				elsif (errFSM = '1' and errcont = '0') then
					state_next <= fsm;
				elsif (errFSM = '0' and errcont = '1') then
					state_next <= contador;
				else
					state_next <= general;
				end if;
		end case;
	end process;
	
	--Moore output
	process(state_reg)
	begin
		case state_reg is
			--estado ok
			when ok =>
				ledFSM <= "00";
				ledcont <= "00";
			when fsm =>
				ledFSM <= "11";
				ledcont <= "00";
			when contador =>
				ledFSM <= "00";
				ledcont <= "11";
			when general =>
				ledFSM <= "11";
				ledcont <= "11";
		end case;
	end process;

end arch;

