--Este modulo recibe una senal de 16 bits (15 mag + 1 sig),
--y genera una senal multiplexada que se dirige al display
--7seg, mostrando su valor numerico en sistema decimal
--La senal de entrada esta codificada en BCD.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DisplayMultiplexing is
	port(
		clk, reset: in std_logic;
		input: in std_logic_vector(15 downto 0);
		sseg: out std_logic_vector(7 downto 0);
		an: out std_logic_vector(3 downto 0)
		);
end DisplayMultiplexing;

architecture arch of DisplayMultiplexing is
	constant N: integer := 19;
	signal cont_reg, cont_next: unsigned(N-1 downto 0);
	signal sel: std_logic_vector(1 downto 0);
	signal dig: std_logic_vector(3 downto 0);
	
	begin
	
	--state register: aca tenemos que poner un contador de clocks
	--el clock tiene 100MHz, necesito mostrar 3ms cada digito
	--si uso una tira de 21 bits, puedo usar los dos ultimos como
	--contadores que se actualizaran cuando se muevan todos los 18
	--bits anteriores
	process(clk, reset)
	begin
		if (reset = '1') then
			cont_reg <= (others => '0');
		elsif (rising_edge(clk)) then
			cont_reg <= cont_next;
		end if;
	end process;
	
	--next_state logic
	cont_next <= cont_reg + 1;
	
	--senal de seleccion que se actualiza cada aprox 3ms
	sel <= std_logic_vector(cont_reg(N-1 downto N-2));
	
	with sel select
		an <=	"0111" when "00",  
				"1011" when "01",
				"1101" when "10",
				"1110" when "11";
					  
	with sel select
		dig <= 	input (15 downto 12) when "00",
					input (11 downto 8) when "01",
					input (7 downto 4) when "10",
					input (3 downto 0) when "11";
						
	ConvHexSsg: entity work.hex_to_ssg(arch)
		port map(hex => dig, sseg => sseg);	


end arch;

