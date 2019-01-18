

		include "../../includes/common.inc"
		include "../../includes/hardware.inc"
		include "../../includes/oslib.inc"
		include "gen-vars.inc"

		setdp	0

		org	$70				; zero page - basic compat
zp_dm_ct_x	equ	$70
zp_dm_ct_y	equ	$71
zp_spr_save_pt	equ	$72				; points at entry in save area
zp_spr_save_ram	equ	$74				; points at chip ram containing the save (only ls 2 bytes!)

TILE_BASE	equ	$2000

CHARAC_SPR	equ	$001000
CHARAC_SPR_MO	equ	(8*24)				; mask offset from start of spr
CHARAC_SPR_SZ	equ	(2*24)+(8*24)			; size of spr

BACK_SPR	equ	$010000
FRONT_SPR	equ	$020000
FRONT_SPR_MO	equ	(8*16)				; mask offset from start of spr
FRONT_SPR_SZ	equ	(2*16)+(8*16)			; size of spr

SPR_SAVE	equ	$030000				; save area for sprites

SCR_SHADOW	equ	$040000				; draw to this screen then blit to SYS

	; sprite save area block offsets
o_spr_save_sava	equ	0
o_spr_save_scra	equ	3
o_spr_save_w	equ	5
o_spr_save_h	equ	6
o_spr_save_l	equ	7


		org	$0E00


		; mode 2
		lda	#22
		jsr	OSWRCH
		lda	#2
		jsr	OSWRCH

		ldx	#str_lod_pal
		jsr	printX
		ldx	#str_fn_pal
		ldy	#TILE_BASE
		jsr	loadFileXatY

		;reset palette
		lda	#$40
		sta	SHEILA_NULA_CTLAUX

		;setup palette
		ldb	#32
		ldx	#TILE_BASE
1		lda	,X+
		sta	SHEILA_NULA_PALAUX
		decb
		bne	1B

		; load character sprites

		ldx	#str_lod_charac
		jsr	printX
		ldx	#str_fn_charac
		ldy	#TILE_BASE
		jsr	loadFileXatY

		; copy chact tiles up to chip ram
		lda	#$FF
		ldx	#TILE_BASE
		ldb	#CHARAC_SPR / $10000
		ldy	#CHARAC_SPR
		ldu	#CHARAC_SPR_LEN-1
		jsr	dmac_copy

		; load background tiles

		ldx	#str_lod_back
		jsr	printX
		ldx	#str_fn_back
		ldy	#TILE_BASE
		jsr	loadFileXatY

		; copy chact tiles up to chip ram
		lda	#$FF
		ldx	#TILE_BASE
		ldb	#BACK_SPR / $10000
		ldy	#BACK_SPR
		ldu	#BACK_SPR_LEN-1
		jsr	dmac_copy

		; load foreground tiles

		ldx	#str_lod_front
		jsr	printX
		ldx	#str_fn_front
		ldy	#TILE_BASE
		jsr	loadFileXatY

		; copy chact tiles up to chip ram
		lda	#$FF
		ldx	#TILE_BASE
		ldb	#FRONT_SPR / $10000
		ldy	#FRONT_SPR
		ldu	#FRONT_SPR_LEN-1
		jsr	dmac_copy


		; load map file
		ldx	#str_lod_map
		jsr	printX
		ldx	#str_fn_map
		ldy	#TILE_BASE
		jsr	loadFileXatY

		jsr	draw_map


		clr	zp_spr_save_pt			; clear hi byte of restore ptr		

X_START		equ	0
X_MAX		equ	160-16
Y_START		equ	-28
Y_MAX		equ	259

		lda	#0
lpy
		ldy	#Y_START
lpx
		ldx	#X_START
