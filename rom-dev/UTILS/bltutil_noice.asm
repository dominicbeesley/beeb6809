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


		; the following (NMI9V/SWI9V) routines are entered with the OS Vector
		; chaining data followed by the interrupt stacked registers.
		; First we must switch to NoIce memory map before calling OSEXITVEC
		; which would page back in the SWR bank in use at the point the interrupt
		; occurred
		

NoIceSys_Handle_NMI9V
		ldx	#NOICE_NMI_ENTER_EXT		; put address of NoIce entry point on stack
		pshs	X
		lda	sheila_ROMCTL_MOS
		ora	#BITS_MEM_CTL_SWMOS_DEBUG
		sta	sheila_ROMCTL_MOS		; this will enable DEBUG map _after_ the next rts
							; by which time we'll be in NoIce...
		rts					; NOT a real rts but a jump to the address we pushed

NoIceSys_Handle_SWI9V
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

mos_select_SWROM_B
		pshs	A
		lda	zp_mos_curROM
		tstb
		bmi	1F
		stb	zp_mos_curROM			;RAM copy of rom latch 
	IF MACH_SBC09
		; TODO: make this more coherent odd/even like Blitter?
		andb	#$F
		stb	SBC09_MMU0 + 2			; write mmu for 8000-BFFF
	ELSE
		stb	sheila_ROMCTL_SWR		;write to rom latch
	ENDIF
1		tfr	A,B
		puls	A,PC				;and return


mos_exit_vec
		; unwind the stack and restore registers to the point at which the vector
		; was called with the caller address as the last item on the stack
		; For interrupts this return address will be a point in the mos containing an RTI
		; which should be discarded.
		; Note: depending on where you are in the chain the other registers and flags
		; may have already been changed by claimants ahead of you. This is primarily
		; supposed to be a mechanism to unwind interrupts (SWI/NMI) to a point where
		; the stack is the same as it would be when an interrupt occurred

	; stack contains
	;	+8	original caller return address	
	;	+6	preserved U
	;	+5	preserved B
	;	+4	original rom #
	;	+2	exit routine address
	;	+0	caller

		ldb	4,S			; restore rom #
		jsr	mos_select_SWROM_B
		ldb	5,S			; restore org caller B
		ldu	6,S
		stu	4,S
		ldu	0,S
		stu	6,S
		leas	4,S
		puls	U,PC


;===============================================================================
; Entry from extended vectors
;===============================================================================
;
; The following routines are entered with the OS vector chaining data followed
; by the interrupt-time registers which we are interested in, first we must
; discard the chaining data and reload the current ROM by calling OSEXITVEC
; and discard the two dummy bytes before entering the actual debugger
;
; 
; We need intimate OS knowledge here as the OSEXITVEC function is not available
; we just paged it out!
;



NOICE_NMI_ENTER_EXT
		jsr	mos_exit_vec
		leas	2,S
		jmp	[NOICE_ENTER_NMI_ENT]

NOICE_SWI_ENTER_EXT
		jsr	mos_exit_vec
		leas	2,S
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


