;; *************************************************************
;; Configuration
;; *************************************************************

   include "SBC09VERSION.inc"

FC_NONE      EQU 0
FC_XON_XOFF  EQU 1
FC_RTS_CTS   EQU 2

FLOW_CONTROL EQU FC_NONE

;; *************************************************************
;; Memory
;; *************************************************************

ZP_START     EQU  $00f0

ZP_TIME      EQU  $00f0
ZP_RX_HEAD   EQU  $00f4
ZP_RX_TAIL   EQU  $00f5
ZP_TX_HEAD   EQU  $00f6
ZP_TX_TAIL   EQU  $00f7
ZP_XOFF      EQU  $00f8
ZP_ERRPTR    EQU  $00fd
ZP_ESCFLAG   EQU  $00ff

ZP_END       EQU  $00fF

BRKV         EQU  $0202


;; Rx Buffer is 0x9e00-0x9eFF - Set in middle as B,X addressing is used (B is signed)
RX_BUFFER    EQU  $9E80

;; Tx Buffer is 0x9f00-0x9FFF - Set in middle as B,X addressing is used (B is signed)
TX_BUFFER    EQU  $9F80

UART         EQU  $A000

;; *************************************************************
;; UART
;; *************************************************************

   IF FLOW_CONTROL == FC_RTS_CTS
;; If Rx occupancy > 75% then
;;     UART_CTRL = D5 (B6:5=10; RTS high; TxIRQ disabled)
;; else if Tx occupancy > 0% then
;;     UART_CTRL = B5 (B6:5=01; RTS low;  TxIRQ enabled)
;; else
;;     UART_CTRL = 95 (95: B6:5=00; RTS low;  TxIRQ disabled)

UPDATE_UART_CTRL
      LDB  <ZP_RX_TAIL    ; Determine whethe RTS needs to be raised
      SUBB <ZP_RX_HEAD    ; Tail - Head gives the receive buffer occupancy
      CMPB #$C0           ; C=0 if occupancy >=75%
      LDB  #$D5
      BCC  2F
      LDB  <ZP_TX_HEAD    ; Is the Tx buffer empty?
      CMPB <ZP_TX_TAIL
      BEQ  1F
      LDB  #$B5
      BRA  2F
1     LDB  #$95
2     STB  UART
      RTS
   ENDIF

IRQ_HANDLER
      LDA  UART            ; Read UART status register
      BITA #$01            ; Test bit 0 (RxFull)

      BEQ  IRQ_TX          ; no, then go on to check for a transmit interrupt
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
      BEQ  IRQ_TX          ; yes, then drop characters
      STB  <ZP_RX_TAIL     ; no, then save the incremented tail pointer

IRQ_TX
      LDA  UART            ; Read UART status register
      BITA #$02            ; Test bit 0 (TxEmpty)
      BEQ  IRQ_EXIT        ; Not empty, so exit

   ;; Simple implementation of XON/XOFF to prevent receive buffer overflow
   IF FLOW_CONTROL == FC_XON_XOFF
      LDB   <ZP_RX_TAIL    ; Determine if we need to send XON or XOFF
      SUBB  <ZP_RX_HEAD    ; Tail - Head gives the receive buffer occupancy
      EORB  <ZP_XOFF       ; In XOFF state, complement to give some hysterisis
      CMPB  #$C0           ; C=0 if occupancy >=75% (when in XON) or <25% (when in XOFF)
      BCS   IRQ_TX_CHAR    ; Nothing to do...
      LDA   #$11           ; 0x11 = XON character
      COM   <ZP_XOFF       ; toggle the XON/XOFF state
      BEQ   SEND_A         ; Send XON
      LDA   #$13           ; 0x13 = XOFF character
      BRA   SEND_A         ; Send XOFF
   ENDIF

IRQ_TX_CHAR
      LDB  <ZP_TX_HEAD     ; Is the Tx buffer empty?
      CMPB <ZP_TX_TAIL
      BEQ  IRQ_TX_EMPTY    ; Yes, then disable Tx interrupts and exit
      LDX  #TX_BUFFER      ; No, then write the next character
      INCB
      STB  <ZP_TX_HEAD
      LDA  B,X

SEND_A
      STA  UART+1

