library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

	
entity TX is

	port(
		clk : in std_logic;
		rstn : in std_logic;
		buss : inout std_logic_vector(7 downto 0);
		adr : in std_logic_vector(4 downto 0);
		WR : in std_logic;
		RD : in std_logic;
		TxD : out std_logic);
		
end entity TX;

architecture RTL of TX is

	constant adr_config : std_logic_vector := "00000";
	constant adr_data : std_logic_vector := "00001";
	constant adr_status : std_logic_vector := "00010";

	type state_machine_type is (config, waiting, start, transfer, parity, stop);
	signal state_machine : state_machine_type;
	
	signal busy : std_logic;
	signal count_out : std_logic;
	signal parity_set : std_logic_vector(1 downto 0);
	signal parity_calc : std_logic;
	signal baudrate : std_logic_vector(2 downto 0);
	signal TxData : std_logic_vector(7 downto 0);

begin
	
	p_state_machine : process(clk, rstn) is
	
		variable count_trnsf : integer;
	
	begin
		if rstn = '0' then 
			-- sette alt man tilordner nedenunder til startverdi
			count_trnsf := 0; 
		elsif rising_edge(clk) then
			case state_machine is
				when config =>
					if (WR = '1' and ADR = adr_config) then
						baudrate <= buss(2 downto 0);
						parity_set <= buss(4 downto 3);
						state_machine <= waiting;
					end if; 
				
				when waiting =>
					busy <= '0';
					if (WR = '1' and ADR = adr_data) then
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
							count_trnsf := 0;
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
		end if;
		
	end process p_state_machine;
	
	
	set_busy_flag_pros : process(clk, rstn) is
	begin
	
		if rstn = '0' then
			buss <= (others => 'Z');
		elsif rising_edge(clk) then
			if (RD = '1' and adr = adr_status) then --- konstandt for adr
				buss <= "0000000" & busy;
			else
				buss <= (others => 'Z');
			end if;
		end if;
		
	end process set_busy_flag_pros;	


end architecture RTL;
