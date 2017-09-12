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

			INCLUDE		"../../includes/common.inc"
			INCLUDE		"../../includes/mosrom.inc"
			INCLUDE		"../../includes/oslib.inc"


DEBUG			EQU	1
LOADADDR		EQU $8000
COMPADDR		EQU $8000
TABLESADDR		EQU $BC00

			INCLUDE		"./macros.inc"
			INCLUDE		"./zp.inc"
			INCLUDE		"./tokens.inc"
			INCLUDE		"./layout.inc"






************************** SETUP TABLES AND CODE AREAS ******************************
			CODE
			ORG	COMPADDR
			SETDP	$00
			SECTION	"tables_and_strings"
			ORG	TABLESADDR

************************** START MAIN ROM CODE ******************************
			CODE
ROMSTART		CMPA	#1
			BEQ	ROM_LANGST
			RTS
			FCB	0
			FCB	$63				;  ROM type=Lang+6809 BASIC 
			FCB	ROM_COPYR-ROMSTART		;  Copyright offset
			FCB	$04				;  ROM version
			FCB	"BASIC 6809"			;  ROM title
			FCB	0
			FCB	"4.33"
ROM_COPYR		FCB	$00
			FCB	"(C)2017 Dossytronics"		;  ROM copyright string
			FCB	$0A
			FCB	$0D
			FCB	$00
			FCB	LOADADDR % 256			; Second processor transfer address, no longer overlaps with 10s table
			FCB	LOADADDR / 256			; Note store in 6502 byte order!
								; High word ($0000) overlaps next table
			FCB	0				; extra zero for load address was getting 01 from changed tens table

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


;
;		;  LANGUAGE STARTUP
;		;  ================
ROM_LANGST	RESET_MACH_STACK
		STA	,-S				; store A



;;		CLRA
;;		TFR	A, DP				; Default direct page

		CALL	OSINIT					; A=0, Set up default environment
		STA	ZP_BIGEND
		STY	ZP_ESCPTR
		LEAU	HandleBRK, PCR
		STU	,X					; Claim BRKV

		LEAU	ROM_COPYR, PCR
		STU	zp_mos_error_ptr

		LDA	#$84
		JSR	OSBYTE					; Read top of memory, set HIMEM
		STX	ZP_HIMEM
		LEAX	ROMSTART,PCR
		CMPX	ZP_HIMEM				; check to see if the returned HIMEM is > than start of ROM
		BHS	1F					; if it is ignore it and set to start of ROM - this for
		STX	ZP_HIMEM				; old matchbox copros with unfixed tube client code
1		DECA
		JSR	OSBYTE
		TFR	X,D					; A=high byte of returned bottom of memory
		CMPA	#8
		BLS	2F					; Too low, reserve space for workspace
		CMPA	ZP_HIMEM				; check to see that returned page isn't too high (matchbox client code fix)
		BLO	1F
2		LDA	#8					; make PAGE at least 800 to leave room for ZP, stack, variable pointers etc
1		STA	ZP_PAGE_H				; Read bottom of memory, set PAGE
								; Will need more work to do "per task" memory relocations

	IF DEBUG != 0
		TST	ZP_BIGEND
		BEQ	1F
		PRINT_STR	"(LE"
		BRA	2F
1		PRINT_STR	"(BE"
2		PRINT_STR	", page="
		LDA	ZP_PAGE_H
		JSR	PRHEX
		PRINT_STR "00, himem="
		LDX	ZP_HIMEM
		JSR	PR2HEX

		PRINT_STR ", swr#="

		LDA	<$F4	; get current rom number
		JSR	PRHEX

	IF MATCHBOX != 0
		PRINT_STR ", MATCHBOX)\r"
	ELSE
		PRINT_STR ", chipkit)\r"
	ENDIF
	ENDIF

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

		ANDCC	#~(CC_I + CC_F)				; enable IRQ, FIRQ
		JUMP	reset_prog_enter_immedprompt		;  Enable IRQs, jump to immediate loop - DB - I've kept this similar as I may want to add command line params later...



	include		"./tokenstable.asm"


;		
;		
;		;  Look up FN/PROC address
;		;  =======================
;		;  On entry, B=length of name
;		;	     (ZP_GEN_PTR)+1=>FN/PROC token (ie, first character of name)
findFNPROC	PSHS	Y
		STB	ZP_NAMELENORVT			;  Store length of name
		LDY	ZP_GEN_PTR
		LDA	1,Y				;  Get FN/PROC character
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
;			;	     (ZP_GEN_PTR)+1=>first character of name
			;  On exit
			;	Z = 1 for not found
			;	else X and ZP_INT_WA + 2 points at variable data
findVarNewAPI
		PSHS	Y
		STB	ZP_NAMELENORVT			;  Store length of name
		LDY	ZP_GEN_PTR
		LDB 	1,Y				;  Get initial letter
		ASLB
;			;  Follow linked variable list to find named item
;			;  ----------------------------------------------
;			;  B = offset in Page 4 link start table
findLinkedListNewAPI
		LDA	#BASWKSP_INTVAR / 256
		TFR	D,X
		LDB	#2
		LDX	,X				; X contains pointer to first var block (or zero)
		BRA	fll_skitem								
fll_nextItem	
		LDX	,X
fll_skitem	BEQ	fll_sk_nomatch				
		*STX	ZP_INT_WA + 2			; store pointer
fll_chlp	LDA	B,X
		BEQ	fll_sk_nameEnd
		CMPA	B,Y
		BNE	fll_nextItem
		INCB
		CMPB	ZP_NAMELENORVT			; at end of name?
		BNE	fll_chlp
		LDA	B, X				; at end of name - check 0 term in dynvar
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
		PULS	Y,PC				;  not matched Z = 1


		;  Search for program line
		;  =======================
		; NEW API
		;  On entry,	ZP_INT_WA + 2 => line number
		;  On Exit,	Y and ZP_FPB + 2 => program line start or next line (points at the 0D at start of this line)
		;		Cy=1 indicates line found
		;		Cy=0 not found
	;  TODO: check all occurrences and remove store to ZP_FPB if not ever used
		; OLD API
		;  On entry,	ZP_INT_WA = line number
		;  On exit,  ZP_FPB + 2 =>program line, or next line
		;	     CS = line found
		;	     CC = line not found
		;	    NOTE: Y = 2 always - TODO: Remove ?
		
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
		ORCC	#CC_C
flp_sk1		STX	ZP_FPB + 2
		LEAY	,X
		RTS
;		
;		
;;findProgLineNewAPI: 
;;		STZ ZP_FPB + 2
;;		LDA ZP_PAGE_H
;;		STA ZP_FPB + 3			;  Start at PAGE
;;@lp1:		LDY #$01
;;		LDA (ZP_FPB + 2),Y			;  Check line number high byte
;;		CMP ZP_INT_WA + 1
;;		BCS @sk1				;  Partial match, jump to check low byte
;;@lp2:		LDY #$03
;;		LDA (ZP_FPB + 2),Y			;  Get line length
;;		ADC ZP_FPB + 2
;;		STA ZP_FPB + 2			;  Step to next line
;;		BCC @lp1
;;		INC ZP_FPB + 3
;;		BRA @lp1				;  Loop back to check next line
;;@sk1:		BNE @sk2				;  Gone past target, jump to return CC and Y=2
;;		INY
;;		LDA (ZP_FPB + 2),Y			;  Check line number low byte
;;		CMP ZP_INT_WA
;;		BCC @lp2				;  line < target, step to next line
;;		BNE @sk2				;  Line not equal, jump to return CC
;;		RTS					;  Line found, return CS and Y=2
;;@sk2:		LDY #$02
;;		CLC
;;		RTS					;  Line not found, return CC and Y=2
;
;			
;			
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
		STA	ZP_GEN_PTR + 1			; save sign of LHS as sign of remainder
		CALL	intWA_ABS			; Ensure LHS is positive
		CALL	stackINTEvalLevel2		; Stack LHS, evaluate RHS
		STB	ZP_VARTYPE			; Save current token
		CALL	checkTypeInAConvert2INT		; Save next character, convert Real to Int
		LDA	ZP_GEN_PTR + 1			; get back sign of remainder
		EORA	ZP_INT_WA + 0			
		STA	ZP_GEN_PTR			; EOR with sign of RHS to get sign of result
		CALL	intWA_ABS			; Ensure RHS is positive
		LDX	#ZP_INT_WA_B			
		CALL	popIntAtXNew			; Pop LHS from stack to IntB at $39-$3C
		CLRA
		STA	ZP_INT_WA_C
		STA	ZP_INT_WA_C + 1
		STA	ZP_INT_WA_C + 2
		STA	ZP_INT_WA_C + 3			; Clear remainder in IntC
		LDA	ZP_INT_WA + 3
		ORA	ZP_INT_WA
		ORA	ZP_INT_WA + 1
		ORA	ZP_INT_WA + 2			; Check if IntA is zero
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
		LDD	,S++
		STD	ZP_INT_WA_C + 2			; Remainder=Remainder-Divisor
		BRA	5F				; Loop to do next bit
4							; L816C:
		ANDCC	#~CC_C				; swap carry
		LEAS	2,S				; Couldn't subtract, drop stacked value
		BRA	6F
5							; L816E:
		ORCC	#CC_C				; swap carry
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
		LSR	ZP_FPA + 3
		ROR	ZP_FPA + 4			; Divide the mantissa by 2 to denormalise by one power
		ROR	ZP_FPA + 5
		ROR	ZP_FPA + 6
		INCA
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
		LSR	ZP_FPA + 3			; roll A mantissa into B mantissa
		ROR	ZP_FPA + 4
		ROR	ZP_FPA + 5
		ROR	ZP_FPA + 6
		ROR	ZP_FPB + 2
		ROR	ZP_FPB + 3
		ROR	ZP_FPB + 4
		ROR	ZP_FPB + 5
		INCA
		BEQ	fpMant2Int_brkTooBig
L8293
		CMPA	#$A0				; compare to A0, i.e. $80 + 32
		BHS	fpMant2Int_brkTooBigIfNE	; if so then if equal return else too big
		CMPA	#$99
		BHS	L8280				; keep rolling bitwise
		ADDA	#$08				; else roll bytewise
		LDB	ZP_FPB + 4
		STB	ZP_FPB + 5
		LDB	ZP_FPB + 3
		STB	ZP_FPB + 4
		LDB	ZP_FPB + 2
		STB	ZP_FPB + 3
		
		LDB	ZP_FPA + 6
		STB	ZP_FPB + 2
		
		LDB	ZP_FPA + 5
		STB	ZP_FPA + 6		
		LDB	ZP_FPA + 4
		STB	ZP_FPA + 5		
		LDB	ZP_FPA + 3
		STB	ZP_FPA + 4
		
		CLR	ZP_FPA + 3
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
L82E0
		LDA	ZP_FPA + 2
		BMI	L82E9
		CLR	ZP_FP_TMP + 6
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

fpCopyBtoA_NewAPI					; L8349		- note TRASHES X, B
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
		LSR	ZP_FPB + 2
		ROR	ZP_FPB + 3
		ROR	ZP_FPB + 4
		ROR	ZP_FPB + 5
		ROR	ZP_FPB + 6
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
fpAddAtoBStoreA_shr1_A_lp				; L83D5:
		LSR	ZP_FPA + 3
		ROR	ZP_FPA + 4
		ROR	ZP_FPA + 5
		ROR	ZP_FPA + 6
		ROR	ZP_FPA + 7
		DECA
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
		STA	ZP_FPA + 6

		LDD	ZP_FPB + 3
		SBCB	ZP_FPA + 5
		SBCA	ZP_FPA + 4
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
		SBCB	ZP_FPB + 4
		SBCA	ZP_FPB + 3
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
;		
;		
;		
;			;  ASSEMBLER
;			;  =========
;			;  Packed mnemonic table, low bytes
;			;  --------------------------------
;L884D:
;		.byte  $4B
;		.byte  $83
;		.byte  $84
;		.byte  $89
;		.byte  $96
;		.byte  $B8
;		.byte  $B9
;		.byte  $D8
;		.byte  $D9
;		.byte  $F0
;		.byte  $01
;		.byte  $10
;		.byte  $81
;		.byte  $90
;		.byte  $89
;		.byte  $93
;		.byte  $A3
;		.byte  $A4
;		.byte  $A9
;		.byte  $38
;		.byte  $39
;		.byte  $78
;		.byte  $01
;		.byte  $13
;		.byte  $21
;		.byte  $A1
;		.byte  $C1
;		.byte  $19
;		.byte  $18
;		.byte  $99
;		.byte  $98
;		.byte  $63
;		.byte  $73
;		.byte  $B1
;		.byte  $A9
;		.byte  $C5
;		.byte  $0C
;		.byte  $C3
;		.byte  $D3
;		.byte  $41
;		.byte  $C4
;		.byte  $F2
;		.byte  $41
;		.byte  $83
;		.byte  $B0
;		.byte  $81
;		.byte  $43
;		.byte  $6C
;		.byte  $72
;		.byte  $EC
;		.byte  $F2
;		.byte  $A3
;		.byte  $C3
;		.byte  $92
;		.byte  $9A
;		.byte  $18
;		.byte  $19
;		.byte  $62
;		.byte  $42
;		.byte  $34
;		.byte  $B0
;		.byte  $72
;		.byte  $98
;		.byte  $99
;		.byte  $81
;		.byte  $98
;		.byte  $99
;		.byte  $14
;			;  Packed mnemonic table, high bytes
;			;  ---------------------------------
;L8891:
;		.byte  $35
;		.byte  $0A
;		.byte  $0D
;		.byte  $0D
;		.byte  $0D
;		.byte  $0D
;		.byte  $10
;		.byte  $10
;		.byte  $25
;		.byte  $25
;		.byte  $39
;		.byte  $41
;		.byte  $41
;		.byte  $41
;		.byte  $41
;		.byte  $4A
;		.byte  $4A
;		.byte  $4C
;		.byte  $4C
;		.byte  $4C
;		.byte  $50
;		.byte  $50
;		.byte  $52
;		.byte  $53
;		.byte  $53
;		.byte  $53
;		.byte  $10
;		.byte  $25
;		.byte  $41
;		.byte  $41
;		.byte  $41
;		.byte  $41
;		.byte  $08
;		.byte  $08
;		.byte  $08
;		.byte  $09
;		.byte  $09
;		.byte  $0A
;		.byte  $0A
;		.byte  $0A
;		.byte  $0A
;		.byte  $05
;		.byte  $15
;		.byte  $3E
;		.byte  $04
;		.byte  $0D
;		.byte  $30
;		.byte  $4C
;		.byte  $06
;		.byte  $32
;		.byte  $49
;		.byte  $49
;		.byte  $10
;		.byte  $25
;		.byte  $0D
;		.byte  $4E
;		.byte  $0E
;		.byte  $0E
;		.byte  $52
;		.byte  $52
;		.byte  $09
;		.byte  $29
;		.byte  $2A
;		.byte  $30
;		.byte  $30
;		.byte  $4E
;		.byte  $4E
;		.byte  $4E
;		.byte  $3E
;		.byte  $16
;		.byte  $00
;			;  ASSEMBLER OPCODE TABLE
;			;  ======================
;L88D8:
;		CLC
;		CLD
;		CLI
;		CLV
;		DEX
;		DEY
;		INX
;		INY
;		NOP
;		PHA
;		PHP
;		PLA
;		PLP
;		RTI
;		RTS
;		SEC
;		SED
;		SEI
;		TAX
;		TAY
;		TSX
;		TXA
;		TXS
;		TYA
;		DEC A
;		INC A
;		PHY
;		PHX
;		PLY
;		PLX
;		.byte  $90
;		.byte  $B0
;			;  BCC, BCS
;		.byte  $F0
;		.byte  $30
;			;  BEQ, BMI
;		.byte  $D0
;		.byte  $10
;			;  BNE, BPL
;		.byte  $50
;		.byte  $70
;			;  BVC, BVS
;		.byte  $80
;			;  BRA
;L88FF:
;		.byte  $21
;		.byte  $41
;			;  AND, EOR
;		.byte  $01
;		.byte  $61
;			;  ORA, ADC
;		.byte  $C1
;		.byte  $A1
;			;  CMP, LDA
;		.byte  $E1
;			;  SBC
;			;  $8906
;		.byte  $06
;		.byte  $46
;			;  ASL, LSR
;		.byte  $26
;		.byte  $66
;			;  ROL, ROR
;		.byte  $C6
;		.byte  $E6
;			;  DEC, INC
;		.byte  $9C
;		.byte  $9C
;			;  STZ, CLR
;			;  $890E
;		.byte  $E0
;		.byte  $C0
;			;  CPX, CPY
;		.byte  $00
;		.byte  $10
;			;  BRK, BPL
;		.byte  $24
;		.byte  $4C
;			;  BIT, JUMP
;		.byte  $20
;		.byte  $A2
;			;  CALL, LDX
;		.byte  $A0
;		.byte  $81
;			;  LDY, STA
;		.byte  $86
;		.byte  $84
;			;  STX, STY
;L891A:
;		DEC A
;		STA ZP_OPT
;		JUMP incYskipSpacesAtYexecImmed
;L8920:
;		CALL skipSpacesPTRA
;		EOR #']'
;		BEQ L891A					;  End of assembler
;		CALL storeYasTXTPTR
;L892A:		DEC ZP_TXTOFF
;		CALL L89EB
;		DEC ZP_TXTOFF
;		LDA ZP_OPT
;		LSR A
;		BCC L89AE
;		LDA ZP_PRLINCOUNT
;		ADC #$04
;		STA ZP_FPB + 4
;		LDA ZP_GEN_PTR + 1
;		CALL list_printHexByte
;		LDA ZP_GEN_PTR
;		CALL list_printHexByteAndSpace
;		LDX #$FC
;		LDY ZP_NAMELENORVT
;		BPL L894E
;		LDY ZP_STRBUFLEN
;L894E:
;		STY ZP_GEN_PTR + 1
;		BEQ L896B
;		LDY #$00
;L8954:
;		INX
;		BNE L8961
;		CALL PrintCRclearPRLINCOUNT
;		LDX ZP_FPB + 4
;		CALL LBDBF
;		LDX #$FD
;L8961:
;		LDA (ZP_NAMELENORVT + 1),Y
;		CALL list_printHexByteAndSpace
;		INY
;		DEC ZP_GEN_PTR + 1
;		BNE L8954
;L896B:
;		TXA
;		TAY
;L896D:
;		INY
;L896E:
;		BEQ L8977
;		LDX #$03
;		CALL LBDBF
;		BRA L896D
;L8977:
;		LDX #$0A
;		LDA (ZP_TXTPTR)
;		CMP #$2E
;		BNE L898E
;L897F:
;		CALL doListPrintTokenA
;		DEX
;		BNE L8987
;		LDX #$01
;L8987:
;		INY
;		LDA (ZP_TXTPTR),Y
;		CPY ZP_FP_TMP + 11
;		BNE L897F
;L898E:
;		CALL LBDBF
;		DEY
;L8992:
;		INY
;		CMP (ZP_TXTPTR),Y
;		BEQ L8992
;L8997:
;		LDA (ZP_TXTPTR),Y
;		CMP #$3A
;		BEQ L89A7
;		CMP #$0D
;		BEQ L89AB
;L89A1:
;		CALL doListPrintTokenA
;		INY
;		BRA L8997
;L89A7		CPY ZP_TXTOFF
;		BCC L89A1
;L89AB		CALL PrintCRclearPRLINCOUNT
;L89AE		LDY ZP_TXTOFF
;		DEY
;L89B1		INY
;		LDA (ZP_TXTPTR),Y
;		CMP #':'
;		BEQ L89BC
;		CMP #$0D
;		BNE L89B1
;L89BC:		CALL scanNextStmtFromY
;		LDA (ZP_TXTPTR)
;		CMP #$3A
;		BEQ L89D1
;		LDA ZP_TXTPTR + 1
;		CMP #$07
;		BNE L89CE
;		JUMP immedPrompt
;L89CE:		CALL doTraceOrEndAtELSE
;L89D1:		JUMP L8920

;L89D4;		CALL findVarOrAllocEmpty
;		BEQ L8A35
;		BCS L8A35
;		CALL pushVarPtrAndType
;		CALL GetP_percent			;  Get P%
;		STA ZP_VARTYPE
;		CALL storeEvaledExpressioninStackedVarPTr
;		CALL copyTXTOFF2toTXTOFF
;		STY ZP_FP_TMP + 11
;L89EB:		CALL skipSpacesPTRA
;		LDY #$00
;		STZ ZP_FPB + 2
;		CMP #':'
;		BEQ L8A5E			;  End of statement
;		CMP #$0D
;		BEQ L8A5E			;  End of line
;		CMP #'\'
;		BEQ L8A5E			;  Comment
;		CMP #'.'
;		BEQ L89D4			;  Label
;		DEC ZP_TXTOFF
;		LDX #$03			;  Prepare to fetch three characters
;L8A06:		LDY ZP_TXTOFF
;		INC ZP_TXTOFF			;  Get current character, inc. index
;		LDA (ZP_TXTPTR),Y
;		BMI L8A38			;  Token, check for tokenised AND, EOR, OR
;		CMP #$20
;		BEQ L8A22			;  Space, step past
;		LDY #$05
;		ASL A
;		ASL A
;		ASL A
;L8A17:		ASL A
;		ROL ZP_FPB + 2
;		ROL ZP_FPB + 3
;		DEY
;		BNE L8A17
;		DEX
;		BNE L8A06
;L8A22:
;		LDX #$45
;		LDA ZP_FPB + 2
;L8A26:
;		CMP L884D-1,X
;		BNE L8A32
;		LDY L8891,X
;		CPY ZP_FPB + 3
;		BEQ L8A53
;L8A32:
;		DEX
;		BNE L8A26
;L8A35:		JUMP brkSyntax


