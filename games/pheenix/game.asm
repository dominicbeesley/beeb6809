		include "../../includes/hardware.inc"
		include "../../includes/oslib.inc"
		include "../../includes/common.inc"
		include "../../includes/mosrom.inc"

DISABLERUPT	equ	0				; when set to 1 no vertical rupture


CRTC_SET_IMM	MACRO	; reg, val
		ldd	#(\1*256)+(\2 & 255)
		std	sheila_CRTC_reg
		ENDM

CRTC_SET_B	MACRO	; reg
		lda	#\1
		std	sheila_CRTC_reg
		ENDM

;=============================================================================
; C O N S T A N T S
;=============================================================================


; mode info
rows_main	equ	28
rows_ship	equ	5				; note the ship rows are within main
rows_status	equ	2

row_size	equ	$200				; number of bytes per screen row

scr_addr	equ	$4800-(row_size*rows_status)	; bottom of screen memory (non scrolling region)
rupt_addr	equ	$4800				; main screen (hardare offset set to this)
screen_end	equ	$8000				; end of screen memory

vtot_main	equ	rows_main
vtot_status	equ	39 - (vtot_main)		; 39 rows total, minus vertical total main and one for the vert adjust row

pix_eor_main	equ	$00				; palette offset for main
pix_eor_blank	equ	$04				; palette offset for blank
pix_eor_status	equ	$01				; palette offset in status
pix_eor_ship	equ	$05				; palette offset in ship area
pix_and_main	equ	$AA				; palette mask value

score_addr	equ	scr_addr + 1*row_size + 3*16
score_lbl_addr	equ	scr_addr + 0*row_size + 3*16

;=============================================================================
; Z E R O   P A G E 
;=============================================================================

		org	$70
zp_start
zp_ship_pix_y		RMB	1	; ship pixel offset within char cell
zp_ship_pix_x		RMB	1	; ship pixel offset x
zp_ship_addr		RMB	2	; ship screen address
zp_ship_src		RMB	2	; ship source sprite address

zp_frame_ctr		RMB	1	; inc'd on frame end (start of status bar)

zp_t2_handler		RMB	2	; pointer to the next Timer 2 handler routine to be called
zp_vrupscrly		RMB	2	; number of pixels to scroll main screen by
zp_vrupscrlysav		RMB	2	; copy of zp_vrupscrly that is saved throughout a CRT frame

zp_keys_state		RMB	1	; current keyboard state
zp_keys_not_prev	RMB	1	; keys previous, complemented

zp_test_ctr		RMB	2
zp_test_tmp		RMB	1

zp_tmp			RMB	1

zp_end

		org	$2000


;=============================================================================
MAIN
;=============================================================================
		SEI					; stop interrupts before we start messing

		; clear all zp variables
		clr	zp_start
		ldw	#zp_end-zp_start
		ldx	#zp_start
		ldy	#zp_start+1
		tfm	X+,Y+

		ldmd	#$01				; native mode, normal FIRQs

		; make a 32x32 char mode 1 (512 bytes per row)
		lda	#0
		ldx	#tblCRTC_init
1		ldb	A,X
		std	sheila_CRTC_reg
		inca	
		cmpa	#13
		bls	1B

		lda	#$D8
		sta	sheila_VIDULA_ctl		; set mode 1 control value

		lda	#pix_and_main
		sta	sheila_VIDULA_pixand
		lda	#pix_eor_main
		sta	sheila_VIDULA_pixeor

		; set scroll base register
		lda	#2*(rupt_addr / 256 / 16)
		sta	sheila_MEMC_SCROFF

		; initialise palette entries

		; as we allow through all 16 colour to the palette we need to define the palette 4 times
		; once for each of the "hidden" options
		; pixand == $CC
		; need colours at $00, $08, $80, $88 
		; plus "alternate" colours for each with $00, $02, $20, $22 added

		lde	#3
palslp0		ldb	#3
		ldx	#tbl_pal_indices
		lda	E,X
		lsra
		lsra
		sta	zp_tmp
		ldy	#tbl_pal_status
		ldu	#tbl_pal_game
