		include "../../includes/hardware.inc"
		include "../../includes/common.inc"
		include "../../includes/oslib.inc"
		include "../../includes/mosrom.inc"

sheila_ADC_CONN		equ	$FE54
sheila_ADC_DATA_HI	equ	$FE55
sheila_ADC_DATA_LO	equ	$FE54

		setdp 0

DP_SAMPLE_CTR		equ		$70
DP_SAMPLE_PTR		equ		$71
DP_FLAG			equ		$73
DP_OLDIRQ		equ		$74
DP_CURBUF		equ		$76
DP_PREVBUF		equ		$78
BUF_A			equ		$2E00
BUF_B			equ		$2F00

		org	$2000

		lds	#$200

		;disable interrupt sampling
		clr	DP_FLAG
		SEI
		ldx	IRQ1V
		stx	DP_OLDIRQ
		ldx	#irq_handle
		stx	IRQ1V

		lda	sheila_USRVIA_acr
		anda	#$3F
		ora	#$40
		sta	sheila_USRVIA_acr		; T1, continuous


		; set up T1 to run at 10KHz
		lda	#100 - 2
		sta	sheila_USRVIA_t1ll
		lda	#0
		sta	sheila_USRVIA_t1ch

		lda	#$C0
		sta	sheila_USRVIA_ier
		CLI


		ldx	#BUF_A
		stx	DP_CURBUF
		ldx	#BUF_B
		stx	DP_PREVBUF

main_loop	; wait for vsync
		lda	#19
		jsr	OSBYTE

		ldx	DP_CURBUF
		stx	DP_SAMPLE_PTR

		lda	#1
		sta	DP_FLAG

1		lda	DP_FLAG
		bne	1B

		ldu	DP_CURBUF
		ldy	DP_PREVBUF
		ldx	#$3000
display_loop	stx	,--S
		; clear old byte
		ldb	,Y+
		andb	#$F8
		abx
		clr	,X

		; get bit mask in a 
		ldb	,U
		andb	#7
		ldx	#bitmasks
		lda	B,X

		; which byte
		ldx	,S
		ldb	,U+
		andb	#$F8
		abx
		sta	,X

		ldd	,S++
		addd	#1		; next line
		bitb	#$08
		beq	1F
		andb	#$F0		; next char row, add 640
		addd	#640
		cmpd	#$8000
		bhs	disp_done
1		tfr	D,X
		bra	display_loop
disp_done	ldu	DP_CURBUF
		ldy	DP_PREVBUF
		sty	DP_CURBUF
		stu	DP_PREVBUF
		bra	main_loop

bitmasks	fcb	$80, $40, $20, $10, $08, $04, $02, $01


irq_handle
		tim	#$40, sheila_USRVIA_ifr
		beq	irq_skip

		lda	sheila_USRVIA_t1cl		; clear interrupt flag

		tst	DP_FLAG
		beq	irq_done

		jsr	sample_0
		aslb
		rola
		aslb
		rola
		aslb
		rola
		aslb
		rola
		ldx	DP_SAMPLE_PTR
		sta	,X+
		stx	DP_SAMPLE_PTR
		inc	DP_SAMPLE_CTR
		bne	irq_done

		clr	DP_FLAG

irq_done	rti
irq_skip	jmp	[DP_OLDIRQ]

sample_0	lda	#$B8
		sta	sheila_ADC_CONN
		nop
		nop
		lda	#$98
		sta	sheila_ADC_CONN
		nop
		nop
		nop
		lda	sheila_ADC_DATA_HI
		ldb	sheila_ADC_DATA_LO
		rts

		end