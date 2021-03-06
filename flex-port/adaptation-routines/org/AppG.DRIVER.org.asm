	* DRIVER ROUTINES FOR SWTPC MF-68
	*
	* COPYRIGHT (C) 1980 BY
	* TECHNICAL SYSTEMS CONSULTANTS, INC.
	* 111 PROVIDENCE RD, CHAPEL HILL, NC 27514
	*
	* THESE DRIVERS ARE FOR A SINGLE-SIDED, SINGLE
	* DENSITY SWTPC MF-68 MINIFLOPPY DISK SYSTEM.
	*
	* THE DRIVER ROUTINES PERFORM THE FOLLOWING
	* 1. READ SINGLE SECTOR - DREAD
	* 2. WRITE SINGLE SECTOR - DWRITE
	* 3. VERIFY WRITE OPERATION - VERIFY
	* 4. RESTORE HEAD TO TRACK 00 - RESTOR
	* 5. DRIVE SELECTION - DRIVE
	* 6. CHECK READY - DCHECK
	* 7. QUICK CHECK READY - DQUICK
	* 8. DRIVER INITIALIZATION - DINIT
	* 9. WARM START ROUTINE - DWARM
	* 10. SEEK ROUTINE - DSEEK
	*EQUATES
DRQ		EQU	2				; DRQ BIT MASK
BUSY		EQU	1				; BUSY MASK
RDMSK		EQU	$1C				; READ ERROR MASK
VERMSK		EQU	$18				; VERIFY ERROR MASK
WTMSK		EQU	$5C				; WRITE ERROR MASK
DRVREG		EQU	$E014				; DRIVE REGISTER
COMREG		EQU	$E018				; COMMMAND REGISTER
TRKREG		EQU	$E019				; TRACK REGISTER
SECREG		EQU	$E01A				; SECTOR REGISTER
DATREG		EQU	$E01B				; DATA REGISTER
RDCMND		EQU	$8C				; READ COMMAND
WTCMND		EQU	$AC				; WRITE COMMAND
RSCMND		EQU	$0B				; RESTORE COMMAND
SKCMND		EQU	$1B				; SEEK COMMAND
PRCNT		EQU	$CC34
	***********************************************
	* DISK DRIVER ROUTINE JUMP TABLE
	***********************************************
		ORG	$DE00
DREAD		JMP	READ
DWRITE		JMP	WRITE
DVERFY		JMP	VERIFY
RESTOR		JMP	RST
DRIVE		JMP	DRV
DCHECK		JMP	CHKRDY
DQUICK		JMP	CHKRDY
DINIT		JMP	INIT
DWARM		JMP	WARM
DSEEK		JMP	SEEK
	***********************************************
	* GLOBAL VARIABLE STORAGE
CURDRV		FCB	0				; CURRENT DRIVE
DRVTRK		FDB	0,0				; CURRENT TRACK PER DRIVE
	* INIT AND WARM
	*
	* DRIVER INITIALIZATION
INIT		LDX	#CURDRV				; POINT TO VARIABLES
		LDB	#5				; NO. OF BYTES TO CLEAR
INIT2		CLR	0,X+				; CLEAR THE STORAGE
error ;;;; !!!! ;;;; DE2A 5A DECB
		BNE	INIT2				; LOOP TIL DONE
WARM		RTS				;  WARM START NOT NEEDED
	* READ
	*
	* READ ONE SECTOR
READ		BSR	SEEK				; SEEK TO TRACK
		LDA	#RDCMND				; SETUP READ SECTOR COMMAND
		TST	PRCNT				; ARE WE SPOOLING?
		BEQ	READ2				; SKIP IF NOT
		SWI3				;  ELSE, SWITCH TASKS
		NOP				;  NECESSARY FOR SBUG
READ2		SEI				;  DISABLE INTERRUPTS
		STA	COMREG				; ISSUE READ COMMAND
		LBSR	DEL28				; DELAY
		CLRB				;  GET SECTOR LENGTH (=256)
READ3		LDA	COMREG				; GET WD STATUS
		BITA	#DRQ				; CHECK FOR DATA
		BNE	READ5				; BRANCH IF DATA PRESENT
		BITA	#BUSY				; CHECK IF BUSY
		BNE	READ3				; LOOP IF SO
		TFR	A,B				; ERROR IF NOT
		BRA	READ6
READ5		LDA	DATREG				; GET DATA BYTE
		STA	0,X+				; PUT IN MEMORY
error ;;;; !!!! ;;;; DE57 5A DECB DEC THE COUNTER
		BNE	READ3				; LOOP TIL DONE
		BSR	WAIT				; WAIT TIL WD IS FINISHED
READ6		BITB	#RDMSK				; MASK ERRORS
		CLI				;  ENABLE INTERRUPTS
		RTS				;  RETURN
	* WAIT
	*
	* WAIT FOR 1771 TO FINISH COMMAND
WAIT		TST	PRCNT				; ARE WE SPOOLING?
		BEQ	WAIT1				; SKIP IF NOT
		SWI3				;  SWITCH TASKS IF SO
		NOP				;  NECESSARY FOR SBUG
WAIT1		LDB	COMREG				; GET WD STATUS
		BITB	#BUSY				; CHECK IF BUSY
		BNE	WAIT				; LOOP TIL NOT BUSY
		RTS				;  RETURN
	* SEEK
	*
	* SEEK THE SPECIFIED TRACK
