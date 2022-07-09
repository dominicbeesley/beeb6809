assScanExit							; L891A
		DECA
		STA	ZP_OPT
		JUMP	skipSpacesAtYexecImmed
assScanEnter						; L8920
		CALL	skipSpacesY
		EORA	#']'
		BEQ	assScanExit				;  End of assembler
		LEAU	-1,U
		CALL	storeYasTXTPTR
		PSHS	U
		CALL	assScanNextOp
		PULS	X
		STX	ZP_TXTPTR2			; points at start of instruction
		STU	ZP_FPA
;;		LEAU	-1,U
		LDA	ZP_OPT
		LSRA
		BCC	assSkipList
		LDA	ZP_PRLINCOUNT
		ADDA	#$05
		STA	ZP_FPB + 4
		LDA	ZP_GEN_PTR			; print opcode address
		CALL	list_printHexByte
		LDA	ZP_GEN_PTR + 1
		CALL	list_printHexByteAndSpace
		LDB	#$FC
		LDA	ZP_ASS_OPLEN			; get back op len
		BPL	assPrintString			; if negative its a string
		LDA	ZP_STRBUFLEN			; get string len
assPrintString						; L894E
		STA	ZP_ASS_LIST_OPLEN
		BEQ	assPrintSk0LenOp
		LDX	ZP_ASS_OPSAVED
assPrintOpCodeLp		
		INCB
		BNE	L8961
		CALL	PrintCRclearPRLINCOUNT
		LDB	ZP_FPB + 4
		CALL	list_printBSpaces
		LDB	#$FD
L8961
		LDA	,X+
		CALL	list_printHexByteAndSpace
		DEC	ZP_ASS_LIST_OPLEN
		BNE	assPrintOpCodeLp
assPrintSk0LenOp
;;		TXA
;;		TAY
assPrintAlignOpTxtLp					;L896D
		INCB
		BEQ	assPrintAlignOpTxtSk
		PSHS	B
		LDB	#$03
		CALL	list_printBSpaces
		PULS	B
		BRA	assPrintAlignOpTxtLp
assPrintAlignOpTxtSk					; L8977
		LDB	#$0A
		LDX	ZP_TXTPTR2			; back to start of stmt in program
		LDA	,X+
		CMPA	#'.'				; if original stmt started with '.' print label
		BNE	assPrintLabelSk				
assPrintLabelLp						; L897F
		CALL	doListPrintTokenA
		DECB
		BNE	1F
		LDB	#$01
1		LDA	,X+
		CMPX	ZP_ASS_LBLEND
		BLS	assPrintLabelLp
assPrintLabelSk						; L898E
		CALL	list_printBSpaces
		LEAX	-1,X
L8992
		CMPA	,X+				; skip spaces at start?
		BEQ	L8992
		LEAX	-1,X
L8997
		LDA	,X
		CMPA	#$3A
		BEQ	L89A7
		CMPA	#$0D
		BEQ	L89AB
L89A1
		CALL doListPrintTokenA
		LEAX	1,X
		BRA	L8997
L89A7		CMPX	ZP_FPA
		BLO	L89A1
L89AB		CALL	PrintCRclearPRLINCOUNT
assSkipList	
;;		LEAU	-1,U
L89B1		LDA	,U+
		CMPA	#':'
		BEQ	L89BC
		CMPA	#$0D
		BNE	L89B1
L89BC		LEAU 	-1,U
		CALL	scanNextStmtFromY
		LDA	,U+
		CMPA	#':'
		BEQ	L89D1
		TFR	U,D
;;;		LDA	ZP_TXTPTR + 1
		CMPA	#$07
		BNE	L89CE
		JUMP	immedPrompt
L89CE		CALL	doTraceOrEndAtELSE
L89D1		JUMP	assScanEnter

