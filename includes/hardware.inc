; beeb6809 hardware locations and constants

rti_opcode		EQU	$3B

JIM			EQU	$FD00

* mos ROM memory map location
sheila_ROMCTL_SWR	EQU	$FE30
sheila_ROMCTL_MOS	EQU	$FE31
sheila_MEM_DEBUG_SAVE	EQU	$FE32


ROMCTL_BITS_FLEX	EQU	$10

	IF MACH_BEEB
;TODO: naming - harmonize with 6502
sheila_MEM_CTL			EQU $FE31

BITS_MEM_CTL_SWMOS		EQU $01
BITS_MEM_CTL_SWMOS_DEBUG	EQU $04
BITS_MEM_CTL_SWMOS_DEBUG_EN	EQU $08
BITS_MEM_CTL_FLEX		EQU $10
BITS_MEM_CTL_SWMOS_DEBUG_5C	EQU $40
BITS_MEM_CTL_SWMOS_DEBUG_ACT	EQU $80


sheila_MEM_TURBO2		EQU $FE36
BITS_MEM_TURBO2_THROTTLE	EQU $80

sheila_MEM_LOMEMTURBO		EQU $FE37


fred_JIM_DEVNO		EQU	$FCFF
fred_JIM_PAGE_HI	EQU	$FCFD
fred_JIM_PAGE_LO	EQU	$FCFE
	
sheila_NULA_CTLAUX	EQU	$FE22
sheila_NULA_PALAUX	EQU	$FE23

sheila_DEBUG		EQU	$FEFF




sheila_BLTCFG0		EQU	$FE3E
sheila_BLTCFG1		EQU	$FE3F
BLTCFG0_T65		EQU	$01
BLTCFG0_CPU_6502A_2M	EQU	$00
BLTCFG0_CPU_65C02_4M	EQU	$02
BLTCFG0_CPU_65C02_8M	EQU	$04
BLTCFG0_CPU_6x09_2M	EQU	$08
BLTCFG0_CPU_6309_4M	EQU	$0A
BLTCFG0_CPU_Z80_8M	EQU	$0C
BLTCFG0_CPU_68008	EQU	$0E
BLTCFG0_SWROMX		EQU	$10
BLTCFG0_BUGBTN		EQU	$80

BLTCFG1_MEMI		EQU	$01
BLTCFG1_BUGOUT		EQU	$02


	ENDIF

	IF MACH_CHIPKIT
sheila_ROMCTL_RAM	EQU	$FE32
sheila_MEMC_SCROFF	EQU	$FE33
	ENDIF



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
	IF MACH_CHIPKIT
sheila_VIDULA_pixand			EQU $FE22
sheila_VIDULA_pixeor			EQU $FE23
sheila_VIDULA_ttx			EQU $FE24

sheila_RAMDAC_ADDR_WR			EQU $FE28
sheila_RAMDAC_VAL			EQU $FE29
sheila_RAMDAC_PIXMASK			EQU $FE2A
sheila_RAMDAC_ADDR_RD			EQU $FE2B
	ENDIF

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
* SYS VIA - slow data bus RTC                                         *
***********************************************************************

	IF MACH_CHIPKIT
BITS_RTC_AS_ON	equ		$88			; PB7
BITS_RTC_AS_OFF equ		$08			;
BITS_RTC_CS	equ		$04			; latch
BITS_RTC_DS	equ		$02			; latch
BITS_RTC_RnW	equ		$01			; latch
BITS_LAT_ON	equ		$08			; latch

RTC_REG_SECONDS	equ		$0
RTC_REG_MINUTES	equ		$2
RTC_REG_HOURS	equ		$4
RTC_REG_DOW	equ		$6
RTC_REG_DAY	equ		$7
RTC_REG_MONTH	equ		$8
RTC_REG_YEAR	equ		$9
	ENDIF


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


***********************************************************************
*  VIA constants                                                      *
***********************************************************************

VIA_IFR_BIT_ANY				EQU $80
VIA_IFR_BIT_T1				EQU $40
VIA_IFR_BIT_T2				EQU $20
VIA_IFR_BIT_CB1				EQU $10
VIA_IFR_BIT_CB2				EQU $08
VIA_IFR_BIT_SR				EQU $04
VIA_IFR_BIT_CA1				EQU $02
VIA_IFR_BIT_CA2				EQU $01


