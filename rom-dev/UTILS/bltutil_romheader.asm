		FCB	0,0,0				; language entry
		jmp	Service				; service entry
		FCB	$83				; not a language, 6809 code
		FCB	Copyright-$8000
		VERSION_BYTE	
utils_name
		VERSION_NAME
		FCB	0
utils_ver
		VERSION_STRING
		FCB	" ("
		VERSION_DATE
		FCB	")"
Copyright
		FCB	0
	IF MACH_CHIPKIT | MACH_SBC09
		FCB	"(C)2023 Dossytronics",0
	ELSE
		FCB	"(C)2023 Dossytronics+Rob Coleman",0
	ENDIF

str_Dossy	FCB	"Dossytronics",0

;* ---------------- 
;* SERVICE ROUTINES
;* ----------------
	;TODO make this relative!
Serv_jump_table
		SJTE	$01, svc1_ClaimAbs
		SJTE	$04, svc4_COMMAND
	IF MACH_BEEB
		SJTE	$05, svc5_UKIRQ
		SJTE	$08, svc8_OSWORD
	ENDIF
		SJTE	$09, svc9_HELP
		FCB	0

Service
	IF MACH_BEEB
		CLAIMDEV
	ENDIF

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
* - We don't need abs workspace but we do want to check for £ key to enter
*   SRNUKE

svc1_ClaimAbs
		pshs	D,X,Y,U

		; check to see if we are current language and put back 
		; original
		lda	sysvar_CUR_LANG
		cmpa	zp_mos_curROM
		bne	1F
		lda	ZP_NUKE_PREVLANG
		sta	sysvar_CUR_LANG
1

	IF MACH_BEEB
		jsr	CheckBlitterPresent
		bcs	2F
	ENDIF
;; DB: removed to not trample workspace!
;;		; belt and braces write $f0 to flash to clear soft id mode
;;		;TODO: this will corrupt main memory!
;;		jsr	romWriteInit
;;		jsr	FlashReset

	IF MACH_BEEB | MACH_CHIPKIT
		; detect NoICE and check we're in ROM#F
		lda	zp_mos_curROM
		cmpa	#$0F
		bne	1F
		; this assumes if bit 3 of FE32 is set we want NoIce

		lda	#BITS_MEM_CTL_SWMOS_DEBUG_EN
		bita	sheila_ROMCTL_MOS
		beq	1F

		jsr	NoIceUtils_Init

	ENDIF

1		lda	#$79
		ldy	#0
		ldx	#$A8
		jsr	OSBYTE				; check if _/£ key down
		tfr	X,D
		tstb
		bpl	2F

		jsr	cmdSRNUKE_lang
		lbra	cmdSRNUKE_reboot

2	
		jsr	cfgPrintVersionBoot
		bcs	1F
		jsr	OSNEWL

	IF MACH_BEEB
		jsr	heap_init
		jsr	sound_boot
		jsr 	vnula_reset			; TODO on "master" do different for shadowed fonts?
	ENDIF


1		puls	D,X,Y,U,PC


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
		; TODO: Check - this doesn't look right it thinks a space is end? should be blo?
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

svc9_helptable	jsr	svc9_HELP_showbanner

		; got a match, dump out our commands help
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
		jsr	svc9_HELP_showbanner
svc9_HELP_exit	puls	D,X,Y,PC

svc9_HELP_showbanner
		jsr	PrintNL
		ldx	#utils_name
		jsr	PrintX
		jsr	PrintSpc
		ldx	#utils_ver
		jsr	PrintX
		jsr	PrintNL
		lda	#' '
		jsr	PrintA
		jsr	PrintA
		ldx	#str_HELP_KEY
		jsr	PrintX
		jmp	PrintNL
	

* --------------------
* SERVICE 4 - *COMMAND
* --------------------


svc4_COMMAND	; scan command table for commands
		pshs	D,X,Y,U
		ldu	#tbl_commands
cmd_loop	ldx	2,S				; reload X
		jsr	SkipSpacesX
		ldy	0,U				; point to cmd name
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
svc4_CMD_exit	puls	D,X,Y,U,PC		


	IF MACH_BEEB
* --------------------
* SERVICE 5 - UkIRQ
* --------------------

		; svc5_UKIRQ is used to intercept unrecognised interrupts

svc5_UKIRQ
		; check to see if this is a sound tick
		lda	sheila_USRVIA_ifr
		bita	#VIA_IFR_BIT_T1
		lbne	sound_irq		
1		rts

* --------------------
* SERVICE 8 - OSWORD
* --------------------

