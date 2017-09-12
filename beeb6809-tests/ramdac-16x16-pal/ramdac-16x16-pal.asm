		include "../../includes/hardware.inc"
		include "../../includes/common.inc"
		include "../../includes/oslib.inc"
		include "../../includes/mosrom.inc"


ZP_CTR		EQU	$80
ZP_CTR2		EQU	$81
ZP_OLD_IRQ1V	EQU	$83

		CODE
		ORG		$2000

		lda	#22
		jsr	OSWRCH
		lda	#2
		jsr	OSWRCH

		clr	ZP_CTR
1		ldb	#0
2		lda	#17
		jsr	OSWRCH
		tfr	B,A
		jsr	OSWRCH
		tfr	B,A
		cmpa	#$A
		blo	3F
		adda	#'A'-'0'-$A
3		adda	#'0'
		jsr	OSWRCH

		incb
		cmpb	#$10
		bne	2B
		jsr	OSNEWL
		inc	ZP_CTR
		ldb	#32
		cmpb	ZP_CTR
		bne	1B

		; stop flashing!
		clr	sysvar_FLASH_SPACE_PERIOD
		clr	sysvar_FLASH_MARK_PERIOD

		ORCC	#CC_I+CC_F			; disable CPU interrupts


		LDA	#$A0				; enable TMR2 (bit 5)
		STA	sheila_SYSVIA_ier
		LDA	sheila_SYSVIA_pcr
		ANDA	#~$0E				;  CA2 interrupt on neg
		STA	sheila_SYSVIA_pcr
		LDA	#$20				; Timer 2 pulse count
		STA	sheila_SYSVIA_acr
		lda	#16
		sta	sheila_SYSVIA_t2cl
		clr	sheila_SYSVIA_t2ch

		ldx	IRQ1V
		stx	ZP_OLD_IRQ1V
		ldx	#IRQ1_HANDLE
		stx	IRQ1V

		ANDCC	#~(CC_I+CC_F)			; disable CPU interrupts



		ldx	#500
		stx	ZP_CTR2
1		lda	#19
		jsr	OSBYTE
		ORCC	#CC_I+CC_F			; disable CPU interrupts
		clr	ZP_CTR
		lda	#14
		sta	sheila_SYSVIA_t2cl
		clr	sheila_SYSVIA_t2ch
		ANDCC	#~(CC_I+CC_F)			; disable CPU interrupts
		ldx	ZP_CTR2
		leax	-1,X
		stx	ZP_CTR2
		bne	1B

		ORCC	#CC_I+CC_F			; disable CPU interrupts
		ldx	ZP_OLD_IRQ1V
		stx	IRQ1V

		; disable timer 2 interrupt
		lda	#$20
		sta	sheila_SYSVIA_ier

		ANDCC	#~(CC_I+CC_F)

		SWI


IRQ1_HANDLE	lda	sheila_SYSVIA_ifr
		bita	#$20
		beq	sk_not_tmr2

		inc	ZP_CTR
		ldb	ZP_CTR
		andb	#$0F
		ldx	#eorvals
		ldb	B,X
		stb	sheila_VIDULA_pixeor

		lda	#15
		sta	sheila_SYSVIA_t2cl
		clr	sheila_SYSVIA_t2ch

sk_not_tmr2	jmp	[ZP_OLD_IRQ1V]

eorvals		FCB	$00, $01, $04, $05, $10, $11, $14, $15
		FCB	$40, $41, $44, $45, $50, $51, $54, $55

