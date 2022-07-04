WIZBASE			EQU	$FC88
WIZ_MR			EQU	WIZBASE
WIZ_AR			EQU	WIZBASE+2
WIZ_DR			EQU	WIZBASE+4


WIZ_MR_RST		EQU	$80
WIZ_MR_MT		EQU	$20
WIZ_MR_IND		EQU	$01


							
WIZ_IR			EQU	$0002			; interrupt flags
WIZ_IMR			EQU	$0004			; interrupt mask
WIZ_SHAR		EQU	$0008			; local MAC address
WIZ_GAR			EQU	$0010			; Gateway IP
WIZ_SUBR		EQU	$0014			; Subnet mask
WIZ_SIPR		EQU	$0018			; local IP address
WIZ_RTR			EQU	$001C			; retrans timeout
WIZ_RCR			EQU	$001E			; retrans count

WIZ_TMS0R_b		EQU	$0020			; socket 0 Tx buffer size
WIZ_TMS1R_b		EQU	$0021			; socket 1 Tx buffer size
WIZ_TMS2R_b		EQU	$0022			; socket 2 Tx buffer size
WIZ_TMS3R_b		EQU	$0023			; socket 3 Tx buffer size
WIZ_TMS4R_b		EQU	$0024			; socket 4 Tx buffer size
WIZ_TMS5R_b		EQU	$0025			; socket 5 Tx buffer size
WIZ_TMS6R_b		EQU	$0026			; socket 6 Tx buffer size
WIZ_TMS7R_b		EQU	$0027			; socket 7 Tx buffer size

WIZ_RMS0R_b		EQU	$0028			; socket 0 Tx buffer size
WIZ_RMS1R_b		EQU	$0029			; socket 1 Tx buffer size
WIZ_RMS2R_b		EQU	$002A			; socket 2 Tx buffer size
WIZ_RMS3R_b		EQU	$002B			; socket 3 Tx buffer size
WIZ_RMS4R_b		EQU	$002C			; socket 4 Tx buffer size
WIZ_RMS5R_b		EQU	$002D			; socket 5 Tx buffer size
WIZ_RMS6R_b		EQU	$002E			; socket 6 Tx buffer size
WIZ_RMS7R_b		EQU	$002F			; socket 7 Tx buffer size

WIZ_MTYPER		EQU	$0030			; memory block type
WIZ_PATR		EQU	$0032			; PPPoE Authentication
WIZ_PTIMER_b		EQU	$0037			; PPP LCP Req Time
WIZ_PMAGICR_b		EQU	$0039			; PPP LCD Magic no
WIZ_PSIDR		EQU	$003C			; PPP Session ID
WIZ_PDHAR		EQU	$0040			; PPP Destination MAC
WIZ_UIPR		EQU	$0048			; Unreachable IP
WIZ_UPORTR		EQU	$004C			; Unreachable port
WIZ_FMTUR		EQU	$004E			; Fragment MTU

WIZ_Sn_MR		EQU	$0200			; Socket n Mode
WIZ_Sn_CR_b		EQU	$0203			; Socket n Command byte
WIZ_Sn_IMR_b		EQU	$0205			; Socket n Interrupt mask
WIZ_Sn_IR_b		EQU	$0207			; Socket n Interrupt flags
WIZ_Sn_SSR_b		EQU	$0209			; Socket n Status byte
WIZ_Sn_PORTR		EQU	$020A			; Socket n Source Port
WIZ_Sn_DHAR		EQU	$020C			; Socket n Dest hardware address
WIZ_Sn_DPORTR		EQU	$0212			; Socket n Dest port
WIZ_Sn_DIPR		EQU	$0214			; Socket n Dest IP
WIZ_Sn_MSSR		EQU	$0218			; Socket n Max seg size
WIZ_Sn_KPALVTR_b	EQU	$021A			; Socket n keep alive
WIZ_Sn_PROTOR_b		EQU	$021B			; Socket n Protocol no
WIZ_Sn_TOSR_b		EQU	$021D			; Socket n TOS
WIZ_Sn_TTLR_b		EQU	$021F			; Socket n TTL
WIZ_Sn_WRSR_24		EQU	$0221			; Socket n Tx Write Size
WIZ_Sn_FSR_24		EQU	$0225			; Socket n Tx Free Size
WIZ_Sn_RSR_24		EQU	$0229			; Socket n Rx Read Size
WIZ_Sn_FRAGR_b		EQU	$022D			; Socket n Fragment
WIZ_Sn_TX_FIFOR		EQU	$022E			; Socket n Tx FIFO
WIZ_Sn_RX_FIFOR		EQU	$0230			; Socket n Rx FIFO