SEEK		STB	SECREG				; SET SECTOR
error ;;;; !!!! ;;;; DE74 Bl E019 CMPA TRKREG DIF THAN LAST?
		BEQ	SEEK4				; EXIT IF NOT
		STA	DATREG				; SET NEW WD TRACK
		LBSR	DEL28				; GO DELAY
		LDA	#SKCMND				; SETUP SEEK COMMAND
		STA	COMREG				; ISSUE SEEK COMMAND
		LBSR	DEL28				; GO DELAY
		BSR	WAIT				; WAIT TIL DONE
		BITB	#$10				; CHECK FOR SEEK ERROR
SEEK4		LBRA	DEL28				; DELAY
	* WRITE
	*
	* WRITE ONE SECTOR
error ;;;; !!!! ;;;; DE8E 8D El WRITE BSR SEEK SEEK TO TRACK
		LDA	#WTDMND				; SETUP WRITE SCTR COMMAND
		TST	PRCNT				; ARE WE SPOOLING?
		BEQ	WRITE2				; SKIP IF NOT
		SWI3				;  CHANGE TASKS IF SO
		NOP				;  NECESSARY FOR SBUG
WRITE2		SEI				;  DISABLE INTERRUPTS
		STA	COMREG				; ISSUE WRITE COMMAND
		LBSR	DEL28				; DELAY
		CLRB				;  GET SECTOR LENGTH (=256)
WRITE3		LDA	COMREG				; CHECK WD STATUS
		BITA	#DRQ				; READY FOR DATA?
		BNE	WRITE5				; SKIP IF READY
		BITA	#BUSY				; STILL BUSY?
		BNE	WRITE3				; LOOP IF SO
		TFR	A,B				; ERROR IF NOT
		BRA	WRITE6
WRITE5		LDA	0,X+				; GET A DATA BYTE
		STA	DATREG				; SEND TO DISK
error ;;;; !!!! ;;;; DEB7 5A DECB DEC THE COUNT
		BNE	WRITE3				; FINISHED?
		BSR	WAIT				; WAIT TIL WD IS FINISHED
WRITE6		BITB	#WTMSK				; MASK ERRORS
		CLI				;  ENABLE INTERRUPTS
		RTS				;  RETURN
	* VERIFY
	*
	* VERIFY LAST SECTOR WRITTEN
VERIFY		LDA	#RDCMND				; SETUP VERIFY COMMAND
		TST	PRCNT				; ARE WE SPOOLING?
		BEQ	VERIF2				; SKIP IF NOT
		SWI3				;  CHANGE TASKS IF SO
		NOP				;  NECESSARY FOR SBUG
VERIF2		SEI				;  DISABLE INTERRUPTS
		STA	COMREG				; ISSUE VERIFY COMMAND
		LBSR	DEL28				; GO DELAY
		BSR	WAIT				; WAIT TIL WD IS DONE
		CLI				;  ENABLE INTERRUPTS
		BITB	#VERMSK				; MASK ERRORS
		RTS				;  RETURN
	* RST
	*
	* RST RESTORES THE HEAD TO 00
RST		PSHS	X				; SAVE X REGISTER
		BSR	DRV				; DO SELECT
		LDA	#RSCMND				; SETUP RESTORE COMMAND
		STA	COMREG				; ISSUE RESTORE COMMAND
		BSR	DEL28				; DELAY
		LBSR	WAIT				; WAIT TIL WD IS FINISHED
		PULS	X				; RESTORE POINTER
		BITB	#$D8				; CHECK FOR ERROR
		RTS				;  RETURN
	* DRV
	*
	* SELECT THE SPECIFIED DRIVE
DRV		LDA	3,X				; GET DRIVE NUMBER
		CMPA	#3				; ENSURE IT'S < 4
		BLS	DRV2				; BRANCH IF OK
		LDB	#$0F				; ELSE SET ERROR VALUE
error ;;;; !!!! ;;;; DEF5 1A 01 SEC
		RTS
DRV2		BSR	FNDTRK				; FIND TRACK
		LDB	TRKREG				; GET CURRENT TRACK
		STB	0,X				; SAVE IT
		STA	DRVREG				; SET NEW DRIVE
		STA	CURDRV
		BSR	FNDTRK				; FIND NEW TRACK
		LDA	0,X
		STA	TRKREG				; PUT NEW TRACK IN WD
		BSR	DEL28				; DELAY
		BRA	OK
	* CHKRDY
	*
	* CHECK DRIVE READY ROUTINE
CHKRDY		LDA	3,X				; GET DRIVE NUMBER
		CMPA	#1				; BE SURE IT'S 0 OR 1
		BLS	OK				; BRANCH IF OK
		LDB	#$80				; ELSE, SHOW NOT READY
error ;;;; !!!! ;;;; DF18 1A 01 SEC
error ;;;; !!!! ;;;; DFLA 39 RTS RETURN
OK		CLRB				;  SHOW NO ERROR
error ;;;; !!!! ;;;; DF1C 1C FE CLC
error ;;;; !!!! ;;;; DFLE 39 RTS
	* FIND THE TRACK FOR CURRENT DRIVE
FNDTRK		LDX	#DRVTRK				; POINT TO TRACK STORE
		LDB	CURDRV				; GET CURRENT DRIVE
		ABX				;  POINT TO DRIVE'S TRACK
		RTS				;  RETURN
	* DELAY
DEL28		LBSR	DEL14
DEL14		LBSR	DEL
DEL		RTS
error ;;;; !!!! ;;;; END
