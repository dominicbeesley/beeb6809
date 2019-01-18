; (c) 2018 Modplay09.asm - a tracker module player for the 6x09 processor and 
; the Dossytronics blitter board 
;
; Plays full protrackers so long as the samples are <65536 bytes and the 
; whole mod is <512K

;===============================================================================
; Build parameters
;===============================================================================
BUILD_TIMER_VSYNC	EQU	0			; when 1 uses EVENT 4 vsync, else uses user 
							; via timer1 which allowes tempo adjustment



		include "../../includes/hardware.inc"
		include "../../includes/oslib.inc"
		include "../../includes/common.inc"
		include "../../includes/mosrom.inc"

		include "modplay.inc"

		setdp 0

; direct page vars
		org $70
zp_note_ptr	rmb	2
zp_si_ptr	rmb	2				; sample info ptr	(used as text pointer when reading cmd line)
zp_cha_var_ptr	rmb	2
zp_cha_ctr	rmb	1
zp_tmp		rmb	4
zp_num1		rmb	2
zp_num2		rmb	2

zp_d24_remain		EQU zp_tmp				; remainder of 24x8 divide
zp_d24_dividend		EQU zp_tmp+2				; result of 24x8 divide
zp_d24_divisor16	EQU zp_tmp+5				; the 8 bit divisor



; tracker display
zp_disp_lin_ctr	rmb	1
zp_disp_row_num	rmb	1
zp_disp_tmp	rmb	1
zp_disp_per	rmb	2
zp_disp_oct	rmb	1
zp_disp_cha_ctr rmb	1

		org $2000
modplay_start
		; scan command line for module name
		lda	#OSARGS_cmdtail
		ldy	#0
		ldx	#zp_si_ptr - 2
		OSCALL	OSARGS
		bra	1F
modplay_debug
		ldx	zp_mos_txtptr
		stx	zp_si_ptr

1		; change to mode 7
		lda	#22
		OSCALL	OSWRCH
		lda	#7
		OSCALL	OSWRCH

		ldx	zp_si_ptr			; command line address
		lda	#MODULE_BASE/256		; base of module load area
		ldb	#LOAD_BLOCK_SIZE		; # of pages to laod at once
		lbsr	mod_load

		jsr	play_init
		jsr	play_loop
		DO_BRK	5, "How did this happen!"

	IF BUILD_TIMER_VSYNC
handle_EVENTV	pshs	D,X,Y,U
		cmpa	#4
		bne	1F
		jsr	play_event
1		puls	D,X,Y,U
		jmp	[old_EVNTV]
	ELSE
handle_IRQ2V
		; do check first
		lda	#VIA_IFR_BIT_T1
		bita	sheila_USRVIA_ifr
		beq	irq2v_sk_no_t1

		; clear interrupt
		lda	sheila_USRVIA_t1cl
		jsr	play_event

irq2v_sk_no_t1	jmp	[old_IRQ2V]		
	ENDIF

;-------------------------------------------------------------
; tracker loop
;-------------------------------------------------------------
play_loop
		; wait for the player to execute
		SEI
		lda	g_flags
		anda	#FLAGS_EXEC^$FF
		sta	g_flags
		CLI

		lda	#FLAGS_EXEC
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

		jsr	play_exit

		lda	#OSBYTE_126_ESCAPE_ACK		; ack escape
		jsr	OSBYTE

		DO_BRK	27, "ESCAPE", 0
donekey

		bra	play_loop

silence		ldb	#3
1		stb	sheila_DMAC_SND_SEL
		clr	sheila_DMAC_SND_STATUS
		decb
		bpl	1B
		rts

