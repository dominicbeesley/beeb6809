
; A simple test ROM for a breadboard lash-up to test LIC behaviour

		include "../../includes/hardware.inc"
		include "../../includes/common.inc"
;		include "../../includes/mosrom.inc"
;		include "../../includes/oslib.inc"

		ORG	$C000


rom_handle_res
		orcc	#CC_I+CC_F

HERE
		ldmd	#0

		ldb	#10
		clra
		ldx	#$1000
1		sta	,X+
		inca
		decb
		bne	1B

		ldmd	#1

		ldb	#10
		clra
		ldx	#$1000
1		sta	,X+
		inca
		decb
		bne	1B
		jmp	HERE


rom_handle_div0
rom_handle_swi3
rom_handle_swi2
rom_handle_irq
rom_handle_swi
rom_handle_nmi
		rti




		ORG	$FFF0

XDIV0		FDB	rom_handle_div0			; $FFF0   	; Hardware vectors, paged in to $F7Fx from $FFFx
XSWI3V		FDB	rom_handle_swi3			; $FFF2		; on 6809 we use this instead of 6502 BRK
XSWI2V		FDB	rom_handle_swi2			; $FFF4
XFIRQV		FDB	rom_handle_nmi			; $FFF6
XIRQV		FDB	rom_handle_irq			; $FFF8
XSWIV		FDB	rom_handle_swi			; $FFFA
XNMIV		FDB	rom_handle_nmi			; $FFFC
XRESETV		FDB	rom_handle_res			; $FFFE

