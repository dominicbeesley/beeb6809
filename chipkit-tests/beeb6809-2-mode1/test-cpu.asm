		ORG	$8000

LCD_REG_CMD	EQU	$FE00
LCD_REG_DATA	EQU	$FE01

CC_C		EQU	$01
CC_I		EQU	$10

NUM_BYTES	EQU	7

COUNTER		EQU	$10
VECTOR_CT	EQU	$20
DIRECT_PAGE	EQU	$0
STACKTOP	EQU	$200
SCREEN_BASEx8	EQU	$0

ZP_VDU_PTR	EQU	0
ZP_RNG_X	EQU	1
ZP_RNG_A	EQU	2
ZP_RNG_B	EQU	3
ZP_RNG_C	EQU	4
ZP_DISPLAY_CTR	EQU	5
ZP_DISPLAY_CTR2	EQU	6
ZP_VDU_WKSP	EQU	7
ZP_VDU_WKSP2	EQU	8
ZP_VDU_FORE	EQU	9
ZP_VDU_BACK	EQU	10
ZP_RECV		EQU	11

SHEILA		EQU	$FE00
SHEILA_UART	EQU	SHEILA + $78
SHEILA_UART_TX	EQU	SHEILA_UART + 0
SHEILA_UART_RX	EQU	SHEILA_UART + 0
SHEILA_UART_DLL	EQU	SHEILA_UART + 0
SHEILA_UART_DLM	EQU	SHEILA_UART + 1
SHEILA_UART_IER	EQU	SHEILA_UART + 1
SHEILA_UART_IIR	EQU	SHEILA_UART + 2
SHEILA_UART_FCR	EQU	SHEILA_UART + 2
SHEILA_UART_LCR	EQU	SHEILA_UART + 3
SHEILA_UART_MCR	EQU	SHEILA_UART + 4
SHEILA_UART_LSR	EQU	SHEILA_UART + 5
SHEILA_UART_MSR	EQU	SHEILA_UART + 6
SHEILA_UART_SCR	EQU	SHEILA_UART + 7



NMI_HANDLE
		INC	VECTOR_CT + 0
		RTI
RES_HANDLE
		INC	VECTOR_CT + 1
		RTI
SWI_HANDLE
		INC	VECTOR_CT + 2
		RTI
SWI2_HANDLE
		INC	VECTOR_CT + 3
		RTI
SWI3_HANDLE
		INC	VECTOR_CT + 4
		RTI
FIRQ_HANDLE
		INC	VECTOR_CT + 5
		RTI
IRQ_HANDLE
		INC	VECTOR_CT + 6

		JSR	display_numbers

		RTI
RESET

		LDS	#STACKTOP
		LDA	#DIRECT_PAGE
		TFR	A,DP

		;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! TEST RAM ACCESSES
		LDA	#$5A
		STA	$1500
		STA	$1501
		LDA	$1500
		LDA	$1501
		LDA	#$A5
		STA	$1501
		LDA	$1500
		LDA	$1501

		; setup CRTC
		LDB	#$B
		LDX	#mostbl_VDU_6845_mode_012
crtcsetlp1	STB	$FE20
		LDA	B,X
		STA	$FE21
		DECB
		BPL	crtcsetlp1

		LDA	#12
		STA	$FE20
		LDA	#SCREEN_BASEx8 / $100
		STA	$FE21

		LDA	#13
		STA	$FE20
		LDA	#SCREEN_BASEx8 % $100
		STA	$FE21

		; setup UART
		CLR	SHEILA_UART_IER			; no interrups
		LDA	#%10000111			; enable FIFOs and clear trigger RECV interrupt at 8
		STA	SHEILA_UART_FCR			; no FIFOs


LCRBITS		EQU	%00000011			; 8N1

		LDA	#$80 + LCRBITS
		STA	SHEILA_UART_LCR

BAUD		EQU	4000000/(19200*16)

		LDA	#BAUD % 256
		STA	SHEILA_UART_DLL
		LDA	#BAUD / 256
		STA	SHEILA_UART_DLM

		LDA	#LCRBITS
		STA	SHEILA_UART_LCR

		LDA	#%00001111
		STA	SHEILA_UART_MCR


		; setup RND generator

		LDX	#$1000
		JSR	randomize
clrlp0		JSR	rnd
		STA	,X+
		CMPX	#$7000
		BLS	clrlp0

		; stripes in low $1000
		LDX	#0
		LDB	#0
		LDA	#0
