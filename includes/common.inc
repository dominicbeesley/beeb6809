		; processor flags
CC_C		EQU	$01
CC_V		EQU	$02
CC_Z		EQU	$04
CC_N		EQU	$08
CC_I		EQU	$10
CC_H		EQU	$20
CC_F		EQU	$40
CC_E		EQU	$80

m_tax		MACRO
		pshs	A
		clr	,-S
		puls	X
		ENDM

m_tax_se	MACRO
		jsr	_m_tax_se
		ENDM


m_tay		MACRO
		pshs	A
		clr	,-S
		puls	Y
		ENDM

m_tbx		MACRO
		pshs	B			;6
		clr	,-S			;8
		puls	X			;7 = 21
		ENDM

m_tby		MACRO
		pshs	B
		clr	,-S
		puls	Y
		ENDM


m_txa		MACRO
		pshs	X
		leas	1,S
		lda	,S+
		ENDM

m_tya		MACRO
		pshs	Y
		leas	1,S
		lda	,S+
		ENDM

m_txb		MACRO
		pshs	X
		leas	1,S
		ldb	,S+
		ENDM

m_tyb		MACRO
		pshs	Y
		leas	1,S
		ldb	,S+
		ENDM



BRKSIZE		EQU	2


BRK	MACRO
	swi3
	ENDM

DO_BRK	MACRO
	BRK
	FCB	\1
	FCB	\2,0
	ENDM


CLI	MACRO
	ANDCC	#~(CC_I+CC_F)
	ENDM

SEI	MACRO
	ORCC	#CC_I+CC_F
	ENDM

CLC	MACRO
	ANDCC	#~CC_C
	ENDM

SEC	MACRO
	ORCC	#CC_C
	ENDM

CLV	MACRO
	ANDCC	#~CC_V
	ENDM

SEV	MACRO
	ORCC	#CC_V
	ENDM

STX_B	MACRO
	PSHS	D
	TFR	X,D
	STB	\1
	PULS	D
	ENDM


STY_B	MACRO
	PSHS	D
	TFR	Y,D
	STB	\1
	PULS	D
	ENDM

LDX_B	MACRO
	PSHS	D
	LDB	\1
	LDA	#0	;DB: changed as CLRA resets carry!
	TFR	D,X
	PULS	D
	ENDM

LDY_B	MACRO
	PSHS	D
	LDB	\1
	LDA	#0	;DB: changed as CLRA resets carry!
	TFR	D,Y
	PULS	D
	ENDM