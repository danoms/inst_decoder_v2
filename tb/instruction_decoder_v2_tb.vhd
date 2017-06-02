library ieee, my_lib;
use   ieee.std_logic_1164.all,
      ieee.numeric_std.all,
      my_lib.types.all;

entity instruction_decoder_v2_tb is
   generic (
     MUX_COUNT : positive := 8;
     CLK_COUNT : positive := 8
   );
end entity;

architecture beh of instruction_decoder_v2_tb is
   component instruction_decoder_v2
   generic (
     MUX_COUNT : positive := 8;
     CLK_COUNT : positive := 8
   );
   port (
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
   type data_i_arr_t   is array(natural range <>) of HALF_WORD;
   constant data_arr : data_i_arr_t   := (   x"0512", x"0934", x"0D56",
                                             x"1256", x"1512", x"1934", x"1D56",
                                             x"2256", x"2512", x"2934", x"2D56",
                                             x"3456", x"4123", x"5654", x"6154", x"7125",
                                             x"B456", x"BA12", x"CD12", x"D123", x"E456",
                                             x"F145", x"F598", x"F945", x"FA49", x"FD12", x"FF15",
                                             x"910F", x"921F",
                                             x"8070", x"8048", x"8260", x"8218");

   type op_arr_t is array(natural range <>) of operation_type;
   constant op_arr : op_arr_t         := (  CPC, SBC, ADD,
                                          CPSE, CP, SUB, ADC,
                                          ANDD, EOR, ORR, MOV,
                                          CPI, SBCI, SUBI, ORI, ANDI,
                                          INN, OUTT, RJMP, RCALL, LDI,
                                          cond_branch, cond_branch, BLD, BST, SBRC, SBRS,
                                          POP, PUSH,
                                          LDDZ, LDDY, STDZ, STDY);

   signal data_i       : HALF_WORD                              := x"921F";
   signal Rd_addr_o    : unsigned(4 downto 0)                   := (others => '0');
   signal Rs_addr_o    : unsigned(4 downto 0)                   := (others => '0');
   signal addr_mode_o  : BYTE_U                                 := (others => '0');
   signal immed_o      : BYTE_U                                 := (others => '0');
   signal op_o         : operation_type                         := NOP;
   signal ctl_line_o   : std_logic_vector(MUX_COUNT-1 downto 0) := (others => '0');
   signal clk_gating_o : std_logic_vector(CLK_COUNT-1 downto 0) := (others => '0');
   signal pc_offset    : signed(11 downto 0)                    := (others => '0');
   signal io_addres_o  : unsigned(5 downto 0)                   := (others => '0');
   signal bit_o        : unsigned(2 downto 0)                   := (others => '0');
begin

data_in : process
begin
   loop_through_instructions :
      for i in data_arr'range loop
         data_i   <= data_arr(i);
         wait for 2 ns;
         assert op_o = op_arr(i) report "error in op" severity error;
         wait for 2 us;
      end loop;
      wait;
end process;

instruction_decoder_v2_i : instruction_decoder_v2
   generic map (
     MUX_COUNT => MUX_COUNT,
     CLK_COUNT => CLK_COUNT
   )
   port map (
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
