		include "../../includes/hardware.inc"
		include "../../includes/common.inc"
		include "../../includes/oslib.inc"
		include "../../includes/mosrom.inc"


		setdp 0


		org	$2000
		; make AS and output and set to low
		lda	#$8F
		sta	sheila_SYSVIA_ddrb

clock_lp

		ldb	#$A
		jsr	rtc_read
		tsta
		bpl	2F

1		ldb	#$A
		jsr	rtc_read
		tsta
		bmi	1B

2		orcc	#CC_I + CC_F
		ldx	#$2800
		ldb	#0
1		jsr	rtc_read
		sta	,X+
		incb
		cmpb	#10
		blo	1B

		lda	$2804
		jsr	PRHEX
		lda	#':'
		jsr	OSWRCH

		lda	$2802
		jsr	PRHEX
		lda	#':'
		jsr	OSWRCH

		lda	$2800
		jsr	PRHEX
		lda	#' '
		jsr	OSWRCH

		lda	$2807
		jsr	PRHEX
		lda	#'/'
		jsr	OSWRCH

		lda	$2808
		jsr	PRHEX
		lda	#'/'
		jsr	OSWRCH

		lda	$2809
		jsr	PRHEX
		jsr	OSNEWL

		bra	clock_lp

excercise	ldb	#$20
1		jsr	rtc_read
		bra	1B


dump_rtc_regs
		; make AS and output and set to low
		lda	#$8F
		sta	sheila_SYSVIA_ddrb

		ldx	#$2800
		ldb	#0
1		jsr	rtc_read
		sta	,X+
		incb
		bne	1B
		swi

setup_rtc_regs
		ldb	#$10
1		tfr	B,A
		jsr	rtc_write
		incb
		bne	1B
		swi

reset_clock
		; make AS and output and set to low
		lda	#$8F
		sta	sheila_SYSVIA_ddrb

		lda	#$21
		ldb	#$A
		jsr	rtc_write

		lda	#$02
		ldb	#$B
		jsr	rtc_write


		lda	#$00		; seconds
		ldb	#0
		jsr	rtc_write


		lda	#$24		; minutes
		ldb	#2
		jsr	rtc_write

		lda	#$17		; hours
		ldb	#4
		jsr	rtc_write

		lda	#7			; DoW
		ldb	#6
		jsr	rtc_write

		lda	#$14		; day
		ldb	#7
		jsr	rtc_write

		lda	#$10		; mo
		ldb	#8
		jsr	rtc_write

		lda	#$17		; yr
		ldb	#9
		jsr	rtc_write

		swi

		; rtc_write A=data, B=address
rtc_write
		pshs	CC,A

		orcc	#CC_I + CC_F			; disable interrupts

		; AS low
		lda	#BITS_RTC_AS_OFF
		sta	sheila_SYSVIA_orb

		; DS low
		lda	#BITS_RTC_DS
		sta	sheila_SYSVIA_orb

		; AS hi
		lda	#BITS_RTC_AS_ON
		sta	sheila_SYSVIA_orb

		lda	#$FF
		sta	sheila_SYSVIA_ddra

		; rtc address
		stb	sheila_SYSVIA_ora_nh

		; CS low
		lda	#BITS_RTC_CS 
		sta	sheila_SYSVIA_orb

		; RnW lo
		lda	#BITS_RTC_RnW
		sta	sheila_SYSVIA_orb

		; AS low
		lda	#BITS_RTC_AS_OFF
		sta	sheila_SYSVIA_orb

		; DS hi
		lda	#BITS_RTC_DS + BITS_LAT_ON
		sta	sheila_SYSVIA_orb

		lda	1,S
		sta	sheila_SYSVIA_ora_nh

		; DS low
		lda	#BITS_RTC_DS
		sta	sheila_SYSVIA_orb

		; CS hi
		lda	#BITS_RTC_CS + BITS_LAT_ON
		sta	sheila_SYSVIA_orb

		puls	CC,A,PC

		; rtc_read A=data, B=address
rtc_read	
		pshs	CC,A

		orcc	#CC_I + CC_F			; disable interrupts

		; AS low
		lda	#BITS_RTC_AS_OFF
		sta	sheila_SYSVIA_orb

		; DS low
		lda	#BITS_RTC_DS
		sta	sheila_SYSVIA_orb

		; AS hi
		lda	#BITS_RTC_AS_ON
		sta	sheila_SYSVIA_orb

		lda	#$FF
		sta	sheila_SYSVIA_ddra

		; rtc address
		stb	sheila_SYSVIA_ora_nh

		; CS low
		lda	#BITS_RTC_CS 
		sta	sheila_SYSVIA_orb

		; slow D all in
		clr	sheila_SYSVIA_ddra

		; RnW hi
		lda	#BITS_RTC_RnW + BITS_LAT_ON
		sta	sheila_SYSVIA_orb

		; AS low
		lda	#BITS_RTC_AS_OFF
		sta	sheila_SYSVIA_orb

		; DS hi
		lda	#BITS_RTC_DS + BITS_LAT_ON
		sta	sheila_SYSVIA_orb

		lda	sheila_SYSVIA_ora_nh
		sta	1,S

		; DS low
		lda	#BITS_RTC_DS
		sta	sheila_SYSVIA_orb

		; CS hi
		lda	#BITS_RTC_CS + BITS_LAT_ON
		sta	sheila_SYSVIA_orb

		puls	CC,A,PC

		end