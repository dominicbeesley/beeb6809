	IF NOICE_NO_INCS

	ELSE
		include "../../../includes/hardware.inc"
		include "../../../includes/common.inc"
		include "../../../includes/mosrom.inc"
		include "../../../includes/noice.inc"
	ENDIF

	IF NOICE_MY
fred_MYELIN_SERIAL_STATUS	EQU	$FCA1
fred_MYELIN_SERIAL_DATA		EQU	$FCA0
MYELIN_SERIAL_TXRDY		EQU	2
MYELIN_SERIAL_RXRDY		EQU	1
	ENDIF


	IF DO_ROMLATCH
MAPREG		EQU	sheila_ROMCTL_SWR
MAPIMG		EQU	zp_mos_curROM
	ENDIF

* Ported to beeb6809 27/4/2017 Dominic Beesley
* adapted for both 6809 (define CPU_6809) or 6309 (define CPU_6309)
* adapted to chipkit with S16550 (define MACH_CHIPKIT) or Model B (define MACH_BEEB)
*  6809 Debug monitor for use with NOICE09
*
*  Copyright (c) 1992-2006 by John Hartman
*
*  Modification History:
*	14-Jun-93 JLH release version
*	24-Aug-93 JLH bad constant for COMBUF length compare
*	25-Feb-98 JLH assemble with either Motorola or Dunfield
*	 1-May-06 JLH slight cleanup
*
*============================================================================
*
*  To customize for a given target, you must change code in the
*  hardware equates, the string TSTG, and the routines RESET and REWDT.
*  You may or may not need to change GETCHAR, PUTCHAR, depending on
*  how peculiar your UART is.
*
*  This file has been assembled with the Motorola Freeware assembler
*  available from the Motorola Freeware BBS and elsewhere.
*   BUT:  you must first "comment out" the conditionals as required,
*   because the Motorola assemblers do not have any IFEQ/ELSE/ENDIF
*
*  This file may also be assembled with the Dunfield assembler
*
*  To add mapped memory support:
*	1) Define map port MAPREG here
*	2) Define or import map port RAM image MAPIMG here if MAPREG is
*	   write only.	(The application code must update MAPIMG before
*	   outputing to MAPREG)
*	3) Search for and modify MAPREG, MAPIMG, and REG_PAGE usage below
*	4) In TSTG below edit "LOW AND HIGH LIMIT OF MAPPED MEM"
*	   to appropriate range (typically 4000H to 07FFFH for two-bit MMU)
*

*
*============================================================================
*
*  RAM interrupt vectors (first in SEG for easy addressing, else move to
*  their own SEG)
NVEC		EQU	8	      ; number of vectors
*
*  Initial user stack
*  (Size and location is user option)
INITSTACK		EQU	$200



		ORG	NOICE_RAM_START			; use cassette / serial input buffer 
MONSTACK	EQU	NOICE_RAM_START + $100	  	; top of!

	IF CPU_6309
TEST_STACK	RMB	14
* It is not possible to read bits 0&1 of regMD so the next three lines enable
* testing of these bits.
E_FLAG		RMB	1		0=not set $80=set
S_IMAGE		RMB	2		temporary store for regS
	ENDIF

*  Target registers:  order must match that in TRGHC11.C
TASK_REGS
REG_STATE	RMB	1
REG_PAGE	RMB	1
REG_SP		RMB	2
REG_U		RMB	2
REG_Y		RMB	2
REG_X		RMB	2
	IF CPU_6309
REG_F		RMB	1		F BEFORE E, SO W IS LEAST SIG. FIRST
REG_E		RMB	1
	ENDIF
REG_B		RMB	1		B BEFORE A, SO D IS LEAST SIG. FIRST
REG_A		RMB	1
REG_DP		RMB	1
REG_CC		RMB	1
	IF CPU_6309
REG_MD		RMB	1
REG_V		RMB	2
	ENDIF
REG_PC		RMB	2
TASK_REG_SZ	EQU	*-TASK_REGS
			IF STANDALONE
RAMVEC		RMB	2*NVEC
			ENDIF
	IF NOICE_DEBUG_MEMMAP
	ELSE
RUNNING_FLAG	RMB	1
	ENDIF

*
*  Communications buffer
*  (Must be at least as long as TASK_REG_SZ.  At least 19 bytes recommended.
*  Larger values may improve speed of NoICE memory move commands.)
COMBUF_SIZE	EQU	128		DATA SIZE FOR COMM BUFFER
COMBUF		RMB	2+COMBUF_SIZE+1 BUFFER ALSO HAS FN, LEN, AND CHECK

	IF NOICE_DEBUG_MEMMAP
RW_MEM_CODE_SAVE
		RMB	$100
	ENDIF

*
RAM_END		EQU    *	       ADDRESS OF TOP+1 OF RAM

		IF	STANDALONE
*
*===========================================================================
* Bodge to make ROM start at $8000
		IF	NOICE_CODE_BASE != $8000
		ORG	$8000
			NOP
			FILL	$FF,NOICE_CODE_BASE-*
		ENDIF
		ENDIF


		ORG	NOICE_CODE_BASE

		IF STANDALONE==0
ENTER_NMI_ENT		FDB	NMI_ENT
ENTER_SWI_ENT		FDB	SWI_ENT
ENTER_PUTCHAR		FDB	PUTCHAR
ENTER_RESET		FDB	RESET
		ENDIF
*
*  Power on reset
RESET

	IF	STANDALONE
*
*  Set CPU mode to safe state
		ORCC	#CC_I+CC_F	      ; INTERRUPTS OFF
		LDS	#MONSTACK	; CLEAN STACK IS HAPPY STACK
*
*----------------------------------------------------------------------------


SCREEN_BASEx8	EQU	0

; setup CRTC to show bottom part of RAM in mode 1

		; setup CRTC
		LDB	#$B
		LDX	#mostbl_VDU_6845_mode_012
crtcsetlp1	STB	sheila_CRTC_reg
		LDA	B,X
		STA	sheila_CRTC_rw
		DECB
		BPL	crtcsetlp1

		LDA	#12
		STA	sheila_CRTC_reg
		LDA	#SCREEN_BASEx8 / $100
		STA	sheila_CRTC_rw

		LDA	#13
		STA	sheila_CRTC_reg
		LDA	#SCREEN_BASEx8 % $100
		STA	sheila_CRTC_rw

		LDA	#$9C
		STA	sheila_VIDULA_ctl

		LDA	#12
		STA	sheila_CRTC_reg
		LDA	#SCREEN_BASEx8 / $100
		STA	sheila_CRTC_rw

		LDA	#13
		STA	sheila_CRTC_reg
		LDA	#SCREEN_BASEx8 % $100
		STA	sheila_CRTC_rw

		LDB	#0