WIZ_S0_MR		EQU	$00 + WIZ_Sn_MR		; Socket 0 Mode
WIZ_S0_CR_b		EQU	$00 + WIZ_Sn_CR_b	; Socket 0 Command byte
WIZ_S0_IMR_b		EQU	$00 + WIZ_Sn_IMR_b	; Socket 0 Interrupt mask
WIZ_S0_IR_b		EQU	$00 + WIZ_Sn_IR_b	; Socket 0 Interrupt flags
WIZ_S0_SSR_b		EQU	$00 + WIZ_Sn_SSR_b	; Socket 0 Status byte
WIZ_S0_PORTR		EQU	$00 + WIZ_Sn_PORTR	; Socket 0 Source Port
WIZ_S0_DHAR		EQU	$00 + WIZ_Sn_DHAR	; Socket 0 Dest hardware address
WIZ_S0_DPORTR		EQU	$00 + WIZ_Sn_DPORTR	; Socket 0 Dest port
WIZ_S0_DIPR		EQU	$00 + WIZ_Sn_DIPR	; Socket 0 Dest IP
WIZ_S0_MSSR		EQU	$00 + WIZ_Sn_MSSR	; Socket 0 Max seg size
WIZ_S0_KPALVTR_b	EQU	$00 + WIZ_Sn_KPALVTR_b	; Socket 0 keep alive
WIZ_S0_PROTOR_b		EQU	$00 + WIZ_Sn_PROTOR_b	; Socket 0 Protocol no
WIZ_S0_TOSR_b		EQU	$00 + WIZ_Sn_TOSR_b	; Socket 0 TOS
WIZ_S0_TTLR_b		EQU	$00 + WIZ_Sn_TTLR_b	; Socket 0 TTL
WIZ_S0_WRSR_24		EQU	$00 + WIZ_Sn_WRSR_24	; Socket 0 Tx Write Size
WIZ_S0_FSR_24		EQU	$00 + WIZ_Sn_FSR_24	; Socket 0 Tx Free Size
WIZ_S0_RSR_24		EQU	$00 + WIZ_Sn_RSR_24	; Socket 0 Rx Read Size
WIZ_S0_FRAGR_b		EQU	$00 + WIZ_Sn_FRAGR_b	; Socket 0 Fragment
WIZ_S0_TX_FIFOR		EQU	$00 + WIZ_Sn_TX_FIFOR	; Socket 0 Tx FIFO
WIZ_S0_RX_FIFOR		EQU	$00 + WIZ_Sn_RX_FIFOR	; Socket 0 Rx FIFO

