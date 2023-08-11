;----- TODO 
;	make commands that can destroy this rom run from a copy in main RAM then reboot i.e. NUKE,ERASE,COPY,LOAD etc
;	MDUMP - make more robust access to chip RAM? sort out addressing?

; Notes for RobC to possibly include in VideoNULA rom
; - osbyte 135 - 
; * rather than setting the background mask to 0 when trying original 135 try
;   setting to zp_vdu_txtcolourOR (i.e. ?&D2) this will then match on any text 
;   in the current colour (D2 contains current attributes)
; * try all combinations of attrs in turn instead of using own routine - 
;   this is slightly slower (for other colours) but has the advantage of using
;   the original 135 routine that correctly uses the MOS table to locate the
;   font - and so works for VDU 23'd chars


		SETDP 0

; JGH
; - mdump, doesn't handle ACCON yet
; - mdump, doesn't get bytes past length (useful where dumping hardware regs, reads past len cause problems)



		include "../../includes/oslib.inc"
		include "../../includes/hardware.inc"
		include "../../includes/common.inc"
		include "../../includes/mosrom.inc"

		include	"bltutil.inc"

	IF MACH_BEEB
		include "bltutil_jimstuff.inc"
		include "VERSION-date.gen.beeb.asm"
	ENDIF
	IF MACH_SBC09
		include "VERSION-date.gen.sbc09.asm"
	ENDIF

		ORG	$8000

		include "bltutil_romheader.asm"








;------------------------------------------------------------------------------
; Commands
;------------------------------------------------------------------------------

ParseIX01Flags
		; check flags I, X|0|1
		lda	#OSWORD_BLTUTIL_FLAG_CURRENT
		sta	zp_SRLOAD_flags
1		jsr	SkipSpacesX
		leax	1,X
		cmpa	#13
		beq	flagloopexit
		jsr	ToUpper
		cmpa	#'I'
		beq	flag_I
		cmpa	#'X'
		beq	flag_X
		cmpa	#'0'
		beq	flag_0
		cmpa	#'1'
		beq	flag_1
		jmp	brkBadCommand
flag_I		lda	zp_SRLOAD_flags
		ora	#OSWORD_BLTUTIL_FLAG_IGNOREMEMI
		bne	2F
flag_X		lda	zp_SRLOAD_flags
		ora	#OSWORD_BLTUTIL_FLAG_ALTERNATE|OSWORD_BLTUTIL_FLAG_CURRENT
		bne	2F
flag_0		lda	zp_SRLOAD_flags
		anda	#OSWORD_BLTUTIL_FLAG_CURRENT
		bne	2F
flag_1		lda	zp_SRLOAD_flags
		anda	#OSWORD_BLTUTIL_FLAG_CURRENT^$FF
		ora	#1
2		sta	zp_SRLOAD_flags
		bra	1B

flagloopexit

		leas	-1,S				; blank for return hi
		lda	zp_SRLOAD_flags
		sta	,-S				; flags in to OSWORD
		lda	zp_SRLOAD_dest
		sta	,-S				; rom #
		ldd	#$0405				; in / out length to/from OSWORD
		std	,--S				; return length in bytes
		lda	#OSWORD_BLTUTIL
		leax	0,S
		jsr	OSWORD

		lda	2,S
		sta	zp_SRLOAD_flags
		lda	3,S
		sta	zp_mos_genPTR			; hi byte of pointer
		clr	zp_mos_genPTR+1
		lda	4,S
		sta	zp_SRLOAD_bank			; bank
		leas	5,S

		rts



brkNotImplemented
		M_ERROR
		FCB	$FF, "Not implemented",0 

cmdSRLOAD	

	IF MACH_BEEB
		jsr	CheckBlitterPresentBrk
	ENDIF

		lda	#22
		jsr	OSWRCH
		lda	#7
		jsr	OSWRCH

		jsr	SkipSpacesX
		cmpa	#$D
		lbeq	brkBadCommand			; no filename!

		stx	ADDR_ERRBUF			; store pointer to filename
