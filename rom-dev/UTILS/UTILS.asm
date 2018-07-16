;----- TODO 
;	V option on ROMS
;	make relocatable
;	make commands that can destroy this rom run from a copy in main RAM then reboot i.e. NUKE,ERASE,COPY,LOAD etc

; Notes for RobC to possibly include in VideoNULA rom
; - osbyte 135 - 
; * rather than setting the background mask to 0 when trying original 135 try
;   setting to zp_vdu_txtcolourOR (i.e. ?&D2) this will then match on any text 
;   in the current colour (D2 contains current attributes)
; * try all combinations of attrs in turn instead of using own routine - 
;   this is slightly slower (for other colours) but has the advantage of using
;   the original 135 routine that correctly uses the MOS table to locate the
;   font - and so works for VDU 23'd chars


; JGH
; - mdump, doesn't handle ACCON yet
; - mdump, doesn't get bytes past length (useful where dumping hardware regs, reads past len cause problems)


		include "../../includes/oslib.inc"
		include "../../includes/hardware.inc"
		include "../../includes/common.inc"
		include "../../includes/mosrom.inc"

		include "VERSION-date.gen.asm"

ADDR_ERRBUF	EQU	$100				; base of stack!

PG_EEPROM_BASE	EQU	$1000				; base phys/jim address of EEPROM is $10 0000

		SETDP 0
zp_trans_tmp	EQU	$A8				; transient command buffer
zp_trans_acc	EQU	$AC				; 4 byte accumulator used in hex parsers

zp_SRCOPY_src	EQU	zp_trans_tmp + 1
zp_SRCOPY_dest	EQU	zp_trans_tmp + 0
zp_SRCOPY_flags	EQU	zp_trans_tmp + 2		; when negative dest if a flash

zp_ROMS_ctr	EQU	zp_trans_tmp + 0
zp_ROMS_copyptr	EQU	zp_trans_tmp + 1
zp_ROMS_flags	EQU	zp_trans_tmp + 3
zp_ROMS_ostbl	EQU	zp_trans_acc + 2

zp_ERASE_dest	EQU	zp_trans_tmp + 0
zp_ERASE_flags	EQU	zp_trans_tmp + 1

zp_SRLOAD_dest	EQU	zp_trans_tmp + 0
zp_SRLOAD_flags	EQU	zp_trans_tmp + 1

zp_mdump_addr	EQU	zp_trans_tmp + 0
zp_mdump_len	EQU	zp_trans_tmp + 4		; not overlaps acc

VERSION_NAME	MACRO
		FCB	"UTILS09"
		ENDM

		;TODO : move these to autogen'd files? Agree version # with JGH
VERSION_BYTE	MACRO
		FCB	1
		ENDM


VERSION_STRING	MACRO
		FCB	"0.01"
		ENDM


M_ERROR		MACRO
		jsr	BounceErrorOffStack
		ENDM

TODO		MACRO
		M_ERROR
		FCB	$FF
		FCB	\1
		FCB	0
		ENDM


		ORG	$8000

		FCB	0,0,0				; language entry
		jmp	Service				; service entry
		FCB	$83				; not a language, 6809 code
		FCB	Copyright-$8000
		VERSION_BYTE	
utils_name
		VERSION_NAME
		FCB	0
		VERSION_STRING
		FCB	" ("
		VERSION_DATE
		FCB	")"
Copyright
		FCB	0
	IF MACH_CHIPKIT
		FCB	"(C)2018 Dossytronics"
	ELSE
		FCB	"(C)2018 Dossytronics+Rob Coleman"
	ENDIF
		FCB	0

SJTE		MACRO
		FCB	\1
		FDB	\2
		ENDM

;* ---------------- 
;* SERVICE ROUTINES
;* ----------------
	;TODO make this relative!
Serv_jump_table
		SJTE	$01, svc1_ClaimAbs
		SJTE	$04, svc4_COMMAND
		SJTE	$09, svc9_HELP
		FCB	0

Service
		leay	Serv_jump_table,PCR
1		tst	,Y
		beq	ServiceOut
		cmpa	,Y+
		bne	2F
		jmp	[,Y]
2		leay	2,Y
		bra	1B
ServiceOut	rts



* -------------------------------
* SERVICE 1 - Claim Abs Workspace
* -------------------------------

svc1_ClaimAbs
		pshs	D,X,Y,U

		lda	#$79
		ldy	#0
		ldx	#$A8
		jsr	OSBYTE				; check if _/£ key down
		tfr	X,D
		tstb
		bpl	svc1_nonuke

		jsr	cmdSRNUKE_lang
		lbra	cmdSRNUKE_reboot

svc1_nonuke	
	IF MACH_BEEB
		jsr 	vnula_reset			; TODO on "master" do different for shadowed fonts?
	ENDIF

		puls	D,X,Y,U,PC

* -----------------
* SERVICE 9 - *Help
* -----------------
svc9_HELP
		pshs	D,X,Y

		jsr	SkipSpacesX
		cmpa	#$D
		beq	svc9_HELP_nokey

svc9_keyloop
		; keywords were included scan for our key
		ldy	#str_HELP_KEY
1		lda	,X+
		jsr	ToUpper				; to upper
		cmpa	,Y+
		beq	1B				
2		cmpa	#' '
		bls	1F				; at end of keywords (on command line)
3		lda	,X+				; not at end skip forwards
		cmpa	#' '
		bhi	3B
2		leax	-1,X
		jsr	SkipSpacesX
		cmpa	#$D
		beq	svc9_HELP_exit
1		tst	-1,Y		
		beq	svc9_helptable			; at end of keyword show table
		jsr	SkipSpacesX			; try another
		cmpa	#$D
		beq	svc9_HELP_exit
		bra	svc9_keyloop

svc9_helptable	; got a match, dump out our commands help
		ldy	#tbl_commands		
1		ldx	,Y
		beq	svc9_HELP_exit
		jsr	PrintSpc
		jsr	PrintSpc
		jsr	PrintX
		jsr	PrintSpc
		ldx	4,Y
		beq	2F
		jsr	PrintX
2		jsr	PrintNL
		leay	6,Y
		bra	1B


svc9_HELP_nokey
		jsr	PrintNL
		ldx	#utils_name
		ldb	#3
1		jsr	PrintX
		lda	#' '
		jsr	PrintA
		decb
		bne	1B
		jsr	PrintNL
		lda	#' '
		jsr	PrintA
		jsr	PrintA
		ldx	#str_HELP_KEY
		jsr	PrintX
		jsr	PrintNL
svc9_HELP_exit	puls	D,X,Y,PC


svc4_COMMAND	; scan command table for commands
		pshs	D,X,Y,U
		ldu	#tbl_commands
cmd_loop	ldx	2,S				; reload X
		jsr	SkipSpacesX
		ldy	0,U				; point to rom name
		beq	svc4_CMD_exit			; no more commands
1		lda	,X+
		jsr	ToUpper
		cmpa	,Y+
		beq	1B
		tst	-1,Y
		beq	1F
2		leau	6,U				; try next table entry
		bra	cmd_loop
1		cmpa	#' '
		bhi	2B				;
		leax	-1,X

svc4_CMD_exec	jsr	[2,U]				; execute command
		clr	,S				; zero accumulator
		puls	D,X,Y,U,PC		

svc4_CMD_exit	puls	D,X,Y,U,PC

;------------------------------------------------------------------------------
; Commands
;------------------------------------------------------------------------------


cmdSRLOAD	jsr	SkipSpacesX
		cmpa	#$D
		lbeq	brkBadCommand			; no filename!
		stx	ADDR_ERRBUF			; store pointer to filename
1		lda	,X+
		cmpa	#' '
		lblt	brkBadId			; < ' ' means end of command no id!
		bne	1B
		lda	#$D
		sta	-1,X				; overwrite ' ' with $D to terminate filename
		jsr	SkipSpacesX

		jsr	ParseHex
		lbcs	brkBadId
		jsr	CheckId
		sta	zp_SRLOAD_dest			; dest id

		; TODO: check for Q etc for now just assume all is well

		; setup OSFILE block to point at $FFFF4000 and load there
		clr	ADDR_ERRBUF + 6			; clear exec address low byte (use my address)
		lda	#$40
		sta	ADDR_ERRBUF + 4
		clr	ADDR_ERRBUF + 5
		lda	#$FF
		sta	ADDR_ERRBUF + 2
		sta	ADDR_ERRBUF + 3
		ldx	#ADDR_ERRBUF
		jsr	OSFILE				; load file

		; now copy to flash/sram
		jsr	romWriteInit			; initialise the ROM writer - any error will trash this!

		clra
		ldb	zp_SRLOAD_dest
		tfr	D,Y				; rom #

		clr	zp_SRLOAD_flags
		; check to see if dest is ROM (4-7)
		lda	zp_SRLOAD_dest
		jsr	IsFlashBank
		bne	cmdSRLOAD_init_RAM		; ram in odd banks
		dec	zp_SRLOAD_flags

		jsr	FlashReset			; in case we're in software ID mode
		jsr	FlashEraseROM
		bra	cmdSRLOAD_go

cmdSRLOAD_init_RAM

cmdSRLOAD_go
		ldx	#$8000
		ldu	#$4000
cmdSRLOAD_go_lp
		lda	,U+
		pshs	A				; save A for later
		tst	zp_SRLOAD_flags
		bpl	1F				; not EEPROM, just write to ROM
		; flash write byte command
		lda	#$A0
		jsr	FlashCmdA			; Flash write byte command
		lda	,S
1		jsr	romWrite
		tst	zp_SRLOAD_flags
		bpl	1F
		jsr	FlashWaitToggle
1		jsr	OSRDRM
		cmpa	,S+
		lbne	cmdSRCOPY_verfail

		leax	1,X
		cmpx	#$C000
		bne	cmdSRLOAD_go_lp
		ldx	#str_OK
		jmp	PrintX
		lbra	cmdSRCOPY_verfail


