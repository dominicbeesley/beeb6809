	include "../../includes/hardware.inc"
	include "../../includes/common.inc"
	include "../../includes/mosrom.inc"
	include "../../includes/noice.inc"
	include "../../includes/oslib.inc"

DEBUGPR		MACRO
		SECTION	"tables_and_strings"
1		FCB	\1,0
__STR		SET	1B
		CODE
		PSHS	X
		LEAX	__STR,PCR
		JSR	debug_printX
		JSR	debug_print_newl
		PULS	X
		ENDM

DEBUGPR2	MACRO
		SECTION	"tables_and_strings"
1		FCB	\1,0
__STR		SET	1B
		CODE
		PSHS	X
		LEAX	__STR,PCR
		JSR	debug_printX
		PULS	X
		ENDM


ASSERT		MACRO
		DEBUGPR	\1
		SWI
		ENDM

TODO		MACRO
		jsr	prTODO
		ASSERT	\1
		ENDM

TODOSKIP	MACRO
		DEBUGPR	\1
		ENDM



	; NOTE: MOS only runs on a 6309 and uses 6309 extra registers
	; NOTE: currently doesn't support native mode!

	CODE
	ORG	MOSROMBASE
	setdp	MOSROMSYS_DP
	SECTION	"tables_and_strings"
	ORG	MOSSTRINGS


NATIVE	equ	0

	CODE
mostbl_chardefs
	FCB	$00,$00,$00,$00,$00,$00,$00,$00
	FCB	$18,$18,$18,$18,$18,$00,$18,$00
	FCB	$6C,$6C,$6C,$00,$00,$00,$00,$00
	FCB	$36,$36,$7F,$36,$7F,$36,$36,$00
	FCB	$0C,$3F,$68,$3E,$0B,$7E,$18,$00
	FCB	$60,$66,$0C,$18,$30,$66,$06,$00
	FCB	$38,$6C,$6C,$38,$6D,$66,$3B,$00
	FCB	$0C,$18,$30,$00,$00,$00,$00,$00
	FCB	$0C,$18,$30,$30,$30,$18,$0C,$00
	FCB	$30,$18,$0C,$0C,$0C,$18,$30,$00
	FCB	$00,$18,$7E,$3C,$7E,$18,$00,$00
	FCB	$00,$18,$18,$7E,$18,$18,$00,$00
	FCB	$00,$00,$00,$00,$00,$18,$18,$30
	FCB	$00,$00,$00,$7E,$00,$00,$00,$00
	FCB	$00,$00,$00,$00,$00,$18,$18,$00
	FCB	$00,$06,$0C,$18,$30,$60,$00,$00
	FCB	$3C,$66,$6E,$7E,$76,$66,$3C,$00
	FCB	$18,$38,$18,$18,$18,$18,$7E,$00
	FCB	$3C,$66,$06,$0C,$18,$30,$7E,$00
	FCB	$3C,$66,$06,$1C,$06,$66,$3C,$00
	FCB	$0C,$1C,$3C,$6C,$7E,$0C,$0C,$00
	FCB	$7E,$60,$7C,$06,$06,$66,$3C,$00
	FCB	$1C,$30,$60,$7C,$66,$66,$3C,$00
	FCB	$7E,$06,$0C,$18,$30,$30,$30,$00
	FCB	$3C,$66,$66,$3C,$66,$66,$3C,$00
	FCB	$3C,$66,$66,$3E,$06,$0C,$38,$00
	FCB	$00,$00,$18,$18,$00,$18,$18,$00
	FCB	$00,$00,$18,$18,$00,$18,$18,$30
	FCB	$0C,$18,$30,$60,$30,$18,$0C,$00
	FCB	$00,$00,$7E,$00,$7E,$00,$00,$00
	FCB	$30,$18,$0C,$06,$0C,$18,$30,$00
	FCB	$3C,$66,$0C,$18,$18,$00,$18,$00
	FCB	$3C,$66,$6E,$6A,$6E,$60,$3C,$00
	FCB	$3C,$66,$66,$7E,$66,$66,$66,$00
	FCB	$7C,$66,$66,$7C,$66,$66,$7C,$00
	FCB	$3C,$66,$60,$60,$60,$66,$3C,$00
	FCB	$78,$6C,$66,$66,$66,$6C,$78,$00
	FCB	$7E,$60,$60,$7C,$60,$60,$7E,$00
	FCB	$7E,$60,$60,$7C,$60,$60,$60,$00
	FCB	$3C,$66,$60,$6E,$66,$66,$3C,$00
	FCB	$66,$66,$66,$7E,$66,$66,$66,$00
	FCB	$7E,$18,$18,$18,$18,$18,$7E,$00
	FCB	$3E,$0C,$0C,$0C,$0C,$6C,$38,$00
	FCB	$66,$6C,$78,$70,$78,$6C,$66,$00
	FCB	$60,$60,$60,$60,$60,$60,$7E,$00
	FCB	$63,$77,$7F,$6B,$6B,$63,$63,$00
	FCB	$66,$66,$76,$7E,$6E,$66,$66,$00
	FCB	$3C,$66,$66,$66,$66,$66,$3C,$00
	FCB	$7C,$66,$66,$7C,$60,$60,$60,$00
	FCB	$3C,$66,$66,$66,$6A,$6C,$36,$00
	FCB	$7C,$66,$66,$7C,$6C,$66,$66,$00
	FCB	$3C,$66,$60,$3C,$06,$66,$3C,$00
	FCB	$7E,$18,$18,$18,$18,$18,$18,$00
	FCB	$66,$66,$66,$66,$66,$66,$3C,$00
	FCB	$66,$66,$66,$66,$66,$3C,$18,$00
	FCB	$63,$63,$6B,$6B,$7F,$77,$63,$00
	FCB	$66,$66,$3C,$18,$3C,$66,$66,$00
	FCB	$66,$66,$66,$3C,$18,$18,$18,$00
	FCB	$7E,$06,$0C,$18,$30,$60,$7E,$00
	FCB	$7C,$60,$60,$60,$60,$60,$7C,$00
	FCB	$00,$60,$30,$18,$0C,$06,$00,$00
	FCB	$3E,$06,$06,$06,$06,$06,$3E,$00
	FCB	$18,$3C,$66,$42,$00,$00,$00,$00
	FCB	$00,$00,$00,$00,$00,$00,$00,$FF
	FCB	$1C,$36,$30,$7C,$30,$30,$7E,$00
	FCB	$00,$00,$3C,$06,$3E,$66,$3E,$00
	FCB	$60,$60,$7C,$66,$66,$66,$7C,$00
	FCB	$00,$00,$3C,$66,$60,$66,$3C,$00
	FCB	$06,$06,$3E,$66,$66,$66,$3E,$00
	FCB	$00,$00,$3C,$66,$7E,$60,$3C,$00
	FCB	$1C,$30,$30,$7C,$30,$30,$30,$00
	FCB	$00,$00,$3E,$66,$66,$3E,$06,$3C
	FCB	$60,$60,$7C,$66,$66,$66,$66,$00
	FCB	$18,$00,$38,$18,$18,$18,$3C,$00
	FCB	$18,$00,$38,$18,$18,$18,$18,$70
	FCB	$60,$60,$66,$6C,$78,$6C,$66,$00
	FCB	$38,$18,$18,$18,$18,$18,$3C,$00
	FCB	$00,$00,$36,$7F,$6B,$6B,$63,$00
	FCB	$00,$00,$7C,$66,$66,$66,$66,$00
	FCB	$00,$00,$3C,$66,$66,$66,$3C,$00
	FCB	$00,$00,$7C,$66,$66,$7C,$60,$60
	FCB	$00,$00,$3E,$66,$66,$3E,$06,$07
	FCB	$00,$00,$6C,$76,$60,$60,$60,$00
	FCB	$00,$00,$3E,$60,$3C,$06,$7C,$00
	FCB	$30,$30,$7C,$30,$30,$30,$1C,$00
	FCB	$00,$00,$66,$66,$66,$66,$3E,$00
	FCB	$00,$00,$66,$66,$66,$3C,$18,$00
	FCB	$00,$00,$63,$6B,$6B,$7F,$36,$00
	FCB	$00,$00,$66,$3C,$18,$3C,$66,$00
	FCB	$00,$00,$66,$66,$66,$3E,$06,$3C
	FCB	$00,$00,$7E,$0C,$18,$30,$7E,$00
	FCB	$0C,$18,$18,$70,$18,$18,$0C,$00
	FCB	$18,$18,$18,$00,$18,$18,$18,$00
	FCB	$30,$18,$18,$0E,$18,$18,$30,$00
	FCB	$31,$6B,$46,$00,$00,$00,$00,$00
	FCB	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	ORG	$C300				; important!
;; ----------------------------------------------------------------------------
mos_jump2vdu_init
	jmp	mos_VDU_init			;	C300
; ----------------------------------------------------------------------------
mos_welcome_msg
	FCB	$0D
	FCB	"Dossy 6809 512K"		;	C304
	FCB	$07, $00
	FCB	$08,$0D,$0D		;	C31A
; ----------------------------------------------------------------------------
mostbl_byte_mask_4col
	FCB	$00,$11,$22,$33,$44,$55,$66,$77 ;	C31F
	FCB	$88,$99,$AA,$BB,$CC,$DD,$EE,$FF ;	C327
mostbl_byte_mask_16col
	FCB	$00,$55,$AA,$FF			;	C32F
; VDU ENTRY POINT LO	   LOOK UP TABLE !!!!!ADDRESSES!!!!
;mostbl_vdu_entry_point_lo
;	FCB	$11,$3B,$96,$A1,$AD,$B9,$11,$6F ;	C333
;	FCB	$C5,$64,$F0,$5B,$59,$AF,$8D,$A6 ;	C33B
;	FCB	$C0,$F9,$FD,$92,$39,$9B,$EB,$F1 ;	C343
;	FCB	$39,$8C,$BD,$11,$FA,$A2,$79,$87 ;	C34B
;	FCB	$AC				;	C353
;; VDU ENTRY POINT HI PARAMETER LOOK UP TABLE !!!!!ADDRESSES!!!!
;mostbl_vdu_entry_point_hi
;	FCB	$C5,$2F,$C5,$C5,$C5,$C5,$C5,$E8 ;	C354
;	FCB	$C5,$C6,$C6,$C6,$C7,$C7,$C5,$C5 ;	C35C
;	FCB	$C7,$4F,$4E,$5B,$C8,$C5,$5F,$57 ;	C364
;	FCB	$78,$6B,$C9,$C5,$3C,$7C,$C7,$4E ;	C36C
;	FCB	$CA				;	C374
mostbl_vdu_entry_points
	FDB	LC511RTS		; VDU 0
	FDB	mos_VDU_1		; VDU 1
	FDB	mos_VDU_2		; VDU 2
	FDB	mos_VDU_3		; VDU 3
	FDB	mos_VDU_4		; VDU 4
	FDB	mos_VDU_5		; VDU 5
	FDB	LC511RTS		; VDU 6
	FDB	mos_VDU_7		; VDU 7

	FDB	mos_VDU_8		; VDU 8
	FDB	mos_VDU_9		; VDU 9
	FDB	mos_VDU_10		; VDU 10
	FDB	mos_VDU_11		; VDU 11
	FDB	mos_VDU_12		; VDU 12
	FDB	mos_VDU_13
	FDB	mos_VDU_14
	FDB	mos_VDU_15

	FDB	mos_VDU_16
	FDB	mos_VDU_17
	FDB	mos_VDU_18
	FDB	mos_VDU_19
	FDB	mos_VDU_20
	FDB	mos_VDU_21
	FDB	mos_VDU_22
	FDB	mos_VDU_23

	FDB	mos_VDU_24
	FDB	mos_VDU_25
	FDB	mos_VDU_26
	FDB	LC511RTS
	FDB	mos_VDU_28
	FDB	mos_VDU_29
	FDB	mos_VDU_30
	FDB	mos_VDU_31

	FDB	mos_VDU_127

mostbl_vdu_q_lengths	; 2's complement
	FCB	$00,$FF,$00,$00,$00,$00,$00,$00	; 0-7
	FCB	$00,$00,$00,$00,$00,$00,$00,$00 ; 8-15
	FCB	$00,$FF,$FE,$FB,$00,$00,$FF,$F7 ; 16-23
	FCB	$F8,$FB,$00,$00,$FC,$FC,$00,$FE ; 24-31
	FCB	$00

; *40 MULTIPLICATION TABLE  TELETEXT  MODE
mostbl_40_mul
	FCB	$00,$00,$00,$28,$00,$50,$00,$78 ;	C3B4
	FCB	$00,$A0,$00,$C8,$00,$F0,$01,$18 ;	C3BC
	FCB	$01,$40,$01,$68,$01,$90,$01,$B8 ;	C3C4
	FCB	$01,$E0,$02,$08,$02,$30,$02,$58 ;	C3CC
	FCB	$02,$80,$02,$A8,$02,$D0,$02,$F8 ;	C3D4
	FCB	$03,$20,$03,$48,$03,$70,$03,$98 ;	C3DC
	FCB	$03				;	C3E4
; TEXT WINDOW -BOTTOM ROW LOOK UP TABLE
mostbl_vdu_window_bottom
	FCB	$C0,$1F,$1F,$1F,$18,$1F,$1F,$18 ;	C3E6
	FCB	$18				;	C3EE
; TEXT WINDOW -RIGHT HAND COLUMN LOOK UP TABLE
mostbl_vdu_window_right
	FCB	$4F,$27,$13,$4F,$27,$13,$27,$27 ;	C3EF
mostbl_VDU_VIDPROC_CTL_by_mode
	FCB	$9C,$D8,$F4,$9C,$88,$C4,$88,$4B ;	C3F7
mostbl_VDU_bytes_per_char
	FCB	$08,$10,$20,$08,$08,$10,$08,$01 ;	C3FF
mostbl_VDU_pix_mask_16colour				
	FCB	$AA,$55				;	C407
mostbl_VDU_pix_mask_4colour
	FCB	$88,$44,$22,$11			;	C409
mostbl_VDU_pix_mask_2colour
	FCB	$80,$40,$20,$10,$08,$04,$02	;	C40D
mostbl_VDU_mode_colours_m1			; - spills into next table
	FCB	$01,$03,$0F,$01,$01,$03,$01,$00 ;	C414
; GCOL PLOT OPTIONS PROCESSING LOOK UP TABLE
mostbl_GCOL_options_proc
	FCB	$FF,$00,$00,$FF,$FF,$FF,$FF,$00 ;	C41C
; 2 COLOUR MODES PARAMETER LOOK UP TABLE
mostbl_2_colour_pixmasks
	FCB	$00,$FF				;	C424
; 4 COLOUR MODES PARAMETER LOOK UP TABLE
mostbl_4_colour_pixmasks
	FCB	$00,$0F,$F0,$FF			;	C426
; 16 COLOUR MODES PARAMETER LOOK UP TABLE
mostbl_16_colour_pixmasks
	FCB	$00,$03,$0C,$0F,$30,$33,$3C,$3F ;	C42A
	FCB	$C0,$C3,$CC,$CF,$F0,$F3,$FC,$FF ;	C432
mostbl_leftmost_pixels
	FCB	$80,$88,$AA
; modes 3,6,7 are 0 but get set to $7 in vdu_init
mostbl_VDU_pixels_per_byte_m1
	FCB	$07,$03,$01,$00,$07,$03		;	C43A
; mode size
mostbl_VDU_mode_size				; note first two entries shared by previous tbl
	FCB	$00,$00,$00,$01,$02,$02,$03,$04 ;	C440
; SOUND PITCH OFFSET BY CHANNEL LOOK UP TABLE ???CHECK
mostbl_SOUND_PITCH_OFFSET_BY_CHANNEL_LOOK_UP_TABLE
	FCB	$00,$06,$02			;	C448
;;;; sent direct to orb of SYSVIA dependent on mode_size
;;;mostbl_VDU_hwscroll_offb1
;;;	FCB	$0D,$05,$0D,$05			;	C44B
;;;; sent direct to orb of SYSVIA dependent on mode_size
;;;mostbl_VDU_hwscroll_offb2
;;;	FCB	$04,$04,$0C,$0C,$04		;	C44F
; new scroll offset table for 6809 hardware offset
mostbl_VDU_hwscroll_offs
	FCB	$06,$08,$0B,$0C,$F;			TODO: mode 7 doesn't work!
; where to jump to in CLS unwound
;;;mostbl_VDU_cls_vecjmp
;;;	FDB	cls_Mode_012_entry_point
;;;	FDB	cls_Mode_3_entry_point
;;;	FDB	cls_Mode_45_entry_point
;;;	FDB	cls_Mode_6_entry_point
;;;	FDB	cls_Mode_7_entry_point
mostbl_VDU_screensize_h
	FCB	$50,$40,$28,$20,$04		;	C459
mostbl_VDU_screebot_h
	FCB	$30,$40,$58,$60,$7C		;	C45E
mostbl_VDU_bytes_per_row_low
	FCB	$28,$40,$80			;	C463
; pointers to tables of 6845 values that follow this by
mostbl_VDU_ptr_end_6845tab
	FCB	$0B + 1
	FCB	$17 + 1
	FCB	$23 + 1
	FCB	$2F + 1
	FCB	$3B + 1
mostbl_VDU_6845_mode_012
	FCB	$7F,$50,$62,$28,$26,$00,$20,$22,$01,$07,$67,$08
mostbl_VDU_6845_mode_3
	FCB	$7F,$50,$62,$28,$1E,$02,$19,$1B,$01,$09,$67,$09
mostbl_VDU_6845_mode_45
	FCB	$3F,$28,$31,$24,$26,$00,$20,$22,$01,$07,$67,$08
mostbl_VDU_6845_mode_6
	FCB	$3F,$28,$31,$24,$1E,$02,$19,$1B,$01,$09,$67,$09
mostbl_VDU_6845_mode_7
	FCB	$3F,$28,$33,$24,$1E,$02,$19,$1B,$93,$12,$72,$13
;; ----------------------------------------------------------------------------
;; VDU ROUTINE VECTOR ADDRESSES !!!!!ADDRESSES!!!!
mostbl_VDU_ROUTINE_VECTOR_ADDRESSES
	FDB	x_draw_line_main_right				;	C4AA
	FDB	x_draw_line_main_up				;	C4AC
;; ----------------------------------------------------------------------------
;; VDU ROUTINE BRANCH VECTOR ADDRESS LO !!!!!ADDRESSES!!!!
;;mostbl_VDU_ROUTINE_BRANCH_VECTOR_ADDRESS_LO
;;	FCB	x_horizontal_scan_module_right % 256, x_horizontal_scan_module_left % 256, x_vertical_scan_module_up % 256, x_vertical_scan_module_dn % 256			;	C4AE
;; VDU ROUTINE BRANCH VECTOR ADDRESS HI !!!!!ADDRESSES!!!!
;;mostbl_VDU_ROUTINE_BRANCH_VECTOR_ADDRESS_HI
;;	FCB	x_horizontal_scan_module_right / 256, x_horizontal_scan_module_left / 256, x_vertical_scan_module_up / 256, x_vertical_scan_module_dn / 256			;	C4B2
mostbl_VDU_ROUTINE_BRANCH_VECTOR_ADDRESS
	FDB	x_horizontal_scan_module_right, x_horizontal_scan_module_left, x_vertical_scan_module_up, x_vertical_scan_module_dn
;; TELETEXT CHARACTER CONVERSION TABLE
mostbl_TTX_CHAR_CONV
	FCB	$23,$5F,$60,$23			;	C4B6
;; SOFT CHARACTER RAM ALLOCATION
mostbl_SOFT_CHARACTER_RAM_ALLOCATION
	FCB	$04,$05,$06,$00,$01,$02		;	C4BA

mc_logo
	FCB	$03,$0C,$10,$24,$4E,$4E,$8F,$9B
	FCB	$80,$60,$10,$48,$E4,$E4,$E2,$B2
	FCB	$91,$51,$50,$20,$10,$0C,$03,$00
	FCB	$12,$14,$14,$08,$10,$60,$80,$00
mc_logo_0
	FCB	$00,$03,$0C,$30,$60,$61,$C3,$C6
	FCB	$3F,$C0,$20,$70,$F8,$FC,$8C,$03
	FCB	$F8,$07,$08,$1C,$3E,$7F,$C3,$80
	FCB	$00,$80,$60,$18,$0C,$0C,$86,$C6

	FCB	$CC,$68,$68,$30,$0C,$03,$00,$00
	FCB	$01,$00,$00,$00,$00,$C0,$3F,$00
	FCB	$00,$00,$00,$00,$00,$07,$F8,$00
	FCB	$66,$2C,$2C,$18,$60,$80,$00,$00

prTODO
	DEBUGPR2	"TODO HALT: ", 1
	rts
;; ----------------------------------------------------------------------------
mos_VDU_WRCH
	ldb	sysvar_VDU_Q_LEN		;	C4C0
	bne	mos_VDU_WRCH_add_to_Q		;	C4C3
	tim	#$40, zp_vdu_status
;;	ldb	#$40
;;	bitb	zp_vdu_status			;	C4C5
	beq	mos_VDU_WRCH_sk_nocurs
	jsr	x_start_curs_edit				;	C4C9
	jsr	x_set_up_write_cursor		;	C4CC
	bmi	mos_VDU_WRCH_sk_nocurs				;	C4CF
	cmpa	#$0D				;	C4D1
	bne	mos_VDU_WRCH_sk_nocurs				;	C4D3
	jsr	x_cancel_cursor_edit				;	C4D5
mos_VDU_WRCH_sk_nocurs
	cmpa	#$7F				;	C4D8
	beq	x_read_linkaddresses_and_number_of_parameters1;	C4DA
	cmpa	#$20				;	C4DC
	blo	x_read_linkaddresses_and_number_of_parameters2;	C4DE
	tst	zp_vdu_status			;	C4E0
	bmi	mos_VDU_WRCH_sk_novdu				;	C4E2
	jsr	render_char				;	C4E4
	jsr	mos_VDU_9			;	C4E7
mos_VDU_WRCH_sk_novdu
	jmp	x_main_exit_routine		;	LC4EA
;; ----------------------------------------------------------------------------
;; read linkFDBesses and number of parameters???
x_read_linkaddresses_and_number_of_parameters1
	lda	#$20				;	C4ED
;; read linkFDBesses and number of parameters???
x_read_linkaddresses_and_number_of_parameters2
	tfr	A,B				;	C4EF
	ldx	#mostbl_vdu_q_lengths
	lda	B,X
	aslb
	ldx	#mostbl_vdu_entry_points
	ldx	B,X
	lsrb
	tsta
	beq	x_vdu_no_q
	sta	sysvar_VDU_Q_LEN
	stx	vduvar_VDU_VEC_JMP
	tim	#$40, zp_vdu_status
;;;	ldb	#$40
;;;	bitb	zp_vdu_status
	bne	LC52F				; cursor editing in force
	andcc	#~CC_C
LC511RTS
	rts
;; ----------------------------------------------------------------------------
;; B, sysvar_VDU_Q_LEN are 2's complement of number of parameters. **{NETV=>vduvar_Q+5-$100}
mos_VDU_WRCH_add_to_Q
	ldx	#vduvar_VDU_Q_END
	sta	B,X				;	C512
	incb					;	C515
	stb	sysvar_VDU_Q_LEN		;	C516
	bne	LC532				;	C519
	tim	#$C0, zp_vdu_status
;;;	lda	zp_vdu_status			;	C51B
;;;	bita	#$C0
	bmi	mos_exec_vdu1			; bit 7 set - VDU disabled
	bne	LC526				; bit 6 set - cursor editing in force
	jsr	[vduvar_VDU_VEC_JMP]
	andcc	#~CC_C				;	C524
	rts					;	C525
; ----------------------------------------------------------------------------
LC526	jsr	x_start_curs_edit				;	C526
	jsr	x_set_up_write_cursor		;	C529
	jsr	[vduvar_VDU_VEC_JMP]
LC52F	jsr	x_cursor_editing_routines	;	C52F
LC532	andcc	#~CC_C				;	C532
	rts					;	C533
;; ----------------------------------------------------------------------------
;; 1 parameter required;	 
mos_exec_vdu1
	TODOSKIP "Printer character skip"		; printer rediretcted here???
;;	ldb	vduvar_VDU_VEC_JMP		; get top byte of jump
;;	cmpb	#$C5				; not used like this any more!
	bne	LC532				;	C539
mos_VDU_1
	ldb	zp_vdu_status
	lsrb
	bcc	LC511RTS
	jmp	LE11E				; send to printer
;; ----------------------------------------------------------------------------
;; if explicit linkFDBess found, no parameters
;x_if_explicit_linkFDBess_found_no_parameters:
x_vdu_no_q
	stx	vduvar_VDU_VEC_JMP		;	C545

	; set C if char > 8 and < 13

	eorb	#$FF
	cmpb	#$F7
	eorb	#$FF
	bcc	LC553
	cmpb	#$13

LC553	tst	zp_vdu_status			;	C553
	bmi	x_reenable_vdu_if_vdu6		;	vdu disabled
	pshs	CC
	jsr	[vduvar_VDU_VEC_JMP]
	puls	CC				;	C55B
	bcc	LC561				;	C55C
;; main exit routine
x_main_exit_routine
	lda	zp_vdu_status			;	C55E
	lsra					;	C560
LC561	tim	#$40, zp_vdu_status
;;;	ldb	#$40
;;;	bitb	zp_vdu_status
	beq	LC511RTS			;	C563
;; cursor editing routines
x_cursor_editing_routines
	jsr	x_start_cursor_edit_qry				;	C565

x_start_curs_edit				;LC568
	pshs	A,CC
	ldx	#$318				;	C56A
	ldy	#$364				;	C56C
	jsr	x_exchange_2atY_with_2atX	;	C56E
	jsr	x_set_up_displayaddress		;	C571
	ldx	zp_vdu_top_scanline
	jsr	x_set_cursor_position_X		;	C574
	lda	zp_vdu_status			;	C577
	eora	#$02				; toggle scrolling disabled
	sta	zp_vdu_status			;	C57B
	puls	A,CC,PC

;; ----------------------------------------------------------------------------
x_reenable_vdu_if_vdu6	
	eorb	#$06
	bne	LC58Crts
	lda	#$7F
	bra	mos_VDU_and_A_vdustatus

;; check text cursor in use
x_check_text_cursor_in_use
	lda	zp_vdu_status
	anda	#$20
LC58Crts
	rts					;	C58C
;; ----------------------------------------------------------------------------
;; SET PAGED MODE  VDU 14;  
mos_VDU_14
	clr	sysvar_SCREENLINES_SINCE_PAGE	;	C58F
	lda	#$04				;	C592
	bra	x_ORA_with_vdu_status				;	C594
;; VDU 2 PRINTER ON
mos_VDU_2
	TODOSKIP "VDU 2"
	rts
;	jsr	LE1A2				;	C596
;	lda	#$94				;	C599
;; no parameters
mos_VDU_21
	lda	#$80
x_ORA_with_vdu_status
	ora	zp_vdu_status			;	C59D
	bra	LC5AA				;	C59F
;; No parameters
mos_VDU_3
	TODOSKIP "VDU 3"
	rts
;	jsr	LE1A2				;	C5A1
;	lda	#$0A				;	C5A4
;; VDU 15 paged mode off	  No parameters
mos_VDU_15
	lda	#~$04
mos_VDU_and_A_vdustatus
	anda	zp_vdu_status			;	C5A8
LC5AA	sta	zp_vdu_status			;	C5AA
LC5ACrts	
	rts					;	C5AC
;; ----------------------------------------------------------------------------
;; VDU 4 select Text Cursor  No parameters;  
mos_VDU_4
	lda	vduvar_PIXELS_PER_BYTE_MINUS1
	beq	LC5ACrts
	jsr	x_crtc_reset_cursor
	lda	#$DF
	bra	mos_VDU_and_A_vdustatus
;; VDU 5 set graphics cursor
mos_VDU_5
	lda	vduvar_PIXELS_PER_BYTE_MINUS1
	beq	LC5ACrts
	lda	#$20
	jsr	x_crtc_set_cursor
	bra	x_ORA_with_vdu_status
;; VDU 8	 CURSOR LEFT	 NO PARAMETERS
mos_VDU_8
	jsr	x_check_text_cursor_in_use	;	C5C5
	bne	x_cursor_left_and_down_with_graphics_cursor_in_use;	C5C8
	dec	vduvar_TXT_CUR_X		;	C5CA
	ldb	vduvar_TXT_CUR_X		;	C5CD
	cmpb	vduvar_TXT_WINDOW_LEFT		;	C5D0
	bmi	x_execute_wraparound_left_up	;	C5D3
	ldb	vduvar_6845_CURSOR_ADDR	+ 1	;	C5D5
	subb	vduvar_BYTES_PER_CHAR		;	C5D9
	lda	vduvar_6845_CURSOR_ADDR		;	C5DD
	sbca	#$00				;	C5E0
	cmpa	vduvar_SCREEN_BOTTOM_HIGH	;	C5E2
	bhs	LC5EA				;	C5E5
	adda	vduvar_SCREEN_SIZE_HIGH		;	C5E7
LC5EA	tfr	D,X				;	C5EA
	jmp	mos_set_cursor_X		;	C5EB
;; ----------------------------------------------------------------------------
;; execute wraparound left-up
x_execute_wraparound_left_up
	lda	vduvar_TXT_WINDOW_RIGHT		;	C5EE
	sta	vduvar_TXT_CUR_X		;	C5F1
;; cursor up
x_cursor_up
	dec	sysvar_SCREENLINES_SINCE_PAGE	;	C5F4
	bpl	LC5FC				;	C5F7
	inc	sysvar_SCREENLINES_SINCE_PAGE	;	C5F9
LC5FC	ldb	vduvar_TXT_CUR_Y		;	C5FC
	cmpb	vduvar_TXT_WINDOW_TOP		;	C5FF
	beq	x_cursor_at_top_of_window	;	C602
	dec	vduvar_TXT_CUR_Y		;	C604
	jmp	x_setup_displayaddress_and_cursor_position
;; ----------------------------------------------------------------------------
;; cursor at top of window
x_cursor_at_top_of_window
	andcc	#~CC_C
	jsr	x_move_text_cursor_to_next_line ;	C60B
	tim	#$08, zp_vdu_status
;;;	lda	#$08				;	C60E
;;;	bita	zp_vdu_status			;	C610
	bne	LC619				;	C612
	jsr	x_adjust_screen_RAM_addresses	;	C614
	bne	LC61C				;	C617
LC619	jsr	LCDA4				;	C619
LC61C	jmp	x_clear_a_line_then_setup_displayaddress_and_cursor_position				;	C61C
;; ----------------------------------------------------------------------------
;; cursor left and down with graphics cursor in use
x_cursor_left_and_down_with_graphics_cursor_in_use
	clrb				;	C61F
;; cursor down with graphics in use; B=2 for vertical or 0 for horizontal 
x_cursor_down_with_graphics_in_use
	stb	zp_vdu_wksp + 1			;	C621
	jsr	x_Check_window_limits		;	C623
	ldb	zp_vdu_wksp + 1			;	C626
	ldx	#vduvar_GRA_CUR_INT + 1
	lda	b,x				;	C629
	suba	#$08				;	C62C
	sta	b,x				;	C62E
	bcc	LC636				;	C631
	decb
	dec	b,x				;	C633
LC636	lda	zp_vdu_wksp			;	C636
	bne	jmp_cal_ext_coors				;	C638
	jsr	x_Check_window_limits		;	C63A
	beq	jmp_cal_ext_coors				;	C63D
	ldy	#vduvar_GRA_WINDOW_RIGHT + 1
	ldb	zp_vdu_wksp+1			;	C63F
	lda	b,y				;	C641
	cmpb	#$01				;	C644
	bhs	LC64A				;	C646
	suba	#$06				;	C648		; CHECK!
LC64A	sta	b,x				;	C64A
	dec	b
	lda	b,y				;	C64D
	sbca	#$00				;	C650
	sta	b,x				;	C652
	incb
	beq	LC660				;	C656
jmp_cal_ext_coors				; LC658
	jmp	x_calculate_external_coordinates_from_internal_coordinates;	C658
;; ----------------------------------------------------------------------------
;; VDU 11 Cursor Up    No Parameters
mos_VDU_11
	jsr	x_check_text_cursor_in_use	;	C65B
	beq	x_cursor_up			;	C65E
LC660	ldb	#$02				;	C660
	bra	x_graphic_cursor_up_Beq2	;	C662
;; VDU 9 Cursor right	No parameters
mos_VDU_9
	lda	zp_vdu_status			;	C664
	anda	#$20				;	C666
	bne	x_graphic_cursor_right		;	C668
	ldb	vduvar_TXT_CUR_X		;	C66A
	cmpb	vduvar_TXT_WINDOW_RIGHT		;	C66D
	bhs	x_text_cursor_down_and_right	;	C670
	inc	vduvar_TXT_CUR_X		;	C672
	ldx	vduvar_6845_CURSOR_ADDR
	ldb	vduvar_BYTES_PER_CHAR		;	C678
	abx
	jmp	mos_set_cursor_X		;	C681
;; ----------------------------------------------------------------------------
;; : text cursor down and right
x_text_cursor_down_and_right
	lda	vduvar_TXT_WINDOW_LEFT
	sta	vduvar_TXT_CUR_X
;; : text cursor down
x_text_cursor_down
	ANDCC	#~CC_C
	jsr	x_control_scrolling_in_paged_mode_2
	ldb	vduvar_TXT_CUR_Y
	cmpb	vduvar_TXT_WINDOW_BOTTOM
	bhs	LC69B
	inc	vduvar_TXT_CUR_Y
	bra	x_setup_displayaddress_and_cursor_position
LC69B	jsr	x_move_text_cursor_to_next_line
	tim	#$08, zp_vdu_status
;;;	lda	#$08
;;;	bita	zp_vdu_status
	bne	LC6A9
	jsr	x_adjust_screen_RAM_addresses_one_line_scroll
	bra	x_clear_a_line_then_setup_displayaddress_and_cursor_position
LC6A9	jsr	x_execute_upward_scroll
x_clear_a_line_then_setup_displayaddress_and_cursor_position
	jsr	x_clear_a_line
x_setup_displayaddress_and_cursor_position
	jsr	x_set_up_displayaddress
	ldx	zp_vdu_top_scanline
	jmp	x_set_cursor_position_X

;; graphic cursor right
x_graphic_cursor_right
	clrb
;; graphic cursor up  (B=2)
x_graphic_cursor_up_Beq2
	stb	zp_vdu_wksp+1			;	C6B6
	jsr	x_Check_window_limits		;	C6B8
	ldb	zp_vdu_wksp+1			;	C6BB
	ldx	#vduvar_GRA_CUR_INT + 1
	lda	b,x				;	C6BE
	adda	#$08				;	C6C1
	sta	b,x				;	C6C3
	bcc	LC6CB				;	C6C6
	decb
	inc	b,x				;	C6C8
LC6CB	lda	zp_vdu_wksp			;	C6CB
	bne	jmp_cal_ext_coors		;	C6CD
	jsr	x_Check_window_limits		;	C6CF
	beq	jmp_cal_ext_coors		;	C6D2
	ldb	zp_vdu_wksp+1			;	C6D4
	ldy	#vduvar_GRA_WINDOW_LEFT
	lda	b,x				;	C6D6
	cmpb	#$01				;	C6D9
	blo	LC6DF				;	C6DB
	adda	#$06				;	C6DD
LC6DF	sta	b,x				;	C6DF
	decb
	lda	b,y				;	C6E2
	adca	#$00				;	C6E5
	sta	b,x				;	C6E7
	incb					;	C6EA
	beq	LC6F5				;	C6EB
	jmp	x_calculate_external_coordinates_from_internal_coordinates;	C6ED
;; ----------------------------------------------------------------------------
;; VDU 10  Cursor down	  No parameters
mos_VDU_10
	jsr	x_check_text_cursor_in_use	;	C6F0
	beq	x_text_cursor_down		;	C6F3
LC6F5	ldb	#$02				;	C6F5
	jmp	x_cursor_down_with_graphics_in_use;	C6F7
;; ----------------------------------------------------------------------------
;; VDU 28   define text window	      4 parameters; parameters are set up thus ; 0320  P1 left margin ; 0321  P2 bottom margin ; 0322  P3 right margin ; 0323  P4 top margin ; Note that last parameter is always in 0323 
mos_VDU_28
	ldb	vduvar_MODE
	ldx	#mostbl_vdu_window_bottom+1
	lda	vduvar_VDU_Q_END - 3
	cmpa	vduvar_VDU_Q_END - 1
	blo	LC758rts
	cmpa	b,x
	bhi	LC758rts
	lda	vduvar_VDU_Q_END - 2
	ldx	#mostbl_vdu_window_right
	cmpa	b,x
	bhi	LC758rts
	suba	vduvar_VDU_Q_END - 4
	bmi	LC758rts
	jsr	LCA88_newAPI
	lda	#$08
	jsr	x_ORA_with_vdu_status
	ldx	#vduvar_VDU_Q_END - 4
	ldy	#vduvar_TXT_WINDOW_LEFT
	jsr	copy4fromXtoY
	jsr	x_check_text_cursor_in_window_setup_display_addr
	bcs	mos_VDU_30
LC732_set_cursor_position
	ldx	zp_vdu_top_scanline				; CHECK!
	jmp	x_set_cursor_position_X
;; ----------------------------------------------------------------------------
;; OSWORD 9    read a pixel; on entry &EF=A=9 ; &F0=X=low byte of parameter blockFDBess ; &F1=Y=high byte of parameter blockFDBess ; PARAMETER BLOCK ; bytes 0,1 X coordinate, bytes 2,3 Y coordinate ; EXIT with result in byte 4 =&FF if point was of screen
;mos_OSWORD_9:
;	ldy	#$03				;	C735
;LC737:	lda	(zp_mos_OSBW_X),y		;	C737
;	sta	vduvar_TEMP_8,y		;	C739
;	dey					;	C73C
;	bpl	LC737				;	C73D
;	lda	#$28				;	C73F
;	jsr	x_pixel_reading			;	C741
;	ldy	#$04				;	C744
;	bne	LC750				;	C746
;; OSWORD 11	  read pallette; on entry &EF=A=11 ; &F0=X=low byte of parameter blockFDBess ; &F1=Y=high byte of parameter blockFDBess ; PARAMETER BLOCK ; bytes 0,logical colour to read		       ; EXIT with result in  4 bytes:-0 logical colour,1
;mos_OSWORD_11:
;	and	vduvar_COL_COUNT_MINUS1		;	C748
;	tax					;	C74B
;	lda	vduvar_PALLETTE,x		;	C74C
;LC74F:	iny					;	C74F
;LC750:	sta	(zp_mos_OSBW_X),y		;	C750
;	lda	#$00				;	C752
;	cpy	#$04				;	C754
;	bne	LC74F				;	C756
LC758rts
	rts					;	C758
;; ----------------------------------------------------------------------------
;; VDU 12  Clear text Screen		  0 parameters;	 
mos_VDU_12
	jsr	x_check_text_cursor_in_use
	bne	x_mos_home_CLG
	lda	zp_vdu_status
	anda	#$08
	lbeq	LCBC1_clear_whole_screen
LC767	ldb	vduvar_TXT_WINDOW_TOP
LC76A	stb	vduvar_TXT_CUR_Y
	jsr	x_clear_a_line
	ldb	vduvar_TXT_CUR_Y
	cmpb	vduvar_TXT_WINDOW_BOTTOM
	incb
	bcc	LC76A
;; VDU 30  Home cursor			  0  parameters
mos_VDU_30
	jsr	x_check_text_cursor_in_use
	beq	LC781
	jmp	x_home_graphics_cursor
;; ----------------------------------------------------------------------------
LC781	clr	vduvar_VDU_Q_END - 1
	clr	vduvar_VDU_Q_END - 2
;; VDU 31  Position text cursor		  2  parameters; 0322 = X coordinate ; 0323 = Y coordinate 
mos_VDU_31
	jsr	x_check_text_cursor_in_use
	bne	LC758rts
	jsr	LC7A8
	lda	vduvar_VDU_Q_END - 2
	adda	vduvar_TXT_WINDOW_LEFT
	sta	vduvar_TXT_CUR_X
	lda	vduvar_VDU_Q_END - 1
	adda	vduvar_TXT_WINDOW_TOP
	sta	vduvar_TXT_CUR_Y
	jsr	x_check_text_cursor_in_window_setup_display_addr
	bcc	LC732_set_cursor_position
LC7A8	ldx	#vduvar_TXT_CUR_X
	ldy	#vduvar_TEMP_8
	jmp	x_exchange_2atY_with_2atX
;; ----------------------------------------------------------------------------
;; VDU  13	  Carriage  Return	  0 parameters
mos_VDU_13
	jsr	x_check_text_cursor_in_use	;	C7AF
	beq	LC7B7				;	C7B2
	jmp	x_set_graphics_cursor_to_left_hand_column;	C7B4
LC7B7	jsr	x_cursor_to_window_left				;	C7B7
	jmp	x_setup_displayaddress_and_cursor_position				;	C7BA
;; ----------------------------------------------------------------------------
x_mos_home_CLG						; LC7BD
	jsr	x_home_graphics_cursor			


;; VDU 16 clear graphics screen		  0 parameters
mos_VDU_16
	lda	vduvar_PIXELS_PER_BYTE_MINUS1		; pixels per byte
	beq	LC7F8rts				; if 0 current mode has no graphics so exit
	lda	vduvar_GRA_BACK				; Background graphics colour
	ldb	vduvar_GRA_PLOT_BACK			; background graphics plot mode (GCOL n)
	jsr	x_set_colour_masks_newAPI		; set graphics byte mask in &D4/5
	ldx	#vduvar_GRA_WINDOW_LEFT			; graphics window
	ldy	#vduvar_TEMP_8				; workspace
	jsr	copy8fromXtoY				; set(300/7+Y) from (300/7+X)
	lda	vduvar_GRA_WINDOW_TOP + 1		; graphics window top lo.
	suba	vduvar_GRA_WINDOW_BOTTOM + 1		; graphics window bottom lo
	inca						; increment
	sta	vduvar_GRA_WKSP				; and store in workspace (this is line count)
1	ldx	#vduvar_TEMP_8 + 4			; right
	ldy	#vduvar_TEMP_8				; left
	jsr	x_vdu_clear_gra_line_newAPI		; clear line
	lda	vduvar_TEMP_8 + 7			; decrement window top in pixels
	bne	2F					; 
	dec	vduvar_TEMP_8 + 6			; 
2	dec	vduvar_TEMP_8 + 7			; 
	dec	vduvar_GRA_WKSP				; decrement line count
	bne	1B					; if <>0 then do it again
LC7F8rts	rts					; exit
;; ----------------------------------------------------------------------------
;; COLOUR; parameter in &0323 
mos_VDU_17	; COLOUR
	ldb	#$00				;	C7F9
	bra	LC7FF				;	C7FB
;; GCOL; parameters in 323,322 
mos_VDU_18	; GCOL
	ldb	#$02
LC7FF	lda	vduvar_VDU_Q_END - 1
	bpl	LC805
	incb
LC805	anda	vduvar_COL_COUNT_MINUS1
	sta	zp_vdu_wksp
	lda	vduvar_COL_COUNT_MINUS1
	beq	LC82B
	anda	#$07
	adda	zp_vdu_wksp
	ldx	#mostbl_2_colour_pixmasks-1
	lda	a,x
	ldy	#vduvar_TXT_FORE
	sta	b,y
	cmpb	#$02
	bhs	LC82C
	lda	vduvar_TXT_FORE
	coma
	sta	zp_vdu_txtcolourEOR
	eora	vduvar_TXT_BACK
	sta	zp_vdu_txtcolourOR
LC82B	rts
LC82C	lda	vduvar_VDU_Q_END - 2
	ldy	vduvar_GRA_FORE
	sta	b,y
	rts
;; ----------------------------------------------------------------------------
LC833	lda	#$20				;	C833
	sta	vduvar_TXT_BACK			;	C835
	rts					;	C838
;; ----------------------------------------------------------------------------
;; VDU 20	  Restore default colours	  0 parameters;	 
mos_VDU_20
	ldb	#$05				;	C839
	lda	#$00				;	C83B
	ldx	#vduvar_TXT_FORE
LC83D	sta	b,x				;	C83D
	decb					;	C840
	bpl	LC83D				;	C841
	ldb	vduvar_COL_COUNT_MINUS1		;	C843
	beq	LC833				;	C846
	lda	#$FF				;	C848
	cmpb	#$0F				;	C84A
	bne	LC850				;	C84C
	lda	#$3F				;	C84E
LC850	sta	vduvar_TXT_FORE			;	C850
	sta	vduvar_GRA_FORE			;	C853
	eora	#$FF				;	C856
	sta	zp_vdu_txtcolourOR		;	C858
	sta	zp_vdu_txtcolourEOR		;	C85A
	stb	vduvar_VDU_Q_END - 5		;	C85C
	cmpb	#$03				;	C85F
	beq	x_4_colour_mode			;	C861
	blo	LC885				;	C863
	stb	vduvar_VDU_Q_END - 4		;	C865
LC868	jsr	mos_VDU_19			;	C868
	dec	vduvar_VDU_Q_END - 4		;	C86B
	dec	vduvar_VDU_Q_END - 5		;	C86E
	bpl	LC868				;	C871
	rts					;	C873
;; ----------------------------------------------------------------------------
;; 4 colour mode
x_4_colour_mode
	ldb	#$07				;	C874
	stb	vduvar_VDU_Q_END - 4		;	C876
LC879	jsr	mos_VDU_19			;	C879
	lsr	vduvar_VDU_Q_END - 4		;	C87C
	dec	vduvar_VDU_Q_END - 5		;	C87F
	bpl	LC879				;	C882
	rts					;	C884
; ----------------------------------------------------------------------------
LC885	ldb	#$07				;	C885
	jsr	LC88F				;	C887
	ldb	#$00				;	C88A
	stb	vduvar_VDU_Q_END - 5;	C88C
LC88F	stb	vduvar_VDU_Q_END - 4			;	C88F
; VDU 19   define logical colours		  5 parameters; &31F=first parameter logical colour ; &320=second physical colour 
mos_VDU_19
	pshs	CC				; save flags
	SEI					; and disable interrupts
	ldb	vduvar_VDU_Q_END - 5		; b <= logical colour
	andb	vduvar_COL_COUNT_MINUS1		; 
	pshs	B
	lda	vduvar_VDU_Q_END - 4		; a <= physical colour
LC89E	anda	#$0F				; 
	ldx	#vduvar_PALLETTE		;
	sta	b,x				; store in saved palette TODO: where to store RGB? Don't store?

	ldb	vduvar_COL_COUNT_MINUS1		; a <= colours - 1

	; get left most pixel mask for this mode
	lda	#$80
	asrb
	asrb
	bcc	1F
	ora	#$08
	asrb
	bcc	1F
	ora	#$22

1	ldb	vduvar_COL_COUNT_MINUS1			; a <= colours - 1
	andb	#$07
	addb	,S+					; get back logical colour from stack
	ldx	#mostbl_2_colour_pixmasks-1
	anda	b,x					; palette entry to set
	sta	sheila_RAMDAC_ADDR_WR


	lda	vduvar_VDU_Q_END - 4			; a <= physical colour
	bita	#$10
	bne	mos_VDU_19_RGB

	jsr	onepalent				; normal colour
	lda	vduvar_VDU_Q_END - 4			; a <= physical colour
	bita	#$8
	beq	1F
	coma						; make flash colour complement
1	jsr	onepalent

	puls	CC,PC					;	C8DE
mos_VDU_19_RGB
	ldb	#2
	bita	#$01
	beq	1F					; if set then do flash only
	decb
	inc	sheila_RAMDAC_ADDR_WR
1	ldx	#vduvar_VDU_Q_END - 3
	jsr	2F
	jsr	2F
	jsr	2F
	decb
	bne	1B
	puls CC,PC
2	lda	,X+
	asra
	asra
	sta	sheila_RAMDAC_VAL
	rts
onepalent
	ldb	#3
	sta	zp_mos_OS_wksp2
1	clra
	ror	zp_mos_OS_wksp2
	bcc	2F
	deca
2	sta	sheila_RAMDAC_VAL
	decb
	bne	1B
	rts

;; ----------------------------------------------------------------------------
;; OSWORD 12    WRITE PALLETTE; on entry X=&F0:Y=&F1:YX points to parameter block ; byte 0 = logical colour;  byte 1 physical colour; bytes 2-4=0 
;mos_OSWORD_12:
;	php					;	C8E0
;	and	vduvar_COL_COUNT_MINUS1		;	C8E1
;	tax					;	C8E4
;	iny					;	C8E5
;	lda	(zp_mos_OSBW_X),y		;	C8E6
;	jmp	LC89E				;	C8E8
;; ----------------------------------------------------------------------------
;; VDU	  22		  Select Mode	1 parameter; parameter in &323 
mos_VDU_22
	lda	vduvar_VDU_Q_END - 1			;	C8EB
	jmp	mos_VDU_set_mode		;	C8EE
;; ----------------------------------------------------------------------------
;; VDU 23 Define characters		  9 parameters; parameters are:- ; 31B character to define ; 31C to 323 definition 
mos_VDU_23
	TODOSKIP	"VDU 23"
	rts
;	lda	vduvar_VDU_Q_END - 9;	C8F1
;	cmp	#$20				;	C8F4
;	bcc	x_set_CRT_controller		;	C8F6
;	pha					;	C8F8
;	lsr	a				;	C8F9
;	lsr	a				;	C8FA
;	lsr	a				;	C8FB
;	lsr	a				;	C8FC
;	lsr	a				;	C8FD
;	tax					;	C8FE
;	lda	mostbl_VDU_pix_mask_2colour,x	;	C8FF
;	bit	vduvar_EXPLODE_FLAGS		;	C902
;	bne	LC927				;	C905
;	ora	vduvar_EXPLODE_FLAGS		;	C907
;	sta	vduvar_EXPLODE_FLAGS		;	C90A
;	txa					;	C90D
;	and	#$03				;	C90E
;	clc					;	C910
;	adc	#$BF				;	C911
;	sta	zp_vdu_wksp+5			;	C913
;	lda	vduvar_EXPLODE_FLAGS,x		;	C915
;	sta	zp_vdu_wksp+3			;	C918
;	ldy	#$00				;	C91A
;	sty	zp_vdu_wksp+2			;	C91C
;	sty	zp_vdu_wksp+4			;	C91E
;LC920:	lda	(zp_vdu_wksp+4),y		;	C920
;	sta	(zp_vdu_wksp+2),y		;	C922
;	dey					;	C924
;	bne	LC920				;	C925
;LC927:	pla					;	C927
;	jsr	x_calc_pattern_addr_for_given_char;	C928
;	ldy	#$07				;	C92B
;LC92D:	lda	$031C,y				;	C92D
;	sta	(zp_vdu_wksp+4),y		;	C930
;	dey					;	C932
;	bpl	LC92D				;	C933
;	rts					;	C935
;; ----------------------------------------------------------------------------
;	pla					;	C936
;LC937:	rts					;	C937
;; ----------------------------------------------------------------------------
;; VDU EXTENSION
x_VDU_EXTENSION
	lda	vduvar_VDU_Q_END - 5		;	C938
	CLC					;	C93B

jmp_VDUV					; LC93C
	jmp	[VDUV]				;	C93C
;; ----------------------------------------------------------------------------
;; set CRT controller
x_set_CRT_controller
	cmpa	#$01				;	C93F
	blo	LC958				; VDU 23,0,R,X - set (R)eg to (X) in CRTC
	bne	jmp_VDUV			;	C943
	ASSERT "Unexpected in x_set_CRT_controller"
;	jsr	x_check_text_cursor_in_use	;	C945
;	bne	LC937				;	C948
;	lda	#$20				;	C94A
;	ldy	vduvar_VDU_Q_END - 8		;	C94C
;	beq	x_crtc_set_cursor		;	C94F
x_crtc_reset_cursor				; LC951
	lda	vduvar_CUR_START_PREV		;	C951
x_crtc_set_cursor
	ldb	#$0A				;	C954
	bra	LC985				;	C956
LC958
	lda	vduvar_VDU_Q_END - 7		;	C958
	ldb	vduvar_VDU_Q_END - 8		;	C95B
mos_set_6845_regBtoA
	cmpb	#$07				;	C95E
	blo	LC985				;	C960
	bne	LC967				;	C962
	adda	oswksp_VDU_VERTADJ		;	C964
LC967	cmpb	#$08				;	C967
	bne	LC972				;	C969
	tsta					;	C96B
	bmi	LC972				;	C96D
	eora	oswksp_VDU_INTERLACE		;	C96F
LC972	cmpb	#$0A				;	C972
	bne	LC985				;	C974
	sta	vduvar_CUR_START_PREV		;	C976
	tfr	a,b				;	C979
	lda	zp_vdu_status			;	C97A
	anda	#$20				;	C97C
	pshs	CC				;	C97E
	tfr	b,a				;	C97F
	ldb	#$0A				;	C980
	puls	CC				;	C982
	bne	LC98B				;	C983
LC985	stb	sheila_CRTC_reg			;	C985
	sta	sheila_CRTC_rw			;	C988
LC98B	rts					;	C98B
;; ----------------------------------------------------------------------------
;; VDU 25	  PLOT			  5 parameters;	 
mos_VDU_25
	tst	vduvar_PIXELS_PER_BYTE_MINUS1	;pixels per byte
	beq	x_VDU_EXTENSION			;if no graphics available go via VDU Extension 
	jmp	x_PLOT_ROUTINES_ENTER_HERE	;else enter Plot routine at D060
;; ----------------------------------------------------------------------------
;; adjust screen RAMFDBesses
x_adjust_screen_RAM_addresses
	ldd	vduvar_6845_SCREEN_START	
	jsr	x_subtract_bytes_per_line_from_D
	bcc	LC9B3
	adda	vduvar_SCREEN_SIZE_HIGH
	bcc	LC9B3
x_adjust_screen_RAM_addresses_one_line_scroll	
	ldd	vduvar_BYTES_PER_ROW
	addd	vduvar_6845_SCREEN_START
	bpl	LC9B3
	suba	vduvar_SCREEN_SIZE_HIGH
LC9B3	std	vduvar_6845_SCREEN_START
	tfr	D,X
	lda	#$0C
	bra	x_set_6845_screenstart_from_X
;; VDU 26  set default windows		  0 parameters
mos_VDU_26
	clra
	ldb	#$2C
	ldx	#vduvar_GRA_WINDOW_LEFT
LC9C1	sta	b,x
	decb					;	C9C4
	bpl	LC9C1				;	C9C5
	lda	vduvar_MODE			;	C9C7
	m_tax
	lda	mostbl_vdu_window_right,x	;	C9CA
	sta	vduvar_TXT_WINDOW_RIGHT		;	C9CD
	jsr	LCA88_newAPI			;	C9D0
	lda	mostbl_vdu_window_bottom+1,x	;	C9D3
	sta	vduvar_TXT_WINDOW_BOTTOM	;	C9D6
	ldb	#$03				;	C9D9
	stb	vduvar_VDU_Q_END - 1			;	C9DB
	incb					;	C9DE
	stb	vduvar_VDU_Q_END - 3			;	C9DF
	dec	vduvar_VDU_Q_END - 2			;	C9E2
	dec	vduvar_VDU_Q_END - 4			;	C9E5
	jsr	mos_VDU_24			;	C9E8
	lda	#$F7				;	C9EB
	jsr	mos_VDU_and_A_vdustatus		;	C9ED
	ldx	vduvar_6845_SCREEN_START	;	C9F0
mos_set_cursor_X
	stx	vduvar_6845_CURSOR_ADDR		;	C9F6
	cmpx	#$8000
	blo	x_set_cursor_position_X
	pshs	D
	tfr	X,D
	suba	vduvar_SCREEN_SIZE_HIGH
	tfr	D,X
	puls	D
;; set cursor position
x_set_cursor_position_X
	stx	zp_vdu_top_scanline
	ldx	vduvar_6845_CURSOR_ADDR
	lda	#$0E
x_set_6845_screenstart_from_X			; LCA0E
	ldb	vduvar_MODE
	cmpb	#$07
	bhs	LCA27
	exg	X,D
	lsra
	rorb
	lsra
	rorb
	lsra
	rorb
	exg	X,D
	bra	mos_stx_6845rA			;	CA24
;; ----------------------------------------------------------------------------
LCA27	
	exg	X,D
	suba	#$74				;	CA27
	eora	#$20				;	CA29
	exg	D,X
mos_stx_6845rA
	pshs	X
	ldb	,S+
	std	sheila_CRTC_reg
	inca
	ldb	,S+
	std	sheila_CRTC_reg
	puls	PC				;	CA38

db_endian_vdu_q_swap
	***********************************************
	* BODGE: endianness swap for VDU drivers      *
	* This is subject to change                   *
	*                                             *
	* workspace vars are all in big endian        *
	* Q is in little endian so swap all the bytes *
	* Y contain number of 16 bit params at end of *
	* Q to swap				      *
	***********************************************
	ldx	#vduvar_VDU_Q_END
1	ldd	,--X
	exg	A,B
	std	,X
	leay	-1,Y
	bne	1B
	rts


;; ----------------------------------------------------------------------------
;; VDU 24 Define graphics window		  8 parameters; &31C/D Left margin ; &31E/F Bottom margin ; &320/1 Right margin ; &322/3 Top margin 
mos_VDU_24

	ldy	#4
	jsr	db_endian_vdu_q_swap

* temporary equs to make things clearer
vduvar_VDU_Q_24_LEFT	equ	vduvar_VDU_Q_END - 8
vduvar_VDU_Q_24_BOTTOM	equ	vduvar_VDU_Q_END - 6
vduvar_VDU_Q_24_RIGHT	equ	vduvar_VDU_Q_END - 4
vduvar_VDU_Q_24_TOP	equ	vduvar_VDU_Q_END - 2
vduvar_TMP_CURSAVE	equ	vduvar_TEMP_8
vudvar_TMP_XY		equ	vduvar_TEMP_8 + 4


	jsr	x_exchange_310_with_328		; save current cursor value at vduvar_TEMP_8
	ldx	#vduvar_VDU_Q_24_LEFT
	ldy	#vudvar_TMP_XY
	jsr	x_coords_to_width_height	; calculate new width/height at TMP_XY
	ora	vudvar_TMP_XY			; A already contains to byte of height, or with top byte of width
	bmi	x_exchange_310_with_328		; if either negative, quit
	ldx	#vduvar_VDU_Q_24_RIGHT
	jsr	x_set_up_and_adjust_coords_atX
	ldx	#vduvar_VDU_Q_24_LEFT
	jsr	x_set_up_and_adjust_coords_atX
	lda	vduvar_VDU_Q_24_BOTTOM
	ora	vduvar_VDU_Q_24_TOP
	bmi	x_exchange_310_with_328		; if top or bottom -ve
	lda	vduvar_VDU_Q_24_TOP
	bne	x_exchange_310_with_328		; if top internal coords > 255
	LDX_B	vduvar_MODE			; screen mode
	lda	vduvar_VDU_Q_24_RIGHT		; right margin hi
	sta	zp_vdu_wksp			; store it
	lda	vduvar_VDU_Q_24_RIGHT + 1	; right margin lo
	lsr	zp_vdu_wksp			; /2
	rora					; A=A/2
	lsr	zp_vdu_wksp			; /2
	bne	x_exchange_310_with_328		; exchange 310/3 with 328/3 - its too big!
	rora					; A=A/2
	lsra					; A=A/2
	cmpa	mostbl_vdu_window_right,x	; text window right hand margin maximum
	beq	LCA7A				; if equal CA7A
	bpl	x_exchange_310_with_328		; exchange 310/3 with 328/3
LCA7A	ldy	#vduvar_GRA_WINDOW_LEFT
	ldx	#vduvar_VDU_Q_END - 8
	jsr	copy8fromXtoY			; save updated data

x_exchange_310_with_328
	ldx	#vduvar_GRA_CUR_EXT		; ==$310
	ldy	#vduvar_TEMP_8			; ==$328
	jmp	x_exchange_4atY_with_4atX

;; ----------------------------------------------------------------------------
LCA88_newAPI
	; old API (y == window width in chars - 1)
	; new API (a == window width in chars - 1)
	inca
	ldb	vduvar_BYTES_PER_CHAR
	mul
	std	vduvar_TXT_WINDOW_WIDTH_BYTES
LCAA1	rts					;	CAA1
;; ----------------------------------------------------------------------------
;; VDU 29  Set graphics origin			  4 parameters;	 
mos_VDU_29
	ldx	#vduvar_VDU_Q_END - 4
	ldy	#vduvar_GRA_ORG_EXT
	jsr	copy4fromXtoY
	jmp	x_calculate_external_coordinates_from_internal_coordinates
;; ----------------------------------------------------------------------------
;; VDU 32  (&7F)	  Delete			  0 parameters
mos_VDU_127					; LCAAC
		jsr	mos_VDU_8			;cursor left
		jsr	x_check_text_cursor_in_use	;A=0 if text cursor A=&20 if graphics cursor
		bne	LCAC7				;if graphics then CAC7
		ldb	vduvar_COL_COUNT_MINUS1		;number of logical colours less 1
		beq	LCAC2				;if mode 7 CAC2
		ldd	#mostbl_chardefs
		std	zp_vdu_wksp+4			;store in &DF (&DE) now points to C300 SPACE pattern
		jmp	LCFBF_renderchar2		;display a space
;; ----------------------------------------------------------------------------
LCAC2		lda	#$20				;A=&20
		jmp	x_convert_teletext_characters	;and return to display a space
;; ----------------------------------------------------------------------------
LCAC7		lda	#$7F				;for graphics cursor
		jsr	x_calc_pattern_addr_for_given_char;set up character definition pointers
		lda	vduvar_GRA_BACK			;Background graphics colour
		ldb	#$00				;plotmode = 0
		jmp	x_plot_char_gra_mode				;invert pattern data (to background colour)
;; ----------------------------------------------------------------------------
;; control scrolling in paged mode
x_control_scrolling_in_paged_mode		; LCAE0
	jsr	x_zero_paged_mode_counter
x_control_scrolling_in_paged_mode_2
	jsr	mos_OSBYTE_118
	bcc	LCAEA
	bmi	x_control_scrolling_in_paged_mode
LCAEA	lda	zp_vdu_status
	eora	#$04
	anda	#$46
	bne	LCB1Crts
	lda	sysvar_SCREENLINES_SINCE_PAGE
	bmi	LCB19
	lda	vduvar_TXT_CUR_Y
	cmpa	vduvar_TXT_WINDOW_BOTTOM
	blo	LCB19
	lsra
	lsra
	orcc	#CC_C
	adca	sysvar_SCREENLINES_SINCE_PAGE
	adca	vduvar_TXT_WINDOW_TOP
	cmpa	vduvar_TXT_WINDOW_BOTTOM
	blo	LCB19
	andcc	#~CC_C
LCB0E	jsr	mos_OSBYTE_118
	orcc	#CC_C
	bpl	LCB0E
;; zero paged mode  counter
x_zero_paged_mode_counter
	lda	#$FF				;	CB14
	sta	sysvar_SCREENLINES_SINCE_PAGE	;	CB16
LCB19	inc	sysvar_SCREENLINES_SINCE_PAGE	;	CB19
LCB1Crts
	rts					;	CB1C
;; ----------------------------------------------------------------------------
;; Set vdu vars to 0, called with mode in A
mos_VDU_init					; LCB1D
	pshs	A				;	CB1D
	ldx	#$7F				;	CB1E
	lda	#$00				;	CB20
	sta	zp_vdu_status			;	CB22
; clear vdu vars block
1	sta	vduvars_start-1,x		;	CB24
	leax	-1,x				;	CB27
	bne	1B				;	CB28
	jsr	mos_OSBYTE_20			;	CB2A
	puls	A				;	CB2D
	ldb	#$7F				;	CB2E
	stb	vduvar_MO7_CUR_CHAR		;	CB30
;; ??? Set mode ???
mos_VDU_set_mode
	tst	sysvar_RAM_AVAIL		;	CB33
	bmi	mos_VDU_set_mode_gt16Ksk	;	CB36
	ora	#$04				;	CB38
;; Skip if > 16k memory available
mos_VDU_set_mode_gt16Ksk
	anda	#$07
	sta	vduvar_MODE
	ldx	#mostbl_VDU_mode_colours_m1
	ldb	a,x
	stb	vduvar_COL_COUNT_MINUS1
	ldx	#mostbl_VDU_bytes_per_char
	ldb	a,x
	stb	vduvar_BYTES_PER_CHAR
	ldx	#mostbl_VDU_pixels_per_byte_m1
	ldb	a,x
	stb	vduvar_PIXELS_PER_BYTE_MINUS1
	bne	mos_VDU_set_mode_bmsk1
	ldb	#$07
	;; bytes per pixel 1 => 8?
mos_VDU_set_mode_bmsk1
	aslb
	ldx	#mostbl_VDU_pix_mask_16colour - 1
	lda	b,x;	CB58	
	sta	vduvar_RIGHTMOST_PIX_MASK	;	CB5B
	;; shunt bitmask to leftmost
1	asla
	bpl	1B				;	CB5F
	sta	vduvar_LEFTMOST_PIX_MASK	;	CB61
	ldx	#mostbl_VDU_mode_size
	lda	vduvar_MODE
	ldb	a,x
	stb	vduvar_MODE_SIZE
	clra
	tfr	D,X
;;;	lda	mostbl_VDU_hwscroll_offb2,x
;;;	jsr	mos_poke_SYSVIA_orb
;;;	lda	mostbl_VDU_hwscroll_offb1,x
;;;	jsr	mos_poke_SYSVIA_orb		;	CB6D
	lda	mostbl_VDU_hwscroll_offs,x
	sta	SHEILA_MEMC_SCROFF
	lda	mostbl_VDU_screensize_h,x	;	CB76
	sta	vduvar_SCREEN_SIZE_HIGH		;	CB79
	lda	mostbl_VDU_screebot_h,x		;	CB7C
	sta	vduvar_SCREEN_BOTTOM_HIGH	;	CB7F
;; A=((y+2)^7)>>1; 0=>2; 1=>2; 2=>1; 3=>1; 4=>0
;;	lda	vduvar_MODE_SIZE		;	CB82
	addb	#$02				;	CB83
	eorb	#$07				;	CB85
	lsrb					;	CB87
	clra
	tfr	D,X
	stb	vduvar_BYTES_PER_ROW
	lda	mostbl_VDU_bytes_per_row_low,x
	sta	vduvar_BYTES_PER_ROW + 1
	lda	#$43				;	CB9B

	; Setup RAMDAC / VIDC stuff
	lda	#$FF
	sta	sheila_RAMDAC_PIXMASK

	ldb	vduvar_COL_COUNT_MINUS1		; a <= colours - 1

	; get left most pixel mask for this mode
	lda	#$80
	asrb
	asrb
	bcc	1F
	ora	#$08
	asrb
	bcc	1F
	ora	#$22
1	; a now contains a left most pixel mask

	; store in RAMDAC pixel mask (TODO: move to MODE change/boot?)
	sta	sheila_VIDULA_pixand

	jsr	mos_VDU_and_A_vdustatus		;	CB9D
	lda	vduvar_MODE			;	CBA0
	ldx	#mostbl_VDU_VIDPROC_CTL_by_mode
	lda	a,x				;	CBA3
	jsr	mos_VIDPROC_set_CTL		;	CBA6
	pshs	CC				;	CBA9
	; Send commands from table for current mode size to 6845
mos_send6845
	SEI			; interrupts off
	ldx	#mostbl_VDU_ptr_end_6845tab
	ldb	vduvar_MODE_SIZE
	ldb	b,x
	ldx	#mostbl_VDU_6845_mode_012
	abx
	ldb	#$0B				
mos_send6845lp					; LCBB0
	lda	,-x				;	CBB0
	jsr	mos_set_6845_regBtoA		;	CBB3
	decb					;	CBB7
	bpl	mos_send6845lp			;	CBB8
	puls	CC				; interrupts back
	jsr	mos_VDU_20			; default logical colours
	jsr	mos_VDU_26			; default windows
LCBC1_clear_whole_screen
	lda	vduvar_SCREEN_BOTTOM_HIGH
	sta	vduvar_6845_SCREEN_START
	clrb
	tfr	D,X
	stx	vduvar_6845_SCREEN_START
	jsr	mos_set_cursor_X		;	CBCC
	lda	#$0C				;	CBCF
	jsr	mos_stx_6845rA			;	CBD1
;;	lda	vduvar_TXT_BACK			;	CBD4
	ldb	vduvar_MODE_SIZE		;	CBD7
;;;	aslb
	clr	sysvar_SCREENLINES_SINCE_PAGE	;	CBE7
	clr	vduvar_TXT_CUR_X		;	CBEA
	clr	vduvar_TXT_CUR_Y		;	CBED
	ldx	#mostbl_VDU_screensize_h
	pshsw
	lde	B,X				; get # bytes to clear (high in E)
	clrf
	;decw
	ldx	vduvar_6845_SCREEN_START
	ldy	#vduvar_TXT_BACK
	tfm	Y,X+
	pulsW
	rts
;;;	ldx	#mostbl_VDU_cls_vecjmp
;;;	jmp	[b,x]
;; ----------------------------------------------------------------------------
;; OSWORD 10	  Read character definition; &EF=A:&F0=X:&F1=Y, on entry YX contains number of byte to be read	; (&DE) points toFDBess ; on exit byte YX+1 to YX+8 contain definition 
;mos_OSWORD_10:
;	jsr	x_calc_pattern_addr_for_given_char;	CBF3
;	ldy	#$00				;	CBF6
;LCBF8:	lda	(zp_vdu_wksp+4),y		;	CBF8
;	iny					;	CBFA
;	sta	(zp_mos_OSBW_X),y		;	CBFB
;	cpy	#$08				;	CBFD
;	bne	LCBF8				;	CBFF
;	rts					;	CC01
;; ----------------------------------------------------------------------------
;; Mode 0,1,2 entry point
;;;cls_Mode_012_entry_point
;;;	ldx	#$3000
;;;1	sta	,x+
;;;	sta	,x+
;;;	sta	,x+
;;;	sta	,x+
;;;	sta	,x+
;;;	sta	,x+
;;;	sta	,x+
;;;	sta	,x+
;;;	sta	,x+
;;;	sta	,x+
;;;	sta	,x+
;;;	sta	,x+
;;;	sta	,x+
;;;	sta	,x+
;;;	sta	,x+
;;;	sta	,x+
;;;	cmpx	#$8000
;;;	blo	1B
;;;	rts
;;;;; Mode 3 entry point
;;;cls_Mode_3_entry_point
;;;	ldx	#$4000
;;;	bra	1B
;;;;; Mode 4,5 entry point
;;;cls_Mode_45_entry_point
;;;	ldx	#$5800
;;;	bra	1B
;;;;; Mode 6 entry point
;;;cls_Mode_6_entry_point
;;;	ldx	#$6000
;;;	bra	1B
;;;;; Mode 7 entry point
;;;cls_Mode_7_entry_point
;;;	ldx	#$7C00
;;;	bra	1B
;; ----------------------------------------------------------------------------
;; subtract bytes per line from X/A
; note new API, address in D instead of X/A and carry flag is opposite sense
x_subtract_bytes_per_line_from_D
	subd	vduvar_BYTES_PER_ROW
	cmpa	vduvar_SCREEN_BOTTOM_HIGH
LCD06	rts					;	CD06
; ----------------------------------------------------------------------------
; OSBYTE 20		  Explode characters;  
mos_OSBYTE_20
	lda	#$0F				;	CD07
	sta	vduvar_EXPLODE_FLAGS		;	CD09
	lda	#$0C				;	CD0C
	ldb	#$06				;	CD0E
	ldy	#vduvar_FONT_LOC32_63
LCD10	sta	b,y
	decb
	bpl	LCD10				;	CD14
;	tfr	X,D
	ldb	zp_mos_OSBW_X
	cmpb	#$07				;	CD16
	bhs	LCD1C				;	CD18
	ldb	#$06				;	CD1A
LCD1C	stb	sysvar_EXPLODESTATUS		;	CD1C
	lda	sysvar_PRI_OSHWM		;	CD1F
	ldb	#$00				;	CD22
	ldx	#mostbl_SOFT_CHARACTER_RAM_ALLOCATION
	ldy	#vduvar_FONT_LOC32_63
LCD24	cmpb	sysvar_EXPLODESTATUS		;	CD24
	bhs	LCD34				;	CD27
	pshs	b
	ldb	b,x				;	CD29
	sta	b,y				;	CD2C
	inca					;	CD2F
	puls	b
	incb					;	CD31
	bne	LCD24				;	CD32
LCD34	sta	sysvar_CUR_OSHWM		;	CD34
	beq	LCD06				;	CD38
	ldb	#SERVICE_11_FONT_BANG		;	CD3A
	jmp	mos_OSBYTE_143_b_cmd_x_param
						;	CD3C
;; ----------------------------------------------------------------------------
;; :move text cursor to next line (direction up/down depends on CC_C)
x_move_text_cursor_to_next_line
	lda	zp_vdu_status
	bita	#$02
	bne	LCD47				; scrolling disabled
	bita	#$40
	beq	LCD65rts			; curor editing
LCD47	ldb	vduvar_TXT_WINDOW_BOTTOM	; if carry set on entry get TOP else get BOTTOM
	bcc	LCD4F				
	ldb	vduvar_TXT_WINDOW_TOP		
LCD4F	bita	#$40
	bne	LCD59				; if cursor editing
	stb	vduvar_TXT_CUR_Y		
	leas	2,S				; skip return and setup address and cursor
	jmp	x_setup_displayaddress_and_cursor_position
;; ----------------------------------------------------------------------------
LCD59	pshs	CC				;	CD59
	cmpb	vduvar_TEXT_IN_CUR_Y		;	CD5A
	beq	1F				;	CD5D
	puls	CC				;	CD5F
	bcc	LCD66				;	CD60
	dec	vduvar_TEXT_IN_CUR_Y		;	CD62
LCD65rts
	rts
1	puls	CC,PC
;; ----------------------------------------------------------------------------
LCD66	inc	vduvar_TEXT_IN_CUR_Y		;	CD66
	rts					;	CD69
;; ----------------------------------------------------------------------------
;; set up write cursor
x_set_up_write_cursor
	pshs	A,B,CC,X
	ldb	vduvar_BYTES_PER_CHAR
	decb
	ldx	zp_vdu_top_scanline
	bne	LCD8F				; it's not MO.7
	lda	vduvar_GRA_WKSP+8
	sta	,X				; restore original MO.7 character?
	puls	A,B,CC,X,PC

;;	php					;	CD6A
;;	pha					;	CD6B
;;	ldy	vduvar_BYTES_PER_CHAR		;	CD6C
;;	dey					;	CD6F
;;	bne	LCD8F				;	CD70
;;	lda	vduvar_GRA_WKSP+8		;	CD72
;;	sta	(zp_vdu_top_scanline),y		;	CD75

;;LCD77:	pla					;	CD77
;;LCD78:	plp					;	CD78
;;LCD79:	rts					;	CD79
;; ----------------------------------------------------------------------------
x_start_cursor_edit_qry	
	pshs	A,B,CC,X
	ldx	zp_vdu_top_scanline
	ldb	vduvar_BYTES_PER_CHAR			;bytes per character
	decb						;
	bne	LCD8F					;if not mode 7
	lda	,x					;get cursor from top scan line
	sta	vduvar_GRA_WKSP+8			;store it
	lda	vduvar_MO7_CUR_CHAR			;mode 7 write cursor character
	sta	,x					;store it at scan line
	puls	A,B,CC,X,PC				;and exit

;; ----------------------------------------------------------------------------
LCD8F	lda	#$FF					;A=&FF =cursor
	cmpb	#$1F					;except in mode 2 (Y=&1F)
	bne	x_produce_white_block_write_cursor	;if not CD97
	lda	#$3F					;load cursor byte mask
;; produce white block write cursor
x_produce_white_block_write_cursor
	sta	zp_vdu_wksp			;	CD97
1	lda	,x				;	CD99
	eora	zp_vdu_wksp			;	CD9B
	sta	,x+				;	CD9D
	decb					;	CD9F
	bpl	1B				;	CDA0
;;;	bmi	LCD77				;	CDA2
	puls	A,B,CC,X,PC



LCDA4
	jsr	x_exchange_TXTCUR_wksp_doublertsifwindowempty ; also saves height in wksp+4
	lda	vduvar_TXT_WINDOW_BOTTOM	;	CDA7
	sta	vduvar_TXT_CUR_Y		;	CDAA
	jsr	x_set_up_displayaddress	;	CDAD
LCDB0	jsr	x_subtract_bytes_per_line_from_D;	CDB0
	bcc	LCDB8				;	CDB3
	adda	vduvar_SCREEN_SIZE_HIGH		;	CDB5
LCDB8	std	zp_vdu_wksp			;	CDB8
	sta	zp_vdu_wksp+2			;	CDBC
	bcs	LCDC6				;	CDBE
LCDC0	jsr	LCE73				;	CDC0
	bra	LCDCE
;; ----------------------------------------------------------------------------
LCDC6	jsr	x_subtract_bytes_per_line_from_D;	CDC6
	bcs	LCDC0				;	CDC9
	jsr	x_copy_routines			;	CDCB
LCDCE	lda	zp_vdu_wksp+2			;	CDCE
	ldb	zp_vdu_wksp+1			;	CDD0
	std	zp_vdu_top_scanline		;	CDD2
	dec	zp_vdu_wksp+4
	bne	LCDB0

x_exchange_TXT_CUR_with_BITMAP_READ		; LCDDA
	ldx	#vduvar_TEMP_8
	ldy	#vduvar_TXT_CUR_X
x_exchange_2atY_with_2atX			; LCDDE
	ldb	#$02				;	CDDE TODO: this is a straigh 16 bit copy do something better?
	bra	x_exchange_B_atY_with_B_atX	;	CDE0
x_exg4atGRACURINTwithGRACURINTOLD			; LCDE2
	ldx	#vduvar_GRA_CUR_INT		;	CDE2
x_exg4atGRACURINTOLDwithX				; LCDE4
	ldy	#vduvar_GRA_CUR_INT_OLD		;	CDE4
x_exchange_4atY_with_4atX
	ldb	#$04				;	CDE6
;; exchange (300/300+A)+Y with (300/300+A)+X
x_exchange_B_atY_with_B_atX
	stb	zp_vdu_wksp			;	CDE8
LCDEA	lda	,x
	ldb	,y
	sta	,y+
	stb	,x+
	dec	zp_vdu_wksp			;	CDFA
	bne	LCDEA				;	CDFC
	rts					;	CDFE
;; ----------------------------------------------------------------------------
;; execute upward scroll;  
x_execute_upward_scroll
	TODO	"x_execute_upward_scroll"
;	jsr	x_exchange_TXTCUR_wksp_doublertsifwindowempty				;	CDFF
;	ldy	vduvar_TXT_WINDOW_TOP		;	CE02
;	sty	vduvar_TXT_CUR_Y		;	CE05
;	jsr	x_set_up_displayaddress	;	CE08
;LCE0B:	jsr	x_Add_number_of_bytes_in_a_line_to_XA;	CE0B
;	bpl	LCE14				;	CE0E
;	sec					;	CE10
;	sbc	vduvar_SCREEN_SIZE_HIGH		;	CE11
;LCE14:	sta	zp_vdu_wksp+1			;	CE14
;	stx	zp_vdu_wksp			;	CE16
;	sta	zp_vdu_wksp+2			;	CE18
;	bcc	LCE22				;	CE1A
;LCE1C:	jsr	LCE73				;	CE1C
;	jmp	LCE2A				;	CE1F
;; ----------------------------------------------------------------------------
;LCE22:	jsr	x_Add_number_of_bytes_in_a_line_to_XA;	CE22
;	bmi	LCE1C				;	CE25
;	jsr	x_copy_routines			;	CE27
;LCE2A:	lda	zp_vdu_wksp+2			;	CE2A
;	ldx	zp_vdu_wksp			;	CE2C
;	sta	zp_vdu_top_scanline+1		;	CE2E
;	stx	zp_vdu_top_scanline		;	CE30
;	dec	zp_vdu_wksp+4			;	CE32
;	bne	LCE0B				;	CE34
;	beq	x_exchange_TXT_CUR_with_BITMAP_READ				;	CE36
;; copy routines
x_copy_routines
	ldd	vduvar_TXT_WINDOW_WIDTH_BYTES
	ldx	zp_vdu_wksp
	ldy	zp_vdu_top_scanline
1	lda	,x+
	sta	,y+
	subd	#1
	bne	1B
	rts					;	CE5A
;; ----------------------------------------------------------------------------
x_exchange_TXTCUR_wksp_doublertsifwindowempty	
	jsr	x_exchange_TXT_CUR_with_BITMAP_READ
	lda	vduvar_TXT_WINDOW_BOTTOM	;	CE5F
	suba	vduvar_TXT_WINDOW_TOP		;	CE62
	sta	zp_vdu_wksp+4			;	CE65
	bne	x_cursor_to_window_left				;	CE67
	leas	2,S
	jmp	x_exchange_TXT_CUR_with_BITMAP_READ	; if no text window pull return address, put back cursor and exit parent subroutine
;; ----------------------------------------------------------------------------
x_cursor_to_window_left	
	lda	vduvar_TXT_WINDOW_LEFT		
	bra	LCEE3_sta_TXT_CUR_X_setC_rts

LCE73
	TODO "LCE73"
;LCE73:	lda	zp_vdu_wksp			;	CE73 TODO copy lines of text - scroll window?
;	pha					;	CE75
;	sec					;	CE76
;	lda	vduvar_TXT_WINDOW_RIGHT		;	CE77
;	sbc	vduvar_TXT_WINDOW_LEFT		;	CE7A
;	sta	zp_vdu_wksp+5			;	CE7D
;LCE7F:	ldy	vduvar_BYTES_PER_CHAR		;	CE7F
;	dey					;	CE82
;LCE83:	lda	(zp_vdu_wksp),y			;	CE83
;	sta	(zp_vdu_top_scanline),y		;	CE85
;	dey					;	CE87
;	bpl	LCE83				;	CE88
;	ldx	#$02				;	CE8A
;LCE8C:	clc					;	CE8C
;	lda	zp_vdu_top_scanline,x		;	CE8D
;	adc	vduvar_BYTES_PER_CHAR		;	CE8F
;	sta	zp_vdu_top_scanline,x		;	CE92
;	lda	zp_vdu_top_scanline+1,x		;	CE94
;	adc	#$00				;	CE96
;	bpl	LCE9E				;	CE98
;	sec					;	CE9A
;	sbc	vduvar_SCREEN_SIZE_HIGH		;	CE9B
;LCE9E:	sta	zp_vdu_top_scanline+1,x		;	CE9E
;	dex					;	CEA0
;	dex					;	CEA1
;	beq	LCE8C				;	CEA2
;	dec	zp_vdu_wksp+5			;	CEA4
;	bpl	LCE7F				;	CEA6
;	pla					;	CEA8
;	sta	zp_vdu_wksp			;	CEA9
;	rts					;	CEAB
;; ----------------------------------------------------------------------------
;; clear a line
x_clear_a_line
	lda	vduvar_TXT_CUR_X
	pshs	A
	jsr	x_cursor_to_window_left
	jsr	x_set_up_displayaddress
	lda	vduvar_TXT_WINDOW_RIGHT
	suba	vduvar_TXT_WINDOW_LEFT
	sta	zp_vdu_wksp+2
	ldx	zp_vdu_top_scanline
	lda	vduvar_TXT_BACK	
LCEBF	ldb	vduvar_BYTES_PER_CHAR
LCEC5	sta	,X+
	decb
	bne	LCEC5
	cmpx	#$8000
	blo	LCEDA
	lda	vduvar_SCREEN_SIZE_HIGH
	nega
	clrb
	leax	D,X
LCEDA	dec	zp_vdu_wksp+2
	bpl	LCEBF
	stx	zp_vdu_top_scanline
	puls	A
LCEE3_sta_TXT_CUR_X_setC_rts	
	sta	vduvar_TXT_CUR_X
LCEE6_setC_rts
	orcc	#CC_C
	rts
;; ----------------------------------------------------------------------------
x_check_text_cursor_in_window_setup_display_addr
	ldb	vduvar_TXT_CUR_X
	cmpb	vduvar_TXT_WINDOW_LEFT
	bmi	LCEE6_setC_rts
	cmpb	vduvar_TXT_WINDOW_RIGHT
	beq	LCEF7
	bpl	LCEE6_setC_rts
LCEF7	ldb	vduvar_TXT_CUR_Y
	cmpb	vduvar_TXT_WINDOW_TOP
	bmi	LCEE6_setC_rts
	cmpb	vduvar_TXT_WINDOW_BOTTOM
	beq	x_set_up_displayaddress
	bpl	LCEE6_setC_rts
;; set up displayaddressess
; 
; Mode 0: (0319)*640+(0318)* 8 		0
; Mode 1: (0319)*640+(0318)*16 		0
; Mode 2: (0319)*640+(0318)*32 		0
; Mode 3: (0319)*640+(0318)* 8 		1
; Mode 4: (0319)*320+(0318)* 8 		2
; Mode 5: (0319)*320+(0318)*16 		2
; Mode 6: (0319)*320+(0318)* 8 		3
; Mode 7: (0319)* 40+(0318)  		4
 ;this gives a displacement relative to the screen RAM start address
 ;which is added to the calculated number and stored in in 34A/B
 ;if the result is less than &8000, the top of screen RAM it is copied into X/A
 ;and D8/9.  
 ;if the result is greater than &7FFF the hi byte of screen RAM size is
 ;subtracted to wraparound the screen. X/A, D8/9 are then set from this

x_set_up_displayaddress
	lda	vduvar_TXT_CUR_Y
	ldb	vduvar_MODE_SIZE
	cmpb	#4
	beq	x_set_up_displayaddress_mo7
	cmpb	#2
	bhs	x_set_up_displayaddress_320
	ldb	#160
	mul
	aslb
	rola
x_set_up_displayaddress_sk1
	aslb
	rola
x_set_up_displayaddress_sk2
	addd	vduvar_6845_SCREEN_START
	std	zp_vdu_top_scanline
	lda	vduvar_TXT_CUR_X
	ldb	vduvar_BYTES_PER_CHAR
	mul
	addd	zp_vdu_top_scanline
	std	vduvar_6845_CURSOR_ADDR
	bpl	x_set_up_displayaddress_nowrap
	suba	vduvar_SCREEN_SIZE_HIGH
x_set_up_displayaddress_nowrap
	std	zp_vdu_top_scanline

	rts
x_set_up_displayaddress_320
	ldb	#160
	mul
	bra	x_set_up_displayaddress_sk1
x_set_up_displayaddress_mo7
	ldb	#40
	mul
	bra	x_set_up_displayaddress_sk2



;;;	lda	vduvar_TXT_CUR_Y		;	CF06
;;;	asl	a				;	CF09
;;;	tay					;	CF0A
;;;	lda	(zp_rom_mul),y			;	CF0B
;;;	sta	zp_vdu_top_scanline+1		;	CF0D
;;;	iny					;	CF0F
;;;	lda	#$02				;	CF10
;;;	and	vduvar_MODE_SIZE		;	CF12
;;;	php					;	CF15
;;;	lda	(zp_rom_mul),y			;	CF16
;;;	plp					;	CF18
;;;	beq	LCF1E				;	CF19
;;;	lsr	zp_vdu_top_scanline+1		;	CF1B
;;;	ror	a				;	CF1D;;
;;

;;;LCF1E:	adc	vduvar_6845_SCREEN_START	;	CF1E
;;;	sta	zp_vdu_top_scanline		;	CF21
;;;	lda	zp_vdu_top_scanline+1		;	CF23
;;;	adc	vduvar_6845_SCREEN_START+1	;	CF25
;;;	tay					;	CF28
;;;	lda	vduvar_TXT_CUR_X		;	CF29
;;;	ldx	vduvar_BYTES_PER_CHAR		;	CF2C
;;;	dex					;	CF2F
;;;	beq	LCF44				;	CF30
;;;	cpx	#$0F				;	CF32
;;;	beq	LCF39				;	CF34
;;;	bcc	LCF3A				;	CF36
;;;	asl	a				;	CF38
;;;LCF39:	asl	a				;	CF39
;;;LCF3A:	asl	a				;	CF3A
;;;	asl	a				;	CF3B
;;;	bcc	LCF40				;	CF3C
;;;	iny					;	CF3E
;;;	iny					;	CF3F
;;;LCF40:	asl	a				;	CF40
;;;	bcc	LCF45				;	CF41
;;;	iny					;	CF43
;;;LCF44:	clc					;	CF44
;;;LCF45:	adc	zp_vdu_top_scanline		;	CF45
;;;	sta	zp_vdu_top_scanline		;	CF47
;;;	sta	vduvar_6845_CURSOR_ADDR		;	CF49
;;;	tax					;	CF4C
;;;	tya					;	CF4D
;;;	adc	#$00				;	CF4E
;;;	sta	vduvar_6845_CURSOR_ADDR+1	;	CF50
;;;	bpl	LCF59				;	CF53
;;;	sec					;	CF55
;;;	sbc	vduvar_SCREEN_SIZE_HIGH		;	CF56
;;;LCF59:	sta	zp_vdu_top_scanline+1		;	CF59
;;;	clc					;	CF5B
;;;	rts					;	CF5C
;; ----------------------------------------------------------------------------
;; Graphics cursor display routine
x_Graphics_cursor_display_routine
	TODO "x_Graphics_cursor_display_routine"
;	ldx	vduvar_GRA_FORE			;	CF5D
;	ldy	vduvar_GRA_PLOT_FORE		;	CF60
x_plot_char_gra_mode				; LCF63
		TODO "x_plot_char_gra_mode"
		jsr	x_set_colour_masks_newAPI		;	CF63
		jsr	copy4from324to328				; LCF66
;	ldy	#$00				;	CF69
;LCF6B:	sty	zp_vdu_wksp+2			;	CF6B
;	ldy	zp_vdu_wksp+2			;	CF6D
;	lda	(zp_vdu_wksp+4),y		;	CF6F
;	beq	LCF86				;	CF71
;	sta	zp_vdu_wksp+3			;	CF73
;LCF75:	bpl	LCF7A				;	CF75
;	jsr	LD0E3				;	CF77
;LCF7A:	inc	vduvar_GRA_CUR_INT		;	CF7A
;	bne	LCF82				;	CF7D
;	inc	vduvar_GRA_CUR_INT+1		;	CF7F
;LCF82:	asl	zp_vdu_wksp+3			;	CF82
;	bne	LCF75				;	CF84
;LCF86:	ldx	#$28				;	CF86
;	ldy	#$24				;	CF88
;	jsr	copy2fromXtoY				;	CF8A
;	ldy	vduvar_GRA_CUR_INT+2		;	CF8D
;	bne	LCF95				;	CF90
;	dec	vduvar_GRA_CUR_INT+3		;	CF92
;LCF95:	dec	vduvar_GRA_CUR_INT+2		;	CF95
;	ldy	zp_vdu_wksp+2			;	CF98
;	iny					;	CF9A
;	cpy	#$08				;	CF9B
;	bne	LCF6B				;	CF9D
;	ldx	#$28				;	CF9F
;	ldy	#$24				;	CFA1
;	jmp	copy4fromXtoY				;	CFA3
;; ----------------------------------------------------------------------------
;; home graphics cursor
x_home_graphics_cursor
	ldx	#vduvar_GRA_WINDOW_TOP
	ldy	#vduvar_GRA_CUR_INT + 2
	jsr	copy2fromXtoY
;; set graphics cursor to left hand column
x_set_graphics_cursor_to_left_hand_column
	ldx	#vduvar_GRA_WINDOW_LEFT
	ldy	#vduvar_GRA_CUR_INT
	jsr	copy2fromXtoY
	jmp	x_calculate_external_coordinates_from_internal_coordinates
;; ----------------------------------------------------------------------------
render_char
	ldb	vduvar_COL_COUNT_MINUS1
	beq	x_convert_teletext_characters
	jsr	x_calc_pattern_addr_for_given_char
LCFBF_renderchar2
	lda	zp_vdu_status			;	CFC2
	anda	#$20				;	CFC4
	bne	x_Graphics_cursor_display_routine;	CFC6
	ldx	zp_vdu_wksp + 4
render_logo2
	ldb	#7
	ldy	zp_vdu_top_scanline
	lda	vduvar_COL_COUNT_MINUS1		;	CFBF
	cmpa	#$03				;	CFCA
	beq	render_char_4colour		;	CFCC
	lbhi	render_char_16colour		;	CFCE
*LCFD0	lda	B,X						;4+1		2
*	ora	zp_vdu_txtcolourOR				;4		2
*	eora	zp_vdu_txtcolourEOR				;4		2
*	sta	B,Y						;4+1		2
*	decb							;2		1
*	bpl	LCFD0						;3		2
*								;23		11
*								;x8=184

	ldd	,X++						;5+1		2
	ora	zp_vdu_txtcolourOR				;4		2
	eora	zp_vdu_txtcolourEOR				;4		2
	orb	zp_vdu_txtcolourOR				;4		2
	eorb	zp_vdu_txtcolourEOR				;4		2
	std	,Y++						;5+1		2

	ldd	,X++						;5+1		2
	ora	zp_vdu_txtcolourOR				;4		2
	eora	zp_vdu_txtcolourEOR				;4		2
	orb	zp_vdu_txtcolourOR				;4		2
	eorb	zp_vdu_txtcolourEOR				;4		2
	std	,Y++						;5+1		2

	ldd	,X++						;5+1		2
	ora	zp_vdu_txtcolourOR				;4		2
	eora	zp_vdu_txtcolourEOR				;4		2
	orb	zp_vdu_txtcolourOR				;4		2
	eorb	zp_vdu_txtcolourEOR				;4		2
	std	,Y++						;5+1		2

	ldd	,X++						;5+1		2
	ora	zp_vdu_txtcolourOR				;4		2
	eora	zp_vdu_txtcolourEOR				;4		2
	orb	zp_vdu_txtcolourOR				;4		2
	eorb	zp_vdu_txtcolourEOR				;4		2
	std	,Y++						;5+1		2

	rts					;	CFDB
render_logox4
	jsr	render_logox2
render_logox2
	jsr	render_logo
render_logo
	pshs	X
	jsr	render_logo2
	jsr	mos_VDU_9
	puls	X
	leax	8,X
	rts
;; ----------------------------------------------------------------------------
;; convert teletext characters; mode 7 
x_convert_teletext_characters
	ldb	#$02
	ldx	#mostbl_TTX_CHAR_CONV
LCFDE	cmpa	B,X
	beq	LCFE9				;	CFE1
	decb					;	CFE3
	bpl	LCFDE				;	CFE4
LCFE6	sta	[zp_vdu_top_scanline]
	rts					;	CFE8
;; ----------------------------------------------------------------------------
LCFE9	incb
	lda	B,X
	decb
	bra	LCFE6
;; four colour modes
render_char_4colour
	pshs	U
	ldu	#mostbl_byte_mask_4col
1
	lda	b,x
	lsra
	lsra
	lsra
	lsra
	lda	a,U
	ora	zp_vdu_txtcolourOR
	eora	zp_vdu_txtcolourEOR
	sta	b,y
	lda	b,x
	addb	#8
	anda	#$0F
	lda	a,U
	ora	zp_vdu_txtcolourOR
	eora	zp_vdu_txtcolourEOR
	sta	b,y
	subb	#9
	bpl	1B
LD017rts
	puls	U
	rts
;; ----------------------------------------------------------------------------
LD018	subb	#$21
	bmi	LD017rts				;	D01B
	bra	rc16csk1
;; 16 COLOUR MODES
render_char_16colour
	pshs	U
	ldu	#mostbl_byte_mask_16col
rc16csk1
	lda	B,X
	sta	zp_vdu_wksp+2
	orcc	#CC_C
LD023	lda	#0				; cant use clra here as we need the carry set
	rol	zp_vdu_wksp+2
	beq	LD018
	rola
	asl	zp_vdu_wksp+2
	rola
	lda	A,U
	ora	zp_vdu_txtcolourOR
	eora	zp_vdu_txtcolourEOR
	sta	B,y
	addb	#$08
	bra	LD023

x_calc_pattern_addr_for_given_char
	pshs	D,X
	ldb	#8				; 2	2
	mul					; 1	11
	stb	zp_vdu_wksp + 5			; 2	4		a contains "char defs page offset"
	ldx	#mostbl_VDU_pix_mask_2colour	; 3	3		convert to a bit mask
	ldb	a,x				; 2	5
	bitb	vduvar_EXPLODE_FLAGS		; 3	5		check if that bit is set in explosion bitmask
	bne	x_cpa_sk_exploded		; 2	3		if it is use that address
	adda	#(mostbl_chardefs/256) - 1	; 2	2		space is at 32 remember!
1	sta	zp_vdu_wksp + 4			; 2	6		store whole address
						; 19	41
	puls	D,X,PC
x_cpa_sk_exploded
	ldx	#vduvar_EXPLODE_FLAGS
	lda	a,x				;	get explode address from table
	bra	1B

;	asl	a				;	D03E	1	2
;	rol	a				;	D03F	1	2
;	rol	a				;	D040	1	2
;	sta	zp_vdu_wksp+4			;	D041	2	3
;	and	#$03				;	D043	2	2
;	rol	a				;	D045	1	2
;	tax					;	D046	1	2
;	and	#$03				;	D047	2	2
;	adc	#$BF				;	D049	2	2
;	tay					;	D04B	1	2
;	lda	mostbl_VDU_pix_mask_2colour,x	;	D04C	3	4
;	bit	vduvar_EXPLODE_FLAGS		;	D04F	3	4
;	beq	LD057				;	D052	2	3
;	ldy	vduvar_EXPLODE_FLAGS,x		;	D054
;LD057:	sty	zp_vdu_wksp+5			;	D057	2	3
;	lda	zp_vdu_wksp+4			;	D059	2	3
;	and	#$F8				;	D05B	2	2
;	sta	zp_vdu_wksp+4			;	D05D	2	3
;	rts					;	D05F	30	43
;; ----------------------------------------------------------------------------
;; PLOT ROUTINES ENTER HERE; 
**************************************************************************
* on entry	
*	ADDRESS		PARAMETER	DESCRIPTION 
*	031F		1		plot type 	vduvar_VDU_Q_END - 5
*	0320/1		2,3		X coordinate	vduvar_VDU_Q_END - 4
*	0322/3		4,5		Y coordinate	vduvar_VDU_Q_END - 2
**************************************************************************


vduvar_VDU_Q_PLT_CODE	equ vduvar_VDU_Q_END - 5
vduvar_VDU_Q_PLT_X	equ vduvar_VDU_Q_END - 4
vduvar_VDU_Q_PLT_Y	equ vduvar_VDU_Q_END - 2

x_PLOT_ROUTINES_ENTER_HERE

	; swap coordinates endiannes
	ldy	#2
	jsr	db_endian_vdu_q_swap			; - if removed reinstate LDX below!

;;	ldx	#vduvar_VDU_Q_PLT_X			; X=&20 - DB: already set up by endiannes swap
	jsr	x_set_up_and_adjust_coords_atX_2	; translate xoordinates
	lda	vduvar_VDU_Q_PLT_CODE			; get plot type
	cmpa	#$04					; if its 4
	lbeq	mos_PLOT_MOVE_absolute			; D0D9 move absolute
	ldb	#$05					; Y=5
	anda	#$03					; mask only bits 0 and 1
	beq	LD080					; if result is 0 then its a move (multiple of 8)
	lsra						; else move bit 0 int C
	bcs	x_graphics_colour_wanted		; if set then D078 graphics colour required
	decb						; Y=4
	bra	LD080					; logic inverse colour must be wanted
;; graphics colour wanted
x_graphics_colour_wanted
	m_tax						; X=A if A=0 its a foreground colour 1 its background
	ldb	vduvar_GRA_PLOT_FORE,x			; get fore or background graphics PLOT mode
	lda	vduvar_GRA_FORE,x			; get fore or background graphics colour
;;;	tax						; X=A
LD080	jsr	x_set_colour_masks_newAPI		; set up colour masks in D4/5
	lda	vduvar_VDU_Q_PLT_CODE			; get plot type
	lbmi	x_VDU_EXTENSION				; if &80-&FF then D0AB type not implemented
	asla						; bit 7=bit 6
	bpl	x_analyse_first_parameter_in_0to63_range; if bit 6 is 0 then plot type is 0-63 so D0C6
	anda	#$F0					; else mask out lower nybble
	asla						; shift old bit 6 into C bit old 5 into bit 7
	beq	mos_PLOT_A_SINGLE_POINT			; if 0 then type 64-71 was called single point plot
							; goto D0D6
	eora	#$40					; if bit 6 NOT set type &80-&87 fill triangle
	lbeq	mos_PLOT_Fill_triangle_routine		; so D0A8
	pshs	A					; else push A
	jsr	x_copyplotcoordsexttoGRACURINT					; copy 0320/3 to 0324/7 setting XY in current graphics
							; coordinates
	puls	A					; get back A
	eora	#$60					; if BITS 6 and 5 NOT SET type 72-79 lateral fill 
	beq	LD0AE					; so D0AE
	cmpa	#$40					; if type 88-95 horizontal line blanking
	lbne	x_VDU_EXTENSION				; so D0AB

	lda	#$02					; else A=2
	sta	zp_vdu_wksp+2				; store it
	jmp	plot_filhorz_back_qry			; and jump to D506 type not implemented ??? DB: I think is fill line in background colour!
;; ----------------------------------------------------------------------------
LD0AE	sta	zp_vdu_wksp+2				;	D0AE
	jmp	mos_LATERAL_FILL_ROUTINE		;	D0B0
;; ----------------------------------------------------------------------------
;; :set colour masks; graphics plot mode in B ; colour in A
* was plot mode in Y, colour in X
x_set_colour_masks_newAPI
	ldx	#0
	abx
	pshs	A
	ora	mostbl_GCOL_options_proc,X	;	D0B4
	eora	mostbl_GCOL_options_proc+1,X	;	D0B7
	sta	zp_vdu_gracolourOR		;	D0BA
	puls	A
	ora	mostbl_VDU_mode_colours_m1+7,X	;	D0BD
	eora	mostbl_GCOL_options_proc+4,X	;	D0C0
	sta	zp_vdu_gracolourEOR		;	D0C3
	rts					;	D0C5
;; ----------------------------------------------------------------------------
;; analyse first parameter in 0-63 range;  
x_analyse_first_parameter_in_0to63_range
	asla					;shift left again
	lbmi	x_VDU_EXTENSION			;if -ve options are in range 32-63 not implemented
	asla					;shift left twice more
	asla					;
	bpl	1F				;if still +ve type is 0-7 or 16-23 so D0D0
	jsr	x_PLOT_grpixmask_ckbounds	;else display a point
1	jsr	x_mos_draw_line	;perform calculations
	jmp	mos_PLOT_MOVE_absolute		;
;; ----------------------------------------------------------------------------
;; PLOT A SINGLE POINT
mos_PLOT_A_SINGLE_POINT					; LD0D6
	jsr	x_PLOT_grpixmask_ckbounds		; plot the point
mos_PLOT_MOVE_absolute					; LD0D9
	jsr	x_exg4atGRACURINTwithGRACURINTOLD	; save the old cursor
x_copyplotcoordsexttoGRACURINT				; LD0DC
	ldy	#vduvar_GRA_CUR_INT			;	D0DC
x_copyplotcoordsexttoY					; LD0DE
	ldx	#vduvar_VDU_Q_PLT_X			;	D0DE
	jmp	copy4fromXtoY				;	D0E0
;; ----------------------------------------------------------------------------
;LD0E3:	ldx	#$24				;	D0E3
;	jsr	x__check_in_window_bounds_setup_screen_addr_atX				;	D0E5
;	beq	x_mos_vdu_gra_drawpixels_in_grpixmask				;	D0E8
;	rts					;	D0EA
;; ----------------------------------------------------------------------------
x_PLOT_grpixmask_ckbounds
	jsr	x__check_in_window_bounds_setup_screen_addr	;	D0EB
	bne	LD103rts				;	D0EE
x_mos_vdu_gra_drawpixels_in_grpixmask		; LD0F0
	ldb	vduvar_GRA_CUR_CELL_LINE	;	D0F0
	;; new API check LD0F3 
x_mos_vdu_gra_drawpixels_in_grpixmask_cell_line_in_B ; LD0F3 
	ldx	zp_vdu_gra_char_cell
	abx
	lda	zp_vdu_grpixmask		;	D0F3
	anda	zp_vdu_gracolourOR		;	D0F5
	ora	,x				;	D0F7
	sta	zp_vdu_wksp			;	D0F9
	lda	zp_vdu_gracolourEOR		;	D0FB
	anda	zp_vdu_grpixmask		;	D0FD
	eora	zp_vdu_wksp			;	D0FF
	sta	,x				;	D101
LD103rts
	rts					;	D103
;; ----------------------------------------------------------------------------

x_mos_vdu_gra_drawpixel_whole_byte
	pshs	A
	ldx	zp_vdu_gra_char_cell
	abx
	lda	,X				; LD104
	ora	zp_vdu_gracolourOR
	eora	zp_vdu_gracolourEOR
	sta	,X
	puls	A,PC
;; ----------------------------------------------------------------------------
;; Check window limits;	
	; returns A = %0000TBRL where any bit means (T)op(B)ottom(R)ight(L)eft bounds
x_Check_window_limits
	ldx	#vduvar_GRA_CUR_INT		;	D10D
x_Check_window_limits_atX
	clr	zp_vdu_wksp			;	D111
	ldy	#vduvar_GRA_WINDOW + 2		;	D113 - bottom
	jsr	x_cursor_and_margins_check	;	D115	; check Y against BOTTOM/TOP
	andcc	#~CC_C				; TODO: remove - unnecessary?
	asl	zp_vdu_wksp			;	D118
	asl	zp_vdu_wksp			;	D11A
	leax	-2,X
	leay	-2,Y
	jsr	x_cursor_and_margins_check	;	D120
	leax	2,X
	lda	zp_vdu_wksp			;	D125
	rts					;	D127
;; ----------------------------------------------------------------------------
;; cursor and margins check;  
	; API: X is coords to check
	; return 1 if (2,X) < (0,Y)
	; return 2 if (2,X) >=(4,Y)
	; return is in zp_vdu_wksp which is 0 on entry
x_cursor_and_margins_check 			
	ldd	2,x				;	D128
	cmpd	0,y				;	D12B
	bmi	LD146				;	D134
	ldd	4,y				;	D136
	cmpd	2,x				;	D139
	bpl	LD148				;	D142
	inc	zp_vdu_wksp			;	D144
LD146	inc	zp_vdu_wksp			;	D146
LD148	rts					;	D148
;; ----------------------------------------------------------------------------
;; set up and adjust positional data
x_set_up_and_adjust_coords_atX				; LD149
	lda	#$FF					;A=&FF
	bne	1F					;then &D150
x_set_up_and_adjust_coords_atX_2			; LD14D
	lda	vduvar_VDU_Q_END - 5			;get first parameter in plot;	D14D
1	sta	zp_vdu_wksp				;store in &DA
	ldy	#vduvar_GRA_WINDOW_BOTTOM		;Y=302
	jsr	x_gra_coord_ext2int			;set up vertical coordinates/2
	jsr	signeddivby2atxplus2			;/2 again to convert 1023 to 0-255 for internal use
							;this is why minimum vertical plot separation is 4
	ldy	#vduvar_GRA_WINDOW_LEFT			;Y=0
	leax	-2,X					;X=X-2
	jsr	x_gra_coord_ext2int			;set up horiz. coordinates/2 this is OK for mode0,4
	ldb	vduvar_PIXELS_PER_BYTE_MINUS1		;get number of pixels/byte (-1)
	cmpb	#$03					;if Y=3 (modes 1 and 5)
	beq	1F					;D16D
	bhs	2F					;for modes 0 & 4 this is 7 so D170
	jsr	signeddivby2atxplus2			;for other modes divide by 2 twice

1	jsr	signeddivby2atxplus2			;divide by 2
2	lda	vduvar_MODE_SIZE			;get screen display type
	bne	signeddivby2atxplus2			;if not 0 (modes 3-7) divide by 2 again
	rts						;and exit
;; ----------------------------------------------------------------------------
;; calculate external coordinates in internal format; 
; on entry 	X is usually &31E or &320  
;		Y is vduvar_GRA_WINDOW_BOTTOM or vduvar_GRA_WINDOW_LEFT for vert/horz calc  
x_gra_coord_ext2int				; LD176
	andcc	#~CC_C
	lda	zp_vdu_wksp			;get &DA
	anda	#$04				;if bit 2=0
	beq	1F				;then D186 to calculate relative coordinates
	ldd	2,x				;else get coordinate 
	bra	2F				;	D184
1	ldd	2,x				;get coordinate 
	addd	$10,y				;add cursor position
2	std	$10,y				;save new cursor 
	addd	$C,y				;add graphics origin
	std	2,x
signeddivby2atxplus2				; LD1AD
	asr	2,x				; DB: change to ASR - TODO: check
	ror	3,x
	rts
;; ----------------------------------------------------------------------------
;; calculate external coordinates from internal coordinates
x_calculate_external_coordinates_from_internal_coordinates ; TODO: speed up by loading X with address of coords instead of offset?
	ldy	#vduvar_GRA_CUR_EXT
	jsr	copy4fromGRA_CUR_INTtoY
	ldx	#$02
	ldb	#$02
	jsr	LD1D5
	ldx	#$00
	ldb	#$04
	lda	vduvar_PIXELS_PER_BYTE_MINUS1
LD1CB	decb
	lsra
	bne	LD1CB
	lda	vduvar_MODE_SIZE
	beq	LD1D5
	incb
LD1D5	asl	vduvar_GRA_CUR_EXT,x
	rol	vduvar_GRA_CUR_EXT+1,x
	decb
	bne	LD1D5
	ldd	vduvar_GRA_CUR_EXT,x
	subd	vduvar_GRA_ORG_EXT,x
	std	vduvar_GRA_CUR_EXT,x
	rts
;; ----------------------------------------------------------------------------
;; compare X and Y PLOT spans

vduvar_TEMP_draw_W	equ	vduvar_TEMP_8 + 0
vduvar_TEMP_draw_H	equ	vduvar_TEMP_8 + 2
vduvar_TEMP_draw_XY	equ	vduvar_TEMP_8 + 4
vduvar_TEMP_draw_Y	equ	vduvar_TEMP_8 + 6

zp_vdu_wksp_draw_X_save	equ	zp_vdu_wksp+2		; save X (counter?)
zp_vdu_wksp_draw_stop	equ	zp_vdu_wksp+3		; pointer to end of line to be drawn (contains $20 or $24)
zp_vdu_wksp_draw_slope	equ	zp_vdu_wksp+4		; either 0 or 2 depending on slop of line
zp_vdu_wksp_draw_start	equ	zp_vdu_wksp+5		; pointer to start of line to be drawn (contains either $20 or $24)
zp_vdu_wksp_draw_flags	equ	zp_vdu_wksp+1		; contains $80 if dotted line to be drawn, $40 if current point is out of bounds
zp_vdu_wksp_draw_sav	equ	zp_vdu_wksp+6		; DB: new used to save single byte register. TODO: check for clash!

vduvar_GRA_WKSP_jmp	equ	vduvar_GRA_WKSP+2	; code to draw pixels?

x_mos_draw_line
	jsr	x_PLOTXYsubGRACURStoTEMP8		; get line width/height
	lda	vduvar_TEMP_draw_H			; eor top bytes of height
	eora	vduvar_TEMP_draw_W			; and width
	bmi	LD207					; if differing signs
	ldd	vduvar_TEMP_draw_W			; compare width to height
	subd	vduvar_TEMP_draw_H			; NOTE: swapped sense here for differing C flag behaviour TODO: check!
	jmp	LD214					;
; ----------------------------------------------------------------------------
LD207	ldd	vduvar_TEMP_draw_W			;	D207
	addd	vduvar_TEMP_draw_H			;	D20B
LD214	rora						;	D214
	ldb	#$00					;	D215
	eora	vduvar_TEMP_draw_H			;	D217
	bpl	LD21E					;	D21A
	ldb	#$02					;	D21C
LD21E	stb	zp_vdu_wksp_draw_slope				;	D21E
	ldx	#mostbl_VDU_ROUTINE_VECTOR_ADDRESSES
	ldx	B,X
	stx	vduvar_VDU_VEC_JMP			;	D229
	ldx	#vduvar_TEMP_8
	tst	B,X
	bpl	LD235					; test direction
	ldx	#vduvar_GRA_CUR_INT			; start drawing from current cursor
	bra	LD237
LD235	ldx	#vduvar_VDU_Q_PLT_X			; start from plot point and work back
LD237	STX_B	zp_vdu_wksp_draw_start			; 
	ldy	#vduvar_TEMP_draw_XY			;	D239
	jsr	copy4fromXtoY				;	D23B
	ldb	zp_vdu_wksp_draw_start			;	D23E
	eorb	#$04					;	D240
	stb	zp_vdu_wksp_draw_stop			;	D242
	orb	zp_vdu_wksp_draw_slope			;	D244
	lda	#$3					; point at page 3
	tfr	D,X					;	D246
	jsr	copy2fromXto330				;	D247
	lda	vduvar_VDU_Q_PLT_CODE			;	D24A
	anda	#$10					;	D24D
	asla						;	D24F
	asla						;	D250
	asla						;	D251
	sta	zp_vdu_wksp_draw_flags			;	D252
	ldx	#vduvar_TEMP_draw_XY			;	D254
	jsr	x_Check_window_limits_atX		;	D256
	sta	zp_vdu_wksp+2				;	D259
	beq	LD263					;	D25B
	lda	#$40					;	D25D
	ora	zp_vdu_wksp_draw_flags			;	D25F
	sta	zp_vdu_wksp_draw_flags			;	D261
LD263	ldb	zp_vdu_wksp_draw_stop			;	D263
	lda	#3					; 		TODO: page 3 bodge
	tfr	D,X
	jsr	x_Check_window_limits_atX		;	D265
	bita	zp_vdu_wksp+2				;	D268
	beq	1F					;	D26A
	rts						; if both start and stop out of bounds POH
;; ----------------------------------------------------------------------------
1	ldb	zp_vdu_wksp_draw_slope			; LD26D
	beq	1F					; depending on slope
	lsra						; shift top bound flag into right bound flag
	lsra						;
1	anda	#$02					; check right bound (or top) flag
	beq	1F					;	D275
;;;	txa						;	D277
	orb	#$04					; == 6 or 4 depending on slope
	lda	#3
	tfr	D,X
;;;	tax						;	D27A
	jsr	copy2fromXto330				; copy right (or top) bound into vduvar_GRA_WKSP
1	jsr	LD42C				;	D27E
	ldb	zp_vdu_wksp_draw_slope			;	D281
	eorb	#$02				;	D283
	stb	zp_vdu_wksp_draw_sav
;;;	tax					;	D285
;;;	tay					;	D286
	lda	vduvar_TEMP_draw_W		; check for with width / height -ve
	eora	vduvar_TEMP_draw_H		;	D28A
	bpl	LD290				;	D28D
	incb					;	D28F
LD290	ldx	#mostbl_VDU_ROUTINE_BRANCH_VECTOR_ADDRESS
	aslb
	ldx	B,X
	asrb
	stx	vduvar_GRA_WKSP_jmp		;	D293
	lda	#$7F				;	D29C
	sta	vduvar_GRA_WKSP+4		;	D29E
	lda	#$40
	bita	zp_vdu_wksp_draw_flags		;	D2A1
	tfr	B,A				; TODO: check!
	bne	LD2CE				;	D2A3
	ldx	#mostbl_VDU_mode_size+7
	ldb	B,X				; 4, 0, 6 or 2 depending on B
;	tax					;	D2A8
	ldx	#vduvar_GRA_WINDOW_LEFT
	ldd	B,X				; 	D2AA
	LDY_B	zp_vdu_wksp_draw_sav
	subd	vduvar_TEMP_draw_XY,Y
;;;	sbc	vduvar_TEMP_8+4,y		;	D2AD
;;;	sta	zp_vdu_wksp			;	D2B0
;;;	lda	vduvar_GRA_WINDOW_LEFT+1,x	;	D2B2
;;;	sbc	vduvar_TEMP_8+5,y		;	D2B5
;;;	ldy	zp_vdu_wksp			;	D2B8
;;;	tax					;	D2BA
	bpl	LD2C0				;	D2BB
	jsr	x_negation_routine_newAPI	;	D2BD
LD2C0
;;;	tax					;	D2C0
;;;	iny					;	D2C1
;;;	bne	LD2C5				;	D2C2
;;;	inx					;	D2C4
;LD2C5:	txa					;	D2C5
	addd	#1
	tsta
	beq	LD2CA					;	D2C6
	ldb	#$00					;	D2C8
LD2CA	stb	zp_vdu_wksp_draw_start			;	D2CA
	beq	LD2D7					;	D2CC
LD2CE	
;;;	txa						;	D2CE
	lsra						;	D2CF
	rora						;	D2D0
	ora	#$02					;	D2D1
	eora	zp_vdu_wksp_draw_slope			;	D2D3
	sta	zp_vdu_wksp_draw_slope			;	D2D5
LD2D7	ldx	#vduvar_TEMP_draw_XY			;	D2D7
	jsr	x_setup_screen_addr_from_intcoords_atX	;	D2D9
	ldx	zp_vdu_wksp_draw_X_save
	leax	-1,X
x_drawline_loop						; LD2E3
	lda	zp_vdu_wksp_draw_flags			;	D2E3
	beq	LD306					;	D2E5
	bpl	LD2F9					;	D2E7
	tst	vduvar_GRA_WKSP+4			;	D2E9
	bpl	LD2F3					;	D2EC
	dec	vduvar_GRA_WKSP+4			;	D2EE
	bne	LD316					;	D2F1
LD2F3	inc	vduvar_GRA_WKSP+4			;	D2F3
	asla						;	D2F6
	bpl	LD306					;	D2F7
LD2F9	stx	zp_vdu_wksp_draw_X_save
	ldx	#vduvar_TEMP_draw_XY			;	D2FB
	jsr	x__check_in_window_bounds_setup_screen_addr_atX				;	D2FD
;;;	ldx	zp_vdu_wksp_draw_X_save			;	D300
	tsta						;	D302
	bne	LD316					;	D304
LD306	lda	zp_vdu_grpixmask			;	D306
	anda	zp_vdu_gracolourOR			;	D308


	ldb	vduvar_GRA_CUR_CELL_LINE
	ldx	zp_vdu_gra_char_cell
	abx
	ora	,X
	;;;	ora	(zp_vdu_gra_char_cell),y	;	D30A
	sta	zp_vdu_wksp			;	D30C
	lda	zp_vdu_gracolourEOR		;	D30E
	anda	zp_vdu_grpixmask		;	D310
	eora	zp_vdu_wksp			;	D312
	sta	,X
	;;;	sta	(zp_vdu_gra_char_cell),y	;	D314
LD316
;;;	sec					;	D316
	ldd	vduvar_GRA_WKSP+5		;	D317
	subd	vduvar_GRA_WKSP+7		;	D31A
	stb	vduvar_GRA_WKSP+6		;	D31D
;;;	lda	vduvar_GRA_WKSP+6		;	D320
;;;	sbc	vduvar_GRA_WKSP+8		;	D323
	bcc	LD339				;	D326
	sta	zp_vdu_wksp			;	D328
	ldb	vduvar_GRA_WKSP+6		;	D32A
	addb	vduvar_GRA_WKSP+10		;	D32D
	stb	vduvar_GRA_WKSP+6		;	D330
	lda	zp_vdu_wksp			;	D333
	adca	vduvar_GRA_WKSP+9		;	D335
	SEC					;	D338
LD339	sta	vduvar_GRA_WKSP+5		;	D339
	pshs	CC				;	D33C
	bcc	LD348				;	D33D
	jmp	[vduvar_GRA_WKSP_jmp]		;	D33F
;; ----------------------------------------------------------------------------
;; vertical scan module 1
x_vertical_scan_module_up			; LD342
	dec	vduvar_GRA_CUR_CELL_LINE	;	D342
	bpl	LD348				;	D343
	jsr	x_move_display_point_up_a_line	;	D345
LD348	jmp	[vduvar_VDU_VEC_JMP]		;	D348
;; ----------------------------------------------------------------------------
;; vertical scan module 2
x_vertical_scan_module_dn			; LD34B
	inc	vduvar_GRA_CUR_CELL_LINE
	ldb	vduvar_GRA_CUR_CELL_LINE	; increment cell line counter
	cmpb	#$08				; if overflowed
	bne	LD348				; add a line's worth to pointer
	ldd	zp_vdu_gra_char_cell		;
	addd	vduvar_BYTES_PER_ROW		;
	std	zp_vdu_gra_char_cell		;
	bpl	LD363				;
	suba	vduvar_SCREEN_SIZE_HIGH		; if we got here wrap screen
	sta	zp_vdu_gra_char_cell		; 
LD363	clr	vduvar_GRA_CUR_CELL_LINE
	jmp	[vduvar_VDU_VEC_JMP]
;; ----------------------------------------------------------------------------
;; horizontal scan module 1
x_horizontal_scan_module_right			; LD36A
	lsr	zp_vdu_grpixmask		;	D36A
	bcc	LD348				;	D36C
	jsr	x_move_display_move_right_to_next_cell				;	D36E
	jmp	[vduvar_VDU_VEC_JMP]		;	D371
;; ----------------------------------------------------------------------------
;; horizontal scan module 2
x_horizontal_scan_module_left				; LD374
	asl	zp_vdu_grpixmask		;	D374
	bcc	LD348				;	D376
	jsr	x_move_display_move_left_to_next_cell				;	D378
	jmp	[vduvar_VDU_VEC_JMP]		;	D37B


;; ----------------------------------------------------------------------------
x_draw_line_main_up				; LD37D
	dec	vduvar_GRA_CUR_CELL_LINE	;	D37E
	bpl	1F				;	D37F
	jsr	x_move_display_point_up_a_line	;	D381
	bra	1F				;	D384
x_draw_line_main_right				; LD386
	lsr	zp_vdu_grpixmask		;	D386
	bcc	1F				;	D388
	jsr	x_move_display_move_right_to_next_cell				;	D38A
1	puls	CC				;	D38D
	ldx	zp_vdu_wksp_draw_X_save
	leax	1,X
	stx	zp_vdu_wksp_draw_X_save
	beq	LD39Frts				;	D393
LD395	lda	#$40
	bita	zp_vdu_wksp_draw_flags		;	D395
	bne	LD3A0				;	D397
	lbcc	x_drawline_loop				;	D399
	dec	zp_vdu_wksp_draw_start			;	D39B
	lbne	x_drawline_loop				;	D39D
LD39Frts
	rts					;	D39F
;; ----------------------------------------------------------------------------
LD3A0	lda	zp_vdu_wksp_draw_slope			;	D3A0
	ldx	#vduvar_TEMP_draw_XY
	anda	#$02				;	D3A4
	bcs	LD3C2				;	D3A7
	tst	zp_vdu_wksp_draw_slope		;	D3A9
	bmi	LD3B7				;	D3AB
	ldy	A,X
	leay	1,y
	sty	A,X
;	inc	vduvar_TEMP_8+4,x		;	D3AD
;	bne	LD3C2				;	D3B0
;	inc	vduvar_TEMP_8+5,x		;	D3B2
;	bcc	LD3C2				;	D3B5
	bra	LD3C2
LD3B7	
	ldy	A,X
	leay	-1,y
	sty	A,X

;;;	lda	vduvar_TEMP_8+4,x		;	D3B7
;;;	bne	LD3BF				;	D3BA
;;;	dec	vduvar_TEMP_8+5,x		;	D3BC
;;;LD3BF:	dec	vduvar_TEMP_8+4,x	;	D3BF

LD3C2	eora	#$02				;	D3C3
	ldy	A,X
	leay	1,Y
	sty	A,X
;;;	inc	vduvar_TEMP_8+4,x		;	D3C6
;;;	bne	LD3CE				;	D3C9
;;;	inc	vduvar_TEMP_8+5,x		;	D3CB
;;;LD3CE:	ldx	zp_vdu_wksp+2		;	D3CE
	jmp	x_drawline_loop				;	D3D0
;; ----------------------------------------------------------------------------
;; move display point up a line
x_move_display_point_up_a_line
	ldd	zp_vdu_gra_char_cell
	subd	vduvar_BYTES_PER_ROW
	cmpa	vduvar_SCREEN_BOTTOM_HIGH
	bhs	1F
	adda	vduvar_SCREEN_SIZE_HIGH		; wrap!
1	std	zp_vdu_gra_char_cell
	ldb	#7
	stb	vduvar_GRA_CUR_CELL_LINE
	rts
;; ----------------------------------------------------------------------------
	;TODO: use index register instead?
x_move_display_move_right_to_next_cell			; LD3ED
	lda	vduvar_LEFTMOST_PIX_MASK	;	D3ED
	sta	zp_vdu_grpixmask		;	D3F0
	ldd	zp_vdu_gra_char_cell		;	D3F2
	addd	#8				; DB: note changed from 7 (was expecting C set on entry)
	std	zp_vdu_gra_char_cell		;	D3F6
	rts					;	D3FC
;; ----------------------------------------------------------------------------
x_move_display_move_left_to_next_cell
	lda	vduvar_RIGHTMOST_PIX_MASK	;	D3FD
	sta	zp_vdu_grpixmask		;	D400
	ldd	zp_vdu_gra_char_cell
	subd	#8
	std	zp_vdu_gra_char_cell
	rts
;; ----------------------------------------------------------------------------
;; :: coordinate subtraction
x_PLOTXYsubGRACURStoTEMP8
	ldy	#vduvar_TEMP_8
	ldx	#vduvar_VDU_Q_PLT_X
x_coords_to_width_height			; LD411
	jsr	1F				
1	ldd	4,x
	subd	,x++
	std	,y++
	rts					;	D42B
;; ----------------------------------------------------------------------------

; fix out of bounds at start
; on entry 	X = 306 or 304 depending on slope
; 		Y = zp_vdu_wksp+2 (332)

LD42C	lda	zp_vdu_wksp_draw_slope		; depending on slope
	bne	LD437				;
	ldx	#vduvar_TEMP_draw_W		;
	ldy	#vduvar_TEMP_draw_H		;
	jsr	x_exchange_2atY_with_2atX	; swap width / height
LD437	ldx	#vduvar_TEMP_draw_W		;
	ldy	#vduvar_GRA_WKSP+7		;
	jsr	copy4fromXtoY			; save W
	LDX_B	zp_vdu_wksp_draw_slope		;	D43F
	ldd	vduvar_GRA_WKSP
	subd	vduvar_TEMP_draw_XY,X		; subtract 
	bmi	LD453				;	D44E
	jsr	x_negation_routine_newAPI	;	D450
LD453	std	zp_vdu_wksp_draw_X_save
	ldx	#vduvar_GRA_WKSP + 5		;	D457
LD459	jsr	2F				;	D459
	lsra					;	D45C
	rorb					;	D461
	std	0,X
	leax	-2,X
2	ldd	2,X				;	D467
	bpl	1F				;	D46D
	jsr	x_negation_routine_newAPI	;	D46F
	std	2,X
1	rts					;	D47B
;; ----------------------------------------------------------------------------
copy8fromXtoY
	ldb	#$08				; LD47C
	bra	x_copy_B_bytes_from_XtoY
copy2fromXto330					; LD480
	ldy	#vduvar_GRA_WKSP
copy2fromXtoY					; LD482
	ldb	#$02				
	bra	x_copy_B_bytes_from_XtoY
copy4from324to328
	ldy	#vduvar_TEMP_8		; LD486
copy4fromGRA_CUR_INTtoY
	ldx	#vduvar_GRA_CUR_INT		; LD488
copy4fromXtoY
	ldb	#$04				; LD48A
x_copy_B_bytes_from_XtoY			; LDF8C
	lda	,x+
	sta	,y+
	decb
	bne	x_copy_B_bytes_from_XtoY
	rts
;; ----------------------------------------------------------------------------
;; negation routine
x_negation_routine_newAPI
	coma					; TODO CHECK!
	comb
	addd	#1
	rts

;	pha					;	D49B
;	tya					;	D49C
;	eor	#$FF				;	D49D
;	tay					;	D49F
;	pla					;	D4A0
;	eor	#$FF				;	D4A1
;	iny					;	D4A3
;	bne	LD4A9				;	D4A4
;	clc					;	D4A6
;	adc	#$01				;	D4A7
;LD4A9:	rts					;	D4A9
;; ----------------------------------------------------------------------------
;LD4AA:	jsr	x__check_in_window_bounds_setup_screen_addr;	D4AA
;	bne	LD4B7				;	D4AD
;	lda	(zp_vdu_gra_char_cell),y	;	D4AF
;	eor	vduvar_GRA_BACK			;	D4B1
;	sta	zp_vdu_wksp			;	D4B4
;	rts					;	D4B6
;; ----------------------------------------------------------------------------
;LD4B7:	pla					;	D4B7
;	pla					;	D4B8
;LD4B9:	inc	vduvar_GRA_CUR_INT+2		;	D4B9
;	jmp	LD545				;	D4BC
;; ----------------------------------------------------------------------------
;; LATERAL FILL ROUTINE
mos_LATERAL_FILL_ROUTINE
	TODO "mos_LATERAL_FILL_ROUTINE"
;	jsr	LD4AA				;	D4BF
;	and	zp_vdu_grpixmask		;	D4C2
;	bne	LD4B9				;	D4C4
;	ldx	#$00				;	D4C6
;	jsr	LD592				;	D4C8
;	beq	LD4FA				;	D4CB
;	ldy	vduvar_GRA_CUR_CELL_LINE	;	D4CD
;	asl	zp_vdu_grpixmask		;	D4D0
;	bcs	LD4D9				;	D4D2
;	jsr	LD574				;	D4D4
;	bcc	LD4FA				;	D4D7
;LD4D9:	jsr	x_move_display_move_left_to_next_cell				;	D4D9
;	lda	(zp_vdu_gra_char_cell),y	;	D4DC
;	eor	vduvar_GRA_BACK			;	D4DE
;	sta	zp_vdu_wksp			;	D4E1
;	bne	LD4F7				;	D4E3
;	sec					;	D4E5
;	txa					;	D4E6
;	adc	vduvar_PIXELS_PER_BYTE_MINUS1	;	D4E7
;	bcc	LD4F0				;	D4EA
;	inc	zp_vdu_wksp_draw_flags			;	D4EC
;	bpl	LD4F7				;	D4EE
;LD4F0:	tax					;	D4F0
;	jsr	x_mos_vdu_gra_drawpixel_whole_byte				;	D4F1
;	sec					;	D4F4
;	bcs	LD4D9				;	D4F5
;LD4F7:	jsr	LD574				;	D4F7
;LD4FA:	ldy	#$00				;	D4FA
;	jsr	LD5AC				;	D4FC
;	ldy	#$20				;	D4FF
;	ldx	#$24				;	D501
;	jsr	x_exchange_300_3Y_with_300_3X	;	D503
plot_filhorz_back_qry				; LD506
	TODO	"plot_filhorz_back_qry - plot fill back?"
;	jsr	LD4AA				;	D506
;	ldx	#$04				;	D509
;	jsr	LD592				;	D50B
;	txa					;	D50E
;	bne	LD513				;	D50F
;	dec	zp_vdu_wksp_draw_flags			;	D511
;LD513:	dex					;	D513
;LD514:	jsr	LD54B				;	D514
;	bcc	LD540				;	D517
;LD519:	jsr	x_move_display_move_right_to_next_cell				;	D519
;	lda	(zp_vdu_gra_char_cell),y	;	D51C
;	eor	vduvar_GRA_BACK			;	D51E
;	sta	zp_vdu_wksp			;	D521
;	lda	zp_vdu_wksp+2			;	D523
;	bne	LD514				;	D525
;	lda	zp_vdu_wksp			;	D527
;	bne	LD53D				;	D529
;	sec					;	D52B
;	txa					;	D52C
;	adc	vduvar_PIXELS_PER_BYTE_MINUS1	;	D52D
;	bcc	LD536				;	D530
;	inc	zp_vdu_wksp_draw_flags			;	D532
;	bpl	LD53D				;	D534
;LD536:	tax					;	D536
;	jsr	x_mos_vdu_gra_drawpixel_whole_byte				;	D537
;	sec					;	D53A
;	bcs	LD519				;	D53B
;LD53D:	jsr	LD54B				;	D53D
;LD540:	ldy	#$04				;	D540
;	jsr	LD5AC				;	D542
;LD545:	jsr	mos_PLOT_MOVE_absolute				;	D545
;	jmp	x_calculate_external_coordinates_from_internal_coordinates;	D548
;; ----------------------------------------------------------------------------
;LD54B:	lda	zp_vdu_grpixmask		;	D54B
;	pha					;	D54D
;	clc					;	D54E
;	bcc	LD560				;	D54F
;LD551:	pla					;	D551
;	inx					;	D552
;	bne	LD559				;	D553
;	inc	zp_vdu_wksp_draw_flags			;	D555
;	bpl	LD56F				;	D557
;LD559:	lsr	zp_vdu_grpixmask		;	D559
;	bcs	LD56F				;	D55B
;	ora	zp_vdu_grpixmask		;	D55D
;	pha					;	D55F
;LD560:	lda	zp_vdu_grpixmask		;	D560
;	bit	zp_vdu_wksp			;	D562
;	php					;	D564
;	pla					;	D565
;	eor	zp_vdu_wksp+2			;	D566
;	pha					;	D568
;	plp					;	D569
;	beq	LD551				;	D56A
;	pla					;	D56C
;	eor	zp_vdu_grpixmask		;	D56D
;LD56F:	sta	zp_vdu_grpixmask		;	D56F
;	jmp	x_mos_vdu_gra_drawpixels_in_grpixmask				;	D571
;; ----------------------------------------------------------------------------
;LD574:	lda	#$00				;	D574
;	clc					;	D576
;	bcc	LD583				;	D577
;LD579:	inx					;	D579
;	bne	LD580				;	D57A
;	inc	zp_vdu_wksp_draw_flags			;	D57C
;	bpl	LD56F				;	D57E
;LD580:	asl	a				;	D580
;	bcs	LD58E				;	D581
;LD583:	ora	zp_vdu_grpixmask		;	D583
;	bit	zp_vdu_wksp			;	D585
;	beq	LD579				;	D587
;	eor	zp_vdu_grpixmask		;	D589
;	lsr	a				;	D58B
;	bcc	LD56F				;	D58C
;LD58E:	ror	a				;	D58E
;	sec					;	D58F
;	bcs	LD56F				;	D590
;LD592:	lda	vduvar_GRA_WINDOW_LEFT,x	;	D592
;	sec					;	D595
;	sbc	vduvar_VDU_Q_END - 4			;	D596
;	tay					;	D599
;	lda	vduvar_GRA_WINDOW_LEFT+1,x	;	D59A
;	sbc	vduvar_VDU_Q_END - 3			;	D59D
;	bmi	LD5A5				;	D5A0
;	jsr	x_negation_routine		;	D5A2
;LD5A5:	sta	zp_vdu_wksp_draw_flags			;	D5A5
;	tya					;	D5A7
;	tax					;	D5A8
;	ora	zp_vdu_wksp_draw_flags			;	D5A9
;	rts					;	D5AB
;; ----------------------------------------------------------------------------
;LD5AC:	sty	zp_vdu_wksp			;	D5AC
;	txa					;	D5AE
;	tay					;	D5AF
;	lda	zp_vdu_wksp_draw_flags			;	D5B0
;	bmi	LD5B6				;	D5B2
;	lda	#$00				;	D5B4
;LD5B6:	ldx	zp_vdu_wksp			;	D5B6
;	bne	LD5BD				;	D5B8
;	jsr	x_negation_routine		;	D5BA
;LD5BD:	pha					;	D5BD
;	clc					;	D5BE
;	tya					;	D5BF
;	adc	vduvar_GRA_WINDOW_LEFT,x	;	D5C0
;	sta	vduvar_VDU_Q_END - 4			;	D5C3
;	pla					;	D5C6
;	adc	vduvar_GRA_WINDOW_LEFT+1,x	;	D5C7
;	sta	vduvar_VDU_Q_END - 3			;	D5CA
;	rts					;	D5CD
;; ----------------------------------------------------------------------------
;; OSWORD 13 read last two graphic cursor positions;  
;mos_OSWORD_13:
;	lda	#$03				;	D5CE
;	jsr	LD5D5				;	D5D0
;	lda	#$07				;	D5D3
;LD5D5:	pha					;	D5D5
;	jsr	x_exg4atGRACURINTwithGRACURINTOLD				;	D5D6
;	jsr	x_calculate_external_coordinates_from_internal_coordinates;	D5D9
;	ldx	#$03				;	D5DC
;	pla					;	D5DE
;	tay					;	D5DF
;LD5E0:	lda	vduvar_GRA_CUR_EXT,x		;	D5E0
;	sta	(zp_mos_OSBW_X),y		;	D5E3
;	dey					;	D5E5
;	dex					;	D5E6
;	bpl	LD5E0				;	D5E7
;	rts					;	D5E9
;; ----------------------------------------------------------------------------
;; PLOT Fill triangle routine
mos_PLOT_Fill_triangle_routine
	TODO "mos_PLOT_Fill_triangle_routine"
;	ldx	#$20				;	D5EA
;	ldy	#$3E				;	D5EC
;	jsr	copy8fromXtoY				;	D5EE
;	jsr	LD632				;	D5F1
;	ldx	#$14				;	D5F4
;	ldy	#$24				;	D5F6
;	jsr	LD636				;	D5F8
;	jsr	LD632				;	D5FB
;	ldx	#$20				;	D5FE
;	ldy	#$2A				;	D600
;	jsr	x_coords_to_width_height				;	D602
;	lda	vduvar_TEMP_8+3		;	D605
;	sta	vduvar_GRA_WKSP+2		;	D608
;	ldx	#$28				;	D60B
;	jsr	LD459				;	D60D
;	ldy	#$2E				;	D610
;	jsr	x_copyplotcoordsexttoY				;	D612
;	jsr	x_exg4atGRACURINTwithGRACURINTOLD				;	D615
;	clc					;	D618
;	jsr	LD658				;	D619
;	jsr	x_exg4atGRACURINTwithGRACURINTOLD				;	D61C
;	ldx	#$20				;	D61F
;	jsr	x_exchange_4atGRACUREXTOLDwithX				;	D621
;	sec					;	D624
;	jsr	LD658				;	D625
;	ldx	#$3E				;	D628
;	ldy	#$20				;	D62A
;	jsr	copy8fromXtoY				;	D62C
;	jmp	mos_PLOT_MOVE_absolute				;	D62F
;; ----------------------------------------------------------------------------
;LD632:	ldx	#$20				;	D632
;	ldy	#$14				;	D634
;LD636:	lda	vduvar_GRA_WINDOW_BOTTOM,x	;	D636
;	cmp	vduvar_GRA_WINDOW_BOTTOM,y	;	D639
;	lda	vduvar_GRA_WINDOW_BOTTOM+1,x	;	D63C
;	sbc	vduvar_GRA_WINDOW_BOTTOM+1,y	;	D63F
;	bmi	LD657				;	D642
;	jmp	x_exchange_300_3Y_with_300_3X	;	D644
;; ----------------------------------------------------------------------------
;; OSBYTE 134  Read cursor position
mos_OSBYTE_134
	clra
	ldb	vduvar_TXT_CUR_X		;	D647
	subb	vduvar_TXT_WINDOW_LEFT		;	D64B
	tfr	D,X
	ldb	vduvar_TXT_CUR_Y		;	D64F
	subb	vduvar_TXT_WINDOW_TOP		;	D653
	tfr	D,Y
LD657	rts					;	D657
;; ----------------------------------------------------------------------------
;LD658:	php					;	D658
;	ldx	#$20				;	D659
;	ldy	#$35				;	D65B
;	jsr	x_coords_to_width_height				;	D65D
;	lda	vduvar_GRA_WKSP+6		;	D660
;	sta	$033D				;	D663
;	ldx	#$33				;	D666
;	jsr	LD459				;	D668
;	ldy	#$39				;	D66B
;	jsr	x_copyplotcoordsexttoY				;	D66D
;	sec					;	D670
;	lda	vduvar_VDU_Q_END - 2			;	D671
;	sbc	vduvar_GRA_CUR_INT+2		;	D674
;	sta	vduvar_VDU_Q_END - 9;	D677
;	lda	vduvar_VDU_Q_END - 1			;	D67A
;	sbc	vduvar_GRA_CUR_INT+3		;	D67D
;	sta	$031C				;	D680
;	ora	vduvar_VDU_Q_END - 9;	D683
;	beq	LD69F				;	D686
;LD688:	jsr	LD6A2				;	D688
;	ldx	#$33				;	D68B
;	jsr	LD774				;	D68D
;	ldx	#$28				;	D690
;	jsr	LD774				;	D692
;	inc	vduvar_VDU_Q_END - 9;	D695
;	bne	LD688				;	D698
;	inc	$031C				;	D69A
;	bne	LD688				;	D69D
;LD69F:	plp					;	D69F
;	bcc	LD657				;	D6A0

;LD6A2:	ldx	#$39				;	D6A2
;	ldy	#$2E				;	D6A4

*****************************************************
* OLD API X,Y contained PAGE 3 relative pointers to *
* start end of line to plot			    *
* now X,Y contain full pointers			    *
*****************************************************

x_vdu_clear_gra_line_newAPI				; 	LD6A6
	stx	zp_vdu_wksp+4				;	check left < right, if not swap em
	ldd	,X
	cmpd	,Y
	blo	1F
	exg	X,Y
	stx	zp_vdu_wksp+4				; note: now using 4,6 instead of 4,5
1	sty	zp_vdu_wksp+6				; 
	ldd	0,y					; right on stack, we're going to use it to count down...
	pshs	D
	ldx	zp_vdu_wksp+6				; check right bound
	jsr	x_Check_window_limits_atX		;
	beq	1F					;

	cmpa	#$02					; check for bounds broken == right
	bne	3F					; if it's any other bound we're off the screen, skip this line
	ldd	vduvar_GRA_WINDOW_RIGHT			;
	std	0,X					; reset right bound to right edge of window/screen 
1	jsr	x_setup_screen_addr_from_intcoords_atX	; setup the screen address pointer
	ldx	zp_vdu_wksp+4				; check left pointer bounds
	jsr	x_Check_window_limits_atX		;
	lsra						; shift right, Left broken into carry rest in A
	bne	3F					; if anything other than left we're off the screen, skip line
	bcc	1F					; if not C then left bound ok
	ldx	#vduvar_GRA_WINDOW_LEFT			;
1	ldd	[zp_vdu_wksp+6]				; subtract left coord (or window left if bounds broken) from right 
	subd	,x					; to get width
	std	zp_vdu_wksp+2				; store here
	clra
LD6FE	asla						; shift left one
	ora	zp_vdu_grpixmask			; copy in another right most pixel to A
	ldb	zp_vdu_wksp+3				; decrement width counter
	bne	LD719					;
	dec	zp_vdu_wksp+2				;
	bpl	LD719					;
	sta	zp_vdu_grpixmask			; we're at the left of the line, plot pixels in current pixel mask
	jsr	x_mos_vdu_gra_drawpixels_in_grpixmask
3	puls	D		
	std	[zp_vdu_wksp+6]				; restore right bound
	rts						; done
;; ----------------------------------------------------------------------------
LD719	dec	zp_vdu_wksp+3				; decrement width counter
	tsta						; see if we've filled up A with pixel mask bits
	bpl	LD6FE					; if not try another pixel
	sta	zp_vdu_grpixmask			; store the pixel mask
	jsr	x_mos_vdu_gra_drawpixels_in_grpixmask 	; and plot
	lda	zp_vdu_wksp+3				; get low byte of width counter
	inca						; increment it
	bne	LD72A					;
	inc	zp_vdu_wksp+2				; and high byte if needed
LD72A	pshs	A					; store updated low byte on stack
	lsr	zp_vdu_wksp+2				; divide by width low by two
	rora						; divide A by two
	ldb	vduvar_PIXELS_PER_BYTE_MINUS1		; get pixels per byte
	cmpb	#$03					; 
	beq	LD73B					;
	bcs	LD73E					;
	lsr	zp_vdu_wksp+2				;
	rora						;
LD73B	lsr	zp_vdu_wksp+2				;
	lsra						; 
LD73E	ldb	vduvar_GRA_CUR_CELL_LINE		;
	tsta						;
	beq	LD753					;	D742
LD744	subb	#$08					;	D746
	bcc	LD74D					;	D749
	dec	zp_vdu_gra_char_cell + 0		;	D74B
LD74D	jsr	x_mos_vdu_gra_drawpixel_whole_byte
	deca						;	D750
	bne	LD744					;	D751


LD753
	puls	A				;	D753
	anda	vduvar_PIXELS_PER_BYTE_MINUS1	;	D754
	beq	3B				;	D757
	pshs	B
	clrb					;	D75A
LD75C	aslb					;	D75C
	orb	vduvar_RIGHTMOST_PIX_MASK	;	D75D
	deca					;	D760
	bne	LD75C				;	D761
	stb	zp_vdu_grpixmask		;	D763
	puls	B
	subb	#$08				;	D767
	bcc	LD76E				;	D76A
	dec	zp_vdu_gra_char_cell		;	D76C
LD76E	jsr	x_mos_vdu_gra_drawpixels_in_grpixmask_cell_line_in_B				;	D76E
	jmp	3B				;	D771
;; ----------------------------------------------------------------------------
;LD774:	inc	vduvar_TXT_WINDOW_LEFT,x	;	D774
;	bne	LD77C				;	D777
;	inc	vduvar_TXT_WINDOW_BOTTOM,x	;	D779
;LD77C:	sec					;	D77C
;	lda	vduvar_GRA_WINDOW_LEFT,x	;	D77D
;	sbc	vduvar_GRA_WINDOW_BOTTOM,x	;	D780
;	sta	vduvar_GRA_WINDOW_LEFT,x	;	D783
;	lda	vduvar_GRA_WINDOW_LEFT+1,x	;	D786
;	sbc	vduvar_GRA_WINDOW_BOTTOM+1,x	;	D789
;	sta	vduvar_GRA_WINDOW_LEFT+1,x	;	D78C
;	bpl	LD7C1				;	D78F
;LD791:	lda	vduvar_TXT_WINDOW_RIGHT,x	;	D791
;	bmi	LD7A1				;	D794
;	inc	vduvar_GRA_WINDOW_TOP,x		;	D796
;	bne	LD7AC				;	D799
;	inc	vduvar_GRA_WINDOW_TOP+1,x	;	D79B
;	jmp	LD7AC				;	D79E
;; ----------------------------------------------------------------------------
;LD7A1:	lda	vduvar_GRA_WINDOW_TOP,x		;	D7A1
;	bne	LD7A9				;	D7A4
;	dec	vduvar_GRA_WINDOW_TOP+1,x	;	D7A6
;LD7A9:	dec	vduvar_GRA_WINDOW_TOP,x		;	D7A9
;LD7AC:	clc					;	D7AC
;	lda	vduvar_GRA_WINDOW_LEFT,x	;	D7AD
;	adc	vduvar_GRA_WINDOW_RIGHT,x	;	D7B0
;	sta	vduvar_GRA_WINDOW_LEFT,x	;	D7B3
;	lda	vduvar_GRA_WINDOW_LEFT+1,x	;	D7B6
;	adc	vduvar_GRA_WINDOW_RIGHT+1,x	;	D7B9
;	sta	vduvar_GRA_WINDOW_LEFT+1,x	;	D7BC
;	bmi	LD791				;	D7BF
;LD7C1:	rts					;	D7C1
;; ----------------------------------------------------------------------------
;; OSBYTE 135  Read character at text cursor position
mos_OSBYTE_135
	tst	vduvar_COL_COUNT_MINUS1			;	D7C2
	bne	LD7DC					;	D7C5
	lda	[zp_vdu_top_scanline]			;	D7C7
	jsr	x_convert_teletext_characters						; TODO - check this is right!
;;;	ldy	#$02					;	D7C9
;;;LD7CB	cmpa	mostbl_TTX_CHAR_CONV+1,y		;	D7CB
;;;	bne	LD7D4					;	D7CE
;;;	lda	mostbl_TTX_CHAR_CONV,y			;	D7D0
;;;	dey						;	D7D3
;;;LD7D4	dey						;	D7D4
;;;	bpl	LD7CB					;	D7D5
mos_OSBYTE_135_YeqMODE_XeqArts
	LDY_B	vduvar_MODE				;	D7D7
	m_tax						;	D7DA
	rts						;	D7DB
;; ----------------------------------------------------------------------------
LD7DC	jsr	x_set_up_pattern_copy			;set up copy of the pattern bytes at text cursor
	lda	#$20					;X=&20
	ldx	#vduvar_TEMP_8
	sta	zp_vdu_wksp				;store current char
	bra	1F
mos_OSBYTE_135_lp1					; LD7E1
;;;	txa					;A=&20
;;;	pha						;Save it
	lda	zp_vdu_wksp
1	jsr	x_calc_pattern_addr_for_given_char	;get pattern address for code in A
	ldy	zp_vdu_wksp + 4
;;;	pla						;get back A
;;;	tax						;and X
LD7E8	ldb	#$07					;Y=7
LD7EA	lda	B,X					;get byte in pattern copy
	cmpa	B,Y					;check against pattern source
	bne	LD7F9					;if not the same D7F9
	decb						;else Y=Y-1
	bpl	LD7EA					;and if +ve D7EA
	lda	zp_vdu_wksp
	cmpa	#$7F					;is X=&7F (delete)
	bne	mos_OSBYTE_135_YeqMODE_XeqArts		;if not D7D7
LD7F9	inc	zp_vdu_wksp				;else X=X+1
	beq	mos_OSBYTE_135_YeqMODE_XeqArts		; past 255 give up return A = 0
	leay	8,Y
	tfr	Y,D
	tstb
;	lda	zp_vdu_wksp+4				;get byte lo address
;	clc						;clear carry
;	adc	#$08					;add 8
;	sta	zp_vdu_wksp+4				;store it
	bne	LD7E8					;and go back to check next character if <>0
	bra	mos_OSBYTE_135_lp1			; recalc char pointer (may be into redeffed chars)
;; set up pattern copy
x_set_up_pattern_copy
	ldb	#$07				; Y=7
	ldx	zp_vdu_top_scanline
	ldy	#vduvar_TEMP_8
LD80A	stb	zp_vdu_wksp			; &DA=Y
	lda	#$01				; A=1 - this will rol out and signal end of loop
	sta	zp_vdu_wksp_draw_flags		; &DB=A
LD810	lda	vduvar_LEFTMOST_PIX_MASK	; A=left colour mask
	sta	zp_vdu_wksp+2			; store an &DC
	lda	B,X				; get a byte from current text character
	eora	vduvar_TXT_BACK			; EOR with text background colour
	CLC					; clear carry
LD81B	bita	zp_vdu_wksp+2			; and check bits of colour mask
	beq	LD820				; if result =0 then D820
	SEC					; else set carry
LD820	rol	zp_vdu_wksp_draw_flags		; &DB=&DB+Carry
	bcs	LD82E				; if carry now set (bit 7 DB originally set) D82E
	lsr	zp_vdu_wksp+2			; else  &DC=&DC/2 - roll screen bits right
	bcc	LD81B				; if carry clear D81B - keep going for this mask
;;;	tya					; A=Y
;;;	adc	#$07				; ADD ( (7+carry)
;;;	tay					; Y=A
	addb	#8
	bra	LD810				; 

LD82E	ldb	zp_vdu_wksp			; read modified values into Y and A
	lda	zp_vdu_wksp_draw_flags		; 
	sta	B,y				; store copy
	decb					; and do it again
	bpl	LD80A				; until 8 bytes copied
	rts					; exit
;; ----------------------------------------------------------------------------
;; pixel reading
;x_pixel_reading:
;	pha					;	D839
;	tax					;	D83A
;	jsr	x_set_up_and_adjust_positional_data;	D83B
;	pla					;	D83E
;	tax					;	D83F
;	jsr	x__check_in_window_bounds_setup_screen_addr_atX				;	D840
;	bne	LD85A				;	D843
;	lda	(zp_vdu_gra_char_cell),y	;	D845
;LD847:	asl	a				;	D847
;	rol	zp_vdu_wksp			;	D848
;	asl	zp_vdu_grpixmask		;	D84A
;	php					;	D84C
;	bcs	LD851				;	D84D
;	lsr	zp_vdu_wksp			;	D84F
;LD851:	plp					;	D851
;	bne	LD847				;	D852
;	lda	zp_vdu_wksp			;	D854
;	and	vduvar_COL_COUNT_MINUS1		;	D856
;	rts					;	D859
;; ----------------------------------------------------------------------------
;LD85A:	lda	#$FF				;	D85A
LD85Crts
	rts					;	D85C
;; ----------------------------------------------------------------------------
;; : check for window violations and set up screen address
x__check_in_window_bounds_setup_screen_addr
	ldx	#vduvar_VDU_Q_END - 4		;	D85D
x__check_in_window_bounds_setup_screen_addr_atX
	jsr	x_Check_window_limits_atX	;	D85F
	bne	LD85Crts				;	D862
x_setup_screen_addr_from_intcoords_atX	
	lda	3,X				; get y coord
	eora	#$FF				;	D867
	tfr	A,B				; todo speed this up by using D and MUL?
	anda	#$07				;	D86A
	sta	vduvar_GRA_CUR_CELL_LINE	;	D86C
	andb	#$F8
	lda	#640/8
	mul
	tst	vduvar_MODE_SIZE		;	D87C
	beq	LD884				;	D87F
	lsra
	rorb
LD884	addd	vduvar_6845_SCREEN_START	;	D884
	std	zp_vdu_gra_char_cell		;	D887
	ldd	,X
	pshs	D
	andb	vduvar_PIXELS_PER_BYTE_MINUS1	
	addb	vduvar_PIXELS_PER_BYTE_MINUS1	
	ldy	#mostbl_VDU_pix_mask_16colour - 1
	lda	b,y	
	sta	zp_vdu_grpixmask		
	ldb	vduvar_PIXELS_PER_BYTE_MINUS1	;	D8A6
	cmpb	#$03				;	D8A9
	puls	D
	beq	LD8B2				;	4 pixels per byte
	bhs	LD8B5				;	8 pixels per byte
						;	2 pixels per byte
	aslb
	rola
	aslb
	rola
	bra	LD8B5
LD8B2	 aslb
	rola
LD8B5	andb	#$F8				;	D8B5
	addd	zp_vdu_gra_char_cell
	bpl	LD8C6				;	D8C0
	suba	vduvar_SCREEN_SIZE_HIGH		;	D8C3
LD8C6	std	zp_vdu_gra_char_cell		;	D8C6
	ldb	vduvar_GRA_CUR_CELL_LINE	;	D8C8
LD8CBclrArts	
	clra
	rts					;	D8CD
;; ----------------------------------------------------------------------------
x_cursor_start					; LD8CE
	pshs	A				; Push A
;;;	lda	#$A0				; A=&A0
	ldb	sysvar_VDU_Q_LEN		; X=number of items in VDU queque
	bne	LD916pulsArts			; if not 0 D916
	tim	#$A0, zp_vdu_status
;;;	bita	zp_vdu_status			; else check VDU status byte
	bne	LD916pulsArts			; if either VDU is disabled or plot to graphics
						; cursor enabled then D916
	tim	#$40, zp_vdu_status
;;;	lda	#$40
;;;	bita	zp_vdu_status
	bne	1F				; if cursor editing enabled D8F5
	lda	vduvar_CUR_START_PREV		; else get 6845 register start setting
	anda	#$9F				; clear bits 5 and 6
	ora	#$40				; set bit 6 to modify last cursor size setting
	jsr	x_crtc_set_cursor		; change write cursor format
	ldx	#vduvar_TXT_CUR_X		; X=&18
	ldy	#vduvar_TEXT_IN_CUR_X		; Y=&64
	jsr	copy2fromXtoY			; set text input cursor from text output cursor
	jsr	x_start_cursor_edit_qry		; modify character at cursor poistion
	lda	#$02				; A=2
	jsr	x_ORA_with_vdu_status		; bit 1 of VDU status is set to bar scrolling
1
	lda	#$BF				;A=&BF
	jsr	mos_VDU_and_A_vdustatus		;bit 6 of VDU status =0 
	puls	A				;Pull A
	anda	#$7F				;clear hi bit (7)
	jsr	mos_VDU_WRCH			; exec up down left or right?
	lda	#$40				;A=&40
	jmp	x_ORA_with_vdu_status		;exit 
;; ----------------------------------------------------------------------------
x_cursor_COPY					; LD905
;;	lda	#$20				;A=&20
;;	bita	zp_vdu_status			
;;	bvc	LD8CBclrArts			;if bit 6 cursor editing is set
;;	bne	LD8CBclrArts			;or bit 5 is set exit &D8CB
	tim	#$40, zp_vdu_status
;;;	lda	#$40
;;;	bita	zp_vdu_status
	beq	LD8CBclrArts			; not cursor editing
	tim	#$20, zp_vdu_status
;;;	lda	#$20
;;;	bita	zp_vdu_status
	bne	LD8CBclrArts			; VDU5
	pshs	B
	jsr	mos_OSBYTE_135			;read a character from the screen
	puls	B
	tsta
	beq	LD917rts			;if A=0 on return exit via D917
	pshs	A				;else store A
	jsr	mos_VDU_9			;perform cursor right
LD916pulsArts	
	puls	A				;	D916
LD917rts	
	rts					;	D917
;; ----------------------------------------------------------------------------


x_cancel_cursor_edit				; LD918
	lda	#$BD				;	D918
	jsr	mos_VDU_and_A_vdustatus		;	D91A
	jsr	x_crtc_reset_cursor				;	D91D
	lda	#$0D				;	D920
	rts					;	D922
;; ----------------------------------------------------------------------------
;; OSBYTE 132  Read bottom of display RAM;  
mos_OSBYTE_132
	ldb	vduvar_MODE			; get current screen mode
;; OSBYTE 133  Read lowestFDBess for given mode
mos_OSBYTE_133
	andb	#$07				; modulo 7 TODO: EXTRA MODES
	ldx	#mostbl_VDU_mode_size
	ldb	B,X				;	D92A
	ldx	#mostbl_VDU_screebot_h
	lda	B,X				;	D92D
	clrb
	tfr	D,X				; return X is full adress, Y is high byte
	m_tay
;;;	tst	sysvar_RAM_AVAIL		;	D932 - removed < 32k check
;;;	bmi	LD93E				;	D935
;;;	anda	#$3F				;	D937
;;;	cpy	#$04				;	D939
;;;	bcs	LD93E				;	D93B
;;;	txa					;	D93D
;;;LD93E:	tay					;	D93E
	rts					;	D93F
;; ----------------------------------------------------------------------------
vec_table
	;TODO = fill these in!
	FDB	x_Bad_command_error		;  LD940 USERV
	FDB	mos_DEFAULT_BRK_HANDLER		;  LD942 BRKV
	FDB	mos_IRQ1V_default_entry		;  LD944 IRQ1V
	FDB	mos_IRQ2V_default_entry		;  LD946 IRQ2V
	FDB	mos_CLIV_default_handler	;  LD948 CLIV
	FDB	mos_default_BYTEV_handler	;  LD94A BYTEV
	FDB	mos_WORDV_default_entry		;  LD94C WORDV
	FDB	mos_WRCH_default_entry		;  LD94E WRCHV
	FDB	mos_RDCHV_default_entry		;  LD950 RDCHV
	FDB	dummy_vector_RTS		;  LD952 FILEV
	FDB	dummy_vector_RTS		;  LD954 ARGSV
	FDB	dummy_vector_RTS		;  LD956 BGETV
	FDB	dummy_vector_RTS 		;  LD958 BPUTV
	FDB	dummy_vector_RTS		;  LD95A GBPBV
	FDB	mos_FINDV_default_handler	;  LD95C FINDV
	FDB	mos_FSCV_default_handler	;  LD95E FSCV
	FDB	dummy_vector_RTS		;  LD960 EVNTV
	FDB	dummy_vector_RTS		;  LD962 UPTV
	FDB	dummy_vector_RTS		;  LD964 NETV
	FDB	dummy_vector_RTS		;  LD966 VDUV
	FDB	KEYV_default			;  LD968 KEYV
	FDB	mos_INSV_default_entry_point	;  LD96A INSV
	FDB	mos_REMV_default_entry_point	;  LD96C REMV
	FDB	mos_CNPV_default_entry_point	;  LD96E CNPV
	FDB	dummy_vector_RTS		;  LD970 IND1V
	FDB	dummy_vector_RTS		;  LD972 IND2V
	FDB	dummy_vector_RTS		;  LD974 IND3V
vec_table_end
;	FDB	x_Bad_command_error			;  LD940 USERV
;	FDB	mos_DEFAULT_BRK_HANDLER			;  LD942 BRKV
;	FDB	mos_IRQ1V_default_entry			;  LD944 IRQ1V
;	FDB	mos_IRQ2V_default_entry			;  LD946 IRQ2V
;	FDB	mos_default_CLIV_handler		;  LD948 CLIV
;	FDB	mos_default_BYTEV_handler		;  LD94A BYTEV
;	FDB	mos_WORDV_default_entry			;  LD94C WORDV
;	FDB	mos_WRCH_default_entry			;  LD94E WRCHV
;	FDB	mos_RDCHV_default_entry			;  LD950 RDCHV
;	FDB	mos_OSFILE_ENTRY			;  LD952 FILEV
;	FDB	mos_start_of_data_for_save		;  LD954 ARGSV
;	FDB	mos_OSBGET_get_a_byte_from_a_file	;  LD956 BGETV
;	FDB	mos_OSBPUT_WRITE_A_BYTE_TO_FILE 	;  LD958 BPUTV
;	FDB	dummy_vector_RTS			;  LD95A GBPBV
;	FDB	mos_FINDV_default_handler			;  LD95C FINDV
;	FDB	mos_FSCV_default_handler		;  LD95E FSCV
;	FDB	dummy_vector_RTS			;  LD960 EVNTV
;	FDB	dummy_vector_RTS			;  LD962 UPTV
;	FDB	dummy_vector_RTS			;  LD964 NETV
;	FDB	dummy_vector_RTS			;  LD966 VDUV
;	FDB	KEYV_default 	;  LD968 KEYV
;	FDB	mos_INSV_default_entry_point		;  LD96A INSV
;	FDB	mos_REMV_default_entry_point		;  LD96C REMV
;	FDB	mos_CNPV_default_entry_point	;  LD96E CNPV
;	FDB	dummy_vector_RTS			;  LD970 IND1V
;	FDB	dummy_vector_RTS			;  LD972 IND2V
;	FDB	dummy_vector_RTS			;  LD974 IND3V



;; ----------------------------------------------------------------------------
;; MOS VARIABLES DEFAULT SETTINGS
mostbl_SYSVAR_DEFAULT_SETTINGS				; LD976
	FDB	sysvar_OSVARADDR - $A6			; A6 default osvar base (minus A6 for osbyte offset)
	FDB	EXT_USERV				; A8 default start of extended vector table
	FDB	oswksp_ROMTYPE_TAB			; AA default start of rom info table
	FDB	key2ascii_tab - $10			; AC default start of keyboard to ASCII table
	
	FDB	vduvars_start				; AE base of VDU variables
	FCB	$00					; B0 CFS timeout
	FCB	$00					; B1 input source number (keyboard=0/serial=1/etc)
	FCB	$FF					; B2 keyboard semaphore
	FCB	$00					; B3 primary OSHWM for exploded font
	FCB	$00					; B4  B4 OSHWM
	FCB	$01 					; B5 Serial mode
	
	FCB	$00					; B6 char def exploded state
	FCB	$00					; B7 cassette/rom switch
	FCB	$00					; B8 video ULA copy (CTL)
	FCB	$00					; B9 video ULA copy (PAL?)
	FCB	$00					; BA ROM number active at BREAK
	FCB	$FF					; BB BASIC ROM number
	FCB	$04					; BC ADC channel
	FCB	$04					; BD Max ADC channel

	FCB	$00					; BE ADC conv type
	FCB	$FF					; BF RS423 use flag
	FCB	$56					; C0 RS423 ctl flag
	FCB	$19					; C1 flash counter
	FCB	$19					; C2 flash mark
	FCB	$19					; C3 flash space
	FCB	$32					; C4 keyboard autorepeat delay
	FCB	$08					; C5 keyboard autorepeat rate

	FCB	$00					; C6 *EXEC handle
	FCB	$00					; C7 *SPOOL handle
	FCB	$00					; C8 ESCAPE effect
	FCB	$00					; C9 keyboard disable
	FCB	$20					; CA keyboard status
	FCB	$09					; CB Serial handshake extent
	FCB	$00					; CC Serial suppression flag
	FCB	$00					; CD Serial/cassette select flag


	FCB	$00					; CE Econet OS Call intercept status
	FCB	$00					; CF Econet read char intercept status
	FCB	$00					; D0 Econet write char intercept status
	FCB	$50					; D1 Speech suppress $50=speak
	FCB	$00					; D2 Sound suppress
	FCB	$03					; D3 Bell channel
	FCB	$90					; D4 Bell vol, H, S
	FCB	$64					; D5 Bell freq

	FCB	$06					; D6 Bell duration
	FCB	$81					; D7 Startup message suppress/!BOOT lock
	FCB	$00					; D8 Soft key string
	FCB	$00					; D9 lines since page
	FCB	$00					; DA VDU Q len
	FCB	$09					; DB TAB char
	FCB	$1B					; DC ESCAPE char
	FCB	$01					; DD Input buffer C0-CF interpretation

	FCB	$D0					; DE Input buffer D0-DF interpretation
	FCB	$E0					; DF Input buffer E0-EF interpretation
	FCB	$F0					; E0 Input buffer F0-FF interpretation
	FCB	$01					; E1 fnKey status 80-8F
	FCB	$80					; E2 fnKey status 90-9F
	FCB	$90					; E3 fnKey status A0-AF
	FCB	$00					; E4 fnKey status B0-BF
	FCB	$00					; E5 ESCAPE key action

	FCB	$00					; E6 ESCAPE effects
	FCB	$FF					; E7 IRQ mask for user VIA
	FCB	$FF					; E8 IRQ mask for 6850 
	FCB	$FF					; E9 IRQ mask for system VIA
	FCB	$00					; EA TUBE flag
	FCB	$00					; EB Speech flag
	FCB	$00					; EC char dest status
	FCB	$00					; ED cursor edit status
	
	FCB	$00					; EE location 27E (keypad numeric base Master)
	FCB	$00					; EF location 27F (?)
	FCB	$00					; F0 location 280 (Country code)
	FCB	$00					; F1 location 281 (user flag)
	FCB	$64					; F2 Serial ULA copy
	FCB	$05					; F3 Timer switch state
	FCB	$FF					; F4 Soft key consistency
	FCB	$01					; F5 Printer dest

	FCB	$0A,$00,$00,$00,$00,$00,$FF	;	D9C6


 **************************************************************************
 **************************************************************************
 **                                                                      **
 **                                                                      **
 **      RESET (BREAK) ENTRY POINT                                       **
 **                                                                      **
 **      Power up Enter with nothing set, 6522 System VIA IER bits       **
 **      0 to 6 will be clear                                            **
 **                                                                      **
 **      BREAK IER bits 0 to 6 one or more will be set 6522 IER          **
 **      not reset by BREAK                                              **
 **                                                                      **
 **************************************************************************
 ************************************************************************** 

;; ----------------------------------------------------------------------------
mos_handle_res
	lda	#$3B				; rti instruction ( was $40 for 6502)
; Store RTI in 1st byte of NMI space
mos_handle_res_resnmi
		sta	vec_nmi				; store rti at start of NMI space
		SEI					; turn of interrupts in case
		lds	#STACKTOP			; this is different to 6502, setup system stack at PAGE 1
		lda	#MOSROMSYS_DP			; and DP at PAGE 0
		tfr	a,dp

	IF NATIVE
		; ENTER NATIVE MODE
		LDMD	#3
	ENDIF


	IF	NOICE
		jsr	noice_handle_res
	ENDIF


		DEBUGPR	"mos_handle_res"
		lda	SHEILA_ROMCTL_RAM		; if bit 7 set this is a cold reset
		clr	SHEILA_ROMCTL_RAM		; clear and set RAM to bank 0
		pshs	a				;save what's left
		tsta
		bmi	mos_handle_res_skip_clear_mem1	;if Power up A bit 7 == 1 
		lda	sysvar_BREAK_EFFECT		;else if BREAK pressed read BREAK Action flags (set by
							;*FX200,n) 
		lsra					;divide by 2
		cmpa	#$01				;if (bit 1 not set by *FX200)
		bne	mos_handle_res_skip_clear_mem2	;then &DA03
		lsra					;divide A by 2 again (A=0 if *FX200,2/3 else A=n/4


; Always clear memory if no sys via interrupts enabled i.e. hard RES
mos_handle_res_skip_clear_mem1
		DEBUGPR	"hard reset"

;TODO - this commented out to stop the noIce debugger getting trampled!

;	ldx	#$400
;; Clear memory 0x0400 upwards - this used to do the 16/32 K check, here we just clear everything except D00 (RTI instruction) up to $7FFF
;mos_handle_res_clear_lp1
;	clr	,X+
;	cmpx	#$8000
;	beq	1F
;	cmpx	#vec_nmi
;	bne	mos_handle_res_clear_lp1
;	leax	1,X
;	bra	mos_handle_res_clear_lp1

;;;;;; special noice version leave holes at $D00-$D01, $A00-$B00
	clr	$400
	ldw	#$A00-$401
	ldx	#$400
	ldy	#$401
	tfm	X,Y+
	ldy	#$B00
	ldw	#$D00-$B01
	tfm	X,Y+
	ldy	#$D01
	ldw	#$8000-$D01
	tfm	X,Y+


1	lda	#$80
	sta	sysvar_RAM_AVAIL
	sta	sysvar_KEYB_SOFT_CONSISTANCY

;; Don't clear memory if clear memory flag not set
mos_handle_res_skip_clear_mem2
	ldb	#$8F				;	DA03
	stb	sheila_SYSVIA_ddrb		;	DA05

 *************************************************************************
 *                                                                       *
 *        set addressable latch IC 32 for peripherals via PORT B         *
 *                                                                       *
 *       ;bit 3 set sets addressed latch high adds 8 to VIA address      *
 *       ;bit 3 reset sets addressed latch low                           *
 *                                                                       *
 *       Peripheral              VIA bit 3=0             VIA bit 3=1     *
 *                                                                       *
 *       Sound chip              Enabled                 Disabled        *
 *       speech chip (RS)        Low                     High            *
 *       speech chip (WS)        Low                     High            *
 *       Keyboard Auto Scan      Disabled                Enabled         *
 *       C0 address modifier     Low                     High            * NOTE: Not used on 6809
 *       C1 address modifier     Low                     High            * NOTE: Not used on 6809
 *       Caps lock  LED          ON                      OFF             *
 *       Shift lock LED          ON                      OFF             *
 *                                                                       *
 *       C0 & C1 are involved with hardware scroll screen address        * NOTE: Not used on 6809
 *************************************************************************
							;B=&F on entry
1	decb						;loop start
	stb	sheila_SYSVIA_orb			;Write latch IC32
	cmpb	#$09					;Is it 9?
	bhs	1B					;If not go back and do it again
							;B=8 at this point
							;Caps Lock On, SHIFT Lock undetermined
							;Keyboard Autoscan on
							;Sound disabled (may still sound)
	clr	sysvar_BREAK_LAST_TYPE			;Clear last BREAK flag
	incb						;B=9
LDA11	tfr	b,a					;A=B
	jsr	keyb_check_key_code_API			;Interrogate keyboard
;	cmpb	#$80					; - change this as was reversing C
	addb	#$80					; - TODO: check works!
							;for keyboard links 9-2 and CTRL key (1)
	ror	zp_mos_INT_A				;rotate MSB into bit 7 of &FC
	tfr	a,b					;Get back value of X for loop
	decb						;Decrement it
	bne	LDA11					;and if >0 do loop again
							;On exit if Carry set link 3 is made
							;link 2 = bit 0 of &FC and so on
							;If CTRL pressed bit 7 of &FC=1 X=0
	rol	zp_mos_INT_A				;CTRL is now in carry &FC is keyboard links	
	jsr	x_Turn_on_Keyboard_indicators		;Set LEDs
							;Carry set on entry is in bit 0 of A on exit
	rora						;Get carry back into carry flag
x_set_up_page_2
	ldx	#$9C					;
	ldy	#$8D					;
;;	puls	A					;get back A from &D9DB
;;	tsta
;;	beq	LDA36					;if A=0 power up reset so DA36 with X=&9C Y=&8D
	tst	,S+
	bmi	LDA36
	ldy	#$7E					;else Y=&7E
	bcc	x_set_up_page_2_2			;and if not CTRL-BREAK DA42 WARM RESET
	ldy	#$87					;else Y=&87 COLD RESET
	inc	sysvar_BREAK_LAST_TYPE			;&28D=1
LDA36	inc	sysvar_BREAK_LAST_TYPE			;&28D=&28D+1
	lda	zp_mos_INT_A				;get keyboard links set
	eora	#$FF					;invert
	sta	sysvar_STARTUP_OPT			;and store at &28F
	ldx	#$90					;X=&90
	

	DEBUGPR	"Setup page 2"

;; : set up page 2; on entry	   &28D=0 Warm reset, X=&9C, Y=&7E ; &28D=1 Power up  , X=&90, Y=&8D ; &28D=2 Cold reset, X=&9C, Y=&87 
x_set_up_page_2_2
	clra
x_setup_pg2_lp0	
	cmpx	#$CE					;zero &200+X to &2CD
	blo	x_setup_pg2_sk1				;	DA46
	lda	#$FF					;then set &2CE to &2FF to &FF
x_setup_pg2_sk1
	sta	$200,x					;LDA4A
	leax	1,x
	cmpx	#$100
	bne	x_setup_pg2_lp0			;	DA4E
	sta	sheila_USRVIA_ddra		;	DA50

	DEBUGPR	"Setup zp"
	ldx	#zp_cfs_w
LDA56	clr	,x+					;zero zeropage &E2 to &FF
	cmpx	#$100
	bne	LDA56				;	DA59

	DEBUGPR	"Setup vectors"


LDA5B	lda	vec_table - 1,y			;	DA5B
	sta	USERV - 1,y			;	DA5E
	leay	-1,y				;	DA61
	bne	LDA5B				;	DA62
	lda	#$62				;	DA64
	sta	zp_mos_keynumfirst		;	DA66
	; TODO:ACIA
;	jsr	LFB0A				;	DA68

	DEBUGPR "Setup vias"

; clear interrupt and enable registers of Both VIAs
x_clear_IFR_IER_VIAs
	ldd	#$7F7F
	std	sheila_SYSVIA_ifr			; disable and clear interrupts on system
	std	sheila_USRVIA_ifr			; and user vias
	clr	-2,S					; clear the stack
	CLI						; briefly allow interrupts to clear anything pending
	SEI						; disallow again N.B. All VIA IRQs are disabled
;;	lda	#$40
;;	bita	zp_mos_INT_A				; if bit 6=1 then JSR &F055 (normally 0) 
	tst	-2,S					; if this is set then an interrupt occurred
	beq	LDA80					; else DA80
	jsr	[$FDFE]					; if IRQ held low at BREAK then jump to address held in
							; FDFE (JIM) 
LDA80	
	lda	#$F2					;enable interrupts 1,4,5,6 of system VIA
	sta	sheila_SYSVIA_ier			;
							;0      Keyboard enabled as needed
							;1      Frame sync pulse
							;4      End of A/D conversion
							;5      T2 counter (for speech)
							;6      T1 counter (10 mSec intervals)
							;
	lda	#$04					;set system VIA PCR
	sta	sheila_SYSVIA_pcr			;
							;CA1 to interrupt on negative edge (Frame sync)
							;CA2 Handshake output for Keyboard
							;CB1 interrupt on negative edge (end of conversion)
							;CB2 Negative edge (Light pen strobe)
	lda	#$60					;                       
	sta	sheila_SYSVIA_acr			;set system VIA ACR
							;disable latching
							;disable shift register
							;T1 counter continuous interrupts
							;T2 counter timed interrupt
	lda	#$0E					;set system VIA T1 counter (Low)
	sta	sheila_SYSVIA_t1ll			;this becomes effective when T1 hi set

	sta	sheila_USRVIA_pcr			;set user VIA PCR
							;CA1 interrupt on -ve edge (Printer Acknowledge)
							;CA2 High output (printer strobe)
							;CB1 Interrupt on -ve edge (user port) 
							;CB2 Negative edge (user port)
;TODO ADC
;;	sta	LFEC0					;set up A/D converter
							;Bits 0 & 1 determine channel selected
							;Bit 3=0 8 bit conversion bit 3=1 12 bit

	cmpa	sheila_USRVIA_pcr			;read user VIA IER if = &0E then DAA2 chip present 
	beq	LDAA2					;so goto DAA2
	inc	sysvar_USERVIA_IRQ_MASK_CPY		;else increment user VIA mask to 0 to bar all 
							;user VIA interrupts

LDAA2	lda	#$27					;set T1 (hi) to &27 this sets T1 to &270E (9998 uS)
	sta	sheila_SYSVIA_t1lh			;or 10msec, interrupts occur every 10msec therefore
	sta	sheila_SYSVIA_t1ch			;

	DEBUGPR	"snd_init"

	jsr	snd_init					;clear the sound channels

	;TODO:SERPROC
;	lda	sysvar_SERPROC_CTL_CPY			;read serial ULA control register
;	and	#$7F					;zero bit 7
;	jsr	LE6A7					;and set up serial ULA

	tst	sysvar_KEYB_SOFT_CONSISTANCY		;get soft key status flag
	beq	mos_cat_swroms  ;if 0 (keys OK) then DABD
	jsr	mos_OSBYTE_18			;else reset function keys


	DEBUGPR	"catalogue ROMs"
; Check sideways ROMS and make catalogue; X=0 
		clrb
mos_cat_swroms
		jsr	mos_select_SWROM_B		;set up ROM latch and RAM copy to X
		ldy	#copyright_symbol_backwards+4	;set X to point to offset in table
		ldb	$8007				;get copyright offset from ROM
							; DF0C = )C( BRK
		ldx	#$8000
		abx					; X now points at 0 byte before (C) if a rom
		ldb	#4
1		lda	,x+				;get first byte
		cmpa	,-y				;compare it with table byte
		bne	mos_cat_swroms_skipnotrom	;if not the same then goto DAFB
		decb					;(s)
		bne	1B				;and if still +ve go back to check next byte
;; there are no matches, if a match found ignore lower priority ROM ???CHECK???
mos_ignore_lower_priority_ROM
		ldb	zp_mos_curROM			;get RAM copy of ROM No. in B

mos_cat_swroms_cmplp_nexthighter			; LDAD5
		incb					;increment B to check 
		cmpb	#$10				;if ROM 15 is current ROM
		bhs	mos_cat_swroms_skipvalid	;if equal or more than 16 goto &DAFF
							;to store catalogue byte
		ldx	#$8000
mos_cat_swroms_cmplp
		lda	zp_mos_curROM
		sta	SHEILA_ROMCTL_SWR		;set cur ROM
		lda	,x				;Get byte 
		stb	SHEILA_ROMCTL_SWR		;switch back to new ROM
		cmpa	,x+				;and compare with previous byte called
		bne	mos_cat_swroms_cmplp_nexthighter;if not the same then go back and do it again
							;with next rom up
		cmpx	#$C000				;&84 (all 16k checked) DB: Note OS1.2 only compares first 1K TODO: put this back to 1K?
		blo	mos_cat_swroms_cmplp		;then check next byte(s)
mos_cat_swroms_skipnotrom			; LDAFB
		ldb	zp_mos_curROM			;B=(&F4)
		bra	mos_cat_swroms_skipnext		;always &DB0C
mos_cat_swroms_skipvalid				; LDAFF	
		ldb	zp_mos_curROM
		stb	SHEILA_ROMCTL_SWR
		lda	$8006				;get rom type
		ldx	#oswksp_ROMTYPE_TAB
		sta	B,X				;store it in catalogue
		anda	#$8F				;check for BASIC (bit 7 not set)
		bne	mos_cat_swroms_skipnext		;if not BASIC the DB0C
		stb	sysvar_ROMNO_BASIC		;else store X at BASIC pointer
mos_cat_swroms_skipnext					;LDB0C
		incb					;increment X to point to next ROM
		cmpb	#$10				;is it 15 or less
		blo	mos_cat_swroms			;if so goto &DABD for next ROM

;TODO - Speech
;; Check SPEECH System; X=&10 
;mos_Check_SPEECH_System:
;	bit	sheila_SYSVIA_orb		;	DB11
;	bmi	x_SCREEN_SET_UP			;	DB14
;	dec	sysvar_SPEECH_PRESENT		;	DB16
;LDB19:	ldy	#$FF				;	DB19
;	jsr	mos_OSBYTE_159			;	DB1B
;	dex					;	DB1E
;	bne	LDB19				;	DB1F
;	stx	sheila_SYSVIA_t2cl		;	DB21
;	stx	sheila_SYSVIA_t2ch		;	DB24

	* TODO: DOM - force non interlace mode
	lda	#1
	sta	oswksp_VDU_INTERLACE


; SCREEN SET UP; X=0 
x_SCREEN_SET_UP
	DEBUGPR "x_SCREEN_SET_UP"
	lda	sysvar_STARTUP_OPT			;get back start up options (mode)
	jsr	mos_jump2vdu_init			;then jump to screen initialisation
	ldy	#$CA					;Y=&CA
	jsr	x_INSERT_byte_in_Keyboard_buffer	;to enter this in keyboard buffer
							;this enables the *KEY 10 facility
;; enter BREAK intercept with Carry Clear
;TODO - ROMS
;TODO - TUBE
	jsr	mos_OSBYTE_247
;TODO - cassette
;	jsr	x_set_cassette_options		;	DB35
;	lda	#$81				;	DB38
;	sta	LFEE0				;	DB3A
;	lda	LFEE0				;	DB3D
;	ror	a				;	DB40
;	bcc	LDB4D				;	DB41
;	ldBBB	#$FF				;	DB43
;	jsr	mos_OSBYTE_143_b_cmd_x_param;	DB45
;	bne	LDB4D				;	DB48
;	dec	sysvar_TUBE_PRESENT		;	DB4A
;LDB4D:	
	ldx	#$0E				;	DB4D
	ldb	#SERVICE_1_ABSWKSP_REQ		;	DB4F
	jsr	mos_OSBYTE_143_b_cmd_x_param	;	DB51
	ldb	#SERVICE_2_RELWKSP_REQ		;	DB54
	jsr	mos_OSBYTE_143_b_cmd_x_param	;	DB56
	tfr	X,D
	stb	sysvar_PRI_OSHWM
	stb	sysvar_CUR_OSHWM			
;	ldBBB	#$FE				;	DB5F
;	ldy	sysvar_TUBE_PRESENT		;	DB61
;	jsr	mos_OSBYTE_143_b_cmd_x_param	;	DB64
;	and	sysvar_STARTUP_DISPOPT		;	DB67
;	bpl	LDB87				;	DB6A

	jsr	printWelcome1

	; TODO REMOVE THIS
	jsr	mos_PRTEXT
	fcb	"MOS=",0
	lda	SHEILA_ROMCTL_MOS
	jsr	PRHEX
	jsr	OSNEWL
	jsr	OSNEWL


	; TODO - work out memory size and print if a hard reset

LDB87
	orcc	#CC_C
	jsr	mos_OSBYTE_247			;look for break intercept jump do *TV etc
	jsr	mos_OSBYTE_118			;set up LEDs in accordance with keyboard status



;TODO - ROMS
	; changed from 6502 -> 6809 sign flag is in bit 3
	tfr	CC,B				; B now contains bit 1=shift
	aslb
	aslb					; get it into bit 3
	eorb	sysvar_STARTUP_OPT		;or with start up options which may or may not
	andb	#$08				;invert bit 3
	clra
	tfr	D,X				; set Y=0 for !BOOT or =8 for no boot
	ldb	#SERVICE_3_AUTOBOOT
	jsr	mos_OSBYTE_143_b_cmd_x_param	; pass round to FS ROMS
;	beq	x_Preserve_current_language_on_soft_RESET;	DB9F
;	tya					;	DBA1
;	bne	x_resettapespeed_enter_lang	;	DBA2
;	lda	#$8D				;	DBA4
;	jsr	mos_selects_ROM_filing_system	;	DBA6
	;;; STARRUNPLINGBOOT!!!!
;	ldx	#$D2				;	DBA9
;	ldy	#$EA				;	DBAB
;	dec	sysvar_STARTUP_DISPOPT		;	DBAD
;	jsr	OSCLI				;	DBB0
;	inc	sysvar_STARTUP_DISPOPT		;	DBB3
;	bne	x_Preserve_current_language_on_soft_RESET;	DBB6
x_resettapespeed_enter_lang
;	lda	#$00				;	DBB8
;	tax					;	DBBA
;	jsr	LF137				;	DBBB
;; Preserve current language on soft RESET
;x_Preserve_current_language_on_soft_RESET:
;	lda	sysvar_BREAK_LAST_TYPE		;	DBBE
;	bne	mos_SEARCH_FOR_LANGUAGE_TO_ENTER_Highest_priority;	DBC1
;	ldx	sysvar_CUR_LANG			;	DBC3
;	bpl	LDBE6				;	DBC6
;; SEARCH FOR LANGUAGE TO ENTER (Highest priority)
mos_SEARCH_FOR_LANGUAGE_TO_ENTER_Highest_priority
		ldb	#$0F				;set pointer to highest available rom
		ldx	#oswksp_ROMTYPE_TAB+$10
1							;LDBCA
		lda	,-x				;get rom type from map
		rola					;put hi-bit into carry, bit 6 into bit 7
		bmi	mos_lang_found			;if bit 7 set then ROM has a language entry so DBE6
		decb					;else search for language until B=&ff
		bpl	1B				;
;; check if tube present
;x_check_if_tube_present:
;	lda	#$00				;	DBD3
;	bit	sysvar_TUBE_PRESENT		;	DBD5
;	bmi	mos_TUBE_FOUND_enter_tube_software;	DBD8
;; no language error
x_no_language_error
	DO_BRK	$F9, "Language?"


x_mos_ENTER_ROM_X
		tfr	X,D				; get X low into B
		bra	x_mos_ENTER_ROM_B
mos_lang_found						; LDBE6
		CLC					;	DBE6
;;B=rom number C set if OSBYTE call clear if initialisation
x_mos_ENTER_ROM_B
		pshs	CC				;save flags
		stb	sysvar_CUR_LANG			;put X in current ROM page
		jsr	mos_select_SWROM_B		;select that ROM
		ldy	#$8009				;Y=8
		jsr	printAtY			;display text string held in ROM at &8009
		leay	-1,Y				;DB, printaty used to return with Y pointing at 0, not 1 place after
		sty	zp_mos_error_ptr		;save Y on exit (end of language string)
		jsr	OSNEWL				;two line feeds
		jsr	OSNEWL				;are output
		puls	CC				;then get back flags
		lda	#$01				;A=1 required for language entry
		; TODO TUBE
;		bit	sysvar_TUBE_PRESENT		;check if tube exists
;		bmi	mos_TUBE_FOUND_enter_tube_software;and goto DC08 if it does
		jmp	$8000				;else enter language at &8000

;; ----------------------------------------------------------------------------
;; TUBE FOUND enter tube software
mos_TUBE_FOUND_enter_tube_software
	TODO	"TUBE"
;	jmp	L0400				;	DC08

mos_get_SWROM_B_X_A_API
	lda	zp_mos_curROM
	sta	,-S
	jsr	mos_select_SWROM_B
	lda	,X
	ldb	,S+
;mos_select_SWROM_X:
mos_select_SWROM_B
	stb	zp_mos_curROM			;RAM copy of rom latch 
	stb	SHEILA_ROMCTL_SWR		;write to rom latch
	rts					;and return
;; ----------------------------------------------------------------------------
mos_handle_irq
	jmp	[IRQ1V]				;	DC24
;; ----------------------------------------------------------------------------
;; BRK handling routine	- TODO: test for native mode!
mos_handle_swi3
	pshs	CC,A,X
	SEI						; disable interrupts - 6809 doesn't do that for us!
	ldx	14,S					; points at byte after SWI instruction
	stx	zp_mos_error_ptr
	stx	2,S					; set X on return to this

	lda	zp_mos_curROM				; get currently active ROM
	sta	sysvar_ROMNO_ATBREAK			; and store it in &24A
	stx	zp_mos_OSBW_X				; store stack pointer in &F0
	ldb	#$06					; and issue ROM service call 6
	jsr	mos_OSBYTE_143_b_cmd_x_param		; (User BRK) to roms
							; at this point &FD/E point to byte after BRK
							; ROMS may use BRK for their own purposes 
	ldb	sysvar_CUR_LANG				; get current language
	jsr	mos_select_SWROM_B			; and activate it
	puls	CC,A,X					; restore A,X,CC
	CLI						; allow interrupts
	jmp	[BRKV]					; and JUMP via BRKV (normally into current language)
;; ----------------------------------------------------------------------------
;; DEFAULT BRK HANDLER
mos_DEFAULT_BRK_HANDLER
	ldy	zp_mos_error_ptr
	jsr	printAtY				;print message - including error number - TODO - is this right?
	lda	sysvar_STARTUP_DISPOPT			;if BIT 0 set and DISC EXEC error
	rora						;occurs
LDC5D	bcs	LDC5D					;hang up machine!!!!
	jsr	OSNEWL					;else print two newlines
	jsr	OSNEWL					;
	jmp	x_resettapespeed_enter_lang		;and set tape speed before entering current
							;language 
;; ----------------------------------------------------------------------------
;LDC68:	sec					;	DC68
;	ror	sysvar_RS423_USEFLAG		;	DC69
;	bit	sysvar_RS423_CTL_COPY		;	DC6C
;	bpl	LDC78				;	DC6F
;	jsr	x_check_RS423_input_buffer	;	DC71
;	ldx	#$00				;	DC74
;	bcs	LDC7A				;	DC76
;LDC78:	ldx	#$40				;	DC78
;LDC7A:	jmp	LE17A				;	DC7A
;; ----------------------------------------------------------------------------
;LDC7D:	ldy	LFE09				;	DC7D
;	and	#$3A				;	DC80
;	bne	LDCB8				;	DC82
;	ldx	sysvar_RS423_SUPPRESS		;	DC84
;	bne	LDC92				;	DC87
;	inx					;	DC89
;	jsr	mos_OSBYTE_153			;	DC8A
;	jsr	x_check_RS423_input_buffer	;	DC8D
;	bcc	LDC78				;	DC90
;LDC92:	rts					;	DC92
;; ----------------------------------------------------------------------------
;; Main IRQ Handling routines, default IRQIV destination
mos_IRQ1V_default_entry				; LDC93
	; TODO ACIA
;LDCA2:	lda	LFE08				;get value of status register of ACIA
;	bvs	LDCA9				;if parity error then DCA9
;	bpl	mos_VIA_INTERUPTS_ROUTINES	;else if no interrupt requested DD06
	bra	mos_VIA_INTERUPTS_ROUTINES
;LDCA9:	ldx	zp_mos_rs423timeout		;read RS423 timeout counter
;	dex					;decrement it
;	bmi	LDCDE				;and if <0 DCDE
;	bvs	LDCDD				;else if >&40 DCDD (RTS to DE82)
;	jmp	LF588				;else read ACIA via F588
;; ----------------------------------------------------------------------------
;LDCB3:	ldy	LFE09				;read ACIA data
;	rol	a				;
;	asl	a				;
;LDCB8:	tax					;X=A
;	tya					;A=Y
;	ldy	#$07				;Y=07
;	jmp	x_CAUSE_AN_EVENT		;check and service EVENT 7 RS423 error
;; ----------------------------------------------------------------------------
;LDCBF:	ldx	#$02				;read RS423 output buffer
;	jsr	mos_OSBYTE_145			;
;	bcc	LDCD6				;if C=0 buffer is not empty goto DCD6
;	lda	sysvar_PRINT_DEST		;else read printer destination
;	cmp	#$02				;is it serial printer??
;	bne	LDC68				;if not DC68
;	inx					;else X=3
;	jsr	mos_OSBYTE_145			;read printer buffer
;	ror	mosbuf_buf_busy+3		;rotate to pass carry into bit 7
;	bmi	LDC68				;if set then DC68
;LDCD6:	sta	LFE09				;pass either printer or RS423 data to ACIA 
;	lda	#$E7				;set timeout counter to stored value
;	sta	zp_mos_rs423timeout		;
LDCDDrti
	rti					;and exit (to DE82)
;; ----------------------------------------------------------------------------
						;A contains ACIA status
;LDCDE:	and	sysvar_ACIA_IRQ_MASK_CPY	;AND with ACIA bit mask (normally FF)
;	lsr	a				;rotate right to put bit 0 in carry 
;	bcc	LDCEB				;if carry clear receive register not full so DCEB
;	bvs	LDCEB				;if V is set then DCEB
;	ldy	sysvar_RS423_CTL_COPY		;else Y=ACIA control setting
;	bmi	LDC7D				;if bit 7 set receive interrupt is enabled so DC7D

;LDCEB:	lsr	a				;put BIT 2 of ACIA status into
;	ror	a				;carry if set then Data Carrier Detected applies
;	bcs	LDCB3				;jump to DCB3

;	bmi	LDCBF				;if original bit 1 is set TDR is empty so DCBF
;	bvs	LDCDDrti			;if V is set then exit to DE82

issue_unknown_interrupt					; LDCF3
		ldb	#SERVICE_5_UKINT		;X=5
		jsr	mos_OSBYTE_143_b_cmd_x_param	;issue rom call 5 'unrecognised interrupt'
		beq	LDCDDrti			;if a rom recognises it then RTI
		jmp	[IRQ2V]				;else offer to the user via IRQ2V
;; ----------------------------------------------------------------------------
;; VIA INTERUPTS ROUTINES
mos_VIA_INTERUPTS_ROUTINES
		lda	sheila_SYSVIA_ifr		;read system VIA interrupt flag register
		bpl	mos_PRINTER_INTERRUPT_USER_VIA_1;if bit 7=0 the VIA has not caused interrupt
							;goto DD47
		anda	sysvar_SYSVIA_IRQ_MASK_CPY	;mask with VIA bit mask
		anda	sheila_SYSVIA_ier		;and interrupt enable register
		rora					;rotate right twice to check for IRQ 1 (frame sync)
		rora					;
		bcc	mos_SYSTEM_INTERRUPT_5_Speech	;if carry clear then no IRQ 1, else
		dec	sysvar_CFSTOCTR			;decrement vertical sync counter
		lda	zp_mos_rs423timeout		;A=RS423 Timeout counter
		bpl	LDD1E				;if +ve then DD1E
		inc	zp_mos_rs423timeout		;else increment it
LDD1E		lda	sysvar_FLASH_CTDOWN		;load flash counter
		beq	LDD3D				;if 0 then system is not in use, ignore it
		dec	sysvar_FLASH_CTDOWN		;else decrement counter
		bne	LDD3D				;and if not 0 go on past reset routine

		ldb	sysvar_FLASH_SPACE_PERIOD	;else get mark period count in X
		lda	sysvar_VIDPROC_CTL_COPY		;current VIDEO ULA control setting in A
		lsra					;shift bit 0 into C to check if first colour
		bcc	LDD34				;is effective if so C=0 jump to DD34

		ldb	sysvar_FLASH_MARK_PERIOD	;else get space period count in X
LDD34		rola					;restore bit
		eora	#$01				;and invert it
		jsr	mos_VIDPROC_set_CTL		;then change colour		;; TODO: remove this it's redundant?

		stb	sysvar_FLASH_CTDOWN		;&0251=X resetting the counter

LDD3D		ldy	#$04				;Y=4 and call E494 to check and implement vertical
		jsr	x_CAUSE_AN_EVENT		;sync event (4) if necessary
		lda	#$02				;A=2
		jmp	irq_set_sysvia_ifr_rti		;clear interrupt 1 and exit
;; ----------------------------------------------------------------------------
;; PRINTER INTERRUPT USER VIA 1
mos_PRINTER_INTERRUPT_USER_VIA_1
	
	;TODO printer interrupts
		bra	issue_unknown_interrupt


;	lda	sheila_USRVIA_ifr		;Check USER VIA interrupt flags register
;	bpl	issue_unknown_interrupt		;if +ve USER VIA did not call interrupt
;	and	sysvar_USERVIA_IRQ_MASK_CPY	;else check for USER IRQ 1
;	and	sheila_USRVIA_ier		;
;	ror	a				;
;	ror	a				;
;	bcc	issue_unknown_interrupt		;if bit 1=0 the no interrupt 1 so DCF3
;	ldy	sysvar_PRINT_DEST		;else get printer type
;	dey					;decrement
;	bne	issue_unknown_interrupt		;if not parallel then DCF3
;	lda	#$02				;reset interrupt 1 flag
;	sta	sheila_USRVIA_ifr		;
;	sta	sheila_USRVIA_ier		;disable interrupt 1
;	ldx	#$03				;and output data to parallel printer
;	jmp	LE13A				;
;; ----------------------------------------------------------------------------
;; SYSTEM INTERRUPT 5   Speech
mos_SYSTEM_INTERRUPT_5_Speech


		rola					;get bit 5 into bit 7
		rola					;
		rola					;
		rola					;

		;TODO = no speech, do something here with timer 2?
		bpl	mos_SYSTEM_INTERRUPT_6_10mS_Clock
		bra	issue_unknown_interrupt

;		bpl	mos_SYSTEM_INTERRUPT_6_10mS_Clock;if not set the not a speech interrupt so DDCA
;		lda	#$20				;	DD6F
;		ldb	#$00				;	DD71
;		sta	sheila_SYSVIA_ifr		;	DD73
;		stb	sheila_SYSVIA_t2ch		;	DD76

;LDD79:		ldx	#$08				;	DD79
;		stx	zp_mos_OS_wksp2+1		;	DD7B
;LDD7D:		jsr	mos_OSBYTE_152			;	DD7D
;		ror	mosbuf_buf_busy+8		;	DD80
;		bmi	LDDC9				;	DD83
;		tay					;	DD85
;		beq	LDD8D				;	DD86
;		jsr	mos_OSBYTE_158			;	DD88
;		bmi	LDDC9				;	DD8B
;LDD8D:		jsr	mos_OSBYTE_145			;	DD8D
;		sta	zp_mos_curPHROM			;	DD90
;		jsr	mos_OSBYTE_145			;	DD92
;		sta	zp_mos_genPTR+1			;	DD95
;		jsr	mos_OSBYTE_145			;	DD97
;		sta	zp_mos_genPTR			;	DD9A
;		ldy	zp_mos_curPHROM			;	DD9C
;		beq	LDDBB				;	DD9E
;		bpl	LDDB8				;	DDA0
;		bit	zp_mos_curPHROM			;	DDA2
;		bvs	LDDAB				;	DDA4
;		jsr	LEEBB				;	DDA6
;		bvc	LDDB2				;	DDA9
;LDDAB:		asl	zp_mos_genPTR			;	DDAB
;		rol	zp_mos_genPTR+1			;	DDAD
;		jsr	LEE3B				;	DDAF
;LDDB2:		ldy	sysvar_SPEECH_SUPPRESS		;	DDB2
;		jmp	mos_OSBYTE_159			;	DDB5
;; ----------------------------------------------------------------------------
;LDDB8:	jsr	mos_OSBYTE_159			;	DDB8
;LDDBB:	ldy	zp_mos_genPTR			;	DDBB
;	jsr	mos_OSBYTE_159			;	DDBD
;	ldy	zp_mos_genPTR+1			;	DDC0
;	jsr	mos_OSBYTE_159			;	DDC2
;	lsr	zp_mos_OS_wksp2+1		;	DDC5
;	bne	LDD7D				;	DDC7
;LDDC9:	rts					;	DDC9
;; ----------------------------------------------------------------------------
;; SYSTEM INTERRUPT 6 10mS Clock
mos_SYSTEM_INTERRUPT_6_10mS_Clock
		bcc	irq_adc_EOC			;bit 6 is in carry so if clear there is no 6 int
							;so go on to DE47
		lda	#$40				;Clear interrupt 6
		sta	sheila_SYSVIA_ifr		;

 ;UPDATE timers routine, There are 2 timer stores &292-6 and &297-B
 ;these are updated by adding 1 to the current timer and storing the
 ;result in the other, the direction of transfer being changed each
 ;time of update.  This ensures that at least 1 timer is valid at any call
 ;as the current timer is only read.  Other methods would cause inaccuracies
 ;if a timer was read whilst being updated.

		lda	sysvar_TIMER_SWITCH		;get current system clock store pointer (5,or 10)
		m_tax					;put A in X
		eora	#$0F				;and invert lo nybble (5 becomes 10 and vv)
		pshs	A				;store A
		m_tay					;put A in Y

		SEC					;Carry is always set at this point
LDDD9		lda	oswksp_TIME-1,x			;get timer value
		adca	#$00				;update it
		sta	oswksp_TIME-1,y			;store result in alternate
		leax	-1,x				;decrement X
		beq	LDDE7				;if 0 exit
		leay	-1,y				;else decrement Y
		bne	LDDD9				;and go back and do next byte

LDDE7		puls	A				;get back A
		sta	sysvar_TIMER_SWITCH		;and store back in clock pointer (i.e. inverse previous
							;contents)
		ldb	#$04				;set loop pointer for countdown timer
		ldx	#oswksp_OSWORD3_CTDOWN
LDDED		inc	b,x				;increment byte and if 
		bne	LDDFA				;not 0 then DDFA
		decb					;else decrement pointer 
		bne	LDDED				;and if not 0 do it again
		ldy	#$05				;process EVENT 5 interval timer
		jsr	x_CAUSE_AN_EVENT		;

LDDFA		lda	oswksp_INKEY_CTDOWN		;get byte of inkey countdown timer
		bne	LDE07				;if not 0 then DE07
		lda	oswksp_INKEY_CTDOWN+1		;else get next byte
		beq	LDE0A				;if 0 DE0A
		dec	oswksp_INKEY_CTDOWN+1		;decrement 2B2
LDE07		dec	oswksp_INKEY_CTDOWN		;and 2B1

LDE0A		tst	mosvar_SOUND_SEMAPHORE		;read bit 7 of envelope processing byte
		bpl	LDE1A				;if 0 then DE1A
		inc	mosvar_SOUND_SEMAPHORE		;else increment to 0
		CLI					;allow interrupts
		jsr	irq_sound			;and do routine sound processes
		SEI					;bar interrupts
		dec	mosvar_SOUND_SEMAPHORE		;DEC envelope processing byte back to FF


LDE1A		;TODO SPEECH
;;		tst	mosbuf_buf_busy+8		;read speech buffer busy flag
;;		bmi	LDE2B				;if set speech buffer is empty, skip routine
;;		jsr	mos_OSBYTE_158			;update speech system variables
;;		eora	#$A0				;
;;		cmpa	#$60				;
;;		bcc	LDE2B				;if result >=&60 DE2B
;;		jsr	LDD79				;else more speech work

		;TODO ACIA
;LDE2B:		orcc	#CC_C+CC_V			;set V and C
;		jsr	LDCA2				;check if ACIA needs attention


		lda	zp_mos_keynumlast		;check if key has been pressed
		ora	zp_mos_keynumfirst		;
		anda	sysvar_KEYB_SEMAPHORE		;(this is 0 if keyboard is to be ignored, else &FF)
		beq	LDE3E				;if 0 ignore keyboard
		SEC					;else set carry
		jsr	mos_enter_keyboard_routines	;and call keyboard

LDE3E		;TODO PRINTER
;		jsr	LE19B				;check for data in user defined printer channel
		;TODO ADC
;		bit	LFEC0				;if ADC bit 6 is set ADC is not busy
;		bvs	LDE4A				;so DE4A

		rti					;else return 
;; ----------------------------------------------------------------------------
;; SYSTEM INTERRUPT 4 ADC end of conversion
irq_adc_EOC
	rola						;put original bit 4 from FE4D into bit 7 of A
	bpl	irq_keyboard ;if not set DE72
	;TODO ADC / CB1

;LDE4A:	ldx	sysvar_ADC_CUR			;else get current ADC channel
;	beq	LDE6C				;if 0 DE6C
;	lda	LFEC2				;read low data byte
;	sta	oswksp_OSWORD0_MAX_CH,x		;store it in &2B6,7,8 or 9
;	lda	LFEC1				;get high data byte 
;	sta	adc_CH4_LOW,x			;and store it in hi byte
;	stx	adc_CH_LAST			;store in Analogue system flag marking last channel
;	ldy	#$03				;handle event 3 conversion complete
;	jsr	x_CAUSE_AN_EVENT		;

;	dex					;decrement X
;	bne	LDE69				;if X=0
;	ldx	sysvar_ADC_MAX			;get highest ADC channel preseny
;LDE69:	jsr	LDE8F				;and start new conversion
LDE6C	lda	#$10				;rest interrupt 4
irq_set_sysvia_ifr_rti				; LDE6E
	sta	sheila_SYSVIA_ifr		; reset SYS VIA IFR
	rti					; finished interrupts
;; ----------------------------------------------------------------------------
;; SYSTEM INTERRUPT 0 Keyboard;	
irq_keyboard					; LDE72
		rola					;get original bit 0 in bit 7 position
		rola					;
		rola					;
		rola					;
		bpl	LDE7F				;if bit 7 clear not a keyboard interrupt
		jsr	mos_enter_keyboard_routines	;else scan keyboard
		lda	#$01				;A=1
		bne	irq_set_sysvia_ifr_rti		;and off to reset interrupt and exit
LDE7F		jmp	issue_unknown_interrupt		
;; ----------------------------------------------------------------------------
;; IRQ2V default entry
mos_IRQ2V_default_entry
	rti					;	DE8B

*************************************************************************
*                                                                       *
*       OSBYTE 17 Start conversion                                      *
*                                                                       *
*************************************************************************

mos_OSBYTE_17						; LDE8C
		clr	adc_CH_LAST			;set last channel to finish conversion - DB: check should this be 0?
LDE8F		;;m_txb
		cmpb	#$05				;if X<4 then
		blo	1F				;DE95
		ldb	#$04				;else X=4
1		stb	sysvar_ADC_CUR			;store it as current ADC channel
		m_tbx
		ldb	sysvar_ADC_ACCURACY		;get conversion type
		decb					;decrement
		andb	#$08				;and it with 08
		addb	sysvar_ADC_CUR			;add to current ADC
		decb					;-1
		TODO "ADC"
		;;sta	LFEC0				;store to the A/D control panel
		rts					;and return
						;
;; ----------------------------------------------------------------------------
printWelcome1
	lda	vduvar_COL_COUNT_MINUS1
	beq	printWelcomeMO7
	lda	#$0D
	jsr	OSASCI
	tst	vduvar_MODE
	beq	printWelcomeMO0
	ldx	#mc_logo
	jsr	render_logox2
	ldy	#mos_welcome_msg + 1
	jsr	printAtY
	lda	#$0D
	jsr	OSASCI
	ldx	#mc_logo  + 16
	jsr	render_logox2
	lda	#$0D
	jmp	OSASCI
printWelcomeMO0
	ldx	#mc_logo_0
	jsr	render_logox4
	ldy	#mos_welcome_msg + 1
	jsr	printAtY
	lda	#$0D
	jsr	OSASCI
	ldx	#mc_logo_0  + 32
	jsr	render_logox4
	lda	#$0D
	jmp	OSASCI
printWelcomeMO7
	ldy	#mos_welcome_msg
printAtY					; LDEB1
	lda	,y+
	jsr	OSASCI
	tsta
	bne	printAtY
	rts
;; ----------------------------------------------------------------------------
;; OSBYTE 129 TIMED ROUTINE; ON ENTRY TIME IS IN X,Y 
x_OSBYTE_129
		STX_B	oswksp_INKEY_CTDOWN+ 1		; store time in INKEY countdown timer
		STY_B	oswksp_INKEY_CTDOWN		; which is decremented every 10ms
		lda	#$FF				; A=&FF
		bra	LDEC7				; goto DEC7
;; RDCHV entry point	  read a character
mos_RDCHV_default_entry
		clra					; signal we entered through RDCHV not OSBYTE 129
LDEC7		sta	zp_mos_OS_wksp			; store entry value of A
		pshs	B,X,Y				; store X and Y
		LDY_B	sysvar_EXEC_FILE		; get *EXEC file handle
		beq	LDEE6				; if 0 (not allocated) then DEE6
		SEC					; set carry
		ror	zp_mos_cfs_critical		; set bit 7 of CFS active flag to prevent  clashes
		jsr	OSBGET				; get a byte from the file
		pshs	CC				; push processor flags to preserve carry
		lsr	zp_mos_cfs_critical		; restore &EB 
		puls	CC				; get back flags
		bcc	mos_RDCHV_char_found		; and if carry clear, character found so exit via DF03
		lda	#$00				; else A=00 as EXEC file empty
		sta	sysvar_EXEC_FILE		; store it in exec fil;e handle
		jsr	OSFIND				; and close file via OSFIND

LDEE6		tst	zp_mos_ESC_flag			; check ESCAPE flag if bit 7 set Escape pressed
		bmi	mos_RDCHV_return_SEC_ESC	; so off to DF00
		LDX_B	sysvar_CURINSTREAM		; else get current input buffer number
		jsr	mos_check_eco_get_byte_from_kbd	; get a byte from keyboard buffer
		bcc	mos_RDCHV_char_found		; and exit if valid character found
		tst	zp_mos_OS_wksp			; check flags

		bpl	LDEE6				; if entered through RDCHV keep trying
		lda	oswksp_INKEY_CTDOWN		; else check if countdown has expired
		ora	oswksp_INKEY_CTDOWN+1		;
		bne	LDEE6				; if it hasn't carry on
		bra	mos_RDCHV_return_CS_restore_A	; else restore A and exit
mos_RDCHV_return_SEC_ESC				; LDF00
		SEC					; set carry
		lda	#$1B				; return ESCAPE
		bra	mos_RDCHV_char_found
mos_RDCHV_return_CS_restore_A				;	LDF05	 - not changed order
		lda	zp_mos_OS_wksp2
mos_RDCHV_char_found					;	LDF03
		puls	B,X,Y,PC
;; ----------------------------------------------------------------------------
copyright_symbol_backwards			; LDF0C
	FCB	")C(",0

STARCMD		MACRO
		FCB	\1
		FDB	\2
		FCB	\3
		ENDM
STARCMDx	MACRO
		FDB	\1
		FCB	\2
		ENDM

mostbl_star_commands
	STARCMD	"."	,mos_jmp_FSCV		,$05	; *.        &E031, A=5     FSCV, X=>String
	STARCMD	"FX"	,mos_STAR_FX		,$FF	; *FX       &E342, A=&FF   Number parameters
	STARCMD	"BASIC"	,mos_STAR_BASIC		,$00	; *BASIC    &E018, A=0     X=>String
	STARCMD	"CAT"	,mos_jmp_FSCV		,$05	; *CAT      &E031, A=5     FSCV, X=>String
	STARCMD	"CODE"	,mos_STAR_OSBYTE_A	,$88	; *CODE     &E348, A=&88   OSBYTE &88
	STARCMD	"EXEC"	,mos_STAR_EXEC		,$00	; *EXEC     &F68D, A=0     X=>String
	STARCMD	"HELP"	,mos_STAR_HELP		,$FF	; *HELP     &F0B9, A=&FF   F2/3=>String
	STARCMD	"KEY"	,mos_STAR_KEY		,$FF	; *KEY      &E327, A=&FF   F2/3=>String
	STARCMD	"LOAD"	,mos_STAR_LOAD		,$00	; *LOAD     &E23C, A=0     X=>String
	STARCMD	"LINE"	,mos_jmp_USERV		,$01	; *LINE     &E659, A=1     USERV, X=>String
;;;	STARCMD	"MOTOR'	,mos_STAR_OSBYTE_A	,$89	; *MOTOR    &E348, A=&89   OSBYTE
	STARCMD	"OPT"	,mos_STAR_OSBYTE_A	,$8B	; *OPT      &E348, A=&8B   OSBYTE
	STARCMD	"RUN"	,mos_jmp_FSCV		,$04	; *RUN      &E031, A=4     FSCV, X=>String
	STARCMD	"ROM"	,mos_STAR_OSBYTE_A	,$8D	; *ROM      &E348, A=&8D   OSBYTE
	STARCMD	"SAVE"	,mos_STAR_SAVE		,$00	; *SAVE     &E23E, A=0     X=>String
	STARCMD	"SPOOL"	,mos_STAR_SPOOL		,$00	; *SPOOL    &E281, A=0     X=>String
;;;	STARCMD	"TAPE'	,mos_STAR_OSBYTE_A	,$8C	; *TAPE     &E348, A=&8C   OSBYTE
	STARCMD "TIME"	,mos_STAR_TIME		,$00	; *TIME
	STARCMD	"TV"	,mos_STAR_OSBYTE_A	,$90	; *TV       &E348, A=&90   OSBYTE
	STARCMDx	mos_jmp_FSCV		,$03	; Unmatched &E031, A=3     FSCV, X=>String
	FCB	00					; Table end marker

mos_CLIV_default_handler			; LDF89
	stx	zp_mos_txtptr			; store text pointer
;;;	sty	zp_mos_txtptr+1			; not needed in 6809
	lda	#$08				; indicate operation to FSCV
	jsr	mos_jmp_FSCV			; inform FS of *command
	ldx	zp_mos_txtptr
	ldb	#0
1	lda	,x+
	cmpa	#$D
	beq	cli_term_ok
	incb
	bne	1B
	rts					; return - no terminating $D found in 256 chars
cli_term_ok					;LDF9E
	ldx	zp_mos_txtptr			;	DF9E
1	jsr	mos_skip_spaces_at_X		; Skip any spaces
	beq	LE017rts			; Exit if at CR
	cmpa	#'*'				; Is this character '*'?
	beq	1B				; Loop back to skip it, and check for spaces again

	cmpa	#$0D				; check for CR
	beq	LE017rts			; Exit if at CR
	cmpa 	#'|'				; Is it '|' - a comment
	beq	LE017rts			; Exit if so
	cmpa	#'/'				; Is it '/' - pass straight to filing system
	bne	LDFBE				; Jump forward if not
;;;	iny					; Move past the '/'
;;;	jsr	LE009				; Convert &F2/3,Y->XY, ignore returned A
;;;	tfr	Y,X				; move Y to X, already have Y pointing after /
	lda	#$02				; 2=RunSlashCommand
	bra	mos_jmp_FSCV			; Jump to pass to FSCV

LDFBE	leax	-1,X				; point back at start of command
	stx	zp_mos_X			; Store offset to start of command
	ldy	#mostbl_star_commands		; point Y at commands table
	bra	LDFD7				; start searching
LDFC4	eora	,Y+				; compare chars
	anda	#$DF				; case insensitive
	bne	cli_skip_end			; if ne skip to end of current table entry
	SEC					;	DFCC
LDFCD	bcc	LDFF4				;	DFCD
;	inx					;	DFCF
	lda	,X+				;	DFD0
	jsr	mos_CHECK_FOR_ALPHA_CHARACTER	;	DFD2
	bcc	LDFC4				;	DFD5
	leax	-1,X				; backup one and check below if it was a .
	CLC					; indicate "found"
LDFD7	lda	,Y+				;	DFD7
	bmi	LDFF2				;	DFDA
	lda	,X+				;	DFDC
	cmpa	#'.'				;	DFDE
	beq	cli_abbrev			;	DFE0
cli_skip_end	
	SEC					; indicate a "not found situation"
	ldx	zp_mos_X			; reload X to start of command buffer
cli_abbrev					; LDFE6
cli_abbrev_loop					; LDFE8
	leay	1,Y				; 
	lda	-2,Y				; get last byte of name in table
	beq	cli_uk_command			; if 0 we're at the end of the table
	bpl	cli_abbrev_loop			; if +ve continue to skip 
	leay	1,Y				; skip over "A" column
	bmi	LDFCD				; if -ve we've reached a command pointer
LDFF2	leay	2,Y				;	DFF2
LDFF4	leay	-3,Y				;	DFF4
	ldb	1,Y
	pshs	D
;;	pha					;	DFF6
;;	lda	LDF11,x				;	DFF7
;;	pha					;	DFFA
	jsr	mos_skip_spaces_at_X		;	DFFB
	leax	-1,X				; point Y back at last char
	CLC					;	DFFE
	pshs	CC				;	DFFF
	jsr	cli_get_params			;	E000
	puls	CC,PC				;	E003
;; ----------------------------------------------------------------------------
cli_get_params					; LE004
	lda	2,Y				; get "A" column from table
	bmi	LE017rts			; if -ve just go
;;	tfr	Y,X				; return X as text pointer (to command tail)
;LE009:	tya					; else
;	ldy	LDF12,x				;	E00A
;LE00D:	clc					;	E00D
;	adc	zp_mos_txtptr			;	E00E
;	tax					;	E010
;	tya					;	E011
;	ldy	zp_mos_txtptr+1			;	E012
;	bcc	LE017rts				;	E014
;	iny					;	E016
	andcc	#~CC_Z				; DB: not sure this is needed but *EXEC expects Z clear on entry!
LE017rts
	rts					;	E017

;; ----------------------------------------------------------------------------
mos_STAR_BASIC					; LE018
	ldb	sysvar_ROMNO_BASIC		; get BASIC rom no
	bmi	cli_uk_command			; if minus then unknown command
	SEC					; else
	jmp	x_mos_ENTER_ROM_B		; enter language
;; ----------------------------------------------------------------------------
cli_uk_command					; LE021
	ldx	zp_mos_X			; Get back pointer to start of command
	ldb	#SVC_OSCLI_UK			; issue service call to ROMs
	jsr	mos_OSBYTE_143_b_cmd_x_param	;
	beq	LE017rts			; if handled exit
	ldx	zp_mos_X			; else get back pointer
	lda	#FSCV_CODE_OSCLI_UK		; and issue to current FS
mos_jmp_FSCV					; LE031	
	jmp	[FSCV]				;	E031
;; ----------------------------------------------------------------------------
LE034	
	asla					;	E034
LE035	anda	#$01				;	E035
	bra	mos_jmp_FSCV			;	E037

mos_skip_spaces_at_X				; LE03A
1	lda	,x+				;	E03A
	cmpa	#' '				;	E03C
	beq	1B				;	E03E
LE040	cmpa	#$0D				;	E040
	rts					;	E042
;;; ----------------------------------------------------------------------------NEEDED BY HEX PARSER FOR *LOAD/SAVE
mos_skip_spaces_at_X_eqCOMMAorCR_whenCS
	bcc	mos_skip_spaces_at_X				;	E043
mos_skip_spaces_at_X_eqCOMMAorCR
	jsr	mos_skip_spaces_at_X				;	E045
	cmpa	#','				;	E048
	bne	LE040				;	E04A
	bra	mos_skip_spaces_at_X
;;	rts					;	E04D
;; ----------------------------------------------------------------------------
	; api change number returned in B instead of X, use X as pointer
cli_parse_number_API2
	leax	-1,X
cli_parse_number_API					; LE04E
	jsr	mos_skip_spaces_at_X
	jsr	cli_parse_number_isdigit	;	E051
	bcc	2F				;	E054
	tfr	a,b
	stb	zp_mos_OS_wksp			;	E056
1	jsr	cli_parse_number_next_isdigit	;	E058
	bcc	LE076				;	E05B
	sta	,-S
	lda	zp_mos_OS_wksp
	ldb	#10
	mul
	tsta
	bne	LE08Dclcrts			; overflowed into A
	addb	,S+
	bcs	LE08Dclcrts			; overflowed 
	stb	zp_mos_OS_wksp
	bra	1B
LE076	cmpa	#$0D				;	E078
	SEC					;	E07A
2	leax	-1,X
	rts
;; ----------------------------------------------------------------------------
;LE07C:	iny					;	E07C
;LE07D:	lda	(zp_mos_txtptr),y		;	E07D
cli_parse_number_next_isdigit
	lda	,X+
cli_parse_number_isdigit
	cmpa	#'0'				;	E083
	blo	LE08Dclcrts			;	E085
	cmpa	#'9'+1				;	E07F
	bhs	LE08Dclcrts			;	E081
	anda	#$0F				;	E087
	rts					; returns with carry set indicating a valid number
;; ----------------------------------------------------------------------------
LE08A	jsr	mos_skip_spaces_at_X_eqCOMMAorCR			;	E08A
LE08Dclcrts
	CLC					;	E08D
	rts					;	E08E
;; ----------------------------------------------------------------------------
x_CheckDigitatXisHEX					; LE08F
	jsr	cli_parse_number_next_isdigit		; 
	bcs	LE0A2					; if Carry set then its a 0-9 number
	leax	-1,X
	anda	#$DF					;	E094
	cmpa	#$47					;	E096
	bhs	LE08A					;	E098
	cmpa	#$41					;	E09A
	blo	LE08A					;	E09C
	suba	#$37					;	E09F
LE0A2
	SEC
	rts						;	E0A3
;; ----------------------------------------------------------------------------
mos_WRCH_default_entry
	pshs	D,X,Y
	; TODO:ECONET
;	tst	sysvar_ECO_OSWRCH_INTERCEPT	;	E0AE
;	bpl	LE0BB				;	E0B1
;	tay					;	E0B3
;	lda	#$04				;	E0B4
;	jsr	LE57E				;	E0B6
;	bcs	LE10D				;	E0B9
;LE0BB:	
	tim	#$02, sysvar_OUTSTREAM_DEST
;;;	ldb	#$02				;	E0BC
;;;	bitb	sysvar_OUTSTREAM_DEST		;	E0BE
	bne	LE0C8				;	E0C1
	jsr	mos_VDU_WRCH			;	E0C5
LE0C8
;	lda	#$08				;	E0C8
;	bit	sysvar_OUTSTREAM_DEST		;	E0CA
;	bne	LE0D1				;	E0CD
;	bcc	LE0D6				;	E0CF
;LE0D1	lda	0,S
;	jsr	mos_PRINTER_DRIVER		;	E0D3
;LE0D6	lda	sysvar_OUTSTREAM_DEST		;	E0D6
;	ror	a				;	E0D9
;	bcc	LE0F7				;	E0DA
;	ldy	zp_mos_rs423timeout		;	E0DC
;	dey					;	E0DE
;	bpl	LE0F7				;	E0DF
;	pla					;	E0E1
;	pha					;	E0E2
;	php					;	E0E3
;	sei					;	E0E4
;	ldx	#$02				;	E0E5
;	pha					;	E0E7
;	jsr	mos_OSBYTE_152			;	E0E8
;	bcc	LE0F0				;	E0EB
;	jsr	LE170				;	E0ED
;LE0F0:	pla					;	E0F0
;	ldx	#$02				;	E0F1
;	jsr	x_INSV_flashiffull;	E0F3
;	plp					;	E0F6
;LE0F7:	lda	#$10				;	E0F7
;	bit	sysvar_OUTSTREAM_DEST		;	E0F9
;	bne	LE10D				;	E0FC
;	ldy	sysvar_SPOOL_FILE		;	E0FE
;	beq	LE10D				;	E101
;	pla					;	E103
;	pha					;	E104
;	sec					;	E105
;	ror	zp_mos_cfs_critical		;	E106
;	jsr	OSBPUT				;	E108
;	lsr	zp_mos_cfs_critical		;	E10B
;LE10D:	
	puls	D,X,Y,PC

;; ----------------------------------------------------------------------------
;; PRINTER DRIVER; A=character to print 
;mos_PRINTER_DRIVER:
;	bit	sysvar_OUTSTREAM_DEST		;	E114
;	bvs	LE139				;	E117
;	cmp	sysvar_PRINT_IGNORE		;	E119
;	beq	LE139				;	E11C
LE11E
	TODO	"PRINTER"
;	php					;	E11E
;	sei					;	E11F
;	tax					;	E120
;	lda	#$04				;	E121
;	bit	sysvar_OUTSTREAM_DEST		;	E123
;	bne	LE138				;	E126
;	txa					;	E128
;	ldx	#$03				;	E129
;	jsr	x_INSV_flashiffull;	E12B
;	bcs	LE138				;	E12E
;	bit	mosbuf_buf_busy+3		;	E130
;	bpl	LE138				;	E133
;	jsr	LE13A				;	E135
;LE138:	plp					;	E138
;LE139:	rts					;	E139
;; ----------------------------------------------------------------------------
;LE13A:	lda	sysvar_PRINT_DEST		;	E13A
;	beq	x_Buffer_handling		;	E13D
;	cmp	#$01				;	E13F
;	bne	x_serial_printer		;	E141
;	jsr	mos_OSBYTE_145			;	E143
;	ror	mosbuf_buf_busy+3		;	E146
;	bmi	LE190				;	E149
;	ldy	#$82				;	E14B
;	sty	sheila_USRVIA_ier		;	E14D
;	sta	sheila_USRVIA_ora		;	E150
;	lda	sheila_USRVIA_pcr		;	E153
;	and	#$F1				;	E156
;	ora	#$0C				;	E158
;	sta	sheila_USRVIA_pcr		;	E15A
;	ora	#$0E				;	E15D
;	sta	sheila_USRVIA_pcr		;	E15F
;	bne	LE190				;	E162
;; :serial printer
;x_serial_printer:
;	cmp	#$02				;	E164
;	bne	x_printer_is_neither_serial_or_parallel_so_its_user_type;	E166
;	ldy	zp_mos_rs423timeout		;	E168
;	dey					;	E16A
;	bpl	x_Buffer_handling		;	E16B
;	lsr	mosbuf_buf_busy+3		;	E16D
;LE170:	lsr	sysvar_RS423_USEFLAG		;	E170
LE173
	;TODO serial
	TODO	"LE173 - rs423 as input"
;	jsr	x_check_RS423_input_buffer	;	E173
;	bcc	LE190				;	E176
;	ldx	#$20				;	E178
;LE17A:	ldy	#$9F				;	E17A
;; OSBYTE 156 update ACIA setting and RAM copy; on entry	 
;mos_OSBYTE_156:
;	php					;	E17C
;	sei					;	E17D
;	tya					;	E17E
;	stx	zp_mos_OS_wksp2			;	E17F
;	and	sysvar_RS423_CTL_COPY		;	E181
;	eor	zp_mos_OS_wksp2			;	E184
;	ldx	sysvar_RS423_CTL_COPY		;	E186
;LE189:	sta	sysvar_RS423_CTL_COPY		;	E189
;	sta	LFE08				;	E18C
;	plp					;	E18F
;LE190:	rts					;	E190
;; ----------------------------------------------------------------------------
;; printer is neither serial or parallel so its user type
;x_printer_is_neither_serial_or_parallel_so_its_user_type:
;	clc					;	E191
;	lda	#$01				;	E192
;	jsr	LE1A2				;	E194
;; OSBYTE 123 Warn printer driver going dormant
;mos_OSBYTE_123:
;	ror	mosbuf_buf_busy+3		;	E197
;LE19A:	rts					;	E19A
;; ----------------------------------------------------------------------------
;LE19B:	bit	mosbuf_buf_busy+3		;	E19B
;	bmi	LE19A				;	E19E
;	lda	#$00				;	E1A0
LE1A2	ldx	#$03				;X=3
LPT_NETV_then_UPTV				; LE1A4
	ldy	sysvar_PRINT_DEST		;Y=printer destination
	jsr	[NETV]				;to JMP (NETV)
	jmp	[UPTV]				;jump to PRINT VECTOR for special routines

 *************** Buffer handling *****************************************
	;X=buffer number
	;Buffer number	Address		Flag	Out pointer	In pointer
	;0=Keyboard	3E0-3FF		2CF	2D8		2E1
	;1=RS423 Input	A00-AFF		2D0	2D9		2E2
	;2=RS423 output	900-9BF		2D1	2DA		2E3
	;3=printer	880-8BF		2D2	2DB		2E4
	;4=sound0	840-84F		2D3	2DC		2E5
	;5=sound1	850-85F		2D4	2DD		2E6
	;6=sound2	860-86F		2D5	2DE		2E7
	;7=sound3	870-87F		2D6	2DF		2E8
	;8=speech	8C0-8FF		2D7	2E0		2E9

x_Buffer_handling					; LE1AD
		CLC					;clear carry
x_Buffer_handling2					; LE1AE
		pshs	A,CC				;save A, flags
		SEI					;set interrupts
		bcs	LE1BB				;if carry set on entry then E1BB
		lda	mostbl_SERIAL_BAUD_LOOK_UP,x	;else get byte from baud rate/sound data table
		bpl	LE1BB				;if +ve the E1BB
		jsr	snd_clear_chan_API			;else clear sound data

LE1BB		SEC					;set carry
		ror	mosbuf_buf_busy,x		;rotate buffer flag to show buffer empty
		cmpx	#$02				;if X>1 then its not an input buffer
		bhs	LE1CB				;so E1CB

		lda	#$00				;else Input buffer so A=0
		sta	sysvar_KEYB_SOFTKEY_LENGTH	;store as length of key string
		sta	sysvar_VDU_Q_LEN		;and length of VDU queque
LE1CB		jsr	x_mos_CLV_and_CNPV				;then enter via count purge vector any 
							;user routines
		puls	CC,A,PC				;restore flags, A and exit

 *************************************************************************
 *                                                                       *
 *       COUNT PURGE VECTOR      DEFAULT ENTRY                           *
 *                                                                       *
 *                                                                       *
 *************************************************************************
 ;on entry if V set clear buffer
 ;         if C set get space left
 ;         else get bytes used 
mos_CNPV_default_entry_point				; LE1D1
		bvc	LE1DA				;if bit 6 is set then E1DA
		lda	mosbuf_buf_start,X		;else start of buffer=end of buffer
		sta	mosbuf_buf_end,X		;
		rts					;and exit
;; ----------------------------------------------------------------------------
LE1DA		pshs	B,CC				;push flags
		SEI					;bar interrupts
		lda	mosbuf_buf_end,X		;get end of buffer
		suba	mosbuf_buf_start,X		;subtract start of buffer
		bcc	LE1EA				;if carry caused E1EA
		suba	mostbl_BUFFER_ADDRESS_OFFS,X	;subtract buffer start offset (i.e. add buffer length)
LE1EA		
		tim	#1, 0,S
;;;		ldb	#1				;check carry in pushed flags
;;;		bitb	,S
		beq	LE1F3				;if carry clear E1F3 to exit
		adda	mostbl_BUFFER_ADDRESS_OFFS,X	;add to get bytes used
		coma					;and invert to get space left
LE1F3
		m_tax					;X=A
		puls	CC,B,PC
;; ----------------------------------------------------------------------------
;; enter byte in buffer, wait and flash lights if full
x_INSV_flashiffull
		SEI					; prevent interrupts
		jsr	[INSV]				; entera byte in buffer X
		bcc	LE20D				; if successful exit
		jsr	x_keyb_leds_test_esc		; else switch on both keyboard lights
		pshs	A,CC
		jsr	x_Turn_on_Keyboard_indicators	; switch off unselected LEDs
		puls	A,CC
		bmi	LE20D				; if return is -ve Escape pressed so exit
		CLI					; else allow interrupts
		bra	x_INSV_flashiffull		; if byte didn't enter buffer go and try it again
LE20D		rts					; then return
;; ----------------------------------------------------------------------------
;; : clear osfile control block workspace
; API change, used to clear osfile_ctlblk,x..x+3 now clears at Y..3,Y
x_loadsave_clr_4bytesY_API
		clr	3,Y
		clr	2,Y
		clr	1,Y
		clr	0,Y
		rts					;	E21E


;; ----------------------------------------------------------------------------
;; shift through osfile control block
x_shift_through_osfile_control_block
		rola					; left justify nybble
		rola
		rola
		rola
		ldb	#$04				; loop counter
LE227		rola					;	E227
		rol	3,Y				;	E228
		rol	2,Y				;	E22B
		rol	1,Y				;	E22E
		rol	,Y				;	E231
		bcs	brkBadAddress			; overflow!
		decb					;	E236
		bne	LE227				;	E237
		rts					;	E23B
;; ----------------------------------------------------------------------------
;; *LOAD ENTRY
mos_STAR_LOAD						; LE23C
		lda	#$FF				;signal that load is being performed
;; *SAVE ENTRY; on entry A=0 for save &ff for load 
mos_STAR_SAVE						; LE23E
;;		clra
;;		stx	zp_mos_txtptr			; store address of rest of command line  
;;		sty	zp_mos_txtptr+1			; 
		stx	osfile_ctlblk			; store X in control block (start of filename)
;;		sty	osfile_ctlblk+1			; 
		sta	,-S				; Push A
		ldy	#osfile_ctlblk + 2
		jsr	x_loadsave_clr_4bytesY_API	; clear the shift register
		ldb	#$FF				; Y=255
		stb	osfile_ctlblk+OSFILE_OFS_EXEC+3	; store in EXEC low byte to signal use catalogue addr
		jsr	mos_CLC_GSINIT			; and call GSINIT to prepare for reading text line
LE257		jsr	mos_GSREAD			; read a code from text line if OK read next
		bcc	LE257				; until end of filename reached
		tst	,S				; get back A without stack changes
		beq	x_SAVE_build_ctl_block		; IF A=0 (SAVE)  E2C2
;;		leax	-1,X				; step back one
		jsr	x_LOADSAVE_readaddr		; set up file block
		bcs	x_loadsave_setAXOSFILE_clrEXEClo; if carry set do OSFILE
		beq	x_loadsave_setAXOSFILE		; else if A=0 goto OSFILE, or drop through for bad addr!
brkBadAddress						; LE267
		DO_BRK	$FC, "Bad Address"

;; CLOSE SPOOL/ EXEC FILES
mos_CLOSE_SPOOL_EXEC
	ldb	#SERVICE_10_SPOOL_CLOSE		; X=10 issue *SPOOL/EXEC files warning
	jsr	mos_OSBYTE_143_b_cmd_x_param	; and issue call
	beq	LE29F				; if a rom accepts and issues a 0 then E29F to return
	jsr	mos_CLOSE_EXEC_FILE		; else close the current file
	clra					; A=0

	; always entered with A=0 but Z=1 flag decided whether to close????
	; Y ignored
	; X filename to open in Z=0
mos_STAR_SPOOL
	pshs	CC,Y					; if A=0 file is closed so
	ldb	sysvar_SPOOL_FILE			; get file handle
	sta	sysvar_SPOOL_FILE			; store A as file handle
	tstb
	beq	LE28F					; if Y<>0 then E28F (i.e. no existing spool file open)
	jsr	OSFIND					; else close file via osfind
LE28F	puls	CC,Y					; get back original Y
							; pull flags
	beq	LE29F					; if Z=1 on entry then exit
	lda	#$80					; else A=&80
	jsr	OSFIND					; to open file Y for output
	tsta						; Y=A
	beq	x_Bad_command_error			; and if this is =0 then E310 BAD COMMAND ERROR
	sta	sysvar_SPOOL_FILE			; store file handle
LE29F	rts						; and exit
;; ----------------------------------------------------------------------------
x_loadsave_setAXOSFILE_clrEXEClo
		bne	x_Bad_command_error		;
		inc	osfile_ctlblk+OSFILE_OFS_EXEC + 3	; indicate a load from catalogue
x_loadsave_setAXOSFILE					;	E2A5
		ldx	#osfile_ctlblk			;
		lda	,S+				;	E2A9
		jmp	OSFILE				;	E2AA
;; ----------------------------------------------------------------------------
;; check for hex digit
x_LOADSAVE_readaddr
		jsr	mos_skip_spaces_at_X		;	E2AD
		beq	LE2C1
		leax	-1,X
		jsr	x_CheckDigitatXisHEX		;	E2B0
		bcc	LE2C1				;	E2B3
		jsr	x_loadsave_clr_4bytesY_API	;	E2B5
;; shift byte into control block
x_shift_byte_into_control_block
		jsr	x_shift_through_osfile_control_block	;	E2B8
		jsr	x_CheckDigitatXisHEX			;	E2BB
		bcs	x_shift_byte_into_control_block 	;	E2BE
		SEC						;	E2C0
LE2C1		rts						;	E2C1
;; ----------------------------------------------------------------------------
;; ; set up OSfile control block
x_SAVE_build_ctl_block
	TODO "x_SAVE_build_ctl_block"
;	ldx	#$0A				;	E2C2
;	jsr	x_LOADSAVE_readaddr		;	E2C4
;	bcc	x_Bad_command_error		;	E2C7
;	clv					;	E2C9
;; READ file length from text line
;x_READ_file_length_from_text_line:
;	lda	(zp_mos_txtptr),y		;	E2CA
;	cmp	#$2B				;	E2CC
;	bne	LE2D4				;	E2CE
;	bit	mostbl_SYSVAR_DEFAULT_SETTINGS+65;	E2D0
;	iny					;	E2D3
;LE2D4:	ldx	#$0E				;	E2D4
;	jsr	x_LOADSAVE_readaddr		;	E2D6
;	bcc	x_Bad_command_error		;	E2D9
;	php					;	E2DB
;	bvc	LE2ED				;	E2DC
;	ldx	#$FC				;	E2DE
;	clc					;	E2E0
;LE2E1:	lda	stack+252,x			;	E2E1
;	adc	USERV,x				;	E2E4
;	sta	USERV,x				;	E2E7
;	inx					;	E2EA
;	bne	LE2E1				;	E2EB
;LE2ED:	ldx	#$03				;	E2ED
;LE2EF:	lda	osfile_ctlblk+10,x		;	E2EF
;	sta	osfile_ctlblk+6,x		;	E2F2
;	sta	osfile_ctlblk+2,x		;	E2F5
;	dex					;	E2F8
;	bpl	LE2EF				;	E2F9
;	plp					;	E2FB
;	beq	x_loadsave_setAXOSFILE				;	E2FC
;	ldx	#$06				;	E2FE
;	jsr	x_LOADSAVE_readaddr		;	E300
;	bcc	x_Bad_command_error		;	E303
;	beq	x_loadsave_setAXOSFILE				;	E305
;	ldx	#$02				;	E307
;	jsr	x_LOADSAVE_readaddr		;	E309
;	bcc	x_Bad_command_error		;	E30C
;	beq	x_loadsave_setAXOSFILE				;	E30E
;; Bad command error
x_Bad_command_error				; LE310
	DO_BRK $FE, "Bad Command"
x_Bad_key_error
	DO_BRK $FB, "Bad Key"
;	adc	(zp_lang+100,x)			;	E313
;	jsr	L6F63				;	E315
;	adc	$616D				;	E318
;	FCB	$6E				;	E31B
;	FCB	$64				;	E31C
;LE31D:	brk					;	E31D
;	FCB	$FB				;	E31E
;	FCB	$42				;	E31F
;	adc	(zp_lang+100,x)			;	E320
;	jsr	L656B				;	E322
;	FCB	$79				;	E325
;	brk					;	E326
;; *KEY ENTRY
mos_STAR_KEY
	TODO	"mos_STAR_KEY"
;	jsr	cli_parse_number				;	E327
;	bcc	LE31D				;	E32A
;	cpx	#$10				;	E32C
;	bcs	LE31D				;	E32E
;	jsr	mos_skip_spaces_at_X_eqCOMMAorCR			;	E330
;	php					;	E333
;	ldx	$0B10				;	E334
;	tya					;	E337
;	pha					;	E338
;	jsr	x_set_up_soft_key_definition	;	E339
;	pla					;	E33C
;	tay					;	E33D
;	plp					;	E33E
;	bne	LE377				;	E33F
;	rts					;	E341
;; ----------------------------------------------------------------------------
;; *FX	OSBYTE
mos_STAR_FX						; LE342
	jsr	cli_parse_number_API			; get number to pass as A to OSBYTE
	bcc	x_Bad_command_error
	tfr	B,A
;; *CODE	  *MOTOR  *OPT	  *ROM	  *TAPE	  *TV; enter codes    *CODE   &88 
; A = osbyte function
; X pointer to command line string
; C clear = entered from CLI parser - don't allow comma, else dropped in from *FX above in which case allow comma
mos_STAR_OSBYTE_A					; LE348
	pshs	A					; save A
;;;	lda	#$00					;	E349
	lda	#0					; clear values for X, Y NB: lda rather than clr, need to preserve C flag
	sta	zp_mos_GSREAD_characc			
	sta	zp_mos_GSREAD_quoteflag			
	jsr	mos_skip_spaces_at_X_eqCOMMAorCR_whenCS ; if CS (i.e. *FX) allow comma, else just skip spaces
	beq	1F					;
	jsr	cli_parse_number_API2			; parse X value
	bcc	x_Bad_command_error			;
	stb	zp_mos_GSREAD_characc			;
	jsr	mos_skip_spaces_at_X_eqCOMMAorCR	; spaces always ok here
	beq	1F					;
	jsr	cli_parse_number_API2			; parse Y value
	bcc	x_Bad_command_error			;
	stb	zp_mos_GSREAD_quoteflag			;
	jsr	mos_skip_spaces_at_X			;
	bne	x_Bad_command_error			; garbage at end
1	LDY_B	zp_mos_GSREAD_quoteflag			;
	LDX_B	zp_mos_GSREAD_characc			;
	puls	A					;
	jsr	OSBYTE					; exec OSBYTE
	bvs	x_Bad_command_error			; BRK if VS
	rts						;
;; ----------------------------------------------------------------------------
;LE377:	sec					;	E377
;	jsr	mos_GSINIT				;	E378
;LE37B:	jsr	mos_GSREAD;	E37B
;	bcs	LE388				;	E37E
;	inx					;	E380
;	beq	LE31D				;	E381
;	sta	$0B00,x				;	E383
;	bcc	LE37B				;	E386
;LE388:	bne	LE31D				;	E388
;	php					;	E38A
;	sei					;	E38B
;	jsr	x_set_up_soft_key_definition	;	E38C
;	ldx	#$10				;	E38F
;LE391:	cpx	zp_mos_OS_wksp			;	E391
;	beq	LE3A3				;	E393
;	lda	$0B00,x				;	E395
;	cmp	$0B00,y				;	E398
;	bne	LE3A3				;	E39B
;	lda	$0B10				;	E39D
;	sta	$0B00,x				;	E3A0
;LE3A3:	dex					;	E3A3
;	bpl	LE391				;	E3A4
;	plp					;	E3A6
;	rts					;	E3A7
;; ----------------------------------------------------------------------------
;; : set string lengths
x_set_string_lengths
		pshs	CC				;push flags
		SEI					;bar interrupts
		lda	$0B10				;get top of currently defined strings
		suba	$0B00,y				;subtract to get the number of bytes in strings
							;above end of string Y
		sta	zp_mos_OS_wksp2+1		;store this
		pshs	X
		ldx	#$11				;and X=16
LE3B7		lda	$0B00-1,x			;get start offset (from B00) of key string X
		suba	$0B00,y				;subtract offset of string we are working on
		bls	LE3C8				;if carry set (B00+Y>=B00+X)
		cmpa	zp_mos_OS_wksp2+1		;or greater or equal to number of bytes above 
							;string we are working on       
		bhs	LE3C8				;then E3C8
		sta	zp_mos_OS_wksp2+1		;else store A in &FB    

LE3C8		leax	-1,X				;point to next lower key offset
		bne	LE3B7				;and if 0 or +ve go back and do it again
		puls	X				;else get back value of X
		lda	zp_mos_OS_wksp2+1		;get back latest value of A     
		puls	CC				;pull flags
		rts					;and return
;; ----------------------------------------------------------------------------
;; : set up soft key definition
;x_set_up_soft_key_definition:
;	php					;	E3D1
;	sei					;	E3D2
;	txa					;	E3D3
;	pha					;	E3D4
;	ldy	zp_mos_OS_wksp			;	E3D5
;	jsr	x_set_string_lengths		;	E3D7
;	lda	$0B00,y				;	E3DA
;	tay					;	E3DD
;	clc					;	E3DE
;	adc	zp_mos_OS_wksp2+1		;	E3DF
;	tax					;	E3E1
;	sta	zp_mos_OS_wksp2			;	E3E2
;	lda	sysvar_KEYB_SOFTKEY_LENGTH	;	E3E4
;	beq	LE3F6				;	E3E7
;	brk					;	E3E9
;	FCB	$FA				;	E3EA
;	FCB	$4B				;	E3EB
;	adc	zp_lang+121			;	E3EC
;	jsr	L6E69				;	E3EE
;	jsr	L7375				;	E3F1
;	adc	zp_lang				;	E3F4
;LE3F6:	dec	sysvar_KEYB_SOFT_CONSISTANCY	;	E3F6
;	pla					;	E3F9
;	sec					;	E3FA
;	sbc	zp_mos_OS_wksp2			;	E3FB
;	sta	zp_mos_OS_wksp2			;	E3FD
;	beq	LE40D				;	E3FF
;LE401:	lda	$0B01,x				;	E401
;	sta	$0B01,y				;	E404
;	iny					;	E407
;	inx					;	E408
;	dec	zp_mos_OS_wksp2			;	E409
;	bne	LE401				;	E40B
;LE40D:	tya					;	E40D
;	pha					;	E40E
;	ldy	zp_mos_OS_wksp			;	E40F
;	ldx	#$10				;	E411
;LE413:	lda	$0B00,x				;	E413
;	cmp	$0B00,y				;	E416
;	bcc	LE422				;	E419
;	beq	LE422				;	E41B
;	sbc	zp_mos_OS_wksp2+1		;	E41D
;	sta	$0B00,x				;	E41F
;LE422:	dex					;	E422
;	bpl	LE413				;	E423
;	lda	$0B10				;	E425
;	sta	$0B00,y				;	E428
;	pla					;	E42B
;	sta	$0B10				;	E42C
;	tax					;	E42F
;	inc	sysvar_KEYB_SOFT_CONSISTANCY	;	E430
;	plp					;	E433
;	rts					;	E434
; ----------------------------------------------------------------------------
; BUFFER ADDRESS HI LOOK UP TABLE
;;;mostbl_BUFFER_ADDRESS_LO_LOOK_UP_TABLE
;;;mostbl_BUFFER_ADDRESS_HI_LOOK_UP_TABLE
mostbl_BUFFER_ADDRESS_PTR_LUT
	BUFFER_PTR_ADDR		BUFFER_KEYB_START,BUFFER_KEYB_END
	BUFFER_PTR_ADDR		BUFFER_SERI_START,BUFFER_SERI_END
	BUFFER_PTR_ADDR		BUFFER_SERO_START,BUFFER_SERO_END
	BUFFER_PTR_ADDR		BUFFER_LPT_START,BUFFER_LPT_END
	BUFFER_PTR_ADDR		BUFFER_SND0_START,BUFFER_SND0_END
	BUFFER_PTR_ADDR		BUFFER_SND1_START,BUFFER_SND1_END
	BUFFER_PTR_ADDR		BUFFER_SND2_START,BUFFER_SND2_END
	BUFFER_PTR_ADDR		BUFFER_SND3_START,BUFFER_SND3_END
	BUFFER_PTR_ADDR		BUFFER_SPCH_START,BUFFER_SPCH_END

;;;mostbl_BUFFER_START_ADDRESS_OFFSET
mostbl_BUFFER_ADDRESS_OFFS
	BUFFER_ACC_OFF		BUFFER_KEYB_START,BUFFER_KEYB_END
	BUFFER_ACC_OFF		BUFFER_SERI_START,BUFFER_SERI_END
	BUFFER_ACC_OFF		BUFFER_SERO_START,BUFFER_SERO_END
	BUFFER_ACC_OFF		BUFFER_LPT_START,BUFFER_LPT_END
	BUFFER_ACC_OFF		BUFFER_SND0_START,BUFFER_SND0_END
	BUFFER_ACC_OFF		BUFFER_SND1_START,BUFFER_SND1_END
	BUFFER_ACC_OFF		BUFFER_SND2_START,BUFFER_SND2_END
	BUFFER_ACC_OFF		BUFFER_SND3_START,BUFFER_SND3_END
	BUFFER_ACC_OFF		BUFFER_SPCH_START,BUFFER_SPCH_END


*************************************************************************
*                                                                       *
*       OSBYTE 152 Examine Buffer status                                *
*                                                                       *
*************************************************************************
;on entry X = buffer number
;on exit Y next character or preserved if buffer empty
;if buffer is empty C=1, Y is preserved else C=0
mos_OSBYTE_152					; LE45B
		SEV
		bra	jmpREMV				;	E45E
*************************************************************************
*                                                                       *
*       OSBYTE 145 Get byte from Buffer                                 *
*                                                                       *
*************************************************************************
;on entry X = buffer number
; ON EXIT Y is character extracted 
;if buffer is empty C=1, else C=0
mos_OSBYTE_145
		CLV
jmpREMV
		jmp	[REMV]
*************************************************************************
*                                                                       *
*       REMV buffer remove vector default entry point                   *
*                                                                       *
*************************************************************************
;on entry X = buffer number
;on exit if buffer is empty C=1, Y is preserved 
;else C=0, Y = char

mos_REMV_default_entry_point				; LE464
		CLC						;clear carry (assume success)
		pshs	B,X,CC					;push flags
		SEI						;bar interrupts
		ldb	mosbuf_buf_start,x			;get output pointer for buffer X
		cmpb	mosbuf_buf_end,x			;compare to input pointer
		beq	remv_SEC_ret				;if equal buffer is empty so E4E0 to exit

		pshs	B					;preserve B for later
		jsr	get_buffer_ptr				;find buffer start pointer
		ldb	,S					;get back B from stack but leave there
		abx
		lda	,X					;get char from buffer
		tim	#$02, 1,S
;;;		ldb	#2
;;;		bitb	1,S					;check overflow flag in stacked flags
		beq	1F					;V not set branch
		m_tay						;stick char found Y
		leas	1,S					;skip stacked B
		puls	B,X,CC,PC				;return with C=0, this is the osbyte 152 return
1		puls	B
		ldx	2,S					;get channel no in X back
		incb						;increment start pointer
		bne	1F					;if it is 0
		ldb	mostbl_BUFFER_ADDRESS_OFFS,X		;wrap around by finding start offs
1		stb	mosbuf_buf_start,x			;store updated pointer
		cmpb	mosbuf_buf_end,x			;check if buffer empty
		bne	1F					;if not the same buffer is not empty so exit
		cmpx	#2					;if buffer is input (0 or 1)
		blo	1F					;then E48F

		ldy	#0					;buffer is empty so Y=0
		jsr	x_CAUSE_AN_EVENT			;and enter EVENT routine to signal EVENT 0 buffer
								;becoming empty
1		m_tay						;return char in Y
		puls	B,X,CC,PC				;return with carry clear

remv_SEC_ret
		inc	,S					; set carry flag in CC on stack
1		puls	B,X,CC,PC


 **************************************************************************
 **************************************************************************
 **                                                                      **
 **      CAUSE AN EVENT                                                  **
 **                                                                      **
 **************************************************************************
 **************************************************************************
 ;on entry Y=event number
 ;A and X may be significant Y=A, A=event no. when event generated @E4A1
 ;on exit carry clear indicates action has been taken else carry set
x_CAUSE_AN_EVENT					;LE494
		CLC
		pshs	D,CC				;push flags, with carry clear
		SEI					;bar interrupts
		sta	zp_mos_OS_wksp2			;&FA=A  
		lda	mosvar_EVENT_ENABLE,y		;get enable event flag
		beq	x_return_with_carry_set_pop_D_CC;if 0 event is not enabled so exit
		ldb	zp_mos_OS_wksp2
		clra
		exg	Y,D
		exg	B,A				;else A=Y, Y=A	 - TODO - this is a bit rubbish
		jsr	[EVNTV]				;vector through &220
		puls	D,CC,PC				; carry already cleared for success

x_return_with_carry_set_pop_D_CC
		inc	,S				; set carry flag (assumes CC pushed with carry clear)
		puls	D,CC,PC				; LEFDF



*************************************************************************
*                                                                       *
*       OSBYTE 138 Put byte into Buffer                                 *
*                                                                       *
*************************************************************************
;on entry X is buffer number, Y is character to be written 
mos_OSBYTE_138						; LE4AF
		lda	zp_mos_OSBW_Y
jmpINSV		jmp	[INSV]

get_buffer_ptr
		m_txb
		aslb					; b = 2 * buffer #
		ldx	#mostbl_BUFFER_ADDRESS_PTR_LUT
		ldx	B,X 				; get buffer start pointer
		rts

*************************************************************************
*                                                                       *
*       INSV insert character in buffer vector default entry point     *
*                                                                       *
*************************************************************************
;on entry X is buffer number, A is character to be written 
mos_INSV_default_entry_point				; LE4B3
		CLC					; clear carry for default exit
		pshs	D,X,CC
		SEI					; disable interrupts
		ldb	mosbuf_buf_end,X		; get current buffer pointer
		pshs	B				; stack B for later
		incb					; incremenet
		bne	1F				; if 0 wrap around
		ldb	mostbl_BUFFER_ADDRESS_OFFS,X	; wrap around by finding start offs
1		cmpb	mosbuf_buf_start,X		; compare to extract pointer
		beq	insv_buf_full			; buffer is full, cause an event and exit
		stb	mosbuf_buf_end,X		; save updated pointer
		jsr	get_buffer_ptr
		puls	B
		abx
		sta	,X				; store the byte in the buffer
		puls	D,X,CC,PC			; exit with carry clear

insv_buf_full	leas	1,S				; reset stack
		cmpx	#2				; if it's an input buffer raise an event
		bhs	insv_SEC_ret			; its 2 or greater skip
		ldy	#1
		jsr	x_CAUSE_AN_EVENT		; raise the input buffer full event
insv_SEC_ret
		inc	,S				; set carry flag in CC on stack
		puls	D,X,CC,PC


; ----------------------------------------------------------------------------
;; check event 2 character entering buffer
x_check_event_2_char_into_buf_fromA				; LE4A8
		ldy	#$02
		jsr	x_CAUSE_AN_EVENT
		bra	jmpINSV

;; ----------------------------------------------------------------------------
;; CHECK FOR ALPHA CHARACTER; ENTRY  character in A ; exit with carry set if non-Alpha character 
mos_CHECK_FOR_ALPHA_CHARACTER			; LE4E3
	PSHS	A				;Save A
	anda	#$DF				;convert lower to upper case
	cmpa	#'Z'				;is it less than eq 'Z'
	bhi	LE4EE				;if so exit with carry clear
	cmpa	#'A'				;is it 'A' or greater ??
	bhs	LE4EF				;if not exit routine with carry set
LE4EE	SEC					;else clear carry
LE4EF	puls	A,PC				;get back original value of A
	rts					;and Return
;; ----------------------------------------------------------------------------
;; : INSERT byte in Keyboard buffer
x_INSERT_byte_in_Keyboard_buffer			; LE4F1
		STY_B	zp_mos_OSBW_Y
		clr	zp_mos_OSBW_X

 *************************************************************************
 *                                                                       *
 *       OSBYTE 153 Put byte in input Buffer checking for ESCAPE         *
 *                                                                       *
 *************************************************************************
 ;on entry X = buffer number (either 0 or 1)
 ;X=1 is RS423 input
 ;X=0 is Keyboard
 ;Y is character to be written 
mos_OSBYTE_153
		ldd	zp_mos_OSBW_Y			; A=Y, B=X (on entry to OSBYTE)
							;A=buffer number
		andb	sysvar_RS423_MODE		;and with RS423 mode (0 treat as keyboard 
							;1 ignore Escapes no events no soft keys)
		bne	mos_OSBYTE_138			;so if RS423 buffer AND RS423 in normal mode (1) E4AF
							;else Y=A character to write
		ldx	#0				;force keyboard buffer -- TODO: is this right?
		cmpa	sysvar_KEYB_ESC_CHAR		;compare with current escape ASCII code (0=match)
		bne	x_check_event_2_char_into_buf_fromA	;if ASCII or no match E4A8 to enter byte in buffer
		tst	sysvar_KEYB_ESC_ACTION		;or with current ESCAPE status (0=ESC, 1=ASCII)
		bne	x_check_event_2_char_into_buf_fromA	;if ASCII or no match E4A8 to enter byte in buffer
		lda	sysvar_BREAK_EFFECT		;else get ESCAPE/BREAK action byte
		rora					;Rotate to get ESCAPE bit into carry
		lda	zp_mos_OSBW_Y			;get character back in A
		bcs	LE513				;and if escape disabled exit with carry clear
		ldy	#$06				;else signal EVENT 6 Escape pressed
		jsr	x_CAUSE_AN_EVENT		;
		bcc	LE513				;if event handles ESCAPE then exit with carry clear
		jsr	mos_OSBYTE_125			;else set ESCAPE flag
LE513		andcc	#~CC_C				;clear carry 
		rts					;and exit
;; ----------------------------------------------------------------------------
;; get a byte from keyboard buffer and interpret as necessary; on entry A=cursor editing status 1=return &87-&8B,  ; 2= use cursor keys as soft keys 11-15 ; this area not reached if cursor editing is normal 
mos_interpret_keyb_byte					; LE515
	rora					;get bit 1 into carry
	bcc	mos_interpret_keyb_byte2
	puls	A				;get back A
	lbra	x_exit_with_carry_clear		;if carry is set return
						;else cursor keys are 'soft'

mos_interpret_keyb_byte2
		lda	,S				;leave A on stack
		lsra					;get high nybble into lo
		lsra					;
		lsra					;
		lsra					;A=8-&F
		eora	#$04				;and invert bit 2
							;&8 becomes &C
							;&9 becomes &D
							;&A becomes &E
							;&B becomes &F
							;&C becomes &8
							;&D becomes &9
							;&E becomes &A
							;&F becomes &B
		m_tay					;Y=A = 8-F
		lda	sysvar_KEYB_C0CF_INSERT_INT-8,y	;read 026D to 0274 code interpretation status
							;0=ignore key, 1=expand as 'soft' key
							;2-&FF add this to base for ASCII code
							;note that provision is made for keypad operation
							;as codes &C0-&FF cannot be generated from keyboard
							;but are recognised by OS
							;

		cmpa	#$01				;is it 01
		beq	x_expand_soft_key_strings	;if so expand as 'soft' key via E594
		puls	A				;else get back original byte
		blo	x_get_byte_from_buffer		;then code 0 must have
							;been returned so E539 to ignore
		anda	#$0F				;else add ASCII to BASE key number so clear hi nybble
		adda	sysvar_KEYB_C0CF_INSERT_INT-8,y	;add ASCII base
		CLC					;clear carry
		rts					;and exit
						;
;; ----------------------------------------------------------------------------
;; ERROR MADE IN USING EDIT FACILITY
x_ERROR_EDITING
		jsr	mos_VDU_7		;	E534
		puls	X
;	pla					;	E537
;	tax					;	E538
;; get byte from buffer
x_get_byte_from_buffer					; LE539
		jsr	mos_OSBYTE_145			;get byte from buffer X
		bcs	LE593rts			;if buffer empty E593 to exit
		pshs	A				;else Push byte
		cmpx	#$01				;and if RS423 input buffer is not the one
		bne	1F				;then E549

		jsr	LE173				;else oswrch
		ldx	#$01				;X=1 (RS423 input buffer)
		CLC					;clear (was set) carry
1							; LE549
		puls	A				;get back original byte
		bcs	1F				;if carry clear (I.E not RS423 input) E551
		ldy	sysvar_RS423_MODE		;else Y=RS423 mode (0 treat as keyboard )
		bne	x_exit_with_carry_clear		;if not 0 ignore escapes etc. goto E592
1							; LE551
		tsta					;test A (was tay)
		bpl	x_exit_with_carry_clear		;if code is less than &80 its simple so E592
		pshs	A
		anda	#$0F				;else clear high nybble
		cmpa	#$0B				;if less than 11 then treat as special code
		blo	mos_interpret_keyb_byte2	;or function key and goto E519
		leas	1,S				;lose A from stack
		adda	#$7C				;else add &7C (&7B +C) to convert codes B-F to 7-B
		pshs	A				;Push A
		lda	sysvar_KEY_CURSORSTAT		;get cursor editing status
		bne	mos_interpret_keyb_byte		; if not 0 (normal) E515
		lda	sysvar_OUTSTREAM_DEST		;else get character destination status
		rora					;get bit 1 into carry
		rora					;
		puls	A				;
		bcs	x_get_byte_from_buffer		;if carry is set E539 screen disabled
		cmpa	#$87				;else is it COPY key
		beq	x_deal_with_COPY_key		;if so E5A6

		;TODO cursor editing
						; LE575
;;;	tay					;else Y=A
;;;	txa					;A=X
;;;	pha					;Push X 
;;;	tya					;get back Y
	pshs	X
	jsr	x_cursor_start				;execute edit action
	puls	X
;	pla					;restore X
;	tax					;
mos_check_eco_get_byte_from_kbd			; LE577
	;	TODO econet
;	bit	sysvar_ECO_OSRDCH_INTERCEPT	;check econet RDCH flag
;	bpl	x_get_byte_from_key_string	;if not set goto E581
;	lda	#$06				;else Econet function 6 
;LE57E:	jmp	(NETV)				;to the Econet vector

********* get byte from key string **************************************
;on entry 0268 contains key length
;and 02C9 key string pointer to next byte

x_get_byte_from_key_string
	lda	sysvar_KEYB_SOFTKEY_LENGTH	;get length of keystring
	beq	x_get_byte_from_buffer		;if 0 E539 get a character from the buffer
	LDY_B	mosvar_SOFTKEY_PTR		;get soft key expansion pointer
	lda	$0B01,y				;get character from string
	inc	mosvar_SOFTKEY_PTR		;increment pointer
	dec	sysvar_KEYB_SOFTKEY_LENGTH	;decrement length
;; exit with carry clear
x_exit_with_carry_clear
	CLC					;	E592
LE593rts	
	rts					;	E593
;; ----------------------------------------------------------------------------
;; expand soft key strings
x_expand_soft_key_strings				; LE594
		puls	A				;restore original code
		anda	#$0F				;blank hi nybble to get key string number
		m_tay					;Y=A
		jsr	x_set_string_lengths		;get string length in A
		sta	sysvar_KEYB_SOFTKEY_LENGTH	;and store it
		lda	$0B00,y				;get start point
		sta	mosvar_SOFTKEY_PTR		;and store it
		bne	mos_check_eco_get_byte_from_kbd	;if not 0 then get byte via E577 and exit

		ASSERT	"can assume not get here and turn to BRA ! no you can't x_expand_soft_key_strings"
;; deal with COPY key
x_deal_with_COPY_key
	pshs	X
	jsr	x_cursor_COPY				;	E5A8
	tsta
	lbeq	x_ERROR_EDITING				;	E5AC
	puls	X
	CLC						;	E5B1
	rts						;	E5B2
;; ----------------------------------------------------------------------------
;; OSBYTE LOOK UP TABLE !!!!!ADDRESSES!!!!
mostbl_OSBYTE_LOOK_UP

		FDB	mos_OSBYTE_0			;	E5B3
		FDB	mos_OSBYTE_1AND6		;	E5B5
		FDB	mos_OSBYTE_2			;	E5B7
		FDB	mos_OSBYTE_3AND4		;	E5B9
		FDB	mos_OSBYTE_3AND4		;	E5BB
		FDB	mos_OSBYTE_5			;	E5BD
		FDB	mos_OSBYTE_1AND6		;	E5BF
		FDB	mos_OSBYTE_07			;	E5C1
		FDB	mos_OSBYTE_08			;	E5C3
		FDB	mos_OSBYTE_09			;	E5C5
		FDB	mos_OSBYTE_10			;	E5C7
		FDB	mos_OSBYTE_11			;	E5C9
		FDB	mos_OSBYTE_12			;	E5CB
		FDB	mos_OSBYTE_13			;	E5CD
		FDB	mos_OSBYTE_14			;	E5CF
		FDB	mos_OSBYTE_15			;	E5D1
		FDB	mos_OSBYTE_16			;	E5D3
		FDB	mos_OSBYTE_17			;	E5D5
		FDB	mos_OSBYTE_18			;	E5D7
		FDB	mos_OSBYTE_19			;	E5D9
		FDB	mos_OSBYTE_20			;	E5DB
		FDB	mos_OSBYTE_21			;	E5DD
OSBYTE1_END	equ	21
OSBYTE2_START	equ	117
mostbl_OSBYTE_LOOK_UP2
		FDB	mos_OSBYTE_117			;	E5DF
		FDB	mos_OSBYTE_118			;	E5E1
		FDB	mos_OSBYTE_nowt			;	E5E3
		FDB	mos_OSBYTE_nowt			;	E5E5
		FDB	mos_OSBYTE_nowt			;	E5E7
		FDB	mos_OSBYTE_122			;	E5E9
		FDB	mos_OSBYTE_nowt			;	E5EB
		FDB	mos_OSBYTE_124			;	E5ED
		FDB	mos_OSBYTE_125			;	E5EF
		FDB	mos_OSBYTE_126			;	E5F1
		FDB	mos_OSBYTE_nowt			;	E5F3
		FDB	mos_OSBYTE_nowt			;	E5F5
		FDB	mos_OSBYTE_129			;	E5F7
		FDB	mos_OSBYTE_130			;	E5F9
		FDB	mos_OSBYTE_131			;	E5FB
		FDB	mos_OSBYTE_132			;	E5FD
		FDB	mos_OSBYTE_133			;	E5FF
		FDB	mos_OSBYTE_134			;	E601
		FDB	mos_OSBYTE_135			;	E603
		FDB	mos_OSBYTE_136			;	E605
		FDB	mos_OSBYTE_nowt			;	E607
		FDB	mos_OSBYTE_nowt			;	E609
		FDB	mos_OSBYTE_nowt			;	E60B
		FDB	mos_OSBYTE_nowt			;	E60D
		FDB	mos_OSBYTE_nowt			;	E60F
		FDB	mos_OSBYTE_nowt			;	E611
		FDB	mos_OSBYTE_143			;	E613
		FDB	mos_OSBYTE_144			;	E615
		FDB	mos_OSBYTE_nowt			;	E617
		FDB	mos_OSBYTE_nowt			;	E619
		FDB	mos_OSBYTE_nowt			;	E61B
		FDB	mos_OSBYTE_nowt			;	E61D
		FDB	mos_OSBYTE_nowt			;	E61F
		FDB	mos_OSBYTE_nowt			;	E621
		FDB	mos_OSBYTE_nowt			;	E623
		FDB	mos_OSBYTE_nowt			;	E625
		FDB	mos_OSBYTE_nowt			;	E627
		FDB	mos_OSBYTE_nowt			;	E629
		FDB	mos_OSBYTE_nowt			;	E62B
		FDB	mos_OSBYTE_nowt			;	E62D
		FDB	mos_OSBYTE_nowt			;	E62F
		FDB	mos_OSBYTE_nowt			;	E631
		FDB	mos_OSBYTE_nowt			;	E633
		FDB	mos_OSBYTE_160			;	E635
OSBYTE2_END	equ	160

		FDB	mos_OSBYTE_RW_SYSTEM_VARIABLE	;	E637
		FDB	mos_OSBYTE_nowt			;	E639
;; OSWORD LOOK UP TABLE !!!!!ADDRESSES!!!!
mostbl_OSWORD_LOOK_UP
		FDB	mos_OSWORD_0_read_line		;	E63B
		FDB	mos_OSWORD_1_rd_sys_clk		;	E63D
		FDB	mos_OSWORD_2_wr_sys_clk		;	E63F
		FDB	mos_OSWORD_3_rd_timer		;	E641
		FDB	mos_OSWORD_4_wr_int_timer	;	E643
		FDB	mos_OSWORD_nowt			;	E645
		FDB	mos_OSWORD_nowt			;	E647
		FDB	mos_OSWORD_7_SOUND		;	E649
		FDB	mos_OSWORD_8_ENVELOPE		;	E64B
		FDB	mos_OSWORD_nowt			;	E64D
		FDB	mos_OSWORD_nowt			;	E64F
		FDB	mos_OSWORD_nowt			;	E651
		FDB	mos_OSWORD_nowt			;	E653
		FDB	mos_OSWORD_nowt			;	E655
		FDB	mos_OSWORD_E_read_rtc
		FDB	mos_OSWORD_F_write_rtc

OSWORD_MAX			equ	15
OSBYTE_TABLE_OSBYTE_SIZE 	equ	mostbl_OSWORD_LOOK_UP - mostbl_OSBYTE_LOOK_UP

*ORIGINALTABLE*
;	FDB	mos_OSBYTE_0			;	E5B3
;	FDB	mos_OSBYTE_1AND6;	E5B5
;	FDB	mos_OSBYTE_2			;	E5B7
;	FDB	mos_OSBYTE_3AND4	;	E5B9
;	FDB	mos_OSBYTE_3AND4	;	E5BB
;	FDB	mos_OSBYTE_5		;	E5BD
;	FDB	mos_OSBYTE_1AND6;	E5BF
;	FDB	mos_OSBYTE_07			;	E5C1
;	FDB	mos_OSBYTE_08			;	E5C3
;	FDB	mos_OSBYTE_09			;	E5C5
;	FDB	mos_OSBYTE_10			;	E5C7
;	FDB	mos_OSBYTE_11;	E5C9
;	FDB	mos_OSBYTE_12;	E5CB
;	FDB	mos_OSBYTE_13			;	E5CD
;	FDB	mos_OSBYTE_14			;	E5CF
;	FDB	mos_OSBYTE_15			;	E5D1
;	FDB	mos_OSBYTE_16			;	E5D3
;	FDB	mos_OSBYTE_17			;	E5D5
;	FDB	mos_OSBYTE_18		;	E5D7
;	FDB	mos_OSBYTE_19		;	E5D9
;	FDB	mos_OSBYTE_20			;	E5DB
;	FDB	mos_OSBYTE_21			;	E5DD
;	FDB	mos_OSBYTE_117			;	E5DF
;	FDB	mos_OSBYTE_118			;	E5E1
;	FDB	mos_CLOSE_SPOOL_EXEC		;	E5E3
;	FDB	mos_OSBYTE_120			;	E5E5
;	FDB	mos_OSBYTE_121			;	E5E7
;	FDB	mos_OSBYTE_122			;	E5E9
;	FDB	mos_OSBYTE_123			;	E5EB
;	FDB	mos_OSBYTE_124			;	E5ED
;	FDB	mos_OSBYTE_125			;	E5EF
;	FDB	mos_OSBYTE_126			;	E5F1
;	FDB	LE035				;	E5F3
;	FDB	mos_OSBYTE_128			;	E5F5
;	FDB	LE713				;	E5F7
;	FDB	LE729				;	E5F9
;	FDB	mos_OSBYTE_131			;	E5FB
;	FDB	mos_OSBYTE_132			;	E5FD
;	FDB	mos_OSBYTE_133			;	E5FF
;	FDB	mos_OSBYTE_134			;	E601
;	FDB	mos_OSBYTE_135			;	E603
;	FDB	mos_OSBYTE_136			;	E605
;	FDB	mos_OSBYTE_137			;	E607
;	FDB	mos_OSBYTE_138			;	E609
;	FDB	LE034				;	E60B
;	FDB	mos_selects_ROM_filing_system	;	E60D
;	FDB	mos_selects_ROM_filing_system	;	E60F
;	FDB	x_mos_ENTER_ROM_X;	E611
;	FDB	mos_OSBYTE_143			;	E613
;	FDB	mos_OSBYTE_144			;	E615
;	FDB	mos_OSBYTE_145			;	E617
;	FDB	mos_OSBYTE_146			;	E619
;	FDB	mos_OSBYTE_147			;	E61B
;	FDB	mos_OSBYTE_148			;	E61D
;	FDB	mos_OSBYTE_149			;	E61F
;	FDB	mos_OSBYTE_150			;	E621
;	FDB	mos_OSBYTE_151			;	E623
;	FDB	mos_OSBYTE_152			;	E625
;	FDB	mos_OSBYTE_153			;	E627
;	FDB	mos_OSBYTE_154			;	E629
;	FDB	mos_OSBYTE_155			;	E62B
;	FDB	mos_OSBYTE_156			;	E62D
;	FDB	mos_OSBYTE_157			;	E62F
;	FDB	mos_OSBYTE_158			;	E631
;	FDB	mos_OSBYTE_159			;	E633
;	FDB	mos_OSBYTE_160		;	E635
;	FDB	mos_OSBYTE_RW_SYSTEM_VARIABLE	;	E637
;	FDB	mos_jmp_USERV			;	E639
;; OSWORD LOOK UP TABLE !!!!!ADDRESSES!!!!
;mostbl_OSWORD_LOOK_UP:
;	FDB	OSWORD_0_read_line;	E63B
;	FDB	mos_OSWORD_1_rd_sys_clk		;	E63D
;	FDB	mos_OSWORD_2_wr_sys_clk		;	E63F
;	FDB	mos_OSWORD_3_rd_timer		;	E641
;	FDB	mos_OSWORD_4_wr_int_timer	;	E643
;	FDB	mos_read_a_byte_from_IO_memory	;	E645
;	FDB	mos_write_a_byte_to_IO_memory	;	E647
;	FDB	mos_OSWORD_7_SOUND		;	E649
;	FDB	mos_OSWORD_8_ENVELOPE		;	E64B
;	FDB	mos_OSWORD_9			;	E64D
;	FDB	mos_OSWORD_10			;	E64F
;	FDB	mos_OSWORD_11			;	E651
;	FDB	mos_OSWORD_12			;	E653
;	FDB	mos_OSWORD_13			;	E655


mos_OSBYTE_nowt
	LDA	zp_mos_OSBW_A
	JSR	debug_print_hex
	TODO	"OSBYTE"

mos_OSWORD_nowt
	LDA	zp_mos_OSBW_A
	JSR	debug_print_hex
	TODO	"OSWORD"


mos_OSBYTE_136					; LE657
;mos_STAR_CODE_effectively:= * + 1		; *CODE effectively???
	CLRA					;	E657
;; ----------------------------------------------------------------------------
;; *LINE	  entry
mos_jmp_USERV
	jmp	[USERV]				;	E659
;; ----------------------------------------------------------------------------
;; OSBYTE  126  Acknowledge detection of ESCAPE condition
mos_OSBYTE_126
	ldx	#$00				;	E65C
	tst	zp_mos_ESC_flag			;	E65E
	bpl	mos_OSBYTE_124			;	E660
	lda	sysvar_KEYB_ESC_EFFECT		;	E662
	bne	LE671				;	E665
	CLI					;	E667
	sta	sysvar_SCREENLINES_SINCE_PAGE	;	E668
	jsr	mos_STAR_EXEC			;	E66B
	jsr	mos_flush_all_buffers				;	E66E
LE671	ldx	#$FF				;	E671
;; OSBYTE  124  Clear ESCAPE condition
mos_OSBYTE_124
	CLC					;	E673
;; OSBYTE  125  Set ESCAPE flag
mos_OSBYTE_125
	ror	zp_mos_ESC_flag			;	E674
;TODO: TUBE
;;	tst	sysvar_TUBE_PRESENT		;	E676
;;	bmi	LE67C				;	E679
	rts					;	E67B
; ----------------------------------------------------------------------------
LE67C	TODO	"TUBE ESCAPE"
;LE67C:	jmp	L0403				;	E67C
;; ----------------------------------------------------------------------------
;; OSBYTE  137  Turn on Tape motor
;mos_OSBYTE_137:
;	lda	sysvar_SERPROC_CTL_CPY		;	E67F
;	tay					;	E682
;	rol	a				;	E683
;	cpx	#$01				;	E684
;	ror	a				;	E686
;	bvc	LE6A7				;	E687
;; OSBYTE 08/07 set serial baud rates
mos_OSBYTE_08
	lda	#$38				;	E689
;; OSBYTE 08/07 set serial baud rates
mos_OSBYTE_07
	; TODO serial
	TODO	"mos_OSBYTE_07"
;	eor	#$3F				;	E68B
;	sta	zp_mos_OS_wksp2			;	E68D
;	ldy	sysvar_SERPROC_CTL_CPY		;	E68F
;	cpx	#$09				;	E692
;	bcs	LE6AD				;	E694
;	and	mostbl_SERIAL_BAUD_LOOK_UP,x	;	E696
;	sta	zp_mos_OS_wksp2+1		;	E699
;	tya					;	E69B
;	ora	zp_mos_OS_wksp2			;	E69C
;	eor	zp_mos_OS_wksp2			;	E69E
;	ora	zp_mos_OS_wksp2+1		;	E6A0
;	ora	#$40				;	E6A2
;	eor	sysvar_RS423CASS_SELECT		;	E6A4
;LE6A7:	sta	sysvar_SERPROC_CTL_CPY		;	E6A7
;	sta	LFE10				;	E6AA
	;TODO - this could be improved
LE6AD	m_tya					;put Y in A to save old contents
LE6AE	m_tax					;write new setting to X
	rts					;and return

*************************************************************************
*                                                                       *
*       OSBYTE  9   Duration of first colour                            *
*                                                                       *
*************************************************************************
;on entry Y=0, X=new value
	; TODO: the next two need optimising
mos_OSBYTE_09					; LE6B0
		ldy	#1				;Y is incremented to 1
		CLC					;clear carry
;; OSBYTE  10   Duration of second colour; on entry Y=0 or 1 if from FX 9 call, X=new value 
mos_OSBYTE_10
		lda	sysvar_FLASH_SPACE_PERIOD,y	;get mark period count
		pshs	A				;push it
		m_txa					;get new count
		sta	sysvar_FLASH_SPACE_PERIOD,y	;store it
		puls	A				;get back original value
		m_tay					;put it in Y
		lda	sysvar_FLASH_CTDOWN		;get value of flash counter
		bne	LE6AD				;if not zero E6D1

		STX_B	sysvar_FLASH_CTDOWN		;else restore old value 
		lda	sysvar_VIDPROC_CTL_COPY		;get current video ULA control register setting
		pshs	CC				;push flags
		rora					;rotate bit 0 into carry, carry into bit 7
		puls	CC				;get back flags
		rola					;rotate back carry into bit 0
		sta	sysvar_VIDPROC_CTL_COPY		;store it in RAM copy
		sta	sheila_VIDULA_ctl		;and ULA control register
		bra	LE6AD				;then exit via OSBYTE 7/8

 *************************************************************************
 *                                                                       *
 *       OSBYTE  2   select input stream                                 *
 *                                                                       *
 *************************************************************************
 
 ;on input X contains stream number
mos_OSBYTE_2
	; TODO SERIAL
;	txa					;	E6D3
;	and	#$01				;	E6D4
;	pha					;	E6D6
;	lda	sysvar_RS423_CTL_COPY		;	E6D7
;	rol	a				;	E6DA
;	cpx	#$01				;	E6DB
;	ror	a				;	E6DD
;	cmp	sysvar_RS423_CTL_COPY		;	E6DE
;	php					;	E6E1
;	sta	sysvar_RS423_CTL_COPY		;	E6E2
;	sta	LFE08				;	E6E5
;	jsr	LE173				;	E6E8
;	plp					;	E6EB
;	beq	LE6F1				;	E6EC
;	bit	LFE09				;	E6EE
;LE6F1:	ldx	sysvar_CURINSTREAM		;	E6F1
;	pla					;	E6F4
;	sta	sysvar_CURINSTREAM		;	E6F5
;	rts					;	E6F8

	; DB: just swap X with contents of CURINSTREAM
	lda	sysvar_CURINSTREAM
	pshs	A
	clr	,-S
	m_txa
	sta	sysvar_CURINSTREAM
	puls	X,PC

*************************************************************************
*                                                                       *
*       OSBYTE  13   disable events                                     *
*                                                                       *
*************************************************************************

        ;X contains event number 0-9
mos_OSBYTE_13
	clra					;	E6F9
*************************************************************************
*                                                                       *
*       OSBYTE  14   enable events                                      *
*                                                                       *
*************************************************************************

        ;X contains event number 0-9
mos_OSBYTE_14					; LE6FA
		cmpx	#$0A				;if X>9			
		bhs	LE6AE				;goto E6AE for exit			
		ldb	mosvar_EVENT_ENABLE,x		;else get event enable flag 
		m_tby					; TODO: use B?
		sta	mosvar_EVENT_ENABLE,x		;store new value in flag
		bra	LE6AD				;and exit via E6AD
;; OSBYTE  16   Select A/D channel; X contains channel number or 0 if disable conversion	 
mos_OSBYTE_16
	TODO	"ADC"
;	beq	LE70B				;	E706
;	jsr	mos_OSBYTE_17			;	E708
;LE70B:	lda	sysvar_ADC_MAX			;	E70B
;	stx	sysvar_ADC_MAX			;	E70E
;	tax					;	E711
;	rts					;	E712
;; ----------------------------------------------------------------------------

; OSBYTE 129   Read key within time limit; X and Y contains either time limit in centi seconds Y=&7F max ; or Y=&FF and X=-ve INKEY value 
mos_OSBYTE_129					; LE713
	tst	zp_mos_OSBW_Y			; check Y negative
	bmi	LE721				; if Y=&FF the E721
	CLI					; else allow interrupts
	jsr	x_OSBYTE_129			; and go to timed routine
	bcs	LE71F				; if carry set then E71F
	m_tax					; then X=A
	clra					; A=0
LE71F	m_tay					; Y=A
	rts					; and return
;; ----------------------------------------------------------------------------
LE721	lda	zp_mos_OSBW_X			; A=X
	beq	mos_OSBYTE_129_machtype
	eora	#$7F				; convert to keyboard input
	m_tax					; X=A
	SEC
	jsr	jmpKEYV				; then scan keyboard
	rola					; put bit 7 into carry
LE729	ldx	#$FFFF				; X=&FF
	ldy	#$FFFF				; Y=&FF
	bcs	LE731				; if bit 7 of A was set goto E731 (RTS)
	leax	1,X				; else X=0
	leay	1,Y				; and Y=0
LE731	rts					; and exit
mos_OSBYTE_129_machtype
	ldx	#mos_MACHINE_TYPE_BYTE
	ldy	#$FFFF
	rts
;; ----------------------------------------------------------------------------
;; check occupancy of input or free space of output buffer; X=buffer number ; Buffer number  Address	    Flag    Out pointer	    In pointer ; 0=Keyboard	3E0-3FF		2CF	2D8		2E1 ; 1=RS423 Input  A00-AFF	     2D0     2D9	 
;x_check_buffer_space:
;	txa					;	E732
;	eor	#$FF				;	E733
;	tax					;	E735
;	cpx	#$02				;	E736
;LE738:	clv					;	E738
;	bvc	x_mos_CNPV				;	E739
x_mos_CLV_and_CNPV					; LE73B
		orcc	#CC_V+CC_C+CC_N
x_mos_CNPV						; LE73E
		jmp	[CNPV]				;	E73E
;; ----------------------------------------------------------------------------
;; check RS423 input buffer
;x_check_RS423_input_buffer:
;	sec					;	E741
;	ldx	#$01				;	E742
;	jsr	LE738				;	E744
;	cpy	#$01				;	E747
;	bcs	LE74E				;	E749
;	cpx	sysvar_RS423_BUF_EXT		;	E74B
;LE74E:	rts					;	E74E
;; ----------------------------------------------------------------------------
;; OSBYTE 128  READ ADC CHANNEL; ON Entry: X=0		    Exit Y contains number of last channel converted ; X=channel number	      X,Y contain 16 bit value read from channe ; X<0 Y=&FF		 X returns information about various buffers ; X=&FF (key
;mos_OSBYTE_128:
;	bmi	x_check_buffer_space		;	E74F
;	beq	LE75F				;	E751
;	cpx	#$05				;	E753
;	bcs	LE729				;	E755
;	ldy	adc_CH4_LOW,x			;	E757
;	lda	oswksp_OSWORD0_MAX_CH,x		;	E75A
;	tax					;	E75D
;	rts					;	E75E
;; ----------------------------------------------------------------------------
;LE75F:	lda	sheila_SYSVIA_orb		;	E75F
;	ror	a				;	E762
;	ror	a				;	E763
;	ror	a				;	E764
;	ror	a				;	E765
;	eor	#$FF				;	E766
;	and	#$03				;	E768
;	ldy	adc_CH_LAST			;	E76A
;	stx	adc_CH_LAST			;	E76D
;	tax					;	E770
;	rts					;	E771
;; ----------------------------------------------------------------------------
;; pointed to by default BYTEV
mos_default_BYTEV_handler
	pshs	A,CC
	SEI					; disable interrupts
	sta	zp_mos_OSBW_A			; store A,X,Y in zero page       
	sty	zp_mos_OSBW_Y			;        
	STX_B	zp_mos_OSBW_X			;        
	ldx	#$07				; X=7 to signal osbyte is being attempted
	cmpa	#OSBYTE2_START			; if A=0-116
	blo	x_Process_OSBYTE_SECTION_1	; then E7C2
	cmpa	#161				; if A<161 
	blo	x_Process_OSBYTE_SECTION_2	; then E78E
	cmpa	#166				; if A=161-165
	blo	mos_exec_BYTEV_from_osword_gtMAX; then EC78
	CLC					; clear carry

mos_exec_BYTEV_from_osword_gt224		; LE78A enters here from above with X=7, carry clear, or from OSWORD with X=8 and carry set, A>=224
	lda	#OSBYTE2_END + 1		; A=&A1
	adca	#$00				;
;; process osbyte calls 117 - 160
x_Process_OSBYTE_SECTION_2
	suba	#OSBYTE2_START - OSBYTE1_END - 1;convert to &16 to &41 (22-65) (OSBYTE 117 to 160) or &42 for OSBYTE > 165, &43 for OSWORD > 224
LE791
	asla					;	E791
	SEC					;	E792
	STY_B	zp_mos_OSBW_Y			; store Y - may have been set in 
mos_exec_BYTEV_from_osword_leMAX			; LE793
	;TODO ECONET, this would need to go back in WORDV too for econet!
;;	bit	sysvar_ECO_OSBW_INTERCEPT	;read econet intercept flag
;;	bpl	LE7A2				;if no econet intercept required E7A2
;;	txa					;else A=X
;;	clv					;V=0
;;	jsr	LE57E				; to JMP via ECONET vector
;;	bvs	LE7BC				;if return with V set E7BC

LE7A2	ldx	#mostbl_OSBYTE_LOOK_UP
	tfr	a,b
	abx
	ldd	,X				;get address from table
	std	zp_mos_OS_wksp2			;store it
	lda	zp_mos_OSBW_A			;restore A      
	LDY_B	zp_mos_OSBW_Y			;Y
	bcs	LE7B6				;if carry is set E7B6
;;	ldy	#$00				;else
	lda	[zp_mos_OSWORD_X]		;get value from address pointed to by &F0/1 (Y,X) - CHECK new API
	ldx	zp_mos_OSBW_Y			; get full 16 bit X for OSWORD
	SEC					;set carry
	bra	1F
LE7B6	
	LDX_B	zp_mos_OSBW_X
1	ldb	zp_mos_OSBW_X			;pass B=X : DB: extra new api to
	jsr	[zp_mos_OS_wksp2]		;call &FA/B
LE7BC	rora					;C=bit 0
	puls	CC				;get back flags
	rola					;bit 0=Carry
	CLV					;clear V
	puls	A,PC				;get back A
						;and exit
;; ----------------------------------------------------------------------------
;; Process OSBYTE CALLS BELOW &75
x_Process_OSBYTE_SECTION_1
	ldy	#$00				;	E7C2
	cmpa	#$16				;	E7C4
	blo	LE791				;	E7C6
mos_exec_BYTEV_from_osword_gtMAX
;;;	php					;	E7C8
;;;	php					;	E7C9
;;;LE7CA:	pla					;	E7CA
;;;	pla					;	E7CB

	; NOTE X has been set to 7 or 8 (osbyte or osword) or 8 from make a sound if unknown channel number
	m_txb					; TODO - sort this out pass B around?
mos_do_ukOSWORD
	jsr	mos_OSBYTE_143_b_cmd_x_param	; pass service call 7/8 to ROMS for unknown osbyte/word
	bne	LE7D6				; if ne return with C and N set
	LDX_B	zp_mos_OSBW_X			; else get original X register
	jmp	LE7BC				;	E7D3
;; ----------------------------------------------------------------------------
LE7D6	puls	A,CC				;	E7D6
	orcc	#CC_C+CC_N			; set C and N
	rts					;	E7DB
;; ----------------------------------------------------------------------------
;LE7DC:	lda	zp_mos_cfs_critical		;	E7DC
;	bmi	LE812				;	E7DE
;	lda	#$08				;	E7E0
;	and	zp_cfs_w			;	E7E2
;	bne	LE7EA				;	E7E4
;	lda	#$88				;	E7E6
;	and	zp_fs_s+11			;	E7E8
;LE7EA:	rts					;	E7EA


 **************************************************************************
 **************************************************************************
 **                                                                      **
 **      OSWORD  DEFAULT ENTRY POINT                                     **
 **                                                                      **
 **      pointed to by default WORDV                                     **
 **                                                                      **
 **************************************************************************
 **************************************************************************

; NOTE: OSWORD API change where X is the pointer to block!

mos_WORDV_default_entry				; LE7EB
	pshs	A,CC				;Push A
						;Push flags
	SEI					;disable interrupts
	sta	zp_mos_OSBW_A			;store A,X,Y
	stx	zp_mos_OSBW_Y			;NOTE: STORE X in Y/X pointer area!
	ldx	#8				; indicate coming from OSWORD
	cmpa	#$E0				;if A=>224
	bhs	1F				;then E78A with carry set

	cmpa	#OSWORD_MAX				;else if A=>14
	bhi	2F				;else E7C8 with carry set pass to ROMS & exit

	asla
	adda	#OSBYTE_TABLE_OSBYTE_SIZE
	jmp	mos_exec_BYTEV_from_osword_leMAX


1
	SEC
	lbra	mos_exec_BYTEV_from_osword_gt224
2
	SEC
	bra	mos_exec_BYTEV_from_osword_gtMAX

;; read a byte from I/O memory; block of 4 bytes set atFDBess pointed to by 00F0/1 (Y,X) ; XY +0  ADDRESS of byte ; +4	 on exit byte read 
;mos_read_a_byte_from_IO_memory:
;	jsr	x_set_up_data_block		;	E803
;	lda	(zp_mos_X+1,x)			;	E806
;	sta	(zp_mos_OSBW_X),y		;	E808
;	rts					;	E80A
;; ----------------------------------------------------------------------------
;; write a byte to I/O memory; block of 5 bytes set atFDBess pointed to by 00F0/1 (Y,X) ; XY +0  ADDRESS of byte ; +4	byte to be written 
;mos_write_a_byte_to_IO_memory:
;	jsr	x_set_up_data_block		;	E80B
;	lda	(zp_mos_OSBW_X),y		;	E80E
;	sta	(zp_mos_X+1,x)			;	E810
;LE812:	lda	#$00				;	E812
;	rts					;	E814
;; ----------------------------------------------------------------------------
;; : set up data block
;x_set_up_data_block:
;	sta	zp_mos_OS_wksp2			;	E815
;	iny					;	E817
;	lda	(zp_mos_OSBW_X),y		;	E818
;	sta	zp_mos_OS_wksp2+1		;	E81A
;	ldy	#$04				;	E81C
;LE81E:	ldx	#$01				;	E81E
;	rts					;	E820
;; ----------------------------------------------------------------------------
;; read OS version number
mos_OSBYTE_0
		bne	osverinx
		DO_BRK	$F7, "OS 1.29"
osverinx	ldx	#17				; As suggested by JGH, see email of 27/617 and http://beebwiki.mdfs.net/OSBYTE_&00
		rts




;; make a sound; block of 8 bytes set atFDBess pointed to by 00F0/1  ; XY +0  Channel or +0=Flush, Channel:+1=Hold,Sync ; 2  Amplitude	 ; 4  Pitch ; 6	 Duration ; Y=0 on entry 
mos_OSWORD_7_SOUND
	ldy	zp_mos_OSBW_Y
	lda	1,Y				; get high byte of channel # (not little endian!)
	cmpa	#$FF
	beq	x_speech_handling_routine	;if its &FF goto speech
	cmpa	#$20				;else if>=&20 set carry
	ldb	#$08				;B=8 for unrecognised OSWORD call via osbyte 143
	bhs	mos_do_ukOSWORD			;and if carry set off to E7CA to offer to ROMS 

	clra					; note must clra here or it will clear C returned next
	jsr	snd_test_H1orF1_API		;return with Carry set if Flush=1:B=Channel#
	orb	#$04				;convert to buffer number
	tfr	D,X				; X = buffer #
	bcc	LE848				;and if carry clear (ex E8C9) then E848

	jsr	x_Buffer_handling2		;else flush buffer

LE848
	ldy	zp_mos_OSBW_Y
	leay	1,Y
	jsr	snd_test_H1orF1_API		;returns with carry set if H=1;B=S
	stb	zp_mos_OS_wksp2			;Sync number =&FA
	pshs	CC				;save flags
	lda	5,Y				;Get Duration byte
	sta	,-S				;push it
	lda	3,Y				;get pitch byte
	sta	,-S				;push it
	lda	1,Y				;get amplitude byte
	rola					;H now =bit 0 (carry shifted)
	suba	#$02				;subract 2
	asla					;multiply by 4
	asla					;
	ora	zp_mos_OS_wksp2			;add S byte (0-3)
						;at this point bit 7=0 for an envelope
						;bits 3-6 give envelope -1, or volume +15 
						;(i.e.complemented)
						;bit 2 gives H
						;bits 0-1 =Sync
	jsr	x_INSV_flashiffull	;transfer to buffer
	bcc	LE887				;if C clear on exit succesful transfer so E887
LE869	leas	2,S				;else get back
						;stored values
	puls	CC,PC				;


;; read VDU status

mos_OSBYTE_117
		LDX_B	zp_vdu_status			;	E86C
		rts					;	E86E
;; ----------------------------------------------------------------------------
;; set up sound data for Bell
mos_VDU_7					; LE86F
		pshs	CC				;push P
		SEI					;bar interrupts
		ldb	sysvar_BELL_CH			;get bell channel number in A
		andb	#$07				; (bits 0-3 only set)
		orb	#$04				;set bit 2
		clra					;X=A = bell channel number +4=buffer number
		tfr	D,X
		lda	sysvar_BELL_ENV			;get bell amplitude/envelope number
		jsr	[INSV]				;store it in buffer pointed to by X
		lda	sysvar_BELL_DUR			;get bell duration
		sta	,-S
		lda	sysvar_BELL_FREQ		;get bell frequency
		sta	,-S
LE887		SEC
		ror	snd_q_occupied-4,x		;and pass into bit 7 to warn that channel is active
		bra	snd_insv2bytesfromstack
;; :speech handling routine
x_speech_handling_routine
	TODO	"x_speech_handling_routine"
;	php					;	E88D
;	iny					;	E88E
;	lda	(zp_mos_OSBW_X),y		;	E88F
;	pha					;	E891
;	iny					;	E892
;	lda	(zp_mos_OSBW_X),y		;	E893
;	pha					;	E895
;	ldy	#$00				;	E896
;	lda	(zp_mos_OSBW_X),y		;	E898
;	ldx	#$08				;	E89A
;	jsr	x_INSV_flashiffull;	E89C
;	bcs	LE869				;	E89F
;	ror	mosbuf_buf_busy+8		;	E8A1
snd_insv2bytesfromstack				; LE8A4
	lda	,S+				; get back byte 
	jsr	jmpINSV				; enter it in buffer X
	lda	,S+				; get back next
	jsr	jmpINSV				; and enter it again
	puls	CC,PC				; get back flags and exit
;; ----------------------------------------------------------------------------


*************************************************************************
 *                                                                       *
 *       OSWORD  08   ENTRY POINT                                        *
 *                                                                       *
 *       define envelope                                                 *
 *                                                                       *
 *************************************************************************
 ;block of 14 bytes set at address pointed to by 00F0/1 
 ;XY +0  Envelope number, also in A
 ;    1  bits 0-6 length of each step in centi-secsonds bit 7=0 auto repeat
 ;    2  change of Pitch per step (-128-+127) in section 1
 ;    3  change of Pitch per step (-128-+127) in section 2
 ;    4  change of Pitch per step (-128-+127) in section 3
 ;    5  number of steps in section 1 (0-255)
 ;    6  number of steps in section 2 (0-255)
 ;    7  number of steps in section 3 (0-255)
 ;    8  change of amplitude per step during attack  phase (-127 to +127)
 ;    9  change of amplitude per step during decay   phase (-127 to +127)
 ;   10  change of amplitude per step during sustain phase (-127 to +127)
 ;   11  change of amplitude per step during release phase (-127 to +127)
 ;   12  target level at end of attack phase   (0-126)
 ;   13  target level at end of decay  phase   (0-126)
mos_OSWORD_8_ENVELOPE
	ldb	,X+
	decb					;set up appropriate displacement to storage area
	andb	#3
	aslb					;A=(A-1)*16 or 15
	aslb					;
	aslb					;
	aslb					;
	ora	#$0F				;
	leay	,X
	ldx	#snd_envelope_defs
	abx
	ldb	#13
1	lda	,Y+
	sta	,X+
	decb
	bne	1B
	clr	,X+
	clr	,X+
	clr	,X
	rts
;; ----------------------------------------------------------------------------

	; API change, X is point to high byte, Carry is set if H>=1, returns channel # in B
snd_test_H1orF1_API				; LE8C9
	ldb	,Y				; get byte
	cmpb	#$10				; is it greater than 15, if so set carry
	andb	#$03				; and 3 to clear bits 2-7
						; increment Y
	pshs	CC
	eim	#1, 0,S
	puls	CC,PC				; and exit
;; ----------------------------------------------------------------------------
;; read interval timer
mos_OSWORD_3_rd_timer
	ldy	#oswksp_OSWORD3_CTDOWN+5	; point 1 after end
	bra	LE8D8
;; read system clock
mos_OSWORD_1_rd_sys_clk
	ldy	#sysvar_BREAK_LAST_TYPE+5	; point 1 after end
	ldb	sysvar_TIMER_SWITCH
	leay	B,Y
LE8D8	ldb	#4
LE8DA	lda	,-Y
	sta	,X+
	decb					;	E8E0
	bpl	LE8DA				;	E8E1
LE8E3	rts					;	E8E3
;; ----------------------------------------------------------------------------
;; write interval timer
mos_OSWORD_4_wr_int_timer				; LE8E4
		ldb	#$0F				; offset between clock and timer
		bra	LE8EE				; jump to E8EE ALWAYS!!
; write system clock
mos_OSWORD_2_wr_sys_clk
		ldb	sysvar_TIMER_SWITCH		; get current clock store pointer (A/5)
		eorb	#$0F				; and invert to get inactive timer(5/A)
		CLC					; clear carry
LE8EE		stb	,-S				; store A
		ldx	#oswksp_TIME-5
		abx
		ldb	#$04				; Y=4
		ldy	zp_mos_OSBW_Y
1		lda	b,y				; and transfer all 5 bytes
		sta	,x+				; to the clock or timer
		decb					; 
		bpl	1B				; if Y>0 then E8F2
		ldb	,S+				; get back stack
		bcs	2F				; if set (write to timer) E8E3 exit
		stb	sysvar_TIMER_SWITCH		; write back current clock store
2		rts					; and exit



mos_OSWORD_0_read_line						; LE902
		ldb	#$04
		ldy	#oswksp_OSWORD0_MAX_CH-4
1		lda	B,X				;transfer bytes 4,3,2 to 2B3-2B5
		sta	B,Y				;
		decb					;decrement Y
		cmpb	#$02				;until Y=1
		bhs	1B				;
		ldy	,X				;get address of input buffer
		clr	sysvar_SCREENLINES_SINCE_PAGE	;Y=0 store in print line counter for paged mode
		CLI					;allow interrupts
		clrb					;zero counter
		bra	OSWORD_0_read_line_loop_read				;Jump to E924

OSWORD_0_read_line_loop_bell				; LE91D
		lda	#$07				;A=7
OSWORD_0_read_line_loop_inc
		incb					;increment Y
		leay	1,Y
OSWORD_0_read_line_loop_echo				; LE921
		jsr	OSWRCH				;and call OSWRCH 
OSWORD_0_read_line_loop_read				; LE924
		jsr	OSRDCH				;else read character  from input stream
		bcs	OSWORD_0_read_line_skip_err	;if carry set then illegal character or other error
							;exit via E972
		pshs	A
		tim	#$02, sysvar_OUTSTREAM_DEST
;;;		lda	sysvar_OUTSTREAM_DEST		;A=&27C get output stream *FX3 
;;;		bita	#2
		puls	A
		bne	OSWORD_0_read_line_skip_novdu	;if Carry set E937
		tst	sysvar_VDU_Q_LEN		;get number of items in VDU queue
		bne	OSWORD_0_read_line_loop_echo	;if not 0 output character and loop round again
OSWORD_0_read_line_skip_novdu				; LE937	
		cmpa	#$7F				;if character is not delete
		bne	OSWORD_0_read_line_skip_notdel				;goto E942
		cmpb	#$00				;else is Y=0
		beq	OSWORD_0_read_line_loop_read	;and goto E924
		decb					;decrement Y and counter
		leay	-1,Y				
		bra	OSWORD_0_read_line_loop_echo	;print backspace
OSWORD_0_read_line_skip_notdel				; LE942
		cmpa	#$15				;is it delete line &21
		bne	OSWORD_0_read_line_skip_not_ctrl_u				;if not E953
		tstb					;if B=0 we are still reading first
							;character
		beq	OSWORD_0_read_line_loop_read	;so E924
		lda	#$7F				;else output DELETES
							; LE94B
1		jsr	OSWRCH				;delete printed chars
		leay	-1,Y				;decrement pointer
		decb					;and counter
		bne	1B				;loop until pointer ==0
		bra	OSWORD_0_read_line_loop_read	;go back to reading from input stream

OSWORD_0_read_line_skip_not_ctrl_u			; LE953
		sta	,y				;store character in designated buffer
		cmpa	#$0D				;is it CR?
		beq	OSWORD_0_read_line_skip_return	;if so E96C
		cmpb	oswksp_OSWORD0_LINE_LEN		;else check the line length
		bhs	OSWORD_0_read_line_loop_bell	;if = or greater loop to ring bell
		cmpa	oswksp_OSWORD0_MIN_CH		;check minimum character
		blo	OSWORD_0_read_line_loop_echo	;if less than ignore and don't increment
		cmpa	oswksp_OSWORD0_MAX_CH		;check maximum character
		bhi	OSWORD_0_read_line_loop_echo	;if higher then ignore and don't increment
		incb
		leay	1,Y
		bra	OSWORD_0_read_line_loop_echo	;if less than ignore and don't increment
OSWORD_0_read_line_skip_return				; LE96C		
		jsr	OSNEWL				;output CR/LF   
		jsr	[NETV]				;call Econet vector
OSWORD_0_read_line_skip_err				; LE972
		m_tby
		lda	zp_mos_ESC_flag			;A=ESCAPE FLAG
		rola					;put bit 7 into carry 
		rts					;and exit routine
;; ----------------------------------------------------------------------------
;; SELECT PRINTER TYPE
mos_OSBYTE_5
		CLI					;allow interrupts briefly
		SEI					;bar interrupts
		tst	zp_mos_ESC_flag			;check if ESCAPE is pending
		bmi	1F				;if it is E9AC
		tst	mosbuf_buf_busy+3		;else check bit 7 buffer 3 (printer)
		bpl	mos_OSBYTE_5			;if not empty bit 7=0 E976
		jsr	LPT_NETV_then_UPTV		;check for user defined routine
		ldy	#$00				;Y=0
		sty	zp_mos_OSBW_Y			;F1=0   


mos_OSBYTE_130					; DB: new
		ldx	#$FFFF
		ldy	#$FFFF
1		rts

mos_STAR_TIME
		;TODO - find somewhere else to put this?
		ldx	#stack
		jsr	mos_OSWORD_E_read_rtc_0
		ldx	#stack

1		lda	,X+
		jsr	OSASCI
		cmpa	#$D
		bne	1B
		rts

mos_OSWORD_F_write_rtc
		leax	1,X
		pshs	CC
		SEI
		jsr	rtc_wait
		cmpa	#8
		beq	mos_OSWORD_F_write_rtc_8
		cmpa	#15
		beq	mos_OSWORD_F_write_rtc_15
		cmpa	#24
		beq	mos_OSWORD_F_write_rtc_24
mos_OSWORD_F_fin
		puls	CC,PC

		; date and time
mos_OSWORD_F_write_rtc_24
		jsr	mos_OSWORD_F_write_rtc_15_x
mos_OSWORD_F_write_rtc_8
		jsr	bcd_at_X
		ldb	#RTC_REG_HOURS
		jsr	rtc_write
		leax	1,X
		jsr	bcd_at_X
		ldb	#RTC_REG_MINUTES
		jsr	rtc_write
		leax	1,X
		jsr	bcd_at_X
		ldb	#RTC_REG_SECONDS
		jsr	rtc_write
		bra	mos_OSWORD_F_fin

mos_OSWORD_F_write_rtc_15_x
		pshs	CC
mos_OSWORD_F_write_rtc_15
		pshsw
		ldw	,X			; D contains first two letters of day
		ldy	#tbl_days
		ldb	#7
		jsr	day_find
		ldb	#RTC_REG_DOW
		jsr	rtc_write

		leax	4,X
		jsr	bcd_at_X
		ldb	#RTC_REG_DAY
		jsr	rtc_write
		
		leax	1,X
		ldw	1,X			; D contains second two letters of month
		ldy	#tbl_months+1
		ldb	#12
		jsr	day_find
		ldb	#RTC_REG_MONTH
		jsr	rtc_write

		leax	6,X
		jsr	bcd_at_X
		ldb	#RTC_REG_YEAR
		jsr	rtc_write
		
		leax	1,X
		pulsw
		bra	mos_OSWORD_F_fin


;  0123456789ABCDEF012345678
;  Day,DD Mon Year.HH:MM:SS£
;  YMDWhms


day_find
		clra
1		cmpw	,Y++
		beq	2F
		leay	1,Y
		inca
		decb
		bpl	1B
		clra
2		inca
		rts

bcd_at_X	jsr	bcd_digit
		asla
		asla
		asla
		asla
		sta	,-S
		jsr	bcd_digit
		adda	,S+
		rts


bcd_digit	lda	,X+
		suba	#'0'
1		cmpa	#9
		bls	1F
		suba	#20
		bra	1B
1		rts


mos_OSWORD_E_read_rtc
		;; lda	,X
		tsta
		beq	mos_OSWORD_E_read_rtc_0
		cmpa	#1
		beq	mos_OSWORD_E_read_rtc_1
		cmpa	#2
		beq	mos_OSWORD_E_read_rtc_2
		rts
mos_OSWORD_E_read_rtc_0
		stx	,--S
		jsr	mos_OSWORD_E_read_rtc_1		; get BCD time
		ldx	,S++
		leax	-1,X
		bra	mos_OSWORD_E_read_rtc_2
mos_OSWORD_E_read_rtc_1

		jsr	rtc_wait

		pshs	CC
		orcc	#CC_I + CC_F		; we mustn't be interrupted
		ldb	#9
1		jsr	rtc_read
		sta	,X+
		decb
		cmpb	#5
		bgt	1B
		decb
		bpl	1B

		puls	CC,PC

mos_OSWORD_E_read_rtc_2
		; seconds
		leay	$17,X
		lda	7,x
		jsr	mos_hexstr_Y
		;minutes
		leay	$14,X
		lda	6,X
		jsr	mos_hexstr_Y
		;hours
		leay	$11,X
		lda	5,X
		jsr	mos_hexstr_Y
		; YY
		leay	$E,X
		lda	1,X
		jsr	mos_hexstr_Y
		; century
		ldb	1,X
		lda	#$19
		cmpa	#$80
		adca	#0
		daa
		leay	$C,X
		jsr	mos_hexstr_Y
		; DD
		leay	$5,X
		lda	3,X
		jsr	mos_hexstr_Y
		; Mon
		stx	,--S
		ldb	$2,X
		cmpb	#$10				; convert BCD to binary
		blo	1F
		subb	#6
1		leay	8,X
		ldx	#tbl_months
		jsr	domonth

		ldx	,S
		; Day
		ldb	$4,X
		leay	1,X
		ldx	#tbl_days
		jsr	doday

		ldx	,S++

		; puntuation
		lda	#$D
		sta	$19,X
		lda	#':'
		sta	$13,X
		sta	$16,X
		lda	#'.'
		sta	$10,X
		lda	#','
		sta	$4,X
		lda	#' '
		sta	$7,X
		sta	$B,X


		rts

domonth
doday
		decb
		stb	,-S
		aslb
		addb	,S+
		abx
		ldb	#3
1		lda	,X+
		sta	,Y+
		decb
		bne	1B
		rts



tbl_days	fcb	"SunMonTueWedThuFriSat"
tbl_months	fcb	"JanFebMarAprMayJumJulAugSepOctNovDec"


rtc_wait					; wait for a UIP clear or if set wait for it to end
		std	,--S
		ldb	#$A
		jsr	rtc_read
		tsta
		bpl	2F			; if not UIP we have 240uS to read clock

1		ldb	#$A
		jsr	rtc_read
		tsta
		bmi	1B			; wait for UIP to go low

2		puls	D,PC


		; rtc_write A=data, B=address
rtc_write
		pshs	CC,A

		orcc	#CC_I + CC_F			; disable interrupts

		; AS low
		lda	#BITS_RTC_AS_OFF
		sta	sheila_SYSVIA_orb

		; DS low
		lda	#BITS_RTC_DS
		sta	sheila_SYSVIA_orb

		; AS hi
		lda	#BITS_RTC_AS_ON
		sta	sheila_SYSVIA_orb

		lda	#$FF
		sta	sheila_SYSVIA_ddra

		; rtc address
		stb	sheila_SYSVIA_ora_nh

		; CS low
		lda	#BITS_RTC_CS 
		sta	sheila_SYSVIA_orb

		; RnW lo
		lda	#BITS_RTC_RnW
		sta	sheila_SYSVIA_orb

		; AS low
		lda	#BITS_RTC_AS_OFF
		sta	sheila_SYSVIA_orb

		; DS hi
		lda	#BITS_RTC_DS + BITS_LAT_ON
		sta	sheila_SYSVIA_orb

		lda	1,S
		sta	sheila_SYSVIA_ora_nh

		; DS low
		lda	#BITS_RTC_DS
		sta	sheila_SYSVIA_orb

		; CS hi
		lda	#BITS_RTC_CS + BITS_LAT_ON
		sta	sheila_SYSVIA_orb

		puls	CC,A,PC


rtc_read	
		pshs	CC,A

		orcc	#CC_I + CC_F			; disable interrupts

		; AS low
		lda	#BITS_RTC_AS_OFF
		sta	sheila_SYSVIA_orb

		; DS low
		lda	#BITS_RTC_DS
		sta	sheila_SYSVIA_orb

		; AS hi
		lda	#BITS_RTC_AS_ON
		sta	sheila_SYSVIA_orb

		lda	#$FF
		sta	sheila_SYSVIA_ddra

		; rtc address
		stb	sheila_SYSVIA_ora_nh

		; CS low
		lda	#BITS_RTC_CS 
		sta	sheila_SYSVIA_orb

		; slow D all in
		clr	sheila_SYSVIA_ddra

		; RnW hi
		lda	#BITS_RTC_RnW + BITS_LAT_ON
		sta	sheila_SYSVIA_orb

		; AS low
		lda	#BITS_RTC_AS_OFF
		sta	sheila_SYSVIA_orb

		; DS hi
		lda	#BITS_RTC_DS + BITS_LAT_ON
		sta	sheila_SYSVIA_orb

		lda	sheila_SYSVIA_ora_nh
		sta	1,S

		; DS low
		lda	#BITS_RTC_DS
		sta	sheila_SYSVIA_orb

		; CS hi
		lda	#BITS_RTC_CS + BITS_LAT_ON
		sta	sheila_SYSVIA_orb

		puls	CC,A,PC




 *************************************************************************
 *                                                                       *
 *       OSBYTE  01   ENTRY POINT                                        *
 *                                                                       *
 *       READ/WRITE USER FLAG (&281)                                     *
 *                                                                       *
 *          AND                                                          *
 *                                                                       *
 *       OSBYTE  06   ENTRY POINT                                        *
 *                                                                       *
 *       SET PRINTER IGNORE CHARACTER                                    *
 *                                                                       *
 *************************************************************************
 ; A contains osbyte number
 ; X contains value
 ; Y = 0 * despite what it says in the userguide!
mos_OSBYTE_1AND6
	ora	#$F0				;A=osbyte +&F0
	bra	LE99A				;JUMP to E99A


 *************************************************************************
 *                                                                       *
 *       OSBYTE  0C   ENTRY POINT                                        *
 *                                                                       *
 *       SET  KEYBOARD AUTOREPEAT RATE                                   *
 *                                                                       *
 *************************************************************************
mos_OSBYTE_12
	bne	mos_OSBYTE_11			;if &F0<>0 goto E995
	ldx	#$32				;if X=0 in original call then X=32
	stx	sysvar_KEYB_AUTOREP_DELAY	;to set keyboard autorepeat delay ram copy
	ldx	#$08				;X=8
;; SET  KEYBOARD AUTOREPEAT DELAY
mos_OSBYTE_11
	adda	#$D0				;	E995
;; ENABLE/DISABLE CURSOR EDITING
mos_OSBYTE_3AND4
	adda	#$E9				;	E998
LE99A
	STX_B	zp_mos_OSBW_X			;	E99A

*************************************************************************
*                                                                       *
*       OSBYTE  A6-FF   ENTRY POINT                                     *
*                                                                       *
*       READ/ WRITE SYSTEM VARIABLE OSBYTE NO. +&190                    *
*                                                                       *
*************************************************************************
mos_OSBYTE_RW_SYSTEM_VARIABLE
	ldx	#sysvar_OSVARADDR-$A6
	tfr	A,B				;Y=A+&190
	cmpb	#$B0
	blo	mos_OSBYTE_RW_SYSTEM_VARIABLE_BE
	abx
	ldd	,x				;i.e. A=&190 +osbyte call!
	sta	,-S
	anda	zp_mos_OSBW_Y			;new value = OLD value AND Y EOR X!     
	eora	zp_mos_OSBW_X			;       
	sta	,x+				;store it
	lda	,S				; bet back original a
	clr	,-S				; stacked Y
	exg	a,b
	std	,--S				; stack this as X
	puls	Y,X,PC

mos_OSBYTE_RW_SYSTEM_VARIABLE_BE		; as above but frig for big endian
	eorb	#1				; read these the opposite way round as they're big endian
	abx
	ldd	-1,X				;i.e. A=&190 +osbyte call and the byte before it (will give wrong answer in Y on odd accesses!)
	stb	,-S				;push original value on stack
	andb	zp_mos_OSBW_Y			;new value = OLD value AND Y EOR X!     
	eorb	zp_mos_OSBW_X			;       
	stb	,X				;store it
	ldb	,S				; get back original B
	clr	,-S				; this as high
	std	,--S				;put Y return into top of returned X
	puls	Y,X,PC



;; ----------------------------------------------------------------------------
;; SERIAL BAUD RATE LOOK UP TABLE
mostbl_SERIAL_BAUD_LOOK_UP			; LE9AD
	FCB	$64					; % 01100100      75
	FCB	$7F					; % 01111111     150
	FCB	$5B					; % 01011011     300
	FCB	$6D					; % 01101101    1200
	FCB	$C9					; % 11001001    2400
	FCB	$F6					; % 11110110    4800
	FCB	$D2					; % 11010010    9600
	FCB	$E4					; % 11100100   19200    
	FCB	$40					; % 01000000

*************************************************************************
*                                                                       *
*       OSBYTE  &13   ENTRY POINT                                       *
*                                                                       *
*       Wait for Animation                                              *
*                                                                       *
*************************************************************************



mos_OSBYTE_19						; LE9B6
	lda	sysvar_CFSTOCTR			;read vertical sync counter
1	CLI					;allow interrupts briefly
	SEI					;bar interrupts
	cmpa	sysvar_CFSTOCTR			;is it 0 (Vertical sync pulse)
	beq	1B				;no then E9B9
;; READ VDU VARIABLE; X contains the variable number ; 0 =lefthand column in pixels current graphics window ; 2 =Bottom row in pixels current graphics window ; 4 =Right hand column in pixels current graphics window ; 6 =Top row in pixels current graphics win
	; TODO: swap certain bytes here
mos_OSBYTE_160
	lda	vduvar_GRA_WINDOW_LEFT+1,x	;	E9C0
	m_tay
	lda	vduvar_GRA_WINDOW_LEFT,x	;	E9C3
	m_tax					;	E9C6
	rts					;	E9C7
;; ----------------------------------------------------------------------------
;; RESET SOFT KEYS

*** <doc>
*** <osbyte num="18">
***  <name>Reset soft keys</name>
***  <params>No parameters</params>
***  <descr>This call clears the soft key buffer so the character strings are no longer available</descr>
***  <exit>
***    <preserves>X Y</preserves>
***    <undefined>A C</undefined>
***  </exit>
*** </osbyte>

mos_OSBYTE_18
	pshs	X
	lda	#$10				;	E9C8
	sta	sysvar_KEYB_SOFT_CONSISTANCY	;	E9CA
	ldx	#soft_keys_start		;	E9CD
	clrb
1	sta	b,x				;	E9CF
	incb					;	E9D2
	bne	1B				;	E9D3
	clr	sysvar_KEYB_SOFT_CONSISTANCY	;	E9D5
	puls	X,PC				;	E9D8
;; ----------------------------------------------------------------------------
 *************************************************************************
 *                                                                       *
 *        OSBYTE &76 (118) SET LEDs to Keyboard Status                   *
 *                                                                       *
 *************************************************************************
                          ;osbyte entry with carry set
                         ;called from &CB0E, &CAE3, &DB8B

mos_OSBYTE_118					; LE9D9
	pshs	CC				;PUSH P
	SEI					;DISABLE INTERUPTS
	lda	#$40				;switch on CAPS and SHIFT lock lights
	jsr	x_keyb_leds_test_esc		;via subroutine
	bmi	LE9E7				;if ESCAPE exists (M set) E9E7
	ANDCC	#~(CC_C + CC_V)			;else clear V and C
						;before calling main keyboard routine to
	jsr	[KEYV]				;switch on lights as required
LE9E7	puls	CC				;get back flags
	rola					;and rotate carry into bit 0
	rts					;Return to calling routine
;; ----------------------------------------------------------------------------
;; Turn on keyboard lights and Test Escape flag; called from &E1FE, &E9DD  ;  
x_keyb_leds_test_esc
	bcc	LE9F5
	ldb	#$07
	stb	sheila_SYSVIA_orb
	decb
	stb	sheila_SYSVIA_orb
LE9F5	tst	zp_mos_ESC_flag
	rts
;; ----------------------------------------------------------------------------
mos_poke_SYSVIA_orb
	pshs	CC
	SEI
	sta	sheila_SYSVIA_orb
	puls	CC,PC

*************************************************************************
*                                                                       *
*       OSBYTE 154 (&9A) SET VIDEO ULA                                  *       
*                                                                       *
*************************************************************************
mos_OSBYTE_154
	m_txa					;osbyte entry! X transferred to A thence to
mos_VIDPROC_set_CTL
	pshs	CC				;save flags
	SEI					;disable interupts
	sta	sysvar_VIDPROC_CTL_COPY		;save RAM copy of new parameter
	sta	sheila_VIDULA_ctl		;write to control register
	anda	#$01
	sta	sheila_VIDULA_pixeor		;RAMDAC flash
	lda	sysvar_FLASH_MARK_PERIOD	;read  space count
	sta	sysvar_FLASH_CTDOWN		;set flash counter to this value
	puls	CC				;get back status
	rts					;and return

*************************************************************************
*                                                                       *
*        OSBYTE &9B (155) write to pallette register                    *       
*                                                                       *
*************************************************************************
                ;entry X contains value to write

mos_OSBYTE_155
	m_txa					;	EA10
write_pallette_reg
	eora	#$07				;	EA11
	pshs	CC				;	EA13
	SEI					;	EA14
	sta	sysvar_VIDPROC_PAL_COPY		;	EA15
	sta	sheila_VIDULA_pal		;	EA18
	puls	CC,PC				;	EA1B
;; ----------------------------------------------------------------------------
;; A contains first non blank character
mos_CLC_GSINIT
	CLC					;	EA1D
mos_GSINIT
	ror	zp_mos_GSREAD_quoteflag		;Rotate moves carry to &E4
	jsr	mos_skip_spaces_at_X		;get character from text
;;	iny					;increment Y to point at next character DB: already is!
	cmpa	#$22				;check to see if its '"'
	beq	LEA2A				;if so EA2A (carry set)
	leax	-1,X				;decrement Y
	CLC					;clear carry
LEA2A	ror	zp_mos_GSREAD_quoteflag		;move bit 7 to bit 6 and put carry in bit 7
	cmpa	#$0D				;check to see if its CR to set Z
	rts					;and return
;; ----------------------------------------------------------------------------
;; new API - read string at X (should have been inited with GSINIT)  
mos_GSREAD
	lda	#$00					; A=0
LEA31	sta	zp_mos_GSREAD_characc			; store A
	lda	,X					; peek first character
	cmpa	#$0D					; is it CR
	bne	GSREAD_notCR1				; if not goto EA3F
	tst	zp_mos_GSREAD_quoteflag			; if bit 7=1 no 2nd '"' found
	bmi	brkBadString				; goto EA8F
	bra	mos_GSREAD_cr					; if not EA5A
GSREAD_notCR1						; LEA3F
	cmpa	#$20					; is less than a space?
	blo	brkBadString				; goto EA8F
	bne	LEA4B					; if its not a space EA4B
	tst	zp_mos_GSREAD_quoteflag			; is bit 7 of &E4 =1
	bmi	LEA89					; if so goto EA89
	tim	#$40, zp_mos_GSREAD_quoteflag		; 
	beq	LEA5A					; if bit 6 = 0 EA5A
LEA4B	cmpa	#$22					; is it '"'
	bne	LEA5F					; if not EA5F
	tst	zp_mos_GSREAD_quoteflag			; if so and Bit 7 of &E4 =0 (no previous ")
	bpl	LEA89					; then EA89
	leax	1,X					; else point at next character
	lda	,X					; get it
	cmpa	#$22					; is it '"'
	beq	LEA89					; if so then EA89
LEA5A	jsr	mos_skip_spaces_at_X			; read a byte from text
mos_GSREAD_cr
	SEC						; and return with
	rts						; carry set
;; ----------------------------------------------------------------------------
LEA5F	cmpa	#'|'					; is it '|'
	bne	LEA89					; if not EA89
	leax	1,X					; if so increase Y to point to next character
	lda	,X					; get it
	cmpa	#'|'					; and compare it with '|' again
	beq	LEA89					; if its '|' then EA89
	cmpa	#'"'					; else is it '"'
	beq	LEA89					; if so then EA89
	cmpa	#'!'					; is it !
	bne	LEA77					; if not then EA77
	leax	1,X					; increment Y again
	lda	#$80					; set bit 7
	bra	LEA31					; loop back to EA31 to set bit 7 in next CHR
LEA77	cmpa	#' '					; is it a space
	bcc	brkBadString				; if less than EA8F Bad String Error
	cmpa	#'?'					; is it '?'
	beq	LEA87					; if so EA87
	jsr	x_Implement_CTRL_codes			; else modify code as if CTRL had been pressed
;;	bit	mostbl_SYSVAR_DEFAULT_SETTINGS+65	; if bit 6 set
;;	bvs	LEA8A					; then EA8A
	; exit with overflow set carry clear
	leax	1,X
	ora	zp_mos_GSREAD_characc
	SEV
	rts


LEA87	lda	#$7F					; else set bits 0 to 6 in A
LEA89	CLV						; clear V
LEA8A	leax	1,X					; increment Y
	ora	zp_mos_GSREAD_characc			;
	CLC						; clear carry
	rts						; Return
;; ----------------------------------------------------------------------------
brkBadString					; LEA8F
	DO_BRK	$FD, "Bad String"

;; Modify code as if SHIFT pressed
x_Modify_code_as_if_SHIFT			; LEA9c
		cmpa	#'0'				;if A='0' skip routine
		beq	LEABErts				;
		cmpa	#'@'				;if A='@' skip routine
		beq	LEABErts				;
		blo	LEAB8				;if A<'@' then EAB8
		cmpa	#$7F				;else is it DELETE
		beq	LEABErts			;if so skip routine
		bhi	LEABCeor10rts			;if greater than &7F then toggle bit 4
LEAACeor30	eora	#$30				;reverse bits 4 and 5
		cmpa	#$6F				;is it &6F (previously '_' (&5F))
		beq	LEAB6				;goto EAB6
		cmpa	#$50				;is it &50 (previously '`' (&60))
		bne	LEAB8				;if not EAB8
LEAB6		eora	#$1F				;else continue to convert ` _
LEAB8		cmpa	#'!'				;compare &21 '!'
		blo	LEABErts			;if less than return
LEABCeor10rts	eora	#$10				;else finish conversion by toggling bit 4
LEABErts	rts				;exit
							;
							;ASCII codes &00 &20 no change
							;21-3F have bit 4 reverses (31-3F)
							;41-5E A-Z have bit 5 reversed a-z
							;5F & 60 are reversed
							;61-7E bit 5 reversed a-z becomes A-Z
							;DELETE unchanged
							;&80+ has bit 4 changed

;; ----------------------------------------------------------------------------
;; Implement CTRL codes
x_Implement_CTRL_codes					; LEABF
		cmpa	#$7F				;is it DEL
		beq	LEAD1rts			;if so ignore routine
		bhs	LEAACeor30				;if greater than &7F go to EAAC
		cmpa	#$60				;if A<>'`'
		bne	LEACB				;goto EACB
		lda	#$5F				;if A=&60, A=&5F

LEACB		cmpa	#'@'				;if A<&40
		blo	LEAD1rts			;goto EAD1  and return unchanged
		anda	#$1F				;else zero bits 5 to 7
LEAD1rts		rts					;return

STARRUNPLINGBOOT
		FCB	'/!BOOT',$0D

;; OSBYTE &F7 (247) INTERCEPT BREAK
mos_OSBYTE_247
	lda	sysvar_BREAK_VECTOR_JMP
	eora	#$4C
	bne	LEAF3rts				;	EADE
	jmp	sysvar_BREAK_VECTOR_JMP
;; ----------------------------------------------------------------------------
;; OSBYTE &90 (144)   *TV; X=display delay ; Y=interlace flag 
mos_OSBYTE_144
	lda	oswksp_VDU_VERTADJ		;	EAE3
	STX_B	oswksp_VDU_VERTADJ
	m_tax
	m_tya					;	EAEA
	anda	#$01				;	EAEB
	LDY_B	oswksp_VDU_INTERLACE		;	EAED
	sta	oswksp_VDU_INTERLACE		;	EAF0
LEAF3rts	
	rts
;; ----------------------------------------------------------------------------
;; OSBYTE &93 (147)  WRITE TO FRED; X is offset within page ; Y is byte to write 
;mos_OSBYTE_147:
;	tya					;	EAF4
;	sta	LFC00,x				;	EAF5
;	rts					;	EAF8
;; ----------------------------------------------------------------------------
;; OSBYTE &95 (149)  WRITE TO JIM; X is offset within page ; Y is byte to write ;  
;mos_OSBYTE_149:
;	tya					;	EAF9
;	sta	LFD00,x				;	EAFA
;	rts					;	EAFD
;; ----------------------------------------------------------------------------
;; OSBYTE &97 (151)  WRITE TO SHEILA; X is offset within page ; Y is byte to write 
;mos_OSBYTE_151:
;	tya					;	EAFE
;	sta	sheila_CRTC_reg,x		;	EAFF
;	rts					;	EB02
;; ----------------------------------------------------------------------------
;; Silence a sound channel; X=channel number 
x_Silence_a_sound_channel				; LEB03
		lda	#$04				;mark end of release phase
		sta	snd_amplitude_phase_count-4,x	;to channel X
		lda	#$C0				;load code for zero volume
;; if sound not disabled set sound generator volume
snd_set_vol
		sta	snd_amplitude-4,x		;store A to give basic sound level of Zero
		ldb	sysvar_SOUND_SUPPRESS		;get sound output/enable flag
		beq	LEB14				;if sound enabled goto EB14
		lda	#$C0				;else load zero sound code 
LEB14		suba	#$40				;subtract &40
		lsra					;divide by 8
		lsra					;to get into bits 0 - 3
		lsra					;
		eora	#$0F				;invert bits 0-3
		ora	mostbl_sound_params-4,x		;get channel number into top nybble
		ora	#$10				;
snd_poke_flags						; LEB21
		pshs	CC
snd_poke_flags_stacked					; LEB22
		SEI					;disable interrupts
		ldb	#$FF				;System VIA port A all outputs
		stb	sheila_SYSVIA_ddra		;set
		sta	sheila_SYSVIA_ora_nh		;output A on port A
		clr	sheila_SYSVIA_orb		;enable sound chip
		ldb	#$02				;set and
1		decb					;execute short delay (2 + 2 + 3 + 2 + 2 = 11cyc on 6502, 12 on 6809)
		bne	1B				;
		ldb	#$08				;then disable sound chip again
		stb	sheila_SYSVIA_orb		;
		ldb	#$04				;set delay
1		decb					;and loop delay
		bne	1B				;
		puls	CC,PC				;get back flags and exit
;; ----------------------------------------------------------------------------
;; : Sound parameters look up table ???CHECK???
mostbl_sound_params
	FCB	$E0, $C0, $A0, $80


*************************************************************************
*                                                                       *
*       PROCESS SOUND INTERRUPT                                         *
*                                                                       *
*************************************************************************
irq_sound						; LEB47
		clr	snd_num_chans_hold_sync		;zero number of channels on hold for sync
		lda	snd_num_chans_sync		;get number of channels required for sync
		bne	1F				;if this <>0 then EB57
		inc	snd_num_chans_hold_sync		;else number of chanels on hold for sync =1
		dec	snd_num_chans_sync		;number of channels required for sync =255

1		ldx	#$08				;set loop counter
irq_sound_loop						; LEB59
		leax	-1,x				;loop
		lda	snd_q_occupied-4,x		;get value of &800 +offset (sound queue occupancy) 
		lbeq	mos_sound_irq_skip		;if 0 goto EC59 no sound this channel
		lda	mosbuf_buf_busy,x		;else get buffer busy flag
		bmi	1F				;if negative (buffer empty) goto EB69
		lda	snd_duration_ctr-4,x		;else if duration count not zer0 
		bne	2F				;goto EB6C

1		jsr	irq_sound_check_get_next	;check and pick up new sound if required
2		lda	snd_duration_ctr-4,x		;if duration count 0
		beq	irq_sound_done			;goto EB84
		cmpa	#$FF				;else if it is &FF (infinite duration)
		beq	irq_sound_cont			;go onto EB87
		dec	snd_duration_mul-4,x		;decrement 10 mS count
		bne	irq_sound_cont			;and if 0
		lda	#$05				;reset to 5
		sta	snd_duration_mul-4,x		;to give 50 mSec delay
		dec	snd_duration_ctr-4,x		;and decrement main counter
		bne	irq_sound_cont			;if not zero then EB87

irq_sound_done	jsr	irq_sound_check_get_next	;else check and get new sound
irq_sound_cont	lda	snd_length_left-4,x		;if step progress counter is 0 no envelope involved
		beq	irq_sound_env_step		;so jump to EB91
		dec	snd_length_left-4,x		;else decrement it
		lbne	mos_sound_irq_skip		;and if not zero go on to EC59
irq_sound_env_step		
		ldb	snd_env_no-4,x			;get  envelope data offset from (8C0)
		cmpb	#$FF				;if 255 no envelope set so
		lbeq	mos_sound_irq_skip		;goto EC59
		m_tby
		lda	snd_envelope_defs,y		;else get get step length 
		anda	#$7F				;zero repeat bit
		sta	snd_length_left-4,x		;and store it
		lda	snd_amplitude_phase_count-4,x	;get phase counter
		cmpa	#$04				;if release phase completed
		beq	irq_sound_env_amp_done		;goto EC07
		ldb	snd_amplitude_phase_count-4,x	;else start new step by getting phase 
		addb	snd_env_no-4,x			;add it to envelope no
		m_tby					;transfer to Y
		lda	snd_envelope_defs+11,y		;and get target value base for envelope
		suba	#$3F				;
		sta	snd_cur_target_amplitude	;store modified number as current target amplitude
		lda	snd_envelope_defs+7,y		;get byte from envelope store
		sta	snd_cur_amp_step		;store as current amplitude step
		lda	snd_amplitude-4,x		;get base volumelevel 
		pshs	a				;save it
		adda	snd_cur_amp_step		;add to current amplitude step
		bvc	1F				;if no overflow
		rola					;double it Carry = bit 7
		lda	#$3F				;if bit =1 A=&3F
		bcs	1F				;into &EBCF
		coma					;else toggle bits (A=&C0)

		;at this point the BASIC volume commands are converted
		; &C0 (0) to &38 (-15) 3 times, In fact last 3 bits 
		;are ignored so &3F represents -15


1		sta	snd_amplitude-4,x		;store in current volume
		rola					;multiply by 2
		eora	snd_amplitude-4,x		;if bits 6 and 7 are equal
		bpl	2F				;goto &EBE1
		lda	#$3F				;if carry clear A=&3F (maximum)
		bcc	1F				;or
		coma					;&C0 minimum
							; LEBDE
1		sta	snd_amplitude-4,x		;and this is stored in current volume

							; LEBE1
2		dec	snd_cur_amp_step		;decrement amplitude change per step
		lda	snd_amplitude-4,x		;get volume again
		suba	snd_cur_target_amplitude	;subtract target value
		eora	snd_cur_amp_step		;negative value indicates correct trend
		bmi	1F				;so jump to next part
		lda	snd_cur_target_amplitude	;else enter new phase
		sta	snd_amplitude-4,x		;
		inc	snd_amplitude_phase_count-4,x	;

1		puls	A				;get the old volume level
		eora	snd_amplitude-4,x		;and compare with the old
		anda	#$F8				;
		beq	irq_sound_env_amp_done		;if they are the same goto EC07
		lda	snd_amplitude-4,x		;else set new level
		jsr	snd_set_vol			;via EB0A
irq_sound_env_amp_done
		lda	snd_pitch_phase_count-4,x	;get absolute pitch value
		cmpa	#$03				;if it =3
		beq	mos_sound_irq_skip		;skip rest of loop as all sections are finished
		lda	snd_steps_left-4,x		;else if 814,X is not 0 current section is not
							;complete 
		bne	irq_sound_env_pitch_cont	;so EC3D
		inc	snd_pitch_phase_count-4,x	;else implement a section change
		lda	snd_pitch_phase_count-4,x	;check if its complete
		cmpa	#$03				;if not
		bne	irq_sound_env_pitch_next				;goto EC2D
		ldb	snd_env_no-4,x			;else set A from
		m_tby
		lda	snd_envelope_defs,y		;&820 and &8C0 (first envelope byte)
		bmi	mos_sound_irq_skip		;if negative there is no repeat
		clra					;else restart section sequence
		sta	snd_pitch_deviation-4,x		;
		sta	snd_pitch_phase_count-4,x	;
irq_sound_env_pitch_next				; LEC2D	
		lda	snd_pitch_phase_count-4,x	;get number of steps in new section
		adda	snd_env_no-4,x			;
		m_tay					;
		lda	snd_envelope_defs+4,y		;
		sta	snd_steps_left-4,x		;set in 814+X
		beq	mos_sound_irq_skip		;and if 0 then EC59
irq_sound_env_pitch_cont				; LEC3D
		dec	snd_steps_left-4,x				;decrement
		lda	snd_env_no-4,x			;and pick up rate of pitch change
		adda	snd_pitch_phase_count-4,x	;
		m_tay					;
		lda	snd_envelope_defs+1,y		;
		adda	snd_pitch_deviation-4,x		;add to rate of differential pitch change
		sta	snd_pitch_deviation-4,x		;and save it
		adda	snd_abs_pitch-4,x		;ad to base pitch
		jsr	snd_check_set_pitch		;and set new pitch
mos_sound_irq_skip					; LEC59
		cmpx	#$04				;if X=4 (last channel)
		beq	LEC6Arts			;goto EC6A (RTS)
		jmp	irq_sound_loop			;else do loop again
;; ----------------------------------------------------------------------------

snd_init						; LEC60
		ldx	#$08
1		leax	-1,x
		jsr	snd_clear_chan_API
		cmpx	#$04
		bne	1B
LEC6Arts	rts
;; ----------------------------------------------------------------------------
irq_sound_check_get_next		; LEC6B
		lda	snd_amplitude_phase_count-4,x	;check for last channel
		cmpa	#$04				;is it 4 (release complete)
		beq	1F				;if so EC77
		lda	#$03				;else mark release in progress
		sta	snd_amplitude_phase_count-4,x	;and store it
1		lda	mosbuf_buf_busy,x		;is buffer not empty
		beq	irq_sound_check_get_next_sync	;if so EC90
							;else mark buffer not empty
		clr	mosbuf_buf_busy,x		;an store it

		ldy	#snd_sync_hold_parm-1
		ldb	#4
1		clr	B,Y				;zero sync bytes 
		decb
		bne	1B

		clr	snd_duration_ctr-4,x		;zero duration count
		decb					;and set sync count to
		stb	snd_num_chans_sync		;&FF
irq_sound_check_get_next_sync				; LEC90		
		lda	snd_sync_hold_parm-4,x		;get synchronising flag
		beq	x_Synchronise_sound_routines	;if its 0 then ECDB
		lda	snd_num_chans_hold_sync		;else get number of channels on hold
		beq	snd_silence_if_not_env		;if 0 then ECD0
		clra					;else
		sta	snd_sync_hold_parm-4,x		;zero note length interval??? No sync parm!
jmp_snd_get_from_buff		
		jmp	snd_get_from_buff

;; ----------------------------------------------------------------------------
	; API change channel no + 4 in X (i.e. buffer #), not A,B are trashed!
snd_clear_chan_API				; LECA2
		jsr	x_Silence_a_sound_channel	;silence the channel
		clr	snd_duration_ctr-4,x		;zero main count
		clr	mosbuf_buf_busy,x		;mark buffer not empty
		clr	snd_q_occupied-4,x		;mark channel dormant
		ldy	#snd_sync_hold_parm		;loop counter
		lda	#3
1		clr	a,y				;zero sync flags
		deca					;
		bpl	1B				;
		sta	snd_num_chans_sync		;number of channels to &FF
		inca					; back to 0
		bra	snd_set_pitch				;jump to ED06 ALWAYS


snd_check_silence_and_finish					; LECBC		
		pshs	CC				;save flags 
		SEI					;and disable interrupts
		lda	snd_amplitude_phase_count-4,x	;check for end of release
		cmpa	#$04				;
		bne	1F				;and if not found ECCF
		jsr	mos_OSBYTE_152			;else examine buffer
		bcc	1F				;if not empty ECCF
							;else mark channel dormant
		clr	snd_q_occupied,x		;
1		puls	CC				;get back flags

snd_silence_if_not_env					; LECD0
		ldb	snd_env_no-4,x			;if no envelope 820=&FF
		cmpb	#$FF				;
		bne	LECDArts			;then terminate sound
		jsr	x_Silence_a_sound_channel	;via EB03 
LECDArts	rts					;else return
;; ----------------------------------------------------------------------------
;; Synchronise sound routines
x_Synchronise_sound_routines
		jsr	mos_OSBYTE_152			;examine buffer if empty carry set
		bcs	snd_check_silence_and_finish	;
		anda	#$03				;else examine next word if>3 or 0
		beq	jmp_snd_get_from_buff		;goto ED98 (via EC9F)
		lda	snd_num_chans_sync		;else get synchronising count
		beq	snd_silence_if_not_env		;in 0 (complete) goto ECFE
		inc	snd_sync_hold_parm-4,x		;else set sync flag
		tst	snd_num_chans_sync		;if 0838 is +ve S has already been set so
		bpl	1F				;jump to ECFB
		jsr	mos_OSBYTE_152			;else get first byte
		anda	#$03				;mask bits 0,1
		sta	snd_num_chans_sync		;and store result
		bra	snd_silence_if_not_env		;Jump to ECFE (ALWAYS!!)

1		dec	snd_num_chans_sync		;decrement 0838
		bra	snd_silence_if_not_env		;and silence the channel if envelope not in use
;; ----------------------------------------------------------------------------
;; Pitch setting
snd_check_set_pitch					; LED01
		cmpa	snd_chip_pitch-4,x		;If A=&82C,X then pitch is unchanged
		beq	LECDArts			;then exit via ECDA
snd_set_pitch						; LED06
		sta	snd_chip_pitch-4,x		;store new pitch
		cmpx	#$04				;if X<>4 then not noise so
		bne	snd_pitch_sk_notnoise		;jump to ED16
;; Noise setting					; LED0D
		anda	#$0F				;convert to chip format
		ora	mostbl_sound_params-4,x		;
		pshs	CC				;save flags
		jmp	snd_poke_flags_stacked		;and pass to chip control routine at EB22 via ED95
;; ----------------------------------------------------------------------------
snd_pitch_sk_notnoise				;LED16
		pshs	A				;
		anda	#$03				;
		sta	snd_parm_wksp			;lose eigth tone surplus
		clr	snd_low_parm			;
		puls	A				;get back A
		lsra					;divide by 4 then 12
		lsra					;
1		cmpa	#$0C				;
		blo	2F				;
		inc	snd_low_parm			;store result
		suba	#$0C				;with remainder in A
		bne	1B				;
							;at this point snd_low_parm defines the Octave
							;A the semitone within the octave
2		tfr	A,B				;B=A
		lda	snd_low_parm			;get octave number into A
		pshs	A				;push it
		ldy	#mostbl_Pitch_lookup1
		lda	b,y				;get byte from look up table
		sta	snd_low_parm			;store it
		ldy	#mostbl_Pitch_lookup2
		lda	b,y				;get byte from second table
		pshs	A				;push it
		anda	#$03				;keep two LS bits only
		sta	snd_high_parm			;save them
		puls	A				;pull second table byte
		lsra					;push hi nybble into lo nybble 
		lsra					;
		lsra					;
		lsra					;
		sta	snd_tempx			;store it
		lda	snd_low_parm			;get back octave number
		ldb	snd_parm_wksp			;adjust for surplus eighth tones
		beq	LED5F				;
LED53		suba	snd_tempx			;
		bcc	LED5C				;
		dec	snd_high_parm			;
LED5C		decb					;
		bne	LED53				;
LED5F		sta	snd_low_parm			;
		puls	B				;
		tstb
		beq	LED6F				;
LED66		lsr	snd_high_parm			;
		ror	snd_low_parm			;
		decb					;
		bne	LED66				;
LED6F		lda	snd_low_parm			;
		adda	mostbl_VDU_pixels_per_byte_m1+3,x;	TODO: check this is not a bug!?!
		sta	snd_low_parm			;
		bcc	LED7E				;
		inc	snd_high_parm			;
LED7E		anda	#$0F				;
		ora	mostbl_sound_params-4,x		;
		pshs	CC				;push P
		SEI					;bar interrupts
		jsr	snd_poke_flags			;set up chip access 1
		lda	snd_low_parm			;
		lsr	snd_high_parm			;
		rora					;
		lsr	snd_high_parm			;
		rora					;
		lsra					;
		lsra					;
LED95		jmp	snd_poke_flags_stacked		;set up chip access 2 and return
;; ----------------------------------------------------------------------------
;; Pick up and interpret sound buffer data
snd_get_from_buff					; LED98
		pshs	CC				;push flags
		SEI					;disable interrupts
		jsr	mos_OSBYTE_145			;read a byte from buffer
;;;		;TODO - use BITA? save pushing and pulling?
;;;		pshs	A				;push A
;;;		anda	#$04				;isolate H bit
		bita	#$04
		beq	snd_get_from_buff_notH		;if 0 then EDB7
;;;		puls	A				;get back A
		ldb	snd_env_no-4,x			;if &820,X=&FF
		cmpb	#$FF				;envelope is not in use
		bne	1F				;
		jsr	x_Silence_a_sound_channel	;so call EB03 to silence channel
1		jsr	mos_OSBYTE_145			;clear buffer of redundant data
		jsr	mos_OSBYTE_145			;and again
		puls	CC				;get back flags
		jmp	snd_get_from_buff_setdurrts	;set main duration count using last byte from buffer

snd_get_from_buff_notH					; LEDB7		
;;;		puls	A				;get back A
		anda	#$F8				;zero bits 0-2
		asla					;put bit 7 into carry
		bcc	snd_get_from_buff_env		;if zero ( i.e. was +ve and have envelope) jump to EDC8
		coma					;invert A
		lsra					;shift right
		suba	#$40				;subtract &40
		jsr	snd_set_vol			;and set volume
		lda	#$FF				;A=&FF
snd_get_from_buff_env					;LEDC8
		sta	snd_env_no-4,x			;get envelope no.-1 *16 into A
		lda	#$05				;set duration sub-counter
		sta	snd_duration_mul-4,x		;
		lda	#$01				;set phase counter
		sta	snd_length_left-4,x		;
		lda	#$00				;set step counter
		sta	snd_steps_left-4,x		;
		sta	snd_amplitude_phase_count-4,x	;and envelope phase
		sta	snd_pitch_deviation-4,x		;and pitch differential
		lda	#$FF				;
		sta	snd_pitch_phase_count-4,x	;set step count
		jsr	mos_OSBYTE_145			;read pitch
		sta	snd_abs_pitch-4,x		;set it
		jsr	mos_OSBYTE_145			;read buffer
		puls	CC				;interrupts back on
		pshs	A				;save duration
		lda	snd_abs_pitch-4,x		;get back pitch value
		jsr	snd_check_set_pitch		;and set it
		puls	A				;get back duration
snd_get_from_buff_setdurrts			; LEDF7
		sta	snd_duration_ctr-4,x		;set it
		rts					;and return
;; ----------------------------------------------------------------------------
;; Pitch look up table 1
mostbl_Pitch_lookup1
	FCB	$F0,$B7,$82,$4F,$20,$F3,$C8,$A0 ;	EDFB
	FCB	$7B,$57,$35,$16			;	EE03
;; Pitch look up table 2
mostbl_Pitch_lookup2
	FCB	$E7,$D7,$CB,$C3,$B7,$AA,$A2,$9A ;	EE07
	FCB	$92,$8A,$82,$7A			;	EE0F
;; ----------------------------------------------------------------------------
;; : set current filing system ROM/PHROM
;x_set_current_filing_system_ROM_PHROM:
;	lda	#$EF				;	EE13
;	sta	zp_mos_curPHROM			;	EE15
;	rts					;	EE17
;; ----------------------------------------------------------------------------
;; Get byte from data ROM
;x_Get_byte_from_data_ROM:
;	ldBB	#$0D				;	EE18
;	inc	zp_mos_curPHROM			;	EE1A
;	ldy	zp_mos_curPHROM			;	EE1C
;	bpl	LEE59				;	EE1E
;	ldx	#$00				;	EE20
;	stx	zp_mos_genPTR+1			;	EE22
;	inx					;	EE24
;	stx	zp_mos_genPTR			;	EE25
;	jsr	LEEBB				;	EE27
;	ldx	#$03				;	EE2A
;LEE2C:	jsr	x_PHROM_SERVICE			;	EE2C
;	cmp	copyright_symbol_backwards,x				;	EE2F
;	bne	x_Get_byte_from_data_ROM	;	EE32
;	dex					;	EE34
;	bpl	LEE2C				;	EE35
;	lda	#$3E				;	EE37
;	sta	zp_mos_genPTR			;	EE39
;LEE3B:	jsr	LEEBB				;	EE3B
;	ldx	#$FF				;	EE3E
;LEE40:	jsr	x_PHROM_SERVICE			;	EE40
;	ldy	#$08				;	EE43
;LEE45:	asl	a				;	EE45
;	ror	zp_mos_genPTR+1,x		;	EE46
;	dey					;	EE48
;	bne	LEE45				;	EE49
;	inx					;	EE4B
;	beq	LEE40				;	EE4C
;	clc					;	EE4E
;	bcc	LEEBB				;	EE4F
;; ROM SERVICE
;x_ROM_SERVICE:
;	ldx	#$0E				;	EE51
;	ldy	zp_mos_curPHROM			;	EE53
;	bmi	x_PHROM_SERVICE			;	EE55
;	ldy	#$FF				;	EE57
;LEE59:	php					;	EE59
;	jsr	mos_OSBYTE_143_b_cmd_x_param			;	EE5A
;	plp					;	EE5D
;	cmp	#$01				;	EE5E
;	tya					;	EE60
;	rts					;	EE61
;; ----------------------------------------------------------------------------
;; PHROM SERVICE;  
;x_PHROM_SERVICE:
;	php					;	EE62
;	sei					;	EE63
;	ldy	#$10				;	EE64
;	jsr	mos_OSBYTE_159			;	EE66
;	ldy	#$00				;	EE69
;	beq	LEE84				;	EE6B
;; OSBYTE 158 read from speech processor
;mos_OSBYTE_158:
;	ldy	#$00				;	EE6D
;	beq	LEE82				;	EE6F
;LEE71:	pha					;	EE71
;	jsr	LEE7A				;	EE72
;	pla					;	EE75
;	ror	a				;	EE76
;	ror	a				;	EE77
;	ror	a				;	EE78
;	ror	a				;	EE79
;LEE7A:	and	#$0F				;	EE7A
;	ora	#$40				;	EE7C
;	tay					;	EE7E
;; OSBYTE 159 Write to speech processor; on entry data or command in Y 
;mos_OSBYTE_159:
;	tya					;	EE7F
;	ldy	#$01				;	EE80
;LEE82:	php					;	EE82
;	sei					;	EE83
;LEE84:	bit	sysvar_SPEECH_PRESENT		;	EE84
;	bpl	LEEAA				;	EE87
;	pha					;	EE89
;	lda	LF075,y				;	EE8A
;	sta	sheila_SYSVIA_ddra		;	EE8D
;	pla					;	EE90
;	sta	sheila_SYSVIA_ora_nh		;	EE91
;	lda	LF077,y				;	EE94
;	sta	sheila_SYSVIA_orb		;	EE97
;LEE9A:	bit	sheila_SYSVIA_orb		;	EE9A
;	bmi	LEE9A				;	EE9D
;	lda	sheila_SYSVIA_ora_nh		;	EE9F
;	pha					;	EEA2
;	lda	LF079,y				;	EEA3
;	sta	sheila_SYSVIA_orb		;	EEA6
;	pla					;	EEA9
;LEEAA:	plp					;	EEAA
;	tay					;	EEAB
;	rts					;	EEAC
;; ----------------------------------------------------------------------------
;LEEAD:	lda	$03CB				;	EEAD
;	sta	zp_mos_genPTR			;	EEB0
;	lda	$03CC				;	EEB2
;	sta	zp_mos_genPTR+1			;	EEB5
;	lda	zp_mos_curPHROM			;	EEB7
;	bpl	LEED9				;	EEB9
;LEEBB:	php					;	EEBB
;	sei					;	EEBC
;	lda	zp_mos_genPTR			;	EEBD
;	jsr	LEE71				;	EEBF
;	lda	zp_mos_curPHROM			;	EEC2
;	sta	zp_mos_OS_wksp2			;	EEC4
;	lda	zp_mos_genPTR+1			;	EEC6
;	rol	a				;	EEC8
;	rol	a				;	EEC9
;	lsr	zp_mos_OS_wksp2			;	EECA
;	ror	a				;	EECC
;	lsr	zp_mos_OS_wksp2			;	EECD
;	ror	a				;	EECF
;	jsr	LEE71				;	EED0
;	lda	zp_mos_OS_wksp2			;	EED3
;	jsr	LEE7A				;	EED5
;	plp					;	EED8
;LEED9:	rts					;	EED9
;; ----------------------------------------------------------------------------
;; Keyboard Input and housekeeping; entered from &F00C 
keyb_input_and_housekeeping			; LEEDA
		ldb	#$FF				;
		lda	zp_mos_keynumlast		;get value of most recently pressed key
		ora	zp_mos_keynumfirst		;Or it with previous key to check for presses
		bne	LEEE8				;if A=0 no keys pressed so off you go
		lda	#$81				;else enable keybd interupt only by writing bit 7
		sta	sheila_SYSVIA_ier		;and bit 0 of system VIA interupt register 
		incb					;set X=0
LEEE8		stb	sysvar_KEYB_SEMAPHORE		;reset keyboard semaphore
; : Turn on Keyboard indicators
x_Turn_on_Keyboard_indicators				; LEEEB
		pshs	B,A,CC				;save flags
		lda	sysvar_KEYB_STATUS		;read keyboard status;
							;Bit 7  =1 shift enabled
							;Bit 6  =1 control pressed
							;bit 5  =0 shift lock
							;Bit 4  =0 Caps lock
							;Bit 3  =1 shift pressed    
		lsra					;shift Caps bit into bit 3
		anda	#$18				;mask out all but 4 and 3
		ora	#$06				;returns 6 if caps lock OFF &E if on
		sta	sheila_SYSVIA_orb		;turn on or off caps light if required
		lsra					;bring shift bit into bit 3
		ora	#$07				;
		sta	sheila_SYSVIA_orb		;turn on or off shift  lock light
		jsr	keyb_hw_enable_scan		;set keyboard counter
		clra
		puls	CC				; have some bodgery to do here to make 
							; Entry N=>control, A==8=>shift, CC_C=>C
							; into 6809 A(7) = control, A(6) = shift, A(0) carry on entry
		bcc	1F
		ora	#$01
1		bpl	1F
		ora	#$80
1		
;;;		ldb	#8
;;;		bitb	,S+
		tim	#$08, ,S+
		beq	1F
		ora	#$40
1		puls	B,PC				;get back flags	in A! and return

 *************************************************************************
 *                                                                       *
 * MAIN KEYBOARD HANDLING ROUTINE   ENTRY FROM KEYV                      *
 * ==========================================================            *
 *                                                                       *
 *                       ENTRY CONDITIONS                                *
 *                       ================                                *
 * C=0, V=0 Test Shift and CTRL keys.. exit with N set if CTRL pressed   *
 *                                 ........with V set if Shift pressed   *
 * C=1, V=0 Scan Keyboard as OSBYTE &79                                  *
 * C=0, V=1 Key pressed interrupt entry                                  *
 * C=1, V=1 Timer interrupt entry                                        *
 *                                                                       *
 *************************************************************************

KEYV_default						; LEF02
		bvc	1F				;if V is clear then leave interrupt routine
		lda	#$01				;disable keyboard interrupts
		sta	sheila_SYSVIA_ier		;by writing to VIA interrupt vector
		bcs	KEYV_Timer_interrupt_entry	;if timer interrupt then EF13
		jmp	KEYV_default_keypress_IRQ	;else to F00F

1		bcc	KEYV_test_shift_ctl		;if test SHFT & CTRL goto EF16
		jmp	KEYV_keyboard_scan		;else to F0D1
								;to scan keyboard
; Timer interrupt entry
KEYV_Timer_interrupt_entry
		inc	sysvar_KEYB_SEMAPHORE		;increment keyboard semaphore (to 0)
; Test Shift and Control Keys entry
KEYV_test_shift_ctl
		lda	sysvar_KEYB_STATUS		;read keyboard status;     
							;Bit 7  =1 shift enabled   
							;Bit 6  =1 control pressed 
							;bit 5  =0 shift lock      
							;Bit 4  =0 Caps lock       
							;Bit 3  =1 shift pressed   
		anda	#$B7				;zero bits 3 and 6
		ldb	#0				;zero B to test for shift key press
							;NB: DON'T use CLRB here need to preserve carry
		jsr	keyb_check_key_code_API		;interrogate keyboard X=&80 if key determined by
							;X on entry is pressed 
		stb	zp_mos_OS_wksp2			;save X
		bpl	1F				;if no key press (X=0) then EF2A else
		ora	#$08				;set bit 3 to indicate Shift was pressed
1		incb					;check the control key
		jsr	keyb_check_key_code_API		;via keyboard interrogate
		bcc	x_Turn_on_Keyboard_indicators	;if carry clear (entry via EF16) then off to EEEB
							;to turn on keyboard lights as required
		bpl	1F				;if key not pressed goto EF30
		ora	#$40				;or set CTRL pressed bit in keyboard status byte in A
1		sta	sysvar_KEYB_STATUS		;save status byte
		ldb	zp_mos_keynumlast		;if no key previously pressed
		lbeq	LEFE9				;then EF4D
		jsr	keyb_check_key_code_API		;else check to see if key still pressed
		bmi	x_REPEAT_ACTION			;if so enter repeat routine at EF50
		cmpb	zp_mos_keynumlast		;else compare B with last key pressed (set flags)
LEF42		beq	1F				;DB: slight change as 6809 sets Z on STx
		stb	zp_mos_keynumlast		;store B in last key pressed
		jmp	LEFE9				;if different from previous (Z clear) then EF4D
1		clrb					;else zero 
		stb	zp_mos_keynumlast		;last key pressed 
LEF4A		jsr	keyb_set_autorepeat_countdown	;and reset repeat system
		jmp	LEFE9
;; ----------------------------------------------------------------------------
;; REPEAT ACTION
x_REPEAT_ACTION
		cmpb	zp_mos_keynumlast		;if B<>last key pressed
		bne	LEF42				;then back to EF42
		lda	zp_mos_autorep_countdown	;else get value of AUTO REPEAT COUNTDOWN TIMER
		lbeq	LEFE9				;if 0 goto EF7B
		dec	zp_mos_autorep_countdown	;else decrement
		lbne	LEFE9				;and if not 0 goto EF7B
							;this means that either the repeat system is dormant
							;or it is not at the end of its count
		lda	mosvar_KEYB_AUTOREPEAT_COUNT	;next value for countdown timer
		sta	zp_mos_autorep_countdown	;store it
		lda	sysvar_KEYB_AUTOREP_PERIOD	;get auto repeat rate from 0255
		sta	mosvar_KEYB_AUTOREPEAT_COUNT	;store it as next value for Countdown timer
		lda	sysvar_KEYB_STATUS		;get keyboard status
		ldb	zp_mos_keynumlast		;get last key pressed
		cmpb	#$D0				;if not SHIFT LOCK key (&D0) goto
		bne	LEF7E				;EF7E
		ora	#$90				;sets shift enabled, & no caps lock all else preserved
		eora	#$A0				;reverses shift lock disables Caps lock and Shift enab
LEF74		sta	sysvar_KEYB_STATUS		;reset keyboard status
		clra					;and set timer
		sta	zp_mos_autorep_countdown	;to 0
		bra	LEFE9
	
LEF7E		cmpb	#$C0				;if not CAPS LOCK
		bne	x_get_ASCII_code		;goto EF91
		ora	#$A0				;sets shift enabled and disables SHIFT LOCK
		tst	zp_mos_OS_wksp2			;if bit 7 not set by (EF20) shift NOT pressed
		bpl	LEF8C				;goto EF8C
		ora	#$10				;else set CAPS LOCK not enabled
		eora	#$80				;reverse SHIFT enabled

LEF8C		eora	#$90				;reverse both SHIFT enabled and CAPs Lock
		bra	LEF74				;reset keyboard status and set timer
;; ----------------------------------------------------------------------------
;; get ASCII code; on entry X=key pressed internal number 
x_get_ASCII_code
		ldx	#key2ascii_tab - $10
		andb	#$7F
		lda	B,X				;get code from look up table
		bne	1F				;if not zero goto EF99 else TAB pressed
		lda	sysvar_KEYB_TAB_CHAR		;get TAB character
1		ldb	sysvar_KEYB_STATUS		;get keyboard status
		stb	zp_mos_OS_wksp2			;store it in &FA
		rol	zp_mos_OS_wksp2			;rotate to get CTRL pressed into bit 7
		bpl	LEFA9				;if CTRL NOT pressed EFA9

		ldb	zp_mos_keynumfirst		;get no. of previously pressed key
LEFA4		bne	LEF4A				;if not 0 goto EF4A to reset repeat system etc.
		jsr	x_Implement_CTRL_codes		;else perform code changes for CTRL

LEFA9		rol	zp_mos_OS_wksp2			;move shift lock into bit 7
LEFAB		bmi	LEFB5				;if not effective goto EFB5 else
		jsr	x_Modify_code_as_if_SHIFT	;make code changes for SHIFT

		rol	zp_mos_OS_wksp2			;move CAPS LOCK into bit 7
		bra	LEFC1				;and Jump to EFC1

LEFB5		rol	zp_mos_OS_wksp2			;move CAPS LOCK into bit 7
		bmi	LEFC6				;if not effective goto EFC6
		jsr	mos_CHECK_FOR_ALPHA_CHARACTER	;else make changes for CAPS LOCK on, return with 
							;C clear for Alphabetic codes
		bcs	LEFC6				;if carry set goto EFC6 else make changes for
		jsr	x_Modify_code_as_if_SHIFT	;SHIFT as above

LEFC1		ldb	sysvar_KEYB_STATUS		;if shift enabled bit is clear
		bpl	LEFD1				;goto EFD1
LEFC6		rol	zp_mos_OS_wksp2			;else get shift bit into 7
		bpl	LEFD1				;if not set goto EFD1
		ldb	zp_mos_keynumfirst		;get previous key press
		bne	LEFA4				;if not 0 reset repeat system etc. via EFA4
		jsr	x_Modify_code_as_if_SHIFT	;else make code changes for SHIFT
LEFD1		cmpa	sysvar_KEYB_ESC_CHAR		;if A<> ESCAPE code 
		bne	LEFDD				;goto EFDD
		ldb	sysvar_KEYB_ESC_ACTION		;get Escape key status
		bne	LEFDD				;if ESCAPE returns ASCII code goto EFDD
		stb	zp_mos_autorep_countdown	;store in Auto repeat countdown timer

LEFDD		m_tay					

		jsr	keyb_enable_scan_IRQonoff	;disable keyboard
		lda	sysvar_KEYB_DISABLE		;read Keyboard disable flag used by Econet 
		bne	LEFE9				;if keyboard locked goto EFE9
		jsr	x_INSERT_byte_in_Keyboard_buffer;put character in input buffer
LEFE9		ldb	zp_mos_keynumfirst		;get previous keypress
		beq	LEFF8				;if none  EFF8
		jsr	keyb_check_key_code_API		;examine to see if key still pressed
		stb	zp_mos_keynumfirst		;store result
		bmi	LEFF8				;if pressed goto EFF8
		clr	zp_mos_keynumfirst		;and &ED

LEFF8		ldb	zp_mos_keynumfirst		;get &ED
		bne	LF012				;if not 0 goto F012
		ldy	#zp_mos_keynumlast		;get first keypress into Y (DB: last!)
		jsr	clc_then_mos_OSBYTE_122		;scan keyboard from &10 (osbyte 122)
		m_txb

		bmi	LF00C				;if exit is negative goto F00C
		lda	zp_mos_keynumlast		;else make last key the
		sta	zp_mos_keynumfirst		;first key pressed i.e. rollover

LF007		stb	zp_mos_keynumlast		;save X into &EC
		jsr	keyb_set_autorepeat_countdown	;set keyboard repeat delay
LF00C		jmp	keyb_input_and_housekeeping	;go back to EEDA
;; ----------------------------------------------------------------------------
;; Key pressed interrupt entry point; enters with X=key 
KEYV_default_keypress_IRQ				; LF00F
		clrb				; DB ??? not sure what is what here on BeebEm always seems to be X=0 here!
		jsr	keyb_check_key_code_API		;check if key pressed
LF012		lda	zp_mos_keynumlast		;get previous key press
		bne	LF00C				;if none back to housekeeping routine
		ldy	#$ED				;get last keypress into Y
		jsr	clc_then_mos_OSBYTE_122		;and scan keyboard
		bmi	LF00C				;if negative on exit back to housekeeping
		m_txb
		bra	LF007				;else back to store X and reset keyboard delay etc.
;; Set Autorepeat countdown timer
keyb_set_autorepeat_countdown
		ldb	#$01				;set timer to 1
		stb	zp_mos_autorep_countdown	;
		ldb	sysvar_KEYB_AUTOREP_DELAY	;get next timer value
		stb	mosvar_KEYB_AUTOREPEAT_COUNT	;and store it
		rts					;
;; ----------------------------------------------------------------------------
;; Interrogate Keyboard routine;
	; NOTE: API change B now contains key code to scan, A is preserved
	; NB: needs to preserve carry!
keyb_check_key_code_API
	pshs	A
	lda	#$03				;stop Auto scan
	sta	sheila_SYSVIA_orb		;by writing to system VIA
	lda	#$7F				;set bits 0 to 6 of port A to input on bit 7
						;output on bits 0 to 6
	sta	sheila_SYSVIA_ddra		;
	stb	sheila_SYSVIA_ora_nh		;write X to Port A system VIA
	ldb	sheila_SYSVIA_ora_nh		;read back &80 if key pressed (M set)
	puls	A,PC				;and return
;; ----------------------------------------------------------------------------

*************************************************************************
 *                                                                       *
 *       KEY TRANSLATION TABLES                                          *
 *                                                                       *
 *       7 BLOCKS interspersed with unrelated code                       *
 *************************************************************************
                                         
 *key data block 1
key2ascii_tab					; LF03B
	FCB	$71,$33,$34,$35,$84,$38,$87,$2D,$5E,$8C
	;	 q , 3 , 4 , 5 , f4, 8 , f7, - , ^ , <-

	RMB	6	; TODO - spare gap in key2ascii map

*key data block 2
 
LF04B	FCB	$80,$77,$65,$74,$37,$69,$39,$30,$5F,$8E
	;	 f0, w , e , t , 7 , i , 9 , 0 , _ ,lft

	RMB	6	; TODO - spare gap in key2ascii map

 *key data block 3
 
LF05B	FCB	$31,$32,$64,$72,$36,$75,$6F,$70,$5B,$8F
	;	 1 , 2 , d , r , 6 , u , o , p , [ , dn

	RMB	6	; TODO - spare gap in key2ascii map

*key data block 4
 
LF06B	FCB	$01,$61,$78,$66,$79,$6A,$6B,$40,$3A,$0D
	;	 CL, a , x , f , y , j , k , @ , : ,RET		N.B CL=CAPS LOCK

*speech routine data
LF075	FCB	$00,$FF,$01,$02,$09,$0A

*key data block 5

F07B	FCB	$02,$73,$63,$67,$68,$6E,$6C,$3B,$5D,$7F
	;	 SL, s , c , g , h , n , l , ; , ] ,DEL		N.B. SL=SHIFT LOCK

	RMB	6	; TODO - spare gap in key2ascii map

 *key data block 6
 
F08B	FCB	$00,$7A,$20,$76,$62,$6D,$2C,$2E,$2F,$8B
	;	TAB, Z ,SPC, v , b , m , , , . , / ,CPY

	RMB	6	; TODO - spare gap in key2ascii map

*key data block 7
F09B	FCB	$1B,$81,$82,$83,$85,$86,$88,$89,$5C,$8D
	;	ESC, f1, f2, f3, f5, f6, f8, f9, \ , ->



;; 7 BLOCKS interspersed with unrelated code
;mos_7_BLOCKS_interspersed_with_unrelated_code:
;	adc	(zp_lang+51),y			;	F03B
;	FCB	$34				;	F03D
;	and	zp_lang+132,x			;	F03E
;	sec					;	F040
;	FCB	$87				;	F041
;	and	$8C5E				;	F042
;; OSBYTE 120  Write KEY pressed Data
;mos_OSBYTE_120:
;	sty	zp_mos_keynumlast		;	F045
;	stx	zp_mos_keynumfirst		;	F047
;	rts					;	F049
;; ----------------------------------------------------------------------------
;	brk					;	F04A
;	FCB	$80				;	F04B
;	FCB	$77				;	F04C
;	adc	zp_lang+116			;	F04D
;	FCB	$37				;	F04F
;	adc	#$39				;	F050
;	bmi	LF0B3				;	F052
;	FCB	$8E				;	F054
;;;LF055:	jmp	(LFDFE)				;	was used in startup sequence if bit 6 of keyboard links is set now deos this in line!
;; ----------------------------------------------------------------------------
;LF058:	jmp	(zp_mos_OS_wksp2)		;	F058
;; ----------------------------------------------------------------------------
;	and	(zp_lang+50),y			;	F05B
;	FCB	$64				;	F05D
;	FCB	$72				;	F05E
;	rol	zp_lang+117,x			;	F05F
;	FCB	$6F				;	F061
;	bvs	LF0BF				;	F062
;	FCB	$8F				;	F064
;; Main entry to keyboard routines
mos_enter_keyboard_routines
	orcc	#CC_V+CC_N			;set V and M
jmpKEYV	
	jmp	[KEYV]
;; ----------------------------------------------------------------------------
;	ora	(zp_lang+97,x)			;	F06B
;	sei					;	F06D
;	ror	zp_lang+121			;	F06E
;	ror	a				;	F070
;	FCB	$6B				;	F071
;	rti					;	F072
;; ----------------------------------------------------------------------------
;	FCB	$3A				;	F073
;	FCB	$0D				;	F074
;LF075:	brk					;	F075
;	FCB	$FF				;	F076
;LF077:	ora	(zp_lang+2,x)			;	F077
;LF079:	ora	#$0A				;	F079
;	FCB	$02				;	F07B
;	FCB	$73				;	F07C
;	FCB	$63				;	F07D
;	FCB	$67				;	F07E
;	pla					;	F07F
;	ror	$3B6C				;	F080
;	FCB	$5D				;	F083
;	FCB	$7F				;	F084
;; OSBYTE 131  READ OSHWM  (PAGE in BASIC)
mos_OSBYTE_131
	lda	sysvar_CUR_OSHWM		;	F085
	clrb
	m_tay
	tfr	D,X
	rts					;	F08A
;; ----------------------------------------------------------------------------
;	brk					;	F08B
;	FCB	$7A				;	F08C
;	jsr	L6276				;	F08D
;	adc	$2E2C				;	F090
;	FCB	$2F				;	F093
;	FCB	$8B				;	F094
;; set input buffer number and flush it
x_set_input_buffer_number_and_flush_it
	ldx	sysvar_CURINSTREAM		;	F095
LF098	jmp	x_Buffer_handling		;	F098
;; ----------------------------------------------------------------------------
;	FCB	$1B				;	F09B
;	sta	(zp_lang+130,x)			;	F09C
;	FCB	$83				;	F09E
;	sta	zp_lang+134			;	F09F
;	dey					;	F0A1
;	FCB	$89				;	F0A2
;	FCB	$5C				;	F0A3
;	FCB	$8D				;	F0A4
;; jsr from code!;LF0A5:	jmp	(EVNTV)				;	F0A5

*************************************************************************
*                                                                       *
*       OSBYTE 15  FLUSH SELECTED BUFFER CLASS                          *
*                                                                       *
*                                                                       *
*************************************************************************

                        ;flush selected buffer
                        ;X=0 flush all buffers
                        ;X>1 flush input buffer


mos_OSBYTE_15						; LF0A8
	bne	x_set_input_buffer_number_and_flush_it;if X<>1 flush input buffer only
mos_flush_all_buffers					; LF0AA
	ldx	#$08				;else load highest buffer number (8)
1	CLI					;allow interrupts 
	SEI					;briefly!
	jsr	mos_OSBYTE_21			;flush buffer
	leax	-1,X				;decrement X to point at next buffer
	cmpx	#$FFFF
	bne	1B
;; OSBYTE 21  FLUSH SPECIFIC BUFFER; on entry X=buffer number 
mos_OSBYTE_21
	cmpx	#$09				;	F0B4
	blo	LF098				;	F0B6
	rts					;	F0B8
;; ----------------------------------------------------------------------------
;; Issue *HELP to ROMS
mos_STAR_HELP
	ldb	#SERVICE_9_HELP			;	F0B9
	jsr	mos_OSBYTE_143_b_cmd_x_param			;	F0BB
	jsr	mos_PRTEXT
	FCB	$0D, "OS 1.09", $0D,0
	rts					;	F0CB
;; ----------------------------------------------------------------------------
;; OSBYTE 122  KEYBOARD SCAN FROM &10 (16);  
clc_then_mos_OSBYTE_122
		CLC					; clear carry to fall through without doing KEYV
mos_OSBYTE_122						; LF0CD
		ldx	#$10				; lowest key to scan (Q)
;; OSBYTE 121  KEYBOARD SCAN FROM VALUE IN X
mos_OSBYTE_121
		bcs	jmpKEYV				;if carry set (by osbyte 121) F068
							;JMPs via KEYV and hence return from osbyte
							;however KEYV will return here... 

 *************************************************************************
 *        Scan Keyboard C=1, V=0 entry via KEYV (or from CLC above)      *
 *************************************************************************

KEYV_keyboard_scan
		m_txa					;if X is +ve goto F0D9
		bpl	LF0D9				;
		tfr	A,B
		jsr	keyb_check_key_code_API		;else interrogate keyboard
LF0D7		bcs	keyb_hw_enable_scan		;if carry set F12E to set Auto scan else
LF0D9		pshs	CC				;push flags
		bcc	LF0DE				;if carry clear goto FODE 
							;else (keep Y passed in to clc_then_mos_OSBYTE_122)
		ldy	#$EE				;set Y so next operation saves to 2cd
LF0DE		sta	mosvar_KEYB_TWOKEY_ROLLOVER-zp_mos_keynumlast,y
							;can be: 	2cb (mosvar_KEYB_TWOKEY_ROLLOVER)
							;	,	2cc (+1)
							;	or 	2cd (+2)
		ldb	#$09				;set X to 9
LF0E3		jsr	keyb_enable_scan_IRQonoff	;select auto scan 
		lda	#$7F				;set port A for input on bit 7 others outputs
		sta	sheila_SYSVIA_ddra		;
		lda	#$03				;stop auto scan
		sta	sheila_SYSVIA_orb		;
		lda	#$0F				;select non-existent keyboard column F (0-9 only!)
		sta	sheila_SYSVIA_ora_nh		;
		lda	#$01				;cancel keyboard interrupt
		sta	sheila_SYSVIA_ifr		;
		stb	sheila_SYSVIA_ora_nh		;select column X (9 max)
		bita	sheila_SYSVIA_ifr		;if bit 1 =0 there is no keyboard interrupt so
		beq	LF123				;goto F123
		tfr	B,A				;else put column address in A
LF103		cmpa	mosvar_KEYB_TWOKEY_ROLLOVER-zp_mos_keynumlast,y	;compare with 1DF+Y
		blo	LF11E				;if less then F11E
		sta	sheila_SYSVIA_ora_nh		;else select column again 
		tst	sheila_SYSVIA_ora_nh		;and if bit 7 is 0
		bpl	LF11E				;then F11E
		puls	CC				;else push and pull flags
		pshs	CC				;
		bcs	LF127				;and if carry set goto F127
		pshs	A				;else Push A
		eora	,y				;EOR with EC,ED, or EE depending on Y value
		asla					;shift left  
		cmpa	#$01				;clear? carry if = or greater than number holds EC,ED,EE
		puls	A				;get back A
		bcc	LF127				;if carry set F127
LF11E		adda	#$10				;add 16
		bpl	LF103				;and do it again if 0=<result<128

LF123		decb					;decrement X
		bpl	LF0E3				;scan again if greater than 0
		tfr	b,a				;
LF127		m_tax_se				;
		puls	CC				;pull flags
keyb_enable_scan_IRQonoff			; LF129
		jsr	keyb_hw_enable_scan		;call autoscan
		CLI					;allow interrupts 
		SEI					;disable interrupts
;; Enable counter scan of keyboard columns; called from &EEFD, &F129 
	
keyb_hw_enable_scan
		stb	,-S				; store B on stack
		lda	#$0B				;	F12E
		sta	sheila_SYSVIA_orb		;	F130
		puls	A,PC				; return with B in A
;; ----------------------------------------------------------------------------
;; selects ROM filing system
;mos_selects_ROM_filing_system:
;	eor	#$8C				;	F135
;LF137:	asl	a				;	F137
;	sta	sysvar_CFSRFS_SWITCH		;	F138
;	cpx	#$03				;	F13B
;	jmp	LF14B				;	F13D
;; ----------------------------------------------------------------------------
;; set cassette options; called after BREAK etc ; lower nybble sets sequential access ; upper sets load and save options ; 0000	 Ignore errors,		 no messages ; 0001   Abort if error,	      no messages ; 0010   Retry after error,	   no messages ; 
;x_set_cassette_options:
;	php					;	F140
;	lda	#$A1				;	F141
;	sta	zp_cfs_w+1			;	F143
;	lda	#$19				;	F145
;	sta	$03D1				;	F147
;	plp					;	F14A
;LF14B:	php					;	F14B
;	lda	#$06				;	F14C
;	jsr	mos_jmp_FSCV				;	F14E
;	ldx	#$06				;	F151
;	plp					;	F153
;	beq	LF157				;	F154
;	dex					;	F156
;LF157:	stx	zp_fs_w+6			;	F157
;	ldx	#$0E				;	F159
;LF15B:	lda	vec_table+17,x			;	F15B
;	sta	$0211,x				;	F15E
;	dex					;	F161
;	bne	LF15B				;	F162
;	stx	zp_fs_w+2			;	F164
;	ldx	#$0F				;	F166

mos_OSBYTE_143
	; b == original X, put Y (param) in X
	tfr	Y,X
	jsr	mos_OSBYTE_143_b_cmd_x_param
	tfr	X,Y
	rts


mos_OSBYTE_143_b_cmd_x_param
	lda	zp_mos_curROM			; get current Rom number
	sta	,-S				; store it on stack along with command # (passed in B)
	tfr	B,A				; service call # in A
	ldb	#$0F				; set X=15
LF16E	ldy	#oswksp_ROMTYPE_TAB		
	tst	B,Y				; read bit 7 on rom map (no rom has type 254 &FE)
	bpl	1F				; skip if bit 7 not set (no service entry)
	stb	zp_mos_curROM			; switch in paged ROM
	stb	SHEILA_ROMCTL_SWR
	jsr	$8003				; call service routine
	tsta					; check to see if A is reset
	beq	2F				; if it is do no more roms
	ldb	zp_mos_curROM			; get current rom #
1	decb					; decrement
	bpl	LF16E				; go again?
2	ldb	,S+				; get back original rom #
	stb	zp_mos_curROM			; switch in paged ROM
	stb	SHEILA_ROMCTL_SWR
	tsta					; set Z if A=0
	rts					; return result still in A, B corrupted (original low byte of X)




;; ----------------------------------------------------------------------------
;; start of data for save, 0E EndFDBess /attributes
;mos_start_of_data_for_save:
;	ora	#$00				;	F18E
;	bne	LF1A2				;	F190
;	cpy	#$00				;	F192
;	bne	LF1A2				;	F194
;	lda	zp_fs_w+6			;	F196
;	and	#$FB				;	F198
;	ora	sysvar_CFSRFS_SWITCH		;	F19A
;	asl	a				;	F19D
;	ora	sysvar_CFSRFS_SWITCH		;	F19E
;	lsr	a				;	F1A1
;LF1A2:	rts					;	F1A2
;; ----------------------------------------------------------------------------
;; FSC	  VECTOR  TABLE
mos_FSC_VECTOR_TABLE
	FDB	mos_FSCV_OPT			; *OPT          (F54C)  
	FDB	mos_FSCV_EOF			; check EOF     (F61D)
	FDB	mos_FSCV_RUN			; */            (F304)
	FDB	x_Bad_command_error		; Bad Command   (E30F) if roms and FS don't want it 
	FDB	mos_FSCV_RUN			; *RUN          (F304)
	FDB	mos_FSCV_CAT			; *CAT          (F32A)
	FDB	mos_CLOSE_SPOOL_EXEC		; osbyte 77     (E274)

;; A= index 0 to 7;
; on entry A is reason code 
; A=0    A *OPT command has been used X & Y are the 2 parameters 
; A=1    EOF is being checked, on entry  X=File handle  
; A=2    A */ command has been used *RUN the file 
; A=3    An unrecognised OS command has ben used X,Y point at command
; A=4    A *RUN command has been used X,Y point at filename
; A=5    A *CAT cammand has been issued X,Y point to rest of command
; A=6    New filing system about to take over close *SPOOL &*EXEC files
; A=7    Return in X and Y lowest and highest file handle used   
; A=8    OS about to process *command

mos_FSCV_default_handler
	cmpa	#$07				; if >= 7
	bhs	1F				; POH
	stx	zp_fs_s+12			;	F1B5
	asla					;	F1B7
	ldx	#mos_FSC_VECTOR_TABLE
	jmp	[A,X]
1	rts					;	F1C3
;; ----------------------------------------------------------------------------
;; LOAD FILE
;mos_LOAD_FILE:
;	php					;	F1C4
;	pha					;	F1C5
;	jsr	mos_claim_serial_system_for_cass;	F1C6
;	lda	L03C2				;	F1C9
;	pha					;	F1CC
;	jsr	LF631				;	F1CD
;	pla					;	F1D0
;	beq	LF1ED				;	F1D1
;	ldx	#$03				;	F1D3
;	lda	#$FF				;	F1D5
;LF1D7:	pha					;	F1D7
;	lda	$03BE,x				;	F1D8
;	sta	zp_fs_s,x			;	F1DB
;	pla					;	F1DD
;	and	zp_fs_s,x			;	F1DE
;	dex					;	F1E0
;	bpl	LF1D7				;	F1E1
;	cmp	#$FF				;	F1E3
;	bne	LF1ED				;	F1E5
;	jsr	x_sound_bell_reset_ACIA_motor_off;	F1E7
;	jmp	brkBadAddress				;	F1EA
;; ----------------------------------------------------------------------------
;LF1ED:	lda	$03CA				;	F1ED
;	lsr	a				;	F1F0
;	pla					;	F1F1
;	beq	LF202				;	F1F2
;	bcc	LF209				;	F1F4
;; LOCKED FILE ROUTINE
;x_LOCKED_FILE_ROUTINE:
;	jsr	LFAF2				;	F1F6
;	brk					;	F1F9
;	FCB	$D5				;	F1FA
;	FCB	"Locked"			;	F1FB
;	FCB	$00				;	F201
;; ----------------------------------------------------------------------------
;LF202:	bcc	LF209				;	F202
;	lda	#$03				;	F204
;	sta	sysvar_BREAK_EFFECT		;	F206
;LF209:	lda	#$30				;	F209
;	and	zp_fs_s+11			;	F20B
;	beq	LF213				;	F20D
;	lda	zp_fs_w+1			;	F20F
;	bne	LF21D				;	F211
;LF213:	tya					;	F213
;	pha					;	F214
;	jsr	x_read_from_second_processor	;	F215
;	pla					;	F218
;	tay					;	F219
;	jsr	LF7D5				;	F21A
;LF21D:	jsr	x_LOAD				;	F21D
;	bne	x_RETRY_AFTER_A_FAILURE_ROUTINE ;	F220
;	jsr	LFB69				;	F222
;	bit	$03CA				;	F225
;	bmi	x_store_data_in_OSFILE_parameter_block;	F228
;	jsr	x_increment_current_loadFDBess;	F22A
;	jsr	LF77B				;	F22D
;	bne	LF209				;	F230
;; store data in OSFILE parameter block
;x_store_data_in_OSFILE_parameter_block:
;	ldy	#$0A				;	F232
;	lda	zp_fs_w+12			;	F234
;	sta	(zp_fs_w+8),y			;	F236
;	iny					;	F238
;	lda	zp_fs_w+13			;	F239
;	sta	(zp_fs_w+8),y			;	F23B
;	lda	#$00				;	F23D
;	iny					;	F23F
;	sta	(zp_fs_w+8),y			;	F240
;	iny					;	F242
;	sta	(zp_fs_w+8),y			;	F243
;	plp					;	F245
;LF246:	jsr	x_sound_bell_reset_ACIA_motor_off;	F246
;LF249:	bit	zp_fs_s+10			;	F249
;	bmi	LF254				;	F24B
;LF24D:	php					;	F24D
;	jsr	LFA46				;	F24E
;	ora	$2800				;	F251
;LF254:	rts					;	F254
;; ----------------------------------------------------------------------------
;; RETRY AFTER A FAILURE ROUTINE
;x_RETRY_AFTER_A_FAILURE_ROUTINE:
;	jsr	LF637				;	F255
;	bne	LF209				;	F258
;; Read Filename using Command Line Interpreter; filename pointed to by X and Y 
;x_Read_Filename_using_Command_Line_Interpreter:
;	stx	zp_mos_txtptr			;	F25A
;	sty	zp_mos_txtptr+1			;	F25C
;	ldy	#$00				;	F25E
;	jsr	mos_CLC_GSINIT;	F260
;	ldx	#$00				;	F263
;LF265:	jsr	mos_GSREAD;	F265
;	bcs	x_terminate_Filename		;	F268
;	beq	LF274				;	F26A
;	sta	$03D2,x				;	F26C
;	inx					;	F26F
;	cpx	#$0B				;	F270
;	bne	LF265				;	F272
;LF274:	jmp	brkBadString				;	F274
;; ----------------------------------------------------------------------------
;; terminate Filename
;x_terminate_Filename:
;	lda	#$00				;	F277
;	sta	$03D2,x				;	F279
;	rts					;	F27C
;; ----------------------------------------------------------------------------
;; OSFILE ENTRY; parameter block located by XY ; 0/1    Address of Filename terminated by &0D ; 2/4    Load Address of File ; 6/9    Execution Address of File ; A/D    StartFDBess of data for write operations or length of file ; for read operations ; E/11 
;mos_OSFILE_ENTRY:
;	pha					;	F27D
;	stx	zp_fs_w+8			;	F27E
;	sty	zp_fs_w+9			;	F280
;	ldy	#$00				;	F282
;	lda	(zp_fs_w+8),y			;	F284
;	tax					;	F286
;	iny					;	F287
;	lda	(zp_fs_w+8),y			;	F288
;	tay					;	F28A
;	jsr	x_Read_Filename_using_Command_Line_Interpreter;	F28B
;	ldy	#$02				;	F28E
;LF290:	lda	(zp_fs_w+8),y			;	F290
;	sta	$03BC,y				;	F292
;	sta	$AE,y				;	F295
;	iny					;	F298
;	cpy	#$0A				;	F299
;	bne	LF290				;	F29B
;	pla					;	F29D
;	beq	x_Save_a_file			;	F29E
;	cmp	#$FF				;	F2A0
;	bne	LF254				;	F2A2
;	jmp	mos_LOAD_FILE			;	F2A4
;; ----------------------------------------------------------------------------
;; Save a file
;x_Save_a_file:
;	sta	$03C6				;	F2A7
;	sta	$03C7				;	F2AA
;LF2AD:	lda	(zp_fs_w+8),y			;	F2AD
;	sta	zp_nmi+6,y			;	F2AF
;	iny					;	F2B2
;	cpy	#$12				;	F2B3
;	bne	LF2AD				;	F2B5
;	txa					;	F2B7
;	beq	LF274				;	F2B8
;	jsr	mos_claim_serial_system_for_cass;	F2BA
;	jsr	x_print_prompt_for_SAVE_on_TAPE ;	F2BD
;	lda	#$00				;	F2C0
;	jsr	LFBBD				;	F2C2
;	jsr	x_control_ACIA_and_Motor	;	F2C5
;LF2C8:	sec					;	F2C8
;	ldx	#$FD				;	F2C9
;LF2CB:	lda	VETABFDB,x			;	F2CB
;	sbc	LFFB3,x				;	F2CE
;	sta	mosvar_KEYB_TWOKEY_ROLLOVER,x	;	F2D1
;	inx					;	F2D4
;	bne	LF2CB				;	F2D5
;	tay					;	F2D7
;	bne	LF2E8				;	F2D8
;	cpx	$03C8				;	F2DA
;	lda	#$01				;	F2DD
;	sbc	$03C9				;	F2DF
;	bcc	LF2E8				;	F2E2
;	ldx	#$80				;	F2E4
;	bne	LF2F0				;	F2E6
;LF2E8:	lda	#$01				;	F2E8
;	sta	$03C9				;	F2EA
;	stx	$03C8				;	F2ED
;LF2F0:	stx	$03CA				;	F2F0
;	jsr	x_SAVE_A_BLOCK			;	F2F3
;	bmi	LF341				;	F2F6
;	jsr	x_increment_current_loadFDBess;	F2F8
;	inc	$03C6				;	F2FB
;	bne	LF2C8				;	F2FE
;	inc	$03C7				;	F300
;	bne	LF2C8				;	F303
;; *RUN	  ENTRY
mos_FSCV_RUN
	TODO	"mos_FSCV_RUN"
;	jsr	x_Read_Filename_using_Command_Line_Interpreter;	F305
;	ldx	#$FF				;	F308
;	stx	L03C2				;	F30A
;	jsr	mos_LOAD_FILE			;	F30D
;	bit	sysvar_TUBE_PRESENT		;	F310
;	bpl	LF31F				;	F313
;	lda	$03C4				;	F315
;	and	$03C5				;	F318
;	cmp	#$FF				;	F31B
;	bne	LF322				;	F31D
;LF31F:	jmp	(L03C2)				;	F31F
;; ----------------------------------------------------------------------------
;LF322:	ldx	#$C2				;	F322
;	ldy	#$03				;	F324
;	lda	#$04				;	F326
;	jmp	LFBC7				;	F328
;; ----------------------------------------------------------------------------
;; *CAT	  ENTRY; CASSETTE OPTIONS in &E2 ; bit 0  input file open ; bit 1  output file open ; bit 2,4,5	 not used ; bit 3  current CATalogue status ; bit 6  EOF reached ; bit 7  EOF warning given 
mos_FSCV_CAT
	TODO	"mos_FSCV_CAT"
;	lda	#$08				;	F32B
;	jsr	LF344				;	F32D
;	jsr	mos_claim_serial_system_for_cass;	F330
;	lda	#$00				;	F333
;	jsr	x_search_routine		;	F335
;	jsr	LFAFC				;	F338
;LF33B:	lda	#$F7				;	F33B
;LF33D:	and	zp_cfs_w			;	F33D
;LF33F:	sta	zp_cfs_w			;	F33F
;LF341:	rts					;	F341
;; ----------------------------------------------------------------------------
;LF342:	lda	#$40				;	F342
;LF344:	ora	zp_cfs_w			;	F344
;	bne	LF33F				;	F346
;; search routine
;x_search_routine:
;	pha					;	F348
;	lda	sysvar_CFSRFS_SWITCH		;	F349
;	beq	x_cassette_routine		;	F34C
;	jsr	x_set_current_filing_system_ROM_PHROM;	F34E
;	jsr	x_Get_byte_from_data_ROM	;	F351
;	bcc	x_cassette_routine		;	F354
;	clv					;	F356
;	bvc	LF39A				;	F357
;; cassette routine
;x_cassette_routine:
;	jsr	LF77B				;	F359
;	lda	$03C6				;	F35C
;	sta	zp_fs_s+4			;	F35F
;	lda	$03C7				;	F361
;	sta	zp_fs_s+5			;	F364
;	ldx	#$FF				;	F366
;	stx	$03DF				;	F368
;	inx					;	F36B
;	stx	zp_fs_s+10			;	F36C
;	beq	LF376				;	F36E
;LF370:	jsr	LFB69				;	F370
;	jsr	LF77B				;	F373
;LF376:	lda	sysvar_CFSRFS_SWITCH		;	F376
;	beq	LF37D				;	F379
;	bvc	LF39A				;	F37B
;LF37D:	pla					;	F37D
;	pha					;	F37E
;	beq	LF3AE				;	F37F
;	jsr	x_compare_filenames		;	F381
;	bne	LF39C				;	F384
;	lda	#$30				;	F386
;	and	zp_fs_s+11			;	F388
;	beq	LF39A				;	F38A
;	lda	$03C6				;	F38C
;	cmp	zp_fs_s+6			;	F38F
;	bne	LF39C				;	F391
;	lda	$03C7				;	F393
;	cmp	zp_fs_s+7			;	F396
;	bne	LF39C				;	F398
;LF39A:	pla					;	F39A
;	rts					;	F39B
;; ----------------------------------------------------------------------------
;LF39C:	lda	sysvar_CFSRFS_SWITCH		;	F39C
;	beq	LF3AE				;	F39F
;LF3A1:	jsr	LEEAD				;	F3A1
;LF3A4:	lda	#$FF				;	F3A4
;	sta	$03C6				;	F3A6
;	sta	$03C7				;	F3A9
;	bne	LF370				;	F3AC
;LF3AE:	bvc	LF3B5				;	F3AE
;	lda	#$FF				;	F3B0
;	jsr	LF7D7				;	F3B2
;LF3B5:	ldx	#$00				;	F3B5
;	jsr	LF9D9				;	F3B7
;	lda	sysvar_CFSRFS_SWITCH		;	F3BA
;	beq	LF3C3				;	F3BD
;	bit	zp_fs_s+11			;	F3BF
;	bvc	LF3A1				;	F3C1
;LF3C3:	bit	$03CA				;	F3C3
;	bmi	LF3A4				;	F3C6
;	bpl	LF370				;	F3C8
;; file handling; on entry A determines Action Y may contain file handle or  ; X/Y point to filename terminated by &0D in memory ; A=0	 closes file in channel Y if Y=0 closes all files ; A=&40  open a file for input  (reading) X/Y points to filename ; A=&8
mos_FINDV_default_handler
	TODOSKIP "mos_FINDV_default_handler"
	rts
;	sta	zp_fs_s+12			;	F3CA
;	txa					;	F3CC
;	pha					;	F3CD
;	tya					;	F3CE
;	pha					;	F3CF
;	lda	zp_fs_s+12			;	F3D0
;	bne	x_OPEN_A_FILE			;	F3D2
;; close a file
;x_close_a_file:
;	tya					;	F3D4
;	bne	LF3E3				;	F3D5
;	jsr	mos_CLOSE_SPOOL_EXEC		;	F3D7
;	jsr	LF478				;	F3DA
;LF3DD:	lsr	zp_cfs_w			;	F3DD
;	asl	zp_cfs_w			;	F3DF
;	bcc	LF3EF				;	F3E1
;LF3E3:	lsr	a				;	F3E3
;	bcs	LF3DD				;	F3E4
;	lsr	a				;	F3E6
;	bcs	LF3EC				;	F3E7
;	jmp	LFBB1				;	F3E9
;; ----------------------------------------------------------------------------
;LF3EC:	jsr	LF478				;	F3EC
;LF3EF:	jmp	LF471				;	F3EF
;; ----------------------------------------------------------------------------
;; OPEN A FILE
;x_OPEN_A_FILE:
;	jsr	x_Read_Filename_using_Command_Line_Interpreter;	F3F2
;	bit	zp_fs_s+12			;	F3F5
;	bvc	x_open_an_output_file		;	F3F7
;; Input files +
;x_Input_files:
;	lda	#$00				;	F3F9
;	sta	$039E				;	F3FB
;	sta	$03DD				;	F3FE
;	sta	$03DE				;	F401
;	lda	#$3E				;	F404
;	jsr	LF33D				;	F406
;	jsr	mos_Claim_serial_system_for_sequential_Access;	F409
;	php					;	F40C
;	jsr	LF631				;	F40D
;	jsr	LF6B4				;	F410
;	plp					;	F413
;	ldx	#$FF				;	F414
;LF416:	inx					;	F416
;	lda	$03B2,x				;	F417
;	sta	$03A7,x				;	F41A
;	bne	LF416				;	F41D
;	lda	#$01				;	F41F
;	jsr	LF344				;	F421
;	lda	cfsrfs_BLK_SIZE			;	F424
;	ora	cfsrfs_BLK_SIZE+1		;	F427
;	bne	LF42F				;	F42A
;	jsr	LF342				;	F42C
;LF42F:	lda	#$01				;	F42F
;	ora	sysvar_CFSRFS_SWITCH		;	F431
;	bne	LF46F				;	F434
;; open an output file
;x_open_an_output_file:
;	txa					;	F436
;	bne	LF43C				;	F437
;	jmp	brkBadString				;	F439
;; ----------------------------------------------------------------------------
;LF43C:	ldx	#$FF				;	F43C
;LF43E:	inx					;	F43E
;	lda	$03D2,x				;	F43F
;	sta	$0380,x				;	F442
;	bne	LF43E				;	F445
;	lda	#$FF				;	F447
;	ldx	#$08				;	F449
;LF44B:	sta	$038B,x				;	F44B
;	dex					;	F44E
;	bne	LF44B				;	F44F
;	txa					;	F451
;	ldx	#$14				;	F452
;LF454:	sta	$0380,x				;	F454
;	inx					;	F457
;	cpx	#$1E				;	F458
;	bne	LF454				;	F45A
;	rol	$0397				;	F45C
;	jsr	mos_claim_serial_system_for_cass;	F45F
;	jsr	x_print_prompt_for_SAVE_on_TAPE ;	F462
;	jsr	LFAF2				;	F465
;	lda	#$02				;	F468
;	jsr	LF344				;	F46A
;	lda	#$02				;	F46D
;LF46F:	sta	zp_fs_s+12			;	F46F
;LF471:	pla					;	F471
;	tay					;	F472
;	pla					;	F473
;	tax					;	F474
;	lda	zp_fs_s+12			;	F475
;LF477:	rts					;	F477
;; ----------------------------------------------------------------------------
;LF478:	lda	#$02				;	F478
;	and	zp_cfs_w			;	F47A
;	beq	LF477				;	F47C
;	lda	#$00				;	F47E
;	sta	$0397				;	F480
;	lda	#$80				;	F483
;	ldx	$039D				;	F485
;	stx	$0396				;	F488
;	sta	$0398				;	F48B
;	jsr	x_SAVE_BLOCK_TO_TAPE		;	F48E
;	lda	#$FD				;	F491
;	jmp	LF33D				;	F493
;; ----------------------------------------------------------------------------
;; SAVE BLOCK TO TAPE
;x_SAVE_BLOCK_TO_TAPE:
;	jsr	mos_Claim_serial_system_for_sequential_Access;	F496
;	ldx	#$11				;	F499
;LF49B:	lda	$038C,x				;	F49B
;	sta	$03BE,x				;	F49E
;	dex					;	F4A1
;	bpl	LF49B				;	F4A2
;	stx	zp_fs_s+2			;	F4A4
;	stx	zp_fs_s+3			;	F4A6
;	inx					;	F4A8
;	stx	zp_fs_s				;	F4A9
;	lda	#$09				;	F4AB
;	sta	zp_fs_s+1			;	F4AD
;	ldx	#$7F				;	F4AF
;	jsr	x_copy_sought_filename_routine	;	F4B1
;	sta	$03DF				;	F4B4
;	jsr	LFB8E				;	F4B7
;	jsr	x_control_ACIA_and_Motor	;	F4BA
;	jsr	x_SAVE_A_BLOCK			;	F4BD
;	inc	$0394				;	F4C0
;	bne	LF4C8				;	F4C3
;	inc	$0395				;	F4C5
;LF4C8:	rts					;	F4C8
;; ----------------------------------------------------------------------------
;; OSBGET  get a byte from a file; on ENTRY	 Y contains channel number ; on EXIT	    X and Y are preserved C=0 indicates valid character ; A contains character (or error) A=&FE End Of File ; push X and Y 
;mos_OSBGET_get_a_byte_from_a_file:
;	txa					;	F4C9
;	pha					;	F4CA
;	tya					;	F4CB
;	pha					;	F4CC
;	lda	#$01				;	F4CD
;	jsr	x_confirm_file_is_open		;	F4CF
;	lda	zp_cfs_w			;	F4D2
;	asl	a				;	F4D4
;	bcs	LF523				;	F4D5
;	asl	a				;	F4D7
;	bcc	LF4E3				;	F4D8
;	lda	#$80				;	F4DA
;	jsr	LF344				;	F4DC
;	lda	#$FE				;	F4DF
;	bcs	LF51B				;	F4E1
;LF4E3:	ldx	$039E				;	F4E3
;	inx					;	F4E6
;	cpx	cfsrfs_BLK_SIZE			;	F4E7
;	bne	LF516				;	F4EA
;	bit	cfsrfs_BLK_FLAG			;	F4EC
;	bmi	LF513				;	F4EF
;	lda	cfsrfs_LAST_CHAR		;	F4F1
;	pha					;	F4F4
;	jsr	mos_Claim_serial_system_for_sequential_Access;	F4F5
;	php					;	F4F8
;	jsr	x_read_a_block			;	F4F9
;	plp					;	F4FC
;	pla					;	F4FD
;	sta	zp_fs_s+12			;	F4FE
;	clc					;	F500
;	bit	cfsrfs_BLK_FLAG			;	F501
;	bpl	LF51D				;	F504
;	lda	cfsrfs_BLK_SIZE			;	F506
;	ora	cfsrfs_BLK_SIZE+1		;	F509
;	bne	LF51D				;	F50C
;	jsr	LF342				;	F50E
;	bne	LF51D				;	F511
;LF513:	jsr	LF342				;	F513
;LF516:	dex					;	F516
;	clc					;	F517
;	lda	$0A00,x				;	F518
;LF51B:	sta	zp_fs_s+12			;	F51B
;LF51D:	inc	$039E				;	F51D
;	jmp	LF471				;	F520
;; ----------------------------------------------------------------------------
;LF523:	brk					;	F523
;	FCB	$DF				;	F524
;	eor	zp_lang+79			;	F525
;	lsr	zp_lang				;	F527
;; OSBPUT  WRITE A BYTE TO FILE; ON ENTRY  Y contains channel number A contains byte to be written 
;mos_OSBPUT_WRITE_A_BYTE_TO_FILE:
;	sta	zp_fs_w+4			;	F529
;	txa					;	F52B
;	pha					;	F52C
;	tya					;	F52D
;	pha					;	F52E
;	lda	#$02				;	F52F
;	jsr	x_confirm_file_is_open		;	F531
;	ldx	$039D				;	F534
;	lda	zp_fs_w+4			;	F537
;	sta	$0900,x				;	F539
;	inx					;	F53C
;	bne	LF545				;	F53D
;	jsr	x_SAVE_BLOCK_TO_TAPE		;	F53F
;	jsr	LFAF2				;	F542
;LF545:	inc	$039D				;	F545
;	lda	zp_fs_w+4			;	F548
;	jmp	LF46F				;	F54A


*************************************************************************
*                                                                       *
*                                                                       *
*       OSBYTE 139      Select file options                             *
*                                                                       *
*                                                                       *
*************************************************************************
;ON ENTRY  Y contains option value  X contains option No. see *OPT X,Y 
;this applies largely to CFS LOAD SAVE CAT and RUN
;X=1    is message switch  
;       Y=0     no messages
;       Y=1     short messages
;       Y=2     gives detailed information on load and execution addresses

;X=2    is error handling  
;       Y=0     ignore errors
;       Y=1     prompt for a retry
;       Y=2     abort operation

;X=3    is interblock gap for BPUT# and PRINT# 
;       Y=0-127 set gap in 1/10ths Second
;       Y > 127 use default values

mos_FSCV_OPT					; LF54D
		m_txa					;A=X
		beq	LF57E				;if A=0 F57E
		cmpx	#$03				;if X=3
		beq	x_set_interblock_gap		;F573 to set interblock gap
		cmpy	#$03				;else if Y>2 then BAD COMMAND error
		bhs	LF55E				;
		leax	-1,X				;X=X-1
		beq	x_message_control		;i.e. if X=1 F561 message control
		leax	-1,X				;X=X-1
		beq	x_error_response		;i.e. if X=2 F568 error response
LF55E		jmp	x_Bad_command_error		;else E310 to issue Bad Command error
x_message_control
		lda	#$33				;to set lower two bits of each nybble as mask
		leay	3,Y				;Y=Y+4
		bra	1F				;goto F56A
x_error_response
		lda	#$CC				;setting top two bits of each nybble as mask
		leay	1,Y				;Y=Y+1
1		anda	zp_opt_val			;clear lower two bits of each nybble
LF56D		ora	x_DEFAULT_OPT_VALUES_TABLE,y	;or with table value
		sta	zp_opt_val			;store it in &E3
		rts					;return

         ;setting of &E3
         ;
         ;lower nybble sets LOAD options
         ;upper sets SAVE options
         
         ;0000   Ignore errors,          no messages
         ;0001   Abort if error,         no messages
         ;0010   Retry after error,      no messages
         ;1000   Ignore error            short messages
         ;1001   Abort if error          short messages
         ;1010   Retry after error       short messages
         ;1100   Ignore error            long messages
         ;1101   Abort if error          long messages
         ;1110   Retry after error       long messages
 
 
 
 ***********set interblock gap *******************************************
x_set_interblock_gap
		m_tya					;A=Y
		bmi	1F				;if Y>127 use default values
		bne	2F				;if Y<>0 skip next instruction
1		lda	#$19				;else A=&19
2		sta	fsvar_seq_block_gap		;sequential block gap
		rts					;return
; ----------------------------------------------------------------------------
LF57E		ldy	#0				;	assume A always 0 and was a tay
		bra	LF56D				;jump to F56D


;; DEFAULT OPT VALUES TABLE
x_DEFAULT_OPT_VALUES_TABLE
	FCB	$A1, $00, $22, $11, $00, $88, $CC	; LF587

;LF588:	dec	zp_fs_w				;	F588
;	lda	sysvar_CFSRFS_SWITCH		;	F58A
;	beq	LF596				;	F58D
;	jsr	x_ROM_SERVICE			;	F58F
;	tay					;	F592
;	clc					;	F593
;	bcc	LF5B0				;	F594
;LF596:	lda	LFE08				;	F596
;	pha					;	F599
;	and	#$02				;	F59A
;	beq	LF5A9				;	F59C
;	ldy	zp_fs_w+10			;	F59E
;	beq	LF5A9				;	F5A0
;	pla					;	F5A2
;	lda	zp_fs_s+13			;	F5A3
;	sta	LFE09				;	F5A5
;	rts					;	F5A8
;; ----------------------------------------------------------------------------
;LF5A9:	ldy	LFE09				;	F5A9
;	pla					;	F5AC
;	lsr	a				;	F5AD
;	lsr	a				;	F5AE
;	lsr	a				;	F5AF
;LF5B0:	ldx	zp_fs_w+2			;	F5B0
;	beq	LF61D				;	F5B2
;	dex					;	F5B4
;	bne	LF5BD				;	F5B5
;	bcc	LF61D				;	F5B7
;	ldy	#$02				;	F5B9
;	bne	LF61B				;	F5BB
;LF5BD:	dex					;	F5BD
;	bne	LF5D3				;	F5BE
;	bcs	LF61D				;	F5C0
;	tya					;	F5C2
;	jsr	LFB78				;	F5C3
;	ldy	#$03				;	F5C6
;	cmp	#$2A				;	F5C8
;	beq	LF61B				;	F5CA
;	jsr	x_control_cassette_system	;	F5CC
;	ldy	#$01				;	F5CF
;	bne	LF61B				;	F5D1
;LF5D3:	dex					;	F5D3
;	bne	LF5E2				;	F5D4
;	bcs	LF5DC				;	F5D6
;	sty	zp_fs_s+13			;	F5D8
;	beq	LF61D				;	F5DA
;LF5DC:	lda	#$80				;	F5DC
;	sta	zp_fs_w				;	F5DE
;	bne	LF61D				;	F5E0
;LF5E2:	dex					;	F5E2
;	bne	LF60E				;	F5E3
;	bcs	LF616				;	F5E5
;	tya					;	F5E7
;	jsr	x_perform_CRC			;	F5E8
;	ldy	zp_fs_s+12			;	F5EB
;	inc	zp_fs_s+12			;	F5ED
;	bit	zp_fs_s+13			;	F5EF
;	bmi	LF600				;	F5F1
;	jsr	x_check_if_second_processor_file_test_tube_prescence;	F5F3
;	beq	LF5FD				;	F5F6
;	stx	LFEE5				;	F5F8
;	bne	LF600				;	F5FB
;LF5FD:	txa					;	F5FD
;	sta	(zp_fs_s),y			;	F5FE
;LF600:	iny					;	F600
;	cpy	$03C8				;	F601
;	bne	LF61D				;	F604
;	lda	#$01				;	F606
;	sta	zp_fs_s+12			;	F608
;	ldy	#$05				;	F60A
;	bne	LF61B				;	F60C
;LF60E:	tya					;	F60E
;	jsr	x_perform_CRC			;	F60F
;	dec	zp_fs_s+12			;	F612
;	bpl	LF61D				;	F614
;LF616:	jsr	LFB46				;	F616
;	ldy	#$00				;	F619
;LF61B:	sty	zp_fs_w+2			;	F61B
;LF61D:	rts					;	F61D
;; ----------------------------------------------------------------------------
;; OSBYTE 127 check for end of file;  
mos_FSCV_EOF
	TODO	"mos_FSCV_EOF"
;	pha					;	F61E
;	tya					;	F61F
;	pha					;	F620
;	txa					;	F621
;	tay					;	F622
;	lda	#$03				;	F623
;	jsr	x_confirm_file_is_open		;	F625
;	lda	zp_cfs_w			;	F628
;	and	#$40				;	F62A
;	tax					;	F62C
;	pla					;	F62D
;	tay					;	F62E
;	pla					;	F62F
;	rts					;	F630
;; ----------------------------------------------------------------------------
;LF631:	lda	#$00				;	F631
;	sta	zp_fs_s+4			;	F633
;	sta	zp_fs_s+5			;	F635
;LF637:	lda	zp_fs_s+4			;	F637
;	pha					;	F639
;	sta	zp_fs_s+6			;	F63A
;	lda	zp_fs_s+5			;	F63C
;	pha					;	F63E
;	sta	zp_fs_s+7			;	F63F
;	jsr	LFA46				;	F641
;	FCB	$53				;	F644
;	adc	zp_lang+97			;	F645
;	FCB	$72				;	F647
;	FCB	$63				;	F648
;	pla					;	F649
;	adc	#$6E				;	F64A
;	FCB	$67				;	F64C
;	ora	$A900				;	F64D
;	FCB	$FF				;	F650
;	jsr	x_search_routine		;	F651
;	pla					;	F654
;	sta	zp_fs_s+5			;	F655
;	pla					;	F657
;	sta	zp_fs_s+4			;	F658
;	lda	zp_fs_s+6			;	F65A
;	ora	zp_fs_s+7			;	F65C
;	bne	LF66D				;	F65E
;	sta	zp_fs_s+4			;	F660
;	sta	zp_fs_s+5			;	F662
;	lda	zp_fs_w+1			;	F664
;	bne	LF66D				;	F666
;	ldx	#$B1				;	F668
;	jsr	x_copy_sought_filename_routine	;	F66A
;LF66D:	lda	sysvar_CFSRFS_SWITCH		;	F66D
;	beq	LF685				;	F670
;	bvs	LF685				;	F672
brkFileNotFound						; LF674
	DO_BRK  $D6, "File Not found"
;LF685:	ldy	#$FF				;	F685
;	sty	$03DF				;	F687
;	rts					;	F68A
;; ----------------------------------------------------------------------------
mos_CLOSE_EXEC_FILE
	clra					; A=0 means close any current file
; * EXEC
	; always entered with A=0 but Z=1 flag decided whether to close????
	; Y ignored
	; X filename to open in Z=0
mos_STAR_EXEC
	pshs	CC,Y				; save flags on stack
						; save Y
	ldb	sysvar_EXEC_FILE		; EXEC file handle
	sta	sysvar_EXEC_FILE		; EXEC file handle
	tstb					; DB: need extra TST here as STA sets Z	
	beq	1F				
	clra
	tfr	D,Y				; if original file is not 0 close file via OSFIND
	jsr	OSFIND				; Y=original file handle, A=0 on entry!?
1
;;;	ldy	zp_mos_OS_wksp			;else Y= original Y
	puls	CC,Y				;get back flags and Y
	beq	1F				;if Z set on entry exit else
	lda	#$40				;A=&40
	jsr	OSFIND				;to open an input file, file name passed in X
	tsta					;Y=A
	beq	brkFileNotFound			;If Y=0 'File not found' else store
	sta	sysvar_EXEC_FILE		;EXEC file handle
1	rts					;return
;; ----------------------------------------------------------------------------
;; read a block
;x_read_a_block:
;	ldx	#$A6				;	F6AC
;	jsr	x_copy_sought_filename_routine	;	F6AE
;	jsr	LF77B				;	F6B1
;LF6B4:	lda	$03CA				;	F6B4
;	lsr	a				;	F6B7
;	bcc	LF6BD				;	F6B8
;	jmp	x_LOCKED_FILE_ROUTINE		;	F6BA
;; ----------------------------------------------------------------------------
;LF6BD:	lda	$03DD				;	F6BD
;	sta	zp_fs_s+4			;	F6C0
;	lda	$03DE				;	F6C2
;	sta	zp_fs_s+5			;	F6C5
;	lda	#$00				;	F6C7
;	sta	zp_fs_s				;	F6C9
;	lda	#$0A				;	F6CB
;	sta	zp_fs_s+1			;	F6CD
;	lda	#$FF				;	F6CF
;	sta	zp_fs_s+2			;	F6D1
;	sta	zp_fs_s+3			;	F6D3
;	jsr	LF7D5				;	F6D5
;	jsr	x_LOAD				;	F6D8
;	bne	LF702				;	F6DB
;	lda	$0AFF				;	F6DD
;	sta	cfsrfs_LAST_CHAR		;	F6E0
;	jsr	LFB69				;	F6E3
;	stx	$03DD				;	F6E6
;	sty	$03DE				;	F6E9
;	ldx	#$02				;	F6EC
;LF6EE:	lda	$03C8,x				;	F6EE
;	sta	cfsrfs_BLK_SIZE,x		;	F6F1
;	dex					;	F6F4
;	bpl	LF6EE				;	F6F5
;	bit	cfsrfs_BLK_FLAG			;	F6F7
;	bpl	LF6FF				;	F6FA
;	jsr	LF249				;	F6FC
;LF6FF:	jmp	LFAF2				;	F6FF
;; ----------------------------------------------------------------------------
;LF702:	jsr	LF637				;	F702
;	bne	LF6B4				;	F705
;LF707:	cmp	#$2A				;	F707
;	beq	LF742				;	F709
;	cmp	#$23				;	F70B
;	bne	LF71E				;	F70D
;	inc	$03C6				;	F70F
;	bne	LF717				;	F712
;	inc	$03C7				;	F714
;LF717:	ldx	#$FF				;	F717
;	bit	mostbl_SYSVAR_DEFAULT_SETTINGS+65;	F719
;	bne	LF773				;	F71C
;LF71E:	lda	#$F7				;	F71E
;	jsr	LF33D				;	F720
;	brk					;	F723
;	FCB	$D7				;	F724
;	FCB	$42				;	F725
;	adc	(zp_lang+100,x)			;	F726
;	jsr	L4F52				;	F728
;	FCB	$4D				;	F72B
;	brk					;	F72C
;; : pick up a header
;x_pick_up_a_header:
;	ldy	#$FF				;	F72D
;	jsr	x_switch_Motor_on		;	F72F
;	lda	#$01				;	F732
;	sta	zp_fs_w+2			;	F734
;	jsr	x_control_cassette_system	;	F736
;LF739:	jsr	x_confirm_CFS_not_operating_nor_ESCAPE_flag_set;	F739
;	lda	#$03				;	F73C
;	cmp	zp_fs_w+2			;	F73E
;	bne	LF739				;	F740
;LF742:	ldy	#$00				;	F742
;	jsr	x_set_0_checksum_bytes		;	F744
;LF747:	jsr	x_get_character_from_file_and_do_CRC;	F747
;	bvc	LF766				;	F74A
;	sta	$03B2,y				;	F74C
;	beq	LF757				;	F74F
;	iny					;	F751
;	cpy	#$0B				;	F752
;	bne	LF747				;	F754
;	dey					;	F756
;LF757:	ldx	#$0C				;	F757
;LF759:	jsr	x_get_character_from_file_and_do_CRC;	F759
;	bvc	LF766				;	F75C
;	sta	$03B2,x				;	F75E
;	inx					;	F761
;	cpx	#$1F				;	F762
;	bne	LF759				;	F764
;LF766:	tya					;	F766
;	tax					;	F767
;	lda	#$00				;	F768
;	sta	$03B2,y				;	F76A
;	lda	zp_fs_s+14			;	F76D
;	ora	zp_fs_s+15			;	F76F
;	sta	zp_fs_w+1			;	F771
;LF773:	jsr	LFB78				;	F773
;	sty	zp_fs_w+2			;	F776
;	txa					;	F778
;	bne	LF7D4				;	F779
;LF77B:	lda	sysvar_CFSRFS_SWITCH		;	F77B
;	beq	x_pick_up_a_header		;	F77E
;LF780:	jsr	x_ROM_SERVICE			;	F780
;	cmp	#$2B				;	F783
;	bne	LF707				;	F785
;; terminator found
;x_terminator_found:
;	lda	#$08				;	F787
;	and	zp_cfs_w			;	F789
;	beq	LF790				;	F78B
;	jsr	LF24D				;	F78D
;LF790:	jsr	x_Get_byte_from_data_ROM	;	F790
;	bcc	LF780				;	F793
;	clv					;	F795
;	rts					;	F796
;; ----------------------------------------------------------------------------
;; get character from file and do CRC;  
;x_get_character_from_file_and_do_CRC:
;	lda	sysvar_CFSRFS_SWITCH		;	F797
;	beq	LF7AD				;	F79A
;	txa					;	F79C
;	pha					;	F79D
;	tya					;	F79E
;	pha					;	F79F
;	jsr	x_ROM_SERVICE			;	F7A0
;	sta	zp_fs_s+13			;	F7A3
;	lda	#$FF				;	F7A5
;	sta	zp_fs_w				;	F7A7
;	pla					;	F7A9
;	tay					;	F7AA
;	pla					;	F7AB
;	tax					;	F7AC
;LF7AD:	jsr	x_check_for_Escape_and_loop_till_bit_7_of_FS_buffer_flag;	F7AD
;; perform CRC
;x_perform_CRC:
;	php					;	F7B0
;	pha					;	F7B1
;	sec					;	F7B2
;	ror	zp_fs_w+11			;	F7B3
;	eor	zp_fs_s+15			;	F7B5
;	sta	zp_fs_s+15			;	F7B7
;LF7B9:	lda	zp_fs_s+15			;	F7B9
;	rol	a				;	F7BB
;	bcc	LF7CA				;	F7BC
;	ror	a				;	F7BE
;	eor	#$08				;	F7BF
;	sta	zp_fs_s+15			;	F7C1
;	lda	zp_fs_s+14			;	F7C3
;	eor	#$10				;	F7C5
;	sta	zp_fs_s+14			;	F7C7
;	sec					;	F7C9
;LF7CA:	rol	zp_fs_s+14			;	F7CA
;	rol	zp_fs_s+15			;	F7CC
;	lsr	zp_fs_w+11			;	F7CE
;	bne	LF7B9				;	F7D0
;	pla					;	F7D2
;	plp					;	F7D3
;LF7D4:	rts					;	F7D4
;; ----------------------------------------------------------------------------
;LF7D5:	lda	#$00				;	F7D5
;LF7D7:	sta	zp_fs_s+13			;	F7D7
;	ldx	#$00				;	F7D9
;	stx	zp_fs_s+12			;	F7DB
;	bvc	LF7E9				;	F7DD
;	lda	$03C8				;	F7DF
;	ora	$03C9				;	F7E2
;	beq	LF7E9				;	F7E5
;	ldx	#$04				;	F7E7
;LF7E9:	stx	zp_fs_w+2			;	F7E9
;	rts					;	F7EB


FILL1
		FILL	$FF,NOICE_CODE_BASE-FILL1
			ORG	NOICE_CODE_BASE
		IF NOICE==0
			FILL	$FF,NOICE_CODE_LEN
		ELSE
			INCLUDEBIN "../noice/noice_beeb6309/noice6309-ovr.bin"
FILLNOICE		FILL	$FF,NOICE_CODE_BASE+NOICE_CODE_LEN-FILLNOICE
		ENDIF

;
;
;	Place code here? Change constants and sync noice code!
;
;


; strings are at F500

;;FILL2
;;		FILL	$FF,REMAPPED_HW_VECTORS-FILL2
		ORG	REMAPPED_HW_VECTORS
*************************************************************
*     R E M A P P E D    H A R D W A R E    V E C T O R S   *
*************************************************************
XRESV		FDB	mos_handle_res	; $FFF0   ; Hardware vectors, paged in to $F7Fx from $FFFx
XSWI3V		FDB	mos_handle_swi3	; $FFF2		; on 6809 we use this instead of 6502 BRK
XSWI2V		FDB	mos_handle_irq	; $FFF4
XFIRQV		FDB	mos_handle_irq	; $FFF6
XIRQV		FDB	mos_handle_irq	; $FFF8
	IF NOICE==0
XSWIV		FDB	mos_handle_irq	; $FFFA
XNMIV		FDB	vec_nmi		; $FFFC
	ELSE
XSWIV		FDB	noice_handle_swi	; $FFFA
XNMIV		FDB	noice_handle_nmi	; $FFFC
	ENDIF
XRESETV		FDB	mos_handle_res	; $FFFE

		IF NOICE
noice_handle_nmi	JMP	[NOICE_CODE_BASE+0]
noice_handle_swi	JMP	[NOICE_CODE_BASE+2]
noice_handle_res	JMP	NOICE_CODE_BASE+4
		ENDIF


*******************************************************************************
* 6809 debug and specials
*******************************************************************************

_ytoa	pshs	Y
	leas	1,S
	puls	A,PC

_m_tax_se		; sign extend A into X
	sta	,-S
	bmi	1F
	clr	,-S
	puls	X,PC
1	clr	,-S
	dec	,S
	puls	X,PC


	; send characters after call to the UART
debug_print
	PSHS	X
	LDX	2,S
	jsr	debug_printX
	STX	2,S
	PULS	X,PC

debug_printX
	pshs	A
1	LDA	,X+	
	BEQ	2F
	ANDA	#$7F
	JSR	debug_print_ch
	BRA	1B
2	puls	A,PC

debug_print_newl
	pshs	A
;;	lda	#13
;;	jsr	debug_print_ch
	lda	#10
	jsr	debug_print_ch
	puls	A,PC

debug_print_hex
	sta	,-S
	lsra
	lsra
	lsra
	lsra
	jsr	debug_print_hex_digit
	lda	,S
	jsr	debug_print_hex_digit
	puls	A,PC
debug_print_hex_digit
	anda	#$F
	adda	#'0'
	cmpa	#'9'
	bls	1F
	adda	#'A'-'9'-1
1
debug_print_ch
	pshs	B
3	LDB	S16550_LSR	; CHECK TX STATUS
	ANDB	#SER_BIT_TXRDY	; RX READY ?
	BEQ	3B
	STA	S16550_TXR	; TRANSMIT CHAR.
	cmpa	#$D
	bne	1F
	pshs	A
	lda	#$A
	jsr	debug_print_ch
	puls	A
1	puls	B,PC


;; ----------------------------------------------------------------------------
;; SAVE A BLOCK
;x_SAVE_A_BLOCK:
;	php					;	F7EC
;	ldx	#$03				;	F7ED
;	lda	#$00				;	F7EF
;LF7F1:	sta	$03CB,x				;	F7F1
;	dex					;	F7F4
;	bpl	LF7F1				;	F7F5
;	lda	$03C6				;	F7F7
;	ora	$03C7				;	F7FA
;	bne	LF804				;	F7FD
;	jsr	x_generate_a_5_second_delay	;	F7FF
;	beq	LF807				;	F802
;LF804:	jsr	x_generate_delay_set_by_interblock_gap;	F804
;LF807:	lda	#$2A				;	F807
;	sta	zp_fs_s+13			;	F809
;	jsr	LFB78				;	F80B
;	jsr	x_set_ACIA_control_register	;	F80E
;	jsr	x_check_for_Escape_and_loop_till_bit_7_of_FS_buffer_flag;	F811
;	dey					;	F814
;LF815:	iny					;	F815
;	lda	$03D2,y				;	F816
;	sta	$03B2,y				;	F819
;	jsr	x_transfer_byte_to_CFS_and_do_CRC;	F81C
;	bne	LF815				;	F81F
;; : deal with rest of header
;x_deal_with_rest_of_header:
;	ldx	#$0C				;	F821
;LF823:	lda	$03B2,x				;	F823
;	jsr	x_transfer_byte_to_CFS_and_do_CRC;	F826
;	inx					;	F829
;	cpx	#$1D				;	F82A
;	bne	LF823				;	F82C
;	jsr	x_save_checksum_to_TAPE_reset_buffer_flag;	F82E
;	lda	$03C8				;	F831
;	ora	$03C9				;	F834
;	beq	LF855				;	F837
;	ldy	#$00				;	F839
;	jsr	x_set_0_checksum_bytes		;	F83B
;LF83E:	lda	(zp_fs_s),y			;	F83E
;	jsr	x_check_if_second_processor_file_test_tube_prescence;	F840
;	beq	LF848				;	F843
;	ldx	LFEE5				;	F845
;LF848:	txa					;	F848
;	jsr	x_transfer_byte_to_CFS_and_do_CRC;	F849
;	iny					;	F84C
;	cpy	$03C8				;	F84D
;	bne	LF83E				;	F850
;	jsr	x_save_checksum_to_TAPE_reset_buffer_flag;	F852
;LF855:	jsr	x_check_for_Escape_and_loop_till_bit_7_of_FS_buffer_flag;	F855
;	jsr	x_check_for_Escape_and_loop_till_bit_7_of_FS_buffer_flag;	F858
;	jsr	LFB46				;	F85B
;	lda	#$01				;	F85E
;	jsr	x_generate_delay		;	F860
;	plp					;	F863
;	jsr	x_update_block_flag_PRINT_filenameFDB;	F864
;	bit	$03CA				;	F867
;	bpl	LF874				;	F86A
;	php					;	F86C
;	jsr	x_generate_a_5_second_delay	;	F86D
;	jsr	LF246				;	F870
;	plp					;	F873
;LF874:	rts					;	F874
;; ----------------------------------------------------------------------------
;; transfer byte to CFS and do CRC;  
;x_transfer_byte_to_CFS_and_do_CRC:
;	jsr	x_save_byte_to_buffer_xfer_to_CFS_reset_flag;	F875
;	jmp	x_perform_CRC			;	F878
;; ----------------------------------------------------------------------------
;; save checksum to TAPE reset buffer flag
;x_save_checksum_to_TAPE_reset_buffer_flag:
;	lda	zp_fs_s+15			;	F87B
;	jsr	x_save_byte_to_buffer_xfer_to_CFS_reset_flag;	F87D
;	lda	zp_fs_s+14			;	F880
;; save byte to buffer, transfer to CFS & reset flag
;x_save_byte_to_buffer_xfer_to_CFS_reset_flag:
;	sta	zp_fs_s+13			;	F882
;; check for Escape and loop till bit 7 of FS buffer flag=1
;x_check_for_Escape_and_loop_till_bit_7_of_FS_buffer_flag:
;	jsr	x_confirm_CFS_not_operating_nor_ESCAPE_flag_set;	F884
;	bit	zp_fs_w				;	F887
;	bpl	x_check_for_Escape_and_loop_till_bit_7_of_FS_buffer_flag;	F889
;	lda	#$00				;	F88B
;	sta	zp_fs_w				;	F88D
;	lda	zp_fs_s+13			;	F88F
;	rts					;	F891
;; ----------------------------------------------------------------------------
;; generate a 5 second delay
;x_generate_a_5_second_delay:
;	lda	#$32				;	F892
;	bne	x_generate_delay		;	F894
;; generate delay set by interblock gap
;x_generate_delay_set_by_interblock_gap:
;	lda	zp_fs_w+7			;	F896
;; generate delay
;x_generate_delay:
;	ldx	#$05				;	F898
;LF89A:	sta	sysvar_CFSTOCTR			;	F89A
;LF89D:	jsr	x_confirm_CFS_not_operating_nor_ESCAPE_flag_set;	F89D
;	bit	sysvar_CFSTOCTR			;	F8A0
;	bpl	LF89D				;	F8A3
;	dex					;	F8A5
;	bne	LF89A				;	F8A6
;	rts					;	F8A8
;; ----------------------------------------------------------------------------
;; : generate screen reports
;x_generate_screen_reports:
;	lda	$03C6				;	F8A9
;	ora	$03C7				;	F8AC
;	beq	LF8B6				;	F8AF
;	bit	$03DF				;	F8B1
;	bpl	x_update_block_flag_PRINT_filenameFDB;	F8B4
;LF8B6:	jsr	LF249				;	F8B6
;; update block flag, PRINT filename (&FDBess if reqd)
;x_update_block_flag_PRINT_filenameFDB:
;	ldy	#$00				;	F8B9
;	sty	zp_fs_s+10			;	F8BB
;	lda	$03CA				;	F8BD
;	sta	$03DF				;	F8C0
;	jsr	LE7DC				;	F8C3
;	beq	LF933				;	F8C6
;	lda	#$0D				;	F8C8
;	jsr	OSWRCH				;	F8CA
;LF8CD:	lda	$03B2,y				;	F8CD
;	beq	x_end_of_filename		;	F8D0
;	cmp	#$20				;	F8D2
;	bcc	x_Control_characters_in_RFS_CFS_filename;	F8D4
;	cmp	#$7F				;	F8D6
;	bcc	LF8DC				;	F8D8
;; Control characters in RFS/CFS filename
;x_Control_characters_in_RFS_CFS_filename:
;	lda	#$3F				;	F8DA
;LF8DC:	jsr	OSWRCH				;	F8DC
;	iny					;	F8DF
;	bne	LF8CD				;	F8E0
;; end of filename
;x_end_of_filename:
;	lda	sysvar_CFSRFS_SWITCH		;	F8E2
;	beq	LF8EB				;	F8E5
;	bit	zp_fs_s+11			;	F8E7
;	bvc	LF933				;	F8E9
;LF8EB:	jsr	x_print_a_space			;	F8EB
;	iny					;	F8EE
;	cpy	#$0B				;	F8EF
;	bcc	x_end_of_filename		;	F8F1
;	lda	$03C6				;	F8F3
;	tax					;	F8F6
;	jsr	x_print_ASCII_equivalent_of_hex_byte;	F8F7
;	bit	$03CA				;	F8FA
;	bpl	LF933				;	F8FD
;	txa					;	F8FF
;	clc					;	F900
;	adc	$03C9				;	F901
;	sta	zp_fs_w+13			;	F904
;	jsr	x_print_a_space_ASCII_equivalent_of_hex_byte;	F906
;	lda	$03C8				;	F909
;	sta	zp_fs_w+12			;	F90C
;	jsr	x_print_ASCII_equivalent_of_hex_byte;	F90E
;	bit	zp_fs_s+11			;	F911
;	bvc	LF933				;	F913
;	ldx	#$04				;	F915
;LF917:	jsr	x_print_a_space			;	F917
;	dex					;	F91A
;	bne	LF917				;	F91B
;	ldx	#$0F				;	F91D
;	jsr	x_print_4_bytes_from_CFS_block_header;	F91F
;	jsr	x_print_a_space			;	F922
;	ldx	#$13				;	F925
;; print 4 bytes from CFS block header
;x_print_4_bytes_from_CFS_block_header:
;	ldy	#$04				;	F927
;LF929:	lda	$03B2,x				;	F929
;	jsr	x_print_ASCII_equivalent_of_hex_byte;	F92C
;	dex					;	F92F
;	dey					;	F930
;	bne	LF929				;	F931
;LF933:	rts					;	F933
;; ----------------------------------------------------------------------------
;; print prompt for SAVE on TAPE
;x_print_prompt_for_SAVE_on_TAPE:
;	lda	sysvar_CFSRFS_SWITCH		;	F934
;	beq	LF93C				;	F937
;	jmp	x_Bad_command_error		;	F939
;; ----------------------------------------------------------------------------
;LF93C:	jsr	LFB8E				;	F93C
;	jsr	x_control_ACIA_and_Motor	;	F93F
;	jsr	LE7DC				;	F942
;	beq	LF933				;	F945
;	jsr	LFA46				;	F947
;	FCB	$52				;	F94A
;	eor	zp_lang+67			;	F94B
;	FCB	$4F				;	F94D
;	FCB	$52				;	F94E
;	FCB	$44				;	F94F
;	jsr	L6874				;	F950
;	adc	zp_lang+110			;	F953
;	jsr	L4552				;	F955
;	FCB	$54				;	F958
;	eor	zp_lang+82,x			;	F959
;	FCB	$4E				;	F95B
;	brk					;	F95C
;LF95D:	jsr	x_confirm_CFS_not_operating_nor_ESCAPE_flag_set;	F95D
;; wait for RETURN key to be pressed
;x_wait_for_RETURN_key_to_be_pressed:
;	jsr	OSRDCH				;	F960
;	cmp	#$0D				;	F963
;	bne	LF95D				;	F965
;	jmp	OSNEWL				;	F967
;; ----------------------------------------------------------------------------
;; increment current loadFDBess
;x_increment_current_loadFDBess:
;	inc	zp_fs_s+1			;	F96A
;	bne	LF974				;	F96C
;	inc	zp_fs_s+2			;	F96E
;	bne	LF974				;	F970
;	inc	zp_fs_s+3			;	F972
;LF974:	rts					;	F974
;; ----------------------------------------------------------------------------
;; print a space + ASCII equivalent of hex byte
;x_print_a_space_ASCII_equivalent_of_hex_byte:
;	pha					;	F975
;	jsr	x_print_a_space			;	F976
;	pla					;	F979
;; print ASCII equivalent of hex byte
;x_print_ASCII_equivalent_of_hex_byte:
;	pha					;	F97A
;	lsr	a				;	F97B
;	lsr	a				;	F97C
;	lsr	a				;	F97D
;	lsr	a				;	F97E
;	jsr	LF983				;	F97F
;	pla					;	F982
;LF983:	clc					;	F983
;	and	#$0F				;	F984
;	adc	#$30				;	F986
;	cmp	#$3A				;	F988
;	bcc	LF98E				;	F98A
;	adc	#$06				;	F98C
;LF98E:	jmp	OSWRCH				;	F98E
;; ----------------------------------------------------------------------------
;; print a space
;x_print_a_space:
;	lda	#$20				;	F991
;	bne	LF98E				;	F993
;; confirm CFS not operating, nor ESCAPE flag set
;x_confirm_CFS_not_operating_nor_ESCAPE_flag_set:
;	php					;	F995
;	bit	zp_mos_cfs_critical		;	F996
;	bmi	LF99E				;	F998
;	bit	zp_mos_ESC_flag			;	F99A
;	bmi	LF9A0				;	F99C
;LF99E:	plp					;	F99E
;	rts					;	F99F
;; ----------------------------------------------------------------------------
;LF9A0:	jsr	LF33B				;	F9A0
;	jsr	LFAF2				;	F9A3
;	lda	#$7E				;	F9A6
;	jsr	OSBYTE				;	F9A8
;	brk					;	F9AB
;	ora	(zp_lang+69),y			;	F9AC
;	FCB	$73				;	F9AE
;	FCB	$63				;	F9AF
;	adc	(zp_lang+112,x)			;	F9B0
;	adc	zp_lang				;	F9B2
;; LOAD
;x_LOAD: tya					;	F9B4
;	beq	LF9C4				;	F9B5
;	jsr	LFA46				;	F9B7
;	ora	$6F4C				;	F9BA
;	adc	(zp_lang+100,x)			;	F9BD
;	adc	#$6E				;	F9BF
;	FCB	$67				;	F9C1
;	FCB	$0D				;	F9C2
;	brk					;	F9C3
;LF9C4:	sta	zp_fs_s+10			;	F9C4
;	ldx	#$FF				;	F9C6
;	lda	zp_fs_w+1			;	F9C8
;	bne	LF9D9				;	F9CA
;	jsr	x_compare_filenames		;	F9CC
;	php					;	F9CF
;	ldx	#$FF				;	F9D0
;	ldy	#$99				;	F9D2
;	lda	#$FA				;	F9D4
;	plp					;	F9D6
;	bne	LF9F5				;	F9D7
;LF9D9:	ldy	#$8E				;	F9D9
;	lda	zp_fs_w+1			;	F9DB
;	beq	LF9E3				;	F9DD
;	lda	#$FA				;	F9DF
;	bne	LF9F5				;	F9E1
;LF9E3:	lda	$03C6				;	F9E3
;	cmp	zp_fs_s+4			;	F9E6
;	bne	LF9F1				;	F9E8
;	lda	$03C7				;	F9EA
;	cmp	zp_fs_s+5			;	F9ED
;	beq	LFA04				;	F9EF
;LF9F1:	ldy	#$A4				;	F9F1
;	lda	#$FA				;	F9F3
;LF9F5:	pha					;	F9F5
;	tya					;	F9F6
;	pha					;	F9F7
;	txa					;	F9F8
;	pha					;	F9F9
;	jsr	LF8B6				;	F9FA
;	pla					;	F9FD
;	tax					;	F9FE
;	pla					;	F9FF
;	tay					;	FA00
;	pla					;	FA01
;	bne	LFA18				;	FA02
;LFA04:	txa					;	FA04
;	pha					;	FA05
;	jsr	x_generate_screen_reports	;	FA06
;	jsr	LFAD6				;	FA09
;	pla					;	FA0C
;	tax					;	FA0D
;	lda	zp_fs_s+14			;	FA0E
;	ora	zp_fs_s+15			;	FA10
;	beq	LFA8D				;	FA12
;	ldy	#$8E				;	FA14
;	lda	#$FA				;	FA16
;LFA18:	dec	zp_fs_s+10			;	FA18
;	pha					;	FA1A
;	bit	zp_mos_cfs_critical		;	FA1B
;	bmi	LFA2C				;	FA1D
;	txa					;	FA1F
;	and	sysvar_CFSRFS_SWITCH		;	FA20
;	bne	LFA2C				;	FA23
;	txa					;	FA25
;	and	#$11				;	FA26
;	and	zp_fs_s+11			;	FA28
;	beq	LFA3C				;	FA2A
;LFA2C:	pla					;	FA2C
;	sta	zp_fs_s+9			;	FA2D
;	sty	zp_fs_s+8			;	FA2F
;	jsr	mos_CLOSE_EXEC_FILE				;	FA31
;	lsr	zp_mos_cfs_critical		;	FA34
;	jsr	x_sound_bell_reset_ACIA_motor_off;	FA36
;	jmp	(zp_fs_s+8)			;	FA39
;; ----------------------------------------------------------------------------
;LFA3C:	pla					;	FA3C
;	iny					;	FA3D
;	bne	LFA43				;	FA3E
;	clc					;	FA40
;	adc	#$01				;	FA41
;LFA43:	pha					;	FA43
;	tya					;	FA44
;	pha					;	FA45
;LFA46:	jsr	LE7DC				;	FA46
;	tay					;	FA49
;; Print 0 terminated string after jsr, return after string
mos_PRTEXT
	puls	X				; get return address back from stack
	jsr	mos_PRSTRING
2	jmp	,X
mos_PRSTRING
1	lda	,X+
	beq	2F
	jsr	OSASCI
	bra	1B
2	rts
;; ----------------------------------------------------------------------------
;; compare filenames
;x_compare_filenames:
;	ldx	#$FF				;	FA72
;LFA74:	inx					;	FA74
;	lda	$03D2,x				;	FA75
;	bne	LFA81				;	FA78
;	txa					;	FA7A
;	beq	LFA80				;	FA7B
;	lda	$03B2,x				;	FA7D
;LFA80:	rts					;	FA80
;; ----------------------------------------------------------------------------
;LFA81:	jsr	mos_CHECK_FOR_ALPHA_CHARACTER	;	FA81
;	eor	$03B2,x				;	FA84
;	bcs	LFA8B				;	FA87
;	and	#$DF				;	FA89
;LFA8B:	beq	LFA74				;	FA8B
;LFA8D:	rts					;	FA8D
;; ----------------------------------------------------------------------------
;	FCB	$00,$D8,$0D			;	FA8E
;	FCB	"Data?"				;	FA91
;	FCB	$00				;	FA96
;; ----------------------------------------------------------------------------
;	bne	LFAAE				;	FA97
;	FCB	$00,$DB,$0D			;	FA99
;	FCB	"File?"				;	FA9C
;	FCB	$00				;	FAA1
;; ----------------------------------------------------------------------------
;	bne	LFAAE				;	FAA2
;	FCB	$00,$DA,$0D			;	FAA4
;	FCB	"Block?"			;	FAA7
;	FCB	$00				;	FAAD
;; ----------------------------------------------------------------------------
;LFAAE:	lda	zp_fs_s+10			;	FAAE
;	beq	LFAD3				;	FAB0
;	txa					;	FAB2
;	beq	LFAD3				;	FAB3
;	lda	#$22				;	FAB5
;	bit	zp_fs_s+11			;	FAB7
;	beq	LFAD3				;	FAB9
;	jsr	LFB46				;	FABB
;	tay					;	FABE
;	jsr	mos_PRTEXT			;	FABF
;	FCB	$0D,$07				;	FAC2
;	FCB	"Rewind tape"			;	FAC4
;						;	FACC
;	FCB	$0D,$0D,$00			;	FACF
;; ----------------------------------------------------------------------------
;LFAD2:	rts					;	FAD2
;; ----------------------------------------------------------------------------
;LFAD3:	jsr	LF24D				;	FAD3
;LFAD6:	lda	zp_fs_w+2			;	FAD6
;	beq	LFAD2				;	FAD8
;	jsr	x_confirm_CFS_not_operating_nor_ESCAPE_flag_set;	FADA
;	lda	sysvar_CFSRFS_SWITCH		;	FADD
;	beq	LFAD6				;	FAE0
;	jsr	LF588				;	FAE2
;	jmp	LFAD6				;	FAE5
;; ----------------------------------------------------------------------------
;; sound bell, reset ACIA, motor off
;x_sound_bell_reset_ACIA_motor_off:
;	jsr	LE7DC				;	FAE8
;	beq	LFAF2				;	FAEB
;	lda	#$07				;	FAED
;	jsr	OSWRCH				;	FAEF
;LFAF2:	lda	#$80				;	FAF2
;	jsr	LFBBD				;	FAF4
;	ldx	#$00				;	FAF7
;	jsr	x_control_motor			;	FAF9
;LFAFC:	php					;	FAFC
;	sei					;	FAFD
;	lda	sysvar_SERPROC_CTL_CPY		;	FAFE
;	sta	LFE10				;	FB01
;	lda	#$00				;	FB04
;	sta	zp_mos_rs423timeout		;	FB06
;	beq	LFB0B				;	FB08
;LFB0A:	php					;	FB0A
;LFB0B:	jsr	LFB46				;	FB0B
;	lda	sysvar_RS423_CTL_COPY		;	FB0E
;	jmp	LE189				;	FB11
;; ----------------------------------------------------------------------------
;LFB14:	plp					;	FB14
;	bit	zp_mos_ESC_flag			;	FB15
;	bpl	LFB31				;	FB17
;	rts					;	FB19
;; ----------------------------------------------------------------------------
;; Claim serial system for sequential Access
;mos_Claim_serial_system_for_sequential_Access:
;	lda	zp_cfs_w+1			;	FB1A
;	asl	a				;	FB1C
;	asl	a				;	FB1D
;	asl	a				;	FB1E
;	asl	a				;	FB1F
;	sta	zp_fs_s+11			;	FB20
;	lda	$03D1				;	FB22
;	bne	LFB2F				;	FB25
;; claim serial system for cassette etc.
;mos_claim_serial_system_for_cass:
;	lda	zp_cfs_w+1			;	FB27
;	and	#$F0				;	FB29
;	sta	zp_fs_s+11			;	FB2B
;	lda	#$06				;	FB2D
;LFB2F:	sta	zp_fs_w+7			;	FB2F
;LFB31:	cli					;	FB31
;	php					;	FB32
;	sei					;	FB33
;	bit	sysvar_RS423_USEFLAG		;	FB34
;	bpl	LFB14				;	FB37
;	lda	zp_mos_rs423timeout		;	FB39
;	bmi	LFB14				;	FB3B
;	lda	#$01				;	FB3D
;	sta	zp_mos_rs423timeout		;	FB3F
;	jsr	LFB46				;	FB41
;	plp					;	FB44
;	rts					;	FB45
;; ----------------------------------------------------------------------------
;LFB46:	lda	#$03				;	FB46
;	bne	LFB65				;	FB48
;; set ACIA control register
;x_set_ACIA_control_register:
;	lda	#$30				;	FB4A
;	sta	zp_fs_w+10			;	FB4C
;	bne	LFB63				;	FB4E
;; control cassette system
;x_control_cassette_system:
;	lda	#$05				;	FB50
;	sta	LFE10				;	FB52
;	ldx	#$FF				;	FB55
;LFB57:	dex					;	FB57
;	bne	LFB57				;	FB58
;	stx	zp_fs_w+10			;	FB5A
;	lda	#$85				;	FB5C
;	sta	LFE10				;	FB5E
;	lda	#$D0				;	FB61
;LFB63:	ora	zp_fs_w+6			;	FB63
;LFB65:	sta	LFE08				;	FB65
;	rts					;	FB68
;; ----------------------------------------------------------------------------
;LFB69:	ldx	$03C6				;	FB69
;	ldy	$03C7				;	FB6C
;	inx					;	FB6F
;	stx	zp_fs_s+4			;	FB70
;	bne	LFB75				;	FB72
;	iny					;	FB74
;LFB75:	sty	zp_fs_s+5			;	FB75
;	rts					;	FB77
;; ----------------------------------------------------------------------------
;LFB78:	ldy	#$00				;	FB78
;	sty	zp_fs_w				;	FB7A
;; set (zero) checksum bytes
;x_set_0_checksum_bytes:
;	sty	zp_fs_s+14			;	FB7C
;	sty	zp_fs_s+15			;	FB7E
;	rts					;	FB80
;; ----------------------------------------------------------------------------
;; copy sought filename routine
;x_copy_sought_filename_routine:
;	ldy	#$FF				;	FB81
;LFB83:	iny					;	FB83
;	inx					;	FB84
;	lda	vduvar_GRA_WINDOW_LEFT,x	;	FB85
;	sta	$03D2,y				;	FB88
;	bne	LFB83				;	FB8B
;	rts					;	FB8D
;; ----------------------------------------------------------------------------
;LFB8E:	ldy	#$00				;	FB8E
;; switch Motor on
;x_switch_Motor_on:
;	cli					;	FB90
;	ldx	#$01				;	FB91
;	sty	zp_fs_w+3			;	FB93
;; : control motor
;x_control_motor:
;	lda	#$89				;	FB95
;	ldy	zp_fs_w+3			;	FB97
;	jmp	OSBYTE				;	FB99
;; ----------------------------------------------------------------------------
;; confirm file is open
;x_confirm_file_is_open:
;	sta	zp_fs_s+12			;	FB9C
;	tya					;	FB9E
;	eor	sysvar_CFSRFS_SWITCH		;	FB9F
;	tay					;	FBA2
;	lda	zp_cfs_w			;	FBA3
;	and	zp_fs_s+12			;	FBA5
;	lsr	a				;	FBA7
;	dey					;	FBA8
;	beq	LFBAF				;	FBA9
;	lsr	a				;	FBAB
;	dey					;	FBAC
;	bne	LFBB1				;	FBAD
;LFBAF:	bcs	LFBFE				;	FBAF
;LFBB1:	brk					;	FBB1
;	FCB	$DE				;	FBB2
;	FCB	"Channel"			;	FBB3
;	FCB	$00				;	FBBA
;; ----------------------------------------------------------------------------
;; read from second processor
;x_read_from_second_processor:
;	lda	#$01				;	FBBB
;LFBBD:	jsr	x_check_if_second_processor_file_test_tube_prescence;	FBBD
;	beq	LFBFE				;	FBC0
;	txa					;	FBC2
;	ldx	#$B0				;	FBC3
;	ldy	#$00				;	FBC5
;LFBC7:	pha					;	FBC7
;	lda	#$C0				;	FBC8
;LFBCA:	jsr	L0406				;	FBCA
;	bcc	LFBCA				;	FBCD
;	pla					;	FBCF
;	jmp	L0406				;	FBD0
;; ----------------------------------------------------------------------------
;; check if second processor file test tube prescence
;x_check_if_second_processor_file_test_tube_prescence:
;	tax					;	FBD3
;	lda	zp_fs_s+2			;	FBD4
;	and	zp_fs_s+3			;	FBD6
;	cmp	#$FF				;	FBD8
;	beq	LFBE1				;	FBDA
;	lda	sysvar_TUBE_PRESENT		;	FBDC
;	and	#$80				;	FBDF
;LFBE1:	rts					;	FBE1
;; ----------------------------------------------------------------------------
;; control ACIA and Motor
;x_control_ACIA_and_Motor:
;	lda	#$85				;	FBE2
;	sta	LFE10				;	FBE4
;	jsr	LFB46				;	FBE7
;	lda	#$10				;	FBEA
;	jsr	LFB63				;	FBEC
;LFBEF:	jsr	x_confirm_CFS_not_operating_nor_ESCAPE_flag_set;	FBEF
;	lda	LFE08				;	FBF2
;	and	#$02				;	FBF5
;	beq	LFBEF				;	FBF7
;	lda	#$AA				;	FBF9
;	sta	LFE09				;	FBFB
;LFBFE:	rts					;	FBFE
;; ----------------------------------------------------------------------------
;	brk					;	FBFF

jgh_SCANHEX
		TODO "jgh_SCANHEX"
jgh_OSQUIT
		TODO "jgh_OSQUIT"
jgh_PR2HEX	tfr	X,D
		jsr	PRHEX
		tfr	B,A
jgh_PRHEX
		PSHS	A
		lsra
		lsra
		lsra
		lsra
		jsr	PRHEXDIG
		puls	A
PRHEXDIG	jsr	mos_convhex_nyb
		jmp	OSASCI
mos_convhex_nyb	anda	#$0F
		adda	#'0'
		cmpa	#'9'
		bls	1F
		adda	#'A'-'9'-1
1		rts
mos_hexstr_Y	sta	,-S
		lsra
		lsra
		lsra
		lsra
		jsr	mos_convhex_nyb
		sta	,Y+
		lda	,S
		jsr	mos_convhex_nyb
		sta	,Y+
		puls	A,PC
jgh_USERINT	rti
jgh_ERRJMP	ldx	,S++
		CLI
		jmp	[BRKV]
jgh_CLICOM	TODO "jgh_CLICOM"
jgh_OSINIT	tsta
		bne	OSINIT_read
		clra
		tfr	A,DP			; set DP=0
OSINIT_read	ldx	#BRKV
		ldy	#zp_mos_ESC_flag
		clra				; indicate BE OS calls
		rts


* Bounce table to cope with fact that indirect jump is 4 bytes on 6809
OSFIND_bounce	jmp	[FINDV]
OSGBPB_bounce	jmp	[GBPBV]
OSBPUT_bounce	jmp	[BPUTV]
OSBGET_bounce	jmp	[BGETV]
OSARGS_bounce	jmp	[ARGSV]
OSFILE_bounce	jmp	[FILEV]
OSRDCH_bounce	jmp	[RDCHV]
OSWRCH_bounce	jmp	[WRCHV]
OSWORD_bounce	jmp	[WORDV]
OSBYTE_bounce	jmp	[BYTEV]
OSCLI_bounce	jmp	[CLIV]


FILL5
		FILL	$FF,HARDWARELOC-FILL5
		ORG	HARDWARELOC
		FILL	$FF,HARDWARELOC_END-HARDWARELOC+1

;LFC00	FCB	"(C) 1981 Ac0rn Computers Ltd.Th";	FC00
;						;	FC08
;						;	FC10
;						;	FC18
;	FCB	"anks are due to the following c";	FC1F
;						;	FC27
;						;	FC2F
;						;	FC37
;	FCB	"ontributors to the development ";	FC3E
;						;	FC46
;						;	FC4E
;						;	FC56
;	FCB	"of the BBC Computer (among othe";	FC5D
;						;	FC65
;						;	FC6D
;						;	FC75
;	FCB	"rs too numerous to mention):- D";	FC7C
;						;	FC84
;						;	FC8C
;						;	FC94
;	FCB	"avid Allen,Bob Austin,Ram Baner";	FC9B
;						;	FCA3
;						;	FCAB
;						;	FCB3
;	FCB	"jee,Paul Bond,Allen Boothroyd,C";	FCBA
;						;	FCC2
;						;	FCCA
;						;	FCD2
;	FCB	"ambridge,Cleartone,John Coll,Jo";	FCD9
;						;	FCE1
;						;	FCE9
;						;	FCF1
;	FCB	"hn Cox,A"			;	FCF8
;LFD00:	FCB	"ndy Cripps,Chris Curry,6502 des";	FD00
;						;	FD08
;						;	FD10
;						;	FD18
;	FCB	"igners,Jeremy Dion,Tim Dobson,J";	FD1F
;						;	FD27
;						;	FD2F
;						;	FD37
;	FCB	"oe Dunn,Paul Farrell,Ferranti,S";	FD3E
;						;	FD46
;						;	FD4E
;						;	FD56
;	FCB	"teve Furber,Jon Gibbons,Andrew ";	FD5D
;						;	FD65
;						;	FD6D
;						;	FD75
;	FCB	"Gordon,Lawrence Hardwick,Dylan ";	FD7C
;						;	FD84
;						;	FD8C
;						;	FD94
;	FCB	"Harris,Hermann Hauser,Hitachi,A";	FD9B
;						;	FDA3
;						;	FDAB
;						;	FDB3
;	FCB	"ndy Hopper,ICL,Martin Jackson,B";	FDBA
;						;	FDC2
;						;	FDCA
;						;	FDD2
;	FCB	"rian Jones,Chris Jordan,David K";	FDD9
;						;	FDE1
;						;	FDE9
;						;	FDF1
;	FCB	"ing,Da"			;	FDF8
;LFDFE:	FCB	"vi"				;	FDFE
;sheila_CRTC_reg:
;	FCB	"d"				;	FE00
;sheila_CRTC_rw:
;	FCB	" Kitson"			;	FE01
;LFE08:	FCB	","				;	FE08
;LFE09:	FCB	"Paul Kr"			;	FE09
;LFE10:	FCB	"iwaczek,Computer"		;	FE10
;						;	FE18
;sheila_VIDULA_ctl:
;	FCB	" "				;	FE20
;sheila_VIDULA_pal:
;	FCB	"Laboratory,Pete"		;	FE21
;						;	FE29
;SHEILA_ROMCTL_SWR:	FCB	"r Miller,Arthur "		;	FE30
;						;	FE38
;sheila_SYSVIA_orb:
;	FCB	"N"				;	FE40
;sheila_SYSVIA_ora:
;	FCB	"o"				;	FE41
;sheila_SYSVIA_ddrb:
;	FCB	"r"				;	FE42
;sheila_SYSVIA_ddra:
;	FCB	"m"				;	FE43
;sheila_SYSVIA_t1cl:
;	FCB	"a"				;	FE44
;sheila_SYSVIA_t1ch:
;	FCB	"n"				;	FE45
;sheila_SYSVIA_t1ll:
;	FCB	","				;	FE46
;sheila_SYSVIA_t1lh:
;	FCB	"G"				;	FE47
;sheila_SYSVIA_t2cl:
;	FCB	"l"				;	FE48
;sheila_SYSVIA_t2ch:
;	FCB	"y"				;	FE49
;sheila_SYSVIA_sr:
;	FCB	"n"				;	FE4A
;sheila_SYSVIA_acr:
;	FCB	" "				;	FE4B
;sheila_SYSVIA_pcr:
;	FCB	"P"				;	FE4C
;sheila_SYSVIA_ifr:
;	FCB	"h"				;	FE4D
;sheila_SYSVIA_ier:
;	FCB	"i"				;	FE4E
;sheila_SYSVIA_ora_nh:
;	FCB	"llips,Mike Prees,"		;	FE4F
;						;	FE57
;						;	FE5F
;sheila_USRVIA_orb:
;	FCB	"J"				;	FE60
;sheila_USRVIA_ora:
;	FCB	"o"				;	FE61
;sheila_USRVIA_ddrb:
;	FCB	"h"				;	FE62
;sheila_USRVIA_ddra:
;	FCB	"n"				;	FE63
;sheila_USRVIA_t1cl:
;	FCB	" "				;	FE64
;sheila_USRVIA_t1ch:
;	FCB	"R"				;	FE65
;sheila_USRVIA_t1ll:
;	FCB	"a"				;	FE66
;sheila_USRVIA_t1lh:
;	FCB	"d"				;	FE67
;sheila_USRVIA_t2cl:
;	FCB	"c"				;	FE68
;sheila_USRVIA_t2ch:
;	FCB	"l"				;	FE69
;sheila_USRVIA_sr:
;	FCB	"i"				;	FE6A
;sheila_USRVIA_acr:
;	FCB	"f"				;	FE6B
;sheila_USRVIA_pcr:
;	FCB	"f"				;	FE6C
;sheila_USRVIA_ifr:
;	FCB	"e"				;	FE6D
;sheila_USRVIA_ier:
;	FCB	","				;	FE6E
;sheila_USRVIA_ora_nh:
;	FCB	"Wilberforce Road,Peter Robinson";	FE6F
;						;	FE77
;						;	FE7F
;						;	FE87
;	FCB	",Richard Russell,Kim Spence-Jon";	FE8E
;						;	FE96
;						;	FE9E
;						;	FEA6
;	FCB	"es,Graham Tebby,Jon"		;	FEAD
;						;	FEB5
;						;	FEBD
;LFEC0:	FCB	" "				;	FEC0
;LFEC1:	FCB	"T"				;	FEC1
;LFEC2:	FCB	"hackray,Chris Turner,Adrian Wa";	FEC2
;						;	FECA
;						;	FED2
;						;	FEDA
;LFEE0:	FCB	"rner,"				;	FEE0
;LFEE5:	FCB	"Roger Wilson,Alan Wright."	;	FEE5
;						;	FEED
;						;	FEF5
;						;	FEFD
;	FCB	$CD,$D9				;	FEFE
		ORG	$FF00
;; ----------------------------------------------------------------------------
;; EXTENDED VECTOR ENTRY POINTS; vectors are pointed to &F000 +vector No. vectors may then be directed thru  
; a three byte vector table whose address is given by osbyte A8, X=0, Y=&FF 
; this is set up as lo-hi byte in ROM and ROM number	 
;x_EXTENDED_VECTOR_ENTRY_POINTS
	jsr	x_enter_extended_vector			;Extended USERV
	jsr	x_enter_extended_vector			;Extended BRKV
	jsr	x_enter_extended_vector			;Extended IRQ1V
	jsr	x_enter_extended_vector			;Extended IRQ2V
	jsr	x_enter_extended_vector			;Extended CLIV
	jsr	x_enter_extended_vector			;Extended BYTEV
	jsr	x_enter_extended_vector			;Extended WORDV
	jsr	x_enter_extended_vector			;Extended WRCHV
	jsr	x_enter_extended_vector			;Extended RDCHV
	jsr	x_enter_extended_vector			;Extended FILEV
	jsr	x_enter_extended_vector			;Extended ARGSV
	jsr	x_enter_extended_vector			;Extended BGETV
	jsr	x_enter_extended_vector			;Extended BPUTV
	jsr	x_enter_extended_vector			;Extended GBPBV
	jsr	x_enter_extended_vector			;Extended FINDV
	jsr	x_enter_extended_vector			;Extended FSCV
	jsr	x_enter_extended_vector			;Extended EVENTV
	jsr	x_enter_extended_vector			;Extended UPTV
	jsr	x_enter_extended_vector			;Extended NETV
	jsr	x_enter_extended_vector			;Extended VDUV
	jsr	x_enter_extended_vector			;Extended KEYV
	jsr	x_enter_extended_vector			;Extended INSV
	jsr	x_enter_extended_vector			;Extended REMV
	jsr	x_enter_extended_vector			;Extended CNPV
	jsr	x_enter_extended_vector			;Extended IND1V
	jsr	x_enter_extended_vector			;Extended IND2V
	jsr	x_enter_extended_vector			;Extended IND3V
x_enter_extended_vector	
	;at this point the stack will hold 4 bytes (at least)
	;S 0,1 extended vector address
	;S 2,3 address of calling routine
	;A,X,Y,P will be as at entry

	leas	-5,S				; reserve 7 bytes on the stack
	pshs	CC,B,X				; save 

	; stack now has
	;	12	Caller addr (lo)
	;	11	Caller addr (hi)
	;	10	Extended vector addr (lo)
	;	9	Extended vector addr (hi)
	;	8	?
	;	7	?
	;	6	?
	;	5	?
	;	4	?
	;	3	X (lo)
	;	2	X (hi)
	;	1	B
	;	0	CC

	ldx	#x_return_addess_from_ROM_indirection
	stx	6,S

	; stack now has
	;	12	Caller addr (lo)
	;	11	Caller addr (hi)
	;	10	Extended vector addr (lo)
	;	9	Extended vector addr (hi)
	;	8	?
	;	7	x_return_addess_from_ROM_indirection (lo)
	;	6	x_return_addess_from_ROM_indirection (hi)
	;	5	?
	;	4	?
	;	3	X (lo)
	;	2	X (hi)
	;	1	B
	;	0	CC

	ldb	zp_mos_curROM
	stb	8,S				; store current ROM on stack

	ldb	10,S				; get low byte of ext vector addr + 3
	ldx	#EXT_USERV - 3
	abx					; X now points at extended vector
	ldb	2,X				; get new rom #
	ldx	,X				; get routine address

	stx	4,S				; store as return address from this routine on stack

	; stack now has
	;	12	Caller addr (lo)
	;	11	Caller addr (hi)
	;	10	Extended vector addr (lo)
	;	9	Extended vector addr (hi)
	;	8	cur SWR#
	;	7	x_return_addess_from_ROM_indirection (lo)
	;	6	x_return_addess_from_ROM_indirection (hi)
	;	5	rom vector handle (lo)
	;	4	rom vector handle (hi)
	;	3	X (lo)
	;	2	X (hi)
	;	1	B
	;	0	CC


	stb	zp_mos_curROM			; Set OS copy and hardware
	stb	SHEILA_ROMCTL_SWR		; SWR #

	puls	CC,B,X,PC			; jump to ROM routine

;; ----------------------------------------------------------------------------
;; returnFDBess from ROM indirection; at this point stack comprises original ROM number,return from JSR &FF51, ; return from original call the return from FF51 is garbage so; 
x_return_addess_from_ROM_indirection

	; stack now has
	;	4	Caller addr (lo)
	;	3	Caller addr (hi)
	;	2	Extended vector addr (lo)
	;	1	Extended vector addr (hi)
	;	0	cur SWR#

	pshs	CC,B


	; stack now has
	;	6	Caller addr (lo)
	;	5	Caller addr (hi)
	;	4	Extended vector addr (lo)
	;	3	Extended vector addr (hi)
	;	2	cur SWR#
	;	1	B
	;	0	CC

	ldb	2,S				; get back saved SWR #
	stb	zp_mos_curROM			; reset MOS SWR #
	stb	SHEILA_ROMCTL_SWR		; and hardware
	puls	B,CC				; restore flags and B
	leas	3,S				; skip unwanted
dummy_vector_RTS				; LFFA6
	rts					;	FFA6
;; ----------------------------------------------------------------------------
;; OSBYTE &9D	FAST BPUT
;mos_OSBYTE_157:
;	txa					;	FFA7
;	bcs	OSBPUT				;	FFA8
;; OSBYTE &92	  READ A BYTE FROM FRED
;mos_OSBYTE_146:
;	ldy	LFC00,x				;	FFAA
;	rts					;	FFAD
;; ----------------------------------------------------------------------------
;; OSBYTE &94	  READ A BYTE FROM JIM;	 
;mos_OSBYTE_148:
;	ldy	LFD00,x				;	FFAE
;	rts					;	FFB1
;; ----------------------------------------------------------------------------
;; OSBYTE &96	  READ A BYTE FROM SHEILA;  
;mos_OSBYTE_150:
;	LDY	$FE00,X
;	RTS


	ORG	DOM_DEBUG_ENTRIES
_DEBUGPRINTNEWL	jmp	debug_print_newl		; FF8C
_DEBUGPRINTHEX	jmp	debug_print_hex			; FF8F
_DEBUGPRINTA	jmp	debug_print_ch			; FF92
_DEBUGPRINTX	jmp	debug_printX			; FF95


	ORG	JGH_OSENTRIESLOC
_OSRDRM		jmp	mos_get_SWROM_B_X_A_API		; FF98	!!! not same as Beeb
_PRSTRING	jmp	mos_PRSTRING			; FF9B
_OSEVEN		jmp	x_CAUSE_AN_EVENT		; FF9E	!!! not same as Beeb
_SCANHEX	jmp	jgh_SCANHEX			; FFA1
_RAWVDU		jmp	mos_VDU_WRCH			; FFA3	!!! not same as Beeb
_OSQUIT		jmp	jgh_OSQUIT			; FFA7
_PRHEX		jmp	jgh_PRHEX			; FFAA
_PR2HEX		jmp	jgh_PR2HEX			; FFAD
_USERINT	jmp	jgh_USERINT			; FFB0
_PRTEXT		jmp	mos_PRTEXT			; FFB3

	ORG	OSENTRIESLOC
VETAB_len
	FCB	vec_table_end-vec_table				;	FFB6
VETAB_addr
	FDB	vec_table			;	FFB7
;; ----------------------------------------------------------------------------
_CLICOM		jmp	jgh_CLICOM			;	FFB9
_ERRJMP		jmp	jgh_ERRJMP			;	FFBC
_OSINIT		jmp	jgh_OSINIT			;	FFBF
_GSINIT		jmp	mos_GSINIT			;	FFC2
_GSREAD		jmp	mos_GSREAD			;	FFC5
_OSRDCH_NV	jmp	mos_RDCHV_default_entry		;	FFC8
_OSWRCH_NV	jmp	mos_WRCH_default_entry		;	FFCB
_OSFIND		jmp	OSFIND_bounce			;	FFCE
_OSGBPB		jmp	OSGBPB_bounce			;	FFD1
_OSBPUT		jmp	OSBPUT_bounce			;	FFD4
_OSBGET		jmp	OSBGET_bounce			;	FFD7
_OSARGS		jmp	OSARGS_bounce			;	FFDA
_OSFILE		jmp	OSFILE_bounce			;	FFDD
_OSRDCH		jmp	OSRDCH_bounce			;	FFE0
_OSASCI		cmpa	#$0D				;	FFE3
		bne	OSWRCH				;	FFE5
_OSNEWL		lda	#$0A				;	FFE7
		jsr	OSWRCH_bounce			;	FFE9
		lda	#$0D				;	FFEC
_OSWRCH		jmp	OSWRCH_bounce			;	FFEE
_OSWORD		jmp	OSWORD_bounce			;	FFF1
_OSBYTE		jmp	OSBYTE_bounce			;	FFF4
_OSCLI		jmp	OSCLI_bounce			;	FFF7
		FCB	"Ishbel"			; this was the original vectors