1		lda	,X+
		cmpa	#' '
		lblt	brkBadId			; < ' ' means end of command no id!
		bne	1B
		lda	#$D
							; TODO: don't write back to command line!
		sta	-1,X				; overwrite ' ' with $D to terminate filename
		jsr	SkipSpacesX

		jsr	ParseHex
		lbcs	brkBadId
		jsr	CheckId
		sta	zp_SRLOAD_dest			; dest id

		jsr	ParseIX01Flags

		jsr	PrintImmed
		FCB	"Loading ROM...",13,0

		; setup OSFILE block to point at $FFFF4000 and load there
		clr	ADDR_ERRBUF + 6			; clear exec address low byte (use my address)
		lda	#SRLOAD_buffer_page
		sta	ADDR_ERRBUF + 4
		clr	ADDR_ERRBUF + 5
		lda	#$FF
		sta	ADDR_ERRBUF + 2
		sta	ADDR_ERRBUF + 3
		ldx	#ADDR_ERRBUF
		jsr	OSFILE				; load file

		jsr	PrintImmed
		FCB	"Writing",0

		; now copy to flash/sram
		jsr	romWriteInit			

  		clra
  		ldb	zp_SRLOAD_dest
  		tfr	D,Y				; Y is the ROM #
  		ldx	zp_mos_genPTR
  		ldu 	#SRLOAD_buffer_page*256

 		pshs	CC
 		SEI

		jsr	Flash_SRLOAD  

		puls	CC,PC

	IF MACH_BEEB

cmdBLTurboQry
		pshs	X				; preserve command ptr
		ldx	#strCmdBLTurbo
		jsr	PrintX				; "BLTURBO"
		jsr	PrintSpc
		; lomem
		lda	#'L'				; "Lxx"
		jsr	OSWRCH
		lda	sheila_MEM_LOMEMTURBO
		jsr	PrintHexA
		jsr	PrintSpc
		; mos
		lda	#'M'				; "M[-]"
		jsr	OSWRCH
		lda	sheila_ROMCTL_MOS
		anda	#BITS_MEM_CTL_SWMOS
		cmpa	#BITS_MEM_CTL_SWMOS
		beq	1F
		lda	#'-'
		jsr	OSWRCH
1		jsr	PrintSpc
		; throttle
		lda	#'T'
		jsr	OSWRCH
		lda	sheila_MEM_TURBO2
		bmi	1F
		lda	#'-'
		jsr	OSWRCH
1		jsr	OSNEWL
		puls	X				; restore command pointer
		jmp	cmdBLTurbo_Next


cmdBLTurboEnd
		rts


tblBLTurboCMD	FCB	"T"
		FDB	cmdBLTurboThrottle
		FCB	"M"
		FDB	cmdBLTurboMos
		FCB	"R"
		FDB	cmdBLTurboRom
		FCB	"L"
		FDB	cmdBLTurboLo
		FCB	"?"
		FDB	cmdBLTurboQry
		FCB	13
		FDB	cmdBLTurboEnd
		FCB	0


cmdBLTurbo	jsr	CheckBlitterPresentBrk
cmdBLTurbo_Next	jsr	SkipSpacesX
		leax	1,X
		ldy	#tblBLTurboCMD
1		tst	,Y
		beq	cmdBLTurboEnd		
		jsr	ToUpper
		cmpa	,Y+
		beq	2F
		leay	2,Y
		bra	1B
		jmp	brkBadCommand
2		jmp	[0,Y]

cmdBLTurboThrottle
		jsr	SkipSpacesX
		cmpa	#'-'
		beq	1F
		lda	sheila_MEM_TURBO2
		ora	#BITS_MEM_TURBO2_THROTTLE
		bra	2F
1		leax	1,X
		lda	sheila_MEM_TURBO2
		anda	#BITS_MEM_TURBO2_THROTTLE ^ $FF
2		sta	sheila_MEM_TURBO2
		bra	cmdBLTurbo_Next

cmdBLTurboMos_OSW
		FCB	4	; in len
		FCB	5	; out len
		FCB	8	; rom #
		FCB	OSWORD_BLTUTIL_FLAG_CURRENT

cmdBLTurboMos
		jsr	SkipSpacesX
		cmpa	#'-'
		beq	cmdBLTurboMos_off

		pshs	CC,X,Y,U			; preserve command pointer and interrupts

		; check to find the ROM slot to use
		; TODO, read this from table?
		leas	-5,S
		ldx	#cmdBLTurboMos_OSW
		ldb	#3
1		lda	B,X
		sta	B,S
		decb
		bpl	1B
		leax	,S				; OSWORD block on stack
		lda	#OSWORD_BLTUTIL
		jsr	OSWORD

		lda	2,S
		sta	zp_blturbo_fl
		ldd	3,S
		std	zp_blturbo_ptr
		leas	5,S

		lda	#OSWORD_BLTUTIL_RET_MAP1
		anda	zp_blturbo_fl
		bne	cmdBLTurbo_MOSWarnAlready

		; This is map one, the MOS is already from a fast chip
		lda	#OSWORD_BLTUTIL_RET_FLASH|OSWORD_BLTUTIL_RET_SYS
		anda	zp_blturbo_fl
		bne	cmdBLTurbo_MOSBadSlot

		lda	#OSWORD_BLTUTIL_RET_MEMI
		anda	zp_blturbo_fl
		beq	1F
		jmp	cmdBLTurbo_MOSInhib
