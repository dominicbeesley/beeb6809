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

IRQVEC		EQU	$F7F8	;IRQ

PAL_RG		EQU	$FE22
PAL_BWR		EQU	$FE23
zp_ctr		EQU	$80
zp_save_D	EQU	$84
zp_save_X	EQU	$86

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

		LDA	#$FF
		STA	sheila_SYSVIA_ddra
		LDA	#$0F
		STA	sheila_SYSVIA_ddrb
		LDA	#$08
		STA	sheila_SYSVIA_orb

		LDA	#0
		LDB	#$F
		JSR	snd_vol
		LDA	#1
		LDB	#$F
		JSR	snd_vol
		LDA	#2
		LDB	#$F
		JSR	snd_vol
		LDA	#3
		LDB	#$F
		JSR	snd_vol

		JSR	delay_long

		LDA	#1
		LDX	#284
		JSR	snd_tone
		LDA	#1
		LDB	#$0
		JSR	snd_vol

		JSR	delay_long
		LDA	#1
		LDB	#$F
		JSR	snd_vol
		LDA	#2
		LDB	#$F

		LDA	#1
		LDX	#500
		JSR	snd_tone
		LDA	#1
		LDB	#$0
		JSR	snd_vol
		LDA	#2
		LDX	#530
		JSR	snd_tone
		LDA	#2
		LDB	#$0
		JSR	snd_vol

		JSR	delay_long
		JSR	delay_long
		JSR	delay_long
		JSR	delay_long
		JSR	delay_long
		JSR	delay_long

		LDA	#2
		LDB	#$F
		JSR	snd_vol

;arpeggio
		LDX	#200
		
arplp
		STX	$80
		LDA	#1
		LDX	#238	; middle C
		JSR	snd_tone
		JSR	delay_short
		LDA	#1
		LDX	#189	; E
		JSR	snd_tone
		JSR	delay_short
		LDA	#1
		LDX	#159	; G
		JSR	snd_tone
		JSR	delay_short
		LDX	$80
		LEAX	-1,X
		BNE	arplp


;chord
		LDA	#1
		LDX	#238	; middle C
		JSR	snd_tone
		JSR	delay_short
		LDA	#2
		LDX	#189	; E
		JSR	snd_tone
		JSR	delay_short
		LDA	#3
		LDX	#159	; G
		JSR	snd_tone

		LDA	#1
		LDB	#$0
		JSR	snd_vol
		LDA	#2
		LDB	#$0
		JSR	snd_vol
		LDA	#3
		LDB	#$0
		JSR	snd_vol

		JSR	delay_long
		JSR	delay_long
		JSR	delay_long
		JSR	delay_long
		JSR	delay_long

		LDA	#1
		LDB	#$F
		JSR	snd_vol
		LDA	#2
		LDB	#$F
		JSR	snd_vol
		LDA	#3
		LDB	#$F
		JSR	snd_vol


		SWI

snd_sendA
		STA	sheila_SYSVIA_ora	; set data
		CLR	sheila_SYSVIA_orb	; we low
		LDB	#2
1		DECB
		BNE	1B
		LDA	#$08
		STA	sheila_SYSVIA_orb	; we high
		LDB	#4
1		DECB
		BNE	1B
		RTS

snd_vol
		COMA
		RORA
		RORA
		RORA
		RORA
		ANDA	#$60
		ORA	#$90
		ANDB	#$0F
		PSHS	B
		ORA	,S+
		BRA	snd_sendA

snd_tone
		COMA
		RORA
		RORA
		RORA
		RORA
		ANDA	#$60
		ORA	#$80
		PSHS	A,X
		LDA	2,S
		ANDA	#$F
		ORA	0,S
		JSR	snd_sendA
		LDD	1,S
		RORA
		RORB

		RORA
		RORB

		RORA
		RORB

		RORA
		RORB

		ANDB	#$7F
		TFR	B,A
		LEAS	3,S
		BRA	snd_sendA

delay_long
		LDX	#0
1		LEAX 	-1,X
		BNE	1B
		RTS

delay_short	LDX	#5000
1		LEAX 	-1,X
		BNE	1B
		RTS
