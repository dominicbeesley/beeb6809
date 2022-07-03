; assumes a working MOS VDU and hardware vectors at $A10

OSWRCH		EQU	$FFEE
OSASCI		EQU	$FFE3

RAMVEC		EQU	$A10	; the hardware vectors redirect to
IRQVEC		EQU	RAMVEC+8

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


		SETDP	$0
		ORG	$1000

; setup

		LDA	#$7F				; disable all interrupts
		STA	sheila_SYSVIA_ier
		LDA	#$05				; CA1 interrupt on pos, CA2 interrupt on pos
		STA	sheila_SYSVIA_pcr
		LDA	#40				; Timer 1 free run
		STA	sheila_SYSVIA_acr

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


wait_vs		LDA	#$02
		ANDA	sheila_SYSVIA_ifr
		BEQ	wait_vs
		LDA	sheila_SYSVIA_ora	; clear int
		LDA	zp_ctr
		ASLA
		ANDA	#$7F
		STA	zp_ctr + 1



		LDB	#0		; line ctr
		STB	zp_ctr + 2
lp3nop		NOP
		NOP
		NOP
		BRA	lp3

lp3		LDB	zp_ctr + 1	; 4	2
		ASRB
		ANDB	#$1E		; 2	2
		LDA	B,X		; 4+1	2+0
		STA	PAL_RG		; 5?1	3
		INCB			; 2	1
		LDA	B,X		; 4+1	2+0
		ANDA	#$0F		; 2	2
		ORA	#$E0		; 2	2
		STA	PAL_BWR		; 5?1	3

		NOP

		LDB	#12		; 2	2
lp_del		DECB			; 2	1
		BNE	lp_del		; 3	1
		NOP

		INC	zp_ctr + 1	; 6	2
		DEC	zp_ctr + 2	; 6	2
		BNE	lp3nop		; 3	2
		INC	zp_ctr		; 6	2
		BRA	wait_vs		; 3	2

		SWI


palents		FDB	$0000, $4000, $8000, $C000
		FDB	$C004, $C008, $C00C, $C00C
		FDB	$C408, $C804, $CC00, $8C00
		FDB	$4C00, $0C00, $0800, $0400

message		FCB	" Ishbel Bobblechops",13,0