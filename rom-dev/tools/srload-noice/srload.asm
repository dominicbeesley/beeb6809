		include "../../../includes/common.inc"
		include "../../../includes/mosrom.inc"
		include "../../../includes/hardware.inc"
		include "../../../includes/noice.inc"


		ORG	$3F00

		; *********************************************************************************
		; on entry $4000-$7FFF should contain a rom image
		; 	   register B should hold SWR bank #
		; SRLOAD load image at $4000 to $C000 copy into sideways RAM at $8000 in ROM bank B

		PSHS	CC
		ORCC	#CC_I+CC_F		; disable interrupts

		LDA	SHEILA_ROMCTL_SWR
		PSHS	A			; save rom bank

;;		LDA	#$80		
		STB	SHEILA_ROMCTL_SWR	; put memory at 8000


		; map RAM bank $8 in top ROM hole and copy $4000-$7FFF there, missing out $FC00-$FEFF
		LDX	#$4000
		LDU	#$8000
		LDY	#$4000
1		LDD	,X++
		STD	,U++
		LEAY	-2,Y
		BNE	1B

** 		LDX	#$7F00
** 		LDU	#$FF00
** 		LDY	#$0100
** 1		LDD	,X++
** 		STD	,U++
** 		LEAY	-2,Y
** 		BNE	1B

		PULS	A			; put back rom bank
		STA	SHEILA_ROMCTL_SWR
		PULS	CC			; renable interrupts?

		SWI	; re-enter debugger

		END