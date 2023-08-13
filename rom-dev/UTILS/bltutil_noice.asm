;==============================================================================
; NoIce utilities called via ROM
;==============================================================================

cmdNOICE
		jsr	SkipSpacesX
		leax	1,X
		jsr	ToUpper		
		cmpa	#13
		beq	cmdNoiceBadCmd
		cmpa	#'O'
		beq	cmdNOICE_onoff
		cmpa	#'B'
		bne	cmdNoiceBadCmd
		lda	,X+
		jsr	ToUpper
		cmpa	#'R'
		bne	cmdNoiceBadCmd
		lda	,X+
		jsr	ToUpper
		cmpa	#'K'
		bne	cmdNoiceBadCmd

cmdNOICE_brk
		stx	zp_mos_txtptr			; picked up by some programs as command line pointer
		lda	#BITS_MEM_CTL_SWMOS_DEBUG_EN
		bita	sheila_ROMCTL_MOS
		bne	1F
		jsr	cmdNOICE_on
1		DEBUG_INST				; issue special BRK illegal op
		rts

cmdNOICE_onoff	lda	,X+
		jsr	ToUpper
		cmpa	#'N'
		beq	cmdNOICE_on
		cmpa	#'F'
		beq	cmdNOICE_off
cmdNoiceBadCmd	lbra	brkBadCommand



cmdNOICE_off	lda	sheila_ROMCTL_MOS
		anda	#~BITS_MEM_CTL_SWMOS_DEBUG_EN
		sta	sheila_ROMCTL_MOS

		jsr	cmdNoicePrNoiceDeb
		ldx	#str_off
		jsr	PrintX
		jmp	PrintNL


cmdNoicePrNoiceDeb
		ldx	#str_NoiceDeb
		jmp	PrintX


;--------------------------------------------------------
NoIceUtils_Init			
cmdNOICE_on	
;--------------------------------------------------------
; called during boot / Service Call 1 to initialise
; or when started bye *NOICE ON or *NOICE BRK
		lda	sheila_ROMCTL_MOS
		ora	#BITS_MEM_CTL_SWMOS_DEBUG_EN
		sta	sheila_ROMCTL_MOS

		; setup serial for 19200
		ldx	#8
		lda	#7
		jsr	OSBYTE
		ldx	#8
		lda	#8
		jsr	OSBYTE

		; TODO: Maybe make this nicer, at the moment it just nabs the
		; vectors
		ldx	#NoIceSys_Handle_NMI9V
		stx	EXT_NMI9V
		lda	zp_mos_curROM
		sta	EXT_NMI9V+2
;Ext only
;;		ldx	#NoIceSys_Handle_SWI9V
;;		stx	EXT_SWI9V

		lda	zp_mos_curROM
		sta	EXT_SWI9V+2
; Ext only
;;		ldx	#EXTVEC_ENTER_SWI9V
;;		stx	SWI9V

		jsr	NoIceSys_Handle_RESET		; call NoIce reset routine

printNoiceOn
		; printed to serial port too...
		jsr	cmdNoicePrNoiceDeb	
		jsr	NoIcePrintX
		ldx	#str_on
		jsr	PrintX
		jsr	NoIcePrintX
		jsr	PrintNL
		jmp	NoIcePrintNL


NoIcePrintNL	lda	#13
		jsr	NoIcePrintCh
		lda	#10
NoIcePrintCh
		pshs	D
		lda	#ACIA_TDRE
		ldb	#0
1		bita	sheila_ACIA_CTL
		bne	2F
		decb
		bne	1B
		puls	D,PC
2		lda	0,S
		sta	sheila_ACIA_DATA
		puls	D,PC

NoIcePrintX	lda	,X+
		beq	1F
		jsr	NoIcePrintCh
		bra	NoIcePrintX
1		rts


		; the following routines are entered with:
		;	5+	Caller RTI signature
		;	4	Extended vector addr (lo)
		;	3	Extended vector addr (hi)
		;	2	cur SWR#
		;	1	x_return_addess_from_ROM_indirection (lo)
		;	0	x_return_addess_from_ROM_indirection (hi)
		; this is set up by the MOS during an extended vector redirect
		; this needs to be unstacked and stack reset to point
		; this has to be done in the 


NoIceSys_Handle_NMI9V
		jsr	OSEXITVEC
		leas	2,S				; discard vector chaining stuff from stack
		ldx	#NOICE_NMI_ENTER_EXT		; put address of NoIce entry point on stack
		pshs	X
		lda	sheila_ROMCTL_MOS
		ora	#BITS_MEM_CTL_SWMOS_DEBUG
		sta	sheila_ROMCTL_MOS		; this will enable DEBUG map _after_ the next rts
							; by which time we'll be in NoIce...
		rts					; NOT a real rts but a jump to the address we pushed

