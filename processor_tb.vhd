use std.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity processor_tb is
	generic (
		infile		:	string := "sample.asc";
		addrfile	:	string := "sample.lst";
		resultfile	:	string := "result_sample.txt"
	);
end processor_tb;

architecture arch_processor_tb of processor_tb is
	component processor
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
	end component;
	
	signal clk		: std_logic;
	signal rst		: std_logic;
	signal run		: std_logic;
	signal wen		: std_logic;
	signal addr		: std_logic_vector(31 downto 0);
	signal din		: std_logic_vector(31 downto 0);
	signal dout		: std_logic_vector(31 downto 0);
	signal fin		: std_logic;
	signal PCout	: std_logic_vector(31 downto 0);
	signal regaddr	: std_logic_vector(4 downto 0);
	signal regdout	: std_logic_vector(31 downto 0);
	
	signal hexcode	: std_logic_vector(3 downto 0);
	signal endaddr	: std_logic_vector(31 downto 0);
	signal dout_buf	: std_logic_vector(31 downto 0);
begin
	P:	processor
	port map (
		clk		=> clk,
		rst		=> rst,
		run		=> run,
		wen		=> wen,
		addr	=> addr,
		din		=> din,
		dout	=> dout,
		fin		=> fin,
		PCout	=> PCout,
		regaddr	=> regaddr,
		regdout	=> regdout
	);
	
	process
	begin
		clk <= '0';
		wait for 50 ns;
		clk <= '1';
		wait for 50 ns;
	end process;
	
	process
		procedure hex2stdvec(signal dcode : out std_logic_vector(3 downto 0);
			variable c : in character;
			variable good : out boolean) is
		begin
			if c = 'F' or c = 'f' then
				good := true;
				dcode <= "1111";
			elsif c = 'E' or c = 'e' then
				good := true;
				dcode <= "1110";
			elsif c = 'D' or c = 'd' then
				good := true;
				dcode <= "1101";
			elsif c = 'C' or c = 'c' then
				good := true;
				dcode <= "1100";
			elsif c = 'B' or c = 'b' then
				good := true;
				dcode <= "1011";
			elsif c = 'A' or c = 'a' then
				good := true;
				dcode <= "1010";
			elsif c = '9' then
				good := true;
				dcode <= "1001";
			elsif c = '8' then
				good := true;
				dcode <= "1000";
			elsif c = '7' then
				good := true;
				dcode <= "0111";
			elsif c = '6' then
				good := true;
				dcode <= "0110";
			elsif c = '5' then
				good := true;
				dcode <= "0101";
			elsif c = '4' then
				good := true;
				dcode <= "0100";
			elsif c = '3' then
				good := true;
				dcode <= "0011";
			elsif c = '2' then
				good := true;
				dcode <= "0010";
			elsif c = '1' then
				good := true;
				dcode <= "0001";
			elsif c = '0' then
				good := true;
				dcode <= "0000";
			else
				good := false;
				dcode <= "XXXX";
			end if;
		end hex2stdvec;

		procedure stdvec2hex(variable c : out character;
			signal din : in std_logic_vector(3 downto 0);
			variable good : out boolean) is
		begin
			if din = "1111" then
				good := true;
				c := 'F';
			elsif din = "1110" then
				good := true;
				c := 'E';
			elsif din = "1101" then
				good := true;
				c := 'D';
			elsif din = "1100" then
				good := true;
				c := 'C';
			elsif din = "1011" then
				good := true;
				c := 'B';
			elsif din = "1010" then
				good := true;
				c := 'A';
			elsif din = "1001" then
				good := true;
				c := '9';
			elsif din = "1000" then
				good := true;
				c := '8';
			elsif din = "0111" then
				good := true;
				c := '7';
			elsif din = "0110" then
				good := true;
				c := '6';
			elsif din = "0101" then
				good := true;
				c := '5';
			elsif din = "0100" then
				good := true;
				c := '4';
			elsif din = "0011" then
				good := true;
				c := '3';
			elsif din = "0010" then
				good := true;
				c := '2';
			elsif din = "0001" then
				good := true;
				c := '1';
			elsif din = "0000" then
				good := true;
				c := '0';
			else
				good := false;
				c := 'X';
			end if;
		end stdvec2hex;

		file ifile			: text open read_mode is infile;
		file afile			: text open read_mode is addrfile;
		file rfile			: text open write_mode is resultfile;
		variable l, message	: line;
		variable c			: character;
		variable i			: natural;
		variable count		: natural;
		variable good		: boolean;
		variable correct	: boolean;
	begin
		rst <= '1';
		run <= '0';
		wen <= '0';
		addr <= (others => '0');
		din <= (others => '0');
		regaddr <= (others => '0');
		hexcode <= (others => '0');
		dout_buf <= (others => '0');
		wait for 130 ns;
		rst <= '0';
		
		write(message, string'("Loading Program into Memory"));
		writeline(output, message);
		writeline(output, message);
		
		while (not endfile(ifile)) loop
			readline(ifile, l);
			wen <= '0';
			din <= "00000000000000000000000000000000";
			correct := true;
			wait for 8 ns;
			for i in 0 to 7 loop
				read(l, c, good);
				
				if good = true then	
					hex2stdvec(hexcode, c, good);
					wait for 1 ns;
					if good = true then
						din <= din(27 downto 0) & hexcode;
					else
						correct := false;
					end if;
					wait for 1 ns;
				else
					correct := false;
					wait for 2 ns;
				end if;
			end loop;
			while not(c = '#') and good = true loop
				read(l, c, good);
				if good = false then
					correct := false;
				end if;
			end loop;
			read(l, c, good);
			if good = true then
				addr <= "00000000000000000000000000000000";
				for i in 0 to 7 loop
					read(l, c, good);
					if good = true then
						hex2stdvec(hexcode, c, good);
						wait for 1 ns;
						if good = true then
							addr <= addr(27 downto 0) & hexcode;
						else
							correct := false;
						end if;
						wait for 1 ns;
					else
						correct := false;
						wait for 2 ns;
					end if;
				end loop;

			else
				correct := false;
			end if;						
			wait for 60 ns;
			
			if correct = true then
				wen <= '1';
				wait for 100 ns;
			end if;
		end loop;
		wen <= '0';
		wait for 100 ns;
		
		run <= '1';
		wait for 100 ns;
		run <= '0';

		while not(fin = '1') loop
			wait for 100 ns;
		end loop;
		
		write(message, string'("Saving Memory Content"));
		writeline(output, message);
		writeline(output, message);
		
		l := null;
		write(l, string'("Memory Value"));
		writeline(rfile, l);
		
		while not(endfile(afile)) loop
			readline(afile, l);
			addr <= "00000000000000000000000000000000";
			wait for 4 ns;
			for i in 0 to 7 loop
				read(l, c, good);
				if good = true then
					hex2stdvec(hexcode, c, good);
					wait for 1 ns;
					if good = true then
						addr <= addr(27 downto 0) & hexcode;
					end if;
					wait for 1 ns;
				else
					wait for 2 ns;
				end if;
			end loop;
			read(l, c, good);
			
			endaddr <= "00000000000000000000000000000000";
			wait for 4 ns;
			for i in 0 to 7 loop
				read(l, c, good);
				if good = true then
					hex2stdvec(hexcode, c, good);
					wait for 1 ns;
					if good = true then
						endaddr <= endaddr(27 downto 0) & hexcode;
					end if;
					wait for 1 ns;
				else
					wait for 2 ns;
				end if;
			end loop;
			endaddr <= endaddr + 4;
			wait for 60 ns;
			
			while not(addr = endaddr) loop
		
				l := null;
				dout_buf <= dout;
				wait for 2 ns;
				for i in 0 to 7 loop
					stdvec2hex(c, dout_buf(31 downto 28), good);
					write(l, c);
					dout_buf <= dout_buf(27 downto 0) & "0000";
					wait for 1 ns;
				end loop;
				
				c := HT;				
				write(l, c);
				dout_buf <= addr;
				wait for 2 ns;
				for i in 0 to 7 loop
					stdvec2hex(c, dout_buf(31 downto 28), good);
					write(l, c);
					dout_buf <= dout_buf(27 downto 0) & "0000";
					wait for 1 ns;
				end loop;
				writeline(rfile, l);
				
				addr <= addr + 4;
				wait for 80 ns;
			end loop;
		end loop;

		write(message, string'("Saving Register Content"));
		writeline(output, message);
		writeline(output, message);
				
		l := null;
		writeline(rfile, l);
		
		l := null;
		write(l, string'("Register Value"));
		writeline(rfile, l);
		
		regaddr <= "00000";
		count := 0;
		wait for 90 ns;
		while not(count = 32) loop
			l := null;
			dout_buf <= regdout;
			wait for 2 ns;
			for i in 0 to 7 loop
				stdvec2hex(c, dout_buf(31 downto 28), good);
				write(l, c);
				dout_buf <= dout_buf(27 downto 0) & "0000";
				wait for 1 ns;
			end loop;
			
			c := HT;				
			write(l, c);
			write(l, count);
			writeline(rfile, l);
			
			regaddr <= regaddr + 1;
			count := count + 1;
			wait for 90 ns;
		end loop;

		l := null;
		dout_buf <= PCout;
		wait for 2 ns;
		for i in 0 to 7 loop
			stdvec2hex(c, dout_buf(31 downto 28), good);
			write(l, c);
			dout_buf <= dout_buf(27 downto 0) & "0000";
			wait for 1 ns;
		end loop;
		c := HT;
		write(l, c);
		write(l, string'("PC"));
		writeline(rfile, l);
		wait for 90 ns;

		write(message, string'("Writing Result Complete"));
		writeline(output, message);
		writeline(output, message);
		
		while fin = '1' loop
			wait for 100 ns;
		end loop;
	end process;
end arch_processor_tb;
			
					
				