pallp		TFR	B,A
		TSTB
		BPL	1F
		ORA	#$F
1		STA	sheila_VIDULA_pal
		ADDB	#$10
		BNE	pallp
	ENDIF

	IF MACH_CHIPKIT
*
*  Initialize UART
*
*  Delay here in case the UART has not come out of reset yet.
		LDX	#0
LOP		LEAX	-1,X		      ;	 DELAY FOR SLOW RESETTING UART
		NOP
		NOP
		BNE	LOP
*
*  access baud generator, no parity, 1 stop bit, 8 data bits
		LDA	#$83
		STA	S16550_LCR
		LDA	#%10000111			; enable FIFOs and clear trigger RECV interrupt at 8
		STA	S16550_FCR			; no FIFOs

*
*  fixed baud rate of 19200:  crystal is 3.686400 Mhz.
*  Divisor is 4000000/(16*baud)
BAUD_WORD	EQU SER_BAUD_CLOCK_IN/(NOICE_BAUD_RATE*16)
		LDA	#BAUD_WORD%256
		STA	S16550_RXR		; lsb
		LDA	#BAUD_WORD/256
		STA	S16550_RXR+1		; msb=0
*
*  access data registers, no parity, 1 stop bits, 8 data bits
		LDA	#$03
		STA	S16550_LCR
*
*  no loopback, OUT2 on, OUT1 on, RTS on, DTR (LED) on
		LDA	#$0F
		STA	S16550_MCR
*
*  disable all interrupts: modem, receive error, transmit, and receive
		LDA	#$00
		STA	S16550_IER
	ENDIF

	IF STANDALONE
*
*----------------------------------------------------------------------------
*
*  Initialize RAM interrupt vectors
		LDY	#INT_ENTRY	; ADDRESS OF DEFAULT HANDLER
		LDX	#RAMVEC		; POINTER TO RAM VECTORS
		LDB	#NVEC		; NUMBER OF VECTORS
RES10		STY	,X++		; SET VECTOR
		DECB
		BNE	RES10

	ENDIF
*
*  Initialize user registers
		LDD	#INITSTACK
		STA	REG_SP+1		; INIT USER'S STACK POINTER MSB
		STB	REG_SP			; LSB
*
		LDD	#0
		STD	REG_PC
		STA	REG_A
		STA	REG_B
	IF CPU_6309
		STA	REG_E
		STA	REG_F
	ENDIF
		STA	REG_DP
	IF CPU_6309
		STA	REG_MD
	ENDIF
		STD	REG_X
		STD	REG_Y
		STD	REG_U
	IF CPU_6309
		STD	REG_V
	ENDIF
		STA	REG_STATE		; initial state is "RESET"
*
*  Initialize memory paging variables and hardware (if any)
		STA	REG_PAGE		; initial page is zero
	IF DO_ROMLATCH
		STA	MAPIMG
		STA	MAPREG			; set hardware map
	ENDIF
		LDA	#CC_E+CC_I+CC_F			 ; state "all regs pushed", no ints
		STA	REG_CC
*
*  Set function code for "GO".	Then if we reset after being told to
*  GO, we will come back with registers so user can see the crash
		LDA	#FN_RUN_TARG
		STA	COMBUF

	IF	STANDALONE
BEEP_FREQ	EQU	525
BEEP_76489CLK	EQU	4000000

		JSR	reset_snd
		LDA	#2
		LDX	#((BEEP_76489CLK/32)/BEEP_FREQ)
		JSR	snd_tone
		LDA	#2
		LDB	#$0
		JSR	snd_vol
		LDX	#0
1		BRA	2F
2		BRA	3F
3		LEAX	-1,X
		BNE	1B
		LDA	#2
		LDB	#$F
		JSR	snd_vol

		JMP	RETURN_REGS		; DUMP REGS, ENTER MONITOR

	ELSE
		IF NOICE_DEBUG_MEMMAP
		ELSE
			LDA	#$FF
			STA	RUNNING_FLAG		; mark as running and drop back to MOS ROM init code
		ENDIF
			RTS				; return to MOS
	ENDIF

*
*===========================================================================
*  Get a character to A
*
*  Return A=char, CY=0 if data received
*	  CY=1 if timeout (0.5 seconds)
*
*  Uses 6 bytes of stack including return address
*
GETCHAR
		PSHS	X
		LDX	#0			; LONG TIMEOUT
GC10		LEAX	-1,X
		BEQ	GC90			; EXIT IF TIMEOUT
	IF MACH_BEEB
	IF NOICE_MY
		LDA	fred_MYELIN_SERIAL_STATUS
		ANDA	#MYELIN_SERIAL_RXRDY
	ELSE
		LDA	sheila_ACIA_CTL		; READ DEVICE STATUS
		ANDA	#1
	ENDIF
	ENDIF
	IF MACH_CHIPKIT
		LDA	S16550_LSR		; READ DEVICE STATUS
		ANDA	#SER_BIT_RXRDY
	ENDIF
		BEQ	GC10			; NOT READY YET.
*
*  Data received:  return CY=0. data in A
		CLRA				; CY=0
	IF MACH_BEEB
	IF NOICE_MY
		LDA	fred_MYELIN_SERIAL_DATA	; READ DATA
	ELSE
		LDA	sheila_ACIA_DATA	; READ DATA
	ENDIF
	ENDIF
	IF MACH_CHIPKIT
		LDA	S16550_RXR		; READ DATA
	ENDIF
		PULS	X,PC

*
*  Timeout:  return CY=1
GC90		ORCC	#CC_C			; CY=1
		PULS	X,PC
*
*===========================================================================
*  Output character in A
*
*  Uses 5 bytes of stack including return address
*
PUTCHAR
		PSHS	A
PC10	
	IF MACH_BEEB
	IF NOICE_MY
		LDA	fred_MYELIN_SERIAL_STATUS	; CHECK TX STATUS
		ANDA	#MYELIN_SERIAL_TXRDY		; TX READY ?
	ELSE
		LDA	sheila_ACIA_CTL	; CHECK TX STATUS
		ANDA	#2		; TX READY ?
	ENDIF
	ENDIF
	IF MACH_CHIPKIT
		LDA	S16550_LSR     ; CHECK TX STATUS
		ANDA	#SER_BIT_TXRDY ; RX READY ?
	ENDIF
		BEQ	PC10
		PULS	A
	IF MACH_BEEB
	IF NOICE_MY
		STA	fred_MYELIN_SERIAL_DATA
	ELSE	
		STA	sheila_ACIA_DATA
	ENDIF
	ENDIF
	IF MACH_CHIPKIT
		STA	S16550_TXR     ; TRANSMIT CHAR.
	ENDIF
		RTS

