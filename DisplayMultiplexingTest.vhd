library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DisplayMultiplexingTest is
	port(
		clk, reset: in std_logic;
		sw: in std_logic_vector(3 downto 0);
		btn: in std_logic_vector(3 downto 0);
		sseg: out std_logic_vector(7 downto 0);
		an: out std_logic_vector(3 downto 0)
		);
end DisplayMultiplexingTest;

architecture arch of DisplayMultiplexingTest is
	signal input: std_logic_vector(15 downto 0);
	signal reg1, next1, reg2, next2, reg3, next3, reg4, next4: std_logic_vector(3 downto 0);
	--me armo 4 registros, que cargan el numero que este en los switches en
	--el slot correspondiente del input del dispmux

	begin
	
	--registro 1
	process(clk,reset,btn)
	begin
		if(reset = '1') then
			reg1 <= (others => '0');
		elsif(rising_edge(clk) and (btn(3) = '1')) then
			reg1 <= next1;
		end if;
	end process;
	
	--logica de prox estado 1
	next1 <= sw;
			
	--registro 2
	process(clk,reset,btn)
	begin
		if(reset = '1') then
			reg2 <= (others => '0');
		elsif(rising_edge(clk) and (btn(2) = '1')) then
			reg2 <= next2;
		end if;
	end process;
	
	--logica de prox estado 1
	next2 <= sw;
	
	--registro 3
	process(clk,reset,btn)
	begin
		if(reset = '1') then
			reg3 <= (others => '0');
		elsif(rising_edge(clk) and (btn(1) = '1')) then
			reg3 <= next3;
		end if;
	end process;
	
	--logica de prox estado 1
	next3 <= sw;
	
	--registro 4
	process(clk,reset,btn)
	begin
		if(reset = '1') then
			reg4 <= (others => '0');
		elsif(rising_edge(clk) and (btn(0) = '1')) then
			reg4 <= next4;
		end if;
	end process;
	
	--logica de prox estado 4
	next4 <= sw;
	
	--armo el input concatenando los 4 registros
	input <= reg1 & reg2 & reg3 & reg4;
	
	--le paso el input al dispmux
	DispMux: entity work.DisplayMultiplexing(arch)
		port map(clk => clk, reset => reset, input => input,
		sseg => sseg, an => an);


end arch;

