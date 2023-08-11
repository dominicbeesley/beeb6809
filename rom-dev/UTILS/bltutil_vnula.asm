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

;==============================================================================
cmdVNRESET
;==============================================================================
		lda	#$40
		sta	sheila_NULA_CTLAUX
		rts


;==============================================================================
cmdVNVDU	* Enable\disable extended VDU drivers
;==============================================================================

		; TODO - use GSREAD!
		jsr	SkipSpacesX
		cmpa	#$D
		lbeq	brkInvalidArgument
		lda	,X+
		anda	#$DF
		cmpa	#'O'
		lbne	brkInvalidArgument
		lda	,X+
		anda	#$DF
		cmpa	#'N'
		beq	vnula_vduon
		cmpa	#'F'
		lbne	brkInvalidArgument
		lda	,X+
		anda	#$DF
		cmpa	#'F'
		lbne	brkInvalidArgument


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
		sta	sheila_NULA_CTLAUX
		lda	#$70
		sta	sheila_NULA_CTLAUX
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
		sta	sheila_NULA_CTLAUX
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
		sta	sheila_NULA_PALAUX
		stb	sheila_NULA_PALAUX
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
		sta	sheila_NULA_CTLAUX		; set vdu19_physical mapping
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
		sta	sheila_NULA_CTLAUX
		lda	#$70
		sta	sheila_NULA_CTLAUX
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
		sta	sheila_NULA_CTLAUX
		lda	#$70
		sta	sheila_NULA_CTLAUX
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
		sta	sheila_NULA_CTLAUX
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

