library ieee, my_lib;
use 	ieee.std_logic_1164.all,
		ieee.numeric_std.all,
		my_lib.types.all;

entity instruction_decoder_v2 is
	generic
	(
		MUX_COUNT	: positive := 8;
		CLK_COUNT	: positive := 8
	);
		port
		(
			data_i			: in HALF_WORD;	-- instruction to decode

			Rd_addr_o		: out unsigned(4 downto 0);	-- destinatio reg address in GPR
			Rs_addr_o		: out unsigned(4 downto 0);	-- source reg address in GPR
			addr_mode_o		: out BYTE_U;	-- I/O or data addressing
			immed_o			: out BYTE_U;	-- immediate value

			op_o				: out operation_type; -- controls ALU
			ctl_line_o		: out std_logic_vector(MUX_COUNT-1 downto 0);
			clk_gating_o	: out std_logic_vector(CLK_COUNT-1 downto 0);

			pc_offset 		: out signed(11 downto 0);
			io_addres_o 	: out unsigned(5 downto 0);
			bit_o 			: out unsigned(3 downto 0);
			
			we_gpr 			: out std_logic;
			we_sreg 			: out std_logic

		);
end entity;

architecture something of instruction_decoder_v2 is
	-- signal data_i : HALF_WORD := data_i_old;
   -- signal high_x   : unsigned(3 downto 0) := unsigned(data_i(15 downto 12));
   alias high_l_x : std_logic_vector(3 downto 0) is data_i(11 downto 8);
	alias high_x   : std_logic_vector(3 downto 0) is data_i(15 downto 12);

   alias low_h_x  : std_logic_vector(3 downto 0) is data_i(7 downto 4);
   alias low_x    : std_logic_vector(3 downto 0) is data_i(3 downto 0);

begin

   decode_input_data : process(all)
   begin
		-- default values/positions
		Rd_addr_o	<= unsigned(data_i(8 downto 4));
		Rs_addr_o 	<= unsigned(data_i(9) & data_i(3 downto 0));
