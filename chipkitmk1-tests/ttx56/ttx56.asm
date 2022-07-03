		include "../../includes/hardware.inc"
		include "../../includes/common.inc"

		CODE
		ORG		$2000

		ORCC	#CC_I+CC_F

		LDX	#$3000
1		CLR	,X+
		CMPX	#$8000
		BNE	1B


		LDA	#1
		STA	sheila_VIDULA_ttx		; enter teletext mode

;		LDA	#$9C
		LDA	#$4B
		STA	sheila_VIDULA_ctl

		LDB	#11
		LDX	#mostbl_VDU_6845_mode_7_56
1		STB	sheila_CRTC_reg
		LDA	B,X
		STA	sheila_CRTC_rw
		DECB	
		BPL	1B

		LDA	#($3000/8)/256
		LDB	#12
		STB	sheila_CRTC_reg
		STA	sheila_CRTC_rw
		LDA	#($3000/8)%256
		LDB	#13
		STB	sheila_CRTC_reg
		STA	sheila_CRTC_rw


		LDX	#$3000+56*8
loop		CMPX	#$5000
		BHS	skip1
		LDY	#TestString
loop2		LDB	#8
		LDA	,Y+
		BEQ	loop
loop3		STA	,X+
		DECB
		BNE	loop3
		BRA	loop2
skip1

		LDA	#0
2		LDX	#$4000
		LDB	#7
1		STA	B,X
		DECB	
		BPL	1B
		INCA
3		LEAX	-1,X
		NOP
		BNE	3B
		BRA	2B

		SWI

TestString	FCB		"Teletext",1,"56",2,"chars",3,"per line   0123456789 "
		FCB		$11,"0123456789     "
		FCB		"01234567890123456789012345678901234567890123456789012345"
		FCB		"0         1         2         3         4         5     ",0

mostbl_VDU_6845_mode_012
	FCB	$7F,$50,$62,$28,$26,$00,$20,$22,$01,$07,$67,$08

mostbl_VDU_6845_mode_3
	FCB	$7F,$50,$62,$28,$1E,$02,$19,$1B,$01,$09,$67,$09


mostbl_VDU_6845_mode_3_7 ; like mode 3 but with 18 scan lines per char and interlace, also chars are 16 instead of 18 pixels high
	FCB	$7F,$50,$62,$28,$1E,$02,$19,$1B,$93,$13,$67,$09

mostbl_VDU_6845_mode_7
	FCB	$3F,$28,$33,$24,$1E,$02,$19,$1B,$93,$13,$72,$13

mostbl_VDU_6845_mode_7_56
	FCB	$3F,$38,$3E,$24,$1E,$02,$19,$1B,$93,$13,$72,$13
