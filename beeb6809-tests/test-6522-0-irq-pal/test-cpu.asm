; assumes a working MOS VDU and hardware vectors at $A10

OSWRCH		EQU	$FFEE
OSASCI		EQU	$FFE3

RAMVEC		EQU	$A10	; the hardware vectors redirect to
IRQVEC		EQU	RAMVEC+8

PAL_RG		EQU	$FE22
PAL_BWR		EQU	$FE23
zp_ctr		EQU	$80

		SETDP	$0
		ORG	$1000

; setup
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

		LDX	#0
		STX	zp_ctr
		LDX	palents
lp3nop
		NOP
		NOP
		NOP
		BRA	lp3

lp3		LDB	zp_ctr + 1	; 4	2
		ANDB	#$F		; 2	2
		ASLB			; 2	1
		LDA	B,X		; 4+1	2+0
		STA	PAL_RG		; 5?1	3
		INCB			; 2	1
		LDA	B,X		; 4+1	2+0
		ANDA	#$0F		; 2	2
		ORA	#$E0		; 2	2
		STA	PAL_BWR		; 5?1	3

		NOP
		NOP
		NOP
		NOP

		LDB	#12		; 2	2
lp_del		DECB			; 2	1
		BNE	lp_del		; 3	1
		NOP

		INC	zp_ctr + 1	; 6	2
		BNE	lp3nop		; 3	2
		INC	zp_ctr		; 6	2
		BNE	lp3		; 3	2

		SWI


palents		FDB	$0000, $4000, $8000, $C000
		FDB	$C004, $C008, $C00C, $C00C
		FDB	$C408, $C804, $CC00, $8C00
		FDB	$4C00, $0C00, $0800, $0400

message		FCB	"Ishbel Bobble Chops",13,0