1
		; check to see if rom #8 is booted
		lda	oswksp_ROMTYPE_TAB+8
		beq	1F
		jmp	cmdBLTurbo_MOSSlotBusy
1

		; copy mos rom from FFCxxx to 7F0xxx
		ldx	#$FFC0
		ldy	zp_blturbo_ptr
		clrb

1		ldu	#JIM
2		; copy mos to SWROM slot 8
		stx	fred_JIM_PAGE_HI
		lda	,U
		sty	fred_JIM_PAGE_HI
		sta	,U+
		incb
		bne	2B
		leay	1,Y
		leax	1,X
		beq	3F
		cmpx	#$FFFC				; skip hardware pages		
		bne	1B
		; skip pages FC-FE
		leax	3,X
		leay	3,Y
		bra	1B
3
		orcc	#CC_I|CC_F
		lda	sheila_ROMCTL_MOS
		ora	#BITS_MEM_CTL_SWMOS		; start shadow mos
		sta	sheila_ROMCTL_MOS	
		bne	cmdBLTurbo_NextMOS	

cmdBLTurboMos_off
		leax	1,X				; skip over '-'
		pshs	CC,X,Y,U
		orcc	#CC_I|CC_F
		lda	sheila_MEM_CTL
		anda	#(~BITS_MEM_CTL_SWMOS) & $FF
		sta	sheila_MEM_CTL
cmdBLTurbo_NextMOS
		puls	CC,X,Y,U
		jmp	cmdBLTurbo_Next
cmdBLTurbo_MOSWarnAlready
		ldx	#str_BLTURBOMOS_ALREADY
		jsr	PrintX
		jmp	cmdBLTurbo_NextMOS
cmdBLTurbo_MOSBadSlot
		M_ERROR
		FCB	$FF, "Slot 8 is not RAM or is in use",0
cmdBLTurbo_MOSInhib
		M_ERROR
		FCB	$FF, "Blitter inhibited",0
cmdBLTurbo_MOSSlotBusy
		M_ERROR
		FCB	$FF, "Slot #8 is in use cannot BLTURBO MOS",0

cmdBLTurboRom
		rts


cmdBLTurboLo	
		jsr	ParseHex		
		lbcs	brkInvalidArgument

		pshs	CC				; save interrupt status
		ORCC	#CC_I+CC_F			; disable interrupts as memory is going to move
		
		jsr	jimSetDEV_blitter

		lda	zp_trans_acc+3
		sta	zp_blturbo_new			; save the new mask 
		pshs	A,X				; save new mask and text pointer
		lda	sheila_MEM_LOMEMTURBO
		sta	zp_blturbo_old			; get the old mask and store in the old zp

		clr	fred_JIM_PAGE_LO
		clr	fred_JIM_PAGE_HI		; point at bottom of chip ram

_l1		
		; compare flags in old/new:
		; - if old = 1 and new = 0 then copy from JIM to SYS else 
		; - if old = 0 and new = 1 then copy from SYS to JIM else
		; - do nowt

		ldy	#$10				; preload number of pages
		clrb					; b is used as the intra page counter


		ror	zp_blturbo_new
		bcc	_new_not_turbo
		; new is turbo, check old
		ror	zp_blturbo_old
		bcs	_donowt
		; new is turbo, old is not, copy SYS to JIM

_s2jl_pag	ldx	#JIM
_s2jl		dec	fred_JIM_PAGE_HI		; switch to SYS ($FF)
		lda	,X				; read from SYS
		inc	fred_JIM_PAGE_HI		; back to chip bank 0
		sta	,X+				; write to shadow
		incb
		bne	_s2jl
		inc	fred_JIM_PAGE_LO		; incremenet page
		leay	-1,Y
		bne	_s2jl_pag
		beq	_snext				; copy done

_new_not_turbo
		ror	zp_blturbo_old
		bcc	_donowt
		; new is SYS, old is not, copy JIM to SYS
_j2sl2_pag	ldx	#JIM	
_j2sl		lda	,X				; read from shadow
		dec	fred_JIM_PAGE_HI
		sta	,X+				; write to sys
		inc	fred_JIM_PAGE_HI		; back to chipram for next go round
		incb
		bne	_j2sl
		inc	fred_JIM_PAGE_LO		; incremenet page
		leay	-1,Y	
		bne	_j2sl2_pag
		beq	_snext				; copy done

_donowt		lda	fred_JIM_PAGE_LO
		adda	#$10
		sta	fred_JIM_PAGE_LO
