----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Kurt Snieckus
-- 
-- Create Date:    05:21:13 08/05/2012 
-- Design Name: 
-- Module Name:    Polyphony Controller - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--					Recieves parameter bus note on and note off messages, 
--					and controls the proper signals to enable each synthesis chain.
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity polyphony_cntrl is
	generic ( 
		voices : integer := 2;
	)    
	Port (
		-- clk
		clk	: in std_logic;
		reset : in std_logic;
		
		-- Parameter bus inputs
		param_addr : in  STD_LOGIC_VECTOR (7 downto 0);
		param_val : in  STD_LOGIC_VECTOR (14 downto 0));
		
		-- common parameter outputs to oscillators
		pitch : out STD_LOGIC_VECTOR (6 downto 0);
		vel : out STD_LOGIC_VECTOR (6 downto 0);
		
		-- latch parameter to particular voice
		wr_voice : out STD_LOGIC_VECTOR ((voices-1) downto 0);
		
		-- Enable voice (seperate from wr_voice so that the arppegiator can work better (i think))
		en_voice : out STD_LOGIC_VECTOR ((voices-1) downto 0);	
	);

end polyphony_cntrl;

architecture RTL of polyphony_cntrl is

	type voice_state_type is array(0 to (voices-1)) of std_logic_vector(6 downto 0);
	signal voice_state : voice_state_type;
	
	signal 

begin

	-- Midi byte collection process
	process(clk)
	begin
		if rising_edge(clk) then
			if (reset = '1') then	-- Reset all signals
				pitch <= (others => '0');
				vel <= (others => '0');
				
				wr_voice <= (others => '0');
				en_voice <= (others => '0');
			
			elsif param_addr /= (others => '1') then -- there's something on the param bus
				if param_addr = "00000000" then -- Note off
					-- Search for a voice that has this note on and turn it off
					for I in 0 to (voices-1) loop
						if voice_state(I) = param_data(6 downto 0) then
							en_voice(I) <= '0';
						end if;
					end loop;
				elsif param_addr = "00000001" then -- Note on
					for I in 0 to (voices-1) loop
					
					
					
					
					
					
					
					
					
				-- Latch _d's to outputs so that the connected devices respond to midi message
				param_addr <= param_addr_d;
				param_val <= param_val_d;
				recv_state <= reset; -- Reset on next clock
						
			elsif nrdy = '0' then	-- If the UART rx buffer is not empty
				wr <= '1';				-- Reading this byte out of the fifo
				case recv_state is
					when idle =>		-- Read incomming byte, and determine if it's a status byte
						if (din(7) = '1') and (chan = din(3 downto 0)) then 
							-- It is indeed a status byte and it's on our channel
							param_addr_d <= din(6:4);
							recv_state <= data;
							case din(6:4) is -- figure out what to do with this
								when '8' => -- Note off
									byte_cnt <= 2; -- 2 Bytes for a note off
								when '9' => -- Note on
									byte_cnt <= 2; -- 2 bytes for a note on
								when others => -- Midi message we are not dealing with
									recv_state <= reset; -- Reset midi controller and wait for the next status byte
							end case;
						else
							recv_state <= reset;
						end if;
					when data =>
						case param_addr_d is
							when '0' => -- Note off or on
								if byte_cnt = 2 then -- first byte is note number
									param_data_d(6:0) <= din(6:0);
									byte_cnt <= 1;
								elsif byte_cnt = 1 then -- second byte is velocity
									param_data_d(13:7) <= din(6:0);
									byte_cnt <= 0;
									recv_state <= done; -- Last byte, latch data and look for next status byte
								end if;
							when others => -- catch things that we havn't written yet
								recv_state <= reset;
						end case;
				end case;
			end if;
		end if;
	end process;
end RTL;

