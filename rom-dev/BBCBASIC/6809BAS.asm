;			(c) Dominic Beesley 2017 - translated BAS4816 - forked from BAS432JGH to 6809
;			;  > Basic4/src
;			;  Source code for 6502 BBC BASIC IV for the BBC
;			
;			; ZP pointers are all in big endian
;			; INTs in ZP_WA are in big endian
;			; when address of variables and type are in ZP_WA then pointer is at +2, type at + 0
;			; when line numbers in ZP_WA then stored at WA+2
;
;

VERSION			EQU $0433	; Version 4.33
VERSIONSTR 	MACRO
			FCB	"2022 Dossy",0
		ENDM

			INCLUDE		"../../includes/common.inc"

	IF	FLEX=1
			INCLUDE		"../../includes/flex/flexlib.inc"
	ELSE
			INCLUDE		"../../includes/mosrom.inc"
			INCLUDE		"../../includes/oslib.inc"
	ENDIF

DEBUG			EQU	1
LOADADDR		EQU $8000
COMPADDR		EQU $8000

ZP_MOS_ERROR_PTR_QRY	EQU	$FD		; TODOFLEX - move this defn somewhere?

			INCLUDE		"./macros.inc"
			INCLUDE		"./zp.inc"
			INCLUDE		"./tokens.inc"
			INCLUDE		"./layout.inc"

************************** SETUP TABLES AND CODE AREAS ******************************
			CODE
			ORG	COMPADDR
			SETDP	$00

************************** START MAIN ROM CODE ******************************
			CODE
	IF FLEX != 1
ROMSTART		
			INCLUDE		"./rom-header-tube.asm"
			CMPA	#1
			BEQ	ROM_LANGST
			RTS
	ELSE
			BRA	FLEX_LANGST
	ENDIF
tblTENS_BE		FDB	$0001
			FDB	$000A
			FDB	$0064
			FDB	$03E8
			FDB	$2710

;		;  LANGUAGE STARTUP
;		;  ================
;;JGH 15-Jun-2017
;; Startup procedure should be:
;;  Reset stack - we can now do CALLs
;;  Set up direct page in case OSINIT doesn't change it
;;  Initialise error handler - we can now claim BRKV, ask for memory limits and access Direct Page
;;  Doing in this order allows OSINIT to set DP to a per-task area
;;  Claim BRKV as pointed to by OSINIT
;;  Request memory limits
;;  Start initialising memory
;;  DB - 


	IF FLEX != 1
;
;		;  LANGUAGE STARTUP
;		;  ================
ROM_LANGST	RESET_MACH_STACK
		PSHS	A					; store A

		CLRA
;;		TFR	A, DP					; Default direct page

		JSR	OSINIT					; A=0, Set up default environment
		STA	ZP_BIGEND
		STY	ZP_ESCPTR
		LEAU	HandleBRK, PCR
		STU	,X					; Claim BRKV

		LEAU	HeaderCopyright, PCR
		STU	ZP_MOS_ERROR_PTR_QRY

		LDA	#$84
		JSR	OSBYTE					; Read top of memory, set HIMEM
		STX	ZP_HIMEM
		LEAX	ROMSTART,PCR
		CMPX	ZP_HIMEM				; check to see if the returned HIMEM is > than start of ROM
		BHS	1F					; if it is ignore it and set to start of ROM - this for
		STX	ZP_HIMEM				; old matchbox copros with unfixed tube client code
1		LDA	#$83					; DB: must reload value here as A might be set above
		JSR	OSBYTE
		TFR	X,D					; A=high byte of returned bottom of memory
		CMPA	#8
		BLS	2F					; Too low, reserve space for workspace
		CMPA	ZP_HIMEM				; check to see that returned page isn't too high (matchbox client code fix)
		BLO	1F
2		LDA	#8					; make PAGE at least 800 to leave room for ZP, stack, variable pointers etc
1		STA	ZP_PAGE_H				; Read bottom of memory, set PAGE
								; Will need more work to do "per task" memory relocations
	ELSE
FLEX_LANGST
		CLRA
		TFR	A, DP					; Default direct page
		RESET_MACH_STACK

		LDA	#$80
		LDY	#$00FF
		CLR	$FF					; TODOFLEX - how to detect ESCAPE?
		STA	ZP_BIGEND
		STY	ZP_ESCPTR
		LDA	#$8
		STA	ZP_PAGE_H
		LDX	#$8000
		STX	ZP_HIMEM				; TODOFLEX this assumes program loaded at $8000 and full 56k memory

		;;CLR	ECHOFLAG				; TODOFLEX - is this the right way to turn off local echo?
	ENDIF

;	IF DEBUG != 0
;		TST	ZP_BIGEND
;		BPL	1F
;		PRINT_STR	"(LE"
;		BRA	2F
;1		PRINT_STR	"(BE"
;2		PRINT_STR	", page="
;		LDA	ZP_PAGE_H
;		CALL	PRHEX
;		PRINT_STR "00, himem="
;		LDX	ZP_HIMEM
;		CALL	PR2HEX
;
;		PRINT_STR ", swr#="
;
;		LDA	<$F4	; get current rom number
;		CALL	PRHEX
;
;	IF IF FLEX = 1
;		PRINT_STR ", FLEX)\r"
;	ELSE
;		PRINT_STR ", BBC/CHIP/MB)\r"
;	ENDIF
;	ENDIF

		LDA	#$01
		ANDA	ZP_RND_WA + 4				; just bottom bit of +4?
		ORA	ZP_RND_WA + 3
		ORA	ZP_RND_WA + 2
		ORA	ZP_RND_WA + 1
		ORA	ZP_RND_WA + 0				;  Check RND seed
		BNE	1F					;  If nonzero, skip past
		LDD	#$5241
		STD	ZP_RND_WA + 2				;  Set RND seed to "ARW" - Acorn/Roger/Wilson
		LDD	#$57
		STD	ZP_RND_WA + 0
1		

		CLR	ZP_LISTO				;  Set LISTO to 0
		CLR	BASWKSP_INTVAR + 0
		CLR	BASWKSP_INTVAR + 1			;  Set @% to $0000xxxx
		LDA	#$FF
		STA	ZP_WIDTH				;  Set WIDTH to $ff
		LDD	#$090A					;  Set up @% (thanks JGH)
		STD	BASWKSP_INTVAR + 2

		CLI						; enable IRQ
		JUMP	reset_prog_enter_immedprompt		;  Enable IRQs, jump to immediate loop - DB - I've kept this similar as I may want to add command line params later...

		******************************************
		* FLEX - Replacement routines
		******************************************

	IF FLEX =1
PRSTRING	LDA	,X+
		BEQ	1F
		JSR	OSASCI					; TODOFLEX: need to check for special chars?
		BRA	PRSTRING
1		RTS

PRHEX		PSHS	A,X
		LEAX	1,S
		JSR	OUTHEX
		PULS	A,X,PC
PR2HEX		PSHS	X
		LEAX	0,S
		JSR	OUTHEX
		LEAX	1,S
		JSR	OUTHEX
		PULS	X,PC
OSASCI		cmpa	#$0D		
		bne	OSWRCH		
OSNEWL		lda	#$0A		
		JSR	OSWRCH	
		lda	#$0D		
OSWRCH		PSHS	A
		JSR	PUTCHR
		PULS	A,PC

OSCLI		PSHS	D,X,U,U,CC
		CLRB
		LDU	#LINBUF
		STU	CBUFPT
1		LDA	B,X
		STA	B,U
		CMPA	#$D
		BEQ	1F
		INCB
		BPL	1B

1		JSR	DOCMD
		TSTB
		BEQ	OSCLI_OK
		ORB	#$80				; make a BASIC error number from a Flex error number
FLEXERROR
		LDU	#MACH_STACK_BOT
		PSHS	U				; "return address" for HandleBRK
		STB	,U+				; error number
		LEAX	strFLEXERROR,PCR
1		LDA	,X+
		STA	,U+
		BNE	1B
		JMP	HandleBRK			; jump to dynamic error


OSCLI_OK		PULS	D,X,U,U,CC,PC

OSRDCH		JMP	GETCHR
		

FLEX_READLINE	CLRB					; TODOFLEX - this is very simplistic
		TFR	D,X
FLEX_RL_LP	JSR	OSRDCH				; get char
		CMPA	#$D
		BEQ	FLEX_RL_CR
		CMPA	#8
		BEQ	FLEX_RL_BS
		CMPA	#$1B
		BEQ	FLEX_RL_ESC
		INCB
		BEQ	FLEX_RL_FULL
		STA	,X+
		;;JSR	OSWRCH
		BRA	FLEX_RL_LP
FLEX_RL_FULL
		DECB
FLEX_RL_BEEP
		LDA	#7
		JSR	OSWRCH
		BRA	FLEX_RL_LP
FLEX_RL_CR
		INCB
		BEQ	FLEX_RL_RTS
		STA	,X+
		JSR	OSNEWL
		BRA	FLEX_RL_RTS
FLEX_RL_BS	TSTB
		BEQ	FLEX_RL_BEEP
		DECB
		LEAX	-1,X
		LDA	#' '
		JSR	OSWRCH				; TODOFLEX - assumes char 8 is backspace
		LDA	#8
		JSR	OSWRCH
		BRA	FLEX_RL_LP

FLEX_RL_ESC	SEC
FLEX_RL_RTS	RTS

		SECTION "tables_and_strings"
strFLEXERROR	FCB	"Flex Error",0
		CODE

	ENDIF


	include		"./tokenstable.asm"


;		
;		
;		;  Look up FN/PROC address
;		;  =======================
;		;  On entry, B=length of name
;		;	     [ZP_GEN_PTR+2]+1=>FN/PROC token (ie, first character of name)
findFNPROC	PSHS	U
		STB	ZP_NAMELENORVT			;  Store length of name
		LDU	ZP_GEN_PTR+2
		LDA	1,U				;  Get FN/PROC character
		LDB	#BASWKSP_DYNVAR_off_PROC	;  Preload with offset to PROC list
		CMPA	#tknPROC
		BEQ	findLinkedListNewAPI		;  If PROC, follow PROC list
		LDB	#BASWKSP_DYNVAR_off_FN
		BRA	findLinkedListNewAPI		;  Otherwise, follow FN list
;		
;		
;			;  Look up variable address
;			;  ========================
;			;  On entry, B=1 + length of name
;			;	     [ZP_GEN_PTR+2]+1=>first character of name
			;  On exit
			;	Z = 1 for not found
			;	else X and ZP_INT_WA + 2 points at variable data
findVarDynLL_NewAPI
		PSHS	U
		STB	ZP_NAMELENORVT			;  Store length of name
		LDU	ZP_GEN_PTR+2
		LDB 	1,U				;  Get initial letter
		ASLB
;			;  Follow linked variable list to find named item
;			;  ----------------------------------------------
;			;  B = offset in Page 4 link start table
findLinkedListNewAPI
		LDA	#BASWKSP_INTVAR / 256
		TFR	D,X
;		LDX	,X				; X contains pointer to first var block (or zero)
;		BRA	fll_skitem								
fll_nextItem	
		LDB	#2
		LDX	,X
fll_skitem	BEQ	fll_sk_nomatch				
		*STX	ZP_INT_WA + 2			; store pointer
fll_chlp	LDA	B,X
		BEQ	fll_sk_nameEnd
		CMPA	B,U
		BNE	fll_nextItem
		INCB
		CMPB	ZP_NAMELENORVT			; at end of name?
		BNE	fll_chlp
		LDA	B,X	 			; at end of name - check 0 term in dynvar
		BNE	fll_nextItem
		BRA	fll_match
;
fll_sk_nameEnd
		CMPB	ZP_NAMELENORVT
		BNE	fll_nextItem
fll_match	INCB
		ABX
		STX	ZP_INT_WA + 2			; ZP_INT_WA points at the start of the variable data
fll_sk_nomatch
		PULS	U,PC				;  not matched Z = 1


		;  Search for program line
		;  =======================
		; NEW API
		;  On entry,	ZP_INT_WA + 2 => line number
		;  On Exit,	X,Y and ZP_FPB + 2 => program line start or next line (points at the 0D at start of this line)
		;		Cy=1 indicates line found
		;		Cy=0 not found
	;  TODO: check all occurrences and remove store to ZP_FPB if not ever used
		; OLD API
		;  On entry,	ZP_INT_WA = line number
		;  On exit,  ZP_FPB + 2 =>program line, or next line
		;	     CS = line found
		;	     CC = line not found
		;	    U, ZP_FPB+2 point to found line, or line after
		
findProgLineNewAPI	
		LDA	ZP_PAGE_H		; X points at start of Program
		CLRB
		TFR	D,X
fpl_lp1		LDD	1,X			; get 16 bit line number at +1
		CMPD	ZP_INT_WA + 2
		BHS	fpl_ge
		LDB	3,X
		ABX
		BRA	fpl_lp1
fpl_ge		BNE	flp_sk1
		SEC
flp_sk1		STX	ZP_FPB + 2
		LEAU	,X
		RTS
;		
;			
;		;  Integer division
;		;  ================
;		;  On entry, $2A-$2D (IntA)  =	integer LHS of A DIV B or A MOD B
;		;	     $30-$34 (RealA) =	real LHS of A DIV B or A MOD B
;		;	     Program pointer => RHS of expression
;		;  On exit,  $39-$3C = result, $37=sign of result
;		;	     $3D-$40 = remainder, $38=sign of remainder
;		;
evalDoIntDivide						; L80F9
		CALL	checkTypeInAConvert2INT		;  Convert Real to Integer
		LDA	ZP_INT_WA + 0
		STA	,-S				; save sign of LHS as sign of remainder
		CALL	intWA_ABS			; Ensure LHS is positive
		CALL	stackINTEvalLevel2		; Stack LHS, evaluate RHS
		STB	ZP_VARTYPE			; Save current token
		CALL	checkTypeInAConvert2INT		; Save next character, convert Real to Int
		LDA	,S+				; get back sign of remainder
		EORA	ZP_INT_WA + 0			
		STA	ZP_GEN_PTR			; EOR with sign of RHS to get sign of result
		CALL	intWA_ABS			; Ensure RHS is positive
		LDX	#ZP_INT_WA_B			
		CALL	popIntAtXNew			; Pop LHS from stack to IntB at $39-$3C

	IF CPU_6309
		CLRD
	ELSE
		CLRA
		CLRB
	ENDIF
		STD	ZP_INT_WA_C
		STD	ZP_INT_WA_C + 2			; Clear remainder in IntC

		CALL	IntWAZero			; Check if IntA is zero
		BEQ	brkDivideByZero			; Error if divide by zero
		LDB	#$20				; 32-bit division
		STB	ZP_FP_TMP

		; TODO - bytewise shift here should speed things up

1							; L812D
		DEC	ZP_FP_TMP
		BEQ	2F				; All bits done
		ASL	ZP_INT_WA_B + 3
		ROL	ZP_INT_WA_B + 2
		ROL	ZP_INT_WA_B + 1
		ROL	ZP_INT_WA_B + 0			; Result=Result*2
		BPL	1B				; Loop if no zero bit
3							; L813A:
		ROL	ZP_INT_WA_B + 3			; Result=Result*2
		ROL	ZP_INT_WA_B + 2
		ROL	ZP_INT_WA_B + 1
		ROL	ZP_INT_WA_B + 0
		ROL	ZP_INT_WA_C + 3			; Remainder=Remainder*2+1 
		ROL	ZP_INT_WA_C + 2			; (there is always a carry from WA_B 
		ROL	ZP_INT_WA_C + 1			; as it was PL at end of loop above)
		ROL	ZP_INT_WA_C + 0				

		LDD	ZP_INT_WA_C + 2
		SUBD	ZP_INT_WA + 2
		PSHS	D
		LDD	ZP_INT_WA_C + 0
		SBCB	ZP_INT_WA + 1
		SBCA	ZP_INT_WA + 0
		BCS	4F				; Couldn't subtract, do next bit
		STD	ZP_INT_WA_C + 0
		PULS	D
		STD	ZP_INT_WA_C + 2			; Remainder=Remainder-Divisor
		BRA	5F				; Loop to do next bit
4							; L816C:
		CLC				; swap carry
		LEAS	2,S				; Couldn't subtract, drop stacked value
		BRA	6F
5							; L816E:
		SEC				; swap carry
6		DEC	ZP_FP_TMP
		BNE	3B				; Loop for another bit
2							; L8171
		RTS					; All done, return

brkDivideByZero
		DO_BRK_B
		FCB	$12,"Division by zero",0


;		;  Convert Integer to Real
;		;  =======================
;		;  On entry, $2A-$2D (IntA) = Integer
;		;  On exit,  $2E=sign of real
;		; TODO - this first bit of shuffling could be done better with D/16
IntToReal
		CLRA
		STA	ZP_FPA + 7
		STA	ZP_FPA + 1				; Clear rounding byte and exponent high byte
IntToReal2							; L8189
		LDA	ZP_INT_WA + 0
		STA	ZP_FPA				; set sign from integer sign
		BPL	Int2R_skPos				; Copy IntA sign to RealA sign, jump if positive
		CALL	negateIntA				; Convert negative IntA to positive

		; left justify the integer in the FPA register mantissa

		LDA	ZP_INT_WA + 0				
Int2R_skPos							; L8194:
		BNE	IntToReal_left32					; Top byte nonzero, so jump to convert
		CLR	ZP_FPA + 6
		LDA	ZP_INT_WA + 1
		BNE	IntToReal_left24					; Clear RealA, if next byte nonzero jump to convert
		CLR	ZP_FPA + 5
		LDA	ZP_INT_WA + 2
		BNE	IntToReal_left16					; Clear RealA, if next byte nonzero jump to convert
		CLR	ZP_FPA + 4
		LDA	ZP_INT_WA + 3
		BRA	IntToReal_skSetB88cont			;  Clear RealA, if next byte nonzero jump to convert

;		;  INT=$0000xxyy where xx<>00
;		;  ----------------------

IntToReal_left16							; L81A8
		LDB	ZP_INT_WA + 3
		STB	ZP_FPA + 4				;  Copy $yy000000 to mantissa
		LDB	#$90
		BRA	IntToReal_Normalize					;  Normalise 16 bits

;		;  INT=$00xxyyyy where xx<>00, A = $xx
;		;  -----------------------------
IntToReal_left24						; L81B0
		LDX	ZP_INT_WA + 2
		STX	ZP_FPA + 4				;  Copy $yyyy0000 to mantissa
		LDB	#$98
		BRA	IntToReal_Normalize					;  Normalise 24 bits

;		;  $xxyyyyyy when xx<>00, A = $xx
;		;  ----------------------------
IntToReal_left32						; L81BC
		LDX	ZP_INT_WA + 1
		STX	ZP_FPA + 4				;  Copy $yyyyyy00 to mantissa
		LDB	ZP_INT_WA + 3
		STB	ZP_FPA + 6
		LDB	#$A0
		BRA	IntToReal_Normalize					;  Normalise 32 bits

;		;  Return Real zero
;		;  ----------------
			; expects A=0 on entry, trashes B
IntToReal_retReal0
		CLRB
		STD	ZP_FPA
		STD	ZP_FPA + 2

anRTS8		RTS

IntToReal_8signedA2real_check				; L81D5
		CALL	zero_FPA
		TSTA
		BPL	IntToReal_skSetB88cont
		STA	ZP_FPA
		EORA	#$FF
		INCA
IntToReal_skSetB88cont					; L81E0
		LDB	#$88				;  Normalise 8 bits

;			;  Normalise RealA
;			;  ---------------
;			;  On entry, A=high byte of mantissa, B=exponent
;			;  On exit,  exponent and mantissa in RealA normalised
IntToReal_Normalize					; L81E2
		TSTA
		BMI	IntToReal_Normalize_sk0		; Top bit set, it is normalized
		BEQ	IntToReal_retReal0		; Zero, jump to return Real zero
IntToReal_Normalize_lp					; L81E8
		DECB					; Decrease exponent, dividing number by 2
		ASL	ZP_FPA + 6
		ROL	ZP_FPA + 5
		ROL	ZP_FPA + 4			; Multiply mantissa by 2, keeping number the same
		ROLA
		BPL	IntToReal_Normalize_lp		; Loop while exponent still >= $80+0
IntToReal_Normalize_sk0					; L81F2
		STA	ZP_FPA + 3			; store MSB
		STB	ZP_FPA + 2			; store exponent
		RTS					; Store mantissa and exponent, return
;		
;			;  Normalise RealA
;			;  ---------------
NormaliseRealA
		LDA	ZP_FPA + 3			; Get mantissa top byte
NormaliseRealA_2
		BMI	anRTS8				; top bit set, return
NormaliseRealA_3
		BNE	__NormaliseRealA_sk2		; Nonzero, skip zero test
		ORA	ZP_FPA + 4
		ORA	ZP_FPA + 5			; Check if mantissa is zero
		ORA	ZP_FPA + 6
		ORA	ZP_FPA + 7
		BEQ	IntToReal_retReal0		; Jump to return Real zero
		LDX	ZP_FPA + 1			; Not zero, get exponent
NormaliseRealA_lp1					; If we got here top byte of mantissa is empty, shift mant up 8 and dec the exp
		LDD	ZP_FPA + 4
		STD	ZP_FPA + 3
		LDD	ZP_FPA + 6
		STD	ZP_FPA + 5
		CLR	ZP_FPA + 7
		LEAX	-8,X				; Decrease exponent by 8
NormaliseRealA_sk1
		TST	ZP_FPA + 3
		BEQ	NormaliseRealA_lp1		; Mantissa top byte still zero, need to normalise more
		BMI	__NormaliseRealA_sk5		; Fully normalised, store and return
		BRA	__NormaliseRealA_sk3		; Less than 8 bits left to normalise
__NormaliseRealA_sk2
		LDX	ZP_FPA + 1			;  Get exponent
__NormaliseRealA_sk3
		LDD	ZP_FPA + 3
NormaliseRealA_lp2
		LEAX	-1,X				;  Decrease exponent by 1
NormaliseRealA_sk4
		ASL	ZP_FPA + 7
		ROL	ZP_FPA + 6			;  Multiply mantissa by 2
		ROL	ZP_FPA + 5
		ROLB
		ROLA
		BPL	NormaliseRealA_lp2		;  Still not normalise, loop for another bit
		STD	ZP_FPA + 3
__NormaliseRealA_sk5
		STX	ZP_FPA + 1
		RTS				;  Store exponent and return
;		
;			;  Convert float to integer
;			;  ========================
;			;  On entry, FloatA (ZP_FPA + 0..7) holds a float (extended exponent ignored but sign byte at ZP_FPA is used)
;			;  On exit,  FloatA (ZP_FPA + 2..7) holds integer part
;			;  ---------------------------------------------
;			;  The real value is partially denormalised by repeatedly dividing the mantissa
;			;  by 2 and incrementing the exponent to multiply the number by 2, until the
;			;  exponent is $80, indicating that we have got to mantissa * 2^0.
;			;
fpAMant2Int
		LDA	ZP_FPA + 2
		BPL	fpAMant2Int_sk1			; Exponent<$80, number<1, jump to return 0
		TST	ZP_FPA + 3
		BEQ	fpMant2Int_CheckSignAndNegate	; Mantissa = $00xxxxxx, real holds an int, jump to check for negative
fpAMant2Int_lp1
		CALL	FPAshr1
		BEQ	fpMant2Int_brkTooBig		; Inc. exponent, if run out of exponent, jump to 'Too big'
fpAMant2Int_lp2	CMPA	#$A0
		BHS	fpMant2Int_brkTooBigIfNE	; Exponent is +32, float has been denormalised to an integer
		CMPA	#$99
		BHS	fpAMant2Int_lp1			; Loop to keep dividing
		ADDA	#$08				; Increment exponent by 8
		LDX	ZP_FPA + 4
		STX	ZP_FPA + 5			; Divide mantissa by 2^8
		LDB	ZP_FPA + 3
		STB	ZP_FPA + 4
		CLR	ZP_FPA + 3
		BRA	fpAMant2Int_lp2			; Loop to keep dividing

FPAshr1
		CLC
FPAror1
		ROR	ZP_FPA + 3
		ROR	ZP_FPA + 4
		ROR	ZP_FPA + 5
		ROR	ZP_FPA + 6
		ROR	ZP_FPA + 7
		INCA
		RTS



fpFPAtoFPBzeroFPA
		CALL fpCopyFPAtoFPB
fpAMant2Int_sk1	JUMP	zero_FPA

fpFPAMant2Int_remainder_inFPB				; L8275
		LDA	ZP_FPA + 2
		BPL	fpFPAtoFPBzeroFPA		; if exponent < $80 then zero FPA and copy FPA to FPB
		CALL	fpSetRealBto0
		LDB	ZP_FPA + 3			; get mantissa MSB return 0 or -1 depending on sign
		BEQ	fpMant2Int_CheckSignAndNegate	; L827E
L8280
		CALL	FPAshr1

		; slow but small - the original only shifted right 3..6 but the FPAshr1 shifts into
		; FPA 7 so shift it back out left to recover carry

		ASL	ZP_FPA + 7

		ROR	ZP_FPB + 2
		ROR	ZP_FPB + 3
		ROR	ZP_FPB + 4
		ROR	ZP_FPB + 5
		TSTA
		BEQ	fpMant2Int_brkTooBig
L8293
		CMPA	#$A0				; compare to A0, i.e. $80 + 32
		BHS	fpMant2Int_brkTooBigIfNE	; if so then if equal return else too big
		CMPA	#$99
		BHS	L8280				; keep rolling bitwise
		ADDA	#$08				; else roll bytewise
		STA	,-S				; save A

		LDD	ZP_FPB + 3
		STD	ZP_FPB + 4
		LDB	ZP_FPB + 2
		STB	ZP_FPB + 3
		
		LDB	ZP_FPA + 6
		STB	ZP_FPB + 2
		
		LDD	ZP_FPA + 4
		STD	ZP_FPA + 5		
		LDB	ZP_FPA + 3
		STB	ZP_FPA + 4
		
		CLR	ZP_FPA + 3
		LDA	,S+
		BRA L8293
fpMant2Int_brkTooBig
		JUMP	brkTooBig
fpMant2Int_brkTooBigIfNE				; L82C0
		BNE	fpMant2Int_brkTooBig		; Exponent>32, jump to 'Too big' error
		STA	ZP_FPA + 2			; Store +32 exponent
fpMant2Int_CheckSignAndNegate				; L82C4
		LDA	ZP_FPA			; sign byte
		BPL	fpMant2Int_RTS			; If positive, jump to return
fpReal2Int_NegateMantissa				; L82C8
		;  Negate the mantissa to get integer
		LDD	#0
		SUBD	ZP_FPA + 5
		STD	ZP_FPA + 5
		LDD	#0
		SBCB	ZP_FPA + 4
		SBCA	ZP_FPA + 3
		STD	ZP_FPA + 3
fpMant2Int_RTS						; L82DF
		RTS
fpFPASplitToFractPlusInt
		LDA	ZP_FPA + 2
		BMI	L82E9				
		CLR	ZP_FP_TMP + 6			; if >1 then fix up for int+fract
		JUMP	fpCheckMant0SetSignExp0
L82E9		CALL	fpFPAMant2Int_remainder_inFPB
		LDA	ZP_FPA + 6
		STA	ZP_FP_TMP + 6
		CALL	fpCopyBManttoA_NewAPI
		LDA	#$80
		STA	ZP_FPA + 2
		LDB	ZP_FPA + 3
		BPL	L830A
		EORA	ZP_FPA
		STA	ZP_FPA
		BPL	L8305
		INC	ZP_FP_TMP + 6
		BRA	L8307
L8305		DEC	ZP_FP_TMP + 6
L8307		CALL	fpReal2Int_NegateMantissa
L830A		JUMP	NormaliseRealA

fpIncrementFPAMantissa					; L830D
		INC	ZP_FPA + 6
		BNE	L831D
		INC	ZP_FPA + 5
		BNE	L831D
		INC	ZP_FPA + 4
		BNE	L831D
		INC	ZP_FPA + 3
		BEQ	fpMant2Int_brkTooBig
L831D
		RTS
		; make next random
		; not order of storage is different to 6502
		; 0 -> 3
		; 1 -> 2
		; 2 -> 1
		; 3 -> 0
		; 4 -> 4
rndNext						; L831E
		LDB	#4
		STB	ZP_FP_TMP
1		ROR	ZP_RND_WA + 4
		LDA	ZP_RND_WA + 0
		TFR	A,B
		RORA
		STA 	ZP_RND_WA + 4
		LDA 	ZP_RND_WA + 1
		STA 	ZP_RND_WA + 0
		LSRA
		EORA	ZP_RND_WA + 2
		ANDA	#$0F
		EORA	ZP_RND_WA + 2
		RORA
		RORA
		RORA
		RORA
		EORA	ZP_RND_WA + 4
		STB	ZP_RND_WA + 4
		LDB	ZP_RND_WA + 2
		STB	ZP_RND_WA + 1
		LDB	ZP_RND_WA + 3
		STB	ZP_RND_WA + 2
		STA	ZP_RND_WA + 3
		DEC	ZP_FP_TMP
		BNE	1B
		RTS

fpCopyBtoA_NewAPI					; L8349		- note TRASHES B
		LDD	ZP_FPB
		STA	ZP_FPA
		CLR	ZP_FPA + 1
		STB	ZP_FPA + 2
fpCopyBManttoA_NewAPI					; L8353		- note TRASHES B
		LDD	ZP_FPB + 2
		STD	ZP_FPA + 3

		LDD	ZP_FPB + 4
		STD	ZP_FPA + 5

		LDA	ZP_FPB + 6
		STA	ZP_FPA + 7
rtsL8367
		RTS
fpAddAtoBStoreA						; L8368
		LDA	ZP_FPA + 3			; quick check if A = 0 then just move B to A
		BEQ	fpCopyBtoA_NewAPI
		LDA	ZP_FPA + 2
		SUBA	ZP_FPB + 1
		BEQ	fpAddAtoBStoreA_sk_sameExp
		BCS	fpAddAtoBStoreA_skAtooSmall
		CMPA	#$25
		BCC	rtsL8367
		TFR	A,B
		ANDA	#$38
		BEQ	fpAddAtoBStoreA_shr8_B_sk
fpAddAtoBStoreA_shr8_B_lp				; L837F
		LDX	ZP_FPB + 4			; shift B right in 8's
		STX	ZP_FPB + 5
		LDX	ZP_FPB + 2
		STX	ZP_FPB + 3
		CLR	ZP_FPB + 2
		SUBA	#$08
		BNE	fpAddAtoBStoreA_shr8_B_lp
fpAddAtoBStoreA_shr8_B_sk				; L8395:
		TFR	B,A
		ANDA	#$07
		BEQ	fpAddAtoBStoreA_sk_sameExp
fpAddAtoBStoreA_shr1_B_lp					; L839A:
		CALL	fpShiftBMantissaRight
		DECA
		BNE	fpAddAtoBStoreA_shr1_B_lp
		BRA	fpAddAtoBStoreA_sk_sameExp

fpAddAtoBStoreA_skAtooSmall				; L83A9
		; shift A  right until it is of same order as B
		EORA	#$FF
		INCA
		CMPA	#$25
		BCC	fpCopyBtoA_NewAPI
		LDB	ZP_FPB + 1
		STB	ZP_FPA + 2
		TFR	A,B
		ANDA	#$38
		BEQ	fpAddAtoBStoreA_shr8_A_sk
fpAddAtoBStoreA_shr8_A_lp				; L83BA:
		LDX	ZP_FPA + 5
		STX	ZP_FPA + 6
		LDX	ZP_FPA + 3
		STX	ZP_FPA + 4
		CLR	ZP_FPA + 3
		SUBA	#$08
		BNE	fpAddAtoBStoreA_shr8_A_lp
fpAddAtoBStoreA_shr8_A_sk				; L83D0:
		TFR	B,A
		ANDA	#$07
		BEQ	fpAddAtoBStoreA_sk_sameExp
		NEGA
fpAddAtoBStoreA_shr1_A_lp				; L83D5:
		CALL	FPAshr1
		BNE	fpAddAtoBStoreA_shr1_A_lp
fpAddAtoBStoreA_sk_sameExp				; L83E2
		LDA	ZP_FPA
		EORA	ZP_FPB
		BMI	fpAddAtoBstoreA_oppsigns	; signs are different
		JUMP	fpAddAtoBstoreinA_sameExp
fpAddAtoBstoreA_oppsigns				; L83EC
		LDD	ZP_FPA + 3			; compare mants
		CMPD	ZP_FPB + 2
		BNE	fpAddAtoBstoreA_oppsigns_sk
		LDD	ZP_FPA + 5
		CMPD	ZP_FPB + 4
		BNE	fpAddAtoBstoreA_oppsigns_sk
		LDA	ZP_FPA + 7
		CMPA	ZP_FPB + 6
		BNE	fpAddAtoBstoreA_oppsigns_sk
		JUMP	zero_FPA			; they're the same return 0
fpAddAtoBstoreA_oppsigns_sk				; L840D
		BHS	fpAddAtoBstoreA_oppsigns_sk2	; gt
		LDA	ZP_FPB
		STA	ZP_FPA			; keep B' sign

		LDD	ZP_FPB + 5
		SUBD	ZP_FPA + 6
		STD	ZP_FPA + 6

		LDD	ZP_FPB + 3
	IF CPU_6309
		SBCD	ZP_FPA + 4
	ELSE
		SBCB	ZP_FPA + 5
		SBCA	ZP_FPA + 4
	ENDIF
		STD	ZP_FPA + 4

		LDA	ZP_FPB + 2
		SBCA	ZP_FPA + 3
		STA	ZP_FPA + 3
		JUMP	NormaliseRealA_2

fpAddAtoBstoreA_oppsigns_sk2				; L8435
		LDD	ZP_FPA + 6
		SUBD	ZP_FPB + 5
		STD	ZP_FPA + 6

		LDD	ZP_FPA + 4
	IF CPU_6309
		SBCD	ZP_FPB + 3
	ELSE
		SBCB	ZP_FPB + 4
		SBCA	ZP_FPB + 3
	ENDIF
		STD	ZP_FPA + 4

		LDA	ZP_FPA + 3
		SBCA	ZP_FPB + 2
		STA	ZP_FPA + 3
		JUMP	NormaliseRealA_2
;		
;			;  00000000
;			;  FUNCTION/COMMAND DISPATCH TABLE
;			;  ===============================
tblCmdDispatch
		 FDB fnOPENIN			;  $8E - OPENIN
		 FDB varGetPTR			;  $8F - =PTR
		 FDB varGetPAGE			;  $90 - =PAGE
		 FDB varGetTIME			;  $91 - =TIME
		 FDB varGetLOMEM		;  $92 - =LOMEM
		 FDB varGetHIMEM		;  $93 - =HIMEM
		 FDB fnABS			;  $94 - ABS
		 FDB fnACS			;  $95 - ACS
		 FDB fnADVAL			;  $96 - ADVAL
		 FDB fnASC			;  $97 - ASC
		 FDB fnASN			;  $98 - ASN
		 FDB fnATN			;  $99 - ATN
		 FDB fnBGET			;  $9A - BGET
		 FDB fnCOS			;  $9B - COS
		 FDB fnCOUNT			;  $9C - COUNT
		 FDB fnDEG			;  $9D - DEG
		 FDB varERL			;  $9E - ERL
		 FDB varERR			;  $9F - ERR
		 FDB fnEVAL			;  $A0 - EVAL
		 FDB fnEXP			;  $A1 - EXP
		 FDB fnEXT			;  $A2 - EXT
		 FDB varFALSE			;  $A3 - FALSE
		 FDB fnFN			;  $A4 - FN
		 FDB fnGET			;  $A5 - GET
		 FDB fnINKEY			;  $A6 - INKEY
		 FDB fnINSTR			;  $A7 - INSTR(
		 FDB fnINT			;  $A8 - INT
		 FDB fnLEN			;  $A9 - LEN
		 FDB fnLN			;  $AA - LN
		 FDB fnLOG			;  $AB - LOG
		 FDB fnNOT			;  $AC - NOT
		 FDB fnOPENUP			;  $AD - OPENUP
		 FDB fnOPENOUT			;  $AE - OPENOUT
		 FDB fnPI			;  $AF - PI
		 FDB fnPOINT			;  $B0 - POINT(
		 FDB fnPOS			;  $B1 - POS
		 FDB fnRAD			;  $B2 - RAD
		 FDB fnRND			;  $B3 - RND
		 FDB fnSGN			;  $B4 - SGN
		 FDB fnSIN			;  $B5 - SIN
		 FDB fnSQR			;  $B6 - SQR
		 FDB fnTAN			;  $B7 - TAN
		 FDB fnTO			;  $B8 - TO
		 FDB returnINTminus1		;  $B9 - TRUE
		 FDB fnUSR			;  $BA - USR
		 FDB fnVAL			;  $BB - VAL
		 FDB fnVPOS			;  $BC - VPOS
		 FDB fnCHR			;  $BD - CHR$
		 FDB fnGETDOLLAR		;  $BE - GET$
		 FDB fnINKEYDOLLAR		;  $BF - INKEY$
		 FDB fnLEFT			;  $C0 - LEFT$(
		 FDB fnMIDstr			;  $C1 - MID$(
		 FDB fnRIGHT			;  $C2 - RIGHT$(
		 FDB fnSTR			;  $C3 - STR$(
		 FDB fnSTRING			;  $C4 - STRING$(
		 FDB fnEOF			;  $C5 - EOF
		 FDB cmdAUTO			;  $C6 - AUTO
		 FDB cmdDELETE			;  $C7 - DELETE
		 FDB cmdLOAD			;  $C8 - LOAD
		 FDB cmdLIST			;  $C9 - LIST
		 FDB cmdNEW			;  $CA - NEW
		 FDB cmdOLD			;  $CB - OLD
		 FDB cmdRENUMBER		;  $CC - RENUMBER
		 FDB cmdSAVE			;  $CD - SAVE
		 FDB cmdEDIT			;  $CE - EDIT
		 FDB varSetPTR			;  $CF - PTR=
		 FDB varSetPAGE			;  $D0 - PAGE=
		 FDB varSetTIME			;  $D1 - TIME=
		 FDB varSetLOMEM		;  $D2 - LOMEM=
		 FDB varSetHIMEM		;  $D3 - HIMEM=
		 FDB cmdSOUND			;  $D4 - SOUND
		 FDB cmdBPUT			;  $D5 - BPUT
		 FDB cmdCALL			;  $D6 - CALL
		 FDB cmdCHAIN			;  $D7 - CHAIN
		 FDB cmdCLEAR			;  $D8 - CLEAR
		 FDB cmdCLOSE			;  $D9 - CLOSE
		 FDB cmdCLG			;  $DA - CLG
		 FDB cmdCLS			;  $DB - CLS
		 FDB cmdREM			;  $DC - DATA
		 FDB cmdREM			;  $DD - DEF
		 FDB cmdDIM			;  $DE - DIM
		 FDB cmdDRAW			;  $DF - DRAW
		 FDB cmdEND			;  $E0 - END
		 FDB cmdENDPROC			;  $E1 - ENDPROC
		 FDB cmdENVELOPE		;  $E2 - ENVELOPE
		 FDB cmdFOR			;  $E3 - FOR
		 FDB cmdGOSUB			;  $E4 - GOSUB
		 FDB cmdGOTO			;  $E5 - GOTO
		 FDB cmdGCOL			;  $E6 - GCOL
		 FDB cmdIF			;  $E7 - IF
		 FDB cmdINPUT			;  $E8 - INPUT
		 FDB cmdLET			;  $E9 - LET
		 FDB cmdLOCAL			;  $EA - LOCAL
		 FDB cmdMode			;  $EB - MODE
		 FDB cmdMOVE			;  $EC - MOVE
		 FDB cmdNEXT			;  $ED - NEXT
		 FDB cmdON			;  $EE - ON
		 FDB cmdVDU			;  $EF - VDU
		 FDB cmdPLOT			;  $F0 - PLOT
		 FDB cmdPRINT			;  $F1 - PRINT
		 FDB cmdPROC			;  $F2 - PROC
		 FDB cmdREAD			;  $F3 - READ
		 FDB cmdREM			;  $F4 - REM
		 FDB cmdREPEAT			;  $F5 - REPEAT
		 FDB cmdREPORT			;  $F6 - REPORT
		 FDB cmdRESTORE			;  $F7 - RESTORE
		 FDB cmdRETURN			;  $F8 - RETURN
		 FDB cmdRUN			;  $F9 - RUN
		 FDB cmdSTOP			;  $FA - STOP
		 FDB cmdCOLOUR			;  $FB - COLOUR
		 FDB cmdTRACE			;  $FC - TRACE
		 FDB cmdUNTIL			;  $FD - UNTIL
		 FDB cmdWIDTH			;  $FE - WIDTH
		 FDB cmdOSCLI			;  $FF - OSCLI

		 include "./assembler_share.asm"

	IF ASSEMBLER_6502
		include "./assembler6502.asm"
	ELSE
		include "./assembler6x09.asm"
	ENDIF

skipSpacesCheckHashAtY
		CALL	skipSpacesY
		CMPA	#'#'
		RTS		
skipSpacesCheckCommaAtY
		CALL	skipSpacesY
		CMPA	#','
		RTS

skipSpacesCheckCommaAtYStepBack
		CALL	skipSpacesCheckCommaAtY
2		BEQ	1F
		LEAU	-1,U
1		RTS		
skipSpacesCheckHashAtYStepBack
		CALL	skipSpacesCheckHashAtY
		BRA	2B

		; [ZP_GEN_PTR+2] <= A
		; ZP_NAMELENORVT <= Y (last character CONSUMED i.e. before what is to be kept)
		; Copy rest of line to ZP_GEN_PTR
		; return with count of chars after token including $0d in B
		; trashes A, X, Y
storeTokenAndCloseUpLine
		LDX	ZP_GEN_PTR+2
		STA	,X+
		CLRB
1		INCB
		LDA	,U+
		STA	,X+		
		CMPA	#$0D
		BNE	1B
		LDU	ZP_GEN_PTR+2
		LEAU	1,U
		RTS

;		CLC
;		TYA
;		ADC ZP_GEN_PTR
;		STA ZP_NAMELENORVT
;		LDU #$00
;		TYA
;		ADC ZP_GEN_PTR + 1
;		STA ZP_NAMELENORVT + 1

;L8CFA:
;		INY
;		LDA (ZP_NAMELENORVT),Y
;		STA (ZP_GEN_PTR),Y
;		CMP #$0D
;		BNE L8CFA
;		RTS

		; on entry A contains a numeric digit
		; parse number and store in ?????
		; TODO, there may be a quicker / smaller way of doing this
		; use shift and add instead of mul and add?
tokenizeLineNo	
		ANDA	#$0F
		STA	ZP_FPB + 3		; low byte
		CLR	ZP_FPB + 2		; convert '0'-'9' to 0-9 and store as 16bit at ZP_FPB + 2	

tokLinLp	LDA	,U+
		CALL	checkIsNumeric
		BCC	tokLineNoSk1
		ANDA	#$F
		STA	ZP_GEN_PTR+1
		CLR	ZP_GEN_PTR+0		; store as 16 bit no

		LDA	ZP_FPB + 3		; low byte * 10
		LDB	#10
		MUL				; this cannot overflow or go minus so don't panic!
		ADDD	ZP_GEN_PTR		; add to current digit
		BMI	tokLinOv		; overflowed
		STD	ZP_GEN_PTR		; store 
		
1		LDA	ZP_FPB + 2		; mul old number hi byte by 10
		LDB	#10
		MUL
		BCS	tokLinOv		; top bit of B
		TSTA				; or top byte of result
		BNE	tokLinOv		; causes overflow
		EXG	A,B			; now D = 256 * B 
2		ADDD	ZP_GEN_PTR
		STD	ZP_FPB + 2		; store result
		BPL	tokLinLp
tokLinOv
		SEC
		RTS				; unstack result
tokLineNoSk1					; found end of number
		LEAU	-1,U			; point at char after last read digit
		LDA	#tknLineNo
		CALL	storeTokenAndCloseUpLine	; B + ZP_GEN_PTR is end of line
		LDU	ZP_GEN_PTR+2
		LEAX	3,U				; make space for line number and length (3)
		STX	ZP_GEN_PTR+2
		INCB
		ABX
		CLRA					
		LEAU	D,U				; point at end of strings + 1
;L8D59:
1
		LDA	,-U			; move end of line on 3 bytes and leave gap for rest of tokenized number
		STA	,-X
		DECB
		BNE	1B
;L8D62: - when moving stuff to point here beware line number must be in ZP_FPB + 2,3 in bigendian, Y must point at byte before first of the three bytes
int16atZP_FPB2toBUFasTOKENIZED
		LDA	ZP_FPB + 2		; see p.40 of ROM UG (note diagram is wrong see text)
		ORA	#$40
		STA	3,U			; byte 3 = "01" & MSB[5 downto 0] 
		LDA	ZP_FPB + 3		; lsb
		ANDA	#$3F
		ORA	#$40
		STA	2,U			; byte 2 = "01" & MSB[5 downto 0] 

	IF CPU_6309
		AIM	#$C0,ZP_FPB + 3
	ELSE
		LDA	ZP_FPB + 3
		ANDA	#$C0		
		STA	ZP_FPB + 3		; mask off all but top two bits of LSB
	ENDIF

		LDA	ZP_FPB + 2
		ANDA	#$C0
		LSRA
		LSRA
		ORA	ZP_FPB + 3
		LSRA
		LSRA
		EORA	#$54
		STA	1,U			; byte 1 = "01" & MSB[7 downto 6] & LSB[7 downto 6] & "00"
		LEAU	4,U			; pointer after tokenized number
		CLC
		RTS

		; returns CY=1 if [_£a-zA-Z0-9]
checkIsValidVariableNameChar
		CMPA	#'z' + 1
		BCC	rtsL8D9A ; > z
		CMPA	#'_'
		BCC	setcarryRTS ; > ='_'
		CMPA	#'Z' + 1 
		BCC	rtsL8D9A ; > 'Z'
		CMPA	#'A'
		BCC	setcarryRTS

		; returns CY=1 if [0-9]
checkIsNumeric	CMPA	#'9' + 1			; not difference to 6502 compares! TODO - change api for fewer jumps?
		BCC	rtsL8D9A			; >'9'	
		CMPA	#'0'
		BCC	setcarryRTS
		CLC
rtsL8D9A	RTS

checkIsDotOrNumeric
		CMPA	#'.'
		BNE	checkIsNumeric
setcarryRTS	SEC
		RTS

;ZPPTR_GetCharIncPtr
;		LDA	[ZP_GEN_PTR]
;ZPPTR_Inc16						; incremenet ptr and save
;		LDX	ZP_GEN_PTR
;		LEAX	1,X
;		STX	ZP_GEN_PTR
;1		RTS			
;
;ZPPTR_IncThenGetNextChar
;		CALL	ZPPTR_Inc16
;		LDA	[ZP_GEN_PTR]
;		RTS


;			;  Tokenise line at $37/8

toklp0		;;LEAU	1,Y				;  Step past charac	ter

tokenizeATY
		STU	ZP_GEN_PTR+2			; where token will be stored
toklp2
		LDA	,U+				;  Get current character
		CMPA	#$0D
		BEQ	rtsL8DDF			;  Exit with <cr>
		CMPA	#' '
		BEQ	toklp0				;  Skip <spc>
		CMPA	#'&'
		BNE	tokNotAmper			;  Jump if not '&'
toklp1		LDA	,U+				;  Get next character, check if it looks like HEX
		CALL	checkIsNumeric			;  Is it a digit?
		BCS	toklp1				;  Loop back if a digit
		CMPA	#'A'
		BCC	toklp2				;  Loop back if <'A'
		CMPA	#'F' + 1
		BCC	toklp1				;  Step to next if 'A'..'F'
tokNotAmper	CMPA	#'"'
		BNE	tokNotQuot			;  Not quote,
tokQuotLp	LDA	,U+				;  Get next character
		CMPA	#'"'
		BEQ	toklp0				;  Jump back if closing quote
		CMPA	#$0D
		BNE	tokQuotLp			;  Loop until <cr> or quote
rtsL8DDF	RTS

tokNotQuot	CMPA	#':'
		BNE	tokNotColon
		
cmdAUTOtokenize	STU	ZP_GEN_PTR+2
		CLR	ZP_FPB				; start of statement - don't expect line num
L8DE9		CLR	ZP_FPB + 1			
		BRA	toklp2


tokNotColon
		CMPA	#','
		BEQ	toklp0				; if comma carry on
		CMPA	#'*'
		BNE	tokNotStar
		TST	ZP_FPB
		BEQ	rtsL8DDF			; if a * and ZP_FPB==0 return (OSCLI at start of stmt?)

tokNotKeyword	LDB	#$FF
		STB	ZP_FPB
		CLR	ZP_FPB + 1
		BRA	toklp0

tokNotStar	CMPA	#'.'
		BEQ	tokDot
		CALL	checkIsNumeric
		BCC	tokNotNum
		TST	ZP_FPB + 1
		BEQ	tokDot
		CALL	tokenizeLineNo
		BCC	toklp0

tokDot		LDA	,U+
		CALL	checkIsDotOrNumeric
		BCS	tokDot
tokNextSetFlag0_FF
		LEAU	-1,U
L8E1F
1		LDA	#$FF
		STA	ZP_FPB
		BRA	L8DE9

tokNotKey2					 ; is it a variable? if so skip over it...
		CALL	checkIsValidVariableNameChar
		BCC	tokNotKeyword
;L8E2A
tokNotKey_SkipVarName
		LDA	,U+
		CALL	checkIsValidVariableNameChar
		BCC	tokNextSetFlag0_FF
		BRA	tokNotKey_SkipVarName
tokNotNum
		CMPA	#'A'
		BLO	tokNotKeyword		; if <'A'
		CMPA	#'W'			
		BHI	tokNotKey2		; of >='X'
		LDX	#tblTOKENS
		LEAU	-1,U
		STU	ZP_GEN_PTR+2
tokKeyCmp
		LDU	ZP_GEN_PTR+2			; reset buffer pointer
;L8E46:
		LDA	,U+				; start again with first char in A
		CMPA	,X+				
		BLO	tokNotKey_SkipVarName		; < tok char lt treat as variable name TODO: we already skipped a lot of the variable but that get wasted here
		BNE	tokSkipEndTryNext
;L8E4E:
tokKeyCmpLp
		LDA	,X+
		BMI	tokKeyFound
		CMPA	,U+
		BEQ	tokKeyCmpLp
		LDA	-1,U
		CMPA	#'.'
		BEQ	tokKeyAbbrev

tokSkipEndTryNext					;L8E5D:
		LDA	,X+
		BPL	tokSkipEndTryNext
		CMPA	#tknWIDTH
		BNE	tokMoveNextTkn			; not the last one, increment pointer and carry on
		BRA	tokNotKey_SkipVarName		

tokKeyAbbrev						;L8E68:
tokKeyAbbrevLp1						;L8E69:
		LDA	,X+				; skip to end of keyword, increasing X
		BMI	tokKeyFound
		BRA	tokKeyAbbrevLp1
tokMoveNextTkn						;L8E75:
		LEAX	1,X				; move X past token and flags
							;L8E80: (not used was a skip for add hi byte)
		BRA	tokKeyCmp
tokKeyFound						;L8E84:
		TFR	A,B				; store token in B (TODO - use A and save a couple of swaps)
		LDA	,X				; get flags in A
		STA	ZP_FPB + 2			; store flags
		BITA	#TOK_FLAG_CONDITIONAL					
		BEQ	tokKeyFound2			; if flags[0]='0' we've got a full keyword
		LDA	,U				; if not check if next is a valid variable char
		CALL	checkIsValidVariableNameChar	
		BCS	tokNotKey_SkipVarName		; and we have a variable name char treat it as such and skip to
							; end of variable
tokKeyFound2						;L8E95
		LDA	ZP_FPB + 2
		BITA	#TOK_FLAG_PSEUDO_VAR
		BEQ	tokNOTPSEUDO
		TST	ZP_FPB
		BNE	tokNOTPSEUDO
		ADDB	#$40				; at start of line and a PSEUDO var then add $40 to token?!
tokNOTPSEUDO	;L8EA0
		TFR	B, A
		CALL	storeTokenAndCloseUpLine 	; attention check regs trashed
		LDA	ZP_FPB + 2
		BITA	#TOK_FLAG_NEXT_MID
		BEQ	tokNOTNEXTMID
		LDB	#$FF
		STB	ZP_FPB
		CLR	ZP_FPB + 1
tokNOTNEXTMID						;L8EB0:
		BITA	#TOK_FLAG_NEXT_START
		BEQ	tokNOTNEXTSTART
		CLR	ZP_FPB
		CLR	ZP_FPB + 1
tokNOTNEXTSTART						;L8EB7:
		BITA	#TOK_FLAG_FNPROC
		BEQ	tokSkipNotFNPROC
		LDU	ZP_GEN_PTR+2		
		LEAU	1,U
tokSkipPROCNAMElp					;L8EBD:					
		LDA	,U+
		CALL	checkIsValidVariableNameChar
		BCS	tokSkipPROCNAMElp
							;L8EC9:
		LEAU	-2,U
		STU	ZP_GEN_PTR+2			; now pointing at last char of name
		
tokSkipNotFNPROC			;L8ECA:
		LDA	ZP_FPB + 2
		BITA	#TOK_FLAG_NEXTLINENO
		BEQ	tokNotNEXTLINENO
		STB	ZP_FPB + 1			; FF
tokNotNEXTLINENO	;L8ECF:
		BITA	#TOK_FLAG_SKIP_EOL
		BNE	anRTS7
		JUMP	toklp0

;		
;		;  Skip spaces at PTRB
;		;  ===================
		;  leaves PTR unchanged returns next non white pointer + 1 in Y, char in A
skipSpacesPTRB
		LDU	ZP_TXTPTR2
skipSpacesY		   
		LDA	,U+
		CMPA	#' '
		BEQ	skipSpacesY
anRTS7		RTS

inySkipSpacesYStepBack
		LEAU	1,U
skipSpacesYStepBack
		CALL	skipSpacesY
		LEAU	-1,U
		RTS

;		
;		;  Skip spaces at PTRA
;		;  ===================
		;  leaves PTR unchanged returns next non white pointer + 1 in Y, char in A
skipSpacesPTRA
		LDU	ZP_TXTPTR
		BRA	skipSpacesY

;		
;			;  Expect comma
;			;  ============
skipSpacesCheckCommaAtYOrBRK
		CALL	skipSpacesCheckCommaAtY
		BEQ	anRTS7			;  Comma found, return
brkMissingComma
		DO_BRK_B
		FCB	$05, tknMissing, ',', 0
cmdCHAIN		; L8EFB

		CALL	loadProg2Page
		BRA	L8F15
cmdOLD			; L8F00
			;  OLD
		CALL	scanNextStmtFromY
		LDA	ZP_PAGE_H
		LDB	#1
		TFR	D,X
		CLR	,X
		CALL	findTOP
		BRA	resetVarsImmedPrompt
cmdRUN
			
;			;  RUN
		CALL	scanNextStmtFromY
L8F15
		CALL	ResetVars
		LDA	ZP_PAGE_H
		CLRB
		STD	ZP_TXTPTR
		BRA	runFromZP_TXTPTR
cmdLOAD
		CALL	loadProg2Page
		BRA	resetVarsImmedPrompt
cmdEND			; L8F25!
		CALL	scanNextStmtFromY
		CALL	findTOP
		BRA	immedPrompt



reset_prog_enter_immedprompt
		;TODO !!!!!!!!!!!!!!!!!!!!!!! FOR TESTING ONLY
*		LDD	#$00F2		; get bytes $f2,f3 from host proc (command pointer)
*		LBSR	retD16asUINT_LE
*		LBSR	callOSWORD5INT_WA
*		TFR	A,B
*		LBSR	callOSWORD5INT_WA
*		EXG	B,A		; little endian!
*		STD	ZP_INT_WA	; zp_int_wa points at end of command tail in host proc
*		LDB	#$14
*1		DECB
*		LBEQ	cmdNEW2
*		LBSR	callOSWORD5INT_WA
*		CMPA	#$0D
*		BEQ	cmdNEW2
*		CMPA	#'@'
*		BNE	1B
*		LBSR	callOSWORD5INT_WA
*		CMPA	#$0D		
*		BNE	cmdNEW2
		CALL	deleteProgSetTOP

		; dom bodge
		CLR	ZP_TRACE

		CALL	findTOP

1		LDU #BAS_InBuf
		STU ZP_TXTPTR
		BRA resetVarsImmedPrompt
;;2		LDA [ZP_LOMEM]
;;		BEQ resetVarsImmedPrompt
;;		STA ,Y+
;;		BEQ cmdNEW2
;;		INC ZP_LOMEM + 1
;;		BNE 1F
;;		INC ZP_LOMEM
;;1		CMPA #$0D
;;		BNE 2B
;;		LDA ZP_LOMEM
;;		CMPA ZP_HIMEM
;;		BCS resetVarsImmedPrompt
;;		CALL tokenizeAndStore
;;		BRA 1B
cmdNEW									;  NEW
		CALL	scanNextStmtFromY
cmdNEW2
		CALL	deleteProgSetTOP
resetVarsImmedPrompt
		CALL	ResetVars


immedPrompt	LDU	#BAS_InBuf
		STU	ZP_TXTPTR			;  PtrA = BAS_InBuf - input buffer
		CALL	ONERROROFF;			;  ON ERROR OFF
		LDA	#'>'
		JSR	OSWRCH			;  Print '>' prompt

		CALL	ReadKeysTo_InBuf			;  Read input to buffer at BAS_InBuf
		
runFromZP_TXTPTR						; L8F97
		RESET_MACH_STACK		
		CALL	ONERROROFF				;  Clear machine stack, ON ERROR OFF
		CALL	tokenizeAndStore
		BCS	resetVarsImmedPrompt			;  Tokenise, enter into program, loop back if program line
		JUMP	execImmediateLine			;  Jump to execute immediate line

doOSCLIAtY						      ; L8FA4
		LEAX	,U
		PSHS	U
		JSR	OSCLI
		PULS	U
;			;  DATA, DEF,	;
;			;  ==============
cmdREM
		LDA	#$0D
1							; L8FB3:
		CMPA	,U+
		BNE	1B				;  Loop until found <cr>
							;L8FB8:
		LEAU	-1,U
		STU	ZP_TXTPTR
		BRA	stepNextLineOrImmedPrompt	;  Update line pointer, step to next line
skipToNextLineOrImmedPrompt				; L8FBD
		CMPA	#$0D
		BNE	cmdREM				;  Step to end of line
stepNextLineOrImmedPrompt
		LDA	ZP_TXTPTR
		CMPA	#BAS_InBuf / 256
		BEQ	immedPrompt
		LDA	1,U				; if next line number top but end of prog
		BMI	immedPrompt
		LDA	ZP_TRACE
		BEQ	skNoTRACE
		LDD	1,U
		STD	ZP_INT_WA + 2
		CALL	doTRACE
skNoTRACE						;L8FDB:
		LEAU	4,U				; skip over $d,line num,len to first token
		STU	ZP_TXTPTR
		BRA	skipSpacesAtYexecImmed
enterAssembler						;L8FE1:
		LDA	#$03
		STA	ZP_OPT
		JUMP	assScanEnter			; enter assembler scanner, default OPT=3
scanTryStarAssEXTEq					; L8FEB
		LDA	-1,U
		CMPA	#'*'
		BEQ	doOSCLIAtY
		CMPA	#'['
		BEQ	enterAssembler
		CMPA	#tknEXT
		LBEQ	cmdEXTEq
		CMPA	#'='
		BEQ	cmdEquals
decYGoScanNextContinue					; L9000
		LEAU  -1,U
scanNextContinue					; L9002
		CALL	scanNextStmtFromY		;  Return to execution loop
continue						; L9005
		LDA   	,U
		CMPA	#':'
		BNE	skipToNextLineOrImmedPrompt
incYskipSpacesAtYexecImmed				; L900B		
		LEAU	1,U
skipSpacesAtYexecImmed					; L900D
		CALL	skipSpacesY
		CMPA	#':'		
		BEQ	skipSpacesAtYexecImmed		;  Skip spaces and ':'
		CMPA	#tknPTRc
		BLO	execTryVarAssign		;  Not command token, try variable assignment
;		
;			;  Dispatch function/command
;			;  -------------------------
exeTokenInA						;L9019:		TODO: move command table and make relative jump
		SUBA	#tknOPENIN			; first token
		TFR	A,B
		ASLB					; mul by two
		LDX	#tblCmdDispatch
		ABX
		JUMP	[,X]		;  Index into dispatch table and jump to routine
;		
;			;  Command entered at immediate prompt
;			;  -----------------------------------
execImmediateLine			;L901E:
		CALL	skipSpacesPTRA			;  Skip spaces at PtrA
		CMPA	#tknAUTO
		BHS	exeTokenInA			;  If command token, jump to execute command
			
;			;  Not command token, try variable assignment
execTryVarAssign					; L9025
		LEAX	-1,U
		STX	ZP_TXTPTR2
		CALL	findVarAtYMinus1
		BNE	assignVarAtZP_INT_WA		;  Look up variable, jump if exists to assign new value
		BCS	scanTryStarAssEXTEq				;  Invalid variable name, try =, [, *, EXT commands

;			;  Variable doesn't exist, create it
;			;  ---------------------------------
		CALL	skipToEqualsOrBRKY		; Check for and step past '='
		CALL	allocVAR			; Create new variable
		LDA	#$05				; Prepare B=5
		CMPA	ZP_INT_WA + 0			
		BNE	varAss_sk1
		INCA		;			;  Use X=6
varAss_sk1						;L9045
		CALL	AllocVarSpaceOnHeap		;  Allocate space for variable
		LDU	ZP_TXTPTR2
;			;  LET <var> = <expression>
;			;  ========================
cmdLET

		CALL	findVarOrAllocEmpty
		LBEQ	brkSyntax			; Find and create variable, error if invalid name
assignVarAtZP_INT_WA					; L904F		
		BCC	cmdSetVarNumeric		;  CC - jump to assign numeric value
		CALL	stackINT_WAasINT
		CALL	skipSpacesExpectEqEvalExp	;  Stack IntA, step past '=' and evaluate expression
		LDA	ZP_VARTYPE
		BNE	brkTypeMismatch			;  If not string, Type mismatch
		CALL	copyStringToVar
		BRA	continue			;  Copy string result to string variable, return to execution loop
;		
;		;  =<expression> - return from function
;		;  ====================================
cmdEquals
		CMPS	#MACH_STACK_TOP - 5
		BHS	brkNoFN			;  Stack empty, not in a function
		LDA	MACH_STACK_TOP - 3
		CMPA	#tknFN
		BNE	brkNoFN			;  No FN token, not in a function
		CALL	evalExpressionMAIN
		JUMP	scanNextStmtFromY			;  Evaluate expression, pop program pointer and continue execution


;			;  <numvar>=<numeric>
;			;  ------------------
cmdSetVarNumeric
		LDX	ZP_INT_WA + 2
		LDA	ZP_INT_WA + 0
		PSHS	A,X
		CALL	skipSpacesExpectEqEvalExp	;  Step past '=' and evalute expression
		CALL	storeEvaledExpressioninStackedVarPTr
		JUMP	continue			;  Copy numeric value to variable, return to execution loop


cmdSTOP

		CALL	scanNextStmtFromY		;  Check end of statement
		DO_BRK_B
		FCB	$00, tknSTOP, 0
brkNoFN
		DO_BRK_B
		FCB  $07, "No ", tknFN, 0
brkTypeMismatch
		DO_BRK_B
		FCB  $06, "Type mismatch", 0
brkNoRoom
		DO_BRK_B
		FCB  $00, "No room", 0
;		
;		;  Copy string value to string variable
;		;  ------------------------------------
copyStringToVar	CALL	popIntANew			;  Pop IntA which points to String Parameter Block
copyStringToVar2					; L90AE
		PSHS	U
		LDA	ZP_INT_WA + 0
		CMPA	#$80
		BEQ	indStringStore			;  Type = $80, $<addr>=<string>, jump to store directly
		LDU	ZP_INT_WA + 2
		LDA	2,U				;  Get maximum string size
		CMPA	ZP_STRBUFLEN
		BHS	L910E			;  Longer than string to store, so store it
		LDD	ZP_VARTOP
		STD	ZP_INT_WA + 2		;  Copy VARTOP to $2C/D as addr of new string block
		LDA	ZP_STRBUFLEN
		CMPA	#$08
		BLO	L90D0			; If new length<8, jump to use it
		ADDA	#$08			; else ADD 8 for luck!
		BCC	L90D0			; If new length<256, use it
		LDA	#$FF			; Otherwise, use 255 bytes
L90D0		PSHS	A			; Save string length to use
		LDX	,U			; get current string pointer
		LDB	2,U			; get current string space
		ABX
		CMPX	ZP_VARTOP
		BNE	L90EA			; if this isn't at the top of the heap then we need to make a new buffer
		
		;  The string's current string block is the last thing in the heap, so it can just be extended
		;  -------------------------------------------------------------------------------------------
		CLR	ZP_INT_WA + 2		; Set ZP_INT_WA + 2 to zero to not change string address later
		SUBA	2,U			; X=newstrlen - currstrlen = extra memory needed
L90EA		TFR	A,B			; B & A contain the ammount that VARTOP needs to be shifted by
		LDX	ZP_VARTOP
		ABX
		CMPX	ZP_BAS_SP
		BHS	brkNoRoom		;  Compare to STACKBOT, no room if new VARTOP>=STACKBOT
		STX	ZP_VARTOP		;  Store new VARTOP
		PULS	B
		STB	2,U			;  Get string length back and store it
		TST	ZP_INT_WA + 2
		BEQ	L910E			;  Get string address, jump if not moved
		LDX	ZP_INT_WA + 2
		STX	,U
L910E		LDB	ZP_STRBUFLEN		;  Get string length
		STB	3,U
		BEQ	L912B			;  Store string length, exit if zero length
		LDU	0,U
		STU	ZP_INT_WA + 2		; store new pointer
		LDX	#BAS_StrA
copystr600
1		LDA	,X+
		STA	,U+
		DECB
		BNE	1B
L912B		PULS	U,PC
;
;			;  Store fixed string at $<addr>
;			;  -----------------------------
indStringStore	CALL	str600CRterm			;  Store <cr> at end of string buffer
		LDU	ZP_INT_WA + 2
		INCB					; include terminating CR
		BRA	copystr600


cmdPRINT_HASH						; L9141
		CALL	decYSaveAndEvalHashChannelAPI
		PSHS	Y				; save Channel #
cmdPRINTHAS_lp		
		LDU	ZP_TXTPTR
		CALL	skipSpacesCheckCommaAtY
		BNE	cmdPRINTHASH_exit
		CALL	evalAtY
		STU	ZP_TXTPTR			; save BASIC test pointer
		LDY	,S				; channel
		LDA	ZP_VARTYPE			; var type, output to file
		JSR	OSBPUT
		TSTA
		BEQ	cmdPRINTHASH_STR
		BMI	cmdPRINTHASH_FP
		LDB	#$03
		LDX	#ZP_INT_WA
1		LDA	,X+				; not it's big endian in the file!
		JSR 	OSBPUT
		DECB
		BPL	1B
		BRA	cmdPRINTHAS_lp
cmdPRINTHASH_FP
		CALL	fpCopyFPA_FPTEMP1		; put eval'd FP at FPTEMP1 in 5 byte form 
		LDB	#$04
		LDX	#BASWKSP_FPTEMP1+5
1		LDA	,-X
		JSR	OSBPUT
		DECB
		BPL 	1B
		BRA	cmdPRINTHAS_lp
cmdPRINTHASH_STR
		LDA	ZP_STRBUFLEN
		JSR	OSBPUT
		LDB	ZP_STRBUFLEN
		LDX	#BAS_StrA
1		BEQ	cmdPRINTHAS_lp
		LDA	,X+
		JSR	OSBPUT
		DECB
		BRA	1B
cmdPRINTHASH_exit
		LEAS	2,S				; discard stacked channel
		LEAU	-1,U
		JUMP	scanNextContinue


;			;  PRINT (<print items>)
;			;  =====================
cmdPRINT
		CALL	skipSpacesCheckHashAtYStepBack
		BEQ	cmdPRINT_HASH			; Get next non-space char, if '#' jump to do PRINT#
		BRA	cmdPRINT_skStart		;  Jump into PRINT loop

cmdPRINT_setHexFlagFromCarry2
		SEC
		BRA	cmdPRINT_setHexFlagFromCarry

;			;  Print a comma
;			;  -------------
cmdPRINT_padToNextField					; L9196
		LDA	BASWKSP_INTVAR + 3		; get low byte of @%
		BEQ	cmdPRINT_skStart		;  If field width zero, no padding needed, jump back into main loop
		LDA	ZP_PRLINCOUNT			;  Get COUNT
cmdPRINT_padToNextField_lp				; L919D
		BEQ	cmdPRINT_skStart		;  Zero, just started a new line, no padding, jump back into main loop
		SUBA	BASWKSP_INTVAR + 3		;  Get COUNT-field width
		BCC	cmdPRINT_padToNextField_lp	;  Loop to reduce until (COUNT MOD fieldwidth)<0
		TFR	A,B				;  B=-number of spaces to get back to (COUNT MOD width)=zero
cmdPRINT_padToNextField_lp2				; L91A5
		CALL	list_print1Space
		INCB
		BNE	cmdPRINT_padToNextField_lp2	; Loop to print required spaces
cmdPRINT_skStart					; L91AB
		
		LDA	BASWKSP_INTVAR + 3		; Get @%
		STA	ZP_PRINTBYTES			; Set current field width from @%
		CLC					; Prepare to print decimal
cmdPRINT_setHexFlagFromCarry				; L91B1
		ROR	ZP_PRINTFLAG			; Set hex/dec flag from Carry
cmdPRINT_lp1						; L91B1
		CALL	skipSpacesY			; Get next non-space character
		CMPA	#':'
		BEQ	cmdPRINT_endcmd			; End of statement if <colon> found
		CMPA	#$0D
		BEQ	cmdPRINT_endcmd			; End if statement if <cr> found
		CMPA	#tknELSE
		BNE	cmdPRINT_sk0			; Not 'ELSE', jump to check this item

;			;  End of PRINT statement
;			;  ----------------------
cmdPRINT_endcmd						; L91C2
		CALL 	PrintCRclearPRLINCOUNT		; Output new line and set COUNT to zero
cmdPRINT_endcmd_noCR					; L91C5
		JUMP	decYGoScanNextContinue		; Check end of statement, return to execution loop
cmdPRINT_lp2_checkendcmd				; L91C8
		CLR	ZP_PRINTBYTES			;TODO: work out if BEQ->LBRA's below are better / shorter/faster than straight LBEQ's
		CLR	ZP_PRINTFLAG			;  Set current field to zero, hex/dec flag to decimal
		CALL	skipSpacesY			;  Get next non-space character
		CMPA	#':'
		BEQ	cmdPRINT_endcmd_noCR		;  <colon> found, finish printing
		CMPA	#$0D
		BEQ	cmdPRINT_endcmd_noCR		;  <cr> found, finish printing
		CMPA	#tknELSE
		BEQ	cmdPRINT_endcmd_noCR		;  'ELSE' found, finish printing

;			;  Otherwise, continue into main loop
cmdPRINT_sk0						; L91DB
		CMPA 	#'~'
		BEQ	cmdPRINT_setHexFlagFromCarry2	; Jump back to set hex/dec flag from Carry
		CMPA	#','
		BEQ 	cmdPRINT_padToNextField		; Jump to pad to next print field
		CMPA	#';'
		BEQ 	cmdPRINT_lp2_checkendcmd	; Jump to check for end of print statement
		CALL	cmdPRINT_checkaposTABSPC
		BCC	cmdPRINT_lp1			; Check for ' TAB SPC, if print token found return to outer main loop

;			;  All print formatting have been checked, so it now must be an expression
;			;  -----------------------------------------------------------------------
		LDD	ZP_PRINTBYTES			; TODO: assumes order ZP_PRINTBYTES precedes ZP_PRINTFLAG
;; removed;		LDB	ZP_PRINTFLAG
		PSHS	D
;			;  Save field width and flags, as evaluator
;			;   may call PRINT (eg FN, STR$, etc.)
		LEAU	-1,U
		CALL	evalAtY				; Evaluate expression
		PULS	D				; Restore field width and flags
		STD	ZP_PRINTBYTES
;; removed;		STB	ZP_PRINTFLAG
		TST	ZP_VARTYPE			; DB - was from Y
		BEQ	cmdPRINT_printString		; If type=0, jump to print string
		CALL	cmdPRINT_num2str		; Convert Numeric value to string
		LDA	ZP_PRINTBYTES			; Get current field width
		SUBA	ZP_STRBUFLEN			; A=width-stringlength
		BLS	cmdPRINT_printString		; length>=width - print it
		TFR	A,B				; B=number of spaces needed
cmdPRINT_padlp1						; L9211
		CALL	list_print1Space
		DECB
		BNE	cmdPRINT_padlp1			;  Loop to print required spaces

;			;  Print string in string buffer
;			;  -----------------------------
cmdPRINT_printString
		LDB	ZP_STRBUFLEN
		BEQ	cmdPRINT_lp1			; Null string, jump back to main loop
		LDX	#BAS_StrA
cmdPRINT_printString_lp					; L921D
		LDA 	,X+
		CALL	list_printANoEDIT		; Print the character from string buffer
		DECB
		BNE	cmdPRINT_printString_lp		;  Increment pointer, loop for full string
		BRA	cmdPRINT_lp1			;  Jump back to main loop


cmdPRINT_TAB_comma					; L922D
		LDA	ZP_INT_WA + 3			;  Save current value
		PSHS	A
		CALL	evalL1BracketAlreadyOpenConvert2INT	;  Evaluate next integer, check for closing bracket
		LDA	#$1F
		JSR	OSWRCH				;  VDU 31 - Set cursor position
		PULS	A				;  Get first parameter back
		JSR	OSWRCH				;  Send X parameter
		CALL	doVDUChar_fromWA3		;  Send Y parameter from integer accumulator
		BRA	rtsCLC_L926A

			;  Clear carry flag, Set PTR A offset = PTR B offset and exit
			;  PRINT TAB()
			;  -----------
cmdPRINT_TAB						; L9241
		CALL	evalAtYcheckTypeInAConvert2INT	; Get Integer result of expression
		CALL	skipSpacesCheckCommaAtY		; Get next non-space character, compare with ','
		BEQ	cmdPRINT_TAB_comma		; Comma, jump to TAB(x,y)
		CMPA	#')'				; Check for closing bracket
		LBNE	brkMissingComma			; Jump to give "Missing )" error
		LDA	ZP_INT_WA + 3			; Get value
		SUBA	ZP_PRLINCOUNT			; A=tab-COUNT
		BEQ	rtsCLC_L926A			; No spaces needed, jump to clear carry, update and return
		TFR	A,B				; B=number of spaces needed
		BCS	cmdPRINT_B_SPACESCLCRTS		; Output X number of spaces, clear carry, update and return
		CALL	PrintCRclearPRLINCOUNT		; Start new output line
		BRA	cmdPRINT_SPACESatZP_INT_WA_3	; Output ?2A number of spaces, clear carry, update and return

;			;  PRINT SPC()
;			;  -----------
cmdPRINT_SPC						; L925B
		CALL	evalLevel1checkTypeStoreAsINT	; Evaluate integer
cmdPRINT_SPACESatZP_INT_WA_3				; L925E
		LDB	ZP_INT_WA + 3			; Get returned value
		BEQ	rtsCLC_L926A			; If zero, clear carry, update and return
cmdPRINT_B_SPACESCLCRTS					; L9262
		CALL	list_printBSpaces		; Output X number of Spaces
		BRA	rtsCLC_L926A			; Clear carry, update and return

;			;  PRINT '
;			;  -------
cmdPRINT_CR					; L9267
			CALL PrintCRclearPRLINCOUNT			;  Output a new line
;			;  Clear carry, update and return
;			;  ------------------------------
rtsCLC_L926A		
		CLC
;		;;;; REMOVED	BRA copyTXTOFF2toTXTOFF			;  Update PTR A offset = PTR B offset and return
		RTS
;		
;	

;decYEvalForceINT
;		LEAU	-1,Y
evalForceINT
		CALL	evalExpressionMAIN
		CALL	checkTypeInAConvert2INT
copyTXTOFF2toTXTOFF
		STU	ZP_TXTPTR
		STU	ZP_TXTPTR2
		RTS

;			;  Check special print formatting ' TAB( SPC
;			;  -----------------------------------------
cmdPRINT_checkaposTABSPC				; L927A
;; REMOVED	;		LDX ZP_TXTPTR
;; REMOVED	;		STX ZP_TXTPTR2
;; REMOVED	;		LDX ZP_TXTPTR + 1
;; REMOVED	;		STX ZP_TXTPTR2 + 1
;; REMOVED	;		LDX ZP_TXTOFF
;; REMOVED	;		STX ZP_TXTOFF2
		CMPA	#'''
		BEQ	cmdPRINT_CR			;  Current char is "'", jump to print newline
		CMPA	#tknTAB
		BEQ	cmdPRINT_TAB			;  Current char 'TAB(', jump to do TAB()
		CMPA	#tknSPC
		BEQ	cmdPRINT_SPC			;  Current char 'SPC', jump to do SPC()
rtsSEC_L9292
		SEC					;  Flag 'not formatting token'
rtsL9293
		RTS
brkMissingQuote						; L9294
		DO_BRK_B
		FCB	$09, tknMissing, $22,
cmdINPUT_PRINT_prompt
		CALL	skipSpacesY
		CALL	cmdPRINT_checkaposTABSPC		
		BCC	rtsL9293			; 
		CMPA 	#'"'
		BNE	rtsSEC_L9292
2		LDA 	,U+
		CMPA	#$0D
		BEQ	brkMissingQuote
		CMPA	#'"'
		BNE	1F
		CMPA	,U				; double " 
		BNE	rtsCLC_L926A
		LEAU	1,U
1		CALL	list_printANoEDIT
		BRA	2B
cmdCALL			; L92BE!
		CALL	evalExpressionMAIN
		CALL	checkTypeInZP_VARTYPEConvert2INT
		CALL	stackINT_WAasINT
		CLR	BAS_StrA			; number of parameters
		LDX	#BAS_StrA+1
L92CC
		CALL	skipSpacesCheckCommaAtYStepBack
		BNE	L92F1
		STX	,--S
		CALL	findVarAtYSkipSpaces
		BEQ	L9301
		LDX	,S++
		LDD	ZP_INT_WA + 2		
		STD	,X++				; var ptr
		LDA	ZP_INT_WA + 0
		STA	,X+				; var type
		INC 	BAS_StrA
		BRA	L92CC
L92F1		CALL	scanNextStmtFromY
		CALL	popIntANew
		PSHS	U
		CALL	callusrSetRegsEnterCode
		PULS	U
		JUMP	continue
L9301
		LDX	,S++
		JUMP	brkNoSuchVar
callusrSetRegsEnterCode				; L9304
		PSHS	U
		LDA	$040C+3				; C% into carry
		LSRA
		LDA	$0404+3
		LDB	$0408+3
		LDX	$0460+2
		LDU	$0464+2
		JSR	[ZP_INT_WA + 2]
		PULS	U,PC
cmdDELETE

		CALL	skipSpacesDecodeLineNumberNewAPIbrkSyntax
		CALL	stackINT_WAasINT
		CALL	skipSpacesCheckCommaAtY
		LBNE	brkSyntax
		CALL	skipSpacesDecodeLineNumberNewAPIbrkSyntax
		CALL	scanNextStmtFromY
		LDD	ZP_INT_WA+2
		STD	ZP_NAMELENORVT
		CALL	popIntANew
L9337		CALL	findLineAndDelete  
		CALL	checkForESC
		CALL	inc_INT_WA
		LDD	ZP_NAMELENORVT
		CMPD	ZP_INT_WA+2
		BHS	L9337
		JUMP	resetVarsImmedPrompt
AUTO_RENUM_STARTSTEP_DEF1010				; L934D
		LDB	#$0A
		CALL	retB8asUINT			; default first param 10
		CALL	skipSpacesDecodeLineNumberNewAPI
		CALL	stackINT_WAasINT
		LDB	#$0A				; default second param 10
		CALL	retB8asUINT
		CALL	skipSpacesCheckCommaAtY
		BNE	L9370
		CALL	skipSpacesDecodeLineNumberNewAPI
		LDA	ZP_INT_WA + 2
		BNE	brkSilly
		LDA	ZP_INT_WA + 3
		BEQ	brkSilly
		JUMP	scanNextStmtFromY
L9370
		JUMP	scanNextExpectColonElseCR

		; DB: Instead of ZP pointers the 6809 routine uses:
		; X - points to "number pile" above TOP (was FPB)
		; U - points to program position (was ZP_GEN_PTR)

renResetPileAndProg				; L9373
		LDX	ZP_TOP
renResetProg					; L937B
		LDA	ZP_PAGE_H
		CLRB
		TFR	D,U
		RTS
cmdRENUMBER		; L9384!
			;  RENUMBER
		CALL	AUTO_RENUM_STARTSTEP_DEF1010
		LDX	#ZP_NAMELENORVT
		CALL	popIntAtXNew
		CALL	findTOP
		CALL	renResetPileAndProg
L9392
		LDD	1,U
		BMI	renPass2		; end of prog - skip to pass #2
		STD	,X++			; store in "PILE"
		CMPX 	ZP_HIMEM
		BHS	brkRENUMBERspace
		CALL	renSkipNextLine
		BRA	L9392
brkRENUMBERspace
		DO_BRK_B
		FCB  $00, tknRENUMBER, " space"
brkSilly
		DO_BRK_B
		FCB	$00, "Silly", 0

		; pass 2 through program - assign new program line numbers

renPass2					; L93C4
		CALL	renResetProg
L93C7		LDA	1,U
		BMI	renPass3		; check for EOP
		LDD	ZP_NAMELENORVT+2
		STD	1,U			; overwrite old line number
		ADDD	ZP_INT_WA+2		; increment line number
		ANDA	#$7F			; top bit clear
		STD	ZP_NAMELENORVT+2	; store it back
		CALL	renSkipNextLine
		BRA	L93C7

renPass3					; L93E7
		CALL	renResetProg
ren3LineLoop					; L93ED
		TST	1,U
		LBMI	resetVarsImmedPrompt	; check for EOP and skip to next pass
		LEAY	4,U			; point Y at line text data
		CLR	ZP_INT_WA		; clear state machine flags 
			; flags are 22 for skip quotes
ren3CharLoop					; L93F7
		LDA	,Y+
		TST	ZP_INT_WA		; test quotes flag
		BNE	ren3SkNotQuo
		CMPA	#tknLineNo
		BEQ	ren3LineNoFnd
		CMPA	#tknREM
		BEQ	ren3NextLine
ren3SkNotQuo					; L9405
		CMPA	#'"'
		BNE	ren3SkNotQuo2
		EORA	ZP_INT_WA
		STA	ZP_INT_WA
ren3SkNotQuo2
		CMPA	#$0D
		BNE	ren3CharLoop
ren3NextLine					; L9412
		CALL	renSkipNextLine
		BRA	ren3LineLoop

ren3LineNoFnd					; L941B
		PSHS	U,Y			; preserve line/char pointers
		LEAU	,Y			; we need to point U at byte after 8D
		CALL	decodeLineNumber	; ZP_INT_WA+2 now contains line number to update
		CALL	renResetPileAndProg

		; Pass 4 8D token found scan program and pile for new/old line number

ren4LineLoop					; L9421
		TST	1,U			; check for EOP
		BMI	ren4NotFound
		LDD	,X++			; get original line num from pile
		CMPD	ZP_INT_WA+2		; compare with 8D number
		BNE	ren4nomatch
		LDD	1,U			; get new line number as binary
		STD	ZP_FPB+2		; store in FPB+2
		LDU	,S			; get back the intra-line pointer from pass3
		LEAU	-1,U			; point back at 8D instruction
		CALL	int16atZP_FPB2toBUFasTOKENIZED	;store updated number back in program at 1,U and move U on
		PULS	Y,U			; get back our pointers
		BRA	ren3CharLoop
ren4nomatch
		CALL	renSkipNextLine
		BRA	ren4LineLoop
ren4NotFound					; L945C
		LEAX	str_failed_at,PCR
		JSR	PRSTRING
		PULS	U,Y
		LDD	1,U
		STD	ZP_INT_WA+2
		CLRA
		CALL	int16print_AnyLen
		CALL	PrintCRclearPRLINCOUNT
		BRA	ren3CharLoop		; do rest of original line in program

str_failed_at
		FCN "Failed at "


renSkipNextLine					; L947A
		; U pointing at start of line + 1 add length byte to U
		LDB	3,U
		CLRA
		LEAU	D,U
		RTS
;			;  AUTO [num[,num]]
;			;  ================
cmdAUTO			
		CALL	AUTO_RENUM_STARTSTEP_DEF1010
		LDA	ZP_INT_WA + 3
		PSHS	A				; stack the step
		CALL	popIntANew
L9492		CALL	stackINT_WAasINT
		CALL	int16print_fmt5
		CALL	ReadKeysTo_InBuf
		CALL	popIntANew
		LDU	#BAS_InBuf
		CALL	cmdAUTOtokenize		
		LDU	#BAS_InBuf
		CALL	tokenizeAndStoreAlreadyLineNoDecoded 
		CALL	ResetVars
		LDB	,S
		CLRA
		ADDD	ZP_INT_WA + 2
		STD	ZP_INT_WA + 2
		BPL	L9492
L94B6		JUMP	resetVarsImmedPrompt


;			;  DIM name - Reserve memory
;			;  -------------------------
cmdDIM_reserve_mem					; L94BC
		CALL	findVarOrAllocEmpty		;  Step back, find/create variable
		BEQ brkBadDIM
		BCS brkBadDIM				;  Error if string variable or bad variable name
		CALL pushVarPtrAndType			;  Push IntA - address of info block
		CALL evalAtYcheckTypeInAConvert2INT
		CALL inc_INT_WA				;  Evaluate integer, IntA=IntA+1 to count zeroth byte
		LDA ZP_INT_WA + 0
		ORA ZP_INT_WA + 1
		BNE brkBadDIM				;  Size>$FFFF or <0, error
;		CLC
;		LDA ZP_INT_WA
;		ADC ZP_VARTOP
;		TAY					;  XY=VARTOP+size
;		LDA ZP_INT_WA + 1
;		ADC ZP_VARTOP + 1
;		TAX
		LDD	ZP_INT_WA + 2
		ADDD	ZP_VARTOP
		CMPD	ZP_BAS_SP			; new vartop
		LBHS	brkDIMspace			; check room
		LDX	ZP_VARTOP
		STX	ZP_INT_WA + 2			; store org vartop as return value (top bytes already 0)
		STD	ZP_VARTOP
		LDA	#$40
		STA	ZP_VARTYPE			;  Type=Integer
		CALL storeEvaledExpressioninStackedVarPTr
		CALL copyTXTOFF2toTXTOFF			;  Set the variable, update PTRA
cmdDIM_more_dims_q					; L94FB
		CALL	skipSpacesCheckCommaAtYStepBack
		BEQ	cmdDIM				;  Next character is comma, do another DIM
		JUMP	scanNextContinue
;			;  Return to execution loop
		; multiply 15 bit contents of 2,S by 15 bits in D, return in D
		; uses ZP_INT_WA_C as scratch space
		;         a b === D
		;       x c d === [,S]
		;       =====
		;         bxd
		;  +    axd
		;  +    bxc
		;  +  axc
		;  ==========
		;     F F C   = bad DIM !
cmdDIM_mul_D_by_S					; L9503
		STD	ZP_INT_WA_C
		TSTA
		BEQ	1F
		TST	2,S
		BNE	brkBadDIM			; > &10000
		
1		LDA	3,S		; A = d
		MUL			; res = b * d
		TSTA
		BMI	brkBadDIM
		STD	ZP_INT_WA_C + 2

		LDA	ZP_INT_WA_C + 0 ; B = a
		LDB	3,S		; A = d
		MUL			
		TSTA
		BNE	brkBadDIM	; overflow
		CLC
		ADCB	ZP_INT_WA_C + 2
		BMI	brkBadDIM	; overflow
		BCS	brkBadDIM	; overflow
		STB	ZP_INT_WA_C + 2

		LDA	ZP_INT_WA_C + 1 ; B = b
		LDB	2,S		; A = c
		MUL			
		TSTA
		BNE	brkBadDIM	; overflow
		CLC
		ADCB	ZP_INT_WA_C + 2
		BMI	brkBadDIM	; overflow
		BCS	brkBadDIM	; overflow
		TFR	B,A
		LDB	ZP_INT_WA_C + 3
		RTS
		

brkBadDIM						; L952C
		DO_BRK_B
		fcb  $0A, "Bad ", tknDIM, 0

;			;  DIM
;			;  ===
cmdDIM
		CALL skipSpacesY
L9541
		LEAU	-2,U				; point 1 before variable name
		STU	ZP_GEN_PTR+2
		LDB	#$05
		STB	ZP_FPB + 4			; Real, 5 bytes needed
		CALL	fnProcScanYplus1varname; Check variable name
		CMPB	#1
		BEQ	brkBadDIM			; Bad name, jump to error
		CMPA	#'('
		BEQ	cmdDIM_realArray				; Real array
		CMPA	#'$'
		BEQ	cmdDIM_strArray			; String array
		CMPA	#'%'
		LBNE	cmdDIM_reserve_mem		; Not (, $, %, reserve memory
cmdDIM_strArray						; L9563
		DEC	ZP_FPB + 4			; String or Integer, 4 bytes needed
		INCB					; length += 1
		LDA	,X+				; Get ext character
		CMPA	#'('
		LBNE	cmdDIM_reserve_mem		; No '(', jump to reserve memory


;			;  Dimension an array
;			;  ------------------
cmdDIM_realArray					; L9570
		STX	ZP_TXTPTR
		INCB
		STB	ZP_NAMELENORVT
		CALL	findVarDynLL_NewAPI		;  Get variable address
		BNE	brkBadDIM
		CALL	allocVAR			;  Create new variable
		LDA	#1
		CALL	AllocVarSpaceOnHeap		;  Allocate space
		LDA	ZP_FPB + 4
		PSHS	A
		LDX	ZP_VARTOP
		LEAX	1,X				; leave room for 1 byte offset to first cell
		PSHS	X
		LDD	#1
		PSHS	D				; total cells accumulator on U stack

		LDU	ZP_TXTPTR

L9589		CALL	evalForceINT			;  Evaluate integer
		LDA	ZP_INT_WA + 2
		ANDA	#$C0
		ORA	ZP_INT_WA + 0
		ORA	ZP_INT_WA + 1
		BNE	brkBadDIM			;  Bad DIM

		LDD	ZP_INT_WA + 2			; current dimension
		CLC
		ADDD	#1				; increment
		LDX	2,S
		STD	,X++				; store at VARTOP...
		STX	2,S
1		CALL	cmdDIM_mul_D_by_S				;  Multiply [,S] by D return in D
		STD	,S
		CALL	skipSpacesCheckCommaAtY		;
		BEQ	L9589				;  Comma, another dimension
		CMPA	#')'
		LBNE	brkBadDIM			;  Not ')', error

;			;  Closing ')' found
;			;  -----------------
		; calculate 1 byte pointer to 1st cell
		TFR	X,D				; transfer X to D
		SUBD	ZP_VARTOP
		STB	[ZP_VARTOP]			; store before the indices

		; calculate the array size in bytes
		LDB	4,S				; get cell size back from stack
		CLRA
		CALL	cmdDIM_mul_D_by_S
		PSHS	D
		PSHS	X
		ADDD	,S++				; add cells byte count to X
		BCS	brkDIMspace			; > 64K
		CMPD	ZP_BAS_SP
		BHS	brkDIMspace			; new VARTOP >= U
		STD	ZP_VARTOP
		PULS	D				; get back byte count
		INCA					; increment hi byte of count so we can do BNE
1		CLR	,X+
		DECB
		BNE	1B
		DECA
		BNE	1B
		LEAS	5,S				; discard cell count and cell size from stack
		JUMP	cmdDIM_more_dims_q
;			;  Check if another dimension
brkDIMspace						; L9605
		DO_BRK_B
		FCB	$0B, tknDIM, " space", 0

;			;  Program environment commands
;			;  ============================
;			;  HIMEM=address - Set top of BASIC memory, clearing stack
;			;  -------------------------------------------------------
varSetHIMEM			; L960F!

			
			
		CALL	evalAssignEqInteger		;  Check for '=', evaluate integer
		LDX	ZP_INT_WA + 2
		STX	ZP_HIMEM
		STX	ZP_BAS_SP
		BRA	L963B_continue			;  Return to execution loop
;			;  LOMEM=address
;			;  -------------
varSetLOMEM			; L9620!
		CALL	evalAssignEqInteger		;  Check for '=', evaluate integer
		LDX	ZP_INT_WA + 2
		STX	ZP_LOMEM
		STX	ZP_VARTOP
		CALL	InittblFPRtnAddr		;  Clear dynamic variables
		BRA	L963B_continue;			;  Return to execution loop
;			;  PAGE=address - Set program start
;			;  --------------------------------
varSetPAGE			; L9634!
		CALL	evalAssignEqInteger		;  Check for '=', evaluate integer
		LDA	ZP_INT_WA + 2
		STA	ZP_PAGE_H			;  Set PAGE
L963B_continue
		JUMP	continue			;  Return to execution loop

;			;  CLEAR
;			;  -----
cmdCLEAR						; L963E

		CALL	scanNextStmtFromY	
		CALL	ResetVars			;  Check end of statement, clear variables
		BRA	L963B_continue;			;  Return to execution loop

;			;  TRACE [ON|OFFOFF|<linenum>]
;			;  ---------------------------
cmdTRACE

		CALL	skipSpacesDecodeLineNumberNewAPI
		BCS	L9656				;  TRACE linenum
		CMPA	#tknON
		BEQ	L9667				;  TRACE ON
		CMPA	#tknOFF
		BEQ	L9670				;  TRACE OFF
		CALL	evalForceINT			;  Evaluate integer
L9656		CALL	scanNextStmtFromY		;  Check end of statement
		LDD	ZP_INT_WA + 2
L965F		STD	ZP_MAXTRACLINE			;  Set TRACE <linenum>
		LDA	#$FF				;  Set TRACE ON
L9663		STA	ZP_TRACE
		JUMP	continue			;  Return to execution loop
L9667		LEAU	1,U
		CALL	scanNextStmtFromY		;  Check end of statement
		LDD	#$FFFF
		BRA	L965F				;  Jump to set TRACE $FFxx and TRACE ON
L9670		LEAU	1,U
		CALL	scanNextStmtFromY		;  Check end of statement
		CLRA
		CLRB
		BRA	L9663

	IF FLEX = 1
brkFlexNotImpl	DO_BRK_B
		FCB	$FE, "Not implemented in FLEX OS", 0
	ENDIF

			;  Jump to set TRACE OFF
			;  TIME=val, TIME$=s$ - set TIME or TIME$
			;  ======================================
varSetTIME			; L9679!

	IF FLEX = 1
		JUMP	brkFlexNotImpl
	ELSE			
		LDA	,U				;  Get next character
		CMPA	#'$'
		BEQ	varSetTime_Dollar		;  Jump for TIME$=
		CALL	evalAssignEqInteger
		CALL	SwapEndian
		CLR	ZP_INT_WA+5			;  Check for '=', evaluate integer, set byte 5 to zero
		LDX	#ZP_INT_WA
		LDA	#$02				;  A=2 for Write TIME
L968B
		JUMP	OSWORD_continue			;  Call OSWORD, return to execution loop
	ENDIF
;			;  TIME$=string
;			;  ------------
varSetTime_Dollar					; L968E
	IF FLEX = 1
		JUMP	brkFlexNotImpl
	ELSE
		LEAU	1,U				; skip '$'
		CALL	styZP_TXTPTR2_skipSpacesExectEqEvalExp
		LDA	ZP_VARTYPE
		LBNE	brkTypeMismatch			;  If not string, jump to Type mismatch
		LDA	#$0F				;  A = $0F for Write RTC
		LDB	ZP_STRBUFLEN
		LDX	#BASWKSP_STRING-1		;  Store string length as subfunction
		STB	,X				;  Point to StringBuf-1				; TODO: CHECK this overwrites &05FF!
		BRA 	L968B				;  Call OSWORD, return to execution loop
	ENDIF
evalstackStringExpectINTCloseBracket			; L96A4
		CALL	StackString
evalL1BracketAlreadyOpenConvert2INT				; L96A7
		CALL	evalL1BracketAlreadyOpen
		BRA	checkTypeInAConvert2INT
checkCommaThenEvalAtYcheckTypeInAConvert2INT		; L96AC
		CALL	skipSpacesCheckCommaAtYOrBRK

evalAtYcheckTypeInAConvert2INT				; L96AF
		CALL	evalAtY
		BRA	checkTypeInAConvert2INT

evalLevel1checkTypeStoreAsINT
		CALL	evalLevel1
		BRA	checkTypeInAConvert2INT
;			;  Evaluate =<integer>
;			;  ===================
evalAssignEqInteger					; L96B9
		CALL styZP_TXTPTR2_skipSpacesExectEqEvalExp			;  Check for '=', evaluate expression
checkTypeInZP_VARTYPEConvert2INT		; L96BC
		LDA ZP_VARTYPE			;  Get type and ensure is an integer
;		
;			;  Convert real to integer
;			;  -----------------------
			;  new API:
			;  expect type in A
			;  convert item to ZP_INT_WA
;; - REMOVE THIS fpTAYcheckTypeInAConvert2INT (expected type in A)
;; - REMOVE THIS fpcheckTypeInAConvert2INT (expected type in Y)
;;;		TAY					;  Copy type to Y to set flags
checkTypeInAConvert2INT
		TSTA
		LBEQ	brkTypeMismatch
		BPL	anRTS				;  If string, error; if already integer, return
		
fpReal2Int	
		CALL	fpAMant2Int			;  Convert real to integer
fpCopyAmant2intWA
		LDD	ZP_FPA + 3
		STD	ZP_INT_WA
		LDD	ZP_FPA + 5
		STD	ZP_INT_WA + 2
anRTS		RTS
;JUMPBrkTypeMismatch2:
;		JUMP brkTypeMismatch
;
evalLevel1ConvertReal
		CALL	 evalLevel1
checkTypeIntToReal
		TSTA
		LBEQ	 brkTypeMismatch
		BMI	anRTS
		JUMP	 IntToReal
;		
;		
cmdPROC

;;;			;  PROC
		STU	ZP_TXTPTR2
		LDA	#tknPROC
		CALL	doFNPROCcall

		CALL	scanNextStmtFromY
		JUMP	continue
L96FB
;;		LDU #$03
;;		LDA #$00
;;		STA (ZP_INT_WA),Y
		LDX	ZP_INT_WA + 2		; get var pointer
		CLR	2,X			; store 0 in top byte of next var pointer
		BRA	L971F
cmdLOCAL
		CMPS	#MACH_STACK_TOP - 5		; Check if stack is "empty"
		BHS	brkNotLOCAL
		CALL	findVarOrAllocEmpty
		BEQ	L972F
		CALL	localVarAtIntA
		TST	ZP_INT_WA
		BMI	L96FB
		CALL	pushVarPtrAndType
		CALL	varFALSE
		STA	ZP_VARTYPE
		CALL	storeEvaledExpressioninStackedVarPTr
L971F		INC	4, S			; DB inc SP + 6
;;		LDU	ZP_TXTOFF2
;;		STU	ZP_TXTOFF
		CALL	skipSpacesCheckCommaAtYStepBack
		BEQ	cmdLOCAL		
L972F		JUMP	scanNextContinue
brkNotLOCAL						; L9732
		DO_BRK_B
		FCB	$0C, "Not ", tknLOCAL, 0
brkBadMode						; L9739
		DO_BRK_B
		FCB	$19
		FCB	"Bad ", tknMODE, 0


cmdGCOL							; L9741
		CALL	evalForceINT
		LDA	ZP_INT_WA + 3
		PSHS	A
		CALL	checkCommaThenEvalAtYcheckTypeInAConvert2INT
		CALL	scanNextStmtFromY
		LDA	#$12
		JSR	OSWRCH
		PULS	A
		BRA	L979B
cmdCOLOUR
;			;  COLOUR
		CALL	evalForceINT
		CALL	scanNextStmtFromY
		LDA	#$11
		BRA	L979B
cmdMode			; L975F!

		CALL	evalForceINT
		CALL	scanNextStmtFromY
	IF FLEX != 1						; TODOFLEX - assuming that this either has no effect or we're on the TUBE?
		JSR	OSByte82
		LEAX	1,X
		BNE	L9797					; machine high order address != $FFFF, skip memory clash check
		LDX	ZP_BAS_SP
		CMPX	ZP_HIMEM				; check if basic stack is at HIMEM
		BNE	brkBadMode				; else "BAD MODE"
		LDX_B	ZP_INT_WA + 3				; mode # low byte as got by eval
		LDA	#$85
		JSR	OSBYTE					; get mode HIMEM address in X
		CMPX	ZP_VARTOP				; if below VARTOP
		BLO	brkBadMode				; "BAD MODE"
		STX	ZP_HIMEM
		STX	ZP_BAS_SP
L9797
	ENDIF
		CLR	ZP_PRLINCOUNT
		LDA	#$16
L979B
		JSR	OSWRCH
		LDA	ZP_INT_WA + 3		; not - got least sig byte
		BRA	OSWRCH_then_continue

cmdMOVE			; L97A2!
		LDA	#$04
		BRA	doMOVE_DRAW

cmdDRAW			; L97A6!
		LDA	#$05
doMOVE_DRAW						; fpFPAeq_sqr_FPA
		PSHS	A
		CALL	evalExpressionMAIN
		CALL	checkTypeInZP_VARTYPEConvert2INT
		BRA	doPLOT2

cmdPLOT
		CALL	evalForceINT
		LDA	ZP_INT_WA + 3
		PSHS	A				; push plot code
		CALL	checkCommaThenEvalAtYcheckTypeInAConvert2INT
doPLOT2							; L97BA
		CALL	stackINT_WAasINT
		CALL	checkCommaThenEvalAtYcheckTypeInAConvert2INT
		CALL	scanNextStmtFromY
		LDA	#$19
		JSR	OSWRCH
		PULS	A
		JSR	OSWRCH
		CALL	popIntAtZP_GEN_PTRNew
		LDA	ZP_GEN_PTR + 3
		JSR	OSWRCH
		LDA	ZP_GEN_PTR + 2
		JSR	OSWRCH
		CALL	doVDUChar_fromWA3
		LDA	ZP_INT_WA + 2
		BRA	OSWRCH_then_continue

;			;  CLG - Clear graphics window
;			;  ---------------------------
cmdCLG							; L97E0!
		CALL	scanNextStmtFromY		;  Check end of statement
		LDA	#$10
		BRA	OSWRCH_then_continue		;  Jump to do VDU 16

;			;  CLS - Clear text window
;			;  -----------------------
cmdCLS			; L97E7!
		CALL	scanNextStmtFromY		;  Check end of statement
		CLR	ZP_PRLINCOUNT
		LDA	#$0C				;  Clear COUNT, do VDU 12
OSWRCH_then_continue					; L97EE
		JSR OSWRCH				;Send to VDU
L97F1		JUMP continue				;Return to execution loop
cmdREPORT
		CALL	scanNextStmtFromY
		CALL	PrintCRclearPRLINCOUNT
		LDX	ZP_MOS_ERROR_PTR_QRY
		LEAX	1,X				; skip error number

cmdREPORTlp						;L97FC:
		LDA	,X+
		LBEQ	continue
		CALL	doListPrintTokenA
		BRA	cmdREPORTlp
doVDUChar_fromWA32				;L9808:
		LDA ZP_INT_WA + 2
		JSR OSWRCH
cmdVDU					       ; L980D!	      ;	 VDU
		CALL	skipSpacesY
1						;L9810:
		CMPA	#':'
		BEQ	skVDUend
		CMPA	#$0D
		BEQ	skVDUend
		CMPA	#tknELSE
		BEQ	skVDUend
		LEAU	-1,U
		CALL	evalForceINT
		CALL	doVDUChar_fromWA3
		CALL	skipSpacesCheckCommaAtY
		BEQ	cmdVDU
		CMPA	#';'
		BEQ	doVDUChar_fromWA32
		CMPA	#'|'
		BNE	1B
		LDA	#$00
		LDB	#$09
2					;L9835:
		JSR	OSWRCH
		DECB
		BNE	2B
		BRA	cmdVDU
skVDUend						;L983D
		JUMP	decYGoScanNextContinue
doVDUChar_fromWA3					;L9840:
		LDA	ZP_INT_WA + 3
		JMP	OSWRCH


allocFNPROC	PSHS	U
		LDU	ZP_GEN_PTR+2
		LDA	1,U				; get token

		LDB	#BASWKSP_DYNVAR_off_PROC	; set A to offset of var list in page 4
		CMPA	#tknPROC
		BEQ	__allocVARint
		LDB	#BASWKSP_DYNVAR_off_FN
		BRA	__allocVARint

		; Allocate a dynamic variable 
		; on entry ZP_GEN_PTR => variable name -1
		; ZP_NAMELENORVT contains the length of the variable name

allocVAR	PSHS	U
		LDU	ZP_GEN_PTR+2
		LDB	1,U
		ASLB				; get variable offset in page 4
__allocVARint
		LDA	#BASWKSP_INTVAR / 256
		TFR	D,U				; Y points at DYN var head
__allocVARint_lp1
		STU	ZP_INT_WA_C			; look for tail of the current list
		TST	0,U				; if high byte of next addr = 0 then at end of list
		BEQ	_allocVARint_sk1
		LDU	,U				; jump to next pointer
		BRA	__allocVARint_lp1@lp1
_allocVARint_sk1
		LDX	ZP_VARTOP
		STX	,U				; store pointer to next var block in old tail ptr
		CLR	,X+
		CLR	,X+
		LDB	#2				
		CMPB	ZP_NAMELENORVT			; equal to 2, don't store name
		BEQ	_allocVARint_sk2
		LDU	ZP_GEN_PTR+2
		LEAU	2,U
_allocVARint_lp2
		LDA	,U+
		STA	,X+
		INCB
		CMPB	ZP_NAMELENORVT
		BNE	_allocVARint_lp2
_allocVARint_sk2
		PULS	U,PC
;		
;		
;			;  Allocate space for variable at top of heap
;			;  ------------------------------------------
			; On entry B points after end of name (at 0 marker to be stored)
			;          A contains the number of bytes to store for end of name byte and variable
			; Trashes X  
AllocVarSpaceOnHeap					; L9883
		LDX	ZP_VARTOP
		ABX
allheap_lp1	CLR	,X+				;  (ZP_VARTOP)=>top of heap
		DECA
		BNE	allheap_lp1			;  Put terminating zero and empty parameter block
CheckVarFitsX						;L988B API change (Expected to add Y to ZP_VARTOP)
		CMPX	ZP_BAS_SP
		BLO	allheap_sk_ok
							;L989F:
		LDX	ZP_INT_WA_C			; Remove this variable from heap
		CLR	0,X
		CLR	1,X				; by removing link from previous variable
		JUMP	brkNoRoom			; Jump to No room error
allheap_sk_ok						;L98A8:
		STX	ZP_VARTOP			; Update VARTOP
anRTS10
		RTS
;
;

L98AB		CALL	AllocVarSpaceOnHeap		
		LDU	ZP_TXTPTR2
findVarOrAllocEmpty
		STU	ZP_TXTPTR2
		CALL	findVarAtYSkipSpaces
		BNE	anRTS6
		BCS	anRTS6
		LDU	ZP_TXTPTR2
		CALL	allocVAR
		LDA	#$05
		CMPA	ZP_INT_WA + 0
		BNE	L98AB
		INCA
		BRA	L98AB

findVARTreatAsMemoryAccess					;L98C1
		CMPA  #'!'
		BEQ   memacc32				; Jump to do !<addr>
		CMPA  #'$'
		BEQ   memaccStr				; Jump to do $<addr>
		EORA  #'?'
		BEQ   memacc8				; Jump to do ?<addr>
		LDA   #$00
		SEC				; Return EQ/CS for invalid name
anRTS6		RTS

memacc32						;L98D1:
		LDA	#VAR_TYPE_INT_LE		; Little-endian integer
memacc8							;L98D3:
		PSHS	A				; 0 for byte on entry unless fallen through from memacc32
		CALL	evalLevel1checkTypeStoreAsINT
		STU	ZP_TXTPTR2
		JUMP	popAasVarType
memaccStr						; L98DC
		CALL	evalLevel1checkTypeStoreAsINT
		LDA	ZP_INT_WA + 2			; if pointer at zero page fail with RANGE TODO: Is this valid on 6809?
		BEQ	brkRange
		STU	ZP_TXTPTR2
		LDA	#VAR_TYPE_STRING_STAT
		STA	ZP_INT_WA + 0
		SEC
		RTS
brkRange						;L98EB:
		DO_BRK_B
		FCB  $08, "$ range", 0

;			;  Find Variable
;			;  =============
;			;  On entry, PTRA (ZP_TXTPTR),ZP_TXTOFF=>variable name
;			;            'variable name' can be:
;			;            '?value' '!value' '$value' 'variable' 'variable?value' 'variable!value'
;			;  On exit,  ZP_INT_WA=>data
;			;	     ZP_INT_WA + 2  = type
;			;  EQ	CC	not found
			;  EQ	CS	invalid name
			;  NE	CS	found, dynamic string
			;  NE	CC	found other
;findVarAtPTRA
;		LDU	ZP_TXTPTR
;		STU	ZP_TXTPTR2
findVarLp1
findVarAtYSkipSpaces					; L9901;
		LDA	,U+
		CMPA	#' '
		BEQ	findVarLp1			; Skip spaces
findVarAtYMinus1						; L9909
;		LEAX	-1,Y				; TODO - tidy this up!
;		STX	ZP_TXTPTR2			; save pointer needed to try again in skfindVarDynamic
		CMPA	#'@'
		BLO	findVARTreatAsMemoryAccess	; <'@', not a variable, check for indirection
		CMPA	#'['
		BHS	skfindVarDynamic		; >'Z', look for dynamic variable
		ASLA
		ASLA
		STA	ZP_INT_WA + 3			; Multiply by 4 in case <uc>% variable
		LDA	0,U				; Get next character
		CMPA	#'%'
		BNE	skfindVarDynamic		; Not <uc>%, jump to look for dynamic variable
		LDA	#BASWKSP_INTVAR / 256
		STA	ZP_INT_WA + 2			; High byte of static variable address
;;		LDA	#VAR_TYPE_INT			; both == 4
		STA	ZP_INT_WA + 0			; Type=Integer
		LEAU	1,U
		LDA	,U				; Get next character
		CMPA	#'('				; check to see if it was an array access after all  
		BNE	findVarCheckForIndirectAfter
		LEAU	-1,U
;			;  Not <uc>%(, so jump to check <uc>%!n and <uc>%?n
;			;  Look for a dynamic variable
;			;  ---------------------------
skfindVarDynamic
		LDB	#$05
		STB	ZP_INT_WA + 0
;		LDU	ZP_TXTPTR2
		LEAX	-2,U
		STX	ZP_GEN_PTR+2			;  $37/8=>1 byte BEFORE start of variable name
		LDB	#1				; variable name length
;		LEAU	1,Y
		LDA	-1,U				; re-get first char
		CMPA	#'A'
		BHS	findVarDyn_sk2
		CMPA	#'0'
		BLO	findVarDyn_skEnd
		CMPA	#'9'+1
		BHS	findVarDyn_skEnd
findVarDyn_lp						; L9959
		INCB
		LDA	,U+
		CMPA	#'A'
		BHS	findVarDyn_sk2
		CMPA	#'0'
		BLO	findVarDyn_skEnd
		CMPA	#'9'+1
		BLO	findVarDyn_lp
		BRA	findVarDyn_skEnd
findVarDyn_sk2						; L996B
		CMPA	#'Z'+1
		BLO	findVarDyn_lp
		CMPA	#'_'
		BLO	findVarDyn_skEnd
		CMPA	#'z'+1
		BLO	findVarDyn_lp
findVarDyn_skEnd					; L9977
		CMPB	#$01				; B = len + 1
		BEQ	findVarDyn_skInvalid		; Checked length=1, invalid name, exit
		CMPA	#'$'
		BEQ	findVarDyn_gotDollar		; String variable
		CMPA	#'%'
		BNE	findVarDyn_skNotInt		; Not integer variable
		DEC	ZP_INT_WA + 0			; Set type=4 - Integer
		INCB
		LDA	,U+				; Get next character
findVarDyn_skNotInt					; L9989
		CMPA	#'('
		BEQ	findVarDyn_skArray		; Jump if array
		LEAU	-1,U
		CALL	findVarDynLL_NewAPI
		BEQ	findVarDyn_skNotFound		; Search for variable, exit if not found
findVarDyn_skGotArrayTryInd				; L9994
		LDA	,U				; Get next character
findVarCheckForIndirectAfter				; L9998
		CMPA	#'!'
		BEQ	findVarIndWord			; Jump for <var>!...
		EORA	#'?'
		BEQ	findVarIndByte			; Jump for <var>?...
		CLC
		STU	ZP_TXTPTR2			; Update PTRB offset
		;;LDA	#$FF
		RTS					; NE/CC = variable found
findVarDyn_skInvalid					; L99A6
		CLRA
		SEC
		RTS					; EQ/CS = invalid variable name
findVarDyn_skNotFound
		CLRA
		RTS					;  EQ/CC = valid name, not found

;		<var>!...
findVarIndWord						; L99AE:
		LDA	#VAR_TYPE_INT_LE
		;  <var>?...
findVarIndByte						;L99B0:
		PSHS	A
		CALL	GetVarValNewAPI
		CALL	checkTypeInAConvert2INT
		LDX	ZP_INT_WA + 2
		PSHS	X
		LEAU	1,U
		CALL	evalLevel1checkTypeStoreAsINT
		PULS	D
		ADDD	ZP_INT_WA + 2
		STD	ZP_INT_WA + 2				; add stacked and eval'd addresses
popAasVarType						      ;L99CE
		PULS	A
		STA	ZP_INT_WA + 0				;  Store returned type
		CLC
		LDA	#$FF
		RTS						NE/CC = variable found


;			;  array(
;			;  ------
findVarDyn_skArray
		CALL findVarDyn_Subscripts			;  get array element address
		BRA findVarDyn_skGotArrayTryInd			;  Check for array()!... and array()?...
findVarDyn_gotDollar
		DEC	ZP_INT_WA + 0	; set type to int? and return that 
		INCB
		LDA	,U+
		CMPA	#'('
		BEQ	findVarDyn_skArrayStr		; got an array
		LEAU	-1,U
		CALL	findVarDynLL_NewAPI
		BEQ	findVarDyn_skNotFound
findVarDyn_retDynStr					; L99EB
		STU	ZP_TXTPTR2
		LDA	#VAR_TYPE_STRING_DYN
		STA	ZP_INT_WA + 0
		SEC
		RTS
findVarDyn_skArrayStr					; L99F1
		CALL	findVarDyn_Subscripts
		BRA	findVarDyn_retDynStr
brkArray						; L99F6
		DO_BRK_B
		FCB	$0E, "Array", 0


			;  Process array dimensions
			;  ------------------------
			;  new API
			;  On entry,	B=1 + length of name
			;		[ZP_GEN_PTR+2]+1=>first character of name
			;		[ZP_INT_WA + 0]=type
			;  On exit,	ZP_INT_WA+2 and X => data block for cell
			;  ------------------------
			;  old API
			;  On entry,    [ZP_GEN_PTR],Y=>'('
			;		ZP_INT_WA + 2=type
			;  On exit,	ZP_INT_WA =>data block
			;
			;  DIM r(100)				r(37)=val	    ->	 r(37)
			;  DIM r(100,200)			r(37,50)=val	    ->	 r(37*100+50)
			;  DIM r(100,200,300)			r(37,50,25)=val	    ->	r((37*100+50)*200+25)
			;  DIM r(100,200,300,400)		r(37,50,25,17)=val  -> r(((37*100+50)*200+25)*300+17)
			;
findVarDyn_Subscripts					; L99FE
		INCB
;		INY					; Step past '('
		CALL findVarDynLL_NewAPI
		BEQ brkArray				; If not found, generate error
		LDB	ZP_INT_WA + 0

		LDA	,X+				; Get offset to data (number of dimensions)*2+1
		LSRA
		DECA
		PSHS	D,X				; push type and pointer to array data ()
		CLR	,-S
		CLR	,-S


		; stack now contains

		;	+4		pointer to DIM block
		;	+3		var type (size 4/5)
		;	+2		data offset (counter) i.e. n (not 2*n+1)
		;	+0		0 (accumulator for previous subscript calc)

		TST	2,S
		BEQ	findVarDyn_Subscripts_one
findVarDyn_Subscripts_lp
		BEQ	findVarDyn_Subscripts_last
		CALL	evalAtYcheckTypeInAConvert2INT	;  Evaluate integer expression
		LDB	,U+
		CMPB	#','
		BNE	brkArray			;  If not ',', error as must be some more dimensions
findVarDynCalc_one_subs
		LDX	4,S
		CALL	findVarDyn_SubsCheck
		LDD	,X++				; get current DIM subscript
		CALL	cmdDIM_mul_D_by_S		; multiply accumulator by row size
		ADDD	ZP_INT_WA + 2			; add current subscript
		BCS	brkSubscript
		BMI	brkSubscript
		STD	,S
		STX	4,S
		DEC	2,S				; decrement subscripts counter
		BPL	findVarDyn_Subscripts_lp
findVarDyn_SubsDone
		; we're done
		LDB	3,S				; cell data size
		STB	ZP_INT_WA + 0			; restore var type
		CLRA
		CALL	cmdDIM_mul_D_by_S		; multiply acc by size of cells for byte offset
		PSHS	X				; use X as base of cells
		ADDD	,S				; add cell byte offset
		LEAS	8,S				; unstack workspace
		STD	ZP_INT_WA + 2
		LDX	ZP_INT_WA + 2
		RTS


findVarDyn_Subscripts_last
		CALL	evalL1BracketAlreadyOpenConvert2INT	; final subscript
		BRA	findVarDynCalc_one_subs

findVarDyn_Subscripts_one
		CALL	evalL1BracketAlreadyOpenConvert2INT	; final subscript
		LDX	4,S
		CALL	findVarDyn_SubsCheck
		LDD	ZP_INT_WA + 2
		STD	,S
		LEAX	2,X
		BRA	findVarDyn_SubsDone

findVarDyn_SubsCheck
		LDA	ZP_INT_WA + 2
		ANDA	#$C0
		ORA	ZP_INT_WA + 0
		ORA	ZP_INT_WA + 1
		BNE	brkSubscript
		LDD	ZP_INT_WA + 2
		CMPD	,X				; check against subscript in var block
		BHS	brkSubscript
		RTS
brkSubscript
		DO_BRK_B
		FCB	$0F, "Subscript", 0

fnProcScanYplus1varname
		LDB	#$01
		* API:
		*	On Entry
		*		Y points at 1 before the string to be scanned
		*		B points at first char after ZP_GEN_PTR to be checked
		*	On Exit
		*		B index of char after last matching
		*		A contains unmatched char (may be "%","$","(")
		*		X points at char after last matching
		; scans chars that are allowed in variable names
fnProcScanYplusBvarname
		CLRA
		LEAX	D,U
1		
		LDA	,X+
		CMPA	#'0'
		BLO	L9B16
		CMPA	#'@'
		BHS	L9B0E
		CMPA	#'9'+1
		BHS	L9B16
		CMPB	#1	; don't allow numbers as char 1 (note when called with a FN/PROC B is 2 on entry!)
		BEQ	L9B16
L9B0A
		INCB
		BNE	1B
L9B0E
		CMPA	#'_'
		BHS	L9B17
		CMPA	#'Z'
		BLS	L9B0A
L9B16
		RTS
L9B17
		CMPA	#'z'
		BLS	L9B0A
		RTS
;		
;		
skipSpacesDecodeLineNumberNewAPIbrkSyntax
		CALL	skipSpacesDecodeLineNumberNewAPI
		BCC	brkSyntax
		RTS


		; API changed used to scan from ZP_TXTPTR now scan from Y
skipSpacesDecodeLineNumberNewAPI
		;		LDU	ZP_TXTPTR
		CALL	skipSpacesY
		CMPA	#tknLineNo
		BEQ	decodeLineNumber
		LEAU	-1,U
		STU	ZP_TXTPTR				;  Not line number, return CC
		CLC
		RTS
decodeLineNumber
		LDA	,U+
		ASLA
		ASLA
		TFR	A,B
		ANDA	#$C0
		EORA	,U+
		STA	ZP_INT_WA + 3
		TFR	B,A
		ASLA
		ASLA
		EORA	,U+
		STA	ZP_INT_WA + 2
		STU	ZP_TXTPTR
		SEC
		RTS
;			;  Line number, return CS
;			;  Expression Evaluator
;			;  ====================
;			;  ExpectEquals - evalute =<expr>
;			;  ------------------------------
styZP_TXTPTR2_skipSpacesExectEqEvalExp
		STU	ZP_TXTPTR2
;;		LDA ZP_TXTPTR
;;		STA ZP_TXTPTR2
;;		LDA ZP_TXTPTR + 1
;;		STA ZP_TXTPTR2 + 1
;;		LDA ZP_TXTOFF
;;		STA ZP_TXTOFF2
skipSpacesExpectEqEvalExp				; L9B52
		CALL	skipSpacesPTRB			;  Skip spaces
		CMPA	#'='
		BEQ	evalAtYExpectColonElseCRThenRTS	;  '=' found, evaluate following expression
brkMistake
		DO_BRK_B
		FCB  $04
		FCB  "Mistake", 0
brkSyntax
		DO_BRK_B
		FCB  $10
		FCB  "Syntax error", 0
brkNoPROC
		DO_BRK_B
		FCB  $0D
		FCB  "No ", tknPROC, 0
errEscape
		DO_BRK_B
		FCB  $11
		FCB  "Escape", 0
		
;		
;		
skipToEqualsOrBRKY
		CALL	skipSpacesY
		CMPA	#'='
		BNE	brkMistake
		RTS
evalAtYExpectColonElseCRThenRTS				; L9B8E
		CALL	evalAtY
		BRA	scanNextStmtFromY
LDUZP_TXTPTR2scanNextStmtFromY				; L9B96
		LDU	ZP_TXTPTR2			; restore Y from ZP_TXTPTR2 - eg after FN/PROCcall
		BRA	scanNextStmtFromY

;		;  ENDPROC
;		;  =======
cmdENDPROC
		CMPS	#MACH_STACK_TOP - 5
		BHS	brkNoPROC			; Stack too empty, not in a PROC
		LDA	MACH_STACK_TOP - 3		; the PROC/FN token on the stack (below pushed Y)
		CMPA	#tknPROC
		BNE	brkNoPROC			; No PROC on the stack
							; drop through to an RTS
;scanNextStmt	LDU ZP_TXTPTR	 -- obsolete?
scanNextStmtFromY
		CALL	skipSpacesYStepBack
scanNextExpectColonElseCR
		CMPA	#':'
		BEQ	1F					;  colon, end of statement
		CMPA	#$0D
		BEQ	1F					;  <cr>, end of statement
		CMPA	#tknELSE
		BNE	brkSyntax				;  Not correctly terminated, error
1
storeYasTXTPTR	STU	ZP_TXTPTR
checkForESC	
		TST	[ZP_ESCPTR]
		BMI	errEscape				;  Escape set, give Escape error
anRTS9		RTS

;
;
scanNextStmtAndTrace						; L9BCF
		CALL	scanNextStmtFromY
		LDA	,U+
		CMPA	#':'
		BEQ	anRTS9
		TFR	U,D
		CMPA	#BAS_InBuf
		LBEQ	immedPrompt
doTraceOrEndAtELSE						; L9BDE
		LDD	,U
		LBMI	immedPrompt				; is end of program?
		TST	ZP_TRACE				; got here it must be an 0d?
		BEQ	skNoTrace
		STD	ZP_INT_WA + 2				; store line # (big endian in ZP_INT_WA)
		CALL	doTRACE
skNoTrace							;L9BF2:
								;L9BF4: -- check API
		LEAU	3,U					; skip to next token (after line number)
								;L9BFD: -- check API
L9C01rts
		RTS
cmdIF			; L9C08
		CALL	evalExpressionMAIN
		LBEQ	brkTypeMismatch
		BPL	skCmdIfNotReal
		CALL	fpReal2Int
skCmdIfNotReal						; L9C12:
		CALL	IntWAZero
		BEQ	skCmdIFFALSE
		CMPB	#tknTHEN
		BEQ	skCmdIfTHEN
		JUMP	skipSpacesAtYexecImmed
skCmdIfTHEN						; L9C27:
		LEAU	1,U				; skip THEN token
execTHENorELSEimpicitGOTO				; L9C29	
		CALL	skipSpacesDecodeLineNumberNewAPI; look for line number
		LBCC	skipSpacesAtYexecImmed		; if not found exec after THEN/ELSE
		CALL	findProgLineOrBRK
		CALL 	checkForESC
		JUMP	cmdGOTODecodedLineNumber
skCmdIFFALSE						; L9C37
							; L9C39
		LDA 	,U+				; look for ELSE, if not found exec as next line
		CMPA	#tknELSE
		BEQ	execTHENorELSEimpicitGOTO
		CMPA	#$0D
		BNE	skCmdIFFALSE
		LEAU	-1,U
		JUMP	stepNextLineOrImmedPrompt
doTRACE						; L9C4B

		; line number is now in WA+2 - this needs changed

		LDD	ZP_INT_WA + 2
		CMPD	ZP_MAXTRACLINE
		BHS	L9C01rts
		LDA	#'['
		CALL	list_printANoEDIT
		CALL	int16print_AnyLen

		LDA	#']'
		CALL	list_printANoEDIT
		JUMP	list_print1Space

evalDoComparePopIntFromMachineStackConvertToRealAndCompare
		PULS	D,X		; get back stacked int
		STX	ZP_INT_WA
		STD	ZP_INT_WA + 2
		CALL	fpStackWAtoStackReal		; stack LHS real
		CALL	IntToReal			; convert INT_WA to real in FPA
		CALL	fpCopyFPAtoFPB			; copy it to FPB
		CALL	popFPandSetPTR1toStack
		CALL	fpCopyPTR1toFPA		; get back stacked LHS real
		CALL	evalDoCompareRealFPAwithFPB	; compare
		PULS	B,PC				; get back stored token and finish
;			;  <real> <compare> ...
;			;  --------------------

		; API CHANGE - alter return CC to match behaviour of 6809
evalDoCompareReal			      ;L9C82
		CALL	fpStackWAtoStackReal
		CALL	evalLevel4
		PSHS	B				; save B (next char)
		CALL	checkTypeIntToReal
		CALL	popFPandSetPTR1toStack
		CALL	evalDoCompareRealFPAwithPTR1
		PULS	B,PC

evalDoCompareRealFPAwithPTR1				; L9C8F
		CALL	fpMoveRealAtPTR1toFPB
evalDoCompareRealFPAwithFPB				; L9C92
		LDA	#$80
		ANDA	ZP_FPB
		STA	ZP_FPB			; make FPB sign bit top bit only
		LDA	ZP_FPA
		ANDA	#$80				; same with FPA
		CMPA	ZP_FPB			; compare
		BNE	L9CBE
		LDA	ZP_FPB + 1
		CMPA	ZP_FPA + 2			;compare exponent
		BNE	L9CBF				;if not equal return C,Z as is
		LDD	ZP_FPB + 2			;otherwise compare matissa and swap C depeding on sign if NE
		CMPD	ZP_FPA + 3
		BNE	L9CBF
		LDD	ZP_FPB + 4
		CMPD	ZP_FPA + 5
		BNE	L9CBF
L9CBE
		RTS
L9CBF
		RORA					; C into top bit of A
		EORA	ZP_FPB			; if -ve swap
		ROLA					; put it back
		LDA	#$01				; return NE, C
		RTS
L9CC6brkTypeMismatch					; L9CC9:
		JUMP brkTypeMismatch
;;evalDoCompareTypeInB					 			; TODO: can be deleted?
;;		TFR	B,A				;  Pass type to A

		; API CHANGE - alter return CC to match behaviour of 6809, trashes B,X
evalDoCompare						; L9CCA
		TSTA
		BEQ	evalDoCompareString		;  type=0, compare strings
		BMI	evalDoCompareReal		;  type<0, compare reals
		LDX	ZP_INT_WA			; note reverse order with least sig 
		LDD	ZP_INT_WA + 2			; bytes pulled first! this meakes thing simpler below
		LEAS	-1,S				; reserving some stack space for storing after EVAL
		PSHS	D,X				;  stack current int 
		CALL	evalLevel4			;  Call Evaluator Level 4 - +, -
		STB	4,S				; store B in reserved stack space
		TSTA
		BEQ	 L9CC6brkTypeMismatch;		;  <int> <compare> <string> - Type mismatch
		BMI	 evalDoComparePopIntFromMachineStackConvertToRealAndCompare	;  <int> <compare> <real> - convert and compare

	IF CPU_6309
		EIM	#$80,ZP_INT_WA
	ELSE

		LDA	 ZP_INT_WA + 0
		EORA	 #$80
		STA	 ZP_INT_WA + 0			; swap RHS sign bit
	ENDIF
					;  Compare current integer with stacked integer
		PULS	D
		SUBD	ZP_INT_WA + 2
		STD	ZP_INT_WA + 2	; subtract least sig
		PULS	D
		SBCB	ZP_INT_WA + 1
		STB	ZP_INT_WA + 1
		EORA	#$80
		SBCA	ZP_INT_WA + 0	; subtract most sig
		ORA	ZP_INT_WA + 1
		ORA	ZP_INT_WA + 2
		ORA	ZP_INT_WA + 3	; set Z if all 0
		PULS	B,PC

		; API CHANGE - alter return CC to match behaviour of 6809
evalDoCompareString ; 				       ; L9D02
		CALL	StackString
		CALL	evalLevel4
		PSHS	B,U
		TSTA
		BNE	L9CC6brkTypeMismatch
		LDX	ZP_BAS_SP
		LDB	0,X				; get stacked string length
		CMPB	ZP_STRBUFLEN			; get shortest length in ZP_GEN_PTR
		BLS	L9D13
		LDB	ZP_STRBUFLEN
L9D13
		STB	ZP_NAMELENORVT
		CLRB
		LEAX	1,X				; point X at 1st byte of stacked string
		LDU	#BASWKSP_STRING			; point Y at LHS string
L9D15
		CMPB	ZP_NAMELENORVT			; compare strings
		BEQ	L9D23
		INCB
		LDA	,X+
		CMPA	,U+
		BEQ	L9D15
		BRA	L9D27
L9D23
		LDA	[ZP_BAS_SP]			; if we got here the strings matched
		CMPA	ZP_STRBUFLEN			; so compare lengths instead
L9D27
		PSHS	CC
		CALL	unstackString
		PULS	CC,B,U,PC
;			; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;			; ;;									   ;;
;			; ;; EXPRESSION EVALUATOR						   ;;
;			; ;; --------------------						   ;;
;			; ;; Recursively calls seven expression levels, evaluating expressions at  ;;
;			; ;; each level, looping within each level until all operators at that	   ;;
;			; ;; level are exhausted.						   ;;
;			; ;;									   ;;
;			; ;; On entry, Y=>start of expression to evaluate			   ;;
;			; ;; On exit,  Y=>first character after evaluated expression		   ;;
;			; ;;	       $2A/B/C/D = returned value				   ;;
;			; ;;	       A,ZP_VARTYPE=type					   ;;
;			; ;;		 ZP_FPB + 5 - integer				   ;;
;			; ;;									   ;;
;			; ;; Within the evaluator, B=next character, A=current type		   ;;
;			; ;; X trampled								   ;;
;			; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			; internally changed so that next token is in B instead of X
evalExpressionMAIN
;		LDA ZP_TXTPTR
;		STA ZP_TXTPTR2
;		LDA ZP_TXTPTR + 1
;		STA ZP_TXTPTR2 + 1
;		LDA ZP_TXTOFF
;		STA ZP_TXTOFF2

;			;  Evaluator Level 7 - OR, EOR
;			;  ===========================
evalAtY		CALL	 evalLevel6			;  Call Level 6 Evaluator - AND
evalLevel7lp0
		CMPB	 #tknOR
		BEQ	 evalLevel7OR			;  Jump to do OR
		CMPB	 #tknEOR
		BEQ	 evalLevel7EOR			;  Jump to do EOR
		STA	 ZP_VARTYPE
		LEAU	 -1,U
		RTS					;  Store type in ZP_VARTYPE and return
;			;  OR <numeric>
;			;  ------------
evalLevel7OR						; L9D4C
		CALL	INTevalLevel6
		CALL	checkTypeInAConvert2INT		;  Stack integer, call Level 6 Evaluator, ensure integer
		PSHS	B
		LDX	ZP_BAS_SP
		LDD	0,X
	IF CPU_6309
		ORD	ZP_INT_WA+0
	ELSE
		ORA	ZP_INT_WA+0
		ORB	ZP_INT_WA+1
	ENDIF
		STD	ZP_INT_WA
		LDD	2,X
	IF CPU_6309
		ORD	ZP_INT_WA+2
	ELSE
		ORA	ZP_INT_WA+2
		ORB	ZP_INT_WA+3
	ENDIF
		STD	ZP_INT_WA+2
evalL7unstackreturnInt_evalL7lp0			; L9D5F
		LEAX	4,X				;  Drop integer from stack
		STX	ZP_BAS_SP
		LDA	#$40
		PULS	B
		BRA	evalLevel7lp0			;  Integer result, jump to check for more OR/EORs
;			;  EOR <numeric>
;			;  -------------
evalLevel7EOR						; L9D4C
		CALL	INTevalLevel6
		CALL	checkTypeInAConvert2INT		;  Stack integer, call Level 6 Evaluator, ensure integer
		PSHS	B
		LDX	ZP_BAS_SP
		LDD	0,X
	IF CPU_6309
		EORD	ZP_INT_WA+0
	ELSE
		EORA	ZP_INT_WA+0
		EORB	ZP_INT_WA+1
	ENDIF
		STD	ZP_INT_WA
		LDD	2,X
	IF CPU_6309
		EORD	ZP_INT_WA+2
	ELSE
		EORA	ZP_INT_WA+2
		EORB	ZP_INT_WA+3
	ENDIF
		STD	ZP_INT_WA+2
		BRA	evalL7unstackreturnInt_evalL7lp0;  Jump to drop integer from stack and loop for more OR/EORs

;			
;			;  Integer Evaluate Level 6 - xxx OR/EOR yyy
;			;  =========================================
INTevalLevel6						; L9D7B
		CALL   checkTypeInAConvert2INT
		CALL   stackINT_WAasINT			;  Ensure number is integer and push onto stack

;			;  Evaluator Level 6 - AND
;			;  =======================
evalLevel6						; L9D81	
		CALL	evalLevel5			;  Call Evaluator Level 5 - < <= = >= > <>
evalLevel6Lp0						; ;L9D84:		
		CMPB	#tknAND
		BEQ	evalDoAND			;  Jump to do AND
		RTS
;			;  AND <numeric>
;			;  -------------
evalDoAND						; L9D89
		CALL	 checkTypeInAConvert2INT
		CALL	 stackINT_WAasINT		 ;  Ensure number is integer and push onto stack
		CALL	evalLevel5
		CALL	checkTypeInAConvert2INT		;  Call Evaluator Level 5, ensure integer

		PSHS	B
		LDX	ZP_BAS_SP
		LDD	0,X
	IF CPU_6309
		ANDD	ZP_INT_WA+0
	ELSE
		ANDA	ZP_INT_WA+0
		ANDB	ZP_INT_WA+1
	ENDIF
		STD	ZP_INT_WA
		LDD	2,X
	IF CPU_6309
		ANDD	ZP_INT_WA+2
	ELSE
		ANDA	ZP_INT_WA+2
		ANDB	ZP_INT_WA+3
	ENDIF
		STD	ZP_INT_WA+2
		LEAX	4,X				;  Drop integer from stack
		STX	ZP_BAS_SP
		LDA	#$40
		PULS	B
		BRA	evalLevel6Lp0			;  Loop to check for more ANDs

;		; Evaluator Level 5 - < <= = >= > <>
;		; ==================================
evalLevel5	CALL	evalLevel4			;  Call Evaluator Level 4 - +, -
		CMPB	#'>'
		BHI	eval5rts			;  Not <,=,>, exit
		CMPB	#'<'
		BHS	evalComparison		;  <,=,>, evaluate comparison
eval5rts	RTS
;			;  <expression> <comparison> <expression>
;			;  --------------------------------------
evalComparison
		BEQ	evalCompLt1			;  '<' - check for <, <=, <>
		CMPB	#'>'
		BEQ	evalComplGt1			;  '>' - check for >, >=
		CALL	evalDoCompare			;  Must be '=', pass type to A, compare expressions
		BNE	evalCompRetFALSE		;  LHS<>RHS, jump to return 0
evalCompRetTRUE					;  L9DC1
		LDX    #$FFFF			;  LHS=RHS, Y = $FF to return -1
		BRA    1F
evalCompRetFALSE				; L9DC2
		LDX    #0
1		STX ZP_INT_WA
		STX ZP_INT_WA + 2
		LDA #$40
		RTS
;			;  Return integer
;			;  <, <=, <>
;			;  ---------
evalCompLt1					;L9DCD:
		LDB	,U+			;  Get next character
		CMPB	#'='
		BEQ	evalCompLtEq1		;  Jump with <=
		CMPB	#'>'
		BEQ	evalComplNE		;  Jump with <>
;			;  Compare <
;			;  ---------
		LEAU	-1,U
		CALL	evalDoCompare			;  Must be <, compare expressions
		BLO	evalCompRetTRUE
		BRA	evalCompRetFALSE		;  < - TRUE, >= - FALSE
;		
;			;  Compare <=
;			;  ----------
evalCompLtEq1					;L9DE1:
		
		CALL	evalDoCompare		;  Step past character, compare expressions
		BLS	evalCompRetTRUE		;  < or = - TRUE
		BRA	evalCompRetFALSE

;			;  > - FALSE
;			;  Compare <>
;			;  ----------
evalComplNE					;L9DEC:
		CALL	evalDoCompare		;  Step past character, compare expressions
		BNE	evalCompRetTRUE
		BRA	evalCompRetFALSE

;			;  <> - TRUE, = - FALSE
;			;  > or >=
;			;  -------
evalComplGt1					  ;L9DF5:
		LDB    ,U+			;  Get next character
		CMPB   #'='
		BEQ    evalCompGE1		;  Jump with >=
		LEAU	-1,U
;			;  Compare >
;			;  ---------
		CALL	evalDoCompare			;  Must be >, compare expressions
		BHI	evalCompRetTRUE			;  = - FALSE, > - TRUE
		BRA	evalCompRetFALSE
;			;  < - FALSE
;			;  Compare >=
;			;  ----------
evalCompGE1			;L9E07:
		CALL	evalDoCompare			;  Step past character, compare expressions
		BHS	evalCompRetTRUE
		BRA	evalCompRetFALSE		;  >= - TRUE, < - FALSE
brkStringTooLong
		DO_BRK_B
		FCB	$13, "String too long", 0
evalL4StringPlus					; L9E22
		CALL	StackString			; stack current
		CALL	evalLevel2			; eval next phrase
		PSHS	B,U				; B contains next token
		TSTA					; if not a string
		LBNE	__skbrkTypeMismatch		; error
		LDX	ZP_BAS_SP
		LDB	,X				; get length of stacked
		ADDB	ZP_STRBUFLEN			; add length of current
		BCS	brkStringTooLong		; if there's a carry its too big
		STB	ZP_NAMELENORVT			; store combined len
		; move current string (RH) along by the length of (LH)
		LDX	#BASWKSP_STRING
		ABX					; X points to last char of combined string + 1
		LEAU	,X				; stick it in Y
		LDX	#BASWKSP_STRING			
		LDB	ZP_STRBUFLEN			; length of LH
		ABX
1		LDA	,-X
		STA	,-U
		DECB
		BNE	1B				; shift current string along
		CALL	popStackedStringNew		; pop stacked string
		LDB	ZP_NAMELENORVT
		STB	ZP_STRBUFLEN
		PULS	B,U				; pop next token
		BRA	_skEvalLevel4_noLevel3
;			;  Evaluator Level 4 - + -
;			;  =======================
evalLevel4						; L9E4C
		CALL	evalLevel3			;  Call Evaluator Level 3 - * / DIV MOD
_skEvalLevel4_noLevel3					; L9E4F
		CMPB	#'+'
		BEQ	evalL4Plus			;  Jump to do +
		CMPB	#'-'
		BEQ	evalL4Minus			;  Jump to do -
		RTS
;			;  <expression> + <expression>
;			;  ---------------------------
evalL4Plus						; L9E58
		TSTA
		BEQ	evalL4StringPlus		;  <string> +
		BMI	evalL4RealPlus			;  <real> +
		CALL	stackIntThenEvalL3		;  Stack integer, call Evaluator Level 3 - * / DIV MOD
		TSTA
		LBEQ	brkTypeMismatch			;  <int> + <string> - Type mismatch
		BMI	evalL4IntPlusReal		;  <int> + <real> - convert
		PSHS	B
		LDX	ZP_BAS_SP
		LDD	2,X
		ADDD	ZP_INT_WA + 2
		STD	ZP_INT_WA + 2
		LDD	,X
	IF CPU_6309
		ADCD	ZP_INT_WA
	ELSE
		ADCB	ZP_INT_WA + 1
		ADCA	ZP_INT_WA + 0
	ENDIF
		STD	ZP_INT_WA
		PULS	B
;			;  Drop integer from stack and return integer
;			;  ------------------------------------------
evalL4PopIntStackReturnIntX				; L9E80
		LEAX	4,X
		STX	ZP_BAS_SP
		LDA	#$40
		BRA	_skEvalLevel4_noLevel3		;  Update SP, loop to do any more +, -

evalL4RealPlus						;L9E94
		CALL	fpStackWAtoStackReal
		CALL	evalLevel3
		STB	ZP_VARTYPE
		TSTA
		LBEQ	brkTypeMismatch
		BMI	L9EA4
		CALL	IntToReal
L9EA4		CALL	popFPandSetPTR1toStack
		CALL	fpFPAeqPTR1addFPA
evalTokenFromVarTypeReturnReal				; L9EAA
		LDB	ZP_VARTYPE			; Get back saved token
		LDA	#$FF
		BRA _skEvalLevel4_noLevel3		;  Loop to do any more +, -



evalL4IntPlusReal					; L9EB0
		STB	ZP_VARTYPE
		CALL	popIntANew
		CALL	fpStackWAtoStackReal
		CALL	IntToReal
		BRA	L9EA4

		;  <expression> - <expression>
		;  ---------------------------
evalL4Minus						; L9E58
		TSTA
		LBEQ	brkTypeMismatch			;  <string> - Type mismatch
		BMI	evalL4RealMinus			;  <real> -
		CALL	stackIntThenEvalL3
		TSTA					;  Stack integer, call Evaluator Level 3 - * / DIV MOD
		LBEQ	brkTypeMismatch			;  <int> - <string> - Type mismatch
		BMI	evalL4IntMinusReal		;  <int> - <real> - convert
		PSHS	B
		LDX	ZP_BAS_SP
		LDD	2,X
		SUBD	ZP_INT_WA + 2
		STD	ZP_INT_WA + 2
		LDD	0,X
	IF CPU_6309
		SBCD	ZP_INT_WA + 0
	ELSE
		SBCB	ZP_INT_WA + 1
		SBCA	ZP_INT_WA + 0
	ENDIF
		STD	ZP_INT_WA + 0
		PULS	B
		BRA evalL4PopIntStackReturnIntX		;  Drop integer from stack and return

__skbrkTypeMismatch
		JUMP brkTypeMismatch


;			;  <real> - <expression>
;			;  ---------------------
evalL4RealMinus						; L9EE7
		CALL	fpStackWAtoStackReal
		CALL	evalLevel3
		STB	ZP_VARTYPE
		TSTA
		BEQ	__skbrkTypeMismatch
		BMI	1F
		CALL	IntToReal
1							; L9EF7
		CALL	popFPandSetPTR1toStack
		CALL	fpFPAeqPTR1subFPA
		BRA	evalTokenFromVarTypeReturnReal


evalL4IntMinusReal					; L9EFF
		STB	ZP_VARTYPE			; preserve token
		CALL	popIntANew
		CALL	fpStackWAtoStackReal
		CALL	IntToReal
		CALL	popFPandSetPTR1toStack
		CALL	fpFPAeqPTR1subFPAnegFPA
		BRA	evalTokenFromVarTypeReturnReal
L9F12
		CALL	IntToReal			; convert RHS to real and mult
L9F15							; convert LHS to real and mult
		CALL	popIntANew
		CALL	fpStackWAtoStackReal
		CALL	IntToReal
		BRA	L9F2D
eval3Mul_IntAsRealEvalAndMul				; L9F20
		CALL	IntToReal
eval3Mul_StackRealEvalAndMul			; L9F23
		CALL	fpStackWAtoStackReal
		CALL	evalLevel2			; call eval level 2
		CALL	checkTypeIntToReal
L9F2D		CALL	popFPandSetPTR1toStack
		CALL	fpFPAeqPTR1mulFPA
		LDA	#$FF
		LDB	-1,U
		JUMP	_skevalLevel3noLevel2
		
		;  <expression> * <expression>
		;  ---------------------------
Eval3Mul
		TSTA
		BEQ	__skbrkTypeMismatch		; can't multiply a string
		BMI	eval3Mul_StackRealEvalAndMul
		LDB	ZP_INT_WA + 0
		CMPB	ZP_INT_WA + 1			; if top two bytes of integer aren't the same
		BNE	eval3Mul_IntAsRealEvalAndMul
		LDA	ZP_INT_WA + 2
		ASLA
		ADCB	#$00				; or top byte + MS bit of 2nd byte <> 0 
		BNE	eval3Mul_IntAsRealEvalAndMul				; do a real mult
		CALL	stackINTEvalLevel2
		STB	ZP_VARTYPE			; save B
		TSTA
		BEQ	__skbrkTypeMismatch
		BMI	L9F15
		LDB	ZP_INT_WA + 0
		CMPB	ZP_INT_WA + 1			; if top two bytes aren't the same then do real multiply
		BNE	L9F12				; convert to real both WA and stacked and do real
		LDA	ZP_INT_WA + 2
		ASLA					; shift top bit of 2 into A (top byte)
		ADCB	#$00
		BNE	L9F12

	IF CPU_6309
		LDX	ZP_BAS_SP
		LDD	ZP_INT_WA+2
		MULD	2,X
		STQ	0,X
	ELSE
		; work out what sign changes (if any) we need to do at the end and pop result from stack
		LDA	ZP_INT_WA + 0
		EORA	[ZP_BAS_SP]
		STA	ZP_GEN_PTR			; ZP_GEN_PTR contains sign flip bit in bit 7


		CALL	intWA_ABS			; ABS int 
		LDX	#ZP_GEN_PTR+2
		CALL	CopyIntWA2X			; and move to temp areas
		LDX	ZP_BAS_SP
		LDD	,X
		STD	ZP_INT_WA
		LDD	2,X
		STD	ZP_INT_WA + 2			; retrieve int from U stack but leave room (we'll place result there)
		CALL	intWA_ABS			; ABS it

		CLRA
		CLRB
		STD	0,X
		STD	2,X

		; now X points to B, WA contains A both only bottom 15 bits, multiply into 4 bytes at ZP_GEN_PTR+2
		LDA	ZP_INT_WA + 3
		BEQ	1F
		LDB	ZP_GEN_PTR + 5
		BEQ	1F
		MUL
		STD	2,X

1		; now contains two LSbytes multiplied together, multiply 2nd byte of A with LSB of B and add to acc
		LDA	ZP_INT_WA + 2
		BEQ	1F
		LDB	ZP_GEN_PTR + 5
		BEQ	1F
		MUL
		ADDD	1,X
		STD	1,X
		BCC	1F
		INC	0,X
1
		;  multiply 1st byte of A with 2nd byte of B and add to acc
		LDA	ZP_INT_WA + 3
		BEQ	1F
		LDB	ZP_GEN_PTR + 4
		BEQ	1F
		MUL
		ADDD	1,X
		STD	1,X
		BCC	1F
		INC	0,X
1
		;  multiply 2nd byte of A with 2nd byte of B and add to acc
		LDA	ZP_INT_WA + 2
		BEQ	1F
		LDB	ZP_GEN_PTR + 4
		BEQ	1F
		MUL
		ADDD	0,X
		STD	0,X
1
	ENDIF ; 6809
		; no check - this should never overflow!
		; now U should contain ABS result
		CALL	popIntANew
divmodNegateWAifZP_GEN_PTR
		TST	ZP_GEN_PTR
divmodNegateWAifMI
		BPL	1F
		CALL	negateIntA
1		LDA	#$40
divmodfinish	LDB	ZP_VARTYPE
		BRA	_skevalLevel3noLevel2




;			;  Evaluator Level 3 - * / DIV MOD
;			;  ===============================
stackIntThenEvalL3					; L9FC4
		CALL stackINT_WAasINT			;  Stack current integer
evalLevel3						; L9FC7
		CALL	evalLevel2			;  Call Evaluator Level 2 - ^
_skevalLevel3noLevel2					; L9FCA
		CMPB	#'*'
		LBEQ	Eval3Mul			;  Jump with *
		CMPB	#'/'
		BEQ	evalL3DoRealDiv			;  Jump with /
		CMPB	#tknMOD
		BEQ	evalL3DoMOD			;  Jump with MOD
		CMPB	#tknDIV
		BEQ	evalL3DoDIV				;  Jump with DIV
		RTS
;			;  <expression> / <expression>
;			;  ---------------------------
evalL3DoRealDiv						; L9FDB
		CALL	checkTypeIntToReal
		CALL	fpStackWAtoStackReal		; Error if string, ensure real, stack real
		CALL	evalLevel2			; Call Evaluator Level 2 - ^
		STB	ZP_VARTYPE			; save current token
		CALL	checkTypeIntToReal
		CALL	popFPandSetPTR1toStack
		CALL	fpFPAeqPTR1divFPA
		LDA	#$FF
		BRA	divmodfinish
;			;  <expression> MOD <expression>
;			;  -----------------------------
evalL3DoMOD						; L9FF5
		CALL	evalDoIntDivide
		LDX	#ZP_INT_WA_C
		CALL	intLoadWAFromX
		LDA	ZP_GEN_PTR
		BRA	divmodNegateWAifMI
;			;  <expression> DIV <expression>
;			;  -----------------------------
evalL3DoDIV						; L9FFD
		CALL	evalDoIntDivide
		ROL	ZP_INT_WA_B + 3
		ROL	ZP_INT_WA_B + 2
		ROL	ZP_INT_WA_B + 1
		ROL	ZP_INT_WA_B + 0
		LDX	#ZP_INT_WA_B
		CALL	intLoadWAFromX
		BRA 	divmodNegateWAifZP_GEN_PTR
;
;			;  Evaluator Level 2 - ^
;			;  =====================
stackINTEvalLevel2					; LA00F
		CALL stackINT_WAasINT			; Stack current integer
evalLevel2						; LA012
		CALL evalLevel1				; Call Evaluator Level 1 - everything else
evalLevel2again						; LA015
evalL2lp1	LDB	,U+
		CMPB	#' '
		BEQ	evalL2lp1			;  Skip spaces
		CMPB	#'^'
		BEQ	evalDoCARET			;  Jump with ^
		RTS
;			;  <expression> ^ <expression>
;			;  ---------------------------
evalDoCARET						;LA027:
		CALL 	checkTypeIntToReal
		CALL 	fpStackWAtoStackReal
		CALL 	evalLevel1ConvertReal
		LDA 	ZP_FPA + 2			; get exponent
		CMPA	#$87				; is it > 87 i.e. FPA > 64
		BHS 	LA079				; if it is ????
		CALL	fpFPASplitToFractPlusInt
		BNE	LA049				; if there's a fractional part then
							; go to do "complex" routin
		CALL	popFPandSetPTR1toStack		; else do a simpler X*X*X*X...
		CALL	fpCopyPTR1toFPA			; move to FPA
		LDA	ZP_FP_TMP + 6			; get integer part
		CALL	FPAeqFPAraisedToA			; FPA = FPA ^ INT(A)
		BRA	LA075retFPval
LA049		CALL	fpCopyFPA_FPTEMP3
		LDX 	ZP_BAS_SP
		CALL	fpCopyXtoFPA
		LDA	ZP_FP_TMP + 6
		CALL	FPAeqFPAraisedToA
LA05C		LDX	#BASWKSP_FPTEMP2
		CALL	fpCopyFPA_X
		CALL	popFPandSetPTR1toStack
		CALL	fpCopyPTR1toFPA
		CALL	fnLN_FPA
		CALL	fpFPAeqFPTEMP3mulFPA
		CALL	fnEXP_int
		LDX	#BASWKSP_FPTEMP2
		CALL	fpFPAeqXmulFPA
LA075retFPval	LDA 	#$FF
		BRA	evalLevel2again
LA079		CALL	fpCopyFPA_FPTEMP3
		CALL	fpLoad1			;  FloatA=1.0
		BRA	LA05C


		; formats a 16 bit integer at ZP_INT_WA + 2 to a string
		; NEW API
		;	A contains preferred length or 0 for any
		;	Y preserved
		;	X preserved					TODO, needed?
		;	ZP_INT_WA + 2 = 0				TODO, needed?
		;	returns with B = $FF

		; OLD API
		;	A contains preferred length or 0 for any
		;	Y preserved
		;	ZP_INT_WA + 2 = 0
		;	returns with X = $FF

int16print_AnyLen				; LA081
		LDA	#$00
		BRA	int16print_fmtA
int16print_fmt5					; LA085
		LDA	#$05
int16print_fmtA					; LA087
		STA	ZP_PRINTBYTES
		LEAX	tblTENS_BE, PCR		; point at tens table
		PSHS	U
		LDU	#ZP_FPB + 4
		LDD	ZP_INT_WA + 2
		CLR	4,U
		CLR	3,U
		CLR	2,U
		CLR	1,U
		CLR	0,U

int16dig4_lp	SUBD	8,X			; try and subtract ten
		BCS	int16dig4_sk
		INC	4,U			; it it doesn't overflow increment digit
		BRA	int16dig4_lp		
int16dig4_sk	ADDD	8,X			; add number back
		BEQ	int16dig_skiprest

int16dig3_lp	SUBD	6,X			; try and subtract ten
		BCS	int16dig3_sk
		INC	3,U			; it it doesn't overflow increment digit
		BRA	int16dig3_lp		
int16dig3_sk	ADDD	6,X			; add number back
		BEQ	int16dig_skiprest

int16dig2_lp	SUBD	4,X			; try and subtract ten
		BCS	int16dig2_sk
		INC	2,U			; it it doesn't overflow increment digit
		BRA	int16dig2_lp		
int16dig2_sk	ADDD	4,X			; add number back
		BEQ	int16dig_skiprest

int16dig1_lp	SUBD	2,X			; try and subtract ten
		BCS	int16dig1_sk
		INC	1,U			; it it doesn't overflow increment digit
		BRA	int16dig1_lp		
int16dig1_sk	ADDD	2,X			; add number back
		BEQ	int16dig_skiprest

int16dig0_lp	SUBD	0,X			; try and subtract ten
		BCS	int16dig_skiprest
		INC	0,U			; it it doesn't overflow increment digit
		BRA	int16dig0_lp		

int16dig_skiprest

		; number now decoded (reversed at ZP_FPB + 4)


		LDB	#$05
int16_scan0_lp					;LA0A8
		DECB				; scan for first non zero element
		BEQ	int16_scan0_sk
		LDA	B,U
		BEQ	int16_scan0_lp
int16_scan0_sk					;LA0AF:
		STB	ZP_GEN_PTR
		LDA	ZP_PRINTBYTES
		BEQ	int16_printDigits
		SUBA	ZP_GEN_PTR
		BEQ	int16_printDigits
		TFR	A,B
		CALL	list_printBSpaces
		LDB	ZP_GEN_PTR
int16_printDigits				;LA0BF:
		LDA	B,U
		ORA	#$30
		CALL	list_printA
		DECB
		BPL	int16_printDigits
		PULS	U,PC			; RTS restore Y


;			;  Convert number to hex string
;			;  ----------------------------
cmdPRINT_num2str_hex					; LA0CA
		PSHS	U
		TST	ZP_VARTYPE			; real?
		BPL	1F				; no
		CALL	fpReal2Int			;  Convert real to integer
1							; LA0D0:
		LDX	#ZP_FPB + 4
		LDU	#ZP_INT_WA + 4
		LDB	#4
1		LDA	,-U				; unwind nibbles into a buffer
		ANDA	#$0F
		STA	,X+
		LDA	,U				; reload for low nibble
		LSRA
		LSRA
		LSRA
		LSRA
		STA	,X+
		DECB
		BNE	1B
		LDB	#7				; note skip at most 7, print 0 for 0!
1							; LA0EA
		LDA	,-X				; skip leading 0's
		BNE	1F
		DECB
		BPL	1B
1							; LA0F1
		CMPA	#10				; Get byte from workspace
		BLO	2F
		ADDA	#'A'-'9'-1			; Convert byte to hex
2							; LA0F9
		ADDA	#'0'
		CALL	cmdPRINT_num2str_storeA		;  Convert to digit and store
		DECB
		BMI	3F
		LDA	,-X
		BRA	1B
3		PULS	U,PC


;			;  Loop for all digits
;			;  Output nonzero real number
;			;  --------------------------
cmdPRINT_num2str_realNon0				; LA102
		BPL	cmdPRINT_num2str_realNon0_lp1	;  Jump forward if positive
		LDA	#'-'
		CLR	ZP_FPA			;  A='-', clear sign flag
		CALL	cmdPRINT_num2str_storeA				;  Add '-' to string buffer
cmdPRINT_num2str_realNon0_lp1				;LA10B:
		LDA	ZP_FPA + 2			;  Get exponent
		CMPA	#$81
		BCC	cmdPRINT_num2str_digit			;  If m*2^1 or larger, number>=1, jump to output it
		CALL	fmMulBy10			;  FloatA=FloatA*10
		DEC	ZP_FP_TMP + 5
		BRA 	cmdPRINT_num2str_realNon0_lp1	;  Loop until number is >=1


;			;  Convert numeric value to string
;			;  ===============================
;			;  On entry, FloatA ($2E-$35)	= number
;			;	     or IntA (ZP_INT_WA)= number
;			;		ZP_VAR_TYPE	= type
;			;		@%		= print format
;			;		ZP_PRINTFLAG[7]	= 1 if hex
;			;  On exit,  StrA contains string version of number
;			;
cmdPRINT_num2str					; LA118
		LDB	BASWKSP_INTVAR + 1		;  Get @% format byte
		CMPB	#$03
		BCS	cmdPRINT_num2str_skFMTOK	;  Use it if valid
		LDB	#$00
;			;  If @% invalid, use General format
cmdPRINT_num2str_skFMTOK				;LA121:
		STB 	ZP_GEN_PTR			; Store format type
		LDA	BASWKSP_INTVAR + 2		; Num dec places
		BEQ	cmdPRINT_num2str_0dp		; If digits is zero, check format
		CMPA	#$0A
		BCC	cmdPRINT_num2str_invaldp	; If digits>10, jump to use 10 digits
		BRA	cmdPRINT_num2str_dp_sk		; Use this number of digits
cmdPRINT_num2str_0dp					; LA12E
		CMPB	#$02
		BEQ	cmdPRINT_num2str_dp_sk		; If fixed format, use zero digits
cmdPRINT_num2str_invaldp				; LA132
		LDA	#$0A				; Otherwise, use ten digits
cmdPRINT_num2str_dp_sk					; LA134
		STA	ZP_GEN_PTR + 1
		STA	ZP_FP_TMP + 10			;  Store digit length
		CLR	ZP_STRBUFLEN
		CLR	ZP_FP_TMP + 5			;  Set initial output to 0, initial exponent to 0
		TST	ZP_PRINTFLAG
		BMI	cmdPRINT_num2str_hex		;  Jump for hex conversion
		TST	ZP_VARTYPE
		BMI	cmdPRINT_num2str_dec_sk1
		CALL	IntToReal			;  Convert integer to real
cmdPRINT_num2str_dec_sk1				;LA146:
		CALL	fpCheckMant0SetSignExp0
		BNE	cmdPRINT_num2str_realNon0	; Get sign, jump if not zero to output nonzero number
		LDA	ZP_GEN_PTR
		LBNE	cmdPRINT_num2str_fmtFixedOrExp0	; If not General format, output fixed or exponential zero
		LDA	#'0'
		JUMP	cmdPRINT_num2str_storeA		;  Store '0' and return
setFloatA1_cmdPRINT_num2str_digit
		CALL	fpLoad1				;  FloatA=1.0
		BRA	cmdPRINT_num2str_digit_sk2


;			;  FloatA now is >=1, check that it is <10
;			;  ---------------------------------------
cmdPRINT_num2str_digit					; LA15C
		CMPA	#$84
		BCS	cmdPRINT_num2str_digit_1_9	; Exponent<4, FloatA<10, jump to convert it
		BNE	cmdPRINT_num2str_digit_sk1	; Exponent<>4, need to divide it
		LDA	ZP_FPA + 3			; Get mantissa top byte
		CMPA	#$A0
		BCS	cmdPRINT_num2str_digit_1_9	; Less than $A0, less than ten, jump to convert it
cmdPRINT_num2str_digit_sk1				; LA168:
		CALL	fpFloatADiv10			; FloatA=FloatA / 10
cmdPRINT_num2str_digit_sk2				; LA16B:
		INC	ZP_FP_TMP + 5			; incremenet exponent
		BRA	cmdPRINT_num2str_realNon0_lp1
;			;  Jump back to get the number >=1 again
;			;  FloatA is now between 1 and 9.999999999
;			;  ---------------------------------------
cmdPRINT_num2str_digit_1_9				;LA16F:
		LDA	ZP_FPA + 7
		STA	ZP_VARTYPE
		CALL	fpCopyFPA_FPTEMP1				;  Copy FloatA to FloatTemp at $27/$046C
		LDA	ZP_FP_TMP + 10
		STA	ZP_GEN_PTR + 1			;  Get number of digits
		LDB	ZP_GEN_PTR			;  Get print format
		CMPB	#$02
		BNE	cmdPRINT_num2str_digit_1_9_sknf				;  Not fixed format, jump to do exponent/general
		SEC
		ADCA	ZP_FP_TMP + 5
		BMI	cmdPRINT_num2str_clearZeroFPAandPrintFMT2
		STA	ZP_GEN_PTR + 1
		CMPA	#$0B
		BCS	cmdPRINT_num2str_digit_1_9_sknf
		LDA	#$0A
		STA	ZP_GEN_PTR + 1
		CLR	ZP_GEN_PTR
cmdPRINT_num2str_digit_1_9_sknf				; LA190
		CALL	zero_FPA_sign_expO_manlo	;  Clear FloatA
		LDA	#$A0
		STA	ZP_FPA + 3
		LDA	#$83
		STA	ZP_FPA + 2
		LDB	ZP_GEN_PTR + 1
		BEQ	LA1A5
LA19F
		PSHS	B
		CALL	fpFloatADiv10			;  FloatA=FloatA/10
		PULS	B
		DECB
		BNE	LA19F
LA1A5		LDX	#BASWKSP_FPTEMP1		;  Point to $46C
		CALL	fpMoveRealAtXtoFPB		;  Unpack to FloatB
		LDA	ZP_VARTYPE
		STA	ZP_FPB + 6
		CALL	fpAddAtoBStoreA				;  Add
		LDA	ZP_FPA + 2
LA1B2
		CMPA	#$84
		BHS	LA1C6				; if >= $84
		CALL	FPAshr1
		BNE	LA1B2
LA1C6
		STA	ZP_FPA + 2
		LDA	ZP_FPA + 3
		CMPA	#$A0
		BHS	setFloatA1_cmdPRINT_num2str_digit
		LDA	ZP_GEN_PTR + 1
		BNE	LA1DE
cmdPRINT_num2str_fmtFixedOrExp0
		CMPA	#$01				; If format == 1 (exp)
		BEQ	cmdPRINT_numstr_strAasDigLenPrintDigs
cmdPRINT_num2str_clearZeroFPAandPrintFMT2		; LA1D4
		CALL	zero_FPA			; Clear FloatA
		CLR	ZP_FP_TMP + 5			; clear 10's exponent
		LDA	ZP_FP_TMP + 10			; digit length
		INCA
		STA	ZP_GEN_PTR + 1
LA1DE
		LDA	#1
		CMPA	ZP_GEN_PTR
		BEQ	cmdPRINT_numstr_strAasDigLenPrintDigs				; if format == 1 (exp)
		LDB	ZP_FP_TMP + 5			; B = 10's exponent
		BMI	cmdPRINT_numstr_printLead0point	; negative 10's exponent
		CMPB	ZP_GEN_PTR + 1
		BCC	cmdPRINT_numstr_strAasDigLenPrintDigs				; 
		CLR	ZP_FP_TMP + 5
		INCB
		TFR	B,A
		BNE	cmdPRINT_numstr_strAasDigLenPrintDigs
cmdPRINT_numstr_printLead0point				; LA1F2
		LDA	ZP_GEN_PTR
		CMPA	#$02				; if format == 2 (fixed)
		BEQ	cmdPRINT_numstr_print0point
		LDA	#1
		CMPB	#$FF
		BNE	cmdPRINT_numstr_strAasDigLenPrintDigs
cmdPRINT_numstr_print0point				; LA1FE
		LDA	#'0'
		CALL	cmdPRINT_num2str_storeA		; Output '0'
		LDA	#'.'
		CALL	cmdPRINT_num2str_storeA		; Output '.'
		LDA	#'0'				; Prepare '0'
cmdPRINT_numstr_print0point_lp				;LA20A:
		INC	ZP_FP_TMP + 5
		BEQ	cmdPRINT_numstr_print0point_sk
		CALL	cmdPRINT_num2str_storeA		; Output
		BRA	cmdPRINT_numstr_print0point_lp
cmdPRINT_numstr_print0point_sk				;LA213:
		LDA	#$80
cmdPRINT_numstr_strAasDigLenPrintDigs			;
		STA	ZP_FP_TMP + 10
cmdPRINT_numstr_print_lp2				;LA217:
		CALL	cmdPRINT_numstr_printAhigh_nyb_asdigit_thenmul10
		DEC	ZP_FP_TMP + 10
		BNE	cmdPRINT_numstr_print_sk2
		LDA	#'.'
		CALL	cmdPRINT_num2str_storeA
cmdPRINT_numstr_print_sk2				;LA223:
		DEC	ZP_GEN_PTR + 1
		BNE	cmdPRINT_numstr_print_lp2
		LDB	ZP_GEN_PTR
		DECB
		BEQ	cmdPRINT_numstr_print_exponent_exp				; format = 1 (exp)
		DECB
		BEQ	cmdPRINT_numstr_print_exponent_fix	; format = 2 (fixed)
		LDB	ZP_STRBUFLEN
		LDX	#BAS_StrA
cmdPRINT_numstr_removetrail0_lp				; LA231
		DECB
		LDA	B,X
		CMPA	#'0'
		BEQ	cmdPRINT_numstr_removetrail0_lp
		CMPA	#'.'
		BEQ	cmdPRINT_numstr_removetrail0_sk
		INCB
cmdPRINT_numstr_removetrail0_sk				; LA23E:
		STB	ZP_STRBUFLEN
cmdPRINT_numstr_print_exponent_fix			; LA240
		LDA	ZP_FP_TMP + 5
		BEQ	rtsLA26B
cmdPRINT_numstr_print_exponent_exp			; LA244
		LDA	#'E'
		CALL	cmdPRINT_num2str_storeA		;  Output 'E'
		LDA	ZP_FP_TMP + 5
		BPL	cmdPRINT_numstr_print_exponent_exp_sk
		LDA	#'-'
		CALL	cmdPRINT_num2str_storeA		; Output '-'
		NEG	ZP_FP_TMP + 5			;  Negate
		LDA	ZP_FP_TMP + 5
cmdPRINT_numstr_print_exponent_exp_sk			; LA257:
		CALL	cmdPRINT_numstr_convert_10_1
		LDA	ZP_GEN_PTR
		BEQ	rtsLA26B
		LDA	#$20
		LDB	ZP_FP_TMP + 5
		BMI	LA267
		CALL	cmdPRINT_num2str_storeA
LA267
		CMPB	#$00
		BEQ	cmdPRINT_num2str_storeA
rtsLA26B
		RTS
cmdPRINT_numstr_printAhigh_nyb_asdigit_thenmul10
		LDA	ZP_FPA + 3
		LSRA
		LSRA
		LSRA
		LSRA
		CALL	cmdPRINT_numstr_printAlow_nyb_asdigit
		LDA	#$0F
		ANDA	ZP_FPA + 3
		STA	ZP_FPA + 3


;			;  FloatA=FloatA*10
;			;  ----------------
parseDMul10					;LA279 - TODO, speed up, make 16 bitted				 
		PSHS	A
		LDB	ZP_FPA + 6
		LDA	ZP_FPA + 3
		PSHS	A
		LDA	ZP_FPA + 4
		PSHS	A
		LDA	ZP_FPA + 5
		PSHS	A
		LDA	ZP_FPA + 7
		ASLA
		ROL	ZP_FPA + 6
		ROL	ZP_FPA + 5
		ROL	ZP_FPA + 4
		ROL	ZP_FPA + 3
		ASLA
		ROL	ZP_FPA + 6
		ROL	ZP_FPA + 5
		ROL	ZP_FPA + 4
		ROL	ZP_FPA + 3
		ADCA	ZP_FPA + 7
		STA	ZP_FPA + 7
		TFR	B,A
		ADCA	ZP_FPA + 6
		STA	ZP_FPA + 6
		PULS	A
		ADCA	ZP_FPA + 5
		STA	ZP_FPA + 5
		PULS	A
		ADCA	ZP_FPA + 4
		STA	ZP_FPA + 4
		PULS	A
		ADCA	ZP_FPA + 3
		ASL	ZP_FPA + 7
		ROL	ZP_FPA + 6
		ROL	ZP_FPA + 5
		ROL	ZP_FPA + 4
		ROLA
		STA	ZP_FPA + 3
		PULS	A
		RTS



		; convert number, B ends up counting 10's, A ends up containing units
cmdPRINT_numstr_convert_10_1				; LA2BC
		TFR	A,B
		LDA	#$FF
LA2BF
		INCA
		SUBB	#$0A
		BCC	LA2BF
		ADDB	#$0A
		TSTA
		BEQ	LA2CD
		CALL	cmdPRINT_numstr_printAlow_nyb_asdigit	; if not 0 print 10's
LA2CD
		TFR	B,A				; print 1's
cmdPRINT_numstr_printAlow_nyb_asdigit			; LA2CE
		ORA	#'0'

;			;  Store character in string buffer
;			;  --------------------------------
cmdPRINT_num2str_storeA					; LA2D0
		PSHS	B,X
		LDB	ZP_STRBUFLEN
		LDX	#BAS_StrA
		ABX
		STA	,X				; Store character
		INC	ZP_STRBUFLEN
		PULS	B,X,PC				;  Increment string length

parseDecNAN						; LA2DA
		CALL	fpSetSignExp0			;  Set IntA to zero
		CLC					;  CLC=no number, return Real
		LDA	#$FF
		RTS


;			;  Scan decimal number
;			;  -------------------
parseDecimalLiteral
		CLR	ZP_FPA + 3
		CLR	ZP_FPA + 4
		CLR	ZP_FPA + 5			;  Clear FloatA
		CLR	ZP_FPA + 6
		CLR	ZP_FPA + 7
		CLR	ZP_FP_TMP + 4			;  Clear 'Decimal point found'
		CLR	ZP_FP_TMP + 5			;  Set exponent to zero
		CMPA	#'.'
		BEQ	parseD_skDPFound		;  Decimal point
		CMPA	#'9'
		BHI	parseDecNAN			;  Not a decimal digit, return 'no number'
		SUBA	#'0'
		BLO	parseDecNAN			;  Convert to binary, if not digit, return 'no number'
		STA	ZP_FPA + 7			;  Store digit
		LDA	,U+				;  Get next character
		CMPA	#'9'
		BHI	parseD_sknotdp			;  Not a digit, check for E or end of number
		SUBA	#'0'
		BLO	parseD_sknotdig			;  Not a digit, check for decimal point
		STA	ZP_FPA				;  Store this digit
		LDA	ZP_FPA + 7
		ASLA
		ASLA					;  A=num*4
		ADDA	ZP_FPA + 7
		ASLA					;  A=(num*4+num)*2 = num*10
		ADDA	ZP_FPA
		STA	ZP_FPA + 7			;  num=num*10+digit
parseD_lp1	LDA	,U+				;  Step to next character	
		BRA	1F				; TODO: this is a bit of a kludge, maybe make '.' do branch?
parseD_sknotdig	LDA	-1,U				; reload previous char
1		CMPA	#'.'
		BNE	parseD_sknotdp			;  Not decimal point, jump to check if digit
parseD_skDPFound
		LDA	ZP_FP_TMP + 4
		BNE	parseD_skDone				;  If already have a decimal point, finish
		INC	ZP_FP_TMP + 4
		BRA	parseD_lp1			;  Set 'decimal point found', and get next digit



;			;  First two digits processed, scan rest of number
;			;  -----------------------------------------------
parseD_sknotdp
		CMPA	#'E'
		BEQ	parseD_skScanExp	;  Jump to scan exponent
		CMPA	#'9'
		BHI	parseD_skDone		;  Not a digit, jump to finish
		SUBA	#'0'
		BLO	parseD_skDone		;  Not a digit, jump to finish
		LDB	ZP_FPA + 3		;  Get mantissa top byte
		CMPB	#26
		BLO	parseD_sk2		;  If <=25, still small enough to add to
		TST	ZP_FP_TMP + 4
		BNE	parseD_lp1		;  Decimal point found, skip digits until end of number
		INC	ZP_FP_TMP + 5
		BRA	parseD_lp1		;  No decimal point, increment exponent and loop skip digits
parseD_sk2	TST	ZP_FP_TMP + 4
		BEQ	parseD_sk1
		DEC	ZP_FP_TMP + 5		;  Decimal point found, decrement exponent
parseD_sk1	CALL	parseDMul10		;  Multiply FloatA by 10
		ADDA	ZP_FPA + 7
		STA	ZP_FPA + 7		;  Add digit to mantisa low byte
		BCC	parseD_lp1		;  No overflow
		INC	ZP_FPA + 6
		BNE	parseD_lp1		;  Add carry through mantissa
		INC	ZP_FPA + 5
		BNE	parseD_lp1
		INC	ZP_FPA + 4
		BNE	parseD_lp1
		INC	ZP_FPA + 3
		BRA	parseD_lp1		;  Loop to check next digit
		
;			;  Deal with Exponent in scanned number
;			;  ------------------------------------
parseD_skScanExp
		CALL	parseD_scanExp			;  Scan following number
		ADDA	ZP_FP_TMP + 5
		STA	ZP_FP_TMP + 5		;  Add to current exponent

;			;  End of number found
;			;  -------------------
parseD_skDone	LEAU	-1,U
		STU	ZP_TXTPTR2		;  Store PtrB offset
		LDA	ZP_FP_TMP + 5
		ORA	ZP_FP_TMP + 4		;  Check exponent and 'decimal found'
		BEQ	parseD_skReturnInt	;  No exp, no dec, jump to return integer
		CALL	fpCheckMant0SetSignExp0
		BEQ	parseD_skReturnInt0
parseD_skNormalise
		LDA	#$A8
		STA	ZP_FPA + 2
		CLR	ZP_FPA + 1
		CLR	ZP_FPA
		CALL	NormaliseRealA
		LDA	ZP_FP_TMP + 5
		BMI	parseD_lp3
		BEQ	parseD_sk3
parseD_lp2	CALL	fmMulBy10
		DEC	ZP_FP_TMP + 5
		BNE	parseD_lp2
		BRA	parseD_sk3
parseD_lp3	CALL	fpFloatADiv10
		INC	ZP_FP_TMP + 5
		BNE	parseD_lp3
parseD_sk3		CALL fpRoundMantissaFPA
parseD_skReturnInt0
		SEC
		LDA	#$FF
		RTS
parseD_skReturnInt
		LDA	ZP_FPA + 4	       ; TODO - optimise using D - not sure if we need B preserved tho
		STA	ZP_INT_WA + 0	       ; DB - endiannes change
		ANDA	#$80
		ORA	ZP_FPA + 3
		BNE	parseD_skNormalise
		LDA	ZP_FPA + 7
		STA	ZP_INT_WA + 3
		LDA	ZP_FPA + 6
		STA	ZP_INT_WA + 2
		LDA	ZP_FPA + 5
		STA	ZP_INT_WA + 1
		LDA	#$40
		SEC
		RTS
parseD_skNegExp						;LA3B3
		CALL	parseD_scanExpReadDigits				;  Scan following number
		NEGA					; complement it
		RTS				;  Negate it, return CS=Ok
;			;  Scan exponent, allows E E+ E- followed by one or two digits
;			;  -----------------------------------------------------------
parseD_scanExp
		LDA	,U+				;  Get next character
		CMPA	#'-'
		BEQ	parseD_skNegExp			;  Jump to scan and negate
		CMPA	#'+'
		BNE	parseD_scanExpSkipNotPlus	;  If '+', just step past it
parseD_scanExpReadDigits				; LA3C5
		LDA	,U+	;			;  Get next character
parseD_scanExpSkipNotPlus				; LA3C8
		CMPA	#'9'
		BHI	parseD_scanExpSkipRet0		;  Not a digit, exit with CC
		SUBA	#'0'
		BCS	parseD_scanExpSkipRet0		;  Not a digit, exit with CC
		LDB	,U+				;  Get next character in B!
		CMPB	#'9'
		BHI	parseD_scanExpSkipRetA		;  Not a digit, exit with CC=Ok
		SUBB	#'0'
		BCS	 parseD_scanExpSkipRetA		;  Not a digit, exit with CC=Ok
		PSHS	B
		LDB	#10
		MUL					; multiply A by 10
		TFR	B,A				; into A
		ADDA	,S+				; add second digit
		LEAU	1,U				; skip forward one, it gets put back later!
parseD_scanExpSkipRetA
		RTS
			;  exp=exp*10+digit
parseD_scanExpSkipRet0					; go back one and return 0
		CLRA
		RTS
			;  Return exp=0 and return CC=Ok
			;  IsZero?
			;  -------
fpCheckMant0SetSignExp0
		LDA	ZP_FPA + 3		; Mantissa MSB	; TODO use D?
		ORA	ZP_FPA + 4		
		ORA	ZP_FPA + 5
		ORA	ZP_FPA + 6
		ORA	ZP_FPA + 7		; Mantissa LSB
		BEQ 	fpSetSignExp0
		LDA	ZP_FPA		; sign
		BNE	anRTS5
		INCA				; return A=1, Z=0, PL
		RTS
;			;  Return zero
;			;  -----------
fpSetSignExp0
		CLR	ZP_FPA
		CLR	ZP_FPA + 2
		CLR	ZP_FPA + 1
anRTS5		RTS

fpCopyFPAtoFPB
		LDA	ZP_FPA
		STA	ZP_FPB			; copy sign
		LDD	ZP_FPA + 2
		STD	ZP_FPB + 1
		LDD	ZP_FPA + 4
		STD	ZP_FPB + 3
		LDD	ZP_FPA + 6
		STD	ZP_FPB + 5
		RTS
fpCopyFPAtoFPBAndShiftRight
		CALL	fpCopyFPAtoFPB
fpShiftBMantissaRight
		LSR	ZP_FPB + 2
		ROR	ZP_FPB + 3
		ROR	ZP_FPB + 4
		ROR	ZP_FPB + 5
		ROR	ZP_FPB + 6
		RTS
fmMulBy10						; LA436
		LDD	ZP_FPA + 1			; mantissa + 3 (i.e. * 8)
		ADDD	#$03
		STD	ZP_FPA + 1
		CALL	fpCopyFPAtoFPBAndShiftRight	; fpB = fpA / 4 i.e.
		CALL	fpShiftBMantissaRight		; note C is brought in here!
fpAddAtoBstoreinA_sameExp
		LDD	ZP_FPA + 6
		ADCB	ZP_FPB + 6
		ADCA	ZP_FPB + 5
		STD	ZP_FPA + 6

		LDD	ZP_FPA + 4		
		ADCB	ZP_FPB + 4
		ADCA	ZP_FPB + 3
		STD	ZP_FPA + 4

		LDA	ZP_FPA + 3
		ADCA	ZP_FPB + 2
		STA	ZP_FPA + 3
		BCC	anRTS11
fpRORMantAincExp
		CALL	FPAror1
		INC	ZP_FPA + 2
		BNE	anRTS11
		INC	ZP_FPA + 1
anRTS11		RTS
fpFloatADiv10						; LA478
		LDA	ZP_FPA + 2			; exponent low
		SUBA	#4
		STA	ZP_FPA + 2
		BCC	fpFloatADiv10_sk1
		DEC	ZP_FPA + 1
fpFloatADiv10_sk1					; LA483:
		CALL	fpCopyFPAtoFPBAndShiftRight
		CALL	fpAddAtoBstoreinA_sameExp
		CALL	fpCopyFPAtoFPBAndShiftRight
		CALL	fpShiftBMantissaRight
		CALL	fpShiftBMantissaRight
		CALL	fpShiftBMantissaRight
		CALL	fpAddAtoBstoreinA_sameExp
		CLR	ZP_FPB + 2
		LDD	ZP_FPA + 3
		STD	ZP_FPB + 3
		LDD	ZP_FPA + 5
		STD	ZP_FPB + 5
		LDA	ZP_FPA + 7
		ROLA
		CALL	fpAddAtoBstoreinA_sameExp
		CLR	ZP_FPB + 3			; TODO - 16 bit this!

		LDA	ZP_FPA + 3
		STA	ZP_FPB + 4

		LDA	ZP_FPA + 4
		STA	ZP_FPB + 5
		LDA	ZP_FPA + 5
		STA	ZP_FPB + 6		
		LDA	ZP_FPA + 6
		ROLA
		CALL	fpAddAtoBstoreinA_sameExp
		LDA	ZP_FPA + 4
		ROLA
		LDA	ZP_FPA + 3
		ADCA	ZP_FPA + 7
		STA	ZP_FPA + 7
		BCC	rtsLA4DF
		INC	ZP_FPA + 6
		BNE	rtsLA4DF
fpIncFPAMantMSBs					; LA4D3
		INC	ZP_FPA + 5			; TODO more 16 bitting?
		BNE	rtsLA4DF
		INC	ZP_FPA + 4
		BNE	rtsLA4DF
		INC	ZP_FPA + 3
		SEC
		BEQ	fpRORMantAincExp
rtsLA4DF
		RTS
fpMoveRealAtPTR1toFPB
		LDX	ZP_FP_TMP_PTR1
fpMoveRealAtXtoFPB
*		PSHS	B				; TODO - check if needed
		CLR	ZP_FPB + 6			; zero overflow
		LDD	3,X				; copy mantissa low bytes
		STD	ZP_FPB + 4

		LDD	1,X				; copy mantissa msb into sign bit and next into mantissa
		STB	ZP_FPB + 3
		STA	ZP_FPB

		LDB	,X				; get exponent
		STB	ZP_FPB + 1			; store
		BNE	fpMoveRealAtXtoFPB_sk1		; if not 0 continue
		ORA	ZP_FPB + 3
		ORA	ZP_FPB + 4
		ORA	ZP_FPB + 5
		BEQ	fpMoveRealAtXtoFPB_sk2		; if rest is zero were done just store 0
fpMoveRealAtXtoFPB_sk1
		LDA	ZP_FPB				; get back mantissa MSB from sign 
		ORA	#$80				; set top bit
fpMoveRealAtXtoFPB_sk2
		STA	ZP_FPB + 2			; store in mantissa
		RTS
;		
;		
;		
fpCopyFPA_FPTEMP3					; LA50D
		LDX	#BASWKSP_FPTEMP3
		STX	ZP_FP_TMP_PTR1			; TODO - this may seem unnecessary but there are functions that expect PTR1 to point to last used location
		BRA	fpCopyFPA_X
fpCopyFPA_FPTEMP1					; LA511
		LDX	#BASWKSP_FPTEMP1
		STX	ZP_FP_TMP_PTR1			; TODO - this may seem unnecessary but there are functions that expect PTR1 to point to last used location
;;		BRA	fpCopyFPA_X
fpCopyFPA_PTR1
		LDX	ZP_FP_TMP_PTR1
fpCopyFPA_X
		LDA	ZP_FPA + 2
		STA	,X+
		LDA	ZP_FPA
		EORA	ZP_FPA + 3
		ANDA	#$80
		EORA	ZP_FPA + 3
		STA	,X+
		LDA	ZP_FPA + 4
		STA	,X+
		LDA	ZP_FPA + 5
		STA	,X+
		LDA	ZP_FPA + 6
		STA	,X
		RTS


fpCopyFPTEMP1toFPA				; LA539
		; note now trashes X
		LDX	#BASWKSP_FPTEMP1
		BRA	fpCopyXtoFPA
;;fpCopyXtoFPA--was 400+A				; LA53B
;;;		STA ZP_FP_TMP_PTR1
;;;		LDA #$04
;;;		STA ZP_FP_TMP_PTR1 + 1


fpCopyPTR1toFPA
		LDX	ZP_FP_TMP_PTR1
fpCopyXtoFPA
*		PSHS	B				; TODO - check if needed
		CLRA
		STA	ZP_FPA + 7			; zero overflow
		STA	ZP_FPA + 1			; zero overflow exp
		LDD	3,X				; copy mantissa low bytes
		STD	ZP_FPA + 5

		LDD	1,X				; copy mantissa msb into sign bit and next into mantissa
		STB	ZP_FPA + 4
		STA	ZP_FPA

		LDB	,X				; get exponent
		STB	ZP_FPA + 2			; store
		BNE	fpCopyXtoFPA_sk1		; if not 0 continue
		ORA	ZP_FPA + 4
		ORA	ZP_FPA + 5
		ORA	ZP_FPA + 6
		BEQ	fpCopyXtoFPA_sk2		; if rest is zero were done just store 0
fpCopyXtoFPA_sk1
		LDA	ZP_FPA			; get back mantissa MSB from sign 
		ORA	#$80				; set top bit
fpCopyXtoFPA_sk2
		STA	ZP_FPA + 3			; store in mantissa
		RTS



fpSetRealBto0	CLR ZP_FPB
		CLR ZP_FPB + 1
		CLR ZP_FPB + 2
fpSetRealBMantTo0
		CLR ZP_FPB + 3
		CLR ZP_FPB + 4
		CLR ZP_FPB + 5
		CLR ZP_FPB + 6
		RTS

fpAdd5toPTR2copytoPTR1				; LA57F
		LDX	ZP_FP_TMP_PTR2
		LEAX	5,X
		STX	ZP_FP_TMP_PTR2
		STX	ZP_FP_TMP_PTR1
		RTS



;;;; TODO Check whether any of these are needed should use X and 
;;;;fpPTR1==pi/2:				; LA589
;;;;		LDA #<fpConstPiDiv2
;;;;fpPTR1==constant at A (near pi/2):		; LA58B
;;;;		STA ZP_FP_TMP_PTR1
;;;;		LDA #>fpConstPiDiv2
;;;;		STA ZP_FP_TMP_PTR1 + 1
;;;;		RTS
;;;FPPTR1=BASWKSP_FPTEMP1:			; LA592
;;;		LDA #$6C
;;;FPPTR1=BASWKSP_400+A:			; LA594
;;;		STA ZP_FP_TMP_PTR1
;;;		LDA #$04
;;;		STA ZP_FP_TMP_PTR1 + 1
;;;		RTS
fnTAN			; LA59B!
		CALL	trigNormaltheta
		LDX	#BASWKSP_FPTEMP4
		CALL	fpCopyFPA_X			; save theta to FPTEMP4
		CALL	fnSIN_internal1		; get sin theta
		LDX	#BASWKSP_FPTEMP3
		CALL	fpCopyFPA_X			; save sin theta to FPTEMP3
		LDX	#BASWKSP_FPTEMP4
		CALL	fpCopyXtoFPA			; get back theta from FPTEMP4
		CALL	fnCOS_internal1			; get cos theta
fpFPAeqFPTEMP3divFPA					; LA5B3
		LDX	#BASWKSP_FPTEMP3
		STX	ZP_FP_TMP_PTR1
		CALL	fpFPAeqPTR1divFPA
		LDA	#$FF
		RTS
FPAeqFPAraisedToA						; TODO: this could be shortened by using stack to store counter
		TFR	A,B
		TSTB
		BPL	LA5C9
		NEGA
		STA	,-S
		CALL	fpFPAeq1.0divFPA
		LDB	,S+
LA5C9
		BEQ	fpLoad1			;  Floata=1.0
		CALL	fpCopyFPA_FPTEMP1
		DECB
		BEQ	LA5D7
LA5D1		PSHS	B
		CALL	fpFPAeqPTR1mulFPA
		PULS	B
		DECB
		BNE	LA5D1
LA5D7
		RTS
;			;  FloatA=1.0
;			;  ----------
fpLoad1
		LDA	#$80
		STA	ZP_FPA + 3			;  Set mantissa = $80000000
		INCA
		STA	ZP_FPA + 2			;  Set exponent = $81 - exp=2^1
		JUMP	zero_FPA_sign_expO_manlo		;  Zero rest of mantissa
tblDivConsts
		FCB	$02,$08,$08,$08
fpFPAeq1.0divFPA					; LA5E9
		LDX_FPC	fpConst1
		STX	ZP_FP_TMP_PTR1
fpFPAeqPTR1divFPA

		LDA	ZP_FPA + 3
		LBEQ	brkDivideByZero			; if MSB of divisor mantissa 0 then error
		CALL	fpMoveRealAtPTR1toFPB		; get dividend, if zero return 0
		BNE	1F
		JUMP	zero_FPA

1							;LA5FA:
;;		STU	ZP_TXTPTR
	IF CPU_6309
		PSHSW					
	ENDIF
		LDD	ZP_FPB				; get b for use below
		EORA	ZP_FPA
		STA	ZP_FPA				; store quotient sign in sign of FPA

;;		LDB	ZP_FPB + 1			; B got in LDD above
		CLRA
		ADDD	#$81
		SUBD	ZP_FPA + 1
		STD	ZP_FPA + 1			; subtract divisor exponent from quotient exponent and add 1

		LDX	#$05
		LDB	#$08
		STB	ZP_FPB+1
	IF CPU_6309
		LDW	ZP_FPB + 2			; cache top bits of mantissa
	ENDIF
		BRA	LA622
LA619
		STB	ZP_FP_TMP-1,X			; store ZP_FPB from end of loop
		LDB	tblDivConsts-1,X		; get new loop counter value from table
		STB	ZP_FPB+1
LA620
		BCS	LA638				; carry here has come from ROLA at POINT X
LA622
	IF CPU_6309
		LDD	ZP_FPA + 3
		CMPR	W,D
	ELSE
		LDA	ZP_FPA + 3			; this is kept as 8 bit for speed!
		CMPA	ZP_FPB + 2
		BNE	LA636
		LDA	ZP_FPA + 4
		CMPA	ZP_FPB + 3
;;		LDD	ZP_FPA + 3			; or 16 bit for size?
;;		CMPD	ZP_FPB + 2
	ENDIF

		BNE	LA636
		LDA	ZP_FPA + 5			; keep this 16 bit - unlikely to be hit?
		CMPA	ZP_FPB + 4
		BNE	LA636
		LDA	ZP_FPA + 6			; keep this 16 bit - unlikely to be hit?
		CMPA	ZP_FPB + 5
LA636
		BCC	LA64F
LA638
		
		LDD	ZP_FPB + 4
		SUBD	ZP_FPA + 5
		STD	ZP_FPB + 4
	IF CPU_6309
		LDD	ZP_FPA + 3
		SBCR	D,W
	ELSE
		LDA	ZP_FPB + 3
		SBCA	ZP_FPA + 4
		STA	ZP_FPB + 3
		LDA	ZP_FPB + 2
		SBCA	ZP_FPA + 3
		STA	ZP_FPB + 2
	ENDIF

		SEC
LA64F
		ROL	ZP_FPB				; store result bit into FPB
		ASL	ZP_FPB + 5
		ROL	ZP_FPB + 4
	IF CPU_6309
		ROLW
	ELSE
		ROL	ZP_FPB + 3
		ROL	ZP_FPB + 2			;;;POINT X
	ENDIF
		DEC	ZP_FPB + 1			; B here is loop counter
		BNE	LA620
		LDB	ZP_FPB
		LEAX	-1,X
		BNE	LA619
	IF CPU_6309
		LDD	ZP_FPB + 4
		ORR	W,D
	ELSE
		LDA	ZP_FPB + 2
		ORA	ZP_FPB + 3
		ORA	ZP_FPB + 4
		ORA	ZP_FPB + 5
	ENDIF
		BEQ	LA66B
		SEC
LA66B

;;		LDU	ZP_TXTPTR			; restore text pointer
	IF CPU_6309
		PULSW
		LDB	ZP_FPB
	ENDIF

		RORB
		RORB
		RORB
		ANDB	#$E0
		STB	ZP_FPA + 7


		LDD	ZP_FP_TMP
		STA	ZP_FPA + 6
		STB	ZP_FPA + 5

		LDD	ZP_FP_TMP + 2
		STA	ZP_FPA + 4
		STB	ZP_FPA + 3

		BMI	fpRoundMantissaFPA
		CALL	NormaliseRealA_3
;;		CALL	__NormaliseRealA_sk2
		BRA	fpRoundMantissaFPA


fpFPAeqXaddFPA
		CALL	fpMoveRealAtXtoFPB
		BRA	fpAddAtoBStoreAndRoundA
fpFPAeqPTR1subFPA
		CALL fpNegateFP_A
fpFPAeqPTR1addFPA
		CALL	fpMoveRealAtPTR1toFPB
		BEQ	anRTS2
fpAddAtoBStoreAndRoundA					; LA692
		CALL	fpAddAtoBStoreA
fpRoundMantissaFPA					; LA695
		LDA	ZP_FPA + 7
		CMPA	#$80
		BLO	2F
		BEQ	1F
		INC	ZP_FPA + 6
		BNE	2F
		CALL	fpIncFPAMantMSBs
		BRA	2F
fpFPAeqPTR1mulFPA
		CALL	fpFPAeqPTR1mulFPA_internal
		BRA	fpRoundMantissaFPA
1							; LA6AB
		SEC
		ROLA
		ORA	ZP_FPA + 6
		STA	ZP_FPA + 6
2							; LA6AE
		LDA	ZP_FPA + 1
		BEQ	zero_FPA_matLsb
		BPL	brkTooBig
		; TODO - speed up with 16bits?
zero_FPA
		CLR	ZP_FPA + 2		; exp
		CLR	ZP_FPA + 3		; mantissa MSB
zero_FPA_sign_expO_manlo
		CLR	ZP_FPA			; sign
		CLR	ZP_FPA + 1			; exponent overflow
		CLR	ZP_FPA + 4			; mantissa 
		CLR	ZP_FPA + 5			; mantissa
		CLR	ZP_FPA + 6			; mantissa
zero_FPA_matLsb						; LA6C2
		CLR	ZP_FPA + 7			; mantissa LSB
anRTS2		RTS
;
;
brkTooBig	DO_BRK_B
		FCB $14, "Too big", 0

		*************************************************
		*						*
		* Multiply FPA and 5 byte FP at PTR1		*
		* first PTR1 is unpacked to FPB in 7 byte format*
		* i.e. 1 byte for exponent			*
		*************************************************
		
fpFPAeqPTR1mulFPA_internal
		LDA	ZP_FPA + 3			; check for 0 in FPA, if 0 return 0
		BEQ	anRTS2
		CALL	fpMoveRealAtPTR1toFPB		; unpack to FPB in 7 byte form
		BEQ	zero_FPA			; if that is zero, clear FPA and return

		LDB	ZP_FPB + 1			; add exponents
		CLRA
		ADDD	ZP_FPA + 1
		SUBD	#$0080
		STD	ZP_FPA + 1

		LDA	ZP_FPA				; multiply signs
		EORA	ZP_FPB
		STA	ZP_FPA


		PSHS	X,U				; nothing to really save here but keep for later pops? X=D in BAS4128
		LDD	ZP_FPA + 3
		STD	ZP_FP_TMP
		LDD	ZP_FPA + 5
		STD	ZP_FP_TMP + 2
		CLRA
		CLRB
		STD	ZP_FPA + 3
		STD	ZP_FPA + 5
		STA	ZP_FPA + 7

							; do a long multiply adding result into FPA mantissa after
							; each byte is multiplied from the "bottom" number (in tmp)
							; shift FPA mantissa to the right by one byte, except last
							; like long multiplication at primary school

		LDY	#ZP_FP_TMP + 4			; point at current byte in "bottom" mantissa
mulloop		LDX	#ZP_FPB + 5			; point at number in "top" row (FPB)
mulloop3	LDU	#ZP_FPA + 6			; point at number in result (16 bit)
mulloop2	LDA	,Y
		BEQ	mul_skip_car1
		LDB	,X
		BEQ	mul_skip_car1
		MUL
		ADDD	,U
		STD	,U
		BCC	mul_skip_car1
		PSHS	U
1		CMPU	#ZP_FPA + 3
		BLS	2F
		INC	,-U
		BEQ	1B
2		PULS	U
mul_skip_car1	LEAU	-1,U
		LEAX	-1,X
		CMPX	#ZP_FPB + 2
		BHS	mulloop2
		CMPY	#ZP_FP_TMP
		BLS	mul_done
		; shift result right one byte
		LDD	ZP_FPA + 5
		STD	ZP_FPA + 6
		LDD	ZP_FPA + 3
		STD	ZP_FPA + 4
		CLR	ZP_FPA + 3
		LEAY	-1,Y
		BRA	mulloop
mul_done
		PULS	X,U
;		LDA	ZP_FPA + 3
		TSTA					; top byte of mant still in A
		LBPL	NormaliseRealA_3		; if top bit of FPA's mantissa not set then normalize it
		RTS
fnLN							;  =LN
		CALL evalLevel1ConvertReal
fnLN_FPA						; LA749
		PSHS	U
		CALL	fpCheckMant0SetSignExp0
		BEQ	brkLogRange
		BPL	LA766
brkLogRange
		DO_BRK_B
		FCB	$16, "Log range", 0
brkNegRoot
		DO_BRK_B
		FCB	$15, "-ve root", 0
LA766
		CALL	fpSetRealBMantTo0
		LDA	#$80
		STA	ZP_FPB
		STA	ZP_FPB + 2
		INCA	
		STA	ZP_FPB + 1
		LDB	ZP_FPA + 2
		BEQ	LA77C
		LDA	ZP_FPA + 3
		CMPA	#$B5
		LDA	#$81
		BCS	LA77E
LA77C
		INCB
		DECA
LA77E
		PSHS	B
		STA	ZP_FPA + 2
		CALL	fpAddAtoBStoreAndRoundA
		LDX	#BASWKSP_FPTEMP4
		CALL	fpCopyFPA_X
		LDX	#fpConst0_54625
		LDU	#fpConstMin0_5
		LDB	#$02
		CALL	LA861NewAPI
		LDX	#BASWKSP_FPTEMP4
		CALL	fpFPAeqXmulFPA
		CALL	fpFPAeqPTR1mulFPA
		CALL	fpFPAeqPTR1addFPA
		CALL	fpCopyFPA_FPTEMP1
		PULS	A
		SUBA	#$81
		CALL	IntToReal_8signedA2real_check
		LDX	#fpConst_ln_2
		CALL	fpFPAeqXmulFPA
		LDX	#BASWKSP_FPTEMP1
		STX	ZP_FP_TMP_PTR1
		CALL	fpFPAeqPTR1addFPA
		LDA	#$FF
		PULS	U,PC

retAeqFF
		LDA	#$FF
		RTS
;		
;		
fnSQR

			;  =cmd
		CALL	evalLevel1ConvertReal
fpFPAeq_sqr_FPA
		CALL	fpCheckMant0SetSignExp0
		BEQ	retAeqFF
		BMI	brkNegRoot
		LDA	ZP_FPA + 2
		LSRA
		PSHS	CC
		ADCA	#$41
		STA	ZP_FPA + 2
		PULS	CC
		BCC	fpFPAeq_sqr_FPA_sk6
		CALL	FPAshr1
fpFPAeq_sqr_FPA_sk6
		CALL	fpSetRealBto0
		CLRA
		STA	ZP_FP_TMP
		STA	ZP_FP_TMP + 1
		STA	ZP_FP_TMP + 2
		STA	ZP_FP_TMP + 3
		LDA	#$40
		STA	ZP_FPB + 2
		STA	ZP_FPB + 7
		LDX	#$0
		LDB	#$10
		STB	ZP_FP_TMP_PTR2
		LDA	ZP_FPA + 3
		SUBA	#$40
		STA	ZP_FPA + 3
fpFPAeq_sqr_FPA_lp1		
		LDA	ZP_FP_TMP_PTR2
		EORA	ZP_FPB + 2,X
		STA	ZP_FP_TMP - 1,X
		LDA	ZP_FPA + 3
		CMPA	ZP_FPB + 7
		BNE	fpFPAeq_sqr_FPA_sk2
		PSHS	X
		LDX	#$0				
fpFPAeq_sqr_FPA_lp2
		LDA	ZP_FPA + 4, X
		CMPA	ZP_FP_TMP, X
		BNE	fpFPAeq_sqr_FPA_sk1
		LEAX	1,X
		CMPX	#4
		BNE	fpFPAeq_sqr_FPA_lp2
fpFPAeq_sqr_FPA_sk1
		PULS	X
fpFPAeq_sqr_FPA_sk2
		BCS	fpFPAeq_sqr_FPA_sk3
		LDD	ZP_FPA + 6
		SUBD	ZP_FP_TMP + 2
		STD	ZP_FPA + 6
		LDD	ZP_FPA + 4
		SBCB	ZP_FP_TMP + 1
		SBCA	ZP_FP_TMP + 0
		STD	ZP_FPA + 4
		LDA	ZP_FPA + 3
		SBCA	ZP_FPB + 7
		STA	ZP_FPA + 3
		LDA	ZP_FP_TMP_PTR2
		ASLA
		BCC	fpFPAeq_sqr_FPA_sk4
		INCA
		EORA	ZP_FPB + 1,X
		STA	ZP_FPB + 1,X
		STA	ZP_FP_TMP  - 2,X
fpFPAeq_sqr_FPA_sk3
		LDA	ZP_FPB + 2,X
		BRA	fpFPAeq_sqr_FPA_sk5
fpFPAeq_sqr_FPA_sk4
		EORA	ZP_FPB + 2,X
		STA	ZP_FPB + 2,X
fpFPAeq_sqr_FPA_sk5
		STA	ZP_FP_TMP - 1,X
		ASL	ZP_FPA + 7
		ROL	ZP_FPA + 6
		ROL	ZP_FPA + 5
		ROL	ZP_FPA + 4
		ROL	ZP_FPA + 3
		LSR	ZP_FP_TMP_PTR2
		BCC	fpFPAeq_sqr_FPA_lp1
		LDB	#$80
		STB	ZP_FP_TMP_PTR2
		LEAX	1,X
		CMPX	#5
		BNE	fpFPAeq_sqr_FPA_lp1
		CALL	fpCopyBManttoA_NewAPI
fpNormalizeAndReturnFPA					; LA854
		LDA	ZP_FPA + 3
		BMI	1F
		CALL	NormaliseRealA_3
1		CALL	fpRoundMantissaFPA
		LDA	#$FF
		RTS
LA861NewAPI
*		B -> # of iterations
*		X -> table of constants to use
*		U -> constant to use if FPA is too small		( was A )
* IF FPA < 0.5e-40 THEN FPA = U
* ELSE 
*	FPTEMP1 = 1/FPA
*	FPA 	= X(0) + FPTEMP1
*	I%=1
*	REPEAT
*		FPA = FPTEMP1 + X(I% + 1) + X(I%) / FPA
*		B = B - 1
*		I% = I% + 2
*	UNTIL B = 0


		STB	ZP_FP_TMP + 4			;						iter = B
		STX	ZP_FP_TMP_PTR2			;						PTR2 = tablestart
		LDA	ZP_FPA + 2			; get FPA exponent				
		CMPA	#$40				;						if ABS(FPA)<1E-64
		BLO	fpUtoPTR1toFPA			; if <-$40 approximate as constant at Y			RETURN default from Y
		CALL	fpFPAeq1.0divFPA		;						FPA=1/FPA
		CALL	fpCopyFPA_FPTEMP1		;						TMP=FPA
		LDX	ZP_FP_TMP_PTR2			;			
		STX	ZP_FP_TMP_PTR1			;						PTR1 = tablestart
		CALL	fpFPAeqPTR1addFPA		;						FPA = X(0) + 1/FPA
LA879							;						REPEAT
		CALL	LA886				;							CALL LA886
		LDX	#BASWKSP_FPTEMP1
		STX	ZP_FP_TMP_PTR1
		CALL	fpFPAeqPTR1addFPA
		DEC	ZP_FP_TMP + 4
		BNE	LA879
LA886
		CALL	fpAdd5toPTR2copytoPTR1
		CALL	fpFPAeqPTR1divFPA
		CALL	fpAdd5toPTR2copytoPTR1
		JUMP	fpFPAeqPTR1addFPA
fpUtoPTR1toFPA						; LA896
		STU	ZP_FP_TMP_PTR1
		JUMP	fpCopyPTR1toFPA
fnACS

			
			;  =ACS
		CALL	fnASN
		BRA	fpFPAEqPiDiv2SubFPA
fnASN
		CALL	evalLevel1ConvertReal
		LDA	ZP_FPA
		BPL	LA8AF				; jump forward if arg is positive
		CLR	ZP_FPA				; else make positive
		CALL	LA8AF				; call positive ASN code (returns with A=FF)
		BRA	LA8D2				; jump forward to set FPA sign to FF
LA8AF
		CALL	fpCopyFPA_FPTEMP3		; FPTEMP3 = FPA
		CALL	LA929				; call SQR(x*x-1)
		LDA	ZP_FPA + 3			; check result is zero
		BEQ	fpSetFPAeqPIdiv2		; if so set FPA=PI/2
		CALL	fpFPAeqFPTEMP3divFPA		; LA5B3
		BRA	LA8C6				; Call ATN
fpSetFPAeqPIdiv2					; LA8BE
		LDX	#fpConstPiDiv2
		JUMP	fpCopyXtoFPA
fnATN
		CALL	evalLevel1ConvertReal
LA8C6
		CALL	fpCheckMant0SetSignExp0
		BEQ	LA926_retFF
		BPL	LA8D5
		CLR	ZP_FPA
		CALL	LA8D5
LA8D2		STA	ZP_FPA				; set minus result and return FF
		RTS
LA8D5
		LDA	ZP_FPA + 2
		CMPA	#$81
		BLO	LA8EA
		CALL	fpFPAeq1.0divFPA
		CALL	LA8EA
fpFPAEqPiDiv2SubFPA					; LA8E1
		LDX	#fpConstPiDiv2
		STX	ZP_FP_TMP_PTR1
		CALL	fpFPAeqPTR1subFPA
		LDA	#$FF
		RTS
LA8EA
		LDA	ZP_FPA + 2
		CMPA	#$73
		BLO	LA926_retFF
		CALL	fpCopyFPA_FPTEMP3
		CALL	fpSetRealBMantTo0
		LDA	#$80
		STA	ZP_FPB + 1
		STA	ZP_FPB + 2
		STA	ZP_FPB
		CALL	fpAddAtoBStoreAndRoundA
		PSHS	U
		LDX	#fpConstMin0_08005
		LDU	#fpConst0_9273
		LDB	#$04
		CALL	LA861NewAPI
		CALL	fpFPAeqFPTEMP3mulFPA
		PULS	U,PC



fnSIN			; LA90D!

;			;  =SIN
		CLC
		BRA	fnSINenter

fnCOS
		SEC
;			;  =COS
fnSINenter
		PSHS	CC			; Save CC to see whether its sin or cos
		CALL	trigNormaltheta
		PULS	CC
		BCC	fnSIN_internal1
fnCOS_internal1					; LA915
		INC	ZP_FP_TMP + 6
fnSIN_internal1					; LA917
		LDA	ZP_FP_TMP + 6
		BITA	#$02
		BEQ	LA923
		CALL	LA923
		JUMP	fpNegateFP_A
LA923
		LSRA
		BCS	LA929
LA926_retFF					; LA926
		LDA	#$FF
		RTS
LA929
		CALL	fpCopyFPA_FPTEMP1
		CALL	fpFPAeqPTR1mulFPA
		LDX_FPC	fpConst1
		STX	ZP_FP_TMP_PTR1
		CALL	fpFPAeqPTR1subFPA
		CALL	fpFPAeq_sqr_FPA
		RTS
trigNormaltheta							; LA93A
		CALL	evalLevel1ConvertReal
		LDA	ZP_FPA + 2
		CMPA	#$98
		BHS	brkAccuracyLost
		CALL	fpCopyFPA_FPTEMP1
		LDX_FPC	fpConstPiDiv2
		CALL	fpMoveRealAtXtoFPB			; FPB = PI/2
		LDA	ZP_FPA
		STA	ZP_FPB				; change FPB's sign to same as FPA
		DEC	ZP_FPB + 1				; decrement exponent FPB = PI
		CALL	fpAddAtoBStoreAndRoundA			; add to FPA
		LDX_FPC	fpConst2DivPi				; multiply by 2/PI
		CALL	fpFPAeqXmulFPA
		CALL	fpReal2Int				; take the real part
		LDA	ZP_INT_WA + 3				; get low byte
		STA	ZP_FP_TMP + 6				; store number of PIs (gets inc'd for sin in main routine...)
		ORA	ZP_INT_WA + 1
		ORA	ZP_INT_WA + 2
		BEQ	LA98D
		CALL	IntToReal2				; if not zero then store
		LDX	#BASWKSP_FPTEMP2			; integer part (as real)
		CALL	fpCopyFPA_X				; to BASWKSP_FPTEMP2
		LDX_FPC	fpConstMinPiDiv2
		CALL	fpFPAeqXmulFPA				; now equals number of PI/2's to add to original param
;;;;?		CALL	FPPTR1=BASWKSP_FPTEMP1
		LDX	#BASWKSP_FPTEMP1
		STX	ZP_FP_TMP_PTR1
		CALL	fpFPAeqPTR1addFPA			; add them to normalize param
		CALL	fpCopyFPA_PTR1				; store normalized param at FPTEMP1
		LDX	#BASWKSP_FPTEMP2
		CALL	fpCopyXtoFPA
		LDX_FPC	fpConst4_454e_6				; multiply number of cycles by 4.454e-6??? correction???
		CALL	fpFPAeqXmulFPA
		LDX	#BASWKSP_FPTEMP1
		CALL	fpFPAeqXaddFPA
		BRA	LA990
LA98D
		CALL fpCopyFPTEMP1toFPA
LA990
		LDX	#BASWKSP_FPTEMP3
		STX	ZP_FP_TMP_PTR1
		CALL	fpCopyFPA_PTR1
		CALL	fpFPAeqPTR1mulFPA			; FPA = FPA * FPA ???
		LDX_FPC	fpConstMin0_011909
		PSHS	U
		LDU_FPC	fpConst1
		LDB	#$02
		CALL	LA861NewAPI
		PULS	U
fpFPAeqFPTEMP3mulFPA
		LDX	#BASWKSP_FPTEMP3

**	NOTE: API change here was YA not X
;;LA9A1 removed was A + $400, now X

fpFPAeqXmulFPA
		STX	ZP_FP_TMP_PTR1
		CALL	fpFPAeqPTR1mulFPA
		LDA	#$FF
		RTS
brkAccuracyLost						; LA9AD
		DO_BRK_B
		FCB	$17, "Accuracy lost", 0
brkExpRange						; LA9BC
		DO_BRK_B
		FCB	$18, "Exp range", 0

fnRAD			; LA9C8!

			;  =RAD
		CALL	evalLevel1ConvertReal
		LDX_FPC fpConstDeg2Rad
		BRA	fpFPAeqXmulFPA
fnLOG

			;  =LOG
		CALL	fnLN
		LDX_FPC	fpConst0_43429
		BRA	fpFPAeqXmulFPA
fnDEG

			;  =DEG
		CALL	evalLevel1ConvertReal
		LDX_FPC	fpConstRad2Deg
		BRA 	fpFPAeqXmulFPA
fnEXP			;  =EXP
		CALL	evalLevel1ConvertReal
fnEXP_int
		PSHS	U
		LDA	ZP_FPA + 2
		CMPA	#$87
		BLO	LA9F7
		BNE	LA9F0
		LDB	ZP_FPA + 3
		CMPB	#$B3
		BLO	LA9F7
LA9F0		LDA	ZP_FPA
		BPL	brkExpRange
		JUMP	zero_FPA
LA9F7		CALL	fpFPASplitToFractPlusInt
		LDX	#fpConst0_07121
		LDU	#fpConst1__2
		LDB	#$03
		CALL	LA861NewAPI
		CALL	fpCopyFPA_FPTEMP3
		LDU	#fpConst_e
		CALL	fpUtoPTR1toFPA
		LDA	ZP_FP_TMP + 6
		CALL	FPAeqFPAraisedToA
		CALL	fpFPAeqFPTEMP3mulFPA
		PULS	U,PC

	IF FLEX != 1
callOSByte81withXYfromINT
		CALL	evalLevel1checkTypeStoreAsINT
		LDA	#$81
		LDX	ZP_INT_WA + 2
		LDY	ZP_INT_WA + 1
		JMP	OSBYTE
					; Returns X=16bit OSBYTE return value

		; note: the RND accumulator is in a different order to 6502
		; 0->3
		; 1->2
		; 2->1
		; 3->0
		; 4->4
		; this makes integer ops easier but adds slight complexity to loading into FPA 
	ENDIF

fnRND_1							; LAA1E
		CALL	rndNext
fnRND_0							; LAA21
		CLR	ZP_FPA
		CLR	ZP_FPA + 1
		CLR	ZP_FPA + 7
		LDA	#$80
		STA	ZP_FPA + 2


		; DB: 2022/9/14 - copy to FPA mantissa, most sig 4 bytes NOT reversing order as already BE

		LDX	#4
1		EORA	ZP_RND_WA-1,X
		STA	ZP_FPA+2,X
		LEAX	-1,X
		BNE	1B


		JUMP	fpNormalizeAndReturnFPA
fnRND_int						; RND(X)
		LEAU	1,U
		CALL	evalL1BracketAlreadyOpenConvert2INT
		LDA	ZP_INT_WA + 0			; see if sign is -ve, if so randomize
		BMI	fnRND_randomize
		ORA	ZP_INT_WA + 2
		ORA	ZP_INT_WA + 1
		BNE	LAA52				; >255
		LDA	ZP_INT_WA + 3	
		BEQ	fnRND_0				; ==0
LAA4E
		CMPA	#$01
		BEQ	fnRND_1
LAA52
		CALL	IntToReal
		CALL	fpStackWAtoStackReal
		CALL	fnRND_1
		CALL	popFPandSetPTR1toStack
		CALL	fpFPAeqPTR1mulFPA_internal
		CALL	fpReal2Int
		CALL	inc_INT_WA
		BRA	LAA90_rtsA40
fnRND_randomize						; LAA69
		LDX	#ZP_RND_WA
		CALL	CopyIntWA2X
		LDA	#$40
		STA	ZP_RND_WA + 4
		RTS
fnRND			; LAA73!
		LDA	,U
		CMPA	#'('
		BEQ	fnRND_int
		CALL	rndNext
		LDX	#ZP_RND_WA
intLoadWAFromX
		LDD	0,X
		STD	ZP_INT_WA + 0
		LDD	2,X
		STD	ZP_INT_WA + 2
LAA90_rtsA40
		LDA	#$40
		RTS
;			;  =NOT
fnNOT

		CALL	evalLevel1checkTypeStoreAsINT
		LDB	#$03
		LDX	#ZP_INT_WA
LAA98		COM	B,X
		DECB
		BPL	LAA98
		BRA	LAA90_rtsA40
fnPOS			; LAAA3!
		CALL	fnVPOS
		STX	ZP_INT_WA+2
		RTS
fnUSR			; LAAA9!

			
			;  =USR
		CALL	evalLevel1checkTypeStoreAsINT
		PSHS	U
		CALL	callusrSetRegsEnterCode
		PSHS	CC
		STU	ZP_INT_WA + 1			; note store 16 bit regs one less to get low bytes
		STX	ZP_INT_WA + 0
		STA	ZP_INT_WA + 3
		PULS	A
		STA	ZP_INT_WA + 0
		PULS	U
		BRA	LAA90_rtsA40
fnVPOS			; LAABC!
	IF FLEX
		JUMP	brkFlexNotImpl
	ELSE
		LDA	#$86
		JSR	OSBYTE
		TFR	Y,D
		JUMP	retB8asUINT
	ENDIF

			;  =EXT#channel - read open file extent
			; -------------------------------------
fnEXT
	IF FLEX = 1
		JUMP	brkFlexNotImpl
	ELSE
		LDA	#$02			; 02=Read EXT
		BRA	varGetFInfo
	ENDIF
			;  =PTR#channel - read open file pointer
			; --------------------------------------
varGetPTR
	IF FLEX = 1
		JUMP	brkFlexNotImpl
	ELSE
		CLRA				; 00=Read PTR
varGetFInfo
		PSHS	A
		CALL	evalHashChannel		; Evaluate #channel, save TXTPTR, Y=channel
		LDX	#ZP_INT_WA
		PULS	A
		JSR	OSARGS			; Read to INTA
		LDU	ZP_TXTPTR		; Get TXTPTR back
		TST	ZP_BIGEND
		LBMI	SwapEndian		; Swap INTA
		RTS
	ENDIF
			;  =BGET#channel - get byte from open file
			; ----------------------------------------
fnBGET
	IF FLEX = 1
		JUMP	brkFlexNotImpl
	ELSE
		CALL	evalHashChannel		; Evaluate #channel, save TXTPTR, Y=channel
		JSR	OSBGET			; Read byte
		LDU	ZP_TXTPTR		; Get TXTPTR back
		JUMP	retA8asUINT
	ENDIF
			;  =OPENIN f$ - open file for input
			;  ================================
fnOPENIN
	IF FLEX = 1
		JUMP	brkFlexNotImpl
	ELSE
		LDA #$40
		BRA fileOpen			;  OPENIN is OSFIND $40
	ENDIF
			;  =OPENOUT f$ - open file for output
			;  ==================================
fnOPENOUT
	IF FLEX = 1
		JUMP	brkFlexNotImpl
	ELSE
		LDA #$80
		BRA fileOpen			;  OPENOUT is OSFIND $80
	ENDIF
;			;  =OPENUP f$ - open file for update
;			;  =================================
fnOPENUP
	IF FLEX = 1
		JUMP	brkFlexNotImpl
	ELSE
		LDA #$C0			;  OPENUP is OSFIND $C0
	ENDIF
fileOpen
	IF FLEX = 1
		JUMP	brkFlexNotImpl
	ELSE
		PSHS	A
		CALL	evalLevel1
		LBNE 	brkTypeMismatch
		CALL	str600CRterm
		PULS	A
		JSR	OSFIND
		JUMP	retA8asUINT
	ENDIF
;
fnPI							; LAAFF!
		CALL	fpSetFPAeqPIdiv2			; load PI/2 into FPA and increment exponent for PI
		INC	ZP_FPA + 2
		RTS

;			;  =EVAL string$ - Tokenise and evaluate expression
;			;  ================================================
fnEVAL			
		CALL	evalLevel1
		LBNE	brkTypeMismatch			;  Evaluate value, error if not string
		LDB	ZP_STRBUFLEN
		INC	ZP_STRBUFLEN
		LDX	#BASWKSP_STRING
		ABX
		LDA	#$0D
		STA	,X				;  Put in terminating <cr>
		CALL	StackString			;  Stack the string
			;  String has to be stacked as otherwise would
			;   be overwritten by any string operations
			;   called by Evaluator
		pshs	U
		ldu	ZP_BAS_SP
		leau	1,U				; skip length byte on stack
		CALL 	L8E1F				;  Tokenise string on stack at GPTR
		ldu	ZP_BAS_SP
		leau	1,U
		CALL 	evalAtY				;  Call expression evaluator
		CALL 	popStackedStringNew		;  Drop string from stack


		PULS	U
		LDA	ZP_VARTYPE			;  Get expression return value
		RTS					;  And return
;
;
fnVAL

			;  =VAL
		CALL	evalLevel1
		LBNE	brkTypeMismatch
str2Num		LDB	ZP_STRBUFLEN
		LDX	#BASWKSP_STRING
		ABX
		CLR	,X
		PSHS	U
		LDU	#BASWKSP_STRING
		CALL	skipSpacesY
		CMPA	#'-'
		BEQ	1F
		CMPA	#'+'
		BNE	2F
		CALL	skipSpacesY
2		CALL	parseDecimalLiteral
		BRA 	3F
1		CALL	skipSpacesY
		CALL	parseDecimalLiteral
		BCC	3F
		CALL	evalLevel1CheckNotStringAndNegate
3		STA	ZP_VARTYPE
		PULS	U,PC
;		
;		
fnINT

		CALL	evalLevel1
		LBEQ	brkTypeMismatch
		BPL	1F			; already an INT
		LDA	ZP_FPA
		PSHS	CC			; get sign in Z flag and save
		CALL 	fpFPAMant2Int_remainder_inFPB
		PULS	CC
		BPL	LABAD			; if positive don't round down, just return FPA mant as int
		LDA	ZP_FPB + 2
		ORA	ZP_FPB + 3
		ORA	ZP_FPB + 4
		ORA	ZP_FPB + 5
		BEQ	LABAD			; if remainder is 0 don't round down
		CALL	fpReal2Int_NegateMantissa	; round down by decrementing mantissa - TODO: speed this up if room
		CALL	fpIncrementFPAMantissa
		CALL	fpReal2Int_NegateMantissa
LABAD
		CALL	fpCopyAmant2intWA
		LDA	#$40
1		RTS				;LABB2:



fnASC
		CALL	evalLevel1
		LBNE	brkTypeMismatch
		LDA	ZP_STRBUFLEN
		BEQ	returnINTminus1
		LDB	BAS_StrA
		JUMP	retB8asUINT

fnINKEY		;  =INKEY
	IF FLEX = 1
		JUMP	brkFlexNotImpl
	ELSE
		CALL	callOSByte81withXYfromINT
		CMPX	#$8000				; Check if X<0
		BHS	returnINTminus1
		JUMP	retX16asUINT
	ENDIF

			;  =EOF#channel - return EndOfFile status - here to be near fnTRUE and fnFALSE
			;  ===========================================================================
fnEOF
	IF FLEX = 1
		JUMP	brkFlexNotImpl
	ELSE
		CALL	evalHashChannel		; Evaluate #channel, save TXTPTR, Y=channel
		LEAX	,Y			; X=channel
		LDA	#$7F
		JSR	OSBYTE			; OSBYTE $7F to read EOF
		LEAX	0,X			; Test X
		BEQ	varFALSE		; If &00, return FALSE
						; Otherwise, return TRUE
						;  Otherwise, return TRUE
	ENDIF
			;  =TRUE
			;  =====
returnINTminus1					; TODO - possibly use D?
		LDB #$FF			;  Return -1
returnB8asINT_S	SEX
		STA ZP_INT_WA
		STA ZP_INT_WA + 1
		STD ZP_INT_WA + 2
returnINT	LDA #$40
		RTS				;  Return Integer
			;  =FALSE
			;  ======
varFALSE			
		CLRB
		BRA returnB8asINT_S			;  Jump to return 0


fnSGN_real						; LABEC
		CALL	fpCheckMant0SetSignExp0
		BEQ	varFALSE
		BPL	fnSGN_pos
		BRA	returnINTminus1
fnSGN							; LABF5!
		CALL	evalLevel1
		LBEQ	brkTypeMismatch
		BMI	fnSGN_real

		CALL	IntWAZero

		BMI	returnINTminus1

		BEQ	returnINT
fnSGN_pos	LDB	#1
		BRA	returnB8asINT_S


fnPOINT			; LAC0E!
			; TODO: use hw stack?
		CALL	evalAtYcheckTypeInAConvert2INT
		CALL	stackINT_WAasINT		; stack X coord
		CALL	skipSpacesCheckCommaAtYOrBRK
		CALL	evalL1BracketAlreadyOpenConvert2INT
		LDD	ZP_INT_WA+2			; get Y coordinate big-endian
		PSHS	D
		CALL	popIntANew
		LDD	ZP_INT_WA+2			; get X coordinate big-endian
		EXG	A,B
		STD	ZP_INT_WA			; store X coordinate little-endian
		PULS	D
		EXG	A,B
		STD	ZP_INT_WA+2			; store Y coordinate little-endian
		LDX	#ZP_INT_WA
		LDA	#9
		JSR	OSWORD
		LDB	ZP_INT_WA+4
		BMI	returnINTminus1
		BRA	returnB8asINT_S
fnINSTR

		CALL	evalAtY
		TSTA
		LBNE	brkTypeMismatch
		CMPB	#','
		LBNE	brkMissingComma
		INC	ZP_TXTOFF2
		CALL	StackString
		LEAU	1,U
		CALL	evalAtY
		TSTA
		LBNE	brkTypeMismatch
		CALL	StackString
		LDA	#$01
		STA	ZP_INT_WA + 3			; Default starting index (rest of INT_WA ignored)
		LEAU	1,U
;;		INC	ZP_TXTOFF2
		CMPB	#')'
		BEQ	fnINSTR_sk_nop3
		CMPB	#','
		LBNE	brkMissingComma
		CALL	evalL1BracketAlreadyOpenConvert2INT

fnINSTR_sk_nop3	TST	ZP_INT_WA + 3
		BNE	1F
		INC	ZP_INT_WA + 3			; if 0 make 1
1		DEC	ZP_INT_WA + 3			; now make it 0 based!

		PSHS	U				; save Y we're about to use it for matching
		CLRA
		LDU	ZP_BAS_SP
		LDB	,U+				; D now contains length of second string
		STB	ZP_INT_WA
		LEAX	,U				; X now points to start of second string
		LEAU	D,U				; unstack string but leave in place for tests below
		LDB	,U+				; D now contains length of first string
		STB	ZP_INT_WA + 1
		LEAY	,U				; U points to start of 1st string
		LEAU	D,U				; unstack string but leave in place
		STU	ZP_BAS_SP
		LDB	ZP_INT_WA + 3
		LEAY	D,Y				; skip to param 3 offset

fnINSTR_lp1	
		LDA	ZP_INT_WA + 3
		ADDA	ZP_INT_WA
		CMPA	ZP_INT_WA + 1
		BHI	fnINSTR_notfound		; if length of match and offset > length of 1st param no match
		PSHS	X,Y				; save X,Y
		LDB	ZP_INT_WA
1		LDA	,X+
		CMPA	,Y+
		BNE	fnINSTR_sknom			; nomatch try moving on one
		DECB
		BNE	1B
		; we have a match
		LEAS	4,S				; discard saved X,Y
		PULS	U				; get back original Y
		LDA	ZP_INT_WA + 3
		INCA					; make back to 1 based
		JUMP	retA8asUINT
fnINSTR_sknom	PULS	X,Y
		LEAY	1,Y
		INC	ZP_INT_WA + 3
		BRA	fnINSTR_lp1

fnINSTR_notfound
		PULS	U
		CLRA
		JUMP	retA8asUINT


;		CALL	popStackedString
;LAC60:
;		LDX ZP_INT_WA
;		BNE LAC66
;		LDX #$01
;LAC66:
;		STX ZP_INT_WA
;		TXA
;		DEX
;		STX ZP_INT_WA + 3
;		CLC
;		ADC ZP_BAS_SP
;		STA ZP_GEN_PTR
;		LDA #$00
;		ADC ZP_BAS_SP + 1
;		STA ZP_GEN_PTR + 1
;		LDA (ZP_BAS_SP)
;		SEC
;		SBC ZP_INT_WA + 3
;		BCC LAC9F
;		SBC ZP_STRBUFLEN
;		BCC LAC9F
;		ADC #$00
;		STA ZP_INT_WA + 1
;		CALL LBCE1
;LAC89:
;		LDU #$00
;		LDX ZP_STRBUFLEN
;		BEQ LAC9A
;LAC8F:
;		LDA (ZP_GEN_PTR),Y
;		CMP $0600,Y
;		BNE LACA6
;		INY
;		DEX
;		BNE LAC8F
;LAC9A:
;		LDA ZP_INT_WA
;LAC9C:
;		LBRA retA8asUINT
;LAC9F:
;		CALL LBCE1
;LACA2:
;		LDA #$00
;		BRA LAC9C
;LACA6:
;		INC ZP_INT_WA
;		DEC ZP_INT_WA + 1
;		BEQ LACA2
;		INC ZP_GEN_PTR
;		BNE LAC89
;		INC ZP_GEN_PTR + 1
;		BRA LAC89
;JUMPBrkTypeMismatch:
;		JUMP brkTypeMismatch
;		
fnABS			;  =ABS
		CALL	evalLevel1
		LBEQ	brkTypeMismatch
		BMI 	fpClearWA_A_sign
intWA_ABS	TST	ZP_INT_WA + 0
		BMI	negateIntA
		BRA	A_eq_40_rts
fpClearWA_A_sign
		CLR	ZP_FPA
		RTS
;			;  Negate real
;			;  -----------
fpFPAeqPTR1subFPAnegFPA					; LACC7
		CALL	fpFPAeqPTR1subFPA		; A = PTR1 - A, then negate A == A - PTR1
fpNegateFP_A
		LDA	ZP_FPA + 3
		BEQ	1F				;  Mantissa=0 - zero
	IF CPU_6309
		EIM	#$80,ZP_FPA
	ELSE
		LDA	ZP_FPA
		EORA	#$80
		STA	ZP_FPA			;  Negate sign fp sign
	ENDIF
1		LDA #$FF
		RTS					;  Return real

;			;  -<value>
;			;  --------
evalLevel1UnaryMinus
		CALL	evalLevel1UnaryPlus		;  Call Level 1 Evaluator, get next value
evalLevel1CheckNotStringAndNegate			; LACDA
		LBEQ	brkTypeMismatch			;  -<string> - Type mismatch
		BMI	fpNegateFP_A			;  -<real> - Jump to negate real
;		
negateIntA	
		LDD	#0
		SUBD	ZP_INT_WA + 2
		STD	ZP_INT_WA + 2
		LDD	#0
		SBCB	ZP_INT_WA + 1
		SBCA	ZP_INT_WA + 0
		STD	ZP_INT_WA + 0
A_eq_40_rts	LDA	#$40
		RTS
;		
;		
readCommaSepString					; LACF8
		CALL	skipSpacesY
		CMPA	#'"'
		BEQ	evalLevel1StringLiteral
		LDX	#BAS_StrA
		LEAU	-1,U
1		LDA	,U+
		STA	,X+
		CMPA	#$0D
		BEQ	LAD10
		CMPA	#','
		BNE	1B
LAD10		LEAU	-1,U
		TFR	X,D
		DECB
		STB	ZP_STRBUFLEN
		LDA #$00
		RTS
;			;  String value
;			;  ------------
evalLevel1StringLiteral				;LAD19:
		LDX 	#BAS_StrA
evalLevel1StringLiteral_lp			;LAD1C:
		LDA 	,U+
		CMPA	#$0D
		LBEQ	brkMissingQuote
		STA	,X+
		CMPA	#'"'
		BNE	evalLevel1StringLiteral_lp
		LDA	,U+
		CMPA	#'"'
		BEQ	evalLevel1StringLiteral_lp
		LEAU	-1,U
		TFR	X,D
		DECB
		STB	ZP_STRBUFLEN
		CLRA
		RTS
;		
;			;  Evaluator Level 1 - $ - + () " ? ! | $ function variable
;			;  ========================================================
;			;  Evaluate a value - called by functions for value parameters
;			;
evalLevel1						; LAD36
;				LEAU	1,Y		; TODO - not sure whether to inc here or after
		LDA	,U+				;  Get next character
		CMPA	#' '
		BEQ	evalLevel1			;  Skip spaces
		CMPA	#'-'
		BEQ	evalLevel1UnaryMinus		;  Unary minus
		CMPA	#'"'
		BEQ	evalLevel1StringLiteral		;  String
		CMPA	#'+'
		BNE	_sk2NotUnPlus			;  Not unary plus
;			
;		;  +<value>
;		;  --------		   
evalLevel1UnaryPlus					; LAD4C
		CALL	skipSpacesY
_sk2NotUnPlus	CMPA	#tknOPENIN
		BLO	evalL1_sk1			;  Not a function, try indirection and immediate value
		CMPA	#tknAUTO
		BHS	brkNoSuchVar			;  A command, not a function
		JUMP	exeTokenInA			;  Jump to dispatch function
evalL1_sk1	CMPA	#'?'
		BHS	evalL1MemOrVar			;  ?, @, A+ - variable or ?value
		CMPA	#'.'
		BHS	evalL1ImmedNum			;  ./0-9    - decimal number
		CMPA	#'&'
		BEQ	evalL1ImmedHex			;  Jump for &hex
		CMPA	#'('
		BEQ	evalL1BracketAlreadyOpen		;  Jump for (expression
							; Fall through with !value

;		;  !value, ?value, variable
;		;  ------------------------
evalL1MemOrVar						;LAD6A
							;  Point to start of name + 1
		CALL	findVarAtYMinus1		;  Search for !value ?value or variable
		BEQ	NoSuchVar			;  Look for variable, jump if doesn't exist
		JUMP	GetVarValNewAPI			;  Fetch variable's value
;		;  Immediate number
;		;  ----------------
evalL1ImmedNum						;LAD74:
		CALL	parseDecimalLiteral		;  Scan in decimal number
		BCC	brkNoSuchVar
		RTS				;  Error if not a decimal number
;		
;		;  Variable not found
;		;  ------------------
NoSuchVar	LDA	ZP_OPT			;  Get assembler OPTion
		ANDA	#$02
		BNE	brkNoSuchVar		;  If OPT 2 set, give No such variable error
		BCS	brkNoSuchVar		;  If invalid variable name, also give error
GetP_percent	LDD	VAR_P_PERCENT+2
		JUMP	retD16asUINT
brkNoSuchVar
		DO_BRK_B
		FCB	$1A, "No such variable", 0
brkMissingEndBracket				; LAD9E
		DO_BRK_B
		FCB	$1B, tknMissing, ")", 0
brkBadHex					; LADA2
		DO_BRK_B
		FCB	$1C, "Bad Hex", 0

;			;  (expression
;			;  -----------
evalL1BracketAlreadyOpen					; LADAC
		CALL	evalAtY				;  Call Level 7 Expression Evaluator
		LEAU	1,U
		CMPB	#')'
		BNE	brkMissingEndBracket		;  No terminating ')'
		TSTA
		RTS					;  Return result


evalL1ImmedHex			      ;LADB7
		CALL	varFALSE			; 0 intA
		CLRB
evalL1ImmedHex_lp					; LADBB
		LDA	,U+				; get digit
		CMPA	#'0'
		BLO	evalL1ImmedHex_skNotDig
		CMPA	#'9'
		BLS	evalL1ImmedHex_skGotDig
		SUBA	#'A' - $A			; hopefully got 'A-F', subtract to make 10-15
		CMPA	#$0A
		BLO	evalL1ImmedHex_skNotDig
		CMPA	#$10
		BHS	evalL1ImmedHex_skNotDig
evalL1ImmedHex_skGotDig
		ASLA
		ASLA
		ASLA
		ASLA					; shift into top nybble
		LDB	#$03
evalL1ImmedHex_lpShiftAcc
		ASLA					; shift into IntA
		ROL	ZP_INT_WA + 3
		ROL	ZP_INT_WA + 2
		ROL	ZP_INT_WA + 1
		ROL	ZP_INT_WA + 0
		DECB
		BPL	evalL1ImmedHex_lpShiftAcc
		BRA	evalL1ImmedHex_lp
evalL1ImmedHex_skNotDig					; LADE4
		TSTB
		BPL	brkBadHex
		LEAU	-1,U
		STU	ZP_TXTPTR2
		LDA	#$40
		RTS

fnADVAL
	IF FLEX  = 1
		JUMP	brkFlexNotImpl
	ELSE
		CALL	evalLevel1checkTypeStoreAsINT
		PSHS	y
		LDX	ZP_INT_WA + 2					
		LDA	#$80
		JSR	OSBYTE
		PULS	U
		BRA	retX16asUINT
	ENDIF
fnTO			; LADF9!

		LDA	,U+
		CMPA	#'P'
		LBNE	brkNoSuchVar
		LDD	ZP_TOP
		BRA retD16asUINT
varGetPAGE

;			;  =PAGE
		LDA	ZP_PAGE_H
		CLRB
		BRA	retD16asUINT
;JUMPBrkTypeMismatch4:
;		JUMP brkTypeMismatch
fnLEN
;			;  =LEN
		CALL	evalLevel1
		LBNE	brkTypeMismatch
		LDB	ZP_STRBUFLEN
		BRA	retB8asUINT


retD16asUINT_LE	CLR	ZP_INT_WA + 2		; little endian version!
		CLR	ZP_INT_WA + 3		
		STD	ZP_INT_WA + 0
		LDA	#$40
		RTS


retA8asUINT	EXG	A,B
retB8asUINT	CLRA
retD16asUINT	STD	ZP_INT_WA + 2
retWA16asUINT	CLR	ZP_INT_WA + 0
		CLR	ZP_INT_WA + 1
		LDA	#$40
		RTS
retX16asUINT	STX	ZP_INT_WA + 2
		BRA	retWA16asUINT

fnCOUNT

		LDB ZP_PRLINCOUNT
		BRA retB8asUINT

varGetLOMEM

		LDD ZP_LOMEM
		BRA retD16asUINT
varGetHIMEM

		LDD ZP_HIMEM
		BRA retD16asUINT
varERL
			;  =ERL
		LDD	ZP_ERL
		BRA	retD16asUINT
varERR
			;  =ERR
		LDB	[ZP_MOS_ERROR_PTR_QRY]
		BRA	retB8asUINT
fnGET
			;  =GET
		JSR	OSRDCH
		BRA	retA8asUINT
varGetTIME
	IF FLEX = 1
		JUMP	brkFlexNotImpl
	ELSE
			;  =TIME
		LDA	,U	
		CMPA	#'$'
		BEQ	varGetTIME_DOLLAR
		PSHS	U
		LDX	#ZP_INT_WA
		LDU	#$00				;DP
		LDA	#$01
		JSR	OSWORD
		PULS	U
		
; Swap endianness of Integer Accumulator
SwapEndian						
;;;		LDD	ZP_INT_WA			; 5	2
;;;		PSHS	D				; 6	2
;;;		LDD	ZP_INT_WA + 2			; 5	2
;;;		EXG	A,B				; 7	2
;;;		STD	ZP_INT_WA			; 5	2
;;;		PULS	D				; 6	2
;;;		EXG	A,B				; 7	2
;;;		STD	ZP_INT_WA + 2			; 5	2
							; 46	16

		LDX	ZP_INT_WA			; 5	2
		LDD	ZP_INT_WA + 2			; 5	2
		EXG	A,B				; 7	2
		STD	ZP_INT_WA			; 5	2
		TFR	X,D				; 7	2
		EXG	A,B				; 7	2
		STD	ZP_INT_WA + 2			; 5	2
							;41	14

		LDA	#VAR_TYPE_INT
		RTS
	ENDIF

varGetTIME_DOLLAR
	IF FLEX = 1
		JUMP	brkFlexNotImpl
	ELSE
		LEAU	1,U
		PSHS	U
		LDA	#$0E
		LDX	#BASWKSP_STRING
		CLR	,X
		JSR	OSWORD
		LDA	#$18
		PULS	U
		BRA	staZpStrBufLen
	ENDIF
fnGETDOLLAR		; LAE69!

			
;			;  =GET$
		JSR	OSRDCH
returnAAsString						; LAE6C
		STA	BASWKSP_STRING
returnString1
		LDA	#$01
		BRA	staZpStrBufLen
returnBAsString	STB	BASWKSP_STRING
		BRA	returnString1

fnLEFT			; LAE73!
		CLC
		BRA	1F
fnRIGHT			; LAE74!

		SEC
1		PSHS	CC			; flag we want LEFT$ below
		CALL	evalAtY
		TSTA
		LBNE	brkTypeMismatch
		CMPB	#','
		LBNE	brkMissingComma
		LEAU	1,U
		CALL	evalstackStringExpectINTCloseBracket
		CALL	popStackedStringNew
		PULS	CC
		BCS	fnRIGHT_do_RIGHT		; DO RIGHT$
		LDA	ZP_INT_WA + 3
		CMPA	ZP_STRBUFLEN
		BCC	retAeq0
staZpStrBufLen	STA	ZP_STRBUFLEN
retAeq0		LDA	#$00
rts_AE93	RTS


fnRIGHT_do_RIGHT					; LAE94
		LDB	ZP_STRBUFLEN			; length of string
		SUBB	ZP_INT_WA + 3			; minus length of amount to copy == length to skip
		BCS	retAeq0
		BEQ	rts_AE93
		LDA	ZP_INT_WA + 3
		STA	ZP_STRBUFLEN
		BEQ	rts_AE93

		LDY	#BASWKSP_STRING
		LDX	#BASWKSP_STRING
		ABX
		LDB	ZP_INT_WA + 3
LAEA5
		LDA	,X+
		STA	,Y+
		DECB
		BNE	LAEA5
		BRA retAeq0


fnINKEYDOLLAR		; LAEB3!
	IF FLEX = 1
		JUMP	brkFlexNotImpl
	ELSE
			;  =INKEY$
		CALL callOSByte81withXYfromINT
		TFR	X,D
		BCC	returnBAsString
	ENDIF
strRet0LenStr							; LAEBB
		CLRA	
		BRA	staZpStrBufLen
	
		; YUSWAP - use Y and no push?
fnMIDstr
		CALL	evalAtY
		TSTA
		LBNE	brkTypeMismatch				; must be a string!
		CMPB	#','
		LBNE	brkMissingComma				; expect ,
		CALL	StackString
		LEAU	1,U					; skip ,
		CALL	evalAtYcheckTypeInAConvert2INT
		LDA	ZP_INT_WA + 3				; store low byte on stack
		PSHS	A
		LDA	#$FF
		STA	ZP_INT_WA				; default length to 255
		LDB	,U					; reload this, it may have been eaten converting to INT above
		LEAU	1,U					; skip next char
		CMPB	#')'
		BEQ	LAEEA					; don't eval length
		CMPB	#','
		LBNE	brkMissingComma
		CALL	evalL1BracketAlreadyOpenConvert2INT
LAEEA		PULS	B					; get back 2nd param (start 1-based index)
		PSHS	U					; remember Y
		BNE	1F
		INCB						; if 0 passed as index bump to 1
1		CMPB	[ZP_BAS_SP]
		BHI	strRet0LenStrPopYU			; branch if 2nd param > strlen
		STB	ZP_INT_WA + 2
		LDX	ZP_BAS_SP
		ABX						; X points at start of string to return
		LDB	[ZP_BAS_SP]
		SUBB	ZP_INT_WA + 2				; A=orig.len-ix
		INCB
		CMPB	ZP_INT_WA + 3				; compare to 3rd param
		BHS	LAF08					; if >= continue
		STB	ZP_INT_WA + 3				; if < use that as required len
LAF08		LDB	ZP_INT_WA + 3
		BEQ	strRet0LenStrPopYU
		STB	ZP_STRBUFLEN
		CMPX	#BASWKSP_STRING
		BEQ	unstackStringMIDS				; pointless copy?
		LDU	#BASWKSP_STRING
LAF0C		LDA	,X+
		STA	,U+
		DECB
		BNE	LAF0C
unstackStringMIDS
		CALL	unstackString
		CLRA
		PULS	U,PC
strRet0LenStrPopYU
		CLR	ZP_STRBUFLEN
		BRA	unstackStringMIDS

unstackString	LDX	ZP_BAS_SP
		LDB	,X+					; get stack str len to unstack
		ABX						; discard string and length byte
		STX	ZP_BAS_SP
		rts


fnSTR			; LAF1C!

		CALL	skipSpacesY
		LDB	#$FF
		CMPA	#'~'
		BEQ	LAF29
		CLRB
		LEAU	-1,U
LAF29
		PSHS	B
		CALL	evalLevel1
		STA	ZP_VARTYPE
		LBEQ	brkTypeMismatch
		PULS	B
		PSHS	U
		STB	ZP_PRINTFLAG			; dec/hex flag
		LDA	BASWKSP_INTVAR + 0		; high byte of @%
		BNE	LAF3F
		STA	ZP_GEN_PTR
		CALL	cmdPRINT_num2str_invaldp
		BRA	LAF7AclrArts
LAF3F
		CALL	cmdPRINT_num2str
		BRA	LAF7AclrArts
fnSTRING			; LAF47!
			
;			;  =STRING$
		CALL	evalAtYcheckTypeInAConvert2INT
		CALL	stackINT_WAasINT
		CALL	skipSpacesCheckCommaAtYOrBRK
		CALL	evalL1BracketAlreadyOpen
		LBNE	brkTypeMismatch
		PSHS	U
		CALL	popIntANew
		LDB	ZP_STRBUFLEN
		BEQ	LAF7AclrArts
		LDA	ZP_INT_WA + 3
		BEQ	fnStringRetBlank		; 0 copies return ""
		DEC	ZP_INT_WA + 3
		BEQ	LAF7AclrArts			; 1 copy return string in buffer
		LDX	#BASWKSP_STRING
		LDB	ZP_STRBUFLEN
		ABX
fnStringCopyOuterLoop					; copy string at end of buffer
		LDU	#BASWKSP_STRING
fnStringCopyInnerLoop					; LAF66
		LDA	,U+
		STA	,X+
		CMPX	#BASWKSP_STRING + $100
		LBEQ	brkStringTooLong
		DECB
		BNE	fnStringCopyInnerLoop
		LDB	ZP_STRBUFLEN
		DEC	ZP_INT_WA + 3			; decrement outer loop counter
		BNE	fnStringCopyOuterLoop
		TFR	X,D				; get back low part of Y in B
		STB	ZP_STRBUFLEN			; use that as new string len
LAF7AclrArts
		CLRA
		PULS	U,PC
fnStringRetBlank					; LAF7D
		STA ZP_STRBUFLEN
		PULS	U,PC
brkNoSuchFN				; LAF83
;;;;		PLA
;;;;		STA ZP_TXTPTR + 1
;;;;		PLA
;;;;		STA ZP_TXTPTR
		LDU	1,S		; get back stacked Y pointer (from callproc)
		STU	ZP_TXTPTR	; point back at caller so that ERL is reported correctly
		DO_BRK_B
		FCB	$1D,"No such ", tknFN, "/", tknPROC,0

	*****************************************************************
	*	Search Program For DEF PROC/FN				*
	*	On entry						*
	*		[ZP_GEN_PTR + 2] + 1 = tknFN or tknPROC		*
	*		[ZP_GEN_PTR + 2] + 2 = proc name		*
	*		ZP_NAMELENORVT is proc name length + 2		*
	*	Trashes	A,B,X,U						*
	*****************************************************************

progFndDEF_skNxtLinPULSU
progFndDEF_skNxtLin					; LAFB0
		LDB	3,X				; line length add to X
		ABX
		BRA	progFndDEF_linLp

progFindDEFPROC						; LAF97
		LDA ZP_PAGE_H
		CLRB
		TFR	D,X
progFndDEF_linLp					; LAF9D
		TST	1,X
		BMI	brkNoSuchFN			; check for end of program
		LEAU	4,X				; point Y after 0D and line number
		CALL	skipSpacesY
		CMPA	#tknDEF
		BNE	progFndDEF_skNxtLin
progFndDEF_skDefFnd					; LAFBF
		JSR	skipSpacesYStepBack
		LDY	ZP_GEN_PTR + 2
		LEAY	1,Y				; point at FN/PROC token, Y already points at one hopefully
		LDB	#1
		STU	ZP_TXTPTR
1		LDA	,U+
		CMPA	,Y+
		BNE	progFndDEF_skNxtLinPULSU	; compare caller / DEF token and name
		INCB
		CMPB	ZP_NAMELENORVT
		BNE	1B
		LDA	,U				; get next char
		CALL	checkIsValidVariableNameChar	; if it looks like a variable name char
		BCS	progFndDEF_skNxtLinPULSU	; then the DEF is for a longer name, keep searching

		; Y now points at parameters or whatever after DEFFNname
		; ZP_TXTPTR starts at FN/PROC token
		; X points at start of DEFFN line 


;;;		INY
;;;		STU ZP_TXTOFF
		CALL	skipSpacesYStepBack
		STU	ZP_TXTPTR
;;;		TYA
;;;		TAX
;;;		CLC
;;;		ADC ZP_TXTPTR
;;;		LDU ZP_TXTPTR + 1
;;;		BCC LAFD0
;;;		INY
;;;		CLC
;;;LAFD0:
;;;		SBC #$00
;;;		STA ZP_FPB + 1
;;;		TYA
;;;		SBC #$00
;;;		STA ZP_FPB + 2
;;;		LDU #$01
;LAFDB:

;;;		INX
;;;		LDA (ZP_FPB + 1),Y
;;;		CMP (ZP_GEN_PTR),Y
;;;		BNE progFndDEF_skNxtLin
;;;		INY
;;;		CPY ZP_NAMELENORVT
;;;		BNE LAFDB
;;;		LDA (ZP_FPB + 1),Y
;;;		CALL checkIsValidVariableNameChar
;;;		BCS progFndDEF_skNxtLin
;		TXA
;		TAY
;		CALL storeYasTXTPTR

		CALL	allocFNPROC
		LDA	#$01
		CALL	AllocVarSpaceOnHeap
		LDD	ZP_TXTPTR
		LDX	ZP_VARTOP
		STD	,X++
;;;		LDA ZP_TXTPTR
;;;		STA (ZP_VARTOP)
;;;		LDU #$01
;;;		LDA ZP_TXTPTR + 1
;;;		STA (ZP_VARTOP),Y
;;;		INY
		CALL	CheckVarFitsX
		BRA	LB072				; back to main PROC call routine
;
brkBadCall						; LB00C
		DO_BRK_B
		FCB	$1E,"Bad call",0

;		;  =FN / PROC
;		; ====
fnFN
;			
		LDA	#tknFN
doFNPROCcall	STA	ZP_VARTYPE			;  Save PROC/FN token
		TFR	S,D				; calculate new BASIC stack pointer 
		SUBD	#MACH_STACK_TOP+2		; by subtracting size of used machine stack + 2 (to store original stack pointer)
		LDX	ZP_BAS_SP
		LEAX	D,X				
		CALL	UpdStackFromXCheckFull		;  Store new BASIC stack pointer, checking for free space
		STS	,X++				; Store current machine stack pointer
1		CMPS	#MACH_STACK_TOP			; Copy machine stack contents to BASIC stack
		BHS	2F				; TODO: use 16bit copy? Require test on first/last loop for single byte tfr
		PULS	A
		STA	,X+
		BRA	1B
2		; S now points at top of stack X points at OLD U value
		; stack active variables on machine stack
		; note this is different to 6502!
		LDA	ZP_VARTYPE
		PSHS	A,U				; store PROC/FN token on the stack
;;;		LDA ZP_VARTYPE
;;;		PHA					;  Push PROC/FN token
;;;		LDA ZP_TXTOFF
;;;		PHA
;;;		LDA ZP_TXTPTR
;;;		PHA					;  Push PtrA line pointer
;;;		LDA ZP_TXTPTR + 1
;;;		PHA					;  Push Prea line offset
;;;		LDA ZP_TXTOFF2
;;;		TAX
;;;		CLC
;;;		ADC ZP_TXTPTR2
;;;		LDU ZP_TXTPTR2 + 1
;;;		BCC LB04C
;;;		INY
;;;		CLC
;;;;LB04C:
		LEAU	-2,U				; step back scan pointer
		STU	ZP_GEN_PTR+2			; this is picked up in findFNPROC below
		LDB	#$02
*		LEAU	1,U
		CALL	fnProcScanYplusBvarname; Check name is valid
		CMPB	#2
		BEQ	brkBadCall			; No valid characters
		LEAX	-1,X				; point ZP_TXTPTR2 at char after name
		STX	ZP_TXTPTR2
		CALL	findFNPROC			; note: this also saves length in B at ZP_NAMELENORVT
							; Look for PROC/FN in heap
		LBEQ	progFindDEFPROC			; Not in heap, jump to look in program
							; LB068
		LDU	[ZP_INT_WA + 2]
LB072
		CLR	,-S				; Store a 0 on the stack to mark 0 params
;		STZ ZP_TXTOFF
		CALL	skipSpacesY
		CMPA	#'('
		BEQ	doFNPROCargumentsEntry
		LEAU	-1,U
LB080
		LDX	ZP_TXTPTR2
		PSHS	X
		CALL	skipSpacesAtYexecImmed		; execute PROC/FN body
		PULS	X
		STX	ZP_TXTPTR2
		STX	ZP_TXTPTR
		LDA	,S+				; get back params flag (use LD for flags)
		BEQ	doFnProcExit_NoParams
		STA	ZP_FPB + 4			; get number of "params" (and locals) to reset
LB09A
		CALL	popIntAtZP_GEN_PTRNew		; get back variable pointer etc
		CALL	delocaliseAtZP_GEN_PTR
		DEC	ZP_FPB + 4
		BNE	LB09A
doFnProcExit_NoParams
;;;		PULS	A,Y
;;;		LEAU	-1,Y
;;;		LEAS	3,S			; discard stacked 

;		
;		stz	$fef0			; TODO - TUBE ????

		LDY	ZP_BAS_SP
		LDS	,Y++			; get old machine stack pointer from
						; BASIC stack
		LEAX	,S
1		CMPX	#MACH_STACK_TOP		; copy bytes from BASIC stack to machine stack
		BHS	2F
		LDA	,Y+
		STA	,X+
		BRA	1B
2
		LDU	ZP_TXTPTR
		LDA	ZP_VARTYPE		; from FN =
		STY	ZP_BAS_SP
		RTS



doFNPROCargumentsEntry
		; Y is pointing at first char of params (after bracket) in DEF
		; ZP_TXTPTR     at opening bracket of params in DEF
		; ZP_TXTPTR2    at opening bracket of call
		LDX	ZP_TXTPTR2
		PSHS	X
		CALL	findVarOrAllocEmpty
		BEQ	doBrkArguments
		PULS	X
		STX	ZP_TXTPTR2
		PULS	A				; bet back "params flag"
		LDX	ZP_INT_WA + 2
		LDB	ZP_INT_WA
		INCA
		PSHS	D,X				; push back incremented var ptr, var type, params flag
		CALL	localVarAtIntA			; push the variable value and pointer onto the BASIC stack
		CALL	skipSpacesCheckCommaAtY		; try and get another parameter
		BEQ	doFNPROCargumentsEntry
		CMPA	#')'
		BNE	doBrkArguments			; check for closing bracket
		STU	ZP_EXTRA_SAVE_PROC		; TODO, stack this or get from somewhere else?
		CLR	,-S				; store a 0 on stack (to be used as another arguments counter)
		CALL	skipSpacesPTRB
		CMPA	#'('
		BNE	doBrkArguments
LB108
		CALL	evalAtY				; get value of argument
		TSTA
		CALL	stackVarTypeInFlags		; push it to BASIC stack
		LDA	ZP_VARTYPE			; store "shadow" var type
		STA	ZP_INT_WA + 1			; TODO: check we actually need all this, can probably just store ZP_VARTYPE on stack as rest is discarded!
		CALL	stackINT_WAasINT		; stack intA on BASIC stack
		INC	,S				; increment arguments counter
		CALL	skipSpacesCheckCommaAtY
		BEQ	LB108
		CMPA	#')'
		BNE	doBrkArguments
		STU	ZP_TXTPTR2
		PULS	A,B				; get back two arguments counters
		STB	ZP_FP_TMP + 9
		STB	ZP_FP_TMP + 10
		CMPA	ZP_FP_TMP + 9			; check they're the same
		BEQ	LB140				; if so continue
doBrkArguments
		LDS	#MACH_STACK_TOP - 2
		LDU	,U++
		STU	ZP_TXTPTR
		DO_BRK_B
		FCB	$1F,"Arguments",0
LB140
		CALL	popIntANew			; get back eval'd type from stack
		PULS	A,X				; get back var type and variable pointer for argument variable
		STA	ZP_INT_WA + 0
		STX	ZP_INT_WA + 2
		TSTA
		BMI	LB16D				; do string arg
		STA	ZP_NAMELENORVT
		LDA	ZP_INT_WA + 1
		BEQ	doBrkArguments
		STA	ZP_VARTYPE
		LDX	ZP_INT_WA + 2
		STX	ZP_GEN_PTR+2			; stick var pointer at ZP_GEN_PTR+2
		LDA	ZP_VARTYPE
		BPL	LB165
		CALL	popFPandSetPTR1toStack
		CALL	fpCopyPTR1toFPA
		BRA	LB168
LB165		CALL	popIntANew
LB168		CALL	storeEvaledExpressioninVarAtZP_GEN_PTR
		BRA	LB177
LB16D		LDA	ZP_INT_WA + 1
		BNE	doBrkArguments
		CALL	popStackedStringNew
		CALL	copyStringToVar2
LB177		DEC	ZP_FP_TMP + 9
		BNE	LB140
		LDA	ZP_FP_TMP + 10
		PSHS	A
		LDU	ZP_EXTRA_SAVE_PROC
		JUMP	LB080


localVarAtIntA						; LB181
		LDB	ZP_INT_WA + 0			; get variable type
		CMPB	#VAR_TYPE_REAL
		PSHS	CC
		BHS	1F				; for not int
		LDX	#ZP_GEN_PTR
		CALL	CopyIntWA2X			; copy pointer to ZP_GEN_PTR, GetVarVal will overwrite it!
1							; LB18C
		CALL	GetVarValNewAPI
		CALL	stackVarTypeInFlags
		PULS	CC
		BHS	1F
		LDX	#ZP_GEN_PTR			; restore var pointer
		CALL	intLoadWAFromX			; get back variable pointer if we saved it
1		JUMP	stackINT_WAasINT		; and stack pointer

		; trashses A, B, X

GetVarValNewAPI						; LB1A0
		LDA	ZP_INT_WA + 0			; Get type
		BMI	GetVarValStr			; b7=String
		BEQ	store_wa_byte			; &00=Byte
		CMPA	#VAR_TYPE_REAL
		BEQ	GetVarValReal			; &05=Real
;;JGH
		CMPA	#VAR_TYPE_INT
		BEQ	GetVarValInt			; &04=Integer
; little-endian integer
		PSHS	U
		LDU	ZP_INT_WA + 2			; &02=Little-endian integer, TODO: check speed / size trade off with swapendian defined elsewhere if short of space
		LDX	#ZP_INT_WA
		CALL	getLEUtoX
		LDA	#VAR_TYPE_INT
		PULS	U,PC

getLEUtoX
		LDD	,U++
		EXG	A,B
		STD	2,X
		LDD	,U++
		EXG	A,B
		STD	0,X
		RTS
;;^^^

GetVarValInt
		LDX	ZP_INT_WA + 2
		LDD	,X++
		STD	ZP_INT_WA + 0
		LDD	,X++
		STD	ZP_INT_WA + 2
		LDA	#VAR_TYPE_INT
		RTS

store_wa_byte	LDB	[ZP_INT_WA + 2]
		JUMP	retB8asUINT

GetVarValReal						; LB1C7
		CLRA
		STA	ZP_FPA + 7			; zero overflow mantissa and exponent bytes
		STA	ZP_FPA + 1
		LDD	3,X
		STD	ZP_FPA + 5
		LDD	1,X
		STB	ZP_FPA + 4
		STA	ZP_FPA
		LDB	,X
		STB	ZP_FPA + 2
		BNE	LB1EF
		ORA	ZP_FPA + 4
		ORA	ZP_FPA + 5
		ORA	ZP_FPA + 6
		BEQ	LB1F2
LB1EF
		LDA	ZP_FPA
		ORA	#$80
LB1F2
		STA	ZP_FPA + 3
		LDA	#$FF
		RTS			;  Return real



GetVarValStr	PSHS	U		; LB1F7
		CMPA	#$80		; check type of string
		BEQ	GetVarValStr_Ind
		LDU	ZP_INT_WA + 2	; get address of param block
		LDA	3,U		; get string len
		STA	ZP_STRBUFLEN
		BEQ	1F
		LDU	,U		; get address of actual string
		LDX	#BASWKSP_STRING
2					; LB20F:
		LDB	,U+
		STB	,X+
		DECA
		BNE	2B
1					;LB218:
		CLRA			; indicate string returned
		PULS	U,PC

		; read string from memory
GetVarValStr_Ind					; LB219
		LDA	ZP_INT_WA + 2			; if MSB of string addr is 0 treat as a single char!
		BEQ	GetVarValStr_SingleCharAtINTWA3
		CLRB
		LDX	ZP_INT_WA + 2
		LDU	#BASWKSP_STRING
1							; LB21F
		LDA	,X+
		STA	,U+
		EORA	#$0D				; eor here ensures 0 A on exit
		BEQ	2F
		INCB
		BNE	1B
		CLRA
2							; LB22C:
		STB	ZP_STRBUFLEN
		CLRA			; indicate string returned
		PULS	U,PC


fnCHR			; LB22F!
;			;  =CHR$
		CALL	evalLevel1checkTypeStoreAsINT
GetVarValStr_SingleCharAtINTWA3				; LB232
		LDA	ZP_INT_WA + 3			; get single char and return in ZP_STR_BUF
		JUMP	returnAAsString


HandleBRKFindERL					; LB237
		CLR	ZP_ERL
		CLR	ZP_ERL + 1
		LDA	ZP_PAGE_H
		LDB	#0
		TFR	D,X			; X points at start of program
		LDB	ZP_TXTPTR
		CMPB	#BAS_InBuf / 256
		BEQ	HandleBRKFindERL_sk1

HandleBRKFindERL_lp				;LB251:
		LDA	,X+
		CMPA	#$0D
		BNE	HandleBRKFindERL_sk2
		CMPX	ZP_TXTPTR
		BHS	HandleBRKFindERL_sk1
		LDA	,X+
		ORA	#$00			; check end of program
		BMI	HandleBRKFindERL_sk1
		STA	ZP_ERL
		LDA	,X+
		STA	ZP_ERL + 1
		LDA	,X+
HandleBRKFindERL_sk2					;LB270:
		CMPX	ZP_TXTPTR
		BLO	HandleBRKFindERL_lp
HandleBRKFindERL_sk1					;LB277:
		RTS
HandleBRK
	IF FLEX = 1
		LDX	,S				; get stacked PC TODOFLEX: check for 6309?
	ENDIF
		STX	ZP_MOS_ERROR_PTR_QRY		; TODO: look at JGH API?
		LDB	#$FF
		STB	ZP_OPT
		RESET_MACH_STACK
	IF FLEX = 1
	ELSE
		PSHS	X
		LDX	#0
		LDU	#$00
		LDA	#$DA
		JSR	OSBYTE				; clear VDU queue
		LDA	#$7E
		JSR	OSBYTE				; Acknowledge any Escape state
	ENDIF

		CALL	HandleBRKFindERL
		CLR	ZP_TRACE
;;		LDA	[ZP_MOS_ERROR_PTR_QRY]
		LDA	[,S++]
		BNE 	HandleBRKsk1
		CALL	ONERROROFF
HandleBRKsk1						; LB296
		LDU	ZP_ERR_VECT
		STU	ZP_TXTPTR
		CALL	ResetStackProgStartRepeatGosubFor
		JUMP	skipSpacesAtYexecImmed
ONERROROFF
		LEAX	defErrBas, PCR
		STX	ZP_ERR_VECT
		RTS
;			;  Default error handler
;			;  ---------------------
defErrBas
		FCB  tknREPORT, ':', tknIF, tknERL, tknPRINT, $22, " at line ", $22, ';'
		FCB  tknERL, ':', tknEND, tknELSE, tknPRINT, ":", tknEND
		FCB  13

cmdSOUND						; LB2C8
	IF FLEX = 1
		JUMP	brkFlexNotImpl
	ELSE
		CALL	evalForceINT
		LDA	#OSWORD_SOUND
		PSHS	A				; store OSWORD # on stack
		LDB	#$04				; read 4 params
LB2CD		LDX	ZP_INT_WA + 2			; store 16 bit number on stack - reversing bytes
		PSHS	X
		DECB
		BEQ	1F
		PSHS	B
		CALL	checkCommaThenEvalAtYcheckTypeInAConvert2INT
		PULS	B
		BRA	LB2CD
1		CALL	LDUZP_TXTPTR2scanNextStmtFromY
		LDB	#$07				; # bytes to restore minus 1
		BRA	sndPullBthenAtoZP_SAVE_BUF_OSWORD_A
	ENDIF
cmdENVELOPE			; LB2EC!
	IF FLEX = 1
		JUMP	brkFlexNotImpl
	ELSE
		CALL	evalForceINT
		LDA	#OSWORD_ENVELOPE
		PSHS	A				; store OSWORD #
		LDB	#14				; read 14 params
LB2F1		LDA	ZP_INT_WA + 3			; get low byte of int
		PSHS	A
		DECB
		BEQ	1F
		PSHS	B
		CALL	checkCommaThenEvalAtYcheckTypeInAConvert2INT
		PULS	B
		BRA	LB2F1
1		CALL	LDUZP_TXTPTR2scanNextStmtFromY
		LDB	#13
sndPullBthenAtoZP_SAVE_BUF_OSWORD_A				; LB307
		LDX	#ZP_SAVE_BUF
1		PULS	A
		STA	B,X
		DECB
		BPL	1B
		PULS	A				; get back OSWORD #
OSWORD_continue
		PSHS	U
		JSR	OSWORD
		PULS	U
		BRA	LB322continue			; Call OSWORD, return to execution loop
	ENDIF


cmdWIDTH

		CALL	evalForceINT
		CALL	scanNextStmtFromY
		LDB	ZP_INT_WA+3
		DECB
		STB	ZP_WIDTH
LB322continue
		JUMP	continue
evalAtYAndStoreEvaledExpressioninStackedVarPTr		; LB328
		CALL evalAtY
		; the pointer to the variable (and it's type) are on the stack above the return pointer
storeEvaledExpressioninStackedVarPTr			; LB32B
;		PLY
;		PLX
;		PLA
;		STA ZP_NAMELENORVT
;		PLA
;		STA ZP_GEN_PTR + 1
;		PLA
;		STA ZP_GEN_PTR
;		PHX
;		PHY
		LDA	2,S
		STA	ZP_NAMELENORVT
		LDX	3,S
		STX	ZP_GEN_PTR+2
		PULS	X
		LEAS	3,S
		PSHS	X
storeEvaledExpressioninVarAtZP_GEN_PTR			; LB338
		LDA	ZP_NAMELENORVT
		CMPA	#VAR_TYPE_REAL
		BEQ	storeEvaledExpressioninRealVarAtZP_GEN_PTR
		LDA	ZP_VARTYPE
		LBEQ	brkTypeMismatch
		BPL	storeInt1
		CALL	fpReal2Int
storeInt1						;LB347:
;;;JGH
;		TST	ZP_NAMELENORVT
		LDA	ZP_NAMELENORVT
		BEQ	storeByte
		CMPA	#$02
		BEQ	storeInt2			; little-endian word
		LDX	ZP_GEN_PTR+2
		LDD	ZP_INT_WA
		STD	0,X
		LDD	ZP_INT_WA + 2
		STD	2,X
		RTS
storeInt2						; Store little-endian word
		LDX	ZP_GEN_PTR+2
		LDD	ZP_INT_WA
		EXG	A,B
		STD	2,X
		LDD	ZP_INT_WA + 2
		EXG	A,B
		STD	0,X
		RTS
;;;^^^
storeByte
		LDA	ZP_INT_WA + 3
		STA	[ZP_GEN_PTR+2]
		RTS
storeEvaledExpressioninRealVarAtZP_GEN_PTR		; LB360
		LDA	ZP_VARTYPE
		LBEQ	brkTypeMismatch
		BMI	skIntToReal1
		CALL	IntToReal
skIntToReal1						; LB369
		LDX	ZP_GEN_PTR+2
fpCopyFPAtoX
		LDA	ZP_FPA + 2
		STA	,X+
		LDA	ZP_FPA			; get mantissa sign back from sign byte
		EORA	ZP_FPA + 3
		ANDA	#$80
		EORA	ZP_FPA + 3
		STA	,X+
		LDA	ZP_FPA + 4
		STA	,X+
		LDA	ZP_FPA + 5
		STA	,X+
		LDA	ZP_FPA + 6
		STA	,X+
		RTS

cmdEDIT			
		CALL	ResetVars
		LDA	#$80
		STA	ZP_LISTO

doLIST
		CLR	ZP_FPB
		CLR	ZP_FPB + 1
		CALL	varFALSE			; set start line no to 0
		CALL	skipSpacesDecodeLineNumberNewAPI
		PSHS	CC
		CALL	stackINT_WAasINT		; stack start line no
		CALL	returnINTminus1			; set end line no to FFFF
		LSR	ZP_INT_WA + 2			; note line number in +2,3, clear top bit end 
							; line no. max is 32767
							; LB3AD:
		PULS	CC
		BCC	doListSkNoLineSpec
		CALL	skipSpacesCheckCommaAtYStepBack		; look for a comma, 
		BEQ	doListSkLineSpec2
		; no second spec, pop first speccd line and use as 2nd param
		CALL	popIntANew		      	; unstack then stack - TODO: check if can load using off,U
		CALL	stackINT_WAasINT
		BRA	doListSkStart
doListSkNoLineSpec				      	;LB3BF:
		CALL	skipSpacesCheckCommaAtYStepBack	; if there's a comma skip it 
doListSkLineSpec2				      	;LB3C6:
		CALL	skipSpacesDecodeLineNumberNewAPI; this will return $FFFF if no match (i.e. go to the end!)
doListSkStart					      	;LB3C9:
		LDX	#ZP_FPA + 3
		CALL	CopyIntWA2X
		CALL	skipSpacesYStepBack
		CMPA	#tknIF
		BNE	doListSkStart2
		CALL	inySkipSpacesYStepBack
		BRA	doListSkStart3
cmdLIST

			
;			;  LIST
		LDA	,U

		CMPA	#'O'
		BNE	doLIST
		LEAU	1,U
		CALL	evalForceINT
		CALL	scanNextStmtFromY
		LDA	ZP_INT_WA + 3
		STA	ZP_LISTO
		JUMP	immedPrompt
doListSkStart2						; LB3F3:
		CALL	scanNextExpectColonElseCR
doListSkStart3						; LB3F6:
		STU	ZP_TXTPTR2			; point at first non-space after IF token or <CR> if not LIST IF
		CALL	findTOP
		CALL	popIntANew			; intWA now contains ending line no
		CALL	findProgLineNewAPI
		BCS	doListSkGotCorrectLine
		BRA	doListSkGotNearestLine
doListPrintLFThenLoop					; LB410
		CALL	list_printA
		TST	ZP_LISTO
		BMI	doListLoop
		LDA	#$0A
		JSR	OSWRCH
doListLoop						;LB41C
;;		CALL storeYasTXTPTR
		CALL	checkForESC
doListSkGotNearestLine					;LB41F:
		LDX	1,U				 ; get the actual line number found
		STX	ZP_INT_WA + 2
doListSkGotCorrectLine					;LB428:
		LDX	ZP_INT_WA + 2
		CMPX	ZP_FPA + 5	
		BLS	doListStartLine
		TST	ZP_LISTO
		LBPL	immedPrompt
		LEAX	strEdit12_2,PCR
		JMP	OSCLI

;			;  EDIT
;			;  ====
strEdit12_2				;LB389:
		FCB	"EDIT 12,2", $0d


doListStartLine						; LB43E:
		CLR	ZP_FP_TMP + 9			; flag Quote/REM open
		CLR	ZP_FP_TMP + 10			; flag whether to display line
		LEAU	4,U				; point at first char/token of actual line 
		STU	ZP_TXTPTR			; store pointer for later after scan

		; scan the line for UNTIL/NEXT for indents
		; scan the line for matches if doing LIST IF

		; reset indent levels if -ve
		TST	ZP_FPB
		BPL	doListSk0
		CLR	ZP_FPB
doListSk0						;LB44E:
		TST	ZP_FPB + 1
		BPL	doListSk1
		CLR	ZP_FPB + 1
doListSk1						;LB454:
doListScanLoop
		LDA	,U				;  Get character
		CMPA	#$0D
		BEQ	doListScanDone			;  End of line
		CMPA	#tknREM
		BEQ	doListSkREM			; ignore quotes in REMs
		CMPA	#'"'
		BNE	doListSkREMQuot
		EORA	ZP_FP_TMP + 9			;  Toggle quote flag (no effect after REM!)
doListSkREM						;LB464:
		STA	ZP_FP_TMP + 9			; if a REM store tknREM, if a Quote toggle
doListSkREMQuot						; LB466
		TST	ZP_FP_TMP + 9
		BNE	doListSkUntil			;  Within quotes / REM
		CMPA	#tknNEXT
		BNE	doListSkNext
		DEC	ZP_FPB				; decrement NEXT indent level
doListSkNext						; LB470
		CMPA	#tknUNTIL
		BNE	doListSkUntil
		DEC	ZP_FPB + 1			; decrement UNTIL indent level
doListSkUntil						; LB476

		; LIST IF

		LDX	ZP_TXTPTR2			; LIST IF 
		PSHS	U				
doListLp_Uk1						; LB478
		LDA	,X				; scan line after LIST IF and try and match within the current line
		CMPA	#$0D
		BEQ	doListSk_Uk1
		CMPA	,U
		BNE	doListSk_Uk2
		LEAU	1,U
		LEAX	1,X
		BRA	doListLp_Uk1

doListSk_Uk1						; LB489:
		STA	ZP_FP_TMP + 10			; matched LIST IF (or there wasn't one) do print this line
doListSk_Uk2						; LB48B:
		PULS	U
		LEAU	1,U
		BRA	doListScanLoop
doListScanDone						;LB491:
		LDA	ZP_FP_TMP + 10
		BEQ	doListLoop
		CALL	int16print_fmt5			; print line number
		LDA	#$01
		INCB					; set to 0
		SEC
		CALL	doLISTOSpaces			; LISTO1 - space after Line no
		LDB	ZP_FPB
		LDA	#$02
		CALL	doLISTOSpacesCLC		; LISTO2 - NEXT indents
		LDB	ZP_FPB + 1
		LDA	#$04				; LISTO4 - REPEAT/UNTIL indents
		CALL	doLISTOSpacesCLC
		CLR	ZP_FP_TMP + 9
doListNextTok2						;LB4AF:
		LDU	ZP_TXTPTR			; TODO reset Y pointer here?
doListNextTok						; LB4B1:
		LDA	,U
		CMPA	#$0D
		LBEQ	doListPrintLFThenLoop
		CMPA	#'"'
		BNE	doListSkNotQuot2
		EORA	ZP_FP_TMP + 9
		STA	ZP_FP_TMP + 9			; Toggle quote flag
		LDA	#'"'
doListQuoteLp2						; LB4C1
		CALL	list_printA
		LEAU	1,U
		BRA	doListNextTok
doListSkNotQuot2					; LB4C7:
		TST	ZP_FP_TMP + 9
		BNE	doListQuoteLp2
		CMPA	#tknLineNo
		BNE	doList_sknotLineNo
		LEAU	1,U
		CALL	decodeLineNumber
							;		STU ZP_TXTOFF - don't think this is needed any longer
		CALL	int16print_AnyLen
		BRA	doListNextTok			;		DB: changes to not restore Y as int16print not longer trashes it
doList_sknotLineNo					; LB4D9:
		CMPA	#tknFOR
		BNE	doList_sknotFOR
		INC	ZP_FPB
doList_sknotFOR						; LB4DF:
		CMPA	#tknREPEAT
		BNE	doList_sknotREPEAT
		INC	ZP_FPB + 1
doList_sknotREPEAT					; LB4E5:
		CMPA	#tknREM
		BNE	doList_sknotREM
		STA	ZP_FP_TMP + 9
doList_sknotREM						;LB4EB:
		CALL	doListPrintTokenA
		LEAU	1,U
		BRA	doListNextTok


			; cmdNEXT
			; =======
cmdNEXT
		CALL	findVarAtYSkipSpaces
		BNE	cmdNextSkSpecdLoopVar
		LDB	ZP_FOR_LVL_X_15
		BEQ	brkNoFOR
		BCS	cmdNEXTTopLoopVar
cmdNextskSyntax	JUMP	brkSyntax
cmdNextSkSpecdLoopVar					; LB4FF
		BCS	cmdNextskSyntax			; TODO: should this not be can't match for? Bug in original BASIC?
		PSHS	U				; use Y as gen ptr, remember to pop before BRKs
		LDB	ZP_FOR_LVL_X_15
		LDX	#BASWKSP_FORSTACK-FORSTACK_ITEM_SIZE
		ABX	
		LEAU	,X				; Y points at last item on FOR stack
		BEQ	brkNoFOR
cmdNEXTstacklp						; LB505
		LDX	ZP_INT_WA + 2			; search FOR stack for a loop with matching variable pointer and type
		CMPX	FORSTACK_OFFS_VARPTR,U
		BNE 	cmdNEXTstacklpsk1
		LDA	ZP_INT_WA + 0
		CMPA	FORSTACK_OFFS_VARTYPE,U
		BNE	cmdNEXTstacklpsk1
		BRA	cmdNEXTfoundLoopVar		
cmdNEXTstacklpsk1					; LB51A
		LEAU	-FORSTACK_ITEM_SIZE,U
		SUBB	#FORSTACK_ITEM_SIZE
		STB	ZP_FOR_LVL_X_15
		BNE	cmdNEXTstacklp
		PULS	U
		DO_BRK_B
		FCB	$21, "Can't match ", tknFOR, 0
brkNoFOR
		PULS	U
		DO_BRK_B
		FCB	$20, "No ", tknFOR, 0
cmdNEXTTopLoopVar					; LB539
		LEAU	-1,U				; if no var found go back a char : TODO - check whether we can change API
		PSHS	U				; use Y as gen ptr, remember to pop before BRKs
		LDU	#BASWKSP_FORSTACK - FORSTACK_ITEM_SIZE
		LEAU	B,U
		LDX	FORSTACK_OFFS_VARPTR,U
		LDA	FORSTACK_OFFS_VARTYPE,U
		STA	ZP_INT_WA + 0
		STX	ZP_INT_WA + 2
cmdNEXTfoundLoopVar
		; X => variable
		; Y => FOR stack
		; B => ZP_FOR_LVL_X_15
		; A is var type
		CMPA	#VAR_TYPE_REAL
		LBEQ	cmdNEXTdoREAL
		CMPA	#VAR_TYPE_INT_LE
		BEQ	cmdNEXTdoINT_LE

		; 32 bit add of integer control VAR, also store at ZP_GEN_PTR (bigendian)
		LDD	2,X
		ADDD	(2+FORSTACK_OFFS_STEP),U
		STD	2,X
		LDD	,X
		ADCB	(1+FORSTACK_OFFS_STEP),U
		ADCA	(0+FORSTACK_OFFS_STEP),U
		STD	0,X

		LDD	2,X				;6
		SUBD	(2+FORSTACK_OFFS_TO),U		;7
		BNE	cmdNEXTnoZ			;3
		LDD	0,X				;5
		SBCB	(1+FORSTACK_OFFS_TO),U		;5
		SBCA	(0+FORSTACK_OFFS_TO),U		;5
		BNE	cmdNEXTnoZ2			;3
		TSTB					;2
		BNE	cmdNEXTnoZ2			;3
;							;=39
		BRA	cmdNEXTexecLoop			;3
cmdNEXTnoZ
		LDD	0,X				;5
		SBCB	(1+FORSTACK_OFFS_TO),U		;5
		SBCA	(0+FORSTACK_OFFS_TO),U		;5
							;=31
cmdNEXTnoZ2
		LDA	0,X
cmdNextnoz3
		EORA	(0+FORSTACK_OFFS_TO),U
		EORA	(0+FORSTACK_OFFS_STEP),U
		BPL	cmdNEXTcksign2
		BCC	cmdNEXTexecLoop
		BRA	cmdNEXTloopFinished
cmdNEXTcksign2						; LB59C
		BCC	cmdNEXTloopFinished
cmdNEXTexecLoop						; LB59E
		LEAS	2,S				; don't pull Y we don't want it
		LDU	FORSTACK_OFFS_LOOP,U
		STU	ZP_TXTPTR
		CALL	checkForESC
		JUMP 	skipSpacesAtYexecImmed

cmdNEXTdoINT_LE						; TODO: see about shortening / sharing this!
		; 32 bit add of integer control VAR, also store at ZP_GEN_PTR (bigendian)
		LDD	0,X
		ADDA	(3+FORSTACK_OFFS_STEP),U
		ADCB	(2+FORSTACK_OFFS_STEP),U
		STD	0,X
		LDD	2,X
		ADCA	(1+FORSTACK_OFFS_STEP),U
		ADCB	(0+FORSTACK_OFFS_STEP),U
		STD	2,X

		LDD	0,X				;6
		SUBA	(3+FORSTACK_OFFS_TO),U		;7
		SBCB	(2+FORSTACK_OFFS_TO),U		;7
		BNE	cmdNEXTnoZLE			;3
		TSTA
		BNE	cmdNEXTnoZLE			;3
		LDD	2,X				;5
		SBCA	(1+FORSTACK_OFFS_TO),U		;5
		SBCB	(0+FORSTACK_OFFS_TO),U		;5
		BNE	cmdNEXTnoZ2LE			;3
		TSTA					;2
		BNE	cmdNEXTnoZ2LE			;3
;							;=39
		BRA	cmdNEXTexecLoop			;3
cmdNEXTnoZLE
		LDD	2,X				;5
		SBCA	(1+FORSTACK_OFFS_TO),U		;5
		SBCB	(0+FORSTACK_OFFS_TO),U		;5
							;=31
cmdNEXTnoZ2LE
		LDA	3,X
		BRA	cmdNextnoz3

cmdNEXTloopFinished					; LB5AE
		LDB	ZP_FOR_LVL_X_15
		SUBB	#FORSTACK_ITEM_SIZE
		STB	ZP_FOR_LVL_X_15
		PULS	U
		CALL	skipSpacesCheckCommaAtY
		LBNE	decYGoScanNextContinue
		JUMP	cmdNEXT				; found a comma, do another round of NEXTing

cmdNEXTdoREAL						; LB5C0
		CALL	GetVarValReal			; get current variable value
		LEAX	FORSTACK_OFFS_STEP,U		; get STEP value
		STX	ZP_FP_TMP_PTR1
		CALL	fpFPAeqPTR1addFPA		; TODO jump straight in with X?

		LDX	ZP_INT_WA + 2			; Get variable pointer
		CALL	fpCopyFPAtoX			; store result of STEP add

		LEAX	FORSTACK_OFFS_TO,U		; Get pointer to TO value
		STX	ZP_FP_TMP_PTR1
		CALL	evalDoCompareRealFPAwithPTR1	; TODO: use X direct
		BEQ	cmdNEXTexecLoop
		TST	FORSTACK_OFFS_STEP + 1,U	; if STEP -ve
		BMI	LB5F1
		BCC	cmdNEXTexecLoop
		BRA	cmdNEXTloopFinished
LB5F1
		BCS	cmdNEXTexecLoop
		BRA	cmdNEXTloopFinished

brkFORVariable
		DO_BRK_B
		FCB	$22, tknFOR, " variable", 0
brkTooManyFORs
		DO_BRK_B
		FCB	$23, "Too many ", tknFOR, "s", 0
brkNoTO
		DO_BRK_B
		FCB	$24, "No ", tknTO, 0
			;============================
			; FOR
			;============================
cmdFOR
		; TODO some recalcs of X could be done by LEAX?
			;  FOR
		CALL	findVarOrAllocEmpty
		BEQ	brkFORVariable
		BCS	brkFORVariable
		CALL	pushVarPtrAndType
		CALL	skipToEqualsOrBRKY
		CALL	evalAtYAndStoreEvaledExpressioninStackedVarPTr
		CALL	skipSpacesY
		CMPA	#tknTO
		BNE	brkNoTO
		LDB	ZP_FOR_LVL_X_15
		CMPB	#FORSTACK_ITEM_SIZE*FORSTACK_MAX_ITEMS
		BCC	brkTooManyFORs
		LDX	#BASWKSP_FORSTACK
		ABX
		STX	ZP_EXTRA_SAVE
		LDB	ZP_FOR_LVL_X_15
		ADDB	#FORSTACK_ITEM_SIZE
		STB	ZP_FOR_LVL_X_15
		LDD	ZP_GEN_PTR+2			; addr of control var
		STD	FORSTACK_OFFS_VARPTR,X
		LDA	ZP_NAMELENORVT
		STA	FORSTACK_OFFS_VARTYPE,X		; type of control var
		CMPA	#$05
		BEQ	cmdFORskipskReal
		CALL	evalAtYcheckTypeInAConvert2INT
		LDX	ZP_EXTRA_SAVE
		LDD	ZP_INT_WA			; store INT TO val at +8
		STD	FORSTACK_OFFS_TO,X
		LDD	ZP_INT_WA + 2
		STD	FORSTACK_OFFS_TO+2,X
		LDA	#$01
		CALL	retA8asUINT			; default STEP to 1
		CALL	skipSpacesY		
		CMPA	#tknSTEP
		BNE	cmdFORskINTnoSTEP
		PSHS	X
		CALL	evalAtYcheckTypeInAConvert2INT
		PULS	X
		LEAU	1,U				; TODO - sort this back and forth out?
cmdFORskINTnoSTEP					; LB677
		LEAU	-1,U
		LDD	ZP_INT_WA			; store INT STEP val at + 5
		STD	FORSTACK_OFFS_STEP,X
		LDD	ZP_INT_WA + 2
		STD	FORSTACK_OFFS_STEP + 2,X
cmdFORskipExecBody					; LB68F
		CALL	scanNextStmtAndTrace
		LDB	ZP_FOR_LVL_X_15
		LDX	#BASWKSP_FORSTACK + FORSTACK_OFFS_LOOP - FORSTACK_ITEM_SIZE
		STU	B,X				; store Y pointer to body statement in FOR stack (2 before next pointer!)
		JUMP	skipSpacesAtYexecImmed
cmdFORskipskReal					; LB6A1

		CALL	evalAtY
		CALL	checkTypeIntToReal
		LDX	ZP_EXTRA_SAVE
		LDB	#FORSTACK_OFFS_TO
		ABX
		CALL	fpCopyFPA_X			; store TO value (real)
		CALL	fpLoad1				; FloatA=1.0 (load default STEP)
		CALL	skipSpacesY
		CMPA	#tknSTEP
		BNE	cmdFORrealNoStep
		CALL	evalAtY
		CALL	checkTypeIntToReal
		LEAU	1,U
cmdFORrealNoStep					; LB6C7
		LEAU	-1,U
		LDX	ZP_EXTRA_SAVE
		LDB	#FORSTACK_OFFS_STEP
		ABX
		CALL	fpCopyFPA_X
		BRA	cmdFORskipExecBody

			;============================
			; GOSUB		
			;============================
cmdGOSUB
		CALL	decodeLineNumberFindProgLine
intGOSUB_FPB_2	CALL	scanNextStmtFromY		; LB6DC
		LDB	ZP_GOSUB_LVL			; Get GOSUB index
		CMPB	#GOSUBSTACK_MAX			; Check whether stack is full
		BHS	brkTooManyGosubs
		LDX	#BASWKSP_GOSUBSTACK
		ASLB
		ABX
		STU	,X				; store text pointer on stack
		INC	ZP_GOSUB_LVL
		BRA	cmdGOTODecodedLineNumber
brkTooManyGosubs
		DO_BRK_B
		FCB	$25, "Too many ", tknGOSUB, "s", 0
brknoGOSUB
		DO_BRK_B
		FCB	$26, "No ", tknGOSUB, 0

			;============================
			; RETURN
			;============================
cmdRETURN
		CALL	scanNextStmtFromY
		LDB	ZP_GOSUB_LVL
		BEQ	brknoGOSUB
		DEC	ZP_GOSUB_LVL
		LDX	#BASWKSP_GOSUBSTACK-2
		ASLB
		ABX
		LDU	,X
LB71A		JUMP	continue

			;============================
			; GOTO
			;============================
cmdGOTO							; LB71D!

		CALL	decodeLineNumberFindProgLine
		;;LDU	ZP_TXTPTR
		CALL	scanNextStmtFromY
cmdGOTODecodedLineNumber				; LB723
		LDA	ZP_TRACE
		BEQ	cmdGOTOskTrace
		CALL	doTRACE
cmdGOTOskTrace						; LB72A
		LDU	ZP_FPB + 2
		LEAU	4,U
STUZPTXTPTR_continue					; LB732
		STU	ZP_TXTPTR
		JUMP	skipSpacesAtYexecImmed

cmdONERROROFF						; LB739
		CALL	scanNextStmtFromY
		CALL	ONERROROFF
		JUMP	continue
cmdONERROR						; LB741
		CALL	skipSpacesY
		CMPA	#tknOFF
		BEQ	cmdONERROROFF
		LEAU	-1,U
		STU	ZP_ERR_VECT
		JUMP	cmdREM				; skip rest
;			;  ON [ERROR][GOTO][GOSUB]
;			;  =======================
cmdON							; LB75B!

		CALL	skipSpacesY
		CMPA	#tknERROR
		BEQ	cmdONERROR				;  ON ERROR

		LEAU	-1,U
		CALL	evalForceINT				;  Evaluate ON <num>
		CMPB 	#tknPROC
		BEQ 	cmdOnGSP				;  ON <num> PROC
		LEAU	1,U
		CMPB	#tknGOTO
		BEQ	cmdOnGSP				;  ON <num> GOTO
		CMPB	#tknGOSUB
		BNE 	brkONSyntax				;  ON <num> GOSUB
cmdOnGSP							; LB774
		PSHS	B					;  Save token
		LDA	ZP_INT_WA + 0
		ORA	ZP_INT_WA + 1
		ORA	ZP_INT_WA + 2		
		BNE	cmdOnSkipNoMatch			; if >255
		DEC	ZP_INT_WA + 3				; make 0-based
		BEQ	cmdOnFound
		BMI	cmdOnSkipNoMatch
cmdOnCharloop							; LB783
		LDA	,U+
		CMPA	#$0D
		BEQ	cmdOnSkipNoMatch2
		CMPA	#':'
		BEQ	cmdOnSkipNoMatch2
		CMPA	#tknELSE
		BEQ	cmdOnSkipNoMatch2
		CMPA	#'"'
		BNE	1F
		EORA	ZP_INT_WA + 1
		STA	ZP_INT_WA + 1				; quotes flag
1		TST	ZP_INT_WA + 1				; LB79A
		BNE	cmdOnCharloop				; skip over quotes PROC params
		CMPA	#')'
		BNE	1F
		DEC 	ZP_INT_WA + 2
1		CMPA 	#'('					; LB7A4
		BNE	1F
		INC	ZP_INT_WA + 2
1		CMPA	#','					; LB7AA
		BNE	 cmdOnCharloop
		TST	 ZP_INT_WA + 2				; brackets
		BNE	 cmdOnCharloop
		DEC	 ZP_INT_WA + 3
		BNE	 cmdOnCharloop
cmdOnFound							; LB7B6
		PULS	A	
		CMPA	#tknPROC
		BEQ	cmdOnFoundPROC
		STU	ZP_TXTOFF
		CMPA	#tknGOSUB
		BEQ	cmdOnFoundGOSUB
		CALL	decodeLineNumberFindProgLine
		CALL	checkForESC
		JUMP	cmdGOTODecodedLineNumber
cmdOnFoundGOSUB							; LB7CA
		CALL	decodeLineNumberFindProgLine
		LDU	ZP_TXTOFF
		CALL	findNextStmt				; find $0D or ':' to use as return from GOSUB
		JUMP	intGOSUB_FPB_2
cmdOnSkipNoMatch2
		LEAU	-1,U
cmdOnSkipNoMatch						; LB7D5
		LEAS	1,S					; remove token from stack
1		LDA	,U+					; search for ELSE or end of statement
		CMPA	#tknELSE
		LBEQ	execTHENorELSEimpicitGOTO
		CMPA	#$0D
		BNE	1B
		DO_BRK_B
		FCB	$28, tknON, " range", 0
brkONSyntax
		DO_BRK_B
		FCB	$27, tknON, " syntax", 0
brkNoSuchLine
		DO_BRK_B
		FCB	$29, "No such line", 0
cmdOnFoundPROC							; LB803
		PSHS	U
		CALL	skipSpacesY
		CMPA	#tknPROC
		BNE	brkONSyntax
		CALL	doFNPROCcall
		PULS	U
		CALL	findNextStmt
		JUMP	scanNextContinue
;;LB81C:
;;		INY
;;LB81D:
;;		LDA (ZP_TXTPTR),Y
;;		CMP #$0D
;;		BEQ LB827
;;		CMP #$3A
;;		BNE LB81C
;;LB827:
;;		STU ZP_TXTOFF
;;		RTS
;;		
findNextStmt	LDA	,U+
		CMPA	#':'
		BEQ	1F
		CMPA	#$0D
		BNE	findNextStmt
1		LEAU	-1,U
		RTS


decodeLineNumberFindProgLine
		CALL	skipSpacesDecodeLineNumberNewAPI
		BCS	findProgLineOrBRK			; tokenised line number found
		CALL	evalForceINT
		LDA	#$7F					; clear top bit of line number
		ANDA	ZP_INT_WA + 2
		STA	ZP_INT_WA + 2
findProgLineOrBRK
		PSHS	U
		CALL	findProgLineNewAPI
		BCC	brkNoSuchLine
		PULS	U,PC
;LB83C:
;		JUMP brkTypeMismatch
;;LB83F:
;;		JUMP brkSyntax

;;cmdINPUT_HASH_exit
;;		STU ZP_TXTOFF
;;;LB844:
;;		JUMP scanNextContinue

cmdINPUTBGETtoX
1		JSR	OSBGET
		STA 	,X+
		DECB		
		BNE	1B
		RTS

cmdINPUT_HASH						; LB847
		CALL	decYSaveAndEvalHashChannelAPI
		PSHS	Y				; save channel #
cmdINPUT_HASH_lp					; LB84F
		LDU	ZP_TXTPTR
		CALL	skipSpacesCheckCommaAtY
		LBNE	cmdPRINTHASH_exit
		CALL	findVarOrAllocEmpty
		LBEQ	brkSyntax
;;		CALL copyTXTOFF2toTXTOFF
		STU	ZP_TXTPTR
;;		PLA
;;		STA ZP_FP_TMP + 9
		PSHS	CC
		CALL	stackINT_WAasINT		; pointer to variable on stack
		LDU	1,S				; channel
		JSR	OSBGET
		STA	ZP_VARTYPE			; get VARTYPE as stored in file
		PULS	CC				; get back var flags
		BCC	cmdINPUT_HASH_notdynstr		; branc if not a dyn string
		TST	ZP_VARTYPE			; check var type (we want 0 for string!)
		LBNE	brkTypeMismatch
		JSR	OSBGET
		STA	ZP_STRBUFLEN
		LDB	ZP_STRBUFLEN			; counter
		BEQ 	2F
		LDX	#BASWKSP_STRING
		CALL	cmdINPUTBGETtoX
2		CALL	copyStringToVar
		BRA	cmdINPUT_HASH_lp
cmdINPUT_HASH_notdynstr					; LB88A
		TST	ZP_VARTYPE
		LBEQ	brkTypeMismatch
		BMI	cmdINPUT_HASH_FP
		LDB	#$04
		LDX	#ZP_INT_WA
		CALL	cmdINPUTBGETtoX
		BRA	cmdINPUT_HASH_StoreAtVarPtr
cmdINPUT_HASH_FP					;
		LDB	#$05
		LDX	#BASWKSP_FPTEMP1 + 5
1		JSR	OSBGET
		STA	,-X
		DECB
		BNE	1B
		CALL	fpCopyFPTEMP1toFPA
cmdINPUT_HASH_StoreAtVarPtr
		CALL	popIntAtZP_GEN_PTRNew
		CALL	storeEvaledExpressioninVarAtZP_GEN_PTR
		BRA	cmdINPUT_HASH_lp
;LB8B2:
;		PLA
;		PLA
;		BRA LB844
cmdINPUT			; LB8B6!
		CALL	skipSpacesCheckHashAtY
		BEQ	cmdINPUT_HASH

		CMPA	#tknLINE
		BEQ	1F
		LEAU	-1,U
		SEC					; note the LINE bit is the opposite sense to 6502
1		ROR	ZP_FP_TMP + 9
		LSR	ZP_FP_TMP + 9
		LDA	#$FF
		STA	ZP_FP_TMP + 10			; flag "first" item after a prompt?
cmdINPUT_LINE_lp					; LB8CA
		ASL	ZP_FP_TMP + 9
		CALL	cmdINPUT_PRINT_prompt
		BCS	LB8D9
1		CALL	cmdINPUT_PRINT_prompt
		BCC	1B
		LDB	#$FF
		STB	ZP_FP_TMP + 10			; flag "first" item after a prompt?
		CLC
LB8D9		ROR	ZP_FP_TMP + 9			; bit 7 set if had prompt, bit 6 set if LINE
		CMPA	#','
		BEQ	cmdINPUT_LINE_lp				; check again for prompts
		CMPA	#';'
		BEQ	cmdINPUT_LINE_lp				; check again for prompts
		LEAU	-1,U
		LDD	ZP_FP_TMP + 9			; stack our flags
		PSHS	D
		CALL	findVarOrAllocEmpty
		LBEQ	cmdPRINTHASH_exit		; "invalid" i.e. no varaible found
		PULS	D
		STD	ZP_FP_TMP+9
;;		CALL	copyTXTOFF2toTXTOFF
		PSHS	CC,U				; store carry flag (set if a string var) and current Y
		LDB	#$40
		BITB	ZP_FP_TMP + 9			; branch if 
		BEQ	LB908				; note opposite sense! branch for LINE
		LDB	ZP_FP_TMP + 10
		CMPB	#$FF
		BNE	cmdINPUT_LINE_readCommaStrItem
LB908
		TST	ZP_FP_TMP + 9
		BPL	1F
		LDA	#'?'
		JSR	OSWRCH
1		LDA	#BASWKSP_STRING / $100
		CALL	ReadKeysTo_PageInA
		TFR	Y,D
		STB	ZP_STRBUFLEN			; length of line read in
		ASL	ZP_FP_TMP + 9
		CLC
		ROR	ZP_FP_TMP + 9			; clear "had prompt" flag
		LDA	#$40
		BITA	ZP_FP_TMP + 9
		BEQ	cmdINPUT_LINE_INPUT
		CLRB
cmdINPUT_LINE_readCommaStrItem				; LB91F
		LDA	#$06
		TFR	D,U
		CALL	readCommaSepString
LB92A
		CALL	skipSpacesCheckCommaAtY
		BEQ	LB935
		CMPA	#$0D
		BNE	LB92A
		LDU	#$FFFF
LB935		TFR	U,D
1		STB	ZP_FP_TMP + 10
cmdINPUT_LINE_INPUT					; LB938
		PULS	CC
		BCS	cmdINPUT_LINE_INPUT_STR
		CALL	pushVarPtrAndType
		CALL	str2Num
		CALL	storeEvaledExpressioninStackedVarPTr
1		PULS	U
		JUMP	cmdINPUT_LINE_lp
cmdINPUT_LINE_INPUT_STR					;LB946:
		CLR	ZP_VARTYPE
		CALL	copyStringToVar2
		BRA	1B



cmdRESTORE
		CLR	ZP_FPB + 3
		LDA	ZP_PAGE_H
		STA	ZP_FPB + 2			; FPB+2=>start of program
		CALL	skipSpacesYStepBack
		CMPA	#':'
		BEQ	LB967
		CMPA	#$0D
		BEQ	LB967
		CMPA	#tknELSE
		BEQ	LB967
		CALL	decodeLineNumberFindProgLine	; expect program line number, find it or BRK
LB967		CALL	scanNextStmtFromY		; scan to start of next statement
		LDD	ZP_FPB + 2			; now pointing at start of line specified or start of program
		STD	ZP_READ_PTR
		JUMP	continue


cmdREAD_next						; LLB975
		CALL	skipSpacesCheckCommaAtYStepBack		; look for comma
		LBNE	scanNextContinue		; if not found continue
							; or fall through for next READ var
cmdREAD
		CALL	findVarOrAllocEmpty
		BEQ	cmdREAD_next			; bad var name, skip
		BCS	cmdREAD_readString		; string ?
		PSHS	U
		CALL	cmdREAD_findNextDataItem
		CALL	pushVarPtrAndType
		CALL	evalAtYAndStoreEvaledExpressioninStackedVarPTr
		BRA	LB99D
cmdREAD_readString
		PSHS	U
		CALL	cmdREAD_findNextDataItem
		CALL	stackINT_WAasINT
		CALL	readCommaSepString
		STA	ZP_VARTYPE
		CALL	copyStringToVar
LB99D
		STU	ZP_READ_PTR
		PULS	U
		BRA	cmdREAD_next

cmdREAD_findNextDataItem
		LDU	ZP_READ_PTR
		CALL	skipSpacesCheckCommaAtY
		BEQ	cmdREAD_dataItemFound
		CMPA	#tknDATA
		BEQ	cmdREAD_dataItemFound
		CMPA	#$0D
		BEQ	cmdREAD_CR
LB9C6
		CALL	skipSpacesCheckCommaAtY
		BEQ	cmdREAD_dataItemFound
		CMPA	#$0D
		BNE	LB9C6
cmdREAD_CR
		LEAX	,U				; save start of line for skip
		LDA	,U+
		BMI	brkOutOfDATA
		LEAU	1,U				; skip 2nd byte of 
		LDB	,U+				; line length
LB9DA
		LDA	,U+
		CMPA	#' '
		BEQ	LB9DA				; skip spaces
		CMPA	#tknDATA			; found DATA token that'll do
		BEQ	cmdREAD_dataItemFound
		ABX					; if not add line length to start of line and continue
		LEAU	,X		
		BRA cmdREAD_CR
brkOutOfDATA
		DO_BRK_B
		FCB	$2A, "Out of ", tknDATA, 0
brkNoREPEAT
		DO_BRK_B
		FCB	$2B, "No ", tknREPEAT, 0
brkMissingHash
		DO_BRK_B
		FCB	$2D, tknMissing, "#", 0
brkTooManyREPEATs
		DO_BRK_B
		FCB	$2C, "Too many ", tknREPEAT, "s", 0
;;LBA13:
;;		INY
;;		STU ZP_TXTOFF2
cmdREAD_dataItemFound
;		LEAU	,X
		RTS

IntWAZero
		PSHS	A
		LDA	ZP_INT_WA
		BMI	1F
		ORA	ZP_INT_WA + 1
		ORA	ZP_INT_WA + 2
		ORA	ZP_INT_WA + 3
1		PULS	A,PC


cmdUNTIL
			
;			;  UNTIL
		CALL	evalExpressionMAIN
		CALL	scanNextStmtFromY
		CALL	checkTypeInZP_VARTYPEConvert2INT
		LDB	ZP_REPEAT_LVL
		BEQ	brkNoREPEAT
		CALL	IntWAZero
		BEQ	1F
		DEC	ZP_REPEAT_LVL			; discard top of repeat stack
		JUMP	continue			; continue
1							; LBA33
		DECB
		ASLB
		LDX	#BASWKSP_REPEATSTACK
		LDU	B,X
		JUMP	STUZPTXTPTR_continue
	; API Change - no longer saves to TXTPTR2
	; TODO: TEST: callers don't push Y
decYSaveAndEvalHashChannelAPI				; LBA3C
		LEAU	-1,U
evalHashChannel						; LBA4A
		CALL	skipSpacesCheckHashAtY
		BNE	brkMissingHash
		CALL	evalLevel1checkTypeStoreAsINT
		LDY	ZP_INT_WA+2
		RTS


cmdREPEAT
			;  REPEAT
		LDB	ZP_REPEAT_LVL
		CMPB	#$14
		BHS	brkTooManyREPEATs
;;		CALL	storeYasTXTPTR
		CALL	checkForESC
		ASLB
		LDX	#BASWKSP_REPEATSTACK
		STU	B,X
		INC	ZP_REPEAT_LVL
		JUMP	skipSpacesAtYexecImmed


ReadKeysTo_InBuf
		LDA	#BAS_InBuf / $100
	IF FLEX = 1
		CLRB
		CALL	FLEX_READLINE
	ELSE
ReadKeysTo_PageInA
		CLRB
		STD	ZP_GEN_PTR
		LDD	#$EE20
		STD	ZP_GEN_PTR + 2
		LDB	#$FF
		STB	ZP_GEN_PTR + 4
		LDX	#ZP_GEN_PTR
;;		LDU	#0
		CLRA
		JSR	OSWORD		; OSWORD 0 - read line to buf at XY
	ENDIF
		BCC	clearPRLINCOUNT
		JUMP	errEscape
PrintCRclearPRLINCOUNT					; LBA92
		JSR	OSNEWL
clearPRLINCOUNT						; LBA95
		CLR	ZP_PRLINCOUNT
		RTS

findLineAndDelete					;LBA98
		CALL	findProgLineNewAPI
		BCC	rtsLBAEA
		STU	ZP_TOP				; we found the line - replace it
		LEAX	,U
		LDB	3,U				; get length of existing line
		CLRA
;;		ADDD	ZP_TOP		
;;		TFR	D,Y
		LEAU	D,U
floCopyLp						; LBAB8
		CALL	floCopy1bytes
		CMPA	#$0D
		BNE	floCopyLp
							;LBAC7:
		CALL	floCopy1bytes			; copy first (line number byte - big endian)
		BMI	floCopySk1			; end of program detected
		CALL	floCopy1bytes			; copy line numbers bytes 
		CALL	floCopy1bytes			; copy length byte
		BRA	floCopyLp
floCopySk1						;LBAD3:
;LBADC:
		STX	ZP_TOP
		RTS
floCopy1bytes
		LDA	,U+
		STA	,X+
rtsLBAEA	RTS
			
		;  Tokenise line, enter into program if program line
		;  returns CY=1 if this is a program line

tokenizeAndStore
		LDA	#$FF
		STA	ZP_OPT
		STA	ZP_FPB + 1
		CALL	ResetStackProgStartRepeatGosubFor		;  do various CLEARs
		LDU	ZP_TXTPTR
		CLR	ZP_FPB
		CALL	tokenizeATY
		LDU	ZP_TXTPTR
		CALL	skipSpacesDecodeLineNumberNewAPI
		BCC	rtsLBAEA
tokenizeAndStoreAlreadyLineNoDecoded					; LBB08
		CLRB
		TST	ZP_LISTO
		BEQ	tokAndStoreListo0
		JSR	skipSpacesYStepBack		
tokAndStoreListo0							;LBB15:
		STU	ZP_FPB
		CALL	findLineAndDelete  
		LDU	ZP_FPB
		LDA	#$0D
		LDB	#1						; count line length
		CMPA	,U+		
		BEQ	rtsLBAEA					; line was nowt but white space, return
tokas_lp2	INCB							;LBB26:
		CMPA	,U+
		BNE	tokas_lp2					; move to EOL marker $D
		LDA	#' '
		LEAU	-1,U
tokas_lp3	DECB							;LBB2D:
		CMPA	,-U
		BEQ tokas_lp3						; skip back over spaces
tokas_sk1	LEAU	1,U						;LBB34:
		LDA	#$0D
		STA	,U						; another EOL marker remove trailing whitespace
		ADDB	#4
		STB	ZP_FPB + 4
		LDX	ZP_TOP
		CLRA
		ADDD	ZP_TOP
		STD	ZP_TOP		
		CMPD	ZP_HIMEM
		BLS	tokas_sk2_spaceok
		CALL	findTOP
		CALL	ResetVars
		DO_BRK_B
		FCB  0, tknLINE, " space", 0


tokas_sk2_spaceok							;LBB6B:
		TFR	D,U
		LEAU	1,U
		LEAX	1,X
tokas_lp4
		LDA	,-X
		STA	,-U
		CMPX	ZP_FPB + 2
		BNE	tokas_lp4


		LEAX	1,X						; move past 0d marker
		LDD	ZP_INT_WA + 2					; get decoded big endian line number
		STD	,X++
		LDB	ZP_FPB + 4					; line length
		STB	,X+	

		SUBB	#4						; reduce line length counter by 4
		LDU	ZP_FPB
tokas_lp5	LDA	,U+						; copy from $700 to program memory
		STA	,X+
		DECB
		BNE	tokas_lp5
		SEC
		RTS
;		
ResetVars	LDD ZP_TOP
		STD ZP_LOMEM
		STD ZP_VARTOP					;  LOMEM=TOP, VARTOP=TOP
		CALL ResetStackProgStartRepeatGosubFor
;			;  Reset DATA, REPEAT, FOR, GOSUB
;			;  Clear dynamic variables
;			;  -----------------------
InittblFPRtnAddr
		PSHS	U
		LDX 	#$10
1		LDD 	tblFPRtnAddr_const-2,X
		STD 	$07F0-2,X				;  Copy entry addresses to $07F0-$07FF
		LEAX	 -2, X
		BNE 	1B
		LDA 	#$40
		LDX 	#0
		LDU 	#BASWKSP_DYNVAR_HEADS
1		STX 	,U++
		DECA	
		BNE 	1B					;  Clear dynamic variables
		PULS	U,PC
ResetStackProgStartRepeatGosubFor
		LDA	ZP_PAGE_H
		CLRB
		STD	ZP_READ_PTR				;  DATA pointer = PAGE
		LDD	ZP_HIMEM				;  STACKBOT=HIMEM
		STD	ZP_BAS_SP
	IF CPU_6309
		AIM	#$7F,ZP_LISTO
	ELSE
		LDA	ZP_LISTO
		ANDA	#$7F
		STA	ZP_LISTO
	ENDIF
		CLR	ZP_REPEAT_LVL
		CLR	ZP_FOR_LVL_X_15
		CLR	ZP_GOSUB_LVL;			;  Clear REPEAT, FOR, GOSUB stacks
		RTS					;  DATA pointer = PAGE
;		
;		
popFPandSetPTR1toStack			; pop FP from stack, set out old stack pointer in PTR1
		LDY	ZP_BAS_SP
		STY	ZP_FP_TMP_PTR1
		LEAY	5,Y
		STY	ZP_BAS_SP
		RTS

fpStackWAtoStackReal	
		LDB	#-5
		CALL	UpdStackByBCheckFull		; make room for a float on the stack
		LDA	ZP_FPA + 2
		STA	0,X
		LDA	ZP_FPA
		EORA	ZP_FPA + 3
		ANDA	#$80
		EORA	ZP_FPA + 3			; Get top bit of sign byte and seven other bits of mantissa MSB
		STA	1,X

		LDD	ZP_FPA + 4
		STD	2,X

		LDA	ZP_FPA + 6
		STA	4,X
		RTS
stackVarTypeInFlags
		BEQ	StackString
		BMI	fpStackWAtoStackReal
stackINT_WAasINT				; LBC26
		LDB	#-4
		CALL	UpdStackByBCheckFull
		LDD	ZP_INT_WA
		STD	,X
		LDD	ZP_INT_WA + 2
		STD	2,X
		RTS
pushVarPtrAndType				; was pullRETpushIntAtoIntAplus2pushRET
		PULS	X
		LDD	ZP_INT_WA + 2
		PSHS	D
		LDA	ZP_INT_WA + 0
		PSHS	A
		JMP	0,X


;		;  Stack the current string
;		;  ========================
StackString
		PSHS	B,X,U
		LDB	ZP_STRBUFLEN			; Calculate new stack pointer address
		LDA	#$FF
		COMB					; D now contains -(ZP_STRBUFLEN + 1)
		LDX	ZP_BAS_SP
		LEAX	D,X
		CALL	UpdStackFromXCheckFull
		LDB	ZP_STRBUFLEN			; store len as first byte of stacked data
		STB	,X+
		BEQ	stackstrsk0
		LDU	#BAS_StrA			; followed by the string data
stackstrlp0	LDA	,U+
		STA	,X+
		DECB
		BNE	stackstrlp0
stackstrsk0	PULS	B,X,U,PC

;	
;		
delocaliseAtZP_GEN_PTR
		PSHS	U
		LDU	ZP_BAS_SP
		LDA	ZP_NAMELENORVT			; get variable type
		CMPA	#VAR_TYPE_STRING_STAT
		BEQ	delocalizeStaticString		; was a static string
		BLO	delocalizeNum

		;delocalise Dynamic String

		LDX	ZP_GEN_PTR + 2			; string params pointer
		LDB	,U+				; get stacked string length
		STB	3,X
		BRA	strCpFin


delocCopyB
		CALL	copyBatUtoX

2							; LBC8D:
delocExit
		STU	ZP_BAS_SP
		PULS	U,PC

copyBatUtoX
1		LDA	,U+
		STA	,X+
		DECB
		BNE	1B
		RTS


delocalizeStaticString					; LBC95
		LDX	ZP_GEN_PTR + 2			; get address to restore string to 
		LDB	,U+				; get stacked string length
strCpFin
		BEQ	2F
		CALL	copyBatUtoX
2		LDA	#$0D
		STA	,X+
		BRA	delocExit
delocalizeNum						; LBCAA
		LDX	ZP_GEN_PTR + 2
		LDB	ZP_NAMELENORVT			; get var type
		BEQ	delocCopy1
		CMPB	#2
		BNE	delocCopyB
		CALL	getLEUtoX			; copy and reverse bytes
		BRA	delocExit
delocCopy1
		LEAU	3,U				; stacked as a 4 byte INT TODO: store as 1 byte int?
		INCB
		BRA	delocCopyB

		; new API - trashes A, X
popStackedStringNew					; LBCD2

		PSHS	U
		LDU	ZP_BAS_SP
		LDX	#BASWKSP_STRING
		LDB	,U+				; first byte contains length
		STB	ZP_STRBUFLEN
		BEQ	delocExit
		CALL	copyBatUtoX
		BRA	delocExit		


		; New API - after call all regs preserved
popIntANew
		PSHS	D,U,X
		LDX	#ZP_INT_WA
		BRA	1F
popIntAtZP_GEN_PTRNew				; LBD06
		LDX #ZP_GEN_PTR			; TODO - WORK THIS LOT OUT!
		; NOTE: trashes A,B
popIntAtXNew					; LBD08
		PSHS	D,U,X
1		LDU	ZP_BAS_SP
		LDB	#4
		CALL	copyBatUtoX
		STU	ZP_BAS_SP
		PULS	D,U,X,PC
UpdStackByBCheckFull
		LDX	ZP_BAS_SP
		SEX
		LEAX	D,X
UpdStackFromXCheckFull
		CMPX	ZP_TOP
		BLO	brabrkNoRoom
		STX	ZP_BAS_SP
		RTS
;
ResetVarsBrkNoRoom
		CALL ResetVars
brabrkNoRoom	JUMP brkNoRoom
;
;
;
doListPrintTokenA					; LBD37
		CMPA	#$80
		BLO	list_printA				; just a normal char print it and continue
		STA	ZP_GEN_PTR
		PSHS	X,U
		LEAX	tblTOKENS,PCR

doListTryNextTok						; LBD46
		LEAU	,X					; Y points to name of current token
doListSkipKey							;LBD48:
		LDA	,X+					; TODO probably can skip first and 2nd char every time?
		BPL	doListSkipKey				; not a token skip it
		CMPA	ZP_GEN_PTR
		BEQ	doListKeyLp				; it's the right token
		LEAX	1,X					; skip flags
		BRA	doListTryNextTok
doListKeyLp							;LBD60:
		LDA	,U+
		BMI	doListKeyFinished
		CALL	list_printA
		BRA	doListKeyLp
doListKeyFinished						;LBD6A:
		PULS	X,U,PC


list_printHexByte					; LBD6C
		PSHS	A
		LSRA
		LSRA
		LSRA
		LSRA
		CALL	list_printHexNybble
		PULS	A
		ANDA	#$0F
list_printHexNybble					; LBD77
		CMPA	#$0A
		BLO	list_printAasDigit
		ADDA	#$07
list_printAasDigit					; LBD7D
		ADDA	#$30
list_printCheckPRLINCOUNT				; LBD7F
		PSHS	A
		LDA	ZP_WIDTH
		CMPA	ZP_PRLINCOUNT
		BCC	list_printCheckPRLINCOUNT_sk1
		CALL	PrintCRclearPRLINCOUNT
list_printCheckPRLINCOUNT_sk1				; LBD89:
		PULS	A
		INC	ZP_PRLINCOUNT
		JMP	OSWRCH
list_printHexByteAndSpace				; LBD8F
		CALL list_printHexByte
list_print1Space					; LBD92
		LDA	#$20
list_printA						; LBD94
		TST	ZP_LISTO
		BMI	list_printToVARTOP
list_printANoEDIT					; LBD98
		CMPA	#$0D
		BNE	list_printCheckPRLINCOUNT
		JSR	OSWRCH
		JUMP	clearPRLINCOUNT
list_printToVARTOP					; LBDA2
		STA	[ZP_VARTOP]			; store at VARTOP for EDIT
		INC	ZP_VARTOP
		BNE	rtsLBDC5
		INC	ZP_VARTOP + 1
		PSHS	A
		LDA	ZP_VARTOP + 1
		EORA	ZP_HIMEM + 1
		BEQ	ResetVarsBrkNoRoom		; out of space for listing
		PULS	A
		RTS
doLISTOSpacesCLC					; LBDB3
		CLC
doLISTOSpaces						; LBDB4
		ANDA	ZP_LISTO
		BEQ	rtsLBDC5
		ROLB
		BCS	rtsLBDC5	
		BEQ	rtsLBDC5
list_printBSpaces			;LBDBF:
		CALL	list_print1Space
		DECB
		BNE	list_printBSpaces
rtsLBDC5
		RTS
;		
;		
CopyIntWA2X				   ; DB: Changed this to use 16 bit reg and X can point anywhere!
		PSHS	D
		LDD	ZP_INT_WA + 0
		STD	,X
		LDD	ZP_INT_WA + 2
		STD	2,X
		PULS	D
		RTS

	IF FLEX
brkBadFileName	DO_BRK_B
		FCB	100				; TODOFLEX - made up error number
		FCB	"Bad filename", 0


FMS_ERR		LDA	FCBOFFS_ERR,X
		PSHS	A
		LDA	#FMS_CLOSE
		STA	,X
		JSR	FMS
		PULS	B
		ORB	#$40					; TODOFLEX - arbitrary number here!
		JMP	FLEXERROR
	ENDIF


;		
;			;  Load program to PAGE
;			;  --------------------
loadProg2Page
	IF FLEX = 1
		CALL	evalYExpectString
		LDB	ZP_STRBUFLEN
		BEQ	brkBadFileName
		BMI	brkBadFileName
		; copy filename to LINBUF
		LDU	#BASWKSP_STRING
		LDX	#LINBUF
		STX	CBUFPT
1		LDA	,U+
		STA	,X+
		DECB
		BNE	1B
		LDA	#$D
		STA	,X+
		LDX	#SYSFCB
		JSR	GETFIL
		BCS	brkBadFileName
		LDA	#SETEXT_BAS
		JSR	SETEXT
		LDA	#FMS_OPENRD
		STA	,X
		JSR	FMS
		BNE	FMS_ERR
		LDA	#$FF
		STA	FCBOFFS_COMPRESS,X			; BINary file
		LDA	ZP_PAGE_H
		CLRB
		TFR	D,U
		LDA	#FMS_RDWR
		STA	,X
1		JSR	FMS
		BNE	FMS_CK_EOF
		STA	,U+
		CMPU	ZP_HIMEM
		BLO	1B
		BRA	1F
FMS_CK_EOF	LDA	FCBOFFS_ERR,X				; Get error number
		CMPA	#FMS_ERR_EOF
		BNE	FMS_ERR
1		LDA	#FMS_CLOSE
		STA	,X
		JSR	FMS
	ELSE
		CALL	GetFileNamePageAndHighOrderAddr	; get cr-string, FILE_NAME=STRA, FILE_LOAD=PAGE/memhigh
; Returns FILE_NAME=>string
;         FILE_EXEC=&00000000
;         X=machine high address
;         D=page
;         Cy=big/little
;
		LDU	#ZP_GEN_PTR+2
		CALL	StoreFileAddress		; Store PAGE at ctrl+2/3/4/5
		LDA	#OSFILE_LOAD
		LDX	#ZP_GEN_PTR			;  Point to OSFILE block
		JSR	OSFILE				;  Continue into FindTOP
	ENDIF
findTOP		LDA	ZP_PAGE_H
		CLRB
		TFR	D,X
		STD	ZP_TOP	
ftop_lp1	LDB	,X
		CMPB	#$0D
		BNE	printBadProgram			; check for CR
		LDB	1,X				; check for -ve line number (end of program)
		BMI	ftop_sk1
		LDB	3,X				; check line length and add for next line
		BEQ	printBadProgram
		CLRA
		ADDD	ZP_TOP
		STD	ZP_TOP
		TFR	D, X
		BRA	ftop_lp1
ftop_sk1	
		LEAX	2,X
		STX	ZP_TOP
		RTS
printBadProgram
		LEAX	str_bad_prog,PCR
		JSR	PRSTRING
		JUMP	immedPrompt

str_bad_prog	FCN 	"\rBad program\r"

;		
str600CRterm	LDX	#BAS_StrA
1		LDB	ZP_STRBUFLEN			;  Get length of string in buffer
		LDA	#$0D
		PSHS	X
		ABX
		STA 	,X
		PULS	X,PC				;  Store <cr> at end of string

evalYExpectString					; LBE36
		CALL	evalExpressionMAIN		;  Call expression evaluator
		TSTA
		LBNE	brkTypeMismatch			
		CALL	str600CRterm			; put terminating <cr> in
		STX	ZP_SAVE_BUF			; Point 37/8 to STRA, TODO: check needed!
		LDA	,U
		JUMP	scanNextExpectColonElseCR

	IF FLEX != 1
OSByte82	LDA	#$82
		JMP	OSBYTE
GetFileNamePageAndHighOrderAddr				; LBE41
		CALL	evalYExpectString		; Get CR-string
		CALL	OSByte82
		CLRA
		CLRB
		STD	ZP_GEN_PTR+6			; exec=0 regardless of endianness
		STD	ZP_GEN_PTR+8
		LDA	ZP_BIGEND
		ASLA					; Cy=big/little
		LDA	ZP_PAGE_H			; D=PAGE
		RTS
StoreFileAddressNext
		LEAU	4,U				; Point to next address
StoreFileAddress
		PSHS	X
		LDX	#0
		BCC	StoreFileBigAddr
		EXG	A,B				; Swap to make little-endian
		EXG	X,D
StoreFileBigAddr
		STX	0,U
		STD	2,U
		PULS	X,PC
	ENDIF

cmdSAVE							; LBE55
	IF FLEX = 1
		JUMP	brkFlexNotImpl
	ELSE
		PSHS	U
		CALL	findTOP
		CALL	GetFileNamePageAndHighOrderAddr		
; Returns FILE_NAME=>string
;         FILE_EXEC=&00000000
;         X=machine high address
;         D=page
;         Cy=big/little
;
		LDU	#ZP_SAVE_BUF+10
		CALL	StoreFileAddress		; FILE_START=PAGE
		LDD	ZP_TOP
		CALL	StoreFileAddressNext		; FILE_END=TOP
		LDU	#ZP_SAVE_BUF+2
		LDX	#$FFFF
		LDD	#$FB00
		CALL	StoreFileAddress		; FILE_LOAD=FFFFFB00 = filetyped to BASIC

;+;		LDX	#ZP_SAVE_BUF+5			; Implement this bit later
;+;		LDA	#3
;+;		STX	0,X
;+;		LDA	#14
;+;		CALL	varGetTime2			; Read RTC datestamp to FILE_EXEC

		LDA	#OSFILE_SAVE			; OSFILE 0
		LDX	#ZP_SAVE_BUF
		JSR	OSFILE
		PULS	U
		JUMP	continue
	ENDIF
cmdOSCLI
		CALL	evalYExpectString
		LDX	#BASWKSP_STRING
		PSHS	U
		JSR	OSCLI
		PULS	U
		JUMP	continue

			; EXT#channel=number
			; ------------------
cmdEXTEq					; LBE93
	IF FLEX = 1
		JUMP	brkFlexNotImpl
	ELSE
		LDA	#$03			; 03=Set extent
		BRA	varSetFInfo
	ENDIF

			; PTR#channel=number
			; ------------------
varSetPTR					; LBE97
	IF FLEX = 1
		JUMP	brkFlexNotImpl
	ELSE
		LDA	#$01			; 01=Set pointer
varSetFInfo					; LBE99
		PSHS	A
		CALL	evalHashChannel		; Evaluate #channel, save TXTPTR, Y=channel
		CALL	skipSpacesExpectEqEvalExp
		CALL	checkTypeInZP_VARTYPEConvert2INT
		TST	ZP_BIGEND
		BMI	1F
		CALL	SwapEndian		; Swap INTA
1		STU	ZP_TXTPTR		; Save TXTPTR
		LDX	#ZP_INT_WA
		PULS	A			; Get action and channel
		JSR	OSARGS			; Write from INTA
		LDU	ZP_TXTPTR		; Get TXTPTR back
		JUMP	continue		; Return to main execution loop
	ENDIF
			; CLOSE#channel
			; -------------
cmdCLOSE					; LBEAE
	IF FLEX = 1
		JUMP	brkFlexNotImpl
	ELSE
		CALL	evalHashChannel		; Evaluate #channel, save TXTPTR, Y=channel
		CLRA				; A=$00 for CLOSE
		JSR	OSFIND
		JUMP	continue		; Return to main execution loop
	ENDIF
			; BPUT#channel,number
			; -------------------
cmdBPUT						; LBEBD
	IF FLEX = 1
		JUMP	brkFlexNotImpl
	ELSE
		CALL	evalHashChannel		; Evaluate #channel, save TXTPTR, Y=channel
		CALL	checkCommaThenEvalAtYcheckTypeInAConvert2INT
		LDA	ZP_INT_WA+3		; Get low byte of number
		JSR	OSBPUT			; Write to channel
		LDU	ZP_TXTPTR		; Get TXTPTR back
		JUMP	continue		; Return to main execution loop
	ENDIF


;;callOSWORD5INT_WA				; get a byte from host processor
;;; not actually needed, 6809 BBC API defined to pass X=>command line on entry
;;		TODODEADEND "callOSWORD5INT_WA - endianness, sort out"
;;		LDA	#$05
;;		PSHU	X
;;		LDX	#ZP_INT_WA
;;		LDU	#0			; DP
;;		JSR	OSWORD
;;		PULU	X
;;		LDA	ZP_INT_WA + 4		; return value in A
inc_INT_WA	INC	ZP_INT_WA + 3		; increment - note big endianness
		BNE	1F
		INC	ZP_INT_WA + 2
		BNE	1F
		INC	ZP_INT_WA + 1
		BNE	1F
		INC	ZP_INT_WA + 0
1		RTS


deleteProgSetTOP
		LDA	ZP_PAGE_H
		CLRB
		CLR	ZP_TRACE
		TFR	D, X
		LDD	#$0DFF			; 0 length program
		STD	,X++			; store at page
		STX	ZP_TOP
		RTS

;			;  Floating-Point Routine Entries
;			;  ==============================
;			;  Copied to $07F0-$07FF
;			;
;		.segment "BF14"
;		.org	$BF14
tblFPRtnAddr_const
		FDB	fpFPAeq_sqr_FPA		;  FloatA = SQR(FloatA)
		FDB	fpFPAeqPTR1divFPA	;  FloatA = ArgP / FloatA
		FDB	fpFPAeqPTR1mulFPA	;  FloatA = ArpP * FloatA
		FDB	fpFPAeqPTR1addFPA	;  FloatA = ArgP + FloatA
		FDB	fpNegateFP_A		;  FloatA = -FloatA
		FDB	fpCopyPTR1toFPA		;  FloatA = (ArgP)
		FDB	fpCopyFPA_PTR1		;  (ArgP) = FloatA
		FCB	ZP_FP_TMP_PTR1		;  Zero page address of ArgP
		FCB	ZP_FPA		;  Zero page address of FloatA
;FPCONST:
fpConstMinPiDiv2	FCB	$81, $C9, $10, $00, $00	; -PI/2
fpConst4_454e_6		FCB	$6F, $15, $77, $7A, $61	; 4.4544551105e-06
fpConstPiDiv2		FCB	$81, $49, $0F, $DA, $A2	; PI/2
fpConst2DivPi		FCB	$80, $22, $F9, $83, $6E ; 2/PI = 0.6366
fpConstDeg2Rad		FCB	$7B, $0E, $FA, $35, $12	;  1.74E-2 - 1 deg in rads
fpConstRad2Deg		FCB	$86, $65, $2E, $E0, $D3	;  57.29 - 1 rad in degrees
fpConst0_43429		FCB	$7F, $5E, $5B, $D8, $AA	;  4.3429448199e-01
fpConst_e		FCB	$82, $2D, $F8, $54, $58	;  e = 2.7182818279e+00
fpConst_ln_2		FCB	$80, $31, $72, $17, $F8	;  ln(2) = 6.9314718130e-01
fpConst0_54625		FCB	$80, $0B, $D7, $50, $29	;  5.4625416757e-01
			FCB	$7C, $D2, $7C, $86, $05	;  -5.1388286127e-02
			FCB	$80, $15, $52, $B6, $36	;  5.8329333132e-01 ;  $BF60
			FCB	$7C, $99, $98, $36, $04	;  -3.7498675345e-02
			FCB	$80, $40, $00, $01, $10	;   3/4	 (7.5000006333e-01)
			FCB	$7F, $2A, $AA, $AA, $E3	;   1/3	 (3.3333333989e-01)
fpConstMin0_5		FCB	$7F, $FF, $FF, $FF, $FF	;  -1/2
fpConstMin0_011909	FCB	$7A, $C3, $1E, $18, $BE	; -1.1909031069e-02 ; Used in SIN/COS
			FCB	$73, $61, $71, $55, $2D ;  1.074994592E-4
			FCB	$7B, $8C, $9B, $91, $88 ; -1.716402458E-2
			FCB	$77, $2B, $A4, $C4, $53 ;  1.309536901e-3
			FCB	$7C, $4C, $CC, $CA, $B7 ;  4.999999223e-2
			FCB	$7E, $AA, $AA, $AA, $A6 ; -0.1666666664
fpConst1		FCB	$81, $00, $00, $00, $00	; 1
fpConstMin0_08005	FCB	$7D, $A3, $F2, $EF, $44	;  -8.0053204787e-02
			FCB	$7E, $1F, $01, $A1, $4D ; 0.155279656
			FCB	$7F, $61, $6D, $F4, $3F ; 0.440292008
			FCB	$7E, $5C, $91, $23, $AC ; 0.215397413
			FCB	$7E, $76, $B8, $8D, $1A ; 0.240938382
;			;  $BFB0
			FCB	$7D, $1D, $3E, $AB, $2C ; 7.67796872e-02
			FCB	$81, $09, $41, $81, $D2 ; 1.07231162
			FCB	$80, $74, $DF, $BD, $20 ; 0.956538983
			FCB	$80, $83, $8B, $1F, $B5 ; -0.513841612
			FCB	$7F, $82, $59, $AD, $AB ; -0.254590442
fpConst0_9273		FCB	$80, $6D, $63, $38, $2C	;  9.2729521822e-01
fpConst0_07121		FCB	$7D, $11, $D4, $B1, $D1	;  7.1206463996e-02
			FCB	$79, $68, $BC, $4F, $59	; 7.10252642e-03
			FCB	$75, $05, $2C, $9E, $39 ; 2.54009799e-04
			FCB	$7B, $08, $88, $3B, $A6 ; 1.66665235e-02
			FCB	$6C, $31, $CF, $D1, $8C	;  6.6240054064e-07
			FCB	$7D, $2A, $AA, $AA, $89	;   8.33
			FCB	$7F, $FF, $FF, $FF, $E8	;  -0.5
			FCB	$81, $00, $00, $00, $00	;   1.0
fpConst1__2		FCB	$81, $00, $00, $00, $00	;   1.0

__CODE_END

__FREESPACE 	EQU $C000-__CODE_END