WIZ_S1_MR		EQU	$40 + WIZ_Sn_MR		; Socket 1 Mode
WIZ_S1_CR_b		EQU	$40 + WIZ_Sn_CR_b	; Socket 1 Command byte
WIZ_S1_IMR_b		EQU	$40 + WIZ_Sn_IMR_b	; Socket 1 Interrupt mask
WIZ_S1_IR_b		EQU	$40 + WIZ_Sn_IR_b	; Socket 1 Interrupt flags
WIZ_S1_SSR_b		EQU	$40 + WIZ_Sn_SSR_b	; Socket 1 Status byte
WIZ_S1_PORTR		EQU	$40 + WIZ_Sn_PORTR	; Socket 1 Source Port
WIZ_S1_DHAR		EQU	$40 + WIZ_Sn_DHAR	; Socket 1 Dest hardware address
WIZ_S1_DPORTR		EQU	$40 + WIZ_Sn_DPORTR	; Socket 1 Dest port
WIZ_S1_DIPR		EQU	$40 + WIZ_Sn_DIPR	; Socket 1 Dest IP
WIZ_S1_MSSR		EQU	$40 + WIZ_Sn_MSSR	; Socket 1 Max seg size
WIZ_S1_KPALVTR_b	EQU	$40 + WIZ_Sn_KPALVTR_b	; Socket 1 keep alive
WIZ_S1_PROTOR_b		EQU	$40 + WIZ_Sn_PROTOR_b	; Socket 1 Protocol no
WIZ_S1_TOSR_b		EQU	$40 + WIZ_Sn_TOSR_b	; Socket 1 TOS
WIZ_S1_TTLR_b		EQU	$40 + WIZ_Sn_TTLR_b	; Socket 1 TTL
WIZ_S1_WRSR_24		EQU	$40 + WIZ_Sn_WRSR_24	; Socket 1 Tx Write Size
WIZ_S1_FSR_24		EQU	$40 + WIZ_Sn_FSR_24	; Socket 1 Tx Free Size
WIZ_S1_RSR_24		EQU	$40 + WIZ_Sn_RSR_24	; Socket 1 Rx Read Size
WIZ_S1_FRAGR_b		EQU	$40 + WIZ_Sn_FRAGR_b	; Socket 1 Fragment
WIZ_S1_TX_FIFOR		EQU	$40 + WIZ_Sn_TX_FIFOR	; Socket 1 Tx FIFO
WIZ_S1_RX_FIFOR		EQU	$40 + WIZ_Sn_RX_FIFOR	; Socket 1 Rx FIFO

WIZ_S2_MR		EQU	$80 + WIZ_Sn_MR		; Socket 2 Mode
WIZ_S2_CR_b		EQU	$80 + WIZ_Sn_CR_b	; Socket 2 Command byte
WIZ_S2_IMR_b		EQU	$80 + WIZ_Sn_IMR_b	; Socket 2 Interrupt mask
WIZ_S2_IR_b		EQU	$80 + WIZ_Sn_IR_b	; Socket 2 Interrupt flags
WIZ_S2_SSR_b		EQU	$80 + WIZ_Sn_SSR_b	; Socket 2 Status byte
WIZ_S2_PORTR		EQU	$80 + WIZ_Sn_PORTR	; Socket 2 Source Port
WIZ_S2_DHAR		EQU	$80 + WIZ_Sn_DHAR	; Socket 2 Dest hardware address
WIZ_S2_DPORTR		EQU	$80 + WIZ_Sn_DPORTR	; Socket 2 Dest port
WIZ_S2_DIPR		EQU	$80 + WIZ_Sn_DIPR	; Socket 2 Dest IP
WIZ_S2_MSSR		EQU	$80 + WIZ_Sn_MSSR	; Socket 2 Max seg size
WIZ_S2_KPALVTR_b	EQU	$80 + WIZ_Sn_KPALVTR_b	; Socket 2 keep alive
WIZ_S2_PROTOR_b		EQU	$80 + WIZ_Sn_PROTOR_b	; Socket 2 Protocol no
WIZ_S2_TOSR_b		EQU	$80 + WIZ_Sn_TOSR_b	; Socket 2 TOS
WIZ_S2_TTLR_b		EQU	$80 + WIZ_Sn_TTLR_b	; Socket 2 TTL
WIZ_S2_WRSR_24		EQU	$80 + WIZ_Sn_WRSR_24	; Socket 2 Tx Write Size
WIZ_S2_FSR_24		EQU	$80 + WIZ_Sn_FSR_24	; Socket 2 Tx Free Size
WIZ_S2_RSR_24		EQU	$80 + WIZ_Sn_RSR_24	; Socket 2 Rx Read Size
WIZ_S2_FRAGR_b		EQU	$80 + WIZ_Sn_FRAGR_b	; Socket 2 Fragment
WIZ_S2_TX_FIFOR		EQU	$80 + WIZ_Sn_TX_FIFOR	; Socket 2 Tx FIFO
WIZ_S2_RX_FIFOR		EQU	$80 + WIZ_Sn_RX_FIFOR	; Socket 2 Rx FIFO

