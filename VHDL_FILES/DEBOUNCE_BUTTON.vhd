library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DEBOUNCE_BUTTON is
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
end DEBOUNCE_BUTTON;

architecture Behavioral of DEBOUNCE_BUTTON is

constant BIT_TIMER_LIMIT	: integer := CLOCK_FREQ/DEBOUNCE_TIME;

signal TIMER		: integer range 0 to BIT_TIMER_LIMIT := 0;
signal TIMER_ENABLE		: std_logic := '0';
signal TIMER_READY	: std_logic := '0';

type STATES is (INITIALIZATION_STATE, ZERO_STATE, ZERO_TO_ONE_STATE, ONE_STATE, ONE_TO_ZERO_STATE);
signal state : STATES := INITIALIZATION_STATE;

begin

process (CLK) begin
if (rising_edge(CLK)) then

	case state is
	
		when INITIALIZATION_STATE =>
		
			if (INIT_VALUE = '0') then
				state	<= ZERO_STATE;
			else
				state	<= ONE_STATE;
			end if;
		
		when ZERO_STATE =>
		
			SIGNAL_OUT	<= '0';
		
			if (SIGNAL_IN = '1') then
				state	<= ZERO_TO_ONE_STATE;
			end if;
		
		when ZERO_TO_ONE_STATE =>
		
			SIGNAL_OUT	<= '0';
			TIMER_ENABLE	<= '1';
			
			if (TIMER_READY = '1') then
				state		<= ONE_STATE;
				TIMER_ENABLE	<= '0';
			end if;
			
			if (SIGNAL_IN = '0') then
				state		<= ZERO_STATE;
				TIMER_ENABLE	<= '0';
			end if;
		
		when ONE_STATE =>
		
			SIGNAL_OUT	<= '1';
		
			if (SIGNAL_IN = '0') then
				state	<= ONE_TO_ZERO_STATE;
			end if;		
		
		when ONE_TO_ZERO_STATE =>
		
			SIGNAL_OUT	<= '1';
			TIMER_ENABLE	<= '1';
			
			if (TIMER_READY = '1') then
				state		<= ZERO_STATE;
				TIMER_ENABLE	<= '0';
			end if;
			
			if (SIGNAL_IN = '1') then
				state		<= ONE_STATE;
				TIMER_ENABLE	<= '0';
			end if;		
	
	end case;

end if;
end process;

P_TIMER : process (CLK) begin
if (rising_edge(CLK)) then

	if (TIMER_ENABLE = '1') then
		if (TIMER = BIT_TIMER_LIMIT-1) then
			TIMER_READY	<= '1';
			TIMER		<= 0;
		else
			TIMER_READY 	<= '0';
			TIMER 		<= TIMER + 1;
		end if;
	else
		TIMER		<= 0;
		TIMER_READY	<= '0';
	end if;

end if;
end process;

end Behavioral;