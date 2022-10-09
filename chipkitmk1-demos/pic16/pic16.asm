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

		CLR	sheila_RAMDAC_ADDR_WR

		LDX	#$2FD0
		LDB	#0
lp		TFR	B,A
		CLR	A_SAV
		ROLA
		ROL	A_SAV
		ROLA
		ROLA
		ROL	A_SAV
		ROLA
		ROLA
		ROL	A_SAV
		ROLA
		ROLA
		ROL	A_SAV
		LDA 	A_SAV
		ADDA	A_SAV
		ADDA	A_SAV
		STA	A_SAV
		LDA	A,X
		LSRA
		LSRA
		STA	sheila_RAMDAC_VAL
		INC	A_SAV
		LDA	A_SAV
		LDA	A,X
		LSRA
		LSRA
		STA	sheila_RAMDAC_VAL
		INC	A_SAV
		LDA	A_SAV
		LDA	A,X
		LSRA
		LSRA
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
osfile_load	FQB	$2FD0
		FQB	0
		FQB	0
		FQB	0
		FQB	0
