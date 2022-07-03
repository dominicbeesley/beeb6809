

ADDR_ERRBUF	EQU	$100				; base of stack!
PG_EEPROM_BASE	EQU	$9000				; base phys/jim address of EEPROM is $90 0000
							; note: this is a second copy of the EEPROM which
							; also appears based at $80 0000

OSWORD_BLTUTIL	EQU	$99				; blutils #

OSWORD_OP_ALLOC EQU	$10
OSWORD_OP_FREE  EQU	$11

JIM_SCRATCH	EQU	$00FD				; page address of scratch space

;offsets in scrarch page
SCR_JIMDEVSAVE	EQU	$00				; belt and braces used in cases of a BRK

OSWORD_BLTUTIL_FLAG_CURRENT	EQU $80
OSWORD_BLTUTIL_FLAG_ALTERNATE	EQU $40
OSWORD_BLTUTIL_FLAG_IGNOREMEMI	EQU $20
OSWORD_BLTUTIL_FLAG_MAP1	EQU $01

OSWORD_BLTUTIL_RET_FLASH	EQU $80			; if memory is chip flash
OSWORD_BLTUTIL_RET_SYS		EQU $40			; bank also base set to FF 80xx
OSWORD_BLTUTIL_RET_MEMI		EQU $20
OSWORD_BLTUTIL_RET_ISCUR	EQU $02
OSWORD_BLTUTIL_RET_MAP1		EQU $01

VERSION_NAME	MACRO
		FCB	"BLTUTIL"
		ENDM

		;TODO : move these to autogen'd files? Agree version # with JGH
VERSION_BYTE	MACRO
		FCB	3
		ENDM

VERSION_STRING	MACRO
		FCB	"0.05"
		ENDM

M_ERROR		MACRO
		jsr	BounceErrorOffStack
		ENDM

TODO		MACRO	error
		M_ERROR
		FCB	$FF
		FCB	error
		FCB	0
		ENDM

CLAIMDEV	MACRO
		jsr	jimClaimDev
		ENDM

SJTE		MACRO
		FCB	\1
		FDB	\2
		ENDM


zp_trans_tmp	EQU	$A8				; transient command buffer
zp_trans_acc	EQU	$AC				; 4 byte accumulator used in hex parsers
zp_tmp_ptr	EQU	$AC				; !! NOTE: overlaps acc

zp_SRCOPY_src	EQU	zp_trans_tmp + 1
zp_SRCOPY_dest	EQU	zp_trans_tmp + 0
zp_SRCOPY_flags	EQU	zp_trans_tmp + 2		; when negative dest if a flash

zp_ROMS_ctr	EQU	zp_trans_tmp + 0
zp_ROMS_copyptr	EQU	zp_trans_tmp + 1
zp_ROMS_flags	EQU	zp_trans_tmp + 3
zp_ROMS_OS99ret	EQU	zp_trans_acc + 2
zp_ROMS_bank	EQU	zp_trans_acc + 3

zp_ERASE_dest	EQU	zp_trans_tmp + 0
zp_ERASE_flags	EQU	zp_trans_tmp + 1
zp_ERASE_ctr	EQU	zp_trans_tmp + 2
zp_ERASE_errct	EQU	zp_trans_tmp + 3
zp_ERASE_bank	EQU	zp_trans_tmp + 5

zp_SRLOAD_dest	EQU	zp_trans_tmp + 0
zp_SRLOAD_flags	EQU	zp_trans_tmp + 1
zp_SRLOAD_ptr	EQU	zp_trans_tmp + 2
zp_SRLOAD_tmpA	EQU	zp_trans_tmp + 4		; note overlaps acc
zp_SRLOAD_bank	EQU	zp_trans_tmp + 5		; note overlaps acc

SRLOAD_buffer_page	EQU	$30

zp_mdump_addr	EQU	zp_trans_tmp + 0
zp_mdump_len	EQU	zp_trans_tmp + 4		; not overlaps acc
zp_mdump_cols	EQU	zp_mos_txtptr			; allows 32 bit addressing

; we can claim to be a language here...well sort of...
ZP_NUKE_LBAS		EQU	$0
ZP_NUKE_ERRPTR		EQU	ZP_NUKE_LBAS + 0
ZP_NUKE_S_TOP		EQU	ZP_NUKE_LBAS + 2
ZP_NUKE_ROMSF		EQU	ZP_NUKE_LBAS + 4
ZP_NUKE_PREVLANG	EQU	ZP_NUKE_LBAS + 5
STR_NUKE_CMD		EQU	$700