*======================================================================
*  Response string for GET TARGET STATUS request
*  Reply describes target:
TSTG	
	IF CPU_6309
		FCB	17			; 2: PROCESSOR TYPE = 6309
	ELSE
		FCB	5			; 2: PROCESSOR TYPE = 6809
	ENDIF
		FCB	COMBUF_SIZE		; 3: SIZE OF COMMUNICATIONS BUFFER
		FCB	0			; 4: NO TASKING SUPPORT
	IF DO_ROMLATCH
		FDB	$8000,$BFFF		; PAGED SW ROM/RAM at $8000
	ELSE
		FDB	0,0			; 5-8: LOW AND HIGH LIMIT OF MAPPED MEM (NONE)
	ENDIF
		FCB	B1-B0			; 9:  BREAKPOINT INSTR LENGTH
B0		SWI				; 10: BREAKPOINT INSTRUCTION
B1		
	IF CPU_6309
		FCC	'6309'
	ELSE
		FCC	'6809'
	ENDIF
		FCC	' monitor V1.1-'	; DESCRIPTION, ZERO
	IF MACH_CHIPKIT
		FCC	'-chipkit'
	ENDIF
	IF MACH_BEEB
		FCC	'-BBC'
	ENDIF
		FCB	0 
TSTG_SIZE	EQU	*-TSTG		; SIZE OF STRING
*
*======================================================================
*  HARDWARE PLATFORM INDEPENDENT EQUATES AND CODE
*
*  Communications function codes.
FN_GET_STAT	EQU	$FF    ; reply with device info
FN_READ_MEM	EQU	$FE    ; reply with data
FN_WRITE_M	EQU	$FD    ; reply with status (+/-)
FN_READ_RG	EQU	$FC    ; reply with registers
FN_WRITE_RG	EQU	$FB    ; reply with status
FN_RUN_TARG	EQU	$FA    ; reply (delayed) with registers
FN_SET_BYTE	EQU	$F9    ; reply with data (truncate if error)
FN_IN		EQU	$F8    ; input from port
FN_OUT		EQU	$F7    ; output to port
*
FN_MIN		EQU	$F7    ; MINIMUM RECOGNIZED FUNCTION CODE
FN_ERROR	EQU	$F0    ; error reply to unknown op-code
*
*===========================================================================
*  Common handler for default interrupt handlers
*  Enter with A=interrupt code = processor state
*  All registers stacked, PC=next instruction
*
*  If 6809 mode, stack has CC A B DP XH XL YH YL UH UL PCH PCL
*  If 6309 mode, stack has CC A B E  F	DP XH XL YH YL UH  UL  PCH PCL
*
INT_ENTRY
		STA	REG_STATE	; SAVE STATE
	IF NOICE_DEBUG_MEMMAP
	ELSE
		CMPA	#2		; DB: check for NMI
		BNE	INT_ENTRY_GO
		TST	RUNNING_FLAG	; not running just RTI
		BNE	INT_ENTRY_GO
		RTI
INT_ENTRY_GO
	ENDIF

*
*  Save registers from stack to reg block for return to master
*  Host wants least significant bytes first, so flip as necessary
		PULS	A
		STA	REG_CC		; CONDITION CODES
		PULS	A
		STA	REG_A		; A
		PULS	A
		STA	REG_B		; B

	IF CPU_6309

*  If native mode, E and F are on stack
*  If 6809 mode, E and F are in registers, unchanged from interrupt til here
	; clear BIT 1 of REG_MD before test and set if in 6309 mode
		AIM	#$FE,REG_MD
		JSR	MD_TEST
		BNE	IE_10		; Jump if 6809 mode
		PULSW			; else native: get from stack
		OIM	#$1,REG_MD
IE_10		STE	REG_E
		STF	REG_F

*  V isn't on the stack, but we haven't touched it.  Copy to RAM
		TFR	V,D
		STA	REG_V+1		; MSB V
		STB	REG_V		; LSB V

*  There seems to be no way to store MD, and no way to load it except immediate
*  Thus we have to construct it by BITMD
		LDA	REG_MD
		; DB: Changed this TEST_MD wasn't saving the bits!
		ANDA	#$03		; save only bits 1 and 0 (set by MD_TEST)
		BITMD	#$40
		BEQ	IE_11
		ORA	#$40
IE_11		BITMD	#$80
		BEQ	IE_12
		ORA	#$80
IE_12		STA	REG_MD

	ENDIF

		PULS	A
		STA	REG_DP		; DP
		PULS	D
		STA	REG_X+1		; MSB X
		STB	REG_X		; LSB X
		PULS	D
		STA	REG_Y+1		; MSB Y
		STB	REG_Y		; LSB Y
		PULS	D
		STA	REG_U+1		; MSB U
		STB	REG_U		; LSB U
*
*  If this is a breakpoint (state = 1), then back up PC to point at SWI
		PULS	X		; PC AFTER INTERRUPT
		LDA	REG_STATE
		CMPA	#1		
		BNE	NOTBP		; BR IF NOT A BREAKPOINT
		LEAX	-(B1-B0),X	      ; ELSE BACK UP TO POINT AT SWI LOCATION
NOTBP		TFR	X,D		; TRANSFER PC TO D
		STA	REG_PC+1	; MSB
		STB	REG_PC		; LSB
		JMP	ENTER_MON	; REG_PC POINTS AT POST-INTERRUPT OPCODE
*
*===========================================================================
*  Main loop  wait for command frame from master
*
*  Uses 6 bytes of stack including return address
*
MAIN		
	IF NOICE_DEBUG_MEMMAP
	ELSE
		CLR	RUNNING_FLAG		; DB: reset running flag to 0 block further NMIs
	ENDIF
		LDS	#MONSTACK		; CLEAN STACK IS HAPPY STACK
		LDX	#COMBUF			; BUILD MESSAGE HERE
*
*  First byte is a function code
		JSR	GETCHAR			; GET A FUNCTION (6 bytes of stack)
		BCS	MAIN			; JIF TIMEOUT: RESYNC
		CMPA	#FN_MIN
		BLO	MAIN			; JIF BELOW MIN: ILLEGAL FUNCTION
		STA	,X+			; SAVE FUNCTION CODE
