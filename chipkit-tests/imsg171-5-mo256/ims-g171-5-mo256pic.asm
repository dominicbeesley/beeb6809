		include "../../includes/hardware.inc"
		include "../../includes/common.inc"



A_SAV			EQU	$80

		CODE
		ORG		$2000

		; set up a mode 2 palette with ramdac_p[6,3,2,0] containing colour number

		LDX	#mostbl_VDU_6845_mode_012
		LDA	#13
1		LDB	A,X
		STD	sheila_CRTC_reg
		DECB
		BPL	1B

		LDA	#$FF				; all 256 colours
		STA	sheila_RAMDAC_PIXMASK
		STA	sheila_VIDULA_pixand
		CLR	sheila_VIDULA_pixeor

		LDA	#$F0
		STA	sheila_VIDULA_ctl		; force 256 colour / 10 chars per line mode (expects us to have started in mode 2)

		CLR	sheila_RAMDAC_ADDR_WR

		LDX	#$2D00
		LDB	#0
lp		LDA	,X+
		ASRA
		ASRA
		STA	sheila_RAMDAC_VAL
		LDA	,X+
		ASRA
		ASRA
		STA	sheila_RAMDAC_VAL
		LDA	,X+
		ASRA
		ASRA
		STA	sheila_RAMDAC_VAL
		INCB
		BNE	lp

		SWI


mostbl_VDU_6845_mode_012
	FCB	$7F,$50,$62,$28,$26,$00,$20,$22,$01,$07,$67,$08,$30/8,0




