		include "../../includes/hardware.inc"
		include "../../includes/common.inc"
		include "../../includes/oslib.inc"



A_SAV			EQU	$80

		CODE
		ORG		$2000

		; change to mode 2
		lda	#22
		jsr	OSWRCH
		lda	#2
		jsr	OSWRCH

		; get filename

		; scan command line for module name
		lda	#OSARGS_cmdtail
		ldy	#0
		ldx	#filename_ptr_hi
		OSCALL	OSARGS
		
		ldx	filename_ptr
1		lda	,X+
		cmpa 	#' '
		beq	1B
		leax	-1,X
		stx	osfile_filename

		lda	#$FF
		ldx	#osfile_block
		jsr	OSFILE

		; turn off flash
		lda 	#193
		ldx	#0
		ldy	#0
		jsr	OSBYTE


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

		RTS


mostbl_VDU_6845_mode_012
	FCB	$7F,$50,$62,$28,$26,$00,$20,$22,$01,$07,$67,$08,$30/8,0


filename_ptr_hi	
	FDB	0
filename_ptr
	FDB	0	


osfile_block
osfile_filename	FDB	0
osfile_load	FQB	$2D00
		FQB	0
		FQB	0
		FQB	0
		FQB	0
