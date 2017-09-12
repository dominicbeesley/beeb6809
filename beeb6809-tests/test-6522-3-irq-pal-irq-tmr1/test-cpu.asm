; assumes a working MOS VDU and hardware vectors at $A10

CC_C		EQU	$01
CC_V		EQU	$02
CC_Z		EQU	$04
CC_N		EQU	$08
CC_I		EQU	$10
CC_H		EQU	$20
CC_F		EQU	$40
CC_E		EQU	$80


OSWRCH		EQU	$FFEE
OSASCI		EQU	$FFE3

IRQVEC		EQU	$F7F8

PAL_RG		EQU	$FE22
PAL_BWR		EQU	$FE23
zp_ctr		EQU	$80

sheila_SYSVIA_orb			EQU $FE40
sheila_SYSVIA_ora			EQU $FE41
sheila_SYSVIA_ddrb			EQU $FE42
sheila_SYSVIA_ddra			EQU $FE43
sheila_SYSVIA_t1cl			EQU $FE44
sheila_SYSVIA_t1ch			EQU $FE45
sheila_SYSVIA_t1ll			EQU $FE46
sheila_SYSVIA_t1lh			EQU $FE47
sheila_SYSVIA_t2cl			EQU $FE48
sheila_SYSVIA_t2ch			EQU $FE49
sheila_SYSVIA_sr			EQU $FE4A
sheila_SYSVIA_acr			EQU $FE4B
sheila_SYSVIA_pcr			EQU $FE4C
sheila_SYSVIA_ifr			EQU $FE4D
sheila_SYSVIA_ier			EQU $FE4E
sheila_SYSVIA_ora_nh			EQU $FE4F


barres		EQU	1				; no of scan lines per interrupt, must divide into frame lines
tm1val		EQU	(64*barres)-2

		SETDP	$0
		ORG	$1000

; setup
		ORCC	#CC_I+CC_F			; disable CPU interrupts

		LDX	#irq_handle
		STX	IRQVEC

		LDA	#$7F				; disable VIA interrupts
		STA	sheila_SYSVIA_ier
		LDA	#$C2				; enable CA1 interrupt (bit 1) and TMR1 (bit 6)
		STA	sheila_SYSVIA_ier
		LDA	#$05				; CA1 interrupt on pos, CA2 interrupt on pos
		STA	sheila_SYSVIA_pcr
		LDA	#$40				; Timer 1 free run
		STA	sheila_SYSVIA_acr

		LDA	#tm1val%256			; 64uS into TMR1
		STA	sheila_SYSVIA_t1ll
		LDA	#tm1val/256			; 64uS into TMR1
		STA	sheila_SYSVIA_t1lh

		LDA	#22
		JSR	OSWRCH
		LDA	#2				; mode 2
		JSR	OSWRCH

		LDA	#0
		LDB	#16
lp1		PSHS	A,B
		LDA	#17
		JSR	OSASCI
		LDA	0,S
		JSR	OSASCI
; print message
		LDX	#message
lp2		LDA	,X+
		BEQ	sk1
		JSR	OSASCI
		bra	lp2
sk1
		PULS	A,B
		INCA
		DECB
		BNE	lp1



; make a border at left
		LDA	#$FC		; two pixels of colour $E
		LDX	#$3000
filllp		LDB	#16
filllp2		STA	,X+
		DECB
		BNE	filllp2
		LEAX	640-16,X
		CMPX	#$8000
		BLO	filllp

		LDX	#0
		STX	zp_ctr
		LDX	#palents

		; synchronise timer and VS
		LDA	sheila_SYSVIA_ora	; clear interrupt
		LDA	#$02
synclp		BITA	sheila_SYSVIA_ifr
		BEQ	synclp
		LDA	#tm1val/256			; 64uS into TMR1
		STA	sheila_SYSVIA_t1lh


		ANDCC	#~CC_I		; enable interrupts


here		bra	here




		SWI


irq_handle	LDA	sheila_SYSVIA_ifr
		BITA	#$02
		BNE	irq_vs
		BITA	#$40
		BNE	irq_tmr1
		RTI

irq_vs
;		CLR	sheila_SYSVIA_t1ch	; synchronise counter
		LDA	sheila_SYSVIA_ora	; clear interrupt
		INC	zp_ctr
		LDA	zp_ctr
		STA	zp_ctr + 1
		RTI

irq_tmr1
		LDA	sheila_SYSVIA_t1cl
lp3		INC	zp_ctr + 1	; 6	2
		LDB	zp_ctr + 1	; 4	2

		ANDB	#$1E		; 2	2
		LDA	B,X		; 4+1	2+0
		STA	PAL_RG		; 5?1	3
		INCB			; 2	1
		LDA	B,X		; 4+1	2+0
		ANDA	#$0F		; 2	2
		ORA	#$E0		; 2	2	; colour 0
		STA	PAL_BWR		; 5?1	3
		RTI


palents		FDB	$0000, $4000, $8000, $C000
		FDB	$C004, $C008, $C00C, $C00C
		FDB	$C408, $C804, $CC00, $8C00
		FDB	$4C00, $0C00, $0800, $0400

message		FCB	" Ishbel Bobblechops",13,0