--		addr_mode_o	<= 
		immed_o		<= unsigned(data_i(11 downto 8) & data_i(3 downto 0));
		
		op_o 			<= NOP;
		
		pc_offset	<= signed(data_i(11 downto 0));
		io_addres_o <= unsigned(data_i(10 downto 9) & data_i(3 downto 0));
		bit_o 		<= unsigned(data_i(9) & data_i(2 downto 0));
		
		we_gpr 		<= '0';
		we_sreg 		<= '0';

      case( high_x ) is

         when x"0" =>

			Rs_addr_o 	<= unsigned(data_i(9) & low_x);
			Rd_addr_o 	<= unsigned(data_i(8) & low_h_x);

            case( high_l_x ) is

            	when x"4" | x"5" | x"6" | x"7" =>
						op_o 			<= cpc;

					when x"8" | x"9" | x"A" | x"B" =>
						op_o 			<= sbc;

					when x"C" | x"D" | x"E" | x"F" =>
						op_o 			<= add;

            	when others =>

            end case;

			when x"1" =>
			Rs_addr_o 	<= unsigned(data_i(9) & low_x);
			Rd_addr_o 	<= unsigned(data_i(8) & low_h_x);

            case( high_l_x ) is

					when x"0" | x"1" | x"2" | x"3" =>
						op_o 			<= cpse;

            	when x"4" | x"5" | x"6" | x"7" =>
						op_o 			<= cp;

					when x"8" | x"9" | x"A" | x"B" =>
						op_o 			<= sub;

					when x"C" | x"D" | x"E" | x"F" =>
						op_o 			<= adc;

            	when others =>

            end case;

			when x"2" =>
			Rs_addr_o 	<= unsigned(data_i(9) & low_x);
			Rd_addr_o 	<= unsigned(data_i(8) & low_h_x);

            case( high_l_x ) is


            	when x"0" | x"1" | x"2" | x"3" =>
						op_o 			<= andd;

            	when x"4" | x"5" | x"6" | x"7" =>
						op_o 			<= eor;

					when x"8" | x"9" | x"A" | x"B" =>
						op_o 			<= orr;

					when x"C" | x"D" | x"E" | x"F" =>
						op_o 			<= mov;

					when others =>

				end case;

			when x"3" =>
				Rd_addr_o 	<= unsigned('0' & low_h_x);
				immed_o 		<= unsigned(high_l_x & low_x);
				op_o 			<= cpi;

			when x"4" =>
				Rd_addr_o 	<=unsigned('0' & low_h_x);
				immed_o 		<= unsigned(high_l_x & low_x);
				op_o 			<= sbci;

			when x"5" =>
				Rd_addr_o 	<= unsigned('0' & low_h_x);
				immed_o 		<= unsigned(high_l_x & low_x);
				op_o 			<= subi;

			when x"6" =>
				Rd_addr_o 	<=unsigned('0' & low_h_x);
				immed_o 		<= unsigned(high_l_x & low_x);
				op_o 			<= ori;

			when x"7" =>
				Rd_addr_o 	<= unsigned('0' & low_h_x);
				immed_o 		<= unsigned(high_l_x & low_x);
				op_o 			<= andi;

			when x"8" | x"A" =>
			Rd_addr_o 	<= unsigned(data_i(8 downto 4));
			immed_o		<= unsigned("00" & data_i(13) & data_i(11 downto 10) & data_i(2 downto 0));

				case?( high_l_x & low_x ) is

					when "--0-0---" =>
						op_o	<= lddz;

					when "--0-1---" =>
						op_o	<= lddy;

					when "--1-0---" =>
						op_o	<= stdz;

					when "--1-1---" =>
						op_o	<= stdy;

					when others =>

				end case?;

			when x"9" =>
			Rd_addr_o 	<= unsigned(data_i(8 downto 4));

				case( high_l_x ) is
					when x"0" | x"1" =>
						case( low_x ) is
							when x"0" =>
								op_o	<= lds;

							when x"1" =>
								op_o 	<= ldzp;

							when x"2" =>
								op_o 	<= ldzm;

							when x"4" =>
								op_o 	<= lpmz;

							when x"5" =>
								op_o 	<= lpmzp;

							when x"6" =>
								op_o 	<= elpmz;

							when x"7" =>
								op_o 	<= elpmzp;

							when x"9" =>
								op_o 	<= ldyp;

							when x"A" =>
								op_o 	<= ldym;

							when x"C" =>
								op_o 	<= ldx;

							when x"D" =>
								op_o 	<= ldxp;

							when x"E" =>
								op_o 	<= ldxm;

							when x"F" =>
								op_o 	<= pop;

							when others =>

						end case;

					when x"2" | x"3" =>
						case( low_x ) is
							when x"0" =>
								op_o	<= sts;

							when x"1" =>
								op_o 	<= stzp;

							when x"2" =>
								op_o 	<= stzm;

							when x"9" =>
								op_o 	<= styp;

							when x"A" =>
								op_o 	<= stym;

							when x"C" =>
								op_o 	<= stx;

							when x"D" =>
								op_o 	<= stxp;

							when x"E" =>
								op_o 	<= stxm;

							when x"F" =>
								op_o 	<= push;
							when others =>
						end case;

					when x"4" | x"5" =>
						case( low_x ) is
							when x"0" =>
								op_o	<= com;

							when x"1" =>
								op_o 	<= neg;

							when x"2" =>
								op_o 	<= swap;

							when x"3" =>
								op_o 	<= inc;

							when x"5" =>
								op_o 	<= asr;

							when x"6" =>
								op_o 	<= lsr;

							when x"7" =>
								op_o 	<= rorr;

							when x"8" =>
								op_o 	<= secc;

							when x"9" =>
								op_o 	<= inc;

							when x"A" =>
								op_o 	<= stym;

							when x"C" =>
								op_o 	<= stx;

							when x"D" =>
								op_o 	<= stxp;

							when x"E" =>
								op_o 	<= stxm;

							when x"F" =>
								op_o 	<= call;
							when others =>
						end case;

					when x"6" =>
						immed_o		<= unsigned("00" & data_i(7 downto 6) & low_x);
						Rd_addr_o	<= unsigned("11" & data_i(5 downto 4) & '0');
						op_o			<= adiw;

					when x"7" =>
						immed_o		<= unsigned("00" & data_i(7 downto 6) & low_x);
						Rd_addr_o	<= unsigned("11" & data_i(5 downto 4) & '0');
						op_o			<= sbiw;

					when x"8" =>
