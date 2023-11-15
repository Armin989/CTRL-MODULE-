--fil for TX

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

	
entity TX is

	port(
		clk : in std_logic;
		rstn : in std_logic;
		buss : inout std_logic_vector(7 downto 0);
		adr : in std_logic_vector(4 downto 0); -- små bokstaver på signaler
		WR : in std_logic;
		RD : in std_logic;
		TxD : out std_logic);
		
end entity TX;

architecture RTL of TX is

	type state_machine_type is (config, waiting, start, transfer, parity, stop);
	
	signal state_machine : state_machine_type;
	signal busy : std_logic;
	signal count_out : std_logic;
	signal parity_set : std_logic_vector(1 downto 0);
	signal parity_calc : std_logic;
	signal baudrate : std_logic_vector(2 downto 0);
	signal TxData : std_logic_vector(7 downto 0);

begin
	state_machine_pros : process (clk, rstn) is
		variable count_trnsf : integer;
	begin
		if rstn = '0' then 
			-- sette alt man tilordner nedenunder til startverdi
			count_trnsf := 0; 
		elsif rising_edge(clk) then
			-- innrykk alt under
		case state_machine is
			when config =>
				if (WR = '1' and ADR = "00000") then -- adr som egen constant (txconfig, txdata og txstatus)
					--tilordne txconfig. de tre siste bit lagres i buadrate, feks. 
					baudrate <= buss(2 downto 0);
					-- gjør det samme med paritet
					parity_set <= buss(4 downto 3);
					state_machine <= waiting;
				end if; 
				
			when waiting =>
				busy <= '0';
				if (WR = '1' and ADR = "00001") then
					TxData <= buss;
					busy <= '1';
					state_machine <= start;
				end if;
			when start =>
				if count_out = '1' then
					TxD <= '0';
					state_machine <= transfer;
				end if;

			when transfer =>
				if count_out = '1' then
					TxD <= TxData(count_trnsf);
					if count_trnsf = 7 then
						count_trnsf := '0';
						if parity_set = ("01" or "10")  then
							state_machine <= parity;
						else 
							state_machine <= stop;
						end if;
					else 
						count_trnsf := count_trnsf + 1;
					end if;
				end if;

			when parity =>
				if count_out = '1' then
					TxD <= parity_calc;
					state_machine <= stop;
				end if;

			when stop =>
				if count_out = '1' then
					TxD <= '1';
					state_machine <= waiting;
				end if;
		end case;
		
	end process state_machine_pros;	

	set_busy_flag_pros : process(clk, rstn) is
	begin
		if rstn = '0' then
			buss <= (others => 'Z');
		elsif rising_edge(clk) then
			if (RD = '1' and adr = "00010") then --- konstandt for adr
				buss <= "0000000" & busy;
			else
				buss <= (others => 'Z');
			end if;
		end if;
	end process set_busy_flag_pros;

        Baudrate: process(clk)
              variable count : integer;
        begin
               count := 0;
               if rising_edge(clk) then
		       case baudrate is	
			       when "000" =>  --Når baudrate=000, da er count_out='1' hvis count=434.
				      if rising_edge(clk) then --115.2k
					 count := count + 1;
		                      end if;
				      if count = 434 then
					 count_out <= '1';   
					 count := 0; --Resetter counter til 0.	
				      end if;
			       when "001" =>     
                                      if rising_edge(clk) then --38.4k
					 count := count + 1;
                                      end if;
				      if count = 1302 then
					 count_out <= '1';  
					 count := 0;	
				      end if;  
			       when "010" =>
                                      if rising_edge(clk) then --19.2k
					 count := count + 1;
				      end if;
				      if count = 2604 then
				         count_out <= '1';  
					 count := 0;	
				      end if;  
			       when "011" =>
				      if rising_edge(clk) then --9600
                                         count := count + 1;
                                      end if;
				      if count = 5208 then
					 count_out <= '1';  
					 count := 0;		
				      end if;
                               when others => null;
		        end case;
	       end if;	
   end process Baudrate;
	
   Paritet: process(clk) 
	variable even_odd : bit; --Lagrer bit verdien.
   begin
	  if rising_edge(clk) then
	     even_odd := to_bit(TxData(0)) xor to_bit(TxData(1)) xor to_bit(TxData(2)) xor to_bit(TxData(3)) xor to_bit(TxData(4)) xor to_bit(TxData(5)) xor to_bit(TxData(6)) xor to_bit(TxData(7)); --Når even_odd=0 da er TXdata odd osv.
	  end if;
	         case parity_set is
		      when "00" => parity_calc<='0';--Ingen paritet
	              when "01" => --Satt til even
			    if even_odd = '1' then  --TxData er even
			       parity_calc<='0';
			    elsif even_odd ='0' then--TxData er odd
			       parity_calc<='1';
			    end if;
		      when "10" => --Satt til odd
			    if even_odd = '1' then --TxData er even
			       parity_calc<='1';
			    elsif even_odd ='0' then--TxData er odd
			       parity_calc<='0';
		            end if; 	   
		      when others => null;
	         end case;
   end process Paritet;
end architecture RTL;

