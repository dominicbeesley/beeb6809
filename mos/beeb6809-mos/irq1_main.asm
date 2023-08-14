	include "shared_100mstick.asm"


		; TODO ACIA


;LDCA2:	lda	LFE08				;get value of status register of ACIA
;	bvs	LDCA9				;if parity error then DCA9
;	bpl	mos_VIA_INTERUPTS_ROUTINES	;else if no interrupt requested DD06
;LDCA9:	ldx	zp_mos_rs423timeout		;read RS423 timeout counter
;	dex					;decrement it
;	bmi	LDCDE				;and if <0 DCDE
;	bvs	LDCDD				;else if >&40 DCDD (RTS to DE82)
;	jmp	LF588				;else read ACIA via F588
;; ----------------------------------------------------------------------------
;LDCB3:	ldy	LFE09				;read ACIA data
;	rol	a				;
;	asl	a				;
;LDCB8:	tax					;X=A
;	tya					;A=Y
;	ldy	#$07				;Y=07
;	jmp	x_CAUSE_AN_EVENT		;check and service EVENT 7 RS423 error
;; ----------------------------------------------------------------------------
;LDCBF:	ldx	#$02				;read RS423 output buffer
;	jsr	mos_OSBYTE_145			;
;	bcc	LDCD6				;if C=0 buffer is not empty goto DCD6
;	lda	sysvar_PRINT_DEST		;else read printer destination
;	cmp	#$02				;is it serial printer??
;	bne	LDC68				;if not DC68
;	inx					;else X=3
;	jsr	mos_OSBYTE_145			;read printer buffer
;	ror	mosbuf_buf_busy+3		;rotate to pass carry into bit 7
;	bmi	LDC68				;if set then DC68
;LDCD6:	sta	LFE09				;pass either printer or RS423 data to ACIA 
;	lda	#$E7				;set timeout counter to stored value
;	sta	zp_mos_rs423timeout		;
LDCDDrti
		rts					;and exit (to DE82)
;; ----------------------------------------------------------------------------
						;A contains ACIA status
;LDCDE:	and	sysvar_ACIA_IRQ_MASK_CPY	;AND with ACIA bit mask (normally FF)
;	lsr	a				;rotate right to put bit 0 in carry 
;	bcc	LDCEB				;if carry clear receive register not full so DCEB
;	bvs	LDCEB				;if V is set then DCEB
;	ldy	sysvar_RS423_CTL_COPY		;else Y=ACIA control setting
;	bmi	LDC7D				;if bit 7 set receive interrupt is enabled so DC7D

;LDCEB:	lsr	a				;put BIT 2 of ACIA status into
;	ror	a				;carry if set then Data Carrier Detected applies
;	bcs	LDCB3				;jump to DCB3

;	bmi	LDCBF				;if original bit 1 is set TDR is empty so DCBF
;	bvs	LDCDDrti			;if V is set then exit to DE82
;	bra	issue_uknown_interrupt
;; ----------------------------------------------------------------------------
;; VIA INTERUPTS ROUTINES

;===================================================================
; VIA INTERRUPTS
;===================================================================
; The main entry point enters at the top of the timer 1 point
; in the hope that that will be fastest but may need moving to the 
; ACIA when that is ready (needs lowest latency)

;===================================================================
; Main IRQ entry point
;===================================================================

;; Main IRQ Handling routines, default IRQIV destination
mos_IRQ1V_default_entry				; LDC93
		lda	sheila_SYSVIA_ifr		;read system VIA interrupt flag register
		lbpl	mos_PRINTER_INTERRUPT_USER_VIA_1;if bit 7=0 the VIA has not caused interrupt
							;goto DD47
		anda	sysvar_SYSVIA_IRQ_MASK_CPY	;mask with VIA bit mask
		anda	sheila_SYSVIA_ier		;and interrupt enable register

		bita	#VIA_MASK_INT_T1
		beq	irq1_not_T1

		lda	#VIA_MASK_INT_T1
		sta	sheila_SYSVIA_ifr
	
	;==================== Timer 1 =========================

	M_100MSTICK
		rts


