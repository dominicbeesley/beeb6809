;; *************************************************************
;; Configuration
;; *************************************************************

;
; Minimal SBC09 FUZIX Boot ROM, based on Dominic Beesley's Blitter-sbc09 boot rom
;
FUZIX_IMG_OFFSET  EQU   $01  ; the starting MMU page for the kernel image (binary format), relative to the Mini MOS
FUZIX_RUN_BLK     EQU   $80   ; the starting MMU page for the base of the kernel at run-time

   include "SBC09VERSION.inc"

FC_NONE        EQU   0
FC_XON_XOFF    EQU   1
FC_RTS_CTS     EQU   2

FLOW_CONTROL   EQU   FC_RTS_CTS

;; Threshold at which RTS is asserted
FC_LO_THRESH   EQU   $80

;; Threshold at which RTS is de-asserted
FC_HI_THRESH   EQU   $C0

;; *************************************************************
;; Memory
;; *************************************************************

ZP_START       EQU   $00f0

ZP_TIME        EQU   $00f0
ZP_RX_HEAD     EQU   $00f4
ZP_RX_TAIL     EQU   $00f5
ZP_TX_HEAD     EQU   $00f6
ZP_TX_TAIL     EQU   $00f7
ZP_XOFF        EQU   $00f8
ZP_ERRPTR      EQU   $00fd
ZP_ESCFLAG     EQU   $00ff

ZP_END         EQU   $00fF

BRKV           EQU   $0202

;; Rx Buffer is 0x7e00-0x7eFF - Set in middle as B,X addressing is used (B is signed)
RX_BUFFER      EQU   $7E80

;; Tx Buffer is 0x7f00-0x7FFF - Set in middle as B,X addressing is used (B is signed)
TX_BUFFER      EQU   $7F80

UART           EQU   $FE00
MMU0           EQU   $FE10
MMU1           EQU   $FE20

UART_MRA       EQU   UART+0x0
UART_SRA       EQU   UART+0x1
UART_CSRA      EQU   UART+0x1
UART_CRA       EQU   UART+0x2
UART_THRA      EQU   UART+0x3
UART_RHRA      EQU   UART+0x3
UART_ACR       EQU   UART+0x4
UART_ISR       EQU   UART+0x5
UART_IMR       EQU   UART+0x5
UART_CTU       EQU   UART+0x6
UART_CTL       EQU   UART+0x7
UART_MRB       EQU   UART+0x8
UART_SRB       EQU   UART+0x9
UART_CSRB      EQU   UART+0x9
UART_CRB       EQU   UART+0xa
UART_THRB      EQU   UART+0xb
UART_RHRB      EQU   UART+0xb
UART_IVR1      EQU   UART+0xc
UART_IPR       EQU   UART+0xd  ; read input port
UART_OPCR      EQU   UART+0xd  ; write
UART_OPRSET    EQU   UART+0xe  ; write
UART_STARTCT   EQU   UART+0xe  ; read command
UART_OPRCLR    EQU   UART+0xf  ; write
UART_STOPCT    EQU   UART+0xf  ; read command

UART_RXINT     EQU   $01
UART_TXINT     EQU   $04

JP1            EQU   $04   ; IP2 - Enable MMU
JP2            EQU   $08   ; IP3 - 8K Mode - hack to IP5
JP3            EQU   $10   ; IP4 - unused

      ORG $F000

;; *************************************************************
;; UART Initialization
;; *************************************************************

UART_INIT MACRO
      LDA   #%00010011     ; NO PARITY, 8 BITS/CHAR - MR1A,B
      STA   UART_MRA
      LDA   #%00010111     ; CTS ENABLE TX, 1.000 STOP BITS - MR2A,B
      STA   UART_MRA
      LDA   #%00000101     ; ENABLE TX AND RX
      STA   UART_CRA
      LDA   #%10000000     ; Set Channel A Rx Extend Bit
      STA   UART_CRA
      LDA   #%10100000     ; Set Channel A Tx Extend Bit
      STA   UART_CRA
      LDA   #%10001000     ; Internal 115,200 baus
      STA   UART_CSRA
      LDA   #%01110000     ; Timer Mode, Clock = XTAL/16 = 3686400 / 16 = 230400 Hz
      STA   UART_ACR
      LDA   #%00000001     ; assert RTS
      STA   UART_OPRSET

      LDA   UART_IPR       ; Read jumpers
      BITA  #JP3           ; Test jumper JP3 (Boot FUZIX)
      LBEQ  FUZIX          ; JP3 fitted, so boot FUZIX

      LDD   #(2304/2-1)    ; 16-bit write to counter to get a 100Hz tick
      STD   UART_CTU
      LDA   #$0A           ; Timer Int, Rx Int enabled; Rx Int disabled
      STA   UART_IMR
      LDA   UART_STARTCT   ; Start the counter-timer
