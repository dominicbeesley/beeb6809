; (c) Modplay09.asm - a tracker module player for the 6x09 processor and the
; Dossytronics blitter board
;
; Loads a protracker module into chipram and sets up ready for playing
;
; All code is relative so can be loaded and exec'd anywher
; 

;;;
;;;		include "../../includes/hardware.inc"
;;;		include "../../includes/oslib.inc"
;;;		include "../../includes/common.inc"
;;;		include "../../includes/mosrom.inc"


lcl_blkszpgs	EQU	0				; # of pages in a block - passed in
lcl_modbase	EQU	1				; page in sys memory

; following used while loading data to chip RAM
lcl_fh		EQU	2				; local var file handle
lcl_chippag	EQU	3				; page # in chip memory
lcl_ext		EQU	5				; overlaps following!
lcl_OSGBPB_blk	EQU	5

; following used while setting up local sample area
lcl_songmax	EQU	2
lcl_samchipaddr EQU	3				; 3 byte CHIP address
lcl_samidx	EQU	6
lcl_replen	EQU	7				; 2 byte sample repeat length

lcl_len		EQU	18



;===============================================================================
mod_load
;===============================================================================

;	On Entry:
;		X => filename, 13
;		A => where to load module play info to system RAM (page #)
;		B => size of load block in pages
;	Trashes D,X,Y,U

		leas	-lcl_len,S
		leau	,S

		stb	lcl_blkszpgs,U
		sta	lcl_modbase,U

		lda	#OSFIND_OPENIN
		OSCALL	OSFIND
		tsta
		beq	brkNotFound
		sta	lcl_fh,U			; store filehandle

		; get file size
		m_tay
		leax	lcl_ext,U
		lda	#OSARGS_EXT
		OSCALL	OSARGS

		tst	lcl_ext+3,U			; ext returned is LE, get number of pages
		bne	brkTooBig			; if high byte > 0 too long

		lda	lcl_ext+2,U			; size * 64K
		cmpa	#$08
		bhs	brkTooBig			; limit to 512K : TODO: this needs more thought!?

		bsr	mod_load_home

		ldx	#0
		ldd	lcl_ext+1,U
		exg	A,B				; ext returned is LE, get number of pages
mod_div_lp	subb	lcl_blkszpgs,U			; subtract size of block
		sbca	#0
		leax	1,X
		bpl	mod_div_lp			; keep going until -ve 
		; X now contains blocks+1
		tfr	X,D

1		lda	#'.'
		OSCALL	OSWRCH
		decb
		bne	1B

		ldd	#MODULE_CPAGE			; load module at specified addr
		std	lcl_chippag,U

		lda	lcl_fh,U
		sta	lcl_OSGBPB_blk,U

		bsr	mod_load_home

		bra	mod_load_loop



brkNotFound
		DO_BRK	$FF, "Not Found"
brkTooBig
		bsr	mod_load_close
		DO_BRK	$FF, "Mod too big"

mod_load_home	lda	#31
		OSCALL	OSWRCH
		clra
		OSCALL	OSWRCH
		OSJMP	OSWRCH
		rts

mod_load_close	lda	#0
		ldb	lcl_fh,U
		tfr	D,Y
		OSJMP	OSFIND

mod_load_loop
		; TODO: ENDIAN: this is all LE - need to change to BE or fix API?
		lda	#$FF
		sta	lcl_OSGBPB_blk + 4,U		;load address
		sta	lcl_OSGBPB_blk + 3,U
		lda	lcl_modbase,U
		sta	lcl_OSGBPB_blk + 2,U		
		clra
		sta	lcl_OSGBPB_blk + 1,U		
		sta	lcl_OSGBPB_blk + 8,U
		sta	lcl_OSGBPB_blk + 7,U
		sta	lcl_OSGBPB_blk + 5,U		
		lda	lcl_blkszpgs,U			; number of pages in a block
		sta	lcl_OSGBPB_blk + 6,U		;count == $4000		
		lda	#OSGBPB_READ_NOPTR
		leax	lcl_OSGBPB_blk,U
		OSCALL	OSGBPB
		pshs	CC				; save OSGBPB return in carry flag

		; always copy a whole block to chip ram - even if not a full one loaded!
		lda	my_jim_dev
		cmpa	#JIM_DEVNO_BLITTER
		beq	mod_load_blitter_cpy_1

		; load using JIM interface and loop - assuming dev has already been set
		lda	lcl_modbase,U
		clrb
		tfr	D,X
		ldd	lcl_chippag,U
		std	fred_JIM_PAGE_HI
		ldb	lcl_blkszpgs,U
		pshs	B
		clrb
1		ldy	#JIM
2		lda	,X+
		sta	,Y+
		decb
		bne	2B
		dec	,S
		beq	3F
		inc	fred_JIM_PAGE_LO
		bne	1B
		inc	fred_JIM_PAGE_HI
		bne	1B
3		leas	1,S
		bra	mod_load_cpy_done_1

mod_load_blitter_cpy_1
		jsr	jimHardwarePage
		clra
		sta	jim_DMAC_DMA_SEL
		sta	jim_DMAC_DMA_DEST_ADDR + 2
		lda	#$FF
		sta	jim_DMAC_DMA_SRC_ADDR + 0
		lda	lcl_modbase,U
		sta	jim_DMAC_DMA_SRC_ADDR + 1
		clrb	
		stb	jim_DMAC_DMA_SRC_ADDR + 2
		ldx	lcl_chippag,U
		stx	jim_DMAC_DMA_DEST_ADDR + 0	
		lda	lcl_blkszpgs,U
		subd	#1
		std	jim_DMAC_DMA_COUNT
		lda	#DMACTL_ACT+DMACTL_HALT+DMACTL_STEP_DEST_UP+DMACTL_STEP_SRC_UP
		sta	jim_DMAC_DMA_CTL

mod_load_cpy_done_1
		; increment blit address
		ldd	lcl_chippag,U
		addb	lcl_blkszpgs,U
		adca	#0
		std	lcl_chippag,U

		lda	#'#'
		OSCALL	OSWRCH

		puls	CC
		lbcc	mod_load_loop

		lbsr	mod_load_close

		; the mod is now loaded up into CHIP RAM we need to get
		; the sampleinfo table back into system memory

		; get back sample info from chip ram and build a smaller sample table

		lda	my_jim_dev
		cmpa	#JIM_DEVNO_BLITTER
		beq	mod_load_cpy_blitter_2

		ldd	#MODULE_CPAGE
		std	fred_JIM_PAGE_HI
		lda	lcl_modbase
		clrb
		tfr	D,X
		ldb	#5				; number of pages to copy back we only really need 1083
		pshs	B
		clrb
1		ldy	#JIM
2		lda	,Y+
		sta	,X+
		decb
		bne	2B
		dec	,S
		beq	3F
		inc	fred_JIM_PAGE_LO
		bne	1B
		inc	fred_JIM_PAGE_HI
		bne	1B
3		leas	1,S
		bra	mod_load_cpy_done_2

mod_load_cpy_blitter_2
		clr	jim_DMAC_DMA_SEL
		clr	jim_DMAC_DMA_DEST_ADDR + 2
		clr	jim_DMAC_DMA_SRC_ADDR + 2
		ldd	#MODULE_CPAGE
		std	jim_DMAC_DMA_SRC_ADDR + 0
		lda	#$FF
		sta	jim_DMAC_DMA_DEST_ADDR + 0
		lda	lcl_modbase,U
		sta	jim_DMAC_DMA_DEST_ADDR + 1
		lda	#1083/256				; size of samples and song area
		sta	jim_DMAC_DMA_COUNT + 0
		lda	#1083%256
		sta	jim_DMAC_DMA_COUNT + 1
		lda	#DMACTL_ACT+DMACTL_HALT+DMACTL_STEP_DEST_UP+DMACTL_STEP_SRC_UP
		sta	jim_DMAC_DMA_CTL
mod_load_cpy_done_2


		OSCALL	OSNEWL

		lda	#129
		OSCALL	OSWRCH
		lda	#157
		OSCALL	OSWRCH
		lda	#131
		OSCALL	OSWRCH

		lda	lcl_modbase, U
		clrb
		tfr	D,X
		leay	song_name,PCR
1		lda	B,X
		sta	B,Y
		beq	2F
		OSCALL	OSWRCH
		incb
		cmpb	#MOD_TITLE_LEN
		bne	1B

2		lda	#' '
		OSCALL	OSWRCH
		OSCALL	OSWRCH
		lda	#156
		OSCALL	OSWRCH
		OSCALL	OSNEWL

		lda	HDR_SONG_LEN_OFFS, X
		sta	g_song_len			; TODO: make relative / pass in pointer


		; find highest pattern number and setup song

		leax	HDR_SONG_DATA_OFFS,X		; move X to point at start of original song data
		ldy	#song_data
		clr	lcl_songmax,U
		ldb	#SONG_DATA_LEN-1
1		lda	B,X
		sta	B,Y
		cmpa	lcl_songmax,U
		blo	2F
		sta	lcl_songmax,U
2		decb
		bpl	1B

		PRINT "Highest Pattern # "
		lda	lcl_songmax,U
		lbsr	PrHexA

		; calculate start of samples addresses
		lda	#HDR_PATT_DATA_OFFS%256
		sta	lcl_samchipaddr+2,U		; lo address

		ldb	lcl_songmax,U
		incb					; max+1
		clra
		aslb
		rola
		aslb
		rola
		addb	#(HDR_PATT_DATA_OFFS/256)+(MODULE_CPAGE%256)
		adca	#MODULE_CPAGE/256
		std	lcl_samchipaddr+0,U

		lda	#' '
		jsr	OSWRCH
		lda	lcl_samchipaddr+0,U
		jsr	PrHexA
		lda	lcl_samchipaddr+1,U
		jsr	PrHexA
		lda	lcl_samchipaddr+2,U
		jsr	PrHexA

		jsr	OSNEWL

		; clear sample table			- TODO: can be removed?
		ldw	#256
		ldy	#sam_data+1
		ldx	#sam_data
		clr	sam_data
		tfm	Y+,X+

		lda	lcl_modbase, U
		clrb
		tfr	D,X
		leax	HDR_SONG_SAMPLES,X		; point at start of samples table
		ldy	#sam_data+8			; TODO: make relative / pass in pointer
		ldb	#1
		stb	lcl_samidx,U
mod_load_samlp	lda	lcl_samidx,U
		jsr	PrHexA

		ldd	s_modsaminfo_len,X
		asld					; *2
		cmpd	#2
		bls	mod_load_sam_nosam

		pshs	D				; length is now stacked

		; store current chip address as the sample pointer then add the length
		ldd	lcl_samchipaddr + 1,U
		std	s_saminfo_addr,Y
		addd	,S				; add len
		std	lcl_samchipaddr + 1,U
		pshs	CC				; save Cy for laster

		; get finetune to top bits of bank
		ldb	s_modsaminfo_fine,X
		aslb
		aslb
		aslb
		aslb
		orb	lcl_samchipaddr + 0,U
		stb	s_saminfo_addr_b,Y		; bank address

		puls	CC
		bcc	1F		
		inc	lcl_samchipaddr + 0,U		; increment bank if needed
1		
		ldd	s_modsaminfo_repoffs,X
		asld
		std	lcl_replen,U			; contains offset so far, we'll add len later
		std	s_saminfo_roff,Y		; store in table

		lda	s_modsaminfo_vol,X
		cmpa	#$40
		blo	1F
		lda	#$3F
1		sta	s_saminfo_repfl,Y		; store volume, may flag for repeat too...

		ldd	s_modsaminfo_replen,X
		asld
		cmpd	#3
		blo	mod_load_sam_norepeat

		oim	#$80, s_saminfo_repfl,Y		; flag repeat

		addd	lcl_replen,U
		std	lcl_replen,U			; now is offset+repeat

		; check to see if repeat length + offset is less than sample length
		; if it is make sample that length or it will sound 'orrible
		cmpd	,S
		bhs	1F
		std	,S	
1

mod_load_sam_norepeat
		puls	D				; get back length
		decd
		std	s_saminfo_len,Y

mod_load_sam_nosam
		inc	lcl_samidx,U
		lda	lcl_samidx,U
		cmpa	#32
		bhs	mod_load_exit

		leax	s_modsaminfo_sizeof,X
		leay	s_saminfo_sizeof,Y
		bra	mod_load_samlp

mod_load_exit
		leas	lcl_len,S
		rts

jimHardwarePage
		pshs	X
		ldx	#jim_page_DMAC
		stx	fred_JIM_PAGE_HI
		puls	X,PC

brksamtoolong
		DO_BRK 4, "Sample too long > 64K"


PrHexA		pshs	A
		LSRA
		LSRA
		LSRA
		LSRA
		BSR 	PrNyb
		puls	A
PrNyb		ANDA	#15
		CMPA	#10
		blo	PrDigit
		ADDA	#7
PrDigit		ADDA	#'0'
		OSJMP	OSWRCH
PrSp		lda	#' '
		OSJMP	OSWRCH
