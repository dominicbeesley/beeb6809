;; *************************************************************
;; Configuration
;; *************************************************************

FC_NONE      EQU 0
FC_XON_XOFF  EQU 1
FC_RTS_CTS   EQU 2

FLOW_CONTROL EQU FC_RTS_CTS

;; Threshold at which RTS is asserted
FC_LO_THRESH EQU $80

;; Threshold at which RTS is de-asserted
FC_HI_THRESH EQU $C0

UART_XTAL       EQU     3686400
UART_T0DIV      EQU     (((UART_XTAL/16)/100)/2)-1

SBC09_INIT MACRO
                ; B contains the current 16K bank # from BOOT menu

                lda     #MR1_PARITY_MODE_OFF|MR1_PARITY_BITS_8    ; no parity, 8 bits/char - mr1a,b
                sta     SBC09_UART_MRA
                lda     #MR2_TxCTS|MR2_STOP_BITS_1                ; cts enable tx, 1.000 stop bits - mr2a,b
                sta     SBC09_UART_MRA
                lda     #CRA_TxEN|CRA_RxEN                        ; enable tx and rx
                sta     SBC09_UART_CRA
                lda     #CRA_CMD_SET_RxBRG                        ; set channel a rx extend bit
                sta     SBC09_UART_CRA
                lda     #CRA_CMD_SET_TxBRG                        ; set channel a tx extend bit
                sta     SBC09_UART_CRA
                lda     #%10001000                                ; internal 115,200 baud
                sta     SBC09_UART_CSRA
                lda     #ACR_CT_MODE_SQ_X1_DIV16                  ; timer mode, clock = xtal/16 = 3686400 / 16 = 230400 hz
                sta     SBC09_UART_ACR
                lda     #UART_T0DIV/256                           ; 16-bit write to counter to get a 100hz tick
                sta     SBC09_UART_CTU
                lda     #UART_T0DIV%256                           ; 16-bit write to counter to get a 100hz tick
                sta     SBC09_UART_CTU+1
                lda     #OP_BIT_RTS_A                             ; assert rts
                sta     SBC09_UART_OPRSET
;;                lda     #IMR_CTR|IMR_RxRDY_A                    ; timer int, rx int enabled; tx int disabled
                lda     #IMR_CTR                                  ; timer int, rx int enabled; tx int disabled
                sta     SBC09_UART_IMR
                lda     SBC09_UART_STARTCT                        ; start the counter-timer
;;      LDA  #%00000100
;;      STA  UART_OPCR     ; Ouput timer squarewave on OP3 for debugging only
;;              lda     SBC09_UART_IPR                            ; read jumpers
;;              bita    #IP_BITS_JP1                              ; test jumper jp1 (enable mmu)
;;              bne     done                                      ; jp1 not fitted, so don't initialiaze mmu
;;              bita    #jp2          ; test jumper jp2 (8k mode)
;;              beq     mmu_8k         ; jp3 fitted, so use 8k mode

; For now always 16K, MMU enabled
;TODO: SBC09: look at 8K mode option

      ;; On reset the MMU is disabled, with block size set to 16K

MMU_16K
                lda     #%10000000                                ; 0000-3fff -> ram block 0
                sta     SBC09_MMU0 + 0
                lda     #%10000001                                ; 4000-7fff -> ram block 1
                sta     SBC09_MMU0 + 1

                
                stb     SBC09_MMU0 + 3
                decb
                stb     SBC09_MMU0 + 2

      ;; Enable the MMU with 16K block size
                lda     #%00010000     ; op4 = low (mmu enabled, output is inverted)
                sta     SBC09_UART_OPRSET
;;              bra     done

;;MMU_8K
;;              lda     #%10000000                                ; 0000-1fff -> ram block 0
;;              sta     SBC09_MMU0 + 0
;;              lda     #%10000001                                ; 2000-3fff -> ram block 1
;;              sta     mmu1 + 0
;;              lda     #%10000010                                ; 4000-5fff -> ram block 2
;;              sta     SBC09_MMU0 + 1
;;              lda     #%10000011                                ; 6000-7fff -> ram block 3
;;              sta     mmu1 + 1
;;              lda     #%00000000                                ; 8000-9fff -> rom0 block 0
;;              sta     SBC09_MMU0 + 2
;;              lda     #%00100000                                ; a000-bfff -> rom0 block 1
;;              sta     mmu1 + 2
;;              lda     #%00000001                                ; c000-dfff -> rom0 block 2
;;              sta     SBC09_MMU0 + 3
;;              lda     #%00100001                                ; e000-ffff -> rom0 block 3
;;              sta     mmu1 + 3
;;
;;      ;; Enable the MMU with 8K block size
;;              lda     #%00011000     ; op4 = low (mmu enabled, output is inverted)
;;              sta     SBC09_UART_OPRSET    ; op3 = low (8k block size, output is inverted)
done            endm