lp2
		clr	SHEILA_DEBUG
		jsr	wait_vysnc

		pshs	D,X,Y,U
		lda	#SCR_SHADOW/$10000
		ldx	#SCR_SHADOW%$10000
		ldb	#$FF
		ldy	#$3000
		ldu	#$5000
		jsr	dmac_copy
		puls	D,X,Y,U


		ldb	#$FF
		stb	SHEILA_DEBUG

		tst	zp_spr_save_pt
		beq	1F
		jsr	spr_restore

1
		pshs	D
		ldd	#spr_save_list
		std	zp_spr_save_pt			; set up save area
		ldd	#SPR_SAVE
		std	zp_spr_save_ram
		puls	D

		pshs	A
		lsra					; animate figure
		lsra
		adda	#4
		jsr	charac_spr_plot
		puls	A
		jsr	draw_front
		inca
		anda	#$F
		leax	1,X
		cmpx	#X_MAX
		blt	1F
		ldx	#X_START
1		leay	1,Y
		cmpy	#Y_MAX
		blt	1F
		ldy	#Y_START
1		bra	lp2


		rts


draw_map	
		pshs	D,X,Y,U
		ldu	#TILE_BASE			; pointer to top,left tile
		lda	#$10				; number of map rows
		sta	zp_dm_ct_y
		ldy	#0
y_lp		ldb	#$A
		stb	zp_dm_ct_x
		ldx	#0
x_lp		lda	,u+
		deca
		jsr	draw_map_tile_no_mask
		leax	16,X
		dec	zp_dm_ct_x
		bne	x_lp
		leau	32-10,U
		leay	16,Y
		dec	zp_dm_ct_y
		bne	y_lp
		puls	D,X,Y,U,PC

draw_front	
		pshs	D,X,Y,U
		; set up zero shift
		lda	#0
		sta	sheila_DMAC_SHIFT
		lda	#$FF
		sta	sheila_DMAC_MASK_FIRST
		sta	sheila_DMAC_MASK_LAST


1		lda	#15
		sta	sheila_DMAC_HEIGHT

		clra
		ldb	#2
		std	sheila_DMAC_STRIDE_A		
		ldb	#8
		std	sheila_DMAC_STRIDE_B		
		ldd	#640
		std	sheila_DMAC_STRIDE_C
		std	sheila_DMAC_STRIDE_D

		; width height

		lda	#8-1
		sta	sheila_DMAC_WIDTH


		ldu	#TILE_BASE+32*32		; pointer to top,left tile
		lda	#$10				; number of map rows
		sta	zp_dm_ct_y
		ldy	#0
df_y_lp		ldb	#$A
		stb	zp_dm_ct_x
		ldx	#0
		jsr	XY_to_ADDR
		tfr	D,X
df_x_lp		lda	,u+
		beq	1F
		deca
		jsr	front_a_addr
		jsr	spr_plotAtX16
1		leax	64,X				; increment screen address
		dec	zp_dm_ct_x
		bne	df_x_lp
		leau	32-10,U
		leay	16,Y
		dec	zp_dm_ct_y
		bne	df_y_lp
		puls	D,X,Y,U,PC



draw_map_tile_no_mask
		pshs	D,X,Y,U
		; gross bounds checking - more to do later for partial
		; reveal at edges
		cmpx	#-16
		lble	draw_map_tile_no_mask_exit
		cmpx	#160
		lbge	draw_map_tile_no_mask_exit
		cmpy	#-24
		lble	draw_map_tile_no_mask_exit
		cmpy	#256
		lbge	draw_map_tile_no_mask_exit

		; calculate sprite source / mask addresses
		clrb					
		lsra
		rorb					; tiles are 8*16 bytes long
		addd	#BACK_SPR
		std	sheila_DMAC_ADDR_B + 1

		; assume we don't cross a bank boundary!
		lda	#BACK_SPR / $10000
		sta	sheila_DMAC_ADDR_B

		clra
		ldb	#8
		std	sheila_DMAC_STRIDE_B		
		ldd	#640
		std	sheila_DMAC_STRIDE_D

		; width height

		lda	#8-1
		sta	sheila_DMAC_WIDTH
		lda	#16-1
		sta	sheila_DMAC_HEIGHT

		jsr	XY_to_ADDR
		std	sheila_DMAC_ADDR_D + 1

		bcs	1F
		; set up zero shift
		lda	#0
		sta	sheila_DMAC_SHIFT
		lda	#$FF
		sta	sheila_DMAC_MASK_FIRST
		lda	#$F0
		sta	sheila_DMAC_MASK_LAST
		bra	2F
		; set up 1px shift
