;		
;		
;		
;			;  ASSEMBLER
;			;  =========
;			;  Packed mnemonic table, low bytes
;			;  --------------------------------

	; 	4	B	0       A
	; 0 1 0 0 1 0 1 1 0 0 0 0 1 0 1 0
	; *-|-------| |-------| |-------|
	;         $14       $18       $0A
	;	    T         X         J

	; 	0	A	4       B
	; 0 0 0 0 1 0 1 0 0 1 0 0 1 0 1 1
	; *-|-------| |-------| |-------|
	;         $02       $12       $0B
	;	    B         R         K

ASM_OPCOUNT		EQU	$45

assOpMungeLowBytes					; L884D
		FCB  $4B				; 'BRK'
		FCB  $83				; 'CLC'
		FCB  $84				; 'CLD'
		FCB  $89				; 'CLI'
		FCB  $96				; 'CLV'
		FCB  $B8				; 'DEX'
		FCB  $B9				; 'DEY'
		FCB  $D8				; 'INX'
		FCB  $D9				; 'INY'
		FCB  $F0				; 'NOP'
		FCB  $01				; 'PHA'
		FCB  $10				; 'PHP'
		FCB  $81				; 'PLA'
		FCB  $90				; 'PLP'
		FCB  $89				; 'RTI'
		FCB  $93				; 'RTS'
		FCB  $A3				; 'SEC'
		FCB  $A4				; 'SED'
		FCB  $A9				; 'SEI'
		FCB  $38				; 'TAX'
		FCB  $39				; 'TAY'
		FCB  $78				; 'TSX'
		FCB  $01				; 'TXA'
		FCB  $13				; 'TXS'
		FCB  $21				; 'TYA'
		FCB  $A1				; 'DEA'
		FCB  $C1				; 'INA'
		FCB  $19				; 'PHY'
		FCB  $18				; 'PHX'
		FCB  $99				; 'PLY'
		FCB  $98				; 'PLX'
		FCB  $63				; 'BCC'
		FCB  $73				; 'BCS'
		FCB  $B1				; 'BEQ'
		FCB  $A9				; 'BMI'
		FCB  $C5				; 'BNE'
		FCB  $0C				; 'BPL'
		FCB  $C3				; 'BVC'
		FCB  $D3				; 'BVS'
		FCB  $41				; 'BRA'
		FCB  $C4				; 'AND'
		FCB  $F2				; 'EOR'
		FCB  $41				; 'ORA'
		FCB  $83				; 'ADC'
		FCB  $B0				; 'CMP'
		FCB  $81				; 'LDA'
		FCB  $43				; 'SBC'
		FCB  $6C				; 'ASL'
		FCB  $72				; 'LSR'
		FCB  $EC				; 'ROL'
		FCB  $F2				; 'ROR'
		FCB  $A3				; 'DEC'
		FCB  $C3				; 'INC'
		FCB  $92				; 'CLR'
		FCB  $9A				; 'STZ'
		FCB  $18				; 'CPX'
		FCB  $19				; 'CPY'
		FCB  $62				; 'TSB'
		FCB  $42				; 'TRB'
		FCB  $34				; 'BIT'
		FCB  $B0				; 'JMP'
		FCB  $72				; 'JSR'
		FCB  $98				; 'LDX'
		FCB  $99				; 'LDY'
		FCB  $81				; 'STA'
		FCB  $98				; 'STX'
		FCB  $99				; 'STY'
		FCB  $14				; 'OPT'
		FCB  $35				; 'EQU'
			;  Packed mnemonic table, high bytes
			;  ---------------------------------