_snext		lda	fred_JIM_PAGE_LO
		bpl	_l1



		puls	A,X				; get back new mask and text pointer
		sta	sheila_MEM_LOMEMTURBO		; switch to new map
		puls	CC				; restore interrupts

		jmp	cmdBLTurbo_Next

	ENDIF

; these flags match those into OSWORD 99
CMDROMS_FLAGS_CURRENT		EQU	$80			; when set show current/alternate set, when clear bit 0 indicates which map
CMDROMS_FLAGS_ALTERNATE		EQU	$40			; when set show alternate roms
CMDROMS_FLAGS_IGNOREMEMI	EQU	$20			; ignore memi
CMDROMS_FLAGS_MAP1		EQU	$01
CMDROMS_FLMASK			EQU	$E1			; used to map out non OSWORD 99 flags

CMDROMS_FLAGS_VERBOSE		EQU	$08
CMDROMS_FLAGS_CRC		EQU	$04
CMDROMS_FLAGS_ALL		EQU	$02

		;	FLAG	OR			AND
cmdRoms_tbl	FCB	'C',	CMDROMS_FLAGS_CRC,				$FF
		FCB	'V',	CMDROMS_FLAGS_VERBOSE,				$FF
		FCB	'A',	CMDROMS_FLAGS_ALL,				$FF
		FCB	'X',	CMDROMS_FLAGS_CURRENT|CMDROMS_FLAGS_ALTERNATE,	~CMDROMS_FLAGS_MAP1
		FCB	'0',	0						,~(CMDROMS_FLAGS_MAP1|CMDROMS_FLAGS_CURRENT|CMDROMS_FLAGS_ALTERNATE)
		FCB	'1',	CMDROMS_FLAGS_MAP1				,~(CMDROMS_FLAGS_MAP1|CMDROMS_FLAGS_CURRENT|CMDROMS_FLAGS_ALTERNATE)
		FCB	'I',	CMDROMS_FLAGS_IGNOREMEMI			,$FF
		FCB	0


cmdRomsCopyAddr	ldx	zp_mos_genPTR+0
		leax	7,X
		jsr	cmdRoms_ReadRom2
		tfr	A,B
		lda	zp_mos_genPTR+0
		tfr	D,X
		rts


cmdRoms		ldb	#CMDROMS_FLAGS_CURRENT
cmdRomsNextArg
		jsr	SkipSpacesX
		cmpa	#13
		beq	cmdRoms_Go
		leax	1,X
		cmpa 	#'-'				; ignore '-'
		beq 	cmdRomsNextArg	
		jsr	ToUpper
		ldu	#cmdRoms_tbl
1		tst	0,U
		lbeq	brkInvalidArgument
		cmpa	0,U
		bne 	2F
		andb	2,U
		orb	1,U
		bra	cmdRomsNextArg
2		leau	3,U
		bra	1B


cmdRoms_Go
		stb	zp_ROMS_flags
		
1		ldx	#strRomsHeadVer			; vecbose headings		
		jsr	PrintX

		clr	zp_ROMS_ctr
cmdRoms_lp	jsr	Print2Spc
		lda	zp_ROMS_ctr
		jsr	PrintHexNybA			; rom #
		jsr	Print2Spc

		clra
		ldb	zp_ROMS_ctr
		tfr	D,Y				; Y now contains ROM# for OSRDRM

		; get rom base using OSWORD 99
		clr	,-S

		lda	zp_ROMS_flags
		anda	#CMDROMS_FLMASK			; mask out flags we want to pass in here
		sta	,-S
		lda	zp_ROMS_ctr
		sta	,-S
		lda	#5				; OSWORD return len
		sta	,-S
		lda	#4				; OSWORD in len
		sta	,-S
		leax	,S
		lda	#OSWORD_BLTUTIL		
		jsr	OSWORD

		lda	4,S
		sta	zp_ROMS_bank
		lda	3,S
		sta	zp_mos_genPTR+0			; pointer high byte
		clr	zp_mos_genPTR+1
		lda	2,S
		sta	zp_ROMS_OS99ret			; OSWORD 99 return flags

		leas	5,S				; reset stack

		bita	#OSWORD_BLTUTIL_RET_ISCUR	; is this the "current" map
		bne	1F	

		; not current map, skip "act" column
		lda	#'-'
		jsr	PrintA
		jsr	PrintA
		jsr	PrintSpc
		bra	cmdRoms_fullcheck		; and look for copyright

		; print "active" rom type from OS table
