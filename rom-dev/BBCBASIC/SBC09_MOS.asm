;; *************************************************************
;; Memory
;; *************************************************************

ZP_TIME      EQU  $00f0
ZP_RX_HEAD   EQU  $00f4
ZP_RX_TAIL   EQU  $00f5
ZP_ERRPTR    EQU  $00fd
ZP_ESCFLAG   EQU  $00ff

BRKV         EQU  $0202


;; 0x300-0x3FF - Set in middle as B,X addressing is used (B is signed)

RX_BUFFER    EQU  $380


;; *************************************************************
;; UART
;; *************************************************************

UART         EQU  $A000

UART_INIT
      ; 6850 ACIA CONTROL REGISTER:
      ; RX INT ENABLED, RTS LOW, TX INT DISABLED, 8N1, CLK/16
      LDA   #$95
      STA   UART
      CLR   <ZP_RX_HEAD
      CLR   <ZP_RX_TAIL
      CLI
      RTS

IRQ_HANDLER
      PSHS CC,A,B,X
      LDA  UART            ; Read UART status register
      BITA #$01            ; Test bit 0 (RxFull)
      BEQ  IRQ_EXIT        ; Exit if no character
      LDA  UART+1          ; Read UART Rx Data (and clear interrupt)
      CMPA #$1B            ; Test for escape
      BNE  IRQ_NOESC
      LDB  #$80            ; Set the escape flag
      STB  <ZP_ESCFLAG
IRQ_NOESC
      LDB  <ZP_RX_TAIL     ; B = keyboard buffer tail index
      LDX  #RX_BUFFER      ; X = keyboard buffer base address
      STA  B,X             ; store the character in the buffer
      INCB                 ; increment the tail pointer
      CMPB <ZP_RX_HEAD     ; has it hit the head (buffer full?)
      BEQ  IRQ_EXIT        ; yes, then drop characters
      STB  <ZP_RX_TAIL     ; no, then save the incremented tail pointer
IRQ_EXIT
      PULS CC,A,B,X
      RTI

OSRDCH
      PSHS  B,X
1     LDB   <ZP_RX_HEAD
      CMPB  <ZP_RX_TAIL
      BEQ   1B
      LDX   #RX_BUFFER
      LDA   B,X
      INCB
      STB   <ZP_RX_HEAD
      LDB   <ZP_ESCFLAG
      ROLB
      PULS  B,X
      RTS

;; *************************************************************
;; OS Interface
;; *************************************************************

OSINIT
		LDA	#$00           ;; Big Endian Flag
      LDX   #BRKV
		LDY	#ZP_ESCFLAG
		CLR	<ZP_ESCFLAG
      RTS

;; *************************************************************
;; File System
;; *************************************************************


OSARGS
OSBGET
OSBPUT
OSCLI
OSFILE
OSFILE_LOAD
OSFILE_SAVE
OSFIND
      RTS

;; *************************************************************
;; OSWORD
;; *************************************************************

OSWORD
      CMPA  #$00
      BEQ   OSWORD_READLINE
      CMPA  #$01
      BEQ   OSWORD_READSYSCLK
      CMPA  #$02
      BEQ   OSWORD_WRITESYSCLK
      RTS

;; On Entry: X points to the parameter block
;; 0: Buffer address
;; 2: Max line length
;; 3: Min ascii
;; 4: Max ascii

OSWORD_READLINE
      CLRB
      LDY   ,X
      BRA   CLOOP2
CLOOP0
      INCB
      LEAY  1,Y
CLOOP1
      JSR   OSASCI
CLOOP2
      JSR   OSRDCH
      BCS   CEXIT_ERR
      CMPA  #$08
      BNE   CNOTDEL
      TSTB
      BEQ   CLOOP2
      DECB
      LEAY  -1,Y
      JSR   OSASCI
      LDA   #$20
      JSR   OSASCI
      LDA   #$08
      BRA   CLOOP1
CNOTDEL
      STA   ,Y
      CMPA  #$0D
      BEQ   CEXIT_OK
      CMPA  3,X
      BLO   CLOOP2
      CMPA  4,X
      BHI   CLOOP2
      CMPB  2,X
      BLO   CLOOP0
      LDA   #$07
      BRA   CLOOP1
