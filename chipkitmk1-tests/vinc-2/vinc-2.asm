		include "../../includes/hardware.inc"
		include "../../includes/common.inc"
		include "../../includes/oslib.inc"
		include "../../includes/mosrom.inc"


		SETDP	$00
		ORG	$00
dp_init_tmp	RMB	1

		ORG	$1000

		; Test vinculum functions 
		; vinc is 	D0-7	USER VIA	PB0-7
		; 		RXF#			PA0
		;		TXE#			PA1
		;		RD#			PA2
		;		WR			PA3

VINC_CMD_SCS	EQU	$10
VINC_CMD_ECS	EQU	$11
VINC_CMD_IPA	EQU	$90
VINC_CMD_IPH	EQU	$91
VINC_CMD_FWV	EQU	$13
VINC_CMD_E_U	EQU	'E'
VINC_CMD_E_L	EQU	'e'

*** VDAP ***
VINC_CMD_DIR	EQU	$01
VINC_CMD_CD	EQU	$02
VINC_CMD_RD	EQU	$04
VINC_CMD_DLD	EQU	$05
VINC_CMD_MKD	EQU	$06
VINC_CMD_DLF	EQU	$07
VINC_CMD_WRF	EQU	$08
VINC_CMD_OPW	EQU	$09
VINC_CMD_CLF	EQU	$0A
VINC_CMD_RDF	EQU	$0B
VINC_CMD_REN	EQU	$0C
VINC_CMD_OPR	EQU	$0E
VINC_CMD_SEK	EQU	$28
VINC_CMD_FS	EQU	$12
VINC_CMD_FSE	EQU	$93
VINC_CMD_IDD	EQU	$0F
VINC_CMD_IDDE	EQU	$94
VINC_CMD_DSN	EQU	$2D
VINC_CMD_DVL	EQU	$2E
VINC_CMD_DIRT	EQU	$2F



		jsr	vinc_init

		ldx	#str_cmd_fwv
		jsr	vinc_cmd_echo

		ldx	#str_cmd_dir
		jsr	vinc_cmd_echo

		ldx	#str_cmd_opr
		jsr	vinc_cmd_echo

		ldx	#str_cmd_rdf
		jsr	vinc_cmd_echo


		swi

***********************************************************************

vinc_cmd_echo
		jsr	PRSTRING
		jsr	vinc_cmd_str
		bne	2F
		jsr	vinc_echo_cmd_response
		bne	1F
		ldx	#str_ok
		jsr	PRSTRING
		orcc	#CC_Z
		rts
1		ldx	#str_timeout_rd
		bra	3F
2		ldx	#str_timeout_wr
3		jsr	PRSTRING
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
		jsr	PRHEX
		bra	1F
3		jsr	OSNEWL
		bra	1F
2		jsr	OSWRCH
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
vinc_read2	ldb	#$08				; #RD low
		stb	sheila_USRVIA_ora
		lda	sheila_USRVIA_orb
		ldb	#$0C				; #RD hi
		stb	sheila_USRVIA_ora
		orcc	#CC_Z				; set Z
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
		lda	#$0C
		sta	sheila_USRVIA_ddra

		ldx	#str_init
		jsr	PRSTRING

vinc_init_loop
		ldx	#str_clear_in
		jsr	PRSTRING
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

vinc_init_nosync
		ldx	#str_no_sync
vinc_init_timeout_wr
		ldx	#str_timeout_wr
		bra	1F
vinc_init_timeout_rd
		ldx	#str_timeout_rd
1		jsr	PRSTRING
		leas	2,S				; don't return!
		bra	vinc_init_loop
vinc_init_sync
		sta	dp_init_tmp			; store A
		jsr	PRSTRING			; message
		lda	dp_init_tmp			; get back A
		jsr	vinc_write_A			; send A to vinc
		bne	vinc_init_timeout_wr
		lda	#$0D
		jsr	vinc_write_A			; send <CR>
		bne	vinc_init_timeout_wr
		jsr	vinc_read_A			; get back response
		bne	vinc_init_timeout_rd
		cmpa	dp_init_tmp			; compare 
		bne	vinc_init_nosync		; no sync
		jsr	vinc_read_A
		bne	vinc_init_timeout_rd
		cmpa	#$D
		bne	vinc_init_nosync
vinc_init_ok
		ldx	#str_ok
		jmp	PRSTRING




str_init	FCB	$0D, $0D, "Initialising", $0D, "============", $0D, 0
str_clear_in	FCB	"Flushing...", 0
str_sync_1	FCB	"Sync 1...", 0
str_sync_2	FCB	"Sync 2...", 0
str_sync_3	FCB	"Sync 3...", 0
str_timeout_rd	FCB	"Timeout (rd)!", $0D, 0
str_timeout_wr	FCB	"Timeout (wr)!", $0D, 0
str_ok		FCB	"OK", $0D, 0
str_no_sync	FCB	"Bad sync", $0D, 0

str_cmd_fwv	FCB	"FWV:", 			0, 1, VINC_CMD_FWV
str_cmd_dir	FCB	"DIR:", 			0, 1, VINC_CMD_DIR
str_cmd_scs	FCB	"SCS:", 			0, 1, VINC_CMD_SCS
str_cmd_iph	FCB	"IPH:", 			0, 1, VINC_CMD_IPH
str_cmd_clf	FCB	"CLF:", 			0, 1, VINC_CMD_CLF
str_cmd_opr	FCB	"OPR test.txt",			0, 10, VINC_CMD_OPR," test.txt"
str_cmd_rdf	FCB	"RDF ", 			0, 6, VINC_CMD_RDF, ' ', 0, 0, 0, 100
