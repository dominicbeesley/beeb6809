
		include "../../includes/oslib.inc"

SCREEN		EQU	$5800
CHARCTR		EQU	$70
LINECTR		EQU	$71
BYTESPERLINE	EQU	40*8

		; load font binary at SCREEN then unpack as single spaced double height chars - assume mode 1

		org	$2000
		lda	#22
		jsr	OSWRCH
		lda	#4
		jsr	OSWRCH

		clr	CHARCTR
		ldu	#SCREEN			; pointer to store unpack chars
		ldx	#FONT			; pointer to char data

linelp
		lda	#20
		sta	LINECTR
charlp		ldb	#16			; rows per char
1		lda	,X+
		sta	,U+
		decb
		cmpb	#8
		bne	1B
		leau	BYTESPERLINE-8,U
1		lda	,X+
		sta	,U+
		decb
		bne	1B
		leau	-(BYTESPERLINE-8),U
		dec	LINECTR
		bne	1F
		leau	BYTESPERLINE,U
		lda	#20
		sta	LINECTR
1		dec	CHARCTR
		bne	charlp
		swi

FONT
		includebin "fastware_fon_8x16.bin"

		end