***********************************************************************
* BBC B/B+ WD177x                                                     *
***********************************************************************

sheila_1770_dcontrol	equ	$FE80
sheila_1770_wdc_cmd	equ	$FE84
sheila_1770_wdc_trk	equ	$FE85
sheila_1770_wdc_sec	equ	$FE86
sheila_1770_wdc_dat	equ	$FE87

***********************************************************************
* TUBE                                                                *
***********************************************************************

sheila_TUBE_R1_STATUS			EQU $FEE0
sheila_TUBE_R1_DATA			EQU $FEE1
sheila_TUBE_R2_STATUS			EQU $FEE2
sheila_TUBE_R2_DATA			EQU $FEE3
sheila_TUBE_R3_STATUS			EQU $FEE4
sheila_TUBE_R3_DATA			EQU $FEE5
sheila_TUBE_R4_STATUS			EQU $FEE6
sheila_TUBE_R4_DATA			EQU $FEE7


	IF MACH_CHIPKIT
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


sheila_VINC_data	EQU	$FE50
sheila_VINC_status	EQU	$FE52
VINC_status_TXE		EQU	$01
VINC_status_RXF		EQU	$02
	ENDIF

	IF MACH_BEEB

* note: this are for Retroclinic DC
sheila_VINC_data	EQU	$FCF8
sheila_VINC_status	EQU	$FCF9
VINC_status_TXE		EQU	$40
VINC_status_RXF		EQU	$80

sheila_ACIA_CTL		EQU	$FE08
sheila_ACIA_DATA	EQU	$FE09
sheila_SERIAL_ULA	EQU	$FE10
ACIA_RDRF		EQU	$01
ACIA_TDRE		EQU	$02


; BLTCON is written in two passes with top bit clear i.e. not BLTCON_ACT_ACT
; the exec flags are first set
; then with top bit set the active flag, bit mode and cell flags are set
; BLTCON/ACT byte flags

BLITCON_ACT_ACT			EQU	$80		; always set when setting act constants/execing
BLITCON_ACT_CELL		EQU	$40		; cell addressing used i.e. move one byte left adds 8 to address
							; moving one line down either adds 1 byte or STRIDE depending on whether 
							; line crosses an 8 line boundary
BLITCON_ACT_MODE_1BBP		EQU	$00		; 1 bit per pixel mapping 2 colours
BLITCON_ACT_MODE_2BBP		EQU	$10		; 2 bit per pixel mapping 4 colours
BLITCON_ACT_MODE_4BBP		EQU	$20		; 4 bit per pixel mapping 16 colours
BLITCON_ACT_MODE_8BBP		EQU	$30		; 8 bit per pixel mapping 256 colours
BLITCON_ACT_LINE		EQU	$08		; draw a line
BLITCON_ACT_COLLISION		EQU	$04		; gets reset for any non-zero D data (even in EXEC_D is clear) 


BLITCON_LINE_MAJOR_UPnRIGHT	EQU	$10		; line draw major axis is up
BLITCON_LINE_MINOR_CCW		EQU	$20		; minor axis is CCW to MAJOR i.e. left when maj up, up when maj right
							; otherwise 			  right when maj up, down when maj right


BLITCON_EXEC_A			EQU	$01
BLITCON_EXEC_B			EQU	$02
BLITCON_EXEC_C			EQU	$04
BLITCON_EXEC_D			EQU	$08
BLITCON_EXEC_E			EQU	$10

; DMA controller control flags
DMACTL_ACT			EQU	$80		; always set to initiate a transfer
DMACTL_EXTEND			EQU	$20		; use extended functions from control2
DMACTL_HALT			EQU	$10		; halt cpu during transfer
DMACTL_STEP_DEST_NONE		EQU	$00		; do not step destination address
DMACTL_STEP_DEST_UP		EQU	$04		; step destination up after transfer
DMACTL_STEP_DEST_DOWN		EQU	$08		; step destination down after transfer
DMACTL_STEP_DEST_RESV		EQU	$0C		; reserved do not use
DMACTL_STEP_SRC_NONE		EQU	$00		; do not step destination address
DMACTL_STEP_SRC_UP		EQU	$01		; step destination up after transfer
DMACTL_STEP_SRC_DOWN		EQU	$02		; step destination down after transfer
DMACTL_STEP_SRC_RESV		EQU	$03		; reserved do not use

