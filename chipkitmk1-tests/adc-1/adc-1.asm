		include "../../includes/hardware.inc"
		include "../../includes/common.inc"
		include "../../includes/oslib.inc"
		include "../../includes/mosrom.inc"

sheila_ADC_CONN		equ	$FE54
sheila_ADC_DATA_HI	equ	$FE55
sheila_ADC_DATA_LO	equ	$FE54

		setdp 0

DP_CTR		equ		$70


		org	$2000

		clr	DP_CTR
mainlp		lda	#31
		jsr	OSASCI
		lda	#0
		jsr	OSASCI
		lda	DP_CTR
		jsr	OSASCI

		lda	DP_CTR
		ora	#$98
		sta	sheila_ADC_CONN

		lda	#0
1		inca
		bne	1B

		lda	sheila_ADC_DATA_HI
		jsr	PRHEX
		lda	sheila_ADC_DATA_LO
		jsr	PRHEX

		lda	DP_CTR
		inca
		cmpa	#4
		blo	1F
		clra
1		sta	DP_CTR
		bra	mainlp

		end