CMDROMS_FLAGS_CRC	EQU	$20
CMDROMS_FLAGS_VERBOSE	EQU	$80
CMDROMS_FLAGS_ALL	EQU	$40


cmdRoms		clrb
cmdRomsNextArg
		jsr	SkipSpacesX
		leax	1,X
		jsr	ToUpper
		cmpa	#13
		beq	cmdRoms_Go
		cmpa	#'C'
		bne	1F
		orb	#$20
		bra	cmdRomsNextArg
1		cmpa	#'V'
		bne	1F
		orb	#$80
		bra	cmdRomsNextArg
1		cmpa	#'A'
		bne	1F
		orb	#$40
		bra	cmdRomsNextArg
1		lbra	brkInvalidArgument


cmdRoms_Go
		stb	zp_ROMS_flags

		lda	#OSBYTE_171_ROMTAB
		ldx	#0
		ldy	#$FF
		jsr	OSBYTE
		stx	zp_ROMS_ostbl

		
		ldx	#strRomsHeadVer			; vecbose headings		
1		jsr	PrintX

		clr	zp_ROMS_ctr
cmdRoms_lp	jsr	Print2Spc
		lda	zp_ROMS_ctr
		jsr	PrintHexNybA			; rom #
		jsr	Print2Spc

		clra
		ldb	zp_ROMS_ctr
		tfr	D,Y				; Y now contains ROM# for OSRDRM


		ldb	zp_ROMS_ctr
		ldu	zp_ROMS_ostbl
		lda	B,U


		pshs	A

		; print "active" rom type from OS table
		jsr	PrintHexA
		jsr	PrintSpc

		puls	A

		tst	zp_ROMS_flags
		bmi	cmdRoms_fullcheck		

		tsta					; trust the OS table
		lbeq	cmdRoms_sk_notrom
		bra	cmdRoms_checkedOStab


cmdRoms_DoCRC
		lda	#CMDROMS_FLAGS_CRC
		bita	zp_ROMS_flags		
		beq	cmdRoms_skipCRC
		ldx	#$8000
		decb
		clr	zp_trans_acc
		clr	zp_trans_acc + 1
1		jsr	OSRDRM
		jsr	crc16
		decb
		bne	2F
		jsr	CheckESC
2		leax	1,X
		cmpx	#$C000
		bne	1B
		ldx	zp_trans_acc
		jsr	PrintHexX
		jmp	Print2Spc

CheckESC	tst	zp_mos_ESC_flag			; TODO - system call for this?
		bpl	1F
ackEscape
		ldx	#$FF
		lda	#OSBYTE_126_ESCAPE_ACK
		jsr	OSBYTE
brkEscape	M_ERROR
		FCB	17, "Escape",0

1		rts

cmdRoms_skipCRC
		jsr	Print2Spc
		jsr	Print2Spc
		jmp	Print2Spc


cmdRoms_fullcheck


		; check for (C) symbol, if not present skip this rom
		ldx	#$8007
		jsr	OSRDRM
		tfr	A,B
		ldx	#$8000
		abx					; X now points at (C) of copyright
		ldb	#4
		ldu	#str_C

1		jsr	OSRDRM
		cmpa	,U+
		bne	cmdRoms_sk_notrom
		leax	1,X
		decb
		bne	1B

cmdRoms_checkedOStab

		jsr	cmdRoms_DoCRC

		; tis a ROM, print type
		ldx	#$8006
		jsr	OSRDRM


		jsr	PrintHexA
		jsr	Print2Spc

		; check for (C) symbol, if not present skip this rom
		ldx	#$8007
		jsr	OSRDRM
		tfr	A,B
		ldx	#$8000
		abx					; X now points at (C) of copyright
		stx	zp_ROMS_copyptr			; copyright pointer (used in title print later)



		; print version
		ldx	#$8008
		jsr	OSRDRM
		jsr	PrintHexA
		jsr	PrintSpc

		; print title

		ldx	#$8009
1		jsr	cmdRoms_PrintX			; print title and optional version str
		jsr	PrintSpc
		cmpx	zp_ROMS_copyptr
		blo	1B

cmdRoms_NoVer	jsr	cmdRoms_PrintX			; print copyright string
		bra	cmdRoms_sk_nextrom


cmdRoms_sk_notrom
		lda	#CMDROMS_FLAGS_ALL
		bita	zp_ROMS_flags
		beq	1F				; not VA
		jsr	cmdRoms_DoCRC
1		ldx	#strNoRom
		jsr	PrintX

cmdRoms_sk_nextrom
		jsr	PrintNL
		inc	zp_ROMS_ctr
		lda	#16
		cmpa	zp_ROMS_ctr
		lbhi	cmdRoms_lp

		rts

cmdRoms_PrintX
1		jsr	OSRDRM
		leax	1,X
		tsta
		beq	2F
		cmpa	#' '
		blo	1B				; skip CR/LF in BASIC (C)
		jsr	PrintA
		bra	1B
2		rts

brkBadCommand	M_ERROR
		FCB	$FE, "Bad Command", 0


cmdSRERASE
		jsr	romWriteInit			; initialise the ROM writer - any error will trash this!

		jsr	ParseHex
		lbcs	brkBadId
		jsr	CheckId
		sta	zp_ERASE_dest			; dest id
		jsr	SkipSpacesX
		clr	zp_ERASE_flags
		cmpa	#'F'
		bne	1F
		dec	zp_ERASE_flags
1		; check for EEPROM
		ldb	zp_ERASE_dest
		clra
		tfr	D,Y
		lda	zp_ERASE_dest
		jsr	IsFlashBank
		bne	cmdSRERASE_RAM

		ldx	#strSRERASEFLASH
		lda	zp_ERASE_dest
		jsr	PrintMsgThenHexNyb

		jmp	FlashEraseROM

cmdSRERASE_RAM	

		ldx	#strSRERASERAM
		lda	zp_ERASE_dest
		jsr	PrintMsgThenHexNyb

		ldx	#$8000
		ldu	#0				; fail counter
1		lda	#$FF
		jsr	romWrite
		jsr	OSRDRM
		cmpa	#$FF
		bne	2F
3		leax	1,X
		cmpx	#$C000
		bne	1B
		leau	0,U
		bne	4F
		ldx	#str_OK
		jsr	PrintX
		rts
4		leax	,U				; got to end with errors
		lda	#'&'
		jsr	PrintA
		jsr	PrintHexX
		ldx	#strErrsDet
		jmp	PrintX
2		leau	1,U
		tst	zp_ERASE_flags
		bmi	3B				; continue - F switch in force
		pshs	X
		ldx	#str_FailedAt
		jsr	PrintX
		puls	X
		jsr	PrintHexX
		lbra	brkEraseFailed

cmdSRCOPY	
		jsr	romWriteInit			; initialise the ROM writer - any error will trash this!

		jsr	ParseHex
		lbcs	brkBadId
		jsr	CheckId
		sta	zp_SRCOPY_dest			; dest id
		jsr	ParseHex
		lbcs	brkBadId
		jsr	CheckId
		sta	zp_SRCOPY_src			; src id
		jsr	SkipSpacesX
		cmpa	#$D
		lbne	brkBadCommand

		lda	zp_SRCOPY_dest
		cmpa	zp_SRCOPY_src
		lbeq	brkBadCommand			; don't copy to self

		clr	zp_SRCOPY_flags
		; check to see if dest is ROM (4-7)
		jsr	IsFlashBank
		bne	cmdSRCOPY_init_RAM		; ram in odd banks
		dec	zp_SRCOPY_flags

		ldx	#strSRCOPY2FLASH
		lda	zp_SRCOPY_dest
		jsr	PrintMsgThenHexNyb

		clra
		ldb	zp_SRCOPY_dest
		tfr	D,Y				; rom #

		jsr	FlashReset			; in case we're in software ID mode
		jsr	FlashEraseROM
		bra	cmdSRCOPY_go

cmdSRCOPY_init_RAM
		ldx	#strSRCOPY2RAM
		lda	zp_SRCOPY_dest
		jsr	PrintMsgThenHexNyb

cmdSRCOPY_go
		ldx	#str_Copying
		jsr	PrintX
		ldx	#$8000
		ldb	zp_SRCOPY_src
		clra
		std	zp_trans_acc
		ldb	zp_SRCOPY_dest
		clra
		std	zp_trans_acc + 2

cmdSRCOPY_go_lp
		ldy	zp_trans_acc			; src ROM #
		jsr	OSRDRM
		ldy	zp_trans_acc + 2		; dest ROM #
		pshs	A				; save A for later
		tst	zp_SRCOPY_flags
		bpl	1F				; not EEPROM, just write to ROM
		; flash write byte command
		lda	#$A0
		jsr	FlashCmdA			; Flash write byte command
		lda	,S
1		jsr	romWrite
		tst	zp_SRCOPY_flags
		bpl	1F
		jsr	FlashWaitToggle
1		jsr	OSRDRM
		cmpa	,S+
		bne	cmdSRCOPY_verfail

		leax	1,X
		cmpx	#$C000
		bne	cmdSRCOPY_go_lp
		ldx	#str_OK
		jmp	PrintX

cmdSRCOPY_verfail
		jsr	PrintHexX
		jsr	PrintNL
		M_ERROR
		FCB	$81, "Verify fail", 0


CheckId		lda	zp_trans_acc			; check acc > 16
		ora	zp_trans_acc + 1
		ora	zp_trans_acc + 2
		bne	brkBadId
		lda	zp_trans_acc + 3
		cmpa	#$10
		bhs	brkBadId
		rts
brkBadId	M_ERROR
		FCB	$FC, "Bad Id", 0


ZP_NUKE_LBAS	EQU	$0
ZP_NUKE_ERRPTR	EQU	ZP_NUKE_LBAS + 0
ZP_NUKE_S_TOP	EQU	ZP_NUKE_LBAS + 2
ZP_NUKE_ROMSF	EQU	ZP_NUKE_LBAS + 4