assOpMungeHiBytes					; L8892
		FCB  $0A				; 'BRK'
		FCB  $0D				; 'CLC'
		FCB  $0D				; 'CLD'
		FCB  $0D				; 'CLI'
		FCB  $0D				; 'CLV'
		FCB  $10				; 'DEX'
		FCB  $10				; 'DEY'
		FCB  $25				; 'INX'
		FCB  $25				; 'INY'
		FCB  $39				; 'NOP'
		FCB  $41				; 'PHA'
		FCB  $41				; 'PHP'
		FCB  $41				; 'PLA'
		FCB  $41				; 'PLP'
		FCB  $4A				; 'RTI'
		FCB  $4A				; 'RTS'
		FCB  $4C				; 'SEC'
		FCB  $4C				; 'SED'
		FCB  $4C				; 'SEI'
		FCB  $50				; 'TAX'
		FCB  $50				; 'TAY'
		FCB  $52				; 'TSX'
		FCB  $53				; 'TXA'
		FCB  $53				; 'TXS'
		FCB  $53				; 'TYA'
		FCB  $10				; 'DEA'
		FCB  $25				; 'INA'
		FCB  $41				; 'PHY'
		FCB  $41				; 'PHX'
		FCB  $41				; 'PLY'
		FCB  $41				; 'PLX'
		FCB  $08				; 'BCC'
		FCB  $08				; 'BCS'
		FCB  $08				; 'BEQ'
		FCB  $09				; 'BMI'
		FCB  $09				; 'BNE'
		FCB  $0A				; 'BPL'
		FCB  $0A				; 'BVC'
		FCB  $0A				; 'BVS'
		FCB  $0A				; 'BRA'
		FCB  $05				; 'AND'
		FCB  $15				; 'EOR'
		FCB  $3E				; 'ORA'
		FCB  $04				; 'ADC'
		FCB  $0D				; 'CMP'
		FCB  $30				; 'LDA'
		FCB  $4C				; 'SBC'
		FCB  $06				; 'ASL'
		FCB  $32				; 'LSR'
		FCB  $49				; 'ROL'
		FCB  $49				; 'ROR'
		FCB  $10				; 'DEC'
		FCB  $25				; 'INC'
		FCB  $0D				; 'CLR'
		FCB  $4E				; 'STZ'
		FCB  $0E				; 'CPX'
		FCB  $0E				; 'CPY'
		FCB  $52				; 'TSB'
		FCB  $52				; 'TRB'
		FCB  $09				; 'BIT'
		FCB  $29				; 'JMP'
		FCB  $2A				; 'JSR'
		FCB  $30				; 'LDX'
		FCB  $30				; 'LDY'
		FCB  $4E				; 'STA'
		FCB  $4E				; 'STX'
		FCB  $4E				; 'STY'
		FCB  $3E				; 'OPT'
		FCB  $16				; 'EQU'
			;  ASSEMBLER OPCODE TABLE
			;  ======================
assOpcodeBytes						; L88D7
		FCB 	$00				; BRK
		FCB	$18				; CLC
		FCB	$D8				; CLD
		FCB	$58				; CLI
		FCB	$B8				; CLV
		FCB	$CA				; DEX
		FCB	$88				; DEY
		FCB	$E8				; INX
		FCB	$C8				; INY
		FCB	$EA				; NOP
		FCB	$48				; PHA
		FCB	$08				; PHP
		FCB	$68				; PLA
		FCB	$28				; PLP
		FCB	$40				; RTI
		FCB	$60				; RTS
		FCB	$38				; SEC
		FCB	$F8				; SED
		FCB	$78				; SEI
		FCB	$AA				; TAX
		FCB	$A8				; TAY
		FCB	$BA				; TSX
		FCB	$8A				; TXA
		FCB	$9A				; TXS
		FCB	$98				; TYA
		FCB	$3A				; DEC A
		FCB	$1A				; INC A
		FCB	$5A				; PHY
		FCB	$DA				; PHX
		FCB	$7A				; PLY
		FCB	$FA				; PLX
ASM_OPLASTIMPLIED	EQU	*-assOpcodeBytes		; $1F
		FCB	$90				; BCC
		FCB	$B0				; BCS
		FCB	$F0				; BEQ
		FCB	$30				; BMI
		FCB	$D0				; BNE
		FCB	$10				; BPL
		FCB	$50				; BVC
		FCB	$70				; BVS
		FCB	$80				; BRA
ASM_OPLASTBRA8		EQU	*-assOpcodeBytes		;$28
		FCB	$21				; AND
		FCB	$41				; EOR
		FCB	$01				; ORA
		FCB	$61				; ADC
		FCB	$C1				; CMP
		FCB	$A1				; LDA
		FCB	$E1				; SBC
ASM_OPASL		EQU	*-assOpcodeBytes		;$2F
		FCB	$06				; ASL
		FCB	$46				; LSR
		FCB	$26				; ROL
		FCB	$66				; ROR
ASM_OPDEC			EQU	*-assOpcodeBytes	;$33
		FCB	$C6				; DEC
		FCB	$E6				; INC
ASM_OPSTZ			EQU	*-assOpcodeBytes	;$35
		FCB	$9C				; STZ
		FCB	$9C				; CLR
