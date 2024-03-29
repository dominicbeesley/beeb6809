			; Zero page
ZP_LOMEM		EQU $00
ZP_VARTOP		EQU $02
ZP_BAS_SP		EQU $04
ZP_HIMEM		EQU $06
ZP_ERL			EQU $08
ZP_TXTOFF		EQU $0A
ZP_TXTPTR		EQU $0B
ZP_RND_WA		EQU $0D		; this keeps same endianness as 6502
ZP_TOP			EQU $12
ZP_PRINTBYTES		EQU $14		; order of these is assumed in cmdPRINT
ZP_PRINTFLAG		EQU $15
ZP_ERR_VECT		EQU $16
ZP_PAGE_H		EQU $18
ZP_TXTPTR2		EQU $19
ZP_TXTOFF2		EQU $1B
ZP_READ_PTR		EQU $1C
ZP_PRLINCOUNT		EQU $1E
ZP_LISTO		EQU $1F
ZP_TRACE		EQU $20
ZP_MAXTRACLINE		EQU $21
ZP_WIDTH		EQU $23
ZP_REPEAT_LVL		EQU $24
ZP_GOSUB_LVL		EQU $25
ZP_FOR_LVL_X_15		EQU $26
ZP_VARTYPE		EQU $27
ZP_OPT			EQU $28
ZP_ASS_OPBUF		EQU $29		;; overlaps ZP_DUNNO, ZP_INT_WA stores opcode/postbytes being assembled
ZP_DUNNO		EQU $29
ZP_INT_WA		EQU $2A
ZP_FPA			EQU $2E
ZP_STRBUFLEN		EQU $36
ZP_SAVE_BUF		EQU $37		;; note this overlaps 
ZP_GEN_PTR		EQU $37
ZP_ASS_LIST_OPLEN	EQU $38
ZP_ASS_OPLEN		EQU $39		;; length of opcode + postbytes

ZP_NAMELENORVT		EQU $37		;; NOTE this is different to 6502 where it is ZP_GEN_PTR+2

ZP_ASS_OPSAVED		EQU $3A		;; start of last saved instruction (used in print)
ZP_FPB			EQU $3B
ZP_INT_WA_B		EQU $39		;; note overlaps ZP_NAMELENORVT and ZP_FP_WA_B sign, exponent
ZP_INT_WA_C		EQU $3D		;; note overlaps ZP_FP_WA_B mantissa
ZP_ASS_OP_IX		EQU ZP_FPB + 9
ZP_FP_TMP		EQU $43
ZP_FP_TMP_PTR1		EQU $4A
ZP_FP_TMP_PTR2		EQU $4C

ZP_ASS_LBLEND		EQU $4E
ZP_TMP			EQU $4E		; new temporary save / loop counter area
ZP_DUNNO_WA		EQU $50	

ZP_ESCPTR		EQU $50		; new save pointer to escape flag
ZP_EXTRA_SAVE		EQU $52		; get rid if possible? (used in cmdFOR)
ZP_BIGEND		EQU $54		; =0 for bigendian OS NE for anything else
ZP_EXTRA_SAVE_PROC	EQU $56		; get rid if possible? (used in doFNPROC)
ZP_DAFT			EQU $6F

