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
		ldb	SBC09_UART_RHRA
		clra
		tfr	D,Y
		jsr	x_INSERT_byte_in_Keyboard_buffer
		
		bra	2B

1               
		tst	sysvar_KEYB_FLOWCTL
		beq	IRQ_EXIT		; flow control off
		ldb     #OP_BIT_RTS_A
                stb     SBC09_UART_OPRCLR     	; de-assert rts
		bra	IRQ_EXIT

IRQ_SET_RTS
                ldb     #OP_BIT_RTS_A
                stb     SBC09_UART_OPRSET     	; assert rts
                rts
