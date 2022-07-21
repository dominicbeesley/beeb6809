;=======================================================
; The following section is assembled to run from main memory trampoline
;=======================================================


__CODE_FLASH_RUN__ 	EQU $2000		
__CODE_FLASH_LOAD__ 	EQU *

		ORG	__CODE_FLASH_RUN__
		PUT	__CODE_FLASH_LOAD__


; write to either JIM at zp_SRLOAD_bank/X or if bank=$FF at rom Y/X
; if CS on entry expecting flash/waittoggle

romRead		ORCC	#CC_V				; set overflow for read TODO: USE B?!
		bvs	romRead2
romWrite
		ANDCC	#~CC_V
romRead2
		pshs	CC,A,U

		lda	zp_SRLOAD_bank
		inca
  		beq	romWR_sys
  		deca
  		sta	fred_JIM_PAGE_HI
  		tfr	X,D
  		sta	fred_JIM_PAGE_LO
  		clra
  		tfr	D,U

  		lda	#CC_V
  		bita	0,S
  		bne	1F				; if C is set then it's a read

  		lda	1,S				; byte to write
  		sta	JIM,U				; store it
  		bra	romWR_exit
1		lda	JIM,U
		sta	1,S				; output A
romWR_exit
		puls	CC,A,U
		bvs	3F
		bcs	FlashWaitToggle
3		rts

romWR_sys
		lda	zp_mos_curROM
		sta	,-S
		tfr	Y,D
  		stb	zp_mos_curROM
  	IF MACH_ELK
  		lda	#$0C
  		sta	sheila_ROMCTL_SWR
  	ENDIF
  		stb	sheila_ROMCTL_SWR

  		lda	#CC_V
  		bita	1,S
  		bne	1F				; if C is set then it's a read

  		lda	2,S				; get back A
  		sta	,X				; store in SW ram area
		bra	2F

1  		lda	,X				; get byte
		sta	2,S				; output A
2		ldb	,S+
  		stb	zp_mos_curROM
  	IF MACH_ELK
  		lda	#$0C
  		sta	sheila_ROMCTL_SWR
  	ENDIF
  		stb	sheila_ROMCTL_SWR
  		bra	romWR_exit
  
  
 
FlashCmdAWT
		jsr FlashCmdA
FlashWaitToggle	pshs	CC,A
		SEI
1  		lda	JIM
  		cmpa	JIM
  		bne	1B
  		puls	CC,A,PC

;;;  ;------------------------------------------------------------------------------
;;;  ; Flash utils
;;;  ;------------------------------------------------------------------------------
;;;  
;;;  
;;;  FlashJim0055:
;;;  		ldx	#<(PG_EEPROM_BASE+$0055)
;;;  		ldy	#>(PG_EEPROM_BASE+$0055)
;;;  JimXY:		stx	fred_JIM_PAGE_LO
;;;  		sty	fred_JIM_PAGE_HI
;;;  		rts
;;;  
;;;  FlashJim5555eqAAthen2A:
;;;  		jsr	FlashJim0055
;;;  		lda	#$AA
;;;  		sta	JIM + $55
;;;  FlashJim2AAAeq55:
;;;  		ldy	#>(PG_EEPROM_BASE+$002A)
;;;  		ldx	#<(PG_EEPROM_BASE+$002A)
;;;  		jsr	JimXY
;;;  		lda	#$55
;;;  		sta	JIM + $AA
;;;  		rts
FlashCmdD
		jsr	FlashCmdA
		tfr	B,A

FlashCmdA	SEC
FlashCmd_S1
		pshs	D,X

		ldx	#PG_EEPROM_BASE+$0055
		stx	fred_JIM_PAGE_HI
		lda	#$AA
		sta	JIM + $55

		ldx	#PG_EEPROM_BASE+$002A
		stx	fred_JIM_PAGE_HI
		lda	#$55
		sta	JIM + $AA

		bcc	1F
		ldx	#PG_EEPROM_BASE+$0055
		stx	fred_JIM_PAGE_HI
		lda	1,S
		sta	JIM + $55

1		puls	D,X,PC		

FlashCmdShort	CLC
		bra	FlashCmd_S1

FlashSectorErase
		pshs	D,U,X,Y

		lda	#$80
		jsr	FlashCmdA
		jsr	FlashCmdShort
		lda	#$30
		SEC	
		jsr	romWrite
		CLC
		leau	$1000,X
		stu	zp_trans_acc+2

		; check that sector has been erased
1		jsr	romRead
		cmpa	#$FF
		bne	_FlashSectorEraseErr
		leax	1,X
		cmpx	zp_trans_acc+2
		bne	1B

_FlashSectorEraseOK
		CLC
		puls	D,U,X,Y,PC
_FlashSectorEraseErr
		lda	#'E'
		jsr	OSWRCH
		lda	zp_SRLOAD_bank
		jsr	FLPrintHexA
		jsr	FLPrintHexX
		SEC
		puls	D,U,X,Y,PC


  		; The business end of SRLOAD needs to be copied to main RAM
  		; in case we want to overwrite this ROM!
