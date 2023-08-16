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
                rts     


IRQ_RX
		; TODO: larger buffer and use Hoglet's thresholds, include XON/XOFF option
		lda	#SR_RxRDY
		bita	SBC09_UART_SRA
		bne	2F
IRQ_UK		ldu	#EXT_IRQ2V		
		jmp	OSCHAINVEC		; we just treat IRQ2V as a chained handler rather than
						; exit IRQ1V chain and start another.


2		ldb	SBC09_UART_RHRA
		clra
		tfr	D,Y
		jsr	x_INSERT_byte_in_Keyboard_buffer
		
		lda	#SR_RxRDY
		bita	SBC09_UART_SRA
		bne	2B
		tst	sysvar_KEYB_FLOWCTL
		beq	IRQ_EXIT		; flow control off
		ldb     #OP_BIT_RTS_A
                stb     SBC09_UART_OPRCLR     	; de-assert rts
		rts

IRQ_SET_RTS
                ldb     #OP_BIT_RTS_A
                stb     SBC09_UART_OPRSET     	; assert rts
                rts