*
*  Second byte is data byte count (may be zero)
		JSR	GETCHAR			; GET A LENGTH BYTE
		BCS	MAIN			; JIF TIMEOUT: RESYNC
		CMPA	#COMBUF_SIZE
		BHI	MAIN			; JIF TOO LONG: ILLEGAL LENGTH
		STA	,X+			; SAVE LENGTH
		CMPA	#0
		BEQ	MA80			; SKIP DATA LOOP IF LENGTH = 0
*
*  Loop for data
		TFR	A,B			; SAVE LENGTH FOR LOOP
MA10		JSR	GETCHAR			; GET A DATA BYTE
		BCS	MAIN			; JIF TIMEOUT: RESYNC
		STA	,X+			; SAVE DATA BYTE
		DECB
		BNE	MA10
*
*  Get the checksum
MA80		JSR	GETCHAR			; GET THE CHECKSUM
		BCS	MAIN			; JIF TIMEOUT: RESYNC
		PSHS	A			; SAVE CHECKSUM
*
*  Compare received checksum to that calculated on received buffer
*  (Sum should be 0)
		JSR	CHECKSUM
		ADDA	,S+			; ADD SAVED CHECKSUM TO COMPUTED
		BNE	MAIN			; JIF BAD CHECKSUM
*
*  Process the message.
		LDX	#COMBUF
		LDA	,X+			; GET THE FUNCTION CODE
		LDB	,X+			; GET THE LENGTH
		CMPA	#FN_GET_STAT
		BEQ	TARGET_STAT
		CMPA	#FN_READ_MEM
		BEQ	JREAD_MEM
		CMPA	#FN_WRITE_M
		BEQ	JWRITE_MEM
		CMPA	#FN_READ_RG
		BEQ	JREAD_REGS
		CMPA	#FN_WRITE_RG
		BEQ	JWRITE_REGS
		CMPA	#FN_RUN_TARG
		BEQ	JRUN_TARGET
		CMPA	#FN_SET_BYTE
		BEQ	JSET_BYTES
		CMPA	#FN_IN
		BEQ	JIN_PORT
		CMPA	#FN_OUT
		BEQ	JOUT_PORT
*
*  Error: unknown function.  Complain
		LDA	#FN_ERROR
		STA	COMBUF		; SET FUNCTION AS "ERROR"
		LDA	#1
		JMP	SEND_STATUS	; VALUE IS "ERROR"
*
*  long jumps to handlers
JREAD_MEM	JMP	READ_MEM
JWRITE_MEM	JMP	WRITE_MEM
JREAD_REGS	JMP	READ_REGS
JWRITE_REGS	JMP	WRITE_REGS
JRUN_TARGET	JMP	RUN_TARGET
JSET_BYTES	JMP	SET_BYTES
JIN_PORT	JMP	IN_PORT
JOUT_PORT	JMP	OUT_PORT

*===========================================================================
*
*  Target Status:  FN, len
*
*  Entry with A=function code, B=data size, X=COMBUF+2
*
TARGET_STAT
		LDX	#TSTG			; DATA FOR REPLY
		LDY	#COMBUF+1		; POINTER TO RETURN BUFFER
		LDB	#TSTG_SIZE		; LENGTH OF REPLY
		STB	,Y+			; SET SIZE IN REPLY BUFFER
TS10		LDA	,X+			; MOVE REPLY DATA TO BUFFER
		STA	,Y+
		DECB
		BNE	TS10
*
*  Compute checksum on buffer, and send to master, then return
		JMP	SEND

	IF NOICE_DEBUG_MEMMAP
MEM_DEBUG_INIT
1		LDA	,Y
		STA	,U+
		LDA	,X+
		STA	,Y+
		DECB
		BNE	1B
		RTS

MEM_DEBUG_RESTORE
1		LDA	,U+
		STA	,Y+
		DECB
		BNE	1B
		RTS
	ENDIF


*===========================================================================
*
*  Read Memory:	 FN, len, page, Alo, Ahi, Nbytes
*
*  Entry with A=function code, B=data size, X=COMBUF+2
*
READ_MEM
*
*  Set map
	IF DO_ROMLATCH
		LDA	0,X
		STA	MAPIMG
		STA	MAPREG
	ENDIF
*
*  Get address
		LDA	2,X			; MSB OF ADDRESS IN A
		LDB	1,X			; LSB OF ADDRESS IN B
		TFR	D,Y			; ADDRESS IN Y
*
*  Prepare return buffer: FN (unchanged), LEN, DATA
		LDB	3,X			; NUMBER OF BYTES TO RETURN
		STB	COMBUF+1		; RETURN LENGTH = REQUESTED DATA	
		BEQ	GLP90			; JIF NO BYTES TO GET


	IF NOICE_DEBUG_MEMMAP
		; if running from debug mem need to look to see
		; if this is an access to C000 onwards 
		; and page back in original MOS if it is

		CMPY	#$C000
		BLO	READ_MEM_NOT_MOS
		; TODO this should maybe also check for FC00-FEFF?

		PSHS	X,Y,U
		LDB	#READ_MEM_DEBUG_LEN
		LDX	#READ_MEM_DEBUG_LOAD
		LDY	#NOICE_DEBUG_CODE_BOUNCE
		LDU	#RW_MEM_CODE_SAVE
		JSR	MEM_DEBUG_INIT
		PULS	X,Y,U
*
*  Read the requested bytes from local memory
1		JSR	READ_MEM_DEBUG			; GET BYTE
		STA	,X+				; STORE TO RETURN BUFFER
		DECB
		BNE	1B

		PSHS	Y,U
		LDB	#READ_MEM_DEBUG_LEN
		LDY	#NOICE_DEBUG_CODE_BOUNCE
		LDU	#RW_MEM_CODE_SAVE
		JSR	MEM_DEBUG_RESTORE
		PULS	Y,U

		JMP	SEND

		; ORG this at bottom of stack NOICE_DEBUG_CODE_BOUNCE and copy from PUT area
READ_MEM_DEBUG_LOAD
		ORG	NOICE_DEBUG_CODE_BOUNCE
                PUT     READ_MEM_DEBUG_LOAD
READ_MEM_DEBUG
		PSHS	B				; preserve B
		LDB	$FE31				; save current MOS state
		STA	$FE32				; restore mos state prior to debug entry
							; NOTE: stack is from DEBUG memory so
							; we can't use the stack until we've
							; restored DEBUG state
		NOP
		LDA	,Y+			; GET BYTE
		STB	$FE31
		NOP					; stores to FE31 bit 2 are delayed by 1 instruction!
		PULS	B,PC
