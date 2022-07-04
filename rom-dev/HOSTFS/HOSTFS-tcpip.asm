VERSION_NAME	MACRO
		FCB	"HOSTFS-tcpip"
		ENDM

TCPIP				EQU	1

KEY_SEL_AT_BREAK		EQU	$10		; 'Q'



		include	"./HOSTFS-core.asm"

		include "./includes/hw_wiz5300.inc"


SpCmdXferFixed
* Decide what local memory to transfer data to/from
* -------------------------------------------------
* A=$Ex/$Fx - Load/Save
*

		jsr	WaitStart

		anda	#$F0			; A=transfer flag with b7=1 for IO transfer
		pshs	A

	; get XFER len
		lbsr	WaitData
		tfr	A,B
		lbsr	WaitData
		exg	A,B
		tfr	D,X


	IF SWROM
		tst	sysvar_TUBE_PRESENT
		bpl	SpCmdXferFixedIO		; No Tube
		ldb	ZP_ADDR_TRANS+0			; Check transfer address
		incb
		bne	SpCmdXferFixedTube		; Tube present, ADDR<$FFxxxxxx
	ENDIF
SpCmdXferFixedIO
;; 	IF SWROM
;; 	; TODO - confer with JGH, this is too wasteful of address space...
;; 		pshs	A
;; 		ldx	ZP_ADDR_TRANS+1
;; 		inx
;; 		beq	WaitIOGo			; $FFFFxxxx - current IO memory
;; 		lda	$D0
;; 		inx
;; 		beq	WaitIOScreen			; $FFFExxxx - current display memory
;; 		inx
;; 		bne	WaitIOGo
;; 		lda	#16				; $FFFDxxxx - shadow screen memory
;; WaitIOScreen
;; 		and	#16
;; 		beq	WaitIOGo			; Non-shadow screen displayed, jump with Y=$E0/$F0
;; 		iny
;; 		bsr	vramSelect			; Page in video RAM, Y is now $E1/$F1
;; WaitIOGo
;; 		tya
;; 	ENDIF
		lda	,S				; get back read / write E0/F0
		ldy	ZP_ADDR_TRANS+2			; Stack IO/Screen flag, init Y=transfer address (16 bit)
		cmpa	#$F0
		bhs	SpCmdXferFixedSaveIO		; HOSTFS_ESC,$Fx - save data

* Load data from remote host
* --------------------------
SpCmdXferFixedLoadIO
;1		lbsr	WaitData			; this will terminate itself?
;		sta	,Y+				; HOSTFS_ESC,$Ex - load data
;		leax	-1,X
;		bne	1B
		jsr	wiz_read_block
		lbra	WaitSaveExit		; Loop until terminated by HOSTFS_ESC,$Bx

* Save data to remote host
* ------------------------
SpCmdXferFixedSaveIO
		BEGINTRANS
1		lda	,Y+
		lbsr	SendData			; HOSTFS_ESC,$Fx - save data
		leax	-1,X
		bne	1B				; Loop until terminated by HOSTFS_ESC,$Bx
		ENDTRANS
		lbra	WaitSaveExit

* Tube and ADDR<$FFxxxxxx	TODO: this needs timing sorting for >2Mhz etc
* -----------------------
* A=$Ex/$Fx - Load/Save
	IF SWROM
SpCmdXferFixedTube
		puls	A
		adda	#$10
		rola					; Cy=1/0 for load/save
		clra
		rola
		pshs	A				; A=1/0 for load/save
		lbsr	TubeAction			; Claim Tube and start transfer
		lda	,S
		beq	SpCmdXferFixedSaveTube		; Leave flag pushed with b7=0 for Tube transfer
SpCmdXferFixedLoadTube
		lbsr	TubeDelay			; note MUST be an _L_ong BSR for timing
		lbsr	WaitData
		sta	sheila_TUBE_R3_DATA		; Fetch byte and send to Tube
		leax	-1,X
		bne	SpCmdXferFixedLoadTube		; Loop until terminated by HOSTFS_ESC,$Bx
		lbra	WaitSaveExit
SpCmdXferFixedSaveTube
		BEGINTRANS
1		lda	sheila_TUBE_R3_DATA
		lbsr	SendData			; Fetch byte from Tube and send it
		lbsr	TubeDelay			; note MUST be an _L_ong BSR for timing
		leax	-1,X
		bne	1B				; Loop until terminated by HOSTFS_ESC,$Bx
		ENDTRANS
		lbra	WaitSaveExit
	ENDIF




;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; TCPIP
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


