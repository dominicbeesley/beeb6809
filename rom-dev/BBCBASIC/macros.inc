ABSR		MACRO
1
__ABSR		SET 1B+2
	IF \1-__ABSR <=127 AND \1-__ABSR >=-128
		BSR	\1
	ELSE
		LBSR	\1
	ENDIF
		ENDM


PRINT_STR	MACRO
		SECTION	"tables_and_strings"
1		FCB	\1,0
__STR		SET	1B
		CODE
		PSHS	X
		LEAX	__STR,PCR
		JSR	PRSTRING
		PULS	X
		ENDM


TODODEADEND		MACRO
			ABSR	PrRegs
		IF	MATCHBOX
			SWI			; generate a normal BRK
			FCB	$FF,\1,0
		ELSE
			PSHS	A,X,CC
			ABSR	PrDead
			PRINT_STR	\1
			PULS	A,X,CC
			SWI			; enter debugger

		ENDIF
			ENDM

TODO_CMD		MACRO
			TODODEADEND "\1"
			ENDM

DO_BRK_B		MACRO			; code
*		IF DEBUG
*			JSR	PrBrk
*			SWI
*		ELSE
		IF MATCHBOX
			SWI
		ELSE
			SWI3
		ENDIF
*		ENDIF
			ENDM

RESET_MACH_STACK	MACRO
			LDS	#MACH_STACK_TOP
			ENDM

LDX_FPC			MACRO			; this may be changed for position independent code
			LDX	#\1		; leave as LDX for now for faster execution
			ENDM

LDU_FPC			MACRO			; this may be changed for position independent code
			LDY	#\1		; leave as LDX for now for faster execution
			ENDM

LDY_FPC			MACRO			; this may be changed for position independent code
			LDY	#\1		; leave as LDX for now for faster execution
			ENDM


CALL			MACRO			; this may be changed for position independent code
9
__XBSR			SET 9B+2
__XBSR2			SET (\1-__XBSR) & $FF00
__XBSR3			SET (\1-__XBSR) & $FF

	IF (__XBSR2==0 && __XBSR3 < $80) || ((__XBSR2 == $FF00) && (__XBSR3 > $80))
			BSR	\1		; HOOP
	ELSE
			JSR	\1
	ENDIF
			ENDM

JUMP			MACRO			; this may be changed for position independant code
			JMP	\1
			ENDM