zp_blturbo_old	EQU	zp_trans_tmp + 0
zp_blturbo_new	EQU	zp_trans_tmp + 1
zp_blturbo_ptr	EQU	zp_trans_tmp + 2
zp_blturbo_fl	EQU	zp_trans_tmp + 4


PAGE_ROMSCRATCH		EQU	$0080
PAGE_SAMPLETBL		EQU	$0081
PAGE_SOUNDWKSP		EQU	$0083
PAGE_SOUNDBUFFERS	EQU	$0084
PAGE_RAM_TOP_BLITTER	EQU	$1C00			; note leave room for SWRAM!
PAGE_RAM_TOP_PAULA	EQU	$0800


			; offsets within scratch space
SCRATCH_CHECKSUM	EQU	$00			; not used currently (reset on break)
SCRATCH_HEAPTOP		EQU	$04			; top of head / ram
SCRATCH_HEAPBOT		EQU	$06			; bottom of heap / extent allocated to heap (may contain holes)
SCRATCH_HEAPLIM		EQU	$08			; lower limit for heap, will not allocate below here

SAMTBL_SZ		EQU	8			; size of a table entry
SAMTBLOFFS_BASE 	EQU	0			; page number of start of sample
SAMTBLOFFS_LEN  	EQU	2			; length in samples
SAMTBLOFFS_REPL 	EQU	4			; repeat offset
SAMTBLOFFS_FLAGS	EQU	7


			; offsets within the sound workspace page at 8300
; the following are all in the ROM workspace at JIM 00 8000
SNDWKSP_SOUNDFLAGS	EQU	$00			
SCR_FLAG_SND_EN		EQU	$80			; enabled flag

SND_BUFFER_NUMBER_0	EQU	$14			; buffer numbers are $14..$1B for channels 0..7
SND_BUF_LEN		EQU	21
SND_NUM_CHANS		EQU	8

SNDWKSP_OLDINSV		EQU	$02
SNDWKSP_OLDREMV		EQU	$04
SNDWKSP_OLDCNPV		EQU	$06
SNDWKSP_OLDBYTEV	EQU	$08

SNDWKDP_SCRATCH8	EQU	$10			; 8 bytes of scratch space

; note the following need to be >SND_BUFFER_NUMBER_0 to avoid LDA nnn-$14,X tickling FRED
SNDWKSP_BUF_BUSY_0	EQU	$20			; 1 byte for each channel - shows if there is stuff in the buffer
SNDWKSP_BUF_OUT_0	EQU	$28			; 1 byte for each channel - pointer into buffer
SNDWKSP_BUF_IN_0	EQU	$30			; 1 byte for each channel - pointer into buffer
SNDWKSP_ACTIVE		EQU	$38			; sound channel active flags 



SNDWKSP_VAR_START		EQU $40
SNDWKSP_QUEUE_OCC		EQU $40
SNDWKSP_AMP_CUR			EQU $48
SNDWKSP_AMP_PHASE_CUR		EQU $50			; current amplitude phase of envelope 0..3
SNDWKSP_AMP_BASE_PITCH		EQU $58
SNDWKSP_PITCH_PHASE_CUR		EQU $60
SNDWKSP_PITCH_PH_STEPS		EQU $68
SNDWKSP_DURATION		EQU $70			; duration from SOUND command
SNDWKSP_DURATION_SUB		EQU $78			; counts down from 5..0 to give 50ms per duration above
SNDWKSP_ENVELOPE_OFFS		EQU $80			; offset into envelope or -1 for no envelope
SNDWKSP_ENV_STEPREPEAT		EQU $88			; step length, b7=repeat flag
SNDWKSP_SYNC_FLAG		EQU $90
SNDWKSP_SYNC_HOLD_PARAM		EQU $98
SNDWKSP_PITCH_SETTING		EQU $A0
SNDWKSP_PITCH_DEV		EQU $A8
SNDWKSP_SAMPLE_NO		EQU $B0

SNDWKSP_SYNC_CHANS		EQU $B8
SNDWKSP_AMP_STEP		EQU $B9
SNDWKSP_AMP_TARGET		EQU $BA
SNDWKSP_SYNC_HOLD_COUNT		EQU $BB
SNDWKSP_WS_0			EQU $BC
SNDWKSP_FREQ_LO			EQU $BD
SNDWKSP_FREQ_HI			EQU $BE
SNDWKSP_WS_3			EQU $BF
SNDWKSP_DEF_SAM			EQU $C0			; table of default sample numbers per channel 0..31|$80
SNDWKSP_VAR_END			EQU $C8


SNDBUF_BUF_0		EQU	$00			; sound buffers 21 bytes per channel


SCRATCH_TMP		EQU	$80			; 128 bytes of scratch space for the current
							; command - do not use in service routines

