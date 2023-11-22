library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TX_tb is
end entity;


architecture Sim of TX_tb is

   -----------------------------------------------------------------------------
   -- Constant declaration
   -----------------------------------------------------------------------------

	constant CLK_PER : time := 20 ns;    -- 50 MHz

   -----------------------------------------------------------------------------
   -- Component declarasion
   -----------------------------------------------------------------------------
	component TX is
		port(
			clk  : in std_logic;
			rstn : in std_logic;
			buss : inout std_logic_vector(7 downto 0);
			adr  : in std_logic_vector(4 downto 0);
			WR   : in std_logic;
			RD   : in std_logic;
			TxD  : out std_logic);

	end component TX;

   -----------------------------------------------------------------------------
   -- Signal declaration
   -----------------------------------------------------------------------------
   -- DUT signals
	signal clk_tb  : std_logic;
	signal rstn_tb : std_logic;
	signal buss_tb : std_logic_vector(7 downto 0);
	signal adr_tb  : std_logic_vector(4 downto 0);
	signal WR_tb   : std_logic;
	signal RD_tb   : std_logic;
	signal TxD_tb  : std_logic;

   -- Testbench signals
  
begin

   -----------------------------------------------------------------------------
   -- Component instantiations
   -----------------------------------------------------------------------------
	i_TX: component TX
		port map (
			clk  => clk_tb,
			rstn => rstn_tb,
			buss => buss_tb,
			adr  => adr_tb,
			WR   => WR_tb,
			RD   => RD_tb,
      			TxD  => TxD_tb
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

		
	state_machine: process is
	begin
      -- Initialize signals
		buss_tb <= (others => 'Z');
		adr_tb  <= "00000";
		WR_tb   <= '0';
		RD_tb   <= '0';

		wait until rstn_tb = '1';
		wait for 50 ns;
		wait until rising_edge(clk_tb);
                wait for 1 ns;

-- Konfigurering 115.2k og ingen paritet:
		WR_tb   <= '1';
		adr_tb  <= "00000";
		buss_tb <= "00010001";
                wait for CLK_PER;
		WR_tb   <= '0';
		buss_tb <= (others => 'Z');

		wait for 10*CLK_PER;

		WR_tb   <= '1';
		adr_tb  <= "00001";
		buss_tb <= "01000010";
		wait for CLK_PER;
		WR_tb   <= '0';
		buss_tb <= (others => 'Z');

		wait for 1 ms;
		assert false report "Testbench finished" severity failure;

	end process state_machine;

end architecture SIM;
