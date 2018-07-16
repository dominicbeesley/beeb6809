

	; vars used in opcode parse phase
ASS_VAR_OPACC	EQU	0				; 2 byte "op-acc" accumulator 25 bits + flags
ASS_VAR_FLAGS	EQU	4				; flags from parse table
	; vars used in class lookup phase and beyond (note flags carry through and are OR'ed with the flags from parse table)
ASS_VAR_IX	EQU	0				; opcode index
ASS_VAR_MODEP	EQU	0				; scratch during mode decoding 
ASS_VAR_SUFFIX	EQU	1				; suffix item index
ASS_VAR_MODESET EQU	2				; mode set for this op class
ASS_VAR_OPLEN	EQU	3				; opcode len (minus prefix byte)

ASS_VAR_PTR_SAV EQU	5				; store U temporarily
ASS_VAR_OP	EQU	7				; "base" opcode number from parse table, followed by upto 4 more post bytes

ASS_VAR_SPACE	EQU	12


	IF ASSEMBLER_6309
		include "6309-assembler.gen.asm"
	ELSE
		include "6809-assembler.gen.asm"
	ENDIF

assJmpScanEndOfStmt
		JUMP	assScanEndOfStmt

assEndStmtChCt	EQU	4
assEndStmtCh	FCB	":",$0D,"\\;"

assScanNextOp	LDB	#ASS_VAR_SPACE
1		CLR	,-S				; make room on stack
		DECB
		BNE	1B
		
assScanContinue
		CALL	skipSpacesYStepBack		; L89EB

		LDB	#assEndStmtChCt
		LDX	#assEndStmtCh
1		CMPA	,X+
		BEQ	assJmpScanEndOfStmt
		DECB
		BNE	1B

		CMPA	#'.'
		BEQ	assScanLabel			;  Label
		LDB	#$03				;  Prepare to fetch up to three characters
		STB	ZP_ASS_LIST_OPLEN		;  counter of # of chars in accumulator

		; special check for op code starting "LB"
		LDD	,Y
		CMPD	#('L'<<8) + 'B'
		BNE	assScanOpLoop
		LDA	#ASS_BITS_EXTRA0
		STA	ASS_VAR_FLAGS,S			; set flag
assScanOpLoop
		; parse loop, keep adding chars until there's a match or 5 chars added
		LDA	,Y+
		BMI	assScanTokFound			; special handling for tokens OR,EOR,AND
		CMPA	#' '
		BEQ	assScanOpSkSpace

		; rol into accumulator
		LDB	#$05
		ASLA
		ASLA
		ASLA
assScanOpLoop2	ASLA					; L8A17
		ROL	ASS_VAR_OPACC+1,S		; roll 5 LSB's of opcode char into accum
		ROL	ASS_VAR_OPACC+0,S
		DECB
		BNE	assScanOpLoop2
		BRA	assScanParseTbl

assScanLabel	LEAY	1,Y				; L89D4
		CALL	findVarOrAllocEmpty
		BEQ	assJmpBrkSyntax2
		BCS	assJmpBrkSyntax2
		CALL	pushVarPtrAndType
		CALL	GetP_percent			;  Get P%
		STA	ZP_VARTYPE
		CALL	storeEvaledExpressioninStackedVarPTr
;;		CALL	copyTXTOFF2toTXTOFF
		STY	ZP_ASS_LBLEND		

		BRA	assScanContinue


assScanTokFound
		; this assumes that the token is at the start of the scan and just sets up the
		; accumulator as such
		LDB	#4
		LEAX	assTok2Acc_tbl,PCR
1		CMPA	,X
		BEQ	1F
		LEAX	2,X
		DECB
		BNE	1B
		BRA	assJmpBrkSyntax2		; not found syntax error
1		LDB	1,X
		STB	ZP_ASS_OP_IX			; setup index
		LDA	#ASS_OPTBL_SIZE
		MUL
		LEAX	assParseTbl,PCR
		LEAX	D,X				; X now points at parse table entry
		BRA	assScanParseTbl_match


assScanOpSkSpace
		CLR	ZP_ASS_LIST_OPLEN		; clear char counter, scan no more chars
assScanParseTbl
		; now try matching against the parse table
		LDX	#assParseTbl			; get start of parse table
		CLR	ZP_ASS_OP_IX			; index
assScanParseTbl_lp
		LDD	ASS_OPTBL_OF_MNE,X		; get hashed opcode from table
		BMI	assScanParse_nomatch
		CMPD	ASS_VAR_OPACC,S			; compare with hashed opcode built from source
		BEQ	assScanParseTbl_match
assScanParseTbl_next		
		INC	ZP_ASS_OP_IX
		LEAX	ASS_OPTBL_SIZE,X		; no match
		BRA	assScanParseTbl_lp
		
assScanParse_nomatch
		DEC	ZP_ASS_LIST_OPLEN
		LBPL	assScanOpLoop

assJmpBrkSyntax2
		JUMP	brkSyntax

assTok2Acc_tbl
		FCB	tknAND
		FCB	assParseTbl_AND_IX
		FCB	tknEOR
		FCB	assParseTbl_EOR_IX
		FCB	tknOR
		FCB	assParseTbl_OR_IX
	IF ASSEMBLER_6309
		FCB	tknDIV
		FCB	assParseTbl_DIV_IX
	ENDIF

	IF 	assParseTbl_AND-assParseTbl > 255 || assParseTbl_EOR-assParseTbl > 255 || assParseTbl_OR-assParseTbl > 255 || assParseTbl_DIV-assParseTbl > 255
		error 	"assTok2Acc_tbl overflow"
	ENDIF


assScanParseTbl_match

assScanProcessTblEnt					
		; X now points at matching parse table entry and we've tried all possible 5 char opcodes
		; we now have X pointing at parser table entry
		; ZP_ASS_OP_IX is the op index which we'll used to access the classes table
		; save the stuff in our stack workspace
		LDA	ASS_OPTBL_OF_OP,X
		STA	ASS_VAR_OP,S			; base opcode
		LDA	ZP_ASS_OP_IX
		STA	ASS_VAR_IX,S			; op index
		; find which class from the class table
		LEAX	assClassTbl,PCR			; get base of class table
		CLRB
1		CMPA	ASS_CLSTBL_OF_IXMAX,X		; see if the opcode index is < ixmax
		BLO	assClassFound
		LEAX	ASS_CLSTBL_SIZE,X
		INCB
		BRA	1B

assClassFound
		LDA	ASS_CLSTBL_OF_FLAGS,X
		ORA	ASS_VAR_FLAGS,S			; possibly already set flags in parse for "LB"
		STA	ASS_VAR_FLAGS,S			; parse flags

		CMPB	#assClass_DIR_ix
		LBEQ	assClass_DIR_parse

		INC	ASS_VAR_OPLEN,S			; got at least 1 byte to store
	IF ASSEMBLER_6309
		CMPB	#assClass_D_ix			; class D is AIM etc require an immediate before looking for modes
		LBEQ	assClass_D_parse
	ENDIF
		; Get modeset and store it
		LDB	ASS_CLSTBL_OF_MODES,X
		STB	ASS_VAR_MODESET,S

		; check to see if there's a suffix set and process it
		LDB	ASS_CLSTBL_OF_SUFS,X
		LBEQ	assModesParse
		LBMI	assClass_SuffSetSingle		; skip straight to singleton
assClassSuff_FollowTail
		LDX	#assSuffSetsTbl			; get base of suffix sets table
		; loop through table to find start of our set, skipping unwanted sets
		ANDB	#$3F
1		DECB
		ABX
assClass_SuffSetLp
		; suffix set found, now need to try out each suffix set item
		LDB	,X+
		BITB	#$40				; check for a tail bit - if set restart scan at spec'd index in lower bits
		BNE	assClassSuff_FollowTail
assClass_SuffSetSingle
		CALL	assParseTrySuffix
		BCS	assClass_suffixMatched		; we found one
		TSTB	
		BPL	assClass_SuffSetLp		; not at end of suffix set yet try again
		; no suffix matched - if "both" flag is set then error out
		LDA	#ASS_BITS_BOTH
		BITA	ASS_VAR_FLAGS,S
		BNE	assJmpBrkSyntax2

assModesParse
		LDB	ASS_VAR_MODESET,S		; get modes set
		LBEQ	assScanEndOfStmt		; node modes set, implicit, we're done
		LBPL	assModesParseMem

		ANDB	#$07
		ASLB
		LDX	#assModesTbl
		ABX
		JMP	[,X]

assClass_suffixMatched
		
		; check to see if this is a "both" type opcode
		LDA	#ASS_BITS_BOTH
		BITA	ASS_VAR_FLAGS,S
		BNE	assModesParse		
		JUMP	assScanEndOfStmt

assParseTrySuffix
		; try and match suffix against source text
		; if a match return CY=1, A=flags, B=opcode delta, else X,B preserved

		PSHS	B,X,Y
		ANDB	#$3F				; ignore tail / end bits
		STB	7+ASS_VAR_SUFFIX,S


		LEAX	assSuffItemTbl,PCR		; point to suffix items table
1		DECB
		BEQ	assSuffItemFound

		; skip suffix string, skip chars until -ve
2		LDA	,X+
		BPL	2B

		BITA	#FLAGS_SUF_OP
		BEQ	3F
		LEAX	1,X				; skip op

3		BITA	#FLAGS_SUF_MODE
		BEQ	3F
		LEAX	1,X				; skip mode

3		BRA	1B

assSuffItemFound
		; we are now pointing at suffix def
		CALL	assMatchXY
		BCS	assSuffItemMatch
		; reset Y
		PULS	B,X,Y,PC

assMatchXY	; match strings at X, Y (X is >$80 terminated) return Cy=1 for match or Cy=0 and >$80 in A
		; match to source
1		LDA	,X+
		BMI	2F	
		EORA	,Y+				; get source char
		ANDA	#$DF				; ifgnore case
		BEQ	1B
3		LDA	,X+
		BPL	3B
4		CLC	
		RTS
2		; check to see if at end of register i.e. <A >Z
		PSHS	A
		LDA	,Y
		CALL	checkIsValidVariableNameChar
		PULS	A
		BCS	4B				; return no match
		SEC
		RTS


assSuffItemMatch		
		LEAS	5,S				; discard saved Y,B,X

		BITA	#FLAGS_SUF_OP
		BEQ	3F
		LDB	,X+				; get op code delta in B
		ADDB	2+ASS_VAR_OP,S
		STB	2+ASS_VAR_OP,S			; update opcode
3		BITA	#FLAGS_SUF_MODE
		BEQ	3F
		LDB	,X+				; get mode override
		STB	2+ASS_VAR_MODESET,S

3		BITA	#ASS_BITS_EXTRA0
		BEQ	3F

		;lookup extra opcode mappings based on suffset/orginal op
		PSHS	D
		LDA	4+ASS_VAR_OP,S			; original opcode
		LDB	4+ASS_VAR_SUFFIX,S		; suffix set
	IF ASSEMBLER_6309
		CMPB	#ASS_REGS_REGREG_IX
		BNE	1F
		LDX	#assXlateRegReg
		BRA	2F
1
	ENDIF
		CMPB	#ASS_REGS_CC_IX
		BNE	1F
		LDX	#assXlateCC
2		; scan table, look for op map
		LDB	,X+
4		CMPA	,X+
		BEQ	5F
		LEAX	1,X
		DECB	
		BNE	4B
		BRA	1F
5		LDA	,X+
		STA	4+ASS_VAR_OP,S
1		PULS	D

3		ANDA	#~FLAGS_SUF_ANY			; clear suffix specific bits
		ORA	2+ASS_VAR_FLAGS,S		; update flags
		STA	2+ASS_VAR_FLAGS,S
		SEC					; indicate successful match
		RTS




assModesTbl
		FDB	assModesRel
		FDB	assModesImmed
		FDB	assModesRegReg
		FDB	assModesPxxxW
	IF ASSEMBLER_6309
		FDB	assModesBitBit
		FDB	assModesTFM
	ENDIF
assModesParseMem
		CALL	skipSpacesY
		; a "standard memory type"
		; immed?
		BITB	#1
		BEQ	assModesParseMem_NotImmed	; if bit 0 set try immed
		CMPA	#'#'
		BNE	assModesParseMem_NotImmed
assModeImmed
		CALL	evalForceINT
		LDB	#-1		
		LDA	ASS_VAR_MODESET,S
		CMPA	#ASS_MODESET_ANY_LDQ		; if LDQ then 32 bit immeds
		BNE	2F
		LDB	#-4
		BRA	1F
2		LDA	ASS_VAR_FLAGS,S
		BITA	#ASS_BITS_16B			; if 16 bit immeds
		BEQ	1F					
		DECB
1		LDX	#ZP_INT_WA+4
		LEAX	B,X
		NEGB
		CALL	assCopyBBytesToOpBuf
		LDB	#ASS_MEMPB_IMM
assMemModeCheckValid
		PSHS	B
		LDA	ASS_VAR_MODEP,S
		ORA	,S+
		ANDB	ASS_VAR_MODESET,S
		ANDB	#$0F
		BEQ	brkIllMode

		; calculate mem/op combination based on address type and modeset
							; get lower 4 bits of MODEP
		ANDA	#$0F
		STA	ZP_INT_WA
		LDA	ASS_VAR_MODESET,S
		ANDA	#$70				; get modeset index
		ORA	ZP_INT_WA
		STA	ZP_INT_WA
		; search assModeTbl for matching entry
		LDX	#assModeTbl
1		LDA	,X+
		BEQ	2F				; end of table
		CMPA	ZP_INT_WA
		BEQ	3F
		LEAX	2,X
		BRA	1B
3		; got a match update flags and opcode
		LDA	,X+
		ADDA	ASS_VAR_OP,S
		STA	ASS_VAR_OP,S
		LDA	,X+
		ORA	ASS_VAR_FLAGS,S
		STA	ASS_VAR_FLAGS,S

2		
		; final mode check

		JUMP	assScanEndOfStmt


assJmpBrkSyntax						; L8A35
		JUMP	 brkSyntax

brkIllMode
		DO_BRK_B
		FCB	$3, "Illegal Mode", 0

assModesParseMem_NotImmed
		; now look for any of the memory addressing modes
		CLR	ASS_VAR_MODEP,S			; clear flags

		; check for any <,>,[
4		CMPA	#'<'
		BNE	1F
		; got an DP indicator
		LDA	#ASS_MEMPB_SZ8
		BRA	2F
1		CMPA	#'['
		BNE	1F
		; got an DP indicator
		LDA	#ASS_MEMPB_IND
		BRA	2F
1		CMPA	#'>'
		BNE	4F
		LDA	#ASS_MEMPB_SZ16
		; got an DP indicator
2		ORA	ASS_VAR_MODEP,S
		STA	ASS_VAR_MODEP,S
3		CALL	skipSpacesY
		BRA	4B

4		CMPA	#','
		LBEQ	assModeZeroIX

		; now check for R,IX form
		STY	ZP_TXTPTR2			; save Y incase we back out
		LDX	#assModesTblAccIX
		ANDA	#$DF				; to upper
		STA	ZP_INT_WA
1		LDD	,X++
		TSTA	
		LBEQ	assModexParseNotRegIX
2		CMPA	ZP_INT_WA			; compare to original char
		BNE	1B
	IF ASSEMBLER_6309
		; check for 6309 mode
		TSTB	
		BPL	1F
		LDA	#$10
		BITA	ZP_OPT
		BEQ	assModexParseNotRegIX		; skip it, we're not in 6309 mode!
1		
	ENDIF
		CALL	skipSpacesCheckCommaAtY
		LBNE	assModexParseNotRegIX
		ANDB	#$0F
		; we now have an index type # in B

		CALL	assModeParseIXRegAfterComma
assPostByteIXCheckIndThenValidate
		CALL	assModeParseIXIndCheckAndMerge2A
assPostByteIXCheckValidModeIX
		LDB	#ASS_MEMPB_IX
assPostByteIXCheckValid
		CALL	assPostByte		
		JUMP	assMemModeCheckValid	

assModeParseIXIndCheckAndMerge2A
		; merge in the indirect flag if present
		LDA	2+ASS_VAR_MODEP,S
		PSHS	B
		ANDA	#ASS_MEMPB_IND
		ORA	,S+
		RTS


assPostByte	PSHS	B
		; add this byte to instruction
		LDB	3+ASS_VAR_OPLEN,S
		ADDB	#3+ASS_VAR_OP
		STA	B,S
		INC	3+ASS_VAR_OPLEN,S
		PULS	B,PC

assModeParseIXRegAfterComma
; enter with index type (i.e. low 4 bits of post byte) in B

		CALL	skipSpacesY			; this should be one of SUXY
		ANDA	#$DF				; to upper
		TSTB
		BNE	assDontCheckPC
		; if B is 0 on entry also test for PC/PCR
		CMPA	#'P'
		BNE	assDontCheckPC
		LDA	,Y+
		CMPA	#'C'
		BNE	brkIndex
		LDA	,Y
		CMPA	#'R'
		BNE	assNotPCR
		LEAY	1,Y
		; PCR, subtract P% from INT_WA		
		; calculate length of instruction in ZP_INT_WA+0,1
		CLR	ZP_INT_WA
		LDA	#3				; room for op, post byte, 8 bit offset 
		LDB	#ASS_BITS_PRE
		BITB	2+ASS_VAR_FLAGS,S
		BNE	1F
		INC	A				; add one for prefix
1		STA	ZP_INT_WA + 1
		LDD	ZP_INT_WA + 2
		SUBD	VAR_P_PERCENT + 2
		SUBD	ZP_INT_WA + 0			; subtract length of op (8 bit form)
		STD	ZP_INT_WA + 2
		SEX
		CMPA	ZP_INT_WA + 2			; check if fits in 8 bits
		BEQ	assNotPCR			; it does
		; it doesn't fit
		LDA	#ASS_MEMPB_SZ16
		ORA	2+ASS_VAR_FLAGS,S
		STA	2+ASS_VAR_FLAGS,S
		CALL	assDecIntWa2

assNotPCR	LDB	#$0C				; +ve C indicates PC/PCR
		RTS
assDontCheckPC	LDX	#assModesTblRegIX
		ORB	#$80+(3<<5)			; index reg bits and 1 in top bit
1		CMPA	,X+
		BEQ	assModeParseIXRegFound
		SUBB	#1<<5
		BMI	1B				; if it goes +ve again we've tried everything
brkIndex	DO_BRK_B
		FCB	$3, "Index", 0
assModeParseIXRegFound
		TSTB
		RTS

assModexParseNotRegIX
		LDY	ZP_TXTPTR2
		LEAY	-1,Y

		CALL	evalForceINT
		CALL	skipSpacesCheckCommaAtYStepBack
		BEQ	assModeParseOffsIX
		; not , so either a DP or EXT or [indir]
		; first check for indir
		LDA	#ASS_MEMPB_IND
		BITA	ASS_VAR_MODEP,S
		BEQ	assModexDpOrExt
		; it is indir
		LDD	#$9F00 + ASS_MEMPB_IX		; special number for indirect
assModePostByteThen16fromWA
		CALL	assPostByte
assMode16fromWA
		LDA	ZP_INT_WA+2
		CALL	assPostByte
assMode8fromWA
		LDA	ZP_INT_WA+3
		JUMP	assPostByteIXCheckValid
assModexDpOrExt
		; TODO - this assumes 16 if not <
		LDA	#ASS_MEMPB_SZ8
		BITA	ASS_VAR_MODEP,S
		BNE	assModexDp
		; mode is EXT
		LDB	#ASS_MEMPB_EXT
		JUMP	assMode16fromWA
assModexDp	LDB	#ASS_MEMPB_DP
		JUMP	assMode8fromWA

assIXAutoDec	INCB
		INCB
		LDA	,Y+
		CMPA	#'-'
		BNE	2F
		INCB
		BRA	1F
2		LEAY	-1,Y
1		CALL	assModeParseIXRegAfterComma
		BRA	assModeParseAutoIncDecDone

assModeZeroIX
		CALL	varFALSE			; put 0 in ZP_INT_WA
assModeParseOffsIX
		; ZP_INT_WA now contains the offset
		; FLAGS may indicate to force 8 or 16 bits
		; first parse which register
		CLRB
		CALL	skipSpacesY
		CMPA	#'-'
		BEQ	assIXAutoDec
		LEAY	-1,Y
		CALL	assModeParseIXRegAfterComma
		BPL	assModeParseOffsIX_NotAutoInc	; if +ve B then is PC/PCR
		; check for -,--,+,++
		CALL	skipSpacesY
		CMPA	#'+'
		BNE	assModeParseOffsIX_NotAutoInc
		LDA	,Y+
		CMPA	#'+'
		BNE	assModeParseAutoIncDecDone
		INCB
assModeParseAutoIncDecDone
2		CALL	IntWAZero
		BNE	brkIndex			; must be 0 offset
							; should be one of 0 for +, 1 for ++, 2 for -, 3 for --
		BITB	#1				; if not odd then can't be indirect
		BNE	1F
		LDA	#ASS_MEMPB_IND
		BITA	ASS_VAR_MODEP,S
		BNE	brkIndex
1		JUMP	assPostByteIXCheckIndThenValidate

assModeParseOffsIX_NotAutoInc
		LEAY	-1,Y
		; check for force 16 bit offset
		LDA	#ASS_MEMPB_SZ16
		BITA	ASS_VAR_MODEP,S
		BNE	assModeParseOffsIX_16B
		; check for zero offset
		CALL	IntWAZero
		BNE	assModeParseOffsIX_NotZeroOffs
		ORB	#$04				; zero offset
		JUMP	assPostByteIXCheckIndThenValidate

assModeParseOffsIX_NotZeroOffs

		; TODO we should check here for SZ8!

		PSHS	B				; save postbyte
		LDD	ZP_INT_WA + 2			; get offset
		BPL	1F
		COMB
		COMA
1		TSTA
		BNE	assModeParseOffsIX_16B		; doesn't fit in a byte
		TST	,S				; check for -ve
		BPL	assModeParseOffsIX_8B		; if so then PC/PCR form
		ANDB	#$F0
		BNE	assModeParseOffsIX_8B		; doesn't fit in 5 bits
		LDA	#ASS_MEMPB_IND
		BITA	1+ASS_VAR_MODEP,S		; indirect use 1 byte form
		BNE	assModeParseOffsIX_8B
		LDB	ZP_INT_WA + 3
		ANDB	#$1F
		ORB	,S+
		ANDB	#$7F
		JUMP	assPostByteIXCheckIndThenValidate

assModeParseOffsIX_8B
		PULS	B
		ORB	#$88
		CALL	assModeParseIXIndCheckAndMerge2A
		BRA	1F
assModeParseOffsIX_16B
		PULS	B
		ORB	#$89				; 16 bit postbyte
		CALL	assModeParseIXIndCheckAndMerge2A
		CALL	assPostByte
		LDA	ZP_INT_WA + 2
1		CALL	assPostByte
		LDA	ZP_INT_WA + 3
		JUMP	assPostByteIXCheckValidModeIX


assJmpBrkSyntax3
		JUMP	assJmpBrkSyntax


assModesTblRegIX
		FCB	"SUYX"

assModesTblAccIX
		FCB	'A', $06
		FCB	'B', $05
		FCB	'D', $0B
	IF ASSEMBLER_6309
		FCB	'E', $87		; 6309 -ve
		FCB	'F', $8A
		FCB	'W', $8E
	ENDIF
		FCB	0


assModesRegReg	CALL	skipSpacesYStepBack
		CALL	assModesRegRegScan
		ASLA
		ASLA
		ASLA
		ASLA
		PSHS	A
		CALL	skipSpacesCheckCommaAtY
		BNE	assJmpBrkSyntax3
		CALL	assModesRegRegScan
		ANDA	#$0F
		ORA	,S+
		JUMP	assPostByteThenScanEndOfStmt
		

assModesRegRegScan
		CLRB
		PSHS	Y
		LDX	#tblRegRegCodes
1		CALL	assMatchXY
		BCS	1F
		LDY	,S
		INCB
		BRA	1B
1		CMPA	#$FF
		BEQ	assJmpBrkSyntax3
		LEAS	2,S				; discard stacked Y
		RTS




	IF ASSEMBLER_6309
assClass_D_parse
		SWI
	ENDIF

	IF ASSEMBLER_6309
assModesBitBit
		SWI
	ENDIF

	IF ASSEMBLER_6309
assModesTFM
		SWI
	ENDIF

assModesPxxxW
	IF ASSEMBLER_6309
		LDA	,Y
		ANDA	#$DF
		CMPA	#'W'
		BNE	1F
		OIM	#ASS_BITS_PRE_10,ASS_VAR_FLAGS,S; set 10 prefix
		EIM	#$0C,ASS_VAR_OP,S		; change opcode
		JUMP	assScanEndOfStmt
1
	ENDIF
		CALL	skipSpacesCheckHashAtYStepBack
		BNE	1F
		; got an immediate
		CALL	evalForceINT
		LDA	ZP_INT_WA+3
		JUMP	assPostByteThenScanEndOfStmt
1		

		CLR	,-S				; build post byte here

assPushPullRegsLoop
		CALL	assModesRegRegScan
		CMPB	#6
		BLS	1F
		DECB
		CMPB	#8
		BHS	assJmpBrkSyntax3
1		LDA	#1
assBitLp	DECB
		BMI	1F
		ASLA
		BRA	assBitLp
1		ORA	,S
		STA	,S				; update postbyte
		CALL	skipSpacesCheckCommaAtYStepBack
		BEQ	assPushPullRegsLoop
		LDA	,S+				; get postbyte
		BEQ	assJmpBrkSyntax3
		JUMP	assPostByteThenScanEndOfStmt


assDecIntWa2
		LDD	ZP_INT_WA+2
		SUBD	#1
		STD	ZP_INT_WA+2
		RTS

assModesRel
		CALL	evalForceINT			; get "other" address
		LDD	ZP_INT_WA+2
		SUBD	VAR_P_PERCENT+2			; get rel addr
		SUBD	#2
		STD	ZP_INT_WA+2
		; check for "LBxx"
		LDA	#ASS_BITS_EXTRA0
		BITA	ASS_VAR_FLAGS,S
		BEQ	assModesRelShort
		; it's a long branch
		CALL	assDecIntWa2
		; sort out op codes
		LDA	ASS_VAR_OP,S
		CMPA	#$20				; BRA
		BNE	1F
		LDA	#$16
assModesRelLong_UpdateOp
		STA	ASS_VAR_OP,S
assModesRelLong_End
		LDB	#2
		LDX	#ZP_INT_WA+2
		JUMP	assCopyBBytesToOpBufAndEnd
1		CMPA	#$8D				; BSR
		BNE	1F
		LDA	#$17
		JUMP	assModesRelLong_UpdateOp
1		LDA	#ASS_BITS_PRE_10
		ORA	ASS_VAR_FLAGS,S
		STA	ASS_VAR_FLAGS,S
		CALL	assDecIntWa2
		JUMP	assModesRelLong_End
assModesRelShort	
		LDB	ZP_INT_WA+3			; get low byte
		SEX
		CMPA	ZP_INT_WA+2			; if <> high byte then out of range
		BNE	assOutOfRange
		TFR	B,A
assPostByteThenScanEndOfStmt
		CALL	assPostByte
		JUMP	assScanEndOfStmt

assModesImmed	CALL	skipSpacesCheckHashAtY
		BNE	assJmpBrkSyntax5
		JUMP	assModeImmed
assOutOfRange
		LDB	ZP_OPT
		ANDB	#$02				; check to see if errors suppressed - if so store 0 in offset!
		BEQ	assPostByteThenScanEndOfStmt	; store anything
brkOutOfRange
		DO_BRK_B
		FCB	$01, "Out of range", 0
	IF ASSEMBLER_6309
brk6309
		DO_BRK_B
		FCB	$3, "6309", 0
	ENDIF



assScanEndOfStmt
		LDA	ASS_VAR_FLAGS,S
	IF ASSEMBLER_6309
		; ignore if this is a 6309 instruction but not OPT $10
		BITA	#ASS_BITS_6309
		BEQ	1F				; not 6309 instr
		LDA	ZP_OPT
		BITA	#$10
		LBEQ	brk6309				; not 6309 mode
1
	ENDIF


		STU	ASS_VAR_PTR_SAV,S		; L8A5E
		LDU	VAR_P_PERCENT + 2
		STU	ZP_GEN_PTR
		LDA	#4
		BITA	ZP_OPT
		BEQ	assSkNotOpt4			; check for OPT 4+
		LDU	VAR_O_PERCENT + 2		; opt 4+ get O% into storage pointer
assSkNotOpt4	STU	ZP_ASS_OPSAVED
		LEAX	ASS_VAR_OP,S			; source for the copy
		LDB	ASS_VAR_OPLEN,S			; get opcode length (without any prefix)
		BPL	1F
		LDB	ZP_STRBUFLEN			; if -ve then store a string set up by EQUS
		LDX	#BASWKSP_STRING			; string buffer
1		STB	ZP_ASS_OPLEN
		BEQ	assSkNowtToStore
		LDA	ASS_VAR_FLAGS,S
		ANDA	#ASS_BITS_PRE			; check for a prefix
		BEQ	assStoreLoop
		INC	ZP_ASS_OPLEN
		INCB
		BRA	1F
assStoreLoop						; L8A83
		LDA	,X+
1
		STA	,U+

		INC	VAR_P_PERCENT + 3
		BNE	1F
		INC	VAR_P_PERCENT + 2
1		LDA	#4
		BITA	ZP_OPT
		BEQ	assSkNotOpt4_2
		INC	VAR_O_PERCENT + 3
		BNE	assSkNotOpt4_2
		INC	VAR_O_PERCENT + 2
assSkNotOpt4_2	DECB
		BNE	assStoreLoop

assSkNowtToStore					; L8AA5
		LDU	ASS_VAR_PTR_SAV,S
		LEAS	ASS_VAR_SPACE,S
		RTS

assJmpBrkSyntax5
		CALL	assJmpBrkSyntax4


assClass_DIR_parse
		CLR	ZP_ASS_OPLEN			; all directives are 0 length

		LDA	ASS_VAR_OP,S			; get "opcode" - for directives
		BNE	assDirNotOPT
		; OPT
		CALL	evalForceINT
		LDA	ZP_INT_WA+3
		STA	ZP_OPT
		JUMP	assScanEndOfStmt
assDirNotOPT
		CMPA	#1
		BNE	assDirNotEQU
		; we have EQUx
		LDA	,Y+
		ANDA	#$DF				; uppercase
		CMPA	#'S'
		BEQ	assDirEQUS
		LDB	#1
		CMPA	#'B'
		BEQ	1F
		INCB
		CMPA	#'W'
		BEQ	1F
		LDB	#4
		CMPA	#'D'
		BNE	assJmpBrkSyntax4
1		PSHS	B
		; get an integer (little endian)
		CALL	assEvalForceINT_LE
		LDX	#ZP_INT_WA
		PULS	B
assCopyBBytesToOpBufAndEnd
		CALL	assCopyBBytesToOpBuf
		JUMP	assScanEndOfStmt

		; copies B bytes from X to end of OpBuf
assCopyBBytesToOpBuf
		PSHS	U
		LEAU	4+ASS_VAR_OP,S			; point U at op buffer
		LDA	4+ASS_VAR_OPLEN,S
		LEAU	A,U				; add length of existing op bytes
1		LDA	,X+
		STA	,U+
		INC	4+ASS_VAR_OPLEN,S
		DECB
		BNE	1B
		PULS	U,PC

assDirEQUS	
		LDA	ZP_OPT
		PSHS	A				; this cribbed from 6502 basic not sure it's needed!
		CALL	evalAtY
		TSTA
		LBNE	brkTypeMismatch			; must be a string!
		PULS	A	
		STA	ZP_OPT
		COM	ASS_VAR_OPLEN,S			; indicate a string
		JUMP	assScanEndOfStmt
assDirNotEQU	CMPA	#5
		BHS	assDirSET
		TFR	A,B
		CMPB	#4
		BEQ	1F
		DECB
1		PSHS	B
		CALL	evalForceINT
		LDB	#4
		SUBB	,S
		LDX	#ZP_INT_WA
		ABX
		PULS	B
		CALL	assCopyBBytesToOpBuf
		JUMP	assScanEndOfStmt


assDirSET
assJmpBrkSyntax4					; L8A35
		JUMP	 brkSyntax


tblRegRegCodes						; index is push/pull bit, terminator is reg,reg code
		FCB	"CC", 	$80 + $0A
		FCB	"A", 	$80 + $08
		FCB	"B", 	$80 + $09
		FCB	"DP", 	$80 + $0B
		FCB	"X", 	$80 + $01
		FCB	"Y", 	$80 + $02
		FCB	"S", 	$80 + $04
		FCB	"U", 	$80 + $03
		FCB	"PC",	$80 + $05

		FCB	"D", 	$80 + $00


	IF ASSEMBLER_6309
		FCB	"W", 	$80 + $06 + ASS_BITS_6309
		FCB	"V", 	$80 + $07 + ASS_BITS_6309
		FCB	"E", 	$80 + $0E + ASS_BITS_6309
		FCB	"F", 	$80 + $0F + ASS_BITS_6309
	ENDIF
		FCB	$FF