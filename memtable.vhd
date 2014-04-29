library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity memtable is
	port (
		clk		:	in std_logic;
		rst		:	in std_logic;
		instaddr:	in std_logic_vector(31 downto 0);
		instout	:	out std_logic_vector(31 downto 0);
		wen		:	in std_logic;
		addr	:	in std_logic_vector(31 downto 0);
		din		:	in std_logic_vector(31 downto 0);
		dout	:	out std_logic_vector(31 downto 0);
		extwen	:	in std_logic;
		extaddr	:	in std_logic_vector(31 downto 0);
		extdin	:	in std_logic_vector(31 downto 0);
		extdout	:	out std_logic_vector(31 downto 0)
	);
end memtable;

architecture arch_memtable of memtable is
	constant msize:	natural := 16383; --word size
	type memdata is array (0 to msize) of std_logic_vector(31 downto 0);
	signal MT : memdata;
begin
	process(clk, rst)
		variable addri, extaddri : integer;
	begin
		if rst = '1' then
			for i in 0 to msize loop
				MT(i) <= (others => '0');
			end loop;
		elsif clk'event and clk = '1' then
			if wen = '1' then
				addri := conv_integer(addr(31 downto 2));
				if addri >= 0 and addri <= msize then
					MT(addri) <= din;
				end if;
			end if;
			if extwen = '1' then
				extaddri := conv_integer(extaddr(31 downto 2));
				if extaddri >= 0 and extaddri <= msize then
					MT(extaddri) <= extdin;
				end if;
			end if;
		end if;
	end process;
	
	process(addr, MT)
		variable addri: integer;
	begin
		dout <= (others => '0');
		addri := conv_integer(addr(31 downto 2));
		if addri >= 0 and addri <= msize then
			dout <= MT(addri);
		end if;
	end process;
	
	process(instaddr, MT)
		variable addri: integer;
	begin
		instout <= (others => '0');
		addri := conv_integer(instaddr(31 downto 2));
		if addri >= 0 and addri <= msize then
			instout <= MT(addri);
		end if;
	end process;

	process(extaddr, MT)
		variable extaddri: integer;
	begin
		extdout <= (others => '0');
		extaddri := conv_integer(extaddr(31 downto 2));
		if extaddri >= 0 and extaddri <= msize then
			extdout <= MT(extaddri);
		end if;
	end process;

end arch_memtable;
