;			(c) Dominic Beesley 2017 - translated and largely reworked from MMFS forked Aug 2017

			INCLUDE		"../../includes/common.inc"
			INCLUDE		"../../includes/mosrom.inc"
			INCLUDE		"../../includes/oslib.inc"
			INCLUDE		"../../includes/hardware.inc"

DEBUG			EQU	1
DEBUG_VERBOSE		EQU	1
LOADADDR		EQU 	0				; TUBE not applicable
COMPADDR		EQU	$8000

TUBE_CODE_QRY		EQU	$0406


************* DIRECT PAGE VARS LOCATIONS *****************************

DP_FST			EQU	$B0
DP_FS_RELWKSP		EQU	DP_FST+$0				; 2 byte pointer to private workspace
DP_FS_READNUM_ACC	EQU	DP_FST+$0

DP_FS_SAVEYAUTOBOOT	EQU	DP_FST+$3
DP_FS_TMP_PTR		EQU	DP_FST+$4				; 2 byte general pointer in ROMS
DP_FS_SC_PRINT_COLCT	EQU	DP_FST+$8
DP_FS_BRK_OFFS		EQU	DP_FST+$9				; 1 byte set to non 0 if printing to screen else offset from 0x100
DP_FS_CMD_NUM		EQU	DP_FST+$E

DP_FS_DISKTABLE_PTR	EQU	$B0					; 2byte  used when checking disks for name / flags in disk table catalogue
DP_FS_BCD_RESULT	EQU	$B5					; 2 byte BCD result from 
DP_FS_DISK_SECTOR_QRY	EQU	$B7					; disk "sector" in disk table
DP_FS_DISKNO		EQU	$B8					; 2 byte disk # 0..511

DP_VINC_DATA_PTR	EQU	$BC					; 2 byte memory pointer for data transfers
DP_VINC_SEK_ADDR	EQU	$BE					; 3 byte "sector" address i.e. SEK address / 256

DP_FSW			EQU	$C0
DP_FSW_DirectoryParam	EQU	DP_FSW+$C
DP_FSW_CurrentDrv	EQU	DP_FSW+$D
DP_FSW_FSP_STR		EQU	$C5

DP_B0_FILEV_PARAM_PTR	EQU	$B0
DP_BA_FILEV_FNAME_PTR	EQU	$BA
DP_BA_FILEV_DIR_ENT_PTR	EQU	$BA
DP_BC_FILEV_LOAD	EQU	$BC
DP_BE_FILEV_EXEC	EQU	$BE
DP_C0_FILEV_LEN		EQU	$C0
DP_C2_FILEV_MULTI	EQU	$C2
DP_C2_VINC_READ_SKIPSEC	EQU	$C2
DP_C3_FILEV_SECTOR	EQU	$C3

DP_C3_BYTES_LAST_SECTOR	EQU	$C3					; # of bytes to transfer from last sector
DP_CE_SECTOR_COUNT	EQU	$CE					; 2 byte (large files) sector transfer count

DP_FST_B0_GD_DSKTAB_PTR	EQU	$B0
DP_FST_B2_GD_DSK_SECTOR	EQU	$B2
DP_FST_B7_DCAT_GDOPT	EQU	$B7
DP_FST_B7_DCAT_DNO	EQU	$B8					; 2 bytes - current disk #
DP_TR_A8_DCAT_END	EQU	$A8					; 2 bytes - last disk number
DP_TR_AA_DCAT_COUNT	EQU	$AA					; 2 bytes - # of disks displayed in DCAT as a BCD #

DP_TR_ROMS_FLAGS	EQU	$A8			; used in ROMS command to store list type
DP_TR_ROMS_LPCTR	EQU	$AA			; loop counter used to count through ROMS
DP_TR_ROMS_STRPTR	EQU	$AB			; 2 byte string pointer (GSINIT/GSREAD)
DP_TR_ROMS_COPYPTR	EQU	$AE			; 1 byte copyright offset
DP_TR_ROMS_SAV		EQU	$AE			; save a byte (overlaps COPYPTR)

DP_TR_CAT_A8_COL	EQU	$A8
DP_TR_CAT_AA_PRDIR	EQU	$AA
DP_TR_CAT_AB_FPTR	EQU	$AB

FILE_SYS_NO		EQU	$04			; Filing System Number
FILEHANDLE_MIN		EQU	$50			; First File Handle - 1, must NOT have bit 3 set
TUBE_ID			EQU	$0A			; See Tube Application Note No.004 Page 7


*************** OFFSET CONSTANTS *************************************

MA			EQU	0				; memory base for workspaces (0 for beeb, might need changed when saving to other banks)
MP			EQU	MA/256				; memory base PAGE for workspaces as above

offs_ForceReset		EQU	$D3				; flag whether a full reset is needed
offs_PriWkspFull	EQU	$D4				; flag whether private workspace is in use or unravelled to absolute ??? QUERY

sws_DMATCH_STR		EQU	MA+$1000
sws_FSP_str		EQU	MA+$1000
sws_DMATCH_LEN		EQU	MA+$100D
sws_DMATCH_WILD		EQU	MA+$100E

sws_cat_curfile		EQU	MA+$1060			; 8 bytes, stores current filename and directory when sorting catalogue
sws_INFO_curattr	EQU	MA+$1060			; used to store current file attributes during info pring

sws_FILEV_LOAD_highord	EQU	MA+$1074
sws_FILEV_EXEC_highord	EQU	MA+$1076

sws_CurrentCat		EQU	MA+$1082			; 
sws_Query1		EQU	MA+$1083			; dunno 
sws_updCatFlag_qry	EQU	MA+$1086			; stores $20 in close (for update catalogue if write only [sic])
sws_BC_SAVE		EQU	MA+$1090			; saves 9 bytes here in load discs VINC_BEGIN1
sws_FILEV_LOAD_LO	EQU	sws_BC_SAVE
sws_FILEV_EXEC_LO	EQU	sws_BC_SAVE + 2
sws_FILEV_LEN_LO	EQU	sws_BC_SAVE + 4
sws_FILEV_MULTI		EQU	sws_BC_SAVE + 6
sws_FILEV_SECTOR_LO	EQU	sws_BC_SAVE + 7

TubeNoTransferIf0	EQU	MA+$109E
sws_VINC_state		EQU	MA+$109F			; Bit 6 set if card initialised
sws_ChannelFlags	EQU	MA+$1117			; Channel flags
sws_Channel_SecHi	EQU	MA+$111D			; ???

sws_vars_10C0		EQU	sws_OpenFlags
sws_OpenFlags		EQU	MA+$10C0

sws_FSmessagesIf0	EQU	MA+$10C6
sws_CMDenabledIf1	EQU	MA+$10C7
sws_default_dir		EQU	MA+$10C9
sws_default_drive	EQU	MA+$10CA
sws_lib_dir		EQU	MA+$10CB
sws_lib_drive		EQU	MA+$10CC
sws_fsp_match_HASH	EQU	MA+$10CD			; if set to '#' then match '#' as wildcard
sws_fsp_match_STAR	EQU	MA+$10CE			; if set to '*' then match '*' as wildcard

sws_TubePresentIf0	EQU	MA+$10D6
sws_param_ptr		EQU	MA+$10DB
sws_error_flag_qry	EQU	MA+$10DD

VID			EQU	MA+$10E0				; VID
VID_DRIVE_INDEX0	EQU	VID			; 4 bytes (low bytes of disk index)
VID_DRIVE_INDEX4	EQU	VID+4			; 4 bytes (hi bytes of disk index and flags)
;VID_MMC_SECTOR		EQU	VID+8			; 3 bytes
VID_VINC_SECTOR_VALID	EQU	VID+$B			; 1 bytes
;VID_MMC_CIDCRC		EQU	VID+$C			; 2 bytes
VID_CHECK_CRC7		EQU	VID+$E			; 1 byte


sws_CurDrvCat		EQU	MA+$0E00
sws_Cat_Filesx8		EQU	sws_CurDrvCat + $105		; number of catalogue entries * 8
sws_Cat_OPT		EQU	sws_CurDrvCat + $106		; OPT/sectors hi bits

	IF DEBUG_VERBOSE != 0
DEBUG_PRINT_STR	MACRO
		SECTION	"tables_and_strings"
1		FCB	\1,13,0
__STR		SET	1B
		CODE
		PSHS	X
		LEAX	__STR,PCR
		JSR	DEBUGPRINTX
		PULS	X
		ENDM

TODOCMD		MACRO
\1		DEBUG_PRINT_STR "TODO:\1"
		rts
		ENDM

TODOSTOP	MACRO
\1		DEBUG_PRINT_STR "TODO HALT:\1"
		swi
		ENDM
	ELSE
DEBUG_PRINT_STR	MACRO
		ENDM

TODOCMD		MACRO
\1		RTS
		ENDM
TODOSTOP	MACRO
\1		SWI
		ENDM
	ENDIF

		; PRINT_STR should be used for inline string printing to enable 
		; it to be turned on / off to ease debugging
PRINT_STR	MACRO
	IF DEBUG !=0 
		SECTION "tables_and_strings"
9		FCB	\1,0
__STR		SET	9B
		CODE
		PSHS	X
		LEAX	__STR,PCR
		jsr	PrintStringX
		PULS	X
	ELSE
		jsr	PrintStringImmed
		FCB	\1, 0
	ENDIF
		ENDM

************************** SETUP TABLES AND CODE AREAS ******************************
			CODE
			ORG	COMPADDR
			SETDP	$00
			SECTION	"tables_and_strings"


************************** START MAIN ROM CODE ******************************
			CODE
ROMSTART		FCB	0,0,0				;  No language entry			
			jmp	rom_handle_service_calls	;  Service call address
			FCB	$83				;  ROM type=6809+Service entry
			FCB	ROM_COPYR-ROMSTART		;  Copyright offset
			FCB	$01				;  ROM version
ROM_TITLE		FCB	"USBFS"				;  ROM title
			FCB	$00
ROM_VERSION		FCB	"0.01"
ROM_COPYR		FCB	$00
			FCB	"(C)2017 Dossytronics"		;  ROM copyright string
			FCB	$0A
			FCB	$0D
			FCB	$00
			FCB	LOADADDR % 256			; Second processor transfer address, no longer overlaps with 10s table
			FCB	LOADADDR / 256			; Note store in 6502 byte order!
								; High word ($0000) overlaps next table
			FCB	0				; extra zero for load address was getting 01 from changed tens table




 **			PAGE=MA+$10CF
 **			RAMBufferSize=MA+$10D0			; HIMEM-PAGE
;;ForceReset		EQU	MA+$10D3
 **			CardSort=MA+$10DE
 **			
 **			buf%=MA+$E00
 **			cat%=MA+$E00
 **			
 **			
 **			
 **			
 **			MACRO BP12K_NEST
 **				IF _BP12K_
 **					JSR PageIn12K
 **					JSR nested
 **					JMP PageOut12K
 **				.nested
 **				ENDIF
 **			ENDMACRO
 **			
 **			
 **			ORG $8000
 **			IF _SWRAM_ AND NOT(_BP12K_)
 **			    guard_value=$B600
 **			ELSE
 **			    guard_value=$C000
 **			ENDIF
 **				GUARD guard_value
 **			
 **				\\ ROM Header
 **			.langentry
 **				BRK
 **				BRK
 **				BRK
 **			.serventry
 **				JMP MMFS_SERVICECALLS
 **			
 **			.romtype
 **				EQUB $82
 **			.copywoffset
 **				EQUB LO(copyright-1)
 **			.binversion
 **				EQUB $7B
 **			.title
 **			    BUILD_NAME
 **			.version
 **			    BUILD_VERSION
 **			.copyright
 **			    BUILD_COPYRIGHT
 **				EQUB _DEVICE_
 **			IF _SWRAM_
 **				EQUS "RAM"
 **			ELSE
 **				EQUS "ROM"
 **			ENDIF
 **			
 **			.Go_FSCV
 **				JMP (FSCV)
 **			



SetLEDS
		pshs	B
		ldb	#5
		stb	$FE40
		puls	B,PC
ResetLEDS
		pshs	B
		ldb	#$0D			; reset sysvia latch 5
		stb	$FE40
		puls	B,PC
errDISK
		jsr	ReportErrorCB		; Disk Error
		fcb	0, "Disc ", $80
		bra	ErrCONTINUE
	
errBAD
		jsr	ReportErrorCB			; Bad Error
		fcb	0, "Bad ", $80
		bra	ErrCONTINUE
brk_brk		BRK					; so we can redfine BRK as SWI/SWI2/SWI3
		
	
	***** Report Error ****
	** A string terminated with 0 causes JMP $100, others appended to $100
	
ReportErrorCB
		* Check if writing channel buffer
		lda	sws_error_flag_qry		; Error while writing
		bne	brk100_notbuf			; channel buffer?
		jsr	ClearEXECSPOOLFileHandle
brk100_notbuf
		lda	#$FF
		sta	sws_CurrentCat
		sta	sws_error_flag_qry		; Not writing buffer
ReportError
		ldx	#$100
		ldy	#brk_brk
		ldb	#BRKSIZE			; copy BRK instruction - (todo macro this?)
1		lda	,Y+
		sta	,X+
		decb
		bne	1B
		clr	,X+				; store a 0 for the error # for now

ErrCONTINUE
		jsr	ResetLEDS
ReportError2
		ldy	,S++				; pull caller's address
		lda	,Y+				; byte after call is error number
		sta	$100 + BRKSIZE
1		lda	,Y+
		bmi	2F
		sta	,X+
		bne	1B
		jsr	TUBE_RELEASE
		jmp	$100				; got a 0 byte jump to our error block at start of system stack
2		jmp	,Y				; continue at instruction after terminator
 **				DEX
 **			.errstr_loop
 **				JSR inc_word_AE
 **				INX
 **				LDA ($AE),Y
 **				STA $0100,X
 **				BMI prtstr_return2		; Bit 7 set, return
 **				BNE errstr_loop
 **				JSR TUBE_RELEASE
 **				JMP $0100
 **			
PrintNewLine
		pshs	A
		lda	#$0D
		jsr	PrintChrA
		puls	A,PC
PrintStringX						;print string at X, 0 or >$80 terminated, 
							; on exit X points after 0, A corrupted
1		lda	,X+
		ble	2F				; stop if 0 or -ve
		jsr	PrintChrA
		bra	1B
2		rts
PrintStringImmed
		pshs	A,X				; Save A,X
		ldx	3,S				; X=byte after JSR to here
		jsr	PrintStringX			; print the string
		stx	3,S				; update return address
		puls	A,X,PC



 **			.PrintString
 **				STA $B3				; Print String (bit 7 terminates)
 **				PLA 				; A,X,Y preserved
 **				STA $AE
 **				PLA
 **				STA $AF
 **				LDA $B3
 **				PHA 				; Save A $ Y
 **				TYA
 **				PHA
 **				LDY #$00
 **			.prtstr_loop
 **				JSR inc_word_AE
 **				LDA ($AE),Y
 **				BMI prtstr_return1		; If end
 **				JSR PrintChrA
 **				JMP prtstr_loop
 **			.prtstr_return1
 **				PLA 				; Restore A $ Y
 **				TAY
 **				PLA
 **			.prtstr_return2
 **				CLC
 **				JMP ($00AE)			; Return to caller
 **			
 **				\ As above sub, but can be spooled
 **			.PrintStringSPL
 **			{
 **				STA $B3				; Save A
 **				PLA 				; Pull calling address
 **				STA $AE
 **				PLA
 **				STA $AF
 **				LDA $B3				; Save A $ Y
 **				PHA
 **				TYA
 **				PHA
 **				LDY #$00
 **			.pstr_loop
 **				JSR inc_word_AE
 **				LDA ($AE),Y
 **				BMI pstr_exloop
 **				JSR OSASCI
 **				JMP pstr_loop
 **			.pstr_exloop
 **				PLA
 **				TAY
 **				PLA
 **				CLC
 **				JMP ($00AE)			;Return
 **			}
	
PrintNibFullStop
		jsr	PrintNibble
PrintFullStop
		lda	#'.'
PrintChrA					; Print character (disable spooling if set)
		pshs	D,X,Y
		lda	#$EC
		jsr	osbyte_X0YFF
		pshs	X			; X = chr destination
		exg	X,D
		orb	#$10
		exg	X,D
		jsr	osbyte03_Xoutstream	; Disable spooled output
		lda	2,S			; get back char
		jsr	OSASCI			; Output chr
		puls	X
		jsr	osbyte03_Xoutstream		; Restore previous setting
		puls	D,X,Y,PC
	
		* Print BCD/Hex : A=number
PrintBCD
		jsr	BinaryToBCD
PrintHex
		sta	,-S
		jsr	A_rorx4
		jsr	PrintNibble
		lda	,S+
PrintNibble
		jsr	NibToASC
		bne	PrintChrA			; always
	
		* As above but allows it to be spooled
PrintBCDSPL
		jsr	BinaryToBCD
PrintHexSPL
		sta	,-S
		jsr	A_rorx4
		jsr	PrintNibbleSPL
		lda	,S+
PrintNibbleSPL
		jsr	NibToASC
		jmp	OSASCI
	
		* Print spaces, exit C=0 A preserved
Print2SpacesSPL
		jsr	PrintSpaceSPL		; Print 2 spaces
PrintSpaceSPL
		pshs	A			; Print space
		lda	#' '
		jsr	OSASCI
		CLC
		puls	A,PC
		* Convert low nibble to ASCII
NibToASC
		anda	#$0F
		cmpa	#$0A
		blo	1F
		adda	#'A'-'0'-10
1		adda	#'0'
		rts

***********************************************************************
Copy32ADDRtoDPandHO
	; copies a 32 bit LOAD/EXEC/etc address at X to
	; DP at Y and high order bytes at U
	; expects everything to be BE
***********************************************************************
	std	,--S
	ldd	,X++
	std	,U++
	ldd	,X++
	std	,Y++
	puls	D,PC

;;; **			
;;; **			.CopyVarsB0BA
;;; **			{
;;; **				JSR CopyWordB0BA
;;; **				DEX
;;; **				DEX 				;restore X to entry value
;;; **				JSR cpybyte1			;copy word (b0)+y to 1072+x
;;; **			.cpybyte1
;;; **				LDA ($B0),Y
;;; **				STA MA+$1072,X
;;; **				INX
;;; **				INY
;;; **				RTS
;;; **			}
;;; **			
;;; **			.CopyWordB0BA
;;; **			{
;;; **				JSR cpybyte2			;Note: to BC,X in 0.90
;;; **			.cpybyte2
;;; **				LDA ($B0),Y
;;; **				STA $BA,X
;;; **				INX
;;; **				INY
;;; **				RTS
;;; **			}
;;; **			
read_fsp_GSREAD
		jsr	Set_CurDirDrv_ToDefaults	; **Read filename to $1000
		bra	rdafsp_entry		; **1st pad $1000-$103F with spaces
read_fspBA_reset
		jsr	Set_CurDirDrv_ToDefaults	; Reset cur dir $ drive
read_fspBA
;;		lda	$BA				; **Also creates copy at $C5
;;		sta	TextPointer
;;		lda	$BB
;;		sta	TextPointer+1
;;		ldy	#$00
		ldx	DP_BA_FILEV_FNAME_PTR		
		jsr	GSINIT_A
rdafsp_entry
		ldb	#' '				; Get drive $ dir (X="space")
		jsr	GSREAD_A			; get C
		bcs	errBadName			; IF end of string
		sta	sws_FSP_str
		cmpa	#'.'				; C="."?
		bne	rdafsp_notdot			; ignore leading …'s
rdafsp_setdrv
		stb	DP_FSW_DirectoryParam		; Save directory (X)
		beq	rdafsp_entry			; always
rdafsp_notdot
		cmpa	#':'				; C=":"? (Drive number follows)
		bne	rdafsp_notcolon
		jsr	Param_DriveNo_BadDrive		; Get drive no.
		jsr	GSREAD_A
		bcs	errBadName			; IF end of string
		cmpa	#'.'				; C="."?
		beq	rdafsp_entry			; err if not eg ":0."
errBadName
		jsr	errBAD
		fcb	$CC, "name",0

rdafsp_notcolon
		tfr	A,B				; X=last Chr
		jsr	GSREAD_A			; get C
		bcs	Rdafsp_padall			; IF end of string
		cmpa	#'.'				; C="."?
		beq	rdafsp_setdrv
		ldb	#1				; Read rest of filename
		ldy	#sws_FSP_str
rdafsp_rdfnloop
		sta	B,Y
		incb
		jsr	GSREAD_A
		bcs	rdafsp_padB			; IF end of string
		cmpb	#$07
		bne	rdafsp_rdfnloop
		bra	errBadName

GSREAD_A
		jsr	GSREAD			; GSREAD ctrl chars cause error
		pshs	CC			; C set if end of string reached
		anda	#$7F
		cmpa	#$0D			; Return?
		beq	dogsrd_exit
		cmpa	#$20			; Control character? (I.e. <$20)
		blo	errBadName
		cmpa	#$7F			; Backspace?
		beq	errBadName
dogsrd_exit
		puls	CC,PC
 **			
 **			.SetTextPointerYX
 **				STX TextPointer
 **				STY TextPointer+1
 **				LDY #$00
 **				RTS

GSINIT_A
		CLC
		jmp	GSINIT

Rdafsp_padall
		ldb	#$01			; Pad all with spaces
rdafsp_padB
		lda	#' '			; Pad with spaces
		ldx	#sws_FSP_str
rdafsp_padloop
		sta	B,X
		incb	
		cmpb	#$40			; Why $40? : Wildcards buffer!
		bne	rdafsp_padloop
		ldb	#$06			; Copy from $1000 to $C5
		ldy	#DP_FSW_FSP_STR
rdafsp_cpyfnloop
		lda	B,X			; 7 byte filename
		sta	B,Y
		decb
		bpl	rdafsp_cpyfnloop
		rts

***********************************************************************
prt_filename_Y_API
	; on entry B contains pointer (in catalogue) to file to print
***********************************************************************
		pshs	D,Y
;;		; set X to point at filename start
;;		ldx	#sws_CurDrvCat + 8
;;		abx					; X now points at start of filename
		lda	7,Y				; get directory / locked
		anda	#$7F				; directory
		bne	prt_filename_prtchr
		jsr	Print2SpacesSPL			; if no dir. print "  "
		bra	prt_filename_nodir		; always?
prt_filename_prtchr
		jsr	PrintChrA			; print dir
		jsr	PrintFullStop			; print "."
prt_filename_nodir
		ldb	#$06				; print filename
prt_filename_loop
		lda	,Y+
		anda	#$7F				; clear top bits
		jsr	PrintChrA
		decb
		bpl	prt_filename_loop
		jsr	Print2SpacesSPL			; print "  "
		lda	#' '				; " "
		tst	,Y				; reload dir
		bpl	prt_filename_notlocked
		lda	#'L'				; "L"
prt_filename_notlocked
		jsr	PrintChrA			; print "L" or " "
		lda	#' '
		jsr	PrintChrA
		puls	D,Y,PC

***********************************************************************
prt_Bspaces_API
***********************************************************************
		jsr	PrintSpaceSPL
		decb
		bne	prt_Bspaces_API
		rts
 **			
 **			
 **			.A_rorx6and3
 **				LSR A
 **				LSR A
 **			.A_rorx4and3
 **				LSR A
 **				LSR A
 **			.A_rorx2and3
 **				LSR A
 **				LSR A
 **				AND #$03
 **				RTS
 **			
A_rorx5				; TODO - work out if these are worthwhile - I suspect not!
		lsra
A_rorx4
		lsra
A_rorx3
		lsra
		lsra
		lsra
		rts
	
A_rolx5
		asla
A_rolx4
		asla
		asla
		asla
		asla
getcat_exit
		rts

***********************************************************************
gatcatentry_GSREAD
***********************************************************************
		jsr	read_fsp_GSREAD
		bra	getcatentry			

***********************************************************************
getcatentry_fspBA
***********************************************************************
		jsr	read_fspBA_reset
***********************************************************************
getcatentry
***********************************************************************
		jsr	srch_cat_1000
		bcs	getcat_exit
	
err_FILENOTFOUND
		jsr	ReportError
		fcb	$D6, "Not found",0		; Not Found error
 **			
 **			
 **			
 **			
 **			\ *EX (<dir>)
		TODOCMD "fscv9_starEX"
 **			.fscv9_starEX
 **				JSR SetTextPointerYX
		TODOCMD	"CMD_EX"
 **			.CMD_EX
 **			{
 **				JSR Set_CurDirDrv_ToDefaults
 **				JSR GSINIT_A
 **				BEQ cmd_ex_nullstr		; If null string
 **				JSR ReadDirDrvParameters2	; Get dir
 **			.cmd_ex_nullstr
 **				LDA #$2A			; "*"
 **				STA MA+$1000
 **				JSR Rdafsp_padall
 **				JSR parameter_afsp
 **				JSR getcatentry
 **				JMP cmd_info_loop
 **			}
 **			
 **				\ *INFO <afsp>
		TODOCMD "fscv10_starINFO"
 **			.fscv10_starINFO
 **				JSR SetTextPointerYX
 **				LDA #info_cmd_index - tblFSCommands-1  ; BF needs to point to the INFO command
 **				STA $BF                            ; Param_SyntaxErrorIfNull to work
CMD_INFO
		jsr	parameter_afsp
		jsr	Param_SyntaxErrorIfNull_API
		jsr	gatcatentry_GSREAD
cmd_info_loop
		jsr	prtInfo_Y_API
		jsr	srch_cat_get_next
		bcs	cmd_info_loop
		clra
		rts
	
	
; TODO - I think this can go - use srch_cat_X?
;; **			.get_cat_firstentry81
;; **				JSR CheckCurDrvCat		; Get cat entry
;; **				LDA #$00
;; **				BEQ srch_cat_entry2		; always
 **			
 **			.srch_catfname
 **				LDX #$06			; copy filename from $C5 to $1058
 **			.getcatloop1
 **				LDA $C5,X
 **				STA MA+$1058,X
 **				DEX
 **				BPL getcatloop1
 **				LDA #$20
 **				STA MA+$105F
 **				LDA #$58
 **				BNE srch_cat_X		; always
 **			
 **			.srch_cat_get_next
 **				LDX #$00			; Entry: wrd $B6 -> first entry
 **				BEQ srch_cat_loop		; always
 **			
srch_cat_1000
		ldx	#sws_FSP_str		; now first byte @ $1000+X
srch_cat_X
		stx	,--S			; Set up $ return first
		jsr	CheckCurDrvCat		; catalogue entry matching
		ldx	,S++			; string at $1000+A
srch_cat_entry2
		ldy	#sws_CurDrvCat
srch_cat_get_next
srch_cat_loop
		tfr	Y,D
		cmpb	sws_Cat_Filesx8
		bhs	srchcat_exit		; If >sws_Cat_Filesx8 Exit with C=0
		leay	8,Y			; move to next entry
		jsr	MatchFilename_API
		bcc	srch_cat_loop		; not a match, try next file
		lda	DP_FSW_DirectoryParam
		ldb	#7			; point at dir char in entry
		jsr	MatchChr
		bne	srch_cat_loop		; If directory doesn't match
		SEC				; Return, Y=offset-8, C=1
srchcat_exit	rts
;; Y_sub8
;; 		DEY
;; 		DEY
;; 		DEY
;; 		DEY
;; 		DEY
;; 		DEY
;; 		DEY
;; 		DEY
;; 		RTS
;; 	

***********************************************************************
MatchFilename_API
	; OLD API - enter with 	$1000,X = filename (wildcarded)
	;			($B6),Y = catalogue entry to match against
	;			on exit C = 1 == match
	; NEW API - enter 	X = filename
	;			Y = catalogue entry
	;			on exit C = 1 == match
***********************************************************************
		pshs	D,X,Y			; Match filename at $1000+X
		ldb	#0			; index into catalogue entry
matfn_loop1
		lda	,X+			; with that at ($B6)
		cmpa	sws_fsp_match_STAR
		bne	matfn_notSTAR		; e.g. If="*"
matfn_loop2	jsr	MatchFilename_API	; recurse!!!
		bcs	matfn_exit		; If match then exit with C=1
		incb
		cmpb	#$07
		blo	matfn_loop2		; If Y<7
matfn_loop3
		lda	,X			; Check next char is a space!
		cmpa	#' '
		bne	matfn_exitC0		; If exit with c=0 (no match)
matfn_exitC1
		SEC
matfn_exit
		puls	D,X,Y,PC
matfn_notSTAR
		cmpb	#$07
		bhs	matfn_loop3		; If Y>=7
		jsr	MatchChr
		bne	matfn_exitC0
		incb
		bne	matfn_loop1		; next chr
matfn_exitC0
		CLC				; exit with C=0
		puls	D,X,Y,PC



MatchChr	; return EQ if B,Y matches A
		cmpa	sws_fsp_match_STAR
		beq	matchr_exit			; eg. If "*"
		cmpa	sws_fsp_match_HASH
		beq	matchr_exit			; eg. If "#"
		jsr	IsAlphaChar
		eora	B,Y
		bcs	matchr_notalpha			; IF not alpha char
		anda	#$5F
matchr_notalpha
		anda	#$7F
matchr_exit
		rts					; If n=1 then matched
	
UcaseA2		pshs	CC
		jsr	IsAlphaChar
		bcs	ucasea
		anda	#$5F			; A=Ucase(A)
ucasea		anda	#$7F			; Ignore bit 7
		puls	CC,PC
 **			
 **			.DeleteCatEntry_YFileOffset
 **			{
 **				JSR CheckFileNotLockedOrOpenY	; Delete catalogue entry
 **			.delcatloop
 **				LDA MA+$0E10,Y
 **				STA MA+$0E08,Y
 **				LDA MA+$0F10,Y
 **				STA MA+$0F08,Y
 **				INY
 **				CPY sws_Cat_Filesx8
 **				BCC delcatloop
 **				TYA
 **				SBC #$08
 **				STA sws_Cat_Filesx8
 **				CLC
 **			}
 **				RTS
 **			
IsAlphaChar
		pshs	A
		anda	#$5F			; Uppercase
		cmpa	#'Z'+1
		bhs	isalpha1		; If >="Z"+1
		cmpa	#'A'
		bhs	2F			; If >="A"
isalpha1
		SEC
2		puls	A,PC

***********************************************************************
prtInfoIfEn_Y_API
	; New API Y should point at cat entry (with details at + $100)
***********************************************************************
		tst	sws_FSmessagesIf0		; Print message
		bmi	print_infoline_exit
***********************************************************************
prtInfo_Y_API
	; New API Y should point at cat entry (with details at + $100)
***********************************************************************
		pshs	D,X,Y
		jsr	prt_filename_Y_API
		ldx	#sws_INFO_curattr
		jsr	ReadFileAttributesToX_YCat_API	; create no. str
		jsr	PrintSpaceSPL		; print "  "
		leax	2,X
		jsr	PrintHex3Byte		; Load address
		jsr	PrintHex3Byte		; Exec address
		jsr	PrintHex3Byte		; Length
		lda	$106,Y			; First sector high bits
		anda	#$03
		jsr	PrintNibble
		lda	$107,Y			; First sector low byte
		jsr	PrintHex
		jsr	PrintNewLine
		puls	D,X,Y,PC
	
