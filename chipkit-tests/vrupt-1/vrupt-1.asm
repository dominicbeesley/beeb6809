		include "../../includes/hardware.inc"
		include "../../includes/common.inc"
		include "../../includes/oslib.inc"
		include "../../includes/mosrom.inc"

CRTC_SET_IMM	MACRO	; reg, val
		ldd	#(\1*256)+(\2 & 255)
		std	sheila_CRTC_reg
		ENDM

CRTC_SET_B	MACRO	; reg
		lda	#\1
		std	sheila_CRTC_reg
		ENDM



rows_main	equ	28
rows_status	equ	2

scr_addr	equ	$4800-($200*rows_status)	; bottom of screen memory (non scrolling region)
rupt_addr	equ	$4800				; main screen (hardare offset set to this)
screen_end	equ	$8000				; end of screen memory

vtot_main	equ	rows_main + 1
vtot_status	equ	39 - (vtot_main) - 1		; 39 rows total, minus vertical total main and one for the vert adjust row


zp_t2_counter		equ	$80
zp_frame_counter	equ	$81
zp_rupt_scroll_y	equ	$82
zp_rupt_scroll_y_saved	equ	$84

zp_tmp			equ	$85

		org	$2000



;;;		lda	#22
;;;		jsr	OSWRCH
;;;		lda	#1
;;;		jsr	OSWRCH				; mode 1

		SEI					; turn off interrupts, we're about to break the OS!

		ldmd	#$01				; native mode, normal FIRQs

		; fill the screen with stuff, top $1000 one pattern, bottom $4000 another
;;		ldd	#$0A50
;;		std	scr_addr
;;		ldx	#scr_addr
;;		std	x
;;		ldw	#rupt_addr-scr_addr
;;		leay	2,X
;;		tfm	X+,Y+
;;
;;		lda	#$AA
;;		ldb	#rows_main
;;
;;1		sta	,X
;;		ldw	#$200
;;		tfm	X+,Y+
;;		rola
;;		decb
;;		bne	1B

		; make a 32x32 char mode 1 (512 bytes per row)
		lda	#0
		ldx	#crtc_setup
1		ldb	A,X
		std	sheila_CRTC_reg
		inca	
		cmpa	#13
		bls	1B

		lda	#$D8
		sta	sheila_VIDULA_ctl

		; set scroll base register
		lda	#2*(rupt_addr / 256 / 16)
		sta	SHEILA_MEMC_SCROFF

		jsr	setup_irqs

;
		CLI


here		;ldb	#10
2		lda	zp_frame_counter
1		cmpa	zp_frame_counter
		beq	1B
		;decb	
		;bne	2B

		ldd	zp_rupt_scroll_y
		addd	#1
		cmpd	#224
		blo	1F
		clrd
1		std	zp_rupt_scroll_y

		bra	here



												; mode 1
crtc_setup	FCB	127				; horz total cells - 1 			127
		FCB	64				; horz displayed cells			80
		FCB	90				; horz sync				98
		FCB	$28				; sync widths (2V, 8H)			$28
		FCB	38				; vert total cells - 1			38
		FCB	0				; vert total adjust			0
		FCB	32				; vert displayed			32
		FCB	35				; vert sync				34
		FCB	$C0				; interlace: no interlace no cursor	$01
		FCB	7				; RA max				7
		FCB	$20				; cursor start(blink slow, row 0)	$67
		FCB	8				; cursor end				8
		FCB	(scr_addr/8)/256
		FCB	(scr_addr/8)%256




