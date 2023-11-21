library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ctrl is
  port (
    clk : in std_logic; -- 50MHz
    rstn : in std_logic; -- Key0
    key : in std_logic; -- Key1
    baudsel : in std_logic_vector(2 downto 0); -- SW3, SW2 og SW1
	 parity : in std_logic_vector(1 downto 0); -- Sw5 og SW4 
	 
    LED : out std_logic; -- LEDR0
    ADR : out std_logic_vector(4 downto 0); -- 
    RD : out std_logic;
	 WR : out std_logic;
	 buss : inout std_logic_vector(7 downto 0) -- Tristate ('Z') etter data har blitt sendt.
 
 );
end entity ctrl; 

architecture RTL of ctrl is
 -------------------------------------------------------------------------------
 -- Konstanter
 ------------------------------------------------------------------------------- 
  constant charA : std_logic_vector(7 downto 0) := "01000001"; --'A'01000001       PROBLEMER MED AT 1 TOLKES SOM UNSIGNED
  constant TARGET_COUNT : integer := 2500000; -- teller saa mange klokkefrekvenser som tilsvarer 50ms
  constant Txconfig : std_logic_vector(4 downto 0) := "00000"; 
  constant TxStatus : std_logic_vector(4 downto 0) := "00010";
  constant TxData : std_logic_vector(4 downto 0) := "00001";
  
  --Tx setter buss verdien som "00000000" naar den er klar til aa motta signal
  constant TX_Klar : std_logic_vector(7 downto 0) := "00000000";
  type statetype is (config, waitkey, checkstatus); 
 
 -------------------------------------------------------------------------------
 -- Signaler
 ------------------------------------------------------------------------------- 
  signal tilstand : statetype; 
  signal counter : integer range 0 to TARGET_COUNT; --Tellevariabel for varigheten til LED lyset. 
  --Lager en variabel for knappen som brukes til aa sjekke naar knapp-verdien gaar fra
  --1 til 0. Slik at datainnholdet endres kun naar knappen blir trykket og ikke presset
  signal key_prev_state : std_logic := '1';
  --signal paritybit : std_logic;
 -------------------------------------------------------------------------------
 -- Funkjson
 -------------------------------------------------------------------------------
--Skal kanskje vaere i Tx-modulen, men ser ikke grunn til aa fjerne den naa.
 
 --Funksjonen tar inn 2 'variabler' den ene som er dataen den skal sjekke enere paa 
--og den andre blir "modus" altsaa parity som sier om den skal legge til parity partall/odde
function calculate_parity(data: std_logic_vector; mode: std_logic_vector) return std_logic is
    variable count: natural := 0;
begin
    for i in data'range loop
        if data(i) = '1' then
            count := count + 1;
        end if;
    end loop;

    case mode is
        when "00" => return 'Z'; -- ingen parity, setter den bare som 'Z' siden da skal funksjonen ikke vaere brukt
        when "01" => -- even parity
            if count/2*2 = count then -- blir det same som "mod 2" hvis count = 3, da blir uttrykket count/2 = 3/2 (=1 i VHDL de runner ned)
                return '1';
            else
                return '0';
            end if;
        when "10" => -- odd parity
            if count/2*2 /= count then 
                return '1';
            else
                return '0';
            end if;
        when others => return 'Z'; --Setter den bare som 'Z' 
    end case;
end function calculate_parity;

  
begin
  process(clk, rstn)
  begin 
    if rstn = '0' then
      
	tilstand <= statetype'left; --config
	counter <= TARGET_COUNT;
	LED <= '0'; -- default 0
	RD <= '0'; --default 0
        WR <= '0'; -- default 0
        buss <= (others => 'Z'); --Dette skal sette hele data til "tristate"?
        ADR <= (others => 'Z');
	counter <= TARGET_COUNT; 
		
  --Kjoorer koden hvis rst_n ikke er '0'
	 elsif rising_edge(clk) then
	   	WR <= '0';
		RD <= '0';
		ADR <= (others => '0');
	        buss <= (others => 'Z');
		
		
		case tilstand is 
		  when config => 
		    LED <= '0';
		    WR <= '1';
	            ADR <= Txconfig;
	            buss <= "000" & parity & baudsel; -- parity: 2 bit, baudsel 3 bit
		    tilstand <= waitkey;
		  
		  when waitkey => 
		    if key = '0' and key_prev_state = '1' then
			counter <= 0; --starter LED
			RD <= '1'; 
			ADR <= Txstatus;
			tilstand <= checkstatus;	        
		    end if;
		    key_prev_state <= key;

		  when checkstatus => --Sjekke busy "flag"
			 if buss = TX_Klar then --Sjekke om Tx er optatt eller ikke.
			   ADR <= TxData;
				WR <= '1'; 
				buss <= charA;
				tilstand <= waitkey; --Gaar tilbake til aa vente paa knappetrykk 
			 end if;
			 
		end case; 


		if counter < (TARGET_COUNT-1) then
      		  counter <= counter + 1; 
                  LED <= '1'; -- LED Paa gjennom tellinga
                else
      		  LED <= '0'; -- LED AV etter tellinga
    		end if;

	 end if;
		 
  --Teller varigheten til LED
--    if counter < (TARGET_COUNT-1) then
--      counter <= counter + 1; 
--      LED <= '1'; -- LED Paa gjennom tellinga
--    else
--      LED <= '0'; -- LED AV etter tellinga
--    
--    end if;
	 

  end process;
 end architecture RTL;