DMACTL2_IF			EQU	$80		; interrupt occurred
DMACTL2_IE			EQU	$02		; interrupt enable, interrupt after transfer
DMACTL2_SZ_BYTE			EQU	$00
DMACTL2_SZ_WORD			EQU	$04
DMACTL2_SZ_WORDSWAPDEST		EQU	$08
DMACTL2_SZ_WORDSWAPSRC		EQU	$0C
DMACTL2_PAUSE			EQU	$01

; Sound Status / control bits
SND_CTL_ACT			EQU	$80
SND_CTL_REPEAT			EQU	$01


DMAC_BLITCON_offs		EQU	0
DMAC_FUNCGEN_offs		EQU	$1
DMAC_WIDTH_offs			EQU	$2
DMAC_HEIGHT_offs		EQU	$3
DMAC_SHIFT_offs			EQU	$4
DMAC_MASK_FIRST_offs		EQU	$5
DMAC_MASK_LAST_offs		EQU	$6
DMAC_DATA_A_offs		EQU	$7
DMAC_ADDR_A_offs		EQU	$8
DMAC_DATA_B_offs		EQU	$B
DMAC_ADDR_B_offs		EQU	$C
DMAC_ADDR_C_offs		EQU	$F
DMAC_ADDR_D_offs		EQU	$12
DMAC_ADDR_E_offs		EQU	$15
DMAC_STRIDE_A_offs		EQU	$18
DMAC_STRIDE_B_offs		EQU	$1A
DMAC_STRIDE_C_offs		EQU	$1C
DMAC_STRIDE_D_offs		EQU	$1E

DMAC_SND_DATA_offs		EQU	$20
DMAC_SND_ADDR_offs		EQU	$21
DMAC_SND_PERIOD_offs		EQU	$24
DMAC_SND_LEN_offs		EQU	$26
DMAC_SND_STATUS_offs		EQU	$28
DMAC_SND_VOL_offs		EQU	$29
DMAC_SND_REPOFF_offs		EQU	$2A
DMAC_SND_PEAK_offs		EQU	$2C

DMAC_SND_MA_VOL_offs		EQU	$2E
DMAC_SND_SEL_offs		EQU	$2F

DMAC_DMA_CTL_offs		EQU	$30
DMAC_DMA_SRC_ADDR_offs		EQU	$31
DMAC_DMA_DEST_ADDR_offs		EQU	$34
DMAC_DMA_COUNT_offs		EQU	$37
DMAC_DMA_DATA_offs		EQU	$39
DMAC_DMA_CTL2_offs		EQU	$3A
DMAC_DMA_PAUSE_offs		EQU	$3B
DMAC_DMA_SEL_offs		EQU	$3F

jim_page_DMAC			EQU	$FEFC		; hardware jim page
jim_DMAC			EQU	$FD60		; jim location in SYS map

jim_page_VERSION		EQU	$FC00

jim_offs_VERSION_API_level	EQU	$80
jim_offs_VERSION_Board_level	EQU	$81
jim_offs_VERSION_API_sublevel	EQU	$82
jim_offs_VERSION_cfg_bits	EQU	$84
jim_offs_VERSION_cap_bits	EQU	$88

; Mk.2/1 option switches - note in API level >1 the sense of these is reversed!
BLT_MK2_CFG0_T65		EQU	$01
BLT_MK2_CFG0_CPU_6502A_2M	EQU	$00
BLT_MK2_CFG0_CPU_65C02_4M	EQU	$02
BLT_MK2_CFG0_CPU_65C02_8M	EQU	$04
BLT_MK2_CFG0_CPU_6x09_2M	EQU	$08
BLT_MK2_CFG0_CPU_6309_4M	EQU	$0A
BLT_MK2_CFG0_CPU_Z80_8M		EQU	$0C
BLT_MK2_CFG0_CPU_68008		EQU	$0E
BLT_MK2_CFG0_SWROMX		EQU	$10
BLT_MK2_CFG0_BUGBTN		EQU	$80

BLT_MK2_CFG1_MEMI		EQU	$01
BLT_MK2_CFG1_BUGOUT		EQU	$02

