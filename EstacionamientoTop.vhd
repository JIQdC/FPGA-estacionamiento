library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity EstacionamientoTop is
	port(
		clk, reset: in std_logic;
		a,b: in std_logic;
		continue: std_logic;
		sseg: out std_logic_vector(7 downto 0);
		an: out std_logic_vector(3 downto 0);
		ledFSM,ledcont: out std_logic_vector(1 downto 0)
		);
		
end EstacionamientoTop;

architecture arch of EstacionamientoTop is
	signal inc, dec: std_logic;
	signal db1, db2: std_logic;
	signal dig: std_logic_vector(15 downto 0);
	signal errFSM, errcont: std_logic;
begin

	--instancio dos debouncers para limpiar las senales de entrada
	debouncer1: entity work.db_fsm(arch)
		port map(clk => clk, reset => reset, sw => a, db => db1);
	debouncer2: entity work.db_fsm(arch)
		port map(clk => clk, reset => reset, sw => b, db => db2);
		
	--instancio la FSM detectora de movimiento
	MovDetect: entity work.MovDetect(arch)
		port map(clk => clk, reset => reset, a => db1, b => db2, inc => inc,
		dec => dec, errFSM => errFSM);
		
	--instancio el contador de autos
	ContAutos: entity work.ContDec4Dig(arch)
		port map(clk => clk, reset => reset, inc => inc, dec => dec,
		dig => dig, errcont => errcont);
		
	--instancio el conversor a sseg
	ConvSseg: entity work.DisplayMultiplexing(arch)
		port map(clk => clk, reset => reset, input => dig, sseg => sseg, an => an);
	
	--instancio el selector de errores
	ErrSelect: entity work.LedErrSelect(arch)
		port map(clk => clk, reset => reset, errFSM => errFSM, errcont => errcont,
		continue => continue, ledFSM => ledFSM, ledcont => ledcont);

end arch;