PrintHex3Byte
		ldb	#$03			; eg print "123456 "
printhex3byte_loop
		leax	1,X			; skip one
1		lda	,X+
		jsr	PrintHex
		decb
		bne	1B
		jmp	PrintSpaceSPL
print_infoline_exit
		rts

 **			
 **			.LoadCurDrvCat2
 **				JSR RememberAXY
 **				JMP LoadCurDrvCat

***********************************************************************
ReadFileAttributesToX_YCat_API
	; OLD API 		OSFILE block at ($B0)
	;			Catalogue entry (filename) at $E00,Y
	; New API		OSFILE block at X
	;			Catalogue filename at Y

		pshs	D,X,Y,U
		clra
		ldb	#$12
readfileattribs_clearloop				; zero all fields except filename pointer in original caller's block
		decb
		sta	B,X
		cmpb	#$02
		bne	readfileattribs_clearloop

		; do this differently to original code
		tst	7,Y				; get locked bit
		bpl	1F
		lda	#$08
		sta	$11,X				; store $08 in attributes
1		leay	$100,Y				; Y now points into second page of catalogue
		abx					; X now points at load address hi byte
		ldb	6,Y				; B now contains bit field containing sectors and address hi bytes
		bsr	readfileattribs_hiorder
		stu	,X				; load hi bytes
		bsr	readfileattribs_len
		stu	8,X				; len hi bytes
		bsr	readfileattribs_hiorder
		stu	4,X				; exec hi bytes
		bsr	readfileattributes_low
		std	2,X				; load low word
		bsr	readfileattributes_low
		std	6,X				; exec low word
		bsr	readfileattributes_low
		std	10,X				; len low word
		puls	D,X,Y,U,PC

readfileattributes_low
		ldb	,Y+
		lda	,Y+				; not order swapped - this quicker, same size as an EXG
		rts


readfileattribs_len
		lsrb
		lsrb
		stb	,-S				; save B
		andb	#3
1		clra
		tfr	D,U
		puls	B,PC
readfileattribs_hiorder
		lsrb
		lsrb
		stb	,-S				; save B
		andb	#3
		cmpb	#3
		bne	1B
		ldu	#$FFFF
		puls	B,PC


 **			
 **			.inc_word_AE
 **			{
 **				INC $AE
 **				BNE inc_word_AE_exit
 **				INC $AF
 **			.inc_word_AE_exit
 **				RTS
 **			}
 **			
 **				\\ Save AXY and restore after
 **				\\ calling subroutine exited
 **			.RememberAXY
 **				PHA
 **				TXA
 **				PHA
 **				TYA
 **				PHA
 **				LDA #HI(rAXY_restore-1)		; Return to rAXY_restore
 **				PHA
 **				LDA #LO(rAXY_restore-1)
 **				PHA
 **			
 **			.rAXY_loop_init
 **			{
 **				LDY #$05
 **			.rAXY_loop
 **				TSX
 **				LDA $0107,X
 **				PHA
 **				DEY
 **				BNE rAXY_loop
 **				LDY #$0A
 **			.rAXY_loop2
 **				LDA $0109,X
 **				STA $010B,X
 **				DEX
 **				DEY
 **				BNE rAXY_loop2
 **				PLA
 **				PLA
 **			}
 **			
 **			.rAXY_restore
 **				PLA
 **				TAY
 **				PLA
 **				TAX
 **				PLA
 **				RTS
 **			
 **			.RememberXYonly
 **				PHA
 **				TXA
 **				PHA
 **				TYA
 **				PHA
 **				JSR rAXY_loop_init
 **			.axyret1
 **				TSX
 **				STA $0103,X
 **				JMP rAXY_restore
 **			
 **			
***********************************************************************
BinaryToBCD9
	; ** Convert 9 bit binary in word DP_FS_DISKNO ($B8) to
	; ** 3 digit BCD in word DP_FS_BCD_RESULT ($B5)
	; Used by GetDisk, *CAT
		stb	,-S
		pshsw					
		lde	#9		; bit shift counter
		clr	DP_FS_BCD_RESULT
		clr	DP_FS_BCD_RESULT + 1
		ror	DP_FS_DISKNO
1		lda	DP_FS_BCD_RESULT + 1
		adca	DP_FS_BCD_RESULT + 1
		daa			; BCD adjust
		sta	DP_FS_BCD_RESULT + 1
		lda	DP_FS_BCD_RESULT
		adca	DP_FS_BCD_RESULT
		daa
		lda	DP_FS_BCD_RESULT
		asl	DP_FS_DISKNO + 1
		dece
		bne	1B
		pulsw
		puls	B,PC
***********************************************************************
BinaryToBCD
	; Convert binary in A to BCD in A
***********************************************************************
		stb	,-S
		pshsw					
		lde	#8		; bit shift counter
		tfr	A,B
		lda	#0		; result
1		sta	,-S
		aslb
		adca	,S+		; A = A*2 + shifted in B top bit
		daa			; BCD adjust
		dece
		bne	1B
		pulsw
		puls	B,PC

 **			.ShowChrA
 **			{
 **				AND #$7F			; If A<$20 OR >=$7F return "."
 **				CMP #$7F			; Ignores bit 7
 **				BEQ showchrdot
 **				CMP #$20
 **				BCS showchrexit
 **			.showchrdot
 **				LDA #$2E			; "."
 **			.showchrexit
 **				RTS
 **			}
 **			
 **			
 **				\\ **** Read decimal number at TxtPtr+Y ****
 **				\\ on exit;
 **				\\ if valid (0 - 510);
 **				\\ C=0, AX=number, $
 **				\\ Y points to next chr
 **				\\ if not valid;
 **				\\ C=1, AX=0, $
 **				\\ Y=entry value
 **				\\ Exit: Uses memory $B0 + $B1
 **			
 **			rn%=$B0
 **			
 	; OLD api	(F2),Y => string to parse
 	;		on fail Y points to start of string, on success Y points to last char+1
 	;		result in DP_FS_RELWKSP and low byte in X, high byte in A
 	;		C=1 for bad number or >511
 	; NEW		X => string to parse
 	;		on fail X points to start of string, on success X points to last char+1
 	;		result in D can be 0..511
 	;		C=1 for bad number or >511
Param_ReadNumAPI
		pshs	X				; save pointer
		SEC
		jsr	GSINIT_A
		beq	Param_ReadNum_notval
		clrd
1
		std	DP_FS_READNUM_ACC
		jsr	GSREAD
		bcs	Param_ReadNum_done
		suba	#'0'
		blo	Param_ReadNum_notval
		cmpa	#9
		bhi	Param_ReadNum_notval
		sta	,-S
		ldd	DP_FS_READNUM_ACC
		tsta
		bne	Param_ReadNum_notval2		; if there's anything in a then that is too big!
		lda	#10
		mul					; multiply B by 10
		addb	,S+				; add current number
		bcc	2F
		inca
2		cmpd	#512
		bhs	Param_ReadNum_notval		; > 512
		bra	1B				; next char
Param_ReadNum_done
		ldd	DP_FS_READNUM_ACC
		leas	2,S				; discard saved X
		CLC
		rts
Param_ReadNum_notval2
		leas	1,S				; discard stacked A
Param_ReadNum_notval
		clrd
		SEC
		puls	X,PC
		rts


catprlp
1		lda	,Y+
		jsr	PrintChrA
		decb
		bne	1B
		rts
fscv5_starCAT
		jsr	Param_OptionalDriveNo
		jsr	LoadCurDrvCat
		ldb	#$FF			; ** PRINT CAT
		stb	DP_TR_CAT_A8_COL		; Y=FF
		incb	
		stb	DP_TR_CAT_AA_PRDIR		; Y=0
		ldy	#sws_CurDrvCat
		ldb	#8
		jsr	catprlp
		ldy	#sws_CurDrvCat + $100
		ldb	#4
		jsr	catprlp

		PRINT_STR 	" ("				; Print "Drive "

		; Print disk no. instead of cycle no.
		ldb	DP_FSW_CurrentDrv
		jsr	PrtDiskNo_API

		PRINT_STR	")\rDrive "
		lda	DP_FSW_CurrentDrv
		jsr	PrintNibble			; print drv.no.
		ldb	#13
		jsr	prt_Bspaces_API			; print 13 spaces
		PRINT_STR	"Option "
		lda	sws_Cat_OPT
		jsr	A_rorx4
		sta	,-S
		jsr	PrintNibble			; print option.no
		PRINT_STR	" ("
		ldb	,S+
		aslb
		aslb
		leax	diskoptions_table,PCR
		abx
		ldb	#$03				; print option.name
1		lda	,X+
		jsr	PrintChrA
		decb
		bpl	1B

		PRINT_STR	")\rDir. :"

		lda	sws_default_drive
		jsr	PrintNibFullStop		; print driveno+"."
		lda	sws_default_dir
		jsr	PrintChrA			; print dir

		ldb	#11
		jsr	prt_Bspaces_API			; print 11 spaces
		PRINT_STR	"Lib. :"		; print "Lib. :"
		lda	sws_lib_drive
		jsr	PrintNibFullStop		; print library.drv+"."
		lda	sws_lib_dir
		jsr	PrintChrA			; print library.dir
		jsr	PrintNewLine			; print
		pshsw
		clrw					; Mark files in cur dir
		ldx	#sws_CurDrvCat + $F
cat_curdirloop
		cmpf	sws_Cat_Filesx8			; no.of.files?
		bhs	cat_sortloop1			; If @ end of catalogue
		lda	W,X
		eora	sws_default_dir
		anda	#$5F
		bne	cat_curdirnext			; If not current dir
		lda	W,X				; Set dir to null, sort=>first
		anda	#$80				; Keep locked flag (bit 7)
		sta	W,X
cat_curdirnext
		addw	#8
		bra	cat_curdirloop			; always
cat_sortloop1
		clrw					; Any unmarked files?
		jsr	cat_getnextunmarkedfileW
		bcs	cat_findnext2pr			; If yes
		lda	#$FF
		sta	sws_CurrentCat			; mark current catalogue as garbage
		jsr	PrintNewLine
		pulsw
		rts					; ** EXIT OF PRINT CAT


cat_getnextunmarkedfile_loop
		addf	#8
		clre
cat_getnextunmarkedfileW
		ldx	#sws_CurDrvCat + $8
		cmpf	sws_Cat_Filesx8
		bhs	cat_exit			; If @ end of cat exit, c=1
		lda	W,X
		bmi	cat_getnextunmarkedfile_loop	; If marked file
cat_exit
		rts
cat_findnext2pr_2
		ldx	#sws_CurDrvCat + 8
cat_findnext2pr
		stf	DP_TR_CAT_AB_FPTR			; save Y=cat offset
		ldb	#8
		ldy	#sws_cat_curfile
		leax	W,X
cat_copyfnloop
		lda	,X+				; Copy filename to 1060
		jsr	UcaseA2
		sta	,Y+
		decb
		bne	cat_copyfnloop			; Chk fn < all other unmarked files
		ldf	DP_TR_CAT_AB_FPTR
		addf	#8				; move to next file
		clre
cat_comparefnloop1
		jsr	cat_getnextunmarkedfileW	; Next unmarked file
		bcc	cat_printfn			; If last file, so print anyway
		ldb	#$06
		CLC
		ldx	#sws_CurDrvCat + 8 + 7		; point at end of filename+1 in table (W,X)
		leax	W,X
		ldy	#sws_cat_curfile + 7
cat_comparefnloop2
		lda	,-X				; compare filenames
		jsr	UcaseA2				; (catfn-memfn)
		sbca	,-Y
		decb
		bpl	cat_comparefnloop2
		lda	7,X				; compare dir
		jsr	UcaseA2				; (clrs bit 7)
		sbca	sws_cat_curfile+7
		bcs	cat_findnext2pr_2		; If catfn<memfn
		addf	#8
		bra	cat_comparefnloop1		; else memfn>catfn
cat_printfn
		ldf	DP_TR_CAT_AB_FPTR		; Y=cat offset
		ldx	#sws_CurDrvCat + 8
		lda	W,X
		ora	#$80
		sta	W,X				; mark file as printed
		lda	sws_cat_curfile + 7		; dir
		cmpa	DP_TR_CAT_AA_PRDIR		; dir being printed
		beq	cat_samedir			; If in same dir
		tst	DP_TR_CAT_AA_PRDIR		; test if was 0 (default) dir
		pshs	CC
		sta	DP_TR_CAT_AA_PRDIR		; Set dir being printed
		puls	CC
		bne	cat_samedir			; If =0 =default dir
		jsr	PrintNewLine			; Two newlines after def dir
cat_newline	jsr	PrintNewLine
		lda	#$FF
		bra	cat_skipspaces			; always => ?$A8=0
cat_samedir	lda	DP_TR_CAT_A8_COL		; [if ?$A0<>0 = first column]
		bne	cat_newline
		ldb	#5				; print column gap
		jsr	prt_Bspaces_API			; print 5 spaces => ?$A8=1
cat_skipspaces	inca
		sta	DP_TR_CAT_A8_COL
		jsr	Print2SpacesSPL			; print 2 spaces
		ldb	DP_TR_CAT_AB_FPTR		; Y=cat offset
		addb	#8
		lda	#sws_CurDrvCat / 256
		tfr	D,Y
		jsr	prt_filename_Y_API		; Print filename
		jmp	cat_sortloop1
 **			
 **			
 **			
 **			
 **			.Getnextblock_Yoffset
 **				LDA MA+$0F0E,Y
 **				JSR A_rorx4and3
 **				STA $C2				;len byte 3
 **				CLC
 **				LDA #$FF			; -1
 **				ADC MA+$0F0C,Y			; + len byte 1
 **				LDA MA+$0F0F,Y			; + start sec byte 1
 **				ADC MA+$0F0D,Y			; + len byte 2
 **				STA $C3
 **				LDA MA+$0F0E,Y			; start sec byte 2
 **				AND #$03
 **				ADC $C2				; calc. next "free" sector
 **				STA $C2				; wC2=start sec + len - 1
 **			.Getfirstblock_Yoffset
 **				SEC
 **				LDA MA+$0F07,Y			; secs on disk
 **				SBC $C3				; or start sec of prev.
 **				PHA 				; file
 **				LDA sws_Cat_OPT,Y			; - end of prev. file (wC2)
 **				AND #$03
 **				SBC $C2
 **				TAX
 **				LDA #$00
 **				CMP $C0
 **				PLA 				; ax=secs on disk-next blk
 **				SBC $C1
 **				TXA 				; req'd=c0/c1/c4
 **				SBC $C4				; big enough?
***********************************************************************
CMD_notFound_tblUtils
***********************************************************************
		DEBUG_PRINT_STR "--CMD_notFound_tblUtils"
		lda	#4		; return with A != 0 and Z=0 to indicate not handled
		rts
***********************************************************************
CMD_notFound_tblFS
***********************************************************************
		DEBUG_PRINT_STR	"CMD_notFound_tblFS"
		jsr	GSINIT_A
		lda	,X+
		ora	#$20
		ldy	#tblDUtilsCommands
		cmpa	#'d'			; "d"
		beq	UnrecCommandTextPointerAPI
		leax	-1,X
		jmp	CMD_notFound_tblDUtils
	