pals2		lda	,X+
		ora	zp_tmp
		sta	sheila_RAMDAC_ADDR_WR
		pshs	A

		lda	,U+
		sta	sheila_RAMDAC_VAL
		lda	,U+
		sta	sheila_RAMDAC_VAL
		lda	,U+
		sta	sheila_RAMDAC_VAL

		; setup "status palettes"
		lda	,Y+
		sta	sheila_RAMDAC_VAL
		lda	,Y+
		sta	sheila_RAMDAC_VAL
		lda	,Y+
		sta	sheila_RAMDAC_VAL

		; setup "blank palette at offset 4"
		puls	A
		adda	#4
		sta	sheila_RAMDAC_ADDR_WR

		lda	#0				; note can't use CLR as that does two writes!
		sta	sheila_RAMDAC_VAL
		sta	sheila_RAMDAC_VAL
		sta	sheila_RAMDAC_VAL

		; setup ship palette
		leau	9,U
		lda	,U+
		sta	sheila_RAMDAC_VAL
		lda	,U+
		sta	sheila_RAMDAC_VAL
		lda	,U+
		sta	sheila_RAMDAC_VAL
		leau	-12,U

		decb
		bpl	pals2

		; add a special star palette entry for colour 1 of main palette
		lda	#$08
		ora	zp_tmp
		sta	sheila_RAMDAC_ADDR_WR
		ldx	#tbl_pal_stars
		leax	E,X
		leax	E,X
		leax	E,X
		lda	,X+
		sta	sheila_RAMDAC_VAL
		lda	,X+
		sta	sheila_RAMDAC_VAL
		lda	,X+
		sta	sheila_RAMDAC_VAL

		dece
		lbpl	palslp0


		jsr	setup_irqs			; start the ruptured screen

;	ldx #end_of_ZP-1 : lda #0 : .zero_ZP : sta 0,x : dex : bne zero_ZP
;	ldx #max_explosions-1 : lda #&80 : .bullet_off : sta explosions_hi,x : dex : bpl bullet_off
;
;	ldx #crtc_end-crtc_setup-1 : {.set_crtc : lda crtc_setup,X : stx CrtcReg : sta CrtcVal : dex : bpl set_crtc}

;;;	ldx #4+0 : stx SysViaRegB \\ these two set the 
;;;	ldx #5+0 : stx SysViaRegB \\ screen size to 16K

;	lda #VideoUlaMode_1NoCrsrFlash0 : sta VideoULAVideoControlRegister        \\ no crsr, M1, non-flash
;
;	lda #Pal4Col0 OR PaletteBlack : jsr set_palette_colour
;	lda #Pal4Col1 OR PaletteBlack : ldx #3 : .lp : sta star_pal,x : dex : bpl lp : sta ship_pal : jsr set_palette_colour
;	lda #Pal4Col2 OR PaletteBlack : sta PaletteCol2 : jsr set_palette_colour
;	lda #Pal4Col3 OR PaletteBlack : sta PaletteCol3 : jsr set_palette_colour
;
;	jsr read_4_keys \\ leaves DDRA ready for sound
;	jsr snd_reset
;
;    
;    LDA #64 : sta SysViaACR                 ; Set T1 free-run mode
;	lda #&FF : STA SysViaT1CL ; STA SysViaT1CH ; Write high and latch low - 3+ frames should be enough to get to a vsync to reset it before it fires
;
;	lda #0 : sta frame_done : sta frame_next : sta score : sta score+1 : sta score+2 : sta hi_score : sta hi_score+1 : sta hi_score+2
;
;
;	jsr relocate_sprites \\ black red green yellow blue purple cyan white
;
;	ldy #0
;.gen_masks
;	tya : sta local_b : lsr A : lsr A : lsr A : lsr A : ora local_b : sta local_b
;	asl A : asl A : asl A : asl A : ora local_b : eor #&FF : sta masks,y : iny : bne gen_masks
;
;	jmp start_main_game

;;.start_main_game

	jsr	cls_status
	jsr	draw_label_SCORE1HI2
