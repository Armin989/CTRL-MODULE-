library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity top-level is

port (

   clk, rstn, key: in std_logic;

   baudsel: in std_logic_vector (2 downto 0);

   parity: in std_logic_vector (1 downto 0);

   TxD, LED: out std_logic; 

 

end entity top-level;

 

 

architecture structural of top-level  is

signal 
    wr, rd: inout std_logic; 
     data: inout std_logic_vector (7 dwonto 0);
     adr: inout std_logic_vector (4 downto 0);
	
            

component ctrl is

  port (
      key, clk, rstn : in std_logic;
      buss: out std_logic_vector (7 downto 0);
      baudsel: in std_logic_vector(2 downto 0);
      parity: in std_logic_vector(1 downto 0);
      adr: out std_logic_vector (4 downto 0); 
      wr, rd, LED: out std_logic; 
 );
end component ctrl;

component tx is

  port (

		 buss: in std_logic_vector(7 downto 0);
		 adr: in std_logic_vector(4 downto 0); 
		 wr, rd, clk, rstn : in std_logic;
		 TxD: out std_logic;
);

end component tx;
 
begin

 i_ctrl: ctrl

    port map  (
      key => key,
		  clk => clk,
		  rstn => rstn,
      data => buss,
		  LED => LED,
      baudsel => baudsel,
		  parity => parity,
      adr => adr, 
		  wr => wrd,
      rd => rd,
      LED => LED                  
);

  i_tx: tx

    port map (
      data => buss,
      adr => adr,
		  wr => wr,
		  rd => rd,
	    clk => clk,
	    rstn => rstn,
		  TxD => TxD
);
 end architecture top-level; 