1		lda	oswksp_ROMTYPE_TAB,Y		; get direct from MOS rom table, don't bother with official OSBYTE
		jsr	PrintHexA
		jsr	PrintSpc

		lda	oswksp_ROMTYPE_TAB,Y		; get direct from MOS rom table, don't bother with official OSBYTE
		bne	cmdRoms_checkedOStab


		lda	zp_ROMS_flags
		bita	#CMDROMS_FLAGS_ALL
		bne	cmdRoms_fullcheck
		bra	cmdRoms_sk_notrom

cmdRoms_checkedOStab
		jsr	cmdRoms_DoCRC

		jsr	cmdRomsCopyAddr
		stx	zp_ROMS_copyptr

		; tis a ROM, print type
		ldx 	zp_mos_genPTR
		leax	6,X
		jsr	cmdRoms_ReadRom2

		jsr	PrintHexA
		jsr	Print2Spc

		leax	2,X		

		; print version
		jsr	cmdRoms_ReadRom2
		jsr	PrintHexA
		jsr	PrintSpc

		leax	1,X

		; print title / all strings
		lda	zp_ROMS_flags
		bita	#CMDROMS_FLAGS_VERBOSE
		beq	cmdRoms_NoVer

1		jsr	cmdRoms_PrintX			; print title and optional version str
		jsr	PrintSpc
		cmpx	zp_ROMS_copyptr
		blo	1B

cmdRoms_NoVer	jsr	cmdRoms_PrintX			; print copyright string
		bra	cmdRoms_sk_nextrom

cmdRoms_fullcheck
		; if this is SYS and not the current map then skip with SYS message
		lda	zp_ROMS_OS99ret
		anda 	#OSWORD_BLTUTIL_RET_SYS|OSWORD_BLTUTIL_RET_ISCUR
		cmpa 	#OSWORD_BLTUTIL_RET_SYS
		bne	roms_notsys1

1		ldx	#str_SYS
		jsr	PrintX
		jmp	cmdRoms_sk_nextrom

roms_notsys1
		; check for (C) symbol, if not present skip this rom
		jsr	cmdRomsCopyAddr
		ldb	#4
		ldu	#Copyright
1		jsr 	cmdRoms_ReadRom2
		cmpa	,U+
		bne	cmdRoms_sk_notrom
		leax	1,X
		decb
		bne	1B
		bra	cmdRoms_checkedOStab


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

cmdRoms_DoCRC
		lda	#CMDROMS_FLAGS_CRC
		bita	zp_ROMS_flags		
		beq	cmdRoms_skipCRC
		ldb	#$40				; # of pages
		stb	,-S
		ldx	zp_mos_genPTR+0		
		clrb					; intra page counter
		clr	zp_trans_acc
		clr	zp_trans_acc+1
		leax	-1,X
1		leax	1,X
		jsr	cmdRoms_ReadRom2
		jsr	crc16
		decb
		bne	1B
		jsr	CheckESC
		dec	,S
		bne	1B
		leas	1,S
		ldx	zp_trans_acc
		jsr	PrintHexX
		jmp	Print2Spc


cmdRoms_skipCRC
		jsr	Print2Spc
		jsr	Print2Spc
		jmp	Print2Spc


cmdRoms_PrintX
1		jsr	cmdRoms_ReadRom2
		leax	1,X
		tsta
		beq	2F
		cmpa	#' '
		blo	1B				; skip CR/LF in BASIC (C)
		jsr	PrintA
		bra	1B
2		rts


		; this is not copied to trampoline but accessed in this rom
cmdRoms_ReadRom2
		pshs	B,X
		lda	zp_ROMS_bank
		cmpa	#$FF
		bne	cmdRoms_ReadRom2_JIM
		jsr	OSRDRM
		puls	B,X,PC
cmdRoms_ReadRom2_JIM
		sta	fred_JIM_PAGE_HI		
		tfr	X,D
		sta	fred_JIM_PAGE_LO	
		lda	#JIM/256
		tfr	D,X	
		lda	,X		
		puls	B,X,PC


brkBadCommand	M_ERROR
		FCB	$FE, "Bad Command", 0

ERASE_FLAG_FORCE	EQU $02


cmdSRERASE
		jsr	CheckBlitterPresentBrk

		clr	zp_ERASE_flags

		jsr	ParseHex
		lbcs	brkBadId
		jsr	CheckId
		sta	zp_ERASE_dest			; dest id

		jsr	SkipSpacesX
		jsr	ToUpper
		cmpa	#'F'
		bne	1F
		leax	1,X
		lda	#ERASE_FLAG_FORCE
		sta	zp_ERASE_flags