;order matters, written as block:
SERV_PORT		FDB	7777
SERV_ADDR		FCB	192,168,5,100
SERV_ADDR_LEN		EQU	6

;order matters, written as block:

WIZ_LCL_SHAR		FCB	$DE, $AD, $BE, $EF, $0D, $0B

WIZ_LCL_GW		FCB	192,168,1,254
WIZ_LCL_SN		FCB	255,255,0,0
WIZ_LCL_IP		FCB	192,168,5,123


WIZ_PORT_EPHEM_BASE	FDB	$C000			; ephemeral local port number

; read/write regs macros - note for odd numbered bytes
; the address is adjusted to be even and the LSB read instead

WZWR16I		MACRO
		pshs	D
		ldd	#\1
		std	WIZ_AR
		ldd	#\2	
		std	WIZ_DR
		puls	D
		ENDM
WZWR16D		MACRO
		pshs	D
		ldd	#\1
		std	WIZ_AR
		puls	D
		std	WIZ_DR
		ENDM
WZWR8		MACRO
		pshs	D
		ldd	#\1 & $FFFE
		std	WIZ_AR
		lda	#\2	
	IF \1 & 0x0001
		sta	WIZ_DR+1
	ELSE
		sta	WIZ_DR
	ENDIF
		puls	D
		ENDM
WZRD16		MACRO
		ldd	#\1
		std	WIZ_AR
		ldd	WIZ_DR
		ENDM
WZRD8		MACRO
		pshs	B
		ldd	#\1 & $FFFE
		std	WIZ_AR
	IF \1 & 0x0001
		lda	WIZ_DR+1
	ELSE
		lda	WIZ_DR
	ENDIF
		puls	B
		ENDM



wiz_init
		; TODO: Check for presence of hardware

		pshs	D,X
		ldd	#WIZ_MR_RST
		std	WIZ_MR+1			; reset 
		jsr	wiz_wait10ms
		jsr	wiz_wait10ms
		jsr	wiz_wait10ms
		jsr	wiz_wait10ms
		jsr	wiz_wait10ms
		jsr	wiz_wait10ms
		jsr	wiz_wait10ms
		jsr	wiz_wait10ms
		jsr	wiz_wait10ms
		jsr	wiz_wait10ms
		lda	#WIZ_MR_IND			; indirect
		sta	WIZ_MR+1		
		; set mac address, local ip, gw, subnet TODO: make configurable
		ldx	#WIZ_SHAR
		ldb	#6
		ldu	#WIZ_LCL_SHAR
		jsr	wiz_write_block

		ldx	#WIZ_GAR
		ldb	#12
		ldu	#WIZ_LCL_GW
		jsr	wiz_write_block


		WZWR8	WIZ_S7_CR_b, WIZ_CR_CLOSE
1		WZRD8	WIZ_S7_SSR_b
		cmpa	#WIZ_SOCK_CLOSED
		bne	1B	

		; mark no data waiting
		clr	ZP_TCPIP_RDBUF_FULL
		clr	ZP_TCPIP_WRBUF_FULL
		clr	ZP_TCPIP_RSR
		clr	ZP_TCPIP_RSR+1

		puls	D,X,PC


; check or connect socket 3
;TODO: allocate a socket nicely
wiz_checkopen
		pshs	D,X,U
		WZRD8	WIZ_S7_SSR_b
		; TODO: check more stuff here - for now if its not ESTABLISHED then 
		; just kill it and start again
		cmpa	#WIZ_SOCK_ESTABLISHED
		bne	wiz_checkopen_do_open
wiz_checkopen_opened
		puls	D,X,U,PC
wiz_checkopen_do_open
		WZWR16I	WIZ_S7_MR, WIZ_Sn_MR_TCP+WIZ_Sn_MR_MF+WIZ_Sn_MR_ND	; not packet separators and filtered MAC
		WZWR8	WIZ_S7_CR_b, WIZ_CR_OPEN
		; wait for open status
		ldx	#WIZ_S7_SSR_b
		stx	WIZ_AR
1		lda	WIZ_DR+1
		cmpa	#WIZ_SOCK_INIT			; wait for SOCK_INIT
		bne	1B

		clra
		ldb	oswksp_TIME+4			; TODO: THIS IS NOT sensible, could easily repeat!
		addd	WIZ_PORT_EPHEM_BASE
							; source port = add TIME MOD 256 to base for port no
		ldx	#WIZ_S7_PORTR
		jsr	wiz_write16

		; set up dest ip, port
		ldx	#WIZ_S7_DPORTR
		ldb	#SERV_ADDR_LEN
		ldu	#SERV_PORT
		jsr	wiz_write_block

		WZWR8	WIZ_S7_IR_b, $FF		; clear interrupt register
		WZWR8	WIZ_S7_CR_b, WIZ_CR_CONNECT

		WZWR16I	WIZ_RTR, 1000