STR_NUKE_CMD	EQU	$700
		
		; BRK handler

cmdSRNUKE_lang_brk
		stx	ZP_NUKE_ERRPTR
		lds	ZP_NUKE_S_TOP

		lda	,X+
		jsr	OSNEWL
		jsr	PrintHexA
		jsr	PrintSpc
		jsr	PrintX
		jsr	OSNEWL
		jsr	OSNEWL

		bra	cmdSRNUKE

cmdSRNUKE_menu
		fcb	13, "0) Exit	1) Erase Flash	2) Erase RAM	3) Show CRC	4) Erase #", 13, 0

inkey_clear
		ldx	#0
		ldy	#0
		lda	#OSBYTE_129_INKEY
		jsr	OSBYTE
		bcc	inkey_clear

inkey
		pshs	X,Y,A
		ldx	#255
		ldy	#127
		lda	#OSBYTE_129_INKEY
		jsr	OSBYTE
		tfr	X,D
		puls	X,Y,A,PC



cmdSRNUKE_lang	;Set ourselves up as a language and take over the machine
		;This is not working - at present only captures BRK handler!

		jsr	cmdVNRESET

		CLRA
		JSR	OSINIT					; A=0, Set up default environment
;		STA	ZP_BIGEND
;		STY	ZP_ESCPTR
		LEAU	cmdSRNUKE_lang_brk, PCR
		STU	,X					; Claim BRKV
		STS	ZP_NUKE_S_TOP				; where to reset stack to on error



cmdSRNUKE	; cmdRoms no VA
		ldb	#CMDROMS_FLAGS_VERBOSE+CMDROMS_FLAGS_ALL
		stb	ZP_NUKE_ROMSF

cmdSRNUKE_mainloop
		ldb	ZP_NUKE_ROMSF
		jsr	cmdRoms_Go
		
		; SHOW MENU
		ldx	#cmdSRNUKE_menu
		jsr	PrintX

1		jsr	inkey_clear
		bcs	1B
		cmpb	#'0'
		lbeq	cmdSRNUKE_exit
		cmpb	#'1'
		beq	cmdSRNUKE_flash
		cmpb	#'2'
		lbeq	cmdSRNUKE_ram
		cmpb	#'3'
		beq	cmdSRNUKE_crctoggle
		cmpb	#'4'
		beq	cmdSRNUKE_erase_rom
		bra	cmdSRNUKE_mainloop

cmdSRNUKE_crctoggle
		ldb	ZP_NUKE_ROMSF
		eorb	#CMDROMS_FLAGS_CRC
		bra	cmdSRNUKE_mainloop

cmdSRNUKE_erase_rom
		ldx	#str_WhichRom
		jsr	PrintX
		jsr	inkey_clear
		tfr	B,A
		jsr	OSASCI
		jsr	OSNEWL
		bcs	cmdSRNUKE_mainloop
		ldx	#STR_NUKE_CMD
		stb	0,X
		ldb	#13
		stb	1,X
		jsr	cmdSRERASE
		bra	cmdSRNUKE_mainloop


cmdSRNUKE_flash
		ldx	#str_NukePrAllFl
		jsr	PromptYN
		bne	cmdSRNUKE_mainloop

		ldx	#str_NukeFl
		jsr	PrintX

		; erase entire flash chip
		jsr	FlashReset
		lda	#$80
		jsr	FlashCmdA
		lda	#$10
		jsr	FlashCmdA
		jsr	FlashWaitToggle
		bra	cmdSRNUKE_mainloop

cmdSRNUKE_reboot
		ORCC	#CC_I+CC_F
		jmp	[$F7FE]				; reboot - if we're running from flash we'll crash anyway!


cmdSRNUKE_ram	ldx	#str_NukePrAllRa
		jsr	PromptYN
		bne	cmdSRNUKE_mainloop

		ldx	#str_NukeRa
		jsr	PrintX

		; enable JIM, setup paging regs
		lda	SHEILA_ROMCTL_MOS
		pshs	A
		ora	#ROMCTL_MOS_JIMEN
		sta	SHEILA_ROMCTL_MOS

		lda	#$0E
		sta	FRED_JIM_PAGE_HI
		clra	
		sta	FRED_JIM_PAGE_LO

		; copy ram nuke routine to ADDR_ERRBUF and execute from there
		ldx	#cmdSRNuke_RAM
		ldu	#ADDR_ERRBUF
		ldb	#cmdSRNuke_RAM_end - cmdSRNuke_RAM
1		lda	,X+				; copy the routine to ram buffer as we are likely to get zapped
		sta	,U+
		decb
		bne	1B
		lda	#$FF
		jmp	ADDR_ERRBUF

cmdSRNuke_RAM	
2		ldx	#JIM
1		sta	,X+
		cmpx	#JIM+$100
		bne	1B
		inc	FRED_JIM_PAGE_LO
		bne	2B
		inc	FRED_JIM_PAGE_HI
		ldb	FRED_JIM_PAGE_HI
		cmpb	#$10
		bne	2B
		lbra	cmdSRNUKE_mainloop
cmdSRNuke_RAM_end

cmdSRNUKE_exit	rts

IsFlashBank
		; rom id in A, returns EQ if this is a Flash Bank, do NOT rely 
		; on value returned in A!
		cmpa	#$3
		bls	1F
		cmpa	#$9
		blo	2F				; treat SYStem sockets (4..7) as RAM (they might be?!)
1		anda	#1
2		rts

;------------------------------------------------------------------------------
; Flash utils
;------------------------------------------------------------------------------

FlashReset	pshs	A
		lda	#$F0
		jsr	FlashCmdA
		puls	A,PC

FlashCmdA	pshs	D,X
		; enable JIM
		lda	SHEILA_ROMCTL_MOS
		pshs	A
		ora	#ROMCTL_MOS_JIMEN
		sta	SHEILA_ROMCTL_MOS

		ldx	#PG_EEPROM_BASE+$0055
		stx	FRED_JIM_PAGE_HI
		lda	#$AA
		sta	JIM + $55

		ldx	#PG_EEPROM_BASE+$002A
		stx	FRED_JIM_PAGE_HI
		lda	#$55
		sta	JIM + $AA

		ldx	#PG_EEPROM_BASE+$0055
		stx	FRED_JIM_PAGE_HI
		lda	1,S
		sta	JIM + $55

		puls	A
		sta	SHEILA_ROMCTL_MOS

		puls	D,X,PC		

FlashCmdShort	pshs	D,X
		; enable JIM
		lda	SHEILA_ROMCTL_MOS
		pshs	A
		ora	#ROMCTL_MOS_JIMEN
		sta	SHEILA_ROMCTL_MOS

		ldx	#PG_EEPROM_BASE+$0055
		stx	FRED_JIM_PAGE_HI
		lda	#$AA
		sta	JIM + $55

		ldx	#PG_EEPROM_BASE+$002A
		stx	FRED_JIM_PAGE_HI
		lda	#$55
		sta	JIM + $AA

		puls	A
		sta	SHEILA_ROMCTL_MOS

		puls	D,X,PC		


FlashSectorErase
		pshs	D,U,X,Y

		lda	#$80
		jsr	FlashCmdA
		jsr	FlashCmdShort
		lda	#$30
		jsr	romWrite

		jsr	FlashWaitToggle

		leau	$1000,X
		stu	zp_trans_acc

		; check that sector has been erased
1		jsr	OSRDRM
		cmpa	#$FF
		bne	FlashSectorEraseErr
		leax	1,X
		cmpx	zp_trans_acc
		bne	1B

FlashSectorEraseOK
		CLC
		puls	D,U,X,Y,PC
FlashSectorEraseErr
		pshs	X
		ldx	#str_FailedAt
		jsr	PrintX
		puls	X
		jsr	PrintHexX
		SEC
		puls	D,U,X,Y,PC

FlashWaitToggle	
		pshs	D
		clrb
FlashWaitToggle_lp		
		jsr	OSRDRM
		pshs	A
		jsr	OSRDRM
		cmpa	,S+
		beq	1F
		decb
		bne	FlashWaitToggle_lp
		lda	#'.'
		jsr	OSWRCH
		bra	FlashWaitToggle_lp
1		puls	D,PC

		; erase ROM slot Y (4 banks)
FlashEraseROM
		pshs	D,X,Y,U
		ldb	#4
		ldu	#$8000				; sector erase address
1							; erase the 4 sectors		
		leax	,U
		jsr	FlashSectorErase
		bcs	brkEraseFailed
		leau	$1000,U
		decb	
		bne	1B
		puls	D,X,Y,U,PC

brkEraseFailed  M_ERROR
		FCB	$80, "Erase fail", 0

;------------------------------------------------------------------------------
; Parsing
;------------------------------------------------------------------------------
SkipSpacesX	lda	,X+
		cmpa	#' '
		beq	SkipSpacesX
		leax	-1,X
		rts

ToUpper		cmpa	#'a'
		blo	1F
		cmpa	#'z'
		bhi	1F
		anda	#$DF
1		rts

ParseHex	clrb
		decb					; indicates first char
		jsr	zeroAcc
		jsr	SkipSpacesX
		cmpa	#$D
		beq	ParseHexErr
ParseHexLp	lda	,X+
		jsr	ToUpper
		incb	
		beq	1F
		cmpa	#'+'
		beq	ParseHexDone	
1		cmpa	#' '
		bls	ParseHexDone
		cmpa	#'0'
		blo	ParseHexErr
		cmpa	#'9'
		bhi	ParseHexAlpha
		suba	#'0'
ParseHexShAd	jsr	asl4Acc				; multiply existing number by 16
		jsr	addAAcc				; add current digit
		bra	ParseHexLp
ParseHexAlpha	cmpa	#'A'
		blo	ParseHexErr
		cmpa	#'F'
		bhi	ParseHexErr
		suba	#'A'-10
		bra	ParseHexShAd
