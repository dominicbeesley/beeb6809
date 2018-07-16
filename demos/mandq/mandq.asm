		include "../../includes/hardware.inc"
		include "../../includes/common.inc"
		include "../../includes/oslib.inc"
		include "../../includes/mosrom.inc"


N_MAX		equ	64
FIX_BITS	equ	5
SZ_X		equ	160
SZ_Y		equ	256

		setdp 0

		org	$70
DP_pal_ix
DP_pixel_X	rmb	1
DD_pal_acc
DP_pixel_Y	rmb	1
DP_pal_off
DP_pixel_row	rmb	1		; 0..7 in cell counter
DP_ADDR_PX	rmb	2
DP_pixel_acc	rmb	1
DP_FP_U		rmb	2
DP_FP_V		rmb	2
DP_FP_X		rmb	2
DP_FP_Y		rmb	2
DP_FP_R		rmb	2
DP_FP_Q		rmb	2
DP_ITER_CT	rmb	1
DP_FP_ACC	rmb	2

CONST_FP	MACRO
		fdb     (\1*(1<<(15-FIX_BITS)))
		ENDM

SHIFTLOOP2	MACRO
		rolw
		rold
__LPCT		SET	__LPCT-1
	IF __LPCT>=0
		SHIFTLOOP2
	ENDIF
		ENDM


MULFP		MACRO
		muld	\1
__LPCT		SET	FIX_BITS
		SHIFTLOOP2
		ENDM


		org	$2000

;================================================================
START
;================================================================

		; native mode
		LDMD	#$01

		; MODE 2
		lda	#22
		jsr	OSWRCH
		lda	#2
		jsr	OSWRCH

		clr	DP_pal_off

;		clr	DP_pal_ix
;1		lda	#17
;		jsr	OSWRCH
;		lda	DP_pal_ix
;		jsr	OSWRCH
;		jsr	PRHEX
;		lda	DP_pal_ix
;		inca	
;		sta	DP_pal_ix
;		cmpa	#16
;		blo	1B

		jsr	PAL

		ldx	#0
		ldy	#0
		lda	#9
		jsr	OSBYTE			; disable FLASH


		clr	DP_pixel_Y
		clr	DP_pixel_row
		ldd	const_start_V
		std	DP_FP_V
		ldx	#$3000			; pixel pointer
		leay	,X			; row start
;================================================================
ROW_LOOP
;================================================================

		clr	DP_pixel_X
		ldd	const_start_U
		std	DP_FP_U

;================================================================
COL_LOOP
;================================================================
		ldd	DP_FP_U			; X = U
		std	DP_FP_X
		ldd	DP_FP_V			; Y = V
		std	DP_FP_Y
		clr	DP_ITER_CT		; N% = 0

;================================================================
ITER_LOOP
;================================================================
		ldd	DP_FP_X
		MULFP	DP_FP_X
		std	DP_FP_R			; R = X*X
		ldd	DP_FP_Y
		MULFP	DP_FP_Y
		std	DP_FP_Q			; R = Y*Y
		addd	DP_FP_R
		cmpd	#4*(1<<(15-FIX_BITS))			; IF Q+R>4
		bhs	ITER_DONE

		ldd	const_2_0
		MULFP	DP_FP_X
		MULFP	DP_FP_Y
		addd	DP_FP_V
		std	DP_FP_Y			; Y = 2*X*Y+V

		ldd	DP_FP_R
		subd	DP_FP_Q
		addd	DP_FP_U
		std	DP_FP_X

		lda	DP_ITER_CT
		inca
		sta	DP_ITER_CT
		cmpa	#N_MAX
		lblo	ITER_LOOP		; IF N%<N_MAX
		clra
		bra	1F

ITER_DONE
		clra
		ldb	DP_ITER_CT
		divd	#15
		inca
		; shift pixel bits into b from N%		B			A		C
1		ldb	DP_pixel_acc			;	hgfedcba		7654321
		rorb					;	-hgfedcb		7654321		a
		rora					;	-hgfedcb		a765432		1
		rorb					;	1-hgfedc		a765432		b
		rorb					;	b1-hgfed		a765432		c
		rora					;	b1-hgfed		ca76543		2
		rorb					;	2b1-hgfe		ca76543		d
		rorb					;	d2b1-hgf		ca76543		e
		rora					;	d2b1-hgf		eca7654		3
		rorb					;	3d2b1-hg		eca7654		f
		rorb					;	f3d2b1-h		eca7654		g
		rora					;	f3d2b1-h		geca765		4
		rorb					;	4f3d2b1-		geca765		h

		tim	#1, DP_pixel_X
		beq	1F
		rorb					;	h4f3d2b1		geca765		-
		stb	,X
		leax	8,X
		bra	2F
1		stb	DP_pixel_acc
2		lda	DP_pixel_X
		inca
		cmpa	const_sz_px_X
		bhs	ROW_DONE
		sta	DP_pixel_X

		ldd	const_step_U		; V=V+STEP_V
		addd	DP_FP_U
		std	DP_FP_U
		jmp	COL_LOOP

ROW_DONE
		lda	DP_pixel_row
		inca	
		cmpa	#8
		bhs	ROW_NEXT_CELL
		leay	1,Y
		bra	2F
ROW_NEXT_CELL	clra
		leay	(640-7),Y
2		leax	,Y
		sta	DP_pixel_row
		lda	DP_pixel_Y
		inca
		cmpa	const_sz_px_Y
		beq	ALL_DONE
		sta	DP_pixel_Y

		ldd	const_step_V		; V=V+STEP_V
		addd	DP_FP_V
		std	DP_FP_V
		lbra	ROW_LOOP


	IF MACH_BEEB
PAL
ALL_DONE
		rts
	ENDIF
	IF MACH_CHIPKIT
ALL_DONE

		lda	#19
		jsr	OSBYTE
		lda	#19
		jsr	OSBYTE
		lda	#19
		jsr	OSBYTE
		jsr	PAL
		bra	ALL_DONE

		swi

PAL
		; palette
		clr	DP_pal_ix
		ldx	#mostbl_16_colours
PAL_LOOP
		clra
		ldb	DP_pal_off
		addb	DP_pal_ix
		divd	#15
		inca				; IX = 1+IX%15
		lda	A,X
		sta	sheila_RAMDAC_ADDR_WR

		lda	DP_pal_ix
		asla
		asla
		sta	sheila_RAMDAC_VAL		; R
		clra
		sta	sheila_RAMDAC_VAL		; R
		lda	DP_pal_ix
		cmpa	#7
		bls	1F
		nega
		adda	#7
		anda	#7
1
		asla
		asla
		sta	sheila_RAMDAC_VAL		; B
		lda	DP_pal_ix
		inca
		sta	DP_pal_ix
		cmpa	#16
		blo	PAL_LOOP

		dec	DP_pal_off
		rts
	ENDIF
mostbl_16_colours
	FCB	$00,$02,$08,$0A,$20,$22,$28,$2A ;	C42A
	FCB	$80,$82,$88,$8A,$A0,$A2,$A8,$AA ;	C432

const_sz_px_X	fcb	SZ_X
const_sz_px_Y	fcb	SZ_Y
const_start_V	CONST_FP	-1.25
const_step_V	CONST_FP	2.5/SZ_Y
const_start_U	CONST_FP	-2.0
const_step_U	CONST_FP	2.5/SZ_X
const_2_0	CONST_FP	2.0

		end