;=============================================================================
setup_irqs
;=============================================================================

		lda	#rti_opcode
		sta	vec_nmi				; copy RTI to &D00 to stop NMIs doing anything
		lda	#$7F 
		sta	sheila_SYSVIA_ier
		sta	sheila_SYSVIA_ifr		; disable and clear all interrupts
		sta	sheila_USRVIA_ier
		sta	sheila_USRVIA_ifr		; disable and clear all interrupts
		lda	#$04
		sta	sheila_SYSVIA_pcr		; vsync \\ CA1 negative-active-edge CA2 input-positive-active-edge CB1 negative-active-edge CB2 input-nagative-active-edge
		clr	sheila_SYSVIA_acr		; none  \\ PA latch-disable PB latch-disable SRC disabled T2 timed-interrupt T1 interrupt-t1-loaded PB7 disabled
		lda	#$0F
		sta	sheila_SYSVIA_ddrb 		; enable write to addressable latch (b0-2 addr, b3 data) and read joystick buttons (b5,b6) and speech (b6 ready, b7 interrupt)
		lda	#0+8
		sta	sheila_SYSVIA_orb		; write "disable" sound
		lda	#3+8
		sta	sheila_SYSVIA_orb		; write "disable" keyboard

		ldx	#irq_handler
		stx	IRQ1V

		lda	sheila_SYSVIA_pcr
		anda	#~$0E				;  CA2 interrupt on neg
		sta	sheila_SYSVIA_pcr
		lda	#$20				; Timer 2 pulse count
		sta	sheila_SYSVIA_acr
		lda	#2
		sta	sheila_SYSVIA_t2cl
		clr	sheila_SYSVIA_t2ch

		lda	#VIA_MASK_INT_IRQ + SYSVIA_MASK_INT_VSYNC + VIA_MASK_INT_T2
		sta	sheila_SYSVIA_ier		; enable Vsync and T2

		rts

;=============================================================================
irq_handler
;=============================================================================

		lda	sheila_SYSVIA_ifr
		bita	#VIA_MASK_INT_IRQ
		lbeq	not_sysvia
		bita	#SYSVIA_MASK_INT_VSYNC
		beq	not_vsync

	;------------------------
	; vsync
	;------------------------

		inc	zp_frame_counter

		; clear the interrupt flag
		lda	#SYSVIA_MASK_INT_VSYNC
		sta	sheila_SYSVIA_ifr

		; we've hit vsync and are about to need to get ready for the "top" half of the screen (bottom in memory)
		; prepare the CRTC regs

		; set T2 to count a few active display lines before another interrupt to set up bottom screen half
		lda	#1
		sta	sheila_SYSVIA_t2cl
		clr	sheila_SYSVIA_t2ch

		; setup CRTC registers for "top half" of ruptured screen

		ldd	zp_rupt_scroll_y_saved
		addd	#rupt_addr / 64
		rolb
		rola
		rolb
		rola
		rolb
		rola
		pshs	b		
		tfr	a,b

		CRTC_SET_B CRTCR12_Screen1stCharHi
		puls	b
		andb	#$C0
		CRTC_SET_B CRTCR13_Screen1stCharLo

		clr	zp_t2_counter

		rti

not_vsync
		bita	#VIA_MASK_INT_T2
		beq	not_t2

	;-------------------------
	; T2
	;-------------------------

		tst	zp_t2_counter
		bne	t2t2
		inc	zp_t2_counter

		lda	#rows_main*8
		sta	sheila_SYSVIA_t2cl
		clr	sheila_SYSVIA_t2ch

		CRTC_SET_IMM CRTCR6_VerticalDisplayed, rows_main
		CRTC_SET_IMM CRTCR4_VerticalTotal, vtot_main - 1
		CRTC_SET_IMM CRTCR7_VerticalSyncPosition, 255			; no vsync

		ldb	zp_rupt_scroll_y_saved + 1
		andb	#7
		CRTC_SET_B CRTCR5_VerticalTotalAdjust

		; set up start address for status bar
		CRTC_SET_IMM CRTCR12_Screen1stCharHi, (scr_addr / 8) / 256
		CRTC_SET_IMM CRTCR13_Screen1stCharLo, (scr_addr / 8) % 256

		rti
t2t2

		; setup CRTC for status bar

		CRTC_SET_IMM CRTCR6_VerticalDisplayed, rows_status
		CRTC_SET_IMM CRTCR4_VerticalTotal, vtot_status - 1
		CRTC_SET_IMM CRTCR7_VerticalSyncPosition, vtot_status - 5			; no vsync

		ldd	zp_rupt_scroll_y
		std	zp_rupt_scroll_y_saved
		comb
		andb	#7
		incb
		CRTC_SET_B CRTCR5_VerticalTotalAdjust


		; set T2 off (well big)
		lda	#$FF
		sta	sheila_SYSVIA_t2ch

		rti

not_t2
		; something's flagged on sysvia
		anda	#$7F
		sta	sheila_SYSVIA_ifr		; clear it!


not_sysvia
		lda	sheila_USRVIA_ifr
		bita	#VIA_MASK_INT_IRQ
		beq	not_user_via

		anda	#$7F
		sta	sheila_USRVIA_ifr		; clear it!

not_user_via	rti


end_code	fill	0, scr_addr - 12 - end_code
		includebin	"bbcb.mo1"

		end