READ_MEM_DEBUG_END
READ_MEM_DEBUG_LEN EQU READ_MEM_DEBUG_END-NOICE_DEBUG_CODE_BOUNCE

		ORG	READ_MEM_DEBUG_LOAD + READ_MEM_DEBUG_LEN
               	PUT     READ_MEM_DEBUG_LOAD + READ_MEM_DEBUG_LEN
READ_MEM_NOT_MOS
	ENDIF
*
*  Read the requested bytes from local memory
GLP		LDA	,Y+			; GET BYTE
		STA	,X+			; STORE TO RETURN BUFFER
		DECB
		BNE	GLP
*
*  Compute checksum on buffer, and send to master, then return
GLP90		JMP	SEND

	IF NOICE_DEBUG_MEMMAP
		; ORG this at bottom of stack NOICE_DEBUG_CODE_BOUNCE and copy from PUT area
WRITE_MEM_DEBUG_LOAD
		ORG	NOICE_DEBUG_CODE_BOUNCE
                PUT     WRITE_MEM_DEBUG_LOAD
WRITE_MEM_DEBUG
		PSHS	B				; preserve B
		LDB	$FE31				; save current MOS state
		STA	$FE32				; restore mos state prior to debug entry
							; NOTE: stack is from DEBUG memory so
							; we can't use the stack until we've
							; restored DEBUG state
		NOP
		STA	,Y+			; GET BYTE
		STB	$FE31
		NOP					; stores to FE31 bit 2 are delayed by 1 instruction!
		PULS	B,PC
WRITE_MEM_DEBUG_END
WRITE_MEM_DEBUG_LEN EQU WRITE_MEM_DEBUG_END-NOICE_DEBUG_CODE_BOUNCE

		ORG	WRITE_MEM_DEBUG_LOAD + WRITE_MEM_DEBUG_LEN
        ENDIF

*===========================================================================
*
*  Write Memory:  FN, len, page, Alo, Ahi, (len-3 bytes of Data)
*
*  Entry with A=function code, B=data size, X=COMBUF+2
*
*  Uses 6 bytes of stack
*
WRITE_MEM
*
*  Set map

		LDA	,X+
	IF DO_ROMLATCH
		STA	MAPIMG
		STA	MAPREG
	ENDIF
*
*  Get address
		LDB	,X+			; LSB OF ADDRESS IN B
		LDA	,X+			; MSB OF ADDRESS IN A
		TFR	D,Y			; ADDRESS IN Y

*
*  Compute number of bytes to write
		LDB	COMBUF+1		; NUMBER OF BYTES TO RETURN
		SUBB	#3			; MINUS PAGE AND ADDRESS
		BEQ	WLP50			; JIF NO BYTES TO PUT

	IF NOICE_DEBUG_MEMMAP
		; if running from debug mem need to look to see
		; if this is an access to C000 onwards 
		; and page back in original MOS if it is

		CMPY	#$C000
		BLO	WRITE_MEM_NOT_MOS
		; TODO this should maybe also check for FC00-FEFF?

		PSHS	B,X,Y,U
		LDB	#WRITE_MEM_DEBUG_LEN
		LDX	#WRITE_MEM_DEBUG_LOAD
		LDY	#NOICE_DEBUG_CODE_BOUNCE
		LDU	#RW_MEM_CODE_SAVE
		JSR	MEM_DEBUG_INIT
		PULS	B,X,Y,U

*
*  Write the specified bytes to local memory
		PSHS	B,X,Y
1		LDA	,X+				; GET BYTE TO WRITE
		JSR	WRITE_MEM_DEBUG			; STORE THE BYTE AT ,Y
		DECB
		BNE	1B

		PSHS	Y,U
		LDB	#WRITE_MEM_DEBUG_LEN
		LDY	#NOICE_DEBUG_CODE_BOUNCE
		LDU	#RW_MEM_CODE_SAVE
		JSR	MEM_DEBUG_RESTORE
		PULS	Y,U

		PSHS	X,Y,U
		LDB	#READ_MEM_DEBUG_LEN
		LDX	#READ_MEM_DEBUG_LOAD
		LDY	#NOICE_DEBUG_CODE_BOUNCE
		LDU	#RW_MEM_CODE_SAVE
		JSR	MEM_DEBUG_INIT
		PULS	X,Y,U

		PULS	B,X,Y
1		JSR	READ_MEM_DEBUG			; DB: Swapped LDA/CMPA to make DEBUG case easier
		CMPA	,X+				; GET BYTE JUST WRITTEN
		BNE	2F				; BR IF WRITE FAILED
		DECB
		BNE	1B
2

		PSHS	CC,Y,U
		LDB	#READ_MEM_DEBUG_LEN
		LDY	#NOICE_DEBUG_CODE_BOUNCE
		LDU	#RW_MEM_CODE_SAVE
		JSR	MEM_DEBUG_RESTORE
		PULS	CC,Y,U

		BNE	WLP80				; signal fail
		BEQ	WLP50				; signal pass

WRITE_MEM_NOT_MOS
	ENDIF

*
*  Write the specified bytes to local memory
		PSHS	B,X,Y
WLP		LDA	,X+			; GET BYTE TO WRITE
		STA	,Y+			; STORE THE BYTE AT ,Y
		DECB
		BNE	WLP
*
*  Compare to see if the write worked
		PULS	B,X,Y
WLP20		LDA	,Y+			; DB: Swapped LDA/CMPA to make DEBUG case easier
		CMPA	,X+			; GET BYTE JUST WRITTEN
		BNE	WLP80			; BR IF WRITE FAILED
		DECB
		BNE	WLP20
*
*  Write succeeded:  return status = 0
WLP50		LDA	#0			; RETURN STATUS = 0
		BRA	WLP90
*
*  Write failed:  return status = 1
WLP80		LDA	#1

*  Return OK status
WLP90		JMP	SEND_STATUS

*===========================================================================
*
*  Read registers:  FN, len=0
*
*  Entry with A=function code, B=data size, X=COMBUF+2
*
READ_REGS
*
*  Enter here from SWI after "RUN" and "STEP" to return task registers
RETURN_REGS
		LDY	#TASK_REGS		; POINTER TO REGISTERS
		LDB	#TASK_REG_SZ		; NUMBER OF BYTES
		LDX	#COMBUF+1		; POINTER TO RETURN BUFFER
		STB	,X+			; SAVE RETURN DATA LENGTH
*
*  Copy the registers
GRLP		LDA	,Y+			; GET BYTE TO A
		STA	,X+			; STORE TO RETURN BUFFER
		DECB
		BNE	GRLP
*
*  Compute checksum on buffer, and send to master, then return
		JMP	SEND

