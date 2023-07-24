		include "../../includes/hardware.inc"
		include "../../includes/common.inc"
		include "../../includes/mosrom.inc"
		include "../../includes/oslib.inc"
		include "./gen-version.inc"

;TODO: remove/improve all m_tay/m_tax?

DOCHIPKIT_RTC EQU 0


	IF MACH_SBC09
INCLUDE_MAIN_VDU		EQU	0
INCLUDE_CURSOR_EDIT	EQU	0
INCLUDE_SOUND		EQU	0
INCLUDE_KEYBOARD		EQU	0
	include "sbc09_uart.asm"
	ELSE
INCLUDE_MAIN_VDU		EQU	1
INCLUDE_CURSOR_EDIT	EQU	1
INCLUDE_SOUND		EQU	1
INCLUDE_KEYBOARD		EQU	1
	ENDIF

; TODO: CLC is set after mos_VDU_WRCH - check if this is necessary suspect it is just used to allow a bcc to replace bra at LE0C8
;       not sure but it may be used for tracking whether a char went to printer around the exit routine


; TODO: RESET vector is called by instruction 3E on 6809
; 	this could be used to form an illegal op
;	use 3E for NOICE debug


KEYCODE_D0_SHIFTLOCK	EQU $D0

	IF CPU_6809
m_NEGD		MACRO
		jsr	x_negation_routine_newAPI
		ENDM
	ELSE
m_NEGD		MACRO
		negd
		ENDM
	ENDIF



DEBUGPR		MACRO
		SECTION	"tables_and_strings"
1		FCB	\1,0
__STR		SET	1B
		CODE
		PSHS	X
		LEAX	__STR,PCR
		JSR	debug_printX
		JSR	debug_print_newl
		PULS	X
		ENDM

DEBUGPR2	MACRO
		SECTION	"tables_and_strings"
1		FCB	\1,0
__STR		SET	1B
		CODE
		PSHS	X
		LEAX	__STR,PCR
		JSR	debug_printX
		PULS	X
		ENDM


ASSERT		MACRO
		DEBUGPR	\1
		ORCC	#$FF
		CWAI	#$FF				; wait for NMI!
		ENDM

TODO		MACRO
		jsr	prTODO
		ASSERT	\1
		ENDM

TODOSKIP	MACRO
		DEBUGPR	\1
		ENDM

DEBUG_INFO	MACRO
		DEBUGPR \1
		ENDM


		; NOTE: MOS only runs on a 6309 and uses 6309 extra registers

		CODE
		ORG	MOSROMBASE
		setdp	MOSROMSYS_DP
		SECTION	"tables_and_strings"
		ORG	MOSSTRINGS

; set this in makefile
;;NATIVE		equ	0

		CODE
	IF INCLUDE_MAIN_VDU
		include 	"vdu_chardefs.asm"
	ENDIF
		ORG	$C300				; important!
;; ----------------------------------------------------------------------------
mos_jump2vdu_init
		jmp	mos_VDU_init			;	C300
; ----------------------------------------------------------------------------
	IF MACH_SBC09
mos_welcome_msg	FCB	$0D, "(M) Hoglet "
	ELSE
mos_welcome_msg7
		FCB	$0D, $81, "(M)", $87
mos_welcome_msg
		FCB	"Dossy "
	ENDIF
	IF MACH_CHIPKIT
		FCB	"chipkit"
	ELSIF MACH_SBC09
		FCB	"sbc09"
	ELSE
		FCB	"beeb"
	ENDIF
		FCB	"-"
	IF CPU_6309
		FCB	"6309"
	ELSE
		FCB	"6809"
	ENDIF
	IF NATIVE
		FCB	"-N"
	ENDIF	
	IF MACH_SBC09
		FCB	" 512K", $D, 0
	ELSE
		FCB	" 1056K", $D, 0
	ENDIF
mos_version7
		FCB	"     "
mos_version
		MOSVERSIONSTR
		FCB	$07, $00
		FCB	$08,$0D,$0D			;	C31A
; ----------------------------------------------------------------------------
	IF INCLUDE_MAIN_VDU
		
		include "vdu_main.asm"
	ELSIF MACH_SBC09
		include "sbc09_vdu_uart.asm"
	ENDIF	; INCLUDE_MAIN_VDU

prTODO
		DEBUGPR2	"TODO HALT: ", 1
		rts

vec_table
		;TODO = fill these in!
		FDB	brkBadCommand			;  LD940 USERV
		FDB	mos_DEFAULT_BRK_HANDLER		;  LD942 BRKV
		FDB	mos_IRQ1V_default_entry		;  LD944 IRQ1V
		FDB	mos_IRQ2V_default_entry		;  LD946 IRQ2V
		FDB	mos_CLIV_default_handler	;  LD948 CLIV
		FDB	mos_default_BYTEV_handler	;  LD94A BYTEV
		FDB	mos_WORDV_default_entry		;  LD94C WORDV
		FDB	mos_WRCH_default_entry		;  LD94E WRCHV
		FDB	mos_RDCHV_default_entry		;  LD950 RDCHV
		FDB	dummy_vector_RTS		;  LD952 FILEV
		FDB	mos_OSARGS			;  LD954 ARGSV
		FDB	dummy_vector_RTS		;  LD956 BGETV
		FDB	dummy_vector_RTS 		;  LD958 BPUTV
		FDB	dummy_vector_RTS		;  LD95A GBPBV
		FDB	mos_FINDV_default_handler	;  LD95C FINDV
		FDB	mos_FSCV_default_handler	;  LD95E FSCV
		FDB	dummy_vector_RTS		;  LD960 EVNTV
		FDB	dummy_vector_RTS		;  LD962 UPTV
		FDB	dummy_vector_RTS		;  LD964 NETV
		FDB	dummy_vector_RTS		;  LD966 VDUV
		FDB	KEYV_default			;  LD968 KEYV
		FDB	mos_INSV_default_entry_point	;  LD96A INSV
		FDB	mos_REMV_default_entry_point	;  LD96C REMV
		FDB	mos_CNPV_default_entry_point	;  LD96E CNPV
		FDB	dummy_vector_RTI		;  LD970 SWI9V
	IF CPU_6309
		FDB	mos_default_illegalop		;  LD972 ILOPV
	ELSE
		FDB	dummy_vector_RTI		;  LD972 ILOPV
	ENDIF
		FDB	dummy_vector_RTI		;  LD974 NMIV
vec_table_end
;	FDB	brkBadCommand			;  LD940 USERV
;	FDB	mos_DEFAULT_BRK_HANDLER			;  LD942 BRKV
;	FDB	mos_IRQ1V_default_entry			;  LD944 IRQ1V
;	FDB	mos_IRQ2V_default_entry			;  LD946 IRQ2V
;	FDB	mos_default_CLIV_handler		;  LD948 CLIV
;	FDB	mos_default_BYTEV_handler		;  LD94A BYTEV
;	FDB	mos_WORDV_default_entry			;  LD94C WORDV
;	FDB	mos_WRCH_default_entry			;  LD94E WRCHV
;	FDB	mos_RDCHV_default_entry			;  LD950 RDCHV
;	FDB	mos_OSFILE_ENTRY			;  LD952 FILEV
;	FDB	mos_OSARGS		;  LD954 ARGSV
;	FDB	mos_OSBGET_get_a_byte_from_a_file	;  LD956 BGETV
;	FDB	mos_OSBPUT_WRITE_A_BYTE_TO_FILE 	;  LD958 BPUTV
;	FDB	dummy_vector_RTS			;  LD95A GBPBV
;	FDB	mos_FINDV_default_handler			;  LD95C FINDV
;	FDB	mos_FSCV_default_handler		;  LD95E FSCV
;	FDB	dummy_vector_RTS			;  LD960 EVNTV
;	FDB	dummy_vector_RTS			;  LD962 UPTV
;	FDB	dummy_vector_RTS			;  LD964 NETV
;	FDB	dummy_vector_RTS			;  LD966 VDUV
;	FDB	KEYV_default 	;  LD968 KEYV
;	FDB	mos_INSV_default_entry_point		;  LD96A INSV
;	FDB	mos_REMV_default_entry_point		;  LD96C REMV
;	FDB	mos_CNPV_default_entry_point	;  LD96E CNPV
;	FDB	dummy_vector_RTS			;  LD970 IND1V
;	FDB	dummy_vector_RTS			;  LD972 IND2V
;	FDB	dummy_vector_RTS			;  LD974 IND3V



;; ----------------------------------------------------------------------------
;; MOS VARIABLES DEFAULT SETTINGS
mostbl_SYSVAR_DEFAULT_SETTINGS				; LD976
		FDB	sysvar_OSVARADDR - $A6			; A6 default osvar base (minus A6 for osbyte offset)
		FDB	EXT_USERV				; A8 default start of extended vector table
		FDB	oswksp_ROMTYPE_TAB			; AA default start of rom info table
		FDB	key2ascii_tab - $10			; AC default start of keyboard to ASCII table
		
		FDB	vduvars_start				; AE base of VDU variables
		FCB	$00					; B0 CFS timeout
		FCB	$00					; B1 input source number (keyboard=0/serial=1/etc)
		FCB	$FF					; B2 keyboard semaphore
		FCB	$00					; B3 primary OSHWM for exploded font
		FCB	$00					; B4  B4 OSHWM
		FCB	$01 					; B5 Serial mode
		
		FCB	$00					; B6 char def exploded state
		FCB	$00					; B7 cassette/rom switch
		FCB	$00					; B8 video ULA copy (CTL)
		FCB	$00					; B9 video ULA copy (PAL?)
		FCB	$00					; BA ROM number active at BREAK
		FCB	$FF					; BB BASIC ROM number
		FCB	$04					; BC ADC channel
		FCB	$04					; BD Max ADC channel

		FCB	$00					; BE ADC conv type
		FCB	$FF					; BF RS423 use flag
		FCB	$56					; C0 RS423 ctl flag
		FCB	$19					; C1 flash counter
		FCB	$19					; C2 flash mark
		FCB	$19					; C3 flash space
		FCB	$32					; C4 keyboard autorepeat delay
		FCB	$08					; C5 keyboard autorepeat rate

		FCB	$00					; C6 *EXEC handle
		FCB	$00					; C7 *SPOOL handle
		FCB	$00					; C8 ESCAPE effect
		FCB	$00					; C9 keyboard disable
		FCB	$20					; CA keyboard status
		FCB	$09					; CB Serial handshake extent
		FCB	$00					; CC Serial suppression flag
		FCB	$00					; CD Serial/cassette select flag


		FCB	$00					; CE Econet OS Call intercept status
		FCB	$00					; CF Econet read char intercept status
		FCB	$00					; D0 Econet write char intercept status
		FCB	$50					; D1 Speech suppress $50=speak
		FCB	$00					; D2 Sound suppress
		FCB	$03					; D3 Bell channel
		FCB	$90					; D4 Bell vol, H, S
		FCB	$64					; D5 Bell freq

		FCB	$06					; D6 Bell duration
		FCB	$81					; D7 Startup message suppress/!BOOT lock
		FCB	$00					; D8 Soft key string
		FCB	$00					; D9 lines since page
		FCB	$00					; DA VDU Q len
		FCB	$09					; DB TAB char
		FCB	$1B					; DC ESCAPE char
		FCB	$01					; DD Input buffer C0-CF interpretation

		FCB	$D0					; DE Input buffer D0-DF interpretation
		FCB	$E0					; DF Input buffer E0-EF interpretation
		FCB	$F0					; E0 Input buffer F0-FF interpretation
		FCB	$01					; E1 fnKey status 80-8F
		FCB	$80					; E2 fnKey status 90-9F
		FCB	$90					; E3 fnKey status A0-AF
		FCB	$00					; E4 fnKey status B0-BF
		FCB	$00					; E5 ESCAPE key action

		FCB	$00					; E6 ESCAPE effects
		FCB	$FF					; E7 IRQ mask for user VIA
		FCB	$FF					; E8 IRQ mask for 6850 
		FCB	$FF					; E9 IRQ mask for system VIA
		FCB	$00					; EA TUBE flag
		FCB	$00					; EB Speech flag
		FCB	$00					; EC char dest status
		FCB	$00					; ED cursor edit status
		
		FCB	$00					; EE location 27E (keypad numeric base Master)
		FCB	$00					; EF location 27F (?)
		FCB	$00					; F0 location 280 (Country code)
		FCB	$00					; F1 location 281 (user flag)
		;TODO this default changed to 9,600 baud
		FCB	$64					; F2 Serial ULA copy - original
;;	IF MACH_BEEB && NOICE
;;		FCB	$40					; F2 Serial ULA copy - 19200 for noice
;;	ELSE
;;		FCB	$52					; F2 Serial ULA copy - 4,800 for HOSTFS
;;	ENDIF
		FCB	$05					; F3 Timer switch state
		FCB	$FF					; F4 Soft key consistency
		FCB	$01					; F5 Printer dest

		FCB	$0A					; Printer ignore
		FCB	$00					; break vector jmp
		FCB	$00					; break vector hi
		FCB	$00					; break vectro lo
		FCB	$00
		FCB	$00
		FCB	$FF					;	D9C6


	IF CPU_6309
 **************************************************************************
 * 6309 div0/illegal op trap
 **************************************************************************
mos_handle_div0
		bitmd	#$40
		bne	mos_handle_illegalop

		DO_BRK	$FF, "Divide by 0", 0
mos_handle_illegalop
		jmp	[ILOPV]
mos_default_illegalop		
		DO_BRK	$FF, "Illegal instruction", 0		
	ENDIF

 **************************************************************************
 **************************************************************************
 **                                                                      **
 **                                                                      **
 **      RESET (BREAK) ENTRY POINT                                       **
 **                                                                      **
 **      Power up Enter with nothing set, 6522 System VIA IER bits       **
 **      0 to 6 will be clear                                            **
 **                                                                      **
 **      BREAK IER bits 0 to 6 one or more will be set 6522 IER          **
 **      not reset by BREAK                                              **
 **                                                                      **
 **************************************************************************
 ************************************************************************** 

;; ----------------------------------------------------------------------------
mos_handle_res
	IF MACH_SBC09
		ldb	#1				; default to the MOS being mapped in slot #1 if reset vector called
mos_handle_boot_menu
	ENDIF
		lda	#$3B				; rti instruction ( was $40 for 6502)