; Mk.3 switches from PORTF/G
BLT_MK3_CFG0_T65		EQU	$08
BLT_MK3_CFG0_SWROMX		EQU	$10
BLT_MK3_CFG0_MEMI		EQU	$40



jim_DMAC_BLITCON		EQU	jim_DMAC + DMAC_BLITCON_offs
jim_DMAC_FUNCGEN		EQU	jim_DMAC + DMAC_FUNCGEN_offs
jim_DMAC_WIDTH			EQU	jim_DMAC + DMAC_WIDTH_offs
jim_DMAC_HEIGHT			EQU	jim_DMAC + DMAC_HEIGHT_offs
jim_DMAC_SHIFT			EQU	jim_DMAC + DMAC_SHIFT_offs
jim_DMAC_MASK_FIRST		EQU	jim_DMAC + DMAC_MASK_FIRST_offs
jim_DMAC_MASK_LAST		EQU	jim_DMAC + DMAC_MASK_LAST_offs
jim_DMAC_DATA_A			EQU	jim_DMAC + DMAC_DATA_A_offs
jim_DMAC_ADDR_A			EQU	jim_DMAC + DMAC_ADDR_A_offs
jim_DMAC_DATA_B			EQU	jim_DMAC + DMAC_DATA_B_offs
jim_DMAC_ADDR_B			EQU	jim_DMAC + DMAC_ADDR_B_offs
jim_DMAC_ADDR_C			EQU	jim_DMAC + DMAC_ADDR_C_offs
jim_DMAC_ADDR_D			EQU	jim_DMAC + DMAC_ADDR_D_offs
jim_DMAC_ADDR_E			EQU	jim_DMAC + DMAC_ADDR_E_offs
jim_DMAC_STRIDE_A		EQU	jim_DMAC + DMAC_STRIDE_A_offs
jim_DMAC_STRIDE_B		EQU	jim_DMAC + DMAC_STRIDE_B_offs
jim_DMAC_STRIDE_C		EQU	jim_DMAC + DMAC_STRIDE_C_offs
jim_DMAC_STRIDE_D		EQU	jim_DMAC + DMAC_STRIDE_D_offs

jim_DMAC_SND_DATA		EQU	jim_DMAC + DMAC_SND_DATA_offs
jim_DMAC_SND_ADDR		EQU	jim_DMAC + DMAC_SND_ADDR_offs
jim_DMAC_SND_PERIOD		EQU	jim_DMAC + DMAC_SND_PERIOD_offs
jim_DMAC_SND_LEN		EQU	jim_DMAC + DMAC_SND_LEN_offs
jim_DMAC_SND_STATUS		EQU	jim_DMAC + DMAC_SND_STATUS_offs
jim_DMAC_SND_VOL		EQU	jim_DMAC + DMAC_SND_VOL_offs
jim_DMAC_SND_REPOFF		EQU	jim_DMAC + DMAC_SND_REPOFF_offs
jim_DMAC_SND_PEAK		EQU 	jim_DMAC + DMAC_SND_PEAK_offs


jim_DMAC_SND_SEL		EQU	jim_DMAC + DMAC_SND_SEL_offs
jim_DMAC_SND_MA_VOL		EQU	jim_DMAC + DMAC_SND_MA_VOL_offs

jim_DMAC_DMA_CTL		EQU	jim_DMAC + DMAC_DMA_CTL_offs
jim_DMAC_DMA_SRC_ADDR		EQU	jim_DMAC + DMAC_DMA_SRC_ADDR_offs
jim_DMAC_DMA_DEST_ADDR		EQU	jim_DMAC + DMAC_DMA_DEST_ADDR_offs
jim_DMAC_DMA_COUNT		EQU	jim_DMAC + DMAC_DMA_COUNT_offs
jim_DMAC_DMA_DATA		EQU	jim_DMAC + DMAC_DMA_DATA_offs
jim_DMAC_DMA_CTL2		EQU	jim_DMAC + DMAC_DMA_CTL2_offs
jim_DMAC_DMA_PAUSE		EQU	jim_DMAC + DMAC_DMA_PAUSE_offs
jim_DMAC_DMA_SEL		EQU	jim_DMAC + DMAC_DMA_SEL_offs

JIM_DEVNO_HOG1MPAULA		EQU	$D0
JIM_DEVNO_BLITTER		EQU	$D1


	ENDIF