*===========================================================================
*
*  Write registers:  FN, len, (register image)
*
*  Entry with A=function code, B=data size, X=COMBUF+2
*
WRITE_REGS
*
		TSTB				; NUMBER OF BYTES
		BEQ	WRR80			; JIF NO REGISTERS
*
*  Copy the registers
		LDY	#TASK_REGS		; POINTER TO REGISTERS
WRRLP		LDA	,X+			; GET BYTE TO A
		STA	,Y+			; STORE TO REGISTER RAM

		DECB
		BNE	WRRLP
*
*  Return OK status
WRR80		CLRA
		JMP	SEND_STATUS

*===========================================================================
*
*  Run Target:	FN, len
*
*  Entry with A=function code, B=data size, X=COMBUF+2
*
RUN_TARGET
*
*  Restore user's map
	IF DO_ROMLATCH
		LDA	REG_PAGE		; USER'S PAGE
		STA	MAPIMG			; SET IMAGE
		STA	MAPREG			; SET MAPPING REGISTER
	ENDIF
*
*  Switch to user stack
		LDA	REG_SP+1		; BACK TO USER STACK
		LDB	REG_SP
		TFR	D,S			; TO S

	IF CPU_6309
*
*  Restore MD, as it affects stack building and RTI
*  Only bits 1 and 0 can be written, and only using LDMD #
*  It's time for some self-modifying code!  Build LDMD #xxx, RTS in RAM and call it.
		LDD	#$113D			; LDMD #imm
		STD	COMBUF+30		; Start code string
		LDA	REG_MD			; #imm is desired MD value
		STA	COMBUF+32
		LDA	#$39			; RTS
		STA	COMBUF+33
		JSR	COMBUF+30
*
*  Restore V, which isn't on the stack
		LDA	REG_V+1
		LDB	REG_V
		TFR	D,V
	ENDIF
*
*  Restore registers
		LDA	REG_PC+1		; MS USER PC FOR RTI
		LDB	REG_PC			; LS USER PC FOR RTI
		PSHS	D

*
		LDA	REG_U+1
		LDB	REG_U
		PSHS	D
*
		LDA	REG_Y+1
		LDB	REG_Y
		PSHS	D
*
		LDA	REG_X+1
		LDB	REG_X
		PSHS	D
*
		LDA	REG_DP
		PSHS	A
	IF CPU_6309
*
*  Restore W from memory (not used between here and RTI)
		LDE	REG_E
		LDF	REG_F
		LDA	REG_MD
		BITA	#1
		BEQ	RT_10			; jump if 6809 mode
		PSHSW			       ; else push W on stack for RTI
RT_10
	ENDIF
*
		LDA	REG_B
		PSHS	A
*
		LDA	REG_A
		PSHS	A
*
		LDA	REG_CC			; SAVE USER CONDITION CODES FOR RTI
		ORA	#CC_E			   ; _MUST_ BE "ALL REGS PUSHED"
		PSHS	A

	IF NOICE_DEBUG_MEMMAP
	ELSE
		LDA	#255
		STA	RUNNING_FLAG
	ENDIF

*
*  Return to user (conditioned by MD.0)
	IF NOICE_DEBUG_MEMMAP
		STA	$FE32				; reset DEBUG map by writing restore reg
	ENDIF
		RTI
*
*===========================================================================
*
*  Common continue point for all monitor entrances
*  SP = user stack
ENTER_MON
		TFR	S,D		; USER STACK POINTER
		STA	REG_SP+1	; SAVE USER'S STACK POINTER (MSB)
		STB	REG_SP		; LSB
*
*  Change to our own stack
		LDS	#MONSTACK	; AND USE OURS INSTEAD
*
*  Operating system variables
	IF DO_ROMLATCH
		LDA	MAPIMG		; GET CURRENT USER MAP
	ELSE
		LDA	#0		; ... OR ZERO IF UNMAPPED TARGET
	ENDIF
		STA	REG_PAGE	; SAVE USER'S PAGE
*
*  Return registers to master
		JMP	RETURN_REGS


	IF NOICE_DEBUG_MEMMAP
		; ORG this at bottom of stack NOICE_DEBUG_CODE_BOUNCE and copy from PUT area
SET_BYTE_DEBUG_LOAD
		ORG	NOICE_DEBUG_CODE_BOUNCE
                PUT     SET_BYTE_DEBUG_LOAD
SET_BYTE_DEBUG
		LDB	3,X				; GET BYTE TO STORE	
		LDA	$FE31				; save current MOS state
		STA	SET_BYTE_TMP			; preserve B - note we can't use the stack here!
		STA	$FE32				; restore mos state prior to debug entry
							; NOTE: stack is from DEBUG memory so
							; we can't use the stack until we've
							; restored DEBUG state
		NOP

*
*  Read current data at byte location
		LDA	0,Y
*
*  Insert new data at byte location
		STB	0,Y			; WRITE TARGET MEMORY
*
*  Verify write
		CMPB	0,Y			; READ TARGET MEMORY
		BNE	SET_BYTE_EXNE
		LDB	SET_BYTE_TMP
		STB	$FE31
		NOP					; stores to FE31 bit 2 are delayed by 1 instruction!
		CLRB
		RTS
SET_BYTE_EXNE
		LDB	SET_BYTE_TMP
		STB	$FE31
		NOP					; stores to FE31 bit 2 are delayed by 1 instruction!
		RTS

SET_BYTE_TMP	RMB	1
SET_BYTE_DEBUG_END
SET_BYTE_DEBUG_LEN EQU SET_BYTE_DEBUG_END-NOICE_DEBUG_CODE_BOUNCE

		ORG	SET_BYTE_DEBUG_LOAD + SET_BYTE_DEBUG_LEN
        ENDIF



*===========================================================================
*
*  Set target byte(s):	FN, len { (page, alow, ahigh, data), (...)... }
*
*  Entry with A=function code, B=data size, X=COMBUF+2
*
*  Return has FN, len, (data from memory locations)
*
*  If error in insert (memory not writable), abort to return short data
*
*  This function is used primarily to set and clear breakpoints
*
*  Uses 1 byte of stack
*
SET_BYTES

	IF NOICE_DEBUG_MEMMAP
		LDU	#COMBUF+1		; POINTER TO RETURN BUFFER
		LDA	#0
		STA	,U+			; SET RETURN COUNT AS ZERO
		LSRB
		LSRB				; LEN/4 = NUMBER OF BYTES TO SET
		BEQ	SB99			; JIF NO BYTES (COMBUF+1 = 0)

		PSHS	B,X,Y,U
		LDB	#SET_BYTE_DEBUG_LEN
		LDX	#SET_BYTE_DEBUG_LOAD
		LDY	#NOICE_DEBUG_CODE_BOUNCE
		LDU	#RW_MEM_CODE_SAVE
		JSR	MEM_DEBUG_INIT
		PULS	B,X,Y,U
	ENDIF