***********************************************************************
fscv3_unreccommand
***********************************************************************
		DEBUG_PRINT_STR "FSCV3 - UK COMMAND"
		ldy	#tblFSCommands
		; and drop into next...
			; OLD API
			; X = command table offset from tblFSCommands
			; Y = command tail offset from F2/F3
			; NEW API
			; Y = pointer to start of table (command # byte)
			; X = command tail pointer exits pointing to first parameter or $0D
UnrecCommandTextPointerAPI
		lda	,Y+				; Get number of last command
		sta	DP_FS_CMD_NUM
		pshs	X
	
unrecloop1
		inc	DP_FS_CMD_NUM

		ldx	,S				; Get back text pointer
		jsr	GSINIT_A			; TextPointer+Y = cmd line

		lda	,Y
		beq	gocmdcode			; If end of table

;;		DEX
;;		DEY
;;		STX $BF				; USED IF SYNTAX ERROR
	
unrecloop2
;;		INX
;;		INY 				; X=start of next string-1
		lda	,Y+
		bmi	endofcmd_oncmdline
unrecloop2in
		eora	,X+			; end of table entry - matched!
		anda	#$5F
		beq	unrecloop2		; ignore case
		leay	-1,Y			; while chrs eq go loop2
	
unrecloop3					; move to params byte
		lda	,Y+
		bpl	unrecloop3		; find end of table entry
	
		lda	-1,X			
		cmpa	#'.'			; does cmd line end with
		bne	unrecloop1		; full stop?
		bra	gocmdcode
	
endofcmd_oncmdline
		lda	,X			; If >="." (always)
		jsr	IsAlphaChar		; matched table entry
		bcc	unrecloop1
	
gocmdcode	leas	2,S			; discard X from stack and keep what we have
		lda	DP_FS_CMD_NUM
		asla
		ldy	#tblFSCommandPointers
		ldy	A,Y
		bpl	dommcinit
gocmdcode2
		jmp	,Y
	
dommcinit
		jsr	VINC_BEGIN2
		tfr	Y,D
		ora	#$80
		tfr	D,Y
		bra	gocmdcode2



	
		TODOCMD	"CMD_WIPE"
 **			.CMD_WIPE
 **			{
 **				JSR parameter_afsp
 **				JSR Param_SyntaxErrorIfNull
 **				JSR gatcatentry_GSREAD
 **			.wipeloop
 **				LDA MA+$0E0F,Y
 **				BMI wipelocked			; Ignore locked files
 **				JSR prt_filename_Y_API
 **				JSR ConfirmYNcolon		; Confirm Y/N
 **				BNE wipeno
 **				LDX $B6
 **				JSR CheckForDiskChange
 **				STX $B6
 **				JSR DeleteCatEntry_AdjustPtr
 **				STY $AB
 **				JSR SaveCatToDisk
 **				LDA $AB
 **				STA $B6
 **			.wipeno
 **				JSR PrintNewLine
 **			.wipelocked
 **				JSR srch_cat_get_next
 **				BCS wipeloop
 **				RTS
 **			}
 **			
		TODOCMD	"CMD_DELETE"
 **			.CMD_DELETE
 **				JSR parameter_fsp
 **				JSR Param_SyntaxErrorIfNull
 **				JSR gatcatentry_GSREAD
 **				JSR prtInfoIfEn_Y_API
 **				JSR DeleteCatEntry_YFileOffset
 **				JMP SaveCatToDisk
 **			
		TODOCMD	"CMD_DESTROY"
 **			.CMD_DESTROY
 **			{
 **				JSR IsEnabledOrGo		; If NO it returns to calling sub
 **				JSR parameter_afsp
 **				JSR Param_SyntaxErrorIfNull
 **				JSR gatcatentry_GSREAD
 **			.destroyloop1
 **				LDA MA+$0E0F,Y			; Print list of matching files
 **				BMI destroylocked1		; IF file locked
 **				JSR prt_filename_Y_API
 **				JSR PrintNewLine
 **			.destroylocked1
 **				JSR srch_cat_get_next
 **				BCS destroyloop1
 **				JSR GoYN			; Confirm Y/N
 **				BEQ destroyyes
 **				JMP PrintNewLine
 **			.destroyyes
 **				JSR CheckForDiskChange
 **				JSR srch_cat_1000
 **			.destroyloop2
 **				LDA MA+$0E0F,Y
 **				BMI destroylocked2		; IF file locked
 **				JSR DeleteCatEntry_AdjustPtr
 **			.destroylocked2
 **				JSR srch_cat_get_next
 **				BCS destroyloop2
 **				JSR SaveCatToDisk
 **			.msgDELETED
 **				JSR PrintString
 **				EQUS 13,"Deleted",13
 **			}
 **			
 **			.Y_add8
 **				INY
 **			.Y_add7
 **				INY
 **				INY
 **				INY
 **				INY
 **				INY
 **				INY
 **				INY
 **				RTS
 **			
 **			.DeleteCatEntry_AdjustPtr
 **				JSR DeleteCatEntry_YFileOffset	; Delete cat entry
 **				LDY $B6
 **				JSR Y_sub8			; Take account of deletion
 **				STY $B6				; so ptr is at next file
 **				RTS
 **			
 **				\\ *DRIVE <drive>
		TODOCMD	"CMD_DRIVE"
 **			.CMD_DRIVE
 **				JSR Param_DriveNo_Syntax
 **				STA sws_default_drive
 **				RTS
 **			
SetCurrentDrive_Adrive
		anda	#$03
		sta	DP_FSW_CurrentDrv
		rts
 **			
osfileFF_loadfiletoaddr
		jsr	getcatentry_fspBA		; Get Load Addr etc.
		jsr	SetParamBlockPointerB0		; from catalogue
		jsr	ReadFileAttributesToX_YCat_API	; (Just for info?)
	
LoadFile_Ycatoffset
		pshs	D,X,Y,U
		sty	DP_BA_FILEV_DIR_ENT_PTR		; save directory entry pointer
		leay	$100,Y				; point Y at the attributes page

		;setup 	load/exec/len at BC..C1 (low words)
		;	load/exec/len at 1074..1079
		;	C2 = multi byte, C3 = sector
		;	if BF (exec address low) = 0 then take load from control block, else from catalogue

		ldx	#DP_BC_FILEV_LOAD
		tst	DP_BE_FILEV_EXEC + 1		; If ?BE=0 don't do Load Addr
		bne	loadAtCatAddr
	
		; use load address in control block, skip copy, its already there from the load block
		ldb	#2
		bra	load_copyfileinfo_start_loop
	
		; use catalogue's load address, get hi order
loadAtCatAddr	ldb	$6,Y				; mixed byte
		jsr	readfileattribs_hiorder		; U now contains hi order
		stu	sws_FILEV_LOAD_highord
		clrb

load_copyfileinfo_start_loop

load_copyfileinfo_loop
		lda	B,Y		; copy and swap endianness
		incb
		sta	B,X
		lda	B,Y
		decb
		sta	B,X
		incb
		incb
		cmpb	#$06
		bne	load_copyfileinfo_loop
		ldu	B,Y		; store last two bytes in normal order
		stu	B,X

		ldb	DP_C2_FILEV_MULTI
		lsrb
		lsrb
		lsrb
		lsrb
		jsr	readfileattribs_hiorder
		stu	sws_FILEV_EXEC_highord
	
		ldy	DP_BA_FILEV_DIR_ENT_PTR
		jsr	prtInfoIfEn_Y_API		; pt. print file info
		jsr	LoadMemBlockEX
		puls	D,X,Y,U,PC

	
		TODOCMD "osfile0_savememblock"
 **			.osfile0_savememblock
 **				JSR CreateFile_FSP
 **				JSR SetParamBlockPointerB0
 **				JSR ReadFileAttributesToX_YCat_API
 **				JMP SaveMemBlock
 **			
		TODOCMD "fscv2_4_11_starRUN"
 **			.fscv2_4_11_starRUN
 **				JSR SetTextPointerYX		; ** RUN
		TODOCMD	"CMD_notFound_tblDUtils"
 **			.CMD_notFound_tblDUtils
 **			{
 **				JSR SetWordBA_txtptr		; (Y preserved)
 **				STY MA+$10DA			; Y=0
 **				JSR read_fspBA_reset		; Look in default drive/dir
 **				STY MA+$10D9			; Y=text ptr offset
 **				JSR get_cat_firstentry81
 **				BCS runfile_found		; If file found
 **				LDY MA+$10DA
 **				LDA sws_lib_dir			; Look in library
 **				STA DP_FSW_DirectoryParam
 **				LDA sws_lib_drive
 **				JSR SetCurrentDrive_Adrive
 **				JSR read_fspBA
 **				JSR get_cat_firstentry81
 **				BCS runfile_found		; If file found
errBADCOMMAND
		jsr	errBAD
		fcb	$FE, "command",0
 **			
 **			.runfile_found
 **				LDA MA+$0F0E,Y			; New to DFS
 **				JSR A_rorx6and3			; If ExecAddr=$FFFFFFFF *EXEC it
 **				CMP #$03
 **				BNE runfile_run			; If ExecAddr<>$FFFFFFFF
 **				LDA MA+$0F0A,Y
 **				AND MA+$0F0B,Y
 **				CMP #$FF
 **				BNE runfile_run			; If ExecAddr<>$FFFFFFFF
 **				LDX #$06			; Else *EXEC file  (New to DFS)
 **			.runfile_exec_loop
 **				LDA MA+$1000,X			; Move filename
 **				STA MA+$1007,X
 **				DEX
 **				BPL runfile_exec_loop
 **				LDA #$0D
 **				STA MA+$100E
 **				LDA #$45
 **				STA MA+$1000			; "E"
 **				LDA #$2E			; "."
 **				STA MA+$1001
 **				LDA #$3A			; ":"
 **				STA MA+$1002
 **				LDA DP_FSW_CurrentDrv
 **				ORA #$30
 **				STA MA+$1003			; Drive number X
 **				LDA #$2E			; "."
 **				STA MA+$1004
 **				STA MA+$1006
 **				LDA DP_FSW_DirectoryParam		; Directory D
 **				STA MA+$1005
 **				LDX #$00			; "E.:X.D.FILENAM"
 **				LDY #MP+$10
 **				JMP OSCLI
 **			
 **			.runfile_run
 **				JSR LoadFile_Ycatoffset	; Load file (host|sp)
 **				CLC
 **				LDA MA+$10D9			; Word $10D9 += text ptr
 **				TAY 				; i.e. -> parameters
 **				ADC TextPointer
 **				STA MA+$10D9
 **				LDA TextPointer+1
 **				ADC #$00
 **				STA MA+$10DA
 **				LDA MA+$1076			; Execution address hi bytes
 **				AND MA+$1077
 **				ORA sws_TubePresentIf0
 **				CMP #$FF
 **				BEQ runfile_inhost		; If in Host
 **				LDA $BE				; Copy exec add low bytes
 **				STA MA+$1074
 **				LDA $BF
 **				STA MA+$1075
 **				JSR TUBE_CLAIM
 **				LDX #$74			; Tell second processor
 **				\ assume tube code doesn't change sw rom
 **				LDY #MP+$10
 **				LDA #$04			; (Exec addr @ 1074)
 **				JMP TUBE_CODE_QRY			; YX=addr,A=0:initrd,A=1:initwr,A=4:strexe
 **			.runfile_inhost
 **				LDA #$01			; Execute program
 **				JMP ($00BE)
 **			}
 **			
 **			.SetWordBA_txtptr
 **				LDA #$FF
 **				STA $BE
 **				LDA TextPointer
 **				STA $BA
 **				LDA TextPointer+1
 **				STA $BB
 **				RTS
 **			
		TODOCMD	"CMD_DIR"
 **			.CMD_DIR
 **				LDX #$00			; ** Set DEFAULT DIR/DRV
 **				BEQ setdirlib
 **			
		TODOCMD	"CMD_LIB"
 **			.CMD_LIB
 **				LDX #$02			; ** Set LIBRARY DIR/DRV
 **			.setdirlib
 **				JSR ReadDirDrvParameters
 **				STA sws_default_drive,X
 **				LDA DP_FSW_DirectoryParam
 **				STA sws_default_dir,X
 **				RTS

***********************************************************************
SaveStaticToPrivateWorkspace
* Copy valuable data from static workspace (sws) to
* private workspace (pws)
* (sws data 10C0-10EF, and 1100-11BF)
***********************************************************************
		pshs	D,X,Y
		pshsw
		ldx	DP_FS_RELWKSP
		stx	,--S				; save current pointer ??? WHY
	
		jsr	SetPrivateWorkspacePointerB0

		ldx	DP_FS_RELWKSP
		ldy	#MA+$1100
		ldw	#$C0
		tfm	Y+,X+				; copy 1100-11BF into PWS
		ldy	#sws_vars_10C0
		ldw	#$30
		tfm	Y+,X+				; copy 10C0-11EF into PWS

		ldx	,S++				; get back DP_FS_RELWKSP
		stx	DP_FS_RELWKSP
		pulsw
		puls	D,X,Y,PC

 **			
 **			
 **			.ReadDirDrvParameters
 **				LDA sws_default_dir			; Read drive/directory from
 **				STA DP_FSW_DirectoryParam		; command line
 **				JSR GSINIT_A
 **				BNE ReadDirDrvParameters2	; If not null string
 **				LDA #$00
 **				JSR SetCurrentDrive_Adrive	; Drive 0!
 **				BEQ rdd_exit1			; always
 **			
 **			.ReadDirDrvParameters2
 **			{
 **				LDA sws_default_drive
 **				JSR SetCurrentDrive_Adrive
 **			.rdd_loop
 **				JSR GSREAD_A
 **				BCS errBADDIRECTORY		; If end of string
 **				CMP #$3A			; ":"?
 **				BNE rdd_exit2
 **				JSR Param_DriveNo_BadDrive	; Get drive
 **				JSR GSREAD_A
 **				BCS rdd_exit1			; If end of string
 **				CMP #$2E			; "."?
 **				BEQ rdd_loop
errBADDIRECTORY
		jsr	errBAD
		fcb	$CE,  "dir",0
 **			
 **			.rdd_exit2
 **				STA DP_FSW_DirectoryParam
 **				JSR GSREAD_A			; Check end of string
 **				BCC errBADDIRECTORY		; If not end of string
 **			}
 **			.rdd_exit1
 **				LDA DP_FSW_CurrentDrv
 **				RTS
 **			
 **			
 **			
 **				\ ** RETITLE DISK
 **			titlestr%=MA+$1000
 **			
		TODOCMD	"CMD_TITLE"
 **			.CMD_TITLE
 **			{
 **				JSR Param_SyntaxErrorIfNull
 **				JSR Set_CurDirDrv_ToDefaults
 **				JSR LoadCurDrvCat2		; load cat
 **			
 **				LDX #$0B			; blank title
 **				LDA #$00
 **			.cmdtit_loop1
 **				JSR SetDiskTitleChr_Xpos
 **				DEX
 **				BPL cmdtit_loop1
 **			
 **			.cmdtit_loop2
 **				INX 				; read title for parameter
 **				JSR GSREAD_A
 **				BCS cmdtit_savecat
 **				JSR SetDiskTitleChr_Xpos
 **				CPX #$0B
 **				BCC cmdtit_loop2
 **			
 **			.cmdtit_savecat
 **				JSR SaveCatToDisk		; save cat
 **				JMP UpdateDiskTableTitle	; update disk table
 **			
 **			.SetDiskTitleChr_Xpos
 **				STA titlestr%,X
 **				CPX #$08
 **				BCC setdisttit_page
 **				STA MA+$0EF8,X
 **				RTS
 **			.setdisttit_page
 **				STA MA+$0E00,X
 **				RTS
 **			}
 **			
 **				\ Update title in disk table for disk in current drive
 **				\ Title at titlestr%
 **			.UpdateDiskTableTitle
 **			{
 **				JSR GetDriveStatus
 **				LDY #$0B
 **			.loop
 **				LDA titlestr%,Y
 **				STA ($B0),Y
 **				DEY
 **				BPL loop
 **				JMP SaveDiskTable
 **			}
 **			
 **				\ ** ACCESS
		TODOCMD	"CMD_ACCESS"
 **			.CMD_ACCESS
 **				JSR parameter_afsp
 **				JSR Param_SyntaxErrorIfNull
 **				JSR read_fsp_GSREAD
 **				LDX #$00			; X=locked mask
 **				JSR GSINIT_A
 **				BNE cmdac_getparam		; If not null string
 **			.cmdac_flag
 **				STX $AA
 **				JSR srch_cat_1000
 **				BCS cmdac_filefound
 **				JMP err_FILENOTFOUND
 **			.cmdac_filefound
 **				JSR CheckFileNotOpenY		; Error if it is!
 **				LDA MA+$0E0F,Y			; Set/Reset locked flag
 **				AND #$7F
 **				ORA $AA
 **				STA MA+$0E0F,Y
 **				JSR prtInfoIfEn_Y_API
 **				JSR srch_cat_get_next
 **				BCS cmdac_filefound
 **				\BCC jmp_savecattodisk		; Save catalogue
 **			.jmp_savecattodisk
 **				JMP SaveCatToDisk
 **			
 **			.cmdac_paramloop
 **				LDX #$80			; Locked bit
 **			.cmdac_getparam
 **				JSR GSREAD_A
 **				BCS cmdac_flag			; If end of string
 **				AND #$5F
 **				CMP #$4C			; "L"?
 **				BEQ cmdac_paramloop
errBADATTRIBUTE
		jsr	errBAD			; Bad attribute
		fcb	$CF, "attribute",0
 **			
 **			
		TODOCMD "fscv0_starOPT"
 **			.fscv0_starOPT
 **				JSR RememberAXY
 **				TXA
 **				CMP #$04
 **				BEQ SetBootOption_Yoption
 **				CMP #$05
 **				BEQ DiskTrapOption
 **				CMP #$02
 **				BCC opts0_1			; If A<2
errBADOPTION
		jsr	errBAD
		fcb	$CB, "option",0
 **			
 **			.opts0_1
 **				LDX #$FF			; *OPT 0,Y or *OPT 1,Y
 **				TYA
 **				BEQ opts0_1_Y0
 **				LDX #$00
 **			.opts0_1_Y0
 **				STX sws_FSmessagesIf0		; =NOT(Y=0), I.e. FF=messages off
 **				RTS
 **			
 **			.SetBootOption_Yoption
 **				TYA 				; *OPT 4,Y
 **				PHA
 **				JSR Set_CurDirDrv_ToDefaults
 **				JSR LoadCurDrvCat		; load cat
 **				PLA
 **				JSR A_rolx4
 **				EOR sws_Cat_OPT
 **				AND #$30
 **				EOR sws_Cat_OPT
 **				STA sws_Cat_OPT
 **				JMP SaveCatToDisk		; save cat
 **			
 **			.DiskTrapOption
 **			{
 **			IF NOT(_MASTER_)			; Master DFS always has higher priority
 **				\ Bit 6 of the swrom_wksp_tab = disable *DISC, *DISK commands etc.
 **				TYA				; *OPT 5,Y
 **				PHP
 **			IF _BP12K_
 **				LDA PagedRomSelector_RAMCopy
 **				AND #$7F
 **				TAX
 **			ELSE
 **				LDX PagedRomSelector_RAMCopy
 **			ENDIF
 **				LDA swrom_wksp_tab,X
 **				AND #$BF			; Clear bit 6
 **				PLP
 **				BEQ skip
 **				ORA #$40			; Set bit 6 if Y<>0
 **			.skip	STA swrom_wksp_tab,X
 **			ENDIF
 **				RTS
 **			}
 **			
errDISKFULL
		jsr	errDISK
		fcb	$C6, "full",0
 **			
 **			.CreateFile_FSP
 **			{
 **				JSR read_fspBA_reset		; loads cat
 **				JSR srch_cat_1000	; does file exist?
 **				BCC createfile_nodel		; If NO
 **				JSR DeleteCatEntry_YFileOffset	; delete previous file
 **			
 **			.createfile_nodel
 **				LDA $C0				; save wC0
 **				PHA
 **				LDA $C1
 **				PHA
 **				SEC
 **				LDA $C2				; A=1078/C1/C0=start address
 **				SBC $C0				; B=107A/C3/C2=end address
 **				STA $C0				; C=C4/C1/C0=file length
 **				LDA $C3
 **				SBC $C1
 **				STA $C1
 **				LDA MA+$107A
 **				SBC MA+$1078
 **				STA $C4				; C=B-A
 **				JSR CreateFile_2
 **				LDA MA+$1079			; Load Address=Start Address
 **				STA MA+$1075			; (4 bytes)
 **				LDA MA+$1078
 **				STA MA+$1074
 **				PLA
 **				STA $BD
 **				PLA
 **				STA $BC
 **				RTS
 **			}
 **			
 **			.CreateFile_2
 **			{
 **				LDA #$00			; NB Cat stored in
 **				STA $C2				; desc start sec order
 **				LDA #$02			; (file at 002 last)
 **				STA $C3				; wC2=$200=sector
 **				LDY sws_Cat_Filesx8			; find free block
 **				CPY #$F8			; big enough
 **				BCS errCATALOGUEFULL		; for new file
 **				JSR Getfirstblock_Yoffset
 **				JMP cfile_cont2
 **			
 **			.cfile_loop
 **				BEQ errDISKFULL
 **				JSR Y_sub8
 **				JSR Getnextblock_Yoffset
 **			.cfile_cont2
 **				TYA
 **				BCC cfile_loop			; If not big enough
 **				STY $B0				; Else block found
 **				LDY sws_Cat_Filesx8			; Insert space into catalogue
 **			.cfile_insertfileloop
 **				CPY $B0
 **				BEQ cfile_atcatentry		; If at new entry
 **				LDA MA+$0E07,Y
 **				STA MA+$0E0F,Y
 **				LDA MA+$0F07,Y
 **				STA MA+$0F0F,Y
 **				DEY
 **				BCS cfile_insertfileloop
 **			.cfile_atcatentry
 **				LDX #$00
 **				JSR CreateMixedByte
 **			.cfile_copyfnloop
 **				LDA $C5,X			; Copy filename from $C5
 **				STA MA+$0E08,Y
 **				INY
 **				INX
 **				CPX #$08
 **				BNE cfile_copyfnloop
 **			.cfile_copyattribsloop
 **				LDA $BB,X			; Copy attributes
 **				DEY
 **				STA MA+$0F08,Y
 **				DEX
 **				BNE cfile_copyattribsloop
 **				JSR prtInfoIfEn_Y_API
 **				TYA
 **				PHA
 **				LDY sws_Cat_Filesx8
 **				JSR Y_add8
 **				STY sws_Cat_Filesx8			; FilesX+=8
 **				JSR SaveCatToDisk		; save cat
 **				PLA
 **				TAY
 **				RTS
 **			}
 **			
errCATALOGUEFULL
		jsr	ReportErrorCB
		fcb	$BE, "Cat full",0
 **			
 **			.CreateMixedByte
 **				LDA MA+$1076			; Exec address b17,b16
 **				AND #$03
 **				ASL A
 **				ASL A
 **				EOR $C4				; Length
 **				AND #$FC
 **				EOR $C4
 **				ASL A
 **				ASL A
 **				EOR MA+$1074			; Load address
 **				AND #$FC
 **				EOR MA+$1074
 **				ASL A
 **				ASL A
 **				EOR $C2				; Sector
 **				AND #$FC
 **				EOR $C2
 **				STA $C2				; C2=mixed byte
 **				RTS
 **			
		TODOCMD	"CMD_ENABLE"
 **			.CMD_ENABLE
 **				LDA #$01
 **				STA sws_CMDenabledIf1
 **				RTS
 **			
 **			
;;; **			.LoadAddrHi2
;;; **			{
;;; **				LDA #$00
;;; **				STA MA+$1075
;;; **				LDA $C2
;;; **				AND #$08
;;; **				STA MA+$1074
;;; **				BEQ ldadd_nothost
;;; **				LDA #$FF
;;; **				STA MA+$1075
;;; **				STA MA+$1074
;;; **			.ldadd_nothost
;;; **				RTS
;;; **			}
;;; **			
;;; **			.ExecAddrHi2
;;; **			{
;;; **				LDA #$00
;;; **				STA MA+$1077
;;; **				LDA $C2
;;; **				JSR A_rorx6and3
;;; **				CMP #$03
;;; **				BNE exadd_nothost
;;; **				LDA #$FF
;;; **				STA MA+$1077
;;; **			.exadd_nothost
;;; **				STA MA+$1076
;;; **				RTS
;;; **			}
 **			
Set_CurDirDrv_ToDefaults
		lda	sws_default_dir			; set working dir
		sta	DP_FSW_DirectoryParam
	
Set_CurDrv_ToDefault
		lda	sws_default_drive		; set working drive
		jmp	SetCurrentDrive_Adrive
	
		* (<drive>) looks for [[:]]<n> sets to "default" if none spec'd
Param_OptionalDriveNo
		jsr	GSINIT_A
		beq	Set_CurDrv_ToDefault		; null string
	
		* <drive>
		* New API, 	X = command pointer (to drive #)
		*		Y = pointer to command's table entry
		* Exit: A=DrvNo, C=0, X points after drive #
Param_DriveNo_Syntax_API
		jsr	Param_SyntaxErrorIfNull_API
Param_DriveNo_BadDrive
		jsr	GSREAD_A
		bcs	errBADDRIVE
		cmpa	#':' 				; ASC(":")
		beq	Param_DriveNo_BadDrive
		suba	#'0'
		blo	errBADDRIVE
		cmpa	#4
		bhs	errBADDRIVE
		jsr	SetCurrentDrive_Adrive
		CLC
		rts
errBADDRIVE
		jsr	errBAD
		fcb	$CD, "drive",0
 **			
 **			.jmpSYNTAX
 **				JMP errSYNTAX
 **			
errDISKNOTFOUND
		jsr	errDISK
		fcb	$D6, "not found", 0
 **			
 **				\\ Read parameters : drive optional
 **				\\ (<drive>) <dno>/<dsp>
 **				\\ Exit: DP_FSW_CurrentDrv=drive, Word $B8=disk no.
 **			
 **			.Param_DriveAndDisk
 **			{
 **				JSR Param_SyntaxErrorIfNull
 **				CMP #$22
 **				BNE param_nq1
 **				DEY
 **			
 **			.param_nq1
 **				STY $B4				 ; Save Y
 **				JSR GSREAD_A
 **				CMP #':'			; ASC(":")
 **				BNE param_dad
 **				JSR Param_DriveNo_BadDrive
 **				BCC Param_Disk			; always
 **			
 **			.param_dad
 **				LDY $B4				; Restore Y
 **				JSR Set_CurDrv_ToDefault
 **			
 **				\ Read 1st number
 **				JSR Param_ReadNum		; rn% @ B0
 **				BCS gddfind			; if not valid number
 **				JSR GSINIT_A
 **				BEQ gdnodrv			; if rest of line blank
 **				CMP #$22
 **				BNE param_nq2
 **				DEY
 **			
 **			.param_nq2
 **				LDA rn%+1
 **				BNE errBADDRIVE			; AX>255
 **				LDA rn%
 **				CMP #4
 **				BCS errBADDRIVE
 **				JSR SetCurrentDrive_Adrive
 **			}
 **			
 **			
 **				\ Read (2nd) number?
 **				\ If it's not a valid number:
 **				\ assume it's a disk name
 **				\ <dno>/<dsp>
 **				\ Exit: Word $B8 = disk no.
 **			.Param_Disk
 **				JSR Param_ReadNum		; rn% @ B0
 **				BCS gddfind			; if not valid number
 **				JSR GSINIT_A
 **				BNE jmpSYNTAX			; if rest of line not blank
 **			
 **			.gdnodrv
 **				LDA rn%+1
 **				STA $B9
 **				LDA rn%
 **				STA $B8
 **			.gddfound
 **				RTS
 **			
 **				\ The parameter is not valid number;
 **				\ so it must be a disk name?!
 **			
 **			.gddfind
 **			{
 **				JSR DMatchInit
 **				LDA #0
 **				STA DP_FST_B7_DCAT_GDOPT			; don't return unformatted disks
 **				JSR GetDiskFirstAll
 **				LDA dmLen%
 **				BEQ jmpSYNTAX
 **				LDA dmAmbig%
 **				BNE jmpSYNTAX
 **			
 **			.gddlp
 **				LDA DP_FST_B7_DCAT_DNO+1
 **				BMI errDISKNOTFOUND
 **				JSR DMatch
 **				BCC gddfound
 **				JSR GetDiskNext
 **				JMP gddlp
 **			}
 **			
 **				\ ** RENAME FILE
		TODOCMD	"CMD_RENAME"
 **			.CMD_RENAME
 **			{
 **				JSR parameter_fsp
 **				JSR Param_SyntaxErrorIfNull
 **				JSR read_fsp_GSREAD
 **				TYA
 **				PHA
 **				JSR getcatentry
 **				JSR CheckFileNotLockedOrOpenY
 **				STY $C4
 **				PLA
 **				TAY
 **				JSR Param_SyntaxErrorIfNull
 **				LDA DP_FSW_CurrentDrv
 **				PHA
 **				JSR read_fsp_GSREAD
 **				PLA
 **				CMP DP_FSW_CurrentDrv
 **				BNE jmpBADDRIVE
 **				JSR srch_cat_1000
 **				BCC rname_ok
 **				CPY $C4
 **				BEQ rname_ok
errFILEEXISTS
		jsr	ReportErrorCB
		fcb	$C4, "Exists",0
 **			.jmpBADDRIVE
 **				JMP errBADDRIVE
 **			.rname_ok
 **				LDY $C4				; Copy filename
 **				JSR Y_add8			; from C5 to catalog
 **				LDX #$07
 **			.rname_loop
 **				LDA $C5,X
 **				STA MA+$0E07,Y
 **				DEY
 **				DEX
 **				BPL rname_loop			; else Save catalogue
 **				JMP SaveCatToDisk
 **			}
 **			
TUBE_CheckIfPresent
			lda	#$EA			; Tube present?
			jsr	osbyte_X0YFF
			tfr	X,B
			eorb	#$FF
			stb	sws_TubePresentIf0
			rts
 **			
 **			.TUBE_CLAIM
 **			{
 **				PHA
 **			.tclaim_loop
 **				LDA #$C0+TUBE_ID
 **				JSR TUBE_CODE_QRY
 **				BCC tclaim_loop
 **				PLA
 **				RTS
 **			}
 **			
TUBE_RELEASE
		jsr	TUBE_CheckIfPresent
		bmi	trelease_exit
TUBE_RELEASE_NoCheck
		sta	,-S
		lda	#$80+TUBE_ID
		jsr	TUBE_CODE_QRY
		lda	,S+
trelease_exit
		rts

CheckESCAPE	; TODO: use JGH API (or ask?)
		tst	$FF				; Check if ESCAPE presed
		bpl	noesc				; Used by *FORM/VERIFY
ReportESCAPE	jsr	osbyte7E_ackESCAPE2
		jsr	ReportError
		fcb	$11, "Escape", 0
 **			
 **			.PrintHex100
 **			{
 **				PHA 				; Print hex to $100+Y
 **				JSR A_rorx4
 **				JSR phex100
 **				PLA
 **			.phex100
 **				JSR NibToASC
 **				STA $0100,Y
 **				INY
 **			}
noesc		rts
 **			
 **			
 **			.BootOptions
 **				EQUS "L.!BOOT",13
 **				EQUS "E.!BOOT",13
 **			
	
		TODOCMD	"CMD_DISC"
 **			.CMD_DISC
 **			IF NOT(_MASTER_)
 **			IF _BP12K_
 **				LDA PagedRomSelector_RAMCopy
 **				AND #$7F
 **				TAX
 **			ELSE
 **				LDX PagedRomSelector_RAMCopy	; Are *DISC,*DISK disabled?
 **			ENDIF
 **				LDA swrom_wksp_tab,X
 **				AND #$40
 **				BEQ CMD_CARD
 **				RTS
 **			ENDIF
 **			
		TODOCMD	"CMD_USBFS"
 **			.CMD_CARD
 **				LDA #$FF
***********************************************************************
initMMFS
; On entry: if A=0 then boot file
***********************************************************************
		pshsw
		pshs	A,U
		lda	#FSCV_6_NewFS
		jsr	[FSCV]			; new filing system
	
		; setup FILEV to FSCV to point at the extended vector entry points
		ldy	#FILEV
		ldx	#EXTVEC_ENTER_FILEV
		ldb	#tblVectorsSize
1		stx	,Y++
		leax	3,X
		decb
		bne	1B

		; Get base address for extended vectors into X
		lda	#$A8				; copy extended vectors
		jsr	osbyte_X0YFF

		ldx	#EXT_FILEV
		leay	tblExtendedVectors,PCR
		ldb	#tblVectorsSize
		lda	zp_mos_curROM
1		ldu	,Y++				; get entry point
		stu	,X++				; store entry point
		sta	,X+				; store our ROM#
		decb
		bne	1B

		lda	#$1B+3*tblVectorsSize		; note sure whether this value matters ???

		sta	sws_CurrentCat			; curdrvcat<>0
		sta	sws_Query1			; ?
		clr	DP_FSW_CurrentDrv		; curdrv=0
		clr	sws_VINC_state			; Uninitialised

		ldx	#SERVICE_F_FSVEC_CLAIMED	; vectors claimed!
		jsr	osbyte_143_svc_req
	
		; If soft break and pws "full" and not booting a disk
		; then copy pws to sws
		; else reset fs to defaults.
	
		jsr	SetPrivateWorkspacePointerB0
		ldx	DP_FS_RELWKSP

		lda	offs_ForceReset,X		; A=PWSP+$D3 (-ve=soft break)
		bpl	initdfs_reset			; Branch if power up or hard break

		lda	offs_PriWkspFull,X			; A=PWSP+$D4
		bmi	initdfs_noreset		; Branch if PWSP "empty"

		jsr	ClaimStaticWorkspace

		; restore Static Workspace from Private Workspace
		; copy 
		; (sws data 10C0-10EF, and 1100-11BF)

		ldy	#MA+$1100
		ldw	#$C0
		tfm	X+,Y+				; copy 1100-11BF from PWS
		ldy	#sws_vars_10C0
		ldw	#$30
		tfm	X+,Y+				; copy 10C0-11EF from PWS

		** Check VID CRC and if wrong reset filing system
		jsr	CalculateCRC7
		cmpa	VID_CHECK_CRC7
		bne	setdefaults


	
		ldy	#$A0				; Refresh channel block info
setchansloop
		tfr	Y,D
		stb	sws_Channel_SecHi,Y		; Buffer sector hi?
		lda	#$3F
		jsr	ChannelFlags_ClearBits		; Clear bits 7 $ 6, C=0
		leay	-$20,Y
		bne	setchansloop
		bra	initdfs_noreset			; always


	
		; Initialise SWS (Static Workspace)
	
initdfs_reset
		DEBUG_PRINT_STR "initdfs_reset"
		jsr	ClaimStaticWorkspace
setdefaults
		jsr	FSDefaults
	
		; INITIALISE VID VARIABLES
		; Don't reset if booting
	
		jsr	VIDRESET
	
initdfs_noreset
		DEBUG_PRINT_STR "initdfs_noreset"
		jsr	TUBE_CheckIfPresent		; Tube present?
	
		tst	,S+				; Get back boot flag
		bne	initdfs_exit			; branch if not boot file
	
		jsr	LoadCurDrvCat
		LDA	sws_Cat_OPT			; Get boot option
		JSR	A_rorx4
		BNE	notOPT0				; branch if not opt.0
	
initdfs_exit
		pulsw
		puls	U,PC				; ??? check!


		TODOCMD	"notOPT0"				; BOOT!
 **			
 **				\ Assumes cmd strings all in same page!
 **			.notOPT0
 **				LDY #HI(BootOptions)		; boot file?
 **				LDX #LO(BootOptions)		; ->L.!BOOT
 **				CMP #$02
 **				BCC jmpOSCLI			; branch if opt 1
 **				BEQ oscliOPT2			; branch if opt 2
 **				IF HI(BootOptions+8)<>HI(BootOptions)
 **					LDY #HI(BootOptions+8)
 **				ENDIF
 **				LDX #LO(BootOptions+8)		; ->E.!BOOT
 **				BNE jmpOSCLI			; always
 **			.oscliOPT2
 **				IF HI(BootOptions+10)<>HI(BootOptions)
 **					LDY #HI(BootOptions+10)
 **				ENDIF
 **				LDX #LO(BootOptions+10)		; ->!BOOT
 **			.jmpOSCLI
 **				JMP OSCLI
 **			}
 **			

***********************************************************************
FSDefaults
***********************************************************************
		lda	#'$'
		sta	sws_default_dir
		sta	sws_lib_dir
		lda	#3
		sta	sws_lib_drive
		lda	#$00
		sta	sws_default_drive
		sta	sws_OpenFlags
	
		deca				; Y=$FF
		sta	sws_CMDenabledIf1
		sta	sws_FSmessagesIf0
		sta	sws_error_flag_qry
		rts

	
VIDRESET				; Reset VID
		DEBUG_PRINT_STR "VIDRESET"
		ldb	#VID_CHECK_CRC7-VID
		ldx	#VID
		clra
1		sta	B,X
		decb
		bpl	1B
		lda	#1
		sta	VID_CHECK_CRC7
		rts
 **			
 **			IF _DEBUG
 **			.PrintAXY
 **				PHA
 **				JSR PrintString
 **				EQUB "A="
 **				NOP
 **				JSR PrintHex
 **				JSR PrintString
 **				EQUB ";X="
 **				NOP
 **				TXA
 **				JSR PrintHex
 **				JSR PrintString
 **				EQUB ";Y="
 **				NOP
 **				TYA
 **				JSR PrintHex
 **				JSR PrintString
 **				EQUB 13
 **				NOP
 **				PLA
 **				RTS
 **			ENDIF
rom_handle_service_calls
 **			{
 **			IF _DEBUG
 **				PHA
 **				JSR PrintString
 **				EQUB "Service "
 **				NOP
 **				JSR PrintAXY
 **				PLA
 **			ENDIF
 **			IF _TUBEHOST_
 **				JSR SERVICE09_TUBEHelp		; Tube service calls
 **			ENDIF
 **			
 		ldy	#swrom_wksp_tab
		tst	B,Y
		bmi	SVC_NULL			; if bit 7 set ROM is disabled
		
		cmpa	#SERVICE_12_INITFS
		beq	SVC_initfs
		cmpa	#SERVICE_A_ABSWKSP_CLAIM
		bhi	SVC_NULL
		asla
		ldy	#tblServiceCallDispatch
		leay	A,Y
		lsra
		jmp	[,Y]
SVC_NULL
 		rts
 **			
 **			
		TODOCMD "SVC_initfs"
 **			.SVC_initfs		; A=$12 Initialise filing system
 **				BP12K_NEST
 **				CPY #FILE_SYS_NO			; Y=ID no. (4=dfs etc.)
 **				BNE label3
 **				JSR RememberAXY
 **				JMP CMD_CARD
 **			}
 **			
SVC_1_abswksp_req					; A=1 Claim absolute workspace
		cmpx	#$17				; X=current upper limit (page #)
		bhs	1F
		ldx	#$17				; Up upper limit to $17
1		rts

SVC_2_relwksp_req					; A=2 Claim private workspace, X=First available page#
		tfr	X,D
		exg	A,B
 		std	DP_FS_RELWKSP			; Set (B0/1) as pointer to PWSP
 		ldb	zp_mos_curROM
 		ldx	#swrom_wksp_tab
 		lda	B,X				; Get current rel pointer for this ROM
 		pshs	A
		anda	#$40				; preserve any flag in bit 6
		ora	DP_FS_RELWKSP
		sta	B,X				; Store back in table
		puls	A
		cmpa	DP_FS_RELWKSP			; Private workspace may have moved!
		beq	samepage			; If same as before
		ldx	DP_FS_RELWKSP
		clr	offs_ForceReset,X		; flag reset in private workspace offset D3
samepage			
		lda	#$FD				; Read hard/soft BREAK
		jsr	osbyte_X0YFF			; X=0=soft,1=power up,2=hard
		tfr	X,D
		decb					; A= FF=soft,0=power up,1=hard
		ldx	DP_FS_RELWKSP
		andb	offs_ForceReset,X
		stb	offs_ForceReset,X		; So, PWSP?$D3 is +ve if:
							; power up, hard reset or PSWP page has changed
		bpl	notsoft				; If not soft break
	
		lda	offs_PriWkspFull		; A=PWSP?$D4
		bpl	notsoft				; If PWSP "full"
	
		; If soft break and pws is empty then I must have owned sws,
		; so copy it to my pws.
		jsr	SaveStaticToPrivateWorkspace	; Copy valuable data to PWSP
notsoft
		clr	offs_PriWkspFull,X		; PWSP?$D4=0 = PWSP "full"
		ldb	DP_FS_RELWKSP			; get back original Y (page #)
		addb	#2				; reserve 2 pages (1 for FS one for UTILS)
		clra
		tfr	D,X				; X return value
		ldb	zp_mos_curROM			; restore X $ A, Y=Y+2
		rts

***********************************************************************
SVC_3_autoboot			; A=3 Autoboot
***********************************************************************
;;		BP12K_NEST
;;		JSR RememberAXY
		pshs	D,X,Y
		tfr	X,D
		stb	DP_FS_SAVEYAUTOBOOT		; if X=0 then !BOOT
		lda	#$7A				; Keyboard scan
		jsr	OSBYTE				; X=int.key.no
		tfr	X,D
		tstb
		bmi	AUTOBOOT			; nothing pressed jump forwards
		cmpb	#'U'				; "U" KEY
		bne	1F				; exit
		lda	#$78				; write current keys pressed info
		jsr	OSBYTE
***********************************************************************
AUTOBOOT
; we ended up here because either shift-break or U pressed at break
***********************************************************************
		ldx	#strBootMessage
		jsr	PrintStringX
		lda	zp_mos_curROM
		jsr	PRHEX
		jsr	OSNEWL

		lda	DP_FS_SAVEYAUTOBOOT		; ?$B3=value of Y on call 3
		jsr	initMMFS
		clr	,S
1		puls	D,X,Y,PC

***********************************************************************
SVC_4_ukcmd			; A=4 Unrec Command, X=command pointer
***********************************************************************
		pshs	A,X,Y
		DEBUG_PRINT_STR "->SVC_4_ukcmd"
		ldy	#tblSelectCommands
		jsr	UnrecCommandTextPointerAPI
		beq	1F
		DEBUG_PRINT_STR "<-SVC_4_ukcmd (not handled)"
		puls	A,X,Y,PC
1
		DEBUG_PRINT_STR "<-SVC_4_ukcmd (handled)"
		clr	,S
		puls	A,X,Y,PC

CMD_notFound_tblSelect
		DEBUG_PRINT_STR "--CMD_notFound_tblSelect"
		ldy	#tblUtilsCommands
		jmp	UnrecCommandTextPointerAPI


		TODOCMD	"SVC_8_ukosword"
 **			.SVC_8_ukosword
 **			{
 **				BP12K_NEST
 **				JSR RememberAXY
 **			
 **				LDY $EF				; Y = Osword call
 **				BMI exit			; Y > $7F
 **				CPY #$7D
 **				BCC exit			; Y < $7D
 **			
 **				JSR ReturnWithA0
 **			
 **				JSR FSisMMFS			; MMFS current fs?
 **				BNE exit
 **			
 **				LDX $F0				; Osword X reg
 **				STX $B0
 **				LDX $F1				; Osword Y reg
 **				STX $B1
 **			
 **				LDY $EF
 **				INY
 **				BPL notOSWORD7F
 **				PHP
 **				CLI
 **				JSR Osword7F_8271_Emulation	; OSWORD $7F 8271 emulation
 **				PLP
 **				RTS
 **			
 **			.notOSWORD7F
 **				JSR Set_CurDirDrv_ToDefaults
 **				JSR LoadCurDrvCat2		; Load catalogue
 **				INY
 **				BMI OSWORD7E
 **				LDY #$00			; OSWORD $7D return cycle no.
 **				LDA MA+$0F04
 **				STA ($B0),Y
 **			.exit	RTS
 **			
 **			.OSWORD7E
 **				LDA #$00			; OSWORD $7E
 **				TAY
 **				STA ($B0),Y
 **				INY
 **				LDA MA+$0F07			; sector count LB
 **				STA ($B0),Y
 **				INY
 **				LDA sws_Cat_OPT			; sector count HB
 **				AND #$03
 **				STA ($B0),Y
 **				INY
 **				LDA #$00			; result
 **				STA ($B0),Y
 **				RTS
 **			}
 **			
 **			

SVC_9_help						; A=9 *HELP
		pshs	D,X,Y
		jsr	help_check_end
		beq	1F
2		ldy	#tblHelpCommands
		jsr	UnrecCommandTextPointerAPI
		jsr	help_check_end
		bne	2B
		puls	D,X,Y,PC
1		ldy	#tblHelpCommands + 1
		jsr	Prthelp_Ytable_API
		puls	D,X,Y,PC
help_check_end	jsr	GSINIT_A
		lda	,X
		cmpa	#$0D
		rts

***********************************************************************
SVC_A_claimabswksp
***********************************************************************
		pshs	B,X,Y
		DEBUG_PRINT_STR "->SVC_A_claimabswksp"

		; Do I own sws?
		jsr	SetPrivateWorkspacePointerB0
		ldx	DP_FS_RELWKSP
		ldb	offs_PriWkspFull
		abx
		tst	,X
		bpl	1F				; If pws "full" then sws is not mine
		pshs	X
		clrb		
		DEBUG_PRINT_STR "--SaveStatic"			
		jsr	ChannelBufferToDisk_Bhandle_API ; flush all files out to disk
		jsr	SaveStaticToPrivateWorkspace	; copy valuable data to private wsp
		clra					; return A=0 to indicate we responded
		sta	[,S++]				; clear private full (pointer stacked earlier)
1
		DEBUG_PRINT_STR "<-SVC_A_claimabswksp"
		puls	B,X,Y,PC
 **			
 **			IF _MASTER_
 **			
 **			.SERVICE21_ClaimHiddenSWS
 **			{
 **				CPY #$CA
 **				BCS ok
 **				LDY #$CA
 **			.ok	RTS
 **			}
 **			
 **			.SERVICE22_ClaimHiddenPWS
 **				TYA
 **				STA swrom_wksp_tab,X
 **				LDA #$22
 **				INY
 **				RTS
 **			
 **			.SERVICE24_RequiredPWS
 **				DEY
 **				RTS
 **			
 **			.SERVICE25_fs_info
 **			{
 **				LDX #$A
 **			.srv25_loop
 **				LDA fsinfo,X
 **				STA (TextPointer),Y
 **				INY
 **				DEX
 **				BPL srv25_loop
 **			
 **				LDA #$25
 **				LDX PagedRomSelector_RAMCopy
 **				RTS
 **			
 **			.fsinfo
 **				EQUB FILE_SYS_NO
 **				EQUB FILEHANDLE_MIN+5
 **				EQUB FILEHANDLE_MIN+1
 **				EQUS "    SFMM"
 **			}
 **			
 **			.SERVICE27_Reset
 **			{
 **				PHA
 **				TXA
 **				PHA
 **				TYA
 **				PHA
 **				LDA #$FD
 **				LDX #$00
 **				LDY #$FF
 **				JSR OSBYTE
 **				CPX #$00
 **				BEQ srv27_softbreak
 **				\ If this is not done, you get a Bad Sum error with autoboot on power on
 **				JSR VIDRESET
 **			.srv27_softbreak
 **				PLA
 **				TAY
 **				PLA
 **				TAX
 **				PLA
 **				RTS
 **			}
 **			ENDIF	; End of MASTER ONLY service calls
 **			
 **				\ Test if MMFS by checking first file handle
 **			.FSisMMFS
 **			{
 **				LDA #7
 **				JSR fsc
 **				CPX #FILEHANDLE_MIN+1
 **				RTS
 **			
 **			.fsc	JMP (FSCV)
 **			}
 **			
 **			
***********************************************************************
FILEV_ENTRY
***********************************************************************
		pshs	D,X,Y,U
		jsr	parameter_fsp

		stx	DP_B0_FILEV_PARAM_PTR		; X -> parameter block
		stx	sws_param_ptr
	
		ldu	,x++				; filename ptr
		stu	DP_BA_FILEV_FNAME_PTR		; BA->filename
		
		ldy	#DP_BC_FILEV_LOAD		; BC $ 1074=load addr (32 bit)
		ldu	#sws_FILEV_LOAD_highord		; BE $ 1076=exec addr
		ldb	#4				; C0 $ 1078=start addr
1		jsr	Copy32ADDRtoDPandHO		; C2 $ 107A=end addr
		decb					; (lo word in zp, hi in page 10)
		bne	1B

		lda	,S+				; get back A code
		inca
		cmpa	#8
		bhs	filev_unknownop
		asla
		ldx	#tblFILEVops
		jsr	[A,X]				; enter subroutine
		puls	B,X,Y,U,PC			; return A from subroutine
filev_unknownop
		clra
		puls	B,X,Y,U,PC			; return A from subroutine

***********************************************************************
FSCV_ENTRY
***********************************************************************
		cmpa	#$0C
		bhs	gbpbv_unrecop
		leas	-2,S				; reserve space jump address on stack
		stx	,--S				; push X
		asla
		ldx	#tblFSCVoper
		ldx	A,X				; get fn address
		stx	2,S				; push onto stack as return address
		lsra					; restore A
		puls	X,PC				; restore X and jump to function

gbpbv_unrecop
		RTS
 **		
 		TODOCMD "GBPBV_ENTRY"
 **			.GBPBV_ENTRY
 **			{
 **				CMP #$09
 **				BCS gbpbv_unrecop
 **				JSR RememberAXY
 **				JSR ReturnWithA0
 **				STX MA+$107D
 **				STY MA+$107E
 **				TAY
 **				JSR gbpb_gosub
 **				PHP
 **				BIT MA+$1081
 **				BPL gbpb_nottube
 **				JSR TUBE_RELEASE_NoCheck
 **			.gbpb_nottube
 **				PLP
 **				RTS
 **			}
 **			
 **			.gbpb_gosub
 **			{
 **				LDA gbpbv_table1,Y
 **				STA MA+$10D7
 **				LDA gbpbv_table2,Y
 **				STA MA+$10D8
 **				LDA gbpbv_table3,Y		; 3 bit flags: bit 2=tube op
 **				LSR A
 **				PHP 				; Save bit 0 (0=write new seq ptr)
 **				LSR A
 **				PHP 				; Save bit 1 (1=read/write seq ptr)
 **				STA MA+$107F			; Save Tube operation
 **				JSR gbpb_wordB4_word107D	; (B4) -> param blk
 **				LDY #$0C
 **			.gbpb_ctlblk_loop
 **				LDA ($B4),Y			; Copy param blk to 1060
 **				STA MA+$1060,Y
 **				DEY
 **				BPL gbpb_ctlblk_loop
 **				LDA MA+$1063			; Data ptr bytes 3 $ 4
 **				AND MA+$1064
 **				ORA sws_TubePresentIf0
 **				CLC
 **				ADC #$01
 **				BEQ gbpb_nottube1		; If not tube
 **				JSR TUBE_CLAIM
 **				CLC
 **				LDA #$FF
 **			.gbpb_nottube1
 **				STA MA+$1081			; GBPB to TUBE IF >=$80
 **				LDA MA+$107F			; Tube op: 0 or 1
 **				BCS gbpb_nottube2		; If not tube
 **				LDX #$61
 **				LDY #MP+$10
 **				JSR TUBE_CODE_QRY 			; (YX=addr,A=0:initrd,A=1:initwr,A=4:strexe) ; Init TUBE addr @ 1061
 **			.gbpb_nottube2
 **				PLP 				; Bit 1
 **				BCS gbpb_rw_seqptr
 **				PLP 				; Bit 0, here always 0
 **			}
 **			.gbpb_jmpsub
 **				JMP (MA+$10D7)
 **			
 **			.gbpb_rw_seqptr
 **			{
 **				LDX #$03			; GBPB 1,2,3 or 4
 **			.gbpb_seqptr_loop1
 **				LDA MA+$1069,X			; !B6=ctl blk seq ptr
 **				STA $B6,X
 **				DEX
 **				BPL gbpb_seqptr_loop1		; on exit A=file handle=?$1060
 **				LDX #$B6
 **				LDY MA+$1060
 **				LDA #$00
 **				PLP				; bit 0
 **				BCS gpbp_dontwriteseqptr
 **				JSR argsv_WriteSeqPointer	; If GBPB 1 $ 3
 **			.gpbp_dontwriteseqptr
 **				JSR argsv_rdseqptr_or_filelen	; read seq ptr to $B6
 **				LDX #$03
 **			.gbpb_seqptr_loop2
 **				LDA $B6,X			; ctl blk seq prt = !B6
 **				STA MA+$1069,X
 **				DEX
 **				BPL gbpb_seqptr_loop2
 **			}
 **			
 **			.gbpb_rwdata
 **			{
 **				JSR gbpb_bytesxferinvert	; Returns with N=1
 **				BMI gbpb_data_loopin		; always
 **			.gbpb_data_loop
 **				LDY MA+$1060			; Y=file handle
 **				JSR gbpb_jmpsub			; *** Get/Put BYTE
 **				BCS gbpb_data_loopout		; If a problem occurred
 **				LDX #$09
 **				JSR gbpb_incdblword1060X	; inc. seq ptr
 **			.gbpb_data_loopin
 **				LDX #$05
 **				JSR gbpb_incdblword1060X	; inc. bytes to txf
 **				BNE gbpb_data_loop
 **				CLC
 **			.gbpb_data_loopout
 **				PHP
 **				JSR gbpb_bytesxferinvert	; bytes to txf XOR $FFFFFFFF
 **				LDX #$05
 **				JSR gbpb_incdblword1060X	; inc. bytes to txf
 **				LDY #$0C	 		; Copy parameter back
 **				JSR gbpb_wordB4_word107D	; (B4) -> param blk
 **			.gbpb_restorectlblk_loop
 **				LDA MA+$1060,Y
 **				STA ($B4),Y
 **				DEY
 **				BPL gbpb_restorectlblk_loop
 **				PLP 				; C=1=txf not completed
 **				RTS 				; **** END GBPB 1-4
 **			}
 **			
 **				\\ READ FILENAMES IN CURRENT CAT
 **			.gbpb8_rdfilescurdir
 **				JSR Set_CurDirDrv_ToDefaults	; GBPB 8
 **				JSR CheckCurDrvCat
 **				LDA #LO(gbpb8_getbyte)
 **				STA MA+$10D7
 **				LDA #HI(gbpb8_getbyte)
 **				STA MA+$10D8
 **				BNE gbpb_rwdata			; always
 **			
 **			.gbpb8_getbyte
 **			{
 **				LDY MA+$1069			; GBPB 8 - Get Byte
 **			.gbpb8_loop
 **				CPY sws_Cat_Filesx8
 **				BCS gbpb8_endofcat		; If end of catalogue, C=1
 **				LDA MA+$0E0F,Y			; Directory
 **				JSR IsAlphaChar
 **				EOR DP_FSW_DirectoryParam
 **				BCS gbpb8_notalpha
 **				AND #$DF
 **			.gbpb8_notalpha
 **				AND #$7F
 **				BEQ gbpb8_filefound		; If in current dir
 **				JSR Y_add8
 **				BNE gbpb8_loop			; next file
 **			.gbpb8_filefound
 **				LDA #$07			; Length of filename
 **				JSR gbpb_gb_SAVEBYTE
 **				STA $B0				; loop counter
 **			.gbpb8_copyfn_loop
 **				LDA MA+$0E08,Y			; Copy fn
 **				JSR gbpb_gb_SAVEBYTE
 **				INY
 **				DEC $B0
 **				BNE gbpb8_copyfn_loop
 **				CLC 				; C=0=more to follow
 **			.gbpb8_endofcat
 **				STY MA+$1069			; Save offset (seq ptr)
 **				LDA MA+$0F04
 **				STA MA+$1060			; Cycle number (file handle)
 **				RTS 				; **** END GBPB 8
 **			}
 **			
 **			
 **				\\ GET MEDIA TITLE
 **			.gbpb5_getmediatitle
 **			{
 **				JSR Set_CurDirDrv_ToDefaults	; GBPB 5
 **				JSR CheckCurDrvCat
 **				LDA #$0C			; Length of title
 **				JSR gbpb_gb_SAVEBYTE
 **				LDY #$00
 **			.gbpb5_titleloop
 **				CPY #$08			; Title
 **				BCS gbpb5_titlehi
 **				LDA MA+$0E00,Y
 **				BCC gbpb5_titlelo
 **			.gbpb5_titlehi
 **				LDA MA+$0EF8,Y
 **			.gbpb5_titlelo
 **				JSR gbpb_gb_SAVEBYTE
 **				INY
 **				CPY #$0C
 **				BNE gbpb5_titleloop
 **				LDA sws_Cat_OPT			; Boot up option
 **				JSR A_rorx4
 **				JSR gbpb_gb_SAVEBYTE
 **				LDA DP_FSW_CurrentDrv			; Current drive
 **				JMP gbpb_gb_SAVEBYTE
 **			}
 **			
 **				\\ READ CUR DRIVE/DIR
 **			.gbpb6_rdcurdirdevice
 **				JSR gbpb_SAVE_01		; GBPB 6
 **				LDA sws_default_drive		; Length of dev.name=1
 **				ORA #$30			; Drive no. to ascii
 **				JSR gbpb_gb_SAVEBYTE
 **				JSR gbpb_SAVE_01		; Lendgh of dir.name=1
 **				LDA sws_default_dir			; Directory
 **				BNE gbpb_gb_SAVEBYTE
 **			
 **				\\ READ LIB DRIVE/DIR
 **			.gbpb7_rdcurlibdevice
 **				JSR gbpb_SAVE_01		; GBPB 7
 **				LDA sws_lib_drive			; Length of dev.name=1
 **				ORA #$30			; Drive no. to ascii
 **				JSR gbpb_gb_SAVEBYTE
 **				JSR gbpb_SAVE_01		; Lendgh of dir.name=1
 **				LDA sws_lib_dir			; Directory
 **				BNE gbpb_gb_SAVEBYTE
 **			
 **			.gpbp_B8memptr
 **				PHA	 			; Set word $B8 to
 **				LDA MA+$1061			; ctl blk mem ptr (host)
 **				STA $B8
 **				LDA MA+$1062
 **				STA $B9
 **				LDX #$00
 **				PLA
 **				RTS
 **			
 **			.gbpb_incDataPtr
 **				JSR RememberAXY			; Increment data ptr
 **				LDX #$01
 **			.gbpb_incdblword1060X
 **			{
 **				LDY #$04			; Increment double word
 **			.gbpb_incdblword_loop
 **				INC MA+$1060,X
 **				BNE gbpb_incdblworkd_exit
 **				INX
 **				DEY
 **				BNE gbpb_incdblword_loop
 **			.gbpb_incdblworkd_exit
 **				RTS
 **			}
 **			
 **			.gbpb_bytesxferinvert
 **			{
 **				LDX #$03			; Bytes to tranfer XOR $FFFF
 **			.gbpb_bytesxferinvert_loop
 **				LDA #$FF
 **				EOR MA+$1065,X
 **				STA MA+$1065,X
 **				DEX
 **				BPL gbpb_bytesxferinvert_loop
 **				RTS
 **			}
 **			
 **			.gbpb_wordB4_word107D
 **				LDA MA+$107D
 **				STA $B4
 **				LDA MA+$107E
 **				STA $B5
 **			.gpbp_exit
 **				RTS
 **			
 **			.gbpb_SAVE_01
 **				LDA #$01
 **				BNE gbpb_gb_SAVEBYTE		; always
 **			.gbpb_getbyteSAVEBYTE
 **				JSR BGETV_ENTRY
 **				BCS gpbp_exit			; If EOF
 **			.gbpb_gb_SAVEBYTE
 **				BIT MA+$1081
 **				BPL gBpb_gb_fromhost
 **				STA TUBE_R3_DATA		; fast Tube Bget
 **				BMI gbpb_incDataPtr
 **			.gBpb_gb_fromhost
 **				JSR gpbp_B8memptr
 **				STA ($B8,X)
 **				JMP gbpb_incDataPtr
 **			.gbpb_putbytes
 **				JSR gpbp_pb_LOADBYTE
 **				JSR BPUTV_ENTRY
 **				CLC
 **				RTS 				; always ok!
 **			.gpbp_pb_LOADBYTE
 **				BIT MA+$1081
 **				BPL gbpb_pb_fromhost
 **				LDA TUBE_R3_DATA		; fast Tube Bput
 **				JMP gbpb_incDataPtr
 **			.gbpb_pb_fromhost
 **				JSR gpbp_B8memptr
 **				LDA ($B8,X)
 **				JMP gbpb_incDataPtr
 **			
 **			
***********************************************************************
fscv8_osabouttoproccmd
***********************************************************************
		tst	sws_CMDenabledIf1
		bmi	parameter_fsp
		dec	sws_CMDenabledIf1
***********************************************************************
parameter_fsp
***********************************************************************
		lda	#$FF
		sta	sws_fsp_match_STAR
***********************************************************************
param_out
***********************************************************************
		sta	sws_fsp_match_HASH
		rts
***********************************************************************
parameter_afsp
***********************************************************************
		lda	#'*'	; "*"
		sta	sws_fsp_match_STAR
		lda	#'#'	; "#"
		bne	param_out
	
		TODOCMD "osfile5_rdcatinfo"
 **			.osfile5_rdcatinfo
 **				JSR CheckFileExists		; READ CAT INFO
 **				JSR ReadFileAttributesToX_YCat_API
 **				LDA #$01			; File type: 1=file found
 **				RTS
		TODOCMD "osfile6_delfile"
 **			.osfile6_delfile
 **				JSR CheckFileNotLocked		; DELETE FILE
 **				JSR ReadFileAttributesToX_YCat_API
 **				JSR DeleteCatEntry_YFileOffset
 **				BCC osfile_savecat_retA_1
		TODOCMD "osfile1_updatecat"
 **			.osfile1_updatecat
 **				JSR CheckFileExists		; UPDATE CAT ENTRY
 **				JSR osfile_update_loadaddr_Xoffset
 **				JSR osfile_update_execaddr_Xoffset
 **				BVC osfile_updatelocksavecat
		TODOCMD "osfile3_wrexecaddr"
 **			.osfile3_wrexecaddr
 **				JSR CheckFileExists		; WRITE EXEC ADDRESS
 **				JSR osfile_update_execaddr_Xoffset
 **				BVC osfile_savecat_retA_1
		TODOCMD "osfile2_wrloadaddr"
 **			.osfile2_wrloadaddr
 **				JSR CheckFileExists		; WRITE LOAD ADDRESS
 **				JSR osfile_update_loadaddr_Xoffset
 **				BVC osfile_savecat_retA_1
		TODOCMD "osfile4_wrattribs"
 **			.osfile4_wrattribs
 **				JSR CheckFileExists		; WRITE ATTRIBUTES
 **				JSR CheckFileNotOpenY
 **			.osfile_updatelocksavecat
 **				JSR osfile_updatelock
 **			.osfile_savecat_retA_1
 **				JSR jmp_savecattodisk
 **				LDA #$01
 **				RTS
 **			.osfile_update_loadaddr_Xoffset
 **				JSR RememberAXY			; Update load address
 **				LDY #$02
 **				LDA ($B0),Y
 **				STA MA+$0F08,X
 **				INY
 **				LDA ($B0),Y
 **				STA MA+$0F09,X
 **				INY
 **				LDA ($B0),Y
 **				ASL A
 **				ASL A
 **				EOR MA+$0F0E,X
 **				AND #$0C
 **				BPL osfile_savemixedbyte	; always
 **			.osfile_update_execaddr_Xoffset
 **				JSR RememberAXY			; Update exec address
 **				LDY #$06
 **				LDA ($B0),Y
 **				STA MA+$0F0A,X
 **				INY
 **				LDA ($B0),Y
 **				STA MA+$0F0B,X
 **				INY
 **				LDA ($B0),Y
 **				ROR A
 **				ROR A
 **				ROR A
 **				EOR MA+$0F0E,X
 **				AND #$C0
 **			.osfile_savemixedbyte
 **				EOR MA+$0F0E,X			; save mixed byte
 **				STA MA+$0F0E,X
 **				CLV
 **				RTS
 **			.osfile_updatelock
 **				JSR RememberAXY			; Update file locked flag
 **				LDY #$0E
 **				LDA ($B0),Y
 **				AND #$0A			; file attributes AUG pg.336
 **				BEQ osfile_notlocked
 **				LDA #$80			; Lock!
 **			.osfile_notlocked
 **				EOR MA+$0E0F,X
 **				AND #$80
 **				EOR MA+$0E0F,X
 **				STA MA+$0E0F,X
 **				RTS
 **			
 **			.CheckFileNotLocked
 **				JSR read_fspBA_findcatentry	; exit:X=Y=offset
 **				BCC ExitCallingSubroutine
 **			.CheckFileNotLockedY
 **				LDA MA+$0E0F,Y
 **				BPL chklock_exit
errFILELOCKED
		jsr	ReportErrorCB
		fcb	$C3, "Locked",0
 **			
 **			.CheckFileNotLockedOrOpenY
 **				JSR CheckFileNotLockedY
 **			.CheckFileNotOpenY
 **				JSR RememberAXY
 **				JSR IsFileOpen_Yoffset
 **				BCC checkexit
 **				JMP errFILEOPEN
 **			.CheckFileExists
 **				JSR read_fspBA_findcatentry	; exit:X=Y=offset
 **				BCS checkexit			; If file found
 **			.ExitCallingSubroutine
 **				PLA 				; Ret. To caller's caller
 **				PLA
 **				LDA #$00
 **			.chklock_exit
 **				RTS
 **			
 **			.read_fspBA_findcatentry
 **				JSR read_fspBA_reset
 **				JSR srch_cat_1000
 **				BCC checkexit
 **				TYA
 **				TAX 				; X=Y=offset
SetParamBlockPointerB0					; Ptr to OSFILE param block
		ldx	sws_param_ptr
		stx	DP_B0_FILEV_PARAM_PTR
		lda	MA+$10DB			
		sta	$B0
		lda	MA+$10DC
		sta	$B1
checkexit
		rts
 **			
 **				\ *** Calc amount of ram available ***
 **			.CalcRAM
 **				LDA #$83
 **				JSR OSBYTE			; YX=OSHWM (PAGE)
 **				STY PAGE
 **				LDA #$84
 **				JSR OSBYTE			; YX=HIMEM
 **				TYA
 **				SEC
 **				SBC PAGE
 **				STA RAMBufferSize		; HIMEM page-OSHWM page
 **				RTS
 **			
 **			IF NOT(_SWRAM_)
ClaimStaticWorkspace
		DEBUG_PRINT_STR "->ClaimStaticWorkspace"
		ldx	#SERVICE_A_ABSWKSP_CLAIM
		jsr	osbyte_143_svc_req			; Issue service request $A
		jsr	SetPrivateWorkspacePointerB0
		ldx	DP_FS_RELWKSP
		lda	#$FF
		sta	offs_ForceReset,X			; Data valid in SWS
		sta	offs_PriWkspFull,X			; Set pws is "empty"
		DEBUG_PRINT_STR "<-ClaimStaticWorkspace"
		rts
	
***********************************************************************
SetPrivateWorkspacePointerB0
***********************************************************************
		pshs	A,X				; Set word $B0 to
		clr	DP_FS_RELWKSP + 1		; clear low byte
		lda	zp_mos_curROM			; point to Private Workspace
		ldx	#swrom_wksp_tab
		lda	A,X
		anda	#$3F				; bits 7 $ 6 are used as flags
		sta	DP_FS_RELWKSP			; set high byte
		puls	A,X,PC
 **			
 **			
;; **			.osbyte0F_flushinbuf2
;; **				JSR RememberAXY
 **			.osbyte0F_flushinbuf
 **				LDA #$0F
 **				LDX #$01
 **				LDY #$00
 **				BEQ goOSBYTE			; always
 **			.osbyte03_Aoutstream
 **				TAX
osbyte03_Xoutstream
		lda	#$03
		bra	goOSBYTE			; always
osbyte7E_ackESCAPE2
		pshs	D,X,Y
		jsr	osbyte7E_ackESCAPE
		puls	D,X,Y,PC
osbyte7E_ackESCAPE
		lda	#$7E
		bra	goOSBYTE
osbyte_143_svc_req
		lda	#$8F
		bra	goOSBYTE
osbyte_X0YFF
		ldx	#$00
osbyte_YFF
		ldy	#$FFFF
goOSBYTE	jmp	OSBYTE
 **			

 **			
		TODOCMD "fscv7_hndlrange"
 **			.fscv7_hndlrange
 **				LDX #FILEHANDLE_MIN+1 ;11		; lowest hndl issued
 **				LDY #FILEHANDLE_MIN+5 ;15		; highest hndl poss.
 **			.closeallfiles_exit
 **				RTS
 **			
		TODOCMD "fscv6_shutdownfilesys"
 **			.fscv6_shutdownfilesys
 **				JSR RememberAXY
 **			IF _DEBUG
 **				JSR PrintString
 **				EQUB "Shutting down MMFS", 13
 **			ENDIF
 **			IF _MASTER_
 **				NOP
 **			   JSR CloseSPOOLEXECfiles
 **				JMP SVC_A_claimabswksp ; save static to private workspace
 **			ELSE
 **				;; fall through into CloseSPOOLEXECfiles
 **			ENDIF
 **			
 **			.CloseSPOOLEXECfiles
 **				LDA #$77			   ; Close any SPOOL or EXEC files
 **				JMP OSBYTE			; (Causes ROM serv.call $10)
 **			
 **				\ *CLOSE
		TODOCMD	"CMD_CLOSE"
 **			.CMD_CLOSE
 **				LDA #$20
 **				STA sws_updCatFlag_qry
 **			.CloseAllFiles_Osbyte77
 **				JSR CloseSPOOLEXECfiles
		TODOCMD "CloseAllFiles"
 **			{
 **				LDA #$00			; intch=intch+$20
 **			.closeallfiles_loop
 **				CLC
 **				ADC #$20
 **				BEQ closeallfiles_exit
 **				TAY
 **				JSR CloseFile_Yintch
 **				BNE closeallfiles_loop		; always
 **			}
 **			
		TODOCMD "CloseFiles_Bhandle_API"
 **				LDA #$20			; Update catalogue if write only
 **				STA sws_updCatFlag_qry
 **				TYA
 **				BEQ CloseAllFiles_Osbyte77	; If y=0 Close all files
 **				JSR CheckChannel_Yhndl_exYintch
 **			
 **			.CloseFile_Yintch
 **			{
 **				PHA 				; Save A
 **				JSR IsHndlinUse_Yintch		; (Saves X to $10C5)
 **				BCS closefile_exit		; If file not open
 **				LDA MA+$111B,Y			; bit mask
 **				EOR #$FF
 **				AND sws_OpenFlags
 **				STA sws_OpenFlags			; Clear 'open' bit
 **				LDA sws_ChannelFlags,Y			; A=flag byte
 **				AND #$60
 **				BEQ closefile_exit		; If bits 5$6=0
 **				JSR Channel_SetDirDrv_GetCatEntry_Yintch
 **				LDA sws_ChannelFlags,Y			; If file extended and not
 **				AND sws_updCatFlag_qry			; forcing buffer to disk
 **				BEQ closefile_buftodisk		; update the file length
 **				LDX MA+$10C3			; X=cat offset
 **				LDA MA+$1114,Y			; File lenth = EXTENT
 **				STA MA+$0F0C,X			; Len lo
 **				LDA MA+$1115,Y
 **				STA MA+$0F0D,X			; Len mi
 **				LDA MA+$1116,Y
 **				JSR A_rolx4			; Len hi
 **				EOR MA+$0F0E,X			; "mixed byte"
 **				AND #$30
 **				EOR MA+$0F0E,X
 **				STA MA+$0F0E,X
 **				JSR SaveCatToDisk		; Update catalog
 **				LDY MA+$10C2
 **			.closefile_buftodisk
 **				JSR ChannelBufferToDisk_Yintch	; Restores Y
 **			.closefile_exit
 **				LDX MA+$10C5			; Restore X (IsHndlInUse)
 **				PLA 				; Restore A
 **				RTS
 **			}
 **			
 **			.Channel_SetDirDrv_GetCatEntry_Yintch
 **				JSR Channel_SetDirDrive_Yintch
 **			.Channel_GetCatEntry_Yintch
 **			{
 **				LDX #$06			; Copy filename from
 **			.chnl_getcatloop
 **				LDA MA+$110C,Y			; channel info to $C5
 **				STA $C5,X
 **				DEY
 **				DEY
 **				DEX
 **				BPL chnl_getcatloop
 **				JSR srch_catfname
 **				BCC errDISKCHANGED		; If file not found
 **				STY MA+$10C3			; ?$10C3=cat file offset
 **				LDY MA+$10C2			; Y=intch
 **			}
 **			.chkdskchangexit
 **				RTS
 **			
 **			.Channel_SetDirDrive_Yintch
 **				LDA MA+$110E,Y			; Directory
 **				AND #$7F
 **				STA DP_FSW_DirectoryParam
 **				LDA sws_ChannelFlags,Y			; Drive
 **				JMP SetCurrentDrive_Adrive
 **			
 **			.CheckForDiskChange
 **				JSR RememberAXY
 **				LDA MA+$0F04
 **				JSR LoadCurDrvCat2
 **				CMP MA+$0F04
 **				BEQ chkdskchangexit		; If cycle no not changed!
 **			
errDISKCHANGED
		jsr	errDISK
		fcb	$C8, "changed",0
 **			
 **				\ OSFIND: A=$40 ro, $80 wo, $C0 rw
 		TODOCMD "FINDV_ENTRY"
 **			.FINDV_ENTRY
 **			{
 **				AND #$C0			; Bit 7=open for output
 **				BNE findvnot0_openfile		; Bit 6=open for input
 **				JSR RememberAXY
 **				JMP CloseFiles_Bhandle_API		; Close file #Y
 **			
 **			.findvnot0_openfile
 **				JSR RememberXYonly		; Open file
 **				STX $BA				; YX=Location of filename
 **				STY $BB
 **				STA $B4				; A=Operation
 **				BIT $B4
 **				PHP
 **				JSR read_fspBA_reset
 **				JSR parameter_fsp
 **				JSR srch_cat_1000
 **				BCS findv_filefound		; If file found
 **				PLP
 **				BVC findv_createfile		; If not read only = write only
 **				LDA #$00			; A=0=file not found
 **				RTS 				; EXIT
 **			
 **			.findv_createfile
 **				PHP 				; Clear data
 **				LDA #$00			; BC-C3=0
 **				LDX #$07			; 1074-107B=0
 **			.findv_loop1
 **				STA $BC,X
 **				STA MA+$1074,X
 **				DEX
 **				BPL findv_loop1
 **				DEC $BE
 **				DEC $BF
 **				DEC MA+$1076
 **				DEC MA+$1077
 **				LDA #$40
 **				STA $C3				; End address = $4000
 **				JSR CreateFile_FSP		; Creates 40 sec buffer
 **			.findv_filefound
 **				PLP 				; in case another file created
 **				PHP
 **				BVS findv_readorupdate		; If opened for read or update
 **				JSR CheckFileNotLockedY		; If locked report error
 **			.findv_readorupdate
 **				JSR IsFileOpen_Yoffset		; Exits with Y=intch, A=flag
 **				BCC findv_openchannel		; If file not open
 **			.findv_loop2
 **				LDA MA+$110C,Y
 **				BPL errFILEOPEN			; If already opened for writing
 **				PLP
 **				PHP
 **				BMI errFILEOPEN			; If opening again to write
 **				JSR IsFileOpenContinue		; ** File can only be opened  **
 **				BCS findv_loop2			; ** once if being written to **
 **			.findv_openchannel
 **				LDY MA+$10C2			; Y=intch
 **				BNE SetupChannelInfoBlock_Yintch
 **			
errTOOMANYFILESOPEN
		jsr	ReportErrorCB
		fcb	$C0, "Too many open",0
 **			}
 **			
errFILEOPEN
		jsr	ReportErrorCB
		fcb	$C2, "Open",0
 **			
 **			
 **			.SetupChannelInfoBlock_Yintch
 **			{
 **				LDA #$08
 **				STA MA+$10C4
 **			.chnlblock_loop1
 **				LDA MA+$0E08,X			; Copy file name $ attributes
 **				STA MA+$1100,Y			; to channel info block
 **				INY
 **				LDA MA+$0F08,X
 **				STA MA+$1100,Y
 **				INY
 **				INX
 **				DEC MA+$10C4
 **				BNE chnlblock_loop1
 **			
 **				LDX #$10
 **				LDA #$00			; Clear rest of block
 **			.chnlblock_loop2
 **				STA MA+$1100,Y
 **				INY
 **				DEX
 **				BNE chnlblock_loop2
 **			
 **				LDA MA+$10C2			; A=intch
 **				TAY
 **				JSR A_rorx5
 **				ADC #MP+$11
 **				STA MA+$1113,Y			; Buffer page
 **				LDA MA+$10C1
 **				STA MA+$111B,Y			; Mask bit
 **				ORA sws_OpenFlags
 **				STA sws_OpenFlags			; Set bit in open flag byte
 **				LDA MA+$1109,Y			; Length0
 **				ADC #$FF			; If Length0>0 C=1
 **				LDA MA+$110B,Y			; Length1
 **				ADC #$00
 **				STA MA+$1119,Y			; Sector count
 **				LDA MA+$110D,Y			; Mixed byte
 **				ORA #$0F
 **				ADC #$00			; Add carry flag
 **				JSR A_rorx4and3			; Length2
 **				STA MA+$111A,Y
 **				PLP
 **				BVC chnlblock_setBit5		; If not read = write
 **				BMI chnlblock_setEXT		; If updating
 **				LDA #$80			; Set Bit7 = Read Only
 **				ORA MA+$110C,Y
 **				STA MA+$110C,Y
 **			.chnlblock_setEXT
 **				LDA MA+$1109,Y			; EXTENT=file length
 **				STA MA+$1114,Y
 **				LDA MA+$110B,Y
 **				STA MA+$1115,Y
 **				LDA MA+$110D,Y
 **				JSR A_rorx4and3
 **				STA MA+$1116,Y
 **			.chnlblock_cont
 **				LDA DP_FSW_CurrentDrv			; Set drive
 **				ORA sws_ChannelFlags,Y
 **				STA sws_ChannelFlags,Y
 **				TYA 				; convert intch to handle
 **				JSR A_rorx5
 **				ORA #FILEHANDLE_MIN 			; $10
 **				RTS 				; RETURN A=handle
 **			
 **			.chnlblock_setBit5
 **				LDA #$20			; Set Bit5 = Update cat file len
 **				STA sws_ChannelFlags,Y			; when channel closed
 **				BNE chnlblock_cont		; always
 **			}
 **			
 **			
 **			.IsFileOpenContinue
 **				TXA 				; Continue looking for more
 **				PHA 				; instances of file being open
 **				JMP fop_nothisfile
 **			
 **			.IsFileOpen_Yoffset
 **				LDA #$00
 **				STA MA+$10C2
 **				LDA #$08
 **				STA $B5				; Channel flag bit
 **				TYA
 **				TAX 				; X=cat offset
 **				LDY #$A0			; Y=intch
 **			.fop_main_loop
 **				STY $B3
 **				TXA 				; save X
 **				PHA
 **				LDA #$08
 **				STA $B2				; cmpfn_loop counter
 **				LDA $B5
 **				BIT sws_OpenFlags
 **				BEQ fop_channelnotopen		; If channel not open
 **				LDA sws_ChannelFlags,Y
 **				EOR DP_FSW_CurrentDrv
 **				AND #$03
 **				BNE fop_nothisfile		; If not current drv?
 **			.fop_cmpfn_loop
 **				LDA MA+$0E08,X			; Compare filename
 **				EOR MA+$1100,Y
 **				AND #$7F
 **				BNE fop_nothisfile
 **				INX
 **				INY
 **				INY
 **				DEC $B2
 **				BNE fop_cmpfn_loop
 **				SEC
 **				BCS fop_matchifCset		; always
 **			.fop_channelnotopen
 **				STY MA+$10C2			; Y=intch = allocated to new channel
 **				STA MA+$10C1			; A=Channel Flag Bit
 **			.fop_nothisfile
 **				SEC
 **				LDA $B3
 **				SBC #$20
 **				STA $B3				; intch=intch-$20
 **				ASL $B5				; flag bit << 1
 **				CLC
 **			.fop_matchifCset
 **				PLA 				; restore X
 **				TAX
 **				LDY $B3				; Y=intch
 **				LDA $B5				; A=flag bit
 **				BCS fop_exit
 **				BNE fop_main_loop		; If flag bit <> 0
 **			.fop_exit
 **				RTS 				; Exit: A=flag Y=intch
 **			
 **			



ChannelBufferToDisk_Bhandle_A0_API
		jsr	ChannelBufferToDisk_Bhandle_API
		clra
		rts
***********************************************************************
ChannelBufferToDisk_Bhandle_API
	; Old API - file handle in Y
	; New API = file handle in B

	; Remarks - appears to close all files but keeps the file 
	; handle flags marked as opened, used to flush files to disk
	; before sws is released
***********************************************************************
		lda	sws_OpenFlags			; Force buffer save
		pshs	A				; Save opened channels flag byte
		clra					; Don't update catalogue
		sta	sws_updCatFlag_qry
		tstb					; check if handle or close all
		bne	chbuf1
		jsr	CloseAllFiles			; no file specified close everything
		beq	chbuf2				; always
chbuf1		jsr	CloseFiles_Bhandle_API		; close just the specifed file
chbuf2		puls	A				; Restore open files flags
		sta	sws_OpenFlags			; 
		rts
 **			.ReturnWithA0
 **				PHA 				; Sets the value of A
 **				TXA 				; restored by RememberAXY
 **				PHA 				; after returning from calling
 **				LDA #$00			; sub routine to 0
 **				TSX
 **				STA $0109,X
 **				PLA
 **				TAX
 **				PLA
 **				RTS
		TODOCMD "ARGSV_ENTRY"
 **			.ARGSV_ENTRY
 **			{
 **				JSR RememberAXY
 **				CMP #$FF
 **				BEQ ChannelBufferToDisk_Bhandle_API_A0	; If file(s) to media
 **				CPY #$00
 **				BEQ argsv_Y0
 **				CMP #$03
 **				BCS argsv_exit			; If A>=3
 **				JSR ReturnWithA0
 **				CMP #$01
 **				BNE argsv_rdseqptr_or_filelen
 **				JMP argsv_WriteSeqPointer
 **			
 **			.argsv_Y0
 **				CMP #$02			; If A>=2
 **				BCS argsv_exit
 **				JSR ReturnWithA0
 **				BEQ argsv_filesysnumber		; If A=0
 **				LDA #$FF
 **				STA $02,X			; 4 byte address of
 **				STA $03,X			; "rest of command line"
 **				LDA MA+$10D9			; (see *run code)
 **				STA $00,X
 **				LDA MA+$10DA
 **				STA $01,X
 **			.argsv_exit
 **				RTS
 **			
 **			.argsv_filesysnumber
 **				LDA #FILE_SYS_NO			; on exit: A = filing system
 **				TSX
 **				STA $0105,X
 **				RTS
 **			}
 **			
 **			.argsv_rdseqptr_or_filelen
 **				JSR CheckChannel_Yhndl_exYintch	; A=0 OR A=2
 **				STY MA+$10C2
 **				ASL A				; A becomes 0 or 4
 **				ADC MA+$10C2
 **				TAY
 **				LDA MA+$1110,Y
 **				STA $00,X
 **				LDA MA+$1111,Y
 **				STA $01,X
 **				LDA MA+$1112,Y
 **				STA $02,X
 **				LDA #$00
 **				STA $03,X
 **				RTS
 **			
 **			.IsHndlinUse_Yintch
 **			{
 **				PHA				; Save A
 **				STX MA+$10C5			; Save X
 **				TYA
 **				AND #$E0
 **				STA MA+$10C2			; Save intch
 **				BEQ hndlinuse_notused_C1
 **				JSR A_rorx5			; ch.1-7
 **				TAY				; creat bit mask
 **				LDA #$00			; 1=1000 0000
 **				SEC				; 2=0100 0000 etc
 **			.hndlinsue_loop
 **				ROR A
 **				DEY
 **				BNE hndlinsue_loop
 **				LDY MA+$10C2			; Y=intch
 **				BIT sws_OpenFlags			; Test if open
 **				BNE hndlinuse_used_C0
 **			.hndlinuse_notused_C1
 **				PLA
 **				SEC
 **				RTS
 **			.hndlinuse_used_C0
 **				PLA
 **				CLC
 **				RTS
 **			}
 **			
 **			

;TODO: check this is right I suspect the logic, it should be bls for at least first? i.e. should allow min+1..min+7
***********************************************************************
conv_mosfh_to_intch_B_API
	; OLD api on entry	Y=handle
	;	  on exit	Y=intch or Y=0, C=1 if out of range
	; NEW api on entry 	B=handle
	;	  on exit	B=intch or B=0, C=1 if out of range
	; NB: assume that bit 3 is NOT set in FILEHANDLE_MIN
***********************************************************************
		cmpb	#FILEHANDLE_MIN			; file
		blo	conv_hndl10
		cmpb	#FILEHANDLE_MIN+8
		blo	conv_hndl18
conv_hndl10
		ldb	#$08			; exit with C=1,A=0	;intch=0
conv_hndl18
		aslb
		aslb
		aslb
		aslb
		aslb				; either C=1,B=0 if b=8 or C=0, B=B*$20
		rts				; c=1 if not valid

		TODOCMD "ClearEXECSPOOLFileHandle"
 **			.ClearEXECSPOOLFileHandle
 **			{
 **				LDA #$C6
 **				JSR osbyte_X0YFF		; X = *EXEC file handle
 **				TXA
 **				BEQ ClearSpoolhandle		; branch if no handle allocated
 **				JSR ConvertXhndl_exYintch
 **				BNE ClearSpoolhandle		; If Y<>?10C2
 **				LDA #$C6			; Clear *EXEC file handle
 **				BNE osbyte_X0Y0
 **			
 **			.ClearSpoolhandle
 **				LDA #$C7			; X = *SPOOL handle
 **				JSR osbyte_X0YFF
 **				JSR ConvertXhndl_exYintch
 **				BNE clrsplhndl_exit		; If Y<>?10C2
 **				LDA #$C7			; Clear *SPOOL file handle
 **			.osbyte_X0Y0
 **				LDX #$00
 **				LDY #$00
 **				JMP OSBYTE
 **			
 **			.ConvertXhndl_exYintch
 **				TXA
 **				TAY
 **				JSR conv_mosfh_to_intch_B_API
 **				CPY MA+$10C2			; Owner?
 **			.clrsplhndl_exit
 **				RTS
 **			}
 **			
		TODOCMD "fscv1_EOF_Yhndl"
 **			.fscv1_EOF_Yhndl
 **			{
 **				PHA
 **				TYA
 **				PHA
 **				TXA
 **				TAY
 **				JSR CheckChannel_Yhndl_exYintch
 **				TYA
 **				JSR CmpPTR			; X=Y
 **				BNE eof_NOTEND
 **				LDX #$FF			; exit with X=FF
 **				BNE eof_exit
 **			.eof_NOTEND
 **				LDX #$00			; exit with X=00
 **			.eof_exit
 **				PLA
 **				TAY
 **				PLA
 **			}
 **			.checkchannel_okexit
 **				RTS
 **			
 **			.CheckChannel_Yhndl_exYintch
 **				JSR conv_mosfh_to_intch_B_API
 **				JSR IsHndlinUse_Yintch
 **				BCC checkchannel_okexit
 **				JSR ClearEXECSPOOLFileHandle	; Next sub routine also calls this!
 **			
errCHANNEL
		jsr	ReportErrorCB
		fcb	$DE, "Channel",0
errEOF
		jsr	ReportErrorCB
		fcb	$DF, "EOF",0
 **			
		TODOCMD "BGETV_ENTRY"
 **			.BGETV_ENTRY
 **			{
 **				JSR RememberXYonly
 **				JSR CheckChannel_Yhndl_exYintch
 **				TYA 				; A=Y
 **				JSR CmpPTR
 **				BNE bg_notEOF			; If PTR<>EXT
 **				LDA sws_ChannelFlags,Y			; Already at EOF?
 **				AND #$10
 **				BNE errEOF			; IF bit 4 set
 **				LDA #$10
 **				JSR ChannelFlags_SetBits	; Set bit 4
 **				LDX MA+$10C5
 **				LDA #$FE
 **				SEC
 **				RTS 				; C=1=EOF
 **			.bg_notEOF
 **				LDA sws_ChannelFlags,Y
 **				BMI bg_samesector1		; If buffer ok
 **				JSR Channel_SetDirDrive_Yintch
 **				JSR ChannelBufferToDisk_Yintch	; Save buffer
 **				SEC
 **				JSR ChannelBufferRW_Yintch_C1read	; Load buffer
 **			.bg_samesector1
 **				LDA MA+$1110,Y			; Seq.Ptr low byte
 **				STA $BA
 **				LDA MA+$1113,Y			; Buffer address
 **				STA $BB
 **				LDY #$00
 **				LDA ($BA),Y			; Byte from buffer
 **				PHA
 **				LDY MA+$10C2			; Y=intch
 **				LDX $BA
 **				INX
 **				TXA
 **				STA MA+$1110,Y			; Seq.Ptr+=1
 **				BNE bg_samesector2
 **				CLC
 **				LDA MA+$1111,Y
 **				ADC #$01
 **				STA MA+$1111,Y
 **				LDA MA+$1112,Y
 **				ADC #$00
 **				STA MA+$1112,Y
 **				JSR ChannelFlags_ClearBit7	; PTR in new sector!
 **			.bg_samesector2
 **				CLC
 **				PLA
 **				RTS				; C=0=NOT EOF
 **			}
 **			
 **			.CalcBufferSectorForPTR
 **				CLC
 **				LDA MA+$110F,Y			; Start Sector + Seq Ptr
 **				ADC MA+$1111,Y
 **				STA $C3
 **				STA MA+$111C,Y			; Buffer sector
 **				LDA MA+$110D,Y
 **				AND #$03
 **				ADC MA+$1112,Y
 **				STA $C2
 **				STA sws_Channel_SecHi,Y


ChannelFlags_SetBit7
		lda	#$80			; Set/Clear flags (C=0 on exit)
ChannelFlags_SetBits
		ora	sws_ChannelFlags,Y
ChannelFlags_ClearBit7
		lda	#$7F
ChannelFlags_ClearBits
		anda	sws_ChannelFlags,Y
chnflg_save
		sta	sws_ChannelFlags,Y
		CLC
		rts
 **			
 **			.ChannelBufferToDisk_Yintch
 **				LDA sws_ChannelFlags,Y
 **				AND #$40			; Bit 6 set?
 **				BEQ chnbuf_exit2		; If no exit
 **				CLC 				; C=0=write buffer
 **			
 **			.ChannelBufferRW_Yintch_C1read
 **			{
 **				PHP 				; Save C
 **				INC sws_error_flag_qry			; Remember in case of error?
 **				LDY MA+$10C2			; Setup NMI vars
 **				LDA MA+$1113,Y			; Buffer page
 **				STA $BD				;Data ptr
 **				LDA #$FF			; \ Set load address to host
 **				STA MA+$1074			; \
 **				STA MA+$1075			; \
 **				LDA #$00
 **				STA $BC
 **				STA $C0				; Sector
 **				LDA #$01
 **				STA $C1
 **				PLP
 **				BCS chnbuf_read			; IF c=1 load buffer else save
 **				LDA MA+$111C,Y			; Buffer sector
 **				STA $C3				; Start sec. b0-b7
 **				LDA sws_Channel_SecHi,Y
 **				STA $C2				; "mixed byte"
 **				JSR SaveMemBlock
 **				LDY MA+$10C2			; Y=intch
 **				LDA #$BF			; Clear bit 6
 **				JSR ChannelFlags_ClearBits
 **				BCC chnbuf_exit			; always
 **			.chnbuf_read
 **				JSR CalcBufferSectorForPTR	; sets NMI data ptr
 **				JSR LoadMemBlock		; Load buffer
 **			.chnbuf_exit
 **				DEC sws_error_flag_qry
 **				LDY MA+$10C2			; Y=intch
 **			}
 **			.chnbuf_exit2
 **				RTS
 **			
 **			.errFILELOCKED2
 **				JMP errFILELOCKED
 **			
errFILEREADONLY
		jsr	ReportErrorCB
		fcb	$C1, "Read only",0
 **			
 **			.bput_Yintchan
 **				JSR RememberAXY
 **				JMP bp_entry

 		TODOCMD "BPUTV_ENTRY"

 **			.BPUTV_ENTRY
 **				JSR RememberAXY
 **				JSR CheckChannel_Yhndl_exYintch
 **			.bp_entry
 **			{
 **				PHA
 **				LDA MA+$110C,Y
 **				BMI errFILEREADONLY
 **				LDA MA+$110E,Y
 **				BMI errFILELOCKED2
 **				JSR Channel_SetDirDrive_Yintch
 **				TYA
 **				CLC
 **				ADC #$04
 **				JSR CmpPTR
 **				BNE bp_noextend			; If PTR<>Sector Count, i.e Ptr<sc
 **				JSR Channel_GetCatEntry_Yintch	; Enough space in gap?
 **				LDX MA+$10C3			; X=cat file offset
 **				SEC 				; Calc size of gap
 **				LDA MA+$0F07,X			; Next file start sector
 **				SBC MA+$0F0F,X			; This file start
 **				PHA 				; lo byte
 **				LDA sws_Cat_OPT,X
 **				SBC MA+$0F0E,X			; Mixed byte
 **				AND #$03			; hi byte
 **				CMP MA+$111A,Y			; File size in sectors
 **				BNE bp_extendby100		; If must be <gap size
 **				PLA
 **				CMP MA+$1119,Y
 **				BNE bp_extendtogap		; If must be <gap size
 **				STY $B4				; Error, save intch handle
 **				STY MA+$10C2			; for clean up
 **				JSR ClearEXECSPOOLFileHandle
errCANTEXTEND
		jsr	ReportErrorCB
		fcb	$BF, "Can't extend",0
 **			
 **			.bp_extendby100
 **				LDA MA+$111A,Y			; Add maximum of $100
 **				CLC 				; to sector count
 **				ADC #$01			; (i.e. 64K)
 **				STA MA+$111A,Y			; [else set to size of gap]
 **				ASL A				; Update cat entry
 **				ASL A
 **				ASL A
 **				ASL A
 **				EOR MA+$0F0E,X			; Mixed byte
 **				AND #$30
 **				EOR MA+$0F0E,X
 **				STA MA+$0F0E,X			; File len 2
 **				PLA
 **				LDA #$00
 **			.bp_extendtogap
 **				STA MA+$0F0D,X			; File len 1
 **				STA MA+$1119,Y
 **				LDA #$00
 **				STA MA+$0F0C,X			; File len 0
 **				JSR SaveCatToDisk
 **				LDY MA+$10C2			; Y=intch
 **			.bp_noextend
 **				LDA sws_ChannelFlags,Y
 **				BMI bp_savebyte			; If PTR in buffer
 **				JSR ChannelBufferToDisk_Yintch	; Save buffer
 **				LDA MA+$1114,Y			; EXT byte 0
 **				BNE bp_loadbuf			; IF <>0 load buffer
 **				TYA
 **				JSR CmpPTR			; A=Y
 **				BNE bp_loadbuf			; If PTR<>EXT, i.e. PTR<EXT
 **				JSR CalcBufferSectorForPTR	; new sector!
 **				BNE bp_savebyte			; always
 **			.bp_loadbuf
 **				SEC 				; Load buffer
 **				JSR ChannelBufferRW_Yintch_C1read
 **			.bp_savebyte
 **				LDA MA+$1110,Y			; Seq.Ptr
 **				STA $BA
 **				LDA MA+$1113,Y			; Buffer page
 **				STA $BB
 **				PLA
 **				LDY #$00
 **				STA ($BA),Y			; Byte to buffer
 **				LDY MA+$10C2
 **				LDA #$40			; Bit 6 set = new data
 **				JSR ChannelFlags_SetBits
 **				INC $BA				; PTR=PTR+1
 **				LDA $BA
 **				STA MA+$1110,Y
 **				BNE bp_samesecnextbyte
 **				JSR ChannelFlags_ClearBit7	; PTR in next sector
 **				LDA MA+$1111,Y
 **				ADC #$01
 **				STA MA+$1111,Y
 **				LDA MA+$1112,Y
 **				ADC #$00
 **				STA MA+$1112,Y
 **			.bp_samesecnextbyte
 **				TYA
 **				JSR CmpPTR
 **				BCC bp_exit			; If PTR<EXT
 **				LDA #$20			; Update cat file len when closed
 **				JSR ChannelFlags_SetBits	; Set bit 5
 **				LDX #$02			; EXT=PTR
 **			.bp_setextloop
 **				LDA MA+$1110,Y
 **				STA MA+$1114,Y
 **				INY
 **				DEX
 **				BPL bp_setextloop
 **			}
 **			.bp_exit
 **				RTS
 **			
 **			
 **			.argsv_WriteSeqPointer
 **			{
 **				JSR RememberAXY			; Write Sequential Pointer
 **				JSR CheckChannel_Yhndl_exYintch	; (new ptr @ 00+X)
 **				LDY MA+$10C2
 **			.wsploop
 **				JSR CmpNewPTRwithEXT
 **				BCS SetSeqPointer_Yintch	; If EXT >= new PTR
 **				LDA MA+$1114,Y			; else new PTR>EXT so pad with a 0
 **				STA MA+$1110,Y
 **				LDA MA+$1115,Y			; first, actual PTR=EXT
 **				STA MA+$1111,Y
 **				LDA MA+$1116,Y
 **				STA MA+$1112,Y
 **				JSR IsSeqPointerInBuffer_Yintch	; Update flags
 **				LDA $B6
 **				PHA 				; Save $B6,$B7,$B8
 **				LDA $B7
 **				PHA
 **				LDA $B8
 **				PHA
 **				LDA #$00
 **				JSR bput_Yintchan		; Pad
 **				PLA 				; Restore $B6,$B7,$B8
 **				STA $B8
 **				PLA
 **				STA $B7
 **				PLA
 **				STA $B6
 **				JMP wsploop			; Loop
 **			}
 **			
 **			.SetSeqPointer_Yintch
 **				LDA $00,X			; Set Sequential Pointer
 **				STA MA+$1110,Y
 **				LDA $01,X
 **				STA MA+$1111,Y
 **				LDA $02,X
 **				STA MA+$1112,Y
 **			
 **			.IsSeqPointerInBuffer_Yintch
 **				LDA #$6F			; Clear bits 7 $ 4 of 1017+Y
 **				JSR ChannelFlags_ClearBits
 **				LDA MA+$110F,Y			; Start sector
 **				ADC MA+$1111,Y			; Add sequ.ptr
 **				STA MA+$10C4
 **				LDA MA+$110D,Y			; Mixed byte
 **				AND #$03			; Start sector bits 8$9
 **				ADC MA+$1112,Y
 **				CMP sws_Channel_SecHi,Y
 **				BNE bp_exit
 **				LDA MA+$10C4
 **				CMP MA+$111C,Y
 **				BNE bp_exit
 **				JMP ChannelFlags_SetBit7	; Seq.Ptr in buffered sector
 **			
 **			.CmpPTR
 **				TAX
 **				LDA MA+$1112,Y
 **				CMP MA+$1116,X
 **				BNE cmpPE_exit
 **				LDA MA+$1111,Y
 **				CMP MA+$1115,X
 **				BNE cmpPE_exit
 **				LDA MA+$1110,Y
 **				CMP MA+$1114,X
 **			.cmpPE_exit
 **				RTS
 **			
 **			.CmpNewPTRwithEXT
 **				LDA MA+$1114,Y			; Compare ctl blk ptr
 **				CMP $00,X			; to existing
 **				LDA MA+$1115,Y			; Z=1 if same
 **				SBC $01,X			; (ch.1=$1138)
 **				LDA MA+$1116,Y
 **				SBC $02,X
 **				RTS 				; C=p>=n
 **			
 **				\ *HELP MMFS

*************************************************************************
* CMD_HELP_USBFS								*
*************************************************************************

CMD_HELP_USBFS	
		ldy	#tblFSCommands + 1

*************************************************************************
* Prthelp_Ytable_API							*
*************************************************************************

	; Used to pass 	A=command tail pointer
	;		X=offset of command table
	;		Y=command table length
	;		Continues to UnrecCommandTextPointerAPI
	; NEW:		A=?
	;		B=table length
	;		Y=table address + 1 (skip command # byte)
	;		X=command tail pointer
	;		preserves X
	;		returns without calling UnrecCommandTextPointer
Prthelp_Ytable_API
		pshs	X
		jsr	PrintStringImmed
		fcb	$0D,"USBFS ",0
		ldx	#ROM_VERSION		; Print ROM version number
		jsr	PrintStringX
		jsr	PrintNewLine
		puls	X
help_dfs_loop
		clr	DP_FS_BRK_OFFS		; ?$B9=0=print command (not error)
		ldb	#1
		jsr	prtcmd_Print_B_Spaces_IfNotErr	; print "  ";
		tst	,Y
		beq	1F			; end of table encountered
		jsr	prtcmdAtBCadd1		; print cmd $ parameters
		jsr	PrintNewLine		; print
		bra	help_dfs_loop
1		rts

*************************************************************************
* CMD_HELP_DUTILS								*
*************************************************************************

CMD_HELP_DUTILS	ldy	#tblDUtilsCommands + 1
		bra	Prthelp_Ytable_API
	
*************************************************************************
* CMD_UTILS								*
*************************************************************************
CMD_UTILS	ldy	#tblUtilsCommands + 1
		bra	Prthelp_Ytable_API

CMD_notFound_tblHelp
		jsr	GSINIT_A
		beq	prtcmdparamexit		; null str
1		jsr	GSREAD_A
		bcc	1B			; if not end of str
		rts


	; New API, when this is called Y should point to the current command's table entry parameters

Param_SyntaxErrorIfNull_API
		jsr	GSINIT_A			; (if no params then syntax error)
		beq	errSYNTAX_API			; branch if not null string
		rts
	
errSYNTAX_API		
		jsr	ReportError			; Print Syntax error
		fcb	$DC, "Syntax: ", $80
		STX_B	DP_FS_BRK_OFFS			; ?$B9=$100 offset (>0)		!!!X into here !
		jsr	prtcmdAtBCadd1			; add command syntax  !!! need to store command pointer somewhere or reuse DP_FS_CMD_NUM to refind command text!!!
		clra
		jsr	prtcmd_prtchr
		jsr	$0100				; Cause BREAK!
	
prtcmdAtBCadd1
		lda	#7				; A=column width
		sta	DP_FS_SC_PRINT_COLCT
		cmpy	#tblDUtilsCommands
		blo	prtcmdloop			; All table 4 commands
		lda	#'D'				; start with "D"
		jsr	prtcmd_prtchr
prtcmdloop
		lda	,Y+
		bmi	prtcmdloop_exit			; If end of str
		jsr	prtcmd_prtchr
		bra	prtcmdloop
	
prtcmdloop_exit
		ldb	DP_FS_SC_PRINT_COLCT
		bmi	prtcmdnospcs
		jsr	prtcmd_Print_B_Spaces_IfNotErr	; print spaces
prtcmdnospcs
		ldb	-1,Y				; paramater code
		andb	#$7F
		jsr	prtcmdparam			; 1st parameter
		lsrb
		lsrb
		lsrb
		lsrb
prtcmdparam
		pshs	D,Y
		andb	#$0F
		beq	prtcmdparamexit		; no parameter
		lda	#' '
		jsr	prtcmd_prtchr		; print space
		ldy	#tblParams
prtcmdparam_findloop
		lda	,Y+
		bpl	prtcmdparam_findloop
		decb
		bne	prtcmdparam_findloop	; next parameter
		anda	#$7F			; Clear bit 7 of first chr
prtcmdparam_loop
		jsr	prtcmd_prtchr		;Print parameter
		lda	,Y+
		bpl	prtcmdparam_loop
prtcmdparamexit
		puls	D,Y,PC
	
prtcmd_prtchr
		tst	DP_FS_BRK_OFFS
		beq	prtcmdparam_prtchr		; If printing help
		pshs	D,X
		inc	DP_FS_BRK_OFFS
		ldb	DP_FS_BRK_OFFS
		clra
		tfr	D,X
		puls	D
		sta	$0100,X
		puls	X,PC
	
prtcmdparam_prtchr
		dec	DP_FS_SC_PRINT_COLCT		; If help print chr
		jmp	PrintChrA
	
prtcmd_Print_B_Spaces_IfNotErr
		tst	DP_FS_BRK_OFFS
		bne	2F			; If printing error exit
		lda	#' '			; Print space
1		jsr	prtcmd_prtchr
		decb
		bpl	1B
2		rts

 **			
 **			
		TODOCMD	"CMD_COMPACT"
 **			.CMD_COMPACT
 **			{
 **				JSR Param_OptionalDriveNo
 **				JSR PrintString			; "Compacting :"
 **				EQUS "Compacting :"
 **			
 **				STA MA+$10D1			; Source Drive No.
 **				STA MA+$10D2			; Dest Drive No.
 **				JSR PrintNibble
 **				JSR PrintNewLine
 **				LDY #$00
 **				JSR CloseFile_Yintch		; Close all files
 **				JSR CalcRAM
 **				JSR LoadCurDrvCat2		; Load catalogue
 **				LDY sws_Cat_Filesx8
 **				STY $CA				; ?CA=file offset
 **				LDA #$02
 **				STA $C8
 **				LDA #$00
 **				STA $C9				; word C8=next free sector
 **			.compact_loop
 **				LDY $CA
 **				JSR Y_sub8
 **				CPY #$F8
 **				BNE compact_checkfile		; If not end of catalogue
 **				LDA MA+$0F07			; Calc $ print no. free sectors
 **				SEC 				; (disk sectors - word C8)
 **				SBC $C8
 **				PHA
 **				LDA sws_Cat_OPT
 **				AND #$03
 **				SBC $C9
 **				JSR PrintNibble
 **				PLA
 **				JSR PrintHex
 **				JSR PrintString			; " free sectors"
 **				EQUS " free sectors",13
 **				NOP
 **				RTS 				; Finished compacting
 **			
 **			.compact_checkfile
 **				STY $CA				; Y=cat offset
 **				JSR prtInfoIfEn_Y_API		; Only if messages on
 **				LDY $CA				; Y preserved?
 **				LDA MA+$0F0C,Y			; A=Len0
 **				CMP #$01			; C=sec count
 **				LDA #$00
 **				STA $BC
 **				STA $C0
 **				ADC MA+$0F0D,Y			; A=Len1
 **				STA $C4
 **				LDA MA+$0F0E,Y
 **				PHP
 **				JSR A_rorx4and3			; A=Len2
 **				PLP
 **				ADC #$00
 **				STA $C5				; word C4=size in sectors
 **				LDA MA+$0F0F,Y			; A=sec0
 **				STA $C6
 **				LDA MA+$0F0E,Y
 **				AND #$03			; A=sec1
 **				STA $C7				; word C6=sector
 **				CMP $C9				; word C6=word C8?
 **				BNE compact_movefile		; If no
 **				LDA $C6
 **				CMP $C8
 **				BNE compact_movefile		; If no
 **				CLC
 **				ADC $C4
 **				STA $C8
 **				LDA $C9
 **				ADC $C5
 **				STA $C9				; word C8 += word C4
 **				JMP compact_fileinfo
 **			
 **			.compact_movefile
 **				LDA $C8				; Move file
 **				STA MA+$0F0F,Y			; Change start sec in catalogue
 **				LDA MA+$0F0E,Y			; to word C8
 **				AND #$FC
 **				ORA $C9
 **				STA MA+$0F0E,Y
 **				LDA #$00
 **				STA $A8				; Don't create file
 **				STA $A9
 **				JSR SaveCatToDisk		; save catalogue
 **				JSR CopyDATABLOCK		; may use buffer @ $E00	;Move file
 **				JSR CheckCurDrvCat
 **			.compact_fileinfo
 **				LDY $CA
 **				JSR prtInfo_Y_API
 **				JMP compact_loop
 **			}
 **			
 **			.IsEnabledOrGo
 **			{
 **				BIT sws_CMDenabledIf1
 **				BPL isgoalready
 **				JSR GoYN
 **				BEQ isgo
 **				PLA 				; don't return to sub
 **				PLA
 **			.isgo
 **				JMP PrintNewLine
 **			}
 **			
 **			.Get_CopyDATA_Drives
 **			{
 **				JSR Param_DriveNo_Syntax	; Get drives $ calc ram $ msg
 **				STA MA+$10D1			; Source drive
 **				JSR Param_DriveNo_Syntax
 **				STA MA+$10D2			; Destination drive
 **			
 **				CMP MA+$10D1
 **				BEQ baddrv			; Drives must be different!
 **			
 **				TYA
 **				PHA
 **				JSR CalcRAM			; Calc ram available
 **				JSR PrintString			; Copying from:
 **				EQUS "Copying from :"
 **				LDA MA+$10D1
 **				JSR PrintNibble
 **				JSR PrintString			; to :
 **				EQUS " to :"
 **				LDA MA+$10D2
 **				JSR PrintNibble
 **				JSR PrintNewLine
 **				PLA
 **				TAY
 **				CLC
 **			}
 **			.isgoalready
 **				RTS
 **			.baddrv JMP errBADDRIVE
 **			
 **			
 **			.ConfirmYNcolon
 **				JSR PrintString
 **				EQUS " : "
 **				BCC ConfirmYN
 **			
 **			.GoYN
 **				JSR PrintString
 **				EQUS "Go (Y/N) ? "		; Go (Y/N) ?
 **				NOP
 **			
 **			.ConfirmYN
 **			{
 **				JSR osbyte0F_flushinbuf2
 **				JSR OSRDCH			; Get chr
 **				BCS err_ESCAPE			; If ESCAPE
 **				AND #$5F
 **				CMP #$59			; "Y"?
 **				PHP
 **				BEQ confYN
 **				LDA #$4E			; "N"
 **			.confYN
 **				JSR PrintChrA
 **				PLP
 **				RTS
 **			}
 **			
 **			.err_ESCAPE
 **				JMP ReportESCAPE
 **			.err_DISKFULL2
 **				JMP errDISKFULL
 **			
		TODOCMD	"CMD_BACKUP"
 **			.CMD_BACKUP
 **			{
 **				JSR Get_CopyDATA_Drives
 **				JSR IsEnabledOrGo
 **				LDA #$00
 **				STA $C7
 **				STA $C9
 **				STA $C8
 **				STA $C6
 **				STA $A8				; Don’t' create file
 **			
 **				\ Source
 **				LDA MA+$10D1
 **				STA DP_FSW_CurrentDrv
 **				JSR LoadCurDrvCat
 **				LDA MA+$0F07			; Size of source disk
 **				STA $C4				; Word C4 = size fo block
 **				LDA sws_Cat_OPT
 **				AND #$03
 **				STA $C5
 **			
 **				\ Destination
 **				LDA MA+$10D2
 **				STA DP_FSW_CurrentDrv
 **				JSR LoadCurDrvCat
 **				LDA sws_Cat_OPT			; Is dest disk smaller?
 **				AND #$03
 **				CMP $C5
 **				BCC err_DISKFULL2
 **				BNE backup_copy
 **				LDA MA+$0F07
 **				CMP $C4
 **				BCC err_DISKFULL2
 **			
 **			.backup_copy
 **			
 **				JSR CopyDATABLOCK
 **				JSR LoadCurDrvCat
 **			
 **				\ Update title in disk table
 **			
 **				LDX #$0A
 **			.tloop
 **				CPX #$08
 **				BCC tskip1
 **				LDA MA+$0EF8,X
 **				BCS tskip2
 **			.tskip1
 **				LDA MA+$0E00,X
 **			.tskip2
 **				STA titlestr%,X
 **				DEX
 **				BPL tloop
 **			
 **				JMP UpdateDiskTableTitle
 **			}
 **			
		TODOCMD	"CMD_COPY"
 **			.CMD_COPY
 **			{
 **				JSR parameter_afsp
 **				JSR Get_CopyDATA_Drives
 **				JSR Param_SyntaxErrorIfNull
 **				JSR read_fsp_GSREAD
 **			
 **				\ Source
 **				LDA MA+$10D1
 **				JSR SetCurrentDrive_Adrive
 **				JSR getcatentry
 **			.copy_loop1
 **				LDA DP_FSW_DirectoryParam
 **				PHA
 **				LDA $B6
 **				STA $AB
 **				JSR prtInfo_Y_API
 **				LDX #$00
 **			.copy_loop2
 **				LDA MA+$0E08,Y
 **				STA $C5,X
 **				STA MA+$1050,X
 **				LDA MA+$0F08,Y
 **				STA $BB,X
 **				STA MA+$1047,X
 **				INX
 **				INY
 **				CPX #$08
 **				BNE copy_loop2
 **				LDA $C1
 **				JSR A_rorx4and3
 **				STA $C3
 **				LDA $BF
 **				CLC
 **				ADC #$FF
 **				LDA $C0
 **				ADC #$00
 **				STA $C4
 **				LDA $C3
 **				ADC #$00
 **				STA $C5
 **				LDA MA+$104E
 **				STA $C6
 **				LDA MA+$104D
 **				AND #$03
 **				STA $C7
 **				LDA #$FF
 **				STA $A8				; Create new file
 **				JSR CopyDATABLOCK
 **			
 **				\ Source
 **				LDA MA+$10D1
 **				JSR SetCurrentDrive_Adrive
 **				JSR LoadCurDrvCat2
 **				LDA $AB
 **				STA $B6
 **				PLA
 **				STA DP_FSW_DirectoryParam
 **				JSR srch_cat_get_next
 **				BCS copy_loop1
 **				RTS
 **			}
 **			
 **			.cd_writedest_cat
 **			{
 **				JSR cd_swapvars			; create file in destination catalogue
 **			
 **				\ Destination
 **				LDA MA+$10D2
 **				STA DP_FSW_CurrentDrv
 **				LDA DP_FSW_DirectoryParam
 **				PHA
 **				JSR LoadCurDrvCat2		; Load cat
 **				JSR srch_catfname
 **				BCC cd_writedest_cat_nodel	; If file not found
 **				JSR DeleteCatEntry_YFileOffset
 **			.cd_writedest_cat_nodel
 **				PLA
 **				STA DP_FSW_DirectoryParam
 **				JSR LoadAddrHi2
 **				JSR ExecAddrHi2
 **				LDA $C2				; mixed byte
 **				JSR A_rorx4and3
 **				STA $C4
 **				JSR CreateFile_2		; Saves cat
 **				LDA $C2				; Remember sector
 **				AND #$03
 **				PHA
 **				LDA $C3
 **				PHA
 **				JSR cd_swapvars			; Back to source
 **				PLA 				; Next free sec on dest
 **				STA $C8
 **				PLA
 **				STA $C9
 **				RTS
 **			
 **			.cd_swapvars
 **				LDX #$11			; Swap BA-CB $ 1045-1056
 **			.cd_swapvars_loop
 **				LDA MA+$1045,X			; I.e. src/dest
 **				LDY $BA,X
 **				STA $BA,X
 **				TYA
 **				STA MA+$1045,X
 **				DEX
 **				BPL cd_swapvars_loop
 **				RTS
 **			}
 **			
 **			.CopyDATABLOCK
 **			{
 **				LDA #$00			; *** Move or copy sectors
 **				STA $BC				; Word $C4 = size of block
 **				STA $C0
 **				BEQ cd_loopentry		; always
 **			.cd_loop
 **				LDA $C4
 **				TAY
 **				CMP RAMBufferSize		; Size of buffer
 **				LDA $C5
 **				SBC #$00
 **				BCC cd_part			; IF size<size of buffer
 **				LDY RAMBufferSize
 **			.cd_part
 **				STY $C1
 **				LDA $C6				; C2/C3 = Block start sector
 **				STA $C3				; Start sec = Word C6
 **				LDA $C7
 **				STA $C2
 **				LDA PAGE			; Buffer address
 **				STA $BD
 **				LDA MA+$10D1
 **				STA DP_FSW_CurrentDrv
 **			
 **				\ Source
 **				JSR SetLoadAddrToHost
 **				JSR LoadMemBlock
 **				LDA MA+$10D2
 **				STA DP_FSW_CurrentDrv
 **				BIT $A8
 **				BPL cd_skipwrcat		; Don’t create file
 **				JSR cd_writedest_cat
 **				LDA #$00
 **				STA $A8				; File created!
 **			.cd_skipwrcat
 **				LDA $C8				; C2/C3 = Block start sector
 **				STA $C3				; Start sec = Word C8
 **				LDA $C9
 **				STA $C2
 **				LDA PAGE			; Buffer address
 **				STA $BD
 **			
 **				\ Destination
 **				JSR SetLoadAddrToHost
 **				JSR SaveMemBlock
 **				LDA $C1				; Word C8 += ?C1
 **				CLC 				; Dest sector start
 **				ADC $C8
 **				STA $C8
 **				BCC cd_inc1
 **				INC $C9
 **			.cd_inc1
 **				LDA $C1				; Word C6 += ?C1
 **				CLC 				; Source sector start
 **				ADC $C6
 **				STA $C6
 **				BCC cd_inc2
 **				INC $C7
 **			.cd_inc2
 **				SEC	 			; Word C4 -= ?C1
 **				LDA $C4				; Sector counter
 **				SBC $C1
 **				STA $C4
 **				BCS cd_loopentry
 **				DEC $C5
 **			.cd_loopentry
 **				LDA $C4
 **				ORA $C5
 **				BNE cd_loop			; If Word C4 <> 0
 **				RTS
 **			}
 **			
 **			.SetLoadAddrToHost
 **				LDA #$FF			; Set load address high bytes
 **				STA MA+$1074			; to FFFF (i.e. host)
 **				STA MA+$1075
 **				RTS
 **			
 **			
		TODOCMD	"CMD_VERIFY"
 **			.CMD_VERIFY
 **				LDA #$00			; \\\\\ *VERIFY
 **				BEQ vform1
 **			
		TODOCMD	"CMD_FORM"
 **			.CMD_FORM
 **				LDA #$FF			; \\\\\ *FORM
 **			.vform1
 **			{
 **				STA $C9
 **				STA $B2				; If -ve, check go ok, calc. memory
 **				BPL vform3_ok			; If verifying
 **			
 **				JSR Param_SyntaxErrorIfNull	; Get number of tracks (40/80)
 **				JSR Param_ReadNum		; rn% @ B0
 **				BCS vform2_syntax
 **				ASL A
 **				BNE vform2_syntax
 **				STX $B5				; no. of tracks
 **				CPX #$28
 **				BEQ vform3_ok			; If =40
 **				CPX #$50
 **				BEQ vform3_ok			; If =80
 **			.vform2_syntax
 **				JMP errSYNTAX
 **			
 **			.vform3_ok
 **				JSR GSINIT_A
 **				STY $CA
 **				BNE vform5_driveloop
 **			
 **				\ No drive param, so ask!
 **				BIT $C9
 **				BMI vform4_form			; IF formatting
 **				JSR PrintString
 **				EQUS "Verify"			; Verify
 **				BCC vform4_askdrive		; always
 **			.vform4_form
 **				JSR PrintString
 **				EQUS "Format"			; Format
 **				NOP
 **			
 **			.vform4_askdrive
 **				JSR PrintString
 **				EQUS " which drive ? "		; which drive ?
 **				NOP
 **				JSR OSRDCH
 **				BCS jmp_reportEscape
 **				CMP #$20
 **				BCC jmp_errBadDrive
 **				JSR PrintChrA
 **				SEC
 **				SBC #$30
 **				BCC jmp_errBadDrive
 **				CMP #$04
 **				BCS jmp_errBadDrive		; If >=4
 **				STA DP_FSW_CurrentDrv
 **				JSR PrintNewLine
 **				LDY $CA
 **				JMP vform6_drivein
 **			
 **			.vform5_driveloop
 **				JSR Param_DriveNo_BadDrive
 **			.vform6_drivein
 **				STY $CA
 **				BIT $B2				; If verifying or already done don't ask!
 **				BPL vform7_go
 **				JSR IsEnabledOrGo
 **			.vform7_go
 **				JSR VFCurDrv
 **				LDY $CA
 **				JSR GSINIT_A
 **				BNE vform5_driveloop		; More drives?
 **				RTS
 **			}
 **			
 **			.jmp_reportEscape
 **				JMP ReportESCAPE
 **			.jmp_errBadDrive
 **				JMP errBADDRIVE
 **			
 **				\\ Verify / Format current drive
 **			.VFCurDrv
 **			{
 **				BIT $C9
 **				BMI vf1				; If formatting
 **				JSR CheckCurDrvFormatted_API
 **				JSR PrintString
 **				EQUS "Verifying"
 **				BCC vf2				; always
 **			.vf1
 **				JSR CheckCurDrvUnformatted
 **				JSR ClearCatalogue
 **				JSR PrintString
 **				EQUS "Formatting"
 **				LDX DP_FSW_CurrentDrv
 **				STX $B2				; clear bit 7
 **			
 **			.vf2
 **				JSR PrintString
 **				EQUS " drive "
 **				LDA DP_FSW_CurrentDrv
 **				JSR PrintNibble
 **				JSR PrintString
 **				EQUS " track   "
 **				NOP
 **				BIT $C9
 **				BMI vf4				; If formatting
 **			
 **				\ If verifying calc. no. of tracks
 **				JSR TracksOnDisk
 **				TXA
 **				BEQ vf6_exit
 **				STA $B5				; number of tracks
 **			
 **			.vf4
 **				LDX #$FF
 **				STX sws_CurrentCat			; Invalid catalogue
 **				INX
 **				STX $B4				; track
 **			.vf5_trackloop
 **				LDA #$08			; print track number
 **				JSR PrintChrA
 **				JSR PrintChrA
 **				LDA $B4
 **				JSR PrintHex			; print track
 **				JSR RW_Track
 **				INC $B4				; track
 **				LDA $B4
 **				CMP $B5				; more tracks?
 **				BNE vf5_trackloop
 **			
 **				BIT $C9
 **				BPL vf6_exit			; If verifying
 **			
 **				\ Save new catalogue
 **				JSR MarkDriveAsFormatted
 **				JSR ClearCatalogue
 **				LDA $B5
 **				CMP #40
 **				BNE vf7
 **				LDY #$01
 **				LDX #$90
 **				BNE vf8
 **			.vf7
 **				LDY #$03
 **				LDX #$20
 **			.vf8
 **				STX MA+$F07			; Disk size in sectors
 **				STY MA+$F06
 **				JSR SaveCatToDisk
 **			.vf6_exit
 **				JMP PrintNewLine
 **			}
 **			
 **				\\ Reset catalogue pages
 **			.ClearCatalogue
 **			{
 **				LDY #$FF
 **				STY sws_CurrentCat			; Invalid catalogue
 **				INY
 **				TYA
 **			.ccatloop
 **				STA MA+$0E00,Y
 **				STA MA+$0F00,Y
 **				INY
 **				BNE ccatloop
 **				RTS
 **			}
 **			
 **				\ * Calc. no. of tracks on disk in curdrv *
 **			.TracksOnDisk
 **			{
 **				JSR LoadCurDrvCat		; Load catalogue
 **				LDA sws_Cat_OPT			; Size of disk
 **				AND #$03
 **				TAX
 **				LDA MA+$0F07
 **				LDY #$0A			; 10 sectors/track
 **				STY $B0
 **				LDY #$FF			; Calc number of tracks
 **			.trkloop1
 **				SEC
 **			.trkloop2
 **				INY
 **				SBC $B0
 **				BCS trkloop2
 **				DEX
 **				BPL trkloop1
 **				ADC $B0
 **				PHA
 **				TYA
 **				TAX
 **				PLA
 **				BEQ trkex
 **				INX
 **			.trkex
 **				RTS
 **			}
 **			
 **			
		TODOCMD	"CMD_FREE"
 **			.CMD_FREE
 **				SEC 				; \\\\\\\\\ *FREE
 **				BCS Label_A7F7
		TODOCMD	"CMD_MAP"
 **			.CMD_MAP
 **				CLC 				; \\\\\\\\\ *MAP
 **			.Label_A7F7
 **			{
 **				ROR $C6
 **				JSR Param_OptionalDriveNo
 **				JSR LoadCurDrvCat2
 **				BIT $C6
 **				BMI Label_A818_free		; If *FREE
 **				JSR PrintStringSPL
 **				EQUS "Address :  Length",13	; "Address : Length"
 **			.Label_A818_free
 **				LDA sws_Cat_OPT
 **				AND #$03
 **				STA $C5
 **				STA $C2
 **				LDA MA+$0F07
 **				STA $C4				; wC4=sector count
 **				SEC
 **				SBC #$02			; wC1=sector count - 2 (map length)
 **				STA $C1
 **				BCS Label_A82F
 **				DEC $C2
 **			.Label_A82F
 **				LDA #$02
 **				STA $BB				; wBB = 0002 (map address)
 **				LDA #$00			; wBF = 0000
 **				STA $BC
 **				STA $BF
 **				STA $C0
 **				LDA sws_Cat_Filesx8
 **				AND #$F8
 **				TAY
 **				BEQ Label_A86B_nofiles		; If no files
 **				BNE Label_A856_fileloop_entry	; always
 **			.Label_A845_fileloop
 **				JSR Sub_A8E2_nextblock
 **				JSR Y_sub8			; Y -> next file
 **				LDA $C4
 **				SEC
 **				SBC $BB
 **				LDA $C5
 **				SBC $BC
 **				BCC Label_A86B_nofiles
 **			.Label_A856_fileloop_entry
 **				LDA MA+$0F07,Y			; wC1 = File Start Sec - Map addr
 **				SEC
 **				SBC $BB
 **				STA $C1
 **				PHP
 **				LDA sws_Cat_OPT,Y
 **				AND #$03
 **				PLP
 **				SBC $BC
 **				STA $C2
 **				BCC Label_A845_fileloop
 **			.Label_A86B_nofiles
 **				STY $BD
 **				BIT $C6
 **				BMI Label_A87A_free		; If *FREE
 **				LDA $C1				; MAP only
 **				ORA $C2
 **				BEQ Label_A87A_free		; If wC1=0
 **				JSR Map_AddressLength
 **			.Label_A87A_free
 **				LDA $C1
 **				CLC
 **				ADC $BF
 **				STA $BF
 **				LDA $C2
 **				ADC $C0
 **				STA $C0
 **				LDY $BD
 **				BNE Label_A845_fileloop
 **				BIT $C6
 **				BPL Label_A8BD_rst		; If *MAP
 **				TAY
 **				LDX $BF
 **				LDA #$F8
 **				SEC
 **				SBC sws_Cat_Filesx8
 **				JSR Sub_A90D_freeinfo
 **				JSR PrintStringSPL
 **				EQUS "Free",13			; "Free"
 **				LDA $C4
 **				SEC
 **				SBC $BF
 **				TAX
 **				LDA $C5
 **				SBC $C0
 **				TAY
 **				LDA sws_Cat_Filesx8
 **				JSR Sub_A90D_freeinfo
 **				JSR PrintStringSPL
 **				EQUS "Used",13			; "Used"
 **				NOP
 **			.Label_A8BD_rst
 **				RTS
 **			}
 **			
 **			.Map_AddressLength
 **			{
 **				LDA $BC				; Print address (3 dig hex)
 **				JSR PrintNibbleSPL		; (*MAP only)
 **				LDA $BB
 **				JSR PrintHexSPL
 **				JSR PrintStringSPL
 **				EQUS "     :  "
 **				LDA $C2				; Print length (3 dig hex)
 **				JSR PrintNibbleSPL
 **				LDA $C1
 **				JSR PrintHexSPL
 **				LDA #$0D
 **				JSR OSASCI
 **			}
 **			
 **			.Sub_A8E2_nextblock
 **			{
 **				LDA sws_Cat_OPT,Y			; wBB = start sec + len
 **				PHA
 **				JSR A_rorx4and3
 **				STA $BC
 **				PLA
 **				AND #$03
 **				CLC
 **				ADC $BC
 **				STA $BC
 **				LDA MA+$0F04,Y
 **				BEQ Label_A8FA
 **				LDA #$01
 **			.Label_A8FA
 **				CLC
 **				ADC sws_Cat_Filesx8,Y
 **				BCC Label_A902
 **				INC $BC
 **			.Label_A902
 **				CLC
 **				ADC MA+$0F07,Y
 **				STA $BB
 **				BCC Label_A90C
 **				INC $BC
 **			.Label_A90C
 **				RTS
 **			}
 **			
 **			.Sub_A90D_freeinfo
 **			{
 **				JSR A_rorx3			; *FREE line
 **				JSR PrintBCDSPL			; A = Number of files
 **				JSR PrintStringSPL
 **				EQUS " Files "
 **				STX $BC				; YX = Number of sectors
 **				STY $BD
 **				TYA
 **				JSR PrintNibbleSPL
 **				TXA
 **				JSR PrintHexSPL
 **				JSR PrintStringSPL
 **				EQUS " Sectors "
 **				LDA #$00
 **				STA $BB
 **				STA $BE				; !BB = number of sectors * 256
 **				LDX #$1F			; i.e. !BB = number of bytes
 **				STX $C1				; Convert to decimal string
 **				LDX #$09
 **			.Label_A941_loop1
 **				STA MA+$1000,X			; ?1000 - ?1009 = 0
 **				DEX
 **				BPL Label_A941_loop1
 **			.Label_A947_loop2
 **				ASL $BB				; !BB = !BB * 2
 **				ROL $BC
 **				ROL $BD
 **				ROL $BE
 **				LDX #$00
 **				LDY #$09			; A=0
 **			.Label_A953_loop3
 **				LDA MA+$1000,X
 **				ROL A
 **				CMP #$0A
 **				BCC Label_A95D			; If <10
 **				SBC #$0A
 **			.Label_A95D
 **				STA MA+$1000,X
 **				INX
 **				DEY
 **				BPL Label_A953_loop3
 **				DEC $C1
 **				BPL Label_A947_loop2
 **				LDY #$20			; Print decimal string
 **				LDX #$05
 **			.Label_A96C_loop4
 **				BNE Label_A970
 **				LDY #$2C
 **			.Label_A970
 **				LDA MA+$1000,X
 **				BNE Label_A97D
 **				CPY #$2C
 **				BEQ Label_A97D
 **				LDA #$20
 **				BNE Label_A982			; always
 **			.Label_A97D
 **				LDY #$2C
 **				CLC
 **				ADC #$30
 **			.Label_A982
 **				JSR OSASCI
 **				CPX #$03
 **				BNE Label_A98D
 **				TYA
 **				JSR OSASCI			; Print " " or ","
 **			.Label_A98D
 **				DEX
 **				BPL Label_A96C_loop4
 **				JSR PrintStringSPL
 **				EQUS " Bytes "
 **				NOP
 **				RTS
 **			}
 **			
 **			
 **				\ *********** MMC ERROR CODE ***********
 **			
 **				\\ Report MMC error
 **				\\ A=MMC response
 **				\\ If X<>0 print sector/parameter
 **			
 **			errno%=$B0
 **			errflag%=$B1
 **			errptr%=$B8
 **			
 **			.ReportMMCErrS
 **				LDX #$FF
 **				BNE rmmc
 **			
 **			.ReportMMCErr
 **				LDX #0
 **			.rmmc
 **			{
 **				LDY #$FF
 **				STY sws_CurrentCat			; make catalogue invalid
 **				STA errno%
 **				STX errflag%
 **				JSR ResetLEDS
 **				PLA
 **				STA errptr%
 **				PLA
 **				STA errptr%+1
 **			
 **				LDY #0
 **				STY ssws_VINC_state
 **				STY $100
 **			.rmmc_loop
 **				INY
 **				BEQ rmmc_cont
 **				LDA (errptr%),Y
 **				STA $100,Y
 **				BNE rmmc_loop
 **			
 **			.rmmc_cont
 **				LDA errno%
 **				JSR PrintHex100
 **			
 **				LDA errflag%
 **				BEQ rmmc_j100
 **				LDA #'/'
 **				STA $100,Y
 **				INY
 **			
 **				LDA par%
 **				JSR PrintHex100
 **				LDA par%+1
 **				JSR PrintHex100
 **				LDA par%+2
 **				JSR PrintHex100
 **			
 **			.rmmc_j100
 **				LDA #0
 **				STA $100,Y
 **				JMP $100
 **			}
 **			
 **			; SFTODO: Slightly wasteful of space here
 **			IF _BP12K_
 **				SKIPTO MA+$0E00
 **				; The tube host code can live in this region; it doesn't access our
 **				; workspace and we won't page in the private 12K bank when calling this.
 **			IF _TUBEHOST_ AND (_BP12K_)
 **				INCLUDE "TubeHost230.asm"
 **			ENDIF
 **				SKIPTO MAEND
 **			ENDIF
 **			
 **				\\ *********** MMC HARDWARE CODE **********
 **			
 **			DP_VINC_DATA_PTR=$BC
 **			IF _LARGEFILES
 **			DP_CE_SECTOR_COUNT=$CE
 **			ELSE
 **			DP_CE_SECTOR_COUNT=$C1
 **			ENDIF
 **			skipsec%=$C2
 **			DP_C3_BYTES_LAST_SECTOR=$C3
 **			
 **			cmdseq%=MA+$1087
 **			par%=MA+$1089
 **			
 **				\ Include FAT routines here
 **			
 **			INCLUDE "FAT.asm"
 **			
		**** Calculate Check Sum (CRC7) ****
		* Exit: A=CRC7, X=0, Y=FF
CalculateCRC7
		pshsw
		ldb	#(VID_CHECK_CRC7-VID-1)
		ldx	#VID
		clra
c7loop1
		eora	B,X
		asla
		lde	#7
c7loop2
		bcc	c7b7z1
		eora	#$12
c7b7z1
		asla
		dece
		bne	c7loop2
		bcc	c7b7z2
		eora	#$12
c7b7z2
		decb
		bpl	c7loop1
		ora	#$01
		pulsw
		rts
	* Check CRC7
CheckCRC7
		pshs	D,X,Y
		jsr	CalculateCRC7
		cmpa	VID_CHECK_CRC7
		bne	errBadSum
		puls	D,X,Y,PC
errBadSum
		jsr	errBAD
		fcb	$FF, "Sum",0

***********************************************************************
ResetCRC7
	; Reset VID_CHECK_CRC7
***********************************************************************
	pshs	A,X,Y
	jsr	CalculateCRC7
	sta	VID_CHECK_CRC7
	puls	A,X,Y,PC
 **			
 **				\\ *****  Reset VID_MMC_SECTOR  *****
 **				\\ (MMC_SECTION is the card address of
 **				\\ Sector 0 of the image file.)
 **			
 **				\\ Default image: BEEB.MMB
 **			.VID_MMC_SECTOR_Reset
 **				LDX #$A
 **				JSR CopyDOSFilename
 **			
 **				\\ Search for Image File
 **				\\ Name at file at fatfilename%
 **			.SelectImage
 **			{
 **				JSR MMC_GetCIDCRC		; YA=CRC16
 **				STA VID_MMC_CIDCRC+1
 **				STY VID_MMC_CIDCRC
 **			
 **				LDA #0
 **				STA VID_VINC_SECTOR_VALID
 **				JSR ResetCRC7
 **			
 **				JSR FATLoadRootDirectory
 **				BCC nofat
 **				JSR FATSearchRootDirectory
 **				BCS fileerr
 **			.nofat
 **			
 **				LDA DP_VINC_SEK_ADDR
 **				STA VID_MMC_SECTOR
 **				LDA DP_VINC_SEK_ADDR+1
 **				STA VID_MMC_SECTOR+1
 **				LDA DP_VINC_SEK_ADDR+2
 **				STA VID_MMC_SECTOR+2
 **				LDA #$FF
 **				STA VID_VINC_SECTOR_VALID
 **			
 **				JMP ResetCRC7
 **			
 **			.fileerr
 **				JSR ReportError
 **				EQUB $FF
 **				EQUS "Image not found!",0
 **			
 **			}
 **			
 **				\\ Copy filename to search for to fatfilename%
 **			.CopyDOSFilename
 **			{
 **				LDY #$A
 **			.loop	LDA filemmb,Y
 **				STA fatfilename%,Y
 **				DEY
 **				BPL loop
 **				RTS
 **			
 **			.filemmb
 **				EQUS "BEEB    MMB"
 **			}
 **			
 **				\\ **** Check drive not write protected ****
 **			.CheckWriteProtect
 **				LDX DP_FSW_CurrentDrv
 **				LDA VID_DRIVE_INDEX4,X		; Bit 6 set = protected
 **				ASL A
 **				BMI errReadOnly
 **				RTS
 **			
 **				\\ *** Set word $B8 to disk in current drive ***
 **				\\ Check: C=0 drive loaded with formatted disk
 **				\\        C=1 drive loaded with unformatted disk
 **			.SetCurrentDiskC
 **				JSR CheckCurDrvFormatted2_API
 **				LDA VID_DRIVE_INDEX0,X
 **				STA $B8
 **				LDA VID_DRIVE_INDEX4,X
 **				AND #1
 **				STA $B9
 **				RTS
 **			
 **				\\ * Check drive loaded with unformatted disk *
 **			.CheckCurDrvUnformatted
 **				SEC
 **				BCS CheckCurDrvFormatted2_API
 **			
		* Check drive loaded with formatted disk *
		; old API X=drive at exit
		; new API B=drive
CheckCurDrvFormatted_API
		CLC
CheckCurDrvFormatted2_API
		ldb	DP_FSW_CurrentDrv
		ldx	#VID_DRIVE_INDEX4
		lda	B,X
		bpl	errNoDisk			; Bit 7 clear = no disk
		anda	#$08
		bcs	1F
		bne	errNotFormatted			; Bit 3 set = unformatted
		rts
1		beq	errFormatted			; Bit 3 clear = formatted
		rts					; exit: B=drive no
	
errReadOnly
		jsr	errDISK
		fcb	$C9, "read only", 0
errNoDisk
		jsr	ReportError
		fcb	$C7, "No disc", 0
errNotFormatted
		jsr	errDISK
		fcb	$C7, "not formatted", 0
errFormatted
		jsr	errDISK
		fcb	$C7, "already formatted", 0

***********************************************************************
USBFS_DiskStart
		; **** Calc first MMC sector of disk ****
		; DP_VINC_SEK_ADDR = 32 + drvidx * 800
		; Call after MMC_BEGIN
	
		; Current drive
***********************************************************************
		jsr	CheckCurDrvFormatted_API	; B=drive on exit
USBFS_DiskStartB_API
		clra
		tfr	D,X
		lda	VID_DRIVE_INDEX4,X
		ldb	VID_DRIVE_INDEX0,X
		anda	#1
	
		; D=drvidx
		; S=I*512+I*256+I*32
USBFS_DiskStartD_API
		pshsw
		muld	#800
		addw	#32
		adcd	#0
		stw	DP_VINC_SEK_ADDR + 1
		stb	DP_VINC_SEK_ADDR
		pulsw
		rts

***********************************************************************
CalcRWVars
		; **** Initialise VARS for MMC R/W ****
		; Call only after MMC_BEGIN
		; Note: Values in BC-C5 copied to 1090-1099
		; Also checks disk loaded/formatted
***********************************************************************
		jsr	USBFS_DiskStart

		ldb	sws_FILEV_SECTOR_LO
		lda	sws_FILEV_MULTI
		anda	#$3
		sta	,-S				; save for overflow check (hi sector start)
		addd	DP_VINC_SEK_ADDR + 1
		std	DP_VINC_SEK_ADDR + 1
		bcc	cvskip
		inc	DP_VINC_SEK_ADDR

cvskip
		; calc sector count
		lda	sws_FILEV_LEN_LO		; high byte of 16 bit part of length
		sta	DP_CE_SECTOR_COUNT + 1		; low byte of sector count 16 bits
		lda	sws_FILEV_MULTI			; mixed byte
		lsra
		lsra
		lsra
		lsra
		anda	#3
		sta	DP_CE_SECTOR_COUNT		; hi byte of sector count 16 bits
		lda	sws_FILEV_LEN_LO + 1		; low byte of length
		sta	DP_C3_BYTES_LAST_SECTOR
		beq	cvskip2
		inc	DP_CE_SECTOR_COUNT + 1
		bne	cvskip2
		inc	DP_CE_SECTOR_COUNT

		; check for overflow
cvskip2		ldb	sws_FILEV_SECTOR_LO
		lda	,S+
		addd	DP_CE_SECTOR_COUNT
		cmpd	#$0321
		bhs	errOverflow
		rts


errBlockSize
		jsr	ReportError
		fcb	$FF, "Block too big", 0

errOverflow
		jsr	errDISK
		fcb	$FF, "overflow", 0


***********************************************************************
LoadMemBlockEX
LoadMemBlock		;TODO: reinstate "checkforexception, or do something for reads over ROM/MOS?"
***********************************************************************
		jsr	VINC_BEGIN1
		jsr	CalcRWVars
readblock
		jsr	MMC_ReadBlock
rwblkexit
		lda	TubeNoTransferIf0
		beq	rwblknottube
		jsr	TUBE_RELEASE_NoCheck
rwblknottube
		jsr	VINC_END
		lda	#1
		rts	
 **			
 **				\\ **** Save block of memory ****
 **			.SaveMemBlock
 **				JSR VINC_BEGIN1
 **				JSR CalcRWVars
 **				JSR CheckWriteProtect
 **			.writeblock
 **				JSR MMC_WriteBlock
 **				JMP rwblkexit
 **			
 **			
***********************************************************************
CheckCurDrvCat
	; **** Check if loaded catalogue is that
	; of the current drive, if not load it ****
***********************************************************************
		lda	sws_CurrentCat
		cmpa	DP_FSW_CurrentDrv
		bne	LoadCurDrvCat
		rts	


***********************************************************************
USBFS_LoadDisks
	;	Reset Discs in Drives
***********************************************************************
	clra
	sta	DP_FS_DISKNO
	ldb	#3
1	stb	DP_FSW_CurrentDrv
	stb	DP_FS_DISKNO + 1			; lo-byte of diskno
	jsr	LoadDrive
	decb	
	bpl	1B
	rts	


	 **** Load catalogue of current drive ****
LoadCurDrvCat
		jsr	VINC_BEGIN1
		jsr	USBFS_DiskStart
		jsr	VINC_ReadCat
rwcatexit
		lda	DP_FSW_CurrentDrv
		sta	sws_CurrentCat
		jmp	VINC_END
 **			
 **				\\ **** Save catalogue of current drive ****
 **			.SaveCatToDisk
 **				LDA MA+$0F04			; Increment Cycle Number
 **				CLC
 **				SED
 **				ADC #$01
 **				STA MA+$0F04
 **				CLD
 **			
 **				JSR VINC_BEGIN1
 **				JSR USBFS_DiskStart
 **				JSR CheckWriteProtect
 **				JSR MMC_WriteCatalogue
 **				JMP rwcatexit
 **			
 **				\ **** Read / Write 'track' ****
 **				\ ?$C9 : -ve = write, +ve = read
 **				\ ?$B4 : track number
 **				\ (Used by CMD_VERIFY / CMD_FORM)
 **			.RW_Track
 **			{
 **				LDA $B4
 **				BNE rwtrk1
 **				LDX DP_FSW_CurrentDrv
 **				JSR USBFS_DiskStartB_API
 **			
 **			.rwtrk1
 **				LDA #5
 **				STA $B6
 **			.rwtrk2_loop
 **				BIT $C9
 **				BMI rwtrk3
 **				JSR VINC_ReadCat		; verify
 **				JMP rwtrk4
 **			.rwtrk3
 **				JSR MMC_WriteCatalogue		; format
 **			.rwtrk4
 **				INC DP_VINC_SEK_ADDR
 **				INC DP_VINC_SEK_ADDR
 **				BNE rwtrk5
 **				INC DP_VINC_SEK_ADDR+1
 **				BNE rwtrk5
 **				INC DP_VINC_SEK_ADDR+2
 **			.rwtrk5
 **				DEC $B6
 **				BNE rwtrk2_loop
 **				RTS
 **			}
 **			

***********************************************************************
GetIndex
	; **** Calc disk table sec $ offset ****
	; Entry: D = Disk no (B8)
	; Exit: (B0) = $E00 + ((D % 32) + 1) x 16
	;     : A=Table Sector Code $80 OR (D DIV 32)*2 i.e. sector number of section of table?
	; Note; D = 511 not valid
***********************************************************************
		lda	DP_FS_DISKNO
		rora
		lda	DP_FS_DISKNO + 1
		inca
		bne	gix1
		SEC
gix1		rola
		rola
		rola
		rola
		rola
		tfr	A,B
		andb	#$1F
		rora
		anda	#$F0
		sta	DP_FS_DISKTABLE_PTR + 1		; lo byte of disk pter
		tfr	B,A
		andb	#$01
		orb	#MP+$0E
		stb	DP_FS_DISKTABLE_PTR
		anda	#$FE
		ora	#$80
		rts
 **			
 **			
 **				\\ Return status of disk in current drive
 **			.GetDriveStatus
 **				CLC				; check loaded with formatted disk
 **			.GetDriveStatusC
 **				JSR SetCurrentDiskC
 **			

***********************************************************************
GetDiskStatus
	; DP_FS_DISKNO = disk no ($B8)
	; On exit; A=disk status byte
	; from Disk Table
	; DP_FS_DISKTABLE_PTR points to location in table (cat) ($B0)
	; Z $ N set on value of A
	; Disk Table sector
	; for disk in cat area
	; Type: 00=RO, 0F=RW, F0=Unformatted, FF=Invalid
	; Z=1=RO, N=1=Unformatted else RW
***********************************************************************
		jsr	GetIndex
		jsr	CheckDiskTable
		ldb	#15
		ldx	DP_FS_DISKTABLE_PTR
		lda	B,X
		cmpa	#$FF
		beq	ErrNotValid
		tsta					; reset flags
		rts
ErrNotValid
		jsr	errDISK
		fcb	$C7, "number not valid", 0

***********************************************************************
UnloadDisk
	; **** If disk in any drive, unload it ****
	; Word $B8=diskno (X,Y preserved)
	; Doesn't check/update CRC7

		pshs	X
		ldx	#4
uldloop
		lda	VID_DRIVE_INDEX0 - 1,X
		cmpa	DP_FS_DISKNO + 1
		bne	uldskip
		lda	VID_DRIVE_INDEX4 - 1,X
		anda	#1
		cmpa	DP_FS_DISKNO
		bne	uldskip
		sta	VID_DRIVE_INDEX4 - 1,X		; Reset bit 7 for unload
uldskip
		leax	-1,X
		bne	uldloop
		puls	X,PC
***********************************************************************
LoadDrive
	***** Load current drive with disk ****
	; Word $B8 = Disc number 0..511
***********************************************************************
		pshs	D,X,Y
		lda	#$C0
		sta	DP_FS_DISK_SECTOR_QRY
		jsr	GetDiskStatus
		beq	ldiskro				; 00 = read only
		bpl	ldiskrw				; 0F = read/write
		lda	#$C8
		bne	ldisknf				; not formatted
ldiskrw
		lda	#$80
ldisknf
		sta	DP_FS_DISK_SECTOR_QRY
ldiskro
		jsr	CheckCRC7
		; Make sure disk is not in another drive
		jsr	UnloadDisk
		ldb	DP_FSW_CurrentDrv
		clra
		tfr	D,X
		lda	DP_FS_DISKNO + 1		; lo byte
		sta	VID_DRIVE_INDEX0,X
		lda	DP_FS_DISKNO			; hi byte
		ora	DP_FS_DISK_SECTOR_QRY		; Loaded flags
		sta	VID_DRIVE_INDEX4,X
		jsr	ResetCRC7
		puls	D,X,Y,PC


***********************************************************************
DiskTableSec
	; **** Calculate disk table sector ****
	; A=sector code (sector + $80)
***********************************************************************
		anda	#$7E				; clear top bit
		sta	DP_VINC_SEK_ADDR + 2
		clr	DP_VINC_SEK_ADDR + 1
		clr	DP_VINC_SEK_ADDR
1		rts

***********************************************************************
CheckDiskTable
	; A=sector code (sector ored with $80)
***********************************************************************
		cmpa	sws_CurrentCat
		beq	1B				; already loaded ignore
***********************************************************************
LoadDiskTable
	; A=sector code
***********************************************************************
		sta	sws_CurrentCat
		jsr	DiskTableSec
		jmp	VINC_ReadCat
 **			
 **			.SaveDiskTable
 **				LDA sws_CurrentCat
 **				JSR DiskTableSec
 **				JMP MMC_WriteCatalogue
 **			
 **			
 **				\\ GetDisk, returns name of disks
 **				\\ in DiskTable (used by *DCAT)
 **				\\ for disks with no's in range
 **				\\ On exit C clear if disk found
 **				\\ and A contains disk status
 **			
 **				\\ Set up and get first disk
 **				\\ Word $B8=first disk no
 **				\\ If ?$B7=0, skip unformatted disks
 **			
***********************************************************************
GetDiskFirst
***********************************************************************
	jsr	BinaryToBCD9
	jsr	GetIndex
	sta	DP_FST_B2_GD_DSK_SECTOR
	jsr	CheckDiskTable
	jmp	gdfirst
 **			
 **				\\ Return ALL disks
 **			.GetDiskFirstAll
 **				LDA #0
 **				STA DP_FS_BCD_RESULT
 **				STA DP_FS_BCD_RESULT+1
 **				STA DP_FST_B7_DCAT_DNO
 **				STA DP_FST_B7_DCAT_DNO+1
 **				LDA #$10
 **				STA DP_FST_B0_GD_DSKTAB_PTR
 **				LDA #MP+$0E
 **				STA DP_FST_B0_GD_DSKTAB_PTR+1
 **				LDA #$80
 **				STA DP_FST_B2_GD_DSK_SECTOR
 **				JSR CheckDiskTable
 **				JMP gdfirst

gdnextloop
		cmpa	#$FF
		beq	gdfin
		tst	DP_FST_B7_DCAT_GDOPT		; Return unformatted disks?
		bmi	gdfnd				; If yes
	
	
GetDiskNext						; Get next disk
		ldd	DP_FST_B0_GD_DSKTAB_PTR
		addd	#16
		std	DP_FST_B0_GD_DSKTAB_PTR
		cmpd	#sws_CurDrvCat + $200
		blo	gdx1
		ldd	#sws_CurDrvCat
		std	DP_FST_B0_GD_DSKTAB_PTR
		lda	DP_FST_B2_GD_DSK_SECTOR		; goto next 2 sectors
		adca	#2
		cmpa	#$A0				; ($80 OR 32)
		beq	gdfin
		sta	DP_FST_B2_GD_DSK_SECTOR
		jsr	CheckDiskTable
gdx1
		inc	DP_FST_B7_DCAT_DNO+1
		bne	gdx50
		inc	DP_FST_B7_DCAT_DNO
gdx50		lda	DP_FS_BCD_RESULT + 1		; inc DP_FS_BCD_RESULT
		adda	#1
		daa
		sta	DP_FS_BCD_RESULT + 1
		lda	DP_FS_BCD_RESULT
		adca	#0
		daa
		sta	DP_FS_BCD_RESULT

gdfirst		ldx	DP_FST_B0_GD_DSKTAB_PTR
		lda	$F,X
		bmi	gdnextloop			; If invalid / unformatted
gdfnd		CLC					; Disk found
		rts

gdfin		lda	#$FF				; No more disks
		sta	DP_FST_B7_DCAT_DNO		; mark as no more
		SEC	
		rts
 **			
 **			
 **			
 **				\\ Include Low Level MMC Code here
 **			
 **			IF _DEVICE_='U'
 **				_TURBOMMC=FALSE
 **				INCLUDE "MMC_UserPort.asm"
 **			ELIF _DEVICE_='T'
 **				_TURBOMMC=TRUE
 **				INCLUDE "MMC_UserPort.asm"
 **			ELIF _DEVICE_='M'
 **				INCLUDE "MMC_MemoryMapped.asm"
 **			ELIF _DEVICE_='E'
 **				INCLUDE "MMC_ElkPlus1.asm"
 **			ENDIF
 **			
 **			.errWrite2
 **				TYA
 **				JSR ReportMMCErrS
 **				EQUB $C5
 **				EQUS "MMC Write response fault "
 **				BRK
 **			
 **				\\ Include high level MMC code here
 **			
 **			INCLUDE "MMC.asm"
 **			
 **			
 **				\\ *DRECAT
 **				\\ Refresh disk table with disc titles
 **			
 **				\ load first sector of disk table
		TODOCMD	"CMD_DRECAT"
 **			.CMD_DRECAT
 **			{
 **				LDA #$80
 **				STA DP_FST_B2_GD_DSK_SECTOR
 **				JSR LoadDiskTable
 **			
 **				\ pointer to first entry
 **				LDA #$10
 **				STA DP_FST_B0_GD_DSKTAB_PTR
 **				LDA #MP+$0E
 **				STA DP_FST_B0_GD_DSKTAB_PTR+1
 **			
 **				\ set read16sec% to first disk
 **				LDA #0
 **				CLC
 **				JSR USBFS_DiskStartD_API
 **				LDX #3
 **			.drc_loop1
 **				LDA DP_VINC_SEK_ADDR,X
 **				STA read16sec%,X
 **				DEX
 **				BPL drc_loop1
 **			
 **				\ is disk valid?
 **			.drc_loop2
 **				LDY #15
 **				LDA (DP_FST_B0_GD_DSKTAB_PTR),Y
 **				CMP #$FF
 **				BEQ drc_label5			; If disc not valid
 **			
 **				\ read disc title
 **				JSR MMC_ReadDiscTitle
 **			
 **				\ read16sec% += 800
 **				CLC
 **				LDA read16sec%
 **				ADC #$20
 **				STA read16sec%
 **				LDA read16sec%+1
 **				ADC #$03
 **				STA read16sec%+1
 **				BCC drc_label3
 **				INC read16sec%+2
 **			
 **				\ copy title to table
 **			.drc_label3
 **				LDY #$0B
 **			.drc_loop4
 **				LDA read16str%,Y
 **				STA (DP_FST_B0_GD_DSKTAB_PTR),Y
 **				DEY
 **				BPL drc_loop4
 **			
 **				\ DP_FST_B0_GD_DSKTAB_PTR += 16
 **				CLC
 **				LDA DP_FST_B0_GD_DSKTAB_PTR
 **				ADC #16
 **				STA DP_FST_B0_GD_DSKTAB_PTR
 **				BNE drc_loop2
 **				LDA DP_FST_B0_GD_DSKTAB_PTR+1
 **				EOR #1
 **				STA DP_FST_B0_GD_DSKTAB_PTR+1
 **				ROR A
 **				BCS drc_loop2
 **			
 **				\ If DP_FST_B0_GD_DSKTAB_PTR = 0
 **				JSR SaveDiskTable
 **				CLC
 **				LDA DP_FST_B2_GD_DSK_SECTOR
 **				ADC #2
 **				CMP #$A0			; ($80 OR 32)
 **				BEQ drc_label7			; if end of table
 **				STA DP_FST_B2_GD_DSK_SECTOR
 **			
 **				JSR CheckESCAPE
 **			
 **				JSR LoadDiskTable
 **				JMP drc_loop2
 **			
 **				\ Has this sector been modifed?
 **				\ ie is DP_FST_B0_GD_DSKTAB_PTR <> 0
 **			.drc_label5
 **				LDA DP_FST_B0_GD_DSKTAB_PTR
 **				BNE drc_label6
 **				ROR DP_FST_B0_GD_DSKTAB_PTR+1
 **				BCC drc_label7
 **			.drc_label6
 **				JMP SaveDiskTable
 **			
 **			.drc_label7
 **				RTS
 **			}
 **			
 **			

DMUCase
		; UCASE
		cmpa	#'a'				; ASC("a")
		blo	dmiUcase			; if <"a"
		cmpa	#'z'+1				;ASC("z")+1
		bhs	dmiUcase			; if >"z"
		eora	#$20				; to upper
dmiUcase	rts

***********************************************************************
DMatchInit_API
	; *** Set up the string to be compared ***
	; The match string is at X
	; Max length=12 chrs (but allow 0 terminator)
	; sws_DMATCH_STR=dmStr%=MA+$1000	; location of string
	; sws_DMATCH_LEN=dmLen%=MA+$100D	; length of string
	; sws_DMATCH_WILD=dmAmbig%=MA+$100E	; ='*' for wildcard or 0
	; if exits with C=1 then syntax error
***********************************************************************
		clr	sws_DMATCH_WILD
		ldy	#sws_DMATCH_STR
		CLC
		jsr	GSINIT
		beq	dmiExit				; null string
dmiLoop
		jsr	GSREAD
		bcs	dmiExit
		cmpa	#'*'				; ASC("*")
		beq	dmiStar				; if ="*"
		jsr	DMUCase
		sta	,Y+
		cmpy	#sws_DMATCH_STR + 12
		blo	dmiLoop
dmiEnd		jsr	GSREAD				; Make sure at end of string
		bcc	ErrBadString			; If not end of string
dmiExit		cmpa	#$0D
		bne	dmi_syntax
		lda	#0
		sta	,Y
		tfr	Y,D
		subd	#sws_DMATCH_STR
		stb	sws_DMATCH_LEN
		CLC
		rts		
dmi_syntax
		SEC
		rts
dmiStar	
	; Wildcard found, must be end of string
		sta	sws_DMATCH_WILD
		bra	dmiEnd			; always
	
ErrBadString
		jsr	ReportError
		fcb	$FF, "Bad string",0



***********************************************************************
DMatch_API
	; *** Perform string match ****
	; String at X
	; C=0 if matched
***********************************************************************
		ldb	sws_DMATCH_LEN
		beq	dmatend
		ldy	#sws_DMATCH_STR
dmatlp
		lda	,X+
		jsr	DMUCase
		cmpa	,Y+
		bne	dmatnomatch
		decb
		bne	dmatlp
dmatend
		lda	,X
		beq	dmmatyes
		lda	sws_DMATCH_LEN
		cmpa	#12
		beq	dmmatyes
		tst	sws_DMATCH_WILD
		beq	dmatnomatch
dmmatyes
		CLC
		rts
dmatnomatch
		SEC
		rts

***********************************************************************
PrintDCat
	 **** Print disk no $ title ****
***********************************************************************
		bcs	pdcnospc
		lda	#' '
		jsr	PrintChrA
pdcnospc
		ldb	#' '
		jsr	BCDPrint4
		lda	#' '
		jsr	PrintChrA
	
		ldx	DP_FST_B0_GD_DSKTAB_PTR
		lda	15,X

		ldb	#12				; max # chars in title
pdcloop		lda	,X+
		beq	pdcspc
		jsr	PrintChrA
		decb
		bne pdcloop
pdcspc
		lda	#' '
pdcspclp
		jsr	PrintChrA
		decb
		bpl	pdcspclp
		ldx	DP_FST_B0_GD_DSKTAB_PTR
		tst	15,X
		bne	pdcnoprot
		ldb	#'P'				; ASC("P")
pdcnoprot	jmp	PrintChrA

pdcnotform	ldb	#13
		jsr	prt_Bspaces_API
		lda	#'U'				; unformatted
		jmp	PrintChrA
***********************************************************************
PrtDiskNo_API
	; Print 4 dig disk number in Drive B (was X)
***********************************************************************
		pshs	X,Y
		ldx	#VID_DRIVE_INDEX0
		lda	B,X
		sta	DP_FS_DISKNO + 1
		ldx	#VID_DRIVE_INDEX4
		lda	B,X
		anda	#1
		sta	DP_FS_DISKNO
		jsr	BinaryToBCD9
		clrb
		jsr	BCDPrint4
		puls	X,Y,PC
***********************************************************************
BCDPrint4
	; Print 4 dig DP_FS_BCD_RESULT padded with chr B
***********************************************************************
		ldy	#4
		lda	DP_FS_BCD_RESULT
		jsr	PrintDecA
		lda	DP_FS_BCD_RESULT + 1
	
***********************************************************************
PrintDecA
		sta	,-S
		lsra
		lsra
		lsra
		lsra
		jsr	pdec1
		lda	,S+
pdec1		anda	#$F
		beq	pdec2
		ldb	#'0'
		adda	#'0'
		jmp	PrintChrA
pdec2		leay	-1,Y
		bne	pdec3				; unless last char print pad char
		ldb	#'0'
pdec3		tfr	B,A
		jmp	PrintChrA

 **			
 **			
 **			IF _ABOUT_
 **				\\ *DABOUT -  PRINT INFO STRING
		TODOCMD	"CMD_DABOUT"
 **			.CMD_DABOUT
 **				JSR PrintString
 **				EQUS "DUTILS by Martin Mather "
 **			.vstr
 **				EQUS "(2011)",13
 **				NOP
 **				RTS
 **			ENDIF
 **			
 **				\\ *DBOOT <dno>/<dsp>
		TODOCMD	"CMD_DBOOT"
 **			.CMD_DBOOT
 **				JSR Param_SyntaxErrorIfNull
 **				LDA #0
 **				STA DP_FSW_CurrentDrv
 **				JSR Param_Disk			; DP_FSW_CurrentDrv=drive / B8=disk no.
 **				JSR LoadDrive
 **				LDA #$00
 **				JMP initMMFS
 **			
 **				\\ *DIN (<drive>)
 **				\\ Load drive
		TODOCMD	"CMD_DIN"
 **			.CMD_DIN
 **				JSR Param_DriveAndDisk
 **				\stx DP_FSW_CurrentDrv
 **				JMP LoadDrive 	; CA
 **			
 **				\\ *DOUT (<drive>)
 **				\\ Unload drive
 **				\\ Note: No error if drive not loaded
		TODOCMD	"CMD_DOUT"
 **			.CMD_DOUT
 **				JSR Param_OptionalDriveNo
 **			.unloaddrive
 **				JSR CheckCRC7
 **				LDX DP_FSW_CurrentDrv
 **				TXA
 **				STA VID_DRIVE_INDEX4,X
 **				JMP ResetCRC7
 **			
 **			
 **				\\ *DCAT ((<f.dno>) <t.dno>) (<adsp>)
 **			dcEnd%=$A8	; last disk in range
 **			dcCount%=$AA	; number of disks found
 **			

***********************************************************************
CMD_DCAT
***********************************************************************
		clra
		sta	DP_FST_B7_DCAT_GDOPT		; GetDisk excludes unformatted disks
		sta	DP_TR_AA_DCAT_COUNT
		sta	DP_TR_AA_DCAT_COUNT + 1
		jsr	Param_ReadNumAPI		; rn% @ B0
		bcs	dc_1				; not number
		std	DP_TR_A8_DCAT_END
		std	DP_FST_B7_DCAT_DNO
		jsr	Param_ReadNumAPI		; rn% @ B0
		bcs	dc_2				; not number
		std	DP_TR_A8_DCAT_END
		cmpd	DP_FST_B7_DCAT_DNO
		bpl	dc_3
badrange	jsr	ReportError
		fcb	$FF, "Bad range", 0
dc_1		ldd	#511
		std	DP_TR_A8_DCAT_END
dc_2		clrd
		std	DP_FST_B7_DCAT_DNO
dc_3		inc	DP_TR_A8_DCAT_END + 1		; set end to end + 1
		bne	dc_4
		inc	DP_TR_A8_DCAT_END

dc_4		jsr	DMatchInit_API
		bcs	DCAT_err_Syntax
		jsr	GetDiskFirst

		clrb
		lda	sws_DMATCH_LEN
		bne	dclp
		decb
		stb	sws_DMATCH_WILD			; set wildcard flag if len == 0

dclp
		ldd	DP_FST_B7_DCAT_DNO		; no next disk
		bmi	dcfin
		cmpd	DP_TR_A8_DCAT_END		; past end of range
		bhs	dcfin

		jsr	DMatch_API
		bcs	dcnxt
		jsr	PrintDCat
	
		lda	DP_TR_AA_DCAT_COUNT + 1
		adda	#1
		daa
		sta	DP_TR_AA_DCAT_COUNT + 1
		lda	DP_TR_AA_DCAT_COUNT
		adca	#0
		daa
		sta	DP_TR_AA_DCAT_COUNT

dcnxt
		jsr	CheckESCAPE
	
dcdonxt
		jsr	GetDiskNext
		jmp	dclp
	
dcfin		lda	#$86
		jsr	OSBYTE			; get cursor pos
		cmpx	#0
		beq	dcEven
		jsr	PrintNewLine
dcEven
		lda	DP_TR_AA_DCAT_COUNT
		ldy	#4
		clrb
		jsr	PrintDecA
		lda	DP_TR_AA_DCAT_COUNT + 1
		jsr	PrintDecA
		PRINT_STR	" disc"
		lda	DP_TR_AA_DCAT_COUNT
		bne	dcNotOne
		dec	DP_TR_AA_DCAT_COUNT + 1
		beq	dcOne
dcNotOne
		lda	#'s'			; ASC("s")
		jsr	PrintChrA
dcOne
		PRINT_STR	" found"
		jmp	PrintNewLine


DCAT_err_Syntax
		ldy	#tblDUtilsCommands_DCAT
		jmp	errSYNTAX_API

 **				\\ *DFREE
 **			dfFree%=$A8	; number of unformatted disks
 **			dfTotal%=$AA	; total number of disks
 **			dfPtr%=$B0
 **			
 **			.dfSyntax
 **				JMP errSYNTAX
 **			
		TODOCMD	"CMD_DFREE"
 **			.CMD_DFREE
 **			{
 **				JSR GSINIT_A
 **				BNE dfSyntax			; no parameters allowed
 **			
 **				LDX #0
 **				STX dfFree%
 **				STX dfFree%+1
 **				STX dfTotal%
 **				STX dfTotal%+1
 **			
 **				LDA #$80
 **				JSR CheckDiskTable
 **				LDA #$10
 **				STA dfPtr%
 **				LDA #MP+$0E
 **				STA dfPtr%+1
 **			
 **			.dfreelp
 **				LDY #15
 **				LDA (dfPtr%),Y
 **				CMP #$FF
 **				BEQ dffin
 **			
 **				SED
 **				TAY
 **				BPL dffmted
 **				CLC
 **				LDA dfFree%
 **				ADC #1
 **				STA dfFree%
 **				BCC dffmted
 **				INC dfFree%+1
 **			.dffmted
 **				CLC
 **				LDA dfTotal%
 **				ADC #1
 **				STA dfTotal%
 **				BCC dfnotval
 **				INC dfTotal%+1
 **			.dfnotval
 **				CLD
 **			
 **				CLC
 **				LDA dfPtr%
 **				ADC #16
 **				STA dfPtr%
 **				BNE dfreelp
 **				LDA dfPtr%+1
 **				EOR #1
 **				STA dfPtr%+1
 **				ROR A
 **				BCS dfreelp
 **				LDA sws_CurrentCat
 **				ADC #2
 **				CMP #($80+32)
 **				BEQ dffin
 **				JSR CheckDiskTable
 **				JMP dfreelp
 **			
 **			.dffin
 **				LDY #4
 **				LDX #0
 **				LDA dfFree%+1
 **				JSR PrintDecA
 **				LDA dfFree%
 **				JSR PrintDecA
 **				JSR PrintString
 **				EQUS " of "
 **				LDX #0
 **				LDY #4
 **				LDA dfTotal%+1
 **				JSR PrintDecA
 **				LDA dfTotal%
 **				JSR PrintDecA
 **				JSR PrintString
 **				EQUS " disc"
 **				LDA dfTotal%+1
 **				BNE dfNotOne
 **				LDA dfTotal%
 **				CMP #1
 **				BEQ dfOne
 **			.dfNotOne
 **				LDA #$73			; ASC("s")
 **				JSR PrintChrA
 **			.dfOne
 **				JSR PrintString
 **				EQUS " free (unformatted)"
 **				NOP
 **				JMP PrintNewLine
 **			}
 **			
 **				\\ *DDRIVE (<drive>)
 **				\\ List disks in drives
		TODOCMD	"CMD_DDRIVE"
 **			.CMD_DDRIVE
 **			{
 **				STY $B3
 **				LDA #$FF
 **				STA DP_FST_B7_DCAT_GDOPT			; GetDisk returns unformatted disks
 **				LDA #3
 **				STA DP_FSW_CurrentDrv			; Last drive to list
 **				LDY $B3
 **				JSR GSINIT_A
 **				BEQ ddsknoparam
 **				JSR Param_DriveNo_BadDrive
 **				BCC ddskloop			; always
 **			.ddsknoparam
 **				LDA #0
 **				\\ A = drive
 **			.ddskloop
 **				PHA
 **				TAX
 **				\\ print drive no
 **				LDA #$3A			; ASC(":")
 **				JSR OSWRCH
 **				CLC
 **				TXA
 **				ADC #$30
 **				JSR OSWRCH
 **			
 **				LDA VID_DRIVE_INDEX4,X
 **				BPL ddcont			; drive not loaded
 **			
 **				AND #1
 **				STA $B9
 **				LDA VID_DRIVE_INDEX0,X
 **				STA $B8
 **				JSR GetDiskFirst
 **				CMP #$FF
 **				BEQ ddcont
 **				SEC
 **				JSR PrintDCat
 **			
 **			.ddcont
 **				JSR OSNEWL
 **				PLA
 **				CMP DP_FSW_CurrentDrv
 **				BEQ ddskexit
 **				ADC #1
 **				BCC ddskloop			; always
 **			.ddskexit
 **				RTS
 **			}
 **			
 **				\\ Mark disk in current drive as formatted
 **				\\ and clear its disk catalogue entry
 **				\\ Used by *FORM
 **			.MarkDriveAsFormatted
 **			{
 **				SEC				; disk must be unformatted
 **				JSR GetDriveStatusC
 **				BPL jmpErrFormatted
 **				LDA #0
 **				TAY
 **			.masf_loop
 **				STA ($B0),Y			; clear title in catalogue
 **				INY
 **				CPY #15
 **				BNE masf_loop
 **				TYA				; A=$0F Unlocked disk
 **				BNE masf_status
 **			}
 **			
 **				\\ Mark disk as read only
 **			.dop_Protect
 **				LDA #$00
 **				BEQ dlul
 **			
 **				\\ Mark disk as writable
 **			.dop_Unprotect
 **				LDA #$0F
 **			.dlul
 **				PHA
 **			.dkconfirmed
 **				JSR GetDriveStatus
 **				BMI jmpErrNotFormatted
 **			.drestore
 **				PLA
 **				LDY #15
 **			.masf_status
 **				STA ($B0),Y
 **				JSR SaveDiskTable
 **				JMP LoadDrive			; reload disk
 **			
 **			.jmpErrNotFormatted
 **				JMP errNotFormatted
 **			.jmpErrFormatted
 **				JMP errFormatted
 **			
 **				\\ Mark disk as unformatted
 **			.dop_Kill
 **			{
 **				JSR IsEnabledOrGo
 **				JSR GetDriveStatus
 **				JSR CheckWriteProtect
 **				JSR GetDiskFirst
 **				JSR PrintString
 **				EQUS "Kill"
 **				NOP
 **				SEC
 **				JSR PrintDCat
 **				JSR PrintString
 **				EQUS " : "
 **				NOP
 **				JSR ConfirmYN
 **				PHP
 **				JSR PrintNewLine
 **				PLP
 **				BNE dkcancel
 **				LDA #$F0			; Unformatted disk
 **				PHA
 **				JMP dkconfirmed
 **			.dkcancel
 **				RTS
 **			}
 **			
 **				\\ Mark disk as formatted (without reformatting)
 **			.dop_Restore
 **				LDA #$0F
 **				PHA
 **				SEC 				; disk must be unformatted
 **				JSR GetDriveStatusC
 **				BMI drestore
 **				BPL jmpErrFormatted
 **			
 **				\\ Find first unformatted disk and load in drive
 **			.dop_New
 **				JSR FreeDisk
 **				BCS ErrNoFreeDisks		; no free disks
 **				\ load unformatted disk
 **				JSR LoadDrive
 **				\ message: disk# in drv#:
 **				JSR PrintString
 **				EQUS "Disc "
 **				LDX #0 === BBBBBBB
 **				JSR BCDPrint4
 **				JSR PrintString
 **				EQUS " in :"
 **				LDA DP_FSW_CurrentDrv
 **				LDX #0
 **				LDY #2
 **				JSR PrintDecA
 **				JMP OSNEWL
 **			
ErrNoFreeDisks
		jsr	ReportError
		fcb	$FF, "No free discs", 0
 **			
 **				\\**** Find first free disk ****
 **				\\ On exit: Word $B8=disk number
 **				\\ C=0=Found / C=1=Not Found
 **			.FreeDisk
 **			{
 **				LDA #$FF
 **				STA DP_FST_B7_DCAT_GDOPT			; GetDisk returns unformatted disk
 **				JSR GetDiskFirstAll
 **				BCS fdknotfound
 **				CMP #$F0			; Is it formatted?
 **				BEQ fdkfound			; No!
 **			.fdkloop
 **				JSR GetDiskNext
 **				BCS fdknotfound
 **				CMP #$F0
 **				BNE fdkloop
 **			.fdkfound
 **				CLC
 **			.fdknotfound
 **				RTS
 **			}
 **			
 **				\\ *DOP (P/U/N/K/R) (<drive>)
 **				\\ Options: P=Protect, U=Unprotect, N=New, K=Kill, R=Restore
		TODOCMD	"CMD_DOP"
 **			.CMD_DOP
 **			{
 **				JSR GSINIT_A
 **				BEQ opterr
 **			
 **				LDX #(dopex-dop)
 **			.optloop
 **				CMP dop,X
 **				BEQ optok
 **				DEX
 **				BPL optloop
 **			
 **			.opterr
 **				JMP errBADOPTION
 **			
 **			.optok
 **				TXA
 **				AND #$FE
 **				TAX
 **				LDA dopex+1,X
 **				PHA
 **				LDA dopex,X
 **				PHA
 **			
 **				INY
 **				JMP Param_OptionalDriveNo
 **			
 **			.dop	EQUS "rRkKnNuUpP"
 **			.dopex  EQUW dop_Restore-1
 **				EQUW dop_Kill-1
 **				EQUW dop_New-1
 **				EQUW dop_Unprotect-1
 **				EQUW dop_Protect-1
 **			}
 **			
 **			
 **				\ Include OSWORD emulation routines here
 **			
 **			INCLUDE "OSWORD7F.asm"
 **			
 **			
 **				\ Optional extras!
 **			IF _ROMS_
 **				INCLUDE "ROMS.asm"
 **			ENDIF
 **			IF _UTILS_
 **				INCLUDE "Utilities.asm"
 **			ENDIF
 **			IF _TUBEHOST_ AND NOT(_BP12K_)
 **				INCLUDE "TubeHost230.asm"
 **			ENDIF
 **			
 **			IF _BP12K_
 **				\ This code must be outside the 12K private RAM bank, so it can run
 **				\ successfully without us having copied our code into that bank.
 **				IF P%<$B000
 **				    SKIPTO $B000
 **				ENDIF
 **			
 **			.Init12K
 **			{
 **				PHP
 **				PHA
 **				TXA
 **				PHA
 **				TYA
 **				PHA
 **				LDA #0
 **				STA $B0
 **				LDA #$7F
 **				STA $B1
 **			
 **				LDA PagedRomSelector_RAMCopy
 **				ORA #$80
 **				TAX
 **				LDY #255
 **				BNE start_loop
 **			.loop
 **				LDA ($B0),Y
 **				STX PagedRomSelector_RAMCopy
 **				STX $FE30
 **				STA ($B0),Y
 **			.start_loop
 **				TXA
 **				AND #$7F
 **				STA PagedRomSelector_RAMCopy
 **				STA $FE30
 **				INY
 **				BNE loop
 **				INC $B1
 **				LDA $B1
 **				CMP #$B0
 **				BEQ done
 **				CMP #HI(MA+$0E00)
 **				BNE loop
 **				LDA #HI(MAEND)
 **				STA $B1
 **				BNE loop
 **			
 **			.done
 **				PLA
 **				TAY
 **				PLA
 **				TAX
 **				PLA
 **				PLP
 **				RTS
 **			}
 **			
 **			.PageIn12K
 **				PHP
 **				PHA
 **				LDA PagedRomSelector_RAMCopy
 **				ORA #$80
 **				STA PagedRomSelector_RAMCopy
 **				STA $FE30
 **				PLA
 **				PLP
 **				RTS
 **			
 **			.PageOut12K
 **				PHP
 **				PHA
 **				LDA PagedRomSelector_RAMCopy
 **				AND #$7F
 **				STA PagedRomSelector_RAMCopy
 **				STA $FE30
 **				PLA
 **				PLP
 **				RTS
 **			ENDIF
 **			
 **			PRINT "    code ends at",~P%," (",(guard_value - P%), "bytes free )"
 **			
 **			SAVE "", $8000, $C000
 **			


************************** UTILITIES.ASM ***********************************************

 **		\** MMFS ROM by Martin Mather
 **		\** Compiled using BeebAsm V1.04
 **		\** June/July 2011
 **		
 **			\ ****** START OF UTILITIES *****
 **		.Utils_SetBufPtr
 **		IF _SWRAM_
 **			LDA #UTILSBUF
 **			STA &AD
 **		ELSE
 **			LDX PagedRomSelector_RAMCopy
 **			LDA PagedROM_PrivWorkspaces,X	; Word AC -> 2nd PWSP Page
 **			AND #&3F			; Bits 7 & 6 are flags
 **			STA &AD
 **			INC &AD
 **		ENDIF
 **			RTS 
 **		
		TODOCMD	"CMD_TYPE"
 **		.CMD_TYPE
 **			JSR Utils_FilenameAtXY
 **			LDA #&00
 **			BEQ type
 **		
		TODOCMD	"CMD_LIST"
 **		.CMD_LIST
 **			JSR Utils_FilenameAtXY
 **			LDA #&FF
 **		.type
 **			STA &AB
 **			LDA #&40
 **			JSR OSFIND			; Open file for input
 **			TAY 				; Y=handle
 **			LDA #&0D
 **			CPY #&00
 **			BNE list_loop_entry		; If file opened
 **		
 **		.utils_filenotfound
 **			JMP err_FILENOTFOUND
 **		
 **		.list_loop
 **			JSR OSBGET
 **			BCS list_eof			; EOF exit loop
 **			CMP #&0A
 **			BEQ list_loop			; ignore &0A
 **			PLP 
 **			BNE list_skiplineno		; If don't print line number
 **			PHA 
 **			JSR Utils_PrintLineNo
 **			JSR PrintSpaceSPL
 **			PLA 
 **		.list_skiplineno
 **			JSR OSASCI
 **			BIT &FF
 **			BMI dump_loop			; Escape?
 **		.list_loop_entry
 **			AND &AB
 **			CMP #&0D			; Carriage return?
 **			PHP 				; (Always false if CMD_TYPE)
 **			JMP list_loop
 **		.list_eof
 **			PLP	 			; Print newline + exit
 **			JSR OSNEWL
 **		
 **		.Utils_CloseFile_Yhandle
 **			LDA #&00
 **			JMP OSFIND
 **		
		TODOCMD	"CMD_DUMP"
 **		.CMD_DUMP
 **			JSR Utils_FilenameAtXY
 **			LDA #&40
 **			JSR OSFIND			; Open file for input
 **			TAY 				; Y=handle
 **			BEQ utils_filenotfound
 **			JSR Utils_SetBufPtr
 **		.dump_loop
 **		{
 **			BIT &FF				; Check escape
 **			BMI Utils_ESCAPE_CloseFileY
 **			LDA &A9				; word A8 is the offset counter
 **			JSR Utils_PrintHexByte
 **			LDA &A8
 **			JSR Utils_PrintHexByte
 **			JSR PrintSpaceSPL
 **			LDA #&08
 **			STA &AC
 **			LDX #&00
 **		.dump_getbytes_loop
 **			JSR OSBGET
 **			BCS dump_eof			; If eof
 **			STA (&AC,X)			; save byte (usually &1800-&1807)
 **			JSR Utils_PrintHexByte
 **			JSR PrintSpaceSPL
 **			DEC &AC
 **			BNE dump_getbytes_loop
 **			CLC 
 **		.dump_eof
 **			PHP 
 **			BCC dump_noteof			; If not eof
 **		.dump_padnum_loop
 **			LDA #&2A			; Pad end of line with "** "
 **			JSR OSASCI
 **			JSR OSASCI
 **			JSR PrintSpaceSPL
 **			LDA #&00
 **			STA (&AC,X)
 **			DEC &AC
 **			BNE dump_padnum_loop
 **		.dump_noteof
 **			JSR dump_printchars
 **			JSR OSNEWL
 **			LDA #&08
 **			CLC 
 **			ADC &A8
 **			STA &A8
 **			BCC dump_inc
 **			INC &A9
 **		.dump_inc
 **			PLP 
 **			BCS Utils_CloseFile_Yhandle
 **			BCC dump_loop			; always
 **		.dump_printchars
 **			LDA #&08
 **			STA &AC
 **		.dump_chr_loop
 **			LDX #&00			; Print characters
 **			LDA (&AC,X)
 **			JSR ShowChrA			; Chr or "."
 **			JSR OSASCI
 **			DEC &AC
 **			BNE dump_chr_loop
 **			RTS
 **		}
 **		
 **		.Utils_ESCAPE_CloseFileY
 **			JSR osbyte7E_ackESCAPE2		; Acknowledge escape, close
 **			JSR Utils_CloseFile_Yhandle	; file Y and report error!
 **			JMP ReportESCAPE
 **		
		TODOCMD	"CMD_BUILD"
 **		.CMD_BUILD
 **		{
 **			JSR Utils_FilenameAtXY		; XY points to filename
 **			LDA #&80			; Open file for OUTPUT only
 **			JSR OSFIND
 **			STA &AB	;File handle
 **		.build_loop1
 **			JSR Utils_PrintLineNo		; Line number prompt:
 **			JSR PrintSpaceSPL		; Build Osword control block @ AC
 **			JSR Utils_SetBufPtr		; Normally ?AD=&18
 **			LDX #&AC			; Osword ptr YX=&00AC
 **			LDY #&FF
 **			STY &AE				; Max length = 256
 **			STY &B0
 **			INY 
 **			STY &AC				; So word AC=&1800 (normally)
 **			LDA #&20
 **			STA &AF				; min ASCII value accepted
 **			TYA 				; max value???
 **			JSR OSWORD			; OSWORD 0, YX=&00AC
 **			PHP 				; Read line from input
 **			STY &AA				; Y=line length
 **			LDY &AB				; Y=file handle
 **			LDX #&00
 **			BEQ build_loop2entry		; always
 **		.build_loop2
 **			LDA (&AC,X)			; Output line to file
 **			JSR OSBPUT
 **			INC &AC
 **		.build_loop2entry
 **			LDA &AC
 **			CMP &AA
 **			BNE build_loop2
 **			PLP 
 **			BCS Utils_ESCAPE_CloseFileY	; Escape pressed so exit
 **			LDA #&0D			; Carriage return
 **			JSR OSBPUT
 **			JMP build_loop1
 **		}
 **		
 **		.Utils_FilenameAtXY
 **			TSX 				; Return A=0 to OS
 **			LDA #&00
 **			STA &0107,X
 **			JSR Utils_SkipSpaces
 **			CMP #&0D
 **			BNE utils_notnullstr		; If not end of line
 **			JMP errSYNTAX			; Syntax Error!
 **		
 **		.utils_notnullstr
 **			LDA #&00			; Reset line counter
 **			STA &A8				; word &A8
 **			STA &A9
 **			PHA				; preserve A, but it's 0?
 **			TYA				; YX=TextPtr+Y
 **			CLC				; Used to pass to OSFIND
 **			ADC TextPointer			; ie. Filename
 **			TAX
 **			LDA TextPointer+1
 **			ADC #&00
 **			TAY
 **			PLA
 **			RTS
 **		
 **		;;.Utils_TextPointerAddY
 **		;;{
 **		;;	TYA 				; TextPointer += Y
 **		;;	CLC 				; (Where is this used?)
 **		;;	ADC TextPointer
 **		;;	STA TextPointer
 **		;;	BCC utils_tpexit
 **		;;	INC TextPointer
 **		;;.utils_tpexit
 **		;;	RTS
 **		;;}
 **		
 **		.utils_skipspcloop
 **			INY 				; Skip spaces
 **		.Utils_SkipSpaces
 **			LDA (TextPointer),Y
 **			CMP #&20
 **			BEQ utils_skipspcloop
 **			RTS
 **		
 **		.Utils_PrintLineNo
 **			SED 				; Incremenet & print line no.
 **			CLC 				; Word &A8=line no. in BCD
 **			LDA &A8
 **			ADC #&01
 **			STA &A8
 **			LDA &A9
 **			ADC #&00
 **			STA &A9				; hi byte
 **			CLD 
 **			JSR Utils_PrintHexByte
 **			LDA &A8				; lo byte
 **		
 **		.Utils_PrintHexByte
 **		{
 **			PHA
 **			JSR A_rorx4
 **			JSR Utils_PrintHexLoNibble	; hi nibble
 **			PLA 				; lo nibble
 **		.Utils_PrintHexLoNibble
 **			JSR NibToASC
 **			JSR OSASCI
 **			SEC
 **			RTS
 **		}
 **		
 **			\ ********** END OF UTILITIES **********
 **************************************** ROMS.ASM **********************************************

 **		\** MMFS ROM by Martin Mather
 **		\** Compiled using BeebAsm V1.04
 **		\** June/July 2011
 **		
 **			\ \\**    *ROMS (<rom>)    **//
***********************************************************************
CMD_ROMS
***********************************************************************

		clr	DP_TR_ROMS_FLAGS		; clear list type flags (0 = full list, $80 = if title matches)
		lda	#$0F
		sta	DP_TR_ROMS_LPCTR
		jsr	Sub_AADD_RomTablePtrBA
		SEC
		jsr	GSINIT
		beq	Label_A9FF_notnum2		; If null str (no parameter)
		stx	DP_TR_ROMS_STRPTR		; store params pointer
Label_A9E7_loop
		stx	DP_TR_ROMS_STRPTR		; and store pointer to first byte of param
		jsr	Param_ReadNumAPI
		bcs	Label_A9FF_notnum		
		cmpb	#16
		bhs	Label_A9E7_loop			; > 16 ignore
		stx	,--S				; save text pointer
		stb	DP_TR_ROMS_LPCTR		; Rom Nr
		jsr	Label_AA53_RomInfo
		ldx	,S++				; get back command pointer
		jsr	GSINIT_A			; get next command param
		bne	Label_A9E7_loop			; Another rom id?
		clra
		rts					; return A=0 to indicate command handled

Label_A9FF_notnum2
		stx	DP_TR_ROMS_STRPTR		; store params pointer
		CLC
Label_A9FF_notnum
		ror	DP_TR_ROMS_FLAGS		; Loop through roms
Label_AA01_loop	tst	DP_TR_ROMS_FLAGS
		bpl	Label_AA0A
		jsr	Sub_AA12_titlecmp		; Match title with parameter
		bcc	Label_AA0D_nomatch
Label_AA0A	jsr	Label_AA53_RomInfo
Label_AA0D_nomatch
		dec	DP_TR_ROMS_LPCTR
		bpl	Label_AA01_loop
		clra
		rts
	
Sub_AA12_titlecmp
		ldx	#$8009				; title
		ldy	DP_TR_ROMS_STRPTR		; param pointer
Label_AA1C_loop
		lda	,Y+
		cmpa	#$0D				; If end of str
		beq	Label_AA44
		cmpa	#'.'
		beq	Label_AA44			; If ="."
		cmpa	#'*'
		beq	Label_AA51_match		; If ="*"
		jsr	UcaseA2
		sta	DP_TR_ROMS_SAV
		jsr	Sub_AACF_ReadRom
		beq	Label_AA42_nomatch
		ldb	DP_TR_ROMS_SAV
		cmpb	#'#'				; "#"
		beq	Label_AA1C_loop
		jsr	UcaseA2
		cmpa	DP_TR_ROMS_SAV
		beq	Label_AA1C_loop
Label_AA42_nomatch
		CLC
		rts
	
Label_AA44
		jsr	Sub_AACF_ReadRom
		beq	Label_AA51_match
		cmpa	#' '
		beq	Label_AA44			; If =" "   skip spaces
		cmpa	#$0D
		bne	Label_AA42_nomatch		; If <>CR
Label_AA51_match
		SEC
		rts
	
Label_AA53_RomInfo
		ldb	DP_TR_ROMS_LPCTR		; Y=Rom nr
		ldy	DP_FS_TMP_PTR
		lda	B,Y
		beq	Label_AA42_nomatch		; If RomTable(Y)=0
		sta	,-S
		jsr	PrintStringImmed
		fcb	"Rom ", 0
		tfr	B,A
		jsr	PrintBCD			; Print ROM nr
		jsr	PrintStringImmed
		fcb	" : ", 0
		lda	#'('				; A="("
		jsr	PrintChrA
		tst	,S
		bmi	Label_AA78			; Bit 7 set = Service Entry
		lda	#' '				; A=" "
		bra	Label_AA7A				; always
Label_AA78
		lda	#'S'				; A="S"
Label_AA7A
		jsr	PrintChrA
		lda	#' '				; A=" "
		ldb	,S+
		aslb
		bpl	Label_AA86			; Bit 6 set = Language Entry
		lda	#'L'				; A="L"
Label_AA86
		jsr	PrintChrA
		lda	#')'				; A=")"
		jsr	PrintChrA
		jsr	PrintSpaceSPL
		jsr	Label_AA9A_PrtRomTitle
		jsr	PrintNewLine
		SEC
		rts

Label_AA9A_PrtRomTitle
		ldx	#$8007				; Print copyright offset title
		jsr	Sub_AACF_ReadRom		; Get copyright pointer
		tfr	A,B
		lda	#$80
		std	DP_TR_ROMS_COPYPTR		; points at copyright message
		leax	1,X				; X=&8009
		ldb	#20
		jsr	Sub_AAC2_PrintRomStr
		bcc	Label_AAB7_rts			; If reached copyright offset (no version string)
1		jsr	PrintSpaceSPL			; pad out
		decb
		bne	1B
		jsr	Sub_AAC2_PrintRomStr
Label_AAB7_rts
		RTS
	
Label_AAB8_loop
		cmpa	#' '
		bhs	3F			; If >=" "
		lda	#' '
3		jsr	PrintChrA
		decb
Sub_AAC2_PrintRomStr
		cmpx	DP_TR_ROMS_COPYPTR
		bhs	1F
		jsr	Sub_AACF_ReadRom
		bne	Label_AAB8_loop
		SEC				; C=0=Terminator
1		rts
Sub_AACF_ReadRom
		stb	,-S
		ldb	DP_TR_ROMS_LPCTR
		jsr	OSRDRM				; get ROM byte
		leax	1,X
		tsta
		puls	B,PC
 **		
Sub_AADD_RomTablePtrBA
		pshs	X,Y
		lda	#$AA			; ROM information table @ X
		jsr	osbyte_X0YFF
		stx	DP_FS_TMP_PTR
		puls	X,Y,PC
 **		
 **		.Sub_AAEA_StackAZero
 **			TSX 				; Change value of A to 0?
 **			LDA #&00
 **			STA &0107,X
 **			RTS
 **		}	\ End of *ROMS code

 		include "vinc.asm"

		SECTION "tables_and_strings"

tblParams
		FCB	'<' + $80,"drive>"				;1
		FCB	'<' + $80,"afsp>"				;2
		FCB	'(' + $80,"L)"					;3
		FCB	'(' + $80,"<drive>)"				;4
		FCB	'(' + $80,"<drive>)..."			;5
		FCB	'(' + $80,"<dir>)"				;6
		FCB	'<' + $80,"dno>/<dsp>"				;7
		FCB	'<' + $80,"fsp>"				;8
		FCB	'P' + $80,"/U/N/K/R"				;9
		FCB	'<' + $80,"title>"				;A
		FCB	'(' + $80,"<rom>)"				;B
		FCB	'<' + $80,"source> <dest.>"			;C
		FCB	'<' + $80,"old fsp> <new fsp>"			;D
		FCB	'(' + $80,"(<f.dno>) <t.dno>) (<adsp>)"	;E
		FCB	'4' + $80,"0/80"				;F
		FCB	$FF

strBootMessage
	fcb	"Vinculum USBFS=", $0

 	* COMMAND TABLE 1		; MMFS commands each command followed by 
					; 2 parameter style numbers in nybbles (index to tblParams) 
					; bit 7 always set for terminator
tblFSCommands
	FCB			$FF		; first command # index - 1
	FCB	"ACCESS",	$80+$32
	FCB	"BACKUP",	$80+$0C
	FCB	"CLOSE",	$80
	FCB	"COMPACT",	$80+$05
	FCB	"COPY",		$80+$2C
	FCB	"DELETE",	$80+$08
	FCB	"DESTROY",	$80+$02
	FCB	"DIR",		$80+$06
	FCB	"DRIVE",	$80+$01
	FCB	"ENABLE",	$80
	FCB	"EX",		$80+$06
	FCB	"FORM",		$80+$5F
	FCB	"FREE",		$80+$04
tblCommand1_info
	FCB	"INFO",		$80+$02
	FCB	"LIB",		$80+$06
	FCB	"MAP",		$80+$04
	FCB	"RENAME",	$80+$0D
	FCB	"TITLE",	$80+$0A
	FCB	"VERIFY",	$80+$05
	FCB	"WIPE",		$80+$02
	FCB			0			; End of table

tblUtilsCommands			; UTILS commands (.tblUtilsCommands)
	FCB (tblUtilsCommandPointers-tblFSCommandPointers)/2-1		; first command # index - 1
	FCB	"BUILD",	$80+$08
	FCB	"DUMP",		$80+$08
	FCB	"LIST",		$80+$08
	FCB	"ROMS",		$80+$0B
	FCB	"TYPE",		$80+$08
	FCB			0

tblSelectCommands			; select commands?
	FCB	(tblSelectCommandPointers-tblFSCommandPointers)/2-1
	FCB	"USBFS",	$80
	FCB			0

	* COMMAND TABLE 3		; HELP command tails rather than actual commands
tblHelpCommands
	FCB	(tblHelpCommandPointers-tblFSCommandPointers)/2-1
	FCB	"DUTILS",	$80
	FCB	"USBFS",	$80
	FCB	"UTILS",	$80
	FCB			0

tblDUtilsCommands
	FCB	(tblDUtilsCommandPointers-tblFSCommandPointers)/2-1
	FCB	"BOOT",		$80+$07
tblDUtilsCommands_DCAT
	FCB	"CAT",		$80+$0E
	FCB	"DRIVE",	$80+$04
	FCB	"FREE",		$80
	FCB	"IN",		$80+$74
	FCB	"OP",		$80+$49
	FCB	"OUT",		$80+$04
	FCB	"RECAT",	$80
	FCB	"ABOUT",	$80
	FCB			0


	** Address of sub-routines
	** If bit 15 clear, call VINC_BEGIN2
tblFSCommandPointers
	FDB	CMD_ACCESS
	FDB	CMD_BACKUP
	FDB	CMD_CLOSE
	FDB	CMD_COMPACT
	FDB	CMD_COPY
	FDB	CMD_DELETE
	FDB	CMD_DESTROY
	FDB	CMD_DIR
	FDB	CMD_DRIVE
	FDB	CMD_ENABLE
	FDB	CMD_EX
	FDB	CMD_FORM-$8000
	FDB	CMD_FREE
	FDB	CMD_INFO
	FDB	CMD_LIB
	FDB	CMD_MAP
	FDB	CMD_RENAME
	FDB	CMD_TITLE
	FDB	CMD_VERIFY-$8000
	FDB	CMD_WIPE
	FDB	CMD_notFound_tblFS

tblUtilsCommandPointers
	FDB	CMD_BUILD
	FDB	CMD_DUMP
	FDB	CMD_LIST
	FDB	CMD_ROMS
	FDB	CMD_TYPE
	FDB	CMD_notFound_tblUtils

tblSelectCommandPointers
	FDB	CMD_USBFS
	FDB	CMD_notFound_tblSelect

tblHelpCommandPointers
	FDB	CMD_HELP_DUTILS
	FDB	CMD_HELP_USBFS
	FDB	CMD_UTILS
	FDB	CMD_notFound_tblHelp

tblDUtilsCommandPointers
	FDB	CMD_DBOOT-$8000
	FDB	CMD_DCAT-$8000
	FDB	CMD_DDRIVE-$8000
	FDB	CMD_DFREE-$8000
	FDB	CMD_DIN-$8000
	FDB	CMD_DOP-$8000
	FDB	CMD_DOUT-$8000
	FDB	CMD_DRECAT-$8000
	FDB	CMD_DABOUT
	FDB	CMD_notFound_tblDUtils

tblEOFCommandPointers

; Vector table copied to $0212
tblVectors
		fdb	EXTVEC_ENTER_FILEV	; FILEV
		fdb	EXTVEC_ENTER_ARGSV	; ARGSV
		fdb	EXTVEC_ENTER_BGETV	; BGETV
		fdb	EXTVEC_ENTER_BPUTV	; BPUTV
		fdb	EXTVEC_ENTER_GBPBV	; GBPBV
		fdb	EXTVEC_ENTER_FINDV	; FINDV
		fdb	EXTVEC_ENTER_FSCV	; FSCV
tblVectorsEnd
tblVectorsSize	EQU	(tblVectorsEnd - tblVectors)/2
	
; Extended vector table
tblExtendedVectors
		fdb	FILEV_ENTRY
		fdb	ARGSV_ENTRY
		fdb	BGETV_ENTRY
		fdb	BPUTV_ENTRY
		fdb	GBPBV_ENTRY
		fdb	FINDV_ENTRY
		fdb	FSCV_ENTRY

tblFSCVoper
		fdb	fscv0_starOPT
		fdb	fscv1_EOF_Yhndl
		fdb	fscv2_4_11_starRUN
		fdb	fscv3_unreccommand
		fdb	fscv2_4_11_starRUN
		fdb	fscv5_starCAT
		fdb	fscv6_shutdownfilesys
		fdb	fscv7_hndlrange
		fdb	fscv8_osabouttoproccmd
		fdb	fscv9_starEX
		fdb	fscv10_starINFO
		fdb	fscv2_4_11_starRUN

tblServiceCallDispatch
		FDB	SVC_NULL				; 0
		FDB	SVC_1_abswksp_req			; 1
		FDB	SVC_2_relwksp_req			; 2
		FDB	SVC_3_autoboot				; 3
		FDB	SVC_4_ukcmd				; 4
		FDB	SVC_NULL				; 5
		FDB	SVC_NULL				; 6
		FDB	SVC_NULL				; 7
		FDB	SVC_8_ukosword				; 8
		FDB	SVC_9_help				; 9
		FDB	SVC_A_claimabswksp			; A

		; OSFILE tables
tblFILEVops
		FDB	osfileFF_loadfiletoaddr
		FDB	osfile0_savememblock
		FDB	osfile1_updatecat
		FDB	osfile2_wrloadaddr
		FDB	osfile3_wrexecaddr
		FDB	osfile4_wrattribs
		FDB	osfile5_rdcatinfo
		FDB	osfile6_delfile
 **			
 **				\ GBPB tables
 **			.gbpbv_table1
 **				EQUB LO(CMD_notFound_tblUtils)
 **				EQUB LO(gbpb_putbytes)
 **				EQUB LO(gbpb_putbytes)
 **				EQUB LO(gbpb_getbyteSAVEBYTE)
 **				EQUB LO(gbpb_getbyteSAVEBYTE)
 **				EQUB LO(gbpb5_getmediatitle)
 **				EQUB LO(gbpb6_rdcurdirdevice)
 **				EQUB LO(gbpb7_rdcurlibdevice)
 **				EQUB LO(gbpb8_rdfilescurdir)
 **			
 **			.gbpbv_table2
 **				EQUB HI(CMD_notFound_tblUtils)
 **				EQUB HI(gbpb_putbytes)
 **				EQUB HI(gbpb_putbytes)
 **				EQUB HI(gbpb_getbyteSAVEBYTE)
 **				EQUB HI(gbpb_getbyteSAVEBYTE)
 **				EQUB HI(gbpb5_getmediatitle)
 **				EQUB HI(gbpb6_rdcurdirdevice)
 **				EQUB HI(gbpb7_rdcurlibdevice)
 **				EQUB HI(gbpb8_rdfilescurdir)
 **			
 **			.gbpbv_table3
 **				EQUB $04
 **				EQUB $02
 **				EQUB $03
 **				EQUB $06
 **				EQUB $07
 **				EQUB $04
 **				EQUB $04
 **				EQUB $04
 **				EQUB $04
 **			


 **			
 **			cmdtab1size= (tblUtilsCommandPointers-tblFSCommandPointers)/2-1
 **			cmdtab2size= (tblSelectCommandPointers-tblUtilsCommandPointers)/2-1
 **			cmdtab22size= (tblHelpCommandPointers-tblSelectCommandPointers)/2-1
 **			cmdtab3size= (tblDUtilsCommandPointers-tblHelpCommandPointers)/2-1
 **			cmdtab4size= (tblEOFCommandPointers-tblDUtilsCommandPointers)/2-1
 **			
 **			cmdtab2= tblUtilsCommands-tblFSCommands
 **			cmdtab22= tblSelectCommands-tblFSCommands
 **			cmdtab3= tblHelpCommands-tblFSCommands
 **			cmdtab4= tblDUtilsCommands-tblFSCommands
 **			
 **				\ End of address tables
 **			
 **			

diskoptions_table
		fcb	"off",0
		fcb	"LOAD"
		fcb	"RUN",0
		fcb	"EXEC"