1		lda	zp_ERASE_flags
		sta	,-S
		jsr	ParseIX01Flags
		lda	zp_ERASE_flags
		ora	,S+
		sta	zp_ERASE_flags

  		clra
  		ldb	zp_SRLOAD_dest
  		tfr	D,Y				; Y is the ROM #

		lda	zp_ERASE_flags
		bita	#OSWORD_BLTUTIL_RET_FLASH
		beq	cmdSRERASE_RAM

		ldx	#strSRERASEFLASH
		lda	zp_ERASE_dest
		jsr	PrintMsgThenHexNyb

  		ldx	zp_mos_genPTR
		jsr	romWriteInit
		jmp	FlashEraseROM

cmdSRERASE_RAM	
		ldx	#strSRERASERAM
		lda	zp_ERASE_dest
		jsr	PrintMsgThenHexNyb


  		ldx	zp_mos_genPTR

		clr	zp_ERASE_errct
		clr	zp_ERASE_errct+1
		ldu	#$4000				; loop counter

		jsr	romWriteInit

1		lda	#$FF
		CLC
		jsr	romWrite
		jsr	romRead
		cmpa	#$FF
		bne	2F
3		leax	1,X
		leau	-1,U
		cmpu	#0
		bne	1B
		ldx	zp_ERASE_errct
		bne	4F
		ldx	#str_OK
		jmp	PrintX
4		; got to end with errors
		lda	#'&'
		jsr	PrintA
		jsr	PrintHexX
		ldx	#strErrsDet
		jmp	PrintX
2		inc	zp_ERASE_errct+1
		bne	5F
		inc	zp_ERASE_errct
5		lda	zp_ERASE_flags
		bita	#ERASE_FLAG_FORCE
		bne	3B
		stx	,--S
		ldx	#str_FailedAt
		jsr	PrintX
		ldx	,S++
		lda	zp_SRLOAD_bank
		jsr	PrintHexA
		jsr	PrintHexX
		jmp	brkEraseFailed

cmdSRCOPY	
		jmp brkNotImplemented
;;;		jsr	FlashUtilsInit			; initialise the ROM writer - any error will trash this!
;;;
;;;		jsr	ParseHex
;;;		lbcs	brkBadId
;;;		jsr	CheckId
;;;		sta	zp_SRCOPY_dest			; dest id
;;;		jsr	ParseHex
;;;		lbcs	brkBadId
;;;		jsr	CheckId
;;;		sta	zp_SRCOPY_src			; src id
;;;		jsr	SkipSpacesX
;;;		cmpa	#$D
;;;		lbne	brkBadCommand
;;;
;;;		lda	zp_SRCOPY_dest
;;;		cmpa	zp_SRCOPY_src
;;;		lbeq	brkBadCommand			; don't copy to self
;;;
;;;		clr	zp_SRCOPY_flags
;;;		; check to see if dest is ROM (4-7)
;;;		jsr	IsFlashBank
;;;		bne	cmdSRCOPY_init_RAM		; ram in odd banks
;;;		dec	zp_SRCOPY_flags
;;;
;;;		ldx	#strSRCOPY2FLASH
;;;		lda	zp_SRCOPY_dest
;;;		jsr	PrintMsgThenHexNyb
;;;
;;;		clra
;;;		ldb	zp_SRCOPY_dest
;;;		tfr	D,Y				; rom #
;;;
;;;		jsr	FlashReset			; in case we're in software ID mode
;;;		jsr	FlashEraseROM
;;;		bra	cmdSRCOPY_go
;;;
;;;cmdSRCOPY_init_RAM
;;;		ldx	#strSRCOPY2RAM
;;;		lda	zp_SRCOPY_dest
;;;		jsr	PrintMsgThenHexNyb
;;;
;;;cmdSRCOPY_go
;;;		ldx	#str_Copying
;;;		jsr	PrintX
;;;		ldx	#$8000
;;;		ldb	zp_SRCOPY_src
;;;		clra
;;;		std	zp_trans_acc
;;;		ldb	zp_SRCOPY_dest
;;;		clra
;;;		std	zp_trans_acc + 2
;;;
;;;cmdSRCOPY_go_lp
;;;		ldy	zp_trans_acc			; src ROM #
;;;		jsr	OSRDRM
;;;		ldy	zp_trans_acc + 2		; dest ROM #
;;;		pshs	A				; save A for later
;;;		tst	zp_SRCOPY_flags
;;;		bpl	1F				; not EEPROM, just write to ROM
;;;		; flash write byte command
;;;		jsr	FlashWriteByte
;;;		bra	2F
;;;1		sta	,X
;;;		lda	,X
;;;2		cmpa	,S+
;;;		bne	cmdSRCOPY_verfail
;;;
;;;		leax	1,X
;;;		cmpx	#$C000
;;;		bne	cmdSRCOPY_go_lp
;;;		ldx	#str_OK
;;;		jmp	PrintX
;;;
;;;cmdSRCOPY_verfail
;;;		jsr	PrintHexX
;;;		jsr	PrintNL
;;;		M_ERROR
;;;		FCB	$81, "Verify fail", 0


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

		jmp	cmdSRNUKE