WIZ_S3_MR		EQU	$C0 + WIZ_Sn_MR		; Socket 3 Mode
WIZ_S3_CR_b		EQU	$C0 + WIZ_Sn_CR_b	; Socket 3 Command byte
WIZ_S3_IMR_b		EQU	$C0 + WIZ_Sn_IMR_b	; Socket 3 Interrupt mask
WIZ_S3_IR_b		EQU	$C0 + WIZ_Sn_IR_b	; Socket 3 Interrupt flags
WIZ_S3_SSR_b		EQU	$C0 + WIZ_Sn_SSR_b	; Socket 3 Status byte
WIZ_S3_PORTR		EQU	$C0 + WIZ_Sn_PORTR	; Socket 3 Source Port
WIZ_S3_DHAR		EQU	$C0 + WIZ_Sn_DHAR	; Socket 3 Dest hardware address
WIZ_S3_DPORTR		EQU	$C0 + WIZ_Sn_DPORTR	; Socket 3 Dest port
WIZ_S3_DIPR		EQU	$C0 + WIZ_Sn_DIPR	; Socket 3 Dest IP
WIZ_S3_MSSR		EQU	$C0 + WIZ_Sn_MSSR	; Socket 3 Max seg size
WIZ_S3_KPALVTR_b	EQU	$C0 + WIZ_Sn_KPALVTR_b	; Socket 3 keep alive
WIZ_S3_PROTOR_b		EQU	$C0 + WIZ_Sn_PROTOR_b	; Socket 3 Protocol no
WIZ_S3_TOSR_b		EQU	$C0 + WIZ_Sn_TOSR_b	; Socket 3 TOS
WIZ_S3_TTLR_b		EQU	$C0 + WIZ_Sn_TTLR_b	; Socket 3 TTL
WIZ_S3_WRSR_24		EQU	$C0 + WIZ_Sn_WRSR_24	; Socket 3 Tx Write Size
WIZ_S3_FSR_24		EQU	$C0 + WIZ_Sn_FSR_24	; Socket 3 Tx Free Size
WIZ_S3_RSR_24		EQU	$C0 + WIZ_Sn_RSR_24	; Socket 3 Rx Read Size
WIZ_S3_FRAGR_b		EQU	$C0 + WIZ_Sn_FRAGR_b	; Socket 3 Fragment
WIZ_S3_TX_FIFOR		EQU	$C0 + WIZ_Sn_TX_FIFOR	; Socket 3 Tx FIFO
WIZ_S3_RX_FIFOR		EQU	$C0 + WIZ_Sn_RX_FIFOR	; Socket 3 Rx FIFO

