library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- use IEEE.STD_LOGIC_ARITH.ALL;
-- use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UART_TRANSMITTER is
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
end UART_TRANSMITTER;

architecture Behavioral of UART_TRANSMITTER is


--CONSTANT DECLERATIONS
constant C_BIT_TIMER_LIMIT 	        : integer := CLOCK_FREQ/BAUD_RATE;
constant C_STOP_BIT_TIMER_LIMIT 	: integer := (CLOCK_FREQ/BAUD_RATE)*STOP_BIT;


--SIGNAL DECLERATIONS
type states is (TX_IDLE_STATE, TX_START_STATE, TX_DATA_TRANSFER_STATE, TX_STOP_STATE);
signal state : states := TX_IDLE_STATE;

signal BIT_TIMER : integer range 0 to C_STOP_BIT_TIMER_LIMIT := 0;
signal BIT_COUNTER	: integer range 0 to 7 := 0;
signal DATA_SHIFTER_REGISTER	: std_logic_vector (7 downto 0) := (others => '0');


begin

P_MAIN : process (CLK) begin
if (rising_edge(CLK)) then

	case state is
	
		when TX_IDLE_STATE =>
		
					TX_OUTPUT				<= '1';
					TX_READY				<= '0';
					BIT_COUNTER				<= 0;
			
			if (TX_START_IN = '1') then
			
					state					<= TX_START_STATE;
					TX_OUTPUT				<= '0';
					DATA_SHIFTER_REGISTER	<= TX_DATA_IN;
			end if;
		
		when TX_START_STATE =>
		

			if (BIT_TIMER = C_BIT_TIMER_LIMIT-1) then
			
					state								<= TX_DATA_TRANSFER_STATE;
					TX_OUTPUT							<= DATA_SHIFTER_REGISTER(0);
					DATA_SHIFTER_REGISTER(7)			<= DATA_SHIFTER_REGISTER(0);
					DATA_SHIFTER_REGISTER(6 downto 0)	<= DATA_SHIFTER_REGISTER(7 downto 1);
					BIT_TIMER							<= 0;
						
			else
					BIT_TIMER							<= BIT_TIMER + 1;
			end if;
			
		when TX_DATA_TRANSFER_STATE =>
		
		
			if (BIT_COUNTER = 7) then
			
						if (BIT_TIMER = C_BIT_TIMER_LIMIT-1) then

							BIT_COUNTER				<= 0;
							state					<= TX_STOP_STATE;
							TX_OUTPUT				<= '1';
							BIT_TIMER				<= 0;
							
						else
							BIT_TIMER				<= BIT_TIMER + 1;					
						end if;		
						
			else
			
						if (BIT_TIMER = C_BIT_TIMER_LIMIT-1) then

							DATA_SHIFTER_REGISTER(7)			<= DATA_SHIFTER_REGISTER(0);
							DATA_SHIFTER_REGISTER(6 downto 0)	<= DATA_SHIFTER_REGISTER(7 downto 1);					
							TX_OUTPUT							<= DATA_SHIFTER_REGISTER(0);
							BIT_COUNTER							<= BIT_COUNTER + 1;
							BIT_TIMER							<= 0;
							
						else
							BIT_TIMER				<= BIT_TIMER + 1;					
						end if;
				
			end if;
		
		when TX_STOP_STATE =>
		
			if (BIT_TIMER = C_STOP_BIT_TIMER_LIMIT-1) then
			
				state				<= TX_IDLE_STATE;
				TX_READY			<= '1';
				BIT_TIMER			<= 0;
				
			else
				BIT_TIMER			<= BIT_TIMER + 1;				
			end if;		
	
	end case;

end if;
end process;


end Behavioral;