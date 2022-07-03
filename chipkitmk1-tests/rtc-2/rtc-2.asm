		include "../../includes/hardware.inc"
		include "../../includes/common.inc"
		include "../../includes/oslib.inc"
		include "../../includes/mosrom.inc"


		setdp 0


		org	$2000

		; test MOS OSWORD 14, 2 - convert BCD to string
		ldw	#8
		ldy	#buffer_bcd2str
		ldx	#bcd2_str_testdata
		tfm	X+,Y+
		ldx	#buffer_bcd2str
		lda	#$E
		jsr	OSWORD
		lda	#1
		ldx	#buffer_bcdread
		sta	,X
		lda	#$E
		jsr	OSWORD
		ldx	#buffer_timeread
		clr	,X
		lda	#$D			; terminate incase nothing returned
		sta	1,X
		lda	#$E
		jsr	OSWORD

		ldx	#buffer_timeread
1		lda	,X+
		jsr	OSWRCH
		cmpa	#' '
		bhs	1B
2		
		swi


bcd2_str_testdata
		fcb	$2, $17, $10, $4, $4, $17, $05, $23

buffer_bcd2str	equ	$2100
buffer_bcdread	equ	$2120
buffer_timeread equ	$2130

		end