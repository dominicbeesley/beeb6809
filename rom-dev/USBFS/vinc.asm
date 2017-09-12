		include	"vinc.inc"

	IF DEBUG_VERBOSE

	ENDIF


vinc_cmd_echo
		jsr	DEBUGPRINTX
		jsr	vinc_cmd_str
		bne	2F
		jsr	vinc_echo_cmd_response
		bne	1F
		ldx	#str_ok
		jsr	DEBUGPRINTX
		orcc	#CC_Z
		rts
1		ldx	#str_timeout_rd
		bra	3F
2		ldx	#str_timeout_wr
3		jsr	DEBUGPRINTX
		andcc	#~CC_Z
		rts

vinc_cmd_str	ldb	,X+
1		lda	,X+
		jsr	vinc_write_A
		bne	3F
		decb
		bne	1B
2		lda	#$0D			; command terminator
		jmp	vinc_write_A		; write and terminate
3		rts


vinc_echo_cmd_response
1		jsr	vinc_read_A
		bne	5F
		jsr	vinc_echo
		cmpa	#'>'
		bne	1B
4		jsr	vinc_read_A
		bne	5F
		jsr	vinc_echo
		cmpa	#$0D
		bne	1B
5		rts


vinc_echo	pshs	A
		cmpa	#$0D
		beq	3F
		cmpa	#' '
		bhs	2F
		jsr	DEBUGPRINTHEX
		bra	1F
3		jsr	DEBUGPRINTNEWL
		bra	1F
2		jsr	DEBUGPRINTA
1		puls	A,PC

vinc_wait_TXE	pshs	D
		ldd	#$8000
2		tim	#$02, sheila_USRVIA_ora
		beq	1F
		decd
		bpl	2B
1		puls	D,PC

vinc_cmd	jsr	vinc_write_A
		bne	1B
		lda	#$0D
		bra	vinc_write_A

vinc_write_D
		jsr	vinc_write_A
		tfr	B,A
vinc_write_A	pshs	B
		jsr	vinc_wait_TXE
		bne	1F				; timeout
		ldb	#$FF
		stb	sheila_USRVIA_ddrb
		sta	sheila_USRVIA_orb

		ldb	#$04
		stb	sheila_USRVIA_ora
		ldb	#$0C
		stb	sheila_USRVIA_ora
		clr	sheila_USRVIA_ddrb
1		puls	B,PC

vinc_read_A	jsr	vinc_wait_RXF
		bne	1F
vinc_read2	pshs	B
		ldb	#$08				; #RD low
		stb	sheila_USRVIA_ora
		lda	sheila_USRVIA_orb
		ldb	#$0C				; #RD hi
		stb	sheila_USRVIA_ora
		orcc	#CC_Z				; set Z
		puls	B,PC
1		rts

;	wait for char ready
;	Z=0 for timeout
vinc_wait_RXF	pshs	D
		ldd	#$8000
1		tim	#$01, sheila_USRVIA_ora
		beq	2F
		decd
		bpl	1B
2		puls	D,PC

;	flush buffer
vinc_clear_RXF	
		pshs	D
		ldd	#1024				; count down - get 1024 empty responses and then we should have cleared it?
1		tim	#$01, sheila_USRVIA_ora		; check #RXF
		bne	2F
		;do a dummy read
		jsr	vinc_read2
		jsr	vinc_echo
		bra	1B
2		decd
		bne	1B
		puls	D,PC



vinc_init
		; set ORA to RD# = 1, WR = 1
		lda	#$0C
		sta	sheila_USRVIA_ora
		; set DDRA
		sta	sheila_USRVIA_ddra

		ldx	#str_init
		jsr	DEBUGPRINTX

vinc_init_loop
		ldx	#str_flush_init
		jsr	DEBUGPRINTX
		jsr	vinc_clear_RXF
		jsr	vinc_init_ok

		ldx	#str_cmd_scs
		jsr	vinc_cmd_echo
		bne	vinc_init_loop

		ldx	#str_cmd_iph
		jsr	vinc_cmd_echo
		bne	vinc_init_loop

		;; synchronise
		ldx	#str_sync_1
		lda	#'E'
		jsr	vinc_init_sync
		;; synchronise
		ldx	#str_sync_2
		lda	#'e'
		jsr	vinc_init_sync
		;; synchronise
		ldx	#str_sync_3
		lda	#'E'
		jsr	vinc_init_sync

		;; close any open file
		ldx	#str_cmd_clf
		jsr	vinc_cmd_echo
		bne	vinc_init_loop

		rts