IRQ_EXIT

   IF FLOW_CONTROL == FC_RTS_CTS
IRQ_TX_EMPTY
      BSR UPDATE_UART_CTRL
   ELSE
      RTI
IRQ_TX_EMPTY
      LDA  #$95
      STA  UART
   ENDIF

ILL_HANDLER
SWI_HANDLER
SWI2_HANDLER
FIRQ_HANDLER
NMI_HANDLER
      RTI

OSRDCH
      PSHS  B,X
1     LDB   <ZP_RX_HEAD
      CMPB  <ZP_RX_TAIL
      BEQ   1B
      LDX   #RX_BUFFER
      LDA   B,X
      INC   <ZP_RX_HEAD
   IF FLOW_CONTROL == FC_RTS_CTS
      BSR   UPDATE_UART_CTRL
   ENDIF
      LDB   <ZP_ESCFLAG
      ROLB
      PULS  B,X
      RTS

;; *************************************************************
;; OS Interface
;; *************************************************************

OSINIT
      CLRA           ;; Big Endian Flag
      LDX   #BRKV
      LDY   #ZP_ESCFLAG
      ;; fall through to

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
      CMPA  #$01
      BLO   OSWORD_READLINE
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
      ROLA
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
      LDX   #$9E00
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
      PSHS  B,X
1
      LDB   <ZP_TX_TAIL ; Is there space in the Tx buffer for one more character?
      INCB
      CMPB  <ZP_TX_HEAD
      BEQ   1B          ; No, then loop back and wait for characters to drain

      LDX   #TX_BUFFER  ; Write the character to the tail of the Tx buffer
      STA   B,X
      STB   <ZP_TX_TAIL ; Save the updated tail pointer
   IF FLOW_CONTROL == FC_RTS_CTS
      JSR   UPDATE_UART_CTRL
   ELSE
      LDB   #$B5        ; Enable Tx interrupts to make sure buffer is serviced
      STB   UART
   ENDIF
      PULS  B,X
      RTS

PRSTRING
      LDA   ,X+
      BEQ   1F
      JSR   OSASCI
      BRA   PRSTRING
1     RTS


SWI3_HANDLER
   IF NATIVE
      ldx   12,S
   ELSE
      ldx   10,S              ; points at byte after SWI instruction
   ENDIF
      stx   <ZP_ERRPTR
      jmp   [BRKV]            ; and JUMP via BRKV (normally into current language)


DEFAULT_BRK_HANDLER

RESET_HANDLER
      ;; Initialize the stack and direct page
      LDS   #$0200
      CLRA
      TFR   A,DP

   IF NATIVE
      LDMD #$01
   ENDIF
      ;; Initialize Zero Page
      LDX  #ZP_START
1
      STA  ,X+
      CMPX #ZP_END+1
      BNE  1B
      ;; Initialize the SWI Handler
      LDD   #DEFAULT_BRK_HANDLER
      STD   BRKV
      ;; Initialize the UART
      ;; RX INT ENABLED, RTS LOW, TX INT DISABLED, 8N1, CLK/16
   IF FLOW_CONTROL == FC_RTS_CTS
      JSR  UPDATE_UART_CTRL
   ELSE
      LDA  #$95
      STA  UART
   ENDIF
      ;; Enable interrupts
      CLI
      ;; Print the reset message
      LDX   #RESET_MSG
      JSR   PRSTRING
      ;; Enter Basic
      JMP   $C000

__CODE_END

      ;; We are placing the manually to work around a asm6809 bug
      ;; that prevented us filling the rom completely
   IF CPU_6309
      ORG   $FFDB
   ELSE
      ORG   $FFDC
   ENDIF

RESET_MSG

__FREESPACE     EQU RESET_MSG-__CODE_END

      FCB  $0D
   IF CPU_6309
      IF NATIVE
         FCC "SBC6309N "
      ELSE
         FCC "SBC6309E "
      ENDIF
   ELSE
      FCC "SBC6809 "
   ENDIF
      FCC  SBC09VERSION
      FCB  $0A, $0D
   IF FLOW_CONTROL == FC_XON_XOFF
      FCB  $11                ; XON
   ENDIF
      FCB  $00

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
