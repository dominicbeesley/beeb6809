;			;  PRINT INLINE TEXT - 0 terminated rather than NOP!
;			;  ================= expects JSR to be followed by a SWI, code, string message



PrBrk
		PSHS	CC,D,DP,X,Y,U

		JSR	PrRegs2

		PRINT_STR	"\r\nBRK:"

		LDX	10,S
		LDA	1,X
		JSR	PRHEX
		LDA	#' '
		JSR	OSASCI
		LEAX	2,X
PrBrkLp		LDA	,X+
		BEQ	PrBrkSk
		JSR	OSASCI
		BRA	PrBrkLp
PrBrkSk		PULS	CC,D,DP,X,Y,U,PC


PrRegs
		PSHS	CC,D,DP,X,Y,U

		JSR	PrRegs2

		PULS	CC,D,DP,X,Y,U,PC



PrRegs2
		PRINT_STR	"CC="
		LDA	2+0,S
		JSR	PRHEX

		PRINT_STR	",D="
		LDA	2+1,S
		JSR	PRHEX
		LDA	2+2,S
		JSR	PRHEX

		PRINT_STR	",DP="
		LDA	2+3,S
		JSR	PRHEX

		PRINT_STR	",X="
		LDA	2+4,S
		JSR	PRHEX
		LDA	2+5,S
		JSR	PRHEX

		PRINT_STR	",Y="
		LDA	2+6,S
		JSR	PRHEX
		LDA	2+7,S
		JSR	PRHEX

		PRINT_STR	",U="
		LDA	2+8,S
		JSR	PRHEX
		LDA	2+9,S
		JSR	PRHEX

		PRINT_STR	",PC="
		LDD	2+10,S
		SUBD	#3
		JSR	PRHEX
		TFR	B,A
		JSR	PRHEX

		PRINT_STR	",S="
		LEAX	2+12,S
		TFR	X,D
		JSR	PRHEX
		TFR	B,A
		JSR	PRHEX

		PRINT_STR	"\rSTACK="
PrLp1		CMPX	#$200
		BHS	PrSk1
		LDA	,X+
		JSR	PRHEX
		LDA	#' '
		JSR	OSASCI
		BRA	PrLp1

PrSk1		JSR	OSNEWL
		RTS





PrDead		PRINT_STR	"DEAD:"
		RTS