NoIceSys_Handle_SWI9V
		jsr	OSEXITVEC
		leas	2,S				; discard vector chaining stuff from stack
		ldx	#NOICE_SWI_ENTER_EXT		; put address of NoIce entry point on stack
		pshs	X
		lda	sheila_ROMCTL_MOS
		ora	#BITS_MEM_CTL_SWMOS_DEBUG
		sta	sheila_ROMCTL_MOS		; this will enable DEBUG map _after_ the next rts
							; by which time we'll be in NoIce...
		rts					; NOT a real rts but a jump to the address we pushed

		; at reset / turn on of NoIce we must
		; call NoIce's reset:
		; - here we page in the debug MOS
		; then jump to the entry function there
		; not strictly necessary (as above cases) as we don't need to page
		; this ROM out.

NoIceSys_Handle_RESET
		ldx	#NoIceSys_Handle_RESET_Done	; return address
		pshs	X
		ldx	#NOICE_RESET_ENTER_EXT		; put address of NoIce entry point on stack
		pshs	X
		lda	sheila_ROMCTL_MOS
		ora	#BITS_MEM_CTL_SWMOS_DEBUG
		sta	sheila_ROMCTL_MOS		; this will enable DEBUG map _after_ the next rts
							; by which time we'll be in NoIce...
		rts					; NOT a real rts but a jump to the address we pushed
NoIceSys_Handle_RESET_Done
		sta	sheila_MEM_DEBUG_SAVE		; reset DEBUG map
		rts



;===============================================================================
; IMPORT NOICE OVERLAY
;===============================================================================


NOICE_CODE_BASE 	EQU $F100
NOICE_ENTER_NMI_ENT 	EQU NOICE_CODE_BASE
NOICE_ENTER_SWI_ENT 	EQU NOICE_CODE_BASE+2
NOICE_ENTER_PUTCHAR_ENT	EQU NOICE_CODE_BASE+4
NOICE_ENTER_RESET_ENT 	EQU NOICE_CODE_BASE+6

		ORG NOICE_CODE_BASE - $4000

		;TODO: check if 6309 version works on 6809 (I think it does but auto-detects?)
		includebin "../../mos/noice/noice/mon-noice-6309-beeb-debug.ovr"

;===============================================================================
; DEBUG VECTORS
;===============================================================================
; These vetors are mapped in (with noice) in the top part of the MOS area when
; debugging is active
;
		ORG	$F7F0
		PUT	$B7F0

		FDB	NOICE_DIV0_ENT		       	; f7f0 (reserved)
		FDB	NOICE_SWI3_ENT			; f7f2 (SWI3)
		FDB	NOICE_SWI2_ENT	       		; f7f4 (SWI2)
		FDB	NOICE_FIRQ_ENT	       		; f7f6 (FIRQ)
		FDB	NOICE_IRQ_ENT		       	; f7f8 (IRQ)
		FDB	NOICE_SWI_ENT	       		; f7fa (SWI/breakpoint)
		FDB	NOICE_NMI_ENT	       		; f7fc (NMI)
		FDB	NOICE_RESET_ENT	       		; f7fe reset

;===============================================================================
; Entry from extended vectors
;===============================================================================
; Here the stack is set up as:
;
; the following routines are entered with:
;	5+	Caller RTI signature
;	4	Extended vector addr (lo)
;	3	Extended vector addr (hi)
;	2	cur SWR#
;	1	x_return_addess_from_ROM_indirection (lo)
;	0	x_return_addess_from_ROM_indirection (hi)
; this is set up by the MOS during an extended vector redirect
; this needs to be unstacked and stack reset to point
; this has to be done in the 
; it needs to be undone to point +5 (for RTI) and the original
; ROM paged back in
; we don't need to worry about trashing registers here as the debugger
; will pick them all up from the stack at 5+

NOICE_NMI_ENTER_EXT
		lda	2,s				; original SWR
		sta	zp_mos_curROM
		sta	sheila_ROMCTL_SWR		; page back in ROM, we're now 
							; running from DEBUG MOS 
		leas	5,S				; reset stack
		jmp	[NOICE_ENTER_NMI_ENT]

NOICE_SWI_ENTER_EXT
		lda	2,s				; original SWR
		sta	zp_mos_curROM
		sta	sheila_ROMCTL_SWR		; page back in ROM, we're now 
							; running from DEBUG MOS 
		leas	5,S				; reset stack
		jmp	[NOICE_ENTER_SWI_ENT]

NOICE_RESET_ENTER_EXT
		lda	zp_mos_curROM
		pshs	A
		jsr	[NOICE_ENTER_RESET_ENT]
		puls	A
		sta	zp_mos_curROM
		sta	sheila_ROMCTL_SWR		; NoIce monitor screws with our rom #
		rts

NOICE_DIV0_ENT
NOICE_SWI3_ENT
NOICE_SWI2_ENT
NOICE_FIRQ_ENT
NOICE_IRQ_ENT
NOICE_SWI_ENT
NOICE_NMI_ENT
NOICE_RESET_ENT

		rti					; none of these should happen!