;L8A38:		LDX #$29			;  opcode number for 'AND'
;		CMP #tknAND
;		BEQ L8A53			;  Tokenised 'AND'
;		INX				;  opcode number for 'EOR'
;		CMP #tknEOR
;		BEQ L8A53
;			;  Tokenised 'EOR'
;		INX
;			;  opcode number for 'ORA'
;		CMP #tknOR
;		BNE L8A35
;			;  Not tokenised 'OR'
;		INC ZP_TXTOFF
;		INY
;		LDA (ZP_TXTPTR),Y
;			;  Get next character
;		AND #$DF
;			;  Ensure upper case
;		CMP #'A'
;		BNE L8A35
;			;  Ensure 'OR' followed by 'A'
;			;  Tokenised opcode found
;			;  ----------------------
;L8A53:
;		LDA L88FF-$29,X
;		STA ZP_DUNNO
;		LDY #$01
;		CPX #$20
;		BCS L8AA6
;L8A5E:
;		LDA $0440
;		STA ZP_GEN_PTR
;		STY ZP_NAMELENORVT
;		LDX ZP_OPT
;		CPX #$04
;		LDX $0441
;		STX ZP_GEN_PTR + 1
;		BCC L8A76
;		LDA $043C
;		LDX $043D
;L8A76:
;		STA ZP_NAMELENORVT + 1
;		STX ZP_FPB
;		TYA
;		BEQ L8AA5
;		BPL L8A83
;		LDY ZP_STRBUFLEN
;		BEQ L8AA5
;L8A83:
;		DEY
;		LDA ZP_DUNNO,Y
;		BIT ZP_NAMELENORVT
;		BPL L8A8E
;		LDA $0600,Y
;L8A8E:
;		STA (ZP_NAMELENORVT + 1),Y
;		INC $0440
;		BNE L8A98
;		INC $0441
;L8A98:
;		BCC L8AA2
;		INC $043C
;		BNE L8AA2
;		INC $043D
;L8AA2:
;		TYA
;		BNE L8A83
;L8AA5:
;		RTS
;L8AA6:
;		CPX #$29
;		BCS L8AE6
;		CALL evalForceINT
;		CLC
;		LDA ZP_INT_WA
;		SBC $0440
;		TAY
;		LDA ZP_INT_WA + 1
;		SBC $0441
;		CPY #$01
;		DEY
;		SBC #$00
;		BEQ L8ADB
;		INC A
;		BNE L8AC6
;		TYA
;		BMI L8ADF
;L8AC6:
;		LDA ZP_OPT
;		AND #$02
;		BEQ L8ADE
;		BRK
;		.byte  $01
;		.byte  "Out of range"
;		BRK
;L8ADB:
;		TYA
;		BMI L8AC6
;L8ADE:
;		TAY
;L8ADF:
;		STY ZP_INT_WA
;L8AE1:
;		LDY #$02
;		JUMP L8A5E
;L8AE6:
;		CPX #$30
;		BCS L8B00
;		CALL SkipSpaceCheckHash
;		BNE L8B07
;		CALL L8CCC
;L8AF2:
;		CALL evalForceINT
;L8AF5:
;		LDA ZP_INT_WA + 1
;L8AF7:
;		BEQ L8AE1
;L8AF9:
;		BRK
;		.byte  $02
;		.byte  "Byte"
;		BRK
;L8B00:
;		CPX #$41
;		BNE L8B67
;		CALL skipSpacesPTRA
;L8B07:
;		CMP #'('
;		BNE L8B44
;		CALL evalForceINT
;		CALL skipSpacesPTRA
;		CMP #')'
;		BNE L8B2C
;		CALL L8CC9
;		CALL SkipSpaceCheckComma
;		BEQ L8B21
;		INC ZP_DUNNO
;		BRA L8AF5
;L8B21:
;		CALL skipSpacesPTRA
;		AND #$DF
;		CMP #$59
;		BEQ L8AF5
;		BRA brkIndex
;L8B2C:
;		CMP #$2C
;		BNE brkIndex
;		CALL SkipSpaceCheckX
;		BNE brkIndex
;		CALL skipSpacesPTRA
;		CMP #')'
;		BEQ L8AF5
;brkIndex:
;		BRK
;		.byte  $03
;		.byte  "Index"
;		BRK
;L8B44:
;		CALL decTXTOFFEvalForceINT
;		CALL SkipSpaceCheckComma
;		BNE L8B5E
;		CALL L8CC9
;		CALL SkipSpaceCheckX
;		BEQ L8B5E
;		CMP #$59
;		BNE brkIndex
;L8B58:
;		CALL L8CCC
;		JUMP L8BFE
;L8B5E:
;		CALL L8CCF
;L8B61:
;		LDA ZP_INT_WA + 1
;		BNE L8B58
;		BRA L8AF7
;L8B67:
;		CPX #$36
;		BCS L8BA1
;		CALL skipSpacesPTRA
;		AND #$DF
;		CMP #'A'
;		BEQ L8B86
;L8B74:
;		CALL decTXTOFFEvalForceINT
;		CALL SkipSpaceCheckComma
;		BNE L8B61
;		CALL L8CC9
;		CALL SkipSpaceCheckX
;		BEQ L8B61
;L8B84:
;		BRA brkIndex
;L8B86:
;		INY
;		LDA (ZP_TXTPTR),Y
;		CALL checkIsValidVariableNameChar
;		BCS L8B74
;		LDY #$16
;		CPX #$34
;		BCC L8B9A
;		BNE L8B98
;		LDY #$36
;L8B98:
;		STY ZP_DUNNO
;L8B9A:
;		CALL L8CCF
;		LDY #$01
;		BRA L8C00
;L8BA1:
;		CPX #$38
;		BCS L8BCA
;		CALL evalForceINT
;		LDY #$03
;		LDX #$01
;		LDA ZP_INT_WA + 1
;		BNE L8BB7
;		LDX #$0F
;		LDA #$64
;		STA ZP_DUNNO
;		DEY
;L8BB7:
;		PHY
;		CALL SkipSpaceCheckComma
;		BNE L8BC7
;		CALL SkipSpaceCheckX
;		BNE L8B84
;		TXA
;		ADC ZP_DUNNO
;		STA ZP_DUNNO
;L8BC7:
;		PLY
;		BRA L8C00
;L8BCA:
;		CPX #$3C
;		BCS L8BEA
;		CPX #$3A
;		BCS L8BD9
;		CALL SkipSpaceCheckHash
;		BEQ L8BE7
;		DEC ZP_TXTOFF
;L8BD9:
;		CALL evalForceINT
;L8BDC:
;		BRA L8B5E
;L8BDE:
;		CALL SkipSpaceCheckHash
;		BNE L8B74
;		LDY #$89
;		STY ZP_DUNNO
;L8BE7:
;		JUMP L8AF2
;L8BEA:
;		BEQ L8BDE
;		CPX #$3E
;		BEQ L8BFB
;		BCS L8C29
;		CALL skipSpacesPTRA
;		CMP #'('
;		BEQ L8C03
;		DEC ZP_TXTOFF
;L8BFB:
;		CALL evalForceINT
;L8BFE:
;		LDY #$03
;L8C00:
;		JUMP L8A5E
;L8C03:
;		CALL L8CC9
;		CALL L8CC9
;		CALL evalForceINT
;		CALL skipSpacesPTRA
;		CMP #')'
;		BEQ L8BFE
;		CMP #$2C
;		BNE L8C26
;		CALL L8CC9
;		CALL SkipSpaceCheckX
;		BNE L8C26
;		CALL skipSpacesPTRA
;		CMP #')'
;		BEQ L8BFE
;L8C26:
;		JUMP brkIndex
;L8C29:
;		CPX #$44
;		BCS L8C7A
;		LDA ZP_FPB + 2
;		EOR #$01
;		AND #$1F
;		PHA
;		CPX #$41
;		BCS L8C59
;		CALL SkipSpaceCheckHash
;		BNE L8C40
;		PLA
;		BRA L8BE7
;L8C40:
;		CALL decTXTOFFEvalForceINT
;		PLA
;		STA ZP_GEN_PTR
;		CALL SkipSpaceCheckComma
;		BNE L8BDC
;		CALL skipSpacesPTRA
;		AND #$1F
;		CMP ZP_GEN_PTR
;		BNE L8C26
;		CALL L8CC9
;		BRA L8BDC
;L8C59:
;		CALL evalForceINT
;		PLA
;		STA ZP_GEN_PTR
;		CALL SkipSpaceCheckComma
;		BNE L8C77
;		CALL skipSpacesPTRA
;		AND #$1F
;		CMP ZP_GEN_PTR
;		BNE L8C26
;		CALL L8CC9
;		LDA ZP_INT_WA + 1
;		BEQ L8C77
;		JUMP L8AF9
;L8C77:
;		JUMP L8B61
;L8C7A:
;		BNE L8C87
;		CALL evalForceINT
;		LDA ZP_INT_WA
;		STA ZP_OPT
;		LDY #$00
;		BRA L8CB1
;L8C87:
;		LDX #$01
;		LDY ZP_TXTOFF
;		INC ZP_TXTOFF
;		LDA (ZP_TXTPTR),Y
;		AND #$DF
;		CMP #$42
;		BEQ L8CA7
;		INX
;		CMP #$57
;		BEQ L8CA7
;		LDX #$04
;		CMP #$44
;		BEQ L8CA7
;		CMP #$53
;		BEQ L8CB7
;		JUMP brkSyntax
;L8CA7:
;		PHX
;		CALL evalForceINT
;		LDX #ZP_DUNNO
;		CALL CopyIntA2ZPX
;		PLY
;L8CB1:
;		JUMP L8A5E
;L8CB4:
;		JUMP brkTypeMismatch
;L8CB7:
;		LDA ZP_OPT
;		PHA
;		CALL evalExpressionMAIN
;		BNE L8CB4
;		PLA
;		STA ZP_OPT
;		CALL copyTXTOFF2toTXTOFF
;		LDY #$FF
;		BRA L8CB1
;L8CC9:
;		CALL L8CCC
;L8CCC:
;		CALL L8CCF
;L8CCF:
;		LDA ZP_DUNNO
;		CLC
;		ADC #$04
;		STA ZP_DUNNO
;		RTS
SkipSpaceCheckXAtY
		CALL	skipSpacesY
		ANDA	#$DF
		CMPA	#'X'
		RTS
SkipSpaceCheckHashAtY
		CALL	skipSpacesY
		CMPA	#'#'
		RTS		
SkipSpaceCheckCommaAtY
		CALL	skipSpacesY
		CMPA	#','
		RTS

		; [ZP_GEN_PTR] <= A
		; ZP_NAMELENORVT <= Y (last character CONSUMED i.e. before what is to be kept)
		; Copy rest of line to ZP_GEN_PTR
		; return with count of chars after token including $0d in B
		; trashes A, X, Y
storeTokenAndCloseUpLine
		LDX	ZP_GEN_PTR
		STA	,X+
		LEAY	1,Y
		CLRB
1		INCB
		LDA	,Y+
		STA	,X+		
		CMPA	#$0D
		BNE	1B
		RTS

;		CLC
;		TYA
;		ADC ZP_GEN_PTR
;		STA ZP_NAMELENORVT
;		LDY #$00
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
		LDY	ZP_GEN_PTR
		LEAY	1,Y
tokLinLp	LDA	,Y+
		CALL	checkIsNumeric
		BCC	tokLineNoSk1
		ANDA	#$F
		PSHS	A
		CLR	,-S			; store on stack as 16 bit no
*		LDD	ZP_FPB + 2		; get cur num
*		ROL	D			; * by 2
*		BMI	tokLinOv		; overflow if top bit set
*		STD	ZP_FPB + 2
*		ROL	D
*		BMI	tokLinOv		; overflow if top bit set

*		ADDD	ZP_FPB + 2
*		BMI	tokLinOv		; overflow if top bit set

		LDA	ZP_FPB + 3		; low byte * 10
		BEQ	1F
		LDB	#10
		MUL				; this cannot overflow or go minus so don't panic!
		ADDD	,S			; add to current digit
		BMI	tokLinOv		; overflowed
		STD	,S			; store 

		
1		LDA	ZP_FPB + 2		; mul old number hi byte by 10
		BEQ	1F
		LDB	#10
		MUL
		BCS	tokLinOv		; top bit of B
		TSTA				; or top byte of result
		EXG	A,B			; now D = 256 * B 
		BEQ	2F
		BRA	tokLinOv		; causes overflow
1		CLRB				
2		ADDD	,S++
		STD	ZP_FPB + 2		; store result
		BPL	tokLinLp
tokLinOv
		ORCC	#CC_C
		RTS
tokLineNoSk1					; found end of number
		LEAY	-2,Y			; point at char after last read digit
		LDA	#tknLineNo
		CALL	storeTokenAndCloseUpLine	; B + ZP_GEN_PTR is end of line
		LDY	ZP_GEN_PTR
		LEAX	3,Y				; make space for line number and length (3)
		STX	ZP_GEN_PTR
		INCB
		CLRA
		LEAX	D,X
		LEAY	D,Y			; point at end of strings + 1
;L8D59:
1
		LDA	,-Y			; move end of line on 3 bytes and leave gap for rest of tokenized number
		STA	,-X
		DECB
		BNE	1B
;L8D62: - when moving stuff to point here beware line number must be in ZP_FPB + 2,3 in bigendian, Y must point at byte before first of the three bytes
int16atZP_FPB2toBUFasTOKENIZED
		LDA	ZP_FPB + 2		; see p.40 of ROM UG (note diagram is wrong see text)
		ORA	#$40
		STA	3, Y			; byte 3 = "01" & MSB[5 downto 0] 
		LDA	ZP_FPB + 3		; lsb
		ANDA	#$3F
		ORA	#$40
		STA	2,Y			; byte 2 = "01" & MSB[5 downto 0] 

		LDA	ZP_FPB + 3
		ANDA	#$C0		
		STA	ZP_FPB + 3		; mask off all but top two bits of LSB

		LDA	ZP_FPB + 2
		ANDA	#$C0
		LSRA
		LSRA
		ORA	ZP_FPB + 3
		LSRA
		LSRA
		EORA	#$54
		STA	1,Y			; byte 1 = "01" & MSB[7 downto 6] & LSB[7 downto 6] & "00"
		ANDCC	#~CC_C
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
		ANDCC	#~CC_C
rtsL8D9A	RTS
setcarryRTS	ORCC	#CC_C
		RTS

checkIsDotOrNumeric
		CMPA	#'.'
		BNE	checkIsNumeric
		ORCC	#CC_C
		RTS

ZPPTR_GetCharIncPtr
		LDA	[ZP_GEN_PTR]
ZPPTR_Inc16						; incremenet ptr and save
		LDX	ZP_GEN_PTR
		LEAX	1,X
		STX	ZP_GEN_PTR
1		RTS			

ZPPTR_IncThenGetNextChar
		CALL	ZPPTR_Inc16
		LDA	[ZP_GEN_PTR]
		RTS


;			;  Tokenise line at $37/8

toklp0		CALL	ZPPTR_Inc16				;  Step past charac	ter

tokenizeATZP_GEN_PTR
toklp2
		LDA	[ZP_GEN_PTR]			;  Get current character
		CMPA	#$0D
		BEQ	rtsL8DDF				;  Exit with <cr>
		CMPA	#' '
		BEQ	toklp0				;  Skip <spc>
		CMPA	#'&'
		BNE	tokNotAmper			;  Jump if not '&'
toklp1		CALL	ZPPTR_IncThenGetNextChar	;  Get next character, check if it looks like HEX
		CALL	checkIsNumeric			;  Is it a digit?
		BCS	toklp1				;  Loop back if a digit
		CMPA	#'A'
		BCC	toklp2				;  Loop back if <'A'
		CMPA	#'F' + 1
		BCC	toklp1				;  Step to next if 'A'..'F'
tokNotAmper	CMPA	#'"'
		BNE	tokNotQuot			;  Not quote,
tokQuotLp	CALL	ZPPTR_IncThenGetNextChar	;  Get next character
		CMPA	#'"'
		BEQ	toklp0				;  Jump back if closing quote
		CMPA	#$0D
		BNE	tokQuotLp			;  Loop until <cr> or quote
rtsL8DDF	RTS

tokNotQuot	CMPA	#':'
		BNE	tokNotColon
		CALL	ZPPTR_Inc16
L8DE7		CLR	ZP_FPB			; start of statement - don't expect line num
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

tokDot		LDA	[ZP_GEN_PTR]
		CALL	checkIsDotOrNumeric
		BCC	tokNextSetFlag0_FF
		CALL	ZPPTR_Inc16
		BRA	tokDot
tokNextSetFlag0_FF
;L8E1F
1		LDA	#$FF
		STA	ZP_FPB
		BRA	L8DE9

tokNotKey2					 ; is it a variable? if so skip over it...
		CALL	checkIsValidVariableNameChar
		BCC	tokNotKeyword
;L8E2A
tokNotKey_SkipVarName
		LDA	[ZP_GEN_PTR]
		CALL	checkIsValidVariableNameChar
		BCC	tokNextSetFlag0_FF
		CALL	ZPPTR_Inc16
		BRA	tokNotKey_SkipVarName
tokNotNum
		CMPA	#'A'
		BLO	tokNotKeyword		; if <'A'
		CMPA	#'W'			
		BHI	tokNotKey2		; of >='X'
		LEAX	tblTOKENS, PCR
tokKeyCmp
		LDY	ZP_GEN_PTR			; reset buffer pointer
;L8E46:
		LDA	,Y+				; start again with first char in A
		CMPA	,X+				
		BLO	tokNotKey_SkipVarName		; < tok char lt treat as variable name TODO: we already skipped a lot of the variable but that get wasted here
		BNE	tokSkipEndTryNext
;L8E4E:
tokKeyCmpLp
		LDA	,X+
		BMI	tokKeyFound
		CMPA	,Y+
		BEQ	tokKeyCmpLp
		LDA	-1,Y
		CMPA	#'.'
		BEQ	tokKeyAbbrev

tokSkipEndTryNext					;L8E5D:
		LDA	,X+
		BPL	tokSkipEndTryNext
		CMPA	#tknWIDTH
		BNE	tokMoveNextTkn			; not the last one, increment pointer and carry on
		BRA	tokNotKey_SkipVarName		; TODO = is this always true - I think it is

tokKeyAbbrev						;L8E68:
tokKeyAbbrevLp1						;L8E69:
		LDA	,X+				; skip to end of keyword, increasing X
		BMI	tokKeyFound
		BRA	tokKeyAbbrevLp1
tokMoveNextTkn						;L8E75:
		LEAX	1, X				; move X past token and flags
							;L8E80: (not used was a skip for add hi byte)
		BRA	tokKeyCmp
tokKeyFound						;L8E84:
		TFR	A,B				; store token in B (TODO - use A and save a couple of swaps)
		LDA	,X				; get flags in A
		STA	ZP_FPB + 2			; store flags
		BITA	#TOK_FLAG_CONDITIONAL					
		BEQ	tokKeyFound2			; if flags[0]='0' we've got a full keyword
		LDA	,Y				; if not check if next is a valid variable char
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
		LEAY	-1, Y
		TFR	B, A
		CALL	storeTokenAndCloseUpLine ; attention check regs trashed
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
		LDY	ZP_GEN_PTR		
		LEAY	1,Y
tokSkipPROCNAMElp					;L8EBD:					
		LDA	,Y+
		CALL	checkIsValidVariableNameChar
		BCS	tokSkipPROCNAMElp
							;L8EC9:
		LEAY	-2,Y
		STY	ZP_GEN_PTR			; now pointing at last char of name
		
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
		LDY	ZP_TXTPTR2
skipSpacesY		   
		LDA	,Y+
		CMPA	#' '
		BEQ	skipSpacesY
anRTS7		RTS

;		
;		;  Skip spaces at PTRA
;		;  ===================
		;  leaves PTR unchanged returns next non white pointer + 1 in Y, char in A
skipSpacesPTRA
		LDY	ZP_TXTPTR
ssAlp2		LDA	,Y+
		CMPA	#' '
		BEQ	ssAlp2
anRTS4		RTS

;
;			;  Check for comma
;			;  ===============
checkForComma
		CALL	skipSpacesY		;  Skip spaces
		CMPA	#','
		RTS				;  Check for comma
;		
;			;  Expect comma
;			;  ============
checkForCommaOrBRK
		CALL	checkForComma
		BEQ	anRTS4			;  Comma found, return
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
*		LBSR	retD16asINT_LE
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

1		LDY #BAS_InBuf
		STY ZP_TXTPTR
2		LDA [ZP_LOMEM]
		BEQ resetVarsImmedPrompt
		STA ,Y+
		BEQ cmdNEW2
		INC ZP_LOMEM + 1
		BNE 1F
		INC ZP_LOMEM
1		CMPA #$0D
		BNE 2B
		LDA ZP_LOMEM
		CMPA ZP_HIMEM
		BCS resetVarsImmedPrompt
		CALL tokenizeAndStore
		BRA 1B
cmdNEW									;  NEW
		CALL	scanNextStmtFromY
cmdNEW2
		CALL	deleteProgSetTOP
resetVarsImmedPrompt
		CALL	ResetVars


immedPrompt	LDY	#BAS_InBuf
		STY	ZP_TXTPTR			;  PtrA = BAS_InBuf - input buffer
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
		LEAX	,Y
		PSHS	Y
		JSR	OSCLI
		PULS	Y
;			;  DATA, DEF,	;
;			;  ==============
cmdREM
		LDA	#$0D
1							; L8FB3:
		CMPA	,Y+
		BNE	1B				;  Loop until found <cr>
							;L8FB8:
		LEAY	-1,Y
		STY	ZP_TXTPTR
		BRA	stepNextLineOrImmedPrompt	;  Update line pointer, step to next line
skipToNextLineOrImmedPrompt				; L8FBD
		CMPA	#$0D
		BNE	cmdREM				;  Step to end of line
stepNextLineOrImmedPrompt
		LDA	ZP_TXTPTR
		CMPA	#BAS_InBuf / 256
		BEQ	immedPrompt
		LDA	1,Y				; if next line number top but end of prog
		BMI	immedPrompt
		LDA	ZP_TRACE
		BEQ	skNoTRACE
		LDD	1,Y
		STD	ZP_INT_WA + 2
		CALL	doTRACE
skNoTRACE						;L8FDB:
		LEAY	4,Y				; skip over $d,line num,len to first token
		STY	ZP_TXTPTR
		BRA	skipSpacesAtYexecImmed
enterAssembler						;L8FE1:
		TODODEADEND "Enter Assembler"
;		LDA #$03
;		STA ZP_OPT
;		JUMP L8920
L8FEB
		LDA   -1,Y
		CMPA  #'*'
		BEQ   doOSCLIAtY
		CMPA  #'['
		BEQ   enterAssembler
		CMPA  #tknEXT
		LBEQ  cmdEXTEq
		CMPA  #'='
		BEQ  cmdEquals
decYGoScanNextContinue				; L9000
		LEAY  -1,Y
scanNextContinue				; L9002
		CALL	scanNextStmtFromY	;  Return to execution loop
continue					; L9005
		LDA    ,Y
		CMPA	#':'
		BNE    skipToNextLineOrImmedPrompt
incYskipSpacesAtYexecImmed			; L900B		
		LEAY	1,Y
skipSpacesAtYexecImmed				; L900D
		STY	ZP_TXTPTR
		LDA	,Y+
		CMPA	#' '		
		BEQ	skipSpacesAtYexecImmed	;  Skip spaces
		CMPA	#':'		
		BEQ	skipSpacesAtYexecImmed	;  Skip spaces
		CMPA	#tknPTRc
		BLO	execTryVarAssign	;  Not command token, try variable assignment
