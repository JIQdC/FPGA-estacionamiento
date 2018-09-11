--Contador de 4 digitos decimales
--
--Contador sincrono que cuenta desde 0000 a 9999, sumando o restando en funcion
--de los valores de sus senales de control inc y dec.
--El valor actual del contador se entrega como una senal de 16 bits codificada en
--BCD.
--Si quiero contar por debajo de 0000 o por arriba de 9999, activo una senal de 
--error y no sigo contando. 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ContDec4Dig is
	port(
		clk, reset: in std_logic;
		inc, dec: in std_logic;
		dig: out std_logic_vector(15 downto 0);
		errcont: out std_logic
	);
end ContDec4Dig;

architecture arch of ContDec4Dig is
	signal max1, max2, max3, max4: std_logic;
	signal min1, min2, min3, min4: std_logic;
	signal en1, en2, en3, en4: std_logic;
	signal up1, up2, up3, up4: std_logic;
	signal dig1,dig2,dig3,dig4: std_logic_vector(3 downto 0);
	signal error: std_logic;
	constant digmin: std_logic_vector(3 downto 0):= (others => '0');
	constant digmax: std_logic_vector(3 downto 0) := "1001";
begin

	--instancio 4 contadores mod10
	cont1: entity work.ContMod10(arch)
		port map(clk => clk, reset => reset, max_tick => max1, min_tick => min1,
		up => up1, en => en1, q => dig1);
	cont2: entity work.ContMod10(arch)
		port map(clk => clk, reset => reset, max_tick => max2, min_tick => min2,
		up => up2, en => en2, q => dig2);
	cont3: entity work.ContMod10(arch)
		port map(clk => clk, reset => reset, max_tick => max3, min_tick => min3,
		up => up3, en => en3, q => dig3);
	cont4: entity work.ContMod10(arch)
		port map(clk => clk, reset => reset, max_tick => max4, min_tick => min4,
		up => up4, en => en4, q => dig4);
		
	--si llego a 9999 y quiero sumar, o si llego a 0000 y quiero restar, es un error
	error <= (max4 and max3 and max2 and max1 and inc) or (min1 and min2 and min3 and min4 and dec);
	
	--el error controla el tick de error
	errcont <= error;
		
	--el digito de las unidades se mueve solamente cuando esta prendida una de las
	--dos senales de cambio y cuando no esta prendida la senal de error...
	en1 <= (inc xor dec) and (not(error));
	--y suma solo cuando esta prendido inc
	up1 <= inc and (not(dec));
	
	--el digito de las decenas se mueve solamente cuando quiero sumar y tengo las
	--unidades llenas, o cuando quiero restar y tengo las unidades vacias, y siempre
	--que no este prendido el error...
	en2 <= ((max1 and inc) or (min1 and dec)) and (not(error));
	--suma cuando quiero sumar, sino no.
	up2 <= inc;
	
	--en las centenas, sumo cuando tengo al maximo las decenas y las unidades
	--y resto cuando tengo al minimo las decenas y las unidades
	--y siempre que no tenga prendido el error
	en3 <= ((max2 and max1 and inc) or (min2 and min1 and dec)) and (not(error));
	up3 <= inc;
	
	--y aca sigo la misma logica
	en4 <= ((max3 and max2 and max1 and inc) or (min3 and min2 and min1 and dec)) and (not(error));
	up4 <= inc;
	
	--la senal de salida es la concatenacion de los digitos (formato BCD)
	dig <= dig4 & dig3 & dig2 & dig1;
		
end arch;