1		inc	sheila_DMAC_WIDTH
		lda	#$11				; shift A,B
		sta	sheila_DMAC_SHIFT
		lda	#$7F
		sta	sheila_DMAC_MASK_FIRST
		lda	#$F0
		sta	sheila_DMAC_MASK_LAST
2

		lda	#SCR_SHADOW/$10000
		sta	sheila_DMAC_ADDR_D

		lda	#$CC				; B
		sta	sheila_DMAC_FUNCGEN

		lda	#$0A				; exec B,D
		sta	sheila_DMAC_BLITCON
		lda	#$E0				; act, cell, 4bpp
		sta	sheila_DMAC_BLITCON


draw_map_tile_no_mask_exit
		puls	D,X,Y,U,PC


		; copy non-overlapping region from
		; A:X to B:Y that is U+1 bytes long
dmac_copy	
		pshs	CC
		SEI
		clr	sheila_DMAC_DMA_SEL		; always use cha 0
		stu	sheila_DMAC_DMA_COUNT
		sta	sheila_DMAC_DMA_SRC_ADDR
		stx	sheila_DMAC_DMA_SRC_ADDR + 1
		stb	sheila_DMAC_DMA_DEST_ADDR
		sty	sheila_DMAC_DMA_DEST_ADDR + 1
		lda	#$85				; up/up act
		sta	sheila_DMAC_DMA_CTL
		puls	CC,PC

spr_restore	; restore saved background
		pshs	D,X

		lda	#$FF
		sta	sheila_DMAC_MASK_FIRST
		sta	sheila_DMAC_MASK_LAST
		lda	#$CC				; copy B
		sta	sheila_DMAC_FUNCGEN
		ldd	#640
		std	sheila_DMAC_STRIDE_D


		ldx	zp_spr_save_pt
spr_restore_lp
		cmpx	#spr_save_list
		bls	spr_restore_dn
		leax	-o_spr_save_l,X
		lda	o_spr_save_sava,X
		sta	sheila_DMAC_ADDR_B
		ldd	o_spr_save_sava + 1,X
		std	sheila_DMAC_ADDR_B + 1
		lda	#SCR_SHADOW/$10000
		sta	sheila_DMAC_ADDR_D
		ldd	o_spr_save_scra,X
		std	sheila_DMAC_ADDR_D + 1
		ldb	o_spr_save_w,X
		stb	sheila_DMAC_WIDTH

		incb
		clra
		std	sheila_DMAC_STRIDE_B


		lda	o_spr_save_h,X
		sta	sheila_DMAC_HEIGHT
		lda	#$0A				; exec B,D
		sta	sheila_DMAC_BLITCON
		lda	#$E0				; act, cell, 4bpp
		sta	sheila_DMAC_BLITCON
		bra	spr_restore_lp
spr_restore_dn
		puls	D,X,PC


charac_spr_plot	; plot character A at X,Y
		pshs	D
		jsr	charac_a_to_u
		lda	#24-1
		jsr	spr_plot
		puls	D,PC

charac_a_to_u	; calculate address of character sprite #A in addresses A/B
		pshs	D

		; calculate sprite source / mask addresses
		ldb	#CHARAC_SPR_SZ			; sprite+mask in bytes
		mul
		addd	#CHARAC_SPR
		std	sheila_DMAC_ADDR_B + 1
		addd	#CHARAC_SPR_MO			; mask offset
		std	sheila_DMAC_ADDR_A + 1

		; assume we don't cross a bank boundary!
		ldb	#CHARAC_SPR / $10000
		stb	sheila_DMAC_ADDR_B
		stb	sheila_DMAC_ADDR_A

		puls	D,PC

