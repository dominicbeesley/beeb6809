;TODO: SBC09: interrupt handlers...

	include "shared_100mstick.asm"
                lda     SBC09_UART_ISR		; read uart interrupt status register
		bita	#ISR_RxRDY_A
		bne	IRQ_RX
		
;;IRQ_TIMER
                bita    #ISR_CTR		; check the timer bit
                beq     IRQ_EXIT
                lda     SBC09_UART_STOPCT	; clear the interrupt

		M_100MSTICK

		
IRQ_EXIT
                rti     


IRQ_RX
		; TODO: larger buffer and use Hoglet's thresholds, include XON/XOFF option
2		lda	#SR_RxRDY
		bita	SBC09_UART_SRA
		beq	1F
		lda	SBC09_UART_RHRA
		ldx	#0 			; keyboard buffer
		jsr 	jmpINSV
		bra	2B

1               ldb     #OP_BIT_RTS_A
                stb     SBC09_UART_OPRCLR     	; de-assert rts
		bra	IRQ_EXIT

IRQ_SET_RTS
                ldb     #OP_BIT_RTS_A
                stb     SBC09_UART_OPRSET     	; de-assert rts
                rts