--						bit_o				<= unsigned(data_i(2 downto 0));
						io_addres_o 	<= unsigned('0' & data_i(7 downto 3));
						op_o				<= cbi;

					when x"9" =>
--						bit_o				<= unsigned(data_i(2 downto 0));
						io_addres_o 	<= unsigned('0' & data_i(7 downto 3));
						op_o				<= sbic;

					when x"A" =>
--						bit_o				<= unsigned(data_i(2 downto 0));
						io_addres_o 	<= unsigned('0' & data_i(7 downto 3));
						op_o				<= sbi;

					when x"B" =>
--						bit_o				<= unsigned(data_i(2 downto 0));
						io_addres_o 	<= unsigned('0' & data_i(7 downto 3));
						op_o				<= sbis;

					when x"C" | x"D" | x"E" | x"F" =>
						Rs_addr_o	<= unsigned(data_i(9) & data_i(3 downto 0));
						Rd_addr_o	<= unsigned(data_i(8 downto 4));
						op_o			<= mul;

					when others =>
				end case;

			when x"B" =>
			io_addres_o 	<= unsigned(data_i(10 downto 9) & low_x);
			Rd_addr_o 		<= unsigned(data_i(8) & low_h_x);

				case( high_l_x ) is

					when x"0" | x"1" | x"2" | x"3" | x"4" | x"5" | x"6" | x"7" =>
						op_o 			<= inn;

					when x"8" | x"9" | x"A" | x"B" | x"C" | x"D" | x"E" | x"F" =>
						op_o 			<= outt;

					when others =>
				end case;

			when x"C" =>
				pc_offset 	<= signed(data_i(11 downto 0));
				op_o 			<= rjmp;

			when x"D" =>
				pc_offset 	<= signed(data_i(11 downto 0));
				op_o 			<= rcall;

			when x"E" =>
				immed_o 		<= unsigned(data_i(11 downto 8) & data_i(3 downto 0));
				Rd_addr_o 	<= unsigned('1' & data_i(7 downto 4));
				op_o 			<= ldi;
				we_gpr		<= '1';

			when x"F" =>
			bit_o 		<= unsigned(data_i(3 downto 0));

				case( high_l_x ) is

					when x"0" | x"1" | x"2" | x"3" | x"4" | x"5" | x"6" | x"7" =>
						op_o 			<= cond_branch;
						pc_offset 	<= signed(data_i(11 downto 0));

					when x"8" | x"9" =>
						op_o 			<= bld;
						Rd_addr_o 	<= unsigned(data_i(8) & low_h_x);

					when x"A" | x"B" =>
						op_o 			<= bst;
						Rd_addr_o 	<= unsigned(data_i(8) & low_h_x);

					when x"C" | x"D" =>
						op_o 			<= sbrc;
						Rd_addr_o 	<= unsigned(data_i(8) & low_h_x);

					when x"E" | x"F" =>
						op_o 			<= sbrs;
						Rd_addr_o 	<= unsigned(data_i(8) & low_h_x);

					when others =>

				end case;

         when others =>

      end case;
   end process;
end architecture;
