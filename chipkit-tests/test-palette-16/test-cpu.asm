		ORG	$200

SCREEN_BASEx8   EQU     $280 / 8
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
		ldx	#data
lp		lda	,x+
		sta	$FE21
		decb
		bpl	lp

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
		asra
		asra
		asra
		asra
		sta	ZP_WKSP2
		lda	ZP_WKSP1
		rola
		rola
		lda	ZP_WKSP2
		rora
		asra
		asra
		asra
		sta	,x+
		decb
		bne	1B




		swi
		

data		fcb	$07, $17, $47, $57
		fcb	$26, $36, $66, $76
		fcb	$84, $94, $C4, $D4
		fcb	$A0, $B0, $E0, $F0

mostbl_VDU_6845_mode_012
		FCB	$7F,$50,$62,$28,$26,$00,$20,$22
		FCB	$00,$07,$67,$08				; note: interlace off!

test_pattern	FCB	$01,$02,$04,$08,$10,$20,$40,$80
		FCB	$11,$11,$22,$22,$44,$44,$88,$88