cl2lp		EORA	#$FF
cl2lp2		STA	,X+
		DECB
		BNE	cl2lp2
		CMPX	#$1000
		BLO	cl2lp

		LDX	#$3000-2*16*40
clboxlp		CLR	,X+
		CMPX	#$3000+3*16*40
		BLO	clboxlp

		LDX	#$1000
charlp2
		LDY	#mostbl_chardefs
charlp		LDA	,Y+
		STA	,X+
		CMPY	#endofchars
		BNE	charlp

		LDA	#0
		JSR	vdu
		LDX	#str_hello
		JSR	vdu_str
		LDX	#str_hello
		JSR	vdu_str
		LDX	#str_hello
		JSR	vdu_str
		LDX	#str_hello
		JSR	vdu_str
		LDX	#str_hello
		JSR	vdu_str

;		JSR	lcd_init

		LDB	#NUM_BYTES
		LDX	#COUNTER - 1
loop0		CLR	B,X
		DECB
		BNE	loop0

		LDB	#10
		LDX	#VECTOR_CT - 1
loop02		CLR	B,X
		DECB
		BNE	loop02

		; enable interrupts

		ANDCC	#~CC_I

		; enter main loop



		LDX	#COUNTER
loop2		LDB	#NUM_BYTES - 1
loop1		INC	B,X
		BNE	sk1
		DECB
		BPL	loop1
sk1		LDA	(NUM_BYTES - 1),X
		BRA	loop2


display_numbers
		LDA	$FE00		; read to clear interrupt

;		LDA	#$80
;		JSR	lcd_cmd
;		LDX	#COUNTER
;		LDB	#NUM_BYTES
;		JSR	show

;		LDA	#$C0		; start of line 2
;		JSR	lcd_cmd
;		LDX	#VECTOR_CT
;		LDB	#8
;		JSR	show

		LDA	#3
		JSR	vdu_fore
		LDA	#0
		JSR	vdu_back

		LDA	#0
		JSR	vdu
		LDX	#COUNTER
		LDB	#NUM_BYTES
		JSR	vshow

		LDA	#'@'
		JSR	vdu

		LDX	#VECTOR_CT
		LDB	#8
		JSR	vshow

		LDX	#str_ser
		JSR	vdu_str

		LDA	#'X'
		JSR	vdu
		JSR	vdu
		LDA	#' '
		JSR	vdu

		LDX	#SHEILA_UART_TX + 1
		LDB	#7
		JSR	vshow

		LDA	#'#'
		JSR	vdu

		INC	ZP_DISPLAY_CTR
		LDA	ZP_DISPLAY_CTR
		STA	SHEILA_UART_TX
		JSR	vdu_hex8
		LDA	#' '
		JSR	vdu
		LDA	ZP_DISPLAY_CTR2
		JSR	vdu_hex8
		LDA	#' '
		JSR	vdu

		LDA	#$1
		BITA	SHEILA_UART_LSR			; check for char in recv buffer
		BEQ	nochar
		LDA	SHEILA_UART_RX
		STA	ZP_RECV
		LDA	#1
		JSR	vdu_fore
		LDA	ZP_RECV
		JSR	vdu_hex8
		INC	ZP_DISPLAY_CTR2
		LDX	#$3000
		LDB	ZP_DISPLAY_CTR2
		ANDB	#$1F
		ASLB
		ASLB
		ASLB
		ASLB
		ABX
		STX	ZP_VDU_PTR

		LDA	ZP_DISPLAY_CTR2
		ANDA	#3
		BNE	1F
		INCA
1		JSR	vdu_fore
		LDA	ZP_RECV
		JSR	vdu
		BRA	donechar

nochar
		LDA	ZP_RECV
		JSR	vdu_hex8
donechar

		RTS

show
loop3		LDA	,X+
		JSR	hex8
		DECB	
		BNE	loop3
		RTS

vshow
vloop3		LDA	,X+
		JSR	vdu_hex8
		LDA	#' '
		JSR	vdu
		DECB	
		BNE	vloop3
		RTS


wait
		LDX	#$4000
wlp		LEAX	-1,X
		BNE	wlp
		RTS		

wait2
		LDX	#$0000
wlp2		LEAX	-1,X
		BNE	wlp2
		RTS		