ASM_OPCPX			EQU	*-assOpcodeBytes	;$37		
		FCB	$E0				; CPX
		FCB	$C0				; CPY
ASM_OPTSB			EQU	*-assOpcodeBytes	;$39		
		FCB	$00				; TSB
		FCB	$10				; TRB
ASM_OPBIT			EQU	*-assOpcodeBytes	;$3B		
		FCB	$24				; BIT
		FCB	$4C				; JMP
ASM_OPJSR			EQU	*-assOpcodeBytes	;$3D		
		FCB	$20				; JSR
		FCB	$A2				; LDX
		FCB	$A0				; LDY
ASM_OPNUM_STA		EQU	*-assOpcodeBytes		;$40
		FCB	$81				; STA
		FCB	$86				; STX
		FCB	$84				; STY
ASM_OPNUM_MAX		EQU	*-assOpcodeBytes		;$43
	

assScanLabel	LEAY	1,Y				; L89D4
		CALL	findVarOrAllocEmpty
		BEQ	assJmpBrkSyntax
		BCS	assJmpBrkSyntax
		CALL	pushVarPtrAndType
		CALL	GetP_percent			;  Get P%
		STA	ZP_VARTYPE
		CALL	storeEvaledExpressioninStackedVarPTr
;;		CALL	copyTXTOFF2toTXTOFF
		STY	ZP_ASS_LBLEND		
assScanNextOp	CLR	ZP_ASS_OPLEN
		CALL	skipSpacesY			; L89EB
		LEAY	-1,Y
		CLR	ZP_FPB + 2			; clear opcode bits accumulator
		CMPA	#':'
		BEQ	assScanEndOfStmt		;  End of statement
		CMPA	#$0D
		BEQ	assScanEndOfStmt		;  End of line
		CMPA	#'\'
		BEQ	assScanEndOfStmt		;  Comment
		CMPA	#'.'
		BEQ	assScanLabel			;  Label
		LDX	#$03				;  Prepare to fetch three characters
assScanOpLoop						; L8A06	
		LDA	,Y+		
		BMI	assScanTokFound			;  Token, check for tokenised AND, EOR, OR
		CMPA	#' '
		BEQ	assScanOpSkSpace		;  Space, step past
		LDB	#$05
		ASLA
		ASLA
		ASLA
assScanOpLoop2	ASLA					; L8A17
		ROL	ZP_FPB + 2			; roll 5 LSB's of opcode char into accum
		ROL	ZP_FPB + 3
		DECB
		BNE	assScanOpLoop2
		LEAX	-1,X
		BNE	assScanOpLoop
assScanOpSkSpace					; L8A22
		LDX	#ASM_OPCOUNT			; 
		LDD	ZP_FPB + 2			; encoded opcode
assScanOpMatchLp
		CMPA	assOpMungeLowBytes-1,X
		BNE	1F
		CMPB	assOpMungeHiBytes-1,X
		BEQ	assScanOpMatchFound
1		LEAX	-1,X
		BNE	assScanOpMatchLp
assJmpBrkSyntax						; L8A35
		JUMP	 brkSyntax


assScanTokFound						; L8A38
		LDX	#$29				;  opcode number for 'AND'
		CMPA	#tknAND
		BEQ	assScanOpMatchFound		;  Tokenised 'AND'
		LEAX	1,X				;  opcode number for 'EOR'
		CMPA	#tknEOR
		BEQ	assScanOpMatchFound		;  Tokenised 'EOR'
		LEAX	1,X
		CMPA	#tknOR				;  opcode number for 'ORA'
		BNE	assJmpBrkSyntax			;  Not tokenised 'OR'
		LDA	,Y+				;  Get next character
		ANDA	#$DF				;  Ensure upper case
		CMPA	#'A'			
		BNE	assJmpBrkSyntax			; Ensure 'OR' followed by 'A'


			;  Tokenised opcode found
			;  ----------------------
assScanOpMatchFound
		LDA	assOpcodeBytes-1,X		; get 6502 opcode byte
		STA	ZP_DUNNO			; store for later
		LDB	#$01				; length of opcode+postbytes
		STB	ZP_ASS_OPLEN			; store
		CMPX	#ASM_OPLASTIMPLIED + 1
		BHS	assProcessOpArgs
assScanEndOfStmt
		PSHS	U				; L8A5E
		LDU	VAR_P_PERCENT + 2
		STU	ZP_GEN_PTR
		LDA	ZP_OPT
		CMPA	#$04
		BLO	assSkNotOpt4			; check for OPT 4+
		LDU	VAR_O_PERCENT + 2		; opt 4+ get O% into storage pointer
