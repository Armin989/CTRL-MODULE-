library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Ctrl_tb is
end entity;


architecture Sim of Ctrl_tb is

   -----------------------------------------------------------------------------
   -- Constant declaration
   -----------------------------------------------------------------------------

	constant CLK_PER : time := 20 ns;    -- 50 MHz

   -----------------------------------------------------------------------------
   -- Component declarasion
   -----------------------------------------------------------------------------
	component Ctrl is
		port(
			clk  : in std_logic;
			rstn : in std_logic;
			key : in std_logic; 
         baudsel : in std_logic_vector(2 downto 0); 
	      parity : in std_logic_vector(1 downto 0); 
			
			buss : inout std_logic_vector(7 downto 0);
			adr  : out std_logic_vector(4 downto 0);
			WR   : out std_logic;
			RD   : out std_logic;
			LED  : out std_logic);

	end component Ctrl;

   -----------------------------------------------------------------------------
   -- Signal declaration
   -----------------------------------------------------------------------------
   -- DUT signals
	signal clk_tb  : std_logic;
	signal rstn_tb : std_logic;
	signal key_tb  : std_logic;
	signal baudsel_tb : std_logic_vector(2 downto 0); 
	signal parity_tb: std_logic_vector(1 downto 0);
	
	signal buss_tb : std_logic_vector(7 downto 0);
	signal adr_tb  : std_logic_vector(4 downto 0);
	signal WR_tb   : std_logic;
	signal RD_tb   : std_logic;
	signal LED_tb  : std_logic;

   -- Testbench signals
  
begin

   -----------------------------------------------------------------------------
   -- Component instantiations
   -----------------------------------------------------------------------------
	i_Ctrl: component Ctrl
		port map (
			clk  => clk_tb,
			rstn => rstn_tb,
			key => key_tb,
			baudsel => baudsel_tb,
			parity => parity_tb,
			
			buss => buss_tb,
			adr  => adr_tb,
			WR   => WR_tb,
			RD   => RD_tb,
      	LED  => LED_tb
		);


p_clk: process is
  begin   
    clk_tb <= '0';
    wait for CLK_PER/2;
    clk_tb <= '1';
    wait for CLK_PER/2;
  end process p_clk;

  p_rst_n: process is
  begin        
    rstn_tb <= '0';
    wait for 2.2*CLK_PER;
    rstn_tb <= '1';
    wait;
  end process p_rst_n;

		
state_machine: process
   begin
      -- Initialize signals
	buss_tb <= "ZZZZZZZZ";
	adr_tb  <= "00000";
	WR_tb   <= '0';
	RD_tb   <= '0';
	baudsel_tb <= "000";  -- Random verdi
   parity_tb <= "00";    
   key_tb <= '1';
   LED_tb <= '0';	


	wait until rstn_tb = '1';
	wait for 50 ns;
	wait until rising_edge(clk_tb);

	adr_tb  <= "00000";
	wait for CLK_PER;
	WR_tb   <= '0';
	RD_tb   <= '0';
	buss_tb <= (others => 'Z');

	wait for 10*CLK_PER;
	key_tb <= '0'; 

	wait 5 ms; 
	assert false report "Testbench finished" severity failure;

   end process state_machine;

end architecture SIM;