;		ldx	#0
;		ldb	#$32
;		jsr	wiz_dump_regs

;		ldx	#WIZ_S7_MR
;		ldb	#$30
;		jsr	wiz_dump_regs

		; reset all interrupt regs
		WZWR8	WIZ_S7_IR_b, $FF

		; mark no data waiting
		clr	ZP_TCPIP_RDBUF_FULL
		clr	ZP_TCPIP_WRBUF_FULL
		clr	ZP_TCPIP_RSR
		clr	ZP_TCPIP_RSR+1

		; wait for either status = CLOSED or ESTABLISH
wiz_checkopen_open_loop
		WZRD8	WIZ_S7_SSR_b
		cmpa	#WIZ_SOCK_ESTABLISHED
		lbeq	wiz_checkopen_opened		
		cmpa	#WIZ_SOCK_CLOSED
		bne	wiz_checkopen_open_loop
wiz_err_socket_closed
		M_ERROR
		FCB	$C0
		FCB	"Socket Closed", 0

	; write block at U, len=B to regs at X, trashses A, updates U
	; this must be even aligned!
wiz_write_block
		pshs	X				; TODO - drop this?
1		stx	WIZ_AR				; point at start of block
		lda	,U+
		sta	WIZ_DR
		lda	,U+
		sta	WIZ_DR+1
		leax	2,X
		decb
		beq	1F
		decb
		bne	1B
1		puls	X,PC

wiz_write16	pshs	X
		stx	WIZ_AR
		std	WIZ_DR
		puls	X,PC

wiz_read16	pshs	X
		stx	WIZ_AR
		ldd	WIZ_DR				;
		puls	X,PC


; read a HOSTFS escaped byte 
; returns byte in A with Cy=0 or preserves registers with Cy=1 if no data ready (A corrputed)
wiz_read_byte_s7
		pshs	D,X
		tst	ZP_TCPIP_RDBUF_FULL
		beq	wiz_read_byte_s7_nobuf
		clr	ZP_TCPIP_RDBUF_FULL
		lda	ZP_TCPIP_RDBUF
		sta	0,S
wiz_read_byte_s7_gotit	
		lda	0,S	
		cmpa	#HOSTFS_ESC
		SEC
		puls	D,X,PC

wiz_read_byte_s7_nobuf

		ldd	ZP_TCPIP_RSR
		bne	wiz_read_byte_s7_got_sommat

		jsr	wiz_check_packet_received
		beq	wiz_read_byte_s7_empty


		; got a packet

		WZRD16	WIZ_S7_RX_FIFOR			; get "packet length" from data stream eugh!
		std	ZP_TCPIP_RSR
		cmpd	#0
		beq	wiz_read_byte_s7_empty
wiz_read_byte_s7_got_sommat
		cmpd	#1
		beq	wiz_read_byte_s7_odd
		; two or more byte waiting
		WZRD16	WIZ_S7_RX_FIFOR
		stb	ZP_TCPIP_RDBUF			; buffer next unwanted byte
		inc	ZP_TCPIP_RDBUF_FULL
		sta	0,S				; return A

		ldd	ZP_TCPIP_RSR
		subd	#2
		std	ZP_TCPIP_RSR
		beq	wiz_read_byte_s7_RECV
		bcs	wiz_read_byte_s7_RECV
		bra	wiz_read_byte_s7_gotit
wiz_read_byte_s7_odd
		WZRD16 WIZ_S7_RX_FIFOR			; get 2 bytes but ignore 2nd - I don't trust this!
		sta	0,S				; return 
		; last byte drop through to send recv
		; we need to send a RECV now
wiz_read_byte_s7_RECV
		clr	ZP_TCPIP_RSR
		clr	ZP_TCPIP_RSR+1		
		jsr	wiz_read_recv
		lbra	wiz_read_byte_s7_gotit

wiz_read_byte_s7_empty
		CLC
		puls	D,X,PC


wiz_read_recv
		WZWR8	WIZ_S7_CR_b, WIZ_CR_RECV
1		WZRD8	WIZ_S7_CR_b
		bne	1B

;		WZRD16	WIZ_S7_FSR_24+1
;		pshs	D
;
;		WZWR16I	WIZ_S7_WRSR_24+1, 0
;		WZWR8	WIZ_S7_CR_b, WIZ_CR_SEND
;
;1		WZRD8	WIZ_S7_CR_b
;		bne	1B
;
;		puls	D
;		WZWR16D	WIZ_S7_FSR_24+1

		rts

