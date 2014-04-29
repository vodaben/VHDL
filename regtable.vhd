library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity regtable is
	port (
		clk		:	in std_logic;
		rst		:	in std_logic;
		raddrA	:	in std_logic_vector(4 downto 0);
		raddrB	:	in std_logic_vector(4 downto 0);
		wen		:	in std_logic;
		waddr	:	in std_logic_vector(4 downto 0);
		din		:	in std_logic_vector(31 downto 0);
		doutA	:	out std_logic_vector(31 downto 0);
		doutB	:	out std_logic_vector(31 downto 0);
		extaddr	:	in std_logic_vector(4 downto 0);
		extdout	:	out std_logic_vector(31 downto 0)
	);
end regtable;

architecture arch_regtable of regtable is
	type regdata is array (0 to 31) of std_logic_vector(31 downto 0);
	signal RT : regdata;
begin
	process(clk, rst)
		variable addri : integer;
	begin
		if rst = '1' then
			RT(0) <= (others => '0');
			RT(1) <= (others => '0');
			RT(2) <= (others => '0');
			RT(3) <= (others => '0');
			RT(4) <= (others => '0');
			RT(5) <= (others => '0');
			RT(6) <= (others => '0');
			RT(7) <= (others => '0');
			RT(8) <= (others => '0');
			RT(9) <= (others => '0');
			RT(10) <= (others => '0');
			RT(11) <= (others => '0');
			RT(12) <= (others => '0');
			RT(13) <= (others => '0');
			RT(14) <= (others => '0');
			RT(15) <= (others => '0');
			RT(16) <= (others => '0');
			RT(17) <= (others => '0');
			RT(18) <= (others => '0');
			RT(19) <= (others => '0');
			RT(20) <= (others => '0');
			RT(21) <= (others => '0');
			RT(22) <= (others => '0');
			RT(23) <= (others => '0');
			RT(24) <= (others => '0');
			RT(25) <= (others => '0');
			RT(26) <= (others => '0');
			RT(27) <= (others => '0');
			RT(28) <= "00000000000000001100000000000000";
			RT(29) <= "00000000000000001111111111111100";
			RT(30) <= (others => '0');
			RT(31) <= (others => '0');
		elsif clk'event and clk = '1' then
			if wen = '1' then
				addri := conv_integer(waddr);
				if not(addri = 0) then
					RT(addri) <= din;
				end if;
			end if;
		end if;
	end process;
	
	process(raddrA, raddrB, extaddr, RT)
		variable addrAi, addrBi, extaddri : integer;
	begin
		addrAi := conv_integer(raddrA);
		addrBi := conv_integer(raddrB);
		extaddri := conv_integer(extaddr);
		doutA <= RT(addrAi);
		doutB <= RT(addrBi);
		extdout <= RT(extaddri);
	end process;
end arch_regtable;