CEXIT_OK
      JSR   OSNEWL
CEXIT_ERR
      LDA   <ZP_ESCFLAG
      ROL   A
      RTS

OSWORD_READSYSCLK
      LDA  <ZP_TIME
      STA  ,X+
      LDA  <ZP_TIME+1
      STA  ,X+
      LDA  <ZP_TIME+2
      STA  ,X+
      LDA  <ZP_TIME+3
      STA  ,X+
      ;; Increment the clock each time it's read, as we have no other timer!
      INC  <ZP_TIME
      BNE  1F
      INC  <ZP_TIME+1
      BNE  1F
      INC  <ZP_TIME+2
      BNE  1F
      INC  <ZP_TIME+3
1     RTS

OSWORD_WRITESYSCLK
      LDA  ,X+
      STA  <ZP_TIME
      LDA  ,X+
      STA  <ZP_TIME+1
      LDA  ,X+
      STA  <ZP_TIME+2
      LDA  ,X+
      STA  <ZP_TIME+3
      RTS

OSWORD_ENVELOPE
OSWORD_SOUND
      RTS

;; *************************************************************
;; OSBYTE
;; *************************************************************

OSBYTE
      CMPA  #$7C
      BNE   1F
      CLR   <ZP_ESCFLAG
      RTS
1
      CMPA  #$7D
      BNE   1F
      CLR   <ZP_ESCFLAG
      COM   <ZP_ESCFLAG
      RTS
1
      CMPA  #$7E
      BNE   1F
      CLR   <ZP_ESCFLAG
      CLR   <ZP_RX_HEAD
      CLR   <ZP_RX_TAIL
      LDX   #$00FF
      RTS
1
      CMPA  #$83
      BNE   1F
      LDX   #$0800
      RTS
1
      CMPA  #$84
      BNE   1F
      LDX   #$8000
      RTS
1
      LDX   #$0000
      RTS

;; *************************************************************
;; Input/Output
;; *************************************************************

OSASCI
      CMPA  #$0D
      BNE   OSWRCH

OSNEWL
      LDA   #$0A
      JSR   OSWRCH
      LDA   #$0D

OSWRCH
      PSHS  A
1     LDA   UART
      ANDA  #$02
      BEQ   1B
      PULS  A
      STA   UART+1
      RTS

PRSTRING
      LDA	,X+
		BEQ	1F
		JSR	OSASCI
		BRA	PRSTRING
1		RTS


RESET_MSG
      FCB  13
      FCC  "SBC09 BBC BASIC"
      FCB  10,13,0

ILL_HANDLER
SWI_HANDLER
SWI2_HANDLER
FIRQ_HANDLER
NMI_HANDLER
      RTI


SWI3_HANDLER
		pshs	CC,A,X
	IF NATIVE
		ldx	16,S
	ELSE
		ldx	14,S					; points at byte after SWI instruction
	ENDIF
		stx   <ZP_ERRPTR
		stx	2,S					; set X on return to this
		puls	CC,A,X			   ; restore A,X,CC
		jmp	[BRKV]				; and JUMP via BRKV (normally into current language)


DEFAULT_BRK_HANDLER

RESET_HANDLER
      ;; Initialize the stack and direct page
      LDS   #$0200
      CLRA
      TFR   A,DP
      ;; Initialize time
      STA   <ZP_TIME
      STA   <ZP_TIME+1
      STA   <ZP_TIME+2
      STA   <ZP_TIME+3
      ;; Initialize the SWI Handler
      LDD   #DEFAULT_BRK_HANDLER
      LDX   #BRKV
      STD   ,X
      ;; Initialize the UART
      JSR   UART_INIT
      ;; Print the reset message
      LDX   #RESET_MSG
      JSR   PRSTRING
      ;; Enter Basic
      JMP   $C000


;; *************************************************************
;; Vectors
;; *************************************************************

      ORG   $FFF0

      FDB   ILL_HANDLER
      FDB   SWI3_HANDLER
      FDB   SWI2_HANDLER
      FDB   FIRQ_HANDLER
      FDB   IRQ_HANDLER
      FDB   SWI_HANDLER
      FDB   NMI_HANDLER
      FDB   RESET_HANDLER