cmdSRNUKE_menu
		fcb	13, "0) Exit 1) Erase Flash 2) Erase RAM 3) CRC 4) Erase # 5) NoIce on 6) NoIce BRK", 13, 0


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

		jsr	cmdSRNUKE
		lbra	cmdSRNUKE_reboot


cmdSRNUKE	jmp	brkNotImplemented
;;;		; cmdRoms no VA
;;;		ldb	#CMDROMS_FLAGS_VERBOSE+CMDROMS_FLAGS_ALL
;;;		stb	ZP_NUKE_ROMSF
;;;
;;;cmdSRNUKE_mainloop
;;;		ldb	ZP_NUKE_ROMSF
;;;		jsr	cmdRoms_Go
;;;		
;;;		; SHOW MENU
;;;		ldx	#cmdSRNUKE_menu
;;;		jsr	PrintX
;;;
;;;1		jsr	inkey_clear
;;;		bcs	1B
;;;		cmpb	#'0'
;;;		lbeq	cmdSRNUKE_exit
;;;		cmpb	#'1'
;;;		beq	cmdSRNUKE_flash
;;;		cmpb	#'2'
;;;		lbeq	cmdSRNUKE_ram
;;;		cmpb	#'3'
;;;		beq	cmdSRNUKE_crctoggle
;;;		cmpb	#'4'
;;;		beq	cmdSRNUKE_erase_rom
;;;		cmpb	#'5'
;;;		beq	cmdSRNUKE_NOICE_on
;;;		cmpb	#'6'
;;;		beq	cmdSRNUKE_NOICE_brk
;;;		bra	1B
;;;
;;;
;;;cmdSRNUKE_NOICE_on
;;;		jsr	cmdNOICE_on
;;;		bra	cmdSRNUKE_mainloop
;;;
;;;cmdSRNUKE_NOICE_brk
;;;		ldx	#str_NoiceEnter
;;;		jsr	PrintX
;;;		jsr	cmdNOICE_brk
;;;		bra	cmdSRNUKE_mainloop
;;;
;;;cmdSRNUKE_crctoggle
;;;		ldb	ZP_NUKE_ROMSF
;;;		eorb	#CMDROMS_FLAGS_CRC
;;;		stb	ZP_NUKE_ROMSF
;;;		bra	cmdSRNUKE_mainloop
;;;
;;;cmdSRNUKE_erase_rom
;;;		ldx	#str_WhichRom
;;;		jsr	PrintX
;;;		jsr	inkey_clear
;;;		tfr	B,A
;;;		jsr	OSASCI
;;;		jsr	OSNEWL
;;;		bcs	cmdSRNUKE_mainloop
;;;		ldx	#STR_NUKE_CMD			; enter the keyed number as a phoney param to cmdSRERASE
;;;		stb	0,X
;;;		ldb	#13
;;;		stb	1,X
;;;		jsr	cmdSRERASE
;;;		bra	cmdSRNUKE_mainloop
;;;
;;;
;;;cmdSRNUKE_flash
;;;		ldx	#str_NukePrAllFl
;;;		jsr	PromptYN
;;;		bne	cmdSRNUKE_mainloop
;;;
;;;		ldx	#str_NukeFl
;;;		jsr	PrintX
;;;
;;;		; erase entire flash chip
;;;		jsr	FlashReset
;;;		jsr	FlashEraseComplete
cmdSRNUKE_reboot
		ORCC	#CC_I+CC_F
		jmp	[$F7FE]				; reboot - if we're running from flash we'll crash anyway!