ParseHexErr	SEC
		rts
ParseHexDone	leax	-1,X
		CLC
		rts

;------------------------------------------------------------------------------
; Arith
;------------------------------------------------------------------------------
zeroAcc		clr	zp_trans_acc
		clr	zp_trans_acc + 1
		clr	zp_trans_acc + 2
		clr	zp_trans_acc + 3
		rts

asl4Acc		pshs	B
		ldb	#4
1		asl	zp_trans_acc + 3
		rol	zp_trans_acc + 2
		rol	zp_trans_acc + 1
		rol	zp_trans_acc + 0
		decb
		bne	1B
		puls	B,PC

addAAcc		pshs	D
		tfr	A,B
		clra
		addd	zp_trans_acc + 2
		std	zp_trans_acc + 2
		clra
		adca	zp_trans_acc + 1
		sta	zp_trans_acc + 1
		clra
		adca	zp_trans_acc + 0
		sta	zp_trans_acc + 0
		puls	D,PC

addAtXAcc	pshs	D
		ldd	2,X
		addd	zp_trans_acc + 2
		std	zp_trans_acc + 2
		ldd	0,x
		adcb	zp_trans_acc + 1
		adca	zp_trans_acc + 0
		std	zp_trans_acc + 0
		puls	D,PC

subAtXAcc	pshs	D
		ldd	zp_trans_acc + 2
		subd	2,X
		std	zp_trans_acc + 2
		ldd	zp_trans_acc + 0
		sbcb	1,X
		sbca	0,x
		std	zp_trans_acc + 0
		puls	D,PC


POLYH    	EQU $10
POLYL   	EQU $21

		; update CRC at zp_trans_acc with byte in A
crc16		pshs	D	
		eora	zp_trans_acc        
		sta	zp_trans_acc
		ldb	#8          
crc16_lp
		asl	zp_trans_acc+1
		rol	zp_trans_acc
		bcc	crc16_cl
		lda	zp_trans_acc
		eora	#POLYH
		sta	zp_trans_acc
		lda	zp_trans_acc + 1
		eora	#POLYL
		sta	zp_trans_acc + 1
crc16_cl	decb
		bne 	crc16_lp
		puls	D,PC


;------------------------------------------------------------------------------
; Write to ROM # in Y, addr in X, data in A
;------------------------------------------------------------------------------
;
; have to bounce off the bottom of the stack while we page in the other ROM
;

romWriteInit	pshs	D,X,U
		ldx	#ADDR_ERRBUF
		ldu	#_romWriteBA
		ldb	#_romWriteBA_end - _romWriteBA
1		lda	,U+
		sta	,X+
		decb
		bne	1B
		puls	D,X,U,PC



romWrite	pshs	D,Y
		
		tfr	Y,D
		lda	,S
		jsr	ADDR_ERRBUF

		puls	D,Y,PC

_romWriteBA	pshs	B
		ldb	zp_mos_curROM
		pshs	B
		ldb	1,S
		stb	zp_mos_curROM
		stb	SHEILA_ROMCTL_SWR
		sta	,X
		puls	B
		stb	zp_mos_curROM
		stb	SHEILA_ROMCTL_SWR
		puls	B,PC
_romWriteBA_end


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


;------------------------------------------------------------------------------
; Printing
;------------------------------------------------------------------------------
Print2Spc	jsr	PrintSpc
PrintSpc	lda	#' '
		bra	PrintA
PrintNL		lda	#$D
PrintA		jmp	OSASCI

PrintX		lda	,X+
		beq	1F
		jsr	OSASCI
		bra	PrintX
1		rts

PrintHexNybA	anda	#$0F
		cmpa	#9
		bls	1F
		adda	#'A'-'9'-1
1		adda	#'0'
		jsr	PrintA
		rts
PrintHexA	pshs	A
		lsra
		lsra
		lsra
		lsra
		jsr	PrintHexNybA
		lda	0,S
		jsr	PrintHexNybA
		puls	A,PC
PrintHexX	pshs	D,X
		tfr	X,D
		jsr	PrintHexA
		lda	3,S
		jsr	PrintHexA
		puls	D,X,PC


PrintMsgThenHexNyb
		pshs	A
		jsr	PrintX
		puls	A
		jsr	PrintHexNybA
		jmp	PrintNL

PromptYN	jsr	PrintX
		ldx	#str_YN
		jsr	PrintX

1		jsr	WaitKey
		bcs	2F
		cmpa	#'Y'
		beq	PromptYes
		cmpa	#'N'
		bne	1B
PromptNo	ldx	#strNo
		jsr	PrintX
		lda	#$FF
		CLC
		rts
PromptYes	ldx	#strYes
		jsr	PrintX
		clra
		CLC
2		rts


WaitKey		pshs	B,X,Y
2		lda	#OSBYTE_129_INKEY
		ldy	#$7F
		ldx	#$FF
		jsr	OSBYTE
		bcs	1F
		tfr	X,D
		tfr	B,A
		CLC
		puls	B,X,Y,PC
1		cmpy	#27				; check for escape
		bne	2B
		lbra	ackEscape

;------------------------------------------------------------------------------
; MDUMP
;------------------------------------------------------------------------------

osbyte_160_vduvars_inB
		pshs	A,X,Y
		lda	#OSBYTE_160_READ_VDU_VARIABLE
		jsr	OSBYTE
		tfr	X,D
		puls	A,X,Y,PC

osbyte_read_var_intoA
		pshs	B,X,Y
		ldx	#0
		ldy	#$FFFF
		jsr	OSBYTE
		tfr	X,D
		tsta
		puls	B,X,Y,PC