;;    LDA   #%00000100
;;    STA   UART_OPCR      ; Ouput timer squarewave on OP3 for debugging only

      LDX   #MMU_DISABLED_MSG
      TFR   U, A           ; It's only possible to disable the MMU if we are currently
      CMPA  #1             ; running from ROM block 1. Any other block, then
      BNE   SKIP_JP1_TEST  ; then we must have entered via the boot loader/MMU Enabled

      LDA   UART_IPR       ; Read jumpers
      BITA  #JP1           ; Test jumper JP1 (Enable MMU)
      BNE   DONE           ; JP1 not fitted, so don't initialiaze MMU

SKIP_JP1_TEST
      LDA   UART_IPR       ; Read jumpers
      BITA  #JP2           ; Test jumper JP2 (8K Mode)
      BEQ   MMU_8K         ; JP2 fitted, so use 8K Mode

;; MMU 7 is write protect (16K mode) or Block LSB (8K Mode)
;; MMU 6:5 is device (00=ROM0, 01=ROM1, 10=RAM, 11=External)
;; MMU 4:0 is block

      ;; On reset the MMU is disabled, with block size set to 16K


MMU_16K
      LDA   #%10000000     ; 0000-3FFF -> RAM block 0
      STA   MMU0 + 0
      LDA   #%10000001     ; 4000-7FFF -> RAM block 1
      STA   MMU0 + 1
      TFR   U,A            ; 8000-BFFF -> ROM0 block 0
      DECA
      STA   MMU0 + 2
      TFR   U,A            ; C000-FFFF -> ROM0 block 1
      STA   MMU0 + 3

      ;; Enable the MMU with 16K block size
      LDA   #%00010000     ; OP4 = low (MMU Enabled, output is inverted)
      STA   UART_OPRSET
      LDX   #MMU_16K_MSG
      BRA   DONE

MMU_8K
      LDA   #%10000000     ; 0000-1FFF -> RAM block 0
      STA   MMU0 + 0
      LDA   #%10000001     ; 2000-3FFF -> RAM block 1
      STA   MMU1 + 0
      LDA   #%10000010     ; 4000-5FFF -> RAM block 2
      STA   MMU0 + 1
      LDA   #%10000011     ; 6000-7FFF -> RAM block 3
      STA   MMU1 + 1
      TFR   U, A           ; 8000-9FFF -> ROM0 block 0
      DECA
      STA   MMU0 + 2
      ORA   #%00100000     ; A000-BFFF -> ROM0 block 1
      STA   MMU1 + 2
      TFR   U, A           ; C000-DFFF -> ROM0 block 2
      STA   MMU0 + 3
      ORA   #%00100000     ; E000-FFFF -> ROM0 block 3
      STA   MMU1 + 3

      ;; Enable the MMU with 8K block size
      LDA   #%00011000     ; OP4 = low (MMU Enabled, output is inverted)
      STA   UART_OPRSET    ; OP3 = low (8K block size, output is inverted)
      LDX   #MMU_8K_MSG

DONE
      ENDM

;; *************************************************************
;; Main IRQ Handler
;; *************************************************************

IRQ_RX
      LDA   UART_RHRA      ; Read UART Rx Data (and clear interrupt)
      CMPA  #$1B           ; Test for escape
      BNE   IRQ_NOESC
      LDB   #$80           ; Set the escape flag
      STB   <ZP_ESCFLAG