play_exit
	IF BUILD_TIMER_VSYNC

		lda	#OSBYTE_13_DISABLE_EVENT
		ldx	#EVENT_NUM_4_VSYNC
		jsr	OSBYTE

		pshs	CC
		SEI
		ldx	old_EVNTV
		stx	EVNTV
		puls	CC

	ELSE
		pshs	CC
		SEI

		lda	#VIA_IFR_BIT_T1
		sta	sheila_USRVIA_ier		; turn off T1 interrupts

		ldx	old_IRQ2V
		stx	IRQ2V

		puls	CC

	ENDIF
		jsr	silence
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
		stb	g_arp_tick
		stb	g_flags
		ldb	#6
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

		pshs	CC
		SEI
	IF BUILD_TIMER_VSYNC
		ldx	EVNTV
		stx	old_EVNTV

		leax	handle_EVENTV,PCR
		stx	EVNTV				

		lda	#OSBYTE_14_ENABLE_EVENT
		ldx	#EVENT_NUM_4_VSYNC
		jsr	OSBYTE				; enable events
	ELSE
		ldx	IRQ2V
		stx	old_IRQ2V

		ldx	#handle_IRQ2V
		stx	IRQ2V

		; setup User VIA T1 to generate interrupts

		ldb	#125
		jsr	more_effects_set_tempo		; set default temp to 125

		lda	sheila_USRVIA_acr
		anda	#$3F
		ora	#$40
		sta	sheila_USRVIA_acr		; T1 free run mode

		lda	#VIA_IFR_BIT_T1 + VIA_IFR_BIT_ANY
		sta	sheila_USRVIA_ier		 ;enable T1 interrupt

	ENDIF
		puls	CC,PC


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

		lda	#FLAGS_key_pause
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

		; save peak and reset
		lda	sheila_DMAC_SND_PEAK
		sta	cha_var_peak,X
		clr	sheila_DMAC_SND_PEAK		; reset


		ldy	zp_note_ptr
		clr	cha_var_s_restart,X		; this gets set if theres a period or sample
		; get sample #

		lda	0,Y
		rola					; get top bit of sample # in Cy
		rola
		rola
		rola

		ldb	2,Y				
		andb	#$F0				; sample no 
		rorb					; A = samno * 8
		beq	sk_samno

		stb	cha_var_sn,X
		clra
		ldu	#sam_data
		leau	D,U				; U is address of sample info
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

		; check for finetune
		lda	cha_var_s_addr_b,X
		anda	#$F0				; get sample fintune
		beq	nofinetune

		lsra
		lsra
		lsra					; finetune * 2 (ptr into table)
		leau	finetunetab,PCR
		ldd	A,U				; A won't overflow -ve get finetune
		std	zp_num1

		ldd	tmp_note_per			; big endian!
		std	zp_num2

		jsr	mul16

		rol	zp_tmp+2
		ldd	zp_tmp+0
		rold
		std	tmp_note_per			; big endian

nofinetune
		oim	#$FF, cha_var_s_restart, X	; restart sample

		lda	cha_var_cmd,X

		cmpa	#3
		lbeq	setporta
		cmpa	#5
		lbeq	setporta

		ldd	tmp_note_per
		std	cha_var_per,X
		clr	cha_var_vib_pos,X

sk_period	tst	cha_var_s_restart,X
		beq	sk_nosample

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
		sta	zp_tmp				; save repeat flag

;----------------------------------------------
; effect 9
;----------------------------------------------

		; check for effect #9 - sample offset
		lda	cha_var_cmd,X
		cmpa	#9
		bne	_sknosampleoffset

		lda	sheila_DMAC_SND_LEN
		suba	cha_var_parm,X
		bcs	sk_nosample			; past end don't play!
		sta	sheila_DMAC_SND_LEN

		; adjust repeat offset
		tst	zp_tmp
		bne	_sksampleoffset_norepl

		lda	sheila_DMAC_SND_REPOFF		; hi byte of repeat offset
		suba	cha_var_parm,X			; note Y and Cy already set above
		sta	sheila_DMAC_SND_REPOFF
		bcc	_sksampleoffset_norepl		; didn't make repeat offset go -ve

							; if we're here the note sample offset has overflowed the repeat offset
		clr	zp_tmp				; clear repeat flag

_sksampleoffset_norepl
		lda	sheila_DMAC_SND_ADDR+1
		adda	cha_var_parm,X
		sta	sheila_DMAC_SND_ADDR+1		
		bcc	1F
		inc	sheila_DMAC_SND_ADDR+0
1

_sknosampleoffset
		lda	zp_tmp				; get back repeat flag

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
		lbra	sk_period

check_more_effects

		ldb	cha_var_parm,X
		lda	cha_var_cmd,X
		
		cmpa	#$C
		beq	more_effects_set_vol
		cmpa	#$F
		beq	more_effects_set_speed

		rts

