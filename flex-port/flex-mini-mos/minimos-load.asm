		include "../../includes/common.inc"
		include "../../includes/mosrom.inc"
		include "../../includes/hardware.inc"
		include "../../includes/noice.inc"
		include "../../includes/oslib.inc"


		ORG	$0F00

		; *********************************************************************************
		; on entry $4000-$6000 should contain a minimos image
		; all interrupts will be disabled, the flex shadow memory set
		; swram bank 9 (BBRAM) will be mapped into $C000 using SWMOS register
		; swram bank 1 (BBRAM) will be mapped into $8000 using SWROM register
		; flex shadow ram will be enabled
		; the minimos will be copied to E000
		; user must press BREAK to continue booting minimos


		; TODO: warn user of impending doom if:
		;	- ROM 8 in use
		;	- already SWRAM
		;	- ROM 0 in use
		; TODO: choose ROMs more carefully? Check? API get MOSRAM slot from API/OS99?


		ORCC	#CC_I+CC_F		; disable interrupts

		LDX	#MSG
1		LDA	,X+
		BEQ	1F
		JSR	OSASCI
		BRA	1B
1


		LDB	#8
		STB	sheila_ROMCTL_SWR	; mos memory at 8000

		; map RAM bank $8 in top ROM hole and copy $4000-$7FFF there, missing out $FC00-$FEFF
		LDX	#$1000
		LDU	#$A000
		LDY	#$2000
1		LDD	,X++
		STD	,U++
		LEAY	-2,Y
		BNE	1B

		LDB	#0
		STB	sheila_ROMCTL_SWR	; swram bank #0 memory at 8000
;		LDB	#$FF
;		STB	sheila_MEM_LOMEMTURBO	; ChipRAM in 0-7FFF

		LDB	sheila_MEM_CTL
		ORB	#BITS_MEM_CTL_SWMOS
		STB	sheila_MEM_CTL

1		CWAI	#$FF				; wait for BREAK
		BRA	1B

MSG		FCB	"Press BREAK to boot minimos...",13,0

		END