front_spr_plot	; plot character A at X,Y
		pshs	D
		jsr	front_a_addr
		lda	#16-1
		jsr	spr_plot
		puls	D,PC

front_a_addr	; calculate address of character sprite #A in addresses A/B
		pshs	D

		; calculate sprite source / mask addresses
		ldb	#FRONT_SPR_SZ			; sprite+mask in bytes
		mul
		addd	#FRONT_SPR
		std	sheila_DMAC_ADDR_B + 1
		addd	#FRONT_SPR_MO			; mask offset
		std	sheila_DMAC_ADDR_A + 1

		; assume we don't cross a bank boundary!
		ldb	#FRONT_SPR / $10000
		stb	sheila_DMAC_ADDR_B
		stb	sheila_DMAC_ADDR_A

		puls	D,PC


		; plot a 16xA+1 "sprite" from (cha A/B aldready setup by
		; xxx_a_to_u) at X,Y
		; with bounds checking
spr_plot	pshs	D,X,Y,U


		; gross bounds checking - more to do later for partial
		; reveal at edges
		cmpx	#-16
		lble	spr_plot_exit
		cmpx	#160
		lbge	spr_plot_exit		
		cmpy	#-24				; TODO - use the passed in height
		lble	spr_plot_exit
		cmpy	#256
		lbge	spr_plot_exit		

1		cmpy	#0
		bge	1F
		leay	1,Y				; off top of screen, move until we're on screen...
		ldu	sheila_DMAC_ADDR_B+1
		leau	8,U				; skip a line of the sprite
		stu	sheila_DMAC_ADDR_B+1
		ldu	sheila_DMAC_ADDR_A+1
		leau	2,U				; skip a line of the sprite
		stu	sheila_DMAC_ADDR_A+1
		deca					; reduce the height
		bpl	1B
		lbra	spr_plot_exit			; <0 height abort

1		sta	sheila_DMAC_HEIGHT

		; check if Y+height > 256
		tfr	Y,D
		addb	sheila_DMAC_HEIGHT
		adda	#0
		beq	1F				; if Y+height-1 >=256 then subtract that from height
		subb	sheila_DMAC_HEIGHT
		negb
		stb	sheila_DMAC_HEIGHT

1		
		clra
		ldb	#2
		std	sheila_DMAC_STRIDE_A		
		ldb	#8
		std	sheila_DMAC_STRIDE_B		
		ldd	#640
		std	sheila_DMAC_STRIDE_C
		std	sheila_DMAC_STRIDE_D

		; width height

		lda	#8-1
		sta	sheila_DMAC_WIDTH


		jsr	XY_to_ADDR
		pshs	D

		bcs	1F
		; set up zero shift
		lda	#0
		sta	sheila_DMAC_SHIFT
		lda	#$FF
		sta	sheila_DMAC_MASK_FIRST
		sta	sheila_DMAC_MASK_LAST
		bra	2F
		; set up 1px shift
1		inc	sheila_DMAC_WIDTH
		lda	#$11				; shift A,B
		sta	sheila_DMAC_SHIFT
		lda	#$7F
		sta	sheila_DMAC_MASK_FIRST
		lda	#$FF
		sta	sheila_DMAC_MASK_LAST		

2		puls	X
		bra	spr_save_then_plot

		; plot a 16x16 "sprite" from (cha A/B aldready setup by
		; xxx_a_to_u) at screen addr X, shift/masks must already be set
		; with no bounds checking
spr_plotAtX16	pshs	D,X,Y,U