lcd_init
		JSR	wait2

		LDA	#$38		; interface 8bits
		STA	LCD_REG_CMD

		JSR	wait2

		LDA	#$38		; interface 8bits again
		STA	LCD_REG_CMD

		JSR	wait2

		LDA	#$38		; interface 8bits again
		STA	LCD_REG_CMD

		JSR	wait2

		LDA	#$38		; interface 8bits again
		STA	LCD_REG_CMD

		JSR	wait2

		LDA	#$08		; display off
		JSR	lcd_cmd

		LDA	#$01		; display clear
		JSR	lcd_cmd

		LDA	#$06		; entry mode
		JSR	lcd_cmd

		LDA	#$0C		; display on, no cursor
		JSR	lcd_cmd
		RTS


lcd_cmd		TST	LCD_REG_CMD
		BMI	lcd_cmd
		STA	LCD_REG_CMD
		RTS

lcd_write	TST	LCD_REG_CMD
		BMI	lcd_write		; wait for busy flag clear
		STA	LCD_REG_DATA
		RTS

hex8		PSHS	A
		LSRA
		LSRA
		LSRA
		LSRA
		JSR	hex4
		LDA	0,S
		ANDA	#$0F
		JSR	hex4
		PULS	A,PC

hex4		CMPA	#9
		BLS	hex4sk1
		ADDA	#'A' - 10;
		BRA	lcd_write
hex4sk1		ADDA	#'0'
		BRA	lcd_write


vdu_hex8	PSHS	A
		LSRA
		LSRA
		LSRA
		LSRA
		JSR	vdu_hex4
		LDA	0,S
		ANDA	#$0F
		JSR	vdu_hex4
		PULS	A,PC

vdu_hex4	CMPA	#9
		BLS	vdu_hex4sk1
		ADDA	#'A' - 10;
		BRA	vdu
vdu_hex4sk1	ADDA	#'0'
		BRA	vdu

vdu_fore	JSR	vdu_colmask
		STB	ZP_VDU_FORE
		RTS

vdu_back	JSR	vdu_colmask
		STB	ZP_VDU_BACK
		RTS

vdu_colmask	CLRB
		RORA
		BCC	1F
		ORB	#$0F
1		RORA
		BCC	1F
		ORB	#$F0
1		RTS


vdu		PSHS	D,X,Y
		CMPA	#32
		BLO	vdu_ctl
		LDX	<ZP_VDU_PTR
		SUBA	#' '
		LDB	#8
		MUL
		ADDD	#mostbl_chardefs
		TFR	D,Y

		LDB	#8
vdu_lp		LDA	,Y+
		; make it mode 1 left most
		anda	#$F0
		sta	ZP_VDU_WKSP
		lsra
		lsra
		lsra
		lsra
		ora	ZP_VDU_WKSP
		jsr	vdu_col
		STA	,X+
		DECB
		BNE	vdu_lp

		LDB	#8
		LEAY	-8,Y	; go back and do the right most
vdu_lp2		LDA	,Y+
		; make it mode 1 left most
		anda	#$0F
		sta	ZP_VDU_WKSP
		asla
		asla
		asla
		asla
		ora	ZP_VDU_WKSP
		jsr	vdu_col
		STA	,X+
		DECB
		BNE	vdu_lp2


		STX	<ZP_VDU_PTR
		PULS	D,X,Y,PC

vdu_col
		sta	ZP_VDU_WKSP
		anda	ZP_VDU_FORE
		sta	ZP_VDU_WKSP2
		lda	ZP_VDU_WKSP
		eora	#$FF
		anda	ZP_VDU_BACK
		ora	ZP_VDU_WKSP2
		rts


vdu_ctl		LDD	#$1400
		STD	<ZP_VDU_PTR
		PULS	D,X,Y,PC

vdu_str		LDA	,X+
		BEQ	vdu_str_sk
		JSR	vdu
		BRA	vdu_str
vdu_str_sk	RTS

randomize	LDA	#1
		STA	ZP_RNG_X
		INCA
		STA	ZP_RNG_A
		INCA
		STA	ZP_RNG_B
		INCA
		STA	ZP_RNG_C
rnd		INC	ZP_RNG_X
		LDA	ZP_RNG_A
		EORA	ZP_RNG_C
		EORA	ZP_RNG_X
		STA	ZP_RNG_A
		ADDA	ZP_RNG_B
		STA	ZP_RNG_B
		ANDCC	#~CC_C
		RORA
		EORA	ZP_RNG_A
		ADDA	ZP_RNG_C
		STA	ZP_RNG_C
		RTS


mostbl_VDU_6845_mode_45
		FCB	$3F,$28,$31,$24,$26,$00,$20,$22 
		FCB	$01,$07,$67,$08                 

