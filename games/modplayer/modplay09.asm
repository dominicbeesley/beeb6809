; (c) Modplay09.asm - a tracker module player for the 6x09 processor and the
; Dossytronics blitter board
;
; Loads a module split into M.XXX and 0.XXX, 1.XXX etc
; as created by the rip2blit.sh script
;
;

		include "../../includes/hardware.inc"
		include "../../includes/oslib.inc"
		include "../../includes/common.inc"
		include "../../includes/mosrom.inc"

MODULE_BASE	equ	$3C00
MODULE_SONG	equ	MODULE_BASE + $80
MODULE_PATTERNS	equ	MODULE_BASE + $100


		setdp 0

; direct page vars
		org $70
zp_note_ptr	rmb	2
zp_si_ptr	rmb	2				; sample info ptr	(used as text pointer when reading cmd line)
zp_cha_var_ptr	rmb	2
zp_tmp		rmb	4
zp_cha_ctr	rmb	1
zp_num1
;;zp_scr_ptr	rmb	2
zp_num2		rmb	2

zp_trk_tmp	rmb	5



; offsets into per - channel variables structure
cha_var_sn		equ 0; .byte		; 1	current sample #*8 (can be used as offs into sample info table)
cha_var_per		equ 1; .word		; 2
cha_var_porta_per	equ 3; .word		; 2
cha_var_porta_speed	equ 5; .byte		; 1
cha_var_vol		equ 6; .byte		; 1	current volume
cha_var_cmd		equ 7; .byte		; 1
cha_var_parm		equ 8; .byte		; 1
cha_var_s_len		equ 9; .word		; 2	; not order important as copied from sample info table
cha_var_s_roff		equ 11; .word		; 2
cha_var_s_addr_b	equ 13; .byte		; 3
cha_var_s_addr		equ 14; .word		; 3
cha_var_s_repfl		equ 16; .byte		; 1	>$80 for repeat (low 6 bits are sample vol)
cha_var_s_flags		equ 17; .byte		; 1	$80 = mute
cha_var_s_restart	equ 18;
cha_var_vib_pos		equ 19
cha_var_vib_cmd		equ 20
cha_vars_size		equ 21



		org $2000

		; change to mode 7
		lda	#22
		jsr	OSWRCH
		lda	#7
		jsr	OSWRCH

		; scan command line for module name
		lda	#OSARGS_cmdtail
		ldy	#0
		ldx	#zp_si_ptr - 2
		jsr	OSARGS

		; find last "." in filename (to replace with M,0,1,2,3,etc)
		ldy	zp_si_ptr
		ldu	#MODNAME
		ldx	#0
lp_sp		lda	,Y+
		cmpa	#' '
		beq	lp_sp
lp_fn		cmpa	#$D
		beq	sk_end
		cmpa	#' '
		beq	sk_end
		sta	,U+
		cmpa	#'.'
		bne	sk_d
		leax	-2,U
sk_d		lda	,Y+
		cmpy	#MODNAME_DIR
		blo	lp_fn
brk_bad
		DO_BRK	1, "Bad name [:X].M.NNNNNNN"
sk_end		lda	#$D
		sta	,U+
		stx	MODNAME_DIR
		beq	brk_bad
		cmpx	#MODNAME
		blo	brk_bad

		lda	,X
		anda	#$DF
		cmpa	#'M'
		bne	brk_bad

		ldx	#str_module
		jsr	printX

		ldx	#MODNAME
		jsr	printX

		clr	zp_note_ptr			; pointer to next area of blit memory (start at 0) (page hi)
		clr	zp_note_ptr+1			; (page lo)
		ldb	#'0'
		stb	zp_tmp
sample_load_loop
		stb	[MODNAME_DIR]

		jsr	load_mod_chunk
		bne	1F
		bra	samples_loaded
1		ldd	zp_note_ptr
		std	BLITSAMLOAD + 3
		leax	BLITSAMLOAD, PCR
		jsr	blit_copy

		ldd	zp_note_ptr
		addd	#$0040
		std	zp_note_ptr

		ldb	zp_tmp
		incb
		stb	zp_tmp
		cmpb	#'9'+1
		bne	sample_load_loop
		ldb	#'A'
		bra	sample_load_loop

