		; NAM  SPOOL MODULE
		; OPT  PAG
	*************************************************
	*
	*  PRINTER SPOOLING MODULE TSC FLEX 3.01
	*
	*************************************************


		; SPC  1
		ORG	$C700
	*ENTRY JUMP TABLE
CNGTSK		JMP	>SCHED				; SWI ENTRY POINT
LOOP		JMP	>LOOP
		JMP	>STARSP				; SPOOL ENTRY
		JMP	>TSTSET				; TEST AND SET FLAG
		JMP	>CLRFLG				; CLEAR FLAG
		JMP	>IENTRY				; IRQ ENTRY
		; SPC  1
	*PROGRAM VARIABLES
FEED		FCB	$0C				; FORM FEED
		FCB	0,0,0,0
		FDB	QBEGIN
QPOINT		FDB	QBEGIN
QCOUNT		FCB	$00
CRFLAG		FCB	$00
CANCEL		FCB	$00				; CANCEL PRINTING FLAG
STOP		FCB	$00				; STOP PRINTING FLAG
		; SPC  1
	*TASK SCHEDULER
	*ENTRY VIA SWI3 OR IRQ
IENTRY		RTI				;  NO LONGER USED
		NOP
SCHED		ORCC	#$10				; MASK IRQ
		LDX	>CURTSK				; GET CURRENT TASK POINTER
		STS	$02,X				; SAVE STACK
		TST	>MODE
		BNE	FORGND
		LDX	#$CCFC				; POINT TO BACKGROUND TASK
		INC	>MODE
		TST	,X				; TASK NOT ACTIVE?
		BEQ	FORGND
TSKRTN		STX	>CURTSK
		LDS	$02,X				; RESTORE STACK
		RTI
FORGND		LDX	#$CCF8				; POINT TO FOREGROUND TASK
		CLR	>MODE				; SET TO FORGND.MODE
		BRA	TSKRTN
		; PAG 
	********************************************
	*
	* PRINT SPOOL BACKGROUND TASK
	* SET UP BY PRINT.CMD
	*
	********************************************


STARSP		ORCC	#$10				; MASK IRQ
		TST	>QCOUNT				; EMPTY?
		BEQ	SPSTOP
		LDX	>QPOINT
		LDA	,X				; GET DRIVE #
		PSHS	A
		LDD	$01,X				; GET TRACK SECTOR
		LDX	#SPLFCB
		STD	$40,X				; SET TRACK SECTOR
		PULS	A
		STA	$03,X				; SET DRIVE #
		CLR	,X				; SET READ BYTE
		LDA	#$01				; FAKE OPEN FOR READ
		STA	$02,X
		CLR	$22,X
		CLR	$3B,X				; SPACE EXPAND ON
STOPIT		TST	>STOP				; STOP REQUEST?
		BEQ	NEXTCH
		SWI3				;  LET OTHER TASK RUN
		NOP
		BRA	STOPIT
		; SPC  1
SPSTOP		ANDCC	#$EF				; CLEAR IRQ MASK
TURNOF		JSR	[TIMOFF]
		CLR	>$CCFC				; TURN OFF BACKGND TASK
		SWI3				;  CHANGE TASK
		NOP
		BRA	TURNOF				; JUST IN CASE
		; SPC  1
	*TEST FLAG SET IF CLEAR
	*LOOP AS LONG AS SET
TSTSET		ORCC	#$10				; MASK IRQ
		TST	>FLAG
		BEQ	OKCONT				; CLEAR SO CONTINUE
		SWI3				;  GIVE UP AND WAIT
		NOP
		BRA	TSTSET
OKCONT		INC	>FLAG				; SET FLAG
		RTS
		; SPC  1
	*CLEAR FMS IN USE FLAG
CLRFLG		CLR	>FLAG
		ANDCC	#$EF				; CLEAR IRQ FLAG
		RTS
		; SPC  1
	*PRINTER SERVICE ROUTINES
NEXTCH		TST	>CANCEL				; ABORT REST OF FILE?
		BNE	WRAPUP				; DONE IF SET
		LDX	#SPLFCB
		JSR	>FMCALL				; READ BYTE FROM FILE
		BNE	WRAPUP				; IF ERROR THEN DONE
		TST	>CRFLAG				; LAST CHAR=RETURN?
		BEQ	LINFED
		CLR	>CRFLAG				; SET LAST CHAR NOT CR
		CMPA	#$0A				; IS IT LINE FEED
		BEQ	PRINT				; THEN PRINT IT
		PSHS	A				; SAVE NEXT CHARACTER
		LDA	#$0A
		BSR	OUTPUT				; PRINT LINE FEED
		PULS	A				; GET NEXT CHARACTER
LINFED		CMPA	#$0D				; IS IT CR?
		BNE	PRINT				; PRINT IT IF NOT CR
		STA	>CRFLAG				; SET CRFLAG FOR LINE FEED
PRINT		BSR	OUTPUT
		BRA	NEXTCH				; LOOP FOR NEXT CHAR.
		; SPC  1
	*END OF FILE CLEANUP
WRAPUP		LDA	#$0D				; OUTPUT RETURN
		BSR	OUTPUT
		LDA	#$0A				; OUTPUT LINE FEED
		BSR	OUTPUT
		LDA	>FEED				; OUTPUT FORM FEED
		BSR	OUTPUT
		CLR	>CANCEL
		LDX	>QPOINT				; POINT TO QUE
		TST	$03,X				; REPEAT COUNT=0?
		BEQ	NXTFIL
		DEC	$03,X				; DEC REPEAT COUNT
		JMP	>STARSP				; RESTART PRINTING
		; SPC  1
NXTFIL		LEAX	$04,X				; BUMP QUE POINTER
		CMPX	#QEND				; END OF QUE?
		BNE	NOTEND
		LDX	#QBEGIN				; MAKE QUE WRAP AROUND
NOTEND		STX	>QPOINT
		DEC	>QCOUNT
		JMP	>STARSP
		; SPC  1
OUTPUT		JSR	>LPREDY				; PRINTER READY?
		BMI	SENDIT
		SWI3				;  NOT READY SO GIVE UP TIME
		NOP
		BRA	OUTPUT				; KEEP TESTING
		; SPC  1
SENDIT		JMP	>LPOUT				; PRINT CHAR.
		; SPC  1
QBEGIN		EQU	$C810
QEND		EQU	$C840
SPLFCB		EQU	$CAC0				; SPOOL FILE CTRL BLOCK
FLAG		EQU	$CC30				; FMS IN USE FLAG
CURTSK		EQU	$CC31				; CURRENT TASK POINTER
MODE		EQU	$CC34				; MODE FLAG
LPREDY		EQU	$CCD8				; PRINTER READY CHECK
LPOUT		EQU	$CCE4				; PRINTER OUTPUT
IHANDL		EQU	$D3E7				; IRQ HANDLER
TIMOFF		EQU	$D3ED				; TURN OFF TIMER
FMCALL		EQU	$D406				; CALL FILE MANAGER