;	ldy #6 { .lp : lda text,y : sta score_1_units+8,y : lda text+6,y : sta score_1_units+16,y : dey : bne lp} \\ add 0s to ends
;	tya : jsr add_score : dec attract_mode
;.start_new_game
;	ldx #&FF : TXS
;	lda #0 : sta score : sta score+1 : sta score+2 : sta total_levels : sta current_level : jsr add_score
;	lda #2*2 : sta bird_shot_level_max
;	lda #2 : sta lives_remaining : ldy #5 {.lp : lda text+18*6*2+1,y : sta ships_addr,y : sta ships_addr+16,y
;	lda text+18*6*2+6+1,y : sta ships_addr+8,y : sta ships_addr+24,y : dey : bpl lp}


		
		jsr	cls_rupt

		CLI
test

		ldx	#rupt_addr
		ldy	#spr_ship
		ldw	#end-spr_ship
		tfm	Y+,X+


		ldx	#$7A00
		stx	zp_ship_addr
		ldx	#spr_ship
		stx	zp_ship_src
		lda	#7
		sta	zp_ship_pix_y
		clr	zp_ship_pix_x

1		jsr	draw_ship
		lda	#8
		jsr	wait
		dec	zp_ship_pix_y
		bne	1b

		ldx	zp_ship_addr
		leax	-row_size,X
		stx	zp_ship_addr

		ldb	#0
		stb	zp_test_ctr
test_loop	jsr	move_ship_right
		jsr	draw_ship
1		lda	#1
		jsr	wait
		dec	zp_test_ctr
		bne	test_loop

test_end	bra	test_end

wait		lda	zp_frame_ctr
1		cmpa	zp_frame_ctr
		beq	1B
		rts

;=============================================================================
draw_label_SCORE1HI2
;=============================================================================

	ldu	#score_lbl_addr+2			; screen address to write to
	ldy	#tbl_str_score				; string to write
1	ldb	,Y+					; get char
	beq	2F					; space
	cmpb	#$20					; end of string
	beq	3F
	ldx	#font					; font data
	decb
	abx
	jsr	4F
	jsr	4F
	bra	1B
4							; draw one half char
	lde	#5
5	lda	,X+
	sta	,U+
	dece
	bpl	5B
	leau	2,U					; only drew 6 rows skip 2
3	rts

2	leau	16,U					; space, skip forwards
	bra	1B


;=============================================================================
cls_rupt
;=============================================================================
		clr	rupt_addr
		ldx	#rupt_addr
		ldw	#(row_size*rows_main)-1
		tfm	X+,X
		rts

;=============================================================================
cls_status
;=============================================================================
		clr	scr_addr
		ldx	#scr_addr
		ldw	#(row_size*rows_status)-1
		tfm	X+,X
		rts

;=============================================================================
read_4_keys
;=============================================================================
		ldb	#3				; counter
		lda	#$7F
		sta	sheila_SYSVIA_ddra		; when keyboard selected, write key val to b0-6 and read key state (1=down) from b7
		lda	zp_keys_state
		coma	
		sta	zp_keys_not_prev
		clra
		SEI
		lde	#3+0
		ste	sheila_SYSVIA_orb		; write "disable" keyboard - allows reading keys: write key value to SysViaRegA and read from b7:1=pressed
		ldx	#tbl_keys_to_scan
read_key
		lde	,X+
		ste	sheila_SYSVIA_ora		; set key to scan
		asl	sheila_SYSVIA_ora		; get result into carry
		rora	
		decb	
		bpl	read_key

		lde	#3+8
		ste	sheila_SYSVIA_orb		; turn off keyboard read 
		CLI
		lde	#$FF
		ste	sheila_SYSVIA_ddra		; put back ready for sound
		sta	zp_keys_state
		rts


;=============================================================================
draw_ship
;=============================================================================
; On entry 
;	zp_ship_addr 	points at screen location to draw ship
;	zp_ship_src	points at sprit data
;	zp_ship_pix_y		ship offset in rows within char cell (added to screen addr)
		ldb	zp_ship_pix_y
		bne	draw_ship_yoff
		ldx	zp_ship_src
		ldy	zp_ship_addr
		ldw	#$20
		tfm	X+,Y+
		leax	256-32,X
		leay	row_size-32,Y
		ldw	#$20
		tfm	X+,Y+
		rts