cmdMdump
 ;; 
 ;;    10 REM >MDump105/s
 ;;    20 REM Source for *MDUMP by J.G.Harston
 ;;    30 REM v0.10 12-Feb-1986 Original MG version
 ;;    40 REM v1.00 10-Mar-1989 Tidied up for Micro User article
 ;;    50 REM v1.01 23-Aug-2006 Added -80 option
 ;;    60 REM v1.02 23-Aug-2006 Tidied up and compacted code
 ;;    70 REM v1.03 25-Aug-2006 Ensured 4-byte Tube address
 ;;    80 REM v1.04 27-Sep-2006 Uses &FFFDxxxx and &FFFExxxx for screen memory
 ;;    90 REM v1.05 29-Sep-2006 Accesses shadow memory on B, not yet B+
 ;;   100 :
 ;;   110 OSWRCH=&FFEE:OSNEWL=&FFE7:OSARGS=&FFDA:OSBYTE=&FFF4
 ;;   120 :
 ;;   130 DIM mcode% &300:load%=&FFFF0900:ver$="v1.05"
 ;;   140 :
 ;;   150 addr=&A8:end=&AC:rom=addr+2:mem=addr+3:os=&AE:cols=&AF:lptr=&F0:tube=&27A
 ;;   160 FOR P=0 TO 1
 ;;   170   P%=load%:O%=mcode%
 ;;   180   [OPT P*3+4
 ;;   190   .buff
 ;;   200   .syntax
 ;;   210   \BRK:\EQUB 220:\EQUS "Syntax:\ MDump (-<cols>) <start> <end>|+<length>":\BRK
 ;;   220   BRK:EQUB 220:EQUS "Syntax: MDump <start> <end>|+<length>":BRK
 ;;   230   :
 ;;   240   .start%
 ;;   250   LDA #135:JSR OSBYTE
 ;;   260   LDX #&16:TYA:BEQ mdump_setcols
 ;;   270   CPY #3:BEQ mdump_setcols:LDX #8


 		pshs	X

 		; DB - use vduvars to divine width of window
 		lda	#16
 		ldx	#vduvar_ix_TXT_WINDOW_LEFT
 		jsr	osbyte_160_vduvars_inB
 		stb	,-S
 		ldx	#vduvar_ix_TXT_WINDOW_RIGHT
 		jsr	osbyte_160_vduvars_inB
 		subb	,S+
 		cmpb	#79
 		bhs	1F
 		lda	#8
1
		puls	X
		sta 	,-S				; stack 16/8 for # of columns to print

		jsr	SkipSpacesX
		cmpa	#'-'
		bne	mdump_skip_cols
		leax	1,X
		jsr	ParseHex
		lbcs	brkInvalidArgument
		lda	zp_trans_acc
		ora	zp_trans_acc + 1
		ora	zp_trans_acc + 2
		lbne 	brkInvalidArgument
		lda	zp_trans_acc + 3		; get low
		cmpa	#$16
		beq	mdump_set16
		cmpa	#$8
		lbne	brkInvalidArgument
		lda	#8
		bra	1F
mdump_set16
		lda	#16		
1		sta	,S				; stack now contains 8/16 for # of cols to display per line

mdump_skip_cols
		lda	,S+				; get # of cols
		nega					; make negative
		leas	A,S				; reserve space on stack
		nega
		sta	,-S				; store # cols on stack

		; now get the start address
		jsr	ParseHex
		lbcs	brkBadCommand
		; save at zp_mdump_addr

		ldd	zp_trans_acc
		std	zp_mdump_addr
		ldd	zp_trans_acc+2
		std	zp_mdump_addr+2

		; copy acc to tmp 
		jsr	SkipSpacesX
		cmpa	#'+'
		bne	1F
		leax	1,X
		jsr	SkipSpacesX
		clra
1		pshs	CC				; stack now contains Z=1 if +

		; get end / len
		jsr	ParseHex
		bcc	mdump_end
		puls	CC				; discard add flag
		clrd
		std	zp_trans_acc
		ldd	#$100
		std	zp_trans_acc + 2
		bra	mdump_main
mdump_end	puls	CC
		beq	mdump_main
mdump_addlen	ldx	#zp_mdump_addr
		jsr	subAtXAcc			; sub addr from end to get len
		lbcs	brkInvalidArgument
mdump_main
		ldb	#$FF
		lda	#OSBYTE_234_VAR_TUBE
		jsr	osbyte_read_var_intoA
		bmi	mdump_loop			; tube is present, use tube addresses
		lda	zp_mdump_addr+1
		bpl	mdump_loop			; address doesn't have top bit 2nd MSB set
		stb	zp_mdump_addr			; set MSB to FF

 ;;;   470   \LDA #0:\JSR OSBYTE:\STX os		; not implemented ACCON on 6809 yet...
mdump_loop
		ldb	#2
		ldx	#zp_mdump_addr+1
1		lda	,X+
		jsr	PrintHexA
		decb
		bpl	1B

		lda	zp_mdump_len
		ora	zp_mdump_len + 1
		ora	zp_mdump_len + 2
		bne	1F
		ldb	zp_mdump_len + 3
		beq	mdump_done
		cmpb	,S
		blo	2F				; if < cols bytes left use that as the count

1		ldb	,S				; number of columns
2		leax	1,S
		jsr	mdump_getbytes		
		pshs	B
mdump_loop_1
		jsr	mdump_prspace
		lda	,X+
		jsr	PrintHexA
		decb
		bne	mdump_loop_1

		ldb	1,S
		subb	,S				; difference between max cols and cols printed this line
		beq	1F
2		jsr	mdump_prspace3
		decb
		bne	2B
1		jsr	mdump_prspace
		ldb	,S
		leax	2,S
mdump_loop2	lda	,X+
		anda	#127
		cmpa	#' '
		blo	2F
		cmpa	#$7F
		bne	1F
2		lda	#'.'
1		jsr	OSWRCH
		decb
		bne	mdump_loop2

		jsr	OSNEWL

		; check escape - TODO use OS call
		lda	$FF
		lbmi	ackEscape

		ldd	zp_mdump_len + 2
		subb	,S+
		sbca	#0
		std	zp_mdump_len + 2
		ldd	zp_mdump_len + 0
		subd	#0
		bcs	mdump_done
		std	zp_mdump_len + 0
		bne	mdump_more
		ldd	zp_mdump_len + 2
		beq	mdump_done

mdump_more	; add # cols to addr
		ldd	zp_mdump_addr + 2
		addb	,S
		adca	#0
		std	zp_mdump_addr + 2
		ldd	zp_mdump_addr + 0
		adcb	#0
		adca	#0
		std	zp_mdump_addr + 0
		lbra	mdump_loop

mdump_done	puls	B
		leas	B,S				; add number of cols back onto stack to clear
		rts

mdump_getbytes	pshs	B,X,Y,U	
		; this is much simplified from JGH's version (for now, no shadow memory or tube yet)

		lda	zp_mdump_addr
		inca
		bne	mdump_gettube
		lda	zp_mdump_addr + 2
		anda	#$C0
		cmpa	#$80
		bne	mdump_getio

		; get from rom using OSRDRM
		pshs	B
		ldb	zp_mdump_addr + 1
		andb	#$0F
		clra
		tfr	D,Y				; Y contains ROM #
		puls	B

		leau	,X				; U contains dest

		ldx	zp_mdump_addr + 2
1		jsr	OSRDRM
		leax	1,X
		sta	,U+
		decb
		bne	1B
		puls	B,X,Y,U,PC


mdump_getio	ldy	zp_mdump_addr + 2
1		lda	,Y+
		sta	,X+
		decb
		bne	1B
		puls	B,X,Y,U,PC


 ;;   800   .GetBytes
 ;;   810   PHP:SEI:LDA &F4:PHA          :\ Disable IRQs, save ROM
 ;;   820   LDA &FE34:PHA                :\ Save ACCCON
 ;;   830   LDX mem:INX:BNE GetTube      :\ addr<&FFxxxxxx, language memory
 ;;   840   AND #&13:JSR SetACCCON       :\ Master, ACCCON=I/O, no FS RAM, main RAM
 ;;   850   LDA rom:TAX
 ;;   860   CLC:ADC #&40:JSR SelectROM   :\ Select the specified ROM
 ;;   870   INX:BEQ GetIOMem             :\ &FFFF - Main memory
 ;;   880   INX:BEQ GetDisplay           :\ &FFFE - Display memory
 ;;   890   INX:BEQ GetShadow            :\ &FFFD - Shadow memory
 ;;   900   ASL A:EOR #&40:AND #&C0      :\ &FFxx0x - page in hidden MOS
 ;;   910   BPL P%+4:ORA #&08:AND #&48   :\ &FFx0xx - page in FS RAM
 ;;   920   ORA &FE34:JSR SetACCCON      :\ Page in requested memory
 ;;   930   BNE GetIOMem
 ;;   940   :
 ;;   950   .GetDisplay
 ;;   960   \LDA &D0:\€ #16:\BEQ GetIOMem :\ Not shadow screen displayed
 ;;   970   LDA #&84:JSR OSBYTE
 ;;   980   TYA:BPL GetIOMem             :\ Not shadow screen displayed
 ;;   990   .GetShadow
 ;;  1000   LDA #1:JSR vramSelect        :\ Page in shadow memory
 ;;  1010   :
 ;;  1020   .GetIOMem
 ;;  1030   LDY #0
 ;;  1040   .GetByteLp
 ;;  1050   LDA (addr),Y:STA buff,Y
 ;;  1060   INY:CPY cols:BNE GetByteLp
 ;;  1070   :
 ;;  1080   LDA #0:JSR vramSelect
 ;;  1090   PLA:JSR SetACCCON:PLA:PLP    :\ Restore ACCCON, restore ROM and IRQs
 ;;  1100   .SelectROM
 ;;  1110   STA &F4:STA &FE30:RTS
 ;;  1120   :
 ;;  1130   .SetACCCON
 ;;  1140   \LDX os:\CPX #3
 ;;  1150   \BCC P%+5:\STA &FE34         :\ Set ACCCON if on Master
 ;;  1160   LDX OSARGS:CPX #&5C
 ;;  1170   BCS P%+5:STA &FE34           :\ Set ACCCON if on Master
 ;;  1180   .vramOk
 ;;  1190   RTS
 ;;  1200   :
 ;;  1210   .vramSelect
 ;;  1220   PHA:TAX                  :\ A=0 main RAM, A=1 video RAM
 ;;  1230   LDA #108:JSR OSBYTE      :\ Attempt to select Master video RAM
 ;;  1240   PLA:INX:BNE vramOk       :\ X<>255, successful
 ;;  1250   EOR #1:TAX               :\ A=1 main RAM, A=0 video RAM
 ;;  1260   LDA #111:JMP OSBYTE      :\ Attempt to select Aries/Watford RAM
 ;;  1270   :


mdump_gettube
		lda	#OSBYTE_234_VAR_TUBE
		jsr	osbyte_read_var_intoA
		bpl	mdump_getio
		M_ERROR
		FCB	255, "Tube not implemented",0

mdump_prspace3	jsr	mdump_prspace
		jsr	mdump_prspace
mdump_prspace	pshs	A
		lda	#' '
		jsr	OSWRCH
		puls	A,PC

 ;;  1280   .GetTube
 ;;  1290   BIT tube:BPL GetIOMem   :\ No Tube present
 ;;  1300   .GetTubeClaim
 ;;  1310   LDA #&C0+&10:JSR &406
 ;;  1320   BCC GetTubeClaim        :\ Claim Tube
 ;;  1330   LDX #addr:LDY #0
 ;;  1340   TYA:JSR &406:LDY #0     :\ Read bytes from Tube
 ;;  1350   .GetTubeLp
 ;;  1360   LDX #9                  :\ Delay between each byte
 ;;  1370   .GetTubeWait
 ;;  1380   DEX:BNE GetTubeWait     :\ 2+(2+3)*9+2+2 = 51 cycles = 25.5us
 ;;  1390   LDA &FEE5:STA buff,Y    :\ Fetch from Tube
 ;;  1400   INY:CPY cols:BNE GetTubeLp
 ;;  1410   PLA:PLA:PLP             :\ Drop from stack, restore IRQs
 ;;  1420   LDA #&80+&10:JMP &406   :\ Release Tube
 ;;  1430   :
 ;;  1440   .PrSpace
 ;;  1450   LDA #32:BNE PrChar
 ;;  1460   .PrHex
 ;;  1470   PHA:LSR A:LSR A:LSR A:LSR A
 ;;  1480   JSR PrDigit:PLA
 ;;  1490   .PrDigit
 ;;  1500   AND #15:CMP #10:BCC PrNybble:ADC #6
 ;;  1510   .PrNybble:ADC #48
 ;;  1520   .PrChar  :JMP OSWRCH
 ;;  1530   :
 ;;  1540   .GetHex
 ;;  1550   LDA #0
 ;;  1560   STA 0,X:STA 1,X
 ;;  1570   STA 2,X:STA 3,X
 ;;  1580   .GetHexNext
 ;;  1590   LDA (lptr),Y
 ;;  1600   CMP #ASC"0":BCC SkipSpace
 ;;  1610   CMP #ASC"9"+1:BCC GetHexDigit
 ;;  1620   SBC #7:BCC SkipSpace
 ;;  1630   CMP #ASC"@":BCS SkipSpace
 ;;  1640   .GetHexDigit
 ;;  1650   AND #&0F:PHA:TYA:PHA:LDY #4
 ;;  1660   .GetHexMultiply
 ;;  1670   ASL 0,X:ROL 1,X:ROL 2,X:ROL 3,X
 ;;  1680   DEY:BNE GetHexMultiply
 ;;  1690   PLA:TAY
 ;;  1700   PLA:ORA 0,X:STA 0,X
 ;;  1710   INY:BNE GetHexNext
 ;;  1720   :
 ;;  1730   .SkipSpace1
 ;;  1740   INY
 ;;  1750   .SkipSpace
 ;;  1760   LDA (lptr),Y:CMP #ASC" ":BEQ SkipSpace1
 ;;  1770   CMP #13:RTS
 ;;  1780   :
 ;;  1790   EQUS ver$
 ;;  1800   :
 ;;  1810   ]:NEXT
 ;;  1820 PRINT"*SAVE MDump "+STR$~mcode%+" "+STR$~O%+" "+STR$~(start%OR&FFFF0000)+" "+STR$~(load%OR&FFFF0000)
 ;; 
 ;; 