irq1_not_T1
		bita	#VIA_MASK_INT_CA1
		beq	irq1_not_vsync

	;==================== CA1 - Vsync ====================

		dec	sysvar_CFSTOCTR			;decrement vertical sync counter
		lda	zp_mos_rs423timeout		;A=RS423 Timeout counter
		bpl	LDD1E				;if +ve then DD1E
		inc	zp_mos_rs423timeout		;else increment it
LDD1E		lda	sysvar_FLASH_CTDOWN		;load flash counter
		beq	LDD3D				;if 0 then system is not in use, ignore it
		dec	sysvar_FLASH_CTDOWN		;else decrement counter
		bne	LDD3D				;and if not 0 go on past reset routine

		ldb	sysvar_FLASH_SPACE_PERIOD	;else get mark period count in X
		lda	sysvar_VIDPROC_CTL_COPY		;current VIDEO ULA control setting in A
		lsra					;shift bit 0 into C to check if first colour
		bcc	LDD34				;is effective if so C=0 jump to DD34

		ldb	sysvar_FLASH_MARK_PERIOD	;else get space period count in X
LDD34		rola					;restore bit
		eora	#$01				;and invert it
		jsr	mos_VIDPROC_set_CTL		;then change colour		;; TODO: remove this it's redundant?

		stb	sysvar_FLASH_CTDOWN		;&0251=X resetting the counter

LDD3D		ldy	#$04				;Y=4 and call E494 to check and implement vertical
		jsr	x_CAUSE_AN_EVENT		;sync event (4) if necessary
		lda	#VIA_MASK_INT_CA1		;A=2
irq_set_sysvia_ifr_rti					; LDE6E
		sta	sheila_SYSVIA_ifr		; reset SYS VIA IFR
		rts					; finished interrupts


irq1_not_vsync
		bita	#VIA_MASK_INT_CB1
		beq	irq1_not_EOC

	; ================== CB2 - EOC =======================


LDE4A		ldb	sysvar_ADC_CUR			;else get current ADC channel
		beq	LDE6C				;if 0 DE6C
		stb	adc_CH_LAST			;store in Analogue system flag marking last channel
		lda	sheila_ADC_DATA_LOW		;read low data byte
		ldx	#adc_CH1_LOW-1
		abx
		sta	,X				;store it in &2B6,7,8 or 9
		lda	sheila_ADC_DATA_HIGH		;get high data byte 
		leax	4,x
		sta	,X				;and store it in hi byte
		clra
		tfr	D,X
		ldy	#$03				;handle event 3 conversion complete
		jsr	x_CAUSE_AN_EVENT		;
		tfr	X,D
		decb
		bne	LDE69				;if X=0
		ldb	sysvar_ADC_MAX			;get highest ADC channel preseny
LDE69		jsr	LDE8F				;and start new conversion
LDE6C		lda	#$10				;rest interrupt 4
		bra	irq_set_sysvia_ifr_rti


irq1_not_EOC
		bita	#VIA_MASK_INT_T2
		beq	irq1_not_T2

	; ==================== T2 - speech =======================

		lda	#VIA_MASK_INT_T2
		sta	sheila_SYSVIA_ifr
irq1rts		rts


;		bpl	mos_SYSTEM_INTERRUPT_6_10mS_Clock;if not set the not a speech interrupt so DDCA
;		lda	#$20				;	DD6F
;		ldb	#$00				;	DD71
;		sta	sheila_SYSVIA_ifr		;	DD73
;		stb	sheila_SYSVIA_t2ch		;	DD76