wiz_check_packet_received
		jsr	wiz_checkopen
		WZRD8	WIZ_S7_SSR_b
		cmpa	#WIZ_SOCK_ESTABLISHED
		lbne	wiz_err_socket_closed

;		WZRD8	WIZ_S7_IR_b
;		anda	#WIZ_Sn_IR_RECV
		WZRD16	WIZ_S7_RSR_24+1
		cmpd	#0
		rts




wiz_send_byte_s7
		tst	ZP_TCPIP_WRBUF_FULL
		bne	1F
		sta	ZP_TCPIP_WRBUF
		inc	ZP_TCPIP_WRBUF_FULL
		rts

1		pshs	CC,D
1		jsr	wiz_checkopen

		WZRD16	WIZ_S7_FSR_24+1
		cmpd	#0
		beq	1B

		; there's a pending byte

		lda	ZP_TCPIP_WRBUF			; get buffered byte and send as a two byte paket
		ldb	1,S
		WZWR16D WIZ_S7_TX_FIFOR			; always write 2 bytes!
		WZWR16I WIZ_S7_WRSR_24+1, 2		; write write size


wiz_send_send
		WZWR8	WIZ_S7_CR_b, WIZ_CR_SEND
1		WZRD8	WIZ_S7_CR_b
		bne	1B

		clr	ZP_TCPIP_WRBUF_FULL

wiz_send_exit
		puls	CC,D,PC



wiz_begin_trans	rts
wiz_end_trans	
		pshs	CC,D
		tst	ZP_TCPIP_WRBUF_FULL
		beq	wiz_send_exit

		lda	ZP_TCPIP_WRBUF
		WZWR16D WIZ_S7_TX_FIFOR			; always write 2 bytes!
		WZWR16I WIZ_S7_WRSR_24+1, 1		; write write size

		bra	wiz_send_send


wiz_dump_regs
		pshs	B
		tfr	X,D
		andb	#$FE
		tfr	D,X
		puls	B

2		jsr	OSNEWL
		pshs	B
		jsr	PR2HEX
		puls	B
		lda	#' '
		jsr	OSWRCH
		lda	#':'
		jsr	OSWRCH
1		lda	#' '
		jsr	OSWRCH
		stx	WIZ_AR
		lda	WIZ_DR
		jsr	PRHEX
		lda	WIZ_DR+1
		jsr	PRHEX
		decb
		beq	3F
		decb
		beq	3F
		leax	2,X
		pshs	D
		tfr	X,D
		andb	#$0F
		puls	D
		beq	2B
		bra	1B
3		jsr	OSNEWL
		rts

LEDON		pshs	A
		lda	#7
		sta	$FE40
		puls	A,PC
LEDOFF		pshs	A
		lda	#$F
		sta	$FE40
		puls	A,PC

		; read X bytes at to mem at Y
		; preserves U,D
		; returns with Y updated, X=0
		; sends mulltiple '0' ack bytes and terminates with a $80
wiz_read_block	pshs	D
		cmpx	#0
		bne	wiz_read_block_zero_len
wiz_read_block_exit
;;		lda	#$80
;;		jsr	wiz_send_byte_s7
		puls	D,PC
wiz_read_block_zero_len
		tst	ZP_TCPIP_RDBUF_FULL		; check for buffered byte
		beq	wiz_read_block_nobuf
		lda	ZP_TCPIP_RDBUF
		sta	,Y+
		clr	ZP_TCPIP_RDBUF_FULL
		leax	-1,X
		beq	wiz_read_block_exit		
wiz_read_block_nobuf		
		ldd	ZP_TCPIP_RSR
		bne	wiz_read_from_socket
		jsr	LEDON
1		jsr	wiz_check_packet_received	; wait for a packet
		beq	1B
		jsr	LEDOFF
		WZRD16	WIZ_S7_RX_FIFOR			; get packet len
		std	ZP_TCPIP_RSR
wiz_read_from_socket
1		cmpx	ZP_TCPIP_RSR
		lbhs	wiz_read_block_dowholebuf	; if X>RSR then read everything in buffer and try again
		ldd	#0				; remainder = 0
		pshs	D

CHUNKSZ EQU 16
MAXCHUNK	EQU 2048

wiz_read_block_doit
		cmpx	#CHUNKSZ
		bls	wiz_read_notchunked
		tfr	X,D
		cmpd	#MAXCHUNK
		bls	1F
		subd	#MAXCHUNK
		addd	,S
		std	,S			; add to remainder on stack
		ldd	#MAXCHUNK
		tfr	D,X
1		andd	#CHUNKSZ-1
		addd	,S
		std	,S
		tfr	X,D
		andd	#~(CHUNKSZ-1)
		pshs	D
		ldd	ZP_TCPIP_RSR
		subd	,S
		std	ZP_TCPIP_RSR
		ldd	#WIZ_S7_RX_FIFOR
		std	WIZ_AR
		puls	X
wiz_read_block_loop1024
		ldd	WIZ_DR				; read two bytes
		std	0,Y
		ldd	WIZ_DR				; read two bytes
		std	2,Y
		ldd	WIZ_DR				; read two bytes
		std	4,Y
		ldd	WIZ_DR				; read two bytes
		std	6,Y
		ldd	WIZ_DR				; read two bytes
		std	8,Y
		ldd	WIZ_DR				; read two bytes
		std	10,Y
		ldd	WIZ_DR				; read two bytes
		std	12,Y
		ldd	WIZ_DR				; read two bytes
		std	14,Y

		leay	CHUNKSZ,Y
		leax	-CHUNKSZ,X
		bne	wiz_read_block_loop1024

		bra	wiz_read_chunk_done
wiz_read_notchunked
		; check for odd length (we can only do this two bytes at a time!)
		tfr	X,D
		bitb	#$01
		beq	wiz_read_block_notodd
		; got odd
		inc	1,S				; add to the remainder
		bne	1F
		inc	0,S
1		leax	-1,X				; and even up the count

		beq	block_done			; HERE: check for single byte case

wiz_read_block_notodd
		ldd	ZP_TCPIP_RSR
		pshs	X
		subd	,S++
		std	ZP_TCPIP_RSR
		ldd	#WIZ_S7_RX_FIFOR
		std	WIZ_AR
wiz_read_block_loop
		ldd	WIZ_DR				; read two bytes
		std	,Y++
		leax	-2,X
		bne	wiz_read_block_loop

wiz_read_chunk_done

;;;; TEST USE DMA
;;		lda	#3
;;		sta	sheila_DMAC_DMA_SEL
;;		lda	#$FF
;;		sta	sheila_DMAC_DMA_SRC_ADDR
;;		sta	sheila_DMAC_DMA_DEST_ADDR
;;		tfr	X,D
;;		lsra
;;		rorb
;;		subd	#1
;;		std	sheila_DMAC_DMA_COUNT
;;		ldd	#WIZ_DR
;;		std	sheila_DMAC_DMA_SRC_ADDR+1
;;		sty	sheila_DMAC_DMA_DEST_ADDR+1
;;		lda	#DMACTL2_SZ_WORD
;;		sta	sheila_DMAC_DMA_CTL2
;;		lda	#DMACTL_ACT+DMACTL_EXTEND+DMACTL_HALT+DMACTL_STEP_DEST_UP+DMACTL_STEP_SRC_NONE
;;		sta	sheila_DMAC_DMA_CTL
;;		ldy	sheila_DMAC_DMA_DEST_ADDR+1		
;;;; END TEST USE DMA

;		ldd	ZP_TCPIP_RSR
;		cmpd	#0
;		bne	1F
		jsr	wiz_read_recv
1

;; ANNOYING BODGE! - The wiznet chip once it has declared it's window is full doesn't declare it back open
; once emptied we have to send a dummy message back to the server to get the window updated!

		jsr	wiz_begin_trans
		lda	#$80
		jsr	wiz_send_byte_s7
		jsr	wiz_end_trans

block_done
		; sort out remainder
		puls	X

		cmpx	#1
		lblo	wiz_read_block_exit		; nothing left
		lbne	wiz_read_block_nobuf		; try for another packet
		jsr	wiz_read_byte_s7
		sta	,Y+
		leax	-1,X
		lbra	wiz_read_block_exit

wiz_read_block_dowholebuf
		tfr	X,D
		subd	ZP_TCPIP_RSR
		pshs	D				; remainder after we've read whole buffer
		ldx	ZP_TCPIP_RSR
		cmpx	#1
		beq	1F
		lbra	wiz_read_block_doit
1		; single byte in RSR just read it
		WZRD16	WIZ_S7_RX_FIFOR
		sta	,Y+
		ldx	#0
		stx	ZP_TCPIP_RSR
		bra	block_done


	


	; note: this actually waits ~20ms belt and braces
wiz_wait10ms	pshs	X
		ldx	#2*20000/9
1		leax	-1,X				; 6 cycles
		bne	1B				; 3
		puls	X,PC

