
; main sound routines


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
		clr	snd_q_occupied-4,x		;
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