;;;
;;;
;;;cmdSRNUKE_ram	ldx	#str_NukePrAllRa
;;;		jsr	PromptYN
;;;		lbne	cmdSRNUKE_mainloop
;;;
;;;		ldx	#str_NukeRa
;;;		jsr	PrintX
;;;
;;;		; enable JIM, setup paging regs
;;;		lda	sheila_ROMCTL_MOS
;;;		pshs	A
;;;;;TODO:new dev sel		ora	#BITS_MEM_CTL_JIMEN
;;;		sta	sheila_ROMCTL_MOS
;;;
;;;		lda	#$0E
;;;		sta	fred_JIM_PAGE_HI
;;;		clra	
;;;		sta	fred_JIM_PAGE_LO
;;;
;;;		; copy ram nuke routine to ADDR_ERRBUF and execute from there
;;;		ldx	#cmdSRNuke_RAM
;;;		ldu	#ADDR_ERRBUF
;;;		ldb	#cmdSRNuke_RAM_end - cmdSRNuke_RAM
;;;1		lda	,X+				; copy the routine to ram buffer as we are likely to get zapped
;;;		sta	,U+
;;;		decb
;;;		bne	1B
;;;		lda	#$FF
;;;		jmp	ADDR_ERRBUF
;;;
;;;cmdSRNuke_RAM	
;;;2		ldx	#JIM
;;;1		sta	,X+
;;;		cmpx	#JIM+$100
;;;		bne	1B
;;;		inc	fred_JIM_PAGE_LO
;;;		bne	2B
;;;		inc	fred_JIM_PAGE_HI
;;;		ldb	fred_JIM_PAGE_HI
;;;		cmpb	#$10
;;;		bne	2B
;;;		ORCC	#CC_I+CC_F
;;;		jmp	[$F7FE]				; reboot - if we're running from flash we'll crash anyway!
;;;cmdSRNuke_RAM_end
;;;
;;;cmdSRNUKE_exit	rts



IsFlashBank
		; rom id in A, returns EQ if this is a Flash Bank, do NOT rely 
		; on value returned in A!
		; if this is an IC slot returs MI
		cmpa	#$3
		bls	1F
		cmpa	#$9
		blo	2F				; treat SYStem sockets (4..7) as RAM (they might be?!)
1		coma
		anda	#1
		rts		
2		lda	#$FF
		rts


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


cmdXMdump
	; Adapted from Source for *MDUMP by J.G.Harston

 		pshs	X

 		; DB - use vduvars to divine width of window (TODO: do this legally, do this in 6502?)
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
		; switch to DEV if specified
		jsr	SkipSpacesX
		cmpa	#'#'
		bne	mdump_skip_dev
		leax	1,X
		jsr	ParseHex
		lbcs	brkInvalidArgument
		lda	zp_trans_acc+3
		sta	zp_mos_jimdevsave
		sta	fred_JIM_DEVNO

mdump_skip_dev

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
		clra
		clrb
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

mdump_getbytes	pshs	D,X,Y,U
		; this is simplified to just get ChipRAM for now

		stb	,-S				; loop counter on stack
		ldy	zp_mdump_addr + 1		; phys address
		sty	fred_JIM_PAGE_HI
		ldb	zp_mdump_addr + 3		; intra page pointer (used for wrap)
		lda	#JIM/256
		tfr	D,U

1		lda	,U+
		sta	,X+
		incb
		bne	2F
		lda	#JIM/256
		tfr	D,U
		leay	1,Y
		sty	fred_JIM_PAGE_HI
2		dec	,S
		bne	1B
		leas	1,S

		puls	D,X,Y,U,PC

mdump_prspace3	jsr	mdump_prspace
		jsr	mdump_prspace
mdump_prspace	pshs	A
		lda	#' '
		jsr	OSWRCH
		puls	A,PC




		include "bltutil_utils.asm"
		include "bltutil_cfg.asm"
		include "bltutil_flashutils.asm"
	IF MACH_BEEB
		include "bltutil_jimstuff.asm"
		include "bltutil_heap.asm"	
		include "bltutil_sound.asm"
	ENDIF

brkInvalidArgument
		M_ERROR
		fcb	$7F, "Invalid Argument", 0


;------------------------------------------------------------------------------
; Strings and tables
;------------------------------------------------------------------------------


str_WhichRom	FCB	"Erase Which Rom", 0

strRomsHeadVer	FCB	"  # act  crc typ ver Title", 13
		FCB	" == === ==== === === =====", 13, 0 

strRomsHead	FCB	"  # typ ver Title", 13
		FCB	" == === === =====", 13, 0 

strNoRom	FCB	"--",0
str_SYS		FCB	"-- SYS ",0

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
str_BLTURBOMOS_ALREADY
		FCB	"Map 1, MOS is already turbo",13,10,0
	ENDIF

	IF MACH_BEEB|MACH_CHIPKIT

str_NoiceDeb	FCB	"NoIce debugging ",0
str_on		FCB	"on",0
str_off		FCB	"off",0
str_NoiceEnter	FCB	"NoIce enter...",13,0
	ENDIF

	IF MACH_BEEB
		include	"bltutil_vnula.asm"
	ENDIF

	IF MACH_BEEB|MACH_CHIPKIT
		include "bltutil_noice.asm"
	ENDIF

