;TODO: SBC09: interrupt handlers...

	include "shared_100mstick.asm"

		


IRQ_TIMER
                lda     SBC09_UART_ISR		; read uart interrupt status register
                bita    #ISR_CTR		; check the timer bit
                beq     IRQ_EXIT
                lda     SBC09_UART_STOPCT	; clear the interrupt

		M_100MSTICK

		; TODO: make this proper RxInt handler
		lda	#SR_RxRDY
		bita	SBC09_UART_SRA
		beq	IRQ_EXIT
		lda	SBC09_UART_RHRA
		ldx	#0 			; keyboard buffer
		jsr 	jmpINSV
		
IRQ_EXIT
                rti     