more_effects_set_vol
		cmpb	#$40
		blo	1F
		ldb	#$3F
1		stb	cha_var_vol,X
		rts

more_effects_set_speed
		cmpb	#$20
		bhs	more_effects_set_tempo
		stb	g_speed
		rts
more_effects_set_tempo
		clr	zp_d24_divisor16
		stb	zp_d24_divisor16+1		
		lda	#$26				; number here is LE 125*1000000/50 = 2,500,000 = $2625A0
		sta	zp_d24_dividend
		ldd	#$25A0
		std	zp_d24_dividend+1

		jsr	div24x16
		bvs	_sk_slow

		lda	zp_d24_dividend+2
		sta	sheila_USRVIA_t1cl
		lda	zp_d24_dividend+1
		sta	sheila_USRVIA_t1ch
		rts

_sk_slow	lda	#$FF
		sta	sheila_USRVIA_t1cl
		sta	sheila_USRVIA_t1ch
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
		nega
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
		beq	1F				; don't set depth if not specd
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
		ldu	#$7E80

		ldx	#g_start
		ldb	#g_size
1		lda	,X+
		jsr	FastPrHexA
		decb
		bne	1B

		lda	#4
		sta	zp_disp_tmp
		ldx	#cha_vars
		ldu	#$7EA8				; screen pointer
		
cvclp		ldb	#cha_vars_size
cl2		lda	,X+
		jsr	FastPrHexA
		decb
		bne	cl2

		; do vu bar chart
		lda	#$94
		jsr	FastPrA				; blue graphics
		ldb	-1,X				; get peak back from vars
		lsrb
		lsrb
		lsrb					; / 8
		beq	sk_vu_1
		cmpb	#$F
		bls	1F
		ldb	#$F
1		pshs	B
		lda	#$7F
vu_lp1		jsr	FastPrA
		decb	
		bne	vu_lp1
		puls	B
sk_vu_1		negb
		addb	#$0F
		beq	sk_vu_2
		lda	#','
vu_lp2		jsr	FastPrA
		decb	
		bne	vu_lp2
sk_vu_2


		dec	zp_disp_tmp
		beq	sk_dispdone
		leau	(80-(16 + cha_vars_size*2)),U
		bra	cvclp
sk_dispdone

		lda	#FLAGS_EXEC
		ora	g_flags
		sta	g_flags

		rts




;--------------------------------------------------
; tracker display
;--------------------------------------------------

track_disp
		ldu	#$7C00
		ldb	#15
		stb	zp_disp_lin_ctr			; line counter
		ldb	g_row_pos
		subb	#7
		stb	zp_disp_row_num		; current row #
		addb	#7
		lda	#16
		mul
		addd	#cur_patt_data
		subd	#16*7
		tfr	D,Y

track_dlp	lda	zp_disp_row_num
		bmi	track_blank_line
		cmpa	#64
		bhs	track_blank_line
		ldb	zp_disp_lin_ctr
		cmpb	#8
		jsr	track_line
track_cnt	inc	zp_disp_row_num
		dec	zp_disp_lin_ctr
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
2		jsr	FastPrA
		puls	A
		jsr	FastPrHexA
		ldb	#3				; channel counter
		stb	zp_disp_cha_ctr

track_lp	lda	#' '
		jsr	FastPrA
		ldd	0,Y
		anda	#$0F
		jsr	PrNote				; note
		lda	#' '
		jsr	FastPrA
		lda	2,Y
		jsr	FastPrHexA
		lda	3,Y
		jsr	FastPrHexA		
		leay	4,Y
		dec	zp_disp_cha_ctr
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
		stb	zp_disp_oct			; octave
prnotelp	ldb	#12
		stb	zp_disp_per			; semitones in an octave	
		leax	pertab,PCR
		ldd	,S
		cmpd	,X++
		bhi	PrNoteOct
prnotelp2	cmpd	,X++
		bhs	PrNoteF
		dec	zp_disp_per
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
		dec	zp_disp_oct
		bne	prnotelp

