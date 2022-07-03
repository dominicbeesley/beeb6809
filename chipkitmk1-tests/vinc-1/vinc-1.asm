		include "../../includes/hardware.inc"
		include "../../includes/common.inc"
		include "../../includes/oslib.inc"
		include "../../includes/mosrom.inc"


		ORG	$2000

		; Test vinculum functions 
		; vinc is 	D0-7	USER VIA	PB0-7
		; 		RXF#			PA0
		;		TXE#			PA1
		;		RD#			PA2
		;		WR			PA3


		; set ORA to RD# = 1, WR = 1
		lda	#$0C
		sta	sheila_USRVIA_ora

		; set DDRA
		lda	#$0C
		sta	sheila_USRVIA_ddra

		lda	#$10
		jsr	vinc_write_A
		lda	#$0D
		jsr	vinc_write_A

		lda	#$13
		jsr	vinc_write_A
		lda	#$0D
		jsr	vinc_write_A

		lda	#$01
		jsr	vinc_write_A
		lda	#$0D
		jsr	vinc_write_A


1		jsr	vinc_read_A
		cmpa	#$0D
		beq	3F
		cmpa	#' '
		bhs	2F
		jsr	PRHEX
		bra	1B
2		jsr	OSWRCH
		bra	1B
3		jsr	OSNEWL
		bra	1B

vinc_wait_TXE	tim	#$02, sheila_USRVIA_ora
		bne	vinc_wait_TXE
		rts

vinc_write_A	jsr	vinc_wait_TXE
		ldb	#$FF
		stb	sheila_USRVIA_ddrb
		sta	sheila_USRVIA_orb

		ldb	#$04
		stb	sheila_USRVIA_ora
		ldb	#$0C
		stb	sheila_USRVIA_ora
		clr	sheila_USRVIA_ddrb
		rts

vinc_read_A	jsr	vinc_wait_RXF
		ldb	#$08
		stb	sheila_USRVIA_ora
		lda	sheila_USRVIA_orb
		ldb	#$0C
		stb	sheila_USRVIA_ora
		rts

vinc_wait_RXF	tim	#$01, sheila_USRVIA_ora
		bne	vinc_wait_RXF
		rts