;LDD79:		ldx	#$08				;	DD79
;		stx	zp_mos_OS_wksp2+1		;	DD7B
;LDD7D:		jsr	mos_OSBYTE_152			;	DD7D
;		ror	mosbuf_buf_busy+8		;	DD80
;		bmi	LDDC9				;	DD83
;		tay					;	DD85
;		beq	LDD8D				;	DD86
;		jsr	mos_OSBYTE_158			;	DD88
;		bmi	LDDC9				;	DD8B
;LDD8D:		jsr	mos_OSBYTE_145			;	DD8D
;		sta	zp_mos_curPHROM			;	DD90
;		jsr	mos_OSBYTE_145			;	DD92
;		sta	zp_mos_genPTR+1			;	DD95
;		jsr	mos_OSBYTE_145			;	DD97
;		sta	zp_mos_genPTR			;	DD9A
;		ldy	zp_mos_curPHROM			;	DD9C
;		beq	LDDBB				;	DD9E
;		bpl	LDDB8				;	DDA0
;		bit	zp_mos_curPHROM			;	DDA2
;		bvs	LDDAB				;	DDA4
;		jsr	LEEBB				;	DDA6
;		bvc	LDDB2				;	DDA9
;LDDAB:		asl	zp_mos_genPTR			;	DDAB
;		rol	zp_mos_genPTR+1			;	DDAD
;		jsr	LEE3B				;	DDAF
;LDDB2:		ldy	sysvar_SPEECH_SUPPRESS		;	DDB2
;		jmp	mos_OSBYTE_159			;	DDB5
;; ----------------------------------------------------------------------------
;LDDB8:	jsr	mos_OSBYTE_159			;	DDB8
;LDDBB:	ldy	zp_mos_genPTR			;	DDBB
;	jsr	mos_OSBYTE_159			;	DDBD
;	ldy	zp_mos_genPTR+1			;	DDC0
;	jsr	mos_OSBYTE_159			;	DDC2
;	lsr	zp_mos_OS_wksp2+1		;	DDC5
;	bne	LDD7D				;	DDC7
;LDDC9:	rts					;	DDC9

irq1_not_T2
		bita	#VIA_MASK_INT_CA2
		beq	irq1_not_keyboard

	; ======================== CA2 - keyboard =====================

		jsr	mos_enter_keyboard_routines	;else scan keyboard
		lda	#VIA_MASK_INT_CA2			;A=1
		lbra	irq_set_sysvia_ifr_rti		;and off to reset interrupt and exit

irq1_not_keyboard
issue_unknown_interrupt					; LDCF3
		ldb	#SERVICE_5_UKINT		;X=5
		jsr	mos_OSBYTE_143_b_cmd_x_param	;issue rom call 5 'unrecognised interrupt'
		beq	irq1rts				;if a rom recognises it then RTI
		ldu	#EXT_IRQ2V		
		jmp	OSCHAINVEC		; we just treat IRQ2V as a chained handler rather than
						; exit IRQ1V chain and start another.



;; ----------------------------------------------------------------------------
;; PRINTER INTERRUPT USER VIA 1
mos_PRINTER_INTERRUPT_USER_VIA_1
		
		;TODO printer interrupts
		bra	issue_unknown_interrupt


;	lda	sheila_USRVIA_ifr		;Check USER VIA interrupt flags register
;	bpl	issue_unknown_interrupt		;if +ve USER VIA did not call interrupt
;	and	sysvar_USERVIA_IRQ_MASK_CPY	;else check for USER IRQ 1
;	and	sheila_USRVIA_ier		;
;	ror	a				;
;	ror	a				;
;	bcc	issue_unknown_interrupt		;if bit 1=0 the no interrupt 1 so DCF3
;	ldy	sysvar_PRINT_DEST		;else get printer type
;	dey					;decrement
;	bne	issue_unknown_interrupt		;if not parallel then DCF3
;	lda	#$02				;reset interrupt 1 flag
;	sta	sheila_USRVIA_ifr		;
;	sta	sheila_USRVIA_ier		;disable interrupt 1
;	ldx	#$03				;and output data to parallel printer
;	jmp	LE13A				;