WIZ_S4_MR		EQU	$100 + WIZ_Sn_MR	; Socket 4 Mode
WIZ_S4_CR_b		EQU	$100 + WIZ_Sn_CR_b	; Socket 4 Command byte
WIZ_S4_IMR_b		EQU	$100 + WIZ_Sn_IMR_b	; Socket 4 Interrupt mask
WIZ_S4_IR_b		EQU	$100 + WIZ_Sn_IR_b	; Socket 4 Interrupt flags
WIZ_S4_SSR_b		EQU	$100 + WIZ_Sn_SSR_b	; Socket 4 Status byte
WIZ_S4_PORTR		EQU	$100 + WIZ_Sn_PORTR	; Socket 4 Source Port
WIZ_S4_DHAR		EQU	$100 + WIZ_Sn_DHAR	; Socket 4 Dest hardware address
WIZ_S4_DPORTR		EQU	$100 + WIZ_Sn_DPORTR	; Socket 4 Dest port
WIZ_S4_DIPR		EQU	$100 + WIZ_Sn_DIPR	; Socket 4 Dest IP
WIZ_S4_MSSR		EQU	$100 + WIZ_Sn_MSSR	; Socket 4 Max seg size
WIZ_S4_KPALVTR_b	EQU	$100 + WIZ_Sn_KPALVTR_b	; Socket 4 keep alive
WIZ_S4_PROTOR_b		EQU	$100 + WIZ_Sn_PROTOR_b	; Socket 4 Protocol no
WIZ_S4_TOSR_b		EQU	$100 + WIZ_Sn_TOSR_b	; Socket 4 TOS
WIZ_S4_TTLR_b		EQU	$100 + WIZ_Sn_TTLR_b	; Socket 4 TTL
WIZ_S4_WRSR_24		EQU	$100 + WIZ_Sn_WRSR_24	; Socket 4 Tx Write Size
WIZ_S4_FSR_24		EQU	$100 + WIZ_Sn_FSR_24	; Socket 4 Tx Free Size
WIZ_S4_RSR_24		EQU	$100 + WIZ_Sn_RSR_24	; Socket 4 Rx Read Size
WIZ_S4_FRAGR_b		EQU	$100 + WIZ_Sn_FRAGR_b	; Socket 4 Fragment
WIZ_S4_TX_FIFOR		EQU	$100 + WIZ_Sn_TX_FIFOR	; Socket 4 Tx FIFO
WIZ_S4_RX_FIFOR		EQU	$100 + WIZ_Sn_RX_FIFOR	; Socket 4 Rx FIFO

WIZ_S5_MR		EQU	$140 + WIZ_Sn_MR	; Socket 5 Mode
WIZ_S5_CR_b		EQU	$140 + WIZ_Sn_CR_b	; Socket 5 Command byte
WIZ_S5_IMR_b		EQU	$140 + WIZ_Sn_IMR_b	; Socket 5 Interrupt mask
WIZ_S5_IR_b		EQU	$140 + WIZ_Sn_IR_b	; Socket 5 Interrupt flags
WIZ_S5_SSR_b		EQU	$140 + WIZ_Sn_SSR_b	; Socket 5 Status byte
WIZ_S5_PORTR		EQU	$140 + WIZ_Sn_PORTR	; Socket 5 Source Port
WIZ_S5_DHAR		EQU	$140 + WIZ_Sn_DHAR	; Socket 5 Dest hardware address
WIZ_S5_DPORTR		EQU	$140 + WIZ_Sn_DPORTR	; Socket 5 Dest port
WIZ_S5_DIPR		EQU	$140 + WIZ_Sn_DIPR	; Socket 5 Dest IP
WIZ_S5_MSSR		EQU	$140 + WIZ_Sn_MSSR	; Socket 5 Max seg size
WIZ_S5_KPALVTR_b	EQU	$140 + WIZ_Sn_KPALVTR_b	; Socket 5 keep alive
WIZ_S5_PROTOR_b		EQU	$140 + WIZ_Sn_PROTOR_b	; Socket 5 Protocol no
WIZ_S5_TOSR_b		EQU	$140 + WIZ_Sn_TOSR_b	; Socket 5 TOS
WIZ_S5_TTLR_b		EQU	$140 + WIZ_Sn_TTLR_b	; Socket 5 TTL
WIZ_S5_WRSR_24		EQU	$140 + WIZ_Sn_WRSR_24	; Socket 5 Tx Write Size
WIZ_S5_FSR_24		EQU	$140 + WIZ_Sn_FSR_24	; Socket 5 Tx Free Size
WIZ_S5_RSR_24		EQU	$140 + WIZ_Sn_RSR_24	; Socket 5 Rx Read Size
WIZ_S5_FRAGR_b		EQU	$140 + WIZ_Sn_FRAGR_b	; Socket 5 Fragment
WIZ_S5_TX_FIFOR		EQU	$140 + WIZ_Sn_TX_FIFOR	; Socket 5 Tx FIFO
WIZ_S5_RX_FIFOR		EQU	$140 + WIZ_Sn_RX_FIFOR	; Socket 5 Rx FIFO