; Store RTI in 1st byte of NMI space
		sta	vec_nmi				; store rti at start of NMI space
		SEI					; turn of interrupts in case
		lds	#STACKTOP			; this is different to 6502, setup system stack at PAGE 1
		lda	#MOSROMSYS_DP			; and DP at PAGE 0
		tfr	a,dp

	IF NATIVE
		; ENTER NATIVE MODE
		LDMD	#1
	ENDIF

	IF MACH_CHIPKIT
		lda	sheila_ROMCTL_RAM		; if bit 7 set this is a cold reset
		clr	sheila_ROMCTL_RAM		; clear and set RAM to bank 0
		pshs	a				;save what's left
		tsta
		bmi	mos_handle_res_skip_clear_mem1	;if Power up A bit 7 == 1 
	ELSIF MACH_BEEB
		lda	sheila_SYSVIA_ier
		asla
		pshs	a
		beq	mos_handle_res_skip_clear_mem1	; it's a power up
	ELSIF MACH_SBC09

		SBC09_INIT				; initialize UART and MMU

		; TODO: SBC09: what to do about CTRL/BREAK - look at 68C681, is there a way to detect power up vs reset?
		clr	A
		pshs	A
		jmp	mos_handle_res_skip_clear_mem1
	ENDIF
		lda	sysvar_BREAK_EFFECT		;else if BREAK pressed read BREAK Action flags (set by
							;*FX200,n) 
		lsra					;divide by 2
		cmpa	#$01				;if (bit 1 not set by *FX200)
		bne	mos_handle_res_skip_clear_mem2	;then &DA03
		lsra					;divide A by 2 again (A=0 if *FX200,2/3 else A=n/4


; Always clear memory if no sys via interrupts enabled i.e. hard RES
mos_handle_res_skip_clear_mem1

	IF CPU_6809
		clra
		ldy	#$8000-$400
		ldx	#$400
1		sta	,X+
		leay	-1,Y
		bne	1B
	ELSE
		clr	$400
		ldx	#$400
		ldy	#$401
		ldw	#$8000-$401
		tfm	X,Y+
	ENDIF

1		lda	#$80
		sta	sysvar_RAM_AVAIL
		sta	sysvar_KEYB_SOFT_CONSISTANCY

;; Don't clear memory if clear memory flag not set
mos_handle_res_skip_clear_mem2
	IF MACH_BEEB | MACH_CHIPKIT
	IF MACH_BEEB
		ldb	#$0F				;	DA03
	ELSIF MACH_CHIPKIT
		ldb	#$8F				;	DA03
	ENDIF
		stb	sheila_SYSVIA_ddrb		;	DA05


 *************************************************************************
 *                                                                       *
 *        set addressable latch IC 32 for peripherals via PORT B         *
 *                                                                       *
 *       ;bit 3 set sets addressed latch high adds 8 to VIA address      *
 *       ;bit 3 reset sets addressed latch low                           *
 *                                                                       *
 *       Peripheral              VIA bit 3=0             VIA bit 3=1     *
 *                                                                       *
 *       Sound chip              Enabled                 Disabled        *
 *       speech chip (RS)        Low                     High            *
 *       speech chip (WS)        Low                     High            *
 *       Keyboard Auto Scan      Disabled                Enabled         *
 *       C0 address modifier     Low                     High            * NOTE: Not used on 6809
 *       C1 address modifier     Low                     High            * NOTE: Not used on 6809
 *       Caps lock  LED          ON                      OFF             *
 *       Shift lock LED          ON                      OFF             *
 *                                                                       *
 *       C0 & C1 are involved with hardware scroll screen address        * NOTE: Not used on 6809
 *************************************************************************
							;B=&F on entry
1		decb						;loop start
		stb	sheila_SYSVIA_orb			;Write latch IC32
		cmpb	#$09					;Is it 9?
		bhs	1B					;If not go back and do it again
							;B=8 at this point
							;Caps Lock On, SHIFT Lock undetermined
							;Keyboard Autoscan on
							;Sound disabled (may still sound)
	ENDIF ; MACH_BEEB|MACH_CHIPKIT
		clr	sysvar_BREAK_LAST_TYPE			;Clear last BREAK flag
	IF MACH_BEEB | MACH_CHIPKIT	
		incb						;B=9
LDA11		tfr	b,a					;A=B
		jsr	keyb_check_key_code_API			;Interrogate keyboard
;	cmpb	#$80					; - change this as was reversing C
		addb	#$80					; - TODO: check works!
							;for keyboard links 9-2 and CTRL key (1)
		ror	zp_mos_INT_A				;rotate MSB into bit 7 of &FC
		tfr	a,b					;Get back value of X for loop
		decb						;Decrement it
		bne	LDA11					;and if >0 do loop again
							;On exit if Carry set link 3 is made
							;link 2 = bit 0 of &FC and so on
							;If CTRL pressed bit 7 of &FC=1 X=0
		rol	zp_mos_INT_A				;CTRL is now in carry &FC is keyboard links	
		jsr	x_Turn_on_Keyboard_indicators		;Set LEDs
							;Carry set on entry is in bit 0 of A on exit
		rora						;Get carry back into carry flag
	ELSE
		clr	zp_mos_INT_A		; TODO: SBC09: not sure what to put in flags here
	ENDIF ; MACH_BEEB|MACH_CHIPKIT
x_set_up_page_2
		ldx	#$9C					;
		ldy	#$8D					;
;;	puls	A					;get back A from &D9DB
;;	tsta
;;	beq	LDA36					;if A=0 power up reset so DA36 with X=&9C Y=&8D
		tst	,S+
	IF MACH_CHIPKIT
		bmi	1F
	ENDIF
	IF MACH_BEEB
		beq	1F
	ENDIF
		ldy	#$7E					;else Y=&7E
		bcc	x_set_up_page_2_2			;and if not CTRL-BREAK DA42 WARM RESET
		ldy	#$87					;else Y=&87 COLD RESET
		inc	sysvar_BREAK_LAST_TYPE			;&28D=1
1		inc	sysvar_BREAK_LAST_TYPE			;&28D=&28D+1
		lda	zp_mos_INT_A				;get keyboard links set
		eora	#$FF					;invert
		sta	sysvar_STARTUP_OPT			;and store at &28F
		ldx	#$90					;X=&90
		

		DEBUG_INFO	"Setup page 2"

;; : set up page 2; on entry	   &28D=0 Warm reset, X=&9C, Y=&7E ; &28D=1 Power up  , X=&90, Y=&8D ; &28D=2 Cold reset, X=&9C, Y=&87 
x_set_up_page_2_2
		clra
x_setup_pg2_lp0	
		cmpx	#$CE					;zero &200+X to &2CD
		blo	x_setup_pg2_sk1				;	DA46
		lda	#$FF					;then set &2CE to &2FF to &FF
x_setup_pg2_sk1
		sta	$200,x					;LDA4A
		leax	1,x
		cmpx	#$100
		bne	x_setup_pg2_lp0			;	DA4E
	IF MACH_BEEB | MACH_CHIPKIT
		sta	sheila_USRVIA_ddra		;	DA50
	ENDIF ; MACH_BEEB|MACH_CHIPKIT

		DEBUG_INFO	"Setup zp"
		ldx	#zp_cfs_w
LDA56		clr	,x+					;zero zeropage &E2 to &FF
		cmpx	#$100
		bne	LDA56				;	DA59

		DEBUG_INFO	"Setup vectors"

		

LDA5B		lda	vec_table - 1,y			;	DA5B
		sta	USERV - 1,y			;	DA5E
		leay	-1,y				;	DA61
		bne	LDA5B				;	DA62
		lda	#$62				;	DA64
		sta	zp_mos_keynumfirst		;	DA66
		
	IF MACH_BEEB
	;; TODO: Reinstate / check / fix - was buggering up debugging
;;		jsr	ACIA_reset_from_CTL_COPY				; reset ACIA
	ENDIF

	IF MACH_BEEB | MACH_CHIPKIT
		DEBUG_INFO "Setup vias"

; clear interrupt and enable registers of Both VIAs
x_clear_IFR_IER_VIAs
		ldd	#$7F7F
		std	sheila_SYSVIA_ifr			; disable and clear interrupts on system
		std	sheila_USRVIA_ifr			; and user vias
	;; DB 20180223 - removed this as *legacy*
;;;		clr	-2,S					; clear the stack
;;;		CLI						; briefly allow interrupts to clear anything pending
;;;		SEI						; disallow again N.B. All VIA IRQs are disabled
;;;;;	lda	#$40
;;;;;	bita	zp_mos_INT_A				; if bit 6=1 then JSR &F055 (normally 0) 
;;;		tst	-2,S					; if this is set then an interrupt occurred
;;;		beq	LDA80					; else DA80
;;;		jsr	[$FDFE]					; if IRQ held low at BREAK then jump to address held in
;;;							; FDFE (JIM) 
;;;LDA80		
		lda	#$F2					;enable interrupts 1,4,5,6 of system VIA
		sta	sheila_SYSVIA_ier			;
							;0      Keyboard enabled as needed
							;1      Frame sync pulse
							;4      End of A/D conversion
							;5      T2 counter (for speech)
							;6      T1 counter (10 mSec intervals)
							;
		lda	#$04					;set system VIA PCR
		sta	sheila_SYSVIA_pcr			;
							;CA1 to interrupt on negative edge (Frame sync)
							;CA2 input pos edge Keyboard
							;CB1 interrupt on negative edge (end of conversion)
							;CB2 Negative edge (Light pen strobe)
		lda	#$60					;                       
		sta	sheila_SYSVIA_acr			;set system VIA ACR
							;disable latching
							;disable shift register
							;T1 counter continuous interrupts
							;T2 counter timed interrupt
		lda	#$0E					;set system VIA T1 counter (Low)
		sta	sheila_SYSVIA_t1ll			;this becomes effective when T1 hi set

		sta	sheila_USRVIA_pcr			;set user VIA PCR
							;CA1 interrupt on -ve edge (Printer Acknowledge)
							;CA2 High output (printer strobe)
							;CB1 Interrupt on -ve edge (user port) 
							;CB2 Negative edge (user port)
;TODO ADC
;;	sta	LFEC0					;set up A/D converter
							;Bits 0 & 1 determine channel selected
							;Bit 3=0 8 bit conversion bit 3=1 12 bit

		cmpa	sheila_USRVIA_pcr		;read user VIA IER if = &0E then DAA2 chip present 
		beq	LDAA2				;so goto DAA2
		inc	sysvar_USERVIA_IRQ_MASK_CPY	;else increment user VIA mask to 0 to bar all 
							;user VIA interrupts

LDAA2		lda	#$27				;set T1 (hi) to &27 this sets T1 to &270E (9998 uS)
		sta	sheila_SYSVIA_t1lh		;or 10msec, interrupts occur every 10msec therefore
		sta	sheila_SYSVIA_t1ch		;

		DEBUG_INFO	"snd_init"

		jsr	snd_init			;clear the sound channels

		lda	sysvar_SERPROC_CTL_CPY		;read serial ULA control register
		anda	#$7F				;zero bit 7
		jsr	setSerULA			;and set up serial ULA

	ENDIF ; MACH_BEEB | MACH_CHIPKIT

		tst	sysvar_KEYB_SOFT_CONSISTANCY	;get soft key status flag
		beq	mos_cat_swroms			;if 0 (keys OK) then DABD
		jsr	mos_OSBYTE_18			;else reset function keys

mos_cat_swroms
		DEBUG_INFO	"catalogue ROMs"
		clrb
; Check sideways ROMS and make catalogue; X=0 
mos_cat_swroms_lp
		jsr	mos_select_SWROM_B		;set up ROM latch and RAM copy to B
		ldy	#copyright_symbol_backwards+4	;set X to point to offset in table
		ldb	$8007				;get copyright offset from ROM
							; DF0C = )C( BRK
		ldx	#$8000
		abx					; X now points at 0 byte before (C) if a rom
		ldb	#4
1		lda	,x+				;get first byte
		cmpa	,-y				;compare it with table byte
		bne	mos_cat_swroms_skipnotrom	;if not the same then goto DAFB
		decb					;(s)
		bne	1B				;and if still +ve go back to check next byte
;; there are no matches, if a match found ignore lower priority ROM ???CHECK???

		ldb	zp_mos_curROM			;get RAM copy of ROM No. in B
mos_cat_swroms_cmplp_nexthighter			; LDAD5
		incb					;increment B to check 
		cmpb	#$10				;if ROM 15 is current ROM
		bhs	mos_cat_swroms_skipvalid	;if equal or more than 16 goto &DAFF
							;to store catalogue byte
		ldx	#$8000
mos_cat_swroms_cmplp
		; swapped sense here from 6502
		jsr	mos_select_SWROM_B		; swap to higher rom, B contains lower rom
		lda	,x				;Get byte 
		jsr	mos_select_SWROM_B		;switch back again to lower B contains higher rom
		cmpa	,x+				;and compare with previous byte called
		bne	mos_cat_swroms_cmplp_nexthighter;if not the same then go back and do it again
							;with next rom up
		cmpx	#$C000				;&84 (all 16k checked) DB: Note OS1.2 only compares first 1K TODO: put this back to 1K?
		blo	mos_cat_swroms_cmplp		;then check next byte(s)
mos_cat_swroms_skipnotrom			; LDAFB
		bra	mos_cat_swroms_skipnext		;always &DB0C

mos_cat_swroms_skipvalid				; LDAFF	
		; we should now be pointing at current i.e. lower ROM
		lda	$8006				;get rom type
		ldx	#oswksp_ROMTYPE_TAB
		ldb	zp_mos_curROM
		sta	B,X				;store it in catalogue
		anda	#$8F				;check for BASIC (bit 7 not set)
		bne	mos_cat_swroms_skipnext		;if not BASIC the DB0C
		stb	sysvar_ROMNO_BASIC		;else store X at BASIC pointer
mos_cat_swroms_skipnext					;LDB0C
		ldb	zp_mos_curROM
		incb					;increment X to point to next ROM
		cmpb 	#$10				;is it 15 or less
		blo	mos_cat_swroms_lp		;if so goto &DABD for next ROM

;TODO - Speech
;; Check SPEECH System; X=&10 
;mos_Check_SPEECH_System:
;	bit	sheila_SYSVIA_orb		;	DB11
;	bmi	x_SCREEN_SET_UP			;	DB14
;	dec	sysvar_SPEECH_PRESENT		;	DB16
;LDB19:	ldy	#$FF				;	DB19
;	jsr	mos_OSBYTE_159			;	DB1B
;	dex					;	DB1E
;	bne	LDB19				;	DB1F
;	stx	sheila_SYSVIA_t2cl		;	DB21
;	stx	sheila_SYSVIA_t2ch		;	DB24

		* TODO: DOM - force non interlace mode
		lda	#1
		sta	oswksp_VDU_INTERLACE


; SCREEN SET UP; X=0 
x_SCREEN_SET_UP
		DEBUG_INFO "x_SCREEN_SET_UP"
		lda	sysvar_STARTUP_OPT			;get back start up options (mode)
		jsr	mos_jump2vdu_init			;then jump to screen initialisation
		ldy	#$CA					;Y=&CA
		jsr	x_INSERT_byte_in_Keyboard_buffer	;to enter this in keyboard buffer
							;this enables the *KEY 10 facility
;; enter BREAK intercept with Carry Clear
;TODO - ROMS
;TODO - TUBE
		jsr	mos_OSBYTE_247
;TODO - cassette
;		jsr	x_set_cassette_options		;	DB35

;TODO - TUBE
;	lda	#$81				;	DB38
;	sta	LFEE0				;	DB3A
;	lda	LFEE0				;	DB3D
;	ror	a				;	DB40
;	bcc	LDB4D				;	DB41
;	ldBBB	#$FF				;	DB43
;	jsr	mos_OSBYTE_143_b_cmd_x_param;	DB45
;	bne	LDB4D				;	DB48
;	dec	sysvar_TUBE_PRESENT		;	DB4A
;LDB4D:	
		ldx	#$0E				;	DB4D
		ldb	#SERVICE_1_ABSWKSP_REQ		;	DB4F
		jsr	mos_OSBYTE_143_b_cmd_x_param	;	DB51
		ldb	#SERVICE_2_RELWKSP_REQ		;	DB54
		jsr	mos_OSBYTE_143_b_cmd_x_param	;	DB56
		tfr	X,D
		stb	sysvar_PRI_OSHWM
		stb	sysvar_CUR_OSHWM			
;	ldBBB	#$FE				;	DB5F
;	ldy	sysvar_TUBE_PRESENT		;	DB61
;	jsr	mos_OSBYTE_143_b_cmd_x_param	;	DB64
;	and	sysvar_STARTUP_DISPOPT		;	DB67
;	bpl	LDB87				;	DB6A

		jsr	printWelcome1

	IF MACH_CHIPKIT
		; TODO REMOVE THIS
		jsr	mos_PRTEXT
		fcb	"MOS=",0
		lda	sheila_ROMCTL_MOS
		jsr	PRHEX
		jsr	OSNEWL
		jsr	OSNEWL
	ENDIF


		; TODO - work out memory size and print if a hard reset

LDB87
		SEC
		jsr	mos_OSBYTE_247			;look for break intercept jump do *TV etc
		jsr	mos_OSBYTE_118			;set up LEDs in accordance with keyboard status



;TODO - ROMS
		; changed from 6502 -> 6809 sign flag is in bit 3
		tfr	CC,B				; B now contains bit 1=shift
		aslb
		aslb					; get it into bit 3
		eorb	sysvar_STARTUP_OPT		;or with start up options which may or may not
		andb	#$08				;invert bit 3
		clra
		tfr	D,X				; set Y=0 for !BOOT or =8 for no boot
		ldb	#SERVICE_3_AUTOBOOT
		jsr	mos_OSBYTE_143_b_cmd_x_param	; pass round to FS ROMS
;	beq	x_Preserve_current_language_on_soft_RESET;	DB9F
;	tya					;	DBA1
;	bne	x_resettapespeed_enter_lang	;	DBA2
;	lda	#$8D				;	DBA4
;	jsr	mos_selects_ROM_filing_system	;	DBA6
		;;; strSTARRUNPLINGBOOT!!!!
;	ldx	#$D2				;	DBA9
;	ldy	#$EA				;	DBAB
;	dec	sysvar_STARTUP_DISPOPT		;	DBAD
;	jsr	OSCLI				;	DBB0
;	inc	sysvar_STARTUP_DISPOPT		;	DBB3
;	bne	x_Preserve_current_language_on_soft_RESET;	DBB6
x_resettapespeed_enter_lang
;	lda	#$00				;	DBB8
;	tax					;	DBBA
;	jsr	LF137				;	DBBB
;; Preserve current language on soft RESET
;x_Preserve_current_language_on_soft_RESET:
;	lda	sysvar_BREAK_LAST_TYPE		;	DBBE
;	bne	mos_SEARCH_FOR_LANGUAGE_TO_ENTER_Highest_priority;	DBC1
;	ldx	sysvar_CUR_LANG			;	DBC3
;	bpl	LDBE6				;	DBC6
;; SEARCH FOR LANGUAGE TO ENTER (Highest priority)
mos_SEARCH_FOR_LANGUAGE_TO_ENTER_Highest_priority
		ldb	#$0F				;set pointer to highest available rom
		ldx	#oswksp_ROMTYPE_TAB+$10
1							;LDBCA
		lda	,-x				;get rom type from map
		rola					;put hi-bit into carry, bit 6 into bit 7
		bmi	mos_lang_found			;if bit 7 set then ROM has a language entry so DBE6
		decb					;else search for language until B=&ff
		bpl	1B				;
;; check if tube present
;x_check_if_tube_present:
;	lda	#$00				;	DBD3
;	bit	sysvar_TUBE_PRESENT		;	DBD5
;	bmi	mos_TUBE_FOUND_enter_tube_software;	DBD8
;; no language error
x_no_language_error
		DO_BRK	$F9, "Language?"


x_mos_ENTER_ROM_X
		tfr	X,D				; get X low into B
		bra	x_mos_ENTER_ROM_B
mos_lang_found						; LDBE6
		CLC					;	DBE6
;;B=rom number C set if OSBYTE call clear if initialisation
x_mos_ENTER_ROM_B
		pshs	CC				;save flags
		stb	sysvar_CUR_LANG			;put X in current ROM page
		jsr	mos_select_SWROM_B		;select that ROM
		ldy	#$8009				;Y=8
		jsr	printAtY			;display text string held in ROM at &8009
		leay	-1,Y				;DB, printaty used to return with Y pointing at 0, not 1 place after
		sty	zp_mos_error_ptr		;save Y on exit (end of language string)
		jsr	OSNEWL				;two line feeds
		jsr	OSNEWL				;are output
		puls	CC				;then get back flags
		lda	#$01				;A=1 required for language entry
		; TODO TUBE
;		bit	sysvar_TUBE_PRESENT		;check if tube exists
;		bmi	mos_TUBE_FOUND_enter_tube_software;and goto DC08 if it does
		jmp	$8000				;else enter language at &8000

;; ----------------------------------------------------------------------------
;; TUBE FOUND enter tube software
mos_TUBE_FOUND_enter_tube_software
		TODO	"TUBE"
;	jmp	L0400				;	DC08

mos_OSRDRM
		pshs 	B
		tfr	Y,D
		lda	zp_mos_curROM
		sta	,-S
		jsr	mos_select_SWROM_B
		lda	,X
		ldb	,S+
		jsr	mos_select_SWROM_B
		puls	B,PC
;mos_select_SWROM_X:
mos_select_SWROM_B
		pshs	A
		lda	zp_mos_curROM
		stb	zp_mos_curROM			;RAM copy of rom latch 
	IF MACH_SBC09
		; TODO: make this more coherent odd/even like Blitter?
		andb	#$F
		stb	SBC09_MMU0 + 2			; write mmu for 8000-BFFF
	ELSE
		stb	sheila_ROMCTL_SWR		;write to rom latch
	ENDIF
		tfr	A,B
		puls	A,PC				;and return
;; ----------------------------------------------------------------------------
mos_handle_irq
		jmp	[IRQ1V]				;	DC24

mos_handle_nmi	
		jmp	[NMI9V]
mos_handle_swi
		jmp	[SWI9V]
mos_handle_swi2
		rti
;; ----------------------------------------------------------------------------
;; BRK handling routine	- TODO: test for native mode!
mos_handle_swi3
		pshs	CC,D,X
		SEI						; disable interrupts - 6809 doesn't do that for us!
	IF NATIVE
		ldx	17,S
	ELSE
		ldx	15,S					; points at byte after SWI instruction
	ENDIF
		stx	zp_mos_error_ptr
		stx	3,S					; set X on return to this

		lda	zp_mos_curROM				; get currently active ROM
		sta	sysvar_ROMNO_ATBREAK			; and store it in &24A
		stx	zp_mos_OSBW_X				; store stack pointer in &F0
		ldb	#SERVICE_6_BRK				; and issue ROM service call 6
		jsr	mos_OSBYTE_143_b_cmd_x_param		; (User BRK) to roms
								; at this point &FD/E point to byte after BRK
								; ROMS may use BRK for their own purposes 
		ldb	sysvar_CUR_LANG				; get current language
		jsr	mos_select_SWROM_B			; and activate it
		puls	CC,D,X					; restore A,X,CC
		CLI						; allow interrupts
		jmp	[BRKV]					; and JUMP via BRKV (normally into current language)
;; ----------------------------------------------------------------------------
;; DEFAULT BRK HANDLER
mos_DEFAULT_BRK_HANDLER

		DEBUG_INFO "mos_DEFAULT_BRK_HANDLER"

		ldy	zp_mos_error_ptr
		leay	1,Y
		jsr	printAtY				;print message - including error number - TODO - is this right?
		lda	sysvar_STARTUP_DISPOPT			;if BIT 0 set and DISC EXEC error
		rora						;occurs
LDC5D		bcs	LDC5D					;hang up machine!!!!
		jsr	OSNEWL					;else print two newlines
		jsr	OSNEWL					;
		jmp	x_resettapespeed_enter_lang		;and set tape speed before entering current
							;language 
;; ----------------------------------------------------------------------------
;LDC68:	sec					;	DC68
;	ror	sysvar_RS423_USEFLAG		;	DC69
;	bit	sysvar_RS423_CTL_COPY		;	DC6C
;	bpl	LDC78				;	DC6F
;	jsr	x_check_RS423_input_buffer	;	DC71
;	ldx	#$00				;	DC74
;	bcs	LDC7A				;	DC76
;LDC78:	ldx	#$40				;	DC78
;LDC7A:	jmp	LE17A				;	DC7A
;; ----------------------------------------------------------------------------
;LDC7D:	ldy	LFE09				;	DC7D
;	and	#$3A				;	DC80
;	bne	LDCB8				;	DC82
;	ldx	sysvar_RS423_SUPPRESS		;	DC84
;	bne	LDC92				;	DC87
;	inx					;	DC89
;	jsr	mos_OSBYTE_153			;	DC8A
;	jsr	x_check_RS423_input_buffer	;	DC8D
;	bcc	LDC78				;	DC90
;LDC92:	rts					;	DC92
;; ----------------------------------------------------------------------------
;; Main IRQ Handling routines, default IRQIV destination
mos_IRQ1V_default_entry				; LDC93
	IF MACH_BEEB | MACH_CHIPKIT
		include "irq1_main.asm"
	ELSIF MACH_SBC09
		include "sbc09_irq1.asm"
	ENDIF
;; ----------------------------------------------------------------------------
;; IRQ2V default entry
mos_IRQ2V_default_entry
		rti					;	DE8B

*************************************************************************
*                                                                       *
*       OSBYTE 17 Start conversion                                      *
*                                                                       *
*************************************************************************

mos_OSBYTE_17						; LDE8C
		clr	adc_CH_LAST			;set last channel to finish conversion - DB: check should this be 0?
LDE8F		;;m_txb
		cmpb	#$05				;if X<4 then
		blo	1F				;DE95
		ldb	#$04				;else X=4
1		stb	sysvar_ADC_CUR			;store it as current ADC channel
		m_tbx
		ldb	sysvar_ADC_ACCURACY		;get conversion type
		decb					;decrement
		andb	#$08				;and it with 08
		addb	sysvar_ADC_CUR			;add to current ADC
		decb					;-1
		TODO "ADC"
		;;sta	LFEC0				;store to the A/D control panel
		rts					;and return
						;
;; ----------------------------------------------------------------------------
printWelcome1
	IF MACH_BEEB | MACH_CHIPKIT
		lda	vduvar_MODE
		beq	printWelcomeMO0
		cmpa	#7
		beq	printWelcomeMO7
		cmpa	#6
		beq	printWelcomeMO36
		cmpa	#3
		beq	printWelcomeMO36
		ldx	#mc_logo
		jsr	render_logox2
		ldy	#mos_welcome_msg
		jsr	printAtY
		ldx	#mc_logo  + 16
		jsr	render_logox2
		bra	1F
printWelcomeMO0
		ldx	#mc_logo_0
		jsr	render_logox4
		ldy	#mos_welcome_msg
		jsr	printAtY
		ldx	#mc_logo_0  + 32
		jsr	render_logox4
	ELSIF MACH_SBC09
		ldy	#mos_welcome_msg
		jsr	printAtY
	ENDIF
1		ldy	#mos_version
2		jsr	printAtY
		jsr	OSNEWL
		jmp	OSNEWL
	IF MACH_BEEB | MACH_CHIPKIT
printWelcomeMO7
		ldy	#mos_welcome_msg7
		jsr	printAtY
		ldy	#mos_version7
		bra	2B
printWelcomeMO36
		ldy	#mos_welcome_msg
		jsr	printAtY
		bra	1B
	ENDIF
printAtY					; LDEB1
		lda	,y+
		beq	1F
		jsr	OSASCI
		bra	printAtY
1		rts
;; ----------------------------------------------------------------------------
;; OSBYTE 129 TIMED ROUTINE; ON ENTRY TIME IS IN X,Y 
OSBYTE_129_timed
		STX_B	oswksp_INKEY_CTDOWN+ 1		; store time in INKEY countdown timer
		STY_B	oswksp_INKEY_CTDOWN		; which is decremented every 10ms
		lda	#$FF				; A=&FF
		bra	LDEC7				; goto DEC7
;; RDCHV entry point	  read a character
mos_RDCHV_default_entry
		clra					; signal we entered through RDCHV not OSBYTE 129
LDEC7		sta	zp_mos_OS_wksp			; store entry value of A
		pshs	B,X,Y				; store X and Y
		LDY_B	sysvar_EXEC_FILE		; get *EXEC file handle
		beq	LDEE6				; if 0 (not allocated) then DEE6
		SEC					; set carry
		ror	zp_mos_cfs_critical		; set bit 7 of CFS active flag to prevent  clashes
		jsr	OSBGET				; get a byte from the file
		pshs	CC				; push processor flags to preserve carry
		lsr	zp_mos_cfs_critical		; restore &EB 
		puls	CC				; get back flags
		bcc	mos_RDCHV_char_found		; and if carry clear, character found so exit via DF03
		lda	#$00				; else A=00 as EXEC file empty
		sta	sysvar_EXEC_FILE		; store it in exec fil;e handle
		jsr	OSFIND				; and close file via OSFIND

LDEE6		tst	zp_mos_ESC_flag			; check ESCAPE flag if bit 7 set Escape pressed
		bmi	mos_RDCHV_return_SEC_ESC	; so off to DF00
		LDX_B	sysvar_CURINSTREAM		; else get current input buffer number
		jsr	mos_check_eco_get_byte_from_kbd	; get a byte from keyboard buffer
		bcc	mos_RDCHV_char_found		; and exit if valid character found
		tst	zp_mos_OS_wksp			; check flags

		bpl	LDEE6				; if entered through RDCHV keep trying
		lda	oswksp_INKEY_CTDOWN		; else check if countdown has expired
		ora	oswksp_INKEY_CTDOWN+1		;
		bne	LDEE6				; if it hasn't carry on
		bra	mos_RDCHV_return_CS_restore_A	; else restore A and exit
mos_RDCHV_return_SEC_ESC				; LDF00
		SEC					; set carry
		lda	#$1B				; return ESCAPE
		bra	mos_RDCHV_char_found
mos_RDCHV_return_CS_restore_A				;	LDF05	 - not changed order
		lda	zp_mos_OS_wksp
mos_RDCHV_char_found					;	LDF03
		puls	B,X,Y,PC
;; ----------------------------------------------------------------------------
copyright_symbol_backwards			; LDF0C
		FCB	")C(",0

STARCMD		MACRO
		FCB	\1
		FDB	\2
		FCB	\3
		ENDM
STARCMDx	MACRO
		FDB	\1
		FCB	\2
		ENDM

mostbl_star_commands
		STARCMD	"."	,mos_jmp_FSCV		,$05	; *.        &E031, A=5     FSCV, X=>String
		STARCMD	"FX"	,mos_STAR_FX		,$FF	; *FX       &E342, A=&FF   Number parameters
		STARCMD	"BASIC"	,mos_STAR_BASIC		,$00	; *BASIC    &E018, A=0     X=>String
		STARCMD	"CAT"	,mos_jmp_FSCV		,$05	; *CAT      &E031, A=5     FSCV, X=>String
		STARCMD	"CODE"	,mos_STAR_OSBYTE_A	,$88	; *CODE     &E348, A=&88   OSBYTE &88
		STARCMD	"EXEC"	,mos_STAR_EXEC		,$00	; *EXEC     &F68D, A=0     X=>String
		STARCMD	"HELP"	,mos_STAR_HELP		,$FF	; *HELP     &F0B9, A=&FF   F2/3=>String
		STARCMD	"KEY"	,mos_STAR_KEY		,$FF	; *KEY      &E327, A=&FF   F2/3=>String
		STARCMD	"LOAD"	,mos_STAR_LOAD		,$00	; *LOAD     &E23C, A=0     X=>String
		STARCMD	"LINE"	,mos_jmp_USERV		,$01	; *LINE     &E659, A=1     USERV, X=>String
;;;	STARCMD	"MOTOR'	,mos_STAR_OSBYTE_A	,$89	; *MOTOR    &E348, A=&89   OSBYTE
		STARCMD	"OPT"	,mos_STAR_OSBYTE_A	,$8B	; *OPT      &E348, A=&8B   OSBYTE
		STARCMD	"RUN"	,mos_jmp_FSCV		,$04	; *RUN      &E031, A=4     FSCV, X=>String
		STARCMD	"ROM"	,mos_STAR_OSBYTE_A	,$8D	; *ROM      &E348, A=&8D   OSBYTE
		STARCMD	"SAVE"	,mos_STAR_SAVE		,$00	; *SAVE     &E23E, A=0     X=>String
		STARCMD	"SPOOL"	,mos_STAR_SPOOL		,$00	; *SPOOL    &E281, A=0     X=>String
;;;	STARCMD	"TAPE'	,mos_STAR_OSBYTE_A	,$8C	; *TAPE     &E348, A=&8C   OSBYTE
	IF MACH_CHIPKIT AND DOCHIPKIT_RTC
		STARCMD "TIME"	,mos_STAR_TIME		,$00	; *TIME
	ENDIF
		STARCMD	"TV"	,mos_STAR_OSBYTE_A	,$90	; *TV       &E348, A=&90   OSBYTE
		STARCMDx	mos_jmp_FSCV		,$03	; Unmatched &E031, A=3     FSCV, X=>String
		FCB	00					; Table end marker

mos_CLIV_default_handler			; LDF89
		stx	zp_mos_txtptr			; store text pointer
;;;	sty	zp_mos_txtptr+1			; not needed in 6809
		lda	#$08				; indicate operation to FSCV
		jsr	mos_jmp_FSCV			; inform FS of *command
		ldx	zp_mos_txtptr
		ldb	#0
1		lda	,x+
		cmpa	#$D
		beq	cli_term_ok
		incb
		bne	1B
		rts					; return - no terminating $D found in 256 chars
cli_term_ok					;LDF9E
		ldx	zp_mos_txtptr			;	DF9E
1		jsr	mos_skip_spaces_at_X		; Skip any spaces
		beq	LE017rts			; Exit if at CR
		cmpa	#'*'				; Is this character '*'?
		beq	1B				; Loop back to skip it, and check for spaces again

		cmpa	#$0D				; check for CR
		beq	LE017rts			; Exit if at CR
		cmpa 	#'|'				; Is it '|' - a comment
		beq	LE017rts			; Exit if so
		cmpa	#'/'				; Is it '/' - pass straight to filing system
		bne	LDFBE				; Jump forward if not
;;;	iny					; Move past the '/'
;;;	jsr	LE009				; Convert &F2/3,Y->XY, ignore returned A
;;;	tfr	Y,X				; move Y to X, already have Y pointing after /
		lda	#$02				; 2=RunSlashCommand
		bra	mos_jmp_FSCV			; Jump to pass to FSCV

LDFBE		leax	-1,X				; point back at start of command
		stx	zp_mos_X			; Store offset to start of command
		ldy	#mostbl_star_commands		; point Y at commands table
		bra	LDFD7				; start searching
LDFC4		eora	,Y+				; compare chars
		anda	#$DF				; case insensitive
		bne	cli_skip_end			; if ne skip to end of current table entry
		SEC					;	DFCC
LDFCD		bcc	LDFF4				;	DFCD
;	inx					;	DFCF
		lda	,X+				;	DFD0
		jsr	mos_CHECK_FOR_ALPHA_CHARACTER	;	DFD2
		bcc	LDFC4				;	DFD5
		leax	-1,X				; backup one and check below if it was a .
		CLC					; indicate "found"
LDFD7		lda	,Y+				;	DFD7
		bmi	LDFF2				;	DFDA
		lda	,X+				;	DFDC
		cmpa	#'.'				;	DFDE
		beq	cli_abbrev			;	DFE0
cli_skip_end	
		SEC					; indicate a "not found situation"
		ldx	zp_mos_X			; reload X to start of command buffer
cli_abbrev					; LDFE6
cli_abbrev_loop					; LDFE8
		leay	1,Y				; 
		lda	-2,Y				; get last byte of name in table
		beq	cli_uk_command			; if 0 we're at the end of the table
		bpl	cli_abbrev_loop			; if +ve continue to skip 
		leay	1,Y				; skip over "A" column
		bmi	LDFCD				; if -ve we've reached a command pointer
LDFF2		leay	2,Y				;	DFF2
LDFF4		leay	-3,Y				;	DFF4
		ldb	1,Y
		pshs	D
;;	pha					;	DFF6
;;	lda	LDF11,x				;	DFF7
;;	pha					;	DFFA
		jsr	mos_skip_spaces_at_X		;	DFFB
		leax	-1,X				; point Y back at last char
		CLC					;	DFFE
		pshs	CC				;	DFFF
		jsr	cli_get_params			;	E000
		puls	CC,PC				;	E003
;; ----------------------------------------------------------------------------
cli_get_params					; LE004
		lda	2,Y				; get "A" column from table
		bmi	LE017rts			; if -ve just go
;;	tfr	Y,X				; return X as text pointer (to command tail)
;LE009:	tya					; else
;	ldy	LDF12,x				;	E00A
;LE00D:	clc					;	E00D
;	adc	zp_mos_txtptr			;	E00E
;	tax					;	E010
;	tya					;	E011
;	ldy	zp_mos_txtptr+1			;	E012
;	bcc	LE017rts				;	E014
;	iny					;	E016
		CLZ				; DB: not sure this is needed but *EXEC expects Z clear on entry!
LE017rts
		rts					;	E017
;; ----------------------------------------------------------------------------
mos_STAR_BASIC						; LE018
		ldb	sysvar_ROMNO_BASIC		; get BASIC rom no
		bmi	cli_uk_command			; if minus then unknown command
		SEC					; else
		jmp	x_mos_ENTER_ROM_B		; enter language
;; ----------------------------------------------------------------------------
cli_uk_command						; LE021
		ldx	zp_mos_X			; Get back pointer to start of command
		ldb	#SERVICE_4_UKCMD		; issue service call to ROMs
		jsr	mos_OSBYTE_143_b_cmd_x_param	;
		beq	LE017rts			; if handled exit
		ldx	zp_mos_X			; else get back pointer
		lda	#FSCV_CODE_OSCLI_UK		; and issue to current FS
mos_jmp_FSCV						; LE031	
		jmp	[FSCV]				;	E031
;; ----------------------------------------------------------------------------
LE034		
		asla					;	E034
LE035		anda	#$01				;	E035
		bra	mos_jmp_FSCV			;	E037

mos_skip_spaces_at_X				; LE03A
1		lda	,x+				;	E03A
		cmpa	#' '				;	E03C
		beq	1B				;	E03E
LE040		cmpa	#$0D				;	E040
		rts					;	E042
;;; ----------------------------------------------------------------------------NEEDED BY HEX PARSER FOR *LOAD/SAVE
mos_skip_spaces_at_X_eqCOMMAorCR_whenCS
		bcc	mos_skip_spaces_at_X				;	E043
mos_skip_spaces_at_X_eqCOMMAorCR
		jsr	mos_skip_spaces_at_X				;	E045
		cmpa	#','				;	E048
		bne	LE040				;	E04A
		bra	mos_skip_spaces_at_X
;;	rts					;	E04D
;; ----------------------------------------------------------------------------
		; api change number returned in B instead of X, use X as pointer
		; also returned in zp_mos_OS_wksp
cli_parse_number_API2
		leax	-1,X
cli_parse_number_API					; LE04E
		jsr	mos_skip_spaces_at_X
		jsr	cli_parse_number_isdigit	;	E051
		bcc	2F				;	E054
		tfr	a,b
		stb	zp_mos_OS_wksp			;	E056
1		jsr	cli_parse_number_next_isdigit	;	E058
		bcc	LE076				;	E05B
		sta	,-S
		lda	zp_mos_OS_wksp
		ldb	#10
		mul
		tsta
		bne	LE08Dclcrts			; overflowed into A
		addb	,S+
		bcs	LE08Dclcrts			; overflowed 
		stb	zp_mos_OS_wksp
		bra	1B
LE076		cmpa	#$0D				;	E078
		SEC					;	E07A
2		leax	-1,X
		rts
;; ----------------------------------------------------------------------------
;LE07C:	iny					;	E07C
;LE07D:	lda	(zp_mos_txtptr),y		;	E07D
cli_parse_number_next_isdigit
		lda	,X+
cli_parse_number_isdigit
		cmpa	#'0'				;	E083
		blo	LE08Dclcrts			;	E085
		cmpa	#'9'+1				;	E07F
		bhs	LE08Dclcrts			;	E081
		anda	#$0F				;	E087
		rts					; returns with carry set indicating a valid number
;; ----------------------------------------------------------------------------
LE08A		leax 	-1,X
		jsr	mos_skip_spaces_at_X_eqCOMMAorCR			;	E08A
LE08Dclcrts
		CLC					;	E08D
		rts					;	E08E
;; ----------------------------------------------------------------------------
x_CheckDigitatXisHEX					; LE08F
		jsr	cli_parse_number_next_isdigit		; 
		bcs	LE0A2					; if Carry set then its a 0-9 number
;		leax	-1,X
		anda	#$DF					;	E094
		cmpa	#$47					;	E096
		bhs	LE08A					;	E098
		cmpa	#$41					;	E09A
		blo	LE08A					;	E09C
		suba	#$37					;	E09F
LE0A2
		SEC
		rts						;	E0A3
;; ----------------------------------------------------------------------------
mos_WRCH_default_entry
		pshs	D,X,Y
		; TODO:ECONET
;	tst	sysvar_ECO_OSWRCH_INTERCEPT		; Check OSWRCH interception flag
;	bpl	LE0BB					; Not set, skip interception call
;	tay						; Pass character to Y
;	lda	#$04					; A=4 for OSWRCH call
;	jsr	jmpNETV					; Call interception code
;	bcs	LE10D					; If claimed, jump past to exit
;LE0BB:	
	IF CPU_6809
		ldb	#$02				;	E0BC
		bitb	sysvar_OUTSTREAM_DEST		;	E0BE
	ELSE
		tim	#$02, sysvar_OUTSTREAM_DEST
	ENDIF
		bne	LE0C8				;	E0C1
		jsr	mos_VDU_WRCH			;	E0C5
LE0C8
		; TODO:PRINTER
	ldb	#$08				; Check output destination
	bitb	sysvar_OUTSTREAM_DEST		; Is printer seperately enabled?
	bne	LE0D1				; Yes, jump to call printer driver
	bcc	LE0D6				; Carry clear, don't sent to printer
LE0D1	;;lda	0,S				; Get character back
	;;					; Resave character
	jsr	mos_PRINTER_DRIVER		; Call printer driver
LE0D6	lda	sysvar_OUTSTREAM_DEST		; Check output destination
	rora					; Is serial output enabled?
	bcc	LE0F7				; No, skip past serial output
	ldb	zp_mos_rs423timeout		; Get serial timout counter
	decb					; Decrease counter
	bpl	LE0F7				; Timed out, skip past serial code
	
	pshs	CC				; Save IRQs
	SEI					; Disable IRQs
	ldx	#$02				; X=2 for serial output buffer
	jsr	mos_OSBYTE_152			; Examine serial output buffer
	bcc	LE0F0				; Buffer not full, jump to send character
	jsr	LE170				; Wait for buffer to empty a bit
LE0F0	lda	1,S				; Get character back
	ldx	#$02				; X=2 for serial output buffer
	jsr	x_INSV_flashiffull		; Send character to serial output buffer
	puls	CC				; Restore IRQs
LE0F7	lda	#$10				; Check output destination
	bita	sysvar_OUTSTREAM_DEST		; Is SPOOL output disabled?
	bne	LE10D				; Yes, skip past SPOOL output
	clra
	ldb	sysvar_SPOOL_FILE		; Get SPOOL handle
	beq	LE10D
	tfr	D,Y
	lda	,S				; Get character back
	SEC					;	E105
	ror	zp_mos_cfs_critical		; Set RFS/CFS's 'spooling' flag
	jsr	OSBPUT				; Write character to SPOOL channel
	lsr	zp_mos_cfs_critical		; Reset RFS/CFS's 'spooling' flag
LE10D	puls	D,X,Y,PC

;; ----------------------------------------------------------------------------
;; PRINTER DRIVER; A=character to print 
mos_PRINTER_DRIVER
	ldb	#$40
	bitb	sysvar_OUTSTREAM_DEST		;if bit 6 of VDU byte =1 printer is disabled
	bne	LE139				;so E139
	cmpa	sysvar_PRINT_IGNORE		;compare with printer ignore character
	beq	LE139				;if the same E139
LE11E
	pshs	CC				;else save flags
	SEI					;bar interrupts 
;;	tax					;X=A
	ldb	#$04				;
	bitb	sysvar_OUTSTREAM_DEST		;read bit 2 'disable printer driver'
	bne	LE138				;if  set printer is disabled so exit E138 
;;	txa					;else A=X
	ldx	#$03				;X=3
	jsr	x_INSV_flashiffull		;and put character in printer buffer
	bcs	LE138				;if carry set on return exit, buffer empty
	tst	mosbuf_buf_busy+3		;else check buffer busy flag if 0
	bpl	LE138				;then E138 to exit
	jsr	LE13A				;else E13A to open printer cahnnel
LE138	puls	CC,PC				;	E138
LE139	rts					;	E139
;; ----------------------------------------------------------------------------
LE13A	lda	sysvar_PRINT_DEST		;check printer destination
	lbeq	x_Buffer_handling		;if 0 then E1AD clear printer buffer and exit
	cmpa	#$01				;if parallel printer not selected
	bne	x_serial_printer		;E164
	jsr	mos_OSBYTE_145			;else read a byte from the printer buffer
	ror	mosbuf_buf_busy+3		;if carry is set then 2d2 is -ve
	bmi	LE139				;so return via E190

	IF MACH_BEEB | MACH_CHIPKIT

	ldb	#$82				;else enable interrupt 1 of the external VIA
	stb	sheila_USRVIA_ier		;
	sta	sheila_USRVIA_ora		;pass code to centronics port
	lda	sheila_USRVIA_pcr		;pulse CA2 line to generate STROBE signal
	anda	#$F1				;to advise printer that
	ora	#$0C				;valid data is 
	sta	sheila_USRVIA_pcr		;waiting
	ora	#$0E				;
	sta	sheila_USRVIA_pcr		;
	ELSE
		; TODO: SBC09 : 2nd port?
	ENDIF
	bra	LE139				;then exit
;; :serial printer
x_serial_printer
	cmpa	#$02				;is it Serial printer??
	bne	x_printer_user			;if not E191
	ldb	zp_mos_rs423timeout		;else is RS423 in use by cassette?? 
	decb					;
	bpl	x_Buffer_handling		;if so E1AD to flush buffer
	lsr	mosbuf_buf_busy+3		;else clear buffer busy flag
LE170	lsr	sysvar_RS423_USEFLAG		;and RS423 busy flag
LE173	jsr	x_check_RS423_input_buffer_API	;count buffer if C is clear on return
	bcs	LE139				;no room is buffer so exit
	ldx	#$20				;else 
LE17A	ldy	#$9F				;

	IF MACH_BEEB
; OSBYTE 156 update ACIA setting and RAM copy; on entry	 
mos_OSBYTE_156
		pshs	CC				;	E17C
		SEI					;	E17D
		m_tya					;	E17E
		STX_B	zp_mos_OS_wksp2			;	E17F
		anda	sysvar_RS423_CTL_COPY		;	E181
		eora	zp_mos_OS_wksp2			;	E184
		LDX_B	sysvar_RS423_CTL_COPY		;	E186
ACIA_set_CTL_and_copy				; LE189
		sta	sysvar_RS423_CTL_COPY		;put new value in
		sta	sheila_ACIA_CTL			;and store to ACIA control register
		puls	CC,PC				;get back flags and exit
	ELSIF MACH_CHIPKIT
mos_OSBYTE_156
	TODOSKIP "CHIPKIT OSBYTE 156"
	ELSIF MACH_SBC09
mos_OSBYTE_156
	TODOSKIP "SBC09 OSBYTE 156"
	ENDIF
;; ----------------------------------------------------------------------------
;; printer is neither serial or parallel so its user type
x_printer_user
	CLC					;	E191
	lda	#$01				;	E192
	jsr	LE1A2				;	E194
; OSBYTE 123 Warn printer driver going dormant
mos_OSBYTE_123
	ror	mosbuf_buf_busy+3		;	E197
LE19A	rts					;	E19A
;; ----------------------------------------------------------------------------
;LE19B:	bit	mosbuf_buf_busy+3		;	E19B
;	bmi	LE19A				;	E19E
;	lda	#$00				;	E1A0
LE1A2		ldx	#$03				;X=3
LPT_NETV_then_UPTV				; LE1A4
		LDY_B	sysvar_PRINT_DEST		;Y=printer destination
		jsr	[NETV]				;to JMP (NETV)
		jmp	[UPTV]				;jump to PRINT VECTOR for special routines

 *************** Buffer handling *****************************************
		;X=buffer number
		;Buffer number	Address		Flag	Out pointer	In pointer
		;0=Keyboard	3E0-3FF		2CF	2D8		2E1
		;1=RS423 Input	A00-AFF		2D0	2D9		2E2
		;2=RS423 output	900-9BF		2D1	2DA		2E3
		;3=printer	880-8BF		2D2	2DB		2E4
		;4=sound0	840-84F		2D3	2DC		2E5
		;5=sound1	850-85F		2D4	2DD		2E6
		;6=sound2	860-86F		2D5	2DE		2E7
		;7=sound3	870-87F		2D6	2DF		2E8
		;8=speech	8C0-8FF		2D7	2E0		2E9

x_Buffer_handling					; LE1AD
		CLC					;clear carry
x_Buffer_handling2					; LE1AE
		pshs	A,CC				;save A, flags
		SEI					;set interrupts
		bcs	LE1BB				;if carry set on entry then E1BB
		lda	mostbl_SERIAL_BAUD_LOOK_UP,x	;else get byte from baud rate/sound data table
		bpl	LE1BB				;if +ve the E1BB
	IF INCLUDE_SOUND
		jsr	snd_clear_chan_API		;else clear sound data
	ENDIF

LE1BB		SEC					;set carry
		ror	mosbuf_buf_busy,x		;rotate buffer flag to show buffer empty
		cmpx	#$02				;if X>1 then its not an input buffer
		bhs	LE1CB				;so E1CB

		lda	#$00				;else Input buffer so A=0
		sta	sysvar_KEYB_SOFTKEY_LENGTH	;store as length of key string
		sta	sysvar_VDU_Q_LEN		;and length of VDU queque
LE1CB		jsr	x_mos_SEV_and_CNPV				;then enter via count purge vector any 
							;user routines
		puls	CC,A,PC				;restore flags, A and exit

 *************************************************************************
 *                                                                       *
 *       COUNT PURGE VECTOR      DEFAULT ENTRY                           *
 *                                                                       *
 *                                                                       *
 *************************************************************************
 ;on entry if V set clear buffer
 ;         if C set get space left
 ;         else get bytes used 
mos_CNPV_default_entry_point				; LE1D1
		bvc	LE1DA				;if bit 6 is set then E1DA
		lda	mosbuf_buf_start,X		;else start of buffer=end of buffer
		sta	mosbuf_buf_end,X		;
		rts					;and exit
;; ----------------------------------------------------------------------------
LE1DA		pshs	B,CC				;push flags
		SEI					;bar interrupts
		lda	mosbuf_buf_end,X		;get end of buffer
		suba	mosbuf_buf_start,X		;subtract start of buffer
		bcc	LE1EA				;if carry caused E1EA
		suba	mostbl_BUFFER_ADDRESS_OFFS,X	;subtract buffer start offset (i.e. add buffer length)
LE1EA		
	IF CPU_6809
		pshs	B
		ldb	#1				;check carry in pushed flags
		bitb	,S
		puls	B				; TODO get rid?
	ELSE
		tim	#1, 0,S
	ENDIF
		beq	LE1F3				;if carry clear E1F3 to exit
		adda	mostbl_BUFFER_ADDRESS_OFFS,X	;add to get bytes used
		coma					;and invert to get space left
LE1F3
		m_tax					;X=A
		puls	CC,B,PC
;; ----------------------------------------------------------------------------
;; enter byte in buffer, wait and flash lights if full
x_INSV_flashiffull
		SEI					; prevent interrupts
		jsr	[INSV]				; entera byte in buffer X
		bcc	LE20D				; if successful exit
		jsr	x_keyb_leds_test_esc		; else switch on both keyboard lights
	IF INCLUDE_KEYBOARD
		pshs	A,CC
		jsr	x_Turn_on_Keyboard_indicators	; switch off unselected LEDs
		puls	A,CC
	ENDIF
		bmi	LE20D				; if return is -ve Escape pressed so exit
		CLI					; else allow interrupts
		bra	x_INSV_flashiffull		; if byte didn't enter buffer go and try it again
LE20D		rts					; then return
;; ----------------------------------------------------------------------------
;; : clear osfile control block workspace
; API change, used to clear osfile_ctlblk,x..x+3 now clears at Y..3,Y
x_loadsave_clr_4bytesY_API
		clr	3,Y
		clr	2,Y
		clr	1,Y
		clr	0,Y
		rts					;	E21E


;; ----------------------------------------------------------------------------
;; shift through osfile control block - BIG ENDIAN!
x_shift_through_osfile_control_block
		rola					; left justify nybble
		rola
		rola
		rola
		ldb	#$04				; loop counter
LE227		rola					;	E227
		rol	3,Y				;	E228
		rol	2,Y				;	E22B
		rol	1,Y				;	E22E
		rol	,Y				;	E231
		bcs	brkBadAddress			; overflow!
		decb					;	E236
		bne	LE227				;	E237
		rts					;	E23B
;; ----------------------------------------------------------------------------
;; *LOAD ENTRY
mos_STAR_LOAD						; LE23C
		lda	#$FF				;signal that load is being performed
;; *SAVE ENTRY; on entry A=0 for save &ff for load 
mos_STAR_SAVE						; LE23E
;;		clra
;;		stx	zp_mos_txtptr			; store address of rest of command line  
;;		sty	zp_mos_txtptr+1			; 
		stx	osfile_ctlblk			; store X in control block (start of filename)
;;		sty	osfile_ctlblk+1			; 
		sta	,-S				; Push A
		ldy	#osfile_ctlblk + 2
		jsr	x_loadsave_clr_4bytesY_API	; clear the shift register
		ldb	#$FF				; Y=255
		stb	osfile_ctlblk+OSFILE_OFS_EXEC+3	; store in EXEC low byte to signal use catalogue addr
		jsr	mos_CLC_GSINIT			; and call GSINIT to prepare for reading text line
LE257		jsr	mos_GSREAD			; read a code from text line if OK read next
		bcc	LE257				; until end of filename reached
		leax	-1,X				; step back one
		tst	,S				; get back A without stack changes
		beq	x_SAVE_build_ctl_block		; IF A=0 (SAVE)  E2C2
		jsr	x_LOADSAVE_readaddr		; set up file block
		bcs	x_loadsave_setAXOSFILE_clrEXEClo; if carry set do OSFILE
		beq	x_loadsave_setAXOSFILE		; else if A=0 goto OSFILE, or drop through for bad addr!
brkBadAddress						; LE267
		DO_BRK	$FC, "Bad Address"

;; CLOSE SPOOL/ EXEC FILES
mos_OSBYTE_119
		ldb	#SERVICE_10_SPOOL_CLOSE		; X=10 issue *SPOOL/EXEC files warning
		jsr	mos_OSBYTE_143_b_cmd_x_param	; and issue call
		beq	LE29F				; if a rom accepts and issues a 0 then E29F to return
		jsr	mos_CLOSE_EXEC_FILE		; else close the current file
		clra					; A=0

		; always entered with A=0 but Z=1 flag decided whether to close????
		; Y ignored
		; X filename to open in Z=0
mos_STAR_SPOOL
		pshs	CC,Y					; if A=0 file is closed so
		ldb	sysvar_SPOOL_FILE			; get file handle
		sta	sysvar_SPOOL_FILE			; store A as file handle
		tstb
		beq	LE28F					; if Y<>0 then E28F (i.e. no existing spool file open)
		jsr	OSFIND					; else close file via osfind
LE28F		puls	CC,Y					; get back original Y
							; pull flags
		beq	LE29F					; if Z=1 on entry then exit
		lda	#$80					; else A=&80
		jsr	OSFIND					; to open file Y for output
		tsta						; Y=A
		lbeq	brkBadCommand			; and if this is =0 then E310 BAD COMMAND ERROR
		sta	sysvar_SPOOL_FILE			; store file handle
LE29F		rts						; and exit
;; ----------------------------------------------------------------------------
x_loadsave_setAXOSFILE_clrEXEClo
		bne	brkBadCommand		;
		inc	osfile_ctlblk+OSFILE_OFS_EXEC + 3	; indicate a load from catalogue
x_loadsave_setAXOSFILE					;	E2A5
		ldx	#osfile_ctlblk			;
		lda	,S+				;	E2A9
		jmp	OSFILE				;	E2AA
;; ----------------------------------------------------------------------------
;; check for hex digit
x_LOADSAVE_readaddr
		jsr	mos_skip_spaces_at_X		;	E2AD
		beq	LE2C1
		leax	-1,X
		jsr	x_CheckDigitatXisHEX		;	E2B0
		bcc	LE2C1				;	E2B3
		jsr	x_loadsave_clr_4bytesY_API	;	E2B5
;; shift byte into control block
x_shift_byte_into_control_block
		jsr	x_shift_through_osfile_control_block	;	E2B8
		jsr	x_CheckDigitatXisHEX			;	E2BB
		bcs	x_shift_byte_into_control_block 	;	E2BE
		SEC						;	E2C0
LE2C1		rts						;	E2C1
;; ----------------------------------------------------------------------------
;; ; set up OSfile control block
x_SAVE_build_ctl_block
	ldy	#osfile_ctlblk+$A			; point at "start address"
	jsr	x_LOADSAVE_readaddr			;	E2C4
	bcc	brkBadCommand			; if no hex digit found EXIT via BAD Command error
	clr	zp_mos_OS_wksp				; clear bit 6
; READ file length from text line
x_READ_file_length_from_text_line
;;	lda	,X					; read next byte from text line
	cmpa	#'+'					; is it '+'
	bne	LE2D4					; if not assume its a last byte address so e2d4
	dec	zp_mos_OS_wksp				; else set V and M flags
;;	leax	1,X					; increment Y to point to hex group
LE2D4	
	ldy	#osfile_ctlblk+$E			;X=E
	jsr	x_LOADSAVE_readaddr			;
	bcc	brkBadCommand			;if carry clear no hex digit so exit via error
	pshs	CC					;save flags
	tst	zp_mos_OS_wksp
	bpl	LE2ED					;if V set them E2ED explicit end address found
;; 	ldx	#$FC					;else X=&FC
;; 	clc						;clear carry
;; LE2E1:	lda	stack+252,x				;and add length data to start address
;; 	adc	USERV,x					;
;; 	sta	USERV,x					;
;; 	inx						;
;;	bne	LE2E1					;repeat until X=0
	; add length to start store at osfil
;;	ldd	osfile_ctlblk+$A+2
;;	addd	osfile_ctlblk+$E+2
;;	std	osfile_ctlblk+$E+2
;;	ldd	osfile_ctlblk+$A
;;	adcb	osfile_ctlblk+$E+1
;;	adca	osfile_ctlblk+$E+0
;;	std	osfile_ctlblk+$E+0			; 21
	CLC
	ldy	#osfile_ctlblk+$A+4			; 3
	ldb	#4					; 2
1	lda	,-Y					; 2+0
	adca	4,Y					; 2+0
	sta	4,Y					; 2+0
	decb						; 1
	bne	1B					; 2
							; 14

LE2ED
;;;	ldx	#$03					;X=3
;;LE2EF:	lda	osfile_ctlblk+10,x			;copy start adddress to load and execution addresses
;;	sta	osfile_ctlblk+6,x			;
;;	sta	osfile_ctlblk+2,x			;
;;	dex						;
;;	bpl	LE2EF					;get back flag
	ldy	#osfile_ctlblk+$A			; 3
	ldb	#3					; 2
1	lda	,Y+					; 2+0
	sta	-5,Y					; 2+0
	sta	-9,Y					; 2+0
	decb						; 1
	bpl	1B					; 2
							; 14



	puls	CC					;if end of command line reached then E2A5
	beq	x_loadsave_setAXOSFILE			; to do osfile
	ldy	#osfile_ctlblk+6			;else set up execution address
	jsr	x_LOADSAVE_readaddr			;
	bcc	brkBadCommand			;if error BAD COMMAND
	beq	x_loadsave_setAXOSFILE			;and if end of line reached do OSFILE
	ldx	#osfile_ctlblk+6			;else set up load address
	jsr	x_LOADSAVE_readaddr			;
	bcc	brkBadCommand			;if error BAD command
	beq	x_loadsave_setAXOSFILE			;else on end of line do OSFILE
							;anything else is an error!!!!
; Bad command error
brkBadCommand				; LE310
		DO_BRK $FE, "Bad Command"
brkBadKey
		DO_BRK $FB, "Bad Key"
;; *KEY ENTRY
mos_STAR_KEY					; 
	jsr	cli_parse_number_API		; set up key number in B
	bcc	brkBadKey			; if not valid number give error 
	cmpb	#$10				; if key number greater than 15
	bhs	brkBadKey			; if greater then give error
	jsr	mos_skip_spaces_at_X_eqCOMMAorCR; otherwise skip commas, and check for CR
	pshs	CC,X				; save flags for later
						; save X
						; to preserve text pointer
	ldb	soft_keys_end_ptr		; get pointer to top of existing key strings
	jsr	x_set_up_soft_key_definition	; set up soft key definition
	puls	CC,X				; and flags
	bne	LE377				; if CR found return else E377 to set up new string
	rts					; else return to set null string
;; ----------------------------------------------------------------------------
;; *FX	OSBYTE
mos_STAR_FX						; LE342
		jsr	cli_parse_number_API			; get number to pass as A to OSBYTE
		bcc	brkBadCommand
		tfr	B,A
;; *CODE	  *MOTOR  *OPT	  *ROM	  *TAPE	  *TV; enter codes    *CODE   &88 
; A = osbyte function
; X pointer to command line string
; C clear = entered from CLI parser - don't allow comma, else dropped in from *FX above in which case allow comma
mos_STAR_OSBYTE_A					; LE348
		pshs	A					; save A
;;;	lda	#$00					;	E349
		lda	#0					; clear values for X, Y NB: lda rather than clr, need to preserve C flag
		sta	zp_mos_GSREAD_characc			
		sta	zp_mos_GSREAD_quoteflag			
		jsr	mos_skip_spaces_at_X_eqCOMMAorCR_whenCS ; if CS (i.e. *FX) allow comma, else just skip spaces
		beq	1F					;
		jsr	cli_parse_number_API2			; parse X value
		bcc	brkBadCommand			;
		stb	zp_mos_GSREAD_characc			;
		jsr	mos_skip_spaces_at_X_eqCOMMAorCR	; spaces always ok here
		beq	1F					;
		jsr	cli_parse_number_API2			; parse Y value
		bcc	brkBadCommand			;
		stb	zp_mos_GSREAD_quoteflag			;
		jsr	mos_skip_spaces_at_X			;
		bne	brkBadCommand			; garbage at end
1		LDY_B	zp_mos_GSREAD_quoteflag			;
		LDX_B	zp_mos_GSREAD_characc			;
		puls	A					;
		jsr	OSBYTE					; exec OSBYTE
		bvs	brkBadCommand			; BRK if VS
		rts						;
;; ----------------------------------------------------------------------------
LE377		clra
		ldy	#soft_keys_start
		leay	D,Y				; point at "end" of strings
		leay	1,Y
		leax	-1,X				; step back command line pointer
		SEC				;
		jsr	mos_GSINIT			; look for '"' on return bit 6 E4=1 bit 7=1 if '"'found
							; this is a GSINIT call without initial CLC
LE37B		jsr	mos_GSREAD			; call GSREAD carry is set if end of line found
		bcs	LE388				; E388 to deal with end of line
		incb					; point to first byte of new key definition
		lbeq	brkBadKey			; if X=0 buffer WILL overflow so exit with BAD KEY error
		sta	,Y+				; store character
		bcc	LE37B				; and loop to get next byte if end of line not found
LE388		lbne	brkBadKey			; if Z clear then no matching '"' found or for some
							; other reason line doesn't terminate properly
		pshs	CC				; else if all OK save flags
		SEI					; bar interrupts
		jsr	x_set_up_soft_key_definition	; and move string
		ldb	#$10				;	E38F
		ldx	#soft_keys_ptrs
LE391		cmpb	zp_mos_OS_wksp			;if key being defined is found
		beq	LE3A3				;then skip rest of loop
		lda	B,X				;else get start of string X
		cmpa	,Y				;compare with start of string Y
		bne	LE3A3				;if not the same then skip rest of loop 
		lda	soft_keys_end_ptr		;else store top of string definition 
		sta	B,X				;in designated key pointer
LE3A3		decb					;decrement loop pointer X
		bpl	LE391				;and do it all again
		puls	CC,PC				;get back flags
							;and exit
;; ----------------------------------------------------------------------------
;; : set string lengths
; on entry: 	B is key number
; on exit:	A, zp_mos_OS_wksp2+1 - length of current keydef
x_get_keydef_length
		pshs	CC,B,X				;push flags
		ldx	#soft_keys_start
		SEI					;bar interrupts
		lda	B,X				; get start of string
		pshs	A
		lda	soft_keys_end_ptr
		suba	,S
		sta	zp_mos_OS_wksp2+1		; max length
		ldb	#$10
1		lda	B,X				; get ptr B
		suba	,S				; is this pointer after "current"
		bls	2F
		cmpa	zp_mos_OS_wksp2+1		; is this shorter?
		bhs	2F				; no
		sta	zp_mos_OS_wksp2+1		; yes
2		decb
		bpl	1B
		leas	1,S				; discard temp val
		lda	zp_mos_OS_wksp2+1		;get back latest value of A     
		puls	CC,B,X,PC				;pull flags, restore X and return						;and return
;; ----------------------------------------------------------------------------
;; : set up soft key definition
; on entry	B is pointer (within page B) of end of definitions after any new string has been added
;		Key numer is in zp_mos_OS_wksp
x_set_up_soft_key_definition				; LE3D1
	pshs	CC,B
	SEI					;can't allow IRQs as they trample zp_mos_os_wksp2
	ldb	zp_mos_OS_wksp			;Key number in B
	jsr	x_get_keydef_length		;and set up &FB 
	clra
	ldb	zp_mos_OS_wksp
	ldx	#soft_keys_ptrs
	ldb	D,X				;get start of string
	leay	D,X				;point Y at start of string
	addb	zp_mos_OS_wksp2+1		;add old length
	stb	zp_mos_OS_wksp2			;and store it
	leax	D,X				;X points at end of string
	tst	sysvar_KEYB_SOFTKEY_LENGTH	;check number of bytes left to remove from key buffer
			                        ;if not 0 key is being used (definition expanded so
                        			;error.  This stops *KEY 1 "*key1 FRED" etc.
	beq	LE3F6				;if not in use continue
brkKeyInUse	DO_BRK $FA, "Key in use"
LE3F6	dec	sysvar_KEYB_SOFT_CONSISTANCY	;decrement consistence flag to &FF to warn that key
						;definitions are being changed
	ldb	1,S				;get back orignal end of strings pointer
	subb	zp_mos_OS_wksp2			;sub new end of strings pointer
	stb	zp_mos_OS_wksp2			;store
	beq	LE40D				;if 0 then no copying to do
LE401	lda	,X+				;close up string to 0 length
	sta	,Y+
	dec	zp_mos_OS_wksp2			
	bne	LE401				
LE40D	tfr	Y,D
	stb	1,S				; save new end of strings pointer
	ldx	#soft_keys_ptrs
	ldb	zp_mos_OS_wksp			; key#
	leay	B,X
	ldb	#$10				;
LE413	lda	,X				; go through all the keys start pointers (and end pointer)
	cmpa	,Y				; decrement by the number of bytes we've just removed if
	bls	LE422				; after the string we just removed
	suba	zp_mos_OS_wksp2+1		;
	sta	,x				;
LE422	leax	1,X
	decb					
	bpl	LE413				
	lda	soft_keys_end_ptr		
	sta	,y				; update current key to point at updated end pointer
	lda	1,S				; update end pointer 
	sta	soft_keys_end_ptr		;	E42C
	inc	sysvar_KEYB_SOFT_CONSISTANCY	; unlock consistancy flag
	puls	CC,B,PC
; ----------------------------------------------------------------------------
; BUFFER ADDRESS HI LOOK UP TABLE - move to after vectors

*************************************************************************
*                                                                       *
*       OSBYTE 152 Examine Buffer status                                *
*                                                                       *
*************************************************************************
;on entry X = buffer number
;on exit Y next character or preserved if buffer empty
;if buffer is empty C=1, Y is preserved else C=0
mos_OSBYTE_152					; LE45B
		SEV
		bra	jmpREMV				;	E45E
*************************************************************************
*                                                                       *
*       OSBYTE 145 Get byte from Buffer                                 *
*                                                                       *
*************************************************************************
;on entry X = buffer number
; ON EXIT Y is character extracted 
;if buffer is empty C=1, else C=0
mos_OSBYTE_145
		CLV
jmpREMV
		jmp	[REMV]
*************************************************************************
*                                                                       *
*       REMV buffer remove vector default entry point                   *
*                                                                       *
*************************************************************************
;on entry X = buffer number
;on exit if buffer is empty C=1, Y is preserved 
;else C=0, Y = char (and A)

mos_REMV_default_entry_point				; LE464
		CLC						;clear carry (assume success)
		pshs	B,X,CC					;push flags
		SEI						;bar interrupts
		ldb	mosbuf_buf_start,x			;get output pointer for buffer X
		cmpb	mosbuf_buf_end,x			;compare to input pointer
		beq	remv_SEC_ret				;if equal buffer is empty so E4E0 to exit

		pshs	B					;preserve B for later
		jsr	get_buffer_ptr				;find buffer start pointer
		ldb	,S					;get back B from stack but leave there
		abx
		lda	,X					;get char from buffer
	IF CPU_6809
		ldb	#2
		bitb	1,S					;check overflow flag in stacked flags
	ELSE
		tim	#$02, 1,S				;check overflow flag in stacked flags
	ENDIF
		beq	1F					;V not set branch
		m_tay						;stick char found Y
		leas	1,S					;skip stacked B
		puls	B,X,CC,PC				;return with C=0, this is the osbyte 152 return
1		puls	B
		ldx	2,S					;get channel no in X back
		incb						;increment start pointer
		bne	1F					;if it is 0
		ldb	mostbl_BUFFER_ADDRESS_OFFS,X		;wrap around by finding start offs
1		stb	mosbuf_buf_start,x			;store updated pointer
		cmpb	mosbuf_buf_end,x			;check if buffer empty
		bne	1F					;if not the same buffer is not empty so exit
		cmpx	#2					;if buffer is input (0 or 1)
		blo	1F					;then E48F

		ldy	#0					;buffer is empty so Y=0
		jsr	x_CAUSE_AN_EVENT			;and enter EVENT routine to signal EVENT 0 buffer
								;becoming empty
1		m_tay						;return char in Y
		puls	B,X,CC,PC				;return with carry clear

remv_SEC_ret
	IF MACH_SBC09
		cmpx	#0
		bne	9F
		jsr	IRQ_SET_RTS
9	
	ENDIF
		inc	,S					; set carry flag in CC on stack
1		puls	B,X,CC,PC


 **************************************************************************
 **************************************************************************
 **                                                                      **
 **      CAUSE AN EVENT                                                  **
 **                                                                      **
 **************************************************************************
 **************************************************************************
 ;on entry Y=event number
 ;A and X may be significant Y=A, A=event no. when event generated @E4A1
 ;on exit carry clear indicates action has been taken else carry set
x_CAUSE_AN_EVENT					;LE494
		CLC
		pshs	D,CC				;push flags, with carry clear
		SEI					;bar interrupts
		sta	zp_mos_OS_wksp2			;&FA=A  
		lda	mosvar_EVENT_ENABLE,y		;get enable event flag
		beq	x_return_with_carry_set_pop_D_CC;if 0 event is not enabled so exit
		ldb	zp_mos_OS_wksp2
		clra
		exg	Y,D
		exg	B,A				;else A=Y, Y=A	 - TODO - this is a bit rubbish
		jsr	[EVNTV]				;vector through &220
		puls	D,CC,PC				; carry already cleared for success

x_return_with_carry_set_pop_D_CC
		inc	,S				; set carry flag (assumes CC pushed with carry clear)
		puls	D,CC,PC				; LEFDF



*************************************************************************
*                                                                       *
*       OSBYTE 138 Put byte into Buffer                                 *
*                                                                       *
*************************************************************************
;on entry X is buffer number, Y is character to be written 
mos_OSBYTE_138						; LE4AF
		lda	zp_mos_OSBW_Y
jmpINSV		jmp	[INSV]

get_buffer_ptr
		m_txb
		aslb					; b = 2 * buffer #
		ldx	#mostbl_BUFFER_ADDRESS_PTR_LUT
		ldx	B,X 				; get buffer start pointer
		rts

*************************************************************************
*                                                                       *
*       INSV insert character in buffer vector default entry point     *
*                                                                       *
*************************************************************************
;on entry X is buffer number, A is character to be written 
mos_INSV_default_entry_point				; LE4B3
		CLC					; clear carry for default exit
		pshs	D,X,CC
		SEI					; disable interrupts
		ldb	mosbuf_buf_end,X		; get current buffer pointer
		pshs	B				; stack B for later
		incb					; incremenet
		bne	1F				; if 0 wrap around
		ldb	mostbl_BUFFER_ADDRESS_OFFS,X	; wrap around by finding start offs
1		cmpb	mosbuf_buf_start,X		; compare to extract pointer
		beq	insv_buf_full			; buffer is full, cause an event and exit
		stb	mosbuf_buf_end,X		; save updated pointer
		jsr	get_buffer_ptr
		puls	B
		abx
		sta	,X				; store the byte in the buffer
		puls	D,X,CC,PC			; exit with carry clear

insv_buf_full	leas	1,S				; reset stack
		cmpx	#2				; if it's an input buffer raise an event
		bhs	insv_SEC_ret			; its 2 or greater skip
		ldy	#1
		jsr	x_CAUSE_AN_EVENT		; raise the input buffer full event
insv_SEC_ret
		inc	,S				; set carry flag in CC on stack
		puls	D,X,CC,PC


; ----------------------------------------------------------------------------
;; check event 2 character entering buffer
x_check_event_2_char_into_buf_fromA				; LE4A8
		ldy	#$02
		jsr	x_CAUSE_AN_EVENT
		bra	jmpINSV

;; ----------------------------------------------------------------------------
;; CHECK FOR ALPHA CHARACTER; ENTRY  character in A ; exit with carry set if non-Alpha character 
mos_CHECK_FOR_ALPHA_CHARACTER			; LE4E3
		PSHS	A				;Save A
		anda	#$DF				;convert lower to upper case
		cmpa	#'Z'				;is it less than eq 'Z'
		bhi	LE4EE				;if so exit with carry clear
		cmpa	#'A'				;is it 'A' or greater ??
		bhs	LE4EF				;if not exit routine with carry set
LE4EE		SEC					;else clear carry
LE4EF		puls	A,PC				;get back original value of A
		;;rts					;and Return
;; ----------------------------------------------------------------------------
;; : INSERT byte in Keyboard buffer
x_INSERT_byte_in_Keyboard_buffer			; LE4F1
		STY_B	zp_mos_OSBW_Y
		clr	zp_mos_OSBW_X

 *************************************************************************
 *                                                                       *
 *       OSBYTE 153 Put byte in input Buffer checking for ESCAPE         *
 *                                                                       *
 *************************************************************************
 ;on entry X = buffer number (either 0 or 1)
 ;X=1 is RS423 input
 ;X=0 is Keyboard
 ;Y is character to be written 
mos_OSBYTE_153
		ldd	zp_mos_OSBW_Y			; A=Y, B=X (on entry to OSBYTE)
							;A=buffer number
		andb	sysvar_RS423_MODE		;and with RS423 mode (0 treat as keyboard 
							;1 ignore Escapes no events no soft keys)
		bne	mos_OSBYTE_138			;so if RS423 buffer AND RS423 in normal mode (1) E4AF
							;else Y=A character to write
		ldx	#0				;force keyboard buffer -- TODO: is this right?
		cmpa	sysvar_KEYB_ESC_CHAR		;compare with current escape ASCII code (0=match)
		bne	x_check_event_2_char_into_buf_fromA	;if ASCII or no match E4A8 to enter byte in buffer
		tst	sysvar_KEYB_ESC_ACTION		;or with current ESCAPE status (0=ESC, 1=ASCII)
		bne	x_check_event_2_char_into_buf_fromA	;if ASCII or no match E4A8 to enter byte in buffer
		lda	sysvar_BREAK_EFFECT		;else get ESCAPE/BREAK action byte
		rora					;Rotate to get ESCAPE bit into carry
		lda	zp_mos_OSBW_Y			;get character back in A
		bcs	LE513				;and if escape disabled exit with carry clear
		ldy	#$06				;else signal EVENT 6 Escape pressed
		jsr	x_CAUSE_AN_EVENT		;
		bcc	LE513				;if event handles ESCAPE then exit with carry clear
		jsr	mos_OSBYTE_125			;else set ESCAPE flag
LE513		CLC					;clear carry 
		rts					;and exit

;; ----------------------------------------------------------------------------
;; get a byte from keyboard buffer and interpret as necessary; on entry A=cursor editing status 1=return &87-&8B,  ; 2= use cursor keys as soft keys 11-15 ; this area not reached if cursor editing is normal 
mos_interpret_keyb_byte					; LE515
		rora					;get bit 1 into carry
		bcc	mos_interpret_keyb_byte2
		puls	A				;get back A
		lbra	x_exit_with_carry_clear		;if carry is set return
						;else cursor keys are 'soft'

mos_interpret_keyb_byte2
		lda	,S				;leave A on stack
		lsra					;get high nybble into lo
		lsra					;
		lsra					;
		lsra					;A=8-&F
		eora	#$04				;and invert bit 2
							;&8 becomes &C
							;&9 becomes &D
							;&A becomes &E
							;&B becomes &F
							;&C becomes &8
							;&D becomes &9
							;&E becomes &A
							;&F becomes &B
		m_tay					;Y=A = 8-F
		lda	sysvar_KEYB_C0CF_INSERT_INT-8,y	;read 026D to 0274 code interpretation status
							;0=ignore key, 1=expand as 'soft' key
							;2-&FF add this to base for ASCII code
							;note that provision is made for keypad operation
							;as codes &C0-&FF cannot be generated from keyboard
							;but are recognised by OS
							;

		cmpa	#$01				;is it 01
		lbeq	x_expand_soft_key_strings	;if so expand as 'soft' key via E594
		puls	A				;else get back original byte
		blo	x_get_byte_from_buffer		;then code 0 must have
							;been returned so E539 to ignore
		anda	#$0F				;else add ASCII to BASE key number so clear hi nybble
		adda	sysvar_KEYB_C0CF_INSERT_INT-8,y	;add ASCII base
		CLC					;clear carry
		rts					;and exit

	IF INCLUDE_CURSOR_EDIT
						;
;; ----------------------------------------------------------------------------
;; ERROR MADE IN USING EDIT FACILITY
x_ERROR_EDITING
		jsr	mos_VDU_7		;	E534
		puls	X
;	pla					;	E537
;	tax					;	E538
	ENDIF
;; get byte from buffer
x_get_byte_from_buffer					; LE539
		jsr	mos_OSBYTE_145			;get byte from buffer X
		bcs	LE593rts			;if buffer empty E593 to exit
		pshs	A				;else Push byte
		cmpx	#$01				;and if RS423 input buffer is not the one
		bne	1F				;then E549

		jsr	LE173				;else oswrch
		ldx	#$01				;X=1 (RS423 input buffer)
		CLC					;clear (was set) carry
1							; LE549
		puls	A				;get back original byte
		bcs	1F				;if carry clear (I.E not RS423 input) E551
		LDY_B	sysvar_RS423_MODE		;else Y=RS423 mode (0 treat as keyboard )
		bne	x_exit_with_carry_clear		;if not 0 ignore escapes etc. goto E592
1							; LE551
		tsta					;test A (was tay)
		bpl	x_exit_with_carry_clear		;if code is less than &80 its simple so E592
		pshs	A
		anda	#$0F				;else clear high nybble
		cmpa	#$0B				;if less than 11 then treat as special code
		blo	mos_interpret_keyb_byte2	;or function key and goto E519
		leas	1,S				;lose A from stack
		adda	#$7C				;else add &7C (&7B +C) to convert codes B-F to 7-B
		pshs	A				;Push A
	IF INCLUDE_CURSOR_EDIT
		lda	sysvar_KEY_CURSORSTAT		;get cursor editing status
		bne	mos_interpret_keyb_byte		; if not 0 (normal) E515
	ENDIF
		lda	sysvar_OUTSTREAM_DEST		;else get character destination status
		rora					;get bit 1 into carry
		rora					;
		puls	A				;
		bcs	x_get_byte_from_buffer		;if carry is set E539 screen disabled
	IF INCLUDE_CURSOR_EDIT
		cmpa	#$87				;else is it COPY key
		beq	x_deal_with_COPY_key		;if so E5A6

		;TODO cursor editing
						; LE575
;;;	tay					;else Y=A
;;;	txa					;A=X
;;;	pha					;Push X 
;;;	tya					;get back Y
		pshs	X
		jsr	x_cursor_start				;execute edit action
		puls	X
;	pla					;restore X
;	tax					;
	ENDIF
mos_check_eco_get_byte_from_kbd			; LE577
		;	TODO econet
	tst	sysvar_ECO_OSRDCH_INTERCEPT	;check econet RDCH flag
	bpl	x_get_byte_from_key_string	;if not set goto E581
	lda	#$06				;else Econet function 6 
jmpNETV						; LE57E
	jmp	[NETV]				;to the Econet vector

********* get byte from key string **************************************
;on entry 0268 contains key length
;and 02C9 key string pointer to next byte

x_get_byte_from_key_string
		lda	sysvar_KEYB_SOFTKEY_LENGTH	;get length of keystring
		beq	x_get_byte_from_buffer		;if 0 E539 get a character from the buffer
		ldb	mosvar_SOFTKEY_PTR		;get soft key expansion pointer
		clra
		ldy	#soft_keys_start+1
		lda	D,Y				;get character from string
		inc	mosvar_SOFTKEY_PTR		;increment pointer
		dec	sysvar_KEYB_SOFTKEY_LENGTH	;decrement length
;; exit with carry clear
x_exit_with_carry_clear
		CLC					;	E592
LE593rts	
		rts					;	E593
;; ----------------------------------------------------------------------------
;; expand soft key strings
x_expand_soft_key_strings				; LE594
		puls	B				;restore original code
		andb	#$0F				;blank hi nybble to get key string number
		ldy	#soft_keys_ptrs
		lda	B,Y				;get start point
		sta	mosvar_SOFTKEY_PTR		;and store it
		jsr	x_get_keydef_length		;get string length in A
		sta	sysvar_KEYB_SOFTKEY_LENGTH	;and store it
		bra	mos_check_eco_get_byte_from_kbd	;if not 0 then get byte via E577 and exit
	IF INCLUDE_CURSOR_EDIT
;; deal with COPY key
x_deal_with_COPY_key
		pshs	X
		jsr	x_cursor_COPY				;	E5A8
		tsta
		lbeq	x_ERROR_EDITING				;	E5AC
		puls	X
		CLC						;	E5B1
		rts						;	E5B2
	ENDIF
;; ----------------------------------------------------------------------------
;; OSBYTE LOOK UP TABLE !!!!!ADDRESSES!!!!
mostbl_OSBYTE_LOOK_UP

		FDB	mos_OSBYTE_0			;	E5B3
		FDB	mos_OSBYTE_1AND6		;	E5B5
		FDB	mos_OSBYTE_2			;	E5B7
		FDB	mos_OSBYTE_3AND4		;	E5B9
		FDB	mos_OSBYTE_3AND4		;	E5BB
		FDB	mos_OSBYTE_5			;	E5BD
		FDB	mos_OSBYTE_1AND6		;	E5BF
		FDB	mos_OSBYTE_07			;	E5C1
		FDB	mos_OSBYTE_08			;	E5C3
		FDB	mos_OSBYTE_09			;	E5C5
		FDB	mos_OSBYTE_10			;	E5C7
		FDB	mos_OSBYTE_11			;	E5C9
		FDB	mos_OSBYTE_12			;	E5CB
		FDB	mos_OSBYTE_13			;	E5CD
		FDB	mos_OSBYTE_14			;	E5CF
		FDB	mos_OSBYTE_15			;	E5D1
		FDB	mos_OSBYTE_16			;	E5D3
		FDB	mos_OSBYTE_17			;	E5D5
		FDB	mos_OSBYTE_18			;	E5D7
		FDB	mos_OSBYTE_19			;	E5D9
		FDB	mos_OSBYTE_20			;	E5DB
		FDB	mos_OSBYTE_21			;	E5DD
OSBYTE1_END	equ	21
OSBYTE2_START	equ	117
mostbl_OSBYTE_LOOK_UP2
		FDB	mos_OSBYTE_117			;	E5DF
		FDB	mos_OSBYTE_118			;	E5E1
		FDB	mos_OSBYTE_119			;	E5E3
		FDB	mos_OSBYTE_nowt			;	E5E5
		FDB	mos_OSBYTE_121			;	E5E7
		FDB	mos_OSBYTE_122			;	E5E9
		FDB	mos_OSBYTE_123			;	E5EB
		FDB	mos_OSBYTE_124			;	E5ED
		FDB	mos_OSBYTE_125			;	E5EF
		FDB	mos_OSBYTE_126			;	E5F1
		FDB	mos_OSBYTE_nowt			;	E5F3
		FDB	mos_OSBYTE_nowt			;	E5F5
		FDB	mos_OSBYTE_129			;	E5F7
		FDB	mos_OSBYTE_130			;	E5F9
		FDB	mos_OSBYTE_131			;	E5FB
		FDB	mos_OSBYTE_132			;	E5FD
		FDB	mos_OSBYTE_133			;	E5FF
		FDB	mos_OSBYTE_134			;	E601
		FDB	mos_OSBYTE_135			;	E603
		FDB	mos_OSBYTE_136			;	E605
		FDB	mos_OSBYTE_nowt			;	E607
		FDB	mos_OSBYTE_nowt			;	E609
		FDB	mos_OSBYTE_nowt			;	E60B
		FDB	mos_OSBYTE_nowt			;	E60D
		FDB	mos_OSBYTE_nowt			;	E60F
		FDB	mos_OSBYTE_nowt			;	E611
		FDB	mos_OSBYTE_143			;	E613
		FDB	mos_OSBYTE_144			;	E615
		FDB	mos_OSBYTE_nowt			;	E617
		FDB	mos_OSBYTE_146			;	E619
		FDB	mos_OSBYTE_nowt			;	E60F
		FDB	mos_OSBYTE_148			;	E61D
		FDB	mos_OSBYTE_nowt			;	E61F
		FDB	mos_OSBYTE_150			;	E621
		FDB	mos_OSBYTE_nowt			;	E623
		FDB	mos_OSBYTE_nowt			;	E625
		FDB	mos_OSBYTE_nowt			;	E627
		FDB	mos_OSBYTE_nowt			;	E629
		FDB	mos_OSBYTE_nowt			;	E62B
		FDB	mos_OSBYTE_156			;	E62D		
		FDB	mos_OSBYTE_157			;	E62F
		FDB	mos_OSBYTE_nowt			;	E631
		FDB	mos_OSBYTE_nowt			;	E633
		FDB	mos_OSBYTE_160			;	E635
OSBYTE2_END	equ	160

		FDB	mos_OSBYTE_RW_SYSTEM_VARIABLE	;	E637
		FDB	mos_OSBYTE_nowt			;	E639
;; OSWORD LOOK UP TABLE !!!!!ADDRESSES!!!!
mostbl_OSWORD_LOOK_UP
		FDB	mos_OSWORD_0_read_line		;	E63B
		FDB	mos_OSWORD_1_rd_sys_clk		;	E63D
		FDB	mos_OSWORD_2_wr_sys_clk		;	E63F
		FDB	mos_OSWORD_3_rd_timer		;	E641
		FDB	mos_OSWORD_4_wr_int_timer	;	E643
		FDB	mos_OSWORD_nowt			;	E645
		FDB	mos_OSWORD_nowt			;	E647
		FDB	mos_OSWORD_7_SOUND		;	E649
		FDB	mos_OSWORD_8_ENVELOPE		;	E64B
		FDB	mos_OSWORD_nowt			;	E64D
		FDB	mos_OSWORD_nowt			;	E64F
		FDB	mos_OSWORD_nowt			;	E651
		FDB	mos_OSWORD_nowt			;	E653
		FDB	mos_OSWORD_nowt			;	E655
	IF MACH_CHIPKIT AND DOCHIPKIT_RTC
		FDB	mos_OSWORD_E_read_rtc
		FDB	mos_OSWORD_F_write_rtc

OSWORD_MAX			equ	15
	ELSE
OSWORD_MAX			equ	13
	ENDIF
OSBYTE_TABLE_OSBYTE_SIZE 	equ	mostbl_OSWORD_LOOK_UP - mostbl_OSBYTE_LOOK_UP

*ORIGINALTABLE*
;	FDB	mos_OSBYTE_0			;	E5B3
;	FDB	mos_OSBYTE_1AND6;	E5B5
;	FDB	mos_OSBYTE_2			;	E5B7
;	FDB	mos_OSBYTE_3AND4	;	E5B9
;	FDB	mos_OSBYTE_3AND4	;	E5BB
;	FDB	mos_OSBYTE_5		;	E5BD
;	FDB	mos_OSBYTE_1AND6;	E5BF
;	FDB	mos_OSBYTE_07			;	E5C1
;	FDB	mos_OSBYTE_08			;	E5C3
;	FDB	mos_OSBYTE_09			;	E5C5
;	FDB	mos_OSBYTE_10			;	E5C7
;	FDB	mos_OSBYTE_11;	E5C9
;	FDB	mos_OSBYTE_12;	E5CB
;	FDB	mos_OSBYTE_13			;	E5CD
;	FDB	mos_OSBYTE_14			;	E5CF
;	FDB	mos_OSBYTE_15			;	E5D1
;	FDB	mos_OSBYTE_16			;	E5D3
;	FDB	mos_OSBYTE_17			;	E5D5
;	FDB	mos_OSBYTE_18		;	E5D7
;	FDB	mos_OSBYTE_19		;	E5D9
;	FDB	mos_OSBYTE_20			;	E5DB
;	FDB	mos_OSBYTE_21			;	E5DD
;	FDB	mos_OSBYTE_117			;	E5DF
;	FDB	mos_OSBYTE_118			;	E5E1
;	FDB	mos_OSBYTE_119		;	E5E3
;	FDB	mos_OSBYTE_120			;	E5E5
;	FDB	mos_OSBYTE_121			;	E5E7
;	FDB	mos_OSBYTE_122			;	E5E9
;	FDB	mos_OSBYTE_123			;	E5EB
;	FDB	mos_OSBYTE_124			;	E5ED
;	FDB	mos_OSBYTE_125			;	E5EF
;	FDB	mos_OSBYTE_126			;	E5F1
;	FDB	LE035				;	E5F3
;	FDB	mos_OSBYTE_128			;	E5F5
;	FDB	LE713				;	E5F7
;	FDB	LE729				;	E5F9
;	FDB	mos_OSBYTE_131			;	E5FB
;	FDB	mos_OSBYTE_132			;	E5FD
;	FDB	mos_OSBYTE_133			;	E5FF
;	FDB	mos_OSBYTE_134			;	E601
;	FDB	mos_OSBYTE_135			;	E603
;	FDB	mos_OSBYTE_136			;	E605
;	FDB	mos_OSBYTE_137			;	E607
;	FDB	mos_OSBYTE_138			;	E609
;	FDB	LE034				;	E60B
;	FDB	mos_selects_ROM_filing_system	;	E60D
;	FDB	mos_selects_ROM_filing_system	;	E60F
;	FDB	x_mos_ENTER_ROM_X;	E611
;	FDB	mos_OSBYTE_143			;	E613
;	FDB	mos_OSBYTE_144			;	E615
;	FDB	mos_OSBYTE_145			;	E617
;	FDB	mos_OSBYTE_146			;	E619
;	FDB	mos_OSBYTE_147			;	E61B
;	FDB	mos_OSBYTE_148			;	E61D
;	FDB	mos_OSBYTE_149			;	E61F
;	FDB	mos_OSBYTE_150			;	E621
;	FDB	mos_OSBYTE_151			;	E623
;	FDB	mos_OSBYTE_152			;	E625
;	FDB	mos_OSBYTE_153			;	E627
;	FDB	mos_OSBYTE_154			;	E629
;	FDB	mos_OSBYTE_155			;	E62B
;	FDB	mos_OSBYTE_156			;	E62D
;	FDB	mos_OSBYTE_157			;	E62F
;	FDB	mos_OSBYTE_158			;	E631
;	FDB	mos_OSBYTE_159			;	E633
;	FDB	mos_OSBYTE_160		;	E635
;	FDB	mos_OSBYTE_RW_SYSTEM_VARIABLE	;	E637
;	FDB	mos_jmp_USERV			;	E639
;; OSWORD LOOK UP TABLE !!!!!ADDRESSES!!!!
;mostbl_OSWORD_LOOK_UP:
;	FDB	OSWORD_0_read_line;	E63B
;	FDB	mos_OSWORD_1_rd_sys_clk		;	E63D
;	FDB	mos_OSWORD_2_wr_sys_clk		;	E63F
;	FDB	mos_OSWORD_3_rd_timer		;	E641
;	FDB	mos_OSWORD_4_wr_int_timer	;	E643
;	FDB	mos_read_a_byte_from_IO_memory	;	E645
;	FDB	mos_write_a_byte_to_IO_memory	;	E647
;	FDB	mos_OSWORD_7_SOUND		;	E649
;	FDB	mos_OSWORD_8_ENVELOPE		;	E64B
;	FDB	mos_OSWORD_9			;	E64D
;	FDB	mos_OSWORD_10			;	E64F
;	FDB	mos_OSWORD_11			;	E651
;	FDB	mos_OSWORD_12			;	E653
;	FDB	mos_OSWORD_13			;	E655


mos_OSBYTE_nowt
		LDA	zp_mos_OSBW_A
		JSR	debug_print_hex
		TODO	"OSBYTE"

mos_OSWORD_nowt
		LDA	zp_mos_OSBW_A
		JSR	debug_print_hex
		TODO	"OSWORD"


mos_OSBYTE_136					; LE657
;mos_STAR_CODE_effectively:= * + 1		; *CODE effectively???
		CLRA					;	E657
;; ----------------------------------------------------------------------------
;; *LINE	  entry
mos_jmp_USERV
		jmp	[USERV]				;	E659
;; ----------------------------------------------------------------------------
;; OSBYTE  126  Acknowledge detection of ESCAPE condition
mos_OSBYTE_126
		ldx	#$00				;	E65C
		tst	zp_mos_ESC_flag			;	E65E
		bpl	mos_OSBYTE_124			;	E660
		lda	sysvar_KEYB_ESC_EFFECT		;	E662
		bne	LE671				;	E665
		CLI					;	E667
		sta	sysvar_SCREENLINES_SINCE_PAGE	;	E668
		jsr	mos_STAR_EXEC			;	E66B
		jsr	mos_flush_all_buffers				;	E66E
LE671		ldx	#$FF				;	E671
;; OSBYTE  124  Clear ESCAPE condition
mos_OSBYTE_124
		CLC					;	E673
;; OSBYTE  125  Set ESCAPE flag
mos_OSBYTE_125
		ror	zp_mos_ESC_flag			;	E674
;TODO: TUBE
;;	tst	sysvar_TUBE_PRESENT		;	E676
;;	bmi	LE67C				;	E679
		rts					;	E67B
; ----------------------------------------------------------------------------
LE67C		TODO	"TUBE ESCAPE"
;LE67C:	jmp	L0403				;	E67C
;; ----------------------------------------------------------------------------
;; OSBYTE  137  Turn on Tape motor
;mos_OSBYTE_137:
;	lda	sysvar_SERPROC_CTL_CPY		;	E67F
;	tay					;	E682
;	rol	a				;	E683
;	cpx	#$01				;	E684
;	ror	a				;	E686
;	bvc	setSerULA				;	E687
;; OSBYTE 08/07 set serial baud rates
mos_OSBYTE_08						; 	E689
		lda	#'8'				;A=ASCII 8
;; OSBYTE 08/07 set serial baud rates
mos_OSBYTE_07						; LE68B
		eora	#$3F				;converts ASCII 8 to 7 binary and ASCII 7 to 8 binary
		sta	zp_mos_OS_wksp2			;store result		
		lda	sysvar_SERPROC_CTL_CPY		;get serial ULA control register setting
		m_tay
		pshs	A
;;		ldb	zp_mos_OSBW_X--already set in dispatcher
		cmpb	#$09				;is it 9 or more?
		bhs	LE6AD				;if so exit
		lda	zp_mos_OS_wksp2
		ldx	#mostbl_SERIAL_BAUD_LOOK_UP
		anda	B,X				;and with byte from look up table
		sta	zp_mos_OS_wksp2+1		;store it
		puls	A				;get back old setting
		ora	zp_mos_OS_wksp2			;and or with Accumulator
		eora	zp_mos_OS_wksp2			;zero the three bits set true
		ora	zp_mos_OS_wksp2+1		;set up data read from look up table + bit 6
		ora	#$40				;
		eora	sysvar_RS423CASS_SELECT		;write cassette/RS423 flag
setSerULA						; LE6A7
		sta	sysvar_SERPROC_CTL_CPY		;	E6A7
	;TODO chipkit serial
	;TODO SBC09 serial
	IF MACH_BEEB
		sta	sheila_SERIAL_ULA		;	E6AA
	ENDIF
LE6AD		
LE6AE		leax	0,Y				;write new setting to X and Y
		rts					;and return

*************************************************************************
*                                                                       *
*       OSBYTE  9   Duration of first colour                            *
*                                                                       *
*************************************************************************
;on entry Y=0, X=new value
		; TODO: the next two need optimising
mos_OSBYTE_09					; LE6B0
		ldy	#1				;Y is incremented to 1
		CLC					;clear carry
;; OSBYTE  10   Duration of second colour; on entry Y=0 or 1 if from FX 9 call, X=new value 
mos_OSBYTE_10
		lda	sysvar_FLASH_SPACE_PERIOD,y	;get mark period count
		pshs	A				;push it
		lda	#0				; don't use CLR we need Cy preserved!
		pshs	A				; store 0 for hi byte of returned Y
		;;m_txa					;get new count
		stb	sysvar_FLASH_SPACE_PERIOD,y	;store it
		puls	Y				;get back original value
		;;m_tay					;put it in Y
		lda	sysvar_FLASH_CTDOWN		;get value of flash counter
		bne	LE6AD				;if not zero E6D1

		stb	sysvar_FLASH_CTDOWN		;else restore old value 
		lda	sysvar_VIDPROC_CTL_COPY		;get current video ULA control register setting
		pshs	CC				;push flags
		rora					;rotate bit 0 into carry, carry into bit 7
		puls	CC				;get back flags
		rola					;rotate back carry into bit 0
		sta	sysvar_VIDPROC_CTL_COPY		;store it in RAM copy
	IF MACH_BEEB | MACH_CHIPKIT
	; TODO: CHIPKIT - check this is the right register!
		sta	sheila_VIDULA_ctl			;and ULA control register
	ENDIF
		bra	LE6AD				;then exit via OSBYTE 7/8

 *************************************************************************
 *                                                                       *
 *       OSBYTE  2   select input stream                                 *
 *                                                                       *
 *************************************************************************
 
 ;on input X contains stream number
mos_OSBYTE_2
		; TODO SERIAL
;	txa					;	E6D3
;	and	#$01				;	E6D4
;	pha					;	E6D6
;	lda	sysvar_RS423_CTL_COPY		;	E6D7
;	rol	a				;	E6DA
;	cpx	#$01				;	E6DB
;	ror	a				;	E6DD
;	cmp	sysvar_RS423_CTL_COPY		;	E6DE
;	php					;	E6E1
;	sta	sysvar_RS423_CTL_COPY		;	E6E2
;	sta	sheila_ACIA_CTL				;	E6E5
;	jsr	LE173				;	E6E8
;	plp					;	E6EB
;	beq	LE6F1				;	E6EC
;	bit	LFE09				;	E6EE
;LE6F1:	ldx	sysvar_CURINSTREAM		;	E6F1
;	pla					;	E6F4
;	sta	sysvar_CURINSTREAM		;	E6F5
;	rts					;	E6F8

		; DB: just swap X with contents of CURINSTREAM
		lda	sysvar_CURINSTREAM
		pshs	A
		clr	,-S
		m_txa
		sta	sysvar_CURINSTREAM
		puls	X,PC

*************************************************************************
*                                                                       *
*       OSBYTE  13   disable events                                     *
*                                                                       *
*************************************************************************

        ;X contains event number 0-9
mos_OSBYTE_13
		clra					;	E6F9
*************************************************************************
*                                                                       *
*       OSBYTE  14   enable events                                      *
*                                                                       *
*************************************************************************

        ;X contains event number 0-9
mos_OSBYTE_14					; LE6FA
		cmpx	#$0A				;if X>9			
		bhs	LE6AE				;goto E6AE for exit			
		ldb	mosvar_EVENT_ENABLE,x		;else get event enable flag 
		m_tby					; TODO: use B?
		sta	mosvar_EVENT_ENABLE,x		;store new value in flag
		bra	LE6AD				;and exit via E6AD
;; OSBYTE  16   Select A/D channel; X contains channel number or 0 if disable conversion	 
mos_OSBYTE_16
		TODO	"ADC"
;	beq	LE70B				;	E706
;	jsr	mos_OSBYTE_17			;	E708
;LE70B:	lda	sysvar_ADC_MAX			;	E70B
;	stx	sysvar_ADC_MAX			;	E70E
;	tax					;	E711
;	rts					;	E712
;; ----------------------------------------------------------------------------

; OSBYTE 129   Read key within time limit; X and Y contains either time limit in centi seconds Y=&7F max ; or Y=&FF and X=-ve INKEY value 
mos_OSBYTE_129					; LE713
		tst	zp_mos_OSBW_Y			; check Y negative
		bmi	LE721				; if Y=&FF the E721
		CLI					; else allow interrupts
		jsr	OSBYTE_129_timed			; and go to timed routine
		bcs	LE71F_tay_c_rts			; if carry set then E71F
		m_tax					; then X=A
		clra					; A=0
LE71F_tay_c_rts	m_tay_c					; Y=A
		rts					; and return
;; ----------------------------------------------------------------------------
LE721		lda	zp_mos_OSBW_X			; A=X
		beq	mos_OSBYTE_129_machtype
		eora	#$7F				; convert to keyboard input
		m_tax					; X=A
		SEC
		jsr	jmpKEYV				; then scan keyboard
		rola					; put bit 7 into carry
LE729		ldx	#$FFFF				; X=&FF
		ldy	#$FFFF				; Y=&FF
		bcs	LE731				; if bit 7 of A was set goto E731 (RTS)
		leax	1,X				; else X=0
		leay	1,Y				; and Y=0
LE731		rts					; and exit
mos_OSBYTE_129_machtype
		ldx	#mos_MACHINE_TYPE_BYTE
		ldy	#$FFFF
		rts
;; ----------------------------------------------------------------------------
;; check occupancy of input or free space of output buffer; X=buffer number ; Buffer number  Address	    Flag    Out pointer	    In pointer ; 0=Keyboard	3E0-3FF		2CF	2D8		2E1 ; 1=RS423 Input  A00-AFF	     2D0     2D9	 
;x_check_buffer_space:
;	txa					;	E732
;	eor	#$FF				;	E733
;	tax					;	E735
;	cpx	#$02				;	E736
LE738		CLV				;	E738
		bra	x_mos_CNPV			;	E739
x_mos_SEV_and_CNPV					; LE73B
		orcc	#CC_V+CC_C+CC_N
x_mos_CNPV						; LE73E
		jmp	[CNPV]				;	E73E
;; ----------------------------------------------------------------------------
;; check RS423 input buffer
	; old API return Cy = 1 when buffer > minimum in BUF_EXT
	; new API return Cy = 0 when buffer > minimum in BUF_EXT
x_check_RS423_input_buffer_API
	SEC					;	E741
	ldx	#$01				;X=1 to point to buffer
	jsr	LE738				;and count it
;;	cmpy	#$01				;if the hi byte of the answer is 1 or more
;;	bcs	LE74E				;then Return
;;	cmpx	sysvar_RS423_BUF_EXT		;else compare with minimum buffer space
;;LE74E	rts					;and exit
	ldb	sysvar_RS423_BUF_EXT
	stb	,-S
	clr	,-S
	cmpx	,S++
	rts
;; ----------------------------------------------------------------------------
;; OSBYTE 128  READ ADC CHANNEL; ON Entry: X=0		    Exit Y contains number of last channel converted ; X=channel number	      X,Y contain 16 bit value read from channe ; X<0 Y=&FF		 X returns information about various buffers ; X=&FF (key
;mos_OSBYTE_128:
;	bmi	x_check_buffer_space		;	E74F
;	beq	LE75F				;	E751
;	cpx	#$05				;	E753
;	bcs	LE729				;	E755
;	ldy	adc_CH4_LOW,x			;	E757
;	lda	oswksp_OSWORD0_MAX_CH,x		;	E75A
;	tax					;	E75D
;	rts					;	E75E
;; ----------------------------------------------------------------------------
;LE75F:	lda	sheila_SYSVIA_orb		;	E75F
;	ror	a				;	E762
;	ror	a				;	E763
;	ror	a				;	E764
;	ror	a				;	E765
;	eor	#$FF				;	E766
;	and	#$03				;	E768
;	ldy	adc_CH_LAST			;	E76A
;	stx	adc_CH_LAST			;	E76D
;	tax					;	E770
;	rts					;	E771
;; ----------------------------------------------------------------------------
;; pointed to by default BYTEV
mos_default_BYTEV_handler
		pshs	D,CC
		SEI					; disable interrupts
		sta	zp_mos_OSBW_A			; store A,X,Y in zero page       
		sty	zp_mos_OSBW_Y			;        
		STX_B	zp_mos_OSBW_X			;        
		ldx	#$07				; X=7 to signal osbyte is being attempted
		cmpa	#OSBYTE2_START			; if A=0-116
		blo	x_Process_OSBYTE_SECTION_1	; then E7C2
		cmpa	#161				; if A<161 
		blo	x_Process_OSBYTE_SECTION_2	; then E78E
		cmpa	#166				; if A=161-165
		blo	mos_exec_BYTEV_from_osword_gtMAX; then EC78
		CLC					; clear carry

mos_exec_BYTEV_from_osword_gt224		; LE78A enters here from above with X=7, carry clear, or from OSWORD with X=8 and carry set, A>=224
		lda	#OSBYTE2_END + 1		; A=&A1
		adca	#$00				;
;; process osbyte calls 117 - 160
x_Process_OSBYTE_SECTION_2
		suba	#OSBYTE2_START - OSBYTE1_END - 1;convert to &16 to &41 (22-65) (OSBYTE 117 to 160) or &42 for OSBYTE > 165, &43 for OSWORD > 224
LE791
		asla					;	E791
		SEC					;	E792
		STY_B	zp_mos_OSBW_Y			; store Y - may have been set in 
mos_exec_BYTEV_from_osword_leMAX			; LE793
		;TODO ECONET, this would need to go back in WORDV too for econet!
;;	bit	sysvar_ECO_OSBW_INTERCEPT	;read econet intercept flag
;;	bpl	LE7A2				;if no econet intercept required E7A2
;;	txa					;else A=X
;;	clv					;V=0
;;	jsr	jmpNETV				; to JMP via ECONET vector
;;	bvs	LE7BC				;if return with V set E7BC

LE7A2		ldx	#mostbl_OSBYTE_LOOK_UP
		tfr	a,b
		abx
		ldd	,X				;get address from table
		std	zp_mos_OS_wksp2			;store it
		lda	zp_mos_OSBW_A			;restore A      
		LDY_B	zp_mos_OSBW_Y			;Y
		bcs	LE7B6				;if carry is set E7B6
;;	ldy	#$00				;else
		lda	[zp_mos_OSWORD_X]		;get value from address pointed to by &F0/1 (Y,X) - CHECK new API
		ldx	zp_mos_OSBW_Y			; get full 16 bit X for OSWORD
		SEC					;set carry
		bra	1F
LE7B6		
		LDX_B	zp_mos_OSBW_X
1		ldb	zp_mos_OSBW_X			;pass B=X : DB: extra new api to
		jsr	[zp_mos_OS_wksp2]		;call &FA/B
LE7BC		rora					;C=bit 0
		puls	CC				;get back flags
		rola					;bit 0=Carry
		CLV					;clear V
		puls	D,PC				;get back A
						;and exit
;; ----------------------------------------------------------------------------
;; Process OSBYTE CALLS BELOW &75
x_Process_OSBYTE_SECTION_1
		ldy	#$00				;	E7C2
		cmpa	#$16				;	E7C4
		blo	LE791				;	E7C6
mos_exec_BYTEV_from_osword_gtMAX
;;;	php					;	E7C8
;;;	php					;	E7C9
;;;LE7CA:	pla					;	E7CA
;;;	pla					;	E7CB

		; NOTE X has been set to 7 or 8 (osbyte or osword) or 8 from make a sound if unknown channel number
		m_txb					; TODO - sort this out pass B around?
mos_do_ukOSWORD
		jsr	mos_OSBYTE_143_b_cmd_x_param	; pass service call 7/8 to ROMS for unknown osbyte/word
		bne	LE7D6				; if ne return with C and N set
		LDX_B	zp_mos_OSBW_X			; else get original X register
		jmp	LE7BC				;	E7D3
;; ----------------------------------------------------------------------------
LE7D6		puls	D,CC				;	E7D6
		orcc	#CC_C+CC_N			; set C and N
		rts					;	E7DB
;; ----------------------------------------------------------------------------
;LE7DC:	lda	zp_mos_cfs_critical		;	E7DC
;	bmi	LE812				;	E7DE
;	lda	#$08				;	E7E0
;	and	zp_cfs_w			;	E7E2
;	bne	LE7EA				;	E7E4
;	lda	#$88				;	E7E6
;	and	zp_fs_s+11			;	E7E8
;LE7EA:	rts					;	E7EA


 **************************************************************************
 **************************************************************************
 **                                                                      **
 **      OSWORD  DEFAULT ENTRY POINT                                     **
 **                                                                      **
 **      pointed to by default WORDV                                     **
 **                                                                      **
 **************************************************************************
 **************************************************************************

; NOTE: OSWORD API change where X is the pointer to block!

mos_WORDV_default_entry				; LE7EB
		pshs	D,CC				;Push A
						;Push flags
		SEI					;disable interrupts
		sta	zp_mos_OSBW_A			;store A,X,Y
		stx	zp_mos_OSBW_Y			;NOTE: STORE X in Y/X pointer area!
		ldx	#8				; indicate coming from OSWORD
		cmpa	#$E0				;if A=>224
		bhs	1F				;then E78A with carry set

		cmpa	#OSWORD_MAX				;else if A=>14
		bhi	2F				;else E7C8 with carry set pass to ROMS & exit

		asla
		adda	#OSBYTE_TABLE_OSBYTE_SIZE
		jmp	mos_exec_BYTEV_from_osword_leMAX


1
		SEC
		lbra	mos_exec_BYTEV_from_osword_gt224
2
		SEC
		bra	mos_exec_BYTEV_from_osword_gtMAX

;; read a byte from I/O memory; block of 4 bytes set atFDBess pointed to by 00F0/1 (Y,X) ; XY +0  ADDRESS of byte ; +4	 on exit byte read 
;mos_read_a_byte_from_IO_memory:
;	jsr	x_set_up_data_block		;	E803
;	lda	(zp_mos_X+1,x)			;	E806
;	sta	(zp_mos_OSBW_X),y		;	E808
;	rts					;	E80A
;; ----------------------------------------------------------------------------
;; write a byte to I/O memory; block of 5 bytes set atFDBess pointed to by 00F0/1 (Y,X) ; XY +0  ADDRESS of byte ; +4	byte to be written 
;mos_write_a_byte_to_IO_memory:
;	jsr	x_set_up_data_block		;	E80B
;	lda	(zp_mos_OSBW_X),y		;	E80E
;	sta	(zp_mos_X+1,x)			;	E810
;LE812:	lda	#$00				;	E812
;	rts					;	E814
;; ----------------------------------------------------------------------------
;; : set up data block
;x_set_up_data_block:
;	sta	zp_mos_OS_wksp2			;	E815
;	iny					;	E817
;	lda	(zp_mos_OSBW_X),y		;	E818
;	sta	zp_mos_OS_wksp2+1		;	E81A
;	ldy	#$04				;	E81C
;LE81E:	ldx	#$01				;	E81E
;	rts					;	E820
;; ----------------------------------------------------------------------------
;; read OS version number
mos_OSBYTE_0
		bne	osverinx
		DO_BRK	$F7, "OS 1.29"
osverinx	ldx	#17				; As suggested by JGH, see email of 27/17 and http://beebwiki.mdfs.net/OSBYTE_&00
		rts




;; make a sound; block of 8 bytes set atFDBess pointed to by 00F0/1  ; XY +0  Channel or +0=Flush, Channel:+1=Hold,Sync ; 2  Amplitude	 ; 4  Pitch ; 6	 Duration ; Y=0 on entry 
mos_OSWORD_7_SOUND
	IF INCLUDE_SOUND
		ldy	zp_mos_OSBW_Y
		lda	1,Y				; get high byte of channel # (not little endian!)
		cmpa	#$FF
		beq	x_speech_handling_routine	;if its &FF goto speech
		cmpa	#$20				;else if>=&20 set carry
		ldb	#$08				;B=8 for unrecognised OSWORD call via osbyte 143
		bhs	mos_do_ukOSWORD			;and if carry set off to E7CA to offer to ROMS 

		clra					; note must clra here or it will clear C returned next
		jsr	snd_test_H1orF1_API		;return with Carry set if Flush=1:B=Channel#
		orb	#$04				;convert to buffer number
		tfr	D,X				; X = buffer #
		bcc	LE848				;and if carry clear (ex E8C9) then E848

		jsr	x_Buffer_handling2		;else flush buffer

LE848
		ldy	zp_mos_OSBW_Y
		leay	1,Y
		jsr	snd_test_H1orF1_API		;returns with carry set if H=1;B=S
		stb	zp_mos_OS_wksp2			;Sync number =&FA
		pshs	CC				;save flags
		lda	5,Y				;Get Duration byte
		sta	,-S				;push it
		lda	3,Y				;get pitch byte
		sta	,-S				;push it
		lda	1,Y				;get amplitude byte
		rola					;H now =bit 0 (carry shifted)
		suba	#$02				;subract 2
		asla					;multiply by 4
		asla					;
		ora	zp_mos_OS_wksp2			;add S byte (0-3)
						;at this point bit 7=0 for an envelope
						;bits 3-6 give envelope -1, or volume +15 
						;(i.e.complemented)
						;bit 2 gives H
						;bits 0-1 =Sync
		jsr	x_INSV_flashiffull	;transfer to buffer
		bcc	LE887				;if C clear on exit succesful transfer so E887
LE869		leas	2,S				;else get back
						;stored values
	ENDIF
		puls	CC,PC				;


;; read VDU status

mos_OSBYTE_117
		LDX_B	zp_vdu_status			;	E86C
		rts					;	E86E
	IF INCLUDE_MAIN_VDU
;; ----------------------------------------------------------------------------
;; set up sound data for Bell
mos_VDU_7					; LE86F
		pshs	CC				;push P
		SEI					;bar interrupts
		ldb	sysvar_BELL_CH			;get bell channel number in A
		andb	#$07				; (bits 0-3 only set)
		orb	#$04				;set bit 2
		clra					;X=A = bell channel number +4=buffer number
		tfr	D,X
		lda	sysvar_BELL_ENV			;get bell amplitude/envelope number
		jsr	[INSV]				;store it in buffer pointed to by X
		lda	sysvar_BELL_DUR			;get bell duration
		sta	,-S
		lda	sysvar_BELL_FREQ		;get bell frequency
		sta	,-S
LE887		SEC
		ror	snd_q_occupied-4,x		;and pass into bit 7 to warn that channel is active
		bra	snd_insv2bytesfromstack
	ENDIF
;; :speech handling routine
x_speech_handling_routine
		TODO	"x_speech_handling_routine"
;	php					;	E88D
;	iny					;	E88E
;	lda	(zp_mos_OSBW_X),y		;	E88F
;	pha					;	E891
;	iny					;	E892
;	lda	(zp_mos_OSBW_X),y		;	E893
;	pha					;	E895
;	ldy	#$00				;	E896
;	lda	(zp_mos_OSBW_X),y		;	E898
;	ldx	#$08				;	E89A
;	jsr	x_INSV_flashiffull;	E89C
;	bcs	LE869				;	E89F
;	ror	mosbuf_buf_busy+8		;	E8A1
snd_insv2bytesfromstack				; LE8A4
		lda	,S+				; get back byte 
		jsr	jmpINSV				; enter it in buffer X
		lda	,S+				; get back next
		jsr	jmpINSV				; and enter it again
		puls	CC,PC				; get back flags and exit
;; ----------------------------------------------------------------------------


*************************************************************************
 *                                                                       *
 *       OSWORD  08   ENTRY POINT                                        *
 *                                                                       *
 *       define envelope                                                 *
 *                                                                       *
 *************************************************************************
 ;block of 14 bytes set at address pointed to by 00F0/1 
 ;XY +0  Envelope number, also in A
 ;    1  bits 0-6 length of each step in centi-secsonds bit 7=0 auto repeat
 ;    2  change of Pitch per step (-128-+127) in section 1
 ;    3  change of Pitch per step (-128-+127) in section 2
 ;    4  change of Pitch per step (-128-+127) in section 3
 ;    5  number of steps in section 1 (0-255)
 ;    6  number of steps in section 2 (0-255)
 ;    7  number of steps in section 3 (0-255)
 ;    8  change of amplitude per step during attack  phase (-127 to +127)
 ;    9  change of amplitude per step during decay   phase (-127 to +127)
 ;   10  change of amplitude per step during sustain phase (-127 to +127)
 ;   11  change of amplitude per step during release phase (-127 to +127)
 ;   12  target level at end of attack phase   (0-126)
 ;   13  target level at end of decay  phase   (0-126)
mos_OSWORD_8_ENVELOPE
	IF INCLUDE_SOUND
		ldb	,X+
		decb					;set up appropriate displacement to storage area
		andb	#3
		aslb					;A=(A-1)*16 or 15
		aslb					;
		aslb					;
		aslb					;
		ora	#$0F				;
		leay	,X
		ldx	#snd_envelope_defs
		abx
		ldb	#13
1		lda	,Y+
		sta	,X+
		decb
		bne	1B
		clr	,X+
		clr	,X+
		clr	,X
	ENDIF
		rts
;; ----------------------------------------------------------------------------

	IF INCLUDE_SOUND
		; API change, X is point to high byte, Carry is set if H>=1, returns channel # in B
snd_test_H1orF1_API				; LE8C9
		ldb	,Y				; get byte
		cmpb	#$10				; is it greater than 15, if so set carry
		andb	#$03				; and 3 to clear bits 2-7
						; increment Y
	IF CPU_6809
		pshs	CC,A
		lda	0,S
		eora	#1				; flip carry
		sta	0,S
		puls	CC,A,PC				; and exit
	ELSE
		pshs	CC
		eim	#1, 0,S
		puls	CC,PC				; and exit
	ENDIF
	ENDIF ; INCLUDE_SOUND
;; ----------------------------------------------------------------------------
;; read interval timer
mos_OSWORD_3_rd_timer
		ldy	#oswksp_OSWORD3_CTDOWN+5	; point 1 after end
		bra	LE8D8
;; read system clock
mos_OSWORD_1_rd_sys_clk
		ldy	#sysvar_BREAK_LAST_TYPE+5	; point 1 after end
		ldb	sysvar_TIMER_SWITCH
		leay	B,Y
LE8D8		ldb	#4
LE8DA		lda	,-Y
		sta	,X+
		decb					;	E8E0
		bpl	LE8DA				;	E8E1
LE8E3		rts					;	E8E3
;; ----------------------------------------------------------------------------
;; write interval timer
mos_OSWORD_4_wr_int_timer				; LE8E4
		ldb	#$0F				; offset between clock and timer
		bra	LE8EE				; jump to E8EE ALWAYS!!
; write system clock
mos_OSWORD_2_wr_sys_clk
		ldb	sysvar_TIMER_SWITCH		; get current clock store pointer (A/5)
		eorb	#$0F				; and invert to get inactive timer(5/A)
		CLC					; clear carry
LE8EE		stb	,-S				; store A
		ldx	#oswksp_TIME-5
		abx
		ldb	#$04				; Y=4
		ldy	zp_mos_OSBW_Y
1		lda	b,y				; and transfer all 5 bytes
		sta	,x+				; to the clock or timer
		decb					; 
		bpl	1B				; if Y>0 then E8F2
		ldb	,S+				; get back stack
		bcs	2F				; if set (write to timer) E8E3 exit
		stb	sysvar_TIMER_SWITCH		; write back current clock store
2		rts					; and exit



mos_OSWORD_0_read_line						; LE902
		ldb	#$04
		ldy	#oswksp_OSWORD0_MAX_CH-4
1		lda	B,X				;transfer bytes 4,3,2 to 2B3-2B5
		sta	B,Y				;
		decb					;decrement Y
		cmpb	#$02				;until Y=1
		bhs	1B				;
		ldy	,X				;get address of input buffer
		clr	sysvar_SCREENLINES_SINCE_PAGE	;Y=0 store in print line counter for paged mode
		CLI					;allow interrupts
		clrb					;zero counter
		bra	OSWORD_0_read_line_loop_read				;Jump to E924

OSWORD_0_read_line_loop_bell				; LE91D
		lda	#$07				;A=7
OSWORD_0_read_line_loop_inc
		incb					;increment Y
		leay	1,Y
OSWORD_0_read_line_loop_echo				; LE921
		jsr	OSWRCH				;and call OSWRCH 
OSWORD_0_read_line_loop_read				; LE924
		jsr	OSRDCH				;else read character  from input stream
		bcs	OSWORD_0_read_line_skip_err	;if carry set then illegal character or other error
							;exit via E972
	IF CPU_6809
		pshs	A
		lda	sysvar_OUTSTREAM_DEST		;A=&27C get output stream *FX3 
		bita	#2
		puls	A
	ELSE
		tim	#$02, sysvar_OUTSTREAM_DEST
	ENDIF
		bne	OSWORD_0_read_line_skip_novdu	;if Carry set E937
		tst	sysvar_VDU_Q_LEN		;get number of items in VDU queue
		bne	OSWORD_0_read_line_loop_echo	;if not 0 output character and loop round again
OSWORD_0_read_line_skip_novdu				; LE937	
		cmpa	#$7F				;if character is not delete
		bne	OSWORD_0_read_line_skip_notdel				;goto E942
		cmpb	#$00				;else is Y=0
		beq	OSWORD_0_read_line_loop_read	;and goto E924
		decb					;decrement Y and counter
		leay	-1,Y				
		bra	OSWORD_0_read_line_loop_echo	;print backspace
OSWORD_0_read_line_skip_notdel				; LE942
		cmpa	#$15				;is it delete line &21
		bne	OSWORD_0_read_line_skip_not_ctrl_u				;if not E953
		tstb					;if B=0 we are still reading first
							;character
		beq	OSWORD_0_read_line_loop_read	;so E924
		lda	#$7F				;else output DELETES
							; LE94B
1		jsr	OSWRCH				;delete printed chars
		leay	-1,Y				;decrement pointer
		decb					;and counter
		bne	1B				;loop until pointer ==0
		bra	OSWORD_0_read_line_loop_read	;go back to reading from input stream

OSWORD_0_read_line_skip_not_ctrl_u			; LE953
		sta	,y				;store character in designated buffer
		cmpa	#$0D				;is it CR?
		beq	OSWORD_0_read_line_skip_return	;if so E96C
		cmpb	oswksp_OSWORD0_LINE_LEN		;else check the line length
		bhs	OSWORD_0_read_line_loop_bell	;if = or greater loop to ring bell
		cmpa	oswksp_OSWORD0_MIN_CH		;check minimum character
		blo	OSWORD_0_read_line_loop_echo	;if less than ignore and don't increment
		cmpa	oswksp_OSWORD0_MAX_CH		;check maximum character
		bhi	OSWORD_0_read_line_loop_echo	;if higher then ignore and don't increment
		incb
		leay	1,Y
		bra	OSWORD_0_read_line_loop_echo	;if less than ignore and don't increment
OSWORD_0_read_line_skip_return				; LE96C		
		jsr	OSNEWL				;output CR/LF   
		jsr	[NETV]				;call Econet vector
OSWORD_0_read_line_skip_err				; LE972
		m_tby
		lda	zp_mos_ESC_flag			;A=ESCAPE FLAG
		rola					;put bit 7 into carry 
		rts					;and exit routine
;; ----------------------------------------------------------------------------
;; SELECT PRINTER TYPE
mos_OSBYTE_5
		CLI					;allow interrupts briefly
		SEI					;bar interrupts
		tst	zp_mos_ESC_flag			;check if ESCAPE is pending
		bmi	1F				;if it is E9AC
		tst	mosbuf_buf_busy+3		;else check bit 7 buffer 3 (printer)
		bpl	mos_OSBYTE_5			;if not empty bit 7=0 E976
		jsr	LPT_NETV_then_UPTV		;check for user defined routine
		ldy	#$00				;Y=0
		sty	zp_mos_OSBW_Y			;F1=0   


mos_OSBYTE_130					; DB: new
		ldx	#$FFFF
		ldy	#$FFFF
1		rts



 *************************************************************************
 *                                                                       *
 *       OSBYTE  01   ENTRY POINT                                        *
 *                                                                       *
 *       READ/WRITE USER FLAG (&281)                                     *
 *                                                                       *
 *          AND                                                          *
 *                                                                       *
 *       OSBYTE  06   ENTRY POINT                                        *
 *                                                                       *
 *       SET PRINTER IGNORE CHARACTER                                    *
 *                                                                       *
 *************************************************************************
 ; A contains osbyte number
 ; X contains value
 ; Y = 0 * despite what it says in the userguide!
mos_OSBYTE_1AND6
		ora	#$F0				;A=osbyte +&F0
		bra	LE99A				;JUMP to E99A


 *************************************************************************
 *                                                                       *
 *       OSBYTE  0C   ENTRY POINT                                        *
 *                                                                       *
 *       SET  KEYBOARD AUTOREPEAT RATE                                   *
 *                                                                       *
 *************************************************************************
mos_OSBYTE_12
		bne	mos_OSBYTE_11			;if &F0<>0 goto E995
		ldx	#$32				;if X=0 in original call then X=32
		stx	sysvar_KEYB_AUTOREP_DELAY	;to set keyboard autorepeat delay ram copy
		ldx	#$08				;X=8
;; SET  KEYBOARD AUTOREPEAT DELAY
mos_OSBYTE_11
		adda	#$D0				;	E995
;; ENABLE/DISABLE CURSOR EDITING
mos_OSBYTE_3AND4
		adda	#$E9				;	E998
LE99A
		STX_B	zp_mos_OSBW_X			;	E99A

*************************************************************************
*                                                                       *
*       OSBYTE  A6-FF   ENTRY POINT                                     *
*                                                                       *
*       READ/ WRITE SYSTEM VARIABLE OSBYTE NO. +&190                    *
*                                                                       *
*************************************************************************
mos_OSBYTE_RW_SYSTEM_VARIABLE
		ldx	#sysvar_OSVARADDR-$A6
		tfr	A,B				;Y=A+&190
		cmpb	#$B0
		blo	mos_OSBYTE_RW_SYSTEM_VARIABLE_BE
		abx
		ldd	,x				;i.e. A=&190 +osbyte call!
		sta	,-S
		anda	zp_mos_OSBW_Y			;new value = OLD value AND Y EOR X!     
		eora	zp_mos_OSBW_X			;       
		sta	,x+				;store it
		lda	,S				; bet back original a
		clr	,-S				; stacked Y
		exg	a,b
		std	,--S				; stack this as X
		puls	Y,X,PC

mos_OSBYTE_RW_SYSTEM_VARIABLE_BE		; as above but frig for big endian
		eorb	#1				; read these the opposite way round as they're big endian
		abx
		ldd	-1,X				;i.e. A=&190 +osbyte call and the byte before it (will give wrong answer in Y on odd accesses!)
		stb	,-S				;push original value on stack
		andb	zp_mos_OSBW_Y			;new value = OLD value AND Y EOR X!     
		eorb	zp_mos_OSBW_X			;       
		stb	,X				;store it
		ldb	,S				; get back original B
		clr	,-S				; this as high
		std	,--S				;put Y return into top of returned X
		puls	Y,X,PC



;; ----------------------------------------------------------------------------
;; SERIAL BAUD RATE LOOK UP TABLE
mostbl_SERIAL_BAUD_LOOK_UP			; LE9AD
		FCB	$64					; % 01100100      75
		FCB	$7F					; % 01111111     150
		FCB	$5B					; % 01011011     300
		FCB	$6D					; % 01101101    1200
		FCB	$C9					; % 11001001    2400
		FCB	$F6					; % 11110110    4800
		FCB	$D2					; % 11010010    9600
		FCB	$E4					; % 11100100   19200    
		FCB	$40					; % 01000000

*************************************************************************
*                                                                       *
*       OSBYTE  &13   ENTRY POINT                                       *
*                                                                       *
*       Wait for Animation                                              *
*                                                                       *
*************************************************************************



mos_OSBYTE_19						; LE9B6
		lda	sysvar_CFSTOCTR			;read vertical sync counter
1		CLI					;allow interrupts briefly
		SEI					;bar interrupts
		cmpa	sysvar_CFSTOCTR			;is it 0 (Vertical sync pulse)
		beq	1B				;no then E9B9
;; READ VDU VARIABLE; X contains the variable number ; 0 =lefthand column in pixels current graphics window ; 2 =Bottom row in pixels current graphics window ; 4 =Right hand column in pixels current graphics window ; 6 =Top row in pixels current graphics win
		; TODO: swap certain bytes here
mos_OSBYTE_160
		lda	vduvar_GRA_WINDOW_LEFT+1,x	;	E9C0
		m_tay
		lda	vduvar_GRA_WINDOW_LEFT,x	;	E9C3
		jmp	mos_tax
;		m_tax					;	E9C6
;		rts					;	E9C7
;; ----------------------------------------------------------------------------
;; RESET SOFT KEYS

*** <doc>
*** <osbyte num="18">
***  <name>Reset soft keys</name>
***  <params>No parameters</params>
***  <descr>This call clears the soft key buffer so the character strings are no longer available</descr>
***  <exit>
***    <preserves>X Y</preserves>
***    <undefined>A C</undefined>
***  </exit>
*** </osbyte>

mos_OSBYTE_18
		pshs	X
		lda	#$10				;	E9C8
		sta	sysvar_KEYB_SOFT_CONSISTANCY	;	E9CA
		ldx	#soft_keys_start		;	E9CD
		clrb
1		sta	b,x				;	E9CF
		incb					;	E9D2
		bne	1B				;	E9D3
		clr	sysvar_KEYB_SOFT_CONSISTANCY	;	E9D5
		puls	X,PC				;	E9D8
;; ----------------------------------------------------------------------------
 *************************************************************************
 *                                                                       *
 *        OSBYTE &76 (118) SET LEDs to Keyboard Status                   *
 *                                                                       *
 *************************************************************************
                          ;osbyte entry with carry set
                         ;called from &CB0E, &CAE3, &DB8B

mos_OSBYTE_118					; LE9D9
		pshs	CC				;PUSH P
		SEI					;DISABLE INTERUPTS
		lda	#$40				;switch on CAPS and SHIFT lock lights
		jsr	x_keyb_leds_test_esc		;via subroutine
		bmi	LE9E7				;if ESCAPE exists (M set) E9E7
		ANDCC	#~(CC_C + CC_V)			;else clear V and C
						;before calling main keyboard routine to
		jsr	[KEYV]				;switch on lights as required
LE9E7		puls	CC				;get back flags
		rola					;and rotate carry into bit 0
		rts					;Return to calling routine
;; ----------------------------------------------------------------------------
;; Turn on keyboard lights and Test Escape flag; called from &E1FE, &E9DD  ;  
x_keyb_leds_test_esc
		bcc	LE9F5
	IF INCLUDE_KEYBOARD
		ldb	#$07
		stb	sheila_SYSVIA_orb
		decb
		stb	sheila_SYSVIA_orb
	ENDIF
LE9F5		tst	zp_mos_ESC_flag
		rts
	IF MACH_BEEB | MACH_CHIPKIT
;; ----------------------------------------------------------------------------
mos_poke_SYSVIA_orb
		pshs	CC
		SEI
		sta	sheila_SYSVIA_orb
		puls	CC,PC
	ENDIF

*************************************************************************
*                                                                       *
*       OSBYTE 154 (&9A) SET VIDEO ULA                                  *       
*                                                                       *
*************************************************************************
mos_OSBYTE_154
		m_txa					;osbyte entry! X transferred to A thence to
mos_VIDPROC_set_CTL
	IF INCLUDE_MAIN_VDU
		pshs	CC				;save flags
		SEI					;disable interupts
		sta	sysvar_VIDPROC_CTL_COPY		;save RAM copy of new parameter
		sta	sheila_VIDULA_ctl		;write to control register
	IF MACH_CHIPKIT
		anda	#$01
		sta	sheila_VIDULA_pixeor		;RAMDAC flash
	ENDIF
		lda	sysvar_FLASH_MARK_PERIOD	;read  space count
		sta	sysvar_FLASH_CTDOWN		;set flash counter to this value
		puls	CC				;get back status
	ENDIF
		rts					;and return

*************************************************************************
*                                                                       *
*        OSBYTE &9B (155) write to pallette register                    *       
*                                                                       *
*************************************************************************
                ;entry X contains value to write

mos_OSBYTE_155
		m_txa					;	EA10
write_pallette_reg
		eora	#$07				;	EA11
		pshs	CC				;	EA13
	IF INCLUDE_MAIN_VDU
		SEI					;	EA14
		sta	sysvar_VIDPROC_PAL_COPY		;	EA15
		sta	sheila_VIDULA_pal		;	EA18
	ENDIF
		puls	CC,PC				;	EA1B
;; ----------------------------------------------------------------------------
;; A contains first non blank character
mos_CLC_GSINIT
		CLC					;	EA1D
mos_GSINIT
		ror	zp_mos_GSREAD_quoteflag		;Rotate moves carry to &E4
		jsr	mos_skip_spaces_at_X		;get character from text
		cmpa	#'"'				;check to see if its '"'
		beq	2F				;if so EA2A (carry set)
		leax	-1,X				;decrement X
		CLC					;clear carry
		bra	1F
2		SEC
1		ror	zp_mos_GSREAD_quoteflag		;move bit 7 to bit 6 and put carry in bit 7
		cmpa	#$0D				;check to see if its CR to set Z
		rts					;and return
;; ----------------------------------------------------------------------------
;; new API - read string at X (should have been inited with GSINIT)  
mos_GSREAD
		pshs	B
		lda	#$00					; A=0
LEA31		sta	zp_mos_GSREAD_characc			; store A
		lda	,X					; peek first character
		cmpa	#$0D					; is it CR
		bne	GSREAD_notCR1				; if not goto EA3F
		tst	zp_mos_GSREAD_quoteflag			; if bit 7=1 no 2nd '"' found
		bmi	brkBadString				; goto EA8F
		bra	LEA5A					; if not EA5A
GSREAD_notCR1							; LEA3F
		cmpa	#' '					; is less than a space?
		blo	brkBadString				; goto EA8F
		bne	LEA4B					; if its not a space EA4B
		tst	zp_mos_GSREAD_quoteflag			; is bit 7 of &E4 =1
		bmi	LEA89					; if so goto EA89
		ldb	#$40
		andb	zp_mos_GSREAD_quoteflag
		beq	LEA5A					; if bit 6 = 0 EA5A
LEA4B		cmpa	#'"'					; is it '"'
		bne	LEA5F					; if not EA5F
		tst	zp_mos_GSREAD_quoteflag			; if so and Bit 7 of &E4 =0 (no previous ")
		bpl	LEA89					; then EA89
		leax	1,X					; else point at next character
		lda	,X					; get it
		cmpa	#'"'					; is it '"'
		beq	LEA89					; if so then EA89
LEA5A		jsr	mos_skip_spaces_at_X			; read a byte from text
		SEC						; and return with
		puls	B,PC					; carry set
;; ----------------------------------------------------------------------------
LEA5F		cmpa	#'|'					; is it '|'
		bne	LEA89					; if not EA89
		leax	1,X					; if so increase Y to point to next character
		lda	,X					; get it
		cmpa	#'|'					; and compare it with '|' again
		beq	LEA89					; if its '|' then EA89
		cmpa	#'"'					; else is it '"'
		beq	LEA89					; if so then EA89
		cmpa	#'!'					; is it !
		bne	LEA77					; if not then EA77
		leax	1,X					; increment Y again
		lda	#$80					; set bit 7
		bra	LEA31					; loop back to EA31 to set bit 7 in next CHR
LEA77		cmpa	#' '					; is it a space
		blo	brkBadString				; if less than EA8F Bad String Error
		cmpa	#'?'					; is it '?'
		beq	LEA87					; if so EA87
		jsr	x_Implement_CTRL_codes			; else modify code as if CTRL had been pressed
;;	bit	mostbl_SYSVAR_DEFAULT_SETTINGS+65	; if bit 6 set
;;	bvs	LEA8A					; then EA8A
		; exit with overflow set carry clear
		leax	1,X
		ora	zp_mos_GSREAD_characc
		SEV
		puls	B,PC


LEA87		lda	#$7F					; else set bits 0 to 6 in A
LEA89		CLV						; clear V
LEA8A		leax	1,X					; increment Y
		ora	zp_mos_GSREAD_characc			;
		CLC						; clear carry
		puls	B,PC					; Return
;; ----------------------------------------------------------------------------
brkBadString					; LEA8F
		DO_BRK	$FD, "Bad String"

;; Modify code as if SHIFT pressed
x_Modify_code_as_if_SHIFT			; LEA9c
		cmpa	#'0'				;if A='0' skip routine
		beq	LEABErts				;
		cmpa	#'@'				;if A='@' skip routine
		beq	LEABErts				;
		blo	LEAB8				;if A<'@' then EAB8
		cmpa	#$7F				;else is it DELETE
		beq	LEABErts			;if so skip routine
		bhi	LEABCeor10rts			;if greater than &7F then toggle bit 4
LEAACeor30	eora	#$30				;reverse bits 4 and 5
		cmpa	#$6F				;is it &6F (previously '_' (&5F))
		beq	LEAB6				;goto EAB6
		cmpa	#$50				;is it &50 (previously '`' (&60))
		bne	LEAB8				;if not EAB8
LEAB6		eora	#$1F				;else continue to convert ` _
LEAB8		cmpa	#'!'				;compare &21 '!'
		blo	LEABErts			;if less than return
LEABCeor10rts	eora	#$10				;else finish conversion by toggling bit 4
LEABErts	rts				;exit
							;
							;ASCII codes &00 &20 no change
							;21-3F have bit 4 reverses (31-3F)
							;41-5E A-Z have bit 5 reversed a-z
							;5F & 60 are reversed
							;61-7E bit 5 reversed a-z becomes A-Z
							;DELETE unchanged
							;&80+ has bit 4 changed

;; ----------------------------------------------------------------------------
;; Implement CTRL codes
x_Implement_CTRL_codes					; LEABF
		cmpa	#$7F				;is it DEL
		beq	LEAD1rts			;if so ignore routine
		bhs	LEAACeor30				;if greater than &7F go to EAAC
		cmpa	#$60				;if A<>'`'
		bne	LEACB				;goto EACB
		lda	#$5F				;if A=&60, A=&5F

LEACB		cmpa	#'@'				;if A<&40
		blo	LEAD1rts			;goto EAD1  and return unchanged
		anda	#$1F				;else zero bits 5 to 7
LEAD1rts		rts					;return


strSTARRUNPLINGBOOT
		FCB	'/!BOOT',$0D

;; OSBYTE &F7 (247) INTERCEPT BREAK
mos_OSBYTE_247
		lda	sysvar_BREAK_VECTOR_JMP
		eora	#$4C
		bne	LEAF3rts				;	EADE
		jmp	sysvar_BREAK_VECTOR_JMP
;; ----------------------------------------------------------------------------
;; OSBYTE &90 (144)   *TV; X=display delay ; Y=interlace flag 
mos_OSBYTE_144
		lda	oswksp_VDU_VERTADJ		;	EAE3
		STX_B	oswksp_VDU_VERTADJ
		m_tax
		m_tya					;	EAEA
		anda	#$01				;	EAEB
		LDY_B	oswksp_VDU_INTERLACE		;	EAED
		sta	oswksp_VDU_INTERLACE		;	EAF0
LEAF3rts	
		rts
;; ----------------------------------------------------------------------------
;; OSBYTE &93 (147)  WRITE TO FRED; X is offset within page ; Y is byte to write 
;mos_OSBYTE_147:
;	tya					;	EAF4
;	sta	LFC00,x				;	EAF5
;	rts					;	EAF8
;; ----------------------------------------------------------------------------
;; OSBYTE &95 (149)  WRITE TO JIM; X is offset within page ; Y is byte to write ;  
;mos_OSBYTE_149:
;	tya					;	EAF9
;	sta	LFD00,x				;	EAFA
;	rts					;	EAFD
;; ----------------------------------------------------------------------------
;; OSBYTE &97 (151)  WRITE TO SHEILA; X is offset within page ; Y is byte to write 
;mos_OSBYTE_151:
;	tya					;	EAFE
;	sta	sheila_CRTC_reg,x		;	EAFF
;	rts					;	EB02
;; ----------------------------------------------------------------------------
	IF INCLUDE_SOUND
		include "sound_main.asm"
	ENDIF ; INCLUDE_SOUND
;; ----------------------------------------------------------------------------
;; : set current filing system ROM/PHROM
;x_set_current_filing_system_ROM_PHROM:
;	lda	#$EF				;	EE13
;	sta	zp_mos_curPHROM			;	EE15
;	rts					;	EE17
;; ----------------------------------------------------------------------------
;; Get byte from data ROM
;x_Get_byte_from_data_ROM:
;	ldBB	#$0D				;	EE18
;	inc	zp_mos_curPHROM			;	EE1A
;	ldy	zp_mos_curPHROM			;	EE1C
;	bpl	LEE59				;	EE1E
;	ldx	#$00				;	EE20
;	stx	zp_mos_genPTR+1			;	EE22
;	inx					;	EE24
;	stx	zp_mos_genPTR			;	EE25
;	jsr	LEEBB				;	EE27
;	ldx	#$03				;	EE2A
;LEE2C:	jsr	x_PHROM_SERVICE			;	EE2C
;	cmp	copyright_symbol_backwards,x				;	EE2F
;	bne	x_Get_byte_from_data_ROM	;	EE32
;	dex					;	EE34
;	bpl	LEE2C				;	EE35
;	lda	#$3E				;	EE37
;	sta	zp_mos_genPTR			;	EE39
;LEE3B:	jsr	LEEBB				;	EE3B
;	ldx	#$FF				;	EE3E
;LEE40:	jsr	x_PHROM_SERVICE			;	EE40
;	ldy	#$08				;	EE43
;LEE45:	asl	a				;	EE45
;	ror	zp_mos_genPTR+1,x		;	EE46
;	dey					;	EE48
;	bne	LEE45				;	EE49
;	inx					;	EE4B
;	beq	LEE40				;	EE4C
;	clc					;	EE4E
;	bcc	LEEBB				;	EE4F
;; ROM SERVICE
;x_ROM_SERVICE:
;	ldx	#$0E				;	EE51
;	ldy	zp_mos_curPHROM			;	EE53
;	bmi	x_PHROM_SERVICE			;	EE55
;	ldy	#$FF				;	EE57
;LEE59:	php					;	EE59
;	jsr	mos_OSBYTE_143_b_cmd_x_param			;	EE5A
;	plp					;	EE5D
;	cmp	#$01				;	EE5E
;	tya					;	EE60
;	rts					;	EE61
;; ----------------------------------------------------------------------------
;; PHROM SERVICE;  
;x_PHROM_SERVICE:
;	php					;	EE62
;	sei					;	EE63
;	ldy	#$10				;	EE64
;	jsr	mos_OSBYTE_159			;	EE66
;	ldy	#$00				;	EE69
;	beq	LEE84				;	EE6B
;; OSBYTE 158 read from speech processor
;mos_OSBYTE_158:
;	ldy	#$00				;	EE6D
;	beq	LEE82				;	EE6F
;LEE71:	pha					;	EE71
;	jsr	LEE7A				;	EE72
;	pla					;	EE75
;	ror	a				;	EE76
;	ror	a				;	EE77
;	ror	a				;	EE78
;	ror	a				;	EE79
;LEE7A:	and	#$0F				;	EE7A
;	ora	#$40				;	EE7C
;	tay					;	EE7E
;; OSBYTE 159 Write to speech processor; on entry data or command in Y 
;mos_OSBYTE_159:
;	tya					;	EE7F
;	ldy	#$01				;	EE80
;LEE82:	php					;	EE82
;	sei					;	EE83
;LEE84:	bit	sysvar_SPEECH_PRESENT		;	EE84
;	bpl	LEEAA				;	EE87
;	pha					;	EE89
;	lda	LF075,y				;	EE8A
;	sta	sheila_SYSVIA_ddra		;	EE8D
;	pla					;	EE90
;	sta	sheila_SYSVIA_ora_nh		;	EE91
;	lda	LF077,y				;	EE94
;	sta	sheila_SYSVIA_orb		;	EE97
;LEE9A:	bit	sheila_SYSVIA_orb		;	EE9A
;	bmi	LEE9A				;	EE9D
;	lda	sheila_SYSVIA_ora_nh		;	EE9F
;	pha					;	EEA2
;	lda	LF079,y				;	EEA3
;	sta	sheila_SYSVIA_orb		;	EEA6
;	pla					;	EEA9
;LEEAA:	plp					;	EEAA
;	tay					;	EEAB
;	rts					;	EEAC
;; ----------------------------------------------------------------------------
;LEEAD:	lda	$03CB				;	EEAD
;	sta	zp_mos_genPTR			;	EEB0
;	lda	$03CC				;	EEB2
;	sta	zp_mos_genPTR+1			;	EEB5
;	lda	zp_mos_curPHROM			;	EEB7
;	bpl	LEED9				;	EEB9
;LEEBB:	php					;	EEBB
;	sei					;	EEBC
;	lda	zp_mos_genPTR			;	EEBD
;	jsr	LEE71				;	EEBF
;	lda	zp_mos_curPHROM			;	EEC2
;	sta	zp_mos_OS_wksp2			;	EEC4
;	lda	zp_mos_genPTR+1			;	EEC6
;	rol	a				;	EEC8
;	rol	a				;	EEC9
;	lsr	zp_mos_OS_wksp2			;	EECA
;	ror	a				;	EECC
;	lsr	zp_mos_OS_wksp2			;	EECD
;	ror	a				;	EECF
;	jsr	LEE71				;	EED0
;	lda	zp_mos_OS_wksp2			;	EED3
;	jsr	LEE7A				;	EED5
;	plp					;	EED8
;LEED9:	rts					;	EED9
;; ----------------------------------------------------------------------------


	IF INCLUDE_KEYBOARD
;; Keyboard Input and housekeeping; entered from &F00C 
keyb_input_and_housekeeping			; LEEDA
		ldb	#$FF				;
		lda	zp_mos_keynumlast		;get value of most recently pressed key
		ora	zp_mos_keynumfirst		;Or it with previous key to check for presses
		bne	LEEE8				;if A=0 no keys pressed so off you go
		lda	#$81				;else enable keybd interupt only by writing bit 7
		sta	sheila_SYSVIA_ier		;and bit 0 of system VIA interupt register 
		incb					;set X=0
LEEE8		stb	sysvar_KEYB_SEMAPHORE		;reset keyboard semaphore
; : Turn on Keyboard indicators
x_Turn_on_Keyboard_indicators				; LEEEB
		pshs	B,A,CC				;save flags
		lda	sysvar_KEYB_STATUS		;read keyboard status;
							;Bit 7  =1 shift enabled
							;Bit 6  =1 control pressed
							;bit 5  =0 shift lock
							;Bit 4  =0 Caps lock
							;Bit 3  =1 shift pressed    
		lsra					;shift Caps bit into bit 3
		anda	#$18				;mask out all but 4 and 3
		ora	#$06				;returns 6 if caps lock OFF &E if on
		sta	sheila_SYSVIA_orb		;turn on or off caps light if required
		lsra					;bring shift bit into bit 3
		ora	#$07				;
		sta	sheila_SYSVIA_orb		;turn on or off shift  lock light
		jsr	keyb_hw_enable_scan		;set keyboard counter
		clra
		puls	CC				; have some bodgery to do here to make 
							; Entry N=>control, A==8=>shift, CC_C=>C
							; into 6809 A(7) = control, A(6) = shift, A(0) carry on entry
		bcc	1F
		ora	#$01
1		bpl	1F
		ora	#$80
1		
	IF CPU_6809
		ldb	#8
		bitb	,S+
	ELSE
		tim	#$08, ,S+
	ENDIF
		beq	1F
		ora	#$40
1		puls	B,PC				;get back flags	in A! and return

 *************************************************************************
 *                                                                       *
 * MAIN KEYBOARD HANDLING ROUTINE   ENTRY FROM KEYV                      *
 * ==========================================================            *
 *                                                                       *
 *                       ENTRY CONDITIONS                                *
 *                       ================                                *
 * C=0, V=0 Test Shift and CTRL keys.. exit with N set if CTRL pressed   *
 *                                 ........with V set if Shift pressed   *
 * C=1, V=0 Scan Keyboard as OSBYTE &79                                  *
 * C=0, V=1 Key pressed interrupt entry                                  *
 * C=1, V=1 Timer interrupt entry                                        *
 *                                                                       *
 *************************************************************************

KEYV_default						; LEF02
		bvc	1F				;if V is clear then leave interrupt routine
		lda	#$01				;disable keyboard interrupts
		sta	sheila_SYSVIA_ier		;by writing to VIA interrupt vector
		bcs	KEYV_Timer_interrupt_entry	;if timer interrupt then EF13
		jmp	KEYV_default_keypress_IRQ	;else to F00F

1		bcc	KEYV_test_shift_ctl		;if test SHFT & CTRL goto EF16
		jmp	KEYV_keyboard_scan		;else to F0D1
								;to scan keyboard
; Timer interrupt entry
KEYV_Timer_interrupt_entry
		inc	sysvar_KEYB_SEMAPHORE		;increment keyboard semaphore (to 0)
; Test Shift and Control Keys entry
KEYV_test_shift_ctl
		lda	sysvar_KEYB_STATUS		;read keyboard status;     
							;Bit 7  =1 shift enabled   
							;Bit 6  =1 control pressed 
							;bit 5  =0 shift lock      
							;Bit 4  =0 Caps lock       
							;Bit 3  =1 shift pressed   
		anda	#$B7				;zero bits 3 and 6
		ldb	#0				;zero B to test for shift key press
							;NB: DON'T use CLRB here need to preserve carry
		jsr	keyb_check_key_code_API		;interrogate keyboard X=&80 if key determined by
							;X on entry is pressed 
		stb	zp_mos_OS_wksp2			;save X
		bpl	1F				;if no key press (X=0) then EF2A else
		ora	#$08				;set bit 3 to indicate Shift was pressed
1		incb					;check the control key
		jsr	keyb_check_key_code_API		;via keyboard interrogate
		bcc	x_Turn_on_Keyboard_indicators	;if carry clear (entry via EF16) then off to EEEB
							;to turn on keyboard lights as required
		bpl	1F				;if key not pressed goto EF30
		ora	#$40				;or set CTRL pressed bit in keyboard status byte in A
1		sta	sysvar_KEYB_STATUS		;save status byte
		ldb	zp_mos_keynumlast		;if no key previously pressed
		lbeq	LEFE9				;then EF4D
		jsr	keyb_check_key_code_API		;else check to see if key still pressed
		bmi	x_REPEAT_ACTION			;if so enter repeat routine at EF50
		cmpb	zp_mos_keynumlast		;else compare B with last key pressed (set flags)
LEF42		beq	1F				;DB: slight change as 6809 sets Z on STx
		stb	zp_mos_keynumlast		;store B in last key pressed
		jmp	LEFE9				;if different from previous (Z clear) then EF4D
1		clrb					;else zero 
		stb	zp_mos_keynumlast		;last key pressed 
LEF4A		jsr	keyb_set_autorepeat_countdown	;and reset repeat system
		jmp	LEFE9
;; ----------------------------------------------------------------------------
;; REPEAT ACTION
x_REPEAT_ACTION
		cmpb	zp_mos_keynumlast		;if B<>last key pressed
		bne	LEF42				;then back to EF42
		lda	zp_mos_autorep_countdown	;else get value of AUTO REPEAT COUNTDOWN TIMER
		lbeq	LEFE9				;if 0 goto EF7B
		dec	zp_mos_autorep_countdown	;else decrement
		lbne	LEFE9				;and if not 0 goto EF7B
							;this means that either the repeat system is dormant
							;or it is not at the end of its count
		lda	mosvar_KEYB_AUTOREPEAT_COUNT	;next value for countdown timer
		sta	zp_mos_autorep_countdown	;store it
		lda	sysvar_KEYB_AUTOREP_PERIOD	;get auto repeat rate from 0255
		sta	mosvar_KEYB_AUTOREPEAT_COUNT	;store it as next value for Countdown timer
		lda	sysvar_KEYB_STATUS		;get keyboard status
		ldb	zp_mos_keynumlast		;get last key pressed
		cmpb	#KEYCODE_D0_SHIFTLOCK		;if not SHIFT LOCK key (&D0) goto
		bne	LEF7E				;EF7E
		ora	#$90				;sets shift enabled, & no caps lock all else preserved
		eora	#$A0				;reverses shift lock disables Caps lock and Shift enab
LEF74		sta	sysvar_KEYB_STATUS		;reset keyboard status
		clra					;and set timer
		sta	zp_mos_autorep_countdown	;to 0
		bra	LEFE9
		
LEF7E		cmpb	#$C0				;if not CAPS LOCK
		bne	x_get_ASCII_code		;goto EF91
		ora	#$A0				;sets shift enabled and disables SHIFT LOCK
		tst	zp_mos_OS_wksp2			;if bit 7 not set by (EF20) shift NOT pressed
		bpl	LEF8C				;goto EF8C
		ora	#$10				;else set CAPS LOCK not enabled
		eora	#$80				;reverse SHIFT enabled

LEF8C		eora	#$90				;reverse both SHIFT enabled and CAPs Lock
		bra	LEF74				;reset keyboard status and set timer
;; ----------------------------------------------------------------------------
;; get ASCII code; on entry B=key pressed internal number 
x_get_ASCII_code
		ldx	#key2ascii_tab - $10
		andb	#$7F
		lda	B,X				;get code from look up table
		bne	1F				;if not zero goto EF99 else TAB pressed
		lda	sysvar_KEYB_TAB_CHAR		;get TAB character
1		ldb	sysvar_KEYB_STATUS		;get keyboard status
		stb	zp_mos_OS_wksp2			;store it in &FA
		rol	zp_mos_OS_wksp2			;rotate to get CTRL pressed into bit 7
		bpl	LEFA9				;if CTRL NOT pressed EFA9

		ldb	zp_mos_keynumfirst		;get no. of previously pressed key
LEFA4		bne	LEF4A				;if not 0 goto EF4A to reset repeat system etc.
		jsr	x_Implement_CTRL_codes		;else perform code changes for CTRL

LEFA9		rol	zp_mos_OS_wksp2			;move shift lock into bit 7
LEFAB		bmi	LEFB5				;if not effective goto EFB5 else
		jsr	x_Modify_code_as_if_SHIFT	;make code changes for SHIFT

		rol	zp_mos_OS_wksp2			;move CAPS LOCK into bit 7
		bra	LEFC1				;and Jump to EFC1

LEFB5		rol	zp_mos_OS_wksp2			;move CAPS LOCK into bit 7
		bmi	LEFC6				;if not effective goto EFC6
		jsr	mos_CHECK_FOR_ALPHA_CHARACTER	;else make changes for CAPS LOCK on, return with 
							;C clear for Alphabetic codes
		bcs	LEFC6				;if carry set goto EFC6 else make changes for
		jsr	x_Modify_code_as_if_SHIFT	;SHIFT as above

LEFC1		ldb	sysvar_KEYB_STATUS		;if shift enabled bit is clear
		bpl	LEFD1				;goto EFD1
LEFC6		rol	zp_mos_OS_wksp2			;else get shift bit into 7
		bpl	LEFD1				;if not set goto EFD1
		ldb	zp_mos_keynumfirst		;get previous key press
		bne	LEFA4				;if not 0 reset repeat system etc. via EFA4
		jsr	x_Modify_code_as_if_SHIFT	;else make code changes for SHIFT
LEFD1		cmpa	sysvar_KEYB_ESC_CHAR		;if A<> ESCAPE code 
		bne	LEFDD				;goto EFDD
		ldb	sysvar_KEYB_ESC_ACTION		;get Escape key status
		bne	LEFDD				;if ESCAPE returns ASCII code goto EFDD
		stb	zp_mos_autorep_countdown	;store in Auto repeat countdown timer

LEFDD		m_tay					

		jsr	keyb_enable_scan_IRQonoff	;disable keyboard
		lda	sysvar_KEYB_DISABLE		;read Keyboard disable flag used by Econet 
		bne	LEFE9				;if keyboard locked goto EFE9
		jsr	x_INSERT_byte_in_Keyboard_buffer;put character in input buffer
LEFE9		ldb	zp_mos_keynumfirst		;get previous keypress
		beq	LEFF8				;if none  EFF8
		jsr	keyb_check_key_code_API		;examine to see if key still pressed
		stb	zp_mos_keynumfirst		;store result
		bmi	LEFF8				;if pressed goto EFF8
		clr	zp_mos_keynumfirst		;and &ED

LEFF8		ldb	zp_mos_keynumfirst		;get &ED
		bne	LF012				;if not 0 goto F012

		ldy	#zp_mos_keynumlast		;get first keypress into Y (DB: last!)
		jsr	clc_then_mos_OSBYTE_122		;scan keyboard from &10 (osbyte 122)
		m_txb

		bmi	LF00C				;if exit is negative goto F00C
		lda	zp_mos_keynumlast		;else make last key the
		sta	zp_mos_keynumfirst		;first key pressed i.e. rollover

LF007		stb	zp_mos_keynumlast		;save X into &EC
		jsr	keyb_set_autorepeat_countdown	;set keyboard repeat delay
LF00C		jmp	keyb_input_and_housekeeping	;go back to EEDA
;; ----------------------------------------------------------------------------
;; Key pressed interrupt entry point; enters with X=key 
KEYV_default_keypress_IRQ				; LF00F
		clrb				; DB ??? not sure what is what here on BeebEm always seems to be X=0 here!
		jsr	keyb_check_key_code_API		;check if key pressed
LF012		lda	zp_mos_keynumlast		;get previous key press
		bne	LF00C				;if none back to housekeeping routine
		ldy	#zp_mos_keynumfirst		;get last keypress into Y
		jsr	clc_then_mos_OSBYTE_122		;and scan keyboard
		bmi	LF00C				;if negative on exit back to housekeeping
		m_txb
		bra	LF007				;else back to store X and reset keyboard delay etc.
;; Set Autorepeat countdown timer
keyb_set_autorepeat_countdown
		ldb	#$01				;set timer to 1
		stb	zp_mos_autorep_countdown	;
		ldb	sysvar_KEYB_AUTOREP_DELAY	;get next timer value
		stb	mosvar_KEYB_AUTOREPEAT_COUNT	;and store it
		rts					;
;; ----------------------------------------------------------------------------
;; Interrogate Keyboard routine;
		; NOTE: API change B now contains key code to scan, A is preserved
		; NB: needs to preserve carry!
keyb_check_key_code_API
		pshs	A
		lda	#$03				;stop Auto scan
		sta	sheila_SYSVIA_orb		;by writing to system VIA
		lda	#$7F				;set bits 0 to 6 of port A to input on bit 7
						;output on bits 0 to 6
		sta	sheila_SYSVIA_ddra		;
		stb	sheila_SYSVIA_ora_nh		;write X to Port A system VIA
		ldb	sheila_SYSVIA_ora_nh		;read back &80 if key pressed (M set)
		puls	A,PC				;and return
;; ----------------------------------------------------------------------------

	ELSE ; NOT INCLUDE_KEYBOARD
KEYV_default
	bvs	1F				;if V is clear then leave interrupt routine
	bcc	1F

	jmp	KEYV_keyboard_scan

	;TODO: SBC09: ? not sure about this
1	clra
	rts

	ENDIF ; INCLUDE_KEYBOARD

*************************************************************************
 *                                                                       *
 *       KEY TRANSLATION TABLES                                          *
 *                                                                       *
 *       7 BLOCKS interspersed with unrelated code                       *
 *************************************************************************
                                         
 *key data block 1
key2ascii_tab					; LF03B
		FCB	$71,$33,$34,$35,$84,$38,$87,$2D,$5E,$8C
		;	 q , 3 , 4 , 5 , f4, 8 , f7, - , ^ , <-

		RMB	6	; TODO - spare gap in key2ascii map

*key data block 2
 
LF04B		FCB	$80,$77,$65,$74,$37,$69,$39,$30,$5F,$8E
		;	 f0, w , e , t , 7 , i , 9 , 0 , _ ,lft

		RMB	6	; TODO - spare gap in key2ascii map

 *key data block 3
 
LF05B		FCB	$31,$32,$64,$72,$36,$75,$6F,$70,$5B,$8F
		;	 1 , 2 , d , r , 6 , u , o , p , [ , dn

		RMB	6	; TODO - spare gap in key2ascii map

*key data block 4
 
LF06B		FCB	$01,$61,$78,$66,$79,$6A,$6B,$40,$3A,$0D
		;	 CL, a , x , f , y , j , k , @ , : ,RET		N.B CL=CAPS LOCK

*speech routine data
LF075		FCB	$00,$FF,$01,$02,$09,$0A

*key data block 5

F07B	FCB	$02,$73,$63,$67,$68,$6E,$6C,$3B,$5D,$7F
		;	 SL, s , c , g , h , n , l , ; , ] ,DEL		N.B. SL=SHIFT LOCK

		RMB	6	; TODO - spare gap in key2ascii map

 *key data block 6
 
F08B	FCB	$00,$7A,$20,$76,$62,$6D,$2C,$2E,$2F,$8B
		;	TAB, Z ,SPC, v , b , m , , , . , / ,CPY

		RMB	6	; TODO - spare gap in key2ascii map

*key data block 7
F09B	FCB	$1B,$81,$82,$83,$85,$86,$88,$89,$5C,$8D
		;	ESC, f1, f2, f3, f5, f6, f8, f9, \ , ->



;; 7 BLOCKS interspersed with unrelated code
;mos_7_BLOCKS_interspersed_with_unrelated_code:
;	adc	(zp_lang+51),y			;	F03B
;	FCB	$34				;	F03D
;	and	zp_lang+132,x			;	F03E
;	sec					;	F040
;	FCB	$87				;	F041
;	and	$8C5E				;	F042
;; OSBYTE 120  Write KEY pressed Data
;mos_OSBYTE_120:
;	sty	zp_mos_keynumlast		;	F045
;	stx	zp_mos_keynumfirst		;	F047
;	rts					;	F049
;; ----------------------------------------------------------------------------
;	brk					;	F04A
;	FCB	$80				;	F04B
;	FCB	$77				;	F04C
;	adc	zp_lang+116			;	F04D
;	FCB	$37				;	F04F
;	adc	#$39				;	F050
;	bmi	LF0B3				;	F052
;	FCB	$8E				;	F054
;;;LF055:	jmp	(LFDFE)				;	was used in startup sequence if bit 6 of keyboard links is set now deos this in line!
;; ----------------------------------------------------------------------------
;LF058:	jmp	(zp_mos_OS_wksp2)		;	F058
;; ----------------------------------------------------------------------------
;	and	(zp_lang+50),y			;	F05B
;	FCB	$64				;	F05D
;	FCB	$72				;	F05E
;	rol	zp_lang+117,x			;	F05F
;	FCB	$6F				;	F061
;	bvs	LF0BF				;	F062
;	FCB	$8F				;	F064
;; Main entry to keyboard routines
mos_enter_keyboard_routines
		orcc	#CC_V+CC_N			;set V and M
jmpKEYV	
		jmp	[KEYV]
;; ----------------------------------------------------------------------------
;	ora	(zp_lang+97,x)			;	F06B
;	sei					;	F06D
;	ror	zp_lang+121			;	F06E
;	ror	a				;	F070
;	FCB	$6B				;	F071
;	rti					;	F072
;; ----------------------------------------------------------------------------
;	FCB	$3A				;	F073
;	FCB	$0D				;	F074
;LF075:	brk					;	F075
;	FCB	$FF				;	F076
;LF077:	ora	(zp_lang+2,x)			;	F077
;LF079:	ora	#$0A				;	F079
;	FCB	$02				;	F07B
;	FCB	$73				;	F07C
;	FCB	$63				;	F07D
;	FCB	$67				;	F07E
;	pla					;	F07F
;	ror	$3B6C				;	F080
;	FCB	$5D				;	F083
;	FCB	$7F				;	F084
;; OSBYTE 131  READ OSHWM  (PAGE in BASIC)
mos_OSBYTE_131
		lda	sysvar_CUR_OSHWM		;	F085
		clrb
		m_tay
		tfr	D,X
		rts					;	F08A

;; set input buffer number and flush it
x_set_input_buffer_number_and_flush_it
		LDX_B	sysvar_CURINSTREAM		;	F095
LF098		jmp	x_Buffer_handling		;	F098
;; ----------------------------------------------------------------------------
;	FCB	$1B				;	F09B
;	sta	(zp_lang+130,x)			;	F09C
;	FCB	$83				;	F09E
;	sta	zp_lang+134			;	F09F
;	dey					;	F0A1
;	FCB	$89				;	F0A2
;	FCB	$5C				;	F0A3
;	FCB	$8D				;	F0A4
;; jsr from code!;LF0A5:	jmp	(EVNTV)				;	F0A5

*************************************************************************
*                                                                       *
*       OSBYTE 15  FLUSH SELECTED BUFFER CLASS                          *
*                                                                       *
*                                                                       *
*************************************************************************

                        ;flush selected buffer
                        ;X=0 flush all buffers
                        ;X>1 flush input buffer


mos_OSBYTE_15						; LF0A8
		bne	x_set_input_buffer_number_and_flush_it;if X<>1 flush input buffer only
mos_flush_all_buffers					; LF0AA
		ldx	#$08				;else load highest buffer number (8)
1		CLI					;allow interrupts 
		SEI					;briefly!
		jsr	mos_OSBYTE_21			;flush buffer
		leax	-1,X				;decrement X to point at next buffer
		cmpx	#$FFFF
		bne	1B
;; OSBYTE 21  FLUSH SPECIFIC BUFFER; on entry X=buffer number 
mos_OSBYTE_21
		cmpx	#$09				;	F0B4
		blo	LF098				;	F0B6
		rts					;	F0B8
;; ----------------------------------------------------------------------------
;; Issue *HELP to ROMS
mos_STAR_HELP
		ldb	#SERVICE_9_HELP			;	F0B9
		jsr	mos_OSBYTE_143_b_cmd_x_param			;	F0BB
		jsr	mos_PRTEXT
		FCB	$0D, "OS 1.09", $0D,0
		rts					;	F0CB
;; ----------------------------------------------------------------------------
;; OSBYTE 122  KEYBOARD SCAN FROM &10 (16);  
clc_then_mos_OSBYTE_122
mos_OSBYTE_122						; LF0CD
		CLC
		ldx	#$10				; lowest key to scan (Q)
;; OSBYTE 121  KEYBOARD SCAN FROM VALUE IN X
mos_OSBYTE_121
		bcs	jmpKEYV				;if carry set (by osbyte 121) F068
							;JMPs via KEYV and hence return from osbyte
							;however KEYV will return here... 

KEYV_keyboard_scan
	IF INCLUDE_KEYBOARD
 *************************************************************************
 *        Scan Keyboard C=1, V=0 entry via KEYV (or from CLC above)      *
 *************************************************************************

		m_txa					;if X is +ve goto F0D9
		bpl	LF0D9				;
		tfr	A,B
		jsr	keyb_check_key_code_API		;else interrogate keyboard
LF0D7		bcs	keyb_hw_enable_scan2		;if carry set F12E to set Auto scan else
LF0D9		pshs	CC				;push flags
		bcc	LF0DE				;if carry clear goto FODE 
							;else (keep Y passed in to clc_then_mos_OSBYTE_122)
		ldy	#$EE				;set Y so next operation saves to 2cd
LF0DE		sta	mosvar_KEYB_TWOKEY_ROLLOVER-zp_mos_keynumlast,y
							;can be: 	2cb (mosvar_KEYB_TWOKEY_ROLLOVER)
							;	,	2cc (+1)
							;	or 	2cd (+2)
		ldb	#$09				;set X to 9
LF0E3		jsr	keyb_enable_scan_IRQonoff	;select auto scan 
		lda	#$7F				;set port A for input on bit 7 others outputs
		sta	sheila_SYSVIA_ddra		;
		lda	#$03				;stop auto scan
		sta	sheila_SYSVIA_orb		;
		lda	#$0F				;select non-existent keyboard column F (0-9 only!)
		sta	sheila_SYSVIA_ora_nh		;
		lda	#$01				;cancel keyboard interrupt
		sta	sheila_SYSVIA_ifr		;
		stb	sheila_SYSVIA_ora_nh		;select column X (9 max)
		bita	sheila_SYSVIA_ifr		;if bit 1 =0 there is no keyboard interrupt so
		beq	LF123				;goto F123
		tfr	B,A				;else put column address in A
LF103		cmpa	mosvar_KEYB_TWOKEY_ROLLOVER-zp_mos_keynumlast,y	;compare with 1DF+Y
		blo	LF11E				;if less then F11E
		sta	sheila_SYSVIA_ora_nh		;else select column again 
		tst	sheila_SYSVIA_ora_nh		;and if bit 7 is 0
		bpl	LF11E				;then F11E
		puls	CC				;else push and pull flags
		pshs	CC				;
		bcs	LF127				;and if carry set goto F127
		pshs	A				;else Push A
		eora	,y				;EOR with EC,ED, or EE depending on Y value
		asla					;shift left  
		cmpa	#$01				;clear? carry if = or greater than number holds EC,ED,EE
		puls	A				;get back A
		bcc	LF127				;if carry set F127
LF11E		adda	#$10				;add 16
		bpl	LF103				;and do it again if 0=<result<128

LF123		decb					;decrement X
		bpl	LF0E3				;scan again if >= 0
		tfr	b,a				;
LF127		m_tax_se				;
		puls	CC				;pull flags
keyb_enable_scan_IRQonoff				; LF129
		jsr	keyb_hw_enable_scan		;call autoscan
		CLI					;allow interrupts 
		SEI					;disable interrupts
;; Enable counter scan of keyboard columns; called from &EEFD, &F129 
		
keyb_hw_enable_scan
		pshs	B
		ldb	#$0B				;	F12E
		stb	sheila_SYSVIA_orb		;	F130
		puls	B,PC				; return with B in X
keyb_hw_enable_scan2
		tfr	B,A
		m_tax_se
		bra	keyb_hw_enable_scan

	ELSE ; NOT INCLUDE_KEYBOARD
		tfr	X,D
		tstb
		bmi	1F
		ldx	#-1
		lda	#$FF
		rts

1		ldx	#0
		clra
		rts
	ENDIF ; INCLUDE_KEYBOARD
;; ----------------------------------------------------------------------------
;; selects ROM filing system
;mos_selects_ROM_filing_system:
;	eor	#$8C				;	F135
;LF137:	asl	a				;	F137
;	sta	sysvar_CFSRFS_SWITCH		;	F138
;	cpx	#$03				;	F13B
;	jmp	LF14B				;	F13D
;; ----------------------------------------------------------------------------
;; set cassette options; called after BREAK etc ; lower nybble sets sequential access ; upper sets load and save options ; 0000	 Ignore errors,		 no messages ; 0001   Abort if error,	      no messages ; 0010   Retry after error,	   no messages ; 
;x_set_cassette_options:
;	php					;	F140
;	lda	#$A1				;	F141
;	sta	zp_cfs_w+1			;	F143
;	lda	#$19				;	F145
;	sta	$03D1				;	F147
;	plp					;	F14A
;LF14B:	php					;	F14B
;	lda	#$06				;	F14C
;	jsr	mos_jmp_FSCV			;	F14E
;	ldx	#$06				;	F151
;	plp					;	F153
;	beq	LF157				;	F154
;	dex					;	F156
;LF157:	stx	zp_fs_w+6			;	F157
;	ldx	#$0E				;	F159
;LF15B:	lda	vec_table+17,x			;	F15B
;	sta	$0211,x				;	F15E
;	dex					;	F161
;	bne	LF15B				;	F162
;	stx	zp_fs_w+2			;	F164
;	ldx	#$0F				;	F166

mos_OSBYTE_143
		; b == original X, put Y (param) in X
		tfr	Y,X
		jsr	mos_OSBYTE_143_b_cmd_x_param
		tfr	X,Y
		rts


mos_OSBYTE_143_b_cmd_x_param
		sty	,--S
		lda	zp_mos_curROM			; get current Rom number
		sta	,-S				; store it on stack along with command # (passed in B)
		tfr	B,A				; service call # in A
		ldb	#$0F				; set X=15
LF16E		ldy	#oswksp_ROMTYPE_TAB		
		tst	B,Y				; read bit 7 on rom map (no rom has type 254 &FE)
		bpl	1F				; skip if bit 7 not set (no service entry)
		jsr	mos_select_SWROM_B
		ldb	zp_mos_curROM			; pass in B as current ROM
		jsr	$8003				; call service routine
		tsta					; check to see if A is reset
		beq	2F				; if it is do no more roms
		ldb	zp_mos_curROM			; get current rom #
1		decb					; decrement
		bpl	LF16E				; go again?
2		ldb	,S+				; get back original rom #
		jsr	mos_select_SWROM_B
		tsta					; set Z if A=0
		puls	Y,PC				; return result still in A, B corrupted (original low byte of X)




;; ----------------------------------------------------------------------------
;; start of data for save, 0E EndFDBess /attributes
mos_OSARGS
	tsta						;	F18E
	bne	LF1A2					;	F190
	cmpy	#$00					;	F192
	bne	LF1A2					;	F194
	lda	zp_fs_w+6				;	F196
	anda	#$FB					;	F198
	ora	sysvar_CFSRFS_SWITCH			;	F19A
	asla						;	F19D
	ora	sysvar_CFSRFS_SWITCH			;	F19E
	lsra						;	F1A1
LF1A2	rts						;	F1A2
;; ----------------------------------------------------------------------------
;; FSC	  VECTOR  TABLE
mos_FSC_VECTOR_TABLE
		FDB	mos_FSCV_OPT			; *OPT          (F54C)  
		FDB	mos_FSCV_EOF			; check EOF     (F61D)
		FDB	mos_FSCV_RUN			; */            (F304)
		FDB	brkBadCommand		; Bad Command   (E30F) if roms and FS don't want it 
		FDB	mos_FSCV_RUN			; *RUN          (F304)
		FDB	mos_FSCV_CAT			; *CAT          (F32A)
		FDB	mos_OSBYTE_119			; osbyte 77     (E274)

;; A= index 0 to 7;
; on entry A is reason code 
; A=0    A *OPT command has been used X & Y are the 2 parameters 
; A=1    EOF is being checked, on entry  X=File handle  
; A=2    A */ command has been used *RUN the file 
; A=3    An unrecognised OS command has ben used X,Y point at command
; A=4    A *RUN command has been used X,Y point at filename
; A=5    A *CAT cammand has been issued X,Y point to rest of command
; A=6    New filing system about to take over close *SPOOL &*EXEC files
; A=7    Return in X and Y lowest and highest file handle used   
; A=8    OS about to process *command

mos_FSCV_default_handler
		cmpa	#$07				; if >= 7
		bhs	1F				; POH
		stx	zp_fs_s+12			;	F1B5
		asla					;	F1B7
		ldx	#mos_FSC_VECTOR_TABLE
		jmp	[A,X]
1		rts					;	F1C3
;; ----------------------------------------------------------------------------
;; LOAD FILE
;mos_LOAD_FILE:
;	php					;	F1C4
;	pha					;	F1C5
;	jsr	mos_claim_serial_system_for_cass;	F1C6
;	lda	L03C2				;	F1C9
;	pha					;	F1CC
;	jsr	LF631				;	F1CD
;	pla					;	F1D0
;	beq	LF1ED				;	F1D1
;	ldx	#$03				;	F1D3
;	lda	#$FF				;	F1D5
;LF1D7:	pha					;	F1D7
;	lda	$03BE,x				;	F1D8
;	sta	zp_fs_s,x			;	F1DB
;	pla					;	F1DD
;	and	zp_fs_s,x			;	F1DE
;	dex					;	F1E0
;	bpl	LF1D7				;	F1E1
;	cmp	#$FF				;	F1E3
;	bne	LF1ED				;	F1E5
;	jsr	x_sound_bell_reset_ACIA_motor_off;	F1E7
;	jmp	brkBadAddress				;	F1EA
;; ----------------------------------------------------------------------------
;LF1ED:	lda	$03CA				;	F1ED
;	lsr	a				;	F1F0
;	pla					;	F1F1
;	beq	LF202				;	F1F2
;	bcc	LF209				;	F1F4
;; LOCKED FILE ROUTINE
;x_LOCKED_FILE_ROUTINE:
;	jsr	LFAF2				;	F1F6
;	brk					;	F1F9
;	FCB	$D5				;	F1FA
;	FCB	"Locked"			;	F1FB
;	FCB	$00				;	F201
;; ----------------------------------------------------------------------------
;LF202:	bcc	LF209				;	F202
;	lda	#$03				;	F204
;	sta	sysvar_BREAK_EFFECT		;	F206
;LF209:	lda	#$30				;	F209
;	and	zp_fs_s+11			;	F20B
;	beq	LF213				;	F20D
;	lda	zp_fs_w+1			;	F20F
;	bne	LF21D				;	F211
;LF213:	tya					;	F213
;	pha					;	F214
;	jsr	x_read_from_second_processor	;	F215
;	pla					;	F218
;	tay					;	F219
;	jsr	LF7D5				;	F21A
;LF21D:	jsr	x_LOAD				;	F21D
;	bne	x_RETRY_AFTER_A_FAILURE_ROUTINE ;	F220
;	jsr	LFB69				;	F222
;	bit	$03CA				;	F225
;	bmi	x_store_data_in_OSFILE_parameter_block;	F228
;	jsr	x_increment_current_loadFDBess;	F22A
;	jsr	LF77B				;	F22D
;	bne	LF209				;	F230
;; store data in OSFILE parameter block
;x_store_data_in_OSFILE_parameter_block:
;	ldy	#$0A				;	F232
;	lda	zp_fs_w+12			;	F234
;	sta	(zp_fs_w+8),y			;	F236
;	iny					;	F238
;	lda	zp_fs_w+13			;	F239
;	sta	(zp_fs_w+8),y			;	F23B
;	lda	#$00				;	F23D
;	iny					;	F23F
;	sta	(zp_fs_w+8),y			;	F240
;	iny					;	F242
;	sta	(zp_fs_w+8),y			;	F243
;	plp					;	F245
;LF246:	jsr	x_sound_bell_reset_ACIA_motor_off;	F246
;LF249:	bit	zp_fs_s+10			;	F249
;	bmi	LF254				;	F24B
;LF24D:	php					;	F24D
;	jsr	LFA46				;	F24E
;	ora	$2800				;	F251
;LF254:	rts					;	F254
;; ----------------------------------------------------------------------------
;; RETRY AFTER A FAILURE ROUTINE
;x_RETRY_AFTER_A_FAILURE_ROUTINE:
;	jsr	LF637				;	F255
;	bne	LF209				;	F258
;; Read Filename using Command Line Interpreter; filename pointed to by X and Y 
;x_Read_Filename_using_Command_Line_Interpreter:
;	stx	zp_mos_txtptr			;	F25A
;	sty	zp_mos_txtptr+1			;	F25C
;	ldy	#$00				;	F25E
;	jsr	mos_CLC_GSINIT;	F260
;	ldx	#$00				;	F263
;LF265:	jsr	mos_GSREAD;	F265
;	bcs	x_terminate_Filename		;	F268
;	beq	LF274				;	F26A
;	sta	$03D2,x				;	F26C
;	inx					;	F26F
;	cpx	#$0B				;	F270
;	bne	LF265				;	F272
;LF274:	jmp	brkBadString				;	F274
;; ----------------------------------------------------------------------------
;; terminate Filename
;x_terminate_Filename:
;	lda	#$00				;	F277
;	sta	$03D2,x				;	F279
;	rts					;	F27C
;; ----------------------------------------------------------------------------
;; OSFILE ENTRY; parameter block located by XY ; 0/1    Address of Filename terminated by &0D ; 2/4    Load Address of File ; 6/9    Execution Address of File ; A/D    StartFDBess of data for write operations or length of file ; for read operations ; E/11 
;mos_OSFILE_ENTRY:
;	pha					;	F27D
;	stx	zp_fs_w+8			;	F27E
;	sty	zp_fs_w+9			;	F280
;	ldy	#$00				;	F282
;	lda	(zp_fs_w+8),y			;	F284
;	tax					;	F286
;	iny					;	F287
;	lda	(zp_fs_w+8),y			;	F288
;	tay					;	F28A
;	jsr	x_Read_Filename_using_Command_Line_Interpreter;	F28B
;	ldy	#$02				;	F28E
;LF290:	lda	(zp_fs_w+8),y			;	F290
;	sta	$03BC,y				;	F292
;	sta	$AE,y				;	F295
;	iny					;	F298
;	cpy	#$0A				;	F299
;	bne	LF290				;	F29B
;	pla					;	F29D
;	beq	x_Save_a_file			;	F29E
;	cmp	#$FF				;	F2A0
;	bne	LF254				;	F2A2
;	jmp	mos_LOAD_FILE			;	F2A4
;; ----------------------------------------------------------------------------
;; Save a file
;x_Save_a_file:
;	sta	$03C6				;	F2A7
;	sta	$03C7				;	F2AA
;LF2AD:	lda	(zp_fs_w+8),y			;	F2AD
;	sta	zp_nmi+6,y			;	F2AF
;	iny					;	F2B2
;	cpy	#$12				;	F2B3
;	bne	LF2AD				;	F2B5
;	txa					;	F2B7
;	beq	LF274				;	F2B8
;	jsr	mos_claim_serial_system_for_cass;	F2BA
;	jsr	x_print_prompt_for_SAVE_on_TAPE ;	F2BD
;	lda	#$00				;	F2C0
;	jsr	LFBBD				;	F2C2
;	jsr	x_control_ACIA_and_Motor	;	F2C5
;LF2C8:	sec					;	F2C8
;	ldx	#$FD				;	F2C9
;LF2CB:	lda	VETABFDB,x			;	F2CB
;	sbc	LFFB3,x				;	F2CE
;	sta	mosvar_KEYB_TWOKEY_ROLLOVER,x	;	F2D1
;	inx					;	F2D4
;	bne	LF2CB				;	F2D5
;	tay					;	F2D7
;	bne	LF2E8				;	F2D8
;	cpx	$03C8				;	F2DA
;	lda	#$01				;	F2DD
;	sbc	$03C9				;	F2DF
;	bcc	LF2E8				;	F2E2
;	ldx	#$80				;	F2E4
;	bne	LF2F0				;	F2E6
;LF2E8:	lda	#$01				;	F2E8
;	sta	$03C9				;	F2EA
;	stx	$03C8				;	F2ED
;LF2F0:	stx	$03CA				;	F2F0
;	jsr	x_SAVE_A_BLOCK			;	F2F3
;	bmi	LF341				;	F2F6
;	jsr	x_increment_current_loadFDBess;	F2F8
;	inc	$03C6				;	F2FB
;	bne	LF2C8				;	F2FE
;	inc	$03C7				;	F300
;	bne	LF2C8				;	F303
;; *RUN	  ENTRY
mos_FSCV_RUN
		TODO	"mos_FSCV_RUN"
;	jsr	x_Read_Filename_using_Command_Line_Interpreter;	F305
;	ldx	#$FF				;	F308
;	stx	L03C2				;	F30A
;	jsr	mos_LOAD_FILE			;	F30D
;	bit	sysvar_TUBE_PRESENT		;	F310
;	bpl	LF31F				;	F313
;	lda	$03C4				;	F315
;	and	$03C5				;	F318
;	cmp	#$FF				;	F31B
;	bne	LF322				;	F31D
;LF31F:	jmp	(L03C2)				;	F31F
;; ----------------------------------------------------------------------------
;LF322:	ldx	#$C2				;	F322
;	ldy	#$03				;	F324
;	lda	#$04				;	F326
;	jmp	LFBC7				;	F328
;; ----------------------------------------------------------------------------
;; *CAT	  ENTRY; CASSETTE OPTIONS in &E2 ; bit 0  input file open ; bit 1  output file open ; bit 2,4,5	 not used ; bit 3  current CATalogue status ; bit 6  EOF reached ; bit 7  EOF warning given 
mos_FSCV_CAT
		TODO	"mos_FSCV_CAT"
;	lda	#$08				;	F32B
;	jsr	LF344				;	F32D
;	jsr	mos_claim_serial_system_for_cass;	F330
;	lda	#$00				;	F333
;	jsr	x_search_routine		;	F335
;	jsr	LFAFC				;	F338
;LF33B:	lda	#$F7				;	F33B
;LF33D:	and	zp_cfs_w			;	F33D
;LF33F:	sta	zp_cfs_w			;	F33F
;LF341:	rts					;	F341
;; ----------------------------------------------------------------------------
;LF342:	lda	#$40				;	F342
;LF344:	ora	zp_cfs_w			;	F344
;	bne	LF33F				;	F346
;; search routine
;x_search_routine:
;	pha					;	F348
;	lda	sysvar_CFSRFS_SWITCH		;	F349
;	beq	x_cassette_routine		;	F34C
;	jsr	x_set_current_filing_system_ROM_PHROM;	F34E
;	jsr	x_Get_byte_from_data_ROM	;	F351
;	bcc	x_cassette_routine		;	F354
;	clv					;	F356
;	bvc	LF39A				;	F357
;; cassette routine
;x_cassette_routine:
;	jsr	LF77B				;	F359
;	lda	$03C6				;	F35C
;	sta	zp_fs_s+4			;	F35F
;	lda	$03C7				;	F361
;	sta	zp_fs_s+5			;	F364
;	ldx	#$FF				;	F366
;	stx	$03DF				;	F368
;	inx					;	F36B
;	stx	zp_fs_s+10			;	F36C
;	beq	LF376				;	F36E
;LF370:	jsr	LFB69				;	F370
;	jsr	LF77B				;	F373
;LF376:	lda	sysvar_CFSRFS_SWITCH		;	F376
;	beq	LF37D				;	F379
;	bvc	LF39A				;	F37B
;LF37D:	pla					;	F37D
;	pha					;	F37E
;	beq	LF3AE				;	F37F
;	jsr	x_compare_filenames		;	F381
;	bne	LF39C				;	F384
;	lda	#$30				;	F386
;	and	zp_fs_s+11			;	F388
;	beq	LF39A				;	F38A
;	lda	$03C6				;	F38C
;	cmp	zp_fs_s+6			;	F38F
;	bne	LF39C				;	F391
;	lda	$03C7				;	F393
;	cmp	zp_fs_s+7			;	F396
;	bne	LF39C				;	F398
;LF39A:	pla					;	F39A
;	rts					;	F39B
;; ----------------------------------------------------------------------------
;LF39C:	lda	sysvar_CFSRFS_SWITCH		;	F39C
;	beq	LF3AE				;	F39F
;LF3A1:	jsr	LEEAD				;	F3A1
;LF3A4:	lda	#$FF				;	F3A4
;	sta	$03C6				;	F3A6
;	sta	$03C7				;	F3A9
;	bne	LF370				;	F3AC
;LF3AE:	bvc	LF3B5				;	F3AE
;	lda	#$FF				;	F3B0
;	jsr	LF7D7				;	F3B2
;LF3B5:	ldx	#$00				;	F3B5
;	jsr	LF9D9				;	F3B7
;	lda	sysvar_CFSRFS_SWITCH		;	F3BA
;	beq	LF3C3				;	F3BD
;	bit	zp_fs_s+11			;	F3BF
;	bvc	LF3A1				;	F3C1
;LF3C3:	bit	$03CA				;	F3C3
;	bmi	LF3A4				;	F3C6
;	bpl	LF370				;	F3C8
;; file handling; on entry A determines Action Y may contain file handle or  ; X/Y point to filename terminated by &0D in memory ; A=0	 closes file in channel Y if Y=0 closes all files ; A=&40  open a file for input  (reading) X/Y points to filename ; A=&8
mos_FINDV_default_handler
		TODOSKIP "mos_FINDV_default_handler"
		rts
;	sta	zp_fs_s+12			;	F3CA
;	txa					;	F3CC
;	pha					;	F3CD
;	tya					;	F3CE
;	pha					;	F3CF
;	lda	zp_fs_s+12			;	F3D0
;	bne	x_OPEN_A_FILE			;	F3D2
;; close a file
;x_close_a_file:
;	tya					;	F3D4
;	bne	LF3E3				;	F3D5
;	jsr	mos_OSBYTE_119		;	F3D7
;	jsr	LF478				;	F3DA
;LF3DD:	lsr	zp_cfs_w			;	F3DD
;	asl	zp_cfs_w			;	F3DF
;	bcc	LF3EF				;	F3E1
;LF3E3:	lsr	a				;	F3E3
;	bcs	LF3DD				;	F3E4
;	lsr	a				;	F3E6
;	bcs	LF3EC				;	F3E7
;	jmp	LFBB1				;	F3E9
;; ----------------------------------------------------------------------------
;LF3EC:	jsr	LF478				;	F3EC
;LF3EF:	jmp	LF471				;	F3EF
;; ----------------------------------------------------------------------------
;; OPEN A FILE
;x_OPEN_A_FILE:
;	jsr	x_Read_Filename_using_Command_Line_Interpreter;	F3F2
;	bit	zp_fs_s+12			;	F3F5
;	bvc	x_open_an_output_file		;	F3F7
;; Input files +
;x_Input_files:
;	lda	#$00				;	F3F9
;	sta	$039E				;	F3FB
;	sta	$03DD				;	F3FE
;	sta	$03DE				;	F401
;	lda	#$3E				;	F404
;	jsr	LF33D				;	F406
;	jsr	mos_Claim_serial_system_for_sequential_Access;	F409
;	php					;	F40C
;	jsr	LF631				;	F40D
;	jsr	LF6B4				;	F410
;	plp					;	F413
;	ldx	#$FF				;	F414
;LF416:	inx					;	F416
;	lda	$03B2,x				;	F417
;	sta	$03A7,x				;	F41A
;	bne	LF416				;	F41D
;	lda	#$01				;	F41F
;	jsr	LF344				;	F421
;	lda	cfsrfs_BLK_SIZE			;	F424
;	ora	cfsrfs_BLK_SIZE+1		;	F427
;	bne	LF42F				;	F42A
;	jsr	LF342				;	F42C
;LF42F:	lda	#$01				;	F42F
;	ora	sysvar_CFSRFS_SWITCH		;	F431
;	bne	LF46F				;	F434
;; open an output file
;x_open_an_output_file:
;	txa					;	F436
;	bne	LF43C				;	F437
;	jmp	brkBadString				;	F439
;; ----------------------------------------------------------------------------
;LF43C:	ldx	#$FF				;	F43C
;LF43E:	inx					;	F43E
;	lda	$03D2,x				;	F43F
;	sta	$0380,x				;	F442
;	bne	LF43E				;	F445
;	lda	#$FF				;	F447
;	ldx	#$08				;	F449
;LF44B:	sta	$038B,x				;	F44B
;	dex					;	F44E
;	bne	LF44B				;	F44F
;	txa					;	F451
;	ldx	#$14				;	F452
;LF454:	sta	$0380,x				;	F454
;	inx					;	F457
;	cpx	#$1E				;	F458
;	bne	LF454				;	F45A
;	rol	$0397				;	F45C
;	jsr	mos_claim_serial_system_for_cass;	F45F
;	jsr	x_print_prompt_for_SAVE_on_TAPE ;	F462
;	jsr	LFAF2				;	F465
;	lda	#$02				;	F468
;	jsr	LF344				;	F46A
;	lda	#$02				;	F46D
;LF46F:	sta	zp_fs_s+12			;	F46F
;LF471:	pla					;	F471
;	tay					;	F472
;	pla					;	F473
;	tax					;	F474
;	lda	zp_fs_s+12			;	F475
;LF477:	rts					;	F477
;; ----------------------------------------------------------------------------
;LF478:	lda	#$02				;	F478
;	and	zp_cfs_w			;	F47A
;	beq	LF477				;	F47C
;	lda	#$00				;	F47E
;	sta	$0397				;	F480
;	lda	#$80				;	F483
;	ldx	$039D				;	F485
;	stx	$0396				;	F488
;	sta	$0398				;	F48B
;	jsr	x_SAVE_BLOCK_TO_TAPE		;	F48E
;	lda	#$FD				;	F491
;	jmp	LF33D				;	F493
;; ----------------------------------------------------------------------------
;; SAVE BLOCK TO TAPE
;x_SAVE_BLOCK_TO_TAPE:
;	jsr	mos_Claim_serial_system_for_sequential_Access;	F496
;	ldx	#$11				;	F499
;LF49B:	lda	$038C,x				;	F49B
;	sta	$03BE,x				;	F49E
;	dex					;	F4A1
;	bpl	LF49B				;	F4A2
;	stx	zp_fs_s+2			;	F4A4
;	stx	zp_fs_s+3			;	F4A6
;	inx					;	F4A8
;	stx	zp_fs_s				;	F4A9
;	lda	#$09				;	F4AB
;	sta	zp_fs_s+1			;	F4AD
;	ldx	#$7F				;	F4AF
;	jsr	x_copy_sought_filename_routine	;	F4B1
;	sta	$03DF				;	F4B4
;	jsr	LFB8E				;	F4B7
;	jsr	x_control_ACIA_and_Motor	;	F4BA
;	jsr	x_SAVE_A_BLOCK			;	F4BD
;	inc	$0394				;	F4C0
;	bne	LF4C8				;	F4C3
;	inc	$0395				;	F4C5
;LF4C8:	rts					;	F4C8
;; ----------------------------------------------------------------------------
;; OSBGET  get a byte from a file; on ENTRY	 Y contains channel number ; on EXIT	    X and Y are preserved C=0 indicates valid character ; A contains character (or error) A=&FE End Of File ; push X and Y 
;mos_OSBGET_get_a_byte_from_a_file:
;	txa					;	F4C9
;	pha					;	F4CA
;	tya					;	F4CB
;	pha					;	F4CC
;	lda	#$01				;	F4CD
;	jsr	x_confirm_file_is_open		;	F4CF
;	lda	zp_cfs_w			;	F4D2
;	asl	a				;	F4D4
;	bcs	LF523				;	F4D5
;	asl	a				;	F4D7
;	bcc	LF4E3				;	F4D8
;	lda	#$80				;	F4DA
;	jsr	LF344				;	F4DC
;	lda	#$FE				;	F4DF
;	bcs	LF51B				;	F4E1
;LF4E3:	ldx	$039E				;	F4E3
;	inx					;	F4E6
;	cpx	cfsrfs_BLK_SIZE			;	F4E7
;	bne	LF516				;	F4EA
;	bit	cfsrfs_BLK_FLAG			;	F4EC
;	bmi	LF513				;	F4EF
;	lda	cfsrfs_LAST_CHAR		;	F4F1
;	pha					;	F4F4
;	jsr	mos_Claim_serial_system_for_sequential_Access;	F4F5
;	php					;	F4F8
;	jsr	x_read_a_block			;	F4F9
;	plp					;	F4FC
;	pla					;	F4FD
;	sta	zp_fs_s+12			;	F4FE
;	clc					;	F500
;	bit	cfsrfs_BLK_FLAG			;	F501
;	bpl	LF51D				;	F504
;	lda	cfsrfs_BLK_SIZE			;	F506
;	ora	cfsrfs_BLK_SIZE+1		;	F509
;	bne	LF51D				;	F50C
;	jsr	LF342				;	F50E
;	bne	LF51D				;	F511
;LF513:	jsr	LF342				;	F513
;LF516:	dex					;	F516
;	clc					;	F517
;	lda	$0A00,x				;	F518
;LF51B:	sta	zp_fs_s+12			;	F51B
;LF51D:	inc	$039E				;	F51D
;	jmp	LF471				;	F520
;; ----------------------------------------------------------------------------
;LF523:	brk					;	F523
;	FCB	$DF				;	F524
;	eor	zp_lang+79			;	F525
;	lsr	zp_lang				;	F527
;; OSBPUT  WRITE A BYTE TO FILE; ON ENTRY  Y contains channel number A contains byte to be written 
;mos_OSBPUT_WRITE_A_BYTE_TO_FILE:
;	sta	zp_fs_w+4			;	F529
;	txa					;	F52B
;	pha					;	F52C
;	tya					;	F52D
;	pha					;	F52E
;	lda	#$02				;	F52F
;	jsr	x_confirm_file_is_open		;	F531
;	ldx	$039D				;	F534
;	lda	zp_fs_w+4			;	F537
;	sta	$0900,x				;	F539
;	inx					;	F53C
;	bne	LF545				;	F53D
;	jsr	x_SAVE_BLOCK_TO_TAPE		;	F53F
;	jsr	LFAF2				;	F542
;LF545:	inc	$039D				;	F545
;	lda	zp_fs_w+4			;	F548
;	jmp	LF46F				;	F54A


*************************************************************************
*                                                                       *
*                                                                       *
*       OSBYTE 139      Select file options                             *
*                                                                       *
*                                                                       *
*************************************************************************
;ON ENTRY  Y contains option value  X contains option No. see *OPT X,Y 
;this applies largely to CFS LOAD SAVE CAT and RUN
;X=1    is message switch  
;       Y=0     no messages
;       Y=1     short messages
;       Y=2     gives detailed information on load and execution addresses

;X=2    is error handling  
;       Y=0     ignore errors
;       Y=1     prompt for a retry
;       Y=2     abort operation

;X=3    is interblock gap for BPUT# and PRINT# 
;       Y=0-127 set gap in 1/10ths Second
;       Y > 127 use default values

mos_FSCV_OPT					; LF54D
		m_txa					;A=X
		beq	LF57E				;if A=0 F57E
		cmpx	#$03				;if X=3
		beq	x_set_interblock_gap		;F573 to set interblock gap
		cmpy	#$03				;else if Y>2 then BAD COMMAND error
		bhs	LF55E				;
		leax	-1,X				;X=X-1
		beq	x_message_control		;i.e. if X=1 F561 message control
		leax	-1,X				;X=X-1
		beq	x_error_response		;i.e. if X=2 F568 error response
LF55E		jmp	brkBadCommand		;else E310 to issue Bad Command error
x_message_control
		lda	#$33				;to set lower two bits of each nybble as mask
		leay	3,Y				;Y=Y+4
		bra	1F				;goto F56A
x_error_response
		lda	#$CC				;setting top two bits of each nybble as mask
		leay	1,Y				;Y=Y+1
1		anda	zp_opt_val			;clear lower two bits of each nybble
LF56D		ora	x_DEFAULT_OPT_VALUES_TABLE,y	;or with table value
		sta	zp_opt_val			;store it in &E3
		rts					;return

         ;setting of &E3
         ;
         ;lower nybble sets LOAD options
         ;upper sets SAVE options
         
         ;0000   Ignore errors,          no messages
         ;0001   Abort if error,         no messages
         ;0010   Retry after error,      no messages
         ;1000   Ignore error            short messages
         ;1001   Abort if error          short messages
         ;1010   Retry after error       short messages
         ;1100   Ignore error            long messages
         ;1101   Abort if error          long messages
         ;1110   Retry after error       long messages
 
 
 
 ***********set interblock gap *******************************************
x_set_interblock_gap
		m_tya					;A=Y
		bmi	1F				;if Y>127 use default values
		bne	2F				;if Y<>0 skip next instruction
1		lda	#$19				;else A=&19
2		sta	fsvar_seq_block_gap		;sequential block gap
		rts					;return
; ----------------------------------------------------------------------------
LF57E		ldy	#0				;	assume A always 0 and was a tay
		bra	LF56D				;jump to F56D


;; DEFAULT OPT VALUES TABLE
x_DEFAULT_OPT_VALUES_TABLE
		FCB	$A1, $00, $22, $11, $00, $88, $CC	; LF587

;LF588:	dec	zp_fs_w				;	F588
;	lda	sysvar_CFSRFS_SWITCH		;	F58A
;	beq	LF596				;	F58D
;	jsr	x_ROM_SERVICE			;	F58F
;	tay					;	F592
;	clc					;	F593
;	bcc	LF5B0				;	F594
;LF596:	lda	sheila_ACIA_CTL				;	F596
;	pha					;	F599
;	and	#$02				;	F59A
;	beq	LF5A9				;	F59C
;	ldy	zp_fs_w+10			;	F59E
;	beq	LF5A9				;	F5A0
;	pla					;	F5A2
;	lda	zp_fs_s+13			;	F5A3
;	sta	LFE09				;	F5A5
;	rts					;	F5A8
;; ----------------------------------------------------------------------------
;LF5A9:	ldy	LFE09				;	F5A9
;	pla					;	F5AC
;	lsr	a				;	F5AD
;	lsr	a				;	F5AE
;	lsr	a				;	F5AF
;LF5B0:	ldx	zp_fs_w+2			;	F5B0
;	beq	LF61D				;	F5B2
;	dex					;	F5B4
;	bne	LF5BD				;	F5B5
;	bcc	LF61D				;	F5B7
;	ldy	#$02				;	F5B9
;	bne	LF61B				;	F5BB
;LF5BD:	dex					;	F5BD
;	bne	LF5D3				;	F5BE
;	bcs	LF61D				;	F5C0
;	tya					;	F5C2
;	jsr	LFB78				;	F5C3
;	ldy	#$03				;	F5C6
;	cmp	#$2A				;	F5C8
;	beq	LF61B				;	F5CA
;	jsr	x_control_cassette_system	;	F5CC
;	ldy	#$01				;	F5CF
;	bne	LF61B				;	F5D1
;LF5D3:	dex					;	F5D3
;	bne	LF5E2				;	F5D4
;	bcs	LF5DC				;	F5D6
;	sty	zp_fs_s+13			;	F5D8
;	beq	LF61D				;	F5DA
;LF5DC:	lda	#$80				;	F5DC
;	sta	zp_fs_w				;	F5DE
;	bne	LF61D				;	F5E0
;LF5E2:	dex					;	F5E2
;	bne	LF60E				;	F5E3
;	bcs	LF616				;	F5E5
;	tya					;	F5E7
;	jsr	x_perform_CRC			;	F5E8
;	ldy	zp_fs_s+12			;	F5EB
;	inc	zp_fs_s+12			;	F5ED
;	bit	zp_fs_s+13			;	F5EF
;	bmi	LF600				;	F5F1
;	jsr	x_check_if_second_processor_file_test_tube_prescence;	F5F3
;	beq	LF5FD				;	F5F6
;	stx	LFEE5				;	F5F8
;	bne	LF600				;	F5FB
;LF5FD:	txa					;	F5FD
;	sta	(zp_fs_s),y			;	F5FE
;LF600:	iny					;	F600
;	cpy	$03C8				;	F601
;	bne	LF61D				;	F604
;	lda	#$01				;	F606
;	sta	zp_fs_s+12			;	F608
;	ldy	#$05				;	F60A
;	bne	LF61B				;	F60C
;LF60E:	tya					;	F60E
;	jsr	x_perform_CRC			;	F60F
;	dec	zp_fs_s+12			;	F612
;	bpl	LF61D				;	F614
;LF616:	jsr	ACIA_rst_ctl3				;	F616
;	ldy	#$00				;	F619
;LF61B:	sty	zp_fs_w+2			;	F61B
;LF61D:	rts					;	F61D
;; ----------------------------------------------------------------------------
;; OSBYTE 127 check for end of file;  
mos_FSCV_EOF
		TODO	"mos_FSCV_EOF"
;	pha					;	F61E
;	tya					;	F61F
;	pha					;	F620
;	txa					;	F621
;	tay					;	F622
;	lda	#$03				;	F623
;	jsr	x_confirm_file_is_open		;	F625
;	lda	zp_cfs_w			;	F628
;	and	#$40				;	F62A
;	tax					;	F62C
;	pla					;	F62D
;	tay					;	F62E
;	pla					;	F62F
;	rts					;	F630
;; ----------------------------------------------------------------------------
;LF631:	lda	#$00				;	F631
;	sta	zp_fs_s+4			;	F633
;	sta	zp_fs_s+5			;	F635
;LF637:	lda	zp_fs_s+4			;	F637
;	pha					;	F639
;	sta	zp_fs_s+6			;	F63A
;	lda	zp_fs_s+5			;	F63C
;	pha					;	F63E
;	sta	zp_fs_s+7			;	F63F
;	jsr	LFA46				;	F641
;	FCB	$53				;	F644
;	adc	zp_lang+97			;	F645
;	FCB	$72				;	F647
;	FCB	$63				;	F648
;	pla					;	F649
;	adc	#$6E				;	F64A
;	FCB	$67				;	F64C
;	ora	$A900				;	F64D
;	FCB	$FF				;	F650
;	jsr	x_search_routine		;	F651
;	pla					;	F654
;	sta	zp_fs_s+5			;	F655
;	pla					;	F657
;	sta	zp_fs_s+4			;	F658
;	lda	zp_fs_s+6			;	F65A
;	ora	zp_fs_s+7			;	F65C
;	bne	LF66D				;	F65E
;	sta	zp_fs_s+4			;	F660
;	sta	zp_fs_s+5			;	F662
;	lda	zp_fs_w+1			;	F664
;	bne	LF66D				;	F666
;	ldx	#$B1				;	F668
;	jsr	x_copy_sought_filename_routine	;	F66A
;LF66D:	lda	sysvar_CFSRFS_SWITCH		;	F66D
;	beq	LF685				;	F670
;	bvs	LF685				;	F672
brkFileNotFound						; LF674
		DO_BRK  $D6, "File Not found"
;LF685:	ldy	#$FF				;	F685
;	sty	$03DF				;	F687
;	rts					;	F68A
;; ----------------------------------------------------------------------------
mos_CLOSE_EXEC_FILE
		clra					; A=0 means close any current file
; * EXEC
		; always entered with A=0 but Z=1 flag decided whether to close????
		; Y ignored
		; X filename to open in Z=0
mos_STAR_EXEC
		pshs	CC,Y				; save flags on stack
						; save Y
		ldb	sysvar_EXEC_FILE		; EXEC file handle
		sta	sysvar_EXEC_FILE		; EXEC file handle
		tstb					; DB: need extra TST here as STA sets Z	
		beq	1F				
		clra
		tfr	D,Y				; if original file is not 0 close file via OSFIND
		jsr	OSFIND				; Y=original file handle, A=0 on entry!?
1
;;;	ldy	zp_mos_OS_wksp			;else Y= original Y
		puls	CC,Y				;get back flags and Y
		beq	1F				;if Z set on entry exit else
		lda	#$40				;A=&40
		jsr	OSFIND				;to open an input file, file name passed in X
		tsta					;Y=A
		beq	brkFileNotFound			;If Y=0 'File not found' else store
		sta	sysvar_EXEC_FILE		;EXEC file handle
1		rts					;return
;; ----------------------------------------------------------------------------
;; read a block
;x_read_a_block:
;	ldx	#$A6				;	F6AC
;	jsr	x_copy_sought_filename_routine	;	F6AE
;	jsr	LF77B				;	F6B1
;LF6B4:	lda	$03CA				;	F6B4
;	lsr	a				;	F6B7
;	bcc	LF6BD				;	F6B8
;	jmp	x_LOCKED_FILE_ROUTINE		;	F6BA
;; ----------------------------------------------------------------------------
;LF6BD:	lda	$03DD				;	F6BD
;	sta	zp_fs_s+4			;	F6C0
;	lda	$03DE				;	F6C2
;	sta	zp_fs_s+5			;	F6C5
;	lda	#$00				;	F6C7
;	sta	zp_fs_s				;	F6C9
;	lda	#$0A				;	F6CB
;	sta	zp_fs_s+1			;	F6CD
;	lda	#$FF				;	F6CF
;	sta	zp_fs_s+2			;	F6D1
;	sta	zp_fs_s+3			;	F6D3
;	jsr	LF7D5				;	F6D5
;	jsr	x_LOAD				;	F6D8
;	bne	LF702				;	F6DB
;	lda	$0AFF				;	F6DD
;	sta	cfsrfs_LAST_CHAR		;	F6E0
;	jsr	LFB69				;	F6E3
;	stx	$03DD				;	F6E6
;	sty	$03DE				;	F6E9
;	ldx	#$02				;	F6EC
;LF6EE:	lda	$03C8,x				;	F6EE
;	sta	cfsrfs_BLK_SIZE,x		;	F6F1
;	dex					;	F6F4
;	bpl	LF6EE				;	F6F5
;	bit	cfsrfs_BLK_FLAG			;	F6F7
;	bpl	LF6FF				;	F6FA
;	jsr	LF249				;	F6FC
;LF6FF:	jmp	LFAF2				;	F6FF
;; ----------------------------------------------------------------------------
;LF702:	jsr	LF637				;	F702
;	bne	LF6B4				;	F705
;LF707:	cmp	#$2A				;	F707
;	beq	LF742				;	F709
;	cmp	#$23				;	F70B
;	bne	LF71E				;	F70D
;	inc	$03C6				;	F70F
;	bne	LF717				;	F712
;	inc	$03C7				;	F714
;LF717:	ldx	#$FF				;	F717
;	bit	mostbl_SYSVAR_DEFAULT_SETTINGS+65;	F719
;	bne	LF773				;	F71C
;LF71E:	lda	#$F7				;	F71E
;	jsr	LF33D				;	F720
;	brk					;	F723
;	FCB	$D7				;	F724
;	FCB	$42				;	F725
;	adc	(zp_lang+100,x)			;	F726
;	jsr	L4F52				;	F728
;	FCB	$4D				;	F72B
;	brk					;	F72C
;; : pick up a header
;x_pick_up_a_header:
;	ldy	#$FF				;	F72D
;	jsr	x_switch_Motor_on		;	F72F
;	lda	#$01				;	F732
;	sta	zp_fs_w+2			;	F734
;	jsr	x_control_cassette_system	;	F736
;LF739:	jsr	x_confirm_CFS_not_operating_nor_ESCAPE_flag_set;	F739
;	lda	#$03				;	F73C
;	cmp	zp_fs_w+2			;	F73E
;	bne	LF739				;	F740
;LF742:	ldy	#$00				;	F742
;	jsr	x_set_0_checksum_bytes		;	F744
;LF747:	jsr	x_get_character_from_file_and_do_CRC;	F747
;	bvc	LF766				;	F74A
;	sta	$03B2,y				;	F74C
;	beq	LF757				;	F74F
;	iny					;	F751
;	cpy	#$0B				;	F752
;	bne	LF747				;	F754
;	dey					;	F756
;LF757:	ldx	#$0C				;	F757
;LF759:	jsr	x_get_character_from_file_and_do_CRC;	F759
;	bvc	LF766				;	F75C
;	sta	$03B2,x				;	F75E
;	inx					;	F761
;	cpx	#$1F				;	F762
;	bne	LF759				;	F764
;LF766:	tya					;	F766
;	tax					;	F767
;	lda	#$00				;	F768
;	sta	$03B2,y				;	F76A
;	lda	zp_fs_s+14			;	F76D
;	ora	zp_fs_s+15			;	F76F
;	sta	zp_fs_w+1			;	F771
;LF773:	jsr	LFB78				;	F773
;	sty	zp_fs_w+2			;	F776
;	txa					;	F778
;	bne	LF7D4				;	F779
;LF77B:	lda	sysvar_CFSRFS_SWITCH		;	F77B
;	beq	x_pick_up_a_header		;	F77E
;LF780:	jsr	x_ROM_SERVICE			;	F780
;	cmp	#$2B				;	F783
;	bne	LF707				;	F785
;; terminator found
;x_terminator_found:
;	lda	#$08				;	F787
;	and	zp_cfs_w			;	F789
;	beq	LF790				;	F78B
;	jsr	LF24D				;	F78D
;LF790:	jsr	x_Get_byte_from_data_ROM	;	F790
;	bcc	LF780				;	F793
;	clv					;	F795
;	rts					;	F796
;; ----------------------------------------------------------------------------
;; get character from file and do CRC;  
;x_get_character_from_file_and_do_CRC:
;	lda	sysvar_CFSRFS_SWITCH		;	F797
;	beq	LF7AD				;	F79A
;	txa					;	F79C
;	pha					;	F79D
;	tya					;	F79E
;	pha					;	F79F
;	jsr	x_ROM_SERVICE			;	F7A0
;	sta	zp_fs_s+13			;	F7A3
;	lda	#$FF				;	F7A5
;	sta	zp_fs_w				;	F7A7
;	pla					;	F7A9
;	tay					;	F7AA
;	pla					;	F7AB
;	tax					;	F7AC
;LF7AD:	jsr	x_check_for_Escape_and_loop_till_bit_7_of_FS_buffer_flag;	F7AD
;; perform CRC
;x_perform_CRC:
;	php					;	F7B0
;	pha					;	F7B1
;	sec					;	F7B2
;	ror	zp_fs_w+11			;	F7B3
;	eor	zp_fs_s+15			;	F7B5
;	sta	zp_fs_s+15			;	F7B7
;LF7B9:	lda	zp_fs_s+15			;	F7B9
;	rol	a				;	F7BB
;	bcc	LF7CA				;	F7BC
;	ror	a				;	F7BE
;	eor	#$08				;	F7BF
;	sta	zp_fs_s+15			;	F7C1
;	lda	zp_fs_s+14			;	F7C3
;	eor	#$10				;	F7C5
;	sta	zp_fs_s+14			;	F7C7
;	sec					;	F7C9
;LF7CA:	rol	zp_fs_s+14			;	F7CA
;	rol	zp_fs_s+15			;	F7CC
;	lsr	zp_fs_w+11			;	F7CE
;	bne	LF7B9				;	F7D0
;	pla					;	F7D2
;	plp					;	F7D3
;LF7D4:	rts					;	F7D4
;; ----------------------------------------------------------------------------
;LF7D5:	lda	#$00				;	F7D5
;LF7D7:	sta	zp_fs_s+13			;	F7D7
;	ldx	#$00				;	F7D9
;	stx	zp_fs_s+12			;	F7DB
;	bvc	LF7E9				;	F7DD
;	lda	$03C8				;	F7DF
;	ora	$03C9				;	F7E2
;	beq	LF7E9				;	F7E5
;	ldx	#$04				;	F7E7
;LF7E9:	stx	zp_fs_w+2			;	F7E9
;	rts					;	F7EB


FILL2
FILL2LEN 	EQU	MOSSTRINGS-FILL2
		FILL	$FF,FILL2LEN


		ORG	REMAPPED_HW_VECTORS
*************************************************************
*     R E M A P P E D    H A R D W A R E    V E C T O R S   *
*************************************************************
	IF CPU_6309
XDIV0		FDB	mos_handle_div0			; $FFF0   	; Hardware vectors, paged in to $F7Fx from $FFFx
	ELSE
		FDB	0
	ENDIF
XSWI3V		FDB	mos_handle_swi3			; $FFF2		; on 6809 we use this instead of 6502 BRK
XSWI2V		FDB	mos_handle_swi2			; $FFF4
XFIRQV		FDB	vec_nmi				; $FFF6
XIRQV		FDB	mos_handle_irq			; $FFF8
XSWIV		FDB	mos_handle_swi			; $FFFA
XNMIV		FDB	mos_handle_nmi			; $FFFC
XRESETV		FDB	mos_handle_res			; $FFFE
	IF MACH_SBC09
		FDB	mos_handle_boot_menu		; $F800		; boot menu entry point, current mapping in B
		FCB	"SBC09MOS"
		FCN	"Midi-mos test"	;TODO: pick up version number here?
	ENDIF

*******************************************************************************
* 6809 debug and specials
*******************************************************************************

_ytoa	pshs	Y
		leas	1,S
		puls	A,PC

_m_tax_se		; sign extend A into X
		sta	,-S
		bmi	1F
		clr	,-S
		puls	X,PC
1		clr	,-S
		dec	,S
		puls	X,PC

;; 	IF MACH_BEEB && NOICE && !NOICE_MY
;; debug_init_beeb
;; 		; force pre-init of ACIA
;; 		jsr	ACIA_rst_ctl3		; master reset of ACIA
;; 		lda	#$40			; 19,200/19,200/serial
;; 		sta	sheila_SERIAL_ULA
;; 		lda	#$56			; div 64, 8N1, RTS, TX irq disable
;; 		sta	sheila_ACIA_CTL
;; 		clr	sheila_ACIA_DATA	; send a zero byte to wake it up!
;; 		rts
;; 	ENDIF

		; send characters after call to the UART
debug_print
		PSHS	X
		LDX	2,S
		jsr	debug_printX
		STX	2,S
		PULS	X,PC

debug_printX
		pshs	A
1		LDA	,X+	
		BEQ	2F
		ANDA	#$7F
		JSR	debug_print_ch
		BRA	1B
2		puls	A,PC

debug_print_newl
		pshs	A
		lda	#13
		jsr	debug_print_ch
		lda	#10
		jsr	debug_print_ch
		puls	A,PC

debug_print_hex
		sta	,-S
		lsra
		lsra
		lsra
		lsra
		jsr	debug_print_hex_digit
		lda	,S
		jsr	debug_print_hex_digit
		puls	A,PC
debug_print_hex_digit
		anda	#$F
		adda	#'0'
		cmpa	#'9'
		bls	1F
		adda	#'A'-'9'-1
1		jmp	debug_print_ch

;debug_print_ch	pshs	A,X				; myelin port, no wait
;		ldx	#100
;		lda	#2
;2		bita	$FCA1
;		bne	1F
;		leax	-1,X
;		bne	2B
;1		lda	,S
;		anda	#$7F
;		sta	$FCA0				
;		puls	A,X,PC

	IF MACH_CHIPKIT
debug_print_ch	; TODO - do debug on serial port
		RTS
	ELSE

debug_print_ch	pshs	A,X
	IF MACH_BEEB | MACH_CHIPKIT
		ldx	#400
		lda	#ACIA_TDRE
2		bita	sheila_ACIA_CTL
		bne	1F
		leax	-1,X
		bne	2B
1		lda	,S
		anda	#$7F
		sta	sheila_ACIA_DATA	
	ENDIF
		jsr	mos_VDU_WRCH
		;TODO: SBC09: debug over 2nd channel
		puls	A,X,PC
	ENDIF

;;;mostbl_BUFFER_ADDRESS_LO_LOOK_UP_TABLE
;;;mostbl_BUFFER_ADDRESS_HI_LOOK_UP_TABLE
mostbl_BUFFER_ADDRESS_PTR_LUT
		BUFFER_PTR_ADDR		BUFFER_KEYB_START,BUFFER_KEYB_END
		BUFFER_PTR_ADDR		BUFFER_SERI_START,BUFFER_SERI_END
		BUFFER_PTR_ADDR		BUFFER_SERO_START,BUFFER_SERO_END
		BUFFER_PTR_ADDR		BUFFER_LPT_START,BUFFER_LPT_END
		BUFFER_PTR_ADDR		BUFFER_SND0_START,BUFFER_SND0_END
		BUFFER_PTR_ADDR		BUFFER_SND1_START,BUFFER_SND1_END
		BUFFER_PTR_ADDR		BUFFER_SND2_START,BUFFER_SND2_END
		BUFFER_PTR_ADDR		BUFFER_SND3_START,BUFFER_SND3_END
		BUFFER_PTR_ADDR		BUFFER_SPCH_START,BUFFER_SPCH_END

;;;mostbl_BUFFER_START_ADDRESS_OFFSET
mostbl_BUFFER_ADDRESS_OFFS
		BUFFER_ACC_OFF		BUFFER_KEYB_START,BUFFER_KEYB_END
		BUFFER_ACC_OFF		BUFFER_SERI_START,BUFFER_SERI_END
		BUFFER_ACC_OFF		BUFFER_SERO_START,BUFFER_SERO_END
		BUFFER_ACC_OFF		BUFFER_LPT_START,BUFFER_LPT_END
		BUFFER_ACC_OFF		BUFFER_SND0_START,BUFFER_SND0_END
		BUFFER_ACC_OFF		BUFFER_SND1_START,BUFFER_SND1_END
		BUFFER_ACC_OFF		BUFFER_SND2_START,BUFFER_SND2_END
		BUFFER_ACC_OFF		BUFFER_SND3_START,BUFFER_SND3_END
		BUFFER_ACC_OFF		BUFFER_SPCH_START,BUFFER_SPCH_END


mc_logo
		FCB	$03,$0F,$1F,$3B,$71,$71,$F0,$E4
		FCB	$80,$E0,$F0,$B8,$1C,$1C,$1E,$4E
		FCB	$EF,$6F,$6F,$3F,$1F,$0F,$03,$00
		FCB	$EE,$EC,$EC,$F8,$F0,$E0,$80,$00

mc_logo_0
		FCB	$00,$03,$0F,$3F,$7F,$7E,$FC,$F9
		FCB	$3F,$FF,$DF,$8F,$07,$03,$73,$FC
		FCB	$F8,$FF,$F7,$E3,$C1,$80,$3C,$7F
		FCB	$00,$80,$E0,$F8,$FC,$FC,$7E,$3E

		FCB	$F3,$77,$77,$3F,$0F,$03,$00,$00
		FCB	$FE,$FF,$FF,$FF,$FF,$FF,$3F,$00
		FCB	$FF,$FF,$FF,$FF,$FF,$FF,$F8,$00
		FCB	$9E,$DC,$DC,$F8,$E0,$80,$00,$00


	IF MACH_CHIPKIT AND DOCHIPKIT_RTC
mos_STAR_TIME
		;TODO - find somewhere else to put this?
		ldx	#stack
		jsr	mos_OSWORD_E_read_rtc_0
		ldx	#stack

1		lda	,X+
		jsr	OSASCI
		cmpa	#$D
		bne	1B
		rts

mos_OSWORD_F_write_rtc
		leax	1,X
		pshs	CC
		SEI
		jsr	rtc_wait
		cmpa	#8
		beq	mos_OSWORD_F_write_rtc_8
		cmpa	#15
		beq	mos_OSWORD_F_write_rtc_15
		cmpa	#24
		beq	mos_OSWORD_F_write_rtc_24
mos_OSWORD_F_fin
		puls	CC,PC

		; date and time
mos_OSWORD_F_write_rtc_24
		jsr	mos_OSWORD_F_write_rtc_15_x
mos_OSWORD_F_write_rtc_8
		jsr	bcd_at_X
		ldb	#RTC_REG_HOURS
		jsr	rtc_write
		leax	1,X
		jsr	bcd_at_X
		ldb	#RTC_REG_MINUTES
		jsr	rtc_write
		leax	1,X
		jsr	bcd_at_X
		ldb	#RTC_REG_SECONDS
		jsr	rtc_write
		bra	mos_OSWORD_F_fin

mos_OSWORD_F_write_rtc_15_x
		pshs	CC
mos_OSWORD_F_write_rtc_15
		pshsw
		ldw	,X			; D contains first two letters of day
		ldy	#tbl_days
		ldb	#7
		jsr	day_find
		ldb	#RTC_REG_DOW
		jsr	rtc_write

		leax	4,X
		jsr	bcd_at_X
		ldb	#RTC_REG_DAY
		jsr	rtc_write
		
		leax	1,X
		ldw	1,X			; D contains second two letters of month
		ldy	#tbl_months+1
		ldb	#12
		jsr	day_find
		ldb	#RTC_REG_MONTH
		jsr	rtc_write

		leax	6,X
		jsr	bcd_at_X
		ldb	#RTC_REG_YEAR
		jsr	rtc_write
		
		leax	1,X
		pulsw
		bra	mos_OSWORD_F_fin


;  0123456789ABCDEF012345678
;  Day,DD Mon Year.HH:MM:SS£
;  YMDWhms


day_find
		clra
1		cmpw	,Y++
		beq	2F
		leay	1,Y
		inca
		decb
		bpl	1B
		clra
2		inca
		rts

bcd_at_X	jsr	bcd_digit
		asla
		asla
		asla
		asla
		sta	,-S
		jsr	bcd_digit
		adda	,S+
		rts


bcd_digit	lda	,X+
		suba	#'0'
1		cmpa	#9
		bls	1F
		suba	#20
		bra	1B
1		rts


mos_OSWORD_E_read_rtc
		;; lda	,X
		tsta
		beq	mos_OSWORD_E_read_rtc_0
		cmpa	#1
		beq	mos_OSWORD_E_read_rtc_1
		cmpa	#2
		beq	mos_OSWORD_E_read_rtc_2
		rts
mos_OSWORD_E_read_rtc_0
		stx	,--S
		jsr	mos_OSWORD_E_read_rtc_1		; get BCD time
		ldx	,S++
		leax	-1,X
		bra	mos_OSWORD_E_read_rtc_2
mos_OSWORD_E_read_rtc_1

		jsr	rtc_wait

		pshs	CC
		SEI					; we mustn't be interrupted
		ldb	#9
1		jsr	rtc_read
		sta	,X+
		decb
		cmpb	#5
		bgt	1B
		decb
		bpl	1B

		puls	CC,PC

mos_OSWORD_E_read_rtc_2
		; seconds
		leay	$17,X
		lda	7,x
		jsr	mos_hexstr_Y
		;minutes
		leay	$14,X
		lda	6,X
		jsr	mos_hexstr_Y
		;hours
		leay	$11,X
		lda	5,X
		jsr	mos_hexstr_Y
		; YY
		leay	$E,X
		lda	1,X
		jsr	mos_hexstr_Y
		; century
		ldb	1,X
		lda	#$19
		cmpa	#$80
		adca	#0
		daa
		leay	$C,X
		jsr	mos_hexstr_Y
		; DD
		leay	$5,X
		lda	3,X
		jsr	mos_hexstr_Y
		; Mon
		stx	,--S
		ldb	$2,X
		cmpb	#$10				; convert BCD to binary
		blo	1F
		subb	#6
1		leay	8,X
		ldx	#tbl_months
		jsr	domonth

		ldx	,S
		; Day
		ldb	$4,X
		leay	1,X
		ldx	#tbl_days
		jsr	doday

		ldx	,S++

		; puntuation
		lda	#$D
		sta	$19,X
		lda	#':'
		sta	$13,X
		sta	$16,X
		lda	#'.'
		sta	$10,X
		lda	#','
		sta	$4,X
		lda	#' '
		sta	$7,X
		sta	$B,X


		rts

domonth
doday
		decb
		stb	,-S
		aslb
		addb	,S+
		abx
		ldb	#3
1		lda	,X+
		sta	,Y+
		decb
		bne	1B
		rts



tbl_days	fcb	"SunMonTueWedThuFriSat"
tbl_months	fcb	"JanFebMarAprMayJumJulAugSepOctNovDec"


rtc_wait					; wait for a UIP clear or if set wait for it to end
		std	,--S
		ldb	#$A
		jsr	rtc_read
		tsta
		bpl	2F			; if not UIP we have 240uS to read clock

1		ldb	#$A
		jsr	rtc_read
		tsta
		bmi	1B			; wait for UIP to go low

2		puls	D,PC


		; rtc_write A=data, B=address
rtc_write
		pshs	CC,A

		SEI					; disable interrupts

		; AS low
		lda	#BITS_RTC_AS_OFF
		sta	sheila_SYSVIA_orb

		; DS low
		lda	#BITS_RTC_DS
		sta	sheila_SYSVIA_orb

		; AS hi
		lda	#BITS_RTC_AS_ON
		sta	sheila_SYSVIA_orb

		lda	#$FF
		sta	sheila_SYSVIA_ddra

		; rtc address
		stb	sheila_SYSVIA_ora_nh

		; CS low
		lda	#BITS_RTC_CS 
		sta	sheila_SYSVIA_orb

		; RnW lo
		lda	#BITS_RTC_RnW
		sta	sheila_SYSVIA_orb

		; AS low
		lda	#BITS_RTC_AS_OFF
		sta	sheila_SYSVIA_orb

		; DS hi
		lda	#BITS_RTC_DS + BITS_LAT_ON
		sta	sheila_SYSVIA_orb

		lda	1,S
		sta	sheila_SYSVIA_ora_nh

		; DS low
		lda	#BITS_RTC_DS
		sta	sheila_SYSVIA_orb

		; CS hi
		lda	#BITS_RTC_CS + BITS_LAT_ON
		sta	sheila_SYSVIA_orb

		puls	CC,A,PC


rtc_read	
		pshs	CC,A

		SEI					; disable interrupts

		; AS low
		lda	#BITS_RTC_AS_OFF
		sta	sheila_SYSVIA_orb

		; DS low
		lda	#BITS_RTC_DS
		sta	sheila_SYSVIA_orb

		; AS hi
		lda	#BITS_RTC_AS_ON
		sta	sheila_SYSVIA_orb

		lda	#$FF
		sta	sheila_SYSVIA_ddra

		; rtc address
		stb	sheila_SYSVIA_ora_nh

		; CS low
		lda	#BITS_RTC_CS 
		sta	sheila_SYSVIA_orb

		; slow D all in
		clr	sheila_SYSVIA_ddra

		; RnW hi
		lda	#BITS_RTC_RnW + BITS_LAT_ON
		sta	sheila_SYSVIA_orb

		; AS low
		lda	#BITS_RTC_AS_OFF
		sta	sheila_SYSVIA_orb

		; DS hi
		lda	#BITS_RTC_DS + BITS_LAT_ON
		sta	sheila_SYSVIA_orb

		lda	sheila_SYSVIA_ora_nh
		sta	1,S

		; DS low
		lda	#BITS_RTC_DS
		sta	sheila_SYSVIA_orb

		; CS hi
		lda	#BITS_RTC_CS + BITS_LAT_ON
		sta	sheila_SYSVIA_orb

		puls	CC,A,PC

	ENDIF



;; ----------------------------------------------------------------------------
;; SAVE A BLOCK
;x_SAVE_A_BLOCK:
;	php					;	F7EC
;	ldx	#$03				;	F7ED
;	lda	#$00				;	F7EF
;LF7F1:	sta	$03CB,x				;	F7F1
;	dex					;	F7F4
;	bpl	LF7F1				;	F7F5
;	lda	$03C6				;	F7F7
;	ora	$03C7				;	F7FA
;	bne	LF804				;	F7FD
;	jsr	x_generate_a_5_second_delay	;	F7FF
;	beq	LF807				;	F802
;LF804:	jsr	x_generate_delay_set_by_interblock_gap;	F804
;LF807:	lda	#$2A				;	F807
;	sta	zp_fs_s+13			;	F809
;	jsr	LFB78				;	F80B
;	jsr	x_set_ACIA_control_register	;	F80E
;	jsr	x_check_for_Escape_and_loop_till_bit_7_of_FS_buffer_flag;	F811
;	dey					;	F814
;LF815:	iny					;	F815
;	lda	$03D2,y				;	F816
;	sta	$03B2,y				;	F819
;	jsr	x_transfer_byte_to_CFS_and_do_CRC;	F81C
;	bne	LF815				;	F81F
;; : deal with rest of header
;x_deal_with_rest_of_header:
;	ldx	#$0C				;	F821
;LF823:	lda	$03B2,x				;	F823
;	jsr	x_transfer_byte_to_CFS_and_do_CRC;	F826
;	inx					;	F829
;	cpx	#$1D				;	F82A
;	bne	LF823				;	F82C
;	jsr	x_save_checksum_to_TAPE_reset_buffer_flag;	F82E
;	lda	$03C8				;	F831
;	ora	$03C9				;	F834
;	beq	LF855				;	F837
;	ldy	#$00				;	F839
;	jsr	x_set_0_checksum_bytes		;	F83B
;LF83E:	lda	(zp_fs_s),y			;	F83E
;	jsr	x_check_if_second_processor_file_test_tube_prescence;	F840
;	beq	LF848				;	F843
;	ldx	LFEE5				;	F845
;LF848:	txa					;	F848
;	jsr	x_transfer_byte_to_CFS_and_do_CRC;	F849
;	iny					;	F84C
;	cpy	$03C8				;	F84D
;	bne	LF83E				;	F850
;	jsr	x_save_checksum_to_TAPE_reset_buffer_flag;	F852
;LF855:	jsr	x_check_for_Escape_and_loop_till_bit_7_of_FS_buffer_flag;	F855
;	jsr	x_check_for_Escape_and_loop_till_bit_7_of_FS_buffer_flag;	F858
;	jsr	ACIA_rst_ctl3				;	F85B
;	lda	#$01				;	F85E
;	jsr	x_generate_delay		;	F860
;	plp					;	F863
;	jsr	x_update_block_flag_PRINT_filenameFDB;	F864
;	bit	$03CA				;	F867
;	bpl	LF874				;	F86A
;	php					;	F86C
;	jsr	x_generate_a_5_second_delay	;	F86D
;	jsr	LF246				;	F870
;	plp					;	F873
;LF874:	rts					;	F874
;; ----------------------------------------------------------------------------
;; transfer byte to CFS and do CRC;  
;x_transfer_byte_to_CFS_and_do_CRC:
;	jsr	x_save_byte_to_buffer_xfer_to_CFS_reset_flag;	F875
;	jmp	x_perform_CRC			;	F878
;; ----------------------------------------------------------------------------
;; save checksum to TAPE reset buffer flag
;x_save_checksum_to_TAPE_reset_buffer_flag:
;	lda	zp_fs_s+15			;	F87B
;	jsr	x_save_byte_to_buffer_xfer_to_CFS_reset_flag;	F87D
;	lda	zp_fs_s+14			;	F880
;; save byte to buffer, transfer to CFS & reset flag
;x_save_byte_to_buffer_xfer_to_CFS_reset_flag:
;	sta	zp_fs_s+13			;	F882
;; check for Escape and loop till bit 7 of FS buffer flag=1
;x_check_for_Escape_and_loop_till_bit_7_of_FS_buffer_flag:
;	jsr	x_confirm_CFS_not_operating_nor_ESCAPE_flag_set;	F884
;	bit	zp_fs_w				;	F887
;	bpl	x_check_for_Escape_and_loop_till_bit_7_of_FS_buffer_flag;	F889
;	lda	#$00				;	F88B
;	sta	zp_fs_w				;	F88D
;	lda	zp_fs_s+13			;	F88F
;	rts					;	F891
;; ----------------------------------------------------------------------------
;; generate a 5 second delay
;x_generate_a_5_second_delay:
;	lda	#$32				;	F892
;	bne	x_generate_delay		;	F894
;; generate delay set by interblock gap
;x_generate_delay_set_by_interblock_gap:
;	lda	zp_fs_w+7			;	F896
;; generate delay
;x_generate_delay:
;	ldx	#$05				;	F898
;LF89A:	sta	sysvar_CFSTOCTR			;	F89A
;LF89D:	jsr	x_confirm_CFS_not_operating_nor_ESCAPE_flag_set;	F89D
;	bit	sysvar_CFSTOCTR			;	F8A0
;	bpl	LF89D				;	F8A3
;	dex					;	F8A5
;	bne	LF89A				;	F8A6
;	rts					;	F8A8
;; ----------------------------------------------------------------------------
;; : generate screen reports
;x_generate_screen_reports:
;	lda	$03C6				;	F8A9
;	ora	$03C7				;	F8AC
;	beq	LF8B6				;	F8AF
;	bit	$03DF				;	F8B1
;	bpl	x_update_block_flag_PRINT_filenameFDB;	F8B4
;LF8B6:	jsr	LF249				;	F8B6
;; update block flag, PRINT filename (&FDBess if reqd)
;x_update_block_flag_PRINT_filenameFDB:
;	ldy	#$00				;	F8B9
;	sty	zp_fs_s+10			;	F8BB
;	lda	$03CA				;	F8BD
;	sta	$03DF				;	F8C0
;	jsr	LE7DC				;	F8C3
;	beq	LF933				;	F8C6
;	lda	#$0D				;	F8C8
;	jsr	OSWRCH				;	F8CA
;LF8CD:	lda	$03B2,y				;	F8CD
;	beq	x_end_of_filename		;	F8D0
;	cmp	#$20				;	F8D2
;	bcc	x_Control_characters_in_RFS_CFS_filename;	F8D4
;	cmp	#$7F				;	F8D6
;	bcc	LF8DC				;	F8D8
;; Control characters in RFS/CFS filename
;x_Control_characters_in_RFS_CFS_filename:
;	lda	#$3F				;	F8DA
;LF8DC:	jsr	OSWRCH				;	F8DC
;	iny					;	F8DF
;	bne	LF8CD				;	F8E0
;; end of filename
;x_end_of_filename:
;	lda	sysvar_CFSRFS_SWITCH		;	F8E2
;	beq	LF8EB				;	F8E5
;	bit	zp_fs_s+11			;	F8E7
;	bvc	LF933				;	F8E9
;LF8EB:	jsr	x_print_a_space			;	F8EB
;	iny					;	F8EE
;	cpy	#$0B				;	F8EF
;	bcc	x_end_of_filename		;	F8F1
;	lda	$03C6				;	F8F3
;	tax					;	F8F6
;	jsr	x_print_ASCII_equivalent_of_hex_byte;	F8F7
;	bit	$03CA				;	F8FA
;	bpl	LF933				;	F8FD
;	txa					;	F8FF
;	clc					;	F900
;	adc	$03C9				;	F901
;	sta	zp_fs_w+13			;	F904
;	jsr	x_print_a_space_ASCII_equivalent_of_hex_byte;	F906
;	lda	$03C8				;	F909
;	sta	zp_fs_w+12			;	F90C
;	jsr	x_print_ASCII_equivalent_of_hex_byte;	F90E
;	bit	zp_fs_s+11			;	F911
;	bvc	LF933				;	F913
;	ldx	#$04				;	F915
;LF917:	jsr	x_print_a_space			;	F917
;	dex					;	F91A
;	bne	LF917				;	F91B
;	ldx	#$0F				;	F91D
;	jsr	x_print_4_bytes_from_CFS_block_header;	F91F
;	jsr	x_print_a_space			;	F922
;	ldx	#$13				;	F925
;; print 4 bytes from CFS block header
;x_print_4_bytes_from_CFS_block_header:
;	ldy	#$04				;	F927
;LF929:	lda	$03B2,x				;	F929
;	jsr	x_print_ASCII_equivalent_of_hex_byte;	F92C
;	dex					;	F92F
;	dey					;	F930
;	bne	LF929				;	F931
;LF933:	rts					;	F933
;; ----------------------------------------------------------------------------
;; print prompt for SAVE on TAPE
;x_print_prompt_for_SAVE_on_TAPE:
;	lda	sysvar_CFSRFS_SWITCH		;	F934
;	beq	LF93C				;	F937
;	jmp	brkBadCommand		;	F939
;; ----------------------------------------------------------------------------
;LF93C:	jsr	LFB8E				;	F93C
;	jsr	x_control_ACIA_and_Motor	;	F93F
;	jsr	LE7DC				;	F942
;	beq	LF933				;	F945
;	jsr	LFA46				;	F947
;	FCB	$52				;	F94A
;	eor	zp_lang+67			;	F94B
;	FCB	$4F				;	F94D
;	FCB	$52				;	F94E
;	FCB	$44				;	F94F
;	jsr	L6874				;	F950
;	adc	zp_lang+110			;	F953
;	jsr	L4552				;	F955
;	FCB	$54				;	F958
;	eor	zp_lang+82,x			;	F959
;	FCB	$4E				;	F95B
;	brk					;	F95C
;LF95D:	jsr	x_confirm_CFS_not_operating_nor_ESCAPE_flag_set;	F95D
;; wait for RETURN key to be pressed
;x_wait_for_RETURN_key_to_be_pressed:
;	jsr	OSRDCH				;	F960
;	cmp	#$0D				;	F963
;	bne	LF95D				;	F965
;	jmp	OSNEWL				;	F967
;; ----------------------------------------------------------------------------
;; increment current loadFDBess
;x_increment_current_loadFDBess:
;	inc	zp_fs_s+1			;	F96A
;	bne	LF974				;	F96C
;	inc	zp_fs_s+2			;	F96E
;	bne	LF974				;	F970
;	inc	zp_fs_s+3			;	F972
;LF974:	rts					;	F974
;; ----------------------------------------------------------------------------
;; print a space + ASCII equivalent of hex byte
;x_print_a_space_ASCII_equivalent_of_hex_byte:
;	pha					;	F975
;	jsr	x_print_a_space			;	F976
;	pla					;	F979
;; print ASCII equivalent of hex byte
;x_print_ASCII_equivalent_of_hex_byte:
;	pha					;	F97A
;	lsr	a				;	F97B
;	lsr	a				;	F97C
;	lsr	a				;	F97D
;	lsr	a				;	F97E
;	jsr	LF983				;	F97F
;	pla					;	F982
;LF983:	clc					;	F983
;	and	#$0F				;	F984
;	adc	#$30				;	F986
;	cmp	#$3A				;	F988
;	bcc	LF98E				;	F98A
;	adc	#$06				;	F98C
;LF98E:	jmp	OSWRCH				;	F98E
;; ----------------------------------------------------------------------------
;; print a space
;x_print_a_space:
;	lda	#$20				;	F991
;	bne	LF98E				;	F993
;; confirm CFS not operating, nor ESCAPE flag set
;x_confirm_CFS_not_operating_nor_ESCAPE_flag_set:
;	php					;	F995
;	bit	zp_mos_cfs_critical		;	F996
;	bmi	LF99E				;	F998
;	bit	zp_mos_ESC_flag			;	F99A
;	bmi	LF9A0				;	F99C
;LF99E:	plp					;	F99E
;	rts					;	F99F
;; ----------------------------------------------------------------------------
;LF9A0:	jsr	LF33B				;	F9A0
;	jsr	LFAF2				;	F9A3
;	lda	#$7E				;	F9A6
;	jsr	OSBYTE				;	F9A8
;	brk					;	F9AB
;	ora	(zp_lang+69),y			;	F9AC
;	FCB	$73				;	F9AE
;	FCB	$63				;	F9AF
;	adc	(zp_lang+112,x)			;	F9B0
;	adc	zp_lang				;	F9B2
;; LOAD
;x_LOAD: tya					;	F9B4
;	beq	LF9C4				;	F9B5
;	jsr	LFA46				;	F9B7
;	ora	$6F4C				;	F9BA
;	adc	(zp_lang+100,x)			;	F9BD
;	adc	#$6E				;	F9BF
;	FCB	$67				;	F9C1
;	FCB	$0D				;	F9C2
;	brk					;	F9C3
;LF9C4:	sta	zp_fs_s+10			;	F9C4
;	ldx	#$FF				;	F9C6
;	lda	zp_fs_w+1			;	F9C8
;	bne	LF9D9				;	F9CA
;	jsr	x_compare_filenames		;	F9CC
;	php					;	F9CF
;	ldx	#$FF				;	F9D0
;	ldy	#$99				;	F9D2
;	lda	#$FA				;	F9D4
;	plp					;	F9D6
;	bne	LF9F5				;	F9D7
;LF9D9:	ldy	#$8E				;	F9D9
;	lda	zp_fs_w+1			;	F9DB
;	beq	LF9E3				;	F9DD
;	lda	#$FA				;	F9DF
;	bne	LF9F5				;	F9E1
;LF9E3:	lda	$03C6				;	F9E3
;	cmp	zp_fs_s+4			;	F9E6
;	bne	LF9F1				;	F9E8
;	lda	$03C7				;	F9EA
;	cmp	zp_fs_s+5			;	F9ED
;	beq	LFA04				;	F9EF
;LF9F1:	ldy	#$A4				;	F9F1
;	lda	#$FA				;	F9F3
;LF9F5:	pha					;	F9F5
;	tya					;	F9F6
;	pha					;	F9F7
;	txa					;	F9F8
;	pha					;	F9F9
;	jsr	LF8B6				;	F9FA
;	pla					;	F9FD
;	tax					;	F9FE
;	pla					;	F9FF
;	tay					;	FA00
;	pla					;	FA01
;	bne	LFA18				;	FA02
;LFA04:	txa					;	FA04
;	pha					;	FA05
;	jsr	x_generate_screen_reports	;	FA06
;	jsr	LFAD6				;	FA09
;	pla					;	FA0C
;	tax					;	FA0D
;	lda	zp_fs_s+14			;	FA0E
;	ora	zp_fs_s+15			;	FA10
;	beq	LFA8D				;	FA12
;	ldy	#$8E				;	FA14
;	lda	#$FA				;	FA16
;LFA18:	dec	zp_fs_s+10			;	FA18
;	pha					;	FA1A
;	bit	zp_mos_cfs_critical		;	FA1B
;	bmi	LFA2C				;	FA1D
;	txa					;	FA1F
;	and	sysvar_CFSRFS_SWITCH		;	FA20
;	bne	LFA2C				;	FA23
;	txa					;	FA25
;	and	#$11				;	FA26
;	and	zp_fs_s+11			;	FA28
;	beq	LFA3C				;	FA2A
;LFA2C:	pla					;	FA2C
;	sta	zp_fs_s+9			;	FA2D
;	sty	zp_fs_s+8			;	FA2F
;	jsr	mos_CLOSE_EXEC_FILE				;	FA31
;	lsr	zp_mos_cfs_critical		;	FA34
;	jsr	x_sound_bell_reset_ACIA_motor_off;	FA36
;	jmp	(zp_fs_s+8)			;	FA39
;; ----------------------------------------------------------------------------
;LFA3C:	pla					;	FA3C
;	iny					;	FA3D
;	bne	LFA43				;	FA3E
;	clc					;	FA40
;	adc	#$01				;	FA41
;LFA43:	pha					;	FA43
;	tya					;	FA44
;	pha					;	FA45
;LFA46:	jsr	LE7DC				;	FA46
;	tay					;	FA49
;; Print 0 terminated string after jsr, return after string
mos_PRTEXT
		puls	X				; get return address back from stack
		jsr	mos_PRSTRING
2		jmp	,X
mos_PRSTRING
1		lda	,X+
		beq	2F
		jsr	OSASCI
		bra	1B
2		rts
;; ----------------------------------------------------------------------------
;; compare filenames
;x_compare_filenames:
;	ldx	#$FF				;	FA72
;LFA74:	inx					;	FA74
;	lda	$03D2,x				;	FA75
;	bne	LFA81				;	FA78
;	txa					;	FA7A
;	beq	LFA80				;	FA7B
;	lda	$03B2,x				;	FA7D
;LFA80:	rts					;	FA80
;; ----------------------------------------------------------------------------
;LFA81:	jsr	mos_CHECK_FOR_ALPHA_CHARACTER	;	FA81
;	eor	$03B2,x				;	FA84
;	bcs	LFA8B				;	FA87
;	and	#$DF				;	FA89
;LFA8B:	beq	LFA74				;	FA8B
;LFA8D:	rts					;	FA8D
;; ----------------------------------------------------------------------------
;	FCB	$00,$D8,$0D			;	FA8E
;	FCB	"Data?"				;	FA91
;	FCB	$00				;	FA96
;; ----------------------------------------------------------------------------
;	bne	LFAAE				;	FA97
;	FCB	$00,$DB,$0D			;	FA99
;	FCB	"File?"				;	FA9C
;	FCB	$00				;	FAA1
;; ----------------------------------------------------------------------------
;	bne	LFAAE				;	FAA2
;	FCB	$00,$DA,$0D			;	FAA4
;	FCB	"Block?"			;	FAA7
;	FCB	$00				;	FAAD
;; ----------------------------------------------------------------------------
;LFAAE:	lda	zp_fs_s+10			;	FAAE
;	beq	LFAD3				;	FAB0
;	txa					;	FAB2
;	beq	LFAD3				;	FAB3
;	lda	#$22				;	FAB5
;	bit	zp_fs_s+11			;	FAB7
;	beq	LFAD3				;	FAB9
;	jsr	ACIA_rst_ctl3				;	FABB
;	tay					;	FABE
;	jsr	mos_PRTEXT			;	FABF
;	FCB	$0D,$07				;	FAC2
;	FCB	"Rewind tape"			;	FAC4
;						;	FACC
;	FCB	$0D,$0D,$00			;	FACF
;; ----------------------------------------------------------------------------
;LFAD2:	rts					;	FAD2
;; ----------------------------------------------------------------------------
;LFAD3:	jsr	LF24D				;	FAD3
;LFAD6:	lda	zp_fs_w+2			;	FAD6
;	beq	LFAD2				;	FAD8
;	jsr	x_confirm_CFS_not_operating_nor_ESCAPE_flag_set;	FADA
;	lda	sysvar_CFSRFS_SWITCH		;	FADD
;	beq	LFAD6				;	FAE0
;	jsr	LF588				;	FAE2
;	jmp	LFAD6				;	FAE5
;; ----------------------------------------------------------------------------
;; sound bell, reset ACIA, motor off
;x_sound_bell_reset_ACIA_motor_off:
;	jsr	LE7DC				;	FAE8
;	beq	LFAF2				;	FAEB
;	lda	#$07				;	FAED
;	jsr	OSWRCH				;	FAEF
;LFAF2:	lda	#$80				;	FAF2
;	jsr	LFBBD				;	FAF4
;	ldx	#$00				;	FAF7
;	jsr	x_control_motor			;	FAF9
;LFAFC:	php					;	FAFC
;	sei					;	FAFD
;	lda	sysvar_SERPROC_CTL_CPY		;	FAFE
;	sta	sheila_SERIAL_ULA				;	FB01
;	lda	#$00				;	FB04
;	sta	zp_mos_rs423timeout		;	FB06
;	beq	LFB0B				;	FB08
	IF MACH_BEEB
ACIA_reset_from_CTL_COPY			; LFB0A
		pshs	CC				;save flags on stacksave flags
LFB0B		jsr	ACIA_rst_ctl3			;release ACIA (by &FE08=3)
		lda	sysvar_RS423_CTL_COPY		;get last setting of ACIA
		jmp	ACIA_set_CTL_and_copy				;set ACIA and &250 from A before exit
	ENDIF
;; ----------------------------------------------------------------------------
;LFB14:	plp					;	FB14
;	bit	zp_mos_ESC_flag			;	FB15
;	bpl	LFB31				;	FB17
;	rts					;	FB19
;; ----------------------------------------------------------------------------
;; Claim serial system for sequential Access
;mos_Claim_serial_system_for_sequential_Access:
;	lda	zp_cfs_w+1			;	FB1A
;	asl	a				;	FB1C
;	asl	a				;	FB1D
;	asl	a				;	FB1E
;	asl	a				;	FB1F
;	sta	zp_fs_s+11			;	FB20
;	lda	$03D1				;	FB22
;	bne	LFB2F				;	FB25
;; claim serial system for cassette etc.
;mos_claim_serial_system_for_cass:
;	lda	zp_cfs_w+1			;	FB27
;	and	#$F0				;	FB29
;	sta	zp_fs_s+11			;	FB2B
;	lda	#$06				;	FB2D
;LFB2F:	sta	zp_fs_w+7			;	FB2F
;LFB31:	cli					;	FB31
;	php					;	FB32
;	sei					;	FB33
;	bit	sysvar_RS423_USEFLAG		;	FB34
;	bpl	LFB14				;	FB37
;	lda	zp_mos_rs423timeout		;	FB39
;	bmi	LFB14				;	FB3B
;	lda	#$01				;	FB3D
;	sta	zp_mos_rs423timeout		;	FB3F
;	jsr	ACIA_rst_ctl3				;	FB41
;	plp					;	FB44
;	rts					;	FB45
;; ----------------------------------------------------------------------------
	IF MACH_BEEB

ACIA_rst_ctl3					; LFB46
		lda	#$03				;	FB46
		bra	ACIA_set_ctl			;	FB48
;; set ACIA control register
;x_set_ACIA_control_register:
;	lda	#$30				;	FB4A
;	sta	zp_fs_w+10			;	FB4C
;	bne	LFB63				;	FB4E
;; control cassette system
;x_control_cassette_system:
;	lda	#$05				;	FB50
;	sta	sheila_SERIAL_ULA				;	FB52
;	ldx	#$FF				;	FB55
;LFB57:	dex					;	FB57
;	bne	LFB57				;	FB58
;	stx	zp_fs_w+10			;	FB5A
;	lda	#$85				;	FB5C
;	sta	sheila_SERIAL_ULA				;	FB5E
;	lda	#$D0				;	FB61
;LFB63:	ora	zp_fs_w+6			;	FB63
ACIA_set_ctl						; LFB65
		sta	sheila_ACIA_CTL			; FB65
		rts					; FB68
	ENDIF
;; ----------------------------------------------------------------------------
;LFB69:	ldx	$03C6				;	FB69
;	ldy	$03C7				;	FB6C
;	inx					;	FB6F
;	stx	zp_fs_s+4			;	FB70
;	bne	LFB75				;	FB72
;	iny					;	FB74
;LFB75:	sty	zp_fs_s+5			;	FB75
;	rts					;	FB77
;; ----------------------------------------------------------------------------
;LFB78:	ldy	#$00				;	FB78
;	sty	zp_fs_w				;	FB7A
;; set (zero) checksum bytes
;x_set_0_checksum_bytes:
;	sty	zp_fs_s+14			;	FB7C
;	sty	zp_fs_s+15			;	FB7E
;	rts					;	FB80
;; ----------------------------------------------------------------------------
;; copy sought filename routine
;x_copy_sought_filename_routine:
;	ldy	#$FF				;	FB81
;LFB83:	iny					;	FB83
;	inx					;	FB84
;	lda	vduvar_GRA_WINDOW_LEFT,x	;	FB85
;	sta	$03D2,y				;	FB88
;	bne	LFB83				;	FB8B
;	rts					;	FB8D
;; ----------------------------------------------------------------------------
;LFB8E:	ldy	#$00				;	FB8E
;; switch Motor on
;x_switch_Motor_on:
;	cli					;	FB90
;	ldx	#$01				;	FB91
;	sty	zp_fs_w+3			;	FB93
;; : control motor
;x_control_motor:
;	lda	#$89				;	FB95
;	ldy	zp_fs_w+3			;	FB97
;	jmp	OSBYTE				;	FB99
;; ----------------------------------------------------------------------------
;; confirm file is open
;x_confirm_file_is_open:
;	sta	zp_fs_s+12			;	FB9C
;	tya					;	FB9E
;	eor	sysvar_CFSRFS_SWITCH		;	FB9F
;	tay					;	FBA2
;	lda	zp_cfs_w			;	FBA3
;	and	zp_fs_s+12			;	FBA5
;	lsr	a				;	FBA7
;	dey					;	FBA8
;	beq	LFBAF				;	FBA9
;	lsr	a				;	FBAB
;	dey					;	FBAC
;	bne	LFBB1				;	FBAD
;LFBAF:	bcs	LFBFE				;	FBAF
;LFBB1:	brk					;	FBB1
;	FCB	$DE				;	FBB2
;	FCB	"Channel"			;	FBB3
;	FCB	$00				;	FBBA
;; ----------------------------------------------------------------------------
;; read from second processor
;x_read_from_second_processor:
;	lda	#$01				;	FBBB
;LFBBD:	jsr	x_check_if_second_processor_file_test_tube_prescence;	FBBD
;	beq	LFBFE				;	FBC0
;	txa					;	FBC2
;	ldx	#$B0				;	FBC3
;	ldy	#$00				;	FBC5
;LFBC7:	pha					;	FBC7
;	lda	#$C0				;	FBC8
;LFBCA:	jsr	L0406				;	FBCA
;	bcc	LFBCA				;	FBCD
;	pla					;	FBCF
;	jmp	L0406				;	FBD0
;; ----------------------------------------------------------------------------
;; check if second processor file test tube prescence
;x_check_if_second_processor_file_test_tube_prescence:
;	tax					;	FBD3
;	lda	zp_fs_s+2			;	FBD4
;	and	zp_fs_s+3			;	FBD6
;	cmp	#$FF				;	FBD8
;	beq	LFBE1				;	FBDA
;	lda	sysvar_TUBE_PRESENT		;	FBDC
;	and	#$80				;	FBDF
;LFBE1:	rts					;	FBE1
;; ----------------------------------------------------------------------------
;; control ACIA and Motor
;x_control_ACIA_and_Motor:
;	lda	#$85				;	FBE2
;	sta	sheila_SERIAL_ULA				;	FBE4
;	jsr	ACIA_rst_ctl3				;	FBE7
;	lda	#$10				;	FBEA
;	jsr	LFB63				;	FBEC
;LFBEF:	jsr	x_confirm_CFS_not_operating_nor_ESCAPE_flag_set;	FBEF
;	lda	sheila_ACIA_CTL				;	FBF2
;	and	#$02				;	FBF5
;	beq	LFBEF				;	FBF7
;	lda	#$AA				;	FBF9
;	sta	LFE09				;	FBFB
;LFBFE:	rts					;	FBFE
;; ----------------------------------------------------------------------------
;	brk					;	FBFF

jgh_SCANHEX
		TODO "jgh_SCANHEX"
jgh_OSQUIT
		TODO "jgh_OSQUIT"
jgh_PR2HEX	tfr	X,D
		jsr	PRHEX
		tfr	B,A
jgh_PRHEX
		PSHS	A
		lsra
		lsra
		lsra
		lsra
		jsr	PRHEXDIG
		puls	A
PRHEXDIG	jsr	mos_convhex_nyb
		jmp	OSASCI
mos_convhex_nyb	anda	#$0F
		adda	#'0'
		cmpa	#'9'
		bls	1F
		adda	#'A'-'9'-1
1		rts
mos_hexstr_Y	sta	,-S
		lsra
		lsra
		lsra
		lsra
		jsr	mos_convhex_nyb
		sta	,Y+
		lda	,S
		jsr	mos_convhex_nyb
		sta	,Y+
		puls	A,PC
jgh_USERINT	rti
jgh_ERRJMP	ldx	,S++
		CLI
		jmp	[BRKV]
jgh_CLICOM	TODO "jgh_CLICOM"
jgh_OSINIT	tsta
		bne	OSINIT_read
		clra
		tfr	A,DP			; set DP=0
OSINIT_read	ldx	#BRKV
		ldy	#zp_mos_ESC_flag
		clra				; indicate BE OS calls
		rts
dummy_vector_RTI
		rti
mos_txa
		m_txa
		rts

; ----------------------------------------------------------------------------
; OSBYTE &94	  READ A BYTE FROM JIM;	 
mos_OSBYTE_148
	lda	$FD00,x				;	FFAE
	bra	1B				;	FFB1
; ----------------------------------------------------------------------------
; OSBYTE &96	  READ A BYTE FROM SHEILA;  
mos_OSBYTE_150
	lda	$FE00,X
	bra	1B

* Bounce table to cope with fact that indirect jump is 4 bytes on 6809
OSFIND_bounce	jmp	[FINDV]
OSGBPB_bounce	jmp	[GBPBV]
OSBPUT_bounce	jmp	[BPUTV]
OSBGET_bounce	jmp	[BGETV]
OSARGS_bounce	jmp	[ARGSV]
OSFILE_bounce	jmp	[FILEV]
OSRDCH_bounce	jmp	[RDCHV]
OSWRCH_bounce	jmp	[WRCHV]
OSWORD_bounce	jmp	[WORDV]
OSBYTE_bounce	jmp	[BYTEV]
OSCLI_bounce	jmp	[CLIV]


FILL5
FILL5LEN	EQU	HARDWARELOC-FILL5
		FILL	$FF,FILL5LEN
		ORG	HARDWARELOC
		FILL	$FF,HARDWARELOC_END-HARDWARELOC+1

;LFC00	FCB	"(C) 1981 Ac0rn Computers Ltd.Th";	FC00
;						;	FC08
;						;	FC10
;						;	FC18
;	FCB	"anks are due to the following c";	FC1F
;						;	FC27
;						;	FC2F
;						;	FC37
;	FCB	"ontributors to the development ";	FC3E
;						;	FC46
;						;	FC4E
;						;	FC56
;	FCB	"of the BBC Computer (among othe";	FC5D
;						;	FC65
;						;	FC6D
;						;	FC75
;	FCB	"rs too numerous to mention):- D";	FC7C
;						;	FC84
;						;	FC8C
;						;	FC94
;	FCB	"avid Allen,Bob Austin,Ram Baner";	FC9B
;						;	FCA3
;						;	FCAB
;						;	FCB3
;	FCB	"jee,Paul Bond,Allen Boothroyd,C";	FCBA
;						;	FCC2
;						;	FCCA
;						;	FCD2
;	FCB	"ambridge,Cleartone,John Coll,Jo";	FCD9
;						;	FCE1
;						;	FCE9
;						;	FCF1
;	FCB	"hn Cox,A"			;	FCF8
;LFD00:	FCB	"ndy Cripps,Chris Curry,6502 des";	FD00
;						;	FD08
;						;	FD10
;						;	FD18
;	FCB	"igners,Jeremy Dion,Tim Dobson,J";	FD1F
;						;	FD27
;						;	FD2F
;						;	FD37
;	FCB	"oe Dunn,Paul Farrell,Ferranti,S";	FD3E
;						;	FD46
;						;	FD4E
;						;	FD56
;	FCB	"teve Furber,Jon Gibbons,Andrew ";	FD5D
;						;	FD65
;						;	FD6D
;						;	FD75
;	FCB	"Gordon,Lawrence Hardwick,Dylan ";	FD7C
;						;	FD84
;						;	FD8C
;						;	FD94
;	FCB	"Harris,Hermann Hauser,Hitachi,A";	FD9B
;						;	FDA3
;						;	FDAB
;						;	FDB3
;	FCB	"ndy Hopper,ICL,Martin Jackson,B";	FDBA
;						;	FDC2
;						;	FDCA
;						;	FDD2
;	FCB	"rian Jones,Chris Jordan,David K";	FDD9
;						;	FDE1
;						;	FDE9
;						;	FDF1
;	FCB	"ing,Da"			;	FDF8
;LFDFE:	FCB	"vi"				;	FDFE
;sheila_CRTC_reg:
;	FCB	"d"				;	FE00
;sheila_CRTC_rw:
;	FCB	" Kitson"			;	FE01
;sheila_ACIA_CTL:	FCB	","				;	FE08
;LFE09:	FCB	"Paul Kr"			;	FE09
;sheila_SERIAL_ULA:	FCB	"iwaczek,Computer"		;	FE10
;						;	FE18
;sheila_VIDULA_ctl:
;	FCB	" "				;	FE20
;sheila_VIDULA_pal:
;	FCB	"Laboratory,Pete"		;	FE21
;						;	FE29
;sheila_ROMCTL_SWR:	FCB	"r Miller,Arthur "		;	FE30
;						;	FE38
;sheila_SYSVIA_orb:
;	FCB	"N"				;	FE40
;sheila_SYSVIA_ora:
;	FCB	"o"				;	FE41
;sheila_SYSVIA_ddrb:
;	FCB	"r"				;	FE42
;sheila_SYSVIA_ddra:
;	FCB	"m"				;	FE43
;sheila_SYSVIA_t1cl:
;	FCB	"a"				;	FE44
;sheila_SYSVIA_t1ch:
;	FCB	"n"				;	FE45
;sheila_SYSVIA_t1ll:
;	FCB	","				;	FE46
;sheila_SYSVIA_t1lh:
;	FCB	"G"				;	FE47
;sheila_SYSVIA_t2cl:
;	FCB	"l"				;	FE48
;sheila_SYSVIA_t2ch:
;	FCB	"y"				;	FE49
;sheila_SYSVIA_sr:
;	FCB	"n"				;	FE4A
;sheila_SYSVIA_acr:
;	FCB	" "				;	FE4B
;sheila_SYSVIA_pcr:
;	FCB	"P"				;	FE4C
;sheila_SYSVIA_ifr:
;	FCB	"h"				;	FE4D
;sheila_SYSVIA_ier:
;	FCB	"i"				;	FE4E
;sheila_SYSVIA_ora_nh:
;	FCB	"llips,Mike Prees,"		;	FE4F
;						;	FE57
;						;	FE5F
;sheila_USRVIA_orb:
;	FCB	"J"				;	FE60
;sheila_USRVIA_ora:
;	FCB	"o"				;	FE61
;sheila_USRVIA_ddrb:
;	FCB	"h"				;	FE62
;sheila_USRVIA_ddra:
;	FCB	"n"				;	FE63
;sheila_USRVIA_t1cl:
;	FCB	" "				;	FE64
;sheila_USRVIA_t1ch:
;	FCB	"R"				;	FE65
;sheila_USRVIA_t1ll:
;	FCB	"a"				;	FE66
;sheila_USRVIA_t1lh:
;	FCB	"d"				;	FE67
;sheila_USRVIA_t2cl:
;	FCB	"c"				;	FE68
;sheila_USRVIA_t2ch:
;	FCB	"l"				;	FE69
;sheila_USRVIA_sr:
;	FCB	"i"				;	FE6A
;sheila_USRVIA_acr:
;	FCB	"f"				;	FE6B
;sheila_USRVIA_pcr:
;	FCB	"f"				;	FE6C
;sheila_USRVIA_ifr:
;	FCB	"e"				;	FE6D
;sheila_USRVIA_ier:
;	FCB	","				;	FE6E
;sheila_USRVIA_ora_nh:
;	FCB	"Wilberforce Road,Peter Robinson";	FE6F
;						;	FE77
;						;	FE7F
;						;	FE87
;	FCB	",Richard Russell,Kim Spence-Jon";	FE8E
;						;	FE96
;						;	FE9E
;						;	FEA6
;	FCB	"es,Graham Tebby,Jon"		;	FEAD
;						;	FEB5
;						;	FEBD
;LFEC0:	FCB	" "				;	FEC0
;LFEC1:	FCB	"T"				;	FEC1
;LFEC2:	FCB	"hackray,Chris Turner,Adrian Wa";	FEC2
;						;	FECA
;						;	FED2
;						;	FEDA
;LFEE0:	FCB	"rner,"				;	FEE0
;LFEE5:	FCB	"Roger Wilson,Alan Wright."	;	FEE5
;						;	FEED
;						;	FEF5
;						;	FEFD
;	FCB	$CD,$D9				;	FEFE
		ORG	$FF00
;; ----------------------------------------------------------------------------
;; EXTENDED VECTOR ENTRY POINTS; vectors are pointed to &F000 +vector No. vectors may then be directed thru  
; a three byte vector table whose address is given by osbyte A8, X=0, Y=&FF 
; this is set up as lo-hi byte in ROM and ROM number	 
;x_EXTENDED_VECTOR_ENTRY_POINTS
		jsr	x_enter_extended_vector			;Extended USERV
		jsr	x_enter_extended_vector			;Extended BRKV
		jsr	x_enter_extended_vector			;Extended IRQ1V
		jsr	x_enter_extended_vector			;Extended IRQ2V
		jsr	x_enter_extended_vector			;Extended CLIV
		jsr	x_enter_extended_vector			;Extended BYTEV
		jsr	x_enter_extended_vector			;Extended WORDV
		jsr	x_enter_extended_vector			;Extended WRCHV
		jsr	x_enter_extended_vector			;Extended RDCHV
		jsr	x_enter_extended_vector			;Extended FILEV
		jsr	x_enter_extended_vector			;Extended ARGSV
		jsr	x_enter_extended_vector			;Extended BGETV
		jsr	x_enter_extended_vector			;Extended BPUTV
		jsr	x_enter_extended_vector			;Extended GBPBV
		jsr	x_enter_extended_vector			;Extended FINDV
		jsr	x_enter_extended_vector			;Extended FSCV
		jsr	x_enter_extended_vector			;Extended EVENTV
		jsr	x_enter_extended_vector			;Extended UPTV
		jsr	x_enter_extended_vector			;Extended NETV
		jsr	x_enter_extended_vector			;Extended VDUV
		jsr	x_enter_extended_vector			;Extended KEYV
		jsr	x_enter_extended_vector			;Extended INSV
		jsr	x_enter_extended_vector			;Extended REMV
		jsr	x_enter_extended_vector			;Extended CNPV
		jsr	x_enter_extended_vector			;Extended IND1V
		jsr	x_enter_extended_vector			;Extended IND2V
		jsr	x_enter_extended_vector			;Extended IND3V
x_enter_extended_vector	
		;at this point the stack will hold 4 bytes (at least)
		;S 0,1 extended vector address
		;S 2,3 address of calling routine
		;A,X,Y,P will be as at entry

		leas	-5,S				; reserve 7 bytes on the stack
		pshs	CC,B,X				; save 

		; stack now has
		;	12	Caller addr (lo)
		;	11	Caller addr (hi)
		;	10	Extended vector addr (lo)
		;	9	Extended vector addr (hi)
		;	8	?
		;	7	?
		;	6	?
		;	5	?
		;	4	?
		;	3	X (lo)
		;	2	X (hi)
		;	1	B
		;	0	CC

		ldx	#x_return_addess_from_ROM_indirection
		stx	6,S

		; stack now has
		;	12	Caller addr (lo)
		;	11	Caller addr (hi)
		;	10	Extended vector addr (lo)
		;	9	Extended vector addr (hi)
		;	8	?
		;	7	x_return_addess_from_ROM_indirection (lo)
		;	6	x_return_addess_from_ROM_indirection (hi)
		;	5	?
		;	4	?
		;	3	X (lo)
		;	2	X (hi)
		;	1	B
		;	0	CC

		ldb	zp_mos_curROM
		stb	8,S				; store current ROM on stack

		ldb	10,S				; get low byte of ext vector addr + 3
		ldx	#EXT_USERV - 3
		abx					; X now points at extended vector
		ldb	2,X				; get new rom #
		ldx	,X				; get routine address

		stx	4,S				; store as return address from this routine on stack

		; stack now has
		;	12	Caller addr (lo)
		;	11	Caller addr (hi)
		;	10	Extended vector addr (lo)
		;	9	Extended vector addr (hi)
		;	8	cur SWR#
		;	7	x_return_addess_from_ROM_indirection (lo)
		;	6	x_return_addess_from_ROM_indirection (hi)
		;	5	rom vector handler (lo)
		;	4	rom vector handler (hi)
		;	3	X (lo)
		;	2	X (hi)
		;	1	B
		;	0	CC


		jsr	mos_select_SWROM_B

		puls	CC,B,X,PC			; jump to ROM routine

		; routine is entered with:
		;	6	Caller addr (lo)
		;	5	Caller addr (hi)
		;	4	Extended vector addr (lo)
		;	3	Extended vector addr (hi)
		;	2	cur SWR#
		;	1	x_return_addess_from_ROM_indirection (lo)
		;	0	x_return_addess_from_ROM_indirection (hi)
		; NOTE: the debugger uses this stack signature and switches ROMS back itsel
		; so if any changes are made here they must be reflected in the ROM		


;; ----------------------------------------------------------------------------
;; returnFDBess from ROM indirection; at this point stack comprises original ROM number,return from JSR &FF51, ; return from original call the return from FF51 is garbage so; 
x_return_addess_from_ROM_indirection

		; stack now has
		;	4	Caller addr (lo)
		;	3	Caller addr (hi)
		;	2	Extended vector addr (lo)
		;	1	Extended vector addr (hi)
		;	0	cur SWR#

		pshs	CC,B


		; stack now has
		;	6	Caller addr (lo)
		;	5	Caller addr (hi)
		;	4	Extended vector addr (lo)
		;	3	Extended vector addr (hi)
		;	2	cur SWR#
		;	1	B
		;	0	CC

		ldb	2,S				; get back saved SWR #
		jsr	mos_select_SWROM_B
		puls	B,CC				; restore flags and B
		leas	3,S				; skip unwanted

;; TODO: Make this RTI or RTS depending on vector?

dummy_vector_RTS				; LFFA6
		rts					;	FFA6
; ----------------------------------------------------------------------------
; OSBYTE &9D	FAST BPUT
mos_OSBYTE_157
	jsr	mos_txa
	jmp	OSBPUT					;	FFA8
; OSBYTE &92	  READ A BYTE FROM FRED
mos_OSBYTE_146
	lda	$FC00,x					;	FFAA
1	jmp	LE71F_tay_c_rts				;	FFAD


FILL3
FILL3LEN	EQU	DOM_DEBUG_ENTRIES - FILL3
		FILL	$FF, FILL3LEN
		ORG	DOM_DEBUG_ENTRIES
_DEBUGPRINTNEWL	jmp	debug_print_newl		; FF8C
_DEBUGPRINTHEX	jmp	debug_print_hex			; FF8F
_DEBUGPRINTA	jmp	debug_print_ch			; FF92
_DEBUGPRINTX	jmp	debug_printX			; FF95


		ORG	JGH_OSENTRIESLOC
_OSRDRM		jmp	mos_OSRDRM			; FF98	!!! not same as Beeb
_PRSTRING	jmp	mos_PRSTRING			; FF9B
_OSEVEN		jmp	x_CAUSE_AN_EVENT		; FF9E	!!! not same as Beeb
_SCANHEX	jmp	jgh_SCANHEX			; FFA1
_RAWVDU		jmp	mos_VDU_WRCH			; FFA3	!!! not same as Beeb
_OSQUIT		jmp	jgh_OSQUIT			; FFA7
_PRHEX		jmp	jgh_PRHEX			; FFAA
_PR2HEX		jmp	jgh_PR2HEX			; FFAD
_USERINT	jmp	jgh_USERINT			; FFB0
_PRTEXT		jmp	mos_PRTEXT			; FFB3

		ORG	OSENTRIESLOC
VETAB_len
		FCB	vec_table_end-vec_table				;	FFB6
VETAB_addr
		FDB	vec_table			;	FFB7
;; ----------------------------------------------------------------------------
_CLICOM		jmp	jgh_CLICOM			;	FFB9
_ERRJMP		jmp	jgh_ERRJMP			;	FFBC
_OSINIT		jmp	jgh_OSINIT			;	FFBF
_GSINIT		jmp	mos_GSINIT			;	FFC2
_GSREAD		jmp	mos_GSREAD			;	FFC5
_OSRDCH_NV	jmp	mos_RDCHV_default_entry		;	FFC8
_OSWRCH_NV	jmp	mos_WRCH_default_entry		;	FFCB
_OSFIND		jmp	OSFIND_bounce			;	FFCE
_OSGBPB		jmp	OSGBPB_bounce			;	FFD1
_OSBPUT		jmp	OSBPUT_bounce			;	FFD4
_OSBGET		jmp	OSBGET_bounce			;	FFD7
_OSARGS		jmp	OSARGS_bounce			;	FFDA
_OSFILE		jmp	OSFILE_bounce			;	FFDD
_OSRDCH		jmp	OSRDCH_bounce			;	FFE0
_OSASCI		cmpa	#$0D				;	FFE3
		bne	OSWRCH				;	FFE5
_OSNEWL		lda	#$0A				;	FFE7
		jsr	OSWRCH_bounce			;	FFE9
		lda	#$0D				;	FFEC
_OSWRCH		jmp	OSWRCH_bounce			;	FFEE
_OSWORD		jmp	OSWORD_bounce			;	FFF1
_OSBYTE		jmp	OSBYTE_bounce			;	FFF4
_OSCLI		jmp	OSCLI_bounce			;	FFF7
_OSROMSEL	jmp	mos_select_SWROM_B		;       FFFA		; NEW: select rom in B, return old in B
		jmp	dummy_vector_RTS		;	FFFD

		SECTION	"tables_and_strings"
MOSSTRINGSEND
MOSSTRINGSLEN	EQU	MOSSTRINGSEND-MOSSTRINGS
MOSSTRINGSFREE	EQU	REMAPPED_HW_VECTORS - MOSSTRINGSEND
		FILL	$FF, MOSSTRINGSFREE
FREE		EQU FILL5LEN + FILL2LEN + FILL3LEN + MOSSTRINGSFREE