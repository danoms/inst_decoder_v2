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
			clk 				: in std_logic;

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
			bit_o 			: out unsigned(2 downto 0)
		);
end entity;

architecture something of instruction_decoder_v2 is
	-- signal data_i : HALF_WORD := data_i_old;
   -- signal high_x   : unsigned(3 downto 0) := unsigned(data_i(15 downto 12));
   alias high_l_x : std_logic_vector(3 downto 0) is data_i(11 downto 8);
	alias high_x   : std_logic_vector(3 downto 0) is data_i(15 downto 12);

   alias low_h_x  : std_logic_vector(3 downto 0) is data_i(7 downto 4);
   alias low_x    : std_logic_vector(3 downto 0) is data_i(3 downto 0);

	signal counter : unsigned(7 downto 0)	:= (others => '0');


begin

-- data_update : process(all)
-- begin
-- 	if rising_edge(clk) then
-- 		data_i <= data_i_old;
-- 	else
-- 		data_i	<= data_i;
-- 	end if;
-- end process;

-- counter_works : process(all)
-- begin
-- 	if rising_edge(clk) then
-- 		counter 	<= counter + 1;
-- 	else
-- 		counter 	<= counter;
-- 	end if;
-- end process;

clk_gating_o 	<= std_logic_vector(counter);

   decode_input_data : process(all)
   begin

		op_o 			<= NOP;
		immed_o		<= (others => '0');
		Rs_addr_o 	<= (others => '0');
		Rd_addr_o	<= (others => '0');
		pc_offset	<= (others => '0');
		io_addres_o <= (others => '0');
		bit_o 		<= (others => '0');

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

			when x"9" =>
			Rd_addr_o 	<= unsigned(data_i(8) & low_h_x);

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

					when others =>

				end case;

			when x"B" =>
			io_addres_o 	<= unsigned(data_i(10 downto 9) & low_x);
			Rd_addr_o 		<= unsigned(data_i(8) & low_h_x);



			when x"C" =>
				pc_offset 	<= signed(data_i(11 downto 0));
				op_o 			<= rjmp;

			when x"D" =>
				pc_offset 	<= signed(data_i(11 downto 0));
				op_o 			<= rcall;

			when x"E" =>
				immed_o 		<= unsigned(high_l_x & low_x);
				Rd_addr_o 	<= unsigned('0' & low_h_x);
				op_o 			<= ldi;

			when x"F" =>
			bit_o 		<= unsigned(data_i(2 downto 0));

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