;mostbl_VDU_6845_mode_45
;		FCB	$41,$28,$31,$24,$26,$00,$20,$22 
;		FCB	$01,$07,$67,$08                 

mostbl_VDU_6845_mode_012
		FCB	$7F,$50,$62,$28,$26,$00,$20,$22
		FCB	$01,$07,$67,$08

;mostbl_VDU_6845_mode_012
;		FCB	$83,$50,$62,$28,$26,$00,$20,$22
;		FCB	$01,$07,$67,$08


str_hello	FCB	"Ishbel Bobblechops!       ",0
str_ser		FCB	" SER=",0

mostbl_chardefs
        FCB	$00,$00,$00,$00,$00,$00,$00,$00
        FCB	$18,$18,$18,$18,$18,$00,$18,$00
        FCB	$6C,$6C,$6C,$00,$00,$00,$00,$00
        FCB	$36,$36,$7F,$36,$7F,$36,$36,$00
        FCB	$0C,$3F,$68,$3E,$0B,$7E,$18,$00
        FCB	$60,$66,$0C,$18,$30,$66,$06,$00
        FCB	$38,$6C,$6C,$38,$6D,$66,$3B,$00
        FCB	$0C,$18,$30,$00,$00,$00,$00,$00
        FCB	$0C,$18,$30,$30,$30,$18,$0C,$00
        FCB	$30,$18,$0C,$0C,$0C,$18,$30,$00
        FCB	$00,$18,$7E,$3C,$7E,$18,$00,$00
        FCB	$00,$18,$18,$7E,$18,$18,$00,$00
        FCB	$00,$00,$00,$00,$00,$18,$18,$30
        FCB	$00,$00,$00,$7E,$00,$00,$00,$00
        FCB	$00,$00,$00,$00,$00,$18,$18,$00
        FCB	$00,$06,$0C,$18,$30,$60,$00,$00
        FCB	$3C,$66,$6E,$7E,$76,$66,$3C,$00
        FCB	$18,$38,$18,$18,$18,$18,$7E,$00
        FCB	$3C,$66,$06,$0C,$18,$30,$7E,$00
        FCB	$3C,$66,$06,$1C,$06,$66,$3C,$00
        FCB	$0C,$1C,$3C,$6C,$7E,$0C,$0C,$00
        FCB	$7E,$60,$7C,$06,$06,$66,$3C,$00
        FCB	$1C,$30,$60,$7C,$66,$66,$3C,$00
        FCB	$7E,$06,$0C,$18,$30,$30,$30,$00
        FCB	$3C,$66,$66,$3C,$66,$66,$3C,$00
        FCB	$3C,$66,$66,$3E,$06,$0C,$38,$00
        FCB	$00,$00,$18,$18,$00,$18,$18,$00
        FCB	$00,$00,$18,$18,$00,$18,$18,$30
        FCB	$0C,$18,$30,$60,$30,$18,$0C,$00
        FCB	$00,$00,$7E,$00,$7E,$00,$00,$00
        FCB	$30,$18,$0C,$06,$0C,$18,$30,$00
        FCB	$3C,$66,$0C,$18,$18,$00,$18,$00
        FCB	$3C,$66,$6E,$6A,$6E,$60,$3C,$00
        FCB	$3C,$66,$66,$7E,$66,$66,$66,$00
        FCB	$7C,$66,$66,$7C,$66,$66,$7C,$00
        FCB	$3C,$66,$60,$60,$60,$66,$3C,$00
        FCB	$78,$6C,$66,$66,$66,$6C,$78,$00
        FCB	$7E,$60,$60,$7C,$60,$60,$7E,$00
        FCB	$7E,$60,$60,$7C,$60,$60,$60,$00
        FCB	$3C,$66,$60,$6E,$66,$66,$3C,$00
        FCB	$66,$66,$66,$7E,$66,$66,$66,$00
        FCB	$7E,$18,$18,$18,$18,$18,$7E,$00
        FCB	$3E,$0C,$0C,$0C,$0C,$6C,$38,$00
        FCB	$66,$6C,$78,$70,$78,$6C,$66,$00
        FCB	$60,$60,$60,$60,$60,$60,$7E,$00
        FCB	$63,$77,$7F,$6B,$6B,$63,$63,$00
        FCB	$66,$66,$76,$7E,$6E,$66,$66,$00
        FCB	$3C,$66,$66,$66,$66,$66,$3C,$00
        FCB	$7C,$66,$66,$7C,$60,$60,$60,$00
        FCB	$3C,$66,$66,$66,$6A,$6C,$36,$00
        FCB	$7C,$66,$66,$7C,$6C,$66,$66,$00 
        FCB	$3C,$66,$60,$3C,$06,$66,$3C,$00 
        FCB	$7E,$18,$18,$18,$18,$18,$18,$00 
        FCB	$66,$66,$66,$66,$66,$66,$3C,$00 
        FCB	$66,$66,$66,$66,$66,$3C,$18,$00 
        FCB	$63,$63,$6B,$6B,$7F,$77,$63,$00 
        FCB	$66,$66,$3C,$18,$3C,$66,$66,$00 
        FCB	$66,$66,$66,$3C,$18,$18,$18,$00 
        FCB	$7E,$06,$0C,$18,$30,$60,$7E,$00 
        FCB	$7C,$60,$60,$60,$60,$60,$7C,$00 
        FCB	$00,$60,$30,$18,$0C,$06,$00,$00 
        FCB	$3E,$06,$06,$06,$06,$06,$3E,$00 
        FCB	$18,$3C,$66,$42,$00,$00,$00,$00 
        FCB	$00,$00,$00,$00,$00,$00,$00,$FF 
        FCB	$1C,$36,$30,$7C,$30,$30,$7E,$00 
        FCB	$00,$00,$3C,$06,$3E,$66,$3E,$00 
        FCB	$60,$60,$7C,$66,$66,$66,$7C,$00 
        FCB	$00,$00,$3C,$66,$60,$66,$3C,$00 
        FCB	$06,$06,$3E,$66,$66,$66,$3E,$00 
        FCB	$00,$00,$3C,$66,$7E,$60,$3C,$00 
        FCB	$1C,$30,$30,$7C,$30,$30,$30,$00 
        FCB	$00,$00,$3E,$66,$66,$3E,$06,$3C 
        FCB	$60,$60,$7C,$66,$66,$66,$66,$00 
        FCB	$18,$00,$38,$18,$18,$18,$3C,$00 
        FCB	$18,$00,$38,$18,$18,$18,$18,$70 
        FCB	$60,$60,$66,$6C,$78,$6C,$66,$00 
        FCB	$38,$18,$18,$18,$18,$18,$3C,$00 
        FCB	$00,$00,$36,$7F,$6B,$6B,$63,$00 
        FCB	$00,$00,$7C,$66,$66,$66,$66,$00 
        FCB	$00,$00,$3C,$66,$66,$66,$3C,$00 
        FCB	$00,$00,$7C,$66,$66,$7C,$60,$60 
        FCB	$00,$00,$3E,$66,$66,$3E,$06,$07 
        FCB	$00,$00,$6C,$76,$60,$60,$60,$00 
        FCB	$00,$00,$3E,$60,$3C,$06,$7C,$00 
        FCB	$30,$30,$7C,$30,$30,$30,$1C,$00 
        FCB	$00,$00,$66,$66,$66,$66,$3E,$00 
        FCB	$00,$00,$66,$66,$66,$3C,$18,$00 
        FCB	$00,$00,$63,$6B,$6B,$7F,$36,$00 
        FCB	$00,$00,$66,$3C,$18,$3C,$66,$00 
        FCB	$00,$00,$66,$66,$66,$3E,$06,$3C 
        FCB	$00,$00,$7E,$0C,$18,$30,$7E,$00 
        FCB	$0C,$18,$18,$70,$18,$18,$0C,$00 
        FCB	$18,$18,$18,$00,$18,$18,$18,$00 
        FCB	$30,$18,$18,$0E,$18,$18,$30,$00 
        FCB	$31,$6B,$46,$00,$00,$00,$00,$00 
        FCB	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF 
endofchars

        FCB	$FF,$FF,$FF,$FF,$FF,$FF

		INCLUDEBIN "z.64c"

here3		
		FILL	$FF, $F7EF-here3-1


		ORG	$F7F0
XRESV     FDB  RES_HANDLE  ; $FFF0   ; Hardware vectors, paged in to $FFFx
XSWI3V    FDB  SWI3_HANDLE ; $FFF2
XSWI2V    FDB  SWI2_HANDLE ; $FFF4
XFIRQV    FDB  FIRQ_HANDLE ; $FFF6
XIRQV     FDB  IRQ_HANDLE  ; $FFF8
XSWIV     FDB  SWI_HANDLE  ; $FFFA
XNMIV     FDB  NMI_HANDLE  ; $FFFC
XRESETV   FDB  RESET       ; $FFFE

here		
		FILL	$FF, $FFFF-here-1

