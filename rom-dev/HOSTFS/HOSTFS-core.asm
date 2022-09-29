		include "../../includes/oslib.inc"
		include "../../includes/hardware.inc"
		include "../../includes/common.inc"
		include "../../includes/mosrom.inc"

		include "VERSION-date.gen.asm"

SWROM			EQU	1

DO_LANGUAGE		EQU	0
DO_TUBE			EQU	0

* Filing System values
* ====================
;HOSTFS_ESC		EQU	$9B
HOSTFS_ESC		EQU	$7F
HOSTFS_FSNO 		EQU	$09
HOSTFS_CHANLO		EQU	$80
HOSTFS_CHANHI		EQU	$9F
KEY_SEL_AT_BREAK	EQU	$60

ADDR_ERRBUF		EQU	$100			; base of stack!

		SETDP 0
ZP_ADDR_PROG		EQU	zp_fs_w + $00
ZP_ADDR_MEMTOP		EQU	zp_fs_w + $04
ZP_ADDR_TRANS		EQU	zp_fs_w + $06		; ADDR   - Data transfer address (assembler doesn't like 'INC ADDR')
ZP_ADDR_LPTR		EQU	zp_fs_w + $0A
ZP_ADDR_CMDPTR		EQU	zp_fs_w + $0E
ZP_ADDR_CTRLPTR		EQU	zp_fs_w + $0C		; OSFILE, OSGBPB control block
ZP_ESCFLG		EQU	$FF			; TODO - get this through API (somehow!)

		;TODO : move these to autogen'd files? Agree version # with JGH
VERSION_BYTE	MACRO
		FCB	0
		ENDM


VERSION_STRING	MACRO
		FCB	"0.24"
		ENDM

		ORG	$8000

M_ERROR		MACRO
		jsr	BounceErrorOffStack
		ENDM

TODO		MACRO
		M_ERROR
		FCB	$FF
		FCB	\1
		FCB	0
		ENDM




; ----------
; ROM HEADER
; ----------
	IF DO_LANGUAGE
;;		jmp	Language
	ELSE
		FCB	0,0,0
	ENDIF
		jmp	Service
		FCB	$83				; not a language, 6809 code
		FCB	Copyright-$8000
		VERSION_BYTE	
hostfs_name
		VERSION_NAME
		FCB	0
		VERSION_STRING
		FCB	" ("
		VERSION_DATE
		FCB	")"
Copyright
		FCB	0
		FCB	"(C) JGH+DOB"
		FCB	0
	IF DO_LANGUAGE
Language
		lbsr	HostFSOn2
		lbra	STARTUP2			; Enter with A=0
	ENDIF

SJTE		MACRO
		FCB	\1
		LBRA	\2
		ENDM

;* ----------------
;* SERVICE ROUTINES
;* ----------------
	;TODO make this relative!
Serv_jump_table
;		SJTE	$01, Serv1
		SJTE	$03, Serv3
		SJTE	$04, Serv4
		SJTE	$09, Serv9
;		SJTE	$0F, ServF
;		SJTE	$10, Serv10
		SJTE	$12, Serv12
		SJTE	$25, Serv25
		FCB	0

Service
		leay	Serv_jump_table,PCR
1		tst	,Y
		beq	ServiceOut
		cmpa	,Y+
		bne	2F
		jmp	,Y
2		leay	3,Y
		bra	1B
ServiceOut	rts
;
;* --------------------------------------
;* SERVICE 1 - Claim workspace/initialise
;* --------------------------------------
;Serv1
;		rts
;
* ---------------------------------------
* SERVICE 3 - Boot filing system on Break
* ---------------------------------------
Serv3
		pshs	B,X,Y
		tfr	X,D
		lda	#$7A
		jsr	OSBYTE				; Get key pressed
		tfr	X,D
		tstb
		cmpb	#$FF
		beq	Serv3Select			; Nothing pressed
		cmpb	#KEY_SEL_AT_BREAK
		beq	Serv3Select			; TAB-Break
notMyFilesystem
		lda	#3
		puls	B,X,Y,PC			; return with all regs intact for no capture
Serv3Select
;IF	CHECK_RTS
;			; If no RTS, do not select us
;		bsr	TestRTS
;		bne	SelectMyFilesystem
;		ldy	#0
;skiplp
;		lda	skipfstxt,Y
;		beq	notMyFilesystem
;		jsr	ummOSWRCH
;		iny
;		bne	skiplp
;skipfstxt
;		equs	"UPURSFS not selected; no RTS"
;		equb	10,13,10,13,0	
;ENDIF
SelectMyFilesystem
		lbsr	SelectFS
		bsr	Serv9a				; Select FS, print title
		jsr	OSNEWL
		tst	4,S				; test low byte of pushed Y
		bne	Serv3Ok				; No boot
		ldx	#0
		lda	#$FF
		jsr	[FSCV]				; Pass 'Booting' to host, Y=0
		tfr	X,D
		andb	#3
		beq	Serv3Ok				; Y=0, no Boot needed
		leax	Serv3Boot,PCR
		ldb	B,X
		leax	B,X
		jsr	OSCLI
Serv3Ok
		lda	#0
		puls	B,X,Y,PC				; Claim

Serv3Boot
		FCB	s3b_load-Serv3Boot		; offsets to load/run/exec !BOOT
		FCB	s3b_run-Serv3Boot
		FCB	s3b_exec-Serv3Boot
s3b_load	FCB	"L."
s3b_run		FCB	"!BOOT",13
s3b_exec	FCB	"E.!BOOT",13
;
;* --------------------
;* SERVICE 4 - *Command
;* --------------------
Serv4
		pshs	B,X
		leay	Serv25Table,PCR
Serv4Lp
		lda	,X+
		cmpa	#'.'
		beq	Serv4Dot
		cmpa	#'!'
		blo	Serv4End
		cmpa	,Y+
		beq	Serv4Lp				; Match with Filing System command
		eora	#$20
		cmpa	-1,Y				; try swapped case
		beq	Serv4Lp
Serv4Quit
		lda	#4
		puls	B,X,PC
Serv4End
		lda	-1,Y
		cmpa	#32
		bne	Serv4Quit			; Check for end of command
Serv4Dot
		lda	,X+
		cmpa	#' '
		beq	Serv4Dot			; Skip spaces
		anda	#$DF
		cmpa	#'O'
		bne	Serv4FS				; Not *HostFS Oxxx, select HostFS
		lda	,X+
		anda	#$DF
		cmpa	#'N'
		beq	HostFSOn			; *HostFS ON
		cmpa	#'F'
		beq	HostFSOff			; *HostFS OFF
Serv4FS
		lbsr	SelectFS
		lda	#0
		puls	B,X,PC

* -----------------
* SERVICE 9 - *Help
* -----------------
Serv9a
		pshs	B,X
		bra	Serv9a_2
Serv9
		pshs	B,X
		lda	,X+
		cmpa	#$0D
		bne	Serv9Exit			; Not *Help<cr>
		jsr	OSNEWL
Serv9a_2
		leax	hostfs_name,PCR
Serv9Lp
		lda	,X+
		bne	Serv9Chk			; Display ROM title
		lda	#' '
		bra	Serv9Char
Serv9Chk
		cmpa	#' '
		beq	Serv9Done
Serv9Char
		jsr	OSWRCH
		bra	Serv9Lp
Serv9Done
		jsr	OSNEWL
Serv9Exit
		lda	#9
		puls	B,X,PC
;
;* -----------------------------
;* SERVICE $0F - Vectors changed
;* -----------------------------
;ServF
;		rts
;
;* --------------------------------
;* SERVICE $10 - SPOOL/EXEC closing
;* --------------------------------
;Serv10
;		rts

;
;* --------------------------------------------
;* *HostFS ON|OFF command - connect Tube client
;* --------------------------------------------
;* NB, *HostFS ON doesn't catch Errors correctly
;*
HostFSOff
		lda	#0				; TODO: ask JGH shouldn't this do something?
		puls	B,X,PC
HostFSOn2
		pshs	B,X				; TODO: is this needed?
HostFSOn
;		pla
	 	ldx 	#6				; offset in normal vectors from CLIV (WRCHV)
		ldy	#21				; offset in extended vectors (WRCHV)
		ldb	#2				; # to copy (7 = FILEV-FSCV)
		bsr	SetVectors			; Set vectors
		bra	Serv12Serial			; Take over Serial system
; TODO ask JGH - this stuff seems dud, in original code it could never be hit? SetVectors always returns EQ
;;;		beq	Serv12Select			; Select HOSTFS
;;;		lda	$F4
;;;		sta	$190+252			; ROM to enter on BRK
;;;		pha
;;;		bra	Serv4FS
;
;* ----------------------------------
;* SERVICE $12 - Select filing system
;* ----------------------------------
Serv12
		pshs	B,X,Y
		cmpx	#HOSTFS_FSNO
		beq	Serv12Select
		puls	B,X,Y,PC
Serv12Select
		lda	#6
		jsr	[FSCV]				; New filing system taking over
		ldx	#10				; offset in normal vectors from CLIV (FILEV)
		ldy	#27				; offset in extended vectors (FILEV)
		ldb	#7				; # to copy (7 = FILEV-FSCV)
		bsr	SetVectors			; Set vectors
		lda	#143
		ldx	#15
		jsr	OSBYTE				; Vectors changed
Serv12Serial	
	IF MACH_CHIPKIT					; We're taking over Serial system
		; TODO: - call MOS?
		; Set 16650 to 19200 8n1 with FIFOs

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
BAUD_WORD	EQU SER_BAUD_CLOCK_IN/(BAUD_RATE*16)
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

*
*  enable FIFOS

		LDA	#$07
		STA	S16550_FCR

		; Set RTS off 
		LDA	#MCR_WAIT
		STA	S16550_MCR


	ELSIF MYELIN
		; no claim to make?
	ELSE
		lda	#156
		ldx	#ACIA_CTL_RxInit
		ldy	#0
		jsr	OSBYTE				; Disable ACIA IRQs, raise RTS
		lda	#232
		ldx	#0
		ldy	#0
		jsr	OSBYTE				; Mask out all ACIA IRQs
	ENDIF
		lda	#0
		puls	B,X,Y,PC

SetVectors
SetVectorLp
		m_tya					; get low byte of Y in A
		sta	CLIV+1,X			; Vect->ExVec
		lda	#$FF
		sta	CLIV+0,X
		lda	Vectors+0,X
		sta	EXT_USERV,Y			; ExVec->MyRoutine
		lda	Vectors+1,X
		sta	EXT_USERV+1,Y
		lda	$F4
		sta	EXT_USERV+2,Y
		leay	3,Y
		leax	2,X
		decb
		bne	SetVectorLp
		rts

; TODO Ask JGH - not sure about this Service call!
* ---------------------------------------
* SERVICE $25 - Filing system information
* ---------------------------------------
Serv25
		pshs	B,X
		ldy	Serv25Table
		ldb	#11				; table len
Serv25Lp
		lda	,Y+
		sta	,X+
		decb
		bne	Serv25Lp
		lda	#$25
		puls	B,X,PC

Serv25Table			FCB	"HOSTFS  "
Serv25Table_HOSTFS_CHANLO	FCB	HOSTFS_CHANLO
Serv25Table_HOSTFS_CHANHI	FCB	HOSTFS_CHANHI
Serv25Table_myfs		FCB	HOSTFS_FSNO


* ------------------
* Filing system code
* ------------------
SelectFS
		ldy	#HOSTFS_FSNO
		ldx	#SERVICE_12_INITFS
		lda	#OSBYTE_142_SERVICE_CALL
		jmp	OSBYTE

* ----------------------------
* I/O system routine addresses
* ----------------------------
Vectors
IOVectors
	IF DO_LANGUAGE or DO_TUBE
		fdb	MyosCLI
		fdb	MyosBYTE
		fdb	MyosWORD
		fdb	MyosWRCH
		fdb	MyosRDCH_IO
	ELSE
		fdb	0
		fdb	0
		fdb	0
		fdb	0
		fdb	0
	ENDIF
* Need some way of seeing that Host has not actioned
* a CLI/BYTE/WORD and pass them on locally.

* -------------------------------
* Filing system routine addresses
* -------------------------------
FSVectors
		fdb	MyosFILE
		fdb	HostARGS
		fdb	MyosBGET
		fdb	MyosBPUT
		fdb	MyosGBPB
		fdb	HostFIND
		fdb	HostFSCV

* ------------------------------
* Precheck OSARGS for local info
* ------------------------------
* Need to return filing system number and address of
* command line parameters locally. Master FileSwitch
* does this check itself, so these two calls are never
* passed here.
*
HostARGS
		cmpy	#0
		bne	TubeARGS
		cmpa	#1
		blo	HostARGS0
		beq	HostARGS1
TubeARGS
		lbra	MyosARGS

* ummOSARGS 0,0 - Return FS number
* -----------------------------
* Return fs=HostFS
HostARGS0
		lda	#HOSTFS_FSNO
		rts

;TODO: Ask JGH - double check endianness! (seems from technical.txt that all addrs are BE)
* ummOSARGS 1,0 - Return command line address
* ----------------------------------------
HostARGS1
		ldy	ZP_ADDR_CMDPTR
		sty	2,X
		lda	#$FF
		sta	0,X
		sta	1,X
		inca
		rts

* ---------------------------
* Precheck OSFIND for CLOSE#0
* ---------------------------
HostFIND
		cmpa	#0
		bne	TubeFind			; Not CLOSE
		cmpy	#0
		bne	TubeFind			; Not CLOSE#0
		pshs	A,X,Y
		lda	#OSBYTE_119_CLOSE_SPOOL_AND_EXEC
		jsr	OSBYTE				; Close Exec and Spool files
		puls	A,X,Y				; Restore for CLOSE#0
TubeFind
		lbra	MyosFIND

* ----------------
* Precheck for FSCV
* ----------------
* Need to find parameters on *commands to return
* later with ummOSARGS 1,0. Master FileSwitch does
* this itself, client does this within FSC.
HostFSCV
		cmpa	#6
		beq	HostFSCV6
		cmpa	#7
		beq	HostFSCV7
		cmpa	#8
		beq	HostFSCVQuit
		lbra	MyosFSCV
HostFSCV6
	IF MYELIN
		rts
	ELSE
		lda	#156
		ldx	#OSBYTE_156_SERIAL_STATE
		ldy	#0
		jsr	OSBYTE				; Release the Serial system
		lda	#OSBYTE_232_VAR_IRQ_MASK_SERIAL
		ldx	#255
		ldy	#0
		jmp	OSBYTE				; Pass ACIA IRQs back to MOS
	ENDIF
HostFSCV7
		ldx	#HOSTFS_CHANLO			; Lowest handle
		ldy	#HOSTFS_CHANHI			; Highest handle
HostFSCVQuit
		rts
;
* -----------------------------
* Generate a sideways ROM error in ADDR_ERRBUF *stack or other space*
* -----------------------------
brk_inst	BRK					; this is a macro on chipkit/beeb it is SWI3 on MB it is SWI
brk_inst_len	EQU	*-brk_inst
BounceErrorOffStack
		bsr	PrepErrBuf
		puls	X				; get back return address
1		lda	,X+				; copy error to stack / buffer
		sta	,Y+
		bne	1B
		jmp	ADDR_ERRBUF			; execute BRK from buffer

PrepErrBuf
		ldy	#ADDR_ERRBUF
		ldb	#brk_inst_len
		leax	brk_inst,PCR
1		lda	,X+
		sta	,Y+
		decb
		bne	1B
		rts


;* ----------
;* Debug code
;* ----------
;PrStack
;		php
;		pha
;		txa
;		pha
;		tsx
;		lda	$106,X
;		bsr	PrHex
;		lda	$107,X
;		bsr	PrHex
;		lda	$108,X
;		bsr	PrHex
;		lda	$109,X
;		bsr	PrHex
;		lda	$10A,X
;		bsr	PrHex
;		lda	$10B,X
;		bsr	PrHex
;		lda	$10C,X
;		bsr	PrHex
;		lda	$10D,X
;		bsr	PrHex
;		lda	$10E,X
;		bsr	PrHex
;		lda	$10F,X
;		bsr	PrHex
;		pla
;		tax
;		pla
;		plp
;		rts
;
;		if	NOT SWROM
;* Start of Tube system code
;* =========================
;* On hardware reset all of memory reads come from ROM, all writes go to RAM.
;* Accessing any I/O location pages ROM out of memory map, thence all reads
;* come from RAM.
;*
;LF800
;		bra	RESET
;PrBanner
;		bsr	PrText
;BANNER
;		equb	13
;		equs	"SERIAL TUBE 6502 64K "
;		equs	LEFT$(ver$+" ",5)
;		equb	13
;		equb	0
;		rts
;
;* Tube Client Startup Code
;* ========================
;RESET
;		sei
;		ldx	#$00			; Disable interupts
;LF802
;		lda	$FF00,X
;		sta	$FF00,X			; Copy entry block to RAM
;		dex
;		bne	LF802
;
;* The following code copies the page with the I/O registers in
;* it without accessing the I/O registers. Modify IOSPACE% according
;* to where the I/O registers actually are.
;
;		ldx	#IOSPACE% AND 255
;LF819
;		lda	$FDFF,X
;		sta	$FDFF,X			; Copy $FE00-$FEEF to RAM, avoiding
;		dex
;		bne	LF819			;  IO space at $FEFx
;
;		ldy	#ROMSTART% AND 255
;		sty	ZP_ADDR_LPTR+0			; Point to start of ROM
;		lda	#ROMSTART% DIV 256
;		sta	ZP_ADDR_LPTR+1
;LF82A			; Copy rest of ROM to RAM
;		lda	(ZP_ADDR_LPTR),Y
;		sta	(ZP_ADDR_LPTR),Y			; Copy a page to RAM
;		iny
;		bne	LF82A			; Loop for 256 bytes
;		inc	ZP_ADDR_LPTR+1
;		lda	ZP_ADDR_LPTR+1			; Inc. address high byte
;		cmp	#$FE
;		bne	LF82A			; Loop up to $FDFF
;
;STARTUP
;		sei
;		ldx	#$35
;LF80D
;		lda	LFF00,X
;		sta	USERV,X			; Set up default vectors
;		dex
;		bpl	LF80D
;		txs			;  and clear stack
;		lda	ACIA_CTL_TxInit
;		sta	sheila_ACIA_CTL			; Initialise port and page ROM out
;		lda	ACIA_CTL_RxInit
;		sta	sheila_ACIA_CTL
;			; Accessing I/O registers will page ROM out if running
;			; from RAM. Once ROM is paged out we can do subroutine
;			; calls as we can now read from stack in RAM.
;
;		lda	#$00
;		sta	ZP_ESCFLG
;		sta	ZP_ADDR_MEMTOP+0			; Clear Escape flag
;		lda	#ROMSTART% DIV 256
;		sta	ZP_ADDR_MEMTOP+1			; Set ZP_ADDR_MEMTOP to start of ROM
;		bsr	InitError			; Claim Error handler
;		lda	ZP_ADDR_PROG+0
;		sta	ZP_ADDR_TRANS+0			; Copy ZP_ADDR_PROG to ZP_ADDR_TRANS address
;		lda	ZP_ADDR_PROG+1
;		sta	ZP_ADDR_TRANS+1
;
;* Tell the Host that we've restarted
;* ----------------------------------
;* Tube data  $18 $00 $FF $FF  --  Cy Y X
;*            followed by string
;*
;* Note for Host authors, Host MUST NOT respond by echoing back a SoftReset
;* as the Client will be trapped in an infinite STARTUP loop. If Host wants
;* to read Client to determine CPU this will change ZP_ADDR_TRANS so must only be
;* done if a later transaction will set ZP_ADDR_TRANS after a language transfer, eg
;* on Hard Reset.
;*
;		ldx	#0
;		lda	#$FF
;		tay
;		bsr	MyosFSCV			; As we are using a serial link, send a Soft Reset
;		txa
;STARTUP2
;		pha			; Save returned Ack byte, will be $00 if no response
;		bsr	PrBanner
;		jsr	ummOSNEWL			; Display startup banner
;		lda	#CmdPrompt AND 255			; Next time RESET is soft entered,
;		sta	LF800+1			;  banner not printed
;		lda	#CmdPrompt DIV 256
;		sta	LF800+2
;		pla
;		clc
;		bsr	WaitCheckCode			; Check Ack code, if $80 enter code,
;			;  else enter command prompt loop
;
;
;* Supervisor Command prompt
;* =========================
;CmdPrompt
;		ldx	#$FF
;		txs
;		bsr	InitError			; Reset stack, claim Error handler
;		lda	#CmdPrompt AND 255
;		sta	ZP_ADDR_PROG+0			; Make Command Prompt the current program
;		lda	#CmdPrompt DIV 256
;		sta	ZP_ADDR_PROG+1
;CmdOSLoop
;		lda	#'*'
;		jsr	ummOSWRCH			; Print '*' prompt
;		ldx	#LF95D AND 255
;		ldy	#LF95D DIV 256
;		lda	#$00
;		jsr	ummOSWORD			; Read line to INPBUF
;		bcs	CmdOSEscape
;		ldx	#INPBUF AND 255
;		ldy	#INPBUF DIV 256			; Execute command
;		jsr	ummOSCLI
;		bra	CmdOSLoop			;  and loop back for another
;CmdOSEscape
;		lda	#$7E
;		jsr	OSBYTE			; Acknowledge Escape state
;		M_ERROR
;		equb	17
;		equs	"Escape"
;		brk
;
;* Control block for command prompt input
;* --------------------------------------
;LF95D
;		equw	INPBUF			; Input text to INPBUF at $236
;		equb	INPEND-INPBUF			; Up to $CA characters
;		equb	$20
;		equb	$FF			; Min=$20, Max=$FF
;
;
;* Error handler
;* =============
;InitError
;		lda	#ErrorHandler AND 255
;		sta	BRKV+0			; Claim Error handler
;		lda	#ErrorHandler DIV 256
;		sta	BRKV+1
;		rts
;
;ErrorHandler
;		ldx	#$FF
;		txs			; Reset stack
;		jsr	ummOSNEWL
;		ldx	FAULT+0
;		ldy	FAULT+1
;		inx
;		bne	*+3
;		iny			; XY=>Error string
;		bsr	PRSTRNG			; Print Error string
;		jsr	ummOSNEWL
;		bra	CmdPrompt			; Jump to command prompt
;
;
;* Interrupt handlers
;* ==================
;IRQHandler
;		sta	IRQA
;		pla
;		pha			; Save A, get flags from stack
;		and	#$10
;		bne	BRKHandler			; If BRK, jump to BRK handler
;		bra	(IRQ1V)			; Continue via IRQ1V handler
;IRQ1Handler
;		bra	(IRQ2V)			; Pass on to IRQ2V
;BRKHandler
;		txa
;		pha			; Save X
;		tsx
;		lda	$0103,X			; Get address from stack
;		cld
;		sec
;		sbc	#$01
;		sta	FAULT+0
;		lda	$0104,X
;		sbc	#$00
;		sta	FAULT+1			; $FD/E=>after BRK opcode
;		pla
;		tax
;		lda	IRQA			; Restore X, get saved A
;		cli
;		bra	(BRKV)			; Restore IRQs, jump to Error Handler
;IRQ2Handler
;		lda	IRQA			; Restore saved A
;NMIHandler
;		rti
;
;
* Skip Spaces
* ===========
;SkipSpaces1
;		iny
;SkipSpaces
;		lda	(ZP_ADDR_LPTR),Y
;		cmp	#$20
;		beq	SkipSpaces1
;NullReturn
;		rts

SkipSpaces	lda	,X+
		cmpa	#' '
		beq	SkipSpaces
		leax	-1,X
		rts

;
;* Scan hex
;* ========
;ScanHex
;		ldx	#$00
;		stx	NUM+0
;		stx	NUM+1			; Clear hex accumulator
;LF98C
;		lda	(ZP_ADDR_LPTR),Y			; Get current character
;		cmp	#$30
;		bcc	LF9B1			; <'0', exit
;		cmp	#$3A
;		bcc	LF9A0			; '0'..'9', add to accumulator
;		and	#$DF
;		sbc	#$07
;		bcc	LF9B1			; Convert letter, if <'A', exit
;		cmp	#$40
;		bcs	LF9B1			; >'F', exit
;LF9A0
;		asl	A
;		asl	A
;		asl	A
;		asl	A			; *16
;		ldx	#$03			; Prepare to move 3+1 bits
;LF9A6
;		asl	A
;		rol	NUM+0
;		rol	NUM+1			; Move bits into accumulator
;		dex
;		bpl	LF9A6			; Loop for four bits, no overflow check
;		iny
;		bne	LF98C			; Move to next character
;LF9B1
;		rts
;
;
* MOS INTERFACE
* ~~~~~~~~~~~~~
*
*
* myosRDCH - Wait for character from input stream
* =============================================
* On exit, A =char, Cy=Escape flag
*
MyosRDCH
		pshs	B
		lbsr	WaitByte			; Wait for character
		ldb	ZP_ESCFLG
		aslb					; Get Escape flag to carry
		puls	B,PC				; Get character to A and return


* ummOSRDCH - Request character via Tube
* ===================================
* On exit, A =char, Cy=Escape flag
*
* Tube data  $00  --  Carry Char
*
MyosRDCH_IO
		clra
		lbsr	SendCommand			; Send command $00 - ummOSRDCH
WaitCarryChar						; Wait for Carry and A
		lbsr	WaitByte			; Wait for carry
		asla
		lbra	WaitByte


* OSCLI - Execute command
* =======================
* On entry, XY=>command string
* On exit,  All registers corrupted

* Local *commands
* ---------------
CmdTable
		FCB	"GO"
		FCB	$80
		FCB	"HELP"
		FCB	$81
		FCB	0

MyosCLI
		stx	ZP_ADDR_LPTR
;		sty	ZP_ADDR_LPTR+1				; ZP_ADDR_LPTR=>command string
;		ldy	#$00
LF9D1
		bsr	SkipSpaces
		lda	,X+
		cmpa	#'*'
		beq	LF9D1				; Skip spaces and stars
; TODO: Ask JGH this doesn't smell right need to convert to upper and should it be BCC anyway?
;;;		cmpa	#'A'
;;;		bcs	osCLI_IO			; Doesn't start with a letter
		leax	-1,X				; Step back
		pshs	X				; Save start of command line
		leay	CmdTable,PCR
osCLIlp2
;		inx
;		iny					; Step to next characters
; TODO: Ask JGH F2 here but it's ZP_ADDR_LPTR above is this right?
;		lda	($F2),Y
		lda	,X+
		cmpa	#'.'
		beq	osCLIdot			; Abbreviated command
		anda	#$DF
		cmpa	,Y+
		beq	osCLIlp2			; Check next character
		lda	-1,Y
		bmi	osCLImatch
		bpl	osCLIskip			; Not full command, skip
;; TODO: Ask JGH there were two .osCLIdot's in the original which is right?
;;osCLIdot
;;		lda	,Y
;;		bpl	osCLInext			; Dot not at end of full command
osCLIskip
		leay	-1,Y
		SEC
osCLInext
		leay	1,Y
osCLIdot
		lda	,Y
		bpl	osCLInext			; Step to end of entry
		bcc	osCLIfound
		ldx	0,S				; Restore line pointer to start of command
		lda	1,Y
		bne	osCLIlp2			; Not at end of table
		leas	2,S				; unstack saved X
		bra	osCLI_IO			; Pass to Tube
osCLImatch
		lda	,X
		cmpa	#'A'
		bhs	osCLInext			; More letters, check next entry
osCLIfound
		leas	2,S				; unstack saved X
		bsr	SkipSpaces			; Drop saved offset, skip spaces
		lda	,Y				; Get command byte
		cmpa	#$81
		beq	CmdHelp				; $81, jump to *Help
			; Fall through to *Go

* *GO - call machine code
* -----------------------
CmdGo
	TODO "CmdGo"
;		bsr	ScanHex
;		bsr	SkipSpaces			; Read hex value and move past spaces
;		cmp	#$0D
;		bne	osCLI_IO			; More parameters, pass to Tube to deal with
;		txa
;		beq	CmdGo2
;		ldx	#NUM-ZP_ADDR_PROG			; If no parameters, jump to ZP_ADDR_PROG, else jump to NUM
;CmdGo2
;		lda	ZP_ADDR_PROG+0,X
;		sta	ZP_ADDR_TRANS+0			; Set address to jump to
;		lda	ZP_ADDR_PROG+1,X
;		sta	ZP_ADDR_TRANS+1
;		bcs	SaveEnterCode			; CS set from CMP earlier
;
;* *Help - Display help information
;* --------------------------------
CmdHelp
	TODO "CmdHelp"
;		bsr	PrBanner			; Print help message
;			; Continue to pass '*Help' command to Tube
;

* OSCLI - Send command line to host
* =================================
* On entry, $F8/9=>command string
*
* Tube data  $02 string $0D  --  $7F or $80
*
osCLI_IO
		lda	#$02
		lbsr	SendCommand			; Send command $02 - OSCLI
		lbsr	SendStringLPTR			; Send command string at ZP_ADDR_LPTR
			
		; Drop through to wait for Ack and enter code

WaitEnterCode
		lbsr	WaitByte
		SEC					; Wait for Ack from Tube
WaitCheckCode
		rola
		bcc	SaveEnterDone			; If <$80, exit
		rora					; Restore Carry, CC=RESET, CS=OSCLI
SaveEnterCode
		ldx	ZP_ADDR_PROG
		pshs	X
		lbsr	EnterCode
		puls	X
		stx	ZP_ADDR_PROG
		stx	ZP_ADDR_MEMTOP
SaveEnterDone
		rts


* FSCV - FSCV Functions
* ===================
* OLD 6502 API:
* 	On entry, A, X, Y=FSCV parameters
* 	On exit,  A, X, Y=return values
*
* 	Tube data  $18 X Y A  --  $FF Y X or
*                           	  $7F then string -- respsonse
* New API
* 	On entry, A, X=FSCV parameters
* 	On exit,  A, X=return values
*
* 	Tube data  $18 X(lo) X(hi) A  --  	$FF X(hi) X(lo) or
*                           	  		$7F then string -- respsonse
*
MyosFSCV
		pshs	A
		lda	#$18
		SEC
		bra	ByteHi2

;
;* OSBYTE - Byte MOS functions
;* ===========================
;* On entry, A, X, Y=OSBYTE parameters
;* On exit,  A  preserved
;*           If A<$80, X=returned value
;*           If A>$7F, X, Y, Carry=returned values
;*
;MyosBYTE
;		cmp	#$80
;		bcs	ByteHigh			; Jump for long OSBYTEs
;*
;* BYTELO
;* Tube data  $04 X A    --  X
;*
;		pha
;		lda	#$04
;		bsr	SendCommand			; Send command $04 - BYTELO
;		txa
;		bsr	SendByte			; Send single parameter
;		pla
;		pha
;		bsr	SendByte			; Send function
;		bsr	WaitByte
;		tax					; Get return value
;		pla
;		rts					; Restore A and return
;
;ByteHigh
;		cmp	#$82
;		beq	Byte82				; Read memory high word
;		cmp	#$83
;		beq	Byte83				; Read bottom of memory
;		cmp	#$84
;		beq	Byte84				; Read top of memory

; API CHANGE -- was XY here now X(lo) X(hi)
;*
;* BYTEHI
;* Tube data  $06 X Y A  --  Cy Y X
;*
;		pha
;		lda	#$06
;		clc
ByteHi2
		pshs	CC
		lbsr	SendCommand
		puls	CC				; Send command $06 or $18 - BYTEHI or FSC
		tfr	X,D
		exg	A,B
		lbsr	SendByte			; Send first parameter
		tfr	B,A
		lbsr	SendByte			; Send second parameter
		puls	A
		lbsr	SendByte			; Send function
		bcs	ByteHi3				; Skip OSBYTE checks
		cmpa	#$8E
		beq	WaitEnterCode			; If select language, check to enter code
		cmpa	#$9D
		beq	LFAEFrts
		CLC					; Fast return with Fast BPUT
ByteHi3
		pshs	A
		lbsr	WaitByte
		bcc	ByteHi4				; Get Carry or byte/string response
		asla
		bcc	FSCString			; Jump to send FSC string
ByteHi4
		asla
		lbsr	WaitByte
		tfr	A,B				; Get return high byte
		lbsr	WaitByte
		exg	A,B				; Get return lo byte
		tfr	D,X				
		puls	A,PC
LFAEFrts
		rts
;
;Byte84
;		ldx	ZP_ADDR_MEMTOP+0
;		ldy	ZP_ADDR_MEMTOP+1
;		rts			; Read top of memory
;Byte83
;		ldx	#$00
;		ldy	#$08
;		rts			; Read bottom of memory
;Byte82
;		ldx	#$00
;		ldy	#$00
;		rts			; Return $0000 as memory high word
;
FSCString
		leas	1,S				; discard stacked A
		lbsr	SendString			; Send string
FSCStrLp2
		lda	,X+
		cmpa	#'!'
		bhs	FSCStrLp2			; Skip to ' ' or <cr>
		leay	-1,X
FSCStrLp3
		lda	,X+
		cmpa	#' '
		beq	FSCStrLp3			; Skip to non-' '
		leay	-1,X
		sty	ZP_ADDR_CMDPTR
		bsr	WaitEnterCode			; Wait for Ack, enter code if needed
		bpl	LFAEFrts			; Response=<$40, all done, return response
			; Response=$40 ($80 at this point), print text
FSCStrChr
		lbsr	WaitByte			; Wait for a character
		cmpa	#$00
		beq	LFAEFrts			; $00 terminates string
		jsr	OSWRCH
		bra	FSCStrChr			; Print character
;
;
;* ummOSWORD - Various functions
;* ==========================
;* On entry, A =function
;*           XY=>control block
;*
;MyosWORD
;		stx	ZP_ADDR_LPTR+0
;		sty	ZP_ADDR_LPTR+1			; ZP_ADDR_LPTR=>control block
;		tay
;		beq	RDLINE			; ummOSWORD 0, jump to read line
;*
;* Tube data  $08 A in_length block out_length  --  block
;*
;		pha
;		pha			; Save function
;		lda	#$08
;		bsr	SendCommand			; Send command $08 - ummOSWORD
;		pla
;		bsr	SendByte			; Send function
;		tax
;		bpl	WordSendLow			; Jump with functions<$80
;		ldy	#$00
;		lda	(ZP_ADDR_LPTR),Y			; Get send block length from control block
;		tay
;		bra	WordSend			; Jump to send control block
;
;WordSendLow
;		ldy	WordLengthsTx-1,X			; Get send block length from table
;		cpx	#$15
;		bcc	WordSend			; Use this length for ummOSWORD 1 to $14
;		ldy	#$10			; Send 16 bytes for ummOSWORD $15 to $7F
;WordSend
;		tya
;		bsr	SendByte			; Send send block length
;		dey
;		bmi	LFB45			; Zero or $81..$FF length, nothing to send
;LFB38
;		lda	(ZP_ADDR_LPTR),Y
;		bsr	SendByte			; Send byte from control block
;		dey
;		bpl	LFB38			; Loop for number to be sent
;LFB45
;		txa
;		bpl	WordRecvLow			; Jump with functions<$80
;		ldy	#$01
;		lda	(ZP_ADDR_LPTR),Y			; Get receive block length from control block
;		tay
;		bra	WordRecv			; Jump to receive control block
;
;WordRecvLow
;		ldy	WordLengthsRx-1,X			; Get receive length from table
;		cpx	#$15
;		bcc	WordRecv			; Use this length for ummOSWORD 1 to $14
;		ldy	#$10			; Receive 16 bytes for ummOSWORD $15 to $7F
;WordRecv
;		tya
;		bsr	SendByte			; Send receive block length
;		dey
;		bmi	LFB71			; Zero of $81..$FF length, nothing to receive
;LFB64
;		bsr	WaitByte
;		sta	(ZP_ADDR_LPTR),Y			; Get byte to control block
;		dey
;		bpl	LFB64			; Loop for number to receive
;LFB71
;		ldy	ZP_ADDR_LPTR+1
;		ldx	ZP_ADDR_LPTR+0
;		pla			; Restore registers
;		rts
;
;
;* RDLINE - Read a line of text
;* ============================
;* On entry, A =0
;*           XY=>control block
;* On exit,  A =undefined
;*           Y =length of returned string
;*           Cy=0 ok, Cy=1 Escape
;*
;* Tube data  $0A block  --  $FF or $7F string $0D
;*
;RDLINE
;		opt	FNif(RDLINE%)			; Perform RDLINE locally
;		ldy	#2
;		lda	(ZP_ADDR_LPTR),Y
;		sta	ZP_ADDR_LPTR+2			; Copy control block to w/s
;		dey
;		lda	(ZP_ADDR_LPTR),Y
;		tax
;		dey
;		lda	(ZP_ADDR_LPTR),Y
;		sta	ZP_ADDR_LPTR+0
;		stx	ZP_ADDR_LPTR+1			; (ZP_ADDR_LPTR)=>string buffer, ZP_ADDR_LPTR+2=max length
;Word00Lp1
;		jsr	ummOSRDCH
;		bcs	Word00Esc			; Wait for character
;		cmp	#$7F
;		bne	Word00Char			; Not Delete
;Word00Delete
;		tya
;		beq	Word00Lp1			; Nothing to delete
;		lda	#$7F
;		jsr	ummOSWRCH			; VDU 127
;		dey
;		bra	Word00Lp1			; Dec. counter, loop back
;Word00Char
;		cmp	#$08
;		beq	Word00Delete			; BS is also Delete
;		cmp	#$15
;		bne	Word00Ins			; Not ZP_ADDR_CTRLPTR-U
;		tya
;		beq	Word00Lp1			; Nothing to delete
;		lda	#$7F
;Word00Lp2
;		jsr	ummOSWRCH
;		dey			; Delete characters
;		bne	Word00Lp2
;		beq	Word00Lp1			; Jump back to start
;Word00Ins
;		sta	(ZP_ADDR_LPTR),Y			; Store character
;		cmp	#$0D
;		clc
;		beq	Word00cr			; Return - finish
;		cpy	ZP_ADDR_LPTR+2
;		bcs	Word00max			; Maximum length
;		cmp	#$20
;		bcs	Word00ctrl			; Control character
;		dey			; Cancel following INY
;Word00ctrl
;		iny
;		jsr	ummOSWRCH			; Inc. counter, print character
;Word00max
;		bra	Word00Lp1			; Loop for more
;Word00cr
;		jsr	ummOSNEWL
;		clc			; Return with CC, Y=length
;Word00Esc
;		rts
;		opt	FNelse
;		lda	#$0A
;		bsr	SendCommand			; Send command $0A - RDLINE
;		ldy	#$04
;LFB7E
;		lda	(ZP_ADDR_LPTR),Y
;		bsr	SendByte			; Send control block
;		dey
;		cpy	#$01
;		bne	LFB7E			; Loop for 4, 3, 2
;		lda	#$07
;		bsr	SendByte			; Send $07 as address high byte
;		lda	(ZP_ADDR_LPTR),Y
;		pha			; Get text buffer address high byte
;		dey
;		tya
;		bsr	SendByte			; Send $00 as address low byte
;		lda	(ZP_ADDR_LPTR),Y
;		pha			; Get text buffer address low byte
;		ldx	#$FF
;		bsr	WaitByte			; Wait for response
;		asl	A
;		bcs	RdLineEscape			; Jump if Escape returned
;		pla
;		sta	ZP_ADDR_LPTR+0
;		pla
;		sta	ZP_ADDR_LPTR+1
;		ldy	#$00			; Set $F8/9=>text buffer
;RdLineLp
;		bsr	WaitByte
;		sta	(ZP_ADDR_LPTR),Y			; Store returned character
;		iny
;		cmp	#$0D
;		bne	RdLineLp			; Loop until <cr>
;		lda	#$00
;		dey
;		clc
;		inx			; Return A=0, Y=len, X=00, Cy=0
;		rts
;RdLineEscape
;		pla
;		pla
;		lda	#$00			; Return A=0, Y=len, X=FF, Cy=1
;		rts
;		opt	FNendif
;
;* ummOSWORD control block lengths
;* ----------------------------
;WordLengthsTx
;		equb	$00
;		equb	$05
;		equb	$00
;		equb	$05
;		equb	$04
;		equb	$05
;		equb	$08
;		equb	$0E
;		equb	$04
;		equb	$01
;		equb	$01
;		equb	$05
;		equb	$00
;		equb	$08
;		equb	$20
;		equb	$10
;		equb	$0D
;		equb	$00
;		equb	$04
;		equb	$80
;WordLengthsRx
;		equb	$05
;		equb	$00
;		equb	$05
;		equb	$00
;		equb	$05
;		equb	$00
;		equb	$00
;		equb	$00
;		equb	$05
;		equb	$09
;		equb	$05
;		equb	$00
;		equb	$08
;		equb	$19
;		equb	$00
;		equb	$01
;		equb	$0D
;		equb	$80
;		equb	$04
;		equb	$80
;
;
* ummOSARGS - Read info on open file
* ===============================
* On entry, A =function
*           X =>data word in zero page
*           Y =handle
* On exit,  A =returned value
*           X  preserved
*           Y  preserved
*
* Tube data  $0C handle block function  --  result block
*
MyosARGS
		pshs	A
		lda	#$0C
		lbsr	SendCommand			; Send command $0C - ummOSARGS
		m_tya
		lbsr	SendByte			; Send handle
		lda	$03,X
		lbsr	SendByte			; Send data word
		lda	$02,X
		lbsr	SendByte
		lda	$01,X
		lbsr	SendByte
		lda	$00,X
		lbsr	SendByte
		puls	A
		lbsr	SendByte			; Send function
		lbsr	WaitByte
		pshs	A				; Get and save result
		lbsr	WaitByte
		sta	$03,X				; Receive data word
		lbsr	WaitByte
		sta	$02,X
		lbsr	WaitByte
		sta	$01,X
		lbsr	WaitByte
		sta	$00,X
		puls	A
		rts			; Get result back and return


* ummOSBGET - Get a byte from open file
* ==================================
* On entry, Y =handle
* On exit,  A =byte Read
*           Y =preserved
*           Cy set if EOF
*
* Tube data  $0E handle --  Carry byte
*
MyosBGET
		lda	#$0E
		lbsr	SendCommand			; Send command $0E - ummOSBGET
		m_tya
		lbsr	SendByte			; Send handle
		lbra	WaitCarryChar			; Jump to wait for Carry and byte


* OSBPUT - Put a byte to an open file
* ===================================
* On entry, A =byte to write
*           Y =handle
* On exit,  A =preserved
*           Y =preserved
*
* Tube data  $10 handle byte  --  $7F
*
MyosBPUT
		pshs	A
		lda	#$10
		lbsr	SendCommand			; Send command $10 - ummOSBPUT
		m_tya
		lbsr	SendByte			; Send handle
		puls	A
		lbsr	SendByte			; Send byte
		pshs	A
		lbsr	WaitByte
		puls	A
		rts					; Wait for acknowledge and return


* ummOSFIND - Open or Close a file
* =============================
* On entry, A =function
*           Y =handle or XY=>filename
* On exit,  A =zero or handle
*
* Tube data  $12 function string $0D  --  handle
*            $12 $00 handle  --  $7F
*
MyosFIND
		pshs	A
		lda	#$12
		lbsr	SendCommand			; Send command $12 - ummOSFIND
		puls	A
		lbsr	SendByte			; Send function
		cmpa	#$00
		bne	OPEN				; If <>0, jump to do OPEN
CLOSE
		pshs	A
		m_tya
		bsr	SendByte			; Send handle
		lbsr	WaitByte
		puls	A
		rts			; Wait for acknowledge, restore regs and return
OPEN
		bsr	SendString			; Send pathname
		lbra	WaitByte			; Wait for and return handle


* OSFILE - Operate on whole files
* ===============================
* On entry, A =function
*           X=>control block
* On exit,  A =result
*           control block updated
*
* Tube data  $14 block string <cr> function  --  result block
*
; TODO: byte order swaps?
MyosFILE
		pshs	D,X,Y
		stx	ZP_ADDR_CTRLPTR
		lda	#$14
		bsr	SendCommand			; Send command $14 - ummOSFILE

;; ;; 		ldb	#$0E				; point at End Addr /attributes
;; ;; LFC5F
;; ;; 		lda	B,X
;; ;; 		bsr	SendByte			; Send control block
;; ;; 		decb
;; ;; 		cmpb	#$01
;; ;; 		bne	LFC5F				; Loop for $11..$02
		; on original 6502 sends bytes $11..$02 in reverse order
		; here we need to swap endianness at the same time

		ldb	#$E-2				; End addr
		leax	2,X
1		lda	B,X
		bsr	SendByte
		incb
		bitb	#3
		bne	1B				; send 4 bytes then 
		subb	#8				; go back to previous word
		bpl	1B
		leax	-2,X

		ldx	,X				; Get pathname address to X		
		bsr	SendString			; Send pathname
		puls	A
		bsr	SendByte			; Send function
		bsr	WaitByte
		pshs	A				; Wait for result

		ldb	#$11
;; ;;		ldx	ZP_ADDR_CTRLPTR
;; ;;LFC7E
;; ;;		bsr	WaitByte
;; ;;		sta	B,X				; Get control block back
;; ;;		decb
;; ;;		cmpb	#$01
;; ;;		bne	LFC7E				; Loop for $11..$02

		ldx	ZP_ADDR_CTRLPTR
		leax	2,X
		ldb	#$E-2				; End addr
1		bsr	WaitByte
		sta	B,X
		incb
		bitb	#3
		bne	1B				; send 4 bytes then 
		subb	#8				; go back to previous word
		bpl	1B

		puls	D,X,Y,PC			; Get result and return


* ummOSGBPB - Multiple byte Read and write
* =====================================
* On entry, A =function
*           X=>control block
* On exit,  A =returned value
*              control block updated
*
* Tube data  $16 block function  --   block Carry result
*
;	TODO: I suspect this will need byte rearranged!? for BE/LE
MyosGBPB
		pshs	A,X
		lda	#$16
		bsr	SendCommand			; Send command $16 - ummOSGBPB
		ldb	#$0C
LFC9A
		lda	B,X
		bsr	SendByte			; Send control block
		decb
		bpl	LFC9A				; Loop for $0C..$00
		puls	A
		bsr	SendByte			; Send function
		ldb	#$0C
		ldx	0,S
LFCA8		bsr	WaitByte
		sta	B,X				; Get control block back
		decb
		bpl	LFCA8				; Loop for $0C..$00
		puls	X
		lbra	WaitCarryChar			; Jump to get Carry and result

* Tube I/O routines
* =================

* Send a string
* -------------
SendString
		stx	ZP_ADDR_LPTR
SendStringLPTR
LF9B8
		lda	,X+
		bsr	SendByte			; Send character to I/O
		cmpa	#$0D
		bne	LF9B8				; Loop until <cr> sent
		ldx	ZP_ADDR_LPTR
		rts			
;
;
;* ummOSWRCH - Send character to output stream
;* ========================================
;* On entry, A =character
;* On exit,  A =preserved
;*
;* Tube data  character  --
;*
;MyosWRCH			; WRCH is simply SendByte
;
;
;* Tube Core I/O Routines
;* ======================
;* Characters and commands are sent over the same single port
;* Outward commands are escaped, and inward responses are escaped
;*
;* Outward
;*   x                 VDU x
;*   HOSTFS_ESC,HOSTFS_ESC           VDU HOSTFS_ESC
;*   HOSTFS_ESC,n             MOS function, control block follows
;*
;* Inward
;*   x                 char/byte x
;*   HOSTFS_ESC,HOSTFS_ESC           char/byte HOSTFS_ESC
;*   HOSTFS_ESC,$00           BRK, Error number+text+null follows
;*   HOSTFS_ESC,<$80          read returned control block set length
;*   HOSTFS_ESC,$8n           Escape change, b0=new state
;*   HOSTFS_ESC,$9x,Y,X,A     Event
;*   HOSTFS_ESC,$Ax           reserved for networking
;*   HOSTFS_ESC,$Bx           end transfer
;*   HOSTFS_ESC,$Cx,addr      set address
;*   HOSTFS_ESC,$Dx,addr      execute address
;*   HOSTFS_ESC,$Ex,addr      start load from address
;*   HOSTFS_ESC,$Fx,addr      start save from address
;*   All commands are data inward, except HOSTFS_ESC,$Fx which is data outward
;
;
* Send a byte, escaping it if needed
* ----------------------------------
* On entry, A=byte to send
* On exit,  A,P preserved
*
SendByte
		pshs	CC
		lbsr	SendData			; Send byte
		cmpa	#HOSTFS_ESC
		bne	SendByte2			; If not HOSTFS_ESC, done
		lbsr	SendData			; If HOSTFS_ESC, send twice to prefix it
SendByte2
		puls	CC,PC

* Send an escaped command
* -----------------------
* On entry, A=command
* On exit,  A,X,Y preserved, P corrupted
SendCommand
		pshs	A
SendCmdLp
		bsr	ReadByte
		bcs	SendCmdLp			; Flush input
		lda	#HOSTFS_ESC
		lbsr	SendData			; Send HOSTFS_ESC prefix
		puls	A
		lbra	SendData			; Send command byte (always <$80)

* Check if a byte is waiting, and read it if there
* ------------------------------------------------
* On exit, P=EQ CC - nothing waiting
*          P=NE CS - byte waiting, returned in A
*
ReadByte
		lbsr	ReadData			; See if data present
		pshs	CC
		bcs	WaitByte2			; Data present, continue with it
		puls	CC
		lda	#0
		rts			; No data present

* Wait for a byte, decoding escaped data
* --------------------------------------
* On exit, A =byte
*          P =preserved
*
WaitByte
		pshs	CC
WaitByteLp
		bsr	WaitData			; Wait for data present
WaitByte2
		bne	WaitByteOk			; Not HOSTFS_ESC, return it
		bsr	WaitData
		beq	WaitByteOk			; HOSTFS_ESC,HOSTFS_ESC, return as HOSTFS_ESC
		pshs	D,X,Y
		bsr	WaitCommand			; Decode escaped command
		puls	D,X,Y
		bra	WaitByteLp			; Loop back to wait for a byte
WaitByteOk
		puls	CC,PC				; Restore flags

* Wait for raw byte of data
* -------------------------
* On exit, A =byte
*          P =EQ byte=HOSTFS_ESC, NE byte<>HOSTFS_ESC
*
WaitData
		lbsr	ReadData
		bcc	WaitData			; Loop until data present
		rts

* Decode escaped command
* ----------------------
* On entry, A=command, P set accordingly
* All registers can be trashed
*
WaitCommand
		tsta
		beq	WaitError			; HOSTFS_ESC,$00 - Error
		bmi	WaitTransfer			; HOSTFS_ESC,>$7F - data transfer

* HOSTFS_ESC,1..127 - read a control block
* ---------------------------------
		tfr	A,B				; Move count to B
		ldx	ZP_ADDR_CTRLPTR
		abx
WaitLength
		bsr	WaitByte			; Wait for a byte
		sta	,-X				; Store it
		decb
		bpl	WaitLength
		rts

;* HOSTFS_ESC,$00 - Error
;* ---------------
WaitError
		jsr	PrepErrBuf			; Y now points after SWI/SWI3 instruction in ERRBUF
		bsr	WaitByte
		sta	,Y+				; Store Error number
WaitErrorLp
		bsr	WaitByte
		sta	,Y+				; Store Error character
		cmpa	#0
		bne	WaitErrorLp			; Loop until final $00

		ldx	#$2000
WaitErr1
		leax	-1,X
		bne	WaitErr1			; Pause a while to let Host
							; reconnect after an Error

		bsr	WaitExitRelease			; Release Tube, restore Screen
		lda	-1,Y
		ora	-2,Y				; Check for Error 0,""
		beq	1F
		lbra	ADDR_ERRBUF			; Jump to Error, no return
1		
	IF DO_TUBE or DO_LANGUAGE
		bra	STARTUP2			; Error 0,"" is RESET
	ELSE
		M_ERROR
		FCB	$FF
		FCB	"Host requested reset!"
		FCB	0
	ENDIF

* HOSTFS_ESC,$8n - Escape change
* -----------------------
WaitTransfer
		cmpa	#$C0
		bhs	WaitStart
		cmpa	#$A0
		bhs	WaitEnd
		cmpa	#$90
		bhs	WaitEvent
		lsra
		ror	ZP_ESCFLG
		rts			; Set Error flag from b0

* HOSTFS_ESC,$9x - Event
* ---------------
WaitEvent
		bsr	WaitByte
		m_tay					; Fetch event Y parameter
		lbsr	WaitByte
		m_tax					; Fetch event X parameter
		lbsr	WaitByte			; Fetch event A parameter
		jmp	[EVNTV]				; Dispatch to event vector

* HOSTFS_ESC,$Ax - Reserved
* ------------------
WaitEnd
		cmpa	#$B0
		blo	WaitExit			; Return to WaitByte

* HOSTFS_ESC,$Bx - End transfer
* ----------------------
;;		pla
;;		pla
;;		pla
;;		pla
;;		pla
;;		pla					; Pop bsr WaitCommand, A,Y,X,A
;;		pla
;;		pla					; Pop bsr Wait/ReadByte in Load/SaveLoop
		leas	11,S				; TODO CHECK CC,D,X,Y,JSR in to WaitCommand + JSR into WaitByte
WaitExitSave
		lda	,S+
		bpl	WaitExitRelease			; Pop transfer flag, b0=0 - Tube release (from WaitLoadIO????)
		rora
		bcs	WaitExitScreen			; b0=1, Screen release
WaitExit
		rts
WaitExitRelease
	IF SWROM
		lbsr	TubeRelChk			; Release if Tube present
	ENDIF
WaitExitScreen
	IF SWROM
		ldy	#0
		bra	vramSelect			; Page in main memory, return to WaitByte
	ELSE
		rts
	ENDIF

* HOSTFS_ESC,$C0+ - Start transfer
* -------------------------
WaitStart
		pshs	A
		ldb	#4				; Save command, point to ZP_ADDR_TRANS
		ldy	#ZP_ADDR_TRANS
WaitStartLp
		lbsr	WaitByte
		sta	,Y+				; Wait for 4-byte data address (reverse order!)
		decb
		bne	WaitStartLp
		puls	A
		cmpa	#$D0
		blo	WaitExit			; HOSTFS_ESC,$Cx - set address for later entry
		cmpa	#$E0
		blo	CallCode			; HOSTFS_ESC,$Dx - enter code immediately

* Decide what local memory to transfer data to/from
* -------------------------------------------------
* A=$Ex/$Fx - Load/Save
*
	IF SWROM
		tst	sysvar_TUBE_PRESENT
		bpl	WaitTransIO			; No Tube
		ldb	ZP_ADDR_TRANS+0			; Check transfer address
		incb
		bne	WaitTransTube			; Tube present, ADDR<$FFxxxxxx
	ENDIF
WaitTransIO
		anda	#$F0				; A=transfer flag with b7=1 for IO transfer
;; 	IF SWROM
;; 	; TODO - confer with JGH, this is too wasteful of address space...
;; 		pshs	A
;; 		ldx	ZP_ADDR_TRANS+1
;; 		inx
;; 		beq	WaitIOGo			; $FFFFxxxx - current IO memory
;; 		lda	$D0
;; 		inx
;; 		beq	WaitIOScreen			; $FFFExxxx - current display memory
;; 		inx
;; 		bne	WaitIOGo
;; 		lda	#16				; $FFFDxxxx - shadow screen memory
;; WaitIOScreen
;; 		and	#16
;; 		beq	WaitIOGo			; Non-shadow screen displayed, jump with Y=$E0/$F0
;; 		iny
;; 		bsr	vramSelect			; Page in video RAM, Y is now $E1/$F1
;; WaitIOGo
;; 		tya
;; 	ENDIF
		pshs	A
		ldy	ZP_ADDR_TRANS+2			; Stack IO/Screen flag, init Y=transfer address (16 bit)
		cmpa	#$F0
		bhs	WaitSaveIO			; HOSTFS_ESC,$Fx - save data

* Load data from remote host
* --------------------------
WaitLoadIO
		lbsr	WaitByte			; this will terminate itself?
		sta	,Y+				; HOSTFS_ESC,$Ex - load data
		bra	WaitLoadIO			; Loop until terminated by HOSTFS_ESC,$Bx

* Save data to remote host
* ------------------------
WaitSaveIO
		lda	,Y+
		lbsr	SendByte			; HOSTFS_ESC,$Fx - save data
		lbsr	ReadByte
		bcs	WaitSaveExit			; Poll input for termination
		bra	WaitSaveIO			; Loop until terminated by HOSTFS_ESC,$Bx
WaitSaveExit
		bra	WaitExitSave

* Tube and ADDR<$FFxxxxxx	TODO: this needs timing sorting for >2Mhz etc
* -----------------------
* A=$Ex/$Fx - Load/Save
	IF SWROM
WaitTransTube
		CLC
		adca	#$10
		rola					; Cy=1/0 for load/save
		lda	#0
		rola
		pshs	A				; A=1/0 for load/save
		bsr	TubeAction			; Claim Tube and start transfer
		lda	,S
		beq	WaitSaveTube			; Leave flag pushed with b7=0 for Tube transfer
WaitLoadTube
		lbsr	TubeDelay			; note MUST be an _L_ong BSR for timing
		lbsr	WaitByte
		sta	sheila_TUBE_R3_DATA		; Fetch byte and send to Tube
		bra	WaitLoadTube			; Loop until terminated by HOSTFS_ESC,$Bx
WaitSaveTube
		lda	sheila_TUBE_R3_DATA
		lbsr	SendByte			; Fetch byte from Tube and send it
		lbsr	ReadByte
		bcs	WaitSaveExit			; Poll input for termination
		lbsr	TubeDelay			; note MUST be an _L_ong BSR for timing
		bra	WaitSaveTube			; Loop until terminated by HOSTFS_ESC,$Bx
	ENDIF

* Enter code
* ----------
CallCode
		lda	#$00
		SEC
		jmp	[ZP_ADDR_TRANS]			; Enter code with A=0, SEC


* Screen selection routines
* =========================
	; TODO: reinstate this and test on Master
	; API change B=0 main RAM, B=1 video RAM (was Y)
	IF SWROM
vramSelect
;;		pshs	B
;;		andb	#1
;;		pshs	B
;;		m_tbx					; X=0 main RAM, X=1 video RAM
;;		lda	#OSBYTE_108_WRITE_SHADOW_STATE
;;		jsr	OSBYTE				; Attempt to select Master video RAM
;;		puls	A
;;		m_txb
;;		incb
;;		bne	vramOk				; X<>255, successful
;;		eora	#1
;;		m_tax					; A=1 main RAM, A=0 video RAM
;;		lda	#111
;;		jsr	OSBYTE			; Attempt to select Aries/Watford RAM
;;.vramOk
;;		puls	B,PC
		rts					; Do nowt on 6809, might need to for a real Master + 6809
	ENDIF

* Tube communication routines
* ===========================
	IF SWROM
		;TODO - this will need addressing for Beeb6809 or Chipkit 2 when / if it runs at 4MHz
			; LBSR to enter 	; 9
TubeDelay						; Delay for 24us
		lbsr	TubeDelay2		; 9 + 7
		lbsr	TubeDelay2		; 9 + 7
TubeDelay2
		nop				; 2
		rts				; 5
						;== 48
TubeEnterCode
		lda	#4				; 4=EnterCode
TubeAction
		pshs	A
TubeClaim
		lda	#$C0+6
		jsr	$406				; Claim with ID=6 (HostFS)
		bcc	TubeClaim
		;TODO TUBE - this assumes X will be the address!
		ldx	#ZP_ADDR_TRANS			; Point to transfer address
		puls	A
		jmp	$406				; Start transfer action
TubeRelChk
		tst	sysvar_TUBE_PRESENT
		bmi	1F				; TODO - check should this jump to TubeRelease?
		rts					; If no Tube, return
TubeRelease
		lda	#$80+6
1		jmp	$406				; Release with ID=6 (HostFS)
	ENDIF

* Enter Code pointed to by ZP_ADDR_TRANS transfer address
* ===============================================
* Checks to see if code has a ROM header, and verifies it
* if it has. CC=entered from RESET, CS=entered from OSCLI
EnterCode
	IF SWROM
		tst	sysvar_TUBE_PRESENT
		bpl	EnterCodeIO			; No Tube present
		ldb	ZP_ADDR_TRANS+0
		incb
		bne	TubeEnterCode			; ADDR<$FFxxxxxx
	ENDIF
EnterCodeIO
		;TODO : Is this all necessary, check other FS's
		;TODO : other address handling
		pshs	CC
		ldy	#ZP_ADDR_TRANS+2
		ldb	7,Y				; Get copyright offset
		clra
		addd	ZP_ADDR_TRANS+2			; add low 16 bits of transfer address
		tfr	D,Y				; now should point at start of (C) if a "rom"
*
* Now check for $00,"(C)"
		leax	CheckCopy+3,PCR
		ldb	#3				; check 4 chars
EnterCheck
		lda	,Y+
		cmpa	,-X
		bne	LF8FA
		decb
		bpl	EnterCheck			; Check for $00,"(C)"
*
* $00,"(C)" exists, check ROM type byte
* -------------------------------------
		ldy	ZP_ADDR_TRANS+2
		lda	6,Y				; Get ROM type
		anda	#$4F
		cmpa	#$40
		blo	NotLanguage			; b6=0, not a language
		anda	#$0F
		beq	LF8FA
		cmpa	#$03				; TODO RomType decide on better number/check for JSR/BSR???
		bne	Not6x09Code			; type<>0 and <>3, not 6x09 code
LF8FA		rolb
		rolb
		andb	#1				; B=0 - raw, B=1 - header (from count in (C) check)
		ldx	ZP_ADDR_TRANS+2			; get low 16 bit address to enter
		tst	ZP_ADDR_TRANS+2
		bpl	LF904				; Entered code<$8000, don't move ZP_ADDR_MEMTOP
		stx	ZP_ADDR_MEMTOP			; Set ZP_ADDR_MEMTOP to current program
		stx	ZP_ADDR_PROG			; Set current program to address entered
LF904		puls	CC
		jmp	[ZP_ADDR_TRANS+2]		; Enter code with A=raw/code, Cy=RESET/OSCLI flag
CheckCopy
		FCB	")C("
		FCB	0
;*
;* Any existing Error handler will probably have been overwritten
;* So, set up new Error handler before generating an Error
NotLanguage
	IF NOT SWROM
		bsr	InitError
	ENDIF
		M_ERROR
		FCB	249
		FCB	"This is not a language"
		FCB	0

Not6x09Code
	IF NOT SWROM
		bsr InitError
	ENDIF
		M_ERROR
		FCB	249
		FCB	"This is not 6x09 code"
		FCB	0


* Low level I/O routines
* ======================
* This is where detailed playful frobbing is done to ensure a clean
* Error-free reliable link channel. All calling code assumes these
* routines are 100% Error-free and reliable. Any handshaking, retries,
* Error correction, etc must be done at this level.

* Send a raw byte of data
* -----------------------
* On entry, A=byte to send
* On exit,  A,X,Y preserved, P corrupted
*
	IF MACH_CHIPKIT
SendData
		sta	,-S

SendWait
		lda	S16550_LSR
		anda	#LSR_BIT_TXRDY		; check for empty FIFO - TODO - should be not full?!?!
		beq	SendWait

		lda	,S+
		sta	S16550_TXR
		rts


	ELSIF MYELIN
SendData
		pshs	A
SendWait
		lda	fred_MYELIN_SERIAL_STATUS	; Get Status
		anda	#MYELIN_SERIAL_TXRDY
		beq	SendWait			; Wait until data can be sent
		puls	A
		sta	fred_MYELIN_SERIAL_DATA
		rts			; Send data
	ELSE
SendData
		pshs	A
SendWait
		lda	sheila_ACIA_CTL			; Get Status
		anda	#ACIA_BITS_TxRDY
		beq	SendWait			; Wait until data can be sent
		puls	A
		sta	sheila_ACIA_DATA
		rts			; Send data
	ENDIF

* Read raw data
* -------------
* On exit, P =CC, no data
*            =CS, data present, EQ=HOSTFS_ESC, NE=not HOSTFS_ESC
*
	IF MACH_CHIPKIT
ReadData
		lda	#LSR_BIT_RXRDY
		bita	S16550_LSR
		bne	ReadDataOk			; Data present already even though we blocked
		; 
		ldb	#MCR_CONT
		stb	S16550_MCR

		; now try a few times, allow time for byte to come through
		bita	S16550_LSR
		bne	ReadDataOk			; Data present
		bita	S16550_LSR
		bne	ReadDataOk			; Data present
		bita	S16550_LSR
		bne	ReadDataOk			; Data present
		bita	S16550_LSR
		bne	ReadDataOk			; Data present
		bita	S16550_LSR
		bne	ReadDataOk			; Data present
		bita	S16550_LSR
		bne	ReadDataOk			; Data present
		bita	S16550_LSR
		bne	ReadDataOk			; Data present
		bita	S16550_LSR
		bne	ReadDataOk			; Data present
		bita	S16550_LSR
		bne	ReadDataOk			; Data present

		ldb	#MCR_WAIT
		stb	S16550_MCR

		;
		CLC
		rts					; CC=No data present
ReadDataOk
		lda	S16550_RXR
		ldb	#MCR_WAIT
		stb	S16550_MCR

		cmpa	#HOSTFS_ESC
		SEC
		rts					; CS=Data present, EQ/NE=HOSTFS_ESC

	ELSIF MYELIN
ReadData
		lda	fred_MYELIN_SERIAL_STATUS	
		anda	#MYELIN_SERIAL_RXRDY
		bne	ReadDataOk			; Data present
		CLC
		rts					; CC=No data present
ReadDataOk
		lda	fred_MYELIN_SERIAL_DATA

		cmpa	#HOSTFS_ESC
		SEC
		rts					; CS=Data present, EQ/NE=HOSTFS_ESC
	ELSE
ReadData
		pshs	CC,B
		SEI					; Speed up by disabling IRQs
		; DB: check one hasn't already sneaked in before we open RTS
		lda	sheila_ACIA_CTL			; Get sheila_ACIA_CTL
		anda	#ACIA_BITS_RxRDY
		bne	ReadDataOk2			; Data present		
		ldb	#ACIA_CTL_RxCont
		stb	sheila_ACIA_CTL			; Lower RTS to allow input
		; DB: this was not resetting RTS for long enough on my machine so give it a few goes!
		ldb	#ACIA_CTL_RxStop

		lda	sheila_ACIA_CTL			; Get sheila_ACIA_CTL
		anda	#ACIA_BITS_RxRDY
		bne	ReadDataOk			; Data present
		lda	sheila_ACIA_CTL			; Get sheila_ACIA_CTL
		anda	#ACIA_BITS_RxRDY
		bne	ReadDataOk			; Data present
		lda	sheila_ACIA_CTL			; Get sheila_ACIA_CTL
		anda	#ACIA_BITS_RxRDY
		bne	ReadDataOk			; Data present


		stb	sheila_ACIA_CTL
		puls	B,CC
		CLC
		rts					; CC=No data present
ReadDataOk
		stb	sheila_ACIA_CTL
ReadDataOk2
		lda	sheila_ACIA_DATA
		puls	B,CC
		cmpa	#HOSTFS_ESC
		SEC
		rts					; CS=Data present, EQ/NE=HOSTFS_ESC
	ENDIF
;
;
;	]
;		if(P%>IOSPACE%)AND(SWROM%=0)
;		Error	1,"Code overrun"
;	[OPT P*3+4
;* Spare space
;* ===========
;		opt	FNif(SWROM%=0)
;		equs	STRING$((IOSPACE%-P%)AND255,CHR$255)
;		opt	FNendif
;
;* I/O Space
;* =========
;		equs	STRING$(8,CHR$0)
;
;* Tube I/O Registers
;* ==================
;TubeS1			; $FEF8
;		equb	0
;TubeR1			; $FEF9
;		equb	0
;TubeS2			; $FEFA
;		equb	0
;TubeR2			; $FEFB
;		equb	0
;TubeS3			; $FEFC
;		equb	0
;TubeR3			; $FEFD
;		equb	0
;TubeS4			; $FEFE
;		equb	0
;TubeR4			; $FEFF
;		equb	0
;
;
;* DEFAULT VECTOR TABLE
;* ====================
;LFF00
;		equw	NullReturn			; $200 - USERV
;		equw	ErrorHandler			; $202 - BRKV
;		equw	IRQ1Handler			; $204 - IRQ1V
;		equw	IRQ2Handler			; $206 - IRQ2V
;		equw	MyosCLI				; $208 - CLIV
;		equw	MyosBYTE			; $20A - BYTEV
;		equw	MyosWORD			; $20C - WORDV
;		equw	MyosWRCH			; $20E - WRCHV
;		equw	MyosRDCH			; $210 - RDCHV
;		equw	MyosFILE			; $212 - FILEV
;		equw	MyosARGS			; $214 - ARGSV
;		equw	MyosBGET			; $216 - BGetV
;		equw	MyosBPUT			; $218 - BPutV
;		equw	MyosGBPB			; $21A - GBPBV
;		equw	MyosFIND			; $21C - FINDV
;		equw	NullReturn			; $21E - FSCV
;		equw	NullReturn			; $220 - EVNTV
;		equw	NullReturn			; $222 - UPTV
;		equw	NullReturn			; $224 - NETV
;		equw	NullReturn			; $226 - VduV
;		equw	NullReturn			; $228 - KEYV
;		equw	NullReturn			; $22A - INSV
;		equw	NullReturn			; $22C - RemV
;		equw	NullReturn			; $22E - CNPV
;		equw	NullReturn			; $230 - IND1V
;		equw	NullReturn			; $232 - IND2V
;		equw	NullReturn			; $234 - IND3V
;
;* Print hex numbers
;* =================
;PrHexXY
;		tya
;		bsr	PrHex
;		txa
;PrHex
;		pha
;		lsr	A
;		lsr	A
;		lsr	A
;		lsr	A
;		bsr	PrNybble
;		pla
;PrNybble
;		and	#15
;		cmp	#10
;		bcc	PrDigit
;		adc	#6
;PrDigit
;		adc	#'0'
;		bra	ummOSWRCH
;
;* Print embedded string
;* =====================
;* Mustn't use ZP_ADDR_LPTR so can be called from OSCLI
;PrText
;		pla
;		sta	TEXT+0
;		pla
;		sta	TEXT+1			; ZP_ADDR_CTRLPTR=>embedded string
;		bsr	PrString2
;		bra	(TEXT)			; Print string and jump back to code
;
;PrString
;		stx	TEXT+0
;		sty	TEXT+1			; ZP_ADDR_CTRLPTR=>string at YX
;PrStringLp
;		ldy	#$00
;		lda	(TEXT),Y			; Get character
;		beq	PrString2
;		jsr	ummOSASCI			; Print character if not $00
;PrString2
;		inc	TEXT+0
;		bne	LFEA6
;		inc	TEXT+1			; Increment address
;LFEA6
;		tya
;		bne	PrStringLp			; Loop back if not $00
;NullReturn
;		rts
;
;
;* Standard Tube entry points
;* ==========================
;* NB! All API entry points must be called in BINARY mode
;*
;		opt	FNif(SWROM%=0)
;		equs	STRING$(($FF95-P%)AND255,CHR$255)
;		opt	FNendif
;LFF95
;		bra	NullReturn			; $FF95
;LFF98
;		bra	NullReturn			; $FF98
;PRSTRNG
;		bra	PrString			; $FFC5  Print zero-terminated text at YX, returns A=0, Y corrupted
;LFF9E
;		bra	NullReturn			; $FF9E
;SCANHEX
;		bra	ScanHex			; $FFA1  Scan hex string at ($F8), returned in $F0/1
;DISKACC
;		bra	NullReturn			; $FFA4
;OSQUIT
;		bra	ummCLICOM			; $FFA7  Quit current program
;PRHEX
;		bra	PrHex			; $FFAA  Print A in hex, A corrupted
;PR2HEX
;		bra	PrHexXY			; $FFAD  Print YX in hex, A corrupted
;USERINT
;		bra	NullReturn			; $FFB0
;PRTEXT
;		bra	PrText			; $FFB3  Print zero-terminated inline text, returns A=0, Y corrupted
;ummVECDEF
;		equb	$36
;		equw	LFF00			; $FFB6
;ummCLICOM
;		bra	CmdPrompt			; $FFB9  Enter supervisor *command prompt
;ummERRbra
;		bra	NullReturn			; $FFBC
;INITERR
;		bra	InitError			; $FFBF  Initialise MOS Error handler, A corrupted
;DISKRST
;		bra	NullReturn			; $FFC2
;LFFC5
;		bra	NullReturn			; $FFC5
;ummNVRDCH
;		bra	osRDCH			; $FFC8
;ummNVWRCH
;		bra	MyosWRCH			; $FFCB
;
;ummOSFIND
;		bra	(FINDV)			; $FFCE
;ummOSGBPB
;		bra	(GBPBV)			; $FFD1
;ummOSBPUT
;		bra	(BPutV)			; $FFD4
;ummOSBGET
;		bra	(BGetV)			; $FFD7
;ummOSARGS
;		bra	(ARGSV)			; $FFDA
;ummOSFILE
;		bra	(FILEV)			; $FFDD
;
;ummOSRDCH
;		bra	(RDCHV)			; $FFE0
;ummOSASCI
;		cmp	#$0D
;		bne	ummOSWRCH			; $FFE3
;ummOSNEWL
;		lda	#$0A
;		jsr	ummOSWRCH			; $FFE7
;ummOSWRCR
;		lda	#$0D			; $FFEC
;ummOSWRCH
;		bra	(WRCHV)			; $FFEE
;ummOSWORD
;		bra	(WORDV)			; $FFF1
;OSBYTE
;		bra	(BYTEV)			; $FFF4
;ummOSCLI
;		bra	(CLIV)			; $FFF7
;
;ummNMIV
;		equw	NMIHandler			; $FFFA  NMI Vector
;ummRESETV
;		equw	RESET			; $FFFC  RESET Vector
;ummIRQV
;		equw	IRQHandler			; $FFFE  IRQ Vector
;	]
;		endproc
;
;
;
;	]
;		if	(opt%AND3)
;		if	(Serv3Boot AND 255)>$F4
;		p."WARNING
;		serv3Boot overlaps"
;		endproc