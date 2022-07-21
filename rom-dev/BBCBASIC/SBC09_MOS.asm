;; *************************************************************
;; UART
;; *************************************************************

UART         EQU  $A000

; 6850 ACIA CONTROL REGISTER:
; RX INT DISABLED, RTS LOW, TX INT DISABLED, 8N1, CLK/16
UART_INIT    EQU  $15


;; *************************************************************
;; Memory
;; *************************************************************

ZP_TIME      EQU  $00f0
ZP_ERRPTR    EQU  $00fd
ZP_ESCFLAG   EQU  $00ff

BRKV         EQU  $0202

;; *************************************************************
;; OS Interface
;; *************************************************************

OSINIT
		LDA	#$00           ;; Big Endian Flag
      LDX   #BRKV
		LDY	#ZP_ESCFLAG
		CLR	ZP_ESCFLAG
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

OSWORD_READLINE
      LDX   ,X
1
      JSR   OSRDCH
      JSR   OSASCI
      CMPA  #$08
      BEQ   2F
      STA   ,X+
      CMPA  #$0D
      BNE   1B
      ANDCC #$FE
      RTS
      RTS
2     LEAX  -1,X
      BRA   1B

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

OSRDCH
      LDA   UART
      ANDA  #$01
      BEQ   OSRDCH
      LDA   UART + 1
      ANDCC #$FE
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
IRQ_HANDLER
NMI_HANDLER
      RTI


SWI3_HANDLER
		pshs	CC,A,X
	IF NATIVE
		ldx	16,S
	ELSE
		ldx	14,S					; points at byte after SWI instruction
	ENDIF
		stx   ZP_ERRPTR
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
      LDX   #UART
      LDA   #UART_INIT
      STA   ,X
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