Flash_SRLOAD



  		; check to see if dest is Flash - if so initialise flash writer
  		lda	#OSWORD_BLTUTIL_RET_FLASH
  		bita	zp_SRLOAD_flags
  		beq	cmdSRLOAD_go			; ram 

  		jsr	FlashReset			; in case we're in software ID mode

  		ldx	zp_mos_genPTR

  		jsr	FlashEraseROM



cmdSRLOAD_go


cmdSRLOAD_go_lp
		lda	,U+
  		sta	zp_SRLOAD_tmpA			; save A for later
  		ldb	zp_SRLOAD_flags
  		rolb 					; Cy contains FLASH bit
  		bcc	1F				; not EEPROM, just write to ROM
  		; flash write byte command
  		lda	#$A0		
  		jsr	FlashCmdA			; Flash write byte command
  		lda	zp_SRLOAD_tmpA			; get back value to write
  		SEC					; indicate to do FlashWriteToggle
1		jsr	romWrite
  		jsr	romRead
  		cmpa	zp_SRLOAD_tmpA
  		beq	1F
		puls	CC
		bra	cmdSRCOPY_verfail
1		leax	1,X
		tfr	X,D
		tstb
		bne	cmdSRLOAD_go_lp
		anda	#$7
		bne	cmdSRLOAD_go_lp
		lda	#'.'
		jsr	OSWRCH
		cmpu	#(SRLOAD_buffer_page*256)+$4000
		blo	cmdSRLOAD_go_lp

  		lda	#'O'
  		jsr	OSASCI
  		lda	#'K'
  		jsr	OSASCI
  		jsr	OSNEWL
  
  		ldb	zp_SRLOAD_dest
  		cmpb	zp_mos_curROM
  		bne	1F
  		lda	#OSWORD_BLTUTIL_RET_ISCUR
  		bita	zp_SRLOAD_flags
2		bra	2B				; hang up
1  		rts


cmdSRCOPY_verfail
		sta	,-S
		lda	#'V'
		jsr	OSASCI				; TODO:debug - remove
		lda	zp_SRLOAD_bank
		jsr	FLPrintHexA
		jsr	FLPrintHexX
		lda	#':'
		jsr	OSASCI
		lda	,S+
		jsr	FLPrintHexA
		lda	#'<'
		jsr	OSASCI
		lda	#'>'
		jsr	OSASCI
		lda	zp_SRLOAD_tmpA
		jsr	FLPrintHexA
		jsr	OSNEWL
1		bra	1B				; hang up
		M_ERROR
		FCB	$81, "Verify fail", 0

FlashReset	pshs	A
		lda	#$F0
		jsr	FlashCmdA
		puls	A,PC
		

brkEraseFailed 	M_ERROR
		FCB	$80, "Erase fail", 0

 		; erase ROM slot Y (4 banks)
FlashEraseROM
 		pshs	D,X,Y,U
 		ldb	#4				; erase the 4 sectors
1		jsr	FlashSectorErase
 		lbcs	brkEraseFailed
 		leax	$1000,X
 		decb	
 		bne	1B
 		puls	D,X,Y,U,PC


FLPrintHexX	pshs	D
		tfr	X,D
		jsr	FLPrintHexA
		tfr	B,A 
		jsr	FLPrintHexA
		puls	D,PC

FLPrintHexA	pshs	A
		lsra
		lsra
		lsra
		lsra
		jsr	FLPrintHexNybA
		lda	0,S
		jsr	FLPrintHexNybA
		puls	A,PC

FLPrintHexNybA	anda	#$0F
		cmpa	#10
		blt	1F
		adda	#'A'-'9'-1
1		adda	#'0'
		jmp	OSASCI		


;=======================================================
; Back to normal memory mapping
;=======================================================


__CODE_FLASH_LENGTH__ EQU *-__CODE_FLASH_RUN__

		ORG	__CODE_FLASH_LOAD__+__CODE_FLASH_LENGTH__

;------------------------------------------------------------------------------
; Write to ROM # in Y, addr in zp_mos_genPTR, data in A
;------------------------------------------------------------------------------
;
; have to copy this to main memory somewhere so we can access roms whilst
; flash is being twiddled with
; TODO: this is likely to corrupt main memory and render OLD useless at boot!
;

romWriteInit	pshs	D,X,Y,U
		ldx	#__CODE_FLASH_RUN__
		ldu	#__CODE_FLASH_LOAD__
		ldy	#(__CODE_FLASH_LENGTH__+1)/2
1		ldd	,U++
		std	,X++
		leay	-1,Y
		bne	1B
		puls	D,X,Y,U



FlashReset_Q
		pshs	A,X
		ldx	#PG_EEPROM_BASE+$0055
		stx	fred_JIM_PAGE_HI
		lda	#$AA
		sta	JIM + $55

		ldx	#PG_EEPROM_BASE+$002A
		stx	fred_JIM_PAGE_HI
		lda	#$55
		sta	JIM + $AA

		ldx	#PG_EEPROM_BASE+$0055
		stx	fred_JIM_PAGE_HI
		lda	#$F0
		sta	JIM + $55
		puls	A,X,PC
