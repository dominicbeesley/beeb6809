M_100MSTICK	macro

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


LDE0A	
	IF INCLUDE_SOUND
		tst	mosvar_SOUND_SEMAPHORE		;read bit 7 of envelope processing byte
		bpl	LDE1A				;if 0 then DE1A
		inc	mosvar_SOUND_SEMAPHORE		;else increment to 0	
		CLI					;allow interrupts
		jsr	irq_sound			;and do routine sound processes
		SEI					;bar interrupts
		dec	mosvar_SOUND_SEMAPHORE		;DEC envelope processing byte back to FF
	ELSE
		;TODO: SBC09 - just discard all the sounds!
		ldx	#4
1		jsr	mos_OSBYTE_145
		bcc	1B
		leax	1,X
		cmpx	#8
		bne	1B
	ENDIF


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

		endm