draw_ship_yoff	; ship is not char cell aligned, can't use TFM have to get
		; cleverer
		incb			; add one to cater for pre decrements
		lde	#8		; max number of loops
		ldx	zp_ship_src	; get source addr
		leax	E,X		; add 8
		ldy	zp_ship_addr	; get 
		leay	B,Y
		leau	row_size,Y

draw_ship_yoff_lp
		lda	,-X				; draw line by line at offset in zp_ship_pix_y
		sta	,-Y				; within a cell until zp_ship_pix_y == 0
		lda	$08,X
		sta	$08,Y
		lda	$10,X
		sta	$10,Y
		lda	$18,X
		sta	$18,Y

		lda	$100,X
		sta	,-U
		lda	$108,X
		sta	$08,U
		lda	$110,X
		sta	$10,U
		lda	$118,X
		sta	$18,U

		dece
		beq	draw_ship_yoff_done		; all done
		decb
		bne	draw_ship_yoff_lp		; more until next cell

		leay	-(row_size-8),Y			; move cell pointers up a line into
		leau	-(row_size-8),U			; the cell above
		bra	draw_ship_yoff_lp

draw_ship_yoff_done
		rts


		
;=============================================================================
move_ship_right
;=============================================================================
		ldb	zp_ship_pix_x
		ldx	#zp_ship_addr_adj
		ldb	B,X
		clra
		addd	zp_ship_addr
		std	zp_ship_addr
		lda	zp_ship_pix_x
		cmpa	#7
		bne	move_ship_right_same_cell
		cmpb	#256-(24+16)*2			; check if we're < edge (low byte)
		blo	move_ship_right_move_ok
		tim	#1,zp_ship_addr			; if LSbit of MSbyte is 1
		bne	move_ship_right_no_move
move_ship_right_move_ok
		lda	#$FF
move_ship_right_same_cell
		inca
		sta	zp_ship_pix_x
		ldx	#ship_sprite_offset
		ldb	A,X
		stb	zp_ship_src + 1			; set low byte of ship sprite offset
move_ship_right_no_move
		rts




;=============================================================================
setup_irqs
;=============================================================================


		lda	#rti_opcode
		sta	vec_nmi				; copy RTI to &D00 to stop NMIs doing anything
		lda	#$7F 
		sta	sheila_SYSVIA_ier
		sta	sheila_SYSVIA_ifr		; disable and clear all interrupts
		sta	sheila_USRVIA_ier
		sta	sheila_USRVIA_ifr		; disable and clear all interrupts
		lda	#$04
		sta	sheila_SYSVIA_pcr		; vsync \\ CA1 negative-active-edge CA2 input-positive-active-edge CB1 negative-active-edge CB2 input-nagative-active-edge
		clr	sheila_SYSVIA_acr		; none  \\ PA latch-disable PB latch-disable SRC disabled T2 timed-interrupt T1 interrupt-t1-loaded PB7 disabled
		lda	#$1F
		sta	sheila_SYSVIA_ddrb 		; enable write to addressable latch (b0-2 addr, b3 data), 4 output for timing pulse (test), 5-7 intputs
		lda	#0+8
		sta	sheila_SYSVIA_orb		; write "disable" sound
		lda	#3+8
		sta	sheila_SYSVIA_orb		; write "disable" keyboard

		ldx	#irq_handler
		stx	IRQ1V

		lda	sheila_SYSVIA_pcr
		anda	#~$0E				;  CA2 interrupt on neg
		sta	sheila_SYSVIA_pcr
		lda	#2
		sta	sheila_SYSVIA_t2cl
		clr	sheila_SYSVIA_t2ch
		lda	#$20				; Timer 2 pulse count
		sta	sheila_SYSVIA_acr
	IF DISABLERUPT == 0
		ldx	#t2tnone
		stx	zp_t2_handler
	ENDIF
		lda	#VIA_MASK_INT_IRQ + SYSVIA_MASK_INT_VSYNC + VIA_MASK_INT_T2
		sta	sheila_SYSVIA_ier		; enable Vsync and T2

		rts

;=============================================================================
irq_handler
;=============================================================================

		lda	sheila_SYSVIA_ifr
		bita	#VIA_MASK_INT_T2
		lbeq	not_t2

	IF DISABLERUPT == 0
	;-------------------------
	; T2
	;-------------------------

		jmp	[zp_t2_handler]
