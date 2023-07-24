mos_VDU_init
		rts
mos_VDU_WRCH
		; unbuffered write - TODO: Use Hoglet's interrupt driven buffers
		pshs	B
		ldb	#SR_TxRDY
1		bitb	SBC09_UART_SRA
		beq	1B
		sta	SBC09_UART_THRA
		CLC
		puls	B,PC


mos_tax		m_tax
		rts

mos_OSBYTE_20
		lda	sysvar_PRI_OSHWM		;	CD1F
		sta	sysvar_CUR_OSHWM		;	CD34
		ldb	#SERVICE_11_FONT_BANG		;	CD3A
		jmp	mos_OSBYTE_143_b_cmd_x_param


mos_OSBYTE_132
mos_OSBYTE_133
		ldd 	#$7E00				; SBC09: HIMEM is always 7E00 for now...
		tfr	D,X				; return X is full adress, Y is high byte
		jmp	LE71F_tay_c_rts
		

mos_OSBYTE_134
		; no cursor
		clra
		clrb
		tfr	D,X
		tfr	D,Y
		rts
mos_OSBYTE_135
		ldy	#0
		ldx	#0
	rts