PrNoteF		leas	2,S				; reset stack
		ldb	#12
		subb	zp_disp_per
		aslb
		leax	nottab,PCR
		abx
		lda	,X+
		sta	,U+
		lda	,X+
		sta	,U+
		lda	zp_disp_oct
		jmp	FastPrNyb






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
		bcs	spp_done			; it overflowed!
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
		cmpa	g_song_len
		bhs	1F
		leax	song_data,PCR		
		lda	A,X
		rts
1		lda	#$80				; retuern -ve for end
		rts
; A = pattern #
; return:
; 	zp_note_ptr -> 1st row of pattern
;	A = 0
;	Z
start_pattern
		clr	sheila_DMAC_DMA_SEL		
		tfr	A,B
		clra
		aslb					; don't need a shift here as A < 128
		aslb
		rola
		addd	#HDR_PATT_DATA_OFFS/256
		std	sheila_DMAC_DMA_SRC_ADDR	; page # of pattern
		ldb	#HDR_PATT_DATA_OFFS%256
		stb	sheila_DMAC_DMA_SRC_ADDR+2	; lo address

		ldb	#$FF
		stb	sheila_DMAC_DMA_DEST_ADDR+0	; SYS
		ldd	#cur_patt_data
		std	sheila_DMAC_DMA_DEST_ADDR+1	; address of current pattern buffer

		ldd	#PATTERN_LEN-1
		std	sheila_DMAC_DMA_COUNT

		lda	#DMACTL_ACT + DMACTL_HALT + DMACTL_STEP_SRC_UP + DMACTL_STEP_DEST_UP
		sta	sheila_DMAC_DMA_CTL


		lda	#16
		ldb	g_row_pos
		mul
		addd	#cur_patt_data
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
FastPrHexA	pshs	A
		LSRA
		LSRA
		LSRA
		LSRA
		JSR 	FastPrNyb
		puls	A
FastPrNyb	ANDA	#15
		CMPA	#10
		blo	FastPrDigit
		ADDA	#7
FastPrDigit	ADDA	#'0'
FastPrA		sta	,U+
		rts
FastPrSp	lda	#' '
		bra	FastPrA

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
key_pause	lda	#FLAGS_key_pause
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

div24x16
		clra
		ldb	zp_d24_dividend
		ldw	zp_d24_dividend + 1
		divq	zp_d24_divisor16
		bvs	div24x16_over
		clr	zp_d24_dividend
		stw	zp_d24_dividend+1
		std	zp_d24_remain
div24x16_over	rts


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

; 8bit
;;finetunetab:	.word 256, 254, 252, 251, 249, 247, 245, 243, 271, 269, 267, 265, 264, 262, 260, 258
finetunetab	fdb	32768, 32532, 32298, 32066, 31835, 31606, 31379, 31153, 34716, 34467, 34219, 33973, 33728, 33486, 33245, 33005
; revers
;;finetunetab:	.word	32768, 33005, 33245, 33486, 33728, 33973, 34219, 34467, 30929, 31153, 31379, 31606, 31835, 32066, 32298, 32532



tmp_note_per	rzb	2
tmp_note_porta	rzb	2
tmp_note_cmd	rzb	1

	IF BUILD_TIMER_VSYNC
old_EVNTV	rzb	2
	ELSE
old_IRQ2V	rzb	2
	ENDIF

g_start
g_speed		rzb	1
g_song_pos	rzb	1
g_pattern	rzb	1
g_tick_ctr	rzb	1
g_row_pos	rzb	1
g_arp_tick	rzb	1
g_flags		rzb	1			; $40 = key_pause; $20 set at end of a vsync (can be reset in calling loop)
g_pat_brk	rzb	1			; when not $FF indicates a pending pattern break
g_pat_rep	rzb	1
g_song_skip	rzb	1
g_song_len	rzb	1
g_end
g_size		equ	g_end-g_start



cha_vars
cha_0_vars	rzb	cha_vars_size
cha_1_vars	rzb	cha_vars_size
cha_2_vars	rzb	cha_vars_size
cha_3_vars	rzb	cha_vars_size

sam_data	rzb	32*s_saminfo_sizeof
song_data	rzb	SONG_DATA_LEN
cur_patt_data	rzb	PATTERN_LEN



		include "modload.asm"