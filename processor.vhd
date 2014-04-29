library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity processor is
	port (
		clk		:	in std_logic;
		rst		:	in std_logic;
		run		:	in std_logic;
		wen		:	in std_logic;
		addr	:	in std_logic_vector(31 downto 0);
		din		:	in std_logic_vector(31 downto 0);
		dout	:	out std_logic_vector(31 downto 0);
		fin		:	out std_logic;
		PCout	:	out std_logic_vector(31 downto 0);
		regaddr	:	in std_logic_vector(4 downto 0);
		regdout	:	out std_logic_vector(31 downto 0)
	);
end processor;
		
architecture arch_processor of processor is
	component memtable
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
	end component;
	component processor_core
		port (
			clk		:	in std_logic;
			rst		:	in std_logic;
			run		:	in std_logic;
			instaddr:	out std_logic_vector(31 downto 0);
			inst	:	in std_logic_vector(31 downto 0);
			memwen	:	out std_logic;
			memaddr	:	out std_logic_vector(31 downto 0);
			memdw	:	out std_logic_vector(31 downto 0);
			memdr	:	in std_logic_vector(31 downto 0);
			fin		:	out std_logic;
			PCout	:	out std_logic_vector(31 downto 0);
			regaddr	:	in std_logic_vector(4 downto 0);
			regdout	:	out std_logic_vector(31 downto 0)
		);
	end component;
	
	signal instaddr	: std_logic_vector(31 downto 0);
	signal inst		: std_logic_vector(31 downto 0);
	signal memwen	: std_logic;
	signal memaddr	: std_logic_vector(31 downto 0);
	signal memdw	: std_logic_vector(31 downto 0);
	signal memdr	: std_logic_vector(31 downto 0);
begin
	MAIN_MEM:	memtable
	port map (
		clk			=> clk,
		rst			=> rst,
		instaddr	=> instaddr,
		instout		=> inst,
		wen			=> memwen,
		addr		=> memaddr,
		din			=> memdw,
		dout		=> memdr,
		extwen		=> wen,
		extaddr		=> addr,
		extdin		=> din,
		extdout		=> dout
	);
	
	PCORE: processor_core
	port map (
		clk			=> clk,
		rst			=> rst,
		run			=> run,
		instaddr	=> instaddr,
		inst		=> inst,
		memwen		=> memwen,
		memaddr		=> memaddr,
		memdw		=> memdw,
		memdr		=> memdr,
		fin			=> fin,
		PCout		=> PCout,
		regaddr		=> regaddr,
		regdout		=> regdout
	);
end arch_processor;