;		A = $99
;	XY?0 <16 - Get SWROM base address
;	---------------------------------
;	On Entry:
;		XY?0 	= Rom #
;		XY?1	= flags: (combination of)
;			$80	= current set
;			$C0	= alternate set
;			$20	= ignore memi (ignore inhibit)
;			$01	= map 1 (map 0 if unset)
;		XY?2	?
;	On Exit:
;		XY?0	= return flags
;			$80	= set if On board Flash
;			$40	= set if SYS
;			$20	= memi (swrom/ram inhibited)
;			$01	= map 1 (map 0 if not set)
;		XY?1	= rom base page lo ($80 if SYS)
;		XY?2	= rom base page hi ($FF if SYS)


svc8_OSWORD	lda	zp_mos_OSBW_A
		cmpa	#OSWORD_BLTUTIL		
		lbeq    	heap_OSWORD_bltutil
		cmpa	#OSWORD_SOUND
		lbeq	sound_OSWORD_SOUND
		
	ENDIF

;------------------------------------------------------------------------------
; Strings and tables
;------------------------------------------------------------------------------


tbl_commands	FDB	strCmdRoms, cmdRoms, helpRoms
		FDB	strCmdSRCOPY, cmdSRCOPY, strHelpSRCOPY
		FDB	strCmdSRERASE, cmdSRERASE, strHelpSRERASE
		FDB	strCmdSRNUKE, cmdSRNUKE, 0
		FDB	strCmdSRLOAD, cmdSRLOAD, strHelpSRLOAD
	IF MACH_BEEB
		FDB	strCmdVNVDU, cmdVNVDU, strHelpVNVDU
		FDB	strCmdVNRESET, cmdVNRESET, 0
	ENDIF
		FDB	strCmdXMDUMP, cmdXMdump, strHelpXMdump
	IF MACH_BEEB
		FDB	strCmdBLTurbo, cmdBLTurbo, strHelpBLTurbo
	ENDIF
	IF MACH_BEEB | MACH_CHIPKIT
		FDB	strCmdNOICE, cmdNOICE, strHelpNOICE
	ENDIF
	IF MACH_BEEB
		FDB	strCmdSound, cmdSound, strHelpSound	
		FDB	strCmdSoundSamLoad, cmdSoundSamLoad, strHelpSoundSamLoad
		FDB	strCmdSoundSamClear, cmdSoundSamClear, strHelpSoundSamClear	
		FDB	strCmdHeapInfo, cmdHeapInfo, strHelpHeapInfo	
		FDB	strCmdSoundSamMap, cmdSoundSamMap, strHelpSoundSamMap

		FDB	strCmdBLInfo, cmdInfo, 0
	ENDIF
		FDB	0

str_HELP_KEY	EQU 	utils_name

strCmdRoms		FCB	"ROMS", 0
helpRoms			FCB	"[V|VA]", 0
strCmdSRCOPY		FCB	"SRCOPY",0
strHelpSRCOPY		FCB	"<dest id> <src id>",0
strCmdSRNUKE		FCB	"SRNUKE",0
strCmdSRERASE		FCB	"SRERASE",0
strHelpSRERASE		FCB	"<dest id> [F]",0
strCmdSRLOAD		FCB	"SRLOAD", 0
strHelpSRLOAD		FCB	"<filename> <id>",0
	IF MACH_BEEB
strCmdVNVDU		FCB	"VNVDU",0
strHelpVNVDU		FCB	"ON|OFF",0
strCmdVNRESET		FCB	"VNRESET",0
	ENDIF
strCmdXMDUMP		FCB	"XMDUMP",0
strHelpXMdump		FCB	"[-8|-16] [#dev] <start> [<end>|+<length>]",0
	IF MACH_BEEB|MACH_CHIPKIT
strCmdNOICE		FCB	"NOICE",0
strHelpNOICE		FCB	"[ON|OFF|BRK]",0
	ENDIF
	IF MACH_BEEB
strCmdBLTurbo		FCB	"BLTURBO",0
strHelpBLTurbo		FCB	"[M[-]] [L<pagemask>] [?]",0
strCmdSound		FCB	"BLSOUND", 0
strHelpSound		FCB	"[ON|OFF|DETUNE]", 0
strCmdHeapInfo		FCB	"BLHINF",0
strHelpHeapInfo		FCB	"[V]",0
strCmdSoundSamLoad	FCB	"BLSAMLD",0
strHelpSoundSamLoad	FCB	"<filename> <SN> [reploffs]",0
strCmdSoundSamMap		FCB	"BLSAMMAP",0
strHelpSoundSamMap	FCB	"<CH> <SN>",0
strCmdSoundSamClear	FCB	"BLSAMCLR",0
strHelpSoundSamClear	FCB	"[SN|*]",0
strCmdBLInfo		FCB	"BLINFO",0
	ENDIF