load_mod_chunk
		; check file exists, if not return 
		ldx	#MODNAME
		stx	OSFILEBLK
		ldx	#OSFILEBLK
		lda	#OSFILE_CAT
		jsr	OSFILE
		tsta	
		beq	1F
		ldx	#str_col_modname
		jsr	printX
		; restore filename
		ldx	#MODNAME
		stx	OSFILEBLK
		jsr	printX
		jsr	OSNEWL
		lda	#$FF				; setup load addr
		sta	OSFILEBLK + 2
		sta	OSFILEBLK + 3
		ldx	#MODULE_BASE
		stx	OSFILEBLK + 4
		ldx	#OSFILEBLK
		lda	#OSFILE_LOAD
		jsr	OSFILE
1		rts

samples_loaded
		ldb	#'M'
		stb	[MODNAME_DIR]
		jsr	load_mod_chunk
		lbeq	brk_bad

		jsr	play_init
		bra	play_loop

handle_eventv	pshs	D,X,Y,U
		cmpa	#4
		bne	1F
		jsr	play_event
1		puls	D,X,Y,U
		jmp	[old_EVNTV]


;-------------------------------------------------------------
; tracker loop
;-------------------------------------------------------------
play_loop
		; wait for the player to execute
		SEI
		lda	g_flags
		anda	#$DF
		sta	g_flags
		CLI

		lda	#$20
1		bita	g_flags
		beq	1B

		jsr	track_disp

		; keyboard

		ldx	#0
		ldy	#0
		lda	#$81
		jsr	OSBYTE
		bcs	nokeys
		tfr	X,D
		ldx	#keyfntab
klkuploop	cmpb	,X+
		bne	1F
		jsr	[,X]
		bra	donekey
1		leax	2,X
		cmpx	#keyfntabend
		blo	klkuploop

nokeys
		cmpy	#27
		bne	donekey

		SEI
		ldx	old_EVNTV
		stx	EVNTV
		CLI

		jsr	silence

		lda	#$7E		; ack escape
		DO_BRK	27, "ESCAPE", 0
donekey

		bra	play_loop

silence		ldb	#3
1		stb	sheila_DMAC_SND_SEL
		clr	sheila_DMAC_SND_STATUS
		decb
		bpl	1B
		rts

;-------------------------------------------------------------
; Init tracker variables
;-------------------------------------------------------------


play_init
		ldb	#$FF
		stb	g_song_pos
		stb	g_pat_brk
		incb
		stb	g_pat_rep
		stb	g_tick_ctr
		stb	g_arp_tick
		stb	g_flags
		ldb	#7
		stb	g_speed
		decb	
		stb	g_tick_ctr
		ldb	#63
		stb	g_row_pos

		; zero all cha_vars
		ldb	#(cha_vars_size*4)-1
		lda	#0
		leax	cha_vars,PCR
1		sta	,X+
		decb
		bpl	1B

		ldx	EVNTV
		stx	old_EVNTV

		leax	handle_eventv,PCR
		stx	EVNTV				; naughty, should really preserve any previous here

		lda	#14
		ldx	#4
		jsr	OSBYTE				; enable events
		rts


play_key_song_prev
		dec	g_song_pos		
		clr	g_song_skip
		bra	restart_thispat
play_key_song_next
		inc	g_song_pos		
		clr	g_song_skip
		bra	restart_thispat

