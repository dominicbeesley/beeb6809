; beeb6809 hardware locations and constants

rti_opcode		EQU	$3B


* mos ROM memory map location
SHEILA_ROMCTL_MOS	EQU	$FE31
SHEILA_ROMCTL_SWR	EQU	$FE30
SHEILA_ROMCTL_RAM	EQU	$FE32
SHEILA_MEMC_SCROFF	EQU	$FE33


* HARDWARELOC - area of RAM used for memory mapped hardware
HARDWARELOC				EQU $FC00
HARDWARELOC_END				EQU $FEFF

* Where the remapped 6809 vectors live, the hardware remaps
* the 6809 hardware vectors to avoid the OS calls in the original 6502 memory map
REMAPPED_HW_VECTORS			EQU $F7F0
OFF_SWI_VEC	EQU	$A
OFF_NMI_VEC	EQU	$C
OFF_RES_VEC	EQU	$E
HW_VECTOR_COUNT	EQU	8

***********************************************************************
* CRTC                                                                *
***********************************************************************
sheila_CRTC_reg				EQU $FE00
sheila_CRTC_rw				EQU $FE01


CRTCR0_HorizontalTotal        		EQU  	 0	; 8b WO m0-3:127 m4-7:63
CRTCR1_HorizontalDisplayed    		EQU	 1	; 8b WO m0-3:80  m4-7:40
CRTCR2_HorizontalSyncPosition 		EQU	 2	; 8b WO m0-3:98  m4-6:49 m7:51
CRTCR3_SyncPulseWidths        		EQU	 3	; Horizontal sync pulse width b0-3 WO m0-3:8 m4-7:4, Vertical sync pulse width b4-7 WO Always 2
CRTCR4_VerticalTotal          		EQU	 4	; 7b WO m0-2,4-5:38 m3,6-7:30
CRTCR5_VerticalTotalAdjust    		EQU	 5	; 5b WO m0-7:0
CRTCR6_VerticalDisplayed      		EQU	 6	; 7b WO m0-2,4-5:32 m3,6-7:25
CRTCR7_VerticalSyncPosition   		EQU	 7	; 7b WO m0-2,4-5:34 m3,6-7:27
CRTCR8_InterlaceAndControl    		EQU	 8	; Interlace modes        b0-1 00,10 non-interlaced, m0-6 01 Interlace sync, m7 11 Interlace sync and video
CRTCR9_CharacterScanLines     		EQU	 9	; 5b WO m0-2,4-5:7 m3,6:9 m7:18
CRTCR10_CursorControlStart    		EQU	10	; 7b WO b7 unused b6 blink enable b5 blink fast b0-4 crsr start line
CRTCR11_CursorEnd             		EQU	11	; 5b WO crsr end line
CRTCR12_Screen1stCharHi       		EQU	12	; 6b WO hi byte of (start of screen address)/8
CRTCR13_Screen1stCharLo       		EQU	13	; 8b WO lo byte of (start of screen address)/8

***********************************************************************
* Simple Video ULA                                                    *
***********************************************************************
sheila_VIDULA_ctl			EQU $FE20
sheila_VIDULA_pal			EQU $FE21
sheila_VIDULA_pixand			EQU $FE22
sheila_VIDULA_pixeor			EQU $FE23
sheila_VIDULA_ttx			EQU $FE24

sheila_RAMDAC_ADDR_WR			EQU $FE28
sheila_RAMDAC_VAL			EQU $FE29
sheila_RAMDAC_PIXMASK			EQU $FE2A
sheila_RAMDAC_ADDR_RD			EQU $FE2B

***********************************************************************
* VIA constants                                                       *
***********************************************************************

VIA_MASK_INT_CA2			EQU	$01
VIA_MASK_INT_CA1			EQU	$02
VIA_MASK_INT_SR				EQU	$04
VIA_MASK_INT_CB2			EQU	$08
VIA_MASK_INT_CB1			EQU	$10
VIA_MASK_INT_T2				EQU	$20
VIA_MASK_INT_T1				EQU	$40
VIA_MASK_INT_IRQ			EQU	$80

SYSVIA_MASK_INT_VSYNC			EQU	VIA_MASK_INT_CA1

***********************************************************************
* System VIA                                                          *
***********************************************************************
sheila_SYSVIA_orb			EQU $FE40
sheila_SYSVIA_ora			EQU $FE41
sheila_SYSVIA_ddrb			EQU $FE42
sheila_SYSVIA_ddra			EQU $FE43
sheila_SYSVIA_t1cl			EQU $FE44
sheila_SYSVIA_t1ch			EQU $FE45
sheila_SYSVIA_t1ll			EQU $FE46
sheila_SYSVIA_t1lh			EQU $FE47
sheila_SYSVIA_t2cl			EQU $FE48
sheila_SYSVIA_t2ch			EQU $FE49
sheila_SYSVIA_sr			EQU $FE4A
sheila_SYSVIA_acr			EQU $FE4B
sheila_SYSVIA_pcr			EQU $FE4C
sheila_SYSVIA_ifr			EQU $FE4D
sheila_SYSVIA_ier			EQU $FE4E
sheila_SYSVIA_ora_nh			EQU $FE4F

***********************************************************************
* User VIA                                                            *
***********************************************************************
sheila_USRVIA_orb			EQU $FE60
sheila_USRVIA_ora			EQU $FE61
sheila_USRVIA_ddrb			EQU $FE62
sheila_USRVIA_ddra			EQU $FE63
sheila_USRVIA_t1cl			EQU $FE64
sheila_USRVIA_t1ch			EQU $FE65
sheila_USRVIA_t1ll			EQU $FE66
sheila_USRVIA_t1lh			EQU $FE67
sheila_USRVIA_t2cl			EQU $FE68
sheila_USRVIA_t2ch			EQU $FE69
sheila_USRVIA_sr			EQU $FE6A
sheila_USRVIA_acr			EQU $FE6B
sheila_USRVIA_pcr			EQU $FE6C
sheila_USRVIA_ifr			EQU $FE6D
sheila_USRVIA_ier			EQU $FE6E
sheila_USRVIA_ora_nh			EQU $FE6F



*============================================================================
*  Equates for memory mapped 16450 serial port 
*============================================================================

S16550			equ	$FE78			; base of 16450 UART
S16550_RXR		equ	S16550+0		; Receiver buffer register
S16550_TXR		equ	S16550+0		; Transmitter buffer register
S16550_IER		equ	S16550+1		; Interrupt enable register
S16550_FCR		equ	S16550+2		; 16550 FIFO control register
S16550_LCR		equ	S16550+3		; Line control register
S16550_MCR		equ	S16550+4		; Modem control register
S16550_DTR		equ	S16550+1		; Bit equate used to control status LED
S16550_LSR		equ	S16550+5		; Line status register

SER_BIT_RXRDY		EQU	$01            ; BIT MASK FOR RX BUFFER FULL
SER_BIT_TXRDY		EQU	$20            ; BIT MASK FOR TX BUFFER EMPTY

SER_BAUD_CLOCK_IN	EQU	7372800			; frequency of on board serial crystal
