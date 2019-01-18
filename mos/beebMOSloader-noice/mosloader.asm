		include "../../includes/common.inc"
		include "../../includes/mosrom.inc"
		include "../../includes/hardware.inc"
		include "../../includes/noice.inc"
		include "../../includes/oslib.inc"



ROMBANK		EQU $8

		ORG	$2000

		; *********************************************************************************
		; load memory at 4000-7FFF to SWRAM bank #8 and switch that as the MOS

		ORCC	#CC_I+CC_F		; disable interrupts


	IF MACH_BEEB
		LDA	zp_mos_curROM
		PSHS	A
		LDA	#ROMBANK
		STA	zp_mos_curROM
		STA	sheila_ROMCTL_SWR
DESTBASE	EQU	$8000				; on beeb copy via SWROM #8
	ELSE
		LDA	#$8		
		ORA	sheila_ROMCTL_MOS
		STA	sheila_ROMCTL_MOS		; put memory at C000
DESTBASE	EQU	$C000				
	ENDIF


	IF MACH_CHIPKIT
		; map RAM bank $8 in top ROM hole and copy $4000-$7FFF there, missing out $FC00-$FEFF
		LDX	#$4000
		LDU	#DESTBASE
		LDY	#$3C00				
1		LDD	,X++
		STD	,U++
		LEAY	-2,Y
		BNE	1B

		LDX	#$7F00
		LDU	#DESTBASE + $3F00
		LDY	#$0100
1		LDD	,X++
		STD	,U++
		LEAY	-2,Y
		BNE	1B
	ELSE
		LDX	#$4000
		LDU	#DESTBASE
		LDY	#$4000				
1		LDD	,X++
		STD	,U++
		LEAY	-2,Y
		BNE	1B	
	ENDIF

;		LDD	ROM_VECTORS_SAV + OFF_SWI_VEC
;		STD	REMAPPED_HW_VECTORS + OFF_SWI_VEC
;
;		LDD	ROM_VECTORS_SAV + OFF_NMI_VEC
;		STD	REMAPPED_HW_VECTORS + OFF_NMI_VEC
;
;		LDD	ROM_VECTORS_SAV + OFF_RES_VEC
;		STD	REMAPPED_HW_VECTORS + OFF_RES_VEC

;;		LDX	#STR_BRK
;;1		LDA	,X+
;;		BEQ	2F
;;		JSR	OSWRCH
;;		BRA 	1B
;;2

	IF MACH_BEEB
		PULS	A
		STA	zp_mos_curROM
		STA	sheila_ROMCTL_SWR
		LDA	#1
		ORA	sheila_ROMCTL_MOS
		STA	sheila_ROMCTL_MOS		; page in new ROM as MOS
	ENDIF


EXITWAIT	JMP	EXITWAIT
;		DEBUG_INST				; re-enter debugger

	RTS

;ROM_VECTORS_SAV	RMB	2*HW_VECTOR_COUNT

STR_BRK		FCB	"Press BREAK",0

		END