IRQ_NOESC
      LDB   <ZP_RX_TAIL    ; B = keyboard buffer tail index
      LDX   #RX_BUFFER     ; X = keyboard buffer base address
      STA   B,X            ; store the character in the buffer
      INCB                 ; increment the tail pointer
      CMPB  <ZP_RX_HEAD    ; has it hit the head (buffer full?)
      BEQ   IRQ_HANDLER    ; yes, then drop characters
      STB   <ZP_RX_TAIL    ; no, then save the incremented tail pointer

   ;; Simple implementation of RTS/CTS to prevent receive buffer overflow
   IF FLOW_CONTROL == FC_RTS_CTS
      SUBB  <ZP_RX_HEAD    ; Tail - Head gives the receive buffer occupancy
      CMPB  #FC_HI_THRESH  ; Compare with upper threshold
      BNE   IRQ_HANDLER
      LDB   #$01
      STB   UART_OPRCLR    ; de-assert RTS
   ENDIF

IRQ_HANDLER

      LDA   UART_SRA       ; Read UART status register
      BITA  #UART_RXINT    ; Test bit 0 (RxRdy)
      BNE   IRQ_RX         ; Ready, branch back handle the character

      BITA  #UART_TXINT    ; Test bit 2 (TxRdy)
      BEQ   IRQ_TIMER      ; Not ready, branch forward to the timer check

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
      LDB   <ZP_TX_HEAD    ; Is the Tx buffer empty?
      CMPB  <ZP_TX_TAIL
      BEQ   IRQ_TX_EMPTY   ; Yes, then disable Tx interrupts and exit
      LDX   #TX_BUFFER     ; No, then write the next character
      INCB
      STB   <ZP_TX_HEAD
      LDA   B,X
SEND_A
      STA   UART_THRA

IRQ_TIMER
      LDA   UART_ISR       ; Read UART Interrupt Status Register
      ANDA  #$08           ; Check the timer bit
      BEQ   IRQ_EXIT

      LDA   UART_STOPCT    ; Clear the interrupt
      INC   <ZP_TIME       ; Update the system clock
      BNE   IRQ_EXIT
      INC   <ZP_TIME+1
      BNE   IRQ_EXIT
      INC   <ZP_TIME+2
      BNE   IRQ_EXIT
      INC   <ZP_TIME+3

IRQ_EXIT
      RTI

IRQ_TX_EMPTY
      LDA   #$0A           ; Disable TX interrupts
      STA   UART_IMR
      BRA   IRQ_TIMER

ILL_HANDLER
SWI_HANDLER
SWI2_HANDLER
FIRQ_HANDLER
NMI_HANDLER
      RTI

NVRDCH
      PSHS  B,X
1     LDB   <ZP_RX_HEAD
      CMPB  <ZP_RX_TAIL
      BEQ   1B
      LDX   #RX_BUFFER
      LDA   B,X
      INC   <ZP_RX_HEAD
   IF FLOW_CONTROL == FC_RTS_CTS
      LDB   <ZP_RX_TAIL    ; Determine whethe RTS needs to be raised
      SUBB  <ZP_RX_HEAD    ; Tail - Head gives the receive buffer occupancy
      CMPB  #FC_LO_THRESH
      BNE   1F
      LDB   #$01
      STB   UART_OPRSET    ; assert RTS
1
   ENDIF
      LDB   <ZP_ESCFLAG
      ROLB
      PULS  B,X
      RTS


;; *************************************************************
;; OSWORD
;; *************************************************************

NVWORD
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
      LDA   <ZP_TIME
      STA   ,X+
      LDA   <ZP_TIME+1
      STA   ,X+
      LDA   <ZP_TIME+2
      STA   ,X+
      LDA   <ZP_TIME+3
      STA   ,X+
      RTS

OSWORD_WRITESYSCLK
      LDA   ,X+
      STA   <ZP_TIME
      LDA   ,X+
      STA   <ZP_TIME+1
      LDA   ,X+
      STA   <ZP_TIME+2
      LDA   ,X+
      STA   <ZP_TIME+3

OSWORD_ENVELOPE
OSWORD_SOUND
      RTS

;; *************************************************************
;; OSBYTE
;; *************************************************************

NVBYTE
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
      LDX   #$7E00
      RTS
1
      LDX   #$0000
      RTS

NVWRCH
      PSHS  B,X
