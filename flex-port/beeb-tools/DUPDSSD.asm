* DB: 2018-04-01 - hacked together from FLEX sources, format a flex disk

		include "../../includes/common.inc"
		include "../../includes/hardware.inc"
		include "../../includes/oslib.inc"

		


		ORG	$1900							; BBC MICRO


		lda	#OSFIND_OPENIN
		ldx	#str_filename
		jsr	OSFIND
		tsta
		lbeq	brkNotFound
		sta	file_handle

		clr	var_trk
		clr	var_sec		


		; select drive 0
		clr	phoney_fcb + 3
		jsr	DRV

		;; move to track 0
		jsr	REST

copy_sector_loop
		lda	#13
		jsr	OSWRCH
		lda	var_trk
		jsr	PrHex
		lda	#' '
		jsr	OSWRCH
		lda	var_sec
		jsr	PrHex


		ldd	#$FFFF
		std	gbpb_block+3
		ldd	#sector_buf
		stb	gbpb_block+1
		sta	gbpb_block+2
		ldd	#0
		std	gbpb_block+7
		ldd	#$100
		stb	gbpb_block+5
		sta	gbpb_block+6
		ldb	file_handle
		stb	gbpb_block+0
		ldx	#gbpb_block
		lda	#OSGBPB_READ_NOPTR
		jsr	OSGBPB


		; write sector
		lda	var_trk
		ldb	var_sec
		ldx	#sector_buf
		jsr	WRITE
		bne	write_error

		; increment sector
		lda	var_sec
		inca
		tst	var_trk
		bne	1F
		cmpa	#1
		bne	1F
		inca
1		sta	var_sec
		cmpa	#SMAXS1
		bls	copy_sector_loop
		
		; next track

		lda	var_trk
		inca
		cmpa	#MAXTRK
		beq	copy_finish
		sta	var_trk
		lda	#1
		sta	var_sec

		; set side 0, next track

		bra	copy_sector_loop


copy_finish
		jsr	OSNEWL
close_file
		ldb	file_handle
		clra
		tfr	D,Y
		jsr	OSFIND				; close file

		rts


write_error
		ldx	#str_write_error
		jsr	PrStr

		tfr	B,A
		jsr	PrHex
		jsr	OSNEWL

		jsr	close_file

		DO_BRK	$FF, "Write error", 0

PrStr	lda	,X+
	beq	1F
	jsr	OSASCI
	bra	PrStr
1	rts


PrHex	pshs	A
	bsr	OUTHL
	lda	,S
	bsr	OUTHR
	puls	A,PC

OUTHL	LSRA 						;move left 4 places
	LSRA
	LSRA
	LSRA
OUTHR	ANDA #$0F					; mask off 4 lsb
	ADDA #$30					; add ascii bias
	CMPA #$39					; is it greater than 9?
	BLS OUTIT					; print if not
	ADDA #$07					; offset to ascii "A"
OUTIT	JMP OSWRCH					; print it


**********************************************************************************
* INCLUDE WD specific driver stuff
		include "../drivers/wd177x/wd177x.inc"

**********************************************************************************
* INCLUDE drivers.asm
		include "../drivers/wd177x/drivers-beeb.asm"


phoney_fcb	rmb	16

file_handle	rmb	1
var_trk		rmb	1
var_sec		rmb	1

brkNotFound	DO_BRK	$FF, "Not found"

str_filename	fcb	":0.BBCFLEX9.dsk", 13, 0
str_write_error	fcb	13,"Write error: ",0

gbpb_block	rmb	$D

sector_buf	rmb	256