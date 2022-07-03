
		


PRINT		macro					;  MSG

		section "data"
1		fcb \1, 0
PRINT_TMP	set	1B
		code
		pshs	A,X
		ldx	#PRINT_TMP
1		lda	,X+
		beq	2F
		jsr	OSASCI
		bra	1B
2		puls	A,X
		endm

PRINTL		macro
		PRINT 	\1
		jsr	OSNEWL
		endm