WIZ_S6_MR		EQU	$180 + WIZ_Sn_MR	; Socket 6 Mode
WIZ_S6_CR_b		EQU	$180 + WIZ_Sn_CR_b	; Socket 6 Command byte
WIZ_S6_IMR_b		EQU	$180 + WIZ_Sn_IMR_b	; Socket 6 Interrupt mask
WIZ_S6_IR_b		EQU	$180 + WIZ_Sn_IR_b	; Socket 6 Interrupt flags
WIZ_S6_SSR_b		EQU	$180 + WIZ_Sn_SSR_b	; Socket 6 Status byte
WIZ_S6_PORTR		EQU	$180 + WIZ_Sn_PORTR	; Socket 6 Source Port
WIZ_S6_DHAR		EQU	$180 + WIZ_Sn_DHAR	; Socket 6 Dest hardware address
WIZ_S6_DPORTR		EQU	$180 + WIZ_Sn_DPORTR	; Socket 6 Dest port
WIZ_S6_DIPR		EQU	$180 + WIZ_Sn_DIPR	; Socket 6 Dest IP
WIZ_S6_MSSR		EQU	$180 + WIZ_Sn_MSSR	; Socket 6 Max seg size
WIZ_S6_KPALVTR_b	EQU	$180 + WIZ_Sn_KPALVTR_b	; Socket 6 keep alive
WIZ_S6_PROTOR_b		EQU	$180 + WIZ_Sn_PROTOR_b	; Socket 6 Protocol no
WIZ_S6_TOSR_b		EQU	$180 + WIZ_Sn_TOSR_b	; Socket 6 TOS
WIZ_S6_TTLR_b		EQU	$180 + WIZ_Sn_TTLR_b	; Socket 6 TTL
WIZ_S6_WRSR_24		EQU	$180 + WIZ_Sn_WRSR_24	; Socket 6 Tx Write Size
WIZ_S6_FSR_24		EQU	$180 + WIZ_Sn_FSR_24	; Socket 6 Tx Free Size
WIZ_S6_RSR_24		EQU	$180 + WIZ_Sn_RSR_24	; Socket 6 Rx Read Size
WIZ_S6_FRAGR_b		EQU	$180 + WIZ_Sn_FRAGR_b	; Socket 6 Fragment
WIZ_S6_TX_FIFOR		EQU	$180 + WIZ_Sn_TX_FIFOR	; Socket 6 Tx FIFO
WIZ_S6_RX_FIFOR		EQU	$180 + WIZ_Sn_RX_FIFOR	; Socket 6 Rx FIFO