spr_save_then_plot
		; before doing the plot, save to the save area
		lda	#SCR_SHADOW/$10000
		sta	sheila_DMAC_ADDR_C
		sta	sheila_DMAC_ADDR_D
		
		stx	sheila_DMAC_ADDR_C + 1
		stx	sheila_DMAC_ADDR_D + 1

		ldu	zp_spr_save_pt
		stx	o_spr_save_scra,U
		lda	sheila_DMAC_WIDTH
		sta	o_spr_save_w,U
		lda	sheila_DMAC_HEIGHT
		sta	o_spr_save_h,U

		lda	#SPR_SAVE/$10000
		sta	sheila_DMAC_ADDR_E
		sta	o_spr_save_sava,U
		ldd	zp_spr_save_ram
		std	sheila_DMAC_ADDR_E + 1
		std	o_spr_save_sava + 1,U
		pshs	D
		ldb	sheila_DMAC_HEIGHT
		incb
		lda	sheila_DMAC_WIDTH
		inca
		mul
		addd	,S++				; add 8*HEIGHT
		std	zp_spr_save_ram

		leau	o_spr_save_l,U
		stu	zp_spr_save_pt
		cmpu	#spr_save_list_end
		bhs	brkSaveFull

		lda	#$CA				; A&B | /A&C
		sta	sheila_DMAC_FUNCGEN

		lda	#$1F				; exec A,B,C,D,E
		sta	sheila_DMAC_BLITCON
		lda	#$E0				; act, cell, 4bpp
		sta	sheila_DMAC_BLITCON


spr_plot_exit	puls	D,X,Y,U,PC


		; before doing the plot, save to the save area

brkSaveFull	BRK
		fcb	255, "Save area full", 0


wait_vysnc	pshs	D,X,Y
		lda	#19
		jsr	OSBYTE
		puls	D,X,Y,PC



XY_to_ADDR	; calculate screen address (in D) Cy set if X was odd
		tfr	Y,D
		pshs	D
		andb	#7
		pshs	B				; save row #
		ldb	2,S				; get back Y low byte - if out of bounds treat as -ve (shouldn't happen)		
		andb	#$F8				; calc 8*(Y DIV 8)
		lda	#80
		mul
		tst	1,S
		bpl	1F
		adda	#$B0				; add -80 if Y is -ve
1		addb	,S+				; add row number popped from stack
		adca	#0				; add mod 8 rows

		std	,S				; store current addr

		tfr	X,D
		lsrb
		pshs	CC				; store low bit of X
		aslb

		aslb
		rola
		aslb
		rola					; * 8 i.e. 8*#of bytes

		addd	1,S				; add address from above

;		addd	#$3000

		puls	CC				; get back X==odd as C
		leas	2,S				; restore stack
		rts


printX		lda	,X+
		beq	1F
		jsr	OSASCI
		bra	printX
1		rts


loadFileXatY
		stx	OSFILE_filename
		sty	OSFILE_load + 2
		clra	
		sta	OSFILE_exec + 3
		deca
		sta	OSFILE_load
		sta	OSFILE_load + 1
		lda	#$FF
		ldx	#OSFILE_block
		jmp	OSFILE

		; general scratch space - overlapping

spr_save_list	


str_lod_charac	fcb	"loading "
str_fn_charac	fcb	"T.CHARAC", $D, 0
str_lod_pal	fcb	"loading "
str_fn_pal	fcb	"P.MAIN", $D, 0
str_lod_back	fcb	"loading "
str_fn_back	fcb	"T.OBACK", $D, 0
str_lod_front	fcb	"loading "
str_fn_front	fcb	"T.OFRONT", $D, 0
str_lod_map	fcb	"loading "
str_fn_map	fcb	"M.HOME", $D, 0

OSFILE_block	
OSFILE_filename	equ	OSFILE_block + 0
OSFILE_load	equ	OSFILE_block + 2
OSFILE_exec	equ	OSFILE_block + 6
OSFILE_start	equ	OSFILE_block + 10
OSFILE_end	equ	OSFILE_block + 14


		org	spr_save_list + o_spr_save_l*64			; room to save 32 sprites
spr_save_list_end

end_addr
	IF end_addr>TILE_BASE
		error	"program too big"
	ENDIF
			