assSkNotOpt4	STU	ZP_ASS_OPSAVED
		LDX	#ZP_ASS_OPBUF			; source for the copy
		LDB	ZP_ASS_OPLEN
		BEQ	assSkNowtToStore
		BPL	assStoreLoop
		LDB	ZP_STRBUFLEN			; i -ve then store a string...
		LDX	#BASWKSP_STRING			; string buffer
		BEQ	assSkNowtToStore
assStoreLoop						; L8A83
		LDA	,X+
		STA	,U+

		INC	VAR_P_PERCENT + 3
		BNE	1F
		INC	VAR_P_PERCENT + 2
1		BCC	assSkNotOpt4_2
		INC	VAR_O_PERCENT + 3
		BNE	assSkNotOpt4_2
		INC	VAR_O_PERCENT + 2
assSkNotOpt4_2	DECB
		BNE	assStoreLoop

assSkNowtToStore					; L8AA5
		PULS	U				; restore U
		RTS
assProcessOpArgs					; proccess opcode arguments
		CMPX	#ASM_OPLASTBRA8 + 1
		BHS	assProcOpSkNotBxx

		; do Bxx branch instructions

		CALL	evalForceINT
		LDD	ZP_INT_WA + 2
		SUBD	VAR_P_PERCENT + 2		; subtract to get rel
		SUBD	#2				; TODO CHECK - should this be 2?
		CMPD	#$007F
		BGT 	assOutOfRange
		CMPD	#$FF80
		BGE	assStorBxxOffset
assOutOfRange						; L8AC6
		LDB	ZP_OPT
		ANDB	#$02				; check to see if errors suppressed - if so store 0 in offset!
		BEQ	assStorBxxOffset
brkOutOfRange
		DO_BRK_B
		FCB	$01, "Out of range", 0
assStorBxxOffset
		STB	ZP_ASS_OPBUF + 1		; store branch offset


ass2OpeLenScanEndOfStmt					; L8AE1
		LDA	#2
		STA	ZP_ASS_OPLEN
		JUMP	assScanEndOfStmt


assProcOpSkNotBxx					; L8AE6
		CMPX	#ASM_OPASL+1
		BHS	assProcOpASLtoINC
		CALL	skipSpacesCheckHashAtY
		BNE	assProcOpSkNotImmed		; no # it's not an immed
		CALL	assOpcodeAdd8
assProcOpParseImmed					; L8AF2
		CALL	assEvalForceINT_LE
assProcOpStoreIntAsPostByte		
		LDA	ZP_INT_WA + 1			; check to see if > 255
ass2OpeLenScanEndOfStmtorBrkIfNE		
		BEQ	ass2OpeLenScanEndOfStmt
brkByte							; L8AF9
		DO_BRK_B
		FCB	$02, "Byte", 0
assProcOpASLtoINC					; L8B00
		CMPX	#ASM_OPNUM_STA + 1
		BNE	asmSkNotSTA
		CALL	skipSpacesY
assProcOpSkNotImmed					; L8B07
		CMPA	#'('
		BNE	asmSkNotIndirBrack
		CALL	assEvalForceINT_LE		; get value
		CALL	skipSpacesY			
		CMPA	#')'
		BNE	asmSkCheckIndirComma		
		CALL	assOpcodeAdd16			; is indirect, add 16 to opcode
		CALL	skipSpacesCheckCommaAtY
		BEQ	asmSkPostIndexIndir	
		LEAY	-1,Y
		INC	ZP_ASS_OPBUF			; just indirect zp, inc opcode
		BRA	assProcOpStoreIntAsPostByte	; store post byte and continue
asmSkPostIndexIndir
		CALL	skipSpacesY
		ANDA	#$DF				; to upper
		CMPA	#'Y'
		BEQ	assProcOpStoreIntAsPostByte
		BRA	brkIndex
asmSkCheckIndirComma
		CMPA	#','
		BNE	brkIndex
		CALL	SkipSpaceCheckXAtY
		BNE	brkIndex
		CALL	skipSpacesY
		CMPA	#')'
		BEQ	assProcOpStoreIntAsPostByte
brkIndex	DO_BRK_B
		FCB	$03, "Index", 0