WIZ_S7_MR		EQU	$1C0 + WIZ_Sn_MR	; Socket 7 Mode
WIZ_S7_CR_b		EQU	$1C0 + WIZ_Sn_CR_b	; Socket 7 Command byte
WIZ_S7_IMR_b		EQU	$1C0 + WIZ_Sn_IMR_b	; Socket 7 Interrupt mask
WIZ_S7_IR_b		EQU	$1C0 + WIZ_Sn_IR_b	; Socket 7 Interrupt flags
WIZ_S7_SSR_b		EQU	$1C0 + WIZ_Sn_SSR_b	; Socket 7 Status byte
WIZ_S7_PORTR		EQU	$1C0 + WIZ_Sn_PORTR	; Socket 7 Source Port
WIZ_S7_DHAR		EQU	$1C0 + WIZ_Sn_DHAR	; Socket 7 Dest hardware address
WIZ_S7_DPORTR		EQU	$1C0 + WIZ_Sn_DPORTR	; Socket 7 Dest port
WIZ_S7_DIPR		EQU	$1C0 + WIZ_Sn_DIPR	; Socket 7 Dest IP
WIZ_S7_MSSR		EQU	$1C0 + WIZ_Sn_MSSR	; Socket 7 Max seg size
WIZ_S7_KPALVTR_b	EQU	$1C0 + WIZ_Sn_KPALVTR_b	; Socket 7 keep alive
WIZ_S7_PROTOR_b		EQU	$1C0 + WIZ_Sn_PROTOR_b	; Socket 7 Protocol no
WIZ_S7_TOSR_b		EQU	$1C0 + WIZ_Sn_TOSR_b	; Socket 7 TOS
WIZ_S7_TTLR_b		EQU	$1C0 + WIZ_Sn_TTLR_b	; Socket 7 TTL
WIZ_S7_WRSR_24		EQU	$1C0 + WIZ_Sn_WRSR_24	; Socket 7 Tx Write Size
WIZ_S7_FSR_24		EQU	$1C0 + WIZ_Sn_FSR_24	; Socket 7 Tx Free Size
WIZ_S7_RSR_24		EQU	$1C0 + WIZ_Sn_RSR_24	; Socket 7 Rx Read Size
WIZ_S7_FRAGR_b		EQU	$1C0 + WIZ_Sn_FRAGR_b	; Socket 7 Fragment
WIZ_S7_TX_FIFOR		EQU	$1C0 + WIZ_Sn_TX_FIFOR	; Socket 7 Tx FIFO
WIZ_S7_RX_FIFOR		EQU	$1C0 + WIZ_Sn_RX_FIFOR	; Socket 7 Rx FIFO


; Socket interrupt flags
WIZ_Sn_IR_RECV		EQU	$04

; Socket SSR statuses
WIZ_SOCK_CLOSED		EQU	$00
WIZ_SOCK_INIT		EQU	$13
WIZ_SOCK_LISTEN		EQU	$14
WIZ_SOCK_ESTABLISHED	EQU	$17
WIZ_SOCK_CLOSE_WAIT	EQU	$1C
WIZ_SOCK_UDP		EQU	$22
WIZ_SOCK_IPRAW		EQU	$32
WIZ_SOCK_MACRAW		EQU	$42
WIZ_SOCK_PPPoE		EQU	$5F
WIZ_SOCK_SYNSENT	EQU	$15
WIZ_SOCK_SYNRECV	EQU	$16
WIZ_SOCK_FIN_WAIT	EQU	$18
WIZ_SOCK_TIME_WAIT	EQU	$1B
WIZ_SOCK_LAST_ACK	EQU	$1D
WIZ_SOCK_ARP		EQU	$01

; Socket master register values
WIZ_Sn_MR_ALIGN		EQU	$100
WIZ_Sn_MR_MULTI		EQU	$80
WIZ_Sn_MR_MF		EQU	$40
WIZ_Sn_MR_ND		EQU	$20
WIZ_Sn_MR_CLOSE		EQU	$00
WIZ_Sn_MR_TCP		EQU	$01
WIZ_Sn_MR_UDP		EQU	$02
WIZ_Sn_MR_IPRAW		EQU	$03
WIZ_Sn_MR_MACRAW	EQU	$04
WIZ_Sn_MR_PPPoE		EQU	$05

; Socket command register values
WIZ_CR_OPEN		EQU	$01
WIZ_CR_LISTEN		EQU	$02
WIZ_CR_CONNECT		EQU	$04
WIZ_CR_DISCON		EQU	$08
WIZ_CR_CLOSE		EQU	$10
WIZ_CR_SEND		EQU	$20
WIZ_CR_SEND_MAC		EQU	$21
WIZ_CR_SEND_KEEP	EQU	$22
WIZ_CR_RECV		EQU	$40

