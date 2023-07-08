		; TODO ACIA


;LDCA2:	lda	LFE08				;get value of status register of ACIA
;	bvs	LDCA9				;if parity error then DCA9
;	bpl	mos_VIA_INTERUPTS_ROUTINES	;else if no interrupt requested DD06
		bra	mos_VIA_INTERUPTS_ROUTINES
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
		rti					;and exit (to DE82)
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

issue_unknown_interrupt					; LDCF3
		ldb	#SERVICE_5_UKINT		;X=5
		jsr	mos_OSBYTE_143_b_cmd_x_param	;issue rom call 5 'unrecognised interrupt'
		beq	LDCDDrti			;if a rom recognises it then RTI
		jmp	[IRQ2V]				;else offer to the user via IRQ2V
;; ----------------------------------------------------------------------------
;; VIA INTERUPTS ROUTINES
mos_VIA_INTERUPTS_ROUTINES
		lda	sheila_SYSVIA_ifr		;read system VIA interrupt flag register
		bpl	mos_PRINTER_INTERRUPT_USER_VIA_1;if bit 7=0 the VIA has not caused interrupt
							;goto DD47
		anda	sysvar_SYSVIA_IRQ_MASK_CPY	;mask with VIA bit mask
		anda	sheila_SYSVIA_ier		;and interrupt enable register
		rora					;rotate right twice to check for IRQ 1 (frame sync)
		rora					;
		bcc	mos_SYSTEM_INTERRUPT_5_Speech	;if carry clear then no IRQ 1, else
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
		lda	#$02				;A=2
		jmp	irq_set_sysvia_ifr_rti		;clear interrupt 1 and exit
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
;; ----------------------------------------------------------------------------
;; SYSTEM INTERRUPT 5   Speech
mos_SYSTEM_INTERRUPT_5_Speech


		rola					;get bit 5 into bit 7
		rola					;
		rola					;
		rola					;

		;TODO = no speech, do something here with timer 2?
		bpl	mos_SYSTEM_INTERRUPT_6_10mS_Clock
		bra	issue_unknown_interrupt

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
;; ----------------------------------------------------------------------------
;; SYSTEM INTERRUPT 6 10mS Clock
mos_SYSTEM_INTERRUPT_6_10mS_Clock
		bcc	irq_adc_EOC			;bit 6 is in carry so if clear there is no 6 int
							;so go on to DE47
		lda	#$40				;Clear interrupt 6
		sta	sheila_SYSVIA_ifr		;

 ;UPDATE timers routine, There are 2 timer stores &292-6 and &297-B
 ;these are updated by adding 1 to the current timer and storing the
 ;result in the other, the direction of transfer being changed each
 ;time of update.  This ensures that at least 1 timer is valid at any call
 ;as the current timer is only read.  Other methods would cause inaccuracies
 ;if a timer was read whilst being updated.

 		ldy	#oswksp_TIME
		ldb	sysvar_TIMER_SWITCH		;get current system clock store pointer (5,or 10)
		leax	B,Y				
		eorb	#$0F				;and invert lo nybble (5 becomes 10 and vv)
		stb	sysvar_TIMER_SWITCH		;and store back in clock pointer (i.e. inverse previous
							;contents)
		leay	B,Y				
		ldb	#5

		SEC
LDDD9		lda	,-X				;get timer value
		adca	#$00				;update it
		sta	,-Y				;store result in alternate
		decb
		bne	LDDD9				;and go back and do next byte

		ldb	#$04				;set loop pointer for countdown timer
		ldx	#oswksp_OSWORD3_CTDOWN
LDDED		inc	b,x				;increment byte and if 
		bne	LDDFA				;not 0 then DDFA
		decb					;else decrement pointer 
		bne	LDDED				;and if not 0 do it again
		ldy	#$05				;process EVENT 5 interval timer
		jsr	x_CAUSE_AN_EVENT		;

