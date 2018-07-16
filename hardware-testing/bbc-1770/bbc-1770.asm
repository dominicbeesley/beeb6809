
		include "../../includes/oslib.inc"
		include "../../includes/hardware.inc"
		include "../../includes/common.inc"
		include "../../includes/mosrom.inc"

		setdp 0
zp_xfer_act	equ	$70
zp_xfer_addr	equ	$71
zp_xfer_len	equ	$73
zp_xfer_a2	equ	$75
zp_xfer_err	equ	$76


		org $1900

rti_inst		equ	$3B


m_hexdig	macro
		if \1==0
			FCB '0'
		elsif \1==1
			FCB '1'
		elsif \1==2
			FCB '2'
		elsif \1==3
			FCB '3'
		elsif \1==4
			FCB '4'
		elsif \1==5
			FCB '5'
		elsif \1==6
			FCB '6'
		elsif \1==7
			FCB '7'
		elsif \1==8
			FCB '8'
		elsif \1==9
			FCB '9'
		elsif \1==10
			FCB 'A'
		elsif \1==11
			FCB 'B'
		elsif \1==12
			FCB 'C'
		elsif \1==13
			FCB 'D'
		elsif \1==14
			FCB 'E'
		else
			FCB 'F'
		endif
		endm

m_hex16		macro
		m_hexdig ((\1 / $1000) & $0F)
		m_hexdig ((\1 / $100) & $0F)
		m_hexdig ((\1 / $10) & $0F)
		m_hexdig (\1 & $0F)
		endm

		; debugger setup
		SEI					; make sure we have interrupts off in case it's stuck

		ldx	#sector_buf
		clra
1		sta	,X+
		deca
		bne	1B

		; setup nmi for rti
		ldx	#nmi2
		ldy	#vec_nmi
		ldb	#nmi2_end-nmi2
1		lda	,X+
		sta	,Y+
		decb
		bne	1B

		ldx	#str_restore
		jsr	PrintX

		; reset 1770
		clr	sheila_1770_dcontrol

		jsr	wait1

		lda	#$29
		sta	sheila_1770_dcontrol		; no reset, single density, side 0, sel 0

		CLI					; should be safe now!

		jsr	wait1

		lda	#$FF
		sta	zp_xfer_a2

		lda	#$04
		sta	sheila_1770_wdc_cmd		; restore, spin up, verify, 6ms


1		tst	zp_xfer_a2
		bmi	1B	

		lda	zp_xfer_err
		ldx	#str_result
		jsr	PrintMsgThenHex	

		; try a read from track 0 sector 0

		jsr	wait1
		jsr	wait1
		jsr	wait1
		jsr	wait1
		jsr	wait1
		jsr	wait1
		jsr	wait1
		jsr	wait1
		jsr	wait1
		jsr	wait1
		jsr	wait1
		jsr	wait1
		jsr	wait1
		jsr	wait1
		jsr	wait1
		jsr	wait1
		jsr	wait1
		jsr	wait1
		jsr	wait1
		jsr	wait1
		jsr	wait1
		jsr	wait1

		ldx	#str_sector
		jsr	PrintX

		orcc	#CC_I				; disable normal interrupts allow FIRQs

		lda	#$FF
		sta	zp_xfer_a2
		ldx	#sector_buf
		stx	zp_xfer_addr
		ldx	#$100
		stx	zp_xfer_len
		lda	#1
		sta	zp_xfer_act


		lda	#2
		sta	sheila_1770_wdc_sec
		clr	sheila_1770_wdc_trk
		lda	#$84				; read sector, single, 15ms settling delay
		sta	sheila_1770_wdc_cmd

1		tst	zp_xfer_a2
		bmi	1B	

		CLI

		lda	#rti_inst
		sta	vec_nmi


		lda	zp_xfer_err
		ldx	#str_result
		jsr	PrintMsgThenHex	

		ldx	#str_mdump
		jsr	OSCLI

		swi

wait1		pshs	A
		lda	#0
1		deca
		bne	1B
		puls	A,PC

;--------------------------------------------------------------------------------

nmi1		pshs	A,X
		lda	sheila_1770_wdc_cmd
		sta	sector_buf
		clr	sector_buf+1
		puls	A,X
		rti
nmi1_end

nmi2
		pshs	A,X
		lda	sheila_1770_wdc_cmd
		anda	#$1F				; get status
		cmpa	#3				; check for BSY and DRQ
		bne	nmi_rd_not_DRQ			
		tst	zp_xfer_act			; check to see if everything has been read that we want
		beq	nmi_rd_discard_data		; and throw away anything after
		lda	sheila_1770_wdc_dat		; get data byte
		ldx	zp_xfer_addr
		sta	,X+				; dave data byte
		stx	zp_xfer_addr
		dec	zp_xfer_len+1
		bne	1F
		dec	zp_xfer_len
		bne	1F
		dec	zp_xfer_act
1		puls	A,X
		rti

nmi_rd_not_DRQ
		anda	#$5C				; mask to just WP, SE/RNF, CRC, LD (though WP already masked out!)
		sta	zp_xfer_err
		lda	sheila_1770_wdc_dat		; clear register just in case
		lda	zp_xfer_a2
		anda	#$7F				; clear top bit - indicate done
		sta	zp_xfer_a2
		puls	A,X
		rti

  
nmi_rd_discard_data
		lda	sheila_1770_wdc_dat		; read data to clear DRQ
		puls	A,X
		rti
nmi2_end

;------------------------------------------------------------------------------
; Printing
;------------------------------------------------------------------------------
Print2Spc	jsr	PrintSpc
PrintSpc	lda	#' '
		bra	PrintA
PrintNL		lda	#$D
PrintA		jmp	OSASCI

PrintX		lda	,X+
		beq	1F
		jsr	OSASCI
		bra	PrintX
1		rts

PrintHexNybA	anda	#$0F
		cmpa	#9
		bls	1F
		adda	#'A'-'9'-1
1		adda	#'0'
		jsr	PrintA
		rts
PrintHexA	pshs	A
		lsra
		lsra
		lsra
		lsra
		jsr	PrintHexNybA
		lda	0,S
		jsr	PrintHexNybA
		puls	A,PC
PrintHexX	pshs	D,X
		tfr	X,D
		jsr	PrintHexA
		lda	3,S
		jsr	PrintHexA
		puls	D,X,PC


PrintMsgThenHexNyb
		pshs	A
		jsr	PrintX
		puls	A
		jsr	PrintHexNybA
		jmp	PrintNL

PrintMsgThenHex
		pshs	A
		jsr	PrintX
		puls	A
		jsr	PrintHexA
		jmp	PrintNL


str_mdump	fcb "MDUMP "
		m_hex16 sector_buf
		fcb "+100", $D

str_restore	fcb "restore ",0
str_sector	fcb "sector ",0
str_result	fcb "result: ",0


		; align 256 - not really necessary
a_h		FILL 	$FF, (256-(a_h & $FF)) & $FF
sector_buf