;		
;			;  Dispatch function/command
;			;  -------------------------
exeTokenInA						;L9019:		TODO: move command table and make relative jump
		SUBA	#tknOPENIN			; first token
		TFR	A,B
		ASLB					; mul by two
		LEAX	tblCmdDispatch, PCR
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
		LDX	ZP_TXTPTR
		STX	ZP_TXTPTR2
		CALL	findVarAtYMinus1
		BNE	assignVarAtZP_INT_WA		;  Look up variable, jump if exists to assign new value
		BCS	L8FEB				;  Invalid variable name, try =, [, *, EXT commands

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
		LDY	ZP_TXTPTR2
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
		JUMP	scanNextExpectColonElseCR_2			;  Evaluate expression, pop program pointer and continue execution


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
		PSHS	Y
		LDA	ZP_INT_WA + 0
		CMPA	#$80
		BEQ	indStringStore			;  Type = $80, $<addr>=<string>, jump to store directly
		LDY	ZP_INT_WA + 2
		LDA	2,Y				;  Get maximum string size
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
		LDX	,Y			; get current string pointer
		LDB	2,Y			; get current string space
		ABX
		CMPX	ZP_VARTOP
		BNE	L90EA			; if this isn't at the top of the heap then we need to make a new buffer
		
		;  The string's current string block is the last thing in the heap, so it can just be extended
		;  -------------------------------------------------------------------------------------------
		CLR	ZP_INT_WA + 2		; Set ZP_INT_WA + 3 to zero to not change string address later
		SUBA	2,Y			; X=newstrlen - currstrlen = extra memory needed
L90EA		TFR	A,B			; B & A contain the ammount that VARTOP needs to be shifted by
		LDX	ZP_VARTOP
		ABX
		PSHS	U
		CMPX	,S++
		BHS	brkNoRoom		;  Compare to STACKBOT, no room if new VARTOP>=STACKBOT
		STX	ZP_VARTOP		;  Store new VARTOP
		LDB	,S+
		STB	2,Y			;  Get string length back and store it
		TST	ZP_INT_WA + 2
		BEQ	L910E			;  Get string address, jump if not moved
		LDX	ZP_INT_WA + 2
		STX	,Y
L910E		LDB	ZP_STRBUFLEN		;  Get string length
		STB	3,Y
		BEQ	L912B			;  Store string length, exit if zero length
		LDX	0,Y
		STX	ZP_INT_WA + 2		; store new pointer
		LDY	#$600
1		LDA	,Y+
		STA	,X+
		DECB
		BNE	1B
L912B		PULS	Y,PC
;
;			;  Store fixed string at $<addr>
;			;  -----------------------------
indStringStore	CALL	str600CRterm			;  Store <cr> at end of string buffer
		LDY	ZP_INT_WA + 2
1		LDA	,X+
		STA	,Y+
		DECB
		BPL	1B				; include terminating CR
		PULS	Y,PC


cmdPRINT_HASH						; L9141
		TODODEADEND "PRINT#"
;		CALL LBA3C
;L9144:		PHY
;		CALL checkForComma
;		BNE L9187
;		CALL evalAtY
;		CALL fpCopyFPA_FPTEMP1
;		PLY
;		LDA ZP_VARTYPE
;		JSR OSBPUT
;		TAX
;		BEQ L9174
;		BMI L9167
;		LDX #$03
;L915D:
;		LDA ZP_INT_WA,X
;		JSR OSBPUT
;		DEX
;		BPL L915D
;		BRA L9144
;L9167:
;		LDX #$04
;L9169:
;		LDA $046C,X
;		JSR OSBPUT
;		DEX
;		BPL L9169
;		BRA L9144
;L9174:
;		LDA ZP_STRBUFLEN
;		JSR OSBPUT
;		TAX
;		BEQ L9144
;L917C:
;		LDA $05FF,X
;		JSR OSBPUT
;		DEX
;		BNE L917C
;		BRA L9144
;L9187:
;		PLA
;		STY ZP_TXTOFF
;		JUMP scanNextContinue


;			;  PRINT (<print items>)
;			;  =====================
cmdPRINT
		CALL	SkipSpaceCheckHashAtY
		BEQ	cmdPRINT_HASH			; Get next non-space char, if '#' jump to do PRINT#
		LEAY	-1,Y
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
		CALL	cmdPRINT_checkCRTABSPC
		BCC	cmdPRINT_lp1			; Check for ' TAB SPC, if print token found return to outer main loop

;			;  All print formatting have been checked, so it now must be an expression
;			;  -----------------------------------------------------------------------
		LDD	ZP_PRINTBYTES			; TODO: assumes order ZP_PRINTBYTES precedes ZP_PRINTFLAG
;; removed;		LDB	ZP_PRINTFLAG
		PSHS	D
;			;  Save field width and flags, as evaluator
;			;   may call PRINT (eg FN, STR$, etc.)
		LEAY	-1,Y
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
		CALL	evalL1OpenBracketConvert2INT	;  Evaluate next integer, check for closing bracket
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
		CALL	checkForComma			; Get next non-space character, compare with ','
		BEQ	cmdPRINT_TAB_comma				; Comma, jump to TAB(x,y)
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
		ANDCC	#~CC_C
;		;;;; REMOVED	BRA copyTXTOFF2toTXTOFF			;  Update PTR A offset = PTR B offset and return
		RTS
;		
;	

;decTXTOFFEvalForceINT:
;		DEC ZP_TXTOFF
evalForceINT
		CALL	evalExpressionMAIN
		CALL	checkTypeInAConvert2INT
copyTXTOFF2toTXTOFF
		STY	ZP_TXTPTR
		STY	ZP_TXTPTR2
		RTS

;			;  Check special print formatting ' TAB( SPC
;			;  -----------------------------------------
cmdPRINT_checkCRTABSPC				; L927A
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
		ORCC	#CC_C			;  Flag 'not formatting token'
rtsL9293
		RTS
brkMissingQuote						; L9294
		DO_BRK_B
		FCB	$09, tknMissing, $22,
;L9299:
;		CALL skipSpacesPTRA
;		CALL cmdPRINT_checkCRTABSPC			-- CHECK what's what with TXTPTRs here!
;		BCC rtsL9293
;		CMP #$22
;		BNE rtsSEC_L9292
;L92A5:
;		INY
;		LDA (ZP_TXTPTR2),Y
;		CMP #$0D
;		BEQ brkMissingQuote
;		CMP #$22
;		BNE L92B9
;		INY
;		STY ZP_TXTOFF2
;		LDA (ZP_TXTPTR2),Y
;		CMP #$22
;		BNE rtsCLC_L926A
;L92B9:
;		CALL list_printANoEDIT
;		BRA L92A5
cmdCALL			; L92BE!

			TODO_CMD "cmdCALL"
			
;			;  CALL
;		CALL evalExpressionMAIN
;		CALL checkTypeInZP_VARTYPEConvert2INT
;		CALL stackINT_WAasINT
;		STZ $0600
;		LDY #$00
;L92CC:
;		PHY
;		CALL checkForComma
;		BNE L92F1
;		LDY ZP_TXTOFF2
;		CALL findVarAtYSkipSpaces
;		BEQ L9301
;		PLY
;		INY
;		LDA ZP_INT_WA
;		STA $0600,Y
;		INY
;		LDA ZP_INT_WA + 1
;		STA $0600,Y
;		INY
;		LDA ZP_INT_WA + 2
;		STA $0600,Y
;		INC $0600
;		BRA L92CC
;L92F1:
;		PLY
;		DEC ZP_TXTOFF2
;		CALL LDYZP_TXTPTR2scanNextStmtFromY
;		CALL popIntA
;		CALL L9304
;		CLD
;		JUMP continue
;L9301:
;		JUMP brkNoSuchVar
;L9304:
;		LDA $040C
;		LSR A
;		LDA $0404
;		LDX $0460
;		LDY $0464
;		JUMP (ZP_INT_WA)
;L9314:
;		JUMP brkSyntax
cmdDELETE

			TODO_CMD "cmdDELETE"
			
;			;  DELETE
;		CALL skipSpacesDecodeLineNumber
;		BCC L9314
;		CALL stackINT_WAasINT
;		CALL SkipSpaceCheckComma
;		BNE L9314
;		CALL skipSpacesDecodeLineNumber
;		BCC L9314
;		CALL scanNextStmt
;		LDA ZP_INT_WA
;		STA ZP_NAMELENORVT
;		LDA ZP_INT_WA + 1
;		STA ZP_NAMELENORVT + 1
;		CALL popIntA
;L9337:
;		CALL findLineAndDelete  
;		CALL checkForESC
;		CALL inc_INT_WA
;		LDA ZP_NAMELENORVT
;		CMP ZP_INT_WA
;		LDA ZP_NAMELENORVT + 1
;		SBC ZP_INT_WA + 1
;		BCS L9337
;		JUMP resetVarsImmedPrompt
;L934D:
		LDB #$0A
		CALL retB8asINT
;		CALL skipSpacesDecodeLineNumber
;		CALL stackINT_WAasINT
		LDB #$0A
		CALL retB8asINT
;		CALL SkipSpaceCheckComma
;		BNE L9370
;		CALL skipSpacesDecodeLineNumber
;		LDA ZP_INT_WA + 1
;		BNE brkSilly
;		LDA ZP_INT_WA
;		BEQ brkSilly
;		JUMP scanNextStmt
;L9370:
;		JUMP scanNextExpectColonElseCR
;L9373:
;		LDA ZP_TOP
;		STA ZP_FPB
;		LDA ZP_TOP + 1
;		STA ZP_FPB + 1
;L937B:
;		LDA ZP_PAGE_H
;		STA ZP_GEN_PTR + 1
;		LDY #$01
;		STY ZP_GEN_PTR
;		RTS
cmdRENUMBER		; L9384!

			TODO_CMD "cmdRENUMBER"
			
;			;  RENUMBER
;		CALL L934D
;		LDX #ZP_NAMELENORVT
;		CALL popIntAtX
;		CALL findTOP
;		CALL L9373
;L9392:
;		LDA (ZP_GEN_PTR)
;		BMI L93C4
;		STA (ZP_FPB)
;		LDA (ZP_GEN_PTR),Y
;		STA (ZP_FPB),Y
;		SEC
;		TYA
;		ADC ZP_FPB
;		STA ZP_FPB
;		BCC L93A6
;		INC ZP_FPB + 1
;L93A6:
;		CMP ZP_HIMEM
;		LDA ZP_FPB + 1
;		SBC ZP_HIMEM + 1
;		BCS brkRENUMBERspace
;		CALL L947A
;		BRA L9392
;brkRENUMBERspace:
;		BRK
;		.byte  $00
;		.byte  tknRENUMBER, " space"
;brkSilly:
;		BRK
;		.byte  $00
;		.byte  "Silly"
;		BRK
;
;L93C4:		CALL L937B
;L93C7:		LDA (ZP_GEN_PTR)
;		BMI L93E7
;		LDA ZP_NAMELENORVT + 1
;		STA (ZP_GEN_PTR)
;		LDA ZP_NAMELENORVT
;		STA (ZP_GEN_PTR),Y
;		CLC
;		LDA ZP_NAMELENORVT
;		ADC ZP_INT_WA
;		STA ZP_NAMELENORVT
;		LDA #$00
;		ADC ZP_NAMELENORVT + 1
;		AND #$7F
;		STA ZP_NAMELENORVT + 1
;		CALL L947A
;		BRA L93C7
;L93E7:
;		LDA ZP_PAGE_H
;		STA ZP_TXTPTR + 1
;		STZ ZP_TXTPTR
;L93ED:
;		LDY #$01
;		LDA (ZP_TXTPTR),Y
;		BMI L945A
;		LDY #$04
;		STZ ZP_INT_WA + 2
;L93F7:
;		LDA (ZP_TXTPTR),Y
;		LDX ZP_INT_WA + 2
;		BNE L9405
;		CMP #$8D
;		BEQ L941B
;		CMP #$F4
;		BEQ L9412
;L9405:
;		INY
;		CMP #$22
;		BNE L940E
;		EOR ZP_INT_WA + 2
;		STA ZP_INT_WA + 2
;L940E:
;		CMP #$0D
;		BNE L93F7
;L9412:
;		LDY #$03
;		LDA (ZP_TXTPTR),Y
;		CALL L9BF4
;		BRA L93ED
;L941B:
;		CALL decodeLineNumber
;		CALL L9373
;L9421:
;		LDA (ZP_GEN_PTR)
;		BMI L945C
;		LDA (ZP_FPB)
;		CMP ZP_INT_WA + 1
;		BNE L944A
;		LDA (ZP_FPB),Y
;		CMP ZP_INT_WA
;		BNE L944A
;		LDA (ZP_GEN_PTR),Y
;		STA ZP_FPB + 2
;		LDA (ZP_GEN_PTR)
;		TAX
;		LDY ZP_TXTOFF
;		DEY
;		LDA ZP_TXTPTR
;		STA ZP_NAMELENORVT
;		LDA ZP_TXTPTR + 1
;		STA ZP_NAMELENORVT + 1
;		CALL L8D62
;L9446:
;		LDY ZP_TXTOFF
;		BRA L93F7
;L944A:
;		CLC
;		CALL L947A
;		LDA ZP_FPB
;		ADC #$02
;		STA ZP_FPB
;		BCC L9421
;		INC ZP_FPB + 1
;		BRA L9421
;L945A:
;		BRA L94B6
;L945C:
;		PRINT_STR "Failed at "
;		LDA (ZP_TXTPTR),Y
;		STA ZP_INT_WA + 1
;		INY
;		LDA (ZP_TXTPTR),Y
;		STA ZP_INT_WA
;		CALL int16print_AnyLen -- API CHANGE -- API CHANGE
;		CALL PrintCRclearPRLINCOUNT
;		BRA L9446
;L947A:
;		INY
;		LDA (ZP_GEN_PTR),Y
;		LDY #$01
;		ADC ZP_GEN_PTR
;		STA ZP_GEN_PTR
;		BCC L9488
;		INC ZP_GEN_PTR + 1
;		CLC
;L9488:
;		RTS
;			;  AUTO [num[,num]]
;			;  ================
cmdAUTO

			TODO_CMD "cmdAUTO"
			
;		CALL L934D
;		LDA ZP_INT_WA
;		PHA
;		CALL popIntA
;L9492:
;		CALL stackINT_WAasINT
;		CALL int16print_fmt5 -- API CHANGE
;		CALL ReadKeysTo_InBuf
;		CALL popIntA
;		CALL L8DE7
;		LDY #$00
;		CALL tokenizeAndStoreAlreadyLineNoDecoded 
;		CALL ResetVars
;		PLA
;		PHA
;		CLC
;		ADC ZP_INT_WA
;		STA ZP_INT_WA
;		BCC L9492
;		INC ZP_INT_WA + 1
;		BPL L9492
;L94B6:
;		JUMP resetVarsImmedPrompt
;L94B9:
;		JUMP L9605
;			;  DIM name - Reserve memory
;			;  -------------------------
;L94BC:
;		DEC ZP_TXTOFF
;		CALL findVarOrAllocEmpty
;			;  Step back, find/create variable
;		BEQ L952C
;		BCS L952C
;			;  Error if string variable or bad variable name
;		CALL pushVarPtrAndType
;			;  Push IntA - address of info block
;		CALL evalAtYcheckTypeInAConvert2INT
;		CALL inc_INT_WA
;			;  Evaluate integer, IntA=IntA+1 to count zeroth byte
;		LDA ZP_INT_WA + 3
;		ORA ZP_INT_WA + 2
;		BNE L952C
;			;  Size>$FFFF or <0, error
;		CLC
;		LDA ZP_INT_WA
;		ADC ZP_VARTOP
;		TAY
;			;  XY=VARTOP+size
;		LDA ZP_INT_WA + 1
;		ADC ZP_VARTOP + 1
;		TAX
;		CPY ZP_BAS_SP
;		SBC ZP_BAS_SP + 1
;		BCS L94B9
;			;  If VARTOP+size>STACKBOT, No Room
;		LDA ZP_VARTOP
;		STA ZP_INT_WA
;			;  Current VARTOP is reserved memory
;		LDA ZP_VARTOP + 1
;		STA ZP_INT_WA + 1
;		STY ZP_VARTOP
;		STX ZP_VARTOP + 1
;			;  Update VARTOP
;		LDA #$40
;		STA ZP_VARTYPE
;			;  Type=Integer
;		CALL storeEvaledExpressioninStackedVarPTr
;		CALL copyTXTOFF2toTXTOFF
;			;  Set the variable, update PTRA
;L94FB:
;		CALL SkipSpaceCheckComma
;		BEQ cmdDIM
;			;  Next character is comma, do another DIM
;		JUMP decYGoScanNextContinue
;			;  Return to execution loop
;L9503:
;		LDX #ZP_FPB + 4
;		CALL popIntAtX
;L9508:
;		LDX #$00
;		LDY #$00
;L950C:
;		LSR ZP_FPB + 5
;		ROR ZP_FPB + 4
;		BCC L951D
;		CLC
;		TYA
;		ADC ZP_INT_WA
;		TAY
;		TXA
;		ADC ZP_INT_WA + 1
;		TAX
;		BCS L952C
;L951D:
;		ASL ZP_INT_WA
;		ROL ZP_INT_WA + 1
;; DOM NOT SURE WHAT TO DO WITH THESE!?!
;;zPERCENT:			;; from JGH BASIC stitch togetherer
;;		BCS L952C
;			;  Added to HiBasic4
;		LDA ZP_FPB + 4
;		ORA ZP_FPB + 5
;		BNE L950C
;		STY ZP_INT_WA
;		STX ZP_INT_WA + 1
;		RTS
;L952C:
;		BRK
;		.byte  $0A
;		.byte  "Bad ", tknDIM
;		BRK
;			;  DIM
;			;  ===
cmdDIM

			TODO_CMD "cmdDIM"
			
;		CALL skipSpacesPTRA
;		TYA
;		CLC
;		ADC ZP_TXTPTR
;			;  Skip spaces
;		LDX ZP_TXTPTR + 1
;		BCC L9541
;		INX
;		CLC
;L9541:
;		SBC #$00
;		STA ZP_GEN_PTR
;		TXA
;		SBC #$00
;		STA ZP_GEN_PTR + 1
;			;  $37/8=>variable name
;		LDX #$05
;		STX ZP_FPB + 4
;			;  Real, 5 bytes needed
;		LDX ZP_TXTOFF
;		CALL fnProcScanZP_GEN_PTRplus1varname
;			;  Check variable name
;		CPY #$01
;		BEQ L952C
;			;  Bad name, jump to error
;		CMP #'('
;		BEQ L9570
;			;  Real array
;		CMP #'$'
;		BEQ L9563
;			;  String array
;		CMP #'%'
;		BNE L956D
;			;  Not (, $, %, reserve memory
;L9563:
;		DEC ZP_FPB + 4
;			;  String or Integer, 4 bytes needed
;		INY
;		INX
;		LDA (ZP_GEN_PTR),Y
;			;  Get ext character
;		CMP #'('
;		BEQ L9570
;			;  '(', jump to dimension array
;L956D:
;		JUMP L94BC
;			;  No '(', jump to reserve memory
;			;  Dimension an array
;			;  ------------------
;L9570:
;		INY
;		STX ZP_TXTOFF
;		CALL findVar			;  Get variable address
;L9576:
;		BNE L952C
;		CALL allocVAR			;  Create new variable
;		LDX #$01
;		CALL AllocVarSpaceOnHeap			;  Allocate space
;		LDA ZP_FPB + 4
		PSHU	B
		LDB	#$01
		PSHU	B
		CALL	retB8asINT		;  IntA=1
;L9589:		CALL stackINT_WAasINT			;  Push IntA
;		CALL evalForceINT		;  Evaluate integer
;		LDA ZP_INT_WA + 1
;		AND #$C0
;		ORA ZP_INT_WA + 2
;		ORA ZP_INT_WA + 3
;		BNE L952C
;			;  Bad DIM
;		CALL inc_INT_WA
;			;  IntA=IntA+1
;		PLY
;		LDA ZP_INT_WA
;		STA (ZP_VARTOP),Y
;		INY
;		LDA ZP_INT_WA + 1
;		STA (ZP_VARTOP),Y
;		INY
;		PHY
;		CALL L9503
;			;  Multiply
;		CALL SkipSpaceCheckComma
;		BEQ L9589
;			;  Comma, another dimension
;		CMP #')'
;		BNE L9576
;			;  Not ')', error
;			;  Closing ')' found
;			;  -----------------
;		PLX
;		PLA
;		PHX
;		STA ZP_FPB + 4
;		STZ ZP_FPB + 5
;		CALL L9508
;			;  Multiply
;		PLA
;		PHA
;		ADC ZP_INT_WA
;		STA ZP_INT_WA
;		BCC L95C8
;		INC ZP_INT_WA + 1
;L95C8:
;		LDA ZP_VARTOP + 1
;		STA ZP_GEN_PTR + 1
;		LDA ZP_VARTOP
;		STA ZP_GEN_PTR
;		CLC
;		ADC ZP_INT_WA
;		TAY
;		LDA ZP_INT_WA + 1
;		ADC ZP_VARTOP + 1
;		BCS L9605
;			;  DIM space
;		TAX
;		CPY ZP_BAS_SP
;		SBC ZP_BAS_SP + 1
;		BCS L9605
;			;  DIM space
;		STY ZP_VARTOP
;		STX ZP_VARTOP + 1
;		PLA
;		STA (ZP_GEN_PTR)
;		ADC ZP_GEN_PTR
;		TAY
;		LDA #$00
;		STZ ZP_GEN_PTR
;		BCC L95F3
;		INC ZP_GEN_PTR + 1
;L95F3:
;		STA (ZP_GEN_PTR),Y
;		INY
;		BNE L95FA
;		INC ZP_GEN_PTR + 1
;L95FA:
;		CPY ZP_VARTOP
;		BNE L95F3
;		CPX ZP_GEN_PTR + 1
;		BNE L95F3
;		JUMP L94FB
;			;  Check if another dimension
;L9605:
;		BRK
;		.byte  $0B
;		.byte  tknDIM, " space"
;		BRK
;			;  Program environment commands
;			;  ============================
;			;  HIMEM=address - Set top of BASIC memory, clearing stack
;			;  -------------------------------------------------------
varSetHIMEM			; L960F!

			TODO_CMD "varSetHIMEM"
			
;		CALL L96B9
;			;  Check for '=', evaluate integer
;		LDA ZP_INT_WA
;		STA ZP_HIMEM
;		STA ZP_BAS_SP
;			;  Set STACKBOT and HIMEM
;		LDA ZP_INT_WA + 1
;		STA ZP_HIMEM + 1
;		STA ZP_BAS_SP + 1
;		BRA L963B
;			;  Return to execution loop
;			;  LOMEM=address
;			;  -------------
varSetLOMEM			; L9620!

			TODO_CMD "varSetLOMEM"
			
;		CALL L96B9
;			;  Check for '=', evaluate integer
;		LDA ZP_INT_WA
;		STA ZP_LOMEM
;		STA ZP_VARTOP
;			;  Set LOMEM and VARTOP
;		LDA ZP_INT_WA + 1
;		STA ZP_LOMEM + 1
;		STA ZP_VARTOP + 1
;		CALL InittblFPRtnAddr
;			;  Clear dynamic variables
;		BRA L963B
;			;  Return to execution loop
;			;  PAGE=address - Set program start
;			;  --------------------------------
varSetPAGE			; L9634!

			TODO_CMD "varSetPAGE"
			
;		CALL L96B9
;			;  Check for '=', evaluate integer
;		LDA ZP_INT_WA + 1
;		STA ZP_PAGE_H
;			;  Set PAGE
;L963B:
;		JUMP continue
;			;  Return to execution loop
;			;  CLEAR
;			;  -----
cmdCLEAR			; L963E!

			TODO_CMD "cmdCLEAR"
			
;		CALL scanNextStmt
;		CALL ResetVars
;			;  Check end of statement, clear variables
;		BRA L963B
;			;  Return to execution loop
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
L9667		LEAY	1,Y
		CALL	scanNextStmtFromY		;  Check end of statement
		LDD	#$FFFF
		BRA	L965F				;  Jump to set TRACE $FFxx and TRACE ON
L9670		LEAY	1,Y
		CALL	scanNextStmtFromY		;  Check end of statement
		CLRD
		BRA	L9663

			;  Jump to set TRACE OFF
			;  TIME=val, TIME$=s$ - set TIME or TIME$
			;  ======================================
varSetTIME			; L9679!

			TODO_CMD "varSetTIME"
			
;		INY
;		LDA (ZP_TXTPTR),Y
;			;  Get next character
;		CMP #'$'
;		BEQ L968E
;			;  Jump for TIME$=
;		CALL L96B9
;		STZ ZP_FPA
;			;  Check for '=', evaluate integer, set byte 5 to zero
;		LDX #ZP_INT_WA
;		LDY #$00			;DP
;			;  Point to IntA
;		LDA #$02
;			;  A=2 for Write TIME
;L968B:
;		JUMP OSWORD_continue
;			;  Call OSWORD, return to execution loop
;			;  TIME$=string
;			;  ------------
;L968E:
;		INC ZP_TXTOFF
;		CALL L9B46
;			;  Step past '$', step past '=', evaluate expression
;		LDA ZP_VARTYPE
;		BNE JUMPBrkTypeMismatch2
;			;  If not string, jump to Type mismatch
;		LDA #$0F\
;			;  A = $0F for Write RTC
;		LDY ZP_STRBUFLEN
;		STY $05FF
;			;  Store string length as subfunction
;		LDX #$FF
;		LDY #$05
;			;  Point to StringBuf-1
;		BRA L968B
;			;  Call OSWORD, return to execution loop
evalstackStringExpectINTCloseBracket			; L96A4
		CALL	StackString
evalL1OpenBracketConvert2INT				; L96A7
		CALL	evalL1OpenBracket
		BRA	checkTypeInAConvert2INT
checkCommaThenEvalAtYcheckTypeInAConvert2INT		; L96AC
		CALL	checkForCommaOrBRK

evalAtYcheckTypeInAConvert2INT				; L96AF
		CALL	evalAtY
		BRA	checkTypeInAConvert2INT

evalLevel1checkTypeStoreAsINT
		CALL	evalLevel1
		BRA	checkTypeInAConvert2INT
;			;  Evaluate =<integer>
;			;  ===================
;L96B9:		CALL L9B46			;  Check for '=', evaluate expression
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
;;;		LDA ZP_TXTPTR
;;;		STA ZP_TXTPTR2
;;;		LDA ZP_TXTPTR + 1
;;;		STA ZP_TXTPTR2 + 1
;;;		LDA ZP_TXTOFF
;;;		STA ZP_TXTOFF2
		STY	ZP_TXTPTR2
		LDA	#tknPROC
		CALL	doFNPROCcall
		CALL	LDYZP_TXTPTR2scanNextStmtFromY
		JUMP	continue
L96FB
;;		LDY #$03
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
;;		LDY	ZP_TXTOFF2
;;		STY	ZP_TXTOFF
		CALL	SkipSpaceCheckCommaAtY
		BEQ	cmdLOCAL
		JUMP	decYGoScanNextContinue
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
		STY	ZP_TXTPTR
		JSR	OSByte82
		LEAX	1,X
		BNE	L9797					; machine high order address != $FFFF, skip memory clash check
		CMPU	ZP_HIMEM				; check if basic stack is at HIMEM
		BNE	brkBadMode				; else "BAD MODE"
		LDX_B	ZP_INT_WA + 3				; mode # low byte as got by eval
		LDA	#$85
		JSR	OSBYTE					; get mode HIMEM address in X
		CMPX	ZP_VARTOP				; if below VARTOP
		LDY	ZP_TXTPTR
		BLO	brkBadMode				; "BAD MODE"
		STX	ZP_HIMEM
		LEAU	,X
L9797
		LDY	ZP_TXTPTR
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
		LDX	zp_mos_error_ptr
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
		LEAY	-1,Y
		CALL	evalForceINT
		CALL	doVDUChar_fromWA3
		CALL	SkipSpaceCheckCommaAtY
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


allocFNPROC	PSHS	Y
		LDY	ZP_GEN_PTR
		LDA	1,Y				; get token

		LDB	#BASWKSP_DYNVAR_off_PROC	; set A to offset of var list in page 4
		CMPA	#tknPROC
		BEQ	__allocVARint
		LDB	#BASWKSP_DYNVAR_off_FN
		BRA	__allocVARint

		; Allocate a dynamic variable 
		; on entry ZP_GEN_PTR => variable name -1
		; ZP_NAMELENORVT contains the length of the variable name

allocVAR	PSHS	Y
		LDY	ZP_GEN_PTR
		LDB	1,Y
		ASLB				; get variable offset in page 4
__allocVARint
		LDA	#BASWKSP_INTVAR / 256
		TFR	D,Y				; Y points at DYN var head
__allocVARint_lp1
		STY	ZP_NAMELENORVT + 1		; look for tail of the current list
		TST	0,Y				; if high byte of next addr = 0 then at end of list
		BEQ	_allocVARint_sk1
		LDY	,Y				; jump to next pointer
		BRA	__allocVARint_lp1@lp1
_allocVARint_sk1
		LDX	ZP_VARTOP
		STX	,Y				; store pointer to next var block in old tail ptr
		CLR	,X+
		CLR	,X+
		LDB	#2				
		CMPB	ZP_NAMELENORVT			; equal to 2, don't store name
		BEQ	_allocVARint_sk2
		LDY	ZP_GEN_PTR
		LEAY	2,Y
_allocVARint_lp2
		LDA	,Y+
		STA	,X+
		INCB
		CMPB	ZP_NAMELENORVT
		BNE	_allocVARint_lp2
_allocVARint_sk2
		PULS	Y,PC
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
		;		CMPX	ZP_BAS_SP
		PSHS	U
		CMPX	,S++
		BLO	allheap_sk_ok
							;L989F:
		LDX	ZP_NAMELENORVT + 1		; Remove this variable from heap
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
		LDY	ZP_TXTPTR2
findVarOrAllocEmpty
		STY	ZP_TXTPTR2
		CALL	findVarAtYSkipSpaces
		BNE	anRTS6
		BCS	anRTS6
		LDY	ZP_TXTPTR2
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
		ORCC  #CC_C				; Return EQ/CS for invalid name
anRTS6		RTS

memacc32						;L98D1:
		LDA	#VAR_TYPE_INT_LE		; Little-endian integer
memacc8							;L98D3:
		PSHS	A				; 0 for byte on entry unless fallen through from memacc32
		CALL	evalLevel1checkTypeStoreAsINT
		STY	ZP_TXTPTR2
		JUMP	popAasVarType
memaccStr						; L98DC
		CALL	evalLevel1checkTypeStoreAsINT
		LDA	ZP_INT_WA + 2			; if pointer at zero page fail with RANGE TODO: Is this valid on 6809?
		BEQ	brkRange
		STY	ZP_TXTPTR2
		LDA	#VAR_TYPE_STRING_STAT
		STA	ZP_INT_WA + 0
		ORCC	#CC_C
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
;findVarAtPTRA
;		LDY	ZP_TXTPTR
;		STY	ZP_TXTPTR2
findVarLp1
findVarAtYSkipSpaces					; L9901;
		LDA	,Y+
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
		LDA	0,Y				; Get next character
		CMPA	#'%'
		BNE	skfindVarDynamic		; Not <uc>%, jump to look for dynamic variable
		LDA	#BASWKSP_INTVAR / 256
		STA	ZP_INT_WA + 2			; High byte of static variable address
		LDA	#VAR_TYPE_INT
		STA	ZP_INT_WA + 0			; Type=Integer
		LEAY	1,Y
		LDA	,Y				; Get next character
		CMPA	#'('				; check to see if it was an array access after all  
		BNE	findVarCheckForIndirectAfter
;			;  Not <uc>%(, so jump to check <uc>%!n and <uc>%?n
;			;  Look for a dynamic variable
;			;  ---------------------------
skfindVarDynamic
		LDB	#$05
		STB	ZP_INT_WA + 0
;		LDY	ZP_TXTPTR2
		LEAX	-2,Y
		STX	ZP_GEN_PTR			;  $37/8=>1 byte BEFORE start of variable name
		LDB	#1				; variable name length
;		LEAY	1,Y
		LDA	-1,Y				; re-get first char
		CMPA	#'A'
		BHS	findVarDyn_sk2
		CMPA	#'0'
		BLO	findVarDyn_skEnd
		CMPA	#'9'+1
		BHS	findVarDyn_skEnd
findVarDyn_lp						; L9959
		INCB
		LDA	,Y+
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
		LDA	,Y+				; Get next character
findVarDyn_skNotInt					; L9989
		CMPA	#'('
		BEQ	findVarDyn_skArray		; Jump if array
		LEAY	-1,Y
		CALL	findVarNewAPI
		BEQ	findVarDyn_skNotFound		; Search for variable, exit if not found
findVarDyn_skGotArrayTryInd				; L9994
		LDA	,Y				; Get next character
findVarCheckForIndirectAfter				; L9998
		CMPA	#'!'
		BEQ	findVarIndWord			; Jump for <var>!...
		EORA	#'?'
		BEQ	findVarIndByte			; Jump for <var>?...
		ANDCC	#~CC_C
		STY	ZP_TXTPTR2			; Update PTRB offset
		LDA	#$FF
		RTS					; NE/CC = variable found
findVarDyn_skInvalid					; L99A6
		LDA	#$00
		ORCC	#CC_C
		RTS					; EQ/CS = invalid variable name
findVarDyn_skNotFound
		LDA	#$00
		ANDCC	#~CC_C
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
		LEAY	1,Y
		CALL	evalLevel1checkTypeStoreAsINT
		PULS	D
		ADDD	ZP_INT_WA + 2
		STD	ZP_INT_WA + 2				; add stacked and eval'd addresses
popAasVarType						      ;L99CE
		PULS	A
		STA	ZP_INT_WA + 0				;  Store returned type
		ANDCC	#~CC_C
		LDA	#$FF
		RTS						NE/CC = variable found


;			;  array(
;			;  ------
findVarDyn_skArray
		TODODEADEND "findVarDyn_skArray"
;		CALL L99FE
;			;  get array element address
;		BRA findVarDyn_skGotArrayTryInd
;			;  Check for array()!... and array()?...
findVarDyn_gotDollar
		DEC	ZP_INT_WA + 0	; set type
		INCB
		LDA	,Y+
		CMPA	#'('
		BEQ	findVarDyn_skArrayStr		; got an array
		LEAY	-1,Y
		CALL	findVarNewAPI
		BEQ	findVarDyn_skNotFound
findVarDyn_retDynStr					; L99EB
		STY	ZP_TXTPTR2
		LDA	#VAR_TYPE_STRING_DYN
		STA	ZP_INT_WA + 0
		SEC
		RTS
findVarDyn_skArrayStr					; L99F1
		TODODEADEND "findVarDyn_skArrayStr"
;		CALL L99FE
;		BRA findVarDyn_retDynStr
;L99F6:
;		BRK
;		.byte  $0E
;		.byte  "Array"
;		BRK
;			;  Process array dimensions
;			;  ------------------------
;			;  On entry, ($37/8),Y=>'('
;			;		   $2C=type
;			;  On exit,	 $2A/B=>data block
;			;
;			;  DIM r(100)				r(37)=val	    ->	 r(37)
;			;  DIM r(100,200)			r(37,50)=val	    ->	 r(37*100+50)
;			;  DIM r(100,200,300)			r(37,50,25)=val	    ->	r((37*100+50)*200+25)
;			;  DIM r(100,200,300,400)		r(37,50,25,17)=val  -> r(((37*100+50)*200+25)*300+17)
;			;
;L99FE:
;		INX
;		INY
;			;  Step past '('
;		CALL findVar
;		BEQ L99F6				;  If not found, generate error
;		STX ZP_TXTOFF2
;		LDA ZP_INT_WA + 2
;		PHA					;  Save info block address and type
;		LDA ZP_INT_WA
;		PHA
;		LDA ZP_INT_WA + 1
;		PHA
;		LDA (ZP_INT_WA)				;  Get offset to data (number of dimensions)*2+1
;		CMP #$04
;		BCC L9A85
;			;  <4 - a 1-dimensional array
;		CALL varFALSE
;			;  IntA=1
;		LDA #$01
;		STA ZP_INT_WA + 3
;L9A1D:
;		CALL stackINT_WAasINT
;			;  Push IntA
;		CALL evalAtYcheckTypeInAConvert2INT
;			;  Evaluate integer expression
;		INC ZP_TXTOFF2
;			;  Step past character
;		CPX #','
;		BNE L99F6
;			;  If not ',', error as must be some more dimensions
;		LDX #ZP_NAMELENORVT
;		CALL popIntAtX
;		LDY ZP_FPB + 1
;		PLA
;		STA ZP_GEN_PTR + 1
;		PLA
;		STA ZP_GEN_PTR
;			;  Pop variable info block pointer
;		PHA
;		LDA ZP_GEN_PTR + 1
;		PHA
;			;  Push it back again
;		CALL L9AD3
;		STY ZP_INT_WA + 3
;		LDA (ZP_GEN_PTR),Y
;		STA ZP_FPB + 4
;		INY
;		LDA (ZP_GEN_PTR),Y
;		STA ZP_FPB + 5
;		LDA ZP_INT_WA
;		ADC ZP_NAMELENORVT
;		STA ZP_INT_WA
;		LDA ZP_INT_WA + 1
;		ADC ZP_NAMELENORVT + 1
;		STA ZP_INT_WA + 1
;		CALL L9508
;		SEC
;		LDA (ZP_GEN_PTR)
;		SBC ZP_INT_WA + 3
;		CMP #$03
;		BCS L9A1D
;		CALL stackINT_WAasINT
;		CALL evalL1OpenBracketConvert2INT
;		PLA
;		STA ZP_GEN_PTR + 1
;		PLA
;		STA ZP_GEN_PTR
;		LDX #ZP_NAMELENORVT
;		CALL popIntAtX
;		LDY ZP_FPB + 1
;		CALL L9AD3
;		CLC
;		LDA ZP_NAMELENORVT
;		ADC ZP_INT_WA
;		STA ZP_INT_WA
;		LDA ZP_NAMELENORVT + 1
;		ADC ZP_INT_WA + 1
;		STA ZP_INT_WA + 1
;		BCC L9A96
;L9A85:
;		CALL evalL1OpenBracket
;		CALL fpcheckTypeInAConvert2INT
;		PLA
;		STA ZP_GEN_PTR + 1
;		PLA
;		STA ZP_GEN_PTR
;		LDY #$01
;		CALL L9AD3
;L9A96:
;		PLA
;		STA ZP_INT_WA + 2
;		CMP #$05
;		BNE L9AB4
;		LDX ZP_INT_WA + 1
;		LDA ZP_INT_WA
;		ASL ZP_INT_WA
;		ROL ZP_INT_WA + 1
;		ASL ZP_INT_WA
;		ROL ZP_INT_WA + 1
;		ADC ZP_INT_WA
;		STA ZP_INT_WA
;		TXA
;		ADC ZP_INT_WA + 1
;		STA ZP_INT_WA + 1
;		BRA L9ABC
;L9AB4:
;		ASL ZP_INT_WA
;		ROL ZP_INT_WA + 1
;		ASL ZP_INT_WA
;		ROL ZP_INT_WA + 1
;L9ABC:
;		TYA
;		ADC ZP_INT_WA
;		STA ZP_INT_WA
;		BCC L9AC6
;		INC ZP_INT_WA + 1
;		CLC
;L9AC6:
;		LDA ZP_GEN_PTR
;		ADC ZP_INT_WA
;		STA ZP_INT_WA
;		LDA ZP_GEN_PTR + 1
;		ADC ZP_INT_WA + 1
;		STA ZP_INT_WA + 1
;		RTS
;L9AD3:
;		LDA ZP_INT_WA + 1
;		AND #$C0
;		ORA ZP_INT_WA + 2
;		ORA ZP_INT_WA + 3
;		BNE brkSubscript
;		LDA ZP_INT_WA
;		CMP (ZP_GEN_PTR),Y
;		INY
;		LDA ZP_INT_WA + 1
;		SBC (ZP_GEN_PTR),Y
;		BCS brkSubscript
;		INY
;		RTS
;brkSubscript:
;		BRK
;		.byte  $0F
;		.byte  "Subscript"
;		BRK
fnProcScanZP_GEN_PTRplus1varname
		LDB	#$01
		* API:
		*	On Entry
		*		ZP_GEN_PTR points at 1 before the string to be scanned
		*		B points at first char after ZP_GEN_PTR to be checked
		*	On Exit
		*		B points at char after last matching
		; scans chars that are allowed in variable names
fnProcScanZP_GEN_PTRplusBvarname
		CLRA
		LDX	ZP_GEN_PTR
		LEAX	D,X
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
		; API changed used to scan from ZP_TXTPTR now scan from Y
skipSpacesDecodeLineNumberNewAPI
		;		LDY	ZP_TXTPTR
skipSpacesDecodeLineNumberlp
		LDA	, Y+
		CMPA	#' '
		BEQ	skipSpacesDecodeLineNumberlp		;  Skip spaces
		CMPA	#tknLineNo
		BEQ	decodeLineNumber
		LEAY	-1,Y
		STY	ZP_TXTPTR
		BRA	__rtsCLC				;  Not line number, return CC
decodeLineNumber
		CLR	ZP_INT_WA				; TODO - remove these added for testing API changes
		CLR	ZP_INT_WA + 1				; TODO - remove these added for testing API changes
		LDA	,Y+
		ASLA
		ASLA
		TFR	A,B
		ANDA	#$C0
		EORA	,Y+
		STA	ZP_INT_WA + 3
		TFR	B,A
		ASLA
		ASLA
		EORA	,Y+
		STA	ZP_INT_WA + 2
		STY	ZP_TXTPTR
		ORCC	#CC_C
		RTS
;			;  Line number, return CS
__rtsCLC
		ANDCC	#~CC_C
		RTS
;			;  Expression Evaluator
;			;  ====================
;			;  ExpectEquals - evalute =<expr>
;			;  ------------------------------
;L9B46:
;		LDA ZP_TXTPTR
;		STA ZP_TXTPTR2
;		LDA ZP_TXTPTR + 1
;		STA ZP_TXTPTR2 + 1
;		LDA ZP_TXTOFF
;		STA ZP_TXTOFF2
skipSpacesExpectEqEvalExp				; L9B52
		LDY	ZP_TXTPTR2
sseeee_lp1	LDA	,Y+
		CMPA	#$20
		BEQ	sseeee_lp1			;  Skip spaces
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
scanNextExpectColonElseCR_2				; L9B91
;;;		LDY	ZP_TXTPTR2
		LDA	,Y+
		BRA	scanNextExpectColonElseCR
LDYZP_TXTPTR2scanNextStmtFromY				; L9B96
		LDY	ZP_TXTPTR2			; restore Y from ZP_TXTPTR2 - eg after FN/PROCcall
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
;scanNextStmt	LDY ZP_TXTPTR	 -- obsolete?
scanNextStmtFromY
1		LDA	,Y+
		CMPA	#' '
		BEQ	1B					;  Skip spaces		
scanNextExpectColonElseCR
		CMPA	#':'
		BEQ	decYasTXTPTR				;  colon, end of statement
		CMPA	#$0D
		BEQ	decYasTXTPTR				;  <cr>, end of statement
		CMPA	#tknELSE
		BNE	brkSyntax				;  Not correctly terminated, error
decYasTXTPTR	LEAY	-1,Y
storeYasTXTPTR	STY	ZP_TXTPTR
checkForESC	
		LDA	[ZP_ESCPTR]
		BMI	errEscape				;  Escape set, give Escape error
anRTS9		RTS

;
;
scanNextStmtAndTrace						; L9BCF
		CALL	scanNextStmtFromY
		LDA	,Y+
		CMPA	#':'
		BEQ	anRTS9
		TFR	Y,D
		CMPA	#BAS_InBuf
		LBEQ	immedPrompt
doTraceOrEndAtELSE						; L9BDE
		LDA	,Y
		LBMI	immedPrompt				; is end of program?
		TST	ZP_TRACE				; got here it must be an 0d?
		BEQ	skNoTrace
		STA	ZP_INT_WA + 3
		LDA	1,Y
		STA	ZP_INT_WA + 2
		CALL	doTRACE
skNoTrace							;L9BF2:
								;L9BF4: -- check API
		LEAY	3,Y					; skip to next token (after line number)
								;L9BFD: -- check API
L9C01rts
		RTS
cmdIF			; L9C08
		CALL	evalExpressionMAIN
		LBEQ	brkTypeMismatch
		BPL	skCmdIfNotReal
		CALL	fpReal2Int
skCmdIfNotReal						; L9C12:
		LDA	ZP_INT_WA
		ORA	ZP_INT_WA + 1
		ORA	ZP_INT_WA + 2
		ORA	ZP_INT_WA + 3
		BEQ	skCmdIFFALSE
		CMPB	#tknTHEN
		BEQ	skCmdIfTHEN
		JUMP	skipSpacesAtYexecImmed
skCmdIfTHEN						; L9C27:
		LEAY	1,Y				; skip THEN token
skCmdIfExecImplicitGotoOrTokens				; L9C29	
		CALL	skipSpacesDecodeLineNumberNewAPI; look for line number
		LBCC	skipSpacesAtYexecImmed		; if not found exec after THEN/ELSE
		CALL	findProgLineOrBRK
		CALL 	checkForESC
		JUMP	cmdGOTODecodedLineNumber
skCmdIFFALSE						; L9C37
							; L9C39
		LDA 	,Y+				; look for ELSE, if not found exec as next line
		CMPA	#tknELSE
		BEQ	skCmdIfExecImplicitGotoOrTokens
		CMPA	#$0D
		BNE	skCmdIFFALSE
		LEAY	-1,Y
		JUMP	stepNextLineOrImmedPrompt
doTRACE						; L9C4B

		; line number is now in WA+2 - this needs changed

		LDD	ZP_INT_WA + 2
		CMPD	ZP_MAXTRACLINE
		BHS	L9C01rts
		LDA	#'['
		CALL	list_printANoEDIT
		CALL	int16print_AnyLen

		;TODO: remove -- prints U register
		LDA	#'&'
		CALL	list_printANoEDIT
		PSHS	X
		TFR	U,X
		JSR	PR2HEX
		PULS	X


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
		CALL	popFPFromStackToPTR1
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
		CALL	popFPFromStackToPTR1
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
		BMI	 evalDoComparePopIntFromMachineStackConvertToRealAndCompare				;  <int> <compare> <real> - convert and compare
		LDA	 ZP_INT_WA + 0
		EORA	 #$80
		STA	 ZP_INT_WA + 0			; swap RHS sign bit
					;  Compare current integer with stacked integer
		LDD	,S++
		SUBD	ZP_INT_WA + 2
		STD	ZP_INT_WA + 2	; subtract least sig
		LDD	,S++
		SBCB	ZP_INT_WA + 1
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
		PSHS	B,Y
		TSTA
		BNE	L9CC6brkTypeMismatch
		LDB	0,U				; get stacked string length
		CMPB	ZP_STRBUFLEN			; get shortest length in ZP_GEN_PTR
		BLS	L9D13
		LDB	ZP_STRBUFLEN
L9D13
		STB	ZP_GEN_PTR
		CLRB
		LEAX	1,U				; point X at 1st byte of stacked string
		LDY	#BASWKSP_STRING			; point Y at LHS string
L9D15
		CMPB	ZP_GEN_PTR			; compare strings
		BEQ	L9D23
		INCB
		LDA	,X+
		CMPA	,Y+
		BEQ	L9D15
		BRA	L9D27
L9D23
		LDA	,U				; if we got here the strings matched
		CMPA	ZP_STRBUFLEN			; so compare lengths instead
L9D27
		PSHS	CC
		CALL	discardStackedStringNew
		PULS	CC,B,Y,PC
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
		LEAY	 -1,Y
		RTS					;  Store type in ZP_VARTYPE and return
;			;  OR <numeric>
;			;  ------------
evalLevel7OR						; L9D4C
		CALL	INTevalLevel6
		CALL	checkTypeInAConvert2INT		;  Stack integer, call Level 6 Evaluator, ensure integer
		PSHS	B
		LDB	#3
		LDX	#ZP_INT_WA
evalLevel7OR_lp						;L9D54:
		LDA	B,U				;  Get byte of stacked integer
		ORA	B,X
		STA	B,X				;  OR with integer accumulator
		DECB
		BPL	evalLevel7OR_lp
evalL7unstackreturnInt_evalL7lp0			; L9D5F
		LEAU	4,U				;  Drop integer from stack
		LDA	#$40
		PULS	B
		BRA	evalLevel7lp0			;  Integer result, jump to check for more OR/EORs
;			;  EOR <numeric>
;			;  -------------
evalLevel7EOR						; L9D4C
		CALL	INTevalLevel6
		CALL	checkTypeInAConvert2INT		;  Stack integer, call Level 6 Evaluator, ensure integer
		PSHS	B
		LDB	#3
		LDX	#ZP_INT_WA
evalLevel7XOR_lp						;L9D54:
		LDA	B,U				;  Get byte of stacked integer
		EORA	B,X
		STA	B,X				;  OR with integer accumulator
		DECB
		BPL	evalLevel7XOR_lp
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

		LDA	,U+
		ANDA	ZP_INT_WA
		STA	ZP_INT_WA
		LDA	,U+
		ANDA	ZP_INT_WA + 1
		STA	ZP_INT_WA + 1
		LDA	,U+
		ANDA	ZP_INT_WA + 2
		STA	ZP_INT_WA + 2
		LDA	,U+
		ANDA	ZP_INT_WA + 3
		STA	ZP_INT_WA + 3

		LDA	#$40
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
		LDB	,Y+			;  Get next character
		CMPB	#'='
		BEQ	evalCompLtEq1		;  Jump with <=
		CMPB	#'>'
		BEQ	evalComplNeq		;  Jump with <>
;			;  Compare <
;			;  ---------
		LEAY	-1,Y
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
evalComplNeq					;L9DEC:
		CALL	evalDoCompare		;  Step past character, compare expressions
		BNE	evalCompRetTRUE
		BRA	evalCompRetFALSE

;			;  <> - TRUE, = - FALSE
;			;  > or >=
;			;  -------
evalComplGt1					  ;L9DF5:
		LDB    ,Y+			;  Get next character
		CMPB   #'='
		BEQ    evalCompGE1		;  Jump with >=
		LEAY	-1,Y
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
		PSHS	B,Y				; B contains next token
		TSTA					; if not a string
		LBNE	__skbrkTypeMismatch		; error
		LDB	,U				; get length of stacked
		ADDB	ZP_STRBUFLEN			; add length of current
		BCS	brkStringTooLong		; if there's a carry its too big
		STB	ZP_NAMELENORVT			; store combined len
		; move current string (RH) along by the length of (LH)
		LDX	#BASWKSP_STRING
		ABX					; X points to last char of combined string + 1
		LEAY	,X				; stick it in Y
		LDX	#BASWKSP_STRING			
		LDB	ZP_STRBUFLEN			; length of LH
		LDA	ZP_STRBUFLEN
		ABX
1		LDB	,-X
		STB	,-Y
		DECA
		BNE	1B				; shift current string along
		CALL	popStackedStringNew		; pop stacked string
		LDB	ZP_NAMELENORVT
		STB	ZP_STRBUFLEN
		PULS	B,Y				; pop next token
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
		LDD	2,U
		ADDD	ZP_INT_WA + 2
		STD	ZP_INT_WA + 2
		LDD	,U
		ADCB	ZP_INT_WA + 1
		ADCA	ZP_INT_WA + 0
		STD	ZP_INT_WA
		PULS	B
;			;  Drop integer from stack and return integer
;			;  ------------------------------------------
evalL4PopIntStackReturnInt				; L9E80
		LEAU	4,U
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
L9EA4		CALL	popFPFromStackToPTR1
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
		LDD	2,U
		SUBD	ZP_INT_WA + 2
		STD	ZP_INT_WA + 2
		LDD	0,U
		SBCB	ZP_INT_WA + 1
		SBCA	ZP_INT_WA + 0
		STD	ZP_INT_WA + 0
		PULS	B
		BRA evalL4PopIntStackReturnInt		;  Drop integer from stack and return

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
		CALL	popFPFromStackToPTR1
		CALL	fpFPAeqPTR1subFPA
		BRA	evalTokenFromVarTypeReturnReal


evalL4IntMinusReal					; L9EFF
		STB	ZP_VARTYPE			; preserve token
		CALL	popIntANew
		CALL	fpStackWAtoStackReal
		CALL	IntToReal
		CALL	popFPFromStackToPTR1
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
L9F2D		CALL	popFPFromStackToPTR1
		CALL	fpFPAeqPTR1mulFPA
		LDA	#$FF
		LDB	-1,Y
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

		; work out what sign changes (if any) we need to do at the end and pop result from stack
		LDA	ZP_INT_WA + 0
		EORA	,U
		STA	ZP_GEN_PTR			; ZP_GEN_PTR contains sign flip bit in bit 7


		CALL	intWA_ABS			; ABS int 
		LDX	#ZP_NAMELENORVT
		CALL	CopyIntA2ZPX			; and move to temp areas
		LDD	,U
		STD	ZP_INT_WA
		LDD	2,U
		STD	ZP_INT_WA + 2			; retrieve int from U stack but leave room (we'll place result there)
		CALL	intWA_ABS			; ABS it

		CLRA
		STA	0,U
		STA	1,U
		STA	2,U
		STA	3,U

		; now U points to B, WA contains A both only bottom 15 bits, multiply into 4 bytes at ZP_NAMELENORVT
		LDA	ZP_INT_WA + 3
		BEQ	1F
		LDB	ZP_NAMELENORVT + 3
		BEQ	1F
		MUL
		STD	2,U

1		; now contains two LSbytes multiplied together, multiply 2nd byte of A with LSB of B and add to acc
		LDA	ZP_INT_WA + 2
		BEQ	1F
		LDB	ZP_NAMELENORVT + 3
		BEQ	1F
		MUL
		ADDD	1,U
		STD	1,U
		BCC	1F
		INC	0,U
1
		;  multiply 1st byte of A with 2nd byte of B and add to acc
		LDA	ZP_INT_WA + 3
		BEQ	1F
		LDB	ZP_NAMELENORVT + 2
		BEQ	1F
		MUL
		ADDD	1,U
		STD	1,U
		BCC	1F
		INC	0,U
1
		;  multiply 2nd byte of A with 2nd byte of B and add to acc
		LDA	ZP_INT_WA + 2
		BEQ	1F
		LDB	ZP_NAMELENORVT + 2
		BEQ	1F
		MUL
		ADDD	0,U
		STD	0,U
1
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
		CALL	popFPFromStackToPTR1
		CALL	fpFPAeqPTR1divFPA
		LDA	#$FF
		BRA	divmodfinish
;			;  <expression> MOD <expression>
;			;  -----------------------------
evalL3DoMOD						; L9FF5
		CALL	evalDoIntDivide
		LDX	#ZP_INT_WA_C
		CALL	intLoadWAFromX
		LDA	ZP_GEN_PTR + 1
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
evalL2lp1	LDB	,Y+
		CMPB	#' '
		BEQ	evalL2lp1			;  Skip spaces
		CMPB	#'^'
		BEQ	evalDoCARET			;  Jump with ^
		RTS
;			;  <expression> ^ <expression>
;			;  ---------------------------
evalDoCARET						;LA027:
		CALL checkTypeIntToReal
		TODODEADEND "evalDoCARET"
;		CALL fpStackWAtoStackReal
;		CALL evalLevel1ConvertReal
;		LDA ZP_FPA + 2
;		CMP #$87
;		BCS LA079
;		CALL L82E0
;		BNE LA049
;		CALL popFPFromStackToPTR1
;		CALL fpCopyPTR1toFPA
;		LDA ZP_FP_TMP + 6
;		CALL LA5BE
;		BRA LA075
;LA049:
;		CALL fpCopyFPA_FPTEMP3
;		LDA ZP_BAS_SP
;		STA ZP_FP_TMP_PTR1
;		LDA ZP_BAS_SP + 1
;		STA ZP_FP_TMP_PTR1 + 1
;		CALL fpCopyPTR1toFPA
;		LDA ZP_FP_TMP + 6
;		CALL LA5BE
;LA05C:
;		LDA #$71
;		CALL fpCopyFPA_X----check was 400+A
;		CALL popFPFromStackToPTR1
;		CALL fpCopyPTR1toFPA
;		CALL fnLN_FPA
;		CALL fpFPAeqFPTEMP3mulFPA
;		CALL LA9E2
;		LDA #$71
;		CALL LA9A1
;LA075:
;		LDA #$FF
;		BRA evalLevel2again
;LA079:
;		CALL fpCopyFPA_FPTEMP3
;		CALL fpLoad1			;  FloatA=1.0
;		BRA LA05C


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
		PSHS	Y
		LDY	#ZP_FPB + 4
		LDD	ZP_INT_WA + 2
		CLR	4,Y
		CLR	3,Y
		CLR	2,Y
		CLR	1,Y
		CLR	0,Y

int16dig4_lp	SUBD	8,X			; try and subtract ten
		BCS	int16dig4_sk
		INC	4,Y			; it it doesn't overflow increment digit
		BRA	int16dig4_lp		
int16dig4_sk	ADDD	8,X			; add number back
		BEQ	int16dig_skiprest

int16dig3_lp	SUBD	6,X			; try and subtract ten
		BCS	int16dig3_sk
		INC	3,Y			; it it doesn't overflow increment digit
		BRA	int16dig3_lp		
int16dig3_sk	ADDD	6,X			; add number back
		BEQ	int16dig_skiprest

int16dig2_lp	SUBD	4,X			; try and subtract ten
		BCS	int16dig2_sk
		INC	2,Y			; it it doesn't overflow increment digit
		BRA	int16dig2_lp		
int16dig2_sk	ADDD	4,X			; add number back
		BEQ	int16dig_skiprest

int16dig1_lp	SUBD	2,X			; try and subtract ten
		BCS	int16dig1_sk
		INC	1,Y			; it it doesn't overflow increment digit
		BRA	int16dig1_lp		
int16dig1_sk	ADDD	2,X			; add number back
		BEQ	int16dig_skiprest

int16dig0_lp	SUBD	0,X			; try and subtract ten
		BCS	int16dig_skiprest
		INC	0,Y			; it it doesn't overflow increment digit
		BRA	int16dig0_lp		

int16dig_skiprest

		; number now decoded (reversed at ZP_FPB + 4)


		LDB	#$05
int16_scan0_lp					;LA0A8
		DECB				; scan for first non zero element
		BEQ	int16_scan0_sk
		LDA	B,Y
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
		LDA	B,Y
		ORA	#$30
		CALL	list_printA
		DECB
		BPL	int16_printDigits
		PULS	Y,PC			; RTS restore Y


;			;  Convert number to hex string
;			;  ----------------------------
cmdPRINT_num2str_hex					; LA0CA
		PSHS	Y
		TST	ZP_VARTYPE			; real?
		BPL	1F				; no
		CALL	fpReal2Int			;  Convert real to integer
1							; LA0D0:
		LDX	#ZP_FPB + 4
		LDY	#ZP_INT_WA + 4
		LDB	#4
1		LDA	,-Y				; unwind nibbles into a buffer
		ANDA	#$0F
		STA	,X+
		LDA	,Y				; reload for low nibble
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
3		PULS	Y,PC


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
		ORCC	#CC_C
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
LA1B2
		LDA	ZP_FPA + 2
		CMPA	#$84
		BHS	LA1C6				; if >= $84
		LSR	ZP_FPA + 3
		ROR	ZP_FPA + 4
		ROR	ZP_FPA + 5
		ROR	ZP_FPA + 6
		ROR	ZP_FPA + 7
		INC	ZP_FPA + 2
		BNE	LA1B2
LA1C6
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
		LDB	#$FF
LA2BF
		INCB
		SUBA	#$0A
		BCC	LA2BF
		ADDA	#$0A
		PSHS	A		; TODO - EXG?
		TFR	B,A
		BEQ	LA2CD
		CALL	cmdPRINT_numstr_printAlow_nyb_asdigit	; if not 0 print 10's
LA2CD
		PULS	A					; print 1's
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
		ANDCC	#~CC_C
		LDA	#$FF
		RTS

;			;  CLC=no number, return Real
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
		LDA	,Y+				;  Get next character
		CMPA	#'9'
		BHI	parseD_sknotdp			;  Not a digit, check for E or end of number
		SUBA	#'0'
		BLO	parseD_sknotdig			;  Not a digit, check for decimal point
		STA	ZP_FPA			;  Store this digit
		LDA	ZP_FPA + 7
		ASLA
		ASLA					;  A=num*4
		ADDA	ZP_FPA + 7
		ASLA					;  A=(num*4+num)*2 = num*10
		ADDA	ZP_FPA
		STA	ZP_FPA + 7			;  num=num*10+digit
parseD_lp1	LDA	,Y+				;  Step to next character	
		BRA	1F				; TODO: this is a bit of a cludge, maybe make '.' do branch?
parseD_sknotdig	LDA	-1,Y				; reload previous char
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
		BRA	parseD_lp1
;			;  Loop to check next digit
;			;  Deal with Exponent in scanned number
;			;  ------------------------------------
parseD_skScanExp
		CALL	parseD_scanExp			;  Scan following number
		ADDA	ZP_FP_TMP + 5
		STA	ZP_FP_TMP + 5		;  Add to current exponent

;			;  End of number found
;			;  -------------------
parseD_skDone	LEAY	-1,Y
		STY	ZP_TXTPTR2		;  Store PtrB offset
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
		ORCC	#CC_C
		RTS
parseD_skNegExp						;LA3B3
		CALL	parseD_scanExpReadDigits				;  Scan following number
		NEGA					; complement it
		RTS				;  Negate it, return CS=Ok
;			;  Scan exponent, allows E E+ E- followed by one or two digits
;			;  -----------------------------------------------------------
parseD_scanExp
		LDA	,Y+				;  Get next character
		CMPA	#'-'
		BEQ	parseD_skNegExp			;  Jump to scan and negate
		CMPA	#'+'
		BNE	parseD_scanExpSkipNotPlus	;  If '+', just step past it
parseD_scanExpReadDigits				; LA3C5
		LDA	,Y+	;			;  Get next character
parseD_scanExpSkipNotPlus				; LA3C8
		CMPA	#'9'
		BHI	parseD_scanExpSkipRet0		;  Not a digit, exit with CC
		SUBA	#'0'
		BCS	parseD_scanExpSkipRet0		;  Not a digit, exit with CC
		LDB	,Y+				;  Get next character in B!
		CMPB	#'9'
		BHI	parseD_scanExpSkipRetA		;  Not a digit, exit with CC=Ok
		SUBB	#'0'
		BCS	 parseD_scanExpSkipRetA		;  Not a digit, exit with CC=Ok
		PSHS	B
		LDB	#10
		MUL					; multiply A by 10
		TFR	B,A				; into A
		ADDA	,S+				; add second digit
		LEAY	-1,Y				; skip forward one, it gets put back later!
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
		ROR	ZP_FPA + 3
		ROR	ZP_FPA + 4
		ROR	ZP_FPA + 5
		ROR	ZP_FPA + 6
		ROR	ZP_FPA + 7
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
		LDA	ZP_FPB			; get back mantissa MSB from sign 
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
		BRA	fpCopyFPA_X
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
LA5B3
		LDX	#BASWKSP_FPTEMP3
		STX	ZP_FP_TMP_PTR1
		CALL	fpFPAeqPTR1divFPA
		LDA	#$FF
		RTS
LA5BE
;;		TAX
		TFR	A,B
		TSTB
		BPL LA5C9
;;		DEC A
;;		EOR #$FF
		NEGA
		STA	,-S
		CALL	fpFPAeq1.0divFPA
;;		PLX
		LDB	,S+
LA5C9
		BEQ	fpLoad1			;  Floata=1.0
		CALL	fpCopyFPA_FPTEMP1
		DECB
		BEQ	LA5D7
LA5D1		STB	,-S
		CALL	fpFPAeqPTR1mulFPA
;;		DEX
		LDB	,S+
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
		; TODO optimise this! 
		;  - Use 16 bit subs 
		;  - or keep at least one shift result in accumulator?
		;  - use ZP var instead of Y
		;  - get rid of lookup table?

		LDA	ZP_FPA + 3
		LBEQ	brkDivideByZero			; if MSB of divisor mantissa 0 then error
		CALL	fpMoveRealAtPTR1toFPB		; get dividend, if zero return 0
		BNE	1F
		JUMP	zero_FPA

1							;LA5FA:
		STY	ZP_TXTPTR
		LDA	ZP_FPB
		EORA	ZP_FPA
		STA	ZP_FPA			; store quotient sign in sign of FPA

		LDB	ZP_FPB + 1
		CLRA
		ADDD	#$81
		SUBD	ZP_FPA + 1
		STD	ZP_FPA + 1			; subtract divisor exponent from quotient exponent and add 1

		LDY	#$05
		LDB	#$08
		BRA	LA622
LA619
		STB	ZP_FP_TMP-1,Y		; store ZP_FPB from end of loop
		LDB	tblDivConsts-1,Y	; get new loop counter value from table
LA620
		BCS	LA638			; carry here has come from ROLA at POINT X
LA622
		LDA	ZP_FPB + 2
		CMPA	ZP_FPA + 3
		BNE	LA636
		LDA	ZP_FPB + 3
		CMPA	ZP_FPA + 4
		BNE	LA636
		LDA	ZP_FPB + 4
		CMPA	ZP_FPA + 5
		BNE	LA636
		LDA	ZP_FPB + 5
		CMPA	ZP_FPA + 6
LA636
		BCC	LA638
		CLC
		BRA	LA64F
LA638
		
		LDA	ZP_FPB + 5
		SUBA	ZP_FPA + 6
		STA	ZP_FPB + 5
		LDA	ZP_FPB + 4
		SBCA	ZP_FPA + 5
		STA	ZP_FPB + 4
		LDA	ZP_FPB + 3
		SBCA	ZP_FPA + 4
		STA	ZP_FPB + 3
		LDA	ZP_FPB + 2
		SBCA	ZP_FPA + 3
		STA	ZP_FPB + 2
		SEC
LA64F
		ROL	ZP_FPB
		ASL	ZP_FPB + 5
		ROL	ZP_FPB + 4
		ROL	ZP_FPB + 3
;;;POINT X
		ROLA
		STA	ZP_FPB + 2
		DECB				; B here is loop counter
		BNE	LA620
		LDB	ZP_FPB
		LEAY	-1,Y
		BNE	LA619
		ORA	ZP_FPB + 3
		ORA	ZP_FPB + 4
		ORA	ZP_FPB + 5
		BEQ	LA66B
		SEC
LA66B

		LDY	ZP_TXTPTR			; restore text pointer

		RORB
		RORB
		RORB
		ANDB	#$E0
		STB	ZP_FPA + 7
		LDA	ZP_FP_TMP
		STA	ZP_FPA + 6
		LDA	ZP_FP_TMP + 1
		STA	ZP_FPA + 5
		LDA	ZP_FP_TMP + 2
		STA	ZP_FPA + 4
		LDA	ZP_FP_TMP + 3
		STA	ZP_FPA + 3
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
		ORCC	#CC_C
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
brkTooBig	CALL PrRegs			; TODO - remove testing
		DO_BRK_B
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

		LDA	ZP_FPA			; multiply signs
		EORA	ZP_FPB
		STA	ZP_FPA


		PSHS	X,Y,U				; nothing to really save here but keep for later pops? X=D in BAS4128
		LDD	ZP_FPA + 3
		STD	ZP_FP_TMP
		LDD	ZP_FPA + 5
		STD	ZP_FP_TMP + 2
		CLRA
		CLRB
		STD	ZP_FPA + 3
		STD	ZP_FPA + 5
		STA	ZP_FPA + 7

							; do a long division adding result into FPA mantissa after
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
		PULS	X,Y,U
;		LDA	ZP_FPA + 3
		TSTA					; top byte of mant still in A
		LBPL	NormaliseRealA_3		; if top bit of FPA's mantissa not set then normalize it
		RTS
fnLN							;  =LN
		CALL evalLevel1ConvertReal
fnLN_FPA						; LA749
		STY	,--S
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
		BCC	LA77E
LA77C
		INCB
		DECA
LA77E
		STB	,-S
		STA	ZP_FPA + 2
		CALL	fpAddAtoBStoreAndRoundA
		LDX	#BASWKSP_FPTEMP4
		CALL	fpCopyFPA_X
		LDX	#fpConst0_54625
		LDY	#fpConstMin0_5
		LDB	#$02
		CALL	LA861NewAPI
		LDX	#BASWKSP_FPTEMP4
		CALL	fpFPAeqXmulFPA
		CALL	fpFPAeqPTR1mulFPA
		CALL	fpFPAeqPTR1addFPA
		CALL	fpCopyFPA_FPTEMP1
		LDA	,S+
		SUBA	#$81
		CALL	IntToReal_8signedA2real_check
		LDX	#fpConst_ln_2
		CALL	fpFPAeqXmulFPA
		LDX	#BASWKSP_FPTEMP1
		STX	ZP_FP_TMP_PTR1
		CALL	fpFPAeqPTR1addFPA
		LDA	#$FF
		PULS	Y,PC

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
		LSR	ZP_FPA + 3
		ROR	ZP_FPA + 4
		ROR	ZP_FPA + 5
		ROR	ZP_FPA + 6
		ROR	ZP_FPA + 7
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
*		Y -> constant to use if FPA is too small		( was A )
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


		STB	ZP_FP_TMP + 4
		STX	ZP_FP_TMP_PTR2
		LDA	ZP_FPA + 2			; get FPA exponent
		CMPA	#$40
		BLO	fpYtoPTR1toFPA			; if <-40 approximate as constant at U
		CALL	fpFPAeq1.0divFPA
		CALL	fpCopyFPA_FPTEMP1
		LDX	ZP_FP_TMP + 9
		STX	ZP_FP_TMP_PTR1
		CALL	fpFPAeqPTR1addFPA
LA879
		CALL	LA886
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
fpYtoPTR1toFPA						; LA896
		STY	ZP_FP_TMP_PTR1
		JUMP	fpCopyPTR1toFPA
fnACS

			TODO_CMD "fnACS"
			
;			;  =ACS
;		CALL fnASN
;		BRA LA8E1
fnASN

			TODO_CMD "fnASN"
			
;		CALL evalLevel1ConvertReal
;		LDA ZP_FPA
;		BPL LA8AF
;		STZ ZP_FPA
;		CALL LA8AF
;		BRA LA8D2
;LA8AF:
;		CALL fpCopyFPA_FPTEMP3
;		CALL LA929
;		LDA ZP_FPA + 3
;		BEQ fpSetFPAPIdiv2
;		CALL LA5B3
;		BRA LA8C6
fpSetFPAPIdiv2						; LA8BE
		LDX	#fpConstPiDiv2
		JUMP	fpCopyXtoFPA
fnATN
		CALL evalLevel1ConvertReal
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
LA8E1
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
		PSHS	Y
		LDX	#fpConstMin0_08005
		LDY	#fpConst0_9273
		LDB	#$04
		CALL	LA861NewAPI
		CALL	fpFPAeqFPTEMP3mulFPA
		PULS	Y,PC



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
		PSHS	Y
		LDY_FPC	fpConst1
		LDB	#$02
		CALL	LA861NewAPI
		PULS	Y
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

			TODO_CMD "fnRAD"
			
;			;  =RAD
;		CALL evalLevel1ConvertReal
;		LDA #<fpConstDeg2Rad
;		BRA fpFPAeqXmulFPA_checkusingX!
fnLOG

			TODO_CMD "fnLOG"
			
;			;  =LOG
;?		CALL	fnLN
;?		LDX	#fpConst0_43429
;?		BRA	fpFPAeqXmulFPA
fnDEG

			TODO_CMD "fnDEG"
			
;			;  =DEG
;		CALL evalLevel1ConvertReal
;		LDA #<fpConstRad2Deg
;		BRA fpFPAeqXmulFPA_checkusingX!
fnEXP			;  =EXP
		CALL	evalLevel1ConvertReal
		STY	,--S
LA9E2
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
LA9F7		CALL	L82E0
		LDX	#fpConst0_07121
		LDY	#fpConst1__2
		LDB	#$03
		CALL	LA861NewAPI
		CALL	fpCopyFPA_FPTEMP3
		LDY	#fpConst_e
		CALL	fpYtoPTR1toFPA
		LDA	ZP_FP_TMP + 6
		CALL	LA5BE
		CALL	fpFPAeqFPTEMP3mulFPA
		PULS	Y,PC

callOSByte81withXYfromINT
		CALL	evalLevel1checkTypeStoreAsINT
		PSHS	Y		; Save program pointer
		LDA	#$81
		LDX	ZP_INT_WA + 2
		LDY	ZP_INT_WA + 1
		JSR	OSBYTE
		PULS	Y,PC		; Get program pointer back
					; Returns X=16bit OSBYTE return value

		; note: the RND accumulator is in a different order to 6502
		; 0->3
		; 1->2
		; 2->1
		; 3->0
		; 4->4
		; this makes integer ops easier but adds slight complexity to loading into FPA 

fnRND_1							; LAA1E
		CALL	rndNext
fnRND_0							; LAA21
		CLR	ZP_FPA
		CLR	ZP_FPA + 1
		CLR	ZP_FPA + 7
		LDA	#$80
		STA	ZP_FPA + 2
;		PSHS	U
;		LDB	#3
;		LDX	#ZP_RND_WA + 4			; copy random accumulator
;		LDU	#ZP_FPA + 7			; int mantissa 6 downto 3
1;		EORA	,-X
;		STA	,-U
;		DECB
;		BPL	1B
;		PULS	U
		LDA	ZP_RND_WA+3
		STA	ZP_FPA+3
		LDA	ZP_RND_WA+2
		STA	ZP_FPA+4
		LDA	ZP_RND_WA+1
		STA	ZP_FPA+5
		LDA	ZP_RND_WA+0
		STA	ZP_FPA+6
		JUMP	fpNormalizeAndReturnFPA
fnRND_int						; RND(X)
		LEAY	1,Y
		CALL	evalL1OpenBracketConvert2INT
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
		CALL	popFPFromStackToPTR1
		CALL	fpFPAeqPTR1mulFPA_internal
		CALL	fpReal2Int
		CALL	inc_INT_WA
		BRA	LAA90
fnRND_randomize						; LAA69
		LDX	#ZP_RND_WA
		CALL	CopyIntA2ZPX
		LDA	#$40
		STA	ZP_RND_WA + 4
		RTS
fnRND			; LAA73!
		LDA	,Y
		CMPA	#'('
		BEQ	fnRND_int
		CALL	rndNext
		LDX	#ZP_RND_WA
intLoadWAFromX
		LDD	0,X
		STD	ZP_INT_WA + 0
		LDD	2,X
		STD	ZP_INT_WA + 2
LAA90
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
		BRA	LAA90
fnPOS			; LAAA3!

			TODO_CMD "fnPOS"
			
;			;  =POS
;		CALL fnVPOS
;		STX ZP_INT_WA
;		RTS
fnUSR			; LAAA9!

			TODO_CMD "fnUSR"
			
;			;  =USR
;		CALL evalLevel1checkTypeStoreAsINT
;		CALL L9304
;		STA ZP_INT_WA
;		STX ZP_INT_WA + 1
;		STY ZP_INT_WA + 2
;		PHP
;		PLA
;		STA ZP_INT_WA + 3
;		CLD
;		BRA LAA90
fnVPOS			; LAABC!

			TODO_CMD "fnVPOS"
			
;			;  =VPOS
;		LDA #$86
;		JSR OSBYTE
;		TYA


			;  =EXT#channel - read open file extent
			; -------------------------------------
fnEXT
		LDA	#$02			; 02=Read EXT
		BRA	varGetFInfo

			;  =PTR#channel - read open file pointer
			; --------------------------------------
varGetPTR
		CLRA				; 00=Read PTR
varGetFInfo
		PSHS	A
		JSR	evalHashChannel		; Evaluate #channel, save TXTPTR, Y=channel
		LDX	#ZP_INT_WA
		PULS	A
		JSR	OSARGS			; Read to INTA
		LDY	ZP_TXTPTR		; Get TXTPTR back
		TST	ZP_BIGEND
		LBNE	SwapEndian		; Swap INTA
		RTS

			;  =BGET#channel - get byte from open file
			; ----------------------------------------
fnBGET
		JSR	evalHashChannel		; Evaluate #channel, save TXTPTR, Y=channel
		JSR	OSBGET			; Read byte
		LDY	ZP_TXTPTR		; Get TXTPTR back
		JUMP	retA8asINT

			;  =OPENIN f$ - open file for input
			;  ================================
fnOPENIN
		LDA #$40
		BRA fileOpen			;  OPENIN is OSFIND $40

			;  =OPENOUT f$ - open file for output
			;  ==================================
fnOPENOUT
		LDA #$80
		BRA fileOpen			;  OPENOUT is OSFIND $80

;			;  =OPENUP f$ - open file for update
;			;  =================================
fnOPENUP
		LDA #$C0			;  OPENUP is OSFIND $C0
fileOpen
		PSHS	A
		TODODEADEND	"fnOPEN*"
;		CALL evalLevel1
;		BNE @sk1
;		CALL str600CRterm
;		LDX #$00
;		LDY #$06
;		PLA
;		JSR OSFIND
		JUMP retA8asINT
;@sk1:		JUMP brkTypeMismatch
;
fnPI							; LAAFF!
		CALL	fpSetFPAPIdiv2			; load PI/2 into FPA and increment exponent for PI
		INC	ZP_FPA + 2
		RTS

;			;  =EVAL string$ - Tokenise and evaluate expression
;			;  ================================================
fnEVAL

		TODO_CMD "fnEVAL"
			
;		CALL evalLevel1
;		BNE JUMPBrkTypeMismatch3		;  Evaluate value, error if not string
;		INC ZP_STRBUFLEN
;		LDY ZP_STRBUFLEN			;  Increment string length to add a <cr>
;		LDA #$0D
;		STA $0600 - 1,Y				;  Put in terminating <cr>
;		CALL StackString				;  Stack the string
;			;  String has to be stacked as otherwise would
;			;   be overwritten by any string operations
;			;   called by Evaluator
;		rep		#PF_I16
;		.i16
;		ldx		ZP_TXTPTR2
;		phx
;		lda		ZP_TXTOFF2
;		pha
;		ldx		ZP_BAS_SP
;		inx
;		stx		ZP_TXTPTR2
;		stx		ZP_GEN_PTR
;		sep		#PF_I16
;		.i8
;		CALL L8E1F				;  Tokenise string on stack at GPTR
;		STZ ZP_TXTOFF2				;  Point PTRB offset back to start
;		CALL evalAtY				;  Call expression evaluator
;		CALL LBCE1				;  Drop string from stack
;pullPTRBandRTS:
;		rep			#PF_I16
;		.i16
;		PLA
;		STA ZP_TXTOFF2				;  Restore PTRB
;		PLX
;		STX ZP_TXTPTR
;		sep			#PF_A16
;		.i8
;		LDA ZP_VARTYPE				;  Get expression return value
;		RTS					;  And return
;JUMPBrkTypeMismatch3:
;		JUMP brkTypeMismatch
;
;
fnVAL

			TODO_CMD "fnVAL"
			;  =VAL
;		CALL		evalLevel1
;		BNE		JUMPBrkTypeMismatch3
;str2Num:	LDX		ZP_STRBUFLEN
;		STZ		$0600,X
;		rep		#PF_I16
;		.i16
;		ldx		ZP_TXTPTR2
;		phx
;		lda		ZP_TXTOFF2
;		pha
;		stz		ZP_TXTOFF2
;		ldx		#$600
;		stx		ZP_TXTPTR2
;		sep		#PF_I16
;		.i8
;		CALL		skipSpacesPTRB
;		CMP		#'-'
;		BEQ		@sk1
;		CMP		#'+'
;		BNE		@sk2
;		CALL		skipSpacesPTRB
;@sk2:		DEC		ZP_TXTOFF2
;		CALL		parseDecimalLiteral
;		BRA @sk3
;@sk1:		CALL skipSpacesPTRB
;		DEC ZP_TXTOFF2
;		CALL parseDecimalLiteral
;		BCC @sk3
;		CALL evalLevel1CheckNotStringAndNegate
;@sk3:		STA ZP_VARTYPE
;		BRA pullPTRBandRTS
;		
;		
fnINT

		CALL	evalLevel1
		LBEQ	brkTypeMismatch
		BPL	1F			; already an INT
		LDA	ZP_FPA
		PSHS	CC			; get sign in Z flag and save
		CALL fpFPAMant2Int_remainder_inFPB
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

			TODO_CMD "fnASC"			
;			;  =ASN
;		CALL evalLevel1
		LBNE brkTypeMismatch
;		LDA ZP_STRBUFLEN
;		BEQ returnINTminus1
		LDB BAS_StrA
		JUMP retB8asINT

fnINKEY		;  =INKEY
		CALL	callOSByte81withXYfromINT
		CMPX	#$8000				; Check if X<0
		BHS	returnINTminus1
		JUMP	retX16asINT


			;  =EOF#channel - return EndOfFile status - here to be near fnTRUE and fnFALSE
			;  ===========================================================================
fnEOF
		JSR	evalHashChannel		; Evaluate #channel, save TXTPTR, Y=channel
		LEAX	,Y			; X=channel
		LDA	#$7F
		JSR	OSBYTE			; OSBYTE $7F to read EOF
		LDY	ZP_TXTPTR		; Get TXTPTR back
		LEAX	0,X			; Test X
		BEQ	varFALSE		; If &00, return FALSE
						; Otherwise, return TRUE
						;  Otherwise, return TRUE
			;  =TRUE
			;  =====
returnINTminus1					; TODO - possibly use D?

		LDA #$FF			;  Return -1
returnAasINT	STA ZP_INT_WA
		STA ZP_INT_WA + 1		;  Store in INTA
		STA ZP_INT_WA + 2
		STA ZP_INT_WA + 3
returnINT	LDA #$40
		RTS				;  Return Integer
			;  =FALSE
			;  ======
varFALSE			
		LDA #$00
		BRA returnAasINT			;  Jump to return 0


;LABEC:
;		CALL fpCheckMant0SetSignExp0
;		BEQ varFALSE
;		BPL LAC0A
;		BRA returnINTminus1
fnSGN			; LABF5!

			TODO_CMD "fnSGN"
			
;			;  =SGN
;		CALL evalLevel1
		LBEQ brkTypeMismatch
;		BMI LABEC
;		LDA ZP_INT_WA + 3
;		ORA ZP_INT_WA + 2
;		ORA ZP_INT_WA + 1
;		ORA ZP_INT_WA
;		BEQ returnINT
;		LDA ZP_INT_WA + 3
;		BMI returnINTminus1
;LAC0A:
;		LDA #$01
;LAC0C:
		JUMP retB8asINT
fnPOINT			; LAC0E!

			TODO_CMD "fnPOINT"
			
;			;  =POINT
;		CALL evalAtYcheckTypeInAConvert2INT
;		CALL stackINT_WAasINT
;		CALL checkForCommaOrBRK
;		CALL evalL1OpenBracketConvert2INT
;		LDA ZP_INT_WA
;		PHA
;		LDX ZP_INT_WA + 1
;		CALL popIntA
;		STX ZP_INT_WA + 3
;		PLA
;		STA ZP_INT_WA + 2
;		LDY #0				;DP
;		LDX #ZP_INT_WA
;		LDA #$09
;		JSR OSWORD
;		LDA ZP_FPA
;		BMI returnINTminus1
;		BRA LAC0C
fnINSTR

		CALL	evalAtY
		TSTA
		LBNE	brkTypeMismatch
		CMPB	#','
		LBNE	brkMissingComma
		INC	ZP_TXTOFF2
		CALL	StackString
		LEAY	1,Y
		CALL	evalAtY
		TSTA
		LBNE	brkTypeMismatch
		CALL	StackString
		LDA	#$01
		STA	ZP_INT_WA + 3			; Default starting index (rest of INT_WA ignored)
		LEAY	1,Y
;;		INC	ZP_TXTOFF2
		CMPB	#')'
		BEQ	fnINSTR_sk_nop3
		CMPB	#','
		LBNE	brkMissingComma
		CALL	evalL1OpenBracketConvert2INT

fnINSTR_sk_nop3	TST	ZP_INT_WA + 3
		BNE	1F
		INC	ZP_INT_WA + 3			; if 0 make 1
1		DEC	ZP_INT_WA + 3			; now make it 0 based!

		STY	,--S				; save Y we're about to use it for matching
		CLRA
		LDB	,U+				; D now contains length of second string
		STB	ZP_INT_WA
		LEAX	,U				; X now points to start of second string
		LEAU	D,U				; unstack string but leave in place for tests below
		LDB	,U+				; D now contains length of first string
		STB	ZP_INT_WA + 1
		LEAY	,U				; Y points to start of 1st string
		LEAU	D,U				; unstack string but leave in place
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
		LDY	,S++				; get back original Y
		LDA	ZP_INT_WA + 3
		INCA					; make back to 1 based
		JUMP	retA8asINT
fnINSTR_sknom	PULS	X,Y
		LEAY	1,Y
		INC	ZP_INT_WA + 3
		BRA	fnINSTR_lp1

fnINSTR_notfound
		LDY	,S++
		CLRA
		JUMP	retA8asINT


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
;		LDY #$00
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
;		LBRA retA8asINT
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
fnABS

			TODO_CMD "fnABS"
			;  =ABS
;		CALL evalLevel1
;		BEQ JUMPBrkTypeMismatch
;		BMI fpClearWA_A_sign
intWA_ABS	TST	ZP_INT_WA + 0
		BMI	negateIntA
		BRA	A_eq_40_rts
;fpClearWA_A_sign:
;		STZ ZP_FPA
;		RTS
;			;  Negate real
;			;  -----------
fpFPAeqPTR1subFPAnegFPA					; LACC7
		CALL	fpFPAeqPTR1subFPA		; A = PTR1 - A, then negate A == A - PTR1
fpNegateFP_A
		LDA	ZP_FPA + 3
		BEQ	1F				;  Mantissa=0 - zero
		LDA	ZP_FPA
		EORA	#$80
		STA	ZP_FPA			;  Negate sign fp sign
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
		LEAY	-1,Y
1		LDA	,Y+
		STA	,X+
		CMPA	#$0D
		BEQ	LAD10
		CMPA	#','
		BNE	1B
LAD10		LEAY	-1,Y
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
		LDA 	,Y+
		CMPA	#$0D
		LBEQ	brkMissingQuote
		STA	,X+
		CMPA	#'"'
		BNE	evalLevel1StringLiteral_lp
		LDA	,Y+
		CMPA	#'"'
		BEQ	evalLevel1StringLiteral_lp
		LEAY	-1,Y
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
;				LEAY	1,Y		; TODO - not sure whether to inc here or after
		LDA	,Y+				;  Get next character
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
		BEQ	evalL1OpenBracket		;  Jump for (expression
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
		TODODEADEND "NoSuchVar - assembler OPT 2 - skip TXTPTR2?"
;		STX ZP_TXTOFF2			;  Store
GetP_percent	LDD	BASWKSP_PPERCENT
		JUMP	retD16asINT
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
evalL1OpenBracket					; LADAC
		CALL	evalAtY				;  Call Level 7 Expression Evaluator
		LEAY	1,Y
		CMPB	#')'
		BNE	brkMissingEndBracket		;  No terminating ')'
		TSTA
		RTS					;  Return result


evalL1ImmedHex			      ;LADB7
		CALL	varFALSE			; 0 intA
		CLRB
evalL1ImmedHex_lp					; LADBB
		LDA	,Y+				; get digit
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
		LEAY	-1,Y
		LDA	#$40
		RTS

fnADVAL

		CALL	evalLevel1checkTypeStoreAsINT
		PSHS	y
		LDX	ZP_INT_WA + 2					
		LDA	#$80
		JSR	OSBYTE
		PULS	Y
		BRA	retX16asINT

fnTO			; LADF9!

		LDA	,Y+
		CMPA	#'P'
		BNE	brkNoSuchVar
		LDD	ZP_TOP
		BRA retD16asINT
varGetPAGE

;			;  =PAGE
		LDA	ZP_PAGE_H
		CLRB
		BRA	retD16asINT
;JUMPBrkTypeMismatch4:
;		JUMP brkTypeMismatch
fnLEN
;			;  =LEN
		CALL	evalLevel1
		LBNE	brkTypeMismatch
		LDB	ZP_STRBUFLEN
		BRA	retB8asINT


retD16asINT_LE	CLR	ZP_INT_WA + 2		; little endian version!
		CLR	ZP_INT_WA + 3
		EXG	A,B
		STD	ZP_INT_WA + 0
		RTS


retA8asINT	EXG	A,B
retB8asINT	CLRA
retD16asINT	CLR	ZP_INT_WA + 0
		CLR	ZP_INT_WA + 1
		STD	ZP_INT_WA + 2
		LDA	#$40
		RTS
retX16asINT	CLR	ZP_INT_WA + 0
		CLR	ZP_INT_WA + 1
		STX	ZP_INT_WA + 2
		LDA	#$40
		RTS

fnCOUNT

		LDB ZP_PRLINCOUNT
		BRA retB8asINT

varGetLOMEM

		LDD ZP_LOMEM
		BRA retD16asINT
varGetHIMEM

		LDD ZP_HIMEM
		BRA retD16asINT
varERL
			;  =ERL
		LDD	ZP_ERL
		BRA	retD16asINT
varERR
			;  =ERR
		LDB	[zp_mos_error_ptr]
		BRA	retB8asINT
fnGET

			TODO_CMD "fnGET"
			;  =GET
		JSR	OSRDCH
		BRA	retA8asINT
varGetTIME

			;  =TIME
		LDA	,Y	
		CMPA	#'$'
		BEQ	varGetTIME_DOLLAR
		PSHS	Y
		LDX	#ZP_INT_WA
		LDY	#$00				;DP
		LDA	#$01
		JSR	OSWORD
		PULS	Y
		
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
		PULS	PC

varGetTIME_DOLLAR
		LEAY	1,Y
		PSHS	Y
		LDA	#$0E
		LDX	#$00
		LDY	#$06
		CLR	BASWKSP_STRING
		JSR	OSWORD
		LDA	#$18
		PULS	Y
		BRA	staZpStrBufLen
fnGETDOLLAR		; LAE69!

			
;			;  =GET$
		JSR	OSRDCH
returnAAsString						; LAE6C
		STA	BASWKSP_STRING
		LDA	#$01
		BRA	staZpStrBufLen

fnLEFT			; LAE73!
		LDA	#1
		STA	ZP_FP_TMP		; flag we want LEFT$ below
		BRA	1F
fnRIGHT			; LAE74!

		CLR	ZP_FP_TMP		; flag we want RIGHT$
1		CALL	evalAtY
		TSTA
		LBNE	brkTypeMismatch
		CMPB	#','
		LBNE	brkMissingComma
		LEAY	1,Y
		CALL	evalstackStringExpectINTCloseBracket
		CALL	popStackedStringNew
		TST	ZP_FP_TMP
		BEQ	fnRIGHT_do_RIGHT		; DO RIGHT$
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
		PSHS	U
		LDU	#BASWKSP_STRING
		LDX	#BASWKSP_STRING
		ABX
		LDB	ZP_INT_WA + 3
LAEA5
		LDA	,X+
		STA	,U+
		DECB
		BNE	LAEA5
		PULS	U
		BRA retAeq0


fnINKEYDOLLAR		; LAEB3!

			TODO_CMD "fnINKEYDOLLAR"
			
;			;  =INKEY$
;		CALL callOSByte81withXYfromINT
;		TXA
;		CPY #$00
;		BEQ returnAAsString
strRet0LenStr							; LAEBB
		CLRA	
		BRA	staZpStrBufLen
;;;LAEBF:
;;;		JUMP brkTypeMismatch
;;;LAEC2:
;;;		JUMP brkMissingComma
;		
fnMIDstr
		CALL	evalAtY
		TSTA
		LBNE	brkTypeMismatch				; must be a string!
		CMPB	#','
		LBNE	brkMissingComma				; expect ,
		CALL	StackString
		LEAY	1,Y					; skip ,
		CALL	evalAtYcheckTypeInAConvert2INT
		LDA	ZP_INT_WA + 3				; store low byte on stack
		STA	,-S
		LDA	#$FF
		STA	ZP_INT_WA				; default length to 255
		LDB	,Y					; reload this, it may have been eaten converting to INT above
		LEAY	1,Y					; skip next char
		CMPB	#')'
		BEQ	LAEEA					; don't eval length
		CMPB	#','
		LBNE	brkMissingComma
		CALL	evalL1OpenBracketConvert2INT
LAEEA		LDB	,S+					; get back 2nd param (start 1-based index)
		PSHS	Y					; remember Y
		BEQ	LAEF8
		CMPB	,U
		BHI	strRet0LenStrPopYU			; branch if 2nd param > strlen
LAEF8		STB	ZP_INT_WA + 2
		LEAX	,U
		ABX						; X points at start of string to return
		LDB	,U
		SUBB	ZP_INT_WA + 2				; A=orig.len-ix
		INCB
		CMPB	ZP_INT_WA + 3				; compare to 3rd param
		BHS	LAF08					; if >= continue
		STB	ZP_INT_WA + 3				; if < use that as required len
LAF08		LDB	ZP_INT_WA + 3
		BEQ	strRet0LenStrPopYU
		STB	ZP_STRBUFLEN
		CMPX	#BASWKSP_STRING
		BEQ	1F					; pointless copy?
		LDY	#BASWKSP_STRING
LAF0C		LDA	,X+
		STA	,Y+
		DECB
		BNE	LAF0C
1		CLRA
		LDB	,U+					; stack str len
		LEAU	D,U					; discard string and length byte
		PULS	Y,PC
strRet0LenStrPopYU
		CLRA
		LDB	,U+					; stack str len
		LEAU	D,U					; discard string and length byte
		STA	ZP_STRBUFLEN
		PULS	Y,PC
fnSTR			; LAF1C!

		CALL	skipSpacesY
		LDB	#$FF
		CMPA	#'~'
		BEQ	LAF29
		CLRB
		LEAY	-1,Y
LAF29
		PSHS	B
		CALL	evalLevel1
		STA	ZP_VARTYPE
		BEQ	LAF44brkTypeMismatch
		PULS	B
		PSHS	Y
		STB	ZP_PRINTFLAG			; dec/hex flag
		LDA	BASWKSP_INTVAR + 0		; high byte of @%
		BNE	LAF3F
		STA	ZP_GEN_PTR
		CALL	cmdPRINT_num2str_invaldp
		BRA	LAF7AclrArts
LAF3F
		CALL	cmdPRINT_num2str
		BRA	LAF7AclrArts
LAF44brkTypeMismatch
		JUMP brkTypeMismatch
fnSTRING			; LAF47!
			
;			;  =STRING$
		CALL	evalAtYcheckTypeInAConvert2INT
		CALL	stackINT_WAasINT
		CALL	checkForCommaOrBRK
		CALL	evalL1OpenBracket
		BNE	LAF44brkTypeMismatch
		PSHS	Y
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
		LDY	#BASWKSP_STRING
fnStringCopyInnerLoop					; LAF66
		LDA	,Y+
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
		PULS	Y,PC
fnStringRetBlank					; LAF7D
		STA ZP_STRBUFLEN
		PULS	Y,PC
brkNoSuchFN				; LAF83
;;;;		PLA
;;;;		STA ZP_TXTPTR + 1
;;;;		PLA
;;;;		STA ZP_TXTPTR
		LDY	1,S		; get back stacked Y pointer (from callproc)
		STY	ZP_TXTPTR	; point back at caller so that ERL is reported correctly
		DO_BRK_B
		FCB	$1D,"No such ", tknFN, "/", tknPROC,0

	*****************************************************************
	*	Search Program For DEF PROC/FN				*
	*	On entry						*
	*		ZP_GEN_PTR + 1 = tknFN or tknPROC		*
	*		ZP_GEN_PTR + 2 = proc name			*
	*		ZP_NAMELENORVT is proc name length + 2		*
	*	Trashes	A,B,X,Y						*
	*****************************************************************


progFindDEFPROC						; LAF97
		LDA ZP_PAGE_H
		CLRB
		TFR	D,X
progFndDEF_linLp					; LAF9D
		TST	1,X
		BMI	brkNoSuchFN			; check for end of program
		LEAY	4,X				; point Y after 0D and line number
1							; LAFA5
		LDA	,Y+
		CMPA	#' '				; skip spaces
		BEQ	1B
		CMPA	#tknDEF
		BEQ	progFndDEF_skDefFnd
		BRA	progFndDEF_skNxtLin
progFndDEF_skNxtLinPULSU
		PULS	U
progFndDEF_skNxtLin					; LAFB0
		LDB	3,X				; line length add to X
		ABX
		BRA	progFndDEF_linLp
progFndDEF_skDefFnd					; LAFBF

		; skip spaces
1		LDA	,Y+
		CMPA	#' '
		BEQ	1B
		LEAY	-1,Y

		PSHS	U
		LDU	ZP_GEN_PTR
		LEAU	1,U				; point at FN/PROC token, Y already points at one hopefully
		LDB	#1
		STY	ZP_TXTPTR
1		LDA	,Y+
		CMPA	,U+
		BNE	progFndDEF_skNxtLinPULSU	; compare caller / DEF token and name
		INCB
		CMPB	ZP_NAMELENORVT
		BNE	1B
		LDA	,Y				; get next char
		CALL	checkIsValidVariableNameChar	; if it looks like a variable name char
		BCS	progFndDEF_skNxtLinPULSU	; then the DEF is for a longer name, keep searching
		PULS	U

		; Y now points at parameters or whatever after DEFFNname
		; ZP_TXTPTR starts at FN/PROC token
		; X points at start of DEFFN line 


;;;		INY
;;;		STY ZP_TXTOFF
		CALL	skipSpacesY
		LEAY	-1,Y				; now point at start of params or CR
		STY	ZP_TXTPTR
;;;		TYA
;;;		TAX
;;;		CLC
;;;		ADC ZP_TXTPTR
;;;		LDY ZP_TXTPTR + 1
;;;		BCC LAFD0
;;;		INY
;;;		CLC
;;;LAFD0:
;;;		SBC #$00
;;;		STA ZP_FPB + 1
;;;		TYA
;;;		SBC #$00
;;;		STA ZP_FPB + 2
;;;		LDY #$01
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
;;;		LDY #$01
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
		LEAX	D,U				
		CALL	UpdStackFromXCheckFull		;  Store new BASIC stack pointer, checking for free space
		LEAX	,U
		STS	,X++				; Store current machine stack pointer
1		CMPS	#MACH_STACK_TOP			; Copy machine stack contents to BASIC stack
		BHS	2F				; TODO: use 16bit copy? Require test on first/last loop for single byte tfr
		LDA	,S+
		STA	,X+
		BRA	1B
2		; S now points at top of stack X points at OLD U value
		; stack active variables on machine stack
		; note this is different to 6502!
		LDA	ZP_VARTYPE
		PSHS	A,Y				; store PROC/FN token on the stack
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
;;;		LDY ZP_TXTPTR2 + 1
;;;		BCC LB04C
;;;		INY
;;;		CLC
;;;;LB04C:
		LEAY	-2,Y				; step back scan pointer
		STY	ZP_GEN_PTR			; ZP_GEN_PTR points at one before FN/PROC token
		LDB	#$02
*		LEAY	1,Y
		CALL	fnProcScanZP_GEN_PTRplusBvarname; Check name is valid
		CMPB	#2
		BEQ	brkBadCall			; No valid characters
		LEAX	-1,X				; point ZP_TXTPTR2 at char after name
		STX	ZP_TXTPTR2
		CALL	findFNPROC			; note: this also saves length in ZP_NAMELENORVT
							; Look for PROC/FN in heap
		LBEQ	progFindDEFPROC			; Not in heap, jump to look in program
							; LB068
		LDY	[ZP_INT_WA + 2]
LB072
		CLR	,-S				; Store a 0 on the stack to mark 0 params
;		STZ ZP_TXTOFF
		CALL	skipSpacesY
		CMPA	#'('
		BEQ	doFNPROCargumentsEntry
		LEAY	-1,Y
LB080
		LDX	ZP_TXTPTR2
		PSHS	X
		CALL	skipSpacesAtYexecImmed		; execute PROC/FN body
		PULS	X
		STX	ZP_TXTPTR2
		STX	ZP_TXTPTR
		LDA	,S+				; get back params flag
		BEQ	LB0A4
		STA	ZP_FPB + 4			; get number of "params" (and locals) to reset
LB09A
		CALL	popIntAtZP_GEN_PTRNew		; get back variable pointer etc
		CALL	delocaliseAtZP_GEN_PTR
		DEC	ZP_FPB + 4
		BNE	LB09A
LB0A4
;;;		PULS	A,Y
;;;		LEAY	-1,Y
;;;		LEAS	3,S			; discard stacked 

;		
;		stz	$fef0			; TODO - TUBE ????


		LDS	,U++			; get old machine stack pointer from
						; BASIC stack
		LEAX	,S
1		CMPX	#MACH_STACK_TOP		; copy bytes from BASIC stack to machine stack
		BHS	2F
		LDA	,U+
		STA	,X+
		BRA	1B
2
		LDY	ZP_TXTPTR
		LDA	ZP_VARTYPE		; from FN =
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
		LDA	,S+				; bet back "params flag"
		LDX	ZP_INT_WA + 2
		LDB	ZP_INT_WA
		INCA
		PSHS	D,X				; push back incremented var ptr, var type, params flag
		CALL	localVarAtIntA			; push the variable value and pointer onto the BASIC stack
		CALL	SkipSpaceCheckCommaAtY		; try and get another parameter
		BEQ	doFNPROCargumentsEntry
		CMPA	#')'
		BNE	doBrkArguments			; check for closing bracket
		STY	ZP_EXTRA_SAVE_PROC		; TODO, stack this or get from somewhere else?
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
		CALL	checkForComma
		BEQ	LB108
		CMPA	#')'
		BNE	doBrkArguments
		STY	ZP_TXTPTR2
		PULS	A,B				; get back two arguments counters
		STB	ZP_FP_TMP + 9
		STB	ZP_FP_TMP + 10
		CMPA	ZP_FP_TMP + 9			; check they're the same
		BEQ	LB140				; if so continue
doBrkArguments
		LDS	#MACH_STACK_TOP - 2
		LDY	,Y++
		STY	ZP_TXTPTR
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
		STX	ZP_GEN_PTR			; stick var pointer at ZP_GEN_PTR
		LDA	ZP_VARTYPE
		BPL	LB165
		CALL	popFPFromStackToPTR1
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
		STA	,-S
		LDY	ZP_EXTRA_SAVE_PROC
		JUMP	LB080


localVarAtIntA						; LB181
		LDB	ZP_INT_WA + 0			; get variable type
		CMPB	#VAR_TYPE_REAL
		PSHS	CC
		BHS	1F				; for not int
		LDX	#ZP_GEN_PTR
		CALL	CopyIntA2ZPX			; copy pointer to ZP_GEN_PTR, GetVarVal will overwrite it!
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
		LDX	ZP_INT_WA + 2			; &02=Little-endian integer, TODO: check speed / size trade off with swapendian defined elsewhere if short of space
		LDD	,X++
		EXG	A,B
		STD	ZP_INT_WA + 2
		LDD	,X++
		EXG	A,B
		STD	ZP_INT_WA + 0
		LDA	#VAR_TYPE_INT
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
		JUMP	retB8asINT

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



GetVarValStr	PSHS	Y		; LB1F7
		CMPA	#$80		; check type of string
		BEQ	GetVarValStr_Ind
		LDY	ZP_INT_WA + 2	; get address of param block
		LDA	3,Y		; get string len
		STA	ZP_STRBUFLEN
		BEQ	1F
		LDY	,Y		; get address of actual string
		LDX	#BASWKSP_STRING
2					; LB20F:
		LDB	,Y+
		STB	,X+
		DECA
		BNE	2B
1					;LB218:
		CLRA			; indicate string returned
		PULS	Y,PC

		; read string from memory
GetVarValStr_Ind					; LB219
		LDA	ZP_INT_WA + 2			; if MSB of string addr is 0 treat as a single char!
		BEQ	GetVarValStr_SingleCharAtINTWA3
		CLRB
		LDX	ZP_INT_WA + 2
		LDY	#BASWKSP_STRING
1							; LB21F
		LDA	,X+
		STA	,Y+
		EORA	#$0D				; eor here ensures 0 A on exit
		BEQ	2F
		INCB
		BNE	1B
		CLRA
2							; LB22C:
		STB	ZP_STRBUFLEN
		CLRA			; indicate string returned
		PULS	Y,PC


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
		STX	zp_mos_error_ptr		; TODO: move this into BASIC's DP? Document
		LDB	#$FF
		STB	ZP_OPT
		RESET_MACH_STACK
		STX	,--S
		LDX	#0
		LDY	#$00
		LDA	#$DA
		JSR	OSBYTE				; clear VDU queue
		LDA	#$7E
		JSR	OSBYTE				; Acknowledge any Escape state
		CALL	HandleBRKFindERL
		CLR	ZP_TRACE
;;		LDA	[zp_mos_error_ptr]
		LDA	[,S++]
		BNE 	HandleBRKsk1
		CALL	ONERROROFF
HandleBRKsk1						; LB296
		LDY	ZP_ERR_VECT
		STY	ZP_TXTPTR
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
		CALL	evalForceINT
		LDA	#OSWORD_SOUND
		STA	,-S				; store OSWORD # on stack
		LDB	#$04				; read 4 params
LB2CD		LDX	ZP_INT_WA + 2			; store 16 bit number on stack - reversing bytes
		STX	,--S
		DECB
		BEQ	1F
		STB	,-S
		CALL	checkCommaThenEvalAtYcheckTypeInAConvert2INT
		LDB	,S+
		BRA	LB2CD
1		CALL	LDYZP_TXTPTR2scanNextStmtFromY
		LDB	#$07				; # bytes to restore minus 1
		BRA	sndPullBthenAtoZP_SAVE_BUF_OSWORD_A
cmdENVELOPE			; LB2EC!
		CALL	evalForceINT
		LDA	#OSWORD_ENVELOPE
		STA	,-S				; store OSWORD #
		LDB	#14				; read 14 params
LB2F1		LDA	ZP_INT_WA + 3			; get low byte of int
		STA	,-S
		DECB
		BEQ	1F
		STB	,-S
		CALL	checkCommaThenEvalAtYcheckTypeInAConvert2INT
		LDB	,S+
		BRA	LB2F1
1		CALL	LDYZP_TXTPTR2scanNextStmtFromY
		LDB	#13
sndPullBthenAtoZP_SAVE_BUF_OSWORD_A				; LB307
		LDX	#ZP_SAVE_BUF
1		LDA	,S+
		STA	B,X
		DECB
		BPL	1B
		LDA	,S+				; get back OSWORD #
OSWORD_continue
		PSHS	Y
		JSR	OSWORD
		PULS	Y
		LBRA	continue			; Call OSWORD, return to execution loop



cmdWIDTH

			TODO_CMD "cmdWIDTH"
			
;			;  WIDTH
;		CALL evalForceINT
;		CALL LDYZP_TXTPTR2scanNextStmtFromY
;		LDY ZP_INT_WA
;		DEY
;		STY ZP_WIDTH
;LB322:
;		JUMP continue
;LB325:
;		JUMP brkTypeMismatch
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
		STX	ZP_GEN_PTR
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
		LDX	ZP_GEN_PTR
		LDD	ZP_INT_WA
		STD	0,X
		LDD	ZP_INT_WA + 2
		STD	2,X
		RTS
storeInt2						; Store little-endian word
		LDX	ZP_GEN_PTR
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
		STA	[ZP_GEN_PTR]
		RTS
storeEvaledExpressioninRealVarAtZP_GEN_PTR		; LB360
		LDA	ZP_VARTYPE
		LBEQ	brkTypeMismatch
		BMI	skIntToReal1
		CALL	IntToReal
skIntToReal1						; LB369
		LDX	ZP_GEN_PTR
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
;			;  EDIT
;			;  ====
strEdit12_2				;LB389:
		FCB	"EDIT 12,2", $0d

cmdEDIT			
		CALL	ResetVars
		LDA	#$80
		STA	ZP_LISTO

doLIST
		LEAY	-1,Y
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
		CALL	SkipSpaceCheckCommaAtY		; look for a comma, 
		BEQ	doListSkLineSpec2
		; no second spec, pop first speccd line and use as 2nd param
		CALL	popIntANew		      ; unstack then stack - TODO: check if can load using off,U
		CALL	stackINT_WAasINT
		LEAY	-1,Y
		BRA	doListSkStart
doListSkNoLineSpec				      ;LB3BF:
		CALL	SkipSpaceCheckCommaAtY
		BEQ	doListSkLineSpec2	      ; no first param but there was a second
		LEAY	-1, Y
doListSkLineSpec2				      ;LB3C6:
		CALL	skipSpacesDecodeLineNumberNewAPI
doListSkStart					      ;LB3C9:
		LDX	#ZP_FPA + 3
		CALL	CopyIntA2ZPX
		CALL	skipSpacesPTRA
		CMPA	#tknIF
		BNE	doListSkStart2
		CALL	skipSpacesPTRA
		STY	ZP_TXTPTR
		BRA	doListSkStart3
cmdLIST

			
;			;  LIST
		LDA ,Y+

		CMPA	#'O'
		BNE	doLIST
		CALL	evalForceINT
		CALL	scanNextStmtFromY
		LDA	ZP_INT_WA + 3
		STA	ZP_LISTO
		JUMP	immedPrompt


doListSkStart2						; LB3F3:
		CALL	scanNextExpectColonElseCR
doListSkStart3						; LB3F6:
		STY	ZP_TXTPTR2
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
		LDX	1,Y				 ; get the actual line number found
		STX	ZP_INT_WA + 2
doListSkGotCorrectLine					;LB428:
		LDX	ZP_INT_WA + 2
		CMPX	ZP_FPA + 5	
		BLS	doListStartLine
		TST	ZP_LISTO
		LBPL	immedPrompt
		LEAX	strEdit12_2,PCR
		JMP	OSCLI
doListStartLine						; LB43E:
		CLR	ZP_FP_TMP + 9			; flag Quote/REM open
		CLR	ZP_FP_TMP + 10			; flag ??
		LEAY	4,Y				; point at first char/token of actual line 
		STY	ZP_TXTPTR			; store pointer for later after scan
		TST	ZP_FPB
		BPL	doListSk0
		CLR	ZP_FPB
doListSk0						;LB44E:
		TST	ZP_FPB + 1
		BPL	doListSk1
		CLR	ZP_FPB + 1
doListSk1						;LB454:
		LDA	,Y				;  Get character
		CMPA	#$0D
		BEQ	doListBlankLine			;  End of line
		CMPA	#tknREM
		BEQ	doListSkREM			; ignore quotes in REMs
		CMPA	#'"'
		BNE	doListSkREMQuot
		EORA	ZP_FP_TMP + 9			;  Toggle quote flag
doListSkREM						;LB464:
		STA	ZP_FP_TMP + 9			; if a REM store tknREM, if a Quote toggle
doListSkREMQuot						; LB466
		TST	ZP_FP_TMP + 9
		BNE	doListSkUntil				;  Within quotes / REM
		CMPA	#tknNEXT
		BNE	doListSkNext
		DEC	ZP_FPB			; decrement NEXT indent level
doListSkNext						; LB470
		CMPA	#tknUNTIL
		BNE	doListSkUntil
		DEC	ZP_FPB + 1			; decrement UNTIL indent level
doListSkUntil						; LB476
		LDX	ZP_TXTPTR2			; TODO not sure what this is doing or why 
doListLp_Uk1						; LB478
		LDA	,X
		CMPA	#$0D
		BEQ	doListSk_Uk1
		CMPA	,Y
		BNE	doListSk_Uk2
		LEAY	1,Y
		LEAY	1,X
		BRA	doListLp_Uk1

doListSk_Uk1						; LB489:
		STA	ZP_FP_TMP + 10
doListSk_Uk2						; LB48B:
		LEAY	1,Y
		BRA	doListSk1
doListBlankLine						;LB491:
		LDA	ZP_FP_TMP + 10
		BEQ	doListLoop
		CALL	int16print_fmt5			; print line number
		LDA	#$01
		INCB					; set to 0
		ORCC	#CC_C
		CALL	doLISTOSpaces			; LISTO1 - space after Line no
		LDB	ZP_FPB
		LDA	#$02
		CALL	doLISTOSpacesCLC		; LISTO2 - NEXT indents
		LDX	ZP_FPB + 1
		LDA	#$04				; LISTO4 - REPEAT/UNTIL indents
		CALL	doLISTOSpacesCLC
		CLR	ZP_FP_TMP + 9
doListNextTok2						;LB4AF:
		LDY	ZP_TXTPTR			; TODO reset Y pointer here?
doListNextTok						; LB4B1:
		LDA	,Y
		CMPA	#$0D
		LBEQ	doListPrintLFThenLoop
		CMPA	#'"'
		BNE	doListSkNotQuot2
		EORA	ZP_FP_TMP + 9
		STA	ZP_FP_TMP + 9			; Toggle quote flag
		LDA	#'"'
doListQuoteLp2						; LB4C1
		CALL	list_printA
		LEAY	1,Y
		BRA	doListNextTok
doListSkNotQuot2					; LB4C7:
		TST	ZP_FP_TMP + 9
		BNE	doListQuoteLp2
		CMPA	#tknLineNo
		BNE	doList_sknotLineNo
		LEAY	1,Y
		CALL	decodeLineNumber
							;		STY ZP_TXTOFF - don't think this is needed any longer
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
		LEAY	1,Y
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
		PSHS	Y				; use Y as gen ptr, remember to pop before BRKs
		LDB	ZP_FOR_LVL_X_15
		LDX	#BASWKSP_FORSTACK-FORSTACK_ITEM_SIZE
		ABX	
		LEAY	,X				; Y points at last item on FOR stack
		BEQ	brkNoFOR
cmdNEXTstacklp						; LB505
		LDX	ZP_INT_WA + 2			; search FOR stack for a loop with matching variable pointer and type
		CMPX	FORSTACK_OFFS_VARPTR,Y
		BNE 	cmdNEXTstacklpsk1
		LDA	ZP_INT_WA + 0
		CMPA	FORSTACK_OFFS_VARTYPE,Y
		BNE	cmdNEXTstacklpsk1
		BRA	cmdNEXTfoundLoopVar		
cmdNEXTstacklpsk1					; LB51A
		LEAY	-FORSTACK_ITEM_SIZE,Y
		SUBB	#FORSTACK_ITEM_SIZE
		STB	ZP_FOR_LVL_X_15
		BNE	cmdNEXTstacklp
		PULS	Y
		DO_BRK_B
		FCB	$21, "Can't match ", tknFOR, 0
brkNoFOR
		PULS	Y
		DO_BRK_B
		FCB	$20, "No ", tknFOR, 0
cmdNEXTTopLoopVar					; LB539
		LEAY	-1,Y				; if no var found go back a char : TODO - check whether we can change API
		PSHS	Y				; use Y as gen ptr, remember to pop before BRKs
		LDY	#BASWKSP_FORSTACK - FORSTACK_ITEM_SIZE
		LEAY	B,Y
		LDX	FORSTACK_OFFS_VARPTR,Y
		LDA	FORSTACK_OFFS_VARTYPE,Y
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
		ADDD	(2+FORSTACK_OFFS_STEP),Y
		STD	2,X
		LDD	,X
		ADCB	(1+FORSTACK_OFFS_STEP),Y
		ADCA	(0+FORSTACK_OFFS_STEP),Y
		STD	0,X

		LDD	2,X				;6
		SUBD	(2+FORSTACK_OFFS_TO),Y		;7
		BNE	cmdNEXTnoZ			;3
		LDD	0,X				;5
		SBCB	(1+FORSTACK_OFFS_TO),Y		;5
		SBCA	(0+FORSTACK_OFFS_TO),Y		;5
		BNE	cmdNEXTnoZ2			;3
		TSTB					;2
		BNE	cmdNEXTnoZ2			;3
;							;=39
		BRA	cmdNEXTexecLoop			;3
cmdNEXTnoZ
		LDD	0,X				;5
		SBCB	(1+FORSTACK_OFFS_TO),Y		;5
		SBCA	(0+FORSTACK_OFFS_TO),Y		;5
							;=31
cmdNEXTnoZ2
		LDA	0,X
		EORA	(0+FORSTACK_OFFS_TO),Y
		EORA	(0+FORSTACK_OFFS_STEP),Y
		BPL	cmdNEXTcksign2
		BCC	cmdNEXTexecLoop
		BRA	cmdNEXTloopFinished
cmdNEXTcksign2						; LB59C
		BCC	cmdNEXTloopFinished
cmdNEXTexecLoop						; LB59E
		LEAS	2,S				; don't pull Y we don't want it
		LDY	FORSTACK_OFFS_LOOP,Y
		STY	ZP_TXTPTR
		CALL	checkForESC
		JUMP 	skipSpacesAtYexecImmed

cmdNEXTdoINT_LE						; TODO: see about shortening / sharing this!
		; 32 bit add of integer control VAR, also store at ZP_GEN_PTR (bigendian)
		LDD	0,X
		ADDA	(3+FORSTACK_OFFS_STEP),Y
		ADCB	(2+FORSTACK_OFFS_STEP),Y
		STD	0,X
		LDD	2,X
		ADCA	(1+FORSTACK_OFFS_STEP),Y
		ADCB	(0+FORSTACK_OFFS_STEP),Y
		STD	2,X

		LDD	0,X				;6
		SUBA	(3+FORSTACK_OFFS_TO),Y		;7
		SBCB	(2+FORSTACK_OFFS_TO),Y		;7
		BNE	cmdNEXTnoZLE			;3
		TSTA
		BNE	cmdNEXTnoZLE			;3
		LDD	2,X				;5
		SBCA	(1+FORSTACK_OFFS_TO),Y		;5
		SBCB	(0+FORSTACK_OFFS_TO),Y		;5
		BNE	cmdNEXTnoZ2LE			;3
		TSTA					;2
		BNE	cmdNEXTnoZ2LE			;3
;							;=39
		BRA	cmdNEXTexecLoop			;3
cmdNEXTnoZLE
		LDD	2,X				;5
		SBCA	(1+FORSTACK_OFFS_TO),Y		;5
		SBCB	(0+FORSTACK_OFFS_TO),Y		;5
							;=31
cmdNEXTnoZ2LE
		LDA	3,X
		EORA	(0+FORSTACK_OFFS_TO),Y
		EORA	(0+FORSTACK_OFFS_STEP),Y
		BPL	cmdNEXTcksign2
		BCC	cmdNEXTexecLoop
		BRA	cmdNEXTloopFinished

cmdNEXTloopFinished					; LB5AE
		LDB	ZP_FOR_LVL_X_15
		SUBB	#FORSTACK_ITEM_SIZE
		STB	ZP_FOR_LVL_X_15
		PULS	Y
		CALL	SkipSpaceCheckCommaAtY
		LBNE	decYGoScanNextContinue
		JUMP	cmdNEXT				; found a comma, do another round of NEXTing

cmdNEXTdoREAL						; LB5C0
		CALL	GetVarValReal			; get current variable value
		LEAX	FORSTACK_OFFS_STEP,Y		; get STEP value
		STX	ZP_FP_TMP_PTR1
		CALL	fpFPAeqPTR1addFPA		; TODO jump straight in with X?

		LDX	ZP_INT_WA + 2			; Get variable pointer
		CALL	fpCopyFPAtoX			; store result of STEP add

		LEAX	FORSTACK_OFFS_TO,Y		; Get pointer to TO value
		STX	ZP_FP_TMP_PTR1
		CALL	evalDoCompareRealFPAwithPTR1	; TODO: use X direct
		BEQ	cmdNEXTexecLoop
		TST	FORSTACK_OFFS_STEP + 1,Y	; if STEP -ve
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
		LDD	ZP_GEN_PTR			; addr of control var
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
		CALL	retA8asINT			; default STEP to 1
		CALL	skipSpacesY		
		CMPA	#tknSTEP
		BNE	cmdFORskINTnoSTEP
		PSHS	X
		CALL	evalAtYcheckTypeInAConvert2INT
		PULS	X
		LEAY	1,Y				; TODO - sort this back and forth out?
cmdFORskINTnoSTEP					; LB677
		LEAY	-1,Y
		LDD	ZP_INT_WA			; store INT STEP val at + 5
		STD	FORSTACK_OFFS_STEP,X
		LDD	ZP_INT_WA + 2
		STD	FORSTACK_OFFS_STEP + 2,X
cmdFORskipExecBody					; LB68F
		CALL	scanNextStmtAndTrace
		LDB	ZP_FOR_LVL_X_15
		LDX	#BASWKSP_FORSTACK + FORSTACK_OFFS_LOOP - FORSTACK_ITEM_SIZE
		STY	B,X				; store Y pointer to body statement in FOR stack (2 before next pointer!)
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
		LEAY	1,Y
cmdFORrealNoStep					; LB6C7
		LEAY	-1,Y
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
LB6DC		CALL	scanNextStmtFromY
		LDB	ZP_GOSUB_LVL			; Get GOSUB index
		CMPB	#GOSUBSTACK_MAX			; Check whether stack is full
		BHS	brkTooManyGosubs
		LDX	#BASWKSP_GOSUBSTACK
		ASLB
		ABX
		STY	,X				; store text pointer on stack
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
		LDY	,X
LB71A		JUMP	continue

			;============================
			; GOTO
			;============================
cmdGOTO							; LB71D!

		CALL	decodeLineNumberFindProgLine
		;;LDY	ZP_TXTPTR
		CALL	scanNextStmtFromY
cmdGOTODecodedLineNumber				; LB723
		LDA	ZP_TRACE
		BEQ	cmdGOTOskTrace
		CALL	doTRACE
cmdGOTOskTrace						; LB72A
		LDY	ZP_FPB + 2
		LEAY	4,Y
STYZPTXTPTR_continue					; LB732
		STY	ZP_TXTPTR
		JUMP	skipSpacesAtYexecImmed

;LB739:
;		CALL scanNextStmt
;		CALL ONERROROFF
;		BRA LB71A
;LB741:
;		CALL skipSpacesPTRA
;		CMP #tknOFF
;		BEQ LB739
;		LDY ZP_TXTOFF
;		DEY
;		CALL storeYasTXTPTR
;		STZ ZP_TXTOFF
;		LDA ZP_TXTPTR
;		STA ZP_ERR_VECT
;		LDA ZP_TXTPTR + 1
;		STA ZP_ERR_VECT + 1
;		JUMP cmdREM	;
;			;  ON [ERROR][GOTO][GOSUB]
;			;  =======================
cmdON			; LB75B!

			TODO_CMD "cmdON"
			
;		CALL skipSpacesPTRA
;		CMP #tknERROR
;		BEQ LB741
;			;  ON ERROR
;		DEC ZP_TXTOFF
;		CALL evalForceINT
;			;  Evaluate ON <num>
;		CPX #tknPROC
;		BEQ LB774
;			;  ON <num> PROC
;		INY
;		CPX #$E5
;		BEQ LB774
;			;  ON <num> GOTO
;		CPX #$E4
;		BNE brkONSyntax
;			;  ON <num> GOSUB
;LB774:
;		PHX
;			;  Save token
;		LDA ZP_INT_WA + 1
;		ORA ZP_INT_WA + 2
;		ORA ZP_INT_WA + 3
;		BNE LB7D5
;		DEC ZP_INT_WA
;		BEQ LB7B6
;		BMI LB7D5
;LB783:
;		LDA (ZP_TXTPTR),Y
;		CMP #$0D
;		BEQ LB7D5
;		CMP #$3A
;		BEQ LB7D5
;		CMP #tknELSE
;		BEQ LB7D5
;		INY
;		CMP #$22
;		BNE LB79A
;		EOR ZP_INT_WA + 1
;		STA ZP_INT_WA + 1
;LB79A:
;		LDX ZP_INT_WA + 1
;		BNE LB783
;		CMP #')'
;		BNE LB7A4
;		DEC ZP_INT_WA + 2
;LB7A4:
;		CMP #'('
;		BNE LB7AA
;		INC ZP_INT_WA + 2
;LB7AA:
;		CMP #$2C
;		BNE LB783
;		LDX ZP_INT_WA + 2
;		BNE LB783
;		DEC ZP_INT_WA
;		BNE LB783
;LB7B6:
;		PLA
;		CMP #$F2
;		BEQ LB803
;		STY ZP_TXTOFF
;		CMP #$E4
;		BEQ LB7CA
;		CALL decodeLineNumberFindProgLine
;		CALL setTXTOFFeq1CheckESC
;		JUMP cmdGOTODecodedLineNumber
;LB7CA:
;		CALL decodeLineNumberFindProgLine
;		LDY ZP_TXTOFF
;		CALL LB81D
;		JUMP LB6DC
;LB7D5:
;		PLA
;LB7D6:
;		LDA (ZP_TXTPTR),Y
;		INY
;		CMP #tknELSE
;		BEQ LB817
;		CMP #$0D
;		BNE LB7D6
		DO_BRK_B
		FCB	$28, tknON, " range", 0
brkONSyntax
		DO_BRK_B
		FCB	$27, tknON, " syntax", 0
brkNoSuchLine
		DO_BRK_B
		FCB	$29, "No such line", 0
;LB803:
;		STY ZP_TXTOFF2
;		CALL skipSpacesPTRB
;		CMP #$F2
;		BNE brkONSyntax
;		CALL doFNPROCcall
;		LDY ZP_TXTOFF2
;		CALL LB81D
;		JUMP scanNextContinue
;LB817:
;		STY ZP_TXTOFF
;		JUMP skCmdIfExecImplicitGotoOrTokens
;LB81C:
;		INY
;LB81D:
;		LDA (ZP_TXTPTR),Y
;		CMP #$0D
;		BEQ LB827
;		CMP #$3A
;		BNE LB81C
;LB827:
;		STY ZP_TXTOFF
;		RTS
;		
decodeLineNumberFindProgLine
		CALL	skipSpacesDecodeLineNumberNewAPI
		BCS	findProgLineOrBRK			; tokenised line number found
		CALL	evalForceINT
		LDA	#$7F					; clear top bit of line number
		ANDA	ZP_INT_WA + 2
		STA	ZP_INT_WA + 2
findProgLineOrBRK
		PSHS	Y
		CALL	findProgLineNewAPI
		BCC	brkNoSuchLine
		PULS	Y,PC
;LB83C:
;		JUMP brkTypeMismatch
;LB83F:
;		JUMP brkSyntax
;LB842:
;		STY ZP_TXTOFF
;LB844:
;		JUMP scanNextContinue
;LB847:
;		CALL LBA3C
;		STY ZP_FP_TMP + 9
;		CALL copyTXTOFF2toTXTOFF
;LB84F:
;		CALL SkipSpaceCheckComma
;		BNE LB842
;		LDA ZP_FP_TMP + 9
;		PHA
;		CALL findVarOrAllocEmpty
;		BEQ LB83F
;		CALL copyTXTOFF2toTXTOFF
;		PLA
;		STA ZP_FP_TMP + 9
;		PHP
;		CALL stackINT_WAasINT
;		LDY ZP_FP_TMP + 9
;		JSR OSBGET
;		STA ZP_VARTYPE
;		PLP
;		BCC LB88A
;		LDA ZP_VARTYPE
;		BNE LB83C
;		JSR OSBGET
;		STA ZP_STRBUFLEN
;		TAX
;		BEQ LB885
;LB87C:
;		JSR OSBGET
;		STA $05FF,X
;		DEX
;		BNE LB87C
;LB885:
;		CALL copyStringToVar
;		BRA LB84F
;LB88A:
;		LDA ZP_VARTYPE
;		BEQ LB83C
;		BMI LB89C
;		LDX #$03
;LB892:
;		JSR OSBGET
;		STA ZP_INT_WA,X
;		DEX
;		BPL LB892
;		BRA LB8AA
;LB89C:
;		LDX #$04
;LB89E:
;		JSR OSBGET
;		STA $046C,X
;		DEX
;		BPL LB89E
;		CALL fpCopyFPTEMP1toFPA
;LB8AA:
;		CALL popIntAtZP_GEN_PTR
;		CALL storeEvaledExpressioninVarAtZP_GEN_PTR
;		BRA LB84F
;LB8B2:
;		PLA
;		PLA
;		BRA LB844
cmdINPUT			; LB8B6!

			TODO_CMD "cmdINPUT"
			
;			;  INPUT
;		CALL SkipSpaceCheckHash
;		BEQ LB847
;		CMP #$86
;		BEQ LB8C2
;		DEC ZP_TXTOFF
;		CLC
;LB8C2:
;		ROR ZP_FP_TMP + 9
;		LSR ZP_FP_TMP + 9
;		LDA #$FF
;		STA ZP_FP_TMP + 10
;LB8CA:
;		CALL L9299
;		BCS LB8D9
;LB8CF:
;		CALL L9299
;		BCC LB8CF
;		LDX #$FF
;		STX ZP_FP_TMP + 10
;		CLC
;LB8D9:
;		PHP
;		ASL ZP_FP_TMP + 9
;		PLP
;		ROR ZP_FP_TMP + 9
;		CMP #$2C
;		BEQ LB8CA
;		CMP #$3B
;		BEQ LB8CA
;		DEC ZP_TXTOFF
;		LDA ZP_FP_TMP + 9
;		PHA
;		LDA ZP_FP_TMP + 10
;		PHA
;		CALL findVarOrAllocEmpty
;		BEQ LB8B2
;		PLA
;		STA ZP_FP_TMP + 10
;		PLA
;		STA ZP_FP_TMP + 9
;		CALL copyTXTOFF2toTXTOFF
;		PHP
;		BIT ZP_FP_TMP + 9
;		BVS LB908
;		LDA ZP_FP_TMP + 10
;		CMP #$FF
;		BNE LB91F
;LB908:
;		BIT ZP_FP_TMP + 9
;		BPL LB911
;		LDA #$3F
;		JSR OSWRCH
;LB911:
;		CALL LBA70
;		STY ZP_STRBUFLEN
;		ASL ZP_FP_TMP + 9
;		CLC
;		ROR ZP_FP_TMP + 9
;		BIT ZP_FP_TMP + 9
;		BVS LB938
;LB91F:
;		STA ZP_TXTOFF2
;		STZ ZP_TXTPTR2
;		LDA #$06
;		STA ZP_TXTPTR2 + 1
;		CALL readCommaSepString
;LB92A:
;		CALL checkForComma
;		BEQ LB935
;		CMP #$0D
;		BNE LB92A
;		LDY #$FE
;LB935:
;		INY
;		STY ZP_FP_TMP + 10
;LB938:
;		PLP
;		BCS LB946
;		CALL pushVarPtrAndType
;		CALL str2Num
;		CALL storeEvaledExpressioninStackedVarPTr
;LB944:
;		BRA LB8CA
;LB946:
;		STZ ZP_VARTYPE
;		CALL copyStringToVar2
;		BRA LB944
cmdRESTORE
		CLR	ZP_FPB + 3
		LDA	ZP_PAGE_H
		STA	ZP_FPB + 2			; FPB+2=>start of program
		CALL	skipSpacesY
		LEAY	-1,Y
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
		CALL	SkipSpaceCheckCommaAtY		; look for comma
		LBNE	decYGoScanNextContinue		; if not found continue
							; or fall through for next READ var
cmdREAD
		CALL	findVarOrAllocEmpty
		BEQ	cmdREAD_next			; bad var name, skip
		BCS	cmdREAD_readString		; string ?
		STY	,--S
		CALL	cmdREAD_findNextDataItem
		CALL	pushVarPtrAndType
		CALL	evalAtYAndStoreEvaledExpressioninStackedVarPTr
		BRA	LB99D
cmdREAD_readString
		STY	,--S
		CALL	cmdREAD_findNextDataItem
		CALL	stackINT_WAasINT
		CALL	readCommaSepString
		STA	ZP_VARTYPE
		CALL	copyStringToVar
LB99D
		STY	ZP_READ_PTR
		LDY	,S++
		BRA	cmdREAD_next

cmdREAD_findNextDataItem
		LDY	ZP_READ_PTR
		CALL	checkForComma
		BEQ	cmdREAD_dataItemFound
		CMPA	#tknDATA
		BEQ	cmdREAD_dataItemFound
		CMPA	#$0D
		BEQ	cmdREAD_CR
LB9C6
		CALL	checkForComma
		BEQ	cmdREAD_dataItemFound
		CMPA	#$0D
		BNE	LB9C6
cmdREAD_CR
		LEAX	,Y				; save start of line for skip
		LDA	,Y+
		BMI	brkOutOfDATA
		LEAY	1,Y				; skip 2nd byte of 
		LDB	,Y+				; line length
LB9DA
		LDA	,Y+
		CMPA	#' '
		BEQ	LB9DA				; skip spaces
		CMPA	#tknDATA			; found DATA token that'll do
		BEQ	cmdREAD_dataItemFound
		ABX					; if not add line length to start of line and continue
		LEAY	,X		
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
;;		STY ZP_TXTOFF2
cmdREAD_dataItemFound
;		LEAY	,X
		RTS
cmdUNTIL
			
;			;  UNTIL
		CALL	evalExpressionMAIN
		CALL	scanNextExpectColonElseCR_2
		CALL	checkTypeInZP_VARTYPEConvert2INT
		LDB	ZP_REPEAT_LVL
		BEQ	brkNoREPEAT
		LDA	ZP_INT_WA
		ORA	ZP_INT_WA + 1
		ORA	ZP_INT_WA + 2
		ORA	ZP_INT_WA + 3
		BEQ	1F
		DEC	ZP_REPEAT_LVL			; discard top of repeat stack
		JUMP	continue			; continue
1							; LBA33
		DECB
		ASLB
		LDX	#BASWKSP_REPEATSTACK
		LDY	B,X
		JUMP	STYZPTXTPTR_continue
;LBA3C:
;		DEC ZP_TXTOFF
;LBA3E:
;		LDA ZP_TXTOFF
;		STA ZP_TXTOFF2
;		LDA ZP_TXTPTR
;		STA ZP_TXTPTR2
;		LDA ZP_TXTPTR + 1
;		STA ZP_TXTPTR2 + 1
			; Parse #channel, save line pointer, return channel in Y
			; To tidy up, move this to be with =PTR/=EXT/=EOF
evalHashChannel						; LBA4A
		JSR	SkipSpaceCheckHashAtY
		CMPA	#'#'
		BNE	brkMissingHash
		JSR	evalLevel1checkTypeStoreAsINT
		STY	ZP_TXTPTR				; TODO - remove this and stack before call?
		LDY	ZP_INT_WA
		RTS


cmdREPEAT
			;  REPEAT
		LDB	ZP_REPEAT_LVL
		CMPB	#$14
		BHS	brkTooManyREPEATs
		CALL	storeYasTXTPTR
		ASLB
		LDX	#BASWKSP_REPEATSTACK
		STY	B,X
		INC	ZP_REPEAT_LVL
		JUMP	skipSpacesAtYexecImmed
;LBA70:
;		LDA #$06
;		BRA ReadKeysTo_PageInA

ReadKeysTo_InBuf
		LDA	#BAS_InBuf / $100
ReadKeysTo_PageInA
		CLRB
		STD	ZP_GEN_PTR
		LDA	#$EE
		STA	ZP_GEN_PTR + 2
		LDA	#' '
		STA	ZP_GEN_PTR + 3
		LDB	#$FF
		STB	ZP_GEN_PTR + 4
		LDX	#ZP_GEN_PTR
		LDY	#0
		CLRA
		JSR	OSWORD		; OSWORD 0 - read line to buf at XY
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
		STY	ZP_TOP				; we found the line - replace it
		LEAX	,Y
		LDB	3,Y				; get length of existing line
		CLRA
		ADDD	ZP_TOP		
		TFR	D,Y
floCopyLp						; LBAB8
		LDA	,Y+
		STA	,X+
		CMPA	#$0D
		BNE	floCopyLp
							;LBAC7:
		LDA	,Y+
		STA	,X+				; copy first (line number byte - big endian)
		BMI	floCopySk1			; end of program detected
		CALL	floCopy1bytes			; copy line numbers bytes 
		CALL	floCopy1bytes			; copy length byte
		BRA	floCopyLp
floCopySk1						;LBAD3:
;LBADC:
		STX	ZP_TOP
		RTS
floCopy1bytes
		LDA	,Y+
		STA	,X+
rtsLBAEA	RTS
			
		;  Tokenise line, enter into program if program line
		;  returns CY=1 if this is a program line

tokenizeAndStore
		LDA	#$FF
		STA	ZP_OPT
		STA	ZP_FPB + 1
		CALL	ResetStackProgStartRepeatGosubFor		;  do various CLEARs
		LDD	ZP_TXTPTR
		STD	ZP_GEN_PTR
		CLR	ZP_FPB
		CLR	ZP_TXTOFF
		CALL	tokenizeATZP_GEN_PTR
		LDY	ZP_TXTPTR
		CALL	skipSpacesDecodeLineNumberNewAPI
		BCC	rtsLBAEA
tokenizeAndStoreAlreadyLineNoDecoded					; LBB08
		CLRB
		LDA	ZP_LISTO
		BEQ	tokAndStoreListo0		
tokas_lp								;LBB0C:
		LDA	,Y+
		CMPA	#' '
		BEQ	tokas_lp
tokAndStoreListo0							;LBB15:
		STY	ZP_FPB
		CALL	findLineAndDelete  
		LDY	ZP_FPB
		LDA	#$0D
		LDB	#1						; count line length
		CMPA	,Y+		
		BEQ	rtsLBAEA					; line was nowt but white space, return
tokas_lp2	INCB							;LBB26:
		CMPA	,Y+
		BNE	tokas_lp2					; move to EOL marker $D
		LDA	#' '
		LEAY	-1,Y
tokas_lp3	DECB							;LBB2D:
		CMPA	,-Y
		BEQ tokas_lp3						; skip back over spaces
tokas_sk1	LEAY	1,Y						;LBB34:
		LDA	#$0D
		STA	,Y						; another EOL marker remove trailing whitespace
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
		TFR	D,Y
		LEAY	1,Y
		LEAX	1,X
tokas_lp4
		LDA	,-X
		STA	,-Y
		CMPX	ZP_FPB + 2
		BNE	tokas_lp4


		LEAX	1,X						; move past 0d marker
		LDD	ZP_INT_WA + 2					; get decoded big endian line number
		STD	,X++
		LDB	ZP_FPB + 4					; line length
		STB	,X+	

		SUBB	#4						; reduce line length counter by 4
		LDY	ZP_FPB
tokas_lp5	LDA	,Y+						; copy from $700 to program memory
		STA	,X+
		DECB
		BNE	tokas_lp5
		ORCC	#CC_C
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
		LDX #$10
1		LDD tblFPRtnAddr_const-2,X
		STD $07F0-2,X				;  Copy entry addresses to $07F0-$07FF
		LEAX -2, X
		BNE 1B
		LDA #$40
		LDX #0
		LDY #BASWKSP_DYNVAR_HEADS
1		STX ,Y++
		DECA
		BNE 1B					;  Clear dynamic variables
		RTS
ResetStackProgStartRepeatGosubFor
		LDA ZP_PAGE_H
		CLRB
		STD ZP_READ_PTR				;  DATA pointer = PAGE
		LDD ZP_HIMEM
		TFR D,U					;  STACKBOT=HIMEM
		LDA ZP_LISTO
		ANDA #$7F
		STA ZP_LISTO
		CLR ZP_REPEAT_LVL
		CLR ZP_FOR_LVL_X_15
		CLR ZP_GOSUB_LVL;			;  Clear REPEAT, FOR, GOSUB stacks
		RTS					;  DATA pointer = PAGE
;		
;		
popFPFromStackToPTR1			; pop FP from stack, set out old stack pointer in PTR1
		STU	ZP_FP_TMP_PTR1
		LEAU	5,U
		RTS

fpStackWAtoStackReal
		LEAX	-5,U
		CALL	UpdStackFromXCheckFull		; make room for a float on the stack
		LDA	ZP_FPA + 2
		STA	0,U
		LDA	ZP_FPA
		EORA	ZP_FPA + 3
		ANDA	#$80
		EORA	ZP_FPA + 3		; Get top bit of sign byte and seven other bits of mantissa MSB
		STA	1,U

		LDD	ZP_FPA + 4
		STD	2,U

		LDA	ZP_FPA + 6
		STA	4,U
		RTS
stackVarTypeInFlags
		BEQ	StackString
		BMI	fpStackWAtoStackReal
stackINT_WAasINT				; LBC26
		LEAX	-4,U
		CALL	UpdStackFromXCheckFull
		LDD	ZP_INT_WA
		STD	,U
		LDD	ZP_INT_WA + 2
		STD	2,U
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
		PSHS	B,X,Y
		LDB	ZP_STRBUFLEN			; Calculate new stack pointer address
		LDA	#$FF
		COMB					; D now contains -(ZP_STRBUFLEN + 1)
		LEAX	D,U
		CALL	UpdStackFromXCheckFull
		LDB	ZP_STRBUFLEN			; store len as first byte of stacked data
		LEAY	,U
		STB	,Y+
		BEQ	stackstrsk0
		LDX	#BAS_StrA			; followed by the string data
stackstrlp0	LDA	,X+
		STA	,Y+
		DECB
		BNE	stackstrlp0
stackstrsk0	PULS	B,X,Y,PC

;	
;		
delocaliseAtZP_GEN_PTR
		LDA	ZP_GEN_PTR + 0			; get variable type
		CMPA	#VAR_TYPE_STRING_STAT
		BEQ	delocalizeStaticString		; was a static string
		BLO	delocalizeNum

		;delocalise Dynamic String

		LDB	,U+				; get stacked string length
		BEQ	2F
		LDX	ZP_GEN_PTR + 2			; string params pointer
		STB	3,X
		LDX	,X				; string pointer

1		LDA	,U+
		STA	,X+
		DECB
		BNE	1B
2							; LBC8D:
		RTS

delocalizeStaticString					; LBC95
		LDB	,U+				; get stacked string length
		BEQ	2F
		LDX	ZP_GEN_PTR + 2			; get address to restore string to 
1							; LBC9C
		LDA	,U+
		STA	,X+
		DECB
		BNE	1B
		LDA	#$0D
		STA	,X+
		RTS
delocalizeNum						; LBCAA
		LDX	ZP_GEN_PTR + 2
		LDB	ZP_GEN_PTR + 0			; get var type
		DECB
1		LDA	,U+				; for 0 (do 1 byte), for 4,5 do 4,5 bytes
		STA	,X+
		DECB
		BPL	1B
		RTS

		; new API - trashes A, X
popStackedStringNew					; LBCD2
		LDA	,U+				; first byte contains length
		STA	ZP_STRBUFLEN
		BEQ	1F
		LDX	#BASWKSP_STRING
2		LDB	,U+
		STB	,X+
		DECA
		BNE	2B
1		RTS

discardStackedStringNew					; LBCE1
		LDB	,U+
		CLRA
		LEAU	D,U				; remove stacked string
		RTS

		; New API - after call all regs preserved
popIntANew
		PSHS	X,Y
		PULU	X,Y
		STX	ZP_INT_WA
		STY	ZP_INT_WA + 2
		PULS	X,Y,PC
popIntAtZP_GEN_PTRNew				; LBD06
		LDX #ZP_GEN_PTR			; TODO - WORK THIS LOT OUT!
		; NOTE: trashes A,B
popIntAtXNew					; LBD08
		LDD	,U++
		STD	0,X
		LDD	,U++
		STD	2,X
		RTS
UpdStackFromXCheckFull
		CMPX	ZP_TOP
		BLO	brabrkNoRoom
		LEAU	,X
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
		PSHS	X,Y
		LEAX	tblTOKENS,PCR

doListTryNextTok						; LBD46
		LEAY	,X					; Y points to name of current token
doListSkipKey							;LBD48:
		LDA	,X+					; TODO probably can skip first and 2nd char every time?
		BPL	doListSkipKey				; not a token skip it
		CMPA	ZP_GEN_PTR
		BEQ	doListKeyLp				; it's the right token
		LEAX	1,X					; skip flags
		BRA	doListTryNextTok
doListKeyLp							;LBD60:
		LDA	,Y+
		BMI	doListKeyFinished
		CALL	list_printA
		BRA	doListKeyLp
doListKeyFinished						;LBD6A:
		PULS	X,Y,PC


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
		ANDCC	#~CC_C
doLISTOSpaces						; LBDB4
		ANDA	ZP_LISTO
		BEQ	rtsLBDC5
		TFR	B,A
		BMI	rtsLBDC5
		ROLA
		TFR	A,B
		BEQ	rtsLBDC5
list_printBSpaces			;LBDBF:
		CALL	list_print1Space
		DECB
		BNE	list_printBSpaces
rtsLBDC5
		RTS
;		
;		
CopyIntA2ZPX				   ; DB: Changed this to use 16 bit reg and X can point anywhere!
		PSHS	D
		LDD	ZP_INT_WA + 0
		STD	,X
		LDD	ZP_INT_WA + 2
		STD	2,X
		PULS	D
		RTS
;		
;			;  Load program to PAGE
;			;  --------------------
loadProg2Page
		CALL	GetFileNamePageAndHighOrderAddr	; get cr-string, FILE_NAME=STRA, FILE_LOAD=PAGE/memhigh
		LDY	#ZP_SAVE_BUF + OSFILE_OFS_EXEC	; set exec address low byte to 0
		LDD	#0
		CALL	Set32BELE
		LDA	#OSFILE_LOAD
		LDX	#ZP_GEN_PTR			;  Point to OSFILE block
		JSR	OSFILE				;  Continue into FindTOP
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
		PRINT_STR "\rBad program\r"
		JUMP immedPrompt
;		
str600CRtermSetGenPtr600
		LDX	#BAS_StrA
		STX	ZP_SAVE_BUF			;  $37/8=>string buffer
		BRA	1F
str600CRterm	LDX	#BAS_StrA
1		LDB	ZP_STRBUFLEN			;  Get length of string in buffer
		LDA	#$0D
		STA 	B,X
		RTS					;  Store <cr> at end of string

evalYExpectString					; LBE36
		CALL	evalExpressionMAIN		;  Call expression evaluator
		TSTA
		LBNE	brkTypeMismatch			
		CALL	str600CRtermSetGenPtr600	;  Point 37/8 to STRA, put terminating <cr> in
		LDA	,Y+
		JUMP	scanNextExpectColonElseCR

OSByte82	LDA	#$82
		JSR	OSBYTE
		RTS
GetFileNamePageAndHighOrderAddr				; LBE41
		CALL	evalYExpectString		; Get CR-string
		CALL	OSByte82
		LDA	ZP_PAGE_H
		CLRB
		LDY	#ZP_SAVE_BUF + OSFILE_OFS_LOAD
Set32BELE						; set a 32 bit number either as BE or LE depending on flag at ZP_BIGEND
							; high order address is in X, D contains value, Y is pointer to value to
		TST	ZP_BIGEND
		BNE	Set32LE
Set32BE		STX	,Y				; high order
		STD	2,Y				; low order
		RTS
Set32LE		STD	,--S				; save D
		TFR	X,D				; swap endianness of high order word
		EXG	A,B
		STD	2,Y				; store in high bytes
		LDD	,S
		EXG	A,B
		STD	0,Y
		PULS	D,PC

cmdSAVE							; LBE55
		CALL	findTOP
		CALL	GetFileNamePageAndHighOrderAddr
		LDY	#ZP_SAVE_BUF + OSFILE_OFS_START	; D already contains PAGE
		CALL	Set32BELE
		LDY	#ZP_SAVE_BUF + OSFILE_OFS_END
		LDD	ZP_TOP
		CALL	Set32BELE
		LDD	#$802B				; BASIC ROM start addr (what to do here?)
		LDY	#ZP_SAVE_BUF + OSFILE_OFS_EXEC
		CALL	Set32BELE
		LDA	#OSFILE_SAVE			; OSFILE 0
		JSR	OSFILE
		JUMP	continue

cmdOSCLI
		CALL	evalYExpectString
		LDX	#BASWKSP_STRING
		PSHS	Y
		JSR	OSCLI
		PULS	Y
		JUMP	continue

			; EXT#channel=number
			; ------------------
cmdEXTEq					; LBE93
		LDA	#$03			; 03=Set extent
		BRA	varSetFInfo

			; PTR#channel=number
			; ------------------
varSetPTR					; LBE97
		LDA	#$01			; 01=Set pointer
varSetFInfo					; LBE99
		PSHS	A
		JSR	evalHashChannel		; Evaluate #channel, save TXTPTR, Y=channel
		PSHS	Y			; Save channel
		LDY	ZP_TXTPTR		; Get TXTPTR back
		CALL	skipSpacesExpectEqEvalExp
		CALL	checkTypeInZP_VARTYPEConvert2INT
		TST	ZP_BIGEND
		BEQ	1F
		CALL	SwapEndian		; Swap INTA
1		STY	ZP_TXTPTR		; Save TXTPTR
		LDX	#ZP_INT_WA
		PULS	A,Y			; Get action and channel
		JSR	OSARGS			; Write from INTA
		LDY	ZP_TXTPTR		; Get TXTPTR back
		JUMP	continue		; Return to main execution loop

			; CLOSE#channel
			; -------------
cmdCLOSE					; LBEAE
		JSR	evalHashChannel		; Evaluate #channel, save TXTPTR, Y=channel
		CLRA				; A=$00 for CLOSE
		JSR	OSFIND
		LDY	ZP_TXTPTR		; Get TXTPTR back
		JUMP	continue		; Return to main execution loop

			; BPUT#channel,number
			; -------------------
cmdBPUT						; LBEBD
		JSR	evalHashChannel		; Evaluate #channel, save TXTPTR, Y=channel
		PSHS	Y			; Save channel
		LDY	ZP_TXTPTR		; Get TXTPTR back
		CALL	checkCommaThenEvalAtYcheckTypeInAConvert2INT
		PULS	Y			; Get channel back
		LDA	ZP_INT_WA+3		; Get low byte of number
		JSR	OSBPUT			; Write to channel
		LDY	ZP_TXTPTR		; Get TXTPTR back
		JUMP	continue		; Return to main execution loop

callOSWORD5INT_WA				; get a byte from host processor
; not actually needed, 6809 BBC API defined to pass X=>command line on entry
		TODODEADEND "callOSWORD5INT_WA - endianness, sort out"
		LDA	#$05
		PSHU	X
		LDX	#ZP_INT_WA
		LDY	#0			; DP
		JSR	OSWORD
		PULU	X
		LDA	ZP_INT_WA + 4		; return value in A
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
;PERCENTz:
;		.byte  "Roger"
;
;		.segment "EXTRA"
;		.org	$c000
;



		include		"./debug_print.asm"


		SECTION		"tables_and_strings"


ENDtables_and_strings
	IF ENDtables_and_strings>$C000
		ERROR	"tables and strings area is full!"
	ENDIF
	IF ENDtables_and_strings<$C000
			ORG $BFFF
			FCB	$FF
	ENDIF