1
      LDB   <ZP_TX_TAIL    ; Is there space in the Tx buffer for one more character?
      INCB
      CMPB  <ZP_TX_HEAD
      BEQ   1B             ; No, then loop back and wait for characters to drain

      LDX   #TX_BUFFER     ; Write the character to the tail of the Tx buffer
      STA   B,X
      STB   <ZP_TX_TAIL    ; Save the updated tail pointer
      LDB   #$0B           ; Enable Tx interrupts to make sure buffer is serviced
      STB   UART_IMR
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
      ldx   10,S           ; points at byte after SWI instruction
   ENDIF
      stx   <ZP_ERRPTR
      jmp   [BRKV]         ; and JUMP via BRKV (normally into current language)

RESET_HANDLER              ; Entry point if there is no boot menu
      LDB   #1             ; Mini MOS assumed to be in ROM Block 1

BOOT_MENU_HANDLER          ; Entry point if there is a boot menu
      TFR   B, U           ; Boot menu passes ROM Block numver of Mini MOS in B register

DEFAULT_BRK_HANDLER        ; Entry point from a BRK error
      ;; Initialize the stack and direct page
      LDS   #$0200
      CLRA
      TFR   A,DP

      ;; Initialize Zero Page
      LDX   #ZP_START
1
      STA   ,X+
      CMPX  #ZP_END+1
      BNE   1B
      ;; Initialize the SWI Handler
      LDD   #DEFAULT_BRK_HANDLER
      STD   BRKV
      ;; Initialize the UART
      ;; RX INT ENABLED, RTS LOW, TX INT DISABLED, 8N1, CLK/16
      UART_INIT
      PSHS  X              ; Save the MMU message
      ;; Enter 6309 native mode
   IF NATIVE
      LDMD  #$01
   ENDIF
      ;; Enable interrupts
      CLI
      ;; Print the reset message
      LDX   #RESET_MSG
      JSR   PRSTRING
      ;; Print the MMU configuration
      PULS  X              ; Restore the MMU message
      JSR   PRSTRING
      ;; Enter Basic
      JMP   $8000

RESET_MSG
      FCB   $0D
   IF CPU_6309
      IF NATIVE
         FCC   "SBC6309N "
      ELSE
         FCC   "SBC6309E "
      ENDIF
   ELSE
      FCC   "SBC6809 "
   ENDIF
      FCC   SBC09VERSION
      FCB   $0A, $0D
   IF FLOW_CONTROL == FC_XON_XOFF
      FCB   $11             ; XON
   ENDIF
      FCB   $00

MMU_DISABLED_MSG
      FCB   "MMU Disabled",10,13,0

MMU_8K_MSG
      FCB   "MMU Enabled, 8KB block size",10,13,0

MMU_16K_MSG
      FCB   "MMU Enabled, 16KB block size",10,13,0

;; *************************************************************
;; Start of FUXIX Boot Loader
;; *************************************************************

FUZIX
      LDS   #$100

;;    We now build FUZIX to run at 115,200 baud
;;    LDA   #%10111011     ; INTERNAL 9,600 BAUD
;;    STA   UART_CSRA

      LDA   #%10000100     ; 0000-3FFF -> RAM block 4
      STA   MMU0 + 0
      TFR   U, A           ; C000-FFFF -> ROM0 block 1
      STA   MMU0 + 3

;; Enable the MMU with 16K block size
      LDA   #%00010000     ; OP4 = low (MMU Enabled, output is inverted)
      STA   UART_OPRSET

      ;; Fuzix Boot messsage

      LDX   #FUZIX_INIT_MSG
      JSR   SER_SEND_STRX

      ;; Copy FUZIX Kernel from ROM to RAM

      LDX   #FUZIX_COPY_MSG
      JSR   SER_SEND_STRX

      TFR   U, A
      ADDA  #FUZIX_IMG_OFFSET
      LDB   #FUZIX_RUN_BLK
FLOOP1
      STA   MMU0 + 1
      STB   MMU0 + 2
      PSHS  A
      LDX   #$4000         ; source block (ROM)
      LDY   #$8000         ; destination block (RAM)
FLOOP2
      LDA   ,X+
      STA   ,Y+
      CMPX  #$8000
      BNE   FLOOP2
      PULS  A
      INCA
      INCB
      CMPB  #FUZIX_RUN_BLK+4
      BNE   FLOOP1

      ;; copy "bounce" code at chipram 100 onwards (we expect 0..200 to be free)

      LDX   #FUZIX_BOOT_MSG
      JSR   SER_SEND_STRX

      ;; set up task 0 to have SYS at top (this code), ChipRAM at ram 0-BFFF and SYS screen memory C000-BFFF

      LDA   #FUZIX_RUN_BLK
      STA   MMU0 + 0
      LDA   #FUZIX_RUN_BLK+1
      STA   MMU0 + 1
      LDA   #FUZIX_RUN_BLK+2
      STA   MMU0 + 2

      ;; we should now be in map 0 with mmu enabled in 16K mode with this ROM (EXT) mapped at top
      ;; copy the bounce code to low memory at 100

      ;; copy user task to bank 0
      LDU   #UT0_R
      LDY   #$100
      LDX   #UT0_END-UT0+1
1
      LDA   ,U+
      STA   ,Y+
      LEAX  -1,X
      BNE   1B

      ;; jump to user task in bank 0
      JMP   $100

UT0_R
      ORG   $100
      PUT   UT0_R
UT0
      ;; this is the "bounce" task that is copied to

      ;; map in top page of RAM in supervisor task
      LDA   #FUZIX_RUN_BLK+3
      STA   MMU0 + 3

      ;; call the kernel
      JMP   $200
UT0_END
      ORG   UT0_R + UT0_END - UT0
      PUT   UT0_R + UT0_END - UT0

SER_SEND_STRX
      PSHS  A
1
      LDA   ,X+
      BEQ   2F
      BSR   SER_SEND_A
      BRA   1B
2
      PULS  A,PC


SER_SEND_A
      STB   ,-S
      LDB   #UART_TXINT
1
      BITB  UART_SRA
      BEQ   1B
      STA   UART_THRA
      PULS  B,PC

FUZIX_INIT_MSG
      FCB   "FUZIX BOOT ROM FOR SBC09",13,10,13,10,0

FUZIX_COPY_MSG
      FCB   "Copying Kernel Image from ROM to RAM",13,10,13,10,0

FUZIX_BOOT_MSG
      FCB   "Starting image at 00 0200",13,10,13,10,0

;; *************************************************************
;; End of FUZIX Boot Loader
;; *************************************************************


__CODE_END
__FREESPACE EQU $F7F0-__CODE_END

;; *************************************************************
;; Vectors
;; *************************************************************

      ORG   $F7F0

      FDB   ILL_HANDLER
      FDB   SWI3_HANDLER
      FDB   SWI2_HANDLER
      FDB   FIRQ_HANDLER
      FDB   IRQ_HANDLER
      FDB   SWI_HANDLER
      FDB   NMI_HANDLER
      FDB   RESET_HANDLER

;; *************************************************************
;; SBC09 Boot Menu Entry
;; *************************************************************

      ORG   $F800

      FDB   BOOT_MENU_HANDLER
      FCB   "SBC09MOS"
      FCC   "Mini-MOS "
      FCC   SBC09VERSION
      FCB   0

;; *************************************************************
;; MOS API
;; *************************************************************

      ORG   $FF00

OSINIT
      CLRA
      LDX   #BRKV
      LDY   #ZP_ESCFLAG
      RTS

      ORG   $FFCE

OSFIND
      RTS
      NOP
      NOP

OSGBPB
      RTS
      NOP
      NOP

OSBPUT
      RTS
      NOP
      NOP

OSBGET
      RTS
      NOP
      NOP

OSARGS
      RTS
      NOP
      NOP

OSFILE
OSFILE_LOAD
OSFILE_SAVE
      RTS
      NOP
      NOP

OSRDCH
      JMP   NVRDCH

OSASCI
      CMPA  #$0D
      BNE   OSWRCH

OSNEWL
      LDA   #$0A
      JSR   OSWRCH
      LDA   #$0D

OSWRCH
      JMP   NVWRCH

OSWORD
      JMP   NVWORD

OSBYTE
      JMP   NVBYTE

OSCLI
      RTS
      NOP
      NOP


      FCB $FF
      FCB $FF
      FCB $FF
      FCB $FF
      FCB $FF
      FCB $FF