asmSkNotIndirBrack					; L8B44
		CALL	assDecYEvalForceINT_LE
		CALL	skipSpacesCheckCommaAtY
		BNE	assOpAdd4CheckIfZpOrAbs
		CALL	assOpcodeAdd16			; got a comma add 16 to op code for XXX,X or XXX,Y
		CALL	SkipSpaceCheckXAtY
		BEQ	assOpAdd4CheckIfZpOrAbs				
		CMPA	#'Y'				; so it should be a Y
		BNE	brkIndex
assOpAdd8Len3						; L8B58
		CALL	assOpcodeAdd8
		JUMP	assScanEndOfStmtOpLen3
assOpAdd4CheckIfZpOrAbs					; L8B5E
		CALL	assOpcodeAdd4
assOpDecYCheckIfZpOrAbs					; L8B61

		LEAY	-1,Y
assOpCheckIfZpOrAbs					; L8B61
		LDA	ZP_INT_WA + 1
		BNE	assOpAdd8Len3
		BRA	ass2OpeLenScanEndOfStmtorBrkIfNE
asmSkNotSTA						; L8B67
		CMPX	#ASM_OPSTZ+1
		BHS	assSkHSSTZ				; HS opcode for STZ
		CALL	skipSpacesY
		ANDA	#$DF
		CMPA	#'A'				; check for ROLA etc
		BEQ	assSkCheckXXX_A
assSkNotXXX_A						; L8B74
		CALL 	assDecYEvalForceINT_LE
		CALL	skipSpacesCheckCommaAtY
		BNE	assOpDecYCheckIfZpOrAbs		; no comma, store as ZP or ABS
		CALL	assOpcodeAdd16			; indexed
		CALL	SkipSpaceCheckXAtY		; make sure its ,X!
		BEQ	assOpCheckIfZpOrAbs		; if it is we're off
L8B84braBrkIndex
		BRA	brkIndex			; if not complain
assSkCheckXXX_A
		LDA	,Y				; check char after 'A'
		CALL	checkIsValidVariableNameChar	; carry set if it's a variable char
		BCS	assSkNotXXX_A			; looks like a variable name instead of A for register A
		LDB	#$16				; opcode = INCA-4
		CMPX	#ASM_OPDEC+1
		BLO	skAssNotINCDEC
		BNE	skAssNotDEC_A
		LDB	#$36				; opcode = DECA-4
skAssNotDEC_A	STB	ZP_ASS_OPBUF			; store modified code
skAssNotINCDEC
		CALL	assOpcodeAdd4
;;		LDY	#$01				; set single byte op - not needed already set?

		BRA	L8C00jumpassScanEndOfStmt
assSkHSSTZ
		CMPX	#ASM_OPCPX + 1
		BHS	assSkOpHS_CPX

		; do STZ 

		CALL	assEvalForceINT_LE
		LDB	#$03
		STB	ZP_ASS_OPLEN			; store len
		DECB					; how much to add to opcode for ,X
		LDA	ZP_INT_WA + 1
		BNE	assSkSTZnotZP
		LDB	#$10				; how much to add to opcode for ,X
		LDA	#$64				; STZ d
		STA	ZP_ASS_OPBUF			; store opcode
		DEC	ZP_ASS_OPLEN
assSkSTZnotZP						; L8BB7
		CALL	skipSpacesCheckCommaAtY
		BNE	assSkSTZnotIndex
		CALL	SkipSpaceCheckXAtY
		BNE	L8B84braBrkIndex
		ADDB	ZP_ASS_OPBUF			; correct opcode for $64 STZ d,X
		STB	ZP_ASS_OPBUF
assSkSTZnotIndex					; L8BC7
		LEAY	-1,Y
		BRA	L8C00jumpassScanEndOfStmt
assSkOpHS_CPX
		CMPX	#ASM_OPBIT + 1
		BHS	assSkHS_BIT
		CMPX	#ASM_OPTSB+1
		BHS	assSkTSB_TRB

		; do CPX/CPY

		CALL	skipSpacesCheckHashAtY
		BEQ	assJumpProcOpParseImmed
		LEAY	-1,Y
assSkTSB_TRB						; L8BD9
		CALL	assEvalForceINT_LE
assBraOpAdd4CheckIfZpOrAbs				; L8BDC
		JUMP	assOpAdd4CheckIfZpOrAbs
assSkBIT						; L8BDE
		CALL	skipSpacesCheckHashAtY
		BNE	assSkNotXXX_A
		LDB	#$89				; opcode for BIT #
		STB	ZP_DUNNO