;-------------------------------------------------------------
; event driven player, call this 50 times a second
;-------------------------------------------------------------
play_event

		lda	#$40
		bita	g_flags
		beq	1F
		lbra	debug_display			; key_pause (don't play)

1

		inc	g_tick_ctr
		ldb	g_tick_ctr
		cmpb	g_speed
		lblo	play_skip_no_read_row	
		clr	g_tick_ctr
		clr	g_arp_tick

		; check for next/prev song keys
		lda	#$40
		bita	g_song_skip
		bne	play_key_song_prev
		lda	#$80
		bita	g_song_skip
		bne	play_key_song_next

		ldb	g_pat_brk
		bmi	1F
		stb	g_row_pos			; had a pattern break, jump to specified row in next pattern
		com	g_pat_brk			; invert to flag done
		bra	2F
1		inc	g_row_pos
		ldb	g_row_pos
		cmpb	#64
		blo	sk_no_next_patt
		clr	g_row_pos
		; move to next pattern
2		tst	g_pat_rep
		bne	restart_thispat

		inc	g_song_pos
		; TODO - end of song detect / loop
restart_thispat	lda	g_song_pos
restart		jsr	lookup_song
		sta	g_pattern
		bpl	skrestart
		;jsr	silence
		clra
		sta	g_song_pos
		bra	restart
skrestart	jsr	start_pattern
sk_no_next_patt
		ldx	#cha_vars
		stx	zp_cha_var_ptr
		clr	zp_cha_ctr
channel_loop	ldb	zp_cha_ctr
		stb	sheila_DMAC_SND_SEL
		ldy	zp_note_ptr
		clr	cha_var_s_restart,X		; this gets set if theres a period or sample
		; get sample #
		lda	2,Y
		anda	#$F0
		beq	sk_samno
		lsra
		sta	cha_var_sn,X
		ldu	#MODULE_BASE
		leau	A,U
		; copy sample data to vars
		ldb	#cha_var_s_len
cplp		lda	,U+				; sample info table
		sta	B,X
		incb
		cmpb	#cha_var_s_repfl + 1
		bne	cplp
		anda	#$3F
		sta	cha_var_vol,X
		dec	cha_var_s_restart,X

sk_samno	; save command and params in channel vars
		lda	2,Y
		anda	#$0F
		sta	cha_var_cmd,X
		lda	3,Y
		sta	cha_var_parm,X

		; check to see if there's a period
		lda	0,Y
		anda	#$0F
		sta	tmp_note_per

		lda	1,Y
		sta	tmp_note_per + 1
		ora	tmp_note_per

		beq	sk_period

		;;;TODO: check fine tune effect and modify perdiod
		lda	cha_var_cmd,X

		cmpa	#3
		beq	setporta
		cmpa	#5
		beq	setporta

		ldd	tmp_note_per
		std	cha_var_per,X
		clr	cha_var_vib_pos,X

sk_period	tst	cha_var_s_restart,X
		beq	sk_nosample
		;;;TODO: check cmd 9 - sample offset - not supported by easy hardware?

		lda	cha_var_sn,X
		beq	sk_nosample			; no sample info set

		; stop current sample
		clr	sheila_DMAC_SND_STATUS

		jsr	set_p_period
		dec	cha_var_s_restart,X


		ldd	cha_var_s_len,X
		std	sheila_DMAC_SND_LEN
		
		ldd	cha_var_s_roff,X
		std	sheila_DMAC_SND_REPOFF
		
		lda	cha_var_s_addr_b,X
		anda	#$0F				; blank out finetune
		sta	sheila_DMAC_SND_ADDR
		ldd	cha_var_s_addr_b+1,X
		std	sheila_DMAC_SND_ADDR + 1
		lda	cha_var_s_repfl,X
		rola					; get repeat flag into bit 0
		rola
		anda	#1
		ora	#$80
		sta	sheila_DMAC_SND_STATUS
sk_nosample	jsr	check_more_effects
		jsr	set_p_vol
		leay	4,Y
		sty	zp_note_ptr
		inc	zp_cha_ctr
		ldb	zp_cha_ctr
		cmpb	#4
		lbeq	play_skip_no_read_row_done
		leax	cha_vars_size,X
		stx	zp_cha_var_ptr

		jmp	channel_loop

setporta	ldd	tmp_note_per
		std	cha_var_porta_per,X
		bra	sk_period

check_more_effects

		ldb	cha_var_parm,X
		lda	cha_var_cmd,X
		
		cmpa	#$C
		beq	more_effects_set_vol
		cmpa	#$F
		beq	more_effects_set_speed

		rts

more_effects_set_vol
		stb	cha_var_vol,X
		rts

more_effects_set_speed
		cmpb	#$20
		bhs	1F
		stb	g_speed
1		;;TODO: BPM
		rts

check_effects
		ldb	cha_var_parm,X
		lda	cha_var_cmd,X
		
		lbeq	do_arpeg
		cmpa	#$1
		beq	effects_porta_up
		cmpa	#$2
		beq	effects_porta_dn
		cmpa	#$3
		beq	effects_set_tone_porta
		cmpa	#$4
		beq	effects_vib
		cmpa	#$5
		beq	effects_tone_porta_vol_slide
		cmpa	#$6
		lbeq	effects_vib_vol_slide
		cmpa	#$A
		beq	effects_volume_slide
		cmpa	#$D
		beq	effects_pattern_break
		rts

effects_pattern_break
							; b contains pattern in bcd!
		pshs	b
		andb	#$F0
		lda	#10*16
		mul					; a now contains 10*((b and $F0)>>4)
		puls	b
		andb	#$0F
		pshs	a
		addb	,S+
		cmpb	#63
		bls	1F
		clrb
1		stb	g_pat_brk
		rts



effects_set_tone_porta
		tstb
		beq	1F
		stb	cha_var_porta_speed,X
1		lbra	do_tone_porta

effects_tone_porta_vol_slide
		jsr	do_tone_porta
		bra	effects_volume_slide

effects_porta_up
		clra
		std	zp_tmp
		ldd	cha_var_per,X
		subd	zp_tmp
		cmpd	#113
		bhs	1F
		ldd	#113
1		std	cha_var_per,X
		lbra	set_p_period

effects_porta_dn
		clra
		addd	cha_var_per,X
		bcc	1F
		ldd	#$FFFF
1		std	cha_var_per,X
		lbra	set_p_period



effects_volume_slide
		tfr	B,A
		anda	#$F0
		bne	effects_volume_slide_up
		tfr	B,A		
		anda	#$0F
		beq	2F
		suba	cha_var_vol,X
		coma
		bpl	1F
		clra
1		sta	cha_var_vol,X
2		rts
effects_volume_slide_up
		lsra
		lsra
		lsra
		lsra
		adda	cha_var_vol,X
		cmpa	#63
		blo	1B
		lda	#63
		bra	1B

effects_vib						; TODO - always sine
		tfr	B,A
		anda	#$F0
		beq	1F				; don't set speed if not specd
		sta	,-S
		lda	cha_var_vib_cmd,X
		anda	#$0F
		ora	,S+
		sta	cha_var_vib_cmd,X
1		tfr	B,A
		anda	#$0F
		beq	1F				; don't set dept if not specd
		sta	,-S
		lda	cha_var_vib_cmd,X
		anda	#$F0
		ora	,S+
		sta	cha_var_vib_cmd,X
1		
effects_do_vib
		pshs	B,U
		; do the vibrato
		ldb	cha_var_vib_pos,X
		lsrb
		lsrb
		andb	#$1F				; make table index
		ldu	#vibtab
		ldb	B,U				; look up vib value
		lda	cha_var_vib_cmd,X
		anda	#$F
		mul					
		aslb
		rola					; A = tab value*depth/128
		tfr	A,B		
		tst	cha_var_vib_pos,X
		bmi	1F				; either add or subtract depending on sign 
		comb					; negate table value (make a 32 byte table into a 64 by symmetry)
1		sex					; make into a 16 bit number
		addd	cha_var_per, X
		jsr 	set_p_period_D

		ldb	cha_var_vib_cmd,X
		andb	#$F0
		lsrb
		lsrb
		addb	cha_var_vib_pos,X
		stb	cha_var_vib_pos,X



		puls	B,U,PC
effects_vib_vol_slide
		jsr	effects_do_vib
		bra	effects_volume_slide

;
;
play_skip_no_read_row_done
play_skip_no_read_row
		; we're not loading a new row, apply any "current" effects

		ldx	#cha_vars
		stx	zp_cha_var_ptr
		ldb	#0
		stb	zp_cha_ctr
cha_loop
		ldb	zp_cha_ctr
		stb	sheila_DMAC_SND_SEL
		jsr	check_effects

		jsr	set_p_vol


		inc	zp_cha_ctr
		ldb	zp_cha_ctr
		cmpb	#4
		beq	sk_cha_loop_done
		leax	cha_vars_size,X
		stx	zp_cha_var_ptr

		bra	cha_loop
sk_cha_loop_done
		inc	g_arp_tick
		ldb	g_arp_tick
		cmpb	#3
		blo	1F
		clr	g_arp_tick
1		



;--------------------------------------------------
; debugger display
;--------------------------------------------------
debug_display
		ldu	#$7ED0

		ldx	#g_start
		ldb	#g_size
1		lda	,X+
		jsr	PrHexA
		decb
		bne	1B

		lda	#4
		sta	zp_tmp
		ldx	#cha_vars
		ldu	#$7EF8				; screen pointer
		
cvclp		ldb	#cha_vars_size
cl2		lda	,X+
		jsr	PrHexA
		decb
		bne	cl2
		dec	zp_tmp
		beq	sk_dispdone
		leau	(40-(cha_vars_size*2)),U
		bra	cvclp
sk_dispdone

		lda	#$20
		ora	g_flags
		sta	g_flags

		rts




;--------------------------------------------------
; tracker display
;--------------------------------------------------

track_disp
		ldu	#$7C00
		ldb	#15
		stb	zp_trk_tmp			; line counter
		ldb	g_row_pos
		subb	#7
		stb	zp_trk_tmp+1			; current row #
		addb	#7
		lda	#16
		mul
		addd	g_pat_bas
		subd	#16*7
		tfr	D,Y

track_dlp	lda	zp_trk_tmp+1
		bmi	track_blank_line
		cmpa	#64
		bhs	track_blank_line
		ldb	zp_trk_tmp
		cmpb	#8
		jsr	track_line
track_cnt	inc	zp_trk_tmp+1
		dec	zp_trk_tmp
		bne	track_dlp

		rts

track_blank_line
		ldb	#40
		lda	#' '
1		sta	,U+
		decb
		bne	1B
		leay	16,Y		
		bra	track_cnt


	; displays a track line at u, taking notes from Y
	; a contains the row #
track_line		
		pshs	A
		beq	1F
		lda	#$82
		bra	2F
1		lda	#$81
2		jsr	PrA
		puls	A
		jsr	PrHexA
		ldb	#3				; channel counter
		stb	zp_trk_tmp+2

track_lp	lda	#' '
		jsr	PrA
		ldd	0,Y
		anda	#$0F
		jsr	PrNote				; note
		lda	#' '
		jsr	PrA
		lda	2,Y
		jsr	PrHexA
		lda	3,Y
		jsr	PrHexA		
		leay	4,Y
		dec	zp_trk_tmp+2	
		bpl	track_lp
		lda	#' '
		sta	,U+
		rts


PrNote		pshs	D
		cmpd	#113
		blo	PrNoNote
		cmpd	#$400
		bhs	PrNoNote
		ldb	#3
		stb	zp_trk_tmp+3			; octave
prnotelp	ldb	#12
		stb	zp_trk_tmp+4			; semitones in an octave	
		leax	pertab,PCR
		ldd	,S
		cmpd	,X++
		bhi	PrNoteOct
prnotelp2	cmpd	,X++
		bhs	PrNoteF
		dec	zp_trk_tmp+4
		bpl	prnotelp2

PrNoNote	lda	#'-'
		sta	,U+
		sta	,U+
		sta	,U+
		puls	D
		rts

PrNoteOct						; too high try next octave
		lsra
		rorb
		std	,S
		dec	zp_trk_tmp+3
		bne	prnotelp

PrNoteF		leas	2,S				; reset stack
		ldb	#12
		subb	zp_trk_tmp+4
		aslb
		leax	nottab,PCR
		abx
		lda	,X+
		sta	,U+
		lda	,X+
		sta	,U+
		lda	zp_trk_tmp+3
		jmp	PrNybble






set_p_period
		ldd	cha_var_per,X
set_p_period_D
		cmpd	#113
		blo	3F
ok		std	sheila_DMAC_SND_PERIOD
3		rts
;
do_arpeg
		lda	g_arp_tick
		beq	arp0
		cmpa	#1
		beq	arp1
		andb	#$0F
		beq	arp0
		aslb
		
arpatB		leau	semitones,PCR
		ldd	B,U
		std	zp_num2
		ldd	cha_var_per,X
		std	zp_num1 
		jsr	mul16

		ldd	zp_tmp
		std	sheila_DMAC_SND_PERIOD
		rts

arp1		
		andb	#$F0
		beq	arp0
		lsrb
		lsrb
		lsrb
		bra	@arpatA
;
arp0		jmp	set_p_period		; (re)set to stored period
;
;
;
set_p_vol
		lda	cha_var_s_flags,X
		bmi	mute
		lda	cha_var_vol,X
		asla
		asla
1		sta	sheila_DMAC_SND_VOL
		rts
mute		clra
		bra	1B
;
do_tone_porta
		ldd	cha_var_porta_per,X
		std	tmp_note_porta							
		bne	doit				; check that we have a target period
		rts
doit
		ldd	cha_var_per,X			;get note porta / per to tmp vars
		std	tmp_note_per			; check direction
		jsr	check_porta_dir
		beq	done
		blo	down				; CC if porta > per
		; subtract speed
		lda	tmp_note_per + 1
		suba	cha_var_porta_speed,X
		sta	tmp_note_per + 1
		lda	tmp_note_per
		sbca	#0
		sta	tmp_note_per
		; check for overflow
		jsr	check_porta_dir
		bhi	exitnotover			; not overflowed
		; store porta period and we're done
spp_done	jsr	store_porta_per
done		clr	cha_var_porta_per,X
		clr	cha_var_porta_per+1,X
		bra	spr
		; store updated period in vars and exit
exitnotover	jsr	store_tmp_per
spr		jsr	set_p_period
		rts

down
		; add speed
		lda	tmp_note_per + 1
		adda	cha_var_porta_speed,X
		sta	tmp_note_per + 1
		lda	tmp_note_per
		adca	#0
		sta	tmp_note_per
		; check for overflow
		jsr	check_porta_dir
		blo	exitnotover		; not overflowed
		bra	spp_done

	; will return Z if tmp_note_porta == tmp_note_per
	; else CS if porta < per
	; else CC if porta > per
check_porta_dir
		; check direction
		; subtract wanted from curent ; note BE
		ldd	tmp_note_per
		subd	tmp_note_porta
s1		rts



store_tmp_per	ldd	tmp_note_per
		std	cha_var_per,X
		rts

store_porta_per
		ldd	tmp_note_porta
		std	cha_var_per,X
		rts


; A = position
; return:
;	A = pattern #
lookup_song
		; TODO: check against length and restart?!
		anda	#$7F
		ldx	#MODULE_SONG
		lda	A,X
		rts
; A = pattern #
; return:
; 	zp_note_ptr -> 1st row of pattern
;	A = 0
;	Z
start_pattern
		asla
		asla
		adda	#MODULE_PATTERNS/$100
		clrb
		std	g_pat_bas
		lda	#16
		ldb	g_row_pos
		mul
		addd	g_pat_bas
		std	zp_note_ptr
		rts
;
;
;PRTXT:		stx	zp_si_ptr
;		sty	zp_si_ptr + 1
;		ldy	#0
;@l:		lda	(zp_si_ptr),Y
;		beq	@r
;		jsr	OSASCI
;		iny
;		bne	@l
;@r:		rts
;
;PRIM:		pla
;		sta	zp_si_ptr
;		pla
;		sta	zp_si_ptr + 1
;		ldy	#1
;@l:		lda	(zp_si_ptr),Y
;		beq	@r
;		jsr	OSASCI
;		iny
;		bne	@l
;		brk
;		.byte 2, "String over", 0
;@r:		iny
;		tya
;		adc	zp_si_ptr
;		sta	zp_si_ptr
;		lda	#0
;		adc	zp_si_ptr + 1
;		sta	zp_si_ptr + 1
;		jmp	(zp_si_ptr)              ; Jump back to code after string
;
PrHexA		pshs	A
		LSRA
		LSRA
		LSRA
		LSRA
		JSR 	PrNybble
		puls	A
PrNybble	ANDA	#15
		CMPA	#10
		blo	PrDigit
		ADDA	#7
PrDigit		ADDA	#'0'
PrA		sta	,U+
		rts
PrSp		lda	#' '
		bra	PrA

key_mute_cha_0
		lda	#0
		jmp	mute_cha_A
key_mute_cha_1
		lda	#1
		jmp	mute_cha_A
key_mute_cha_2
		lda	#2
		jmp	mute_cha_A
key_mute_cha_3
		lda	#3
mute_cha_A	ldb	#cha_vars_size
		mul
		leax	cha_vars,PCR
		leax	D,X
		lda	cha_var_s_flags,X
		eora	#$80
		sta	cha_var_s_flags,X
		rts
key_pause	lda	#$40
		eora	g_flags
		sta	g_flags
		rts

key_pattern_rep	lda	#$FF
		sta	g_pat_rep
		rts

key_song_next	lda	#$80
		sta	g_song_skip
		rts

key_song_prev	lda	#$40
		sta	g_song_skip
		rts

key_faster	dec	g_speed
		bne	1F
		inc	g_speed
1		rts


key_slower	inc	g_speed
		bne	1F
		dec	g_speed
1		rts


;
;		; mul16 using 8 bit unsigned muls
;		; zp_tmp <= zp_num1 * zp_num2
;
;		      a b
;		    * c d
;		=========
;		     bdbd
;		   adad
;		   cbcb
;		 acac
mul16
		clr	zp_tmp
		clr	zp_tmp + 1

		lda	zp_num1 + 1			; b
		ldb	zp_num2 + 1			; d
		mul
		std	zp_tmp + 2
		
		lda	zp_num1				; a
		ldb	zp_num2 + 1			; d
		mul
		addd	zp_tmp + 1
		std	zp_tmp + 1
		bcc	1F
		inc	zp_tmp
1
		lda	zp_num1 + 1			; b
		ldb	zp_num2				; c
		mul
		addd	zp_tmp + 1
		std	zp_tmp + 1
		bcc	1F
		inc	zp_tmp
1
		lda	zp_num1				; a
		ldb	zp_num2				; c
		mul
		addd	zp_tmp
		std	zp_tmp
		rts


;===============================================
; blit_copy
; Note: the 6502 version has this as little 
; endian
; On entry:
;	X => 
;		+0	src addr bank
;		+1	src addr hi
;		+2	src addr lo
;		+3	dest addr bank
;		+4	dest addr hi
;		+5	dest addr lo
;		+6	length hi
;		+7	length lo
; On exit:
;	A,B,X,Y => destroyed
; runs the blit
blit_copy
		lda	#$CC				; copy B to D, ignore A, C	FUNCGEN
		sta	sheila_DMAC_FUNCGEN
		ldy	#sheila_DMAC_ADDR_B
		jsr	_blit_rd_bloc_be24
		ldy	#sheila_DMAC_ADDR_D
		jsr	_blit_rd_bloc_be24
		ldb	#0
		stb	sheila_DMAC_HEIGHT
		; stride B / D to $100
		stb	sheila_DMAC_STRIDE_B + 1	; lo
		stb	sheila_DMAC_STRIDE_D + 1	; lo
		incb
		stb	sheila_DMAC_STRIDE_B		; hi
		stb	sheila_DMAC_STRIDE_D		; hi


		jsr	_blit_rd_bloc			; how many pages?
		beq	blit_copy_sk1
		; do full pages
		deca
		sta	sheila_DMAC_HEIGHT
		lda	#$FF
		sta	sheila_DMAC_WIDTH
		jsr	blit_copy_ex
blit_copy_sk1	jsr	_blit_rd_bloc
		beq	blit_copy_sk2			; the are no part pages to copy
		deca
		sta	sheila_DMAC_WIDTH
		lda	#$0				; 256 width
		sta	sheila_DMAC_HEIGHT		; pages
blit_copy_ex	lda	#$0A				; execD, execB	BLTCON
		sta	sheila_DMAC_BLITCON		
		lda	#$80				
		sta	sheila_DMAC_BLITCON		; exec, lin, mode 0
blit_copy_sk2	rts

_blit_rd_bloc
		lda	,X+
		sta	,Y+
		rts
_blit_rd_bloc_be24
		lda	,X+
		sta	,Y+
		ldd	,X++
		std	,Y++
		rts


printX		lda	,X+
		beq	1F
		jsr	OSASCI
		bra	printX
1		rts

		; fixed point semitones (16 bits), missing 0th as always equal
		; used by arpeggio
semitones	fdb	0
		fdb	$F1A1		; 0.943874
		fdb	$E411		; 0.890899
		fdb	$D744		; 0.840896
		fdb	$CB2F		; 0.793701
		fdb	$BFC8		; 0.749154
		fdb	$B504		; 0.707107
		fdb	$AADC		; 0.66742
		fdb	$A145		; 0.629961
		fdb	$9837		; 0.594604
		fdb	$8FAC		; 0.561231
		fdb	$879C		; 0.529732
		fdb	$8000		; 0.5
		fdb	$78D0		; 0.471937
		fdb	$7208		; 0.445449
		fdb	$6BA2		; 0.420448
		fdb	$6597		; 0.39685

keyfntab	fcb	'1'
		fdb	key_mute_cha_0
		fcb	'2'
		fdb	key_mute_cha_1
		fcb	'3'
		fdb	key_mute_cha_2
		fcb	'4'
		fdb	key_mute_cha_3
		fcb	' '
		fdb	key_pause
		fcb	'P'
		fdb	key_pattern_rep
		fcb	']'
		fdb	key_song_next
		fcb	'['
		fdb	key_song_prev
		fcb	'F'
		fdb	key_faster
		fcb	'S'
		fdb	key_slower
keyfntabend	
;			    214,202,190,180,170,160,151,143,135,127,120,113
pertab		fdb	220,208,196,185,175,165,156,147,139,131,124,117,111
nottab		fcb	"C-C",223,"D-D",223,"E-F-F",223,"G-G",223,"A-A",223,"B-"

vibtab		fcb    $00, $18, $31, $4A, $61, $78, $8D, $A1,
		fcb    $B4, $C5, $D4, $E0, $EB, $F4, $FA, $FD,
		fcb    $FF, $FD, $FA, $F4, $EB, $E0, $D4, $C5,
		fcb    $B4, $A1, $8D, $78, $61, $4A, $31, $18


OSFILEBLK	fdb	MODNAME
		rzb	$10
BLITSAMLOAD	fcb	$FF
		fdb	MODULE_BASE		; src		
		fcb	0
		fdb	0			; dest
		fdb	$4000			; len
MODNAME		rzb	$30
MODNAME_DIR	rzb	$2

tmp_note_per	rzb	2
tmp_note_porta	rzb	2
tmp_note_cmd	rzb	1

old_EVNTV	rzb	2

g_start
g_speed		rzb	1
g_song_pos	rzb	1
g_pattern	rzb	1
g_tick_ctr	rzb	1
g_row_pos	rzb	1
g_arp_tick	rzb	1
g_flags		rzb	1			; $40 = key_pause; $20 set at end of a vsync (can be reset in calling loop)
g_pat_bas	rzb	2
g_pat_brk	rzb	1			; when not $FF indicates a pending pattern break
g_pat_rep	rzb	1
g_song_skip	rzb	1
g_end
g_size		equ	g_end-g_start



cha_vars
cha_0_vars	rzb	cha_vars_size
cha_1_vars	rzb	cha_vars_size
cha_2_vars	rzb	cha_vars_size
cha_3_vars	rzb	cha_vars_size

str_module	fcb	"Module ", 0
str_col_modname fcb	$81,":",$82,0