;------------------------------------------------------------------------------
; Strings and tables
;------------------------------------------------------------------------------

str_HELP_KEY	EQU 	utils_name

tbl_commands	FDB	strCmdRoms, cmdRoms, helpRoms
		FDB	strCmdSRCOPY, cmdSRCOPY, strHelpSRCOPY
		FDB	strCmdSRERASE, cmdSRERASE, strHelpSRERASE
		FDB	strCmdSRNUKE, cmdSRNUKE, 0
		FDB	strCmdSRLOAD, cmdSRLOAD, strHelpSRLOAD
	IF MACH_BEEB
		FDB	strCmdVNVDU, cmdVNVDU, strHelpVNVDU
		FDB	strCmdVNRESET, cmdVNRESET, 0
	ENDIF
		FDB	strCmdMDUMP, cmdMdump, strHelpMdump
		FDB	0

str_WhichRom	FCB	"Erase Which Rom", 0
strCmdRoms	FCB	"ROMS", 0
helpRoms	FCB	"[V|VA]", 0
strCmdSRCOPY	FCB	"SRCOPY",0
strHelpSRCOPY	FCB	"<dest id> <src id>",0
strCmdSRNUKE	FCB	"SRNUKE",0
strCmdSRERASE	FCB	"SRERASE",0
strHelpSRERASE	FCB	"<dest id> [F]",0
strCmdSRLOAD	FCB	"SRLOAD", 0
strHelpSRLOAD	FCB	"<filename> <id>",0
	IF MACH_BEEB
strCmdVNVDU	FCB	"VNVDU",0
strHelpVNVDU	FCB	"ON|OFF",0
strCmdVNRESET	FCB	"VNRESET",0
	ENDIF
strCmdMDUMP	FCB	"MDUMP",0
strHelpMdump	FCB	"[-8|-16] <start> [<end>|+<length>]",0

strRomsHeadVer	FCB	"  # act  crc typ ver Title", 13
		FCB	" == === ==== === === =====", 13, 0 

strRomsHead	FCB	"  # typ ver Title", 13
		FCB	" == === === =====", 13, 0 

str_C		FCB	0,"(C)"
strNoRom	FCB	"--",0

strSRCOPY2RAM	FCB	"Copying to SROM/SRAM at ",0
strSRCOPY2FLASH	FCB	"Copying to Flash at ",0
strSRERASEFLASH	FCB	"Erasing Flash at ",0
strSRERASERAM	FCB	"Erasing SRAM at ",0

str_Copying	FCB	"Copying...", 0
str_OK		FCB	$D, "OK.", $D, 0
str_NukePrAllFl	FCB	"Erase whole Flash", 0
str_NukePrAllRa	FCB	"Erase whole SRAM", 0
str_NukePrRom	FCB	"Erase rom ",

str_YN		FCB	" (Y/N)?",0
str_FailedAt	FCB	"failed at ",0
strErrsDet	FCB	" errors detected", 0
strNo		FCB	"No", $D, 0
strYes		FCB	"Yes", $D, 0
str_NukeFl	FCB	"Erasing flash...", $D, 0
str_NukeRa	FCB	"Erasing SRAM $E00000 to $0FFFFF, please wait...", $D, 0

	IF MACH_BEEB

vnula_flags		equ	$39F				; unused OS var in CFS workspace, need to be careful here as I'm likely to get rid of CFS!
vnula_oldwrchv		equ	$3A0				; unused OS var in CFS workspace, need to be careful here as I'm likely to get rid of CFS!
vnula_oldbytev		equ	$3A5				; unused OS var in CFS workspace, need to be careful here as I'm likely to get rid of CFS!
vnula_vdu_code_sav 	equ	$3A2				; unused OS var in CFS workspace, need to be careful here as I'm likely to get rid of CFS!
vnula_chosen_mode	equ	$3A3				; unused OS var in CFS workspace, need to be careful here as I'm likely to get rid of CFS!

vnula_newmodeflag	equ	$03				; (bits 0 and 1)
vnula_newvduflag 	equ	$04				; (bit 2)
vnula_thinfontflag 	equ	$08 				; (bit 3)
ext_wrchv_offs		equ	$15
ext_bytev_offs		equ	$0F
vnula_key_COPY 		equ	$8B
vnula_zp		equ	$A8				; use transient area
vnula_MODE_base		equ	96
vnula_MODES_count	equ	9
vnula_MODES_top		equ	vnula_MODE_base+vnula_MODES_count



; always works as a BBC - there's more to the OS number on a 6x09 system 
;vnula_whichos	clra
;		ldx	#1
;		jsr	OSBYTE
;		cmpx	#3				; set HS if master i.e. Cy=0
;		rts

vnula_reset	; ORGLABEL=.thirtyseven
 		jsr	vnula_noattributes			
 		lda	#OSBYTE_253_VAR_LAST_RESET
 		ldx	#0
 		ldy	#$FF
 		jsr	OSBYTE				; do OSBYTE call to establish type of reset
 		cmpx	#0
 		bne	vnula_hardbreak			; restore original font as soft-break
 		jsr	vnula_restoreoriginalfont
		
vnula_hardbreak
 		
vnula_breakreset
 		
 		lda	#~vnula_thinfontflag
 		anda	vnula_flags
 		sta	vnula_flags			; clear thin font flag as fonts will have been reset
 		
 		* if extended vdu drivers had been turned on, re-enable them
 		* check for sensible values (as have seen it set to &FF on power-up)
 		lda	vnula_flags
 		cmpa	#$10
 		bhs	vnula_resetflags
 		anda	#vnula_newvduflag
 		beq	1F
 		jsr	vnula_enablexvdu
1 		rts
 		
vnula_resetflags
		clr	vnula_flags
		rts

brkInvalidArgument
		M_ERROR
		fcb	$7F, "Invalid Argument", 0

;==============================================================================
cmdVNRESET
;==============================================================================
		lda	#$40
		sta	SHEILA_NULA_CTLAUX
		rts


;==============================================================================
cmdVNVDU	* Enable\disable extended VDU drivers
;==============================================================================

		; TODO - use GSREAD!
		jsr	SkipSpacesX
		cmpa	#$D
		beq	brkInvalidArgument
		lda	,X+
		anda	#$DF
		cmpa	#'O'
		bne	brkInvalidArgument
		lda	,X+
		anda	#$DF
		cmpa	#'N'
		beq	vnula_vduon
		cmpa	#'F'
		bne	brkInvalidArgument
		lda	,X+
		anda	#$DF
		cmpa	#'F'
		bne	brkInvalidArgument


vnula_vduoff
		lda	vnula_flags
		anda	#vnula_newvduflag
		bne	1F
		rts
1		* restore old vectors
		pshs	CC
		SEI
		ldx	vnula_oldwrchv
		stx	WRCHV
		ldx	vnula_oldbytev
		stx	BYTEV
		puls	CC				; restore interrupts to how the were

		lda	vnula_flags
		anda	#vnula_newmodeflag
		beq	vnula_resetflags		; not in new a new mode so switch off attribute modes
		
		jsr	vnula_noattributes			
		jsr	vnula_restoreoriginalfont	; and restore original font
		
		lda	#22
		jsr	OSWRCH
		lda	vduvar_MODE
		jsr	OSWRCH				; and restore screen mode
		bra	vnula_resetflags
		
vnula_noattributes
		lda	#$60	
		sta	SHEILA_NULA_CTLAUX
		lda	#$70
		sta	SHEILA_NULA_CTLAUX
		rts	

vnula_vduon
		lda	vnula_flags
		anda	#vnula_newvduflag
		beq	vnula_enablexvdu
		rts

vnula_enablexvdu
		pshs	CC
		SEI					; DB: just in case

		; enable extended VDU vectors
		; get start of extended vector space
		lda	#OSBYTE_168_READ_ROM_POINTER_TABLE
		ldx	#0
		ldy	#$FF
		jsr	OSBYTE				; X now points at start of extended vectors (usually $0D9F)
		
		ldd	#vnula_newwrch
		std	ext_wrchv_offs,X
		lda	zp_mos_curROM
		sta	ext_wrchv_offs+2,X

		ldd	#vnula_newbytev
		std	ext_bytev_offs,X
		lda	zp_mos_curROM
		sta	ext_bytev_offs+2,X

		ldd	WRCHV
		std	vnula_oldwrchv
		ldd	#$FF00 + ext_wrchv_offs
		std	WRCHV

		ldd	BYTEV
		std	vnula_oldbytev
		ldd	#$FF00 + ext_bytev_offs
		std	BYTEV

		lda	#vnula_newvduflag
		sta	vnula_flags

		puls	CC,PC				; restore interrupts

;==============================================================================
; WRCHV
;==============================================================================

		; extended WRCH routine for VDU 17, 19, 20 and 22
vnula_newwrch
		pshs	D
		tst	sysvar_VDU_Q_LEN
		bmi	vnula_wrch_checkQ
		sta	vnula_vdu_code_sav		; save for later so we know which of our routines to enter when
		cmpa	#20				; Q is filled (if any)
		lbeq	vnula_vdu20
vnula_oldwrchD	puls	D
		jmp	[vnula_oldwrchv]