vinc_init_sync
		sta	,-S				; store A
		jsr	DEBUGPRINTX			; message
		lda	,S				; get back A
		jsr	vinc_write_A			; send A to vinc
		bne	vinc_init_timeout_wr
		lda	#$0D
		jsr	vinc_write_A			; send <CR>
		bne	vinc_init_timeout_wr
		jsr	vinc_read_A			; get back response
		bne	vinc_init_timeout_rd
		cmpa	,S				; compare 
		bne	vinc_init_nosync		; no sync
		jsr	vinc_read_A
		bne	vinc_init_timeout_rd
		cmpa	#$D
		bne	vinc_init_nosync
		leas	1,S
vinc_init_ok
		ldx	#str_ok
		jmp	DEBUGPRINTX
vinc_init_nosync
		ldx	#str_no_sync
vinc_init_timeout_wr
		ldx	#str_timeout_wr
		bra	1F
vinc_init_timeout_rd
		ldx	#str_timeout_rd
1		jsr	DEBUGPRINTX
		leas	3,S				; don't return!
		bra	vinc_init_loop


VINC_Sector_Reset		; TODO - multiple images?
		lda	#$FF
		sta	VID_VINC_SECTOR_VALID
		jmp	ResetCRC7



VINC_BEGIN1
	pshsw
	ldw	#9
	ldx	#DP_VINC_DATA_PTR
	ldy	#sws_BC_SAVE
	tfm	X+,Y+
	pulsw

	; Check if MMC initialised
	; If not intialise the card
	lda	#$40
	bita	sws_VINC_state
	bne	beg2

	jsr	vinc_init

	; Check MMC_SECTOR & DRIVE_INDEX initialised
beg2
	jsr	CheckCRC7
	tst	VID_VINC_SECTOR_VALID
	beq	beg3
	rts

beg3
	jsr	VINC_Sector_Reset
	jsr	USBFS_LoadDisks
	rts


	; Failed to initialise card!
carderr
	jsr	ReportError
	fcb	$FF, "Card?",0

VINC_BEGIN2
	pshs	D,X,Y
	jsr	VINC_BEGIN1
	puls	D,X,Y,PC		; should call VINC_END to end transaction
VINC_END
	pshsw
	ldw	#9
	ldx	#DP_VINC_DATA_PTR
	ldy	#sws_BC_SAVE
	tfm	Y+,X+
	pulsw
	rts


	**** Read the Catalogue ****
VINC_ReadCat
	jsr	SetLEDS
	ldy	#sws_CurDrvCat
	clr	TubeNoTransferIf0
	jsr	VINC_SetupRead
	jsr	VINC_StartRead
	ldx	#$200				; two sectors
	jsr	VINC_ReadXtoY
	jmp	ResetLEDS

VINC_SetupRead
	pshs	D,X
	ldx	#str_cmd_opr
	jsr	vinc_cmd_echo
	lbne	vinc_err

	ldx	#str_sek
	jsr	DEBUGPRINTX

	lda	#VINC_CMD_SEK
	jsr	vinc_write_A
	lbne	vinc_err
	lda	#' '
	jsr	vinc_write_A
	lbne	vinc_err

	lda	DP_VINC_SEK_ADDR
	jsr	DEBUGPRINTHEX
	jsr	vinc_write_A
	bne	vinc_err

	lda	DP_VINC_SEK_ADDR + 1
	jsr	DEBUGPRINTHEX
	jsr	vinc_write_A
	bne	vinc_err

	lda	DP_VINC_SEK_ADDR + 2
	jsr	DEBUGPRINTHEX
	jsr	vinc_write_A
	bne	vinc_err

	clra
	jsr	DEBUGPRINTHEX
	jsr	vinc_write_A
	bne	vinc_err

	lda	#$D
	jsr	vinc_write_A
	bne	vinc_err
	jsr	vinc_echo_cmd_response
	bne	vinc_err
	puls	D,X,PC

