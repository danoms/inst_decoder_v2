library ieee, my_lib;
use   ieee.std_logic_1164.all,
      ieee.numeric_std.all,
      my_lib.types.all;

entity instruction_decoder_v2_tb is
   generic (
     MUX_COUNT : positive := 8;
     CLK_COUNT : positive := 8;
     MAIN_CLK_PERIOD : time := 10 ns
   );
end entity;

architecture beh of instruction_decoder_v2_tb is
   component instruction_decoder_v2
   generic (
     MUX_COUNT : positive := 8;
     CLK_COUNT : positive := 8
   );
   port (
      clk 				    : in std_logic;

      data_i   			 : in HALF_WORD;	-- instruction to decode
      Rd_addr_o          : out unsigned(4 downto 0);
      Rs_addr_o          : out unsigned(4 downto 0);
      addr_mode_o        : out BYTE_U;
      immed_o            : out BYTE_U;
      op_o               : out operation_type;
      ctl_line_o         : out std_logic_vector(MUX_COUNT-1 downto 0);
      clk_gating_o       : out std_logic_vector(CLK_COUNT-1 downto 0);
      pc_offset          : out signed(11 downto 0);
      io_addres_o        : out unsigned(5 downto 0);
      bit_o              : out unsigned(2 downto 0)
   );
   end component instruction_decoder_v2;

   signal data_i       : HALF_WORD  := x"921F";
   signal Rd_addr_o    : unsigned(4 downto 0)   := (others => '0');
   signal Rs_addr_o    : unsigned(4 downto 0)   := (others => '0');
   signal addr_mode_o  : BYTE_U    := (others => '0');
   signal immed_o      : BYTE_U   := (others => '0');
   signal op_o         : operation_type := NOP;
   signal ctl_line_o   : std_logic_vector(MUX_COUNT-1 downto 0)   := (others => '0');
   signal clk_gating_o : std_logic_vector(CLK_COUNT-1 downto 0)   := (others => '0');
   signal pc_offset    : signed(11 downto 0)   := (others => '0');
   signal io_addres_o  : unsigned(5 downto 0)   := (others => '0');
   signal bit_o        : unsigned(2 downto 0)   := (others => '0');
   signal clk           : std_logic   := '0';
begin
-- clk <= not clk after MAIN_CLK_PERIOD / 2;

data_in : process
begin
   data_i   <= x"921F";
   wait for 2 us;
   data_i   <= x"927F";
   wait for 2 us;
   data_i   <= x"1120";
   wait for 2 us;
   data_i   <= x"1475";
   wait for 2 us;
   data_i   <= x"4444";
   wait for 2 us;
end process;

instruction_decoder_v2_i : instruction_decoder_v2
   generic map (
     MUX_COUNT => MUX_COUNT,
     CLK_COUNT => CLK_COUNT
   )
   port map (
      clk   => clk,

     data_i       => data_i,
     Rd_addr_o    => Rd_addr_o,
     Rs_addr_o    => Rs_addr_o,
     addr_mode_o  => addr_mode_o,
     immed_o      => immed_o,
     op_o         => op_o,
     ctl_line_o   => ctl_line_o,
     clk_gating_o => clk_gating_o,
     pc_offset    => pc_offset,
     io_addres_o  => io_addres_o,
     bit_o        => bit_o
   );


end architecture;