vnula_wrch_checkQ
		; check VDU settings before doing anything
		ldb	#2
		bitb	sysvar_OUTSTREAM_DEST
		bne	vnula_oldwrchD
		ldb	#$80
		bitb	zp_vdu_status
		bne	vnula_oldwrchD 
		; check queue length and first code
		ldb	sysvar_VDU_Q_LEN
		cmpb	#255
		bne	vnula_oldwrchD
		sta	vduvar_VDU_Q_END-1		; complete the Q, but don't update LEN yet 
		ldb	vnula_vdu_code_sav		; - that might be done by original routine if we pass on
		cmpb	#19
		beq	dovdu19
		cmpb	#22
		lbeq	dovdu22
		cmpb	#17
		beq	dovdu1718
		cmpb	#18
		beq	dovdu1718
		jmp	vnula_oldwrchD

dovdu1718	; first check whether we are in a new mode
		ldb	#vnula_newmodeflag
		bitb	vnula_flags
		beq	vnula_oldwrchD
newvdu1718	; store X and vnula_zp vars on stack
		ldd	vnula_zp
		pshs	D,X
		; get Y=0 for VDU 17, Y=2 for VDU 18
		ldb	vnula_vdu_code_sav
		andb	#2
		jsr	vnula_docol_attr_API
		bra	newvdu_done_ZP_X_D

vdu19Q_log	EQU	vduvar_VDU_Q_END-5
vdu19Q_phys	EQU	vduvar_VDU_Q_END-4
vdu19Q_R	EQU	vduvar_VDU_Q_END-3
vdu19Q_G	EQU	vduvar_VDU_Q_END-2
vdu19Q_B	EQU	vduvar_VDU_Q_END-1

dovdu19
vdu19
		; VDU queue
		; $31F logical colour, $320 vdu19_physical colour + extensions
		; $321 red component, $322 green component, $323 blue component
		lda	vdu19Q_phys			; get phys/ext
		cmpa	#16
		beq	vdu19_logical
		blo	vdu19_physical	
		bra	vnula_oldwrchD

vdu19_logical
		ldd	vnula_zp
		pshs	D,X
		; set logical mapping
		lda	#$11
		sta	SHEILA_NULA_CTLAUX
		lda	vdu19Q_log


vnu19_shiftcol
		asla
		asla
		asla
		asla
		sta	vnula_zp
		lda	vdu19Q_R
		lsra
		lsra
		lsra
		lsra
		ora	vnula_zp
		ldb	vdu19Q_G
		andb	#$F0
		stb	vnula_zp
		ldb	vdu19Q_B
		lsrb
		lsrb
		lsrb
		lsrb
		orb	vnula_zp
		SEI
		sta	SHEILA_NULA_PALAUX
		stb	SHEILA_NULA_PALAUX
		CLI
		bra	newvdu_done_ZP_X_D

vdu19_physical
		; test vdu19_logical colour = 0
		lda	vdu19Q_log
		bne	checknewmodevdu19
		; test r,b or g non-zero
		lda	vdu19Q_R
		ora	vdu19Q_G
		ora	vdu19Q_B
		bne	dophysvdu
checknewmodevdu19
		lda	#vnula_newmodeflag
		bita	vnula_flags
		bne	newmodevdu19
		jmp	vnula_oldwrchD

dophysvdu	ldd	vnula_zp 			;store X and vnula_zp vars on stack
		pshs	D,X		
		lda	#$10
		sta	SHEILA_NULA_CTLAUX		; set vdu19_physical mapping
		lda	$320
		jmp	vnu19_shiftcol
				
newvdu_done_ZP_X_D
		puls	D,X
		std	vnula_zp
newvdu_done_D
		inc	sysvar_VDU_Q_LEN		; indicate we've complete Q
		puls	D,PC

newmodevdu19
		; this is VDU 19,l,p,0,0,0 for new modes
		; check vdu19_logical 0-15
		; already know vdu19_physical is 0-15 and last three not all zero
		lda	vdu19Q_log
		bmi	newvdu_done_D
		beq	vdu19_setzero
		cmpa	#16
		bhs	newvdu_done_D

		ldd	vnula_zp 			;store X and vnula_zp vars on stack
		pshs	D,X
		
		ldb	vnula_chosen_mode
		andb	#$7F				; check vdu19_logical colour is in correct range
		subb	#vnula_MODE_base
		ldx	#vnulatbl_newmodemaxcol
		lda	B,X
		cmpa	vdu19Q_log
		blo	newvdu_done_ZP_X_D		; exit if <
		; map new mode colour number to actual vdu19_logical colour
		ldx	#vnulatbl_paltableindex
		lda	B,X
		adda	vdu19Q_log
		ldx	#vnulatbl_colmapping
		lda	A,X
		sta	vnula_zp 			; store that
		lda	vdu19Q_phys
		eora	#7
		ora	vnula_zp
		sta	sheila_VIDULA_pal
		jmp	newvdu_done_ZP_X_D
				
vdu19_setzero
		ldd	vnula_zp 			;store X and vnula_zp vars on stack
		pshs	D,X

		lda	vnula_chosen_mode
		andb	#$7F
		subb	#vnula_MODE_base
		ldx	#vnulatbl_newmodemaxcol
		ldb	b,X
;;;		tay
;;;		cmp	$31F				; what was this for?
		lda	vdu19Q_phys
		eora	#7
		sta	vnula_zp
		sta	sheila_VIDULA_pal ; col 0
		adda	#$40
		sta	sheila_VIDULA_pal ; col 4
		adda	#$40
		sta	sheila_VIDULA_pal ; col 8
		adda	#$40
		sta	sheila_VIDULA_pal ; col 12
		; check max colours
		cmpb	#15
		beq	setzeroend
		lda	vnula_zp
		adda	#$20
		sta	sheila_VIDULA_pal ; col 2
		adda	#$40
		sta	sheila_VIDULA_pal ; col 6
		adda	#$40 
		sta	sheila_VIDULA_pal ; col 10
		adda	#$40
		sta	sheila_VIDULA_pal ; col 14
		cmpb	#8
		beq	setzeroend
		lda	vnula_zp
		adda	#$30
		sta	sheila_VIDULA_pal ; col 3
		adda	#$40
		sta	sheila_VIDULA_pal ; col 7
		adda	#$40 
		sta	sheila_VIDULA_pal ; col 11
		adda	#$40
		sta	sheila_VIDULA_pal ; col 15				
setzeroend
		jmp	newvdu_done_ZP_X_D


dovdu22		lda	vduvar_VDU_Q_END-1
		anda	#$7F
		cmpa	#vnula_MODE_base
		bhs	vdu22_newmode
vdu22_not_newmode
		; original mode so switch off attribute modes
		lda	#$60
		sta	SHEILA_NULA_CTLAUX
		lda	#$70
		sta	SHEILA_NULA_CTLAUX
		lda	#~vnula_newmodeflag
		anda	vnula_flags
		sta	vnula_flags
		anda	#vnula_thinfontflag
		beq	vdu22_not_newmode_ret
		; need to restore original font
		jsr	vnula_restoreoriginalfont
		; clear thin font flag
		lda	#~vnula_thinfontflag
		anda	vnula_flags
		sta	vnula_flags
;;; TODO ;;;	; reinsert vdu 22 on Master as we've used VDU23 to restore font
;;; TODO ;;;	jsr	whichOS
;;; TODO ;;;	bcc	noneedforvdu22
;;; TODO ;;;	lda	#22
;;; TODO ;;;	jsr	OSVDU
;;; noneedforvdu22
;;;		pla
;;;		pha
;;;		sta	$323
vdu22_not_newmode_ret
		jmp	vnula_oldwrchD


vdu22_newmode
		cmpa	#vnula_MODES_top
		bhs	vdu22_not_newmode
		lda	#~(vnula_newmodeflag|vnula_thinfontflag)
		anda	vnula_flags
		ora	#1							; mode 1 ??
		sta	vnula_flags

		ldd	vnula_zp 			;store X and vnula_zp vars on stack
		pshs	D,X

		ldb	vduvar_VDU_Q_END-1
		andb	#$7F				; get back mode #
		subb	#vnula_MODE_base
		stb	vnula_zp			; now contains new mode offset #
		; get equivalent original mode number (including shadow bit)
		ldx	#vnulatbl_modenumtab
		lda	B,X
		sta	vnula_zp+1			
		lda	vnula_chosen_mode
		anda	#$80
		ora	vnula_zp+1
		sta	vnula_zp+1			; now contains a "base mode"
		; change to equivalent original mode
		lda	#0
		sta	sysvar_VDU_Q_LEN		; reset Q so subsequent mode change works
		lda	#22
		jsr	vnula_OSVDU
		lda	vnula_zp+1
		jsr	vnula_OSVDU

		; sort out VDU queue
		lda	#255
		sta	sysvar_VDU_Q_LEN
				
		; switch on 2-bit attribute mode only
		lda	#$61
		sta	SHEILA_NULA_CTLAUX
		lda	#$70
		sta	SHEILA_NULA_CTLAUX
		; switch on 3-bit attribute mode if required
		ldb	vnula_zp
		ldx	#vnulatbl_threebittab
		lda	B,X
		beq	vdu22_donewpalandfont
		bpl	vdu22_xtraattr
				
		; set new mode flag to 2 (10) for 2-bit per pixel/2-bit attribute 
		lda	#vnula_newmodeflag
		eora	vnula_flags
		sta	vnula_flags
		jmp	vdu22_donewpalandfont

vnula_OSVDU	jmp	[vnula_oldwrchv]		; TODO: this is to replace the RobC jump straigh to VDU driver


vdu22_xtraattr
		lda	#$71
		sta	SHEILA_NULA_CTLAUX
		; mark as text-only mode (0 pixels per byte)
		lda	#0
		sta	vduvar_PIXELS_PER_BYTE_MINUS1
		lda	vnula_flags
		ora	#3
		sta	vnula_flags

		; setup palette
vdu22_donewpalandfont 
		jsr	vnula_newmode_pal
				
		; setup font
vdu22_donewfont
		lda	vnula_flags
		anda	#vnula_thinfontflag
		beq	loadthinfont
		jmp	newvdu_done_ZP_X_D

loadthinfont
		; set thin font flag
		lda	vnula_flags
		ora	#vnula_thinfontflag
		sta	vnula_flags