assJumpProcOpParseImmed					; L8BE7
		JUMP	assProcOpParseImmed
assSkHS_BIT						; L8BEA
		BEQ	assSkBIT
		CMPX	#ASM_OPJSR + 1
		BEQ	assSkJSR
		BHS	assSkHI_JSR

		; jmp

		CALL	skipSpacesY
		CMPA	#'('
		BEQ	assSkJMPIndir
		LEAY	-1,Y
assSkJSR	CALL	assEvalForceINT_LE
assScanEndOfStmtOpLen3					; L8BFE
		LDB	#3
		STB	ZP_ASS_OPLEN
L8C00jumpassScanEndOfStmt
		JUMP assScanEndOfStmt
assSkJMPIndir
		CALL	assOpcodeAdd16
		CALL	assOpcodeAdd16
		CALL	assEvalForceINT_LE
		CALL	skipSpacesY
		CMPA	#')'
		BEQ	assScanEndOfStmtOpLen3
		CMPA	#','
		BNE	L8C26jmpbrkIndex
		CALL	assOpcodeAdd16
		CALL	SkipSpaceCheckXAtY
		BNE	L8C26jmpbrkIndex
		CALL	skipSpacesY
		CMPA	#')'
		BEQ	assScanEndOfStmtOpLen3
L8C26jmpbrkIndex
		JUMP	brkIndex
assSkHI_JSR
		CMPX	#ASM_OPNUM_MAX+1
		BHS	assSkProcDirectives
		LDA	ZP_FPB + 2
		EORA	#$01
		ANDA	#$1F
		PSHS	A				; this now contains %000LI00X where 
							; L = 1 for load, 0 for store
							; I = 1 for X/Y
							; X = 1 for X, 0 for Y
							; I = 0, X = 0 for A
		CMPX	#ASM_OPNUM_STA+1
		BHS	assSkdoST_
		CALL	skipSpacesCheckHashAtY
		BNE	assSkdoLD_notImmed
		LEAS	1,S				; discard number from stack
		BRA	assJumpProcOpParseImmed
assSkdoLD_notImmed					; L8C40
		CALL	assDecYEvalForceINT_LE
		PULS	A
		STA	ZP_GEN_PTR
		CALL	skipSpacesCheckCommaAtY
		BNE	assBraOpAdd4CheckIfZpOrAbs
		CALL	skipSpacesY
		ANDA	#$1F				; this contains the index, either X (18) or Y (19) (opposite of above)
		CMPA	ZP_GEN_PTR			; check LDX xxxx,Y or LDY xxxx,X
		BNE	L8C26jmpbrkIndex
		CALL	assOpcodeAdd16
		JUMP	assBraOpAdd4CheckIfZpOrAbs
assSkdoST_						; L8C59
		CALL	assEvalForceINT_LE
		PULS	A			
		STA	ZP_GEN_PTR
		CALL	skipSpacesCheckCommaAtY
		BNE	assSkdoST_notIndex2
		CALL	skipSpacesY
		ANDA	#$1F
		CMPA	ZP_GEN_PTR
		BNE	L8C26jmpbrkIndex
		CALL	assOpcodeAdd16
		LDA	ZP_INT_WA + 1
		BEQ	assSkdoST_notIndex
		JUMP	brkByte
assSkdoST_notIndex2
		LEAY	-1,Y		
assSkdoST_notIndex					; L8C77
		JUMP assOpCheckIfZpOrAbs			; TODO: remove and use LBxx
assSkProcDirectives
		; OPT
		BNE	assSkEQU
		CALL	evalForceINT
		LDA	ZP_INT_WA + 3
		STA	ZP_OPT
		CLR	ZP_ASS_OPLEN
		BRA	L8CB1jmpAssScanEndOfStmt
assSkEQU
		TODODEADEND "EQU"
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
L8CB1jmpAssScanEndOfStmt
		JUMP assScanEndOfStmt
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
;		BRA L8CB1jmpAssScanEndOfStmt
assOpcodeAdd16						; L8CC9
		CALL	assOpcodeAdd8
assOpcodeAdd8						; L8CCC
		CALL	assOpcodeAdd4
assOpcodeAdd4						; L8CCF
		LDA	ZP_DUNNO
		ADDA	#4
		STA	ZP_DUNNO
		RTS
SkipSpaceCheckXAtY
		CALL	skipSpacesY
		ANDA	#$DF
		CMPA	#'X'
		RTS
