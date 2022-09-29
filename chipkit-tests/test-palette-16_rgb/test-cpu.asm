		ORG	$200

SCREEN_BASEx8   EQU     $1000 / 8
ZP_WKSP1	EQU	0
ZP_WKSP2	EQU	1


		; setup CRTC
		LDB	#$B
		LDX	#mostbl_VDU_6845_mode_012
crtcsetlp1	STB	$FE00
		LDA	B,X
		STA	$FE01
		DECB
		BPL	crtcsetlp1

		LDA	#12
		STA	$FE00
		LDA	#SCREEN_BASEx8 / $100
		STA	$FE01

		LDA	#13
		STA	$FE00
		LDA	#SCREEN_BASEx8 % $100
		STA	$FE01

		ldb	#0
		leax	pal_data_rgb,PCR
1		lda	,x+
		sta	$FE22
		lda	,x+
		sta	$FE23

		ora	#$10
		sta	$FE23

		ora	#$40
		sta	$FE23

		eora	#$10
		sta	$FE23
		incb	
		cmpb	#4
		bne	1B



		ldx	#$1000
		ldb	#0
lp2		ldy	#test_pattern
lp3		lda	,y+
		sta	,x+
		decb
		beq	sk
		bitb	#$F
		beq	lp2
		bra	lp3
sk		
		ldb	#0
1		stb	ZP_WKSP1
		lda	ZP_WKSP1
		rola
		asra
		asra
		asra
		asra
		sta	ZP_WKSP2
		lda	ZP_WKSP1
		rola
		lda	ZP_WKSP2
		rora
		asra
		asra
		asra
		sta	,x+
		incb
		bne	1B




		swi
		
		; colours are GR, LB where L is logical colours in bits 3,2
pal_data_rgb	FCB	$00,$00,$0F,$20,$FF,$80,$FF,$AF

mostbl_VDU_6845_mode_012
		FCB	$7F,$50,$62,$28,$26,$00,$20,$22
		FCB	$00,$07,$67,$08				; note: interlace off!

test_pattern	FCB	$01,$02,$04,$08,$10,$20,$40,$80
		FCB	$11,$11,$22,$22,$44,$44,$88,$88