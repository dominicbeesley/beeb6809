;			;  Meaning of ZP_FP_WA_B and ZP_FP_WA_B + 1 in tokenizer loop
			;  ZP_FP_WA_B	+0	+1	State is
			;		FF	0	Middle of statement mode
			;		0	0	Start of statement mode
			;		-	FF	Expect line number next

;			;  TOKEN TABLE
;			;  ===========
;			;  string, token (b7=1), flag
;			;
;			;  Token flag
;			;  Bit 0 - Conditional tokenisation (don't tokenise if followed by an alphabetic character).
;			;  Bit 1 - Go into "Middle of Statement" mode.
;			;  Bit 2 - Go into "Start of Statement" mode.
;			;  Bit 3 - FN/PROC keyword - don't tokenise the name of the subroutine.
;			;  Bit 4 - Start tokenising a line number now (after a GOTO, etc...).
;			;  Bit 5 - Don't tokenise rest of line (REM , DATA, etc...) ; DB: JGH had this as bit 6
;			;  Bit 6 - Pseudo variable flag - add $40 to token if at the start of a 
			;	   statement/hex number i.e. PAGE
;			;  Bit 7 - Unused - externally used for quote toggle.

TOK_FLAG_CONDITIONAL	EQU	$01
BIT_FLAG_CONDITIONAL	EQU	0

TOK_FLAG_NEXT_MID	EQU	$02
BIT_FLAG_NEXT_MOD	EQU	1

TOK_FLAG_NEXT_START	EQU	$04
BIT_FLAG_NEXT_START	EQU	2

TOK_FLAG_FNPROC		EQU	$08
BIT_FLAG_FNPROC		EQU	3

TOK_FLAG_NEXTLINENO	EQU	$10
BIT_FLAG_NEXTLINENO	EQU	4


TOK_FLAG_SKIP_EOL	EQU	$20
BIT_FLAG_SKIP_EOL	EQU	5

TOK_FLAG_PSEUDO_VAR	EQU	$40
BIT_FLAG_PSEUDO_VAR	EQU	6

tblTOKENS
		 FCB	  "AND",	$80,	$00		;  00000000
		 FCB	  "ABS",	$94,	$00		;  00000000
		 FCB	  "ACS",	$95,	$00		;  00000000
		 FCB	  "ADVAL",	$96,	$00		;  00000000
		 FCB	  "ASC",	$97,	$00		;  00000000
		 FCB	  "ASN",	$98,	$00		;  00000000
		 FCB	  "ATN",	$99,	$00		;  00000000
		 FCB	  "AUTO",	$C6,	$10		;  00010000
		 FCB	  "BGET",	$9A,	$01		;  00000001
		 FCB	  "BPUT",	$D5,	$03		;  00000011
		 FCB	  "COLOUR",	$FB,	$02		;  00000010
		 FCB	  "CALL",	$D6,	$02		;  00000010
		 FCB	  "CHAIN",	$D7,	$02		;  00000010
		 FCB	  "CHR$",	$BD,	$00		;  00000000
		 FCB	  "CLEAR",	$D8,	$01		;  00000001
		 FCB	  "CLOSE",	$D9,	$03		;  00000011
		 FCB	  "CLG",	$DA,	$01		;  00000001
		 FCB	  "CLS",	$DB,	$01		;  00000001
		 FCB	  "COS",	$9B,	$00		;  00000000
		 FCB	  "COUNT",	$9C,	$01		;  00000001
		 FCB	  "COLOR",	$FB,	$02		;  00000010
		 FCB	  "DATA",	$DC,	$20		;  00100000
		 FCB	  "DEG",	$9D,	$00		;  00000000
		 FCB	  "DEF",	$DD,	$00		;  00000000
		 FCB	  "DELETE",	$C7,	$10		;  00010000
		 FCB	  "DIV",	$81,	$00		;  00000000
		 FCB	  "DIM",	$DE,	$02		;  00000010
		 FCB	  "DRAW",	$DF,	$02		;  00000010
		 FCB	  "ENDPROC",	$E1,	$01		;  00000001
		 FCB	  "END",	$E0,	$01		;  00000001
		 FCB	  "ENVELOPE",	$E2,	$02		;  00000010
		 FCB	  "ELSE",	$8B,	$14		;  00010100
		 FCB	  "EVAL",	$A0,	$00		;  00000000
		 FCB	  "ERL",	$9E,	$01		;  00000001
		 FCB	  "ERROR",	$85,	$04		;  00000100
		 FCB	  "EOF",	$C5,	$01		;  00000001
		 FCB	  "EOR",	$82,	$00		;  00000000
		 FCB	  "ERR",	$9F,	$01		;  00000001
		 FCB	  "EXP",	$A1,	$00		;  00000000
		 FCB	  "EXT",	$A2,	$01		;  00000001
		 FCB	  "EDIT",	$CE,	$10		;  00010000
		 FCB	  "FOR",	$E3,	$02		;  00000010
		 FCB	  "FALSE",	$A3,	$01		;  00000001
		 FCB	  "FN",		$A4,	$08		;  00001000
		 FCB	  "GOTO",	$E5,	$12		;  00010010
		 FCB	  "GET$",	$BE,	$00		;  00000000
		 FCB	  "GET",	$A5,	$00		;  00000000
		 FCB	  "GOSUB",	$E4,	$12		;  00010010
		 FCB	  "GCOL",	$E6,	$02		;  00000010
		 FCB	  "HIMEM",	$93,	$43		;  00100011
		 FCB	  "INPUT",	$E8,	$02		;  00000010
		 FCB	  "IF",		$E7,	$02		;  00000010
		 FCB	  "INKEY$",	$BF,	$00		;  00000000
		 FCB	  "INKEY",	$A6,	$00		;  00000000
		 FCB	  "INT",	$A8,	$00		;  00000000
		 FCB	  "INSTR(",	$A7,	$00		;  00000000
		 FCB	  "LIST",	$C9,	$10		;  00010000
		 FCB	  "LINE",	$86,	$00		;  00000000
		 FCB	  "LOAD",	$C8,	$02		;  00000010
		 FCB	  "LOMEM",	$92,	$43		;  00100011
		 FCB	  "LOCAL",	$EA,	$02		;  00000010
		 FCB	  "LEFT$(",	$C0,	$00		;  00000000
		 FCB	  "LEN",	$A9,	$00		;  00000000
		 FCB	  "LET",	$E9,	$04		;  00000100
		 FCB	  "LOG",	$AB,	$00		;  00000000
		 FCB	  "LN",		$AA,	$00		;  00000000
		 FCB	  "MID$(",	$C1,	$00		;  00000000
		 FCB	  "MODE",	$EB,	$02		;  00000010
		 FCB	  "MOD",	$83,	$00		;  00000000
		 FCB	  "MOVE",	$EC,	$02		;  00000010
		 FCB	  "NEXT",	$ED,	$02		;  00000010
		 FCB	  "NEW",	$CA,	$01		;  00000001
		 FCB	  "NOT",	$AC,	$00		;  00000000
		 FCB	  "OLD",	$CB,	$01		;  00000001
		 FCB	  "ON",		$EE,	$02		;  00000010
		 FCB	  "OFF",	$87,	$00		;  00000000
		 FCB	  "OR",		$84,	$00		;  00000000
		 FCB	  "OPENIN",	$8E,	$00		;  00000000
		 FCB	  "OPENOUT",	$AE,	$00		;  00000000
		 FCB	  "OPENUP",	$AD,	$00		;  00000000
		 FCB	  "OSCLI",	$FF,	$02		;  00000010
		 FCB	  "PRINT",	$F1,	$02		;  00000010
		 FCB	  "PAGE",	$90,	$43		;  01000011
		 FCB	  "PTR",	$8F,	$43		;  01000011
		 FCB	  "PI",		$AF,	$01		;  00000001
		 FCB	  "PLOT",	$F0,	$02		;  00000010
		 FCB	  "POINT(",	$B0,	$00		;  00000000
		 FCB	  "PROC",	$F2,	$0A		;  00001010
		 FCB	  "POS",	$B1,	$01		;  00000001
		 FCB	  "RETURN",	$F8,	$01		;  00000001
		 FCB	  "REPEAT",	$F5,	$00		;  00000000
		 FCB	  "REPORT",	$F6,	$01		;  00000001
		 FCB	  "READ",	$F3,	$02		;  00000010
		 FCB	  "REM",	$F4,	$20		;  00100000
		 FCB	  "RUN",	$F9,	$01		;  00000001
		 FCB	  "RAD",	$B2,	$00		;  00000000
		 FCB	  "RESTORE",	$F7,	$12		;  00010010
		 FCB	  "RIGHT$(",	$C2,	$00		;  00000000
		 FCB	  "RND",	$B3,	$01		;  00000001
		 FCB	  "RENUMBER",	$CC,	$10		;  00010000
		 FCB	  "STEP",	$88,	$00		;  00000000
		 FCB	  "SAVE",	$CD,	$02		;  00000010
		 FCB	  "SGN",	$B4,	$00		;  00000000
		 FCB	  "SIN",	$B5,	$00		;  00000000
		 FCB	  "SQR",	$B6,	$00		;  00000000
		 FCB	  "SPC",	$89,	$00		;  00000000
		 FCB	  "STR$",	$C3,	$00		;  00000000
		 FCB	  "STRING$(",	$C4,	$00		;  00000000
		 FCB	  "SOUND",	$D4,	$02		;  00000010
		 FCB	  "STOP",	$FA,	$01		;  00000001
		 FCB	  "TAN",	$B7,	$00		;  00000000
		 FCB	  "THEN",	$8C,	$14		;  00010100
		 FCB	  "TO",		$B8,	$00		;  00000000
		 FCB	  "TAB(",	$8A,	$00		;  00000000
		 FCB	  "TRACE",	$FC,	$12		;  00010010
		 FCB	  "TIME",	$91,	$43		;  01000011
		 FCB	  "TRUE",	$B9,	$01		;  00000001
		 FCB	  "UNTIL",	$FD,	$02		;  00000010
		 FCB	  "USR",	$BA,	$00		;  00000000
		 FCB	  "VDU",	$EF,	$02		;  00000010
		 FCB	  "VAL",	$BB,	$00		;  00000000
		 FCB	  "VPOS",	$BC,	$01		;  00000001
		 FCB	  "WIDTH",	$FE,	$02		;  00000010
		 FCB	  "PAGE",	$D0,	$00		;  00000000
		 FCB	  "PTR",	$CF,	$00		;  00000000
		 FCB	  "TIME",	$D1,	$00		;  00000000
		 FCB	  "LOMEM",	$D2,	$00		;  00000000
		 FCB	  "HIMEM",	$D3,	$00		;  00000000
		 FCB	  "Missing ",	$8D,	$00
; END


