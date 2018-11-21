library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
 
entity uart is

port     (clock_in : in std_logic;
r_CLOCK_i : out std_logic;
tx_dv_i: in  std_logic;
rx_dr_i: out  std_logic;
r_TX_BYTE_i   : in std_logic_vector(7 downto 0);
w_TX_SERIAL_i: out std_logic;
r_RX_SERIAL_i: in std_logic;
w_RX_BYTE_i: out std_logic_vector(7 downto 0));

end entity;
 
architecture behave of uart is
 
  component uart_tx is
    generic (
      g_CLKS_PER_BIT : integer := 115   -- Needs to be set correctly
      );
    port (
      i_clk       : in  std_logic;
      i_tx_dv     : in  std_logic;
      i_tx_byte   : in  std_logic_vector(7 downto 0);
      o_tx_active : out std_logic;
      o_tx_serial : out std_logic;
      o_tx_done   : out std_logic
      );
  end component uart_tx;
 
  component uart_rx is
    generic (
      g_CLKS_PER_BIT : integer := 115   -- Needs to be set correctly
      );
    port (
      i_clk       : in  std_logic;
      i_rx_serial : in  std_logic;
      o_rx_dv     : out std_logic;
      o_rx_byte   : out std_logic_vector(7 downto 0)
      );
  end component uart_rx;
 
   
  -- Test Bench uses a 10 MHz Clock
  -- Want to interface to 115200 baud UART
  -- 10000000 / 115200 = 87 Clocks Per Bit.
  -- constant c_CLKS_PER_BIT : integer := 87;
 
 --  constant c_BIT_PERIOD : time := 8680 ns;
   
  signal r_CLOCK     : std_logic                    := '0';
  signal r_TX_DV     : std_logic                    := '0';
  signal r_TX_BYTE   : std_logic_vector(7 downto 0) := (others => '0');
  signal w_TX_SERIAL : std_logic;
  signal w_TX_DONE   : std_logic;
  signal w_RX_DV     : std_logic;
  signal w_RX_BYTE   : std_logic_vector(7 downto 0);
  signal r_RX_SERIAL : std_logic := '1';
  signal r_clock1: std_logic :='0';
  signal count: integer range 0 to 1023;
   
begin
-- fabricate r_clock form clock_in...

  -- Test Bench uses a 10 MHz Clock
  -- Want to interface to 115200 baud UART
  -- 50000000 / 115200 = 435 Clocks Per Bit.
  -- constant c_CLKS_PER_BIT : integer := 1b3; == numb


-- ................
r_tx_dv <= tx_dv_i;
rx_dr_i<= w_rx_dv ;


r_TX_BYTE <= r_TX_BYTE_i;

w_rx_byte_i <= w_rx_byte;
w_tx_serial_i <= w_tx_serial;
r_rx_serial <= r_rx_serial_i;

r_clock_i <= r_clock;

 process (clock_in)
begin
   if rising_edge (clock_in) then
	if count = 435 then
		count <= 0;
		r_clock1 <= not (r_clock1);
    	else 
		count <= count +1;
	end if;
   end if;
 end process;

r_clock <= r_clock1;

--.........

  -- Instantiate UART transmitter
  UART_TX_INST : uart_tx
    generic map (
      g_CLKS_PER_BIT => 435
      )
    port map (
      i_clk       => r_CLOCK,
      i_tx_dv     => r_TX_DV,
      i_tx_byte   => r_TX_BYTE,
      o_tx_active => open,
      o_tx_serial => w_TX_SERIAL,
      o_tx_done   => w_TX_DONE
      );
 
  -- Instantiate UART Receiver
  UART_RX_INST : uart_rx
    generic map (
      g_CLKS_PER_BIT => 435
      )
    port map (
      i_clk       => r_CLOCK,
      i_rx_serial => r_RX_SERIAL,
      o_rx_dv     => w_RX_DV,
      o_rx_byte   => w_RX_BYTE
      );
 

   
--   process is
--  begin
 
    -- Tell the UART to send a command.
--    wait until rising_edge(r_CLOCK);
 --  wait until rising_edge(r_CLOCK);
 --   r_TX_DV   <= '1';
  --  r_TX_BYTE <= X"AB";
   -- wait until rising_edge(r_CLOCK);
   --  r_TX_DV   <= '0';
 --   wait until w_TX_DONE = '1';
 
     
    -- Send a command to the UART
 --   wait until rising_edge(r_CLOCK);
 --   UART_WRITE_BYTE(X"3F", r_RX_SERIAL);
 --   wait until rising_edge(r_CLOCK);
 
    -- Check that the correct command was received
 --   if w_RX_BYTE = X"3F" then
 --     report "Test Passed - Correct Byte Received" severity note;
 --   else
 --     report "Test Failed - Incorrect Byte Received" severity note;
 --   end if;
 
--    assert false report "Tests Complete" severity failure;
     
--  end process;
   
end behave;

-- UCF
--clock_in      => 50 Mhz;
--
--R_clock, out_clock - fabricate by div from 50 Mhz - IN CODE ! : TBD !
--
--R_Data, T_data  - Leds, from Kb...
--r__serian, W_serial - BLE interface...