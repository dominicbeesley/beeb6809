		include "../../includes/common.inc"
		include "../../includes/mosrom.inc"
		include "../../includes/hardware.inc"
		include "../../includes/noice.inc"


		; copy noIce code to main RAM
		IF	NOICE_CODE_BASE<$C000
		ERROR	"NOICE_CODE_BASE must be >=$C000"
		ENDIF 


		ORG	$2000

		; *********************************************************************************
		; MOSLOADER load image at $4000 to $C000 and run from reset entry point at $7FFE
		; the "current" nmi, swi vectors (pointing at NoICE) are copied from ROM#1 into 
		; destination memory bank
		; The currently running noice code at the hole NOICE_CODE_BASE to +NOICE_CODE_LEN
		; is copied over the rom image at $4000 before copying back into the "soft rom"

		ORCC	#CC_I+CC_F		; disable interrupts

;		LDA	#$0		
;		STA	SHEILA_ROMCTL_MOS	; ROM0 at C000

;		LDX	#NOICE_CODE_BASE
;		LDY	#NOICE_CODE_BASE-$8000	;address in image
;1		LDA	,X+
;		STA	,Y+
;		CMPX	#NOICE_CODE_BASE + NOICE_CODE_LEN
;		BLS	1B
;		

;		; SAVE ROM vectors
;		LDB	#HW_VECTOR_COUNT
;		LDX	#ROM_VECTORS_SAV
;		LDY	#REMAPPED_HW_VECTORS
;1		LDU	,Y++
;		STU	,X++
;		DECB
;		BNE	1B

		LDA	#$8		
		STA	SHEILA_ROMCTL_MOS	; put memory at C000


		; map RAM bank $8 in top ROM hole and copy $4000-$7FFF there, missing out $FC00-$FEFF
		LDX	#$4000
		LDU	#$C000
		LDY	#$3C00
1		LDD	,X++
		STD	,U++
		LEAY	-2,Y
		BNE	1B

		LDX	#$7F00
		LDU	#$FF00
		LDY	#$0100
1		LDD	,X++
		STD	,U++
		LEAY	-2,Y
		BNE	1B

;		LDD	ROM_VECTORS_SAV + OFF_SWI_VEC
;		STD	REMAPPED_HW_VECTORS + OFF_SWI_VEC
;
;		LDD	ROM_VECTORS_SAV + OFF_NMI_VEC
;		STD	REMAPPED_HW_VECTORS + OFF_NMI_VEC
;
;		LDD	ROM_VECTORS_SAV + OFF_RES_VEC
;		STD	REMAPPED_HW_VECTORS + OFF_RES_VEC

		SWI	; re-enter debugger

;ROM_VECTORS_SAV	RMB	2*HW_VECTOR_COUNT

		END