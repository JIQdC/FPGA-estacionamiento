library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ContMod10 is
	generic(N: integer := 4);
	port(
		up,en: in std_logic;
		clk, reset: in std_logic;
		q: out std_logic_vector(N-1 downto 0);
		max_tick, min_tick: out std_logic
	);
end ContMod10;

architecture arch of ContMod10 is
	signal sum, res: unsigned(N-1 downto 0);
	signal r_reg, r_next: std_logic_vector(N-1 downto 0);
	constant zeros: std_logic_vector(N-1 downto 0) := (others => '0');
	constant max: std_logic_vector(N-1 downto 0) := "1001";

begin
	--register
	process(clk,reset)
	begin
		if (reset = '1') then
			r_reg <= (others => '0');
		elsif (rising_edge(clk)) then
			r_reg <= r_next;
		end if;
	end process;
	
	--next state logic
	sum <= 1 + unsigned(r_reg);
	res <= unsigned(r_reg) - 1;
	
	r_next <= r_reg when en = '0' else
				 std_logic_vector(sum) when (up = '1' and not(r_reg = max)) else
				 (others => '0') when (up = '1' and r_reg = max) else
				 std_logic_vector(res) when (up = '0' and not(r_reg = zeros)) else
				 max;
				 
	--output logic
	q <= r_reg;
	max_tick <= '1' when (r_reg = max) else '0';
	min_tick <= '1' when (r_reg = zeros) else '0';
		

end arch;

