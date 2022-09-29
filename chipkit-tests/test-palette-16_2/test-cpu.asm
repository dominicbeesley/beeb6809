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


		ldb	#$F
		ldx	#pal_data_hi
1		lda	,x+
		sta	$FE21
		decb
		bpl	1B
		ldb	#$F
		ldx	#pal_data_lo
1		lda	,x+
		sta	$FE22
		decb
		bpl	1B

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
		

pal_data_hi
		fcb	$07, $17, $47, $57	; hi bits
		fcb	$27, $37, $67, $77
		fcb	$80, $90, $C0, $D0
		fcb	$A0, $B0, $E0, $F0
pal_data_lo
		fcb	$07, $17, $47, $57	; lo bits
		fcb	$20, $30, $60, $70
		fcb	$87, $97, $C7, $D7
		fcb	$A0, $B0, $E0, $F0

mostbl_VDU_6845_mode_012
		FCB	$7F,$50,$62,$28,$26,$00,$20,$22
		FCB	$00,$07,$67,$08				; note: interlace off!

test_pattern	FCB	$01,$02,$04,$08,$10,$20,$40,$80
		FCB	$11,$11,$22,$22,$44,$44,$88,$88