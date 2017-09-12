		include "../../includes/hardware.inc"
		include "../../includes/common.inc"

SHEILA_RAMDAC		EQU	$FE28
SHEILA_RAMDAC_WR_ADD	EQU	SHEILA_RAMDAC
SHEILA_RAMDAC_RD_ADD	EQU	SHEILA_RAMDAC + 3
SHEILA_RAMDAC_VAL	EQU	SHEILA_RAMDAC + 1
SHEILA_RAMDAC_MASK	EQU	SHEILA_RAMDAC + 2


A_SAV			EQU	$80

		CODE
		ORG		$2000

		; set up a mode 2 palette with ramdac_p[6,3,2,0] containing colour number

		LDA	#$0F
		STA	SHEILA_RAMDAC_MASK

		CLR	SHEILA_RAMDAC_WR_ADD

		LDB	#0
lp		TFR	B,A
		STA	A_SAV

		ANDA	#$1
		BEQ	sk_R
		LDA	#$3F
sk_R		STA	SHEILA_RAMDAC_VAL

		LDA	A_SAV
		ANDA	#$2
		BEQ	sk_G
		LDA	#$3F
sk_G		STA	SHEILA_RAMDAC_VAL

		LDA	A_SAV
		ANDA	#$4
		BEQ	sk_B
		LDA	#$3F
sk_B		STA	SHEILA_RAMDAC_VAL

colsk
		INCB
		BNE	lp

		SWI