t2t0
		lda	#pix_eor_main
		sta	sheila_VIDULA_pixeor					; show the top in palette #0

		lda	#(rows_main - rows_ship -1)*8 - 1
		ldb	zp_vrupscrlysav + 1
		andb	#7
		bne	1F
		deca
1		sta	sheila_SYSVIA_t2cl
		clr	sheila_SYSVIA_t2ch

		CRTC_SET_IMM CRTCR6_VerticalDisplayed, rows_main
		CRTC_SET_IMM CRTCR4_VerticalTotal, vtot_main - 1
		CRTC_SET_IMM CRTCR7_VerticalSyncPosition, 255			; no vsync

		ldb	zp_vrupscrlysav + 1
		andb	#7
		CRTC_SET_B CRTCR5_VerticalTotalAdjust

		; set up start address for status bar
		CRTC_SET_IMM CRTCR12_Screen1stCharHi, (scr_addr / 8) / 256
		CRTC_SET_IMM CRTCR13_Screen1stCharLo, (scr_addr / 8) % 256

		ldx	#t2t1
		stx	zp_t2_handler
		rti

	ENDIF
t2t1
		lda	#pix_eor_ship
		sta	sheila_VIDULA_pixeor					; show the top in palette #0
	IF DISABLERUPT == 0
		lda	#rows_ship*8						; wait until end of ship area and switch to blank again
		sta	sheila_SYSVIA_t2cl
		clr	sheila_SYSVIA_t2ch
		ldx	#t2t2
		stx	zp_t2_handler
	ELSE
		lda	#$FF
		sta	sheila_SYSVIA_t2ch					; if no "rupt" then no more timer 2 so don't reset
	ENDIF									
		rti

	IF DISABLERUPT == 0
t2t2

		; at end of main turn off palette again
		lda	#pix_eor_blank
		sta	sheila_VIDULA_pixeor

		; then skip 8 lines before turning back on
		lda	#7
		suba	zp_vrupscrlysav + 1
		anda	#7
		inca
		sta	sheila_SYSVIA_t2cl
		clr	sheila_SYSVIA_t2ch

		ldx	#t2t3
		stx	zp_t2_handler
		rti

t2t3

		lda	#pix_eor_status
		sta	sheila_VIDULA_pixeor			; set "status" palette

		clr	sheila_SYSVIA_t2cl
		clr	sheila_SYSVIA_t2ch

		ldx	#t2t4
		stx	zp_t2_handler
		rti
t2t4

		; setup CRTC for status bar

		CRTC_SET_IMM CRTCR6_VerticalDisplayed, rows_status
		CRTC_SET_IMM CRTCR4_VerticalTotal, vtot_status - 1
		CRTC_SET_IMM CRTCR7_VerticalSyncPosition, vtot_status - 5			; no vsync

		ldd	zp_vrupscrly
		std	zp_vrupscrlysav
		comb
		andb	#7
		incb
		CRTC_SET_B CRTCR5_VerticalTotalAdjust
t2tnone
		; set T2 off (well big)
		lda	#$FF
		sta	sheila_SYSVIA_t2ch
		ldx	#t2t0
		stx	zp_t2_handler
		rti
	ENDIF

not_t2
		bita	#SYSVIA_MASK_INT_VSYNC
		beq	not_vsync

	;------------------------
	; vsync
	;------------------------

		inc	zp_frame_ctr

		; clear the interrupt flag
		lda	#SYSVIA_MASK_INT_VSYNC
		sta	sheila_SYSVIA_ifr

	IF DISABLERUPT == 0

		; we've hit vsync and are about to need to get ready for the "top" half of the screen (bottom in memory)
		; prepare the CRTC regs


		; setup CRTC registers for "top half" of ruptured screen

		ldd	zp_vrupscrlysav
		addd	#rupt_addr / 64
		rolb
		rola
		rolb
		rola
		rolb
		rola
		pshs	b		
		tfr	a,b

		CRTC_SET_B CRTCR12_Screen1stCharHi
		puls	b
		andb	#$C0
		CRTC_SET_B CRTCR13_Screen1stCharLo

		ldb	zp_vrupscrlysav + 1
		andb	#7
		beq	no_blanks_at_top

		; set T2 to count a few active display lines before another interrupt to set up bottom screen half
		decb
		stb	sheila_SYSVIA_t2cl
		clr	sheila_SYSVIA_t2ch

		lda	#pix_eor_blank
		sta	sheila_VIDULA_pixeor			; blank the top

		ldx	#t2t0
		stx	zp_t2_handler
		rti