LDDFA		lda	oswksp_INKEY_CTDOWN		;get byte of inkey countdown timer
		bne	LDE07				;if not 0 then DE07
		lda	oswksp_INKEY_CTDOWN+1		;else get next byte
		beq	LDE0A				;if 0 DE0A
		dec	oswksp_INKEY_CTDOWN+1		;decrement 2B2
LDE07		dec	oswksp_INKEY_CTDOWN		;and 2B1


LDE0A		tst	mosvar_SOUND_SEMAPHORE		;read bit 7 of envelope processing byte
		bpl	LDE1A				;if 0 then DE1A
		inc	mosvar_SOUND_SEMAPHORE		;else increment to 0
		CLI					;allow interrupts
		jsr	irq_sound			;and do routine sound processes
		SEI					;bar interrupts
		dec	mosvar_SOUND_SEMAPHORE		;DEC envelope processing byte back to FF


LDE1A		;TODO SPEECH
;;		tst	mosbuf_buf_busy+8		;read speech buffer busy flag
;;		bmi	LDE2B				;if set speech buffer is empty, skip routine
;;		jsr	mos_OSBYTE_158			;update speech system variables
;;		eora	#$A0				;
;;		cmpa	#$60				;
;;		bcc	LDE2B				;if result >=&60 DE2B
;;		jsr	LDD79				;else more speech work

		;TODO ACIA
;LDE2B:		orcc	#CC_C+CC_V			;set V and C
;		jsr	LDCA2				;check if ACIA needs attention


		lda	zp_mos_keynumlast		;check if key has been pressed
		ora	zp_mos_keynumfirst		;
		anda	sysvar_KEYB_SEMAPHORE		;(this is 0 if keyboard is to be ignored, else &FF)
		beq	LDE3E				;if 0 ignore keyboard
		SEC					;else set carry
		jsr	mos_enter_keyboard_routines	;and call keyboard

LDE3E		;TODO PRINTER
;		jsr	LE19B				;check for data in user defined printer channel
		;TODO ADC
;		bit	LFEC0				;if ADC bit 6 is set ADC is not busy
;		bvs	LDE4A				;so DE4A

		rti					;else return 
;; ----------------------------------------------------------------------------
;; SYSTEM INTERRUPT 4 ADC end of conversion
irq_adc_EOC
		rola						;put original bit 4 from FE4D into bit 7 of A
		bpl	irq_keyboard ;if not set DE72
		;TODO ADC / CB1

;LDE4A:	ldx	sysvar_ADC_CUR			;else get current ADC channel
;	beq	LDE6C				;if 0 DE6C
;	lda	LFEC2				;read low data byte
;	sta	oswksp_OSWORD0_MAX_CH,x		;store it in &2B6,7,8 or 9
;	lda	LFEC1				;get high data byte 
;	sta	adc_CH4_LOW,x			;and store it in hi byte
;	stx	adc_CH_LAST			;store in Analogue system flag marking last channel
;	ldy	#$03				;handle event 3 conversion complete
;	jsr	x_CAUSE_AN_EVENT		;

;	dex					;decrement X
;	bne	LDE69				;if X=0
;	ldx	sysvar_ADC_MAX			;get highest ADC channel preseny
;LDE69:	jsr	LDE8F				;and start new conversion
LDE6C		lda	#$10				;rest interrupt 4
irq_set_sysvia_ifr_rti				; LDE6E
		sta	sheila_SYSVIA_ifr		; reset SYS VIA IFR
		rti					; finished interrupts
;; ----------------------------------------------------------------------------
;; SYSTEM INTERRUPT 0 Keyboard;	
irq_keyboard					; LDE72
		rola					;get original bit 0 in bit 7 position
		rola					;
		rola					;
		rola					;
		bpl	LDE7F				;if bit 7 clear not a keyboard interrupt
		jsr	mos_enter_keyboard_routines	;else scan keyboard
		lda	#$01				;A=1
		bne	irq_set_sysvia_ifr_rti		;and off to reset interrupt and exit
LDE7F		jmp	issue_unknown_interrupt		