*
*  Loop on inserting bytes
SB10		PSHS	B			; SAVE LOOP COUNTER
*
*  Set map
	IF DO_ROMLATCH
		LDA	0,X
		STA	MAPIMG
		STA	MAPREG
	ENDIF
*
*  Get address
		LDA	2,X			; MSB OF ADDRESS IN A
		LDB	1,X			; LSB OF ADDRESS IN B
		TFR	D,Y			; MEMORY ADDRESS IN Y

	IF NOICE_DEBUG_MEMMAP
		JSR	SET_BYTE_DEBUG
	ELSE
*
*  Read current data at byte location
		LDA	0,Y
*
*  Insert new data at byte location
		LDB	3,X			; GET BYTE TO STORE	
		STB	0,Y			; WRITE TARGET MEMORY
*
*  Verify write
		CMPB	0,Y			; READ TARGET MEMORY

	ENDIF

		PULS	B			; RESTORE LOOP COUNT, CC'S INTACT
		BNE	SB90			; BR IF INSERT FAILED: ABORT
*
*  Save target byte in return buffer
		STA	,U+
		INC	COMBUF+1		; COUNT ONE RETURN BYTE
*
*  Loop for next byte
		LEAX	4,X			; STEP TO NEXT BYTE SPECIFIER
		CMPB	COMBUF+1
		BNE	SB10			; *LOOP FOR ALL BYTES
*
*  Return buffer with data from byte locations
SB90
	IF NOICE_DEBUG_MEMMAP
		PSHS	CC,Y,U
		LDB	#SET_BYTE_DEBUG_LEN
		LDY	#NOICE_DEBUG_CODE_BOUNCE
		LDU	#RW_MEM_CODE_SAVE
		JSR	MEM_DEBUG_RESTORE
		PULS	CC,Y,U
	ENDIF

*
*  Compute checksum on buffer, and send to master, then return
SB99		JMP	SEND

*===========================================================================
*
*  Input from port:  FN, len, PortAddressLo, PAhi (=0)
*
*  While the 6809 has no input or output instructions, we retain these
*  to allow write-without-verify
*
*  Entry with A=function code, B=data size, X=COMBUF+2
*
IN_PORT
*
*  Get port address
		LDA	1,X			; MSB OF ADDRESS IN A
		LDB	0,X			; LSB OF ADDRESS IN B
		TFR	D,Y			; MEMORY ADDRESS IN Y
*
*  Read the requested byte from local memory
		LDA	0,Y
*
*  Return byte read as "status"
		JMP	SEND_STATUS

*===========================================================================
*
*  Output to port  FN, len, PortAddressLo, PAhi (=0), data
*
*  Entry with A=function code, B=data size, X=COMBUF+2
*
OUT_PORT
*
*  Get port address
		LDA	1,X			; MSB OF ADDRESS IN A
		LDB	0,X			; LSB OF ADDRESS IN B
		TFR	D,Y			; MEMORY ADDRESS IN Y
*
*  Get data
		LDA	2,X
*
*  Write value to port
		STA	0,Y
