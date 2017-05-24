-- synthesis library my_lib
library ieee;
use ieee.std_logic_1164.all,
		ieee.numeric_std.all;

package types is

	-- std_logic_vector
	subtype WORD is std_logic_vector(31 downto 0);
	subtype HALF_WORD is std_logic_vector(15 downto 0);
	subtype BYTE is std_logic_vector(7 downto 0);

	-- unsigned
	subtype WORD_U is unsigned(31 downto 0);
	subtype HALF_WORD_U is unsigned(15 downto 0);
	subtype BYTE_U is unsigned(7 downto 0);

	-- signed
	subtype WORD_S is unsigned(31 downto 0);
	subtype HALF_WORD_S is signed(15 downto 0);
	subtype BYTE_S is unsigned(7 downto 0);
	--Memory type
	type GPR_type is array(0 to 31) of BYTE_U;

	-- flags for status register
	constant C			: integer := 0; 	-- carry
	constant Z 			: integer := 1; 	-- zero
	constant N			: integer := 2;	-- negative
	constant V			: integer := 3;	-- overflow
	constant S			: integer := 4;	-- sign
	constant H			: integer := 5;	-- half carry
	constant T 			: integer := 6;	-- bit copy
	constant I 			: integer := 7;	-- interrupt enable

	-- types
--	type operation_type is (ldi, movw, sub, sbc, cpi, cpc, adiw, rjmp, sbiw, eor, rcall);
	attribute enum_encoding : string;
	type operation_type is (ADD, ADC, ADIW, SUB, SUBI, SBC, SBCI, SBIW,
									ANDD, ANDI, ORR, ORI, EOR, COM, NEG, SBR, CBR,
									INC, DEC, TST, CLR, SER, MUL, MULS, MULSU,
									MOV, MOVW, LDI,
									FMUL, FMULS, FMULU, CPC, CP, ROLL, LSL, CPSE,
									CPI, LDYP, LDYM, LDZP, LDZM, LDS, STS,
									LDDY, LDDZ, LPMZ, ELPMZ, LPMZP, ELPMZP,
									XCH, LAS, LAC, LAT, LDX, LDXP, LDXM, POP, PUSH,
									SWAP, ASR, LSR, RORR,
									SLEEP, BREAK, WDR, LPM, ELPM, SPM, SPMZP,
									JMP, CALL,
									CBI, SBI, SBIC, SBIS,
									INN, OUTT,
									ICALL, RCALL, RET, RETI,
									NOP, STZP, STYP, STZM, STYM, STDY, STDZ, SPMZ,
									RJMP, cond_branch, BLD, BST, SBRC, SBRS, stx, stxp, stxm,
									secc);
	attribute enum_encoding of operation_type : type is "gray";
end package;