;;;		jsr	whichOS
;;;		bcc	beebthinfont
;;;		jmp	masterthinfont

beebthinfont
		; B/B+ - set font pointers
		lda	vnula_flags
		anda	#vnula_newmodeflag
		cmpa	#2
		bne	beebthin1

tfont2_page	equ	t_font2 / 256
tfont_page	equ	t_font / 256
beebthin2
		lda	#tfont2_page
		bra	1F
				
beebthin1
		; B/B+ - set font pointers
		lda	#tfont_page
1		sta	vduvar_FONT_LOC32_63
		inca
		sta	vduvar_FONT_LOC64_95
		inca
		sta	vduvar_FONT_LOC96_127
beebthinend
		; flag chars 32-127 as in "RAM"
		lda	vduvar_EXPLODE_FLAGS
		ora	#$70
		sta	vduvar_EXPLODE_FLAGS
		jmp	newvdu_done_ZP_X_D

vnula_restoreoriginalfont
;;;		jsr	whichOS
;;;		bcc	beeboriginalfont
;;;		jmp	masteroriginalfont
;;;beeboriginalfont
		; B/B+ - set font pointers
		lda	#$C0d
		sta	vduvar_FONT_LOC32_63
		inca
		sta	vduvar_FONT_LOC64_95
		inca
		sta	vduvar_FONT_LOC96_127
		; flag chars 32-127 as in ROM
		lda	vduvar_EXPLODE_FLAGS
		anda	#$8F
		sta	vduvar_EXPLODE_FLAGS
		rts


vnula_vdu20		
		; ; first check whether we are in a new mode
		lda	vnula_flags
		anda	#vnula_newmodeflag
		lbeq	vnula_oldwrchD

		ldd	vnula_zp 			;store X and vnula_zp vars on stack
		pshs	D,X

		ldb	vnula_chosen_mode
		andb	#$7F
		subb	#vnula_MODE_base
		jsr	vnula_newmode_pal
		lda	#255
		sta	sysvar_VDU_Q_LEN
		jmp	newvdu_done_ZP_X_D



		; Set up default palette (X is new mode - basemode)
vnula_newmode_pal
		ldx	#vnulatbl_paltableindex
		lda	B,X

		; set default foreground colour
		ldx	#vnulatbl_defaultfcol
		ldb	B,X
		stb	vduvar_VDU_Q_END-1


		ldx	#vnulatbl_paltb
		tfr	a,b
		abx
		ldb	#16
vnula_newmode_pallp
		lda	,X+
		sta	sheila_VIDULA_pal
		decb
		bne	vnula_newmode_pallp
				
		clrb



		; API changed 
		;	Y contained 0 for VDU 17 (txt), 2 for VDU 18 (gra)
		; 	- now use B 
vnula_docol_attr_API
		lda	vnula_flags
		anda	#vnula_newmodeflag		; get mode flags	
		tst	vduvar_VDU_Q_END-1
		bpl	fgcol
		incb
fgcol		cmpa	#1
		beq	coltab1
		cmpa	#2
		beq	coltab2
		bra	coltab3
coltab1
		lda	vduvar_VDU_Q_END-1
		beq	coltab1b
		deca
		anda	#3				; confine to index 1..4
		inca
coltab1b	ldx	#vnulatbl_colplottable1		
		lda	A,X
		sta	vnula_zp
		lda	#$FC
		sta	zp_vdu_wksp		
		jmp	storecol

coltab2		lda	vduvar_VDU_Q_END-1
		anda	#$0F
		ldx	#vnulatbl_colplottable2
		lda	A,X
		sta	vnula_zp
		lda	#$EE
		sta	zp_vdu_wksp
		jmp	storecol

coltab3		lda	vduvar_VDU_Q_END-1
		beq	coltab3b
		deca
		anda	#7				; confine to index 1..8
		inca		
coltab3b
		ldx	#vnulatbl_colplottable3
		lda	A,X
		sta	vnula_zp
		lda	#$F8
		sta	zp_vdu_wksp
storecol
		lda	vnula_zp
		ldx	#vduvar_TXT_FORE
		sta	B,X
		cmpb	#2
		bhs	dographcol
		lda	vduvar_TXT_FORE
		eora	#$FF
		anda	zp_vdu_wksp
		sta	zp_vdu_txtcolourEOR		 ; foreground text colour masked
		eora	vduvar_TXT_BACK ; background text colour
		anda	zp_vdu_wksp
		sta	zp_vdu_txtcolourOR
		lda	zp_vdu_wksp
		eora	#$FF
		anda	vnula_zp
		ora	zp_vdu_txtcolourOR
		sta	zp_vdu_txtcolourOR
		rts
				
dographcol
		lda	vduvar_VDU_Q_END-2		; getback gcol code from Q
		ldx	#vduvar_GRA_PLOT_FORE-2
		sta	B,X
		rts
			


vnula_newbytev
		pshs	CC,D

		cmpa	#$85
		beq	vnula_new_osbyte_133

		cmpa	#$87
		beq	vnula_new_osbyte_135

vnula_oldbytev_D_CC		
		puls	CC,D
		jmp	[vnula_oldbytev]


vnula_new_osbyte_133
		tfr	X,D				; b contains mode
		andb	#$7F
		cmpb	#vnula_MODE_base
		blo	vnula_oldbytev_D_CC
		cmpb	#vnula_MODES_top
		bhs	vnula_oldbytev_D_CC
		; now know this is a new mode - replace X with standard mode equivalent
		subb	#vnula_MODE_base
		ldx	#vnulatbl_modenumtab
		ldb	B,X				; get mode start page
		clra
		tfr	D,X				; X now contains "base" mode number
		bra	vnula_oldbytev_D_CC		; call original OSBYTE


vnula_new_osbyte_135
		ldb	#vnula_newmodeflag
		andb	vnula_flags			
		beq	vnula_oldbytev_D_CC		; not a new mode, call org function

		lda	vduvar_TXT_BACK			; get current background colour
		sta	,-S				; stack it

		lda	zp_vdu_txtcolourOR		; get current attributes
		eora	zp_vdu_txtcolourEOR		; this should contain the colour and attributes
		cmpb	#2
		beq	1F				; if mo.1+attrs mask off to $11
		bhi	2F				; 3 bpp
		anda	#3
		bra	3F
2		anda	#7
		bra	3F
1		anda	#$11
3		sta	,-S				; cur attrs, store this to let us know if we've done all the attributes

vnula_new_osbyte_135_loop
		sta	vduvar_TXT_BACK			; this is used in 135 MOS routine to mask out attributes
		lda	#135
		jsr	[vnula_oldbytev]		; call original routine
		cmpx	#0
		bne	vnula_new_osbyte_135_done

		; try next attribute
		lda	vduvar_TXT_BACK
		cmpb	#2
		beq	1F
		inca
		anda	#7				; 3bpp
		blo	3F
		anda	#3				; 2bpp
		bra	3F
1		lsra
		bcs	2F
		SEC
		rola
		bra	3F
2		asla
		eora	#$10
3		cmpa	,S				; if eq then we've tried all combinations
		bne	vnula_new_osbyte_135_loop

vnula_new_osbyte_135_done
		leas	1,S				; unstack saved initial attribute
		ldb	vnula_chosen_mode
		clra
		tfr	D,Y
		lda	,S+
		sta	vduvar_TXT_BACK
		puls	CC,D,PC




		; colour table for 2-bit, 2 colour attribute modes
vnulatbl_colplottable1
		fcb	$00, $FC, $FD, $FE, $FF
				
		; colour table for 2-bit, 4 colour attribute modes
vnulatbl_colplottable2
		fcb	$00
		fcb	$0E, $E0, $EE
		fcb	$0F, $E1, $EF 
		fcb	$1E, $F0, $FE
		fcb	$1F, $F1, $FF
		fcb	$00, $00, $00
				
		; colour table for 3-bit 2 colour attribute modes
vnulatbl_colplottable3
		fcb	$00, $F8, $F9, $FA, $FB, $FC, $FD, $FE, $FF

vnulatbl_modenumtab
		fcb	0, 1, 3, 4, 6, 0, 3, 4, 6
vnulatbl_threebittab
		fcb	0, -1, 0, 0, 0, 1, 1, 1, 1
vnulatbl_paltableindex
		fcb	0, 16, 0, 0, 0, 32, 32, 32, 32
vnulatbl_defaultfcol
		fcb	4, 7, 4, 4, 4, 7, 7, 7, 7
vnulatbl_newmodemaxcol
		fcb	4, 15, 4, 4, 4, 8, 8, 8, 8

vnulatbl_colmapping
		fcb	$00, $10, $50, $90, $D0, $00, $00, $00
		fcb	$00, $00, $00, $00, $00, $00, $00, $00
		fcb	$00, $10, $20, $30, $50, $60, $70, $90
		fcb	$A0, $B0, $D0, $E0, $F0, $00, $00, $00
		fcb	$00, $10, $30, $50, $70, $90, $B0, $D0, $F0 

vnulatbl_paltb
		; 2-bit attribute, 2 colour modes
		fcb	$07,$16,$27,$37,$47,$55,$67,$77,$87,$94,$A7,$B7,$C7,$D0,$E7,$F7
		; 2-bit attribute, 4 colour mode
		fcb	$07,$16,$25,$34,$47,$53,$62,$71,$87,$90,$AF,$BE,$C7,$DA,$E9,$F8
		; 3-bit attribute, 2 colour modes
		fcb	$07,$16,$27,$35,$47,$54,$67,$73,$87,$92,$A7,$B1,$C7,$D0,$E7,$FF


a_h		FILL 	$FF, (256-(a_h & $FF)) & $FF

t_font
		include	"vnula_font_thin_mo0.asm"
t_font2
		include	"vnula_font_thin_mo1.asm"
ofont
		include "vnula_font_original.asm"

	ENDIF