no_blanks_at_top
		clr	sheila_SYSVIA_t2cl
		clr	sheila_SYSVIA_t2ch
		lda	#$00
		sta	sheila_VIDULA_pixeor			; blank the top
	ELSE
		lda	#pix_eor_main
		sta	sheila_VIDULA_pixeor			; main palette for most of screen
		lda	#(rows_main - rows_ship)*8
		sta	sheila_SYSVIA_t2cl
		clr	sheila_SYSVIA_t2ch
	ENDIF
		rti

not_vsync
		bita	#VIA_MASK_INT_IRQ
		beq	not_sysvia

		; something's flagged on sysvia
		anda	#$7F
		sta	sheila_SYSVIA_ifr		; clear it!
		rti

not_sysvia
		lda	sheila_USRVIA_ifr
		bita	#VIA_MASK_INT_IRQ
		beq	not_user_via

		anda	#$7F
		sta	sheila_USRVIA_ifr		; clear it!

not_user_via	rti

;=============================================================================
; T A B L E S
;=============================================================================


		; this sets up a "rupt" only screen						; mode 1
tblCRTC_init	FCB	127				; horz total cells - 1 			127
		FCB	64				; horz displayed cells			80
		FCB	90				; horz sync				98
		FCB	$28				; sync widths (2V, 8H)			$28
		FCB	38				; vert total cells - 1			38
		FCB	0				; vert total adjust			0
		FCB	28				; vert displayed			32
		FCB	35				; vert sync				34
		FCB	$C0				; interlace: no interlace no cursor	$01
		FCB	7				; RA max				7
		FCB	$20				; cursor start(blink slow, row 0)	$67
		FCB	8				; cursor end				8
		FCB	(rupt_addr/8)/256
		FCB	(rupt_addr/8)%256

tbl_pal_indices	FCB	$00, $08, $80, $88	; base indexes for the 4 mode 1 colours
tbl_pal_game	FCB	$00, $00, $00		; main game palette
		FCB	$3F, $00, $00
		FCB	$3F, $3F, $00
		FCB	$3F, $3F, $3F
tbl_pal_ship	FCB	$00, $00, $08		; palette for bottom "ship" area
		FCB	$3F, $00, $00
		FCB	$3F, $3F, $00
		FCB	$3F, $3F, $3F
tbl_pal_status	FCB	$00, $08, $10		; status bar palette
		FCB	$10, $10, $10
		FCB	$20, $00, $18
		FCB	$3F, $3F, $00
tbl_pal_stars	FCB	$00, $3F, $3F		; "special stars" palette - these are set up as "extras" on colour 1 of the main screen
		FCB	$00, $00, $3F
		FCB	$3F, $00, $00
		FCB	$3F, $00, $00

tbl_str_score	FCB	121,133,145,157,169	; the words "SCORE           HI-SCORE" in offsets from font data
		FCB	0,0,0,0,0,0,0,0,0,0,0
		FCB	181,193,205
		FCB	121,133,145,157,169
		FCB	$20


zp_ship_addr_adj	FCB   8,   0,   0,   0,   0,   0,   8,  0 \\ use before inc for right, after dec for left
ship_bullet_offset	FCB  16,   8,   8,   8,  16,  16,  16,  8
ship_bullet_byte	FCB $88, $44, $22, $11, $88, $44, $22, $11
ship_sprite_offset	FCB   0,  32,  64,  96, 128, 160, 192, 224

tbl_keys_to_scan	FCB	$61			; Z
			FCB	$42			; X
			FCB	$49			; RETURN
			FCB	$00			; SHIFT


		org	$2800
spr_ship	include "./sprites/ship.asm"
spr_shield_sm	include "./sprites/shield_small.asm"
spr_shield_lrg	include "./sprites/shield_large.asm"
font		include "./sprites/text.asm"
end