; TODO: SBC09 : Properly buffer Rx/Tx
;;; ;; *************************************************************
;;; ;; Main IRQ Handler
;;; ;; *************************************************************
;;; 
;;; IRQ_RX
;;;                 lda     uart_rhra       ; read uart rx data (and clear interrupt)
;;;                 cmpa    #$1b            ; test for escape
;;;                 bne     irq_noesc
;;;                 ldb     #$80            ; set the escape flag
;;;                 stb     <zp_escflag
;;; 
;;; IRQ_NOESC
;;;                 ldb     <zp_rx_tail     ; b = keyboard buffer tail index
;;;                 ldx     #rx_buffer      ; x = keyboard buffer base address
;;;                 sta     b,x             ; store the character in the buffer
;;;                 incb    ; increment the tail pointer
;;;                 cmpb    <zp_rx_head     ; has it hit the head (buffer full?)
;;;                 beq     irq_handler     ; yes, then drop characters
;;;                 stb     <zp_rx_tail     ; no, then save the incremented tail pointer
;;; 
;;;    ;; Simple implementation of RTS/CTS to prevent receive buffer overflow
;;;    IF FLOW_CONTROL == FC_RTS_CTS
;;;                 subb    <zp_rx_head     ; tail - head gives the receive buffer occupancy
;;;                 cmpb    #fc_hi_thresh   ; compare with upper threshold
;;;                 bne     irq_handler
;;;                 ldb     #$01
;;;                 stb     uart_oprclr     ; de-assert rts
;;;    ENDIF
;;; 
;;; IRQ_HANDLER
;;;                 lda     uart_sra        ; read uart status register
;;;                 bita    #uart_rxint     ; test bit 0 (rxrdy)
;;;                 bne     irq_rx          ; ready, branch back handle the character
;;;                 bita    #uart_txint     ; test bit 2 (txrdy)
;;;                 beq     irq_timer       ; not ready, branch forward to the timer check
;;; 
;;;    ;; Simple implementation of XON/XOFF to prevent receive buffer overflow
;;;    IF FLOW_CONTROL == FC_XON_XOFF
;;;                 ldb     <zp_rx_tail    ; determine if we need to send xon or xoff
;;;                 subb    <zp_rx_head    ; tail - head gives the receive buffer occupancy
;;;                 eorb    <zp_xoff       ; in xoff state, complement to give some hysterisis
;;;                 cmpb    #$c0           ; c=0 if occupancy >=75% (when in xon) or <25% (when in xoff)
;;;                 bcs     irq_tx_char    ; nothing to do...
;;;                 lda     #$11           ; 0x11 = xon character
;;;                 com     <zp_xoff       ; toggle the xon/xoff state
;;;                 beq     send_a         ; send xon
;;;                 lda     #$13           ; 0x13 = xoff character
;;;                 bra     send_a         ; send xoff
;;;    ENDIF
;;; 
;;; IRQ_TX_CHAR
;;;                 ldb     <zp_tx_head     ; is the tx buffer empty?
;;;                 cmpb    <zp_tx_tail
;;;                 beq     irq_tx_empty    ; yes, then disable tx interrupts and exit
;;;                 ldx     #tx_buffer      ; no, then write the next character
;;;                 incb    
;;;                 stb     <zp_tx_head
;;;                 lda     b,x
;;; SEND_A
;;;                 sta     uart_thra
;;; 
;;; IRQ_TIMER
;;;                 lda     uart_isr        ; read uart interrupt status register
;;;                 anda    #$08            ; check the timer bit
;;;                 beq     irq_exit
;;;                 lda     uart_stopct     ; clear the interrupt
;;;                 inc     <zp_time        ; update the system clock
;;;                 bne     irq_exit
;;;                 inc     <zp_time+1
;;;                 bne     irq_exit
;;;                 inc     <zp_time+2
;;;                 bne     irq_exit
;;;                 inc     <zp_time+3
;;; 
;;; IRQ_EXIT
;;;                 rti     
;;; 
;;; IRQ_TX_EMPTY
;;;                 lda     #$0a          ; disable tx interrupts
;;;                 sta     SBC09_UART_IMR
;;;                 bra     irq_timer
;;; 
;;;                 rti     
;;; NVRDCH
;;; 
;;;                 pshs    b,x
;;; 1     LDB   <ZP_RX_HEAD
;;;                 cmpb    <zp_rx_tail
;;;                 beq     1b
;;;                 ldx     #rx_buffer
;;;                 lda     b,x
;;;                 inc     <zp_rx_head
;;;    IF FLOW_CONTROL == FC_RTS_CTS
;;;                 ldb     <zp_rx_tail    ; determine whethe rts needs to be raised
;;;                 subb    <zp_rx_head    ; tail - head gives the receive buffer occupancy
;;;                 cmpb    #fc_lo_thresh
;;;                 bne     1f
;;;                 ldb     #$01
;;;                 stb     SBC09_UART_OPRSET     ; assert rts
;;; 1
;;;    ENDIF
;;;                 ldb     <zp_escflag
;;;                 rolb    puls  b,x
;;;                 rts     