VINC_StartRead
	rts

VINC_ReadXtoY
	pshsw
	pshs	X
	ldx	#str_rdf
	jsr	DEBUGPRINTX
	puls	X

	lda	#VINC_CMD_RDF
	jsr	vinc_write_A
	bne	vinc_err
	lda	#' '
	jsr	vinc_write_A
	bne	vinc_err
	clra
	jsr	vinc_write_A
	bne	vinc_err
	clra
	jsr	vinc_write_A
	bne	vinc_err
	tfr	X,D
	jsr	vinc_write_D				; two byte length
	bne	vinc_err
	lda	#$0D
	jsr	vinc_write_A
	bne	vinc_err
	clre
1	jsr	vinc_read_A
	bne	2F
	clre
	sta	,Y+
	leax	-1,X
	bne	1B

	pulsw
	jsr	vinc_echo_cmd_response
	bne	vinc_err
	rts
2	dece
	beq	vinc_err


vinc_err
	jsr	ReportError
	fcb	99, "VINC ERROR", 0


***********************************************************************
MMC_ReadBlock
	; **** Read data block to memory ****
	; at loc. 	datptr%
	; 		DP_VINC_SEK_ADDR, DP_CE_SECTOR_COUNT, DP_C3_BYTES_LAST_SECTOR
	; define block
***********************************************************************

		jsr	SetLEDS
		jsr	rdblk
		jsr	ResetLEDS
		rts

rb1_exit
		rts

rdblk		; TODO TUBE / inter bank addressing, for now just point Y at load address and load
		ldu	DP_CE_SECTOR_COUNT
		beq	rb1_exit
		cmpu	#256
		lbhs	errBlockSize

		jsr	VINC_SetupRead
		jsr	VINC_StartRead

		lda	DP_CE_SECTOR_COUNT + 1
		ldb	DP_C3_BYTES_LAST_SECTOR
;		bne	1F
;		deca
1		tfr	D,X
		ldy	DP_VINC_DATA_PTR
		jsr	VINC_ReadXtoY
		rts


 **		
 **			\\ **** Write data block from memory ****
 **		.wb1_exit
 **			RTS
 **		
 **		.MMC_WriteBlock
 **		{
 **			JSR SetLEDS
 **			JSR wrblk
 **			JMP ResetLEDS
 **		
 **		.wrblk
 **		IF _LARGEFILES
 **			LDX DP_CE_SECTOR_COUNT
 **			BNE wb1
 **			LDA DP_CE_SECTOR_COUNT+1
 **			BEQ wb1_exit			; nothing to do
 **		.wb1
 **		ELSE
 **			LDX DP_CE_SECTOR_COUNT
 **			BEQ wb1_exit			; nothing to do!
 **		ENDIF
 **		
 **			LDA #0
 **			JSR MMC_RWBlock_CheckIfToTube
 **		
 **			LDX DP_CE_SECTOR_COUNT
 **			ROR DP_VINC_SEK_ADDR
 **			ROR A
 **			ASL DP_VINC_SEK_ADDR
 **			PHA
 **		
 **			JSR MMC_SetupWrite
 **		
 **			PLA
 **			BPL wb2				; sec even!
 **		
 **			\\ start is odd!
 **			\\ read mmc sector bytes 0-255
 **			\\ to buffer, then rewrite it
 **			\\ with page 1 of the data
 **		
 **			LDA #read_single_block
 **			STA cmdseq%+1
 **			JSR MMC_StartRead
 **			JSR MMC_ReadBuffer
 **			LDY #0
 **			JSR MMC_Clocks
 **			LDY #2
 **			JSR MMC_Clocks
 **		
 **			LDA #write_block
 **			STA cmdseq%+1
 **			JSR MMC_StartWrite
 **			JSR MMC_WriteBuffer
 **			JSR MMC_Write256
 **			JSR MMC_EndWrite
 **		IF _LARGEFILES
 **			LDA #&FF
 **			JSR dec_seccount
 **		ELSE
 **			DEC DP_CE_SECTOR_COUNT
 **		ENDIF
 **			BEQ wb1_exit			; finished
 **			INC datptr%+1
 **		
 **			\\ sector+=2
 **		.wb4
 **			JSR incCommandAddress
 **		
 **		.wb2
 **		IF _LARGEFILES
 **			LDA DP_CE_SECTOR_COUNT+1
 **			BNE wb3
 **		ENDIF
 **			LDX DP_CE_SECTOR_COUNT
 **			BEQ wb5				; finished
 **			DEX
 **			BNE wb3				; seccount>=2
 **		
 **			\\ 1 sector left
 **			\\ read mmc sector bytes 256-511
 **			\\ to buffer, then write last
 **			\\ page of data, followed by the
 **			\\ data in the buffer
 **		
 **			LDA #read_single_block
 **			STA cmdseq%+1
 **			JSR MMC_StartRead
 **			LDY #0
 **			JSR MMC_Clocks
 **			JSR MMC_ReadBuffer
 **			LDY #2
 **			JSR MMC_Clocks
 **		
 **			LDA #write_block
 **			STA cmdseq%+1
 **			JSR MMC_StartWrite
 **			JSR MMC_Write256
 **			JSR MMC_WriteBuffer
 **			JMP MMC_EndWrite		; finished
 **		
 **			\\ write whole sectors
 **			\\ i.e. 2 pages (512 bytes)
 **		
 **		.wb3
 **			JSR MMC_StartWrite
 **			JSR MMC_Write256
 **			INC datptr%+1
 **			JSR MMC_Write256
 **			INC datptr%+1
 **			JSR MMC_EndWrite
 **		IF _LARGEFILES
 **			LDA #&FE
 **			JSR dec_seccount
 **		ELSE
 **			DEC DP_CE_SECTOR_COUNT
 **			DEC DP_CE_SECTOR_COUNT
 **		ENDIF
 **			BNE wb4
 **		
 **		.wb5
 **			RTS
 **		}
 **		
 **		IF _LARGEFILES
 **		\\ Decrement a 16-bit sector count
 **		\\ Call with A=-1 (&FF) to decrement by 1
 **		\\ Call with A=-2 (&FE) to decrement by 2
 **		\\ On exit:
 **		\\ X = value of DP_CE_SECTOR_COUNT
 **		\\ Z flag if DP_CE_SECTOR_COUNT,DP_CE_SECTOR_COUNT+1 zero
 **		.dec_seccount
 **		{
 **			CLC
 **			ADC DP_CE_SECTOR_COUNT
 **			STA DP_CE_SECTOR_COUNT
 **			TAX
 **			LDA #&FF
 **			ADC DP_CE_SECTOR_COUNT+1
 **			STA DP_CE_SECTOR_COUNT+1
 **			ORA DP_CE_SECTOR_COUNT
 **			RTS
 **		}
 **		ENDIF
 **		

str_init	FCB	$0D, $0D, "Initialising", $0D, "============", $0D, 0
str_flush_init	FCB	"Flushing...", 0
str_sync_1	FCB	"Sync 1...", 0
str_sync_2	FCB	"Sync 2...", 0
str_sync_3	FCB	"Sync 3...", 0
str_timeout_rd	FCB	"Timeout (rd)!", $0D, 0
str_timeout_wr	FCB	"Timeout (wr)!", $0D, 0
str_ok		FCB	"OK", $0D, 0
str_no_sync	FCB	"Bad sync", $0D, 0

str_sek		FCB	"SEK:", 0
str_rdf		FCB	"RDF:", 13, 0

str_cmd_fwv	FCB	"FWV:", 			0, 1, VINC_CMD_FWV
str_cmd_dir	FCB	"DIR:", 			0, 1, VINC_CMD_DIR
str_cmd_scs	FCB	"SCS:", 			0, 1, VINC_CMD_SCS
str_cmd_iph	FCB	"IPH:", 			0, 1, VINC_CMD_IPH
str_cmd_clf	FCB	"CLF:", 			0, 1, VINC_CMD_CLF
str_cmd_opr	FCB	"OPR BEEB.MMB",			0, 10, VINC_CMD_OPR," BEEB.MMB"
str_cmd_rdf	FCB	"RDF ", 			0, 6, VINC_CMD_RDF, ' ', 0, 0, 0, 100
