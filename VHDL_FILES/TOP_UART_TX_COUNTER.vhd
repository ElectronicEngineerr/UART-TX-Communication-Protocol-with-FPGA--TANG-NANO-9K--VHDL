library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TOP_UART_TX_COUNTER is

generic (
			CLOCK_FREQ		: integer := 27_000_000;
			BAUD_RATE		: integer := 115_200;
			STOP_BIT		: integer := 2;
			DEBOUNCE_TIME	: integer := 1000;
			INIT_VALUE		: std_logic	:= '0'
);

port (
			CLK 			: in  std_logic;
			BUTTON_IN 		: in  std_logic;
			RESET			: in  std_logic;
			TX_O			: out std_logic
);

end TOP_UART_TX_COUNTER;

architecture Behavioral of TOP_UART_TX_COUNTER is


COMPONENT UART_TRANSMITTER is
		generic (
		CLOCK_FREQ		: integer := 27_000_000;
		BAUD_RATE		: integer := 115_200;
		STOP_BIT		: integer := 2
		);
		port (
		CLK				: in std_logic;
		TX_DATA_IN		: in std_logic_vector (7 downto 0);
		TX_START_IN		: in std_logic;
		TX_OUTPUT		: out std_logic;
		TX_READY		: out std_logic
		);
end COMPONENT;


COMPONENT DEBOUNCE_BUTTON is
		generic (
		CLOCK_FREQ		: integer := 27_000_000;
		DEBOUNCE_TIME	: integer := 1000;
		INIT_VALUE		: std_logic	:= '0'
		);
		port (
		CLK				: in std_logic;
		SIGNAL_IN		: in std_logic;
		SIGNAL_OUT		: out std_logic
		);
end COMPONENT;

signal COUNTER_DATA			: std_logic_vector(7 downto 0) := (others => '0');
signal TX_START_IN	    	: std_logic := '0';
signal TX_READY				: std_logic := '0';
signal BUTTON_DEBOUNCE		: std_logic := '0';
signal BUTTON_DEBOUNCE_NEXT	: std_logic := '0';



begin

UART_TX_I : UART_TRANSMITTER
		generic map(
		CLOCK_FREQ		=> CLOCK_FREQ,
		BAUD_RATE		=> BAUD_RATE,
		STOP_BIT		=> STOP_BIT
		)
		port 	map(
		CLK				=> CLK,
		TX_DATA_IN		=> COUNTER_DATA,
		TX_START_IN		=> TX_START_IN,
		TX_OUTPUT		=> TX_O,
		TX_READY		=> TX_READY
		);


BUTTON_I : DEBOUNCE_BUTTON 
		generic map(
		CLOCK_FREQ		=> CLOCK_FREQ,
		DEBOUNCE_TIME	=> DEBOUNCE_TIME,
		INIT_VALUE		=> INIT_VALUE
		)
		port 	map(
		CLK				=> CLK,
		SIGNAL_IN		=> BUTTON_IN,
		SIGNAL_OUT		=> BUTTON_DEBOUNCE
		);
		
		
	PROCESS (CLK, RESET)
		begin
			if(rising_edge(CLK)) then
			
			
				BUTTON_DEBOUNCE_NEXT <= BUTTON_DEBOUNCE;
				TX_START_IN <= '0';
				if(RESET = '0') then
				
					COUNTER_DATA <= (OTHERS => '0');
					
				elsif (BUTTON_DEBOUNCE = '0' and BUTTON_DEBOUNCE_NEXT = '1') then	
				
					BUTTON_DEBOUNCE_NEXT <= BUTTON_DEBOUNCE;
					TX_START_IN <= '1';
					COUNTER_DATA <= STD_LOGIC_VECTOR(UNSIGNED(COUNTER_DATA) + 1);
				end if;				
				
			end if;
	END PROCESS;
		
end Behavioral;