*
*  Do not read port to verify (some I/O devices don't like it)
*
*  Return status of OK
		CLRA
		JMP	SEND_STATUS

*===========================================================================
*  Build status return with value from "A"
*
SEND_STATUS
		STA	COMBUF+2		; SET STATUS
		LDA	#1
		STA	COMBUF+1		; SET LENGTH
		BRA	SEND

*===========================================================================
*  Append checksum to COMBUF and send to master
*
SEND		JSR	CHECKSUM		; GET A=CHECKSUM, X->checksum location
		NEGA
		STA	0,X			; STORE NEGATIVE OF CHECKSUM
*
*  Send buffer to master
		LDX	#COMBUF			; POINTER TO DATA
		LDB	1,X			; LENGTH OF DATA
		ADDB	#3			; PLUS FUNCTION, LENGTH, CHECKSUM
SND10		LDA	,X+
		JSR	PUTCHAR			; SEND A BYTE
		DECB
		BNE	SND10
		JMP	MAIN			; BACK TO MAIN LOOP

*===========================================================================
*  Compute checksum on COMBUF.	COMBUF+1 has length of data,
*  Also include function byte and length byte
*
*  Returns:
*	A = checksum
*	X = pointer to next byte in buffer (checksum location)
*	B is scratched
*
CHECKSUM
		LDX	#COMBUF			; pointer to buffer
		LDB	1,X			; length of message
		ADDB	#2			; plus function, length
		LDA	#0			; init checksum to 0
CHK10		ADDA	,X+
		DECB
		BNE	CHK10			; loop for all
		RTS				; return with checksum in A

***********************************************************************
*
*  Interrupt handlers to catch unused interrupts and traps
*  Registers are stacked.  Jump through RAM vector using X, type in A
*
*  This will affect only interrupt routines looking for register values!
*
*  Our default handler uses the code in "A" as the processor state to be
*  passed back to the host.
*

	IF STANDALONE

*  This is "reserved" on 6809
*  Used for Divide-by-zero and Illegal-instruction on 6309
RES_ENT		LDA	#7
		LDX	RAMVEC+0
		JMP	0,X
*
SWI3_ENT	LDA	#6
		LDX	RAMVEC+2
		JMP	0,X
*
SWI2_ENT	LDA	#5
		LDX	RAMVEC+4
		JMP	0,X
*
*  Will have only PC and CC's pushed unless we were waiting for an interrupt
*  or MD.1 is true.  Use CC's E bit to distinguish.
*  Push all registers here for common entry (else we can't use our RAM vector)
FIRQ_ENT	STA	REG_A	; SAVE A REG
		PULS	A		; GET CC'S FROM STACK
		BITA	#CC_E
		BNE	FIRQ9	; BR IF ALL REGISTERS PUSHED ALREADY
	IF CPU_6309

* CC.E was not set which means that regMD bit2 was not set and that bit in
* the image should be cleared. If CC.E is set, we can't tell what set it, a
* direct command, CWAI, or bit 1 of regMD.
*
* Push registers as if CC.E had been set
*  If 6809 mode, stack needs CC A B DP XH XL YH YL UH UL PCH PCL
*  If 6309 mode, stack needs CC A B E  F  DP XH XL YH YL UH  UL	 PCH PCL
*
		CLR	E_FLAG
		LDA	REG_MD
		ANDA	#$FD		; BIT1 must be clear, else all regs would have been pushed
		STA	REG_MD
		PSHS	U,Y,X,DP	; push regs next below PC

		STW	REG_F		; MD_TEST will not preserve regW
		JSR	MD_TEST
		PSHS	CC		; Save result
		LDW	REG_F		; Recover regW
		PULS	CC		; Recover result of test
		BNE	FE1
		PSHSW
FE1		PSHS	B
	ELSE
		PSHS	U,Y,X,DP,B	;ELSE PUSH THEM NOW
	ENDIF

		LDB	REG_A
		PSHS	B
		ORA	#CC_E		; SET AS "ALL REGS PUSHED"




FIRQ9	
	IF CPU_6309
		TST	E_FLAG
		BNE	FIRQ9B
		LDB	REG_MD		; We got here with E_FLAG clear and CC.E set which
		ORB	#2		; means regMD bit2 must be set.
		STB	REG_MD
FIRQ9B	
	ENDIF
		PSHS	A		; REPLACE CC'S
		LDA	#4
		LDX	RAMVEC+6
		JMP	0,X

IRQ_ENT		LDA	#3
		LDX	RAMVEC+8
		JMP	0,X
*
NMI_ENT		LDA	#2
		LDX	RAMVEC+12
		JMP	0,X
*
SWI_ENT		LDA	#1
		JMP	INT_ENTRY
	ELSE
		; in mos overlay these are jumped to from the two entry points at start of overlay
SWI_ENT		LDA	#1
		JMP	INT_ENTRY
NMI_ENT		LDA	#2
		JMP	INT_ENTRY

	ENDIF

	IF STANDALONE

*mostbl_VDU_6845_mode_45
*		 FCB	 $3F,$28,$31,$24,$26,$00,$20,$22 
*		 FCB	 $01,$07,$67,$08		 


mostbl_VDU_6845_mode_012
		FCB	$7F,$50,$62,$28,$26,$00,$20,$22
		FCB	$01,$07,$67,$08

	ENDIF

	IF CPU_6309
* TEST FOR BIT0 OF regMD:
* Exit emulation mode: regW=$1234
*      native	 mode: regW=$0000
*
* Preserves W and V.  Other registers destroyed.
*
MD_TEST	    
		PSHSW
*
* If 6809 mode, RTI will pop 12 bytes: CC A B DP XH XL YH YL UH UL PCH PCL
* If 6309 mode, RTI will pop 14 bytes: CC A B E	 F  DP XH XL YH YL UH  UL  PCH PCL
*
* Initialize TEST_STACK used for fake RTI. The return address will be MD_RETURN
* in both emulation and native modes. If native mode, regW will be cleared.
		LDX	#TEST_STACK

		TFR	CC,A
		ORA	#$80			; DB: changed to set CC on stack (was clearing interrupt flags!)
		STA	,X+			; CC with E set

		LDB	#9
RES11		CLR	,X+			; zeros for other registers, including W
		DECB
		BNE	RES11

		LDD	#MD_RETURN
		STD	,X++			; 6809 return address, or 6309 U
		STD	,X++			; 6309 return address, or past 6809 stack

		STS	S_IMAGE
		LDS	#TEST_STACK
		LDW	#$1234
		RTI				; if 6309 mode, W gets 0; else unchanged

MD_RETURN   
		LDS	S_IMAGE
		TSTW				; adjust CC.Z: set if 6309 mode
		PULSW
		RTS
	ENDIF

	IF STANDALONE
*********************************************************************************
*				S O U N D					*
*********************************************************************************


reset_snd
		LDA	#$FF			; portA all outputs
		STA	sheila_SYSVIA_ddra
		LDA	#$0F			; portB bottom 4 outputs, rest inputs
		STA	sheila_SYSVIA_ddrb
		LDA	#$04			; CA1 active leading edge
		STA	sheila_SYSVIA_pcr
		LDA	#$60
		STA	sheila_SYSVIA_acr	; turn off port latches etc

		LDA	#$08			; make snd latch high
1		STA	sheila_SYSVIA_orb
		INCA
		CMPA	#$10
		BLO	1B

		LDX	#100
1		LEAX	-1,X
		BNE	1B

		LDA	#0
		LDB	#$F
		JSR	snd_vol
		LDA	#1
		LDB	#$F
		JSR	snd_vol
		LDA	#2
		LDB	#$F
		JSR	snd_vol
		LDA	#3
		LDB	#$F
		JSR	snd_vol
		rts

snd_sendA
		PSHS	CC
		ORCC	#CC_I+CC_F
		LDB	#$FF
		STB	sheila_SYSVIA_ddra
		STA	sheila_SYSVIA_ora_nh	   ; set data
		LDB	#0
		STB	sheila_SYSVIA_orb	; we low
		LDB	#2
1		DECB
		BNE	1B
		LDB	#$08
		STB	sheila_SYSVIA_orb	; we high
		LDB	#4
1		DECB
		BNE	1B
anRTS		PULS	CC,PC

snd_vol
		RORA
		RORA
		RORA
		RORA
		ANDA	#$60
		ORA	#$90
		ANDB	#$0F
		PSHS	B
		ORA	,S+
		BRA	snd_sendA

snd_tone
		RORA
		RORA
		RORA
		RORA
		ANDA	#$60
		ORA	#$80
		PSHS	A,X
		LDA	2,S
		ANDA	#$F
		ORA	0,S
		JSR	snd_sendA
		LDA	2,S
		LDB	1,S		; get em reversed here as we want "course" in A
		RORB
		RORA

		RORB
		RORA

		LSRA

		LSRA

		LEAS	3,S
		BRA	snd_sendA


here3		
		FILL	$FF, REMAPPED_HW_VECTORS-here3-1

*
*============================================================================
*  VECTORS THROUGH RAM
		ORG	REMAPPED_HW_VECTORS

		FDB	RES_ENT		       ; f7f0 (reserved)
		FDB	SWI3_ENT	       ; f7f2 (SWI3)
		FDB	SWI2_ENT	       ; f7f4 (SWI2)
		FDB	FIRQ_ENT	       ; f7f6 (FIRQ)
		FDB	IRQ_ENT		       ; f7f8 (IRQ)
		FDB	SWI_ENT		       ; f7fa (SWI/breakpoint)
		FDB	NMI_ENT		       ; f7fc (NMI)
		FDB	RESET		       ; f7fe reset

here		
		FILL	$FF, $FFFF-here-1

	ENDIF

herend
	IF STANDALONE==0 && herend>=NOICE_CODE_BASE+NOICE_CODE_LEN
		ERROR	"OVERLAY CODE TOO BIG, INCREASE NOICE_CODE_LEN"
	ENDIF

		END
