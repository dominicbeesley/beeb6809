	\\ any label used by adding sm_lo/hi/op is self-modding the follwoing instruction
	\\ any label starting sm_ is only used for self modding, not branching / jumping
	sm_lo = 1 \\ lo byte of addr
	sm_hi = 2 \\ hi byte of addr
	sm_im = 1 \\ immediate value

	OSBYTE    = &fff4
	OSWRCH    = &ffe3
	SystemVIA = &FE40
	UserVIA   = &FE60 \\ Ports: A=printer B=user
	CrtcReg   = &FE00
	CrtcVal   = &FE01
	VideoULA  = &FE20
	OSCLI     = &FFF7

	CrtcR0HorizontalTotal        =  0 \\ 8b WO m0-3:127 m4-7:63
	CrtcR1HorizontalDisplayed    =  1 \\ 8b WO m0-3:80  m4-7:40
	CrtcR2HorizontalSyncPosition =  2 \\ 8b WO m0-3:98  m4-6:49 m7:51
	CrtcR3SyncPulseWidths        =  3 \\ Horizontal sync pulse width b0-3 WO m0-3:8 m4-7:4, Vertical sync pulse width b4-7 WO Always 2
	CrtcR4VerticalTotal          =  4 \\ 7b WO m0-2,4-5:38 m3,6-7:30
	CrtcR5VerticalTotalAdjust    =  5 \\ 5b WO m0-7:0
	CrtcR6VerticalDisplayed      =  6 \\ 7b WO m0-2,4-5:32 m3,6-7:25
	CrtcR7VerticalSyncPosition   =  7 \\ 7b WO m0-2,4-5:34 m3,6-7:27
	CrtcR8InterlaceAndControl    =  8 \\ Interlace modes        b0-1 00,10 non-interlaced, m0-6 01 Interlace sync, m7 11 Interlace sync and video
	                                  \\ Display blanking delay b4-5 m0-6 00 no delay, m7 01 one character, 10 two characters, 11 disable video output
	                                  \\ Cursor blanking delay  b6-7 m0-6 00 no delay, 01 one character, m7 10 two characters, 11 disable cursor output
		CrtcR8_M7_Default  = &91 \\ Interlaced
		CrtcR8_M06_Default = &01 \\ Interlaced
		CrtcR8_M06_Game    = &C0 \\ no interlace, no crsr
		CrtcR8_M06_NoVideo = &F0 \\ no interlace, no crsr, video disabled
	CrtcR9CharacterScanLines     =  9 \\ 5b WO m0-2,4-5:7 m3,6:9 m7:18
	CrtcR10CursorControlStart    = 10 \\ 7b WO b7 unused b6 blink enable b5 blink fast b0-4 crsr start line
	CrtcR11CursorEnd             = 11 \\ 5b WO crsr end line
	CrtcR12Screen1stCharHi       = 12 \\ 6b WO hi byte of (start of screen address)/8
	CrtcR13Screen1stCharLo       = 13 \\ 8b WO lo byte of (start of screen address)/8

	VideoULAVideoControlRegister = VideoULA + 0 \\ 8b WO b7 master crsr size b5-6 crsr bytes wide 00:1 m0,3-4,6 01:undef 10:2 m1,5,6 11:4 m2
	                                            \\ b567=000 disables the crsr b4 6845 clock rate 0:m4-7 1:m0-3
	                                            \\ b2-3 chars per line 11:80 10:40 01:20 00:10 b1 teletext b0 flash colour set
	                                            \\ m0:&9C m1:&D8 m2:&F4 m3:&9C m4:&88 m5:&C4 m6:&88 m7:&4B \\ NB check erata
	
		VideoUlaMode_1NoCrsrFlash0 = &18 \\ non-flash colours
		VideoUlaMode_1NoCrsrFlash1 = &19 \\ flash colours
		VideoUlaMode_4NoCrsr       = &08 \\ lsb flips flash colours
		VideoUlaMode_5NoCrsr       = &04 \\ which could be used to save some palette swapping

	VideoULAPalette              = VideoULA + 1 \\ b4-7 logical colour 2c:b7xxx 4c:b7xb5x 16c:b7-4, b0-3 actual colour (^7)
	                                            \\ c0:black, c1:red, c2:green, c3:yellow, c4:blue, c5:magenta, c6:cyan, c7:white, c8-15:c0-7/c7-0
	PaletteWhite   = &00 : PaletteFlashWhiteBlack   = &08 ; Pal2Col0 = &00;
	PaletteCyan    = &01 : PaletteFlashCyanRed      = &09 ; Pal2Col1 = &80;
	PaletteMagenta = &02 : PaletteFlashMagentaGreen = &0A
	PaletteBlue    = &03 : PaletteFlashBlueYellow   = &0B
	PaletteYellow  = &04 : PaletteFlashYellowBlue   = &0C : Pal4Col0 = &00;
	PaletteGreen   = &05 : PaletteFlashGreenMagenta = &0D : Pal4Col1 = &20;
	PaletteRed     = &06 : PaletteFlashRedCyan      = &0E : Pal4Col2 = &80;
	PaletteBlack   = &07 : PaletteFlashBlackWhite   = &0F : Pal4Col3 = &A0;

	ViaRegB = 0  \\ RegB
	ViaRegH = 1  \\ Handshake RegA
	ViaDDRB = 2  \\ controls which bits are write (1) and read (0) in RegB
	ViaDDRA = 3  \\ controls which bits are write (1) and read (0) in RegA
	ViaT1CL = 4  \\ Timer 1 Low order latches (write) counter (read)
	ViaT1CH = 5  \\ Timer 1 High order counter (write to apply T1CL)
	ViaT1LL = 6  \\ Timer 1 low order latch
	ViaT1LH = 7  \\ Timer 1 high order latch
	ViaT2CL = 8  \\ Timer 2 Low order latches (write) counter (read)
	ViaT2CH = 9  \\ Timer 2 High order counter (write to apply T2CL)
	ViaSR   = 10 \\ Shift Register
	ViaACR  = 11 \\ Auxiliary Control Register
	ViaPCR  = 12 \\ Periferal Control Register
	ViaIFR  = 13 \\ Interrupt Flag    Register // b7:any/all   b6:timer1 b5:timer2 b4:CB1 b3:CB2 b2:ShiftReg B1:CA1 b0:CA2
	ViaIER  = 14 \\ Interrupt Enable  Register // b7:1set1s/0clear1s b2:shift-reg (8)
	ViaRegA = 15 \\ No hadshake RegA

	IntCA2 =  1 \\ CA2 active edge
	IntCA1 =  2 \\ CA1 active edge
	IntSR  =  4 \\ Shift Reg completed 8 shifts
	IntCB2 =  8 \\ CB2 active edge
	IntCB1 = 16 \\ CB2 active edge
	IntT2  = 32 \\ Time out of T2
	IntT1  = 64 \\ Time out of T1
	IntIRQ =128 \\ Any enabled Interrupt (IFR) Set/Clear (IER)

	irq_A_save = &FC

	SysIntKbd   = IntCA2 \\ key pressed
	SysIntVSync = IntCA1 \\ 6845 vsync
	SysIntSR    = IntSR  \\ Shift Reg completed 8 shifts (not usually used)
	SysIntPen   = IntCB2 \\ light pen strobe detected
	SysIntA2D   = IntCB1 \\ End of Conversion from the analogue to digital converter
	SysIntT2    = IntT2  \\ Time out of T2 (used for speech)
	SysIntT1    = IntT1  \\ Time out of T1 (100Hz signal for internal clocks)
	SysIntIRQ   = IntIRQ \\ Set if the system via was the cause of the interrupt

	SysViaRegB = SystemVIA+ViaRegB \\ 0 b0..b2 addressable latch bit, b3 value to write, b4,b5 joystick-buttons b6 speech-ready b7 speech-interrupt
	                               \\   B0 Sound write enable, B1 Read select speech, B2 write select speech, B3 keyboard write enable
							       \\   B4,B5 screen wrap address (&8000-size) 11:20K, 00:16K, 10:10K, 01:8K, B6 Caps Lock LED B7 Shift Lock LED
	SysViaRegH = SystemVIA+ViaRegH \\ 1 Handshake RegA - Access slow data bus connection (RegB-B0-B3) and read/write (DDRA)
	SysViaDDRB = SystemVIA+ViaDDRB \\ 2 controls which bits are write (1) and read (0) in RegB
	SysViaDDRA = SystemVIA+ViaDDRA \\ 3 controls which bits are write (1) and read (0) in RegA (slow data bus)
	SysViaT1CL = SystemVIA+ViaT1CL \\ 4 Timer 1 Low order latches (write) counter (read)
	SysViaT1CH = SystemVIA+ViaT1CH \\ 5 Timer 1 High order counter (write to apply T2CL)
	SysViaT1LL = SystemVIA+ViaT1LL \\ 6 Timer 1 Low order latches
	SysViaT1LH = SystemVIA+ViaT1LH \\ 7 Timer 1 High order latches
	SysViaT2CL = SystemVIA+ViaT2CL \\ 8 Timer 2 Low order latches (write) counter (read)
	SysViaT2CH = SystemVIA+ViaT2CH \\ 9 Timer 2 High order counter (write to apply T2CL)
	SysViaSR   = SystemVIA+ViaSR   \\ A Shift Register \\ unused
	SysViaACR  = SystemVIA+ViaACR  \\ B Auxiliary Control Register
	SysViaPCR  = SystemVIA+ViaPCR  \\ C Periferal Control Register
	SysViaIFR  = SystemVIA+ViaIFR  \\ D Interrupt Flag    Register // b7:any/all   b6:timer1 b5:timer2 b4:CB1-ADC-EndOfConv b3:CB2-light-pen-strobe * (AUG414)
	SysViaIER  = SystemVIA+ViaIER  \\ E Interrupt Enable  Register // b7:1set1s/0clear1s b2:shift-reg (8) b1:CA1-6845-vsync b0CA2-keyboard-keypress
	SysViaRegA = SystemVIA+ViaRegA \\ F No hadshake RegA (good for keyboard) - Access slow data bus connection (RegB-B0-B3) and read/write (DDRA)

	UsrViaIFR  = UserVIA+ViaIFR  \\ Interrupt Flag    Register // b7:any/all   b6:timer1 b5:timer2 b4:CB1-ADC-EndOfConv b3:CB2-light-pen-strobe * (AUG414)
	UsrViaIER  = UserVIA+ViaIER  \\ Interrupt Enable  Register // b7:1set1s/0clear1s b2:shift-reg (8) b1:CA1-6845-vsync b0CA2-keyboard-keypress

	AddrLatchBits = 15

	\\ mode info
	top_rows    = 29
	btm_rows    = 2
	vsync_row   = 34 \\ must be here
	scr_rows    = 39 \\ must be
	row_bytes   = &200
;	t2_period   = scr_rows*8*192 / 3 - 2
	scr_addr    = &8000 - 32 * row_bytes
	btm_addr    = scr_addr - btm_rows * row_bytes
	StarsToBtm  = 6

	max_bird_shots = 6 \\ per evn / odd
	score_1_start = scr_addr-&200+5*8+8
	ships_addr    = score_1_start - &200 + 6*8*2+1
	hiscore_start = score_1_start+17*8*2
;	score_2_start = hiscore_start+9*8*2
	max_diving_birds = 8 \\ must be power of 2 (maybe!)
	b2d = (16-max_diving_birds)*2

	FIRST_SWING_ROW = 2

ORG   $0
GUARD irq_A_save

;; Any variables ending in local are caler saves

.ZERO_PAGE

.player_dead           EQUB 0
.lives_remaining       EQUB 2
.attract_mode          EQUB 0

.score				   EQUB 0,0,0
.hi_score			   EQUB 0,0,0
.total_levels          EQUB 0
.dive_level            EQUB 0
.current_level		   EQUB 0
;.level_config          EQUB 0
.starting_level        EQUB 0

.keys_state			   EQUB 0 \\ updated by read keys
.keys_not_prev         EQUB 0
.keys_just_pressed     EQUB 0
.last_rand             EQUB 0
.frame_done	           EQUB 0
.frame_next	           EQUB 0

.wait_x                EQUB 0
.wait_y                EQUB 0

.pix_y                 EQUB 0
.y_pix                 EQUB 0 \\ copy of pix_y when row_y/8-pix_y are set
.row_y                 EQUB 0
.t1_count              EQUB 0
.irq_tmp               EQUB 0
.old_bomb_y            EQUB 0

.bullet_byte           EQUB 0
.bullet_addr           EQUW 0
.bullet_byte2          EQUB 0
.bullet_addr2          EQUW 0

.bullet_col0           EQUB 0
.bullet_col2           EQUB 0

.ship_pix              EQUB 0
.ship_addr             EQUW btm_addr
.ship_abtm             EQUW btm_addr
.ship_src              EQUW ship

;.ship_clr0             EQUW 0
.ship_clr1             EQUW 0
.ship_clr2             EQUW 0
.ship_clr3             EQUW 0

;.shot_vol              EQUB 0
;.shot_freq             EQUW 0
;.shot_tk2_dec          EQUB 0

;; sound ;;

.shot_vol              EQUB 0
.shot_tim              EQUB 0

.wound_tim             EQUB 0

.wlk_exp_idx           EQUB 0

.diving_tim            EQUB 0
.diving_frq            EQUB 0

.swy_exp_vol           EQUB 0

.siren_frq             EQUB 0

.alarm_num             EQUB 0
.alarm_tim             EQUB 0

.tune_index            EQUB 0
.tune_vol              EQUB 0
.tune_sustain          EQUB 0
.tune_timer            EQUB 0
.tune_cadence          EQUB 0

;; level features ;;

.feature_draw          EQUW 0 \\ stars / boss / nothing
.feature_timer         EQUB 0
.feature_hit           EQUW 0
\\.explosion_count       EQUB 0

.big_exp_lhs_lo        EQUB 1,2,3,4 \\ set to 0 to disable exp
.big_exp_lhs_hi        EQUB 1,2,3,4
.big_exp_rhs_lo        EQUB 1,2,3,4 \\ set to 0 to disable exp
.big_exp_rhs_hi        EQUB 1,2,3,4

.local_b               EQUB 0
.local_w               EQUW 0
.lvl_data              EQUW 0

.boss_data             EQUW 0
.boss_src              EQUW 0
.boss_scroll_stars     EQUB 0

.star_pal              EQUB Pal4Col1 OR PaletteCyan OR &00, Pal4Col1 OR PaletteBlue OR &10, Pal4Col1 OR PaletteRed  OR &40, Pal4Col1 OR PaletteRed  OR &50
.ship_pal              EQUB Pal4Col1 OR PaletteRed

.top_left              EQUW scr_addr
.crtc12hi              EQUB 0
.crtc13lo              EQUB 0
;.draw_src              EQUW 0
;.draw_dst              EQUW 0
.draw_local            EQUW 0
.irq_local             EQUB 0
\\.font_src              EQUW text

;.sprite_offset         EQUB 0

.PaletteCol2           EQUB 0
.PaletteCol3           EQUB 0
.bird_timer            EQUB 0
.bird_dir              EQUB 0
.bird_bytes            EQUB 0
.bird_count            EQUB 0
.bird_src              EQUW birds
.bird_dst              EQUW 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
.bird_bullet_byte      EQUB 0
.bird_bullet_offset    EQUB 0

.bird_shot_level_max   EQUB (max_bird_shots-1)*2
.bird_shot_top_height  EQUB 4 \\ ldx bird_shot_top_height : jsr eor_top_bird_shot
.bird_shot_rest_height EQUB 0
.bird_shot_pix_y       EQUB 0
.bird_shot_top_count   EQUB (max_bird_shots-1)*2
.bird_shot_top_byte    EQUB 0 \\ must be immediatelly before bird_shot_top_row
.bird_shot_top_row     SKIP 2*max_bird_shots-1 \\ must follow bird_shot_top_byte
.bird_shot_top_addr    SKIP max_bird_shots*2 \\ bird_bullet_byte &3

.bird_shooting         EQUB 0
.bird_shots_left       EQUB 0

.dive_shooting         EQUB 0
.dive_shots_left       EQUB 0

;SKIP max_bird_shots*2 \\ bird_bullet_byte &c \\ must follow odd
.swing_bob_dir_freq    EQUB 0 \\ MSb=dir, 0 for 25Hz, 1 for 12.5Hz, 3 for 6.25Hz etc
.swing_bob_timer       EQUB 0

.diving_bird_first     EQUB 16
.div_anim_frame        SKIP 1 \\ max_diving_birds ; relative to diving_anims \\ (diving_anims: b7-b5 move b4-b0 frame)
.div_anim_sprite       SKIP max_diving_birds*2-1 ; sprite index for diving_spr and diving_data

;.snd_max_vol           EQUB 0,0,0,0
.eor_drawing           EQUB 0
.shield_timer          EQUB 0
.cooldown_timer        EQUB 0
.feature_bits          EQUB 0 \\ b7 = swaying birds

SHIELD_ACTIVE   = 52
SHIELD_COOLDOWN = 76

.end_of_ZP

CLEAR 0,&100

	\\ unless documented, AXY and CNVZ are undefined on exit, BID are unchanged (B=B I=I D=D)

	sprites       =  &300 \\ &1200 +stars +masks
	birds         =  &300 \\  &AFF
	boss          =  &B00 \\  &CFF
	text          =  &d00 \\  &DFF
	ship          =  &E00 \\  &FFF
	explosion     = &1000 \\ &11FF
	shielded_ship = &1200 \\ &13ff small + large
	stars         = &1400 \\ &12FF
	masks         = &1500 \\ &13ff
	sprites_end   = &1600

	GUARD btm_addr
	ORG sprites_end

.BEGIN

.wait_full_scan_line        \\ 128 cycles
{
	jsr wait_half_scan_line \\ drop through to run twice
}                           \\ 1 jsr here, 1 to half, two rts from half === calling half twice
.wait_half_scan_line        \\ 64 cycles
{                           \\ 6 jsr to get here
	php : pha               \\ 3+3
	clc : lda #128-7        \\ 2+2
.loop				        
	adc #1 : bpl loop       \\ 35 (2+3)*7 \\ -1 last time
	pla : plp               \\ 4+4
	RTS                     \\ 6
}                           \\ total 64 cycles in jsr and rts

\\ FFFE    EQUW	DC1C                                // 5 ~JMP()
\\ DC1C    STA     &FC     ;save A				    // 3
\\ DC1E    PLA             ;get back status (flags) // 4
\\ DC1F    PHA             ;and save again		    // 3
\\ DC20    AND     #&10    ;check if BRK flag set   // 2
\\ DC22    BNE     &DC27   ;if so goto DC27		    // 2
\\ DC24    JMP     (&0204) ;else JMP (IRQ1V)	    // 5
\\ So irq_handler should be hit ~24 cycles after vsync

.irq_handler \\ should be hit ~24 cycles after vsync
{
	lda SysViaIFR : and #SysIntVSync : beq not_vsync : sta SysViaIFR \\ 24+4+2+2+4

	\\ vsync

	ScanLineUs  = 64
;    FramePeriod = scr_rows*8*ScanLineUs \\ non-interlaced (+ScanLineUs/2 ? for interlaced)
	ReloadTime  = 2
	VSyncToTop  = 5*8-2 \\ scan lines as the vsync interrupt arrives at the end of the 2nd scan line pulse
    ToTopStart  = (VSyncToTop + 7-16) * ScanLineUs - (10+43)/2;+ 8*ScanLineUs \\ TODO allow for OS->irq+irq->handler (-cycles/2)
	ToStarsEnd  = ((top_rows-StarsToBtm)*8) * ScanLineUs - ReloadTime ; (FramePeriod DIV 3) - ReloadTime
	ToBtmStart  = (StarsToBtm*8) * ScanLineUs - ReloadTime
	ToBtmEnd    = (btm_rows*8) * ScanLineUs - ReloadTime

    lda #LO(ToTopStart) : STA SysViaT1CL ; Write T1 low (Latched)
    lda #HI(ToTopStart) : STA SysViaT1CH ; Write high (copies latched low)
    LDA #LO(ToStarsEnd) : STA SysViaT1LL ; Will be set 2 clocks after first T1 hits
    LDA #HI(ToStarsEnd) : STA SysViaT1LH ; Will be set 2 clocks after first T1 hits

	lda #CrtcR6VerticalDisplayed    : sta CrtcReg : lda #top_rows+1                         : sta CrtcVal \\ 7b WO m0-2,4-5:32 m3,6-7:25
	lda #CrtcR8InterlaceAndControl  : sta CrtcReg : lda #CrtcR8_M06_NoVideo                 : sta CrtcVal \\ Interlace and delay register {6bWO} \\ interlaced, no crsr, video enabled
	lda #CrtcR7VerticalSyncPosition : sta CrtcReg : lda #vsync_row                          : sta CrtcVal \\ Vertical sync position {7bWO} \\ make vsync happen at normal 34 (27 from other CRTC cycle + 4 from this + the 8 lines)
	lda #CrtcR12Screen1stCharHi     : sta CrtcReg : lda row_y : lsr A : ror irq_tmp : lsr A : sta CrtcVal \\ crtc start addr hi 12
	lda #CrtcR13Screen1stCharLo     : sta CrtcReg : lda irq_tmp : and #&80 : ror A          : sta CrtcVal \\ crtc start addr lo 13 \\ c=0
;	lda #VideoUlaMode_1NoCrsrFlash0 : sta VideoULAVideoControlRegister                                    \\ no crsr, M1, non-flash
	lda #CrtcR5VerticalTotalAdjust  : sta CrtcReg : lda pix_y : sta y_pix : eor #7 : adc #1 : sta CrtcVal \\ v-offset 5 (C=0 so (5-y-1) << 1) \\ 8,6,4,2

	lda PaletteCol2 : jsr set_palette_colour
	lda PaletteCol3 : jsr set_palette_colour
	stx irq_local : ldx #3 : .set_star_pal : lda star_pal,x : sta VideoULAPalette : dex : bpl set_star_pal : ldx irq_local

	lda #254 : sta t1_count \\ vsync:-5 -1:0 (top begin) 9:2.5 8:5 7:7.5 6:10 5:12.5 4:15 3:17.5 2:20 1:22.5 0:25 (bottom begin) 10:27.5 (score title colours) 9:30 8:32.5 (off screen) \\ 33 vsync

	lda irq_A_save			\\
	RTI						\\

.not_vsync

	lda SysViaIFR : and #SysIntT1 : beq not_t1 : sta SysViaIFR \\ 24+4+2+2+4

	inc t1_count                                               \\ 36+5
	bpl not_top_begin                                            \\ 41+2

	\\ top-begin \\ 46c

	lda #CrtcR8InterlaceAndControl  : sta CrtcReg : lda #CrtcR8_M06_Game       : sta CrtcVal \\ Interlace and delay register {6bWO} \\ interlaced, no crsr, video enabled
	jsr wait_full_scan_line
	lda #CrtcR13Screen1stCharLo     : sta CrtcReg : lda #LO(btm_addr/8)        : sta CrtcVal \\ crtc start addr lo 13
	lda #CrtcR12Screen1stCharHi     : sta CrtcReg : lda #HI(btm_addr/8)        : sta CrtcVal \\ crtc start addr hi 12
	lda #CrtcR4VerticalTotal        : sta CrtcReg : lda #top_rows-1            : sta CrtcVal \\ Vertical total               {7bWO} \\ 27 lines in this CRTC cycle (vsync needs to be at 34)
	lda #CrtcR5VerticalTotalAdjust  : sta CrtcReg : lda y_pix                  : sta CrtcVal \\ v-offset 5 \\ 0,2,4,6

    LDA #LO(ToBtmStart) : STA SysViaT1LL ; Will be set 2 clocks after first T1 hits
    LDA #HI(ToBtmStart) : STA SysViaT1LH ; Will be set 2 clocks after first T1 hits

	lda irq_A_save			\\
	RTI						\\

.not_t1
	lda SysViaIFR : and #&7F : sta SysViaIFR \\ clear all SysVia interrupt flags
\\		lda UserViaIFR          \\
\\		sta UserViaIFR			\\ clear all SysVia interrupt flags
	lda irq_A_save			\\
	RTI						\\

.not_top_begin \\ 33c if actually not T1

	bne not_stars_end
	lda ship_pal : jsr set_palette_colour

    LDA #LO(&FFFF) : STA SysViaT1LL ; Will be set 2 clocks after first T1 hits
    LDA #HI(&FFFF) : STA SysViaT1LH ; Will be set 2 clocks after first T1 hits

	lda irq_A_save			\\
	RTI						\\

.not_stars_end

	lda t1_count : eor #1
	bne not_bottom_begin

	\\ bottom-begin \\ 43c

	lda #Pal4Col2 OR PaletteWhite : jsr set_palette_colour
	lda #Pal4Col3 OR PaletteBlue  : jsr set_palette_colour

	inc frame_next

;;	lda #VideoUlaMode_1NoCrsrFlash1 : sta VideoULAVideoControlRegister                        \\ no crsr, M1, flash
	jsr wait_full_scan_line
	lda #CrtcR4VerticalTotal        : sta CrtcReg : lda #scr_rows-top_rows-1-1  : sta CrtcVal \\ Vertical total               {7bWO} \\ 27 lines in this CRTC cycle (vsync needs to be at 34)
	lda #CrtcR6VerticalDisplayed    : sta CrtcReg : lda #btm_rows               : sta CrtcVal \\ 7b WO m0-2,4-5:32 m3,6-7:25
	lda #CrtcR7VerticalSyncPosition : sta CrtcReg : lda #vsync_row-top_rows-1+2 : sta CrtcVal \\ Vertical sync position {7bWO} \\ make vsync happen at normal 34 (27 from other CRTC cycle + 4 from this + the 8 lines)

	lda irq_A_save			\\
	RTI						\\

.not_bottom_begin

.off_bottom
	lda irq_A_save			\\
	RTI						\\

; R12/13 (latched) and v-tot-adj (latched?) are read at v-total/start, the others are read on the fly
}

.frame_wait \\ AXY=?
{
;jsr *+3
	stx wait_x
	sty wait_y
	lda frame_done
.wait
	cmp frame_next
	beq wait
	inc frame_done
	jsr snd_update
	bit attract_mode : bpl playing
	jsr read_4_keys : and #&20 : beq playing
	inc attract_mode : jmp start_new_game
.playing
	ldx wait_x
	ldy wait_y
	rts
}

; DATA &20, "f0", &71, "f1", &72, "f2", &73, "f3", &14, "f4", &74, "f5", &75, "f6", &16, "f7", &76, "f8", &77, "f9"
; DATA &70, "Escape", &30, "1" , &31, "2" , &11, "3" , &12, "4" , &13, "5" , &34, "6" , &24, "7" , &15, "8" , &26, "9" , &27, "0" , &17, "-" , &18, "^" , &78, "\" , &19, "Left", &79, "Right"
; DATA &10, "Q", &21, "W", &22, "E", &33, "R", &23, "T", &44, "Y", &35, "U", &25, "I", &36, "O", &37, "P", &47, "@", &38, "[", &28, "_", &39, "Up", &29, "Down"
; DATA &40, "Caps Lock", &01, "CTRL", &41, "A", &51, "S", &32, "D", &43, "F", &53, "G", &54, "H", &45, "J", &46, "K", &56, "L", &57, ";", &48, ":", &58, "]"
; DATA &61, "Z", &42, "X", &52, "C", &63, "V", &64, "B", &55, "N", &65, "M", &66, "<", &67, ">", &68, "/"
; DATA &60, "Tab", &49, "Return", &50, "Shift Lock", &59, "DELETE", &69, "COPY", &62, "SPACE", &00, "SHIFT"

.keys_to_scan  EQUB &61, &42, &49, &00 \\ move me to page TWO (actually page ONE with hi-score and add joystick controlls)

.read_4_keys \\ : X=11 A=key_state Y=&FF
	ldy #3
.read_keys \\ Y = key count - 1 to scan -> A msb(s) = keys (k0=b7), then keys_not_prev, X=11, Y=&FF, keys_state = new A
{
	lda #&7F : sta SysViaDDRA \\ when keyboard selected, write key val to b0-6 and read key state (1=down) from b7
	lda keys_state : eor #&FF : sta keys_not_prev
	lda #0
	SEI
	ldx #3+0 : stx SysViaRegB \\ write "disable" keyboard - allows reading keys: write key value to SysViaRegA and read from b7:1=pressed
.read_key
	ldx keys_to_scan,y : stx SysViaRegA : asl SysViaRegA : ror A : dey : bpl read_key
	ldx #3+8 : stx SysViaRegB \\ write "disable" keyboard - allows reading keys: write key value to SysViaRegA and read from b7:1=pressed
	CLI
	ldx #&FF : stx SysViaDDRA \\ put back ready for sound
	sta keys_state
	RTS
}

;.draw_ship
;{
;	ldy #31
;}.draw_ship_loop
;	.ship_src  : lda ship,y : sta (ship_addr),y
;	.ship_src2 : lda ship+&100,y : sta (ship_abtm),y
;{	dey : bpl draw_ship_loop
;	RTS
;}

.draw_ship
{
	clc : lda ship_src : sta top+ 0+sm_lo : sta btm+ 0+sm_lo
	adc #8 :             sta top+ 6+sm_lo : sta btm+ 6+sm_lo
	adc #8 :             sta top+12+sm_lo : sta btm+12+sm_lo
	adc #8 :             sta top+18+sm_lo : sta btm+18+sm_lo
	{lda ship_addr : ldx ship_addr+1 : ldy ship_abtm+1 : sta top+ 3+sm_lo : sta btm+ 3+sm_lo : stx top+ 3+sm_hi : sty btm+ 3+sm_hi}
	{adc #8 : bcc no_wrap : inx : iny : clc : .no_wrap : sta top+ 9+sm_lo : sta btm+ 9+sm_lo : stx top+ 9+sm_hi : sty btm+ 9+sm_hi}
	{adc #8 : bcc no_wrap : inx : iny : clc : .no_wrap : sta top+15+sm_lo : sta btm+15+sm_lo : stx top+15+sm_hi : sty btm+15+sm_hi}
	{adc #8 : bcc no_wrap : inx : iny : clc : .no_wrap : sta top+21+sm_lo : sta btm+21+sm_lo : stx top+21+sm_hi : sty btm+21+sm_hi}
	ldx #7 : ldy pix_y
.lp
	.top : lda ship     ,x : sta scr_addr,y : lda ship     ,x : sta scr_addr,y : lda ship     ,x : sta scr_addr,y : lda ship     ,x : sta scr_addr,y
	.btm : lda ship+&100,x : sta scr_addr,y : lda ship+&100,x : sta scr_addr,y : lda ship+&100,x : sta scr_addr,y : lda ship+&100,x : sta scr_addr,y
	dex : bmi done
	dey : bpl lp
	stx local_b : ldy ship_addr+1 : tya : sbc #1 : ora #&40 : tax \\ C=0->1
	{clc : lda ship_addr                               : stx top+ 3+sm_hi : sty btm+ 3+sm_hi}
	{adc #8 : bcc no_wrap : inx : iny : clc : .no_wrap : stx top+ 9+sm_hi : sty btm+ 9+sm_hi}
	{adc #8 : bcc no_wrap : inx : iny : clc : .no_wrap : stx top+15+sm_hi : sty btm+15+sm_hi}
	{adc #8 : bcc no_wrap : inx : iny : clc : .no_wrap : stx top+21+sm_hi : sty btm+21+sm_hi}
	ldx local_b : ldy #7 : bne lp
.done
	RTS
}

.shield_pals : EQUB Pal4Col1 OR PaletteGreen, Pal4Col1 OR PaletteRed, Pal4Col1 OR PaletteGreen, Pal4Col1 OR PaletteRed
.shield_gfx  : EQUB HI(shielded_ship)+1, 0, HI(shielded_ship), HI(shielded_ship)+1

.check_draw_shielded_ship
	lsr A
	bit feature_bits : bmi do_draw_shielded_ship
	jmp draw_ship
.draw_shielded_ship
;{
	lda shield_timer : beq draw_shielded_ship-3
	lsr A : bcs check_draw_shielded_ship : lsr A : bcs check_draw_shielded_ship+1
	and #3 : tax
	lda shield_pals,x : sta ship_pal
	lda shield_gfx ,x : beq draw_shielded_ship-3
	sta col0+sm_hi : sta col1+sm_hi : sta col2+sm_hi : sta col3+sm_hi : sta col4+sm_hi : sta col5+sm_hi : sta col6+sm_hi : sta col7+sm_hi

.do_draw_shielded_ship
;{
	{lda ship_addr+1 : clc : adc #4 : and #&3F : ora #&40 : tax : lda ship_addr : sbc #16-1 : bcs no_wrap : dex : .no_wrap : clc}
	sta col0+3+sm_lo : stx col0+3+sm_hi {adc #8 : bcc no_wrap : inx : clc : .no_wrap}
	sta col1+3+sm_lo : stx col1+3+sm_hi {adc #8 : bcc no_wrap : inx : clc : .no_wrap}
	sta col2+3+sm_lo : stx col2+3+sm_hi {adc #8 : bcc no_wrap : inx : clc : .no_wrap}
	sta col3+3+sm_lo : stx col3+3+sm_hi {adc #8 : bcc no_wrap : inx : clc : .no_wrap}
	sta col4+3+sm_lo : stx col4+3+sm_hi {adc #8 : bcc no_wrap : inx : clc : .no_wrap}
	sta col5+3+sm_lo : stx col5+3+sm_hi {adc #8 : bcc no_wrap : inx : clc : .no_wrap}
	sta col6+3+sm_lo : stx col6+3+sm_hi {adc #8 : bcc no_wrap : inx : clc : .no_wrap}
	sta col7+3+sm_lo : stx col7+3+sm_hi

	ldx #31 : ldy pix_y : sec
.row_lp
	.col0 : lda shielded_ship+&00,x : sta scr_addr,y
	.col1 : lda shielded_ship+&20,x : sta scr_addr,y
	.col2 : lda shielded_ship+&40,x : sta scr_addr,y
	.col3 : lda shielded_ship+&60,x : sta scr_addr,y
	.col4 : lda shielded_ship+&80,x : sta scr_addr,y
	.col5 : lda shielded_ship+&a0,x : sta scr_addr,y
	.col6 : lda shielded_ship+&c0,x : sta scr_addr,y
	.col7 : lda shielded_ship+&e0,x : sta scr_addr,y
{	dex : bmi done
	dey : bpl row_lp
	ldy #col7-col0 : {.lp : lda col0+3+sm_hi,y : sbc #2 : ora #&40 : sta col0+3+sm_hi,y : tya : sbc #6 : tay : bcs lp : sec}
	ldy #7 : bpl row_lp
.done
	RTS
}
.check_cooldown_timer
{
	lda cooldown_timer : beq done
	dec cooldown_timer
.done
	RTS
}
.clear_shielded_ship
{
	lda shield_timer : beq check_cooldown_timer : sec : sbc #1 : sta shield_timer
	ldy #6-1 : ldx #32+8+2-1
	bit feature_bits : bmi do_clear
	and #3 : bne clear_shielded_ship-1
	ldy #4-1 : ldx #32-1
.do_clear

	{tya : adc ship_addr+1 : and #&3F : ora #&40 : tay : lda ship_addr : sbc #16-1 : bcs no_wrap : dey : .no_wrap : clc}
	sta col0+sm_lo : sty col0+sm_hi {adc #8 : bcc no_wrap : iny : clc : .no_wrap}
	sta col1+sm_lo : sty col1+sm_hi {adc #8 : bcc no_wrap : iny : clc : .no_wrap}
	sta col2+sm_lo : sty col2+sm_hi {adc #8 : bcc no_wrap : iny : clc : .no_wrap}
	sta col3+sm_lo : sty col3+sm_hi {adc #8 : bcc no_wrap : iny : clc : .no_wrap}
	sta col4+sm_lo : sty col4+sm_hi {adc #8 : bcc no_wrap : iny : clc : .no_wrap}
	sta col5+sm_lo : sty col5+sm_hi {adc #8 : bcc no_wrap : iny : clc : .no_wrap}
	sta col6+sm_lo : sty col6+sm_hi {adc #8 : bcc no_wrap : iny : clc : .no_wrap}
	sta col7+sm_lo : sty col7+sm_hi

	ldy pix_y : sec : lda #0
.row_lp
	.col0 : sta scr_addr,y
	.col1 : sta scr_addr,y
	.col2 : sta scr_addr,y
	.col3 : sta scr_addr,y
	.col4 : sta scr_addr,y
	.col5 : sta scr_addr,y
	.col6 : sta scr_addr,y
	.col7 : sta scr_addr,y
	dex : bmi done
	dey : bpl row_lp
	ldy #col7-col0 : {.lp : lda col0+sm_hi,y : sbc #2 : ora #&40 : sta col0+sm_hi,y : dey : dey : dey : bpl lp}
	ldy #7 : lda #0 : bpl row_lp
.done
	RTS
}

\\bird_spawn_width = 16 : bird_spawn_frames = 5 \\ player appears when last appears (but probably can't hit it until it has changed)
\\.bird_spawn_screen EQUB   0,   0,   0,   0,   0,   0
\\.bird_spawn_sprite EQUB  96, 112, 128, 144, 160, 176 \\ last seems to be upside down (copied from drop?)

\\bird_walk_width = 32 : bird_walk_frames = 4 : bird_walk_move = 16
\\.bird_walk_right_screen EQUB   0,   8,   8,   8
\\.bird_walk_right_sprite EQUB  64,  40,   0,  32
\\.bird_walk_left_screen  EQUB   8,   8,   0,   0
\\.bird_walk_left_sprite  EQUB  64,  40,   0,  40

explosion_bytes = 6*8 : explosion_frames = 5 : explosion_period = 2 ; 2 rows a page apart
;;.explosion_bullet_offset EQUB -24, -24, -24, -24,  -8
.explosion_sprite_offset EQUB   0,  48,   0,  48,  96\\, 144 \\ last frame is 16x8 (only bottom used)
.explosion_frame_periods EQUB 2-1, 3-1, 4-1, 4-1, 4-1\\, 0\\4

max_explosions = 4
.explosions_lo    skip max_explosions
.explosions_hi    skip max_explosions \\ MSB set -> unused
.explosions_frame skip max_explosions
.explosions_time  skip max_explosions

\\ should be 3 for bullet 2, but they have been swapped by time this called, so could remove
.start_explosion \\ X=bullet_sddr off set (0->bullet, 3->bullet2[never used], ship_addr-bullet_addr->player top, ship_abtm-bullet_addr->player btm)
start_explosion_silent = start_explosion+3
{
	jsr play_walk_explode

	ldy #max_explosions-1
.loop
	lda explosions_hi,y : bpl next
	lda bullet_addr  ,x : sec : sbc #24 : sta explosions_lo,y
	lda bullet_addr+1,x :     : sbc #2  : and #&3F : ora #&40 : sta explosions_hi,y
	lda #0 : sta explosions_frame,y
	lda explosion_frame_periods : sta explosions_time,y
	RTS
.next
	dey : bpl loop
.done
	RTS
}

.eor_explosions
{
	jsr eor_big_explosions

	ldx #max_explosions-1
.loop
	ldy explosions_hi,x : bmi next
	sty exp_dstt+sm_hi : sty exp_dstt+3+sm_hi : iny : iny : tya : and #&3F : ora #&40 : tay
	sty exp_dstb+sm_hi : sty exp_dstb+3+sm_hi
	lda explosions_lo,x    : sta exp_dstt+sm_lo : sta exp_dstb+sm_lo : sta exp_dstt+3+sm_lo : sta exp_dstb+3+sm_lo
	ldy explosions_frame,x : lda explosion_sprite_offset,y : sta exp_srct+sm_lo : sta exp_srcb+sm_lo
	ldy #explosion_bytes-1
	.exp_srct : lda explosion+&000,y : .exp_dstt : eor scr_addr,y : sta scr_addr,y
	.exp_srcb : lda explosion+&100,y : .exp_dstb : eor scr_addr,y : sta scr_addr,y
	dey : bpl exp_srct
.next
	dex : bpl loop
.done
	RTS
}

split_explosion_width = 48 : split_explosion_period = 4 ; 2 rows
split_explosion_offset_left  = 160
split_explosion_offset_right = 208
; explosions split appart at 2 chars each per 4 frames, bonus appears between for duration

.start_big_explosion \\ X=bullet_sddr off set (0->bullet, 3->bullet2, ship_addr-bullet_addr->player top, ship_abtm-bullet_addr->player btm)
start_big_explosion_silent = start_big_explosion+3
{
	jsr play_sway_explode

	ldy #max_explosions-1
.find_rhs
	lda big_exp_rhs_hi,y : beq this_rhs : dey : bpl find_rhs : bmi done_rhs
.this_rhs
	lda bullet_addr  ,x : sta big_exp_rhs_lo,y
	lda bullet_addr+1,x : and #&3f : ora #&40 : sta big_exp_rhs_hi,y
.done_rhs
	ldy #max_explosions-1
.find_lhs
	lda big_exp_lhs_hi,y : beq this_lhs : dey : bpl find_lhs : RTS
.this_lhs
	lda bullet_addr  ,x : sec : sbc #6*8 : sta big_exp_lhs_lo,y
	lda bullet_addr+1,x :     : sbc #0   : and #&3f : ora #&40 : sta big_exp_lhs_hi,y
	RTS
}

big_exp_lhs_off = 80*2 : big_exp_rhs_off = 104*2

.clr_big_explosions
{
	lda eor_drawing : bne eor_big_explosions+4 ; drawing not clearing

	clc
	lda #big_exp_lhs_lo  : sta exp_dst_lo+sm_im  : lda #big_exp_lhs_hi : sta exp_dst_hi+sm_im
	jsr draw_big_exp_halfs
	lda #big_exp_rhs_lo  : sta exp_dst_lo+sm_im  : lda #big_exp_rhs_hi : sta exp_dst_hi+sm_im

.draw_big_exp_halfs
	ldx #max_explosions-1
.draw_big_exp
	.exp_dst_hi  : lda big_exp_lhs_hi,x : beq draw_big_next : sta exp_dst_top+sm_hi : adc #2 : and #&3F : ora #&40 : sta exp_dst_btm+sm_hi
	.exp_dst_lo  : ldy big_exp_lhs_lo,x : sty exp_dst_top+sm_lo : sty exp_dst_btm+sm_lo
	ldy #6*8-1

.draw_big_lp
	lda #0
	.exp_dst_top : sta scr_addr,y
	.exp_dst_btm : sta scr_addr,y
	dey : bpl draw_big_lp
.draw_big_next
	dex : bpl draw_big_exp
	RTS
}

.eor_big_explosions
{
	;	bit player_dead : bmi no_keys \\ dying
	lda bird_count : bmi clr_big_explosions

	clc
	lda #big_exp_lhs_off : sta exp_src_top+sm_lo : sta exp_src_btm+sm_lo
	lda #big_exp_lhs_lo  : sta exp_dst_lo+sm_im  : lda #big_exp_lhs_hi : sta exp_dst_hi+sm_im
	jsr draw_big_exp_halfs
	lda #big_exp_rhs_off : sta exp_src_top+sm_lo : sta exp_src_btm+sm_lo
	lda #big_exp_rhs_lo  : sta exp_dst_lo+sm_im  : lda #big_exp_rhs_hi : sta exp_dst_hi+sm_im

.draw_big_exp_halfs
	ldx #max_explosions-1
.draw_big_exp
	.exp_dst_hi  : lda big_exp_lhs_hi,x : beq draw_big_next : sta exp_dst_top+sm_hi : sta exp_dst_top+3+sm_hi : adc #2 : and #&3F : ora #&40 : sta exp_dst_btm+sm_hi : sta exp_dst_btm+3+sm_hi
	.exp_dst_lo  : ldy big_exp_lhs_lo,x : sty exp_dst_top+sm_lo : sty exp_dst_top+3+sm_lo : sty exp_dst_btm+sm_lo : sty exp_dst_btm+3+sm_lo
	ldy #6*8-1

.draw_big_lp
	.exp_src_top : lda explosion     ,y : .exp_dst_top : eor scr_addr,y : sta scr_addr,y
	.exp_src_btm : lda explosion+&100,y : .exp_dst_btm : eor scr_addr,y : sta scr_addr,y
	dey : bpl draw_big_lp
.draw_big_next
	dex : bpl draw_big_exp
	RTS
}

.advance_explosions \\ X=bullet_sddr off set (0->bullet, 2->bullet2)
{
	ldx #max_explosions-1
.loop
	lda explosions_hi,x : bmi next
	dec explosions_time,x : bpl next
	ldy explosions_frame,x : iny : lda explosion_frame_periods,y : sta explosions_time,x : tya : sta explosions_frame,x
	cpy #explosion_frames : bcc next
	lda #&80 : sta explosions_hi,x \\ disable
.next
	dex : bpl loop
.done


.advance_big_explosions \\ X=bullet_sddr off set (0->bullet, 2->bullet2)
{
	ldx #max_explosions-1
.loop_lhs
	ldy big_exp_lhs_hi,x : beq next_lhs : lda big_exp_lhs_lo,x : sec : sbc #8 : sta big_exp_lhs_lo,x
	bcs next_lhs : tya : lsr A : dey : bcs update_lhs : ldy #0
.update_lhs
	sty big_exp_lhs_hi,x
.next_lhs
	dex : bpl loop_lhs
	ldx #max_explosions-1
.loop_rhs
	ldy big_exp_rhs_hi,x : beq next_rhs : lda big_exp_rhs_lo,x : clc : adc #8 : sta big_exp_rhs_lo,x : iny
	bcs update_rhs : cmp #256-6*8 : bne next_rhs : tya : lsr A : bcs next_rhs : ldy #0
.update_rhs
	sty big_exp_rhs_hi,x
.next_rhs
	dex : bpl loop_rhs
}

	RTS
}


bird_width = 32 : bird_frames = 8 : bird_move = 16 \\ START MOVING LEFT from rightmost, so first drawn is centre
.bird_l_sprites    EQUB 144, 120,  80, 120   \\ mv left from thin
.bird_r_sprites    EQUB 144, 112,  80, 112   \\ mv right from thin
.bird_moves        EQUB   8,   0,   8,   0   \\ add when moving to
.bird_l_bullets    EQUB  16,   8,  16,   8   
.bird_r_bullets    EQUB  16,   8,  16,  16   
.bird_bullet_bytes EQUB &cc, &33, &cc, &33

.advance_birds
{
	inc bird_timer : lda bird_timer : lsr A : bcc no_bombs
	
	ldx bird_count : bmi no_room
	ldx bird_shot_top_count : bmi room : cpx bird_shot_level_max : bcs no_room : .room : inx : inx \\ (max_bird_shots-1)
	jsr rand : cmp #64 : bcs no_room \\ C=0
	ldy bird_shooting : dec bird_shots_left : bpl shoot
	inc bird_shots_left : cmp #16 : bcs no_room \\ C=0
	and bird_count : and #&FE : tay
	and #2 : sta bird_shots_left : sty bird_shooting
.shoot
	lda bird_dst  ,y : adc bird_bullet_offset             : sta bird_shot_top_addr  ,x
	lda bird_dst+1,y : adc #0 : and #&3F : ora #&40       : sta bird_shot_top_addr+1,x
	lsr A : eor #63 : sec : adc row_y : adc #26 : and #31 : sta bird_shot_top_row   ,x
	lda bird_bullet_byte                                  : sta bird_shot_top_byte  ,x
	stx bird_shot_top_count
	ldy bird_shot_top_count : beq no_room
.check_for_duplicate
	lda bird_shot_top_addr-2,y : cmp bird_shot_top_addr  ,x : bne not_same
	lda bird_shot_top_addr-1,y : cmp bird_shot_top_addr+1,x : bne not_same
	dex : dex : stx bird_shot_top_count : bpl no_room
.not_same
	dey : dey : bne check_for_duplicate
.no_room

	jsr move_diving_birds

	jmp advance_bird_bombs

.no_bombs
	lsr A : bcs done : lsr A : bcs done : and #3 : tay      \\ y = frame

	lda bird_bullet_bytes,y : sta bird_bullet_byte
	ldx bird_count : bmi done : inc bird_dir : bmi left_dir : lda bird_dir : cmp #39 : bne right_dir : lda #LO(-41) : sta bird_dir \\ x = bird_count * 2
.right_dir
	{
		lda bird_r_bullets,y : sta bird_bullet_offset : lda bird_r_sprites,y : sta bird_src : lda bird_moves,y : sta bird_adv+sm_im
		.lp : lda bird_dst,x : clc : .bird_adv : adc #0 : sta bird_dst,x : bcc same_half : inc bird_dst+1,x
		.same_half : dex : dex : bpl lp : bmi both_dirs \\ allways
	}
.left_dir
	{
		lda bird_l_bullets,y : sta bird_bullet_offset : lda bird_l_sprites,y : sta bird_src : lda bird_moves,y : sta bird_adv+sm_im
		.lp : lda bird_dst,x : sec : .bird_adv : sbc #0 : sta bird_dst,x : bcs same_half : dec bird_dst+1,x
		.same_half : dex : dex : bpl lp
	}
.both_dirs
	ldy bird_count
.redraw_stars
	ldx bird_dst+1,y : inc stars-&40,x : dey : dey : bpl redraw_stars
.done

	RTS
}

.maybe_diving_drop_bomb
{
	lda diving_bird_first
	cmp #max_diving_birds*2
	bcs no_room

	lda diving_tim : bne already_diving
	jsr play_diving
.already_diving

	ldx bird_shot_top_count : bmi room : cpx bird_shot_level_max : bcs no_room : .room : inx : inx \\ (max_bird_shots-1)
	jsr rand : cmp #64 : bcs no_room \\ C=0
	ldy dive_shooting : dec dive_shots_left : bpl shoot
	inc dive_shots_left : cmp #16 : bcs no_room \\ C=0
	ora diving_bird_first : and #max_diving_birds*2-2 : tay \\ C=0
	and #2 : sta dive_shots_left : sty dive_shooting
.shoot
	lda bird_dst+b2d  ,y : adc #8                         : sta bird_shot_top_addr  ,x
	lda bird_dst+b2d+1,y : adc #0 : and #&7F : ora #&40   : sta bird_shot_top_addr+1,x
	lsr A : eor #63 : sec : adc row_y : adc #26 : and #31 : sta bird_shot_top_row   ,x
	lda bird_bullet_byte                                  : sta bird_shot_top_byte  ,x
	stx bird_shot_top_count
	ldy bird_shot_top_count : beq no_room \\ only bullet, can't coincide
.check_for_duplicate
	lda bird_shot_top_addr-2,y : cmp bird_shot_top_addr  ,x : bne not_same
	lda bird_shot_top_addr-1,y : cmp bird_shot_top_addr+1,x : bne not_same
	dex : dex : stx bird_shot_top_count : bpl no_room \\ always
.not_same
	dey : dey : bne check_for_duplicate
.no_room

	RTS
}


.move_diving_birds \\ X=bird \\ div_anim_frame,x is likely to be one too many !!!
{
	jsr start_diving_bird

	ldx diving_bird_first
	
.move_next_bird \\ C=1

	cpx #max_diving_birds*2
	bcs maybe_diving_drop_bomb
	; check end of frame

	dec div_vsyncs_left   ,x ; %000000vv (vsyncs-1)
	bmi not_same_frame
	jmp same_frame
.not_same_frame

	; check end of anim

	ldy div_anim_frame    ,x
	iny
	tya
	cmp div_frame_end     ,x
	bcs choose_next_anim       \\ C=1

.new_frame    \\ X=bird, Y=current frame \\ movements are in diving_data


	sty div_anim_frame    ,x    ; current frame

; diving_R_ = 0
; diving__u = 1 : diving__d = 1
; diving_r_ = 2
; diving_ru = 3 : diving_rd = 3
; diving___ = 4
; diving_lu = 5 : diving_ld = 5
; diving_l_ = 6
; diving_Lu = 7 ; spare but mv_Ld \\ b7 0:r, 1:l b5 0:- 1:^v
; 
; .diving_move_x : EQUB 16,0,8,8,0,&F8,&F8,&F0

	lda diving_anims      ,y    ; dir * 32 + spr \\ C=0
	sta local_w                 ; save diving_anims,y
	lsr A : lsr A : lsr A : lsr A : lsr A
	tay                         ; index into diving_move_x
	clc                         ; C=0
	and #4                      ; 0:right !0:left
	bne move_left
.move_right
	lda diving_move_x     ,y
	adc bird_dst+b2d      ,x
	sta bird_dst+b2d      ,x
	bcc h_move_done
	inc bird_dst+1+b2d    ,x
	bne h_move_done             ; allways
.move_left
	lda diving_move_x     ,y
	beq h_move_done
	adc bird_dst+b2d      ,x
	sta bird_dst+b2d      ,x
	bcs h_move_done
	dec bird_dst+1+b2d    ,x
.h_move_done                    ; C=?

	tya : lsr A : bcc v_move_done
	lda bird_dst+1+b2d    ,x
	clc
	adc div_vert_direct   ,x    ; C=0
	sta bird_dst+1+b2d    ,x
.v_move_done

lda bird_dst+1+b2d,x : and #HI(scr_addr)-1 : ora #HI(scr_addr) : sta bird_dst+1+b2d,x ; not off bottom - TODO remove when using constraints

	lda local_w                 ; dir * 32 + spr
	and #31
	tay
	sty div_anim_sprite   ,x

	lda diving_data       ,y    ; b76 --w:2 b3 --v:2 --h: ; (width-1) * 16 + (vsyncs-1) * 2 + (height-1)
	lsr A : and #3
	sta div_vsyncs_left   ,x    ; %000000vv (vsyncs-1)
	lda diving_data       ,y    ; b76 --w:2 b3 --v:2 --h:1 ; (width-1) * 16 + (vsyncs-1) * 2 + (height-1)
	ora #&7*2
	sta div_bytes_tall    ,x    ; %wwww111h (width-1) (height-1)

.same_frame
	inx : inx
	jmp move_next_bird \\ allways

.choose_next_anim

	choice_max = local_b   ; space_above = 1
	choice_1st = local_w   ; space_below = 2
	choice_msk = local_w+1 ; space_right = 4
	choice_add = lvl_data  ; space_left  = 8
	choice_try = lvl_data+1

	\\ C=1
	lda bird_dst+b2d+1    ,x : lsr A : sta choice_max \\ row addr
	lda bird_dst+b2d      ,x : ror A
	cmp #32  : rol choice_msk \\ room on left
	cmp #224 : rol choice_msk \\ ! room on right
	lda choice_max : sec : sbc row_y : and #&1F \\ row addr
	cmp #24  : rol choice_msk \\ ! room below
	cmp #16  : rol choice_msk \\ room above
	lda choice_msk : and #15 : eor #space_right OR space_below : sta choice_msk

; Add rest of code to pick from valid options

	; new anim

	ldy div_anim_sprite   ,x

	lda choose_anim       ,y     ; start * 8 + count offsets from anim_choices
	and #7
	sta choice_max               ; max choice
	jsr rand
	and #15
.make_in_range
	cmp choice_max
	bcc chosen
	sbc choice_max
	bcs make_in_range            ; allways
.chosen
	sta choice_1st               ; choice in range
	sta choice_try

	lda choose_anim       ,y
	lsr A : lsr A : lsr A
	sta choice_add

.try_next_hi
	lda choice_try
	clc
	adc choice_add               ; index into anim_choices  \\ C=0
	tay
	lda anim_constraints  ,y     ; move up to check anim is valid b7=up!down
	and choice_msk
	eor anim_constraints  ,y
	and #15
	beq found_one
	ldy choice_try
	iny : sty choice_try
	cpy choice_max : bcc try_next_hi

	lda #0 : sta choice_try

.try_next_lo
	lda choice_try
	clc
	adc choice_add               ; index into anim_choices  \\ C=0
	tay
	lda anim_constraints  ,y     ; move up to check anim is valid b7=up!down
	and choice_msk
	eor anim_constraints  ,y
	and #15
	beq found_one
	ldy choice_try
	iny : sty choice_try
	cpy choice_1st : bcc try_next_lo

	lda choice_try
	clc
	adc choice_add               ; index into anim_choices  \\ C=0
	tay

.found_one
	lda anim_constraints  ,y     ; move up to check anim is valid b7=up!down
	asl A : lda #&FE : bcs up : lda #2 : .up
	sta div_vert_direct   ,x

	lda anim_choices+1    ,y     ; one past last frame
	sta div_frame_end     ,x
	lda anim_choices      ,y     ; index into diving_anims

	tay
	jmp new_frame
}

.start_diving_bird
{
	jsr rand
	bit starting_level : bmi no_dive
	ldx bird_count : bmi no_dive
	cmp dive_level : bcs no_dive

	ldy diving_bird_first : beq no_dive
	dey : dey : sty diving_bird_first

	lda bird_dst+1      ,x
	lsr A
.above
	stx local_b             ; bird to dive
	sta local_w             ; highest screen row
.next
	dex : dex : bmi found
	lda bird_dst+1      ,x
	lsr A
	cmp local_w
	bcc above
	bcs next
.found
	ldx local_b             ; bird to dive

	\\ swap last bird with bird to dive (may be same if last bird is highest on screen)
	ldy bird_count
	lda bird_dst  ,y : pha : lda bird_dst  ,x : sta bird_dst  ,y : pla : sta bird_dst  ,x
	lda bird_dst+1,y : pha : lda bird_dst+1,x : sta bird_dst+1,y : pla : sta bird_dst+1,x

	cpy bird_shooting : bne not_diving : dec bird_shots_left : dec bird_shots_left : .not_diving
	cpx bird_shooting : bne not_moved  : sty bird_shooting                         : .not_moved

	\\ copy bird to dive to diving bird (same if none dead yet)
	ldx diving_bird_first
	lda bird_dst  ,y : sta bird_dst+b2d  ,x : sta local_w
	lda bird_dst+1,y : sta bird_dst+b2d+1,x : sta local_w+1

	inc draw_birds_bcc+sm_im : inc draw_birds_bcc+sm_im
	dey : dey : sty bird_count

	lda #0
	sta div_vsyncs_left ,x ; %000000vv (vsyncs-1)
	sta div_anim_frame  ,x
	sta div_frame_end   ,x
	sta div_anim_sprite ,x

	ldy bird_bytes : dey : lda #0 : .clr : sta (local_w),y : dey : bpl clr

.no_dive
	RTS
}



.advance_bird_bombs
{
	lda bird_shot_pix_y : eor #4 : sta bird_shot_pix_y : lda old_bomb_y : sta local_b \\ flip
	lda pix_y : eor bird_shot_pix_y : sta old_bomb_y : cmp local_b : bcs same_row
.move_down
	jsr move_bird_shot_top_down_a_row
.same_row
	lda bird_shot_pix_y : bne done2

\\	move bombs down and kill when at botom

	ldx bird_shot_top_count : bmi done2
;	lda row_y : asl A : adc #top_rows*2 : sta swap_cmp+sm_im
.check
;	lda bird_shot_top_addr+1,x : .swap_cmp : cmp #HI(scr_addr+top_rows*&200) : bcc dont_kill

	dec bird_shot_top_row,x : bpl dont_kill \\ TODO remove temp check to kill bombs at end of screen

	ldy bird_shot_top_count
	lda bird_shot_top_addr+1,y : sta bird_shot_top_addr+1,x
	lda bird_shot_top_addr  ,y : sta bird_shot_top_addr  ,x
	lda bird_shot_top_row   ,y : sta bird_shot_top_row   ,x
	lda bird_shot_top_byte  ,y : sta bird_shot_top_byte  ,x
	dey : dey : sty bird_shot_top_count

.dont_kill : dex : dex : bpl check
.done2

	jmp calc_bird_shot_eor_addrs
\\	RTS
}   

ship_width = 32 : ship_frames = 8 : ship_move = 16 ; 2 rows, a page each
.ship_addr_adj      EQUB   8,   0,   0,   0,   0,   0,   8,  0 \\ use before inc for right, after dec for left
.ship_bullet_offset EQUB  16,   8,   8,   8,  16,  16,  16,  8
.ship_bullet_byte   EQUB &88, &44, &22, &11, &88, &44, &22, &11
.ship_sprite_offset EQUB   0,  32,  64,  96, 128, 160, 192, 224

.swap_bullets
{
	ldx #2 : .lp : lda bullet_byte,x : ldy bullet_byte2,x : sty bullet_byte,x : sta bullet_byte2,x : dex : bpl lp
	RTS
}

.check_for_player_hit_enemy \\ returns via feature_hit if anything hit
{
	lda bullet_byte : beq no_hit0
	lda #0
	ldy #7
.hit0
	ora (bullet_addr),y
	dey
	bpl hit0
	and bullet_byte
	and #&F0
.no_hit0
	sta bullet_col0

	lda bullet_byte2 : beq no_hit2
	lda #0
	ldy #7
.hit2
	ora (bullet_addr2),y
	dey
	bpl hit2
	and bullet_byte2
	and #&F0
.no_hit2
	sta bullet_col2
	RTS
}

.process_player_hit_enemy \\ returns via feature_hit if anything hit
{
	lda bullet_col0 : beq no_hit0 : jsr process_hit : .no_hit0
	lda bullet_col2 : beq done
	jsr swap_bullets
.process_hit
	jmp (feature_hit) \\ bullet is col3, check only col2 and col3
.done
	RTS
}

.move_bullets \\ X=bullet hi or 0 if off screen (beq)
{
	ldx #3
.move_bullet
	lda bullet_byte,x : beq done \\ beq may not be necessary, but is safe
	lda bullet_addr+1,x
	sec : sbc #2 : ora #&40 : sta bullet_addr+1,x
	lsr A : sec : sbc row_y : and #31 : sec : sbc #30 : bmi done
	lda #0 : sta bullet_byte,x
.done
	dex : dex : dex : beq move_bullet
	RTS
}

.eor_bullets
{
	lda bullet_addr2+1 : bmi eor_bullet
	jsr eor_bullet : jsr swap_bullets
.eor_bullet
	ldx bullet_byte : beq none
	ldy #7 : .bullet_on : txa : eor (bullet_addr),y : sta (bullet_addr),y : dey : bpl bullet_on
.none
	RTS
}

.try_start_shield
{
	lda cooldown_timer : bne no_shield : lda #SHIELD_ACTIVE : sta shield_timer : lda #SHIELD_COOLDOWN : sta cooldown_timer
	lda ship_src : clc : adc #7 : tay : ldx #7
	{
	.lp
		lda ship+ &00,y : sta shielded_ship+&48,x : sta shielded_ship+&148,x
		lda ship+ &08,y : sta shielded_ship+&68,x : sta shielded_ship+&168,x
		lda ship+ &10,y : sta shielded_ship+&88,x : sta shielded_ship+&188,x
		lda ship+ &18,y : sta shielded_ship+&a8,x : sta shielded_ship+&1a8,x
		lda ship+&100,y : sta shielded_ship+&50,x : sta shielded_ship+&150,x
		lda ship+&108,y : sta shielded_ship+&70,x : sta shielded_ship+&170,x
		lda ship+&110,y : sta shielded_ship+&90,x : sta shielded_ship+&190,x
		lda ship+&118,y : sta shielded_ship+&b0,x : sta shielded_ship+&1b0,x
		dey : dex : bpl lp
	}
.no_shield
	RTS
}

.process_keys \\ continue turn ( && ), cur dir (keys_state & cur_dir), 
{
	key_left   = &80 \\ bmi
	key_right  = &40 \\ bvs
	key_fire   = &20
	key_shield = &10

	clc : ldx #0 : ldy pix_y
	txa : sta (ship_abtm),y : tya : adc #8 : tay
	txa : sta (ship_abtm),y : tya : adc #8 : tay
	txa : sta (ship_abtm),y : tya : adc #8 : tay
	txa : sta (ship_abtm),y
	lda ship_addr : sta local_w : lda ship_addr+1 : sbc #1 : ldy pix_y : iny : cpy #8 : bcc one_row : ldy #0 : sbc #254
.one_row : ora #&40 : sta local_w+1 : tya : adc #8 : tay
	txa : sta (local_w),y : tya : adc #8 : tay
	txa : sta (local_w),y

	bit attract_mode : bmi done
	lda shield_timer : bne done
	jsr read_4_keys
	and #key_fire : and keys_not_prev : beq no_fire
	lda bullet_addr+1 : bmi no_fire : lda bullet_byte : beq fire_bullet
	bit bullet_addr2+1 : bmi no_fire : lda bullet_byte2 : bne no_fire : jsr swap_bullets
.fire_bullet
	ldx ship_pix : lda ship_addr : clc : adc ship_bullet_offset,x : sta bullet_addr : lda ship_addr+1 : sbc #1 : ora #&40 : sta bullet_addr+1
	lda ship_bullet_byte,x : sta bullet_byte
	jsr play_shot
	
.no_fire
	lda keys_state : and #key_shield { beq no : jsr try_start_shield : .no}

	\\ check shield

	bit keys_state : bpl not_left : bvs no_move \\ L+R=none
.move_ship_left
	{
		ldx ship_pix : dex : bpl same_anim : lda ship_addr : cmp #(24+8)*2 : bcs move_ok : lda ship_addr+1 : lsr A : bcc no_move : .move_ok : ldx #7 : .same_anim : stx ship_pix
		lda ship_addr : sec : sbc ship_addr_adj,x : sta ship_addr : sta ship_abtm : bcs same_half : dec ship_addr+1 : dec ship_abtm+1 : .same_half
		lda ship_sprite_offset,x : sta ship_src
	.no_move
	}
.done
	RTS
.not_left
	bvc no_move
.move_ship_right
	{
		ldx ship_pix
		lda ship_addr_adj,x : clc : adc ship_addr : sta ship_addr : sta ship_abtm : bcc same_half : inc ship_addr+1 : inc ship_abtm+1 : .same_half
		cpx #7 : bne same_anim : cmp #256-(24+16)*2 : bcc move_ok : lda ship_addr+1 : lsr A : bcs no_move : .move_ok : ldx #LO(-1) : .same_anim : inx : stx ship_pix
		lda ship_sprite_offset,x : sta ship_src
	.no_move
	}
.no_move
	RTS
}

.set_palette_colour \\ A = &pxpxcccc Palette(0=COLOUR0) Colour^7(7=black)
{
	STA VideoULAPalette : EOR #&10 : STA VideoULAPalette : EOR #&40 : STA VideoULAPalette : EOR #&10 : STA VideoULAPalette
;	eor #&40 : and #&A0 : bne ok : brk : .ok
	RTS
}

.rand \\ returns rand in A C=? X=X Y=Y
{
	lda last_rand
	asl a
	asl a
	clc
	adc last_rand
	clc
	adc #&45
;lda #0 : NOP
	sta last_rand
EOR &FE44
	rts
}

.cls
{
	lda #HI(scr_addr) : sta cls_sm+sm_hi : lda #0 : tay
;	lda #HI(btm_addr) : sta cls_sm+sm_hi : lda #0 : tay
	.cls_sm : sta scr_addr,y : iny : bne cls_sm : inc cls_sm+sm_hi : bpl cls_sm
	RTS
}

MAPCHAR '0', 0*12+1 : MAPCHAR '1', 1*12+1 : MAPCHAR '2', 2*12+1 : MAPCHAR '3', 3*12+1 : MAPCHAR '4', 4*12+1
MAPCHAR '5', 5*12+1 : MAPCHAR '6', 6*12+1 : MAPCHAR '7', 7*12+1 : MAPCHAR '8', 8*12+1 : MAPCHAR '9', 9*12+1
MAPCHAR 'S',10*12+1 : MAPCHAR 'C',11*12+1 : MAPCHAR 'O',12*12+1 : MAPCHAR 'R',13*12+1 : MAPCHAR 'E',14*12+1
MAPCHAR 'H',15*12+1 : MAPCHAR 'I',16*12+1 : MAPCHAR '-',17*12+1 : MAPCHAR '#',18*12+1 : MAPCHAR '@',19*12+1
MAPCHAR ' ', 0      : MAPCHAR '*',20*12+1 \\ '#'=ship, '@'=alien, '-'=minus, '*'=star, ' '=gap

end_of_text = &20 \\ JSR

.draw_label_SCORE1HI2
	jsr draw_label
	EQUW score_1_start-&200+1
	EQUS "SCORE           HI-SCORE"

.end_label \\ same as jsr	
	EQUB end_of_text

MAPCHAR ' ','~',&20 \\ reset 32..126

.draw_label \\ writes @ addr after .label, terminate string with end_of_text (JSR)
{
	pla : sta draw_local   \\ the address pulled is 1 less
	pla : sta draw_local+1 \\ than the next instruction
	ldy #1                 \\ (or here 1 before the dst address)
	lda (draw_local),y : sta text_draw_sm+sm_lo : iny
	lda (draw_local),y : sta text_draw_sm+sm_hi
.next_char
	iny : lda (draw_local),y
	beq space : cmp #end_of_text : beq done
	sta text_src_sm+sm_lo
	jsr draw_half : jsr draw_half : bne next_char
.draw_half
	ldx #5
.text_src_sm  : lda text,x
.text_draw_sm : sta scr_addr,x
	dex : bpl text_src_sm
	lda #6 : clc : adc text_src_sm+sm_lo : sta text_src_sm+sm_lo
	lda #8
.advance
	clc : adc text_draw_sm+sm_lo : sta text_draw_sm+sm_lo : bcc done : inc text_draw_sm+sm_hi
.done
	RTS
.space
	lda #16 : jsr advance : bne next_char
}

.init_volume
;	EQUB (CHAN_3 OR FRQ_LO OR 7) \\ make white noise freq come from CHAN_2
	EQUB (CHAN_3 OR FRQ_LO OR 6) \\ make white noise HIGH freq
.default_volume
	EQUB %10011111 \\ channel 0 max volume, (%0000=loudest..%1111=silent) \\ move me to page TWO
	EQUB %10111111 \\ channel 1 max volume, (%0000=loudest..%1111=silent)
	EQUB %11011111 \\ channel 2 max volume, (%0000=loudest..%1111=silent)
	EQUB %11111111 \\ channel 3 max volume, (%0000=loudest..%1111=silent) \\ noise

.setup_level
{
	lda #Pal4Col1 OR PaletteRed : sta ship_pal
	lda total_levels : sta dive_level
	dec starting_level
	jsr cls
	jsr frame_wait
	lda siren_frq : ora alarm_num : beq not_siren
	lda #0 : sta shield_timer : sta cooldown_timer
	sta siren_frq : sta alarm_num : sta bird_shots_left : sta dive_shots_left : sta eor_drawing
;	lda #&FF : sta SysViaDDRA
	lda #(VOLUME OR CHAN_2) : jsr snd_write_A
	lda #(VOLUME OR CHAN_3) : jsr snd_write_A
.not_siren

	\\ reset video and scrolling related positions

;;;	lda #CrtcR8InterlaceAndControl  : sta CrtcReg : lda #CrtcR8_M06_Game : sta CrtcVal \\ Interlace and delay register {6bWO} \\ interlaced, no crsr, video enabled
;;	lda #Pal4Col0 OR PaletteBlack           : jsr set_palette_colour
;;	lda #Pal4Col1 OR PaletteFlashBlueYellow : jsr set_palette_colour
;;	lda #Pal4Col2 OR PaletteFlashCyanRed    : jsr set_palette_colour
;;	lda #Pal4Col3 OR PaletteWhite           : jsr set_palette_colour

	\\ clear stars then scroll them on

;;	lda #(VOLUME OR CHAN_3) : jsr snd_write_A
	lda #0 : sta player_dead : sta feature_timer : sta bird_shot_pix_y : ldy #max_explosions-1 : {.lp : sta big_exp_lhs_hi,y : sta big_exp_rhs_hi,y : dey : bpl lp}
	sta swing_bob_dir_freq : inc swing_bob_dir_freq : sta swing_bob_timer
	ldy #&3F : .dark : sta stars,y : dey : bpl dark \\ A=0 X=X Y=&FF
	ldy #&40 : .init_stars : jsr rand : lda last_rand : sta stars,y : iny : bne init_stars
	ldx bird_shot_level_max : inx : inx : cpx #(max_bird_shots-1)*2+1 : bcs max_shots : stx bird_shot_level_max : .max_shots

	\\ setup birds

	lda #max_diving_birds * 2 : sta diving_bird_first : ;;  jsr draw_diving_birds : jsr draw_diving_birds_in_batches
	lda #&80 : ldx #31 : .birdoff : sta bird_dst,x : dex : bpl birdoff : stx bullet_addr2+1 \\ MSB=1 -> one shot
	ldx current_level
	lda lvl_LO,x : sta lvl_data : lda lvl_HI,x : sta lvl_data+1
	ldy #0
	cpx #1 : beq two_shot : cpx #6 : bne one_shot : .two_shot : sty bullet_addr2+1 : .one_shot \\ MSB=0 -> two shot
	lda (lvl_data),y : lsr A : lsr A : tay
	lda (lvl_data),y : sta PaletteCol3 : dey
	lda (lvl_data),y : sta PaletteCol2 : dey
	lda (lvl_data),y : sta bird_src    : dey : lda #HI(birds) : sta bird_src+1 : lda #16 : sta bird_bytes
	dey : dey : sty bird_count : iny : iny : lda #&D9+32 : sta draw_birds_bcc+sm_im
	.position_birds : lda (lvl_data),y : sta bird_dst-1,y : dec draw_birds_bcc+sm_im : dey : bne position_birds
	lda (lvl_data),y : and #3 : tay
	lda feature_draw_lo,y : sta feature_draw : lda feature_draw_hi,y : sta feature_draw+1
	lda feature_hit_lo,y : sta feature_hit : lda feature_hit_hi,y : sta feature_hit+1
	lda features_bits,y : sta feature_bits
	lda star_pals_0,y : sta star_pal : lda star_pals_1,y : sta star_pal+1 : lda star_pals_4,y : sta star_pal+2 : lda star_pals_5,y : sta star_pal+3
\\	lda star_pals_0+1 : sta star_pal : lda star_pals_1+1 : sta star_pal+1 : lda star_pals_4+1 : sta star_pal+2 : lda star_pals_5+1 : sta star_pal+3
	cpy #2 : bcc no_mothership
	lsr dive_level
	ldy #initial_hull_shield_end-initial_hull : .hull_shield : lda initial_hull,y : sta hull,y : dey : bpl hull_shield
	jsr play_alarm
.no_mothership

	\\ scroll on stars

	jsr frame_wait
	lda #HI((scr_addr+(32-top_rows)*&200)/2) : sta row_y
	tya : bne start_scroll \\ no feature

	\\ init swing

	jsr play_siren
	lda #HI((scr_addr)/2) : sta row_y
	lda #1 : ldy #0 : {.lp : sta stars,y : iny : bne lp}
	tya : ldy #(8-1)*2 : {.lp : tya : lsr A : and #1 : sta swing_anim_seq,y : dey : dey : bpl lp} bmi no_scroll \\ allways

.start_scroll

	ldy #fur_elise       - tunes_data : cpx #0 : beq tune_selected
	cpx #5 : bne tunes_done
	ldy #spanish_romance - tunes_data
.tune_selected
	jsr start_tune
.tunes_done

	lda #HI((scr_addr+(top_rows-StarsToBtm)*&200)/2)-1 : sta row_y
\\	lda #HI((scr_addr+32*&200)/2)-1 : sta row_y
	ldx #2*(top_rows-StarsToBtm)-1
.scroll_stars
	stx bullet_byte
	lda #7 : sta pix_y
	inc stars,x : dex
	inc stars,x : dex
\\	stx bullet_byte
	lda #0 : sta feature_timer : sta bird_timer : jsr draw_feature \\ keep resetting feature timer to stop it from drawing prematurely
.row_loop
	jsr frame_wait
	dec pix_y : dec pix_y : bpl row_loop
	dec row_y
	ldx bullet_byte
	dec stars,x : dex
	dec stars,x : dex
	bpl scroll_stars
	inx : stx pix_y : inc row_y \\ pix_y=0 X=0 Y=Y=&FF

	ldx #14
.off_scr_stars
	dec stars,x : dex
	dec stars,x : dex
	bpl off_scr_stars
	jsr draw_stars
.no_scroll

	\\ spawn birds while scrolling on player 

	lda #LO(btm_addr+(24/4*8)+&38-8) : sta ship_addr : sta ship_abtm
	lda #(HI(scr_addr+(top_rows-StarsToBtm+4)*&200) AND &3F) OR &40 : sta ship_addr+1 : lda #(HI(scr_addr+(top_rows-StarsToBtm+5)*&200) AND &3F) OR &40 : sta ship_abtm+1
.scroll_ship_row
	ldy bird_bytes : jsr draw_birds : lda bird_src : clc : adc #16 : sta bird_src
	ldy #7 : sty ship_pix
.scroll_ship
	jsr frame_wait
;	ldy #128 : .wt : jsr wait_full_scan_line : dey : bpl wt
	lda pix_y : sta local_w
	lda ship_pix : sta pix_y
	jsr draw_ship
	lda local_w  : sta pix_y

;	ldy ship_pix : lda ship_addr : sta dst0+sm_hi : sta dst1+sm_hi : sta dst2+sm_hi
;	lda #HI(ship)   : jsr draw_ship_row : cpy #HI(scr_addr) : bcs ship_done
;	lda #HI(ship)+1 : jsr draw_ship_row : cpy #HI(scr_addr) : bcs ship_done
;	lda dst0+sm_hi : sta clr0+sm_hi : sta clr1+sm_hi : sta clr2+sm_hi : lda #255
;	.clr0 : sta btm_addr+(24/4*8)+&38,y : .clr1 : sta btm_addr+(24/4*8)+&40,y : .clr2 : sta btm_addr+(24/4*8)+&48,y
;.ship_done

	ldy #128 : .wt : jsr wait_full_scan_line : dey : bpl wt
	clc : ldx #0 : ldy ship_pix
	txa : sta (ship_abtm),y : tya : adc #8 : tay
	txa : sta (ship_abtm),y : tya : adc #8 : tay
	txa : sta (ship_abtm),y : tya : adc #8 : tay
	txa : sta (ship_abtm),y
	dec ship_pix : bpl scroll_ship
	lda ship_addr+1 : cmp #(HI(scr_addr+(top_rows-StarsToBtm+2)*&200) AND &3F) OR &40 : beq scroll_ship_done
	sta ship_abtm+1 : sec : sbc #2 : ora #&40 : sta ship_addr+1 : bne scroll_ship_row
.scroll_ship_done

	\\ position real ship

	lda #0 : sta ship_pix : sta bullet_byte : sta bullet_byte2 : sta bullet_addr+1
	lda ship_sprite_offset+0 : sta ship_src

	\\ init birds

	lda #LO(-2) : sta bird_shot_top_count
	lda #&FD : sta eor_top_bird_shot+1+sm_im : sta eor_top_bird_shot_rest+1+sm_im
	lda #LO(-22) : sta bird_dir : lda #LO(-1) : sta bird_timer : lda #32 : sta bird_bytes
	jsr advance_birds

	\\ change palete and draw scores

	jsr frame_wait
;	{ldy #6 : .lp : lda text  ,y : sta score_1_start  ,y
;	                lda text+6,y : sta score_1_start+8,y : dey : bne lp} \\ add 0s to ends
;	tya : jsr add_score \\ player 1
;	ldy #5*8*2-1 {.lp : lda score_1_start,y : sta hiscore_start,y : dey : bpl lp}
;	{ldx #6*8*2 : .lp : lda score_1_start,x : sta hiscore_start,x : dex : bpl lp} \\ copy to hi-score
;	tya : ldx #2 : jsr add_score \\ player 2
;	{ldx #6*8*2 : .lp : lda score_1_start,x : sta score_2_start,x : dex : bpl lp} \\ copy to player 2
;	tya : jsr add_score \\ player 1

	lda bird_count : cmp #(8-1)*2 : bne setup_done \\ swing levels
	lda #0 : sta bird_bytes

.setup_done
	inc starting_level
;	jmp draw_label_SCORE1HI2
	RTS

;.draw_ship_row \\ A=HI(ship_addr) Y=pix_y : Y=cut off ? HI(scr_addr) : Y
;	sta src0+sm_hi : sta src1+sm_hi : sta src2+sm_hi : ldx #0
;.draw_ship_line
;	.src0 : lda ship+&08,x : .dst0 : sta btm_addr+(24/4*8)+&38,y
;	.src1 : lda ship+&10,x : .dst1 : sta btm_addr+(24/4*8)+&40,y
;	.src2 : lda ship+&18,x : .dst2 : sta btm_addr+(24/4*8)+&48,y
;	iny : cpy #8 : bcc same_dst
;	ldy dst0+sm_hi : iny : iny : cpy #HI(scr_addr) : bcs draw_ship_done
;	sty dst0+sm_hi : sty dst1+sm_hi : sty dst2+sm_hi
;	ldy #0 : .same_dst
;	inx : cpx #8 : bcc draw_ship_line : .draw_ship_done
;	RTS

\\ could save a few bytes by storing in one page and only taling the lo byte
.lvl_LO EQUB LO(lvl0), LO(lvl1), LO(lvl2), LO(lvl3), LO(lvl4), LO(lvl5), LO(lvl6), LO(lvl2), LO(lvl3), LO(lvl4)
.lvl_HI EQUB HI(lvl0), HI(lvl1), HI(lvl2), HI(lvl3), HI(lvl4), HI(lvl5), HI(lvl6), HI(lvl2), HI(lvl3), HI(lvl4)

.feature_draw_lo : EQUB LO(draw_swing), LO(draw_stars), LO(draw_boss)
.feature_draw_hi : EQUB HI(draw_swing), HI(draw_stars), HI(draw_boss)

.feature_hit_lo : EQUB LO(hit_swing), LO(hit_stars), LO(hit_boss)
.feature_hit_hi : EQUB HI(hit_swing), HI(hit_stars), HI(hit_boss)

.features_bits  : EQUB &80, &00, &00

MACRO xy2ad x,y
	EQUW scr_addr + x*16+8 + y*&200
ENDMACRO
;FIRST_SWING_ROW=2
.lvl0   EQUB (16*2+3)*4+1 : xy2ad 10,1 : xy2ad 20,1 : xy2ad  8,2 : xy2ad 22,2 : xy2ad  6, 3 : xy2ad 24, 3 : xy2ad  6, 5 : xy2ad 24, 5 : xy2ad  8,6 : xy2ad 15,6 : xy2ad 22,6 : xy2ad 10,7 : xy2ad 20,7 : xy2ad 12,8 : xy2ad 15,8 : xy2ad 18,8 : EQUB   0, Pal4Col2 OR PaletteMagenta, Pal4Col3 OR PaletteYellow
.lvl1   EQUB (16*2+3)*4+1 : xy2ad 13,1 : xy2ad 17,1 : xy2ad 15,2 : xy2ad  9,3 : xy2ad 21, 3 : xy2ad  7, 4 : xy2ad 11, 4 : xy2ad 15, 4 : xy2ad 19,4 : xy2ad 23,4 : xy2ad 13,5 : xy2ad 17,5 : xy2ad  6,6 : xy2ad 15,6 : xy2ad 24,6 : xy2ad 15,8 : EQUB   0, Pal4Col2 OR PaletteGreen  , Pal4Col3 OR PaletteMagenta
.lvl2   EQUB ( 8*2+3)*4+0 : xy2ad  9,2 : xy2ad 11,4 : xy2ad 13,6 : xy2ad 15,8 : xy2ad 17,10 : xy2ad 19,12 : xy2ad 21,14 : xy2ad 23,16                                                                                                         : EQUB 176, Pal4Col2 OR PaletteBlue   , Pal4Col3 OR PaletteYellow
.lvl3   EQUB ( 8*2+3)*4+0 : xy2ad 23,2 : xy2ad  8,4 : xy2ad 23,6 : xy2ad  8,8 : xy2ad 23,10 : xy2ad  8,12 : xy2ad 23,14 : xy2ad  8,16                                                                                                         : EQUB 176, Pal4Col2 OR PaletteMagenta, Pal4Col3 OR PaletteYellow
.lvl4   EQUB (16*2+3)*4+2 : xy2ad 15,1 : xy2ad 13,2 : xy2ad 17,2 : xy2ad 11,3 : xy2ad 19,3  : xy2ad  9, 4 : xy2ad 21, 4 : xy2ad 15, 1 : xy2ad 13,2 : xy2ad 17,2 : xy2ad 11,3 : xy2ad 19,3 : xy2ad  9,4 : xy2ad 21,4 : xy2ad  7,5 : xy2ad 23,5 : EQUB   0, Pal4Col2 OR PaletteGreen  , Pal4Col3 OR PaletteMagenta   \\ if you die or kill all, all respawn \\ first 3 are actually doubles!
.lvl5   EQUB (16*2+3)*4+1 : xy2ad  5,1 : xy2ad 25,1 : xy2ad  7,2 : xy2ad 23,2 : xy2ad  9,3  : xy2ad 21, 3 : xy2ad 11, 4 : xy2ad 19, 4 : xy2ad 13,5 : xy2ad 17,5 : xy2ad 11,6 : xy2ad 15,6 : xy2ad 19,6 : xy2ad 13,7 : xy2ad 17,7 : xy2ad 15,8 : EQUB   0, Pal4Col2 OR PaletteMagenta, Pal4Col3 OR PaletteYellow
.lvl6   EQUB (16*2+3)*4+1 : xy2ad 15,1 : xy2ad 13,2 : xy2ad 17,2 : xy2ad 11,3 : xy2ad 19,3  : xy2ad  9, 4 : xy2ad 21, 4 : xy2ad  7, 5 : xy2ad 23,5 : xy2ad  9,6 : xy2ad 21,6 : xy2ad 11,7 : xy2ad 19,7 : xy2ad 13,8 : xy2ad 15,8 : xy2ad 17,8 : EQUB   0, Pal4Col2 OR PaletteGreen  , Pal4Col3 OR PaletteCyan
;lvl7   EQUB (16*2+3)*4+2 : xy2ad 15,11: xy2ad 13,11: xy2ad 17,11: xy2ad 11,11: xy2ad 19,11 : xy2ad  9, 11: xy2ad 21, 11: xy2ad 15, 3 : xy2ad 13,4 : xy2ad 17,4 : xy2ad 11,5 : xy2ad 19,5 : xy2ad  9,6 : xy2ad 21,6 : xy2ad  7,7 : xy2ad 23,7 : EQUB   0, Pal4Col2 OR PaletteGreen  , Pal4Col3 OR PaletteMagenta   \\ if you die or kill all, all respawn \\ first 3 are actually doubles!
}

.star_pals_0 : EQUB (Pal4Col1 OR PaletteGreen OR &00), (Pal4Col1 OR PaletteCyan OR &00), (Pal4Col1 OR PaletteCyan OR &00)
.star_pals_1 : EQUB (Pal4Col1 OR PaletteGreen OR &10), (Pal4Col1 OR PaletteBlue OR &10), (Pal4Col1 OR PaletteBlue OR &10)
.star_pals_4 : EQUB (Pal4Col1 OR PaletteGreen OR &40), (Pal4Col1 OR PaletteRed  OR &40), (Pal4Col1 OR PaletteRed  OR &40)
.star_pals_5 : EQUB (Pal4Col1 OR PaletteGreen OR &50), (Pal4Col1 OR PaletteRed  OR &50), (Pal4Col1 OR PaletteRed  OR &50)

.boss_layout
{
	EQUB row0-boss_layout, row1-boss_layout, row2-boss_layout, row3-boss_layout
	.row0 : EQUB &14,                          &00, &08, &10, &18
	.row1 : EQUB &26,                     &98, &20, &28, &30, &38, &a0
	.row2 : EQUB &4A,           &98, &a8, &40, &48, &70, &78, &48, &50, &b0, &a0
	.row3 : EQUB &6E, &98, &a8, &40, &58, &58, &58, &F0, &F8, &58, &58, &58, &50, &b0, &a0
	\\ &41...&51
}

.initial_hull   : EQUB 2,4,7,10,12,14,15,16,17,17,16,15,14,12,10,7,4,2 : .initial_shield : EQUB &98,&98, &90,&90, &98,&98, &90,&90, &98,&98, &90,&90, &98,&98, &90,&90, &98,&98, &90,&90, &98,&98, &90,&90, &98,&98, &90,&90, &98,&98, &90,&90, &98,&98, &90,&90 : .initial_hull_shield_end

.hull   SKIP 64\\ = stars+&A0
shield = hull + initial_shield - initial_hull

hull_1 = 56/4*8 : hull_2 = 16/4*8 : hull_3 = 64/4*8 : hull_4 = 80/4*8
.hull_to_boss : EQUB hull_1, hull_2, hull_3, hull_4

.hit_swing
{
	bird_dst1 = local_w
	bird_dst2 = boss_data

;;	lda bullet_addr+1 : sec : sbc #HI(scr_addr + (2+32-top_rows)*&200) : lsr A : and #&1E : tax     \\ x=bird index (b*2)
	lda bullet_addr+1 : sec : sbc #FIRST_SWING_ROW * 2 : lsr A : and #30 : tax : and #16 : bne done \\ x=bird index (b*2)
	lda bird_dst+1,x : lsr A : lda bird_dst,x : ror A : sta local_b                                 \\ a=index into sprite /2
	lda bullet_addr+1 : lsr A : lda bullet_addr : ror A : sec : sbc local_b                         \\ a=bullet pos in pixels
	bcc done : asl A : bcs done : cmp swing_draw_bytes,x : bcs done                                 \\ left, a=index, off page, right
	sta local_b : ldy swing_current_frame,x : lda swing_data,y : asl A : asl A : clc : adc local_b  \\ calc page offset
	sta local_w : lda swing_src_page,x : sta local_w+1 : lda bullet_addr+1 : and #2 : beq start_cmp \\ 1st row, is 1st row
	lda local_w+1 : cmp #sw_egg_hi : beq done : inc local_w+1                                       \\ 2nd of 1, 2nd
.start_cmp

	ldy #7 : lda #0 : {.lp : ora (local_w),y : dey : bpl lp} : and bullet_byte : beq done           \\ hit what, nothing
	ldy swing_src_page,x : cpy #sw_fly_hi : bne kill_swing_bird
	cmp bullet_byte : beq kill_swing_bird \\ dead_center
	jsr play_wound
	ldx #0 : stx bullet_byte
	lda #2 : jmp add_score : .done : RTS
}
.kill_swing_bird
{
	bird_dst1 = local_w
	bird_dst2 = boss_data

	sty local_b
	lda bird_dst,x : sta bird_dst1 : sta bird_dst2 : ldy bird_dst+1,x : sty bird_dst1+1 : iny : iny : sty bird_dst2+1
	lda #0 : ldy swing_draw_bytes,x : {.lp : sta (bird_dst1),y : sta (bird_dst2),y : dey : bpl lp}

	lda #dead_loop-anim_seq        : sta swing_anim_seq    ,x
	lda #1 : sta swing_reps_left,x : sta swing_frames_left ,x
	dec bird_count : dec bird_count

	lda bullet_addr+1 : and #&FF-2 : sta bullet_addr+1 \\ move to top row of bird	
	ldy local_b : cpy #sw_fly_hi : bne minor_explosion
	sec : sbc #2 : sta bullet_addr+1
;;	jsr rand : and #&70 : clc : adc #&10 : jsr add_score \\ kills x,y,a
	lda #&20 : jsr add_score \\ kills x,y,a
	ldx #0 : stx bullet_byte : jmp start_big_explosion
\\	RTS

.minor_explosion
	lda #2 : cpy #sw_egg_hi : bne not_egg : lda #5 : .not_egg : jsr add_score \\ kills x,y,a
	ldx #0 : stx bullet_byte : jmp start_explosion
\\	RTS
}

swing_type_egg = 1 : swing_type_hatch = 0 : swing_type_bird = &FF

sw_mv_rt = &80
sw_mv_lf = &C0
sw_mv_no = &00
sw_0draw = &40

.swing_data \\ 72 84 100 112/116

\\ slow - from 72
.big_htom  : EQUB sw_0draw OR (60/2), sw_0draw OR (60/2), sw_0draw OR (60/2), (60/2), sw_0draw OR ( 8/2), sw_0draw OR ( 8/2), sw_0draw OR ( 8/2), sw_mv_lf OR ( 8/2)
.big_vv_0  : EQUB sw_0draw OR (60/2), sw_0draw OR (60/2), sw_0draw OR (60/2), (60/2)
.big_mv_l  : EQUB sw_0draw OR (60/2), sw_0draw OR (60/2), sw_0draw OR (60/2), sw_mv_lf OR (60/2), sw_0draw OR ( 8/2), sw_0draw OR ( 8/2), sw_0draw OR ( 8/2), ( 8/2)
.big_vv_l  : EQUB sw_0draw OR (60/2), sw_mv_lf OR (60/2)
.big_vl_0  : EQUB sw_0draw OR (56/2), sw_mv_lf OR (56/2)
.big_mv_r  : EQUB sw_0draw OR (56/2), sw_0draw OR (56/2), sw_0draw OR (56/2), (56/2), sw_0draw OR ( 4/2), sw_0draw OR ( 4/2), sw_0draw OR ( 4/2), sw_mv_rt OR ( 4/2)
.big_vv_r  : EQUB sw_0draw OR (56/2), sw_mv_rt OR (56/2)
.big_vr_0  : EQUB sw_0draw OR (60/2), sw_mv_rt OR (60/2)
.large_anims_end
.hatch_0  : EQUB sw_0draw OR  4/2,  4/2
.hatch_1  : EQUB sw_0draw OR 20/2, 20/2
.hatch_2  : EQUB sw_0draw OR 40/2, 40/2
.hatch_3  : EQUB sw_0draw OR 64/2, 64/2
.hatch_4  : EQUB sw_0draw OR 92/2, 92/2
.hatch_anims_end
.egg_rt_2 : EQUB sw_mv_rt OR ( 72/2), (112/2)
.egg_rt_1 : EQUB ( 72/2), sw_mv_rt OR (100/2), (112/2), (84/2)
.egg_mv_0 : EQUB ( 72/2)
.egg_lf_1 : EQUB ( 72/2), sw_mv_lf OR ( 84/2), (116/2), (100/2)
.egg_lf_2 : EQUB sw_mv_lf OR ( 72/2), (116/2)
.egg_init : EQUB ( 72/2)
.egg_mv_end
.fly_dead : EQUB sw_0draw OR (72/2)
.fly_dead_end

;;.anim_frame_counts : EQUB 8,4,8,2,2,8,2,2
.anim_frame_counts : EQUB 2,2,2,1,1,2,1,1
                     EQUB 2, 2, 2, 2, 2
                     EQUB 2, 4, 1, 4, 2, 1, 1
.anim_frame_starts : EQUB big_vv_0-swing_data, big_mv_l-swing_data, big_vv_l-swing_data, big_vl_0-swing_data, big_mv_r-swing_data, big_vv_r-swing_data, big_vr_0-swing_data, large_anims_end-swing_data
                     EQUB hatch_1-swing_data, hatch_2-swing_data, hatch_3-swing_data, hatch_4-swing_data, hatch_anims_end-swing_data
                     EQUB egg_rt_1-swing_data, egg_mv_0-swing_data, egg_lf_1-swing_data, egg_lf_2-swing_data, egg_init-swing_data, egg_mv_end-swing_data, fly_dead_end-swing_data
.anim_frame_reps   : EQUB 1,2,2,0,1,2,0,1
                     EQUB 4, 4, 4, 4, 4
                     EQUB 0, 1, 8, 1, 0, 1, 32
.anim_src_row_hi   : EQUB sw_fly_hi, sw_fly_hi, sw_fly_hi, sw_fly_hi, sw_fly_hi, sw_fly_hi, sw_fly_hi, sw_fly_hi
                     EQUB sw_hat_hi, sw_hat_hi, sw_hat_hi, sw_hat_hi, sw_hat_hi
                     EQUB sw_egg_hi, sw_egg_hi, sw_egg_hi, sw_egg_hi, sw_egg_hi, sw_egg_hi, sw_fly_hi
.anim_src_bytes    : EQUB 95,95,95,103,95,95,103,95
                     EQUB 23, 31, 39, 47, 63
                     EQUB 31, 31, 31, 31, 31, 31, 15
.anim_shot_offsets : EQUB 5*8, 6*8, 5*8, 6*8, 7*8, 6*8, 7*8, 6*8
                     EQUB 0, 0, 2*8, 3*8, 4*8
                     \\ only used for double height draws
.anim_shot_bytes   : EQUB &33, &CC, &33, &CC, &CC, &33, &CC, &CC
                     EQUB 0, 0, &33, &CC, &CC
                     \\ only used for double height draws

fly_htom = 0 : fly_vv_0 = 1 : fly_mv_l = 2 : fly_vv_l = 3 : fly_vl_0 = 4 : fly_mv_r = 5 : fly_vv_r = 6 : fly_vr_0 = 7 : edo_goto = &80
edo_hatch0 = 8 : edo_hatch1 = 9 : edo_hatch2 = 10 : edo_hatch3 = 11 : edo_hatch4 = 12
edo_rt_2 = 13 : edo_rt_1 = 14 : edo_mv_0 = 15 : edo_lf_1 = 16 : edo_lf_2 = 17 : edo_init_odd = 18 : flying_dead = 19

sw_egg_hi = HI(birds+&500) : sw_hat_hi = HI(birds+&100) : sw_fly_hi = HI(birds+&300)

.anim_seq   : EQUB edo_init_odd, edo_mv_0, edo_rt_1, edo_rt_2, edo_rt_1, edo_mv_0, edo_lf_1, edo_lf_2, edo_lf_1, edo_mv_0, edo_rt_1, edo_rt_2, edo_rt_1
            : EQUB edo_hatch0, edo_hatch1, edo_hatch2, edo_hatch3, edo_hatch4
			: EQUB fly_htom : .fly_loop : EQUB fly_vv_0, fly_mv_l, fly_vv_l, fly_mv_l, fly_vv_0, fly_vl_0, fly_mv_r, fly_vv_r, fly_mv_r, fly_vr_0, edo_goto OR (fly_loop - anim_seq)
.dead_loop  : EQUB flying_dead, edo_goto OR (dead_loop - anim_seq)
.swing_data_end

swing_frames_left   = stars  + 128             \\ init to 1
swing_current_frame = swing_frames_left  + 1   \\ init to -
swing_src_page      = swing_frames_left  + 8*2 \\ init to 1
swing_draw_bytes    = swing_src_page     + 1   \\ init to -
swing_frame_counts  = swing_src_page     + 8*2 \\ init to 1
swing_frame_starts  = swing_frame_counts + 1   \\ init to -
swing_anim_seq      = swing_frame_counts + 8*2 \\ init to 0
swing_reps_left     = swing_anim_seq     + 1   \\ init to 1
swing_bomb_offsets  = swing_anim_seq     + 8*2 \\ init to 0
swing_bomb_bytes    = swing_bomb_offsets + 1   \\ init to 1

; PRINT "swing_frames_left  ", ~swing_frames_left  
; PRINT "swing_current_frame", ~swing_current_frame
; PRINT "swing_src_page     ", ~swing_src_page     
; PRINT "swing_draw_bytes   ", ~swing_draw_bytes   
; PRINT "swing_frame_counts ", ~swing_frame_counts 
; PRINT "swing_frame_starts ", ~swing_frame_starts 
; PRINT "swing_anim_seq     ", ~swing_anim_seq     
; PRINT "swing_reps_left    ", ~swing_reps_left    
; PRINT "swing_bomb_offsets ", ~swing_bomb_offsets 
; PRINT "swing_bomb_bytes   ", ~swing_bomb_bytes   
; PRINT "bird_dst           ", ~bird_dst           
; PRINT "div_anim_frame     ", ~div_anim_frame     
; PRINT "div_anim_sprite    ", ~div_anim_sprite    

.bob_and_advance_bird_bombs
{
	lda ship_addr+1 : sec : sbc #FIRST_SWING_ROW * 2 : lsr A : and #31 : tax : and #17 : bne miss \\ x=bird index (b*2)
	lda swing_current_frame,x : cmp #fly_dead-swing_data : beq miss
	lda bird_dst+1,x : lsr A : lda bird_dst,x : ror A : sta local_b
	lda swing_bomb_offsets,x : lsr A : adc local_b : sta local_b ; second column of centre
	lda ship_addr+1 : lsr A : lda ship_addr : ror A ;; first column of ship in pixels
	eor #&FF : sec : adc local_b : cmp #21 : bcs miss
	lda shield_timer { bne safe : jmp collide_player : .safe }
	ldy swing_src_page,x : jsr kill_swing_bird
.miss

	dec swing_bob_timer : bmi swing_bob_new_time : bit player_dead : bmi done
	lda #7*8 : bit swing_bob_dir_freq : beq done : bmi swing_bob_down
;swing_bob_up
	inc pix_y : lda pix_y : and #7 : bne done : sta pix_y : inc row_y : lda row_y : and #&1F : ora #&20 : sta row_y
	lda ship_abtm+1 : sta ship_addr+1 : clc : adc #2 : and #&3F : ora #&40 : sta ship_abtm+1
	jmp done \\ allways
.swing_bob_down
	bvs drop_fast
.single 
	dec pix_y : bpl done : lda #7 : sta pix_y : dec row_y : lda row_y : ora #&20 : sta row_y
	lda ship_addr+1 : sta ship_abtm+1 : sec : sbc #2 : ora #&40 : sta ship_addr+1
	jmp done \\ allways
.swing_bob_new_time
	lda last_rand : and #7 : eor row_y : sbc #&5C/2 : and #16+3 : asl A : asl A : asl A : sta swing_bob_dir_freq
;;	jsr rand : and #31 : beq swing_bob_drop : and #31 : bne swing_bob_bob : sta swing_bob_dir_freq : .swing_bob_bob : ora #16 : sta swing_bob_timer
	jsr rand : and #30 : beq swing_bob_drop : .no_swing_bob_drop : adc #16 : sta swing_bob_timer
.done
	jmp advance_bird_bombs
.swing_bob_drop
	lda swing_src_page : cmp #sw_fly_hi : bne no_swing_bob_drop
	lda #&CC : sta swing_bob_dir_freq : lda #64 : sta swing_bob_timer : bne done \\ allways

.drop_fast
;	lda swing_src_page : cmp #sw_fly_hi : bne swing_bob_down
;	lda ship_abtm : sec : sbc #8 : sta ship_clr0 : eor #1 : sta ship_clr1 : eor #2 : sta ship_clr2 : eor #1 : sta ship_clr3
;	lda ship_abtm+1 : sbc #0
	lda ship_abtm : eor #1 : sta ship_clr1 : eor #2 : sta ship_clr2 : eor #1 : sta ship_clr3
	lda ship_abtm+1

;	lda ship_addr : sta local_w : lda ship_addr+1 : sbc #1 : ldy pix_y : iny : cpy #8 : bcc one_row : ldy #0 : sbc #254
;.one_row : ora #&40 : sta local_w+1 : tya : adc #8 : tay

	clc
	ldy pix_y : dey : dey : dey : dey : bpl same_row
	ldy #0 ;;;: adc #2 : and #&3F : ora #&40

.same_row
	sta ship_clr1+1        : sta ship_clr2+1        : sta ship_clr3+1
	ldx #0
;	txa : sta (ship_abtm),y : sta (ship_clr1),y : sta (ship_clr2),y : sta (ship_clr3),y : tya : adc #8 : tay
	txa : sta (ship_abtm),y : sta (ship_clr1),y : sta (ship_clr2),y : sta (ship_clr3),y : tya : adc #8 : tay
	txa : sta (ship_abtm),y : sta (ship_clr1),y : sta (ship_clr2),y : sta (ship_clr3),y : tya : adc #8 : tay
	txa : sta (ship_abtm),y : sta (ship_clr1),y : sta (ship_clr2),y : sta (ship_clr3),y : tya : adc #8 : tay
	txa : sta (ship_abtm),y : sta (ship_clr1),y : sta (ship_clr2),y : sta (ship_clr3),y
	dec pix_y : dec pix_y : dec pix_y
	jmp single
}

.special_reps
	lda bird_dst+1,x : lsr A : lda bird_dst,x : ror A : lsr A : lsr A : cpy #edo_rt_2 : beq calc_rt_reps : cpy #fly_vv_r : beq calc_rt_reps \\ c=0
;calc_lf_reps
	sbc #6 : bcc min_reps : bcs calc_tot \\ allways
.calc_rt_reps
	sta local_b : lda #46 : sbc local_b : bcc min_reps
.calc_tot
;	lsr A : sta local_b : and &FE44 : adc local_b : bne special_reps_done
	sta local_b : lda &FE44 : and #7 : eor local_b : bne special_reps_done
.min_reps
	lda #1 : bne special_reps_done \\ allways

.next_anim
	ldy swing_anim_seq,x : lda anim_seq,y : bpl next_seq
	and #&7F : sta swing_anim_seq,x : tay : lda anim_seq,y
.next_seq
	tay : inc swing_anim_seq,x
	lda anim_src_row_hi  ,y : sta swing_src_page    ,x
	lda anim_src_bytes   ,y : sta swing_draw_bytes  ,x
	lda anim_frame_starts,y : sta swing_frame_starts,x
	lda anim_frame_counts,y : sta swing_frame_counts,x
	lda anim_shot_offsets,y : sta swing_bomb_offsets,x
	lda anim_shot_bytes  ,y : sta swing_bomb_bytes  ,x
	lda anim_frame_reps  ,y : beq special_reps : .special_reps_done : sta swing_reps_left,x : bne next_rep \\ allways

.draw_swing 
	bird_src2 = boss_src
	bird_dst1 = local_w
	bird_dst2 = boss_data

	inc bird_timer : lda bird_timer : lsr A : bcc no_bob : jsr bob_and_advance_bird_bombs
;;	inc bird_timer : jsr bob_and_advance_bird_bombs // double speed !!!
.no_bob
	ldx bird_count : bmi draw_swing_done : ldx #(8-1)*2

.next
	dec swing_frames_left,x : bne current_rep
	dec swing_reps_left  ,x : beq next_anim
.next_rep
	lda swing_frame_starts,x : sta swing_current_frame,x
	lda swing_frame_counts,x : sta swing_frames_left  ,x
.current_rep
	dec swing_current_frame,x
	ldy swing_current_frame,x
	lda swing_data,y : asl A : bcs move_dst
	asl A : bcs draw2_done : sta bird_src : sta bird_src2 \\: bcc move_rt \\ sw_mv_sp reserved, could just remove /2
	lda bird_dst  ,x : sta bird_dst1 : sta bird_dst2
	lda bird_dst+1,x
.draw
	sta bird_dst1+1 : adc #2 : sta bird_dst2+1
	ldy swing_src_page,x : sty bird_src+1 : cpy #sw_egg_hi : beq single_height : iny : sty bird_src2+1

	{ldy swing_draw_bytes,x : .lp
	lda (bird_src),y : sta (bird_dst1),y : lda (bird_src2),y : sta (bird_dst2),y : dey
	lda (bird_src),y : sta (bird_dst1),y : lda (bird_src2),y : sta (bird_dst2),y : dey
	bpl lp}

	lda swing_bomb_offsets,x : bne maybe_drop_bomb
.draw2_done
	dex : dex : bpl next : bmi draw_swing_done \\ allways
.single_height
	{ldy swing_draw_bytes,x : .lp : lda (bird_src),y : sta (bird_dst1),y : dey : bpl lp}
	dex : dex : bpl next

.draw_swing_done

	RTS
.move_dst
	asl A : sta bird_src : sta bird_src2 : bcc move_rt
;move_lf
	lda bird_dst  ,x : sbc #8 : sta bird_dst  ,x : sta bird_dst1 : sta bird_dst2
	lda bird_dst+1,x : sbc #0 : sta bird_dst+1,x : clc : bne draw \\ allways
.move_rt
	lda bird_dst  ,x : adc #8 : sta bird_dst  ,x : sta bird_dst1 : sta bird_dst2
	lda bird_dst+1,x : adc #0 : sta bird_dst+1,x : bne draw \\ allways

.maybe_drop_bomb
{
    ldy bird_shot_top_count : bmi room : cpy bird_shot_level_max : bcs no_room : .room : iny : iny \\ (max_bird_shots-1)
	jsr rand : cmp #64 : bcs no_room \\ C=0
	lda bird_dst2   : adc swing_bomb_offsets,x            : sta bird_shot_top_addr  ,y
	lda bird_dst2+1 : adc #0 : and #&7F : ora #&40        : sta bird_shot_top_addr+1,y
	lsr A : eor #63 : sec : adc row_y : adc #26 : and #31 : sta bird_shot_top_row   ,y
	lda swing_bomb_bytes,x                                : sta bird_shot_top_byte  ,y
	sty bird_shot_top_count
.no_room
	jmp draw2_done
}

.hit_stars
.kill_if_hit_walker \\ TODO maybe swap for swing collision type
{
	lda bullet_addr+1 : lsr A : sta ph_row+sm_im : sta ph_row_d0+sm_im : sta ph_row_d1+sm_im
	lda bullet_addr   : ror A : sta ny_sub+sm_im : sta ny_sub_d0+sm_im : sta ny_sub_d1+sm_im

	ldx diving_bird_first \\ top row

.check_diving_top
	cpx #max_diving_birds*2 : bcs check_diving_top_done
	lda div_bytes_tall    ,x    ; %wwww111h (width-1) (height-1)
	lsr A : lsr A : adc #0 : sta sr_off_d0+sm_im
	lda bird_dst+b2d+1,x : lsr A : .ph_row_d0 : eor #HI(scr_addr) : bne try_next_top
	lda bird_dst+b2d,x : ror A : sta local_b \\ C=0
	.ny_sub_d0 : lda #LO(scr_addr) : sec : sbc local_b : bcc try_next_top
	.sr_off_d0 : cmp #bird_bytes : bcs try_next_top
	sta local_b \\ C=0
	
	ldy div_anim_sprite   ,x    ; sprite index
	lda diving_spr        ,y    ; xxxxxyyy
	and #&F8                    ; xxxxx---
	sta local_w
	eor diving_spr        ,y    ; -----yyy
	adc #HI(birds)
	sta local_w+1

	ldy local_b : stx local_b	
	ldx #7 : lda #0 : {.lp : ora (local_w),y : iny : dex : bpl lp} : ldx local_b : and bullet_byte : beq try_next_top : jmp hit_diving_bird_x
.try_next_top
	inx : inx : bne check_diving_top \\ allways
.check_diving_top_done

	ldx diving_bird_first \\ top row

.check_diving_btm
	cpx #max_diving_birds*2 : bcs check_diving_btm_done
	lda div_bytes_tall    ,x    ; %wwww111h (width-1) (height-1)
	lsr A : bcc try_next_btm
	lsr A : adc #0 : sta sr_off_d1+sm_im \\ C=0
	lda bird_dst+b2d+1,x : adc #2 : lsr A : .ph_row_d1 : eor #HI(scr_addr) : bne try_next_btm
	lda bird_dst+b2d,x : ror A : sta local_b \\ C=0
	.ny_sub_d1 : lda #LO(scr_addr) : sec : sbc local_b : bcc try_next_btm
	.sr_off_d1 : cmp #bird_bytes : bcs try_next_btm
	sta local_b \\ C=0
	
	ldy div_anim_sprite   ,x    ; sprite index
	lda diving_spr        ,y    ; xxxxxyyy
	and #&F8                    ; xxxxx---
	sta local_w
	eor diving_spr        ,y    ; -----yyy
	adc #HI(birds)+1            ; +1 second row
	sta local_w+1

	ldy local_b : stx local_b	
	ldx #7 : lda #0 : {.lp : ora (local_w),y : iny : dex : bpl lp} : ldx local_b : and bullet_byte : bne hit_diving_bird_x
.try_next_btm
	inx : inx : bne check_diving_btm \\ allways
.check_diving_btm_done


.check_walking
	ldx bird_count : bmi done
	lda bird_bytes : lsr A : sta sr_off+sm_im : lda bird_src+1 : sta local_w+1
.find_hit_bird
	lda bird_dst+1,x : lsr A : .ph_row : eor #HI(scr_addr) : bne try_next
	lda bird_dst,x : ror A : eor #&FF : sec : .ny_sub : adc #bird_bytes : bcc try_next : .sr_off : cmp #bird_bytes : bcs try_next
	asl A : adc bird_src : sta local_w
	ldy #7 : lda #0 : {.lp : ora (local_w),y : dey : bpl lp} : and bullet_byte : bne hit_bird_x
.try_next
	dex : dex : bpl find_hit_bird
.done
	RTS

.hit_bird_x
	lda bird_dst,x : sta local_w : lda bird_dst+1,x : sta local_w+1
	ldy bird_bytes : dey : lda #0 : .clr : sta (local_w),y : dey : bpl clr

	ldy bird_count : lda bird_dst,y : sta bird_dst,x : lda bird_dst+1,y : sta bird_dst+1,x
	dey : dey : sty bird_count : inc draw_birds_bcc+sm_im : inc draw_birds_bcc+sm_im
	lda #2 : jsr add_score

;;;	jsr rand : and #7 : jsr start_diving_bird

	ldx #0 : stx bullet_byte : jmp start_explosion
\\	RTS

.hit_diving_bird_x
{
	ldy div_anim_sprite   ,x    ; sprite index
	lda diving_spr        ,y    ; xxxxxyyy
	ldy #&20
	cmp #80 : bcc maybe_200 : cmp #176 : bcc sc_40 : .maybe_200
	and #6 : eor #6 : beq sc_200
.sc_40
	ldy #4
.sc_200
	sty local_b

;	lda bird_dst+b2d,x : sta local_w : lda bird_dst+b2d+1,x : sta local_w+1
;	lda div_bytes_tall    ,x : lsr A : tay ; %wwww111h (width-1) (height-1)
;	{lda #0 : .clr : sta (local_w),y : dey : bpl clr}
;	txa : ldx local_w+1
;	inc stars-&40,x : inc stars-&40+1,x
;	tax
;	bcc clr_done
;	inc local_w+1 : inc local_w+1
;	lda div_bytes_tall    ,x : lsr A : tay ; %wwww111h (width-1) (height-1)
;	{lda #0 : .clr : sta (local_w),y : dey : bpl clr}
;	txa : ldx local_w+1
;	inc stars-&40,x : inc stars-&40+1,x
;	tax
.clr_done

	ldy diving_bird_first
	lda bird_dst+b2d   ,y : sta bird_dst+b2d   ,x
	lda bird_dst+b2d+1 ,y : sta bird_dst+b2d+1 ,x
	lda div_bytes_tall ,y : sta div_bytes_tall ,x ; %wwww111h (width-1) (height-1)
	lda div_vsyncs_left,y : sta div_vsyncs_left,x ; %000000vv (vsyncs-1)
	lda div_vert_direct,y : sta div_vert_direct,x
	lda div_frame_end  ,y : sta div_frame_end  ,x
	lda div_anim_frame ,y : sta div_anim_frame ,x
	lda div_anim_sprite,y : sta div_anim_sprite,x

	cpx dive_shooting : bne not_killed : dec dive_shots_left : dec dive_shots_left : .not_killed
	cpy dive_shooting : bne not_moved  : stx dive_shooting                         : .not_moved

	iny : iny : sty diving_bird_first

	lda local_b : pha : jsr add_score
;;;	jsr rand : and #7 : jsr start_diving_bird
	ldx #0 : stx bullet_byte
	pla : cmp #&20 : bne small_explosion
	jmp start_big_explosion
.small_explosion
	jmp start_explosion
\\	RTS
}
}

boss_top_gap = 6 : boss_top_rows = 4
.hit_boss_bonus
{
	asl A : adc #1 : sta local_b : asl A : adc local_b : asl A : tay : ldx #6
	bonus_addr = scr_addr+(boss_top_gap+boss_top_rows+3)*&200+&100-32
	{.lp : lda text,y : sta bonus_addr,x : lda text+6,y : sta bonus_addr+8,x
	lda text,x : sta bonus_addr+16,x : sta bonus_addr+32,x : sta bonus_addr+48,x
	lda text+6,x : sta bonus_addr+24,x : sta bonus_addr+40,x : sta bonus_addr+56,x : dey : dex : bne lp}

	pla : sei : sed : adc score+1 : sta score+1 : lda score+2 : adc #0 : cld : cli
	sta score+2 : lda pix_y : asl A : asl A : asl A : asl A : jmp add_score
}
.hit_boss
{
	jsr kill_if_hit_walker : lda bullet_byte : beq done

	\\ check for hit ship/alien - assume ship for now
	lda bullet_addr+1 : lsr A : tay : lda bullet_addr : ror A : lsr A : lsr A : sec : sbc #2*(15-8) : bcc done : cmp #2*(2*9) : bcs done
	cpy #(HI(scr_addr)+(boss_top_gap+boss_top_rows)*2)/2 : beq hit_shield : bcs hit_hull
	cmp #&10 : bcc done : cmp #&14 : bcs done
	ldy #max_diving_birds*2 : sty diving_bird_first : ldy #&FF : sty bird_count : iny : sty draw_birds_bcc+sm_im
	lda bullet_addr+1 : ora #3 : sta bullet_addr+1 : lda #0 : sta bullet_addr
	ldx #0 : stx feature_timer : stx bullet_byte : jsr start_explosion ;;;;; jsr eor_explosions+3 ;; skip big explosions
	dec bullet_addr+1 : dec bullet_addr+1 : jsr start_big_explosion
	lda #HI((scr_addr+(32-top_rows)*&200)/2) : sec : sbc row_y : pha : jmp hit_boss_bonus
.done
	ldx #0 : stx bullet_byte
	RTS
.hit_shield
	tax : lda shield,x : eor #&80 : bpl not_gone : lda #0 : .not_gone : sta shield,x : sta draw_shield_tile+sm_lo
	ldy #7 : .draw_shield_tile : lda boss+&100,y : sta (bullet_addr),y : dey : bpl draw_shield_tile : bmi done \\ allways
\\	RTS
.hit_hull
	lsr A : tax

;;;;tya : clc : sbc #(HI(scr_addr)+(boss_top_gap+boss_top_rows)*2)/2 : asl A : asl A : cmp hull,x : beq in_hull : bcc in_hull : brk : jmp hit_boss : .in_hull

	lda bullet_addr : and #&F0 : sta bullet_addr
	lda hull,x : dec hull,x : beq clear_char : and #3 : beq draw_fat_above
	tay : lda hull_to_boss-1,y : sta draw_partial+sm_lo
	ldy #15 : .draw_partial : lda boss+&100,y : sta (bullet_addr),y : dey : bpl draw_partial : bmi done \\ allways
.draw_fat_above
	ldx bullet_addr+1 : dex : dex : stx bullet_addr+1
	ldy #15 : .draw_fat : lda boss+&100+hull_4,y : sta (bullet_addr),y : dey : bpl draw_fat
	inx : inx : stx bullet_addr+1
.clear_char
	ldx bullet_addr+1 : inc stars-&40,x
	ldy #15 : lda #0 : .clr_hull : sta (bullet_addr),y : dey : bpl clr_hull : bmi done \\ allways
\\	RTS
}

.draw_feature
{
	jmp (feature_draw)
}

.continue_ship_explosion
{
	lda feature_timer : cmp #64 : bcs done : lsr A : bcs done : lsr A : bcs done : lsr A : bcs done : lsr A : bcs done
	tay : lda explosion_btm-1,y : sta local_b
	lda explosion_top-1,y : sta bullet_addr+1 : ldx #0 : jsr start_big_explosion
	lda local_b           : sta bullet_addr+1 : ldx #0 : jmp start_big_explosion
.done
	RTS        : shield = HI(scr_addr)+(boss_top_gap+boss_top_rows)*2+1
.explosion_top : EQUB shield-8, shield-12, shield-16, shield-20
.explosion_btm : EQUB shield  , shield+4, shield + 8, shield+12
}

.draw_boss
{
	{ldx boss_scroll_stars : beq no_scroll : inc stars-&40,x : inc stars-&40+1,x : ldx #0 : stx boss_scroll_stars : .no_scroll}
	jsr draw_stars
	\\ draw top half of ship
	btm_depth = 4 : max_hull_row = 4
	chrs_left = local_b : boss_dst = local_w

	inc feature_timer : lda bird_count : bmi continue_ship_explosion
	
	lda feature_timer : and #7 { beq time : jmp not_time : .time } \\ scroll shield every 8 clocks
	ldy shield+9*4-1 : ldx #9*4-2 : .rotate_shield : lda shield,x : sta shield+1,x : dex : bpl rotate_shield : sty shield
	inc stars+(boss_top_gap+boss_top_rows)*2

	lda feature_timer : and #31 : bne not_time \\ lower mothership every 32 clocks

    ldy bird_shot_top_count : bmi room : cpy bird_shot_level_max : bcs no_room : .room : iny : iny \\ (max_bird_shots-1)
	ldx #(boss_top_gap+boss_top_rows)*2+1 : jsr rand : and #8 : bne right : dex : lda #&F0 : .right
	sta bird_shot_top_addr  ,y : txa : sta bird_shot_top_addr+1,y
	lsr A : eor #63 : sec : adc row_y : adc #26 : and #31 : sta bird_shot_top_row   ,y : lda #&66 : sta bird_shot_top_byte  ,y
	sty bird_shot_top_count
.no_room

	ldx pix_y : dex : bpl same_char : lda row_y : cmp #&72/2 : beq not_time : sec : sbc #1 : ora #&40/2 : sta row_y
	asl A : sta boss_scroll_stars : ldx #7
	lda ship_addr+1 : sta ship_abtm+1 : sec : sbc #2 : ora #&40 : sta ship_addr+1
.same_char : stx pix_y

	lda row_y : asl A
	adc #(top_rows-StarsToBtm)*2 : and #&3f : ora #&40 : sta clr_line+2+sm_hi
	adc #1    : and #&3f : ora #&40 : sta clr_line+5+sm_hi
	ldy pix_y
.clr_line
	lda #0 : sta scr_addr,y : sta scr_addr,y
	tya : adc #8 : tay : bcc clr_line

.not_time

	lda #HI(scr_addr + (boss_top_gap+boss_top_rows-1) * &200)+1 : sta boss_dst+1 : ldx #boss_top_rows * 2 - 1
.nxt
	lda stars+boss_top_gap*2,x : dex : ora stars+boss_top_gap*2,x : beq skip \\ stars+&40 is reserved for enabling stars for offscreen birds

	txa : lsr A : tay : lda boss_layout,y : clc : adc #LO(boss_layout) : sta boss_data : lda #HI(boss_layout) : adc #0 : sta boss_data+1
	ldy #0 : lda (boss_data),y : and #&F0 : sta boss_dst : eor (boss_data),y : sta chrs_left
.draw_chrs
	ldy chrs_left : lda (boss_data),y : asl A : sta boss_src : lda #HI(boss) : adc #0 : sta boss_src+1
	ldy #15 : .loop : lda (boss_src),y : sta (boss_dst),y : dey : bpl loop
	lda boss_dst : sec : sbc #16 : sta boss_dst : bcs same_half : dec boss_dst+1 : .same_half
	dec chrs_left : bne draw_chrs : inc boss_dst+1

;;;	lda #0 : sta stars+boss_top_gap,x
.skip
	dec boss_dst+1 : dec boss_dst+1 : dex : bpl nxt

	left_end = scr_addr+(boss_top_gap+boss_top_rows)*&200+&68 : right_end = scr_addr+(boss_top_gap+boss_top_rows)*&200+&190
	lda stars+(boss_top_gap+boss_top_rows)*2 : ora stars+(boss_top_gap+boss_top_rows)*2+1 : beq skip_shield \\ stars+&40 is reserved for enabling stars for offscreen birds
	ldy #7 : .ends : lda boss+&1B0,y : sta left_end,y : lda boss+&1B8,y : sta right_end,y : dey : bpl ends
	lda #LO(right_end-8) : sta boss_dst : lda #HI(right_end-8) : sta boss_dst+1
	{sec : ldx #9*4-1 : .draw_shield : lda shield,x : sta shield_src+sm_lo : ldy #7 : .shield_src : lda boss+&100,y : sta (boss_dst),y : dey : bpl shield_src
	lda boss_dst : sbc #8 : sta boss_dst : bcs same_half : sec : dec boss_dst+1 : .same_half : dex : bpl draw_shield}
;;;	lda #0 : sta stars+(boss_top_gap+boss_top_rows)*2 : sta stars+(boss_top_gap+boss_top_rows)*2+1
.skip_shield

	hull_top_row = scr_addr + (boss_top_gap+boss_top_rows+1) * &200

	ldx #HI(hull_top_row + max_hull_row * &200)   : ldy #256-2*8  : lda #LO(hull + 0) : jsr draw_hull_half
	ldx #HI(hull_top_row + max_hull_row * &200)+1 : ldy #(18-2)*8 : lda #LO(hull + 9) : \\jmp draw_hull_half
\\	RTS

	hull_row = local_b
.draw_hull_half
	sty right_char+sm_lo : sta hull_depth+sm_lo : lda #max_hull_row*4 : sta hull_row
.draw_hull_row
	lda stars-&40,x : beq skip_hull_row : stx boss_dst+1
	ldx #8 : .right_char : lda #0 : sta boss_dst
	.hull_depth : lda hull,x : beq gap : sec : sbc hull_row : bcc gap : cmp #4 : bcs full_block
	tay : lda hull_to_boss,y : sta hull_src+sm_lo
	ldy #15 : .hull_src : lda boss+&100,y : sta (boss_dst),y : dey : bpl hull_src
.gap
	lda boss_dst : sec : sbc #16 : sta boss_dst : dex : bpl hull_depth
	ldx boss_dst+1
.skip_hull_row
	lda hull_row : sec : sbc #4 : sta hull_row : dex : dex : cpx #HI(hull_top_row) : bcs draw_hull_row
	RTS
.full_block
	lda #&F0 : ldy #15 : .lp : sta (boss_dst),y : dey : bpl lp : bmi gap \\ allways
}


\\.draw_birds // call with C=0, Y = byte count (not -1)
{
	FOR b,15,0,-1
		sta (bird_dst+b*2),y
	NEXT
}.draw_birds{
	dey : cpy #255
	lda (bird_src),y
}.draw_birds_bcc{
	bcc draw_birds-16*2 \\ will be updated as birds added/removed - default all
	RTS
}


;\\ fallthrough
;.draw_diving_birds \\ X=bird \\ div_anim_frame,x is likely to be one too many !!!
;{
;	ldx diving_bird_first \\ clear will be filled in from draw at end of draw
;	lda #&FD
;	sta draw_16_bytes_top+1+sm_im
;	sta draw_24_bytes_top+1+sm_im
;	sta draw_32_bytes_top+1+sm_im
;	sta draw_16_bytes_btm+1+sm_im
;	sta draw_24_bytes_btm+1+sm_im
;	sta draw_32_bytes_btm+1+sm_im
;	
;	cpx #max_diving_birds*2
;\\	bcs done                    ; C=0
;bcc ok : RTS : .ok
;
;.draw_next_bird \\ C=0
;
;	ldy div_anim_sprite   ,x    ; sprite index
;	lda diving_spr        ,y    ; xxxxxyyy
;	and #&F8                    ; xxxxx---
;	sta local_w
;	eor diving_spr        ,y    ; -----yyy
;	adc #HI(birds)
;	sta local_w+1
;	lda div_bytes_tall    ,x    ; %wwww111h (width-1) (height-1)
;	lsr A                       ; C=double height A=width in bytes - 1
;.draw_row
;	lsr A : lsr A : lsr A : lsr A : bcs not_bytes_23
;
;.bytes_23 ; C=0
;{
;	lda draw_24_bytes_top+1+sm_im
;	sbc #6*3-1 : tay           \\ C=0>1
;	lda local_w              : sta draw_24_bytes_top-&FD+0*3+sm_lo,y
;	lda local_w+1            : sta draw_24_bytes_top-&FD+0*3+sm_hi,y
;	lda bird_dst+b2d      ,x : sta draw_24_bytes_top-&FD+3*3+sm_lo,y
;	                           sta draw_24_bytes_top-&FD+5*3+sm_lo,y
;	lda bird_dst+b2d+1    ,x : sta draw_24_bytes_top-&FD+3*3+sm_hi,y
;	                           sta draw_24_bytes_top-&FD+5*3+sm_hi,y
;	sty draw_24_bytes_top+1+sm_im
;
;	lda div_bytes_tall    ,x : lsr A \\ C=double-height ; %wwww111h (width-1) (height-1)
;	bcc single_24_draw         \\ C=1
;
;	lda draw_24_bytes_btm+1+sm_im
;	sbc #6*3 : tay             \\ C=1>1
;	lda local_w              : sta draw_24_bytes_btm-&FD+0*3+sm_lo,y
;	lda local_w+1 : adc #1-1 : sta draw_24_bytes_btm-&FD+0*3+sm_hi,y  \\ C=1>0
;	lda bird_dst+b2d      ,x : sta draw_24_bytes_btm-&FD+3*3+sm_lo,y
;	                           sta draw_24_bytes_btm-&FD+5*3+sm_lo,y
;	lda bird_dst+b2d+1    ,x : adc #2                                 \\ C=0>0
;and #HI(scr_addr-1) : ora #HI(scr_addr) \\ TODO remove when diving don't go off top/bottom
;	                           sta draw_24_bytes_btm-&FD+3*3+sm_hi,y
;	                           sta draw_24_bytes_btm-&FD+5*3+sm_hi,y
;	sty draw_24_bytes_btm+1+sm_im
;
;.single_24_draw              \\ C=0
;
;	jmp do_draw \\ allways
;}
;
;.not_bytes_23 : lsr A : bcc bytes_15
;
;.bytes_31 ; C=1
;{
;	lda draw_32_bytes_top+1+sm_im
;	sbc #6*3 : tay           \\ C=1>1
;	lda local_w              : sta draw_32_bytes_top-&FD+0*3+sm_lo,y
;	lda local_w+1            : sta draw_32_bytes_top-&FD+0*3+sm_hi,y
;	lda bird_dst+b2d      ,x : sta draw_32_bytes_top-&FD+3*3+sm_lo,y
;	                           sta draw_32_bytes_top-&FD+5*3+sm_lo,y
;	lda bird_dst+b2d+1    ,x : sta draw_32_bytes_top-&FD+3*3+sm_hi,y
;	                           sta draw_32_bytes_top-&FD+5*3+sm_hi,y
;	sty draw_32_bytes_top+1+sm_im
;
;	lda div_bytes_tall    ,x : lsr A ; %wwww111h (width-1) (height-1)
;	bcc single_32_draw         \\ C=1
;
;	lda draw_32_bytes_btm+1+sm_im
;	sbc #6*3 : tay             \\ C=1>1
;	lda local_w              : sta draw_32_bytes_btm-&FD+0*3+sm_lo,y
;	lda local_w+1 : adc #1-1 : sta draw_32_bytes_btm-&FD+0*3+sm_hi,y  \\ C=1>0
;	lda bird_dst+b2d      ,x : sta draw_32_bytes_btm-&FD+3*3+sm_lo,y
;	                           sta draw_32_bytes_btm-&FD+5*3+sm_lo,y
;	lda bird_dst+b2d+1    ,x : adc #2                                 \\ C=0>0
;and #HI(scr_addr-1) : ora #HI(scr_addr) \\ TODO remove when diving don't go off top/bottom
;	                           sta draw_32_bytes_btm-&FD+3*3+sm_hi,y
;	                           sta draw_32_bytes_btm-&FD+5*3+sm_hi,y
;	sty draw_32_bytes_btm+1+sm_im
;
;.single_32_draw              \\ C=0
;
;	bne do_draw \\ allways
;}
;
;.bytes_15 ; C=0
;{
;	lda draw_16_bytes_top+1+sm_im
;	sbc #6*3-1 : tay           \\ C=0>1
;	lda local_w              : sta draw_16_bytes_top-&FD+0*3+sm_lo,y
;	lda local_w+1            : sta draw_16_bytes_top-&FD+0*3+sm_hi,y
;	lda bird_dst+b2d      ,x : sta draw_16_bytes_top-&FD+3*3+sm_lo,y
;	                           sta draw_16_bytes_top-&FD+5*3+sm_lo,y
;	lda bird_dst+b2d+1    ,x : sta draw_16_bytes_top-&FD+3*3+sm_hi,y
;	                           sta draw_16_bytes_top-&FD+5*3+sm_hi,y
;	sty draw_16_bytes_top+1+sm_im
;
;	lda div_bytes_tall    ,x : lsr A ; %wwww111h (width-1) (height-1)
;	bcc single_16_draw         \\ C=1
;
;	lda draw_16_bytes_btm+1+sm_im
;	sbc #6*3 : tay             \\ C=1>1
;	lda local_w              : sta draw_16_bytes_btm-&FD+0*3+sm_lo,y
;	lda local_w+1 : adc #1-1 : sta draw_16_bytes_btm-&FD+0*3+sm_hi,y  \\ C=1>0
;	lda bird_dst+b2d      ,x : sta draw_16_bytes_btm-&FD+3*3+sm_lo,y
;	                           sta draw_16_bytes_btm-&FD+5*3+sm_lo,y
;	lda bird_dst+b2d+1    ,x : adc #2                                 \\ C=0>0
;and #HI(scr_addr-1) : ora #HI(scr_addr) \\ TODO remove when diving don't go off top/bottom
;	                           sta draw_16_bytes_btm-&FD+3*3+sm_hi,y
;	                           sta draw_16_bytes_btm-&FD+5*3+sm_hi,y
;	sty draw_16_bytes_btm+1+sm_im
;
;.single_16_draw              \\ C=0
;
;\\	bne do_draw \\ allways
;}
;
;.do_draw
;
;.draw_done
;	inx : inx
;	cpx #max_diving_birds*2
;	bcs draw_diving_birds_in_batches
;	jmp draw_next_bird          ; allways
;.done
;\\	RTS
;}
;
;.draw_diving_birds_in_batches
;{
;	ldy #15 : bpl draw_16_bytes_top+1
;
;	FOR d,0,max_diving_birds
;	{
;		lda birds,y
;		sta ld_mask+sm_lo
;	.ld_mask
;		lda masks
;		and scr_addr,y
;		ora ld_mask+sm_lo
;		sta scr_addr,y
;	}
;	NEXT
;}.draw_16_bytes_top{
;	dey
;	bpl draw_16_bytes_top
;
;	ldy #15 : bpl draw_16_bytes_btm+1
;
;	FOR d,0,max_diving_birds
;	{
;		lda birds,y
;		sta ld_mask+sm_lo
;	.ld_mask
;		lda masks
;		and scr_addr,y
;		ora ld_mask+sm_lo
;		sta scr_addr,y
;	}
;	NEXT
;}.draw_16_bytes_btm{
;	dey
;	bpl draw_16_bytes_btm
;
;	ldy #23 : bpl draw_24_bytes_top+1
;
;	FOR d,0,max_diving_birds
;	{
;		lda birds,y
;		sta ld_mask+sm_lo
;	.ld_mask
;		lda masks
;		and scr_addr,y
;		ora ld_mask+sm_lo
;		sta scr_addr,y
;	}
;	NEXT
;}.draw_24_bytes_top{
;	dey
;	bpl draw_24_bytes_top
;
;	ldy #23 : bpl draw_24_bytes_btm+1
;
;	FOR d,0,max_diving_birds
;	{
;		lda birds,y
;		sta ld_mask+sm_lo
;	.ld_mask
;		lda masks
;		and scr_addr,y
;		ora ld_mask+sm_lo
;		sta scr_addr,y
;	}
;	NEXT
;}.draw_24_bytes_btm{
;	dey
;	bpl draw_24_bytes_btm
;
;	ldy #31 : bpl draw_32_bytes_top+1
;
;	FOR d,0,max_diving_birds
;	{
;		lda birds,y
;		sta ld_mask+sm_lo
;	.ld_mask
;		lda masks
;		and scr_addr,y
;		ora ld_mask+sm_lo
;		sta scr_addr,y
;	}
;	NEXT
;}.draw_32_bytes_top{
;	dey
;	bpl draw_32_bytes_top
;
;	ldy #31 : bpl draw_32_bytes_btm+1
;
;	FOR d,0,max_diving_birds
;	{
;		lda birds,y
;		sta ld_mask+sm_lo
;	.ld_mask
;		lda masks
;		and scr_addr,y
;		ora ld_mask+sm_lo
;		sta scr_addr,y
;	}
;	NEXT
;}.draw_32_bytes_btm{
;	dey
;	bpl draw_32_bytes_btm
;
;	\\ copy draw addresses to clear
;
;	ldy #&FD
;	lda draw_32_bytes_top+1+sm_im : clc : adc #3*3 : bcs done_32_top : tax 
;.copy_32_top
;	dey : dey : dey
;	lda draw_32_bytes_top-&FD+sm_lo,x : sta clear_32_bytes-&FD+sm_lo,y   : adc #32
;	lda draw_32_bytes_top-&FD+sm_hi,x : sta clear_32_bytes-&FD+sm_hi,y   : and #&3F : sta lhs32+sm_lo : adc #0 : sta rhs32+sm_lo : .lhs32 inc stars : .rhs32 inc stars
;	txa : adc #6*3 : tax : bcc copy_32_top  \\ C=0
;.done_32_top  \\ C=1
;	lda draw_32_bytes_btm+1+sm_im : adc #3*3-1 : bcs done_32_btm : tax  \\ C:1>0
;.copy_32_btm
;	dey : dey : dey
;	lda draw_32_bytes_btm-&FD+sm_lo,x : sta clear_32_bytes-&FD+sm_lo,y   : adc #32
;	lda draw_32_bytes_btm-&FD+sm_hi,x : sta clear_32_bytes-&FD+sm_hi,y   : and #&3F : sta lbs32+sm_lo : adc #0 : sta rbs32+sm_lo : .lbs32 inc stars : .rbs32 inc stars
;	txa : adc #6*3 : tax : bcc copy_32_btm  \\ C=0
;.done_32_btm
;	sty clear_32_bytes+1+sm_im              \\ C=1
;
;	ldy #&FD
;	lda draw_24_bytes_top+1+sm_im : adc #3*3-1 : bcs done_24_top : tax 
;.copy_24_top
;	dey : dey : dey
;	lda draw_24_bytes_top-&FD+sm_lo,x : sta clear_24_bytes-&FD+sm_lo,y   : adc #24
;	lda draw_24_bytes_top-&FD+sm_hi,x : sta clear_24_bytes-&FD+sm_hi,y   : and #&3F : sta lhs24+sm_lo : adc #0 : sta rhs24+sm_lo : .lhs24 inc stars : .rhs24 inc stars
;	txa : adc #6*3 : tax : bcc copy_24_top  \\ C=0
;.done_24_top  C=1
;	lda draw_24_bytes_btm+1+sm_im : adc #3*3-1 : bcs done_24_btm : tax  \\ c:1>0
;.copy_24_btm
;	dey : dey : dey
;	lda draw_24_bytes_btm-&FD+sm_lo,x : sta clear_24_bytes-&FD+sm_lo,y   : adc #24
;	lda draw_24_bytes_btm-&FD+sm_hi,x : sta clear_24_bytes-&FD+sm_hi,y   : and #&3F : sta lbs24+sm_lo : adc #0 : sta rbs24+sm_lo : .lbs24 inc stars : .rbs24 inc stars
;	txa : adc #6*3 : tax : bcc copy_24_btm  \\ C=0
;.done_24_btm
;	sty clear_24_bytes+1+sm_im              \\ C=1
;
;	ldy #&FD
;	lda draw_16_bytes_top+1+sm_im : adc #3*3-1 : bcs done_16_top : tax 
;.copy_16_top
;	dey : dey : dey
;	lda draw_16_bytes_top-&FD+sm_lo,x : sta clear_16_bytes-&FD+sm_lo,y   : adc #16
;	lda draw_16_bytes_top-&FD+sm_hi,x : sta clear_16_bytes-&FD+sm_hi,y   : and #&3F : sta lhs16+sm_lo : adc #0 : sta rhs16+sm_lo : .lhs16 inc stars : .rhs16 inc stars
;	txa : adc #6*3 : tax : bcc copy_16_top  \\ C=0
;.done_16_top  \\ C=1
;	lda draw_16_bytes_btm+1+sm_im : adc #3*3-1 : bcs done_16_btm : tax 
;.copy_16_btm
;	dey : dey : dey
;	lda draw_16_bytes_btm-&FD+sm_lo,x : sta clear_16_bytes-&FD+sm_lo,y   : adc #16
;	lda draw_16_bytes_btm-&FD+sm_hi,x : sta clear_16_bytes-&FD+sm_hi,y   : and #&3F : sta lbs16+sm_lo : adc #0 : sta rbs16+sm_lo : .lbs16 inc stars : .rbs16 inc stars
;	txa : adc #6*3 : tax : bcc copy_16_btm  \\ C=0
;.done_16_btm  \\ C=1
;	sty clear_16_bytes+1+sm_im              \\ C=1
;
;	RTS
;}









.setup_eor_diving_birds \\ X=bird \\ div_anim_frame,x is likely to be one too many !!!
{
	lda ship_addr+1 : lsr A : lda ship_addr : ror A : adc #12+1 : sta local_b ;; third column of ship in pixels

	ldx diving_bird_first \\ clear will be filled in from draw at end of draw
	lda #&FD
	sta eor_16_bytes_top+1+sm_im
	sta eor_24_bytes_top+1+sm_im
	sta eor_32_bytes_top+1+sm_im
	sta eor_16_bytes_btm+1+sm_im
	sta eor_24_bytes_btm+1+sm_im
	sta eor_32_bytes_btm+1+sm_im
	
	cpx #max_diving_birds*2 : {bcc ok : RTS : .ok}
}
.eor_next_bird \\ C=0
{
	ldy div_anim_sprite   ,x    ; sprite index
	lda diving_spr        ,y    ; xxxxxyyy
	and #&F8                    ; xxxxx---
	sta local_w
	eor diving_spr        ,y    ; -----yyy
	adc #HI(birds)
	sta local_w+1
	lda div_bytes_tall    ,x    ; %wwww111h (width-1) (height-1)
	lsr A                       ; C=double height A=width in bytes - 1
.draw_row
	lsr A : lsr A : lsr A : lsr A : bcs not_bytes_23

.bytes_23 ; C=0
{
	lda bird_dst+b2d+1,x : lsr A : lda bird_dst+b2d,x : ror A : sbc local_b : bcs miss
	adc #20 : bcc miss
	lda ship_abtm+1 : ora #1 : sec : sbc bird_dst+b2d+1,x : and #63 : cmp #6 : bcs miss
	jmp collide_player
.miss
	lda eor_24_bytes_top+1+sm_im
	sec : sbc #9 : tay       \\ C=1>1
	lda local_w              : sta eor_24_bytes_top-&FD+0+sm_lo,y
	lda local_w+1            : sta eor_24_bytes_top-&FD+0+sm_hi,y
	lda bird_dst+b2d      ,x : sta eor_24_bytes_top-&FD+3+sm_lo,y
	                           sta eor_24_bytes_top-&FD+6+sm_lo,y
	lda bird_dst+b2d+1    ,x : sta eor_24_bytes_top-&FD+3+sm_hi,y
	                           sta eor_24_bytes_top-&FD+6+sm_hi,y
	sty eor_24_bytes_top+1+sm_im

	lda div_bytes_tall    ,x : lsr A \\ C=double-height ; %wwww111h (width-1) (height-1)
	bcc single_24_eor          \\ C=1

	lda eor_24_bytes_btm+1+sm_im
	sbc #9 : tay             \\ C=1>1
	lda local_w              : sta eor_24_bytes_btm-&FD+0+sm_lo,y
	lda local_w+1 : adc #1-1 : sta eor_24_bytes_btm-&FD+0+sm_hi,y  \\ C=1>0
	lda bird_dst+b2d      ,x : sta eor_24_bytes_btm-&FD+3+sm_lo,y
	                           sta eor_24_bytes_btm-&FD+6+sm_lo,y
	lda bird_dst+b2d+1    ,x : adc #2                                 \\ C=0>0
and #HI(scr_addr-1) : ora #HI(scr_addr) \\ TODO remove when diving don't go off top/bottom
	                           sta eor_24_bytes_btm-&FD+3+sm_hi,y
	                           sta eor_24_bytes_btm-&FD+6+sm_hi,y
	sty eor_24_bytes_btm+1+sm_im

.single_24_eor              \\ C=0

	jmp do_eor \\ allways
}

.not_bytes_23 : lsr A : bcc bytes_15

.bytes_31 ; C=1
{
	lda bird_dst+b2d+1,x : lsr A : lda bird_dst+b2d,x : ror A : sbc local_b : bcs miss
	adc #20 : bcc miss
	lda ship_abtm+1 : ora #1 : sec : sbc bird_dst+b2d+1,x : and #63 : cmp #6 : bcs miss
	jmp collide_player
.miss
	lda eor_32_bytes_top+1+sm_im
	SEC : sbc #9 : tay       \\ C=1
	lda local_w              : sta eor_32_bytes_top-&FD+0+sm_lo,y
	lda local_w+1            : sta eor_32_bytes_top-&FD+0+sm_hi,y
	lda bird_dst+b2d      ,x : sta eor_32_bytes_top-&FD+3+sm_lo,y
	                           sta eor_32_bytes_top-&FD+6+sm_lo,y
	lda bird_dst+b2d+1    ,x : sta eor_32_bytes_top-&FD+3+sm_hi,y
	                           sta eor_32_bytes_top-&FD+6+sm_hi,y
	sty eor_32_bytes_top+1+sm_im

	lda div_bytes_tall    ,x : lsr A ; %wwww111h (width-1) (height-1)
	bcc single_32_eor         \\ C=1

	lda eor_32_bytes_btm+1+sm_im
	sbc #9 : tay             \\ C=1>1
	lda local_w              : sta eor_32_bytes_btm-&FD+0+sm_lo,y
	lda local_w+1 : adc #1-1 : sta eor_32_bytes_btm-&FD+0+sm_hi,y  \\ C=1>0
	lda bird_dst+b2d      ,x : sta eor_32_bytes_btm-&FD+3+sm_lo,y
	                           sta eor_32_bytes_btm-&FD+6+sm_lo,y
	lda bird_dst+b2d+1    ,x : adc #2                                 \\ C=0>0
and #HI(scr_addr-1) : ora #HI(scr_addr) \\ TODO remove when diving don't go off top/bottom
	                           sta eor_32_bytes_btm-&FD+3+sm_hi,y
	                           sta eor_32_bytes_btm-&FD+6+sm_hi,y
	sty eor_32_bytes_btm+1+sm_im

.single_32_eor              \\ C=0

	bne do_eor \\ allways
}

.bytes_15 ; C=0
{
	lda bird_dst+b2d+1,x : lsr A : lda bird_dst+b2d,x : ror A : sbc local_b : bcs miss
	adc #20 : bcc miss
	lda ship_abtm+1 : ora #1 : sec : sbc bird_dst+b2d+1,x : and #63 : cmp #6 : bcc collide_player
.miss
	lda eor_16_bytes_top+1+sm_im
	sec : sbc #9 : tay       \\ C=0>1
	lda local_w              : sta eor_16_bytes_top-&FD+0+sm_lo,y
	lda local_w+1            : sta eor_16_bytes_top-&FD+0+sm_hi,y
	lda bird_dst+b2d      ,x : sta eor_16_bytes_top-&FD+3+sm_lo,y
	                           sta eor_16_bytes_top-&FD+6+sm_lo,y
	lda bird_dst+b2d+1    ,x : sta eor_16_bytes_top-&FD+3+sm_hi,y
	                           sta eor_16_bytes_top-&FD+6+sm_hi,y
	sty eor_16_bytes_top+1+sm_im

	lda div_bytes_tall    ,x : lsr A ; %wwww111h (width-1) (height-1)
	bcc single_16_eor         \\ C=1

	lda eor_16_bytes_btm+1+sm_im
	sbc #9 : tay             \\ C=1>1
	lda local_w              : sta eor_16_bytes_btm-&FD+0+sm_lo,y
	lda local_w+1 : adc #1-1 : sta eor_16_bytes_btm-&FD+0+sm_hi,y  \\ C=1>0
	lda bird_dst+b2d      ,x : sta eor_16_bytes_btm-&FD+3+sm_lo,y
	                           sta eor_16_bytes_btm-&FD+6+sm_lo,y
	lda bird_dst+b2d+1    ,x : adc #2                                 \\ C=0>0
and #HI(scr_addr-1) : ora #HI(scr_addr) \\ TODO remove when diving don't go off top/bottom
	                           sta eor_16_bytes_btm-&FD+3+sm_hi,y
	                           sta eor_16_bytes_btm-&FD+6+sm_hi,y
	sty eor_16_bytes_btm+1+sm_im

.single_16_eor              \\ C=0

\\	bne do_eor \\ allways
}

.do_eor
}
.diving_birds_eor_done
{
	inx : inx
	cpx #max_diving_birds*2
	{bcs done : jmp eor_next_bird : .done}
	RTS
}
.collide_player
{
	lda shield_timer : bne kill_bird
	ldy #&FF : jmp kill_player
;	RTS
.kill_bird
	jsr play_walk_explode : lda #2 : jsr add_score : txa : tay
.next
	dey : dey
	lda bird_dst+b2d   ,y : sta bird_dst+b2d   +2,y
	lda bird_dst+b2d+1 ,y : sta bird_dst+b2d+1 +2,y
	lda div_bytes_tall ,y : sta div_bytes_tall +2,y
	lda div_vsyncs_left,y : sta div_vsyncs_left+2,y
	lda div_vert_direct,y : sta div_vert_direct+2,y
	lda div_frame_end  ,y : sta div_frame_end  +2,y
	cpy diving_bird_first {beq done : bcs next : .done}
	inc diving_bird_first : inc diving_bird_first : bne diving_birds_eor_done \\ allways
}









.eor_diving_birds
{
	ldy #15 : bpl eor_16_bytes_top+1

	FOR d,0,max_diving_birds
	{
		lda birds,y : eor scr_addr,y : sta scr_addr,y
	}
	NEXT
}.eor_16_bytes_top{
	dey
	bpl eor_16_bytes_top

	ldy #15 : bpl eor_16_bytes_btm+1

	FOR d,0,max_diving_birds
	{
		lda birds,y : eor scr_addr,y : sta scr_addr,y
	}
	NEXT
}.eor_16_bytes_btm{
	dey
	bpl eor_16_bytes_btm

	ldy #23 : bpl eor_24_bytes_top+1

	FOR d,0,max_diving_birds
	{
		lda birds,y : eor scr_addr,y : sta scr_addr,y
	}
	NEXT
}.eor_24_bytes_top{
	dey
	bpl eor_24_bytes_top

	ldy #23 : bpl eor_24_bytes_btm+1

	FOR d,0,max_diving_birds
	{
		lda birds,y : eor scr_addr,y : sta scr_addr,y
	}
	NEXT
}.eor_24_bytes_btm{
	dey
	bpl eor_24_bytes_btm

	ldy #31 : bpl eor_32_bytes_top+1

	FOR d,0,max_diving_birds
	{
		lda birds,y : eor scr_addr,y : sta scr_addr,y
	}
	NEXT
}.eor_32_bytes_top{
	dey
	bpl eor_32_bytes_top

	ldy #31 : bpl eor_32_bytes_btm+1

	FOR d,0,max_diving_birds
	{
		lda birds,y : eor scr_addr,y : sta scr_addr,y
	}
	NEXT
}.eor_32_bytes_btm{
	dey
	bpl eor_32_bytes_btm
	RTS
}

.clear_diving_birds
{
	lda #0 : ldy #15 : bpl clear_16_bytes+1

	FOR d,0,max_diving_birds*2
		sta scr_addr,y
	NEXT
}.clear_16_bytes {
	dey
	bpl clear_16_bytes

	ldy #23 : bpl clear_24_bytes+1

	FOR d,0,max_diving_birds*2
		sta scr_addr,y
	NEXT
}.clear_24_bytes {
	dey
	bpl clear_24_bytes

	ldy #31 : bpl clear_32_bytes+1

	FOR d,0,max_diving_birds*2
		sta scr_addr,y
	NEXT
}.clear_32_bytes {
	dey
	bpl clear_32_bytes



	RTS
}


\\ BIRD SHOT

;.move_bird_shot_top_up_a_row
;{
;	ldx bird_shot_top_count : bmi done : sec
;.lp
;	lda bird_shot_top_addr+1,x : sbc #2 : sta bird_shot_top_addr+1,x
;	dex : dex : bpl lp
;.done
;	RTS
;}

.move_bird_shot_top_down_a_row
{
	ldx bird_shot_top_count : bmi done : clc
.lp
	lda bird_shot_top_addr+1,x : adc #2 : and #&7F : ora #&40 : sta bird_shot_top_addr+1,x
	dex : dex : bpl lp
.done
	RTS
}

;eor_top_bird_shot \\ ldx bird_shot_top_height : jsr eor_top_bird_shot
{
	FOR b,max_bird_shots-1,0,-1
		lda #0 : eor scr_addr,x : sta scr_addr,x
	NEXT
} .eor_top_bird_shot {
	dex : bpl eor_top_bird_shot
	ldx bird_shot_rest_height : bne eor_top_bird_shot_rest
	RTS

	FOR b,max_bird_shots-1,0,-1
		lda #0 : eor scr_addr,x : sta scr_addr,x
	NEXT
} .eor_top_bird_shot_rest {
	dex : bpl eor_top_bird_shot_rest
	RTS
}

.calc_bird_shot_eor_addrs
{
	eor_start_sm  = eor_top_bird_shot      - &FD - 8
	eor_finish_sm = eor_top_bird_shot_rest - &FD - 8

	lda #4 : sta bird_shot_top_height : lda #0 : sta bird_shot_rest_height
	lda old_bomb_y : and #7 : sta lo_or+sm_im
	lda #4 : sec : sbc lo_or+sm_im : bcs one_row
	and #3 : sta bird_shot_top_height : lda #5 : sbc bird_shot_top_height : sta bird_shot_rest_height : .one_row \\ C=0->1

	ldy #&FD \\ eor_top_bird_shot
	ldx bird_shot_top_count : bmi done : ldx #&FE
	clc
.lp
	inx : inx
	lda bird_shot_top_addr  ,x : sta eor_finish_sm+2+sm_lo,y : sta eor_finish_sm+5+sm_lo,y
	         .lo_or ora #pix_y : sta eor_start_sm +2+sm_lo,y : sta eor_start_sm +5+sm_lo,y
	lda bird_shot_top_addr+1,x : sta eor_start_sm +2+sm_hi,y : sta eor_start_sm +5+sm_hi,y
	adc #2 : and #&7F : ora #&40 : sta eor_finish_sm+2+sm_hi,y : sta eor_finish_sm+5+sm_hi,y \\ C=0->0
	lda bird_shot_top_byte  ,x : sta eor_start_sm +0+sm_im,y : sta eor_finish_sm+0+sm_im,y
	tya : sbc #7 : tay : cpx bird_shot_top_count : bcc lp                                  \\ C=0->0
.done
	sty eor_top_bird_shot+1+sm_im : sty eor_top_bird_shot_rest+1+sm_im
	RTS
}

.draw_stars \\ .25k+88 45-48.5s +2+2-1+6
{
;;;	jsr rand : jsr start_diving_bird

	jsr advance_birds
	ldx #0 : stx local_w : ldx #&40
.nxt
	lda stars-&40,x : beq skip \\ stars+&40 is reserved for enabling stars for offscreen birds
	stx local_w+1                                                                               \\ 3           *64  1.5s
	ldy stars+1+0*25,x : lda #1 : sta (local_w),y \\ 5+3+5+2+2+6 *64 11.5s
	ldy stars+1+1*25,x : lda #2 : sta (local_w),y \\ 4+3+5+2+2+6 *64 11  s
	ldy stars+1+2*25,x : lda #4 : sta (local_w),y \\ 4+3+5+2+2+6 *64 11  s
	ldy stars+1+3*25,x : lda #6 : sta (local_w),y \\ 5+3+5+2+2+6 *64 11.5s
	ldy stars+1+4*25,x : lda #8 : sta (local_w),y \\ 4+3+5+2+2+6 *64 11  s
;	ldy stars+&20   ,x : lda #3 : sta (local_w),y \\ 4+3+5+2+2+6 *64 11  s
;	ldy stars+&50   ,x : lda #7 : sta (local_w),y \\ 5+3+5+2+2+6 *64 11.5s
;	ldy stars+&70   ,x : lda #12: sta (local_w),y \\ 4+3+5+2+2+6 *64 11  s
	ldy stars+&80   ,x : lda #14: sta (local_w),y \\ 4+3+5+2+2+6 *64 11  s
\\	lda #0 : sta stars-&40,x
.skip
	inx : bpl nxt                                                                               \\ 2+3         *64  2.5s

	RTS                                                                                         \\ 48.5s +2+2-1+6
}

score_1_units = score_1_start + 8+5*8*2

.add_score \\ A=add/10 Y=0, A=LO(score_1_start)+8
{
	clc : sei : sed : adc score : sta score : lda score+1 : adc #0 : sta score+1 : lda score+2 : adc #0 : sta score+2 : cld : cli
	lda #LO(score_1_units) : sta digit_dst+sm_lo
	lda score : jsr write_digits : lda score+1 : jsr write_digits : lda score+2
.write_digits
	sta local_w+1 : and #&f0 : sta local_w : eor local_w+1 : jsr write_digit : lda local_w : lsr A : lsr A : lsr A : lsr A
.write_digit
	asl A : adc #1 : sta local_b : asl A : adc local_b : asl A : sta digit_src+sm_lo
	sec : jsr write_half_digit : lda digit_src+sm_lo : sbc #6 : sta digit_src+sm_lo
.write_half_digit
	ldy #6 : .digit_src : lda text,y : .digit_dst : sta score_1_units,y : dey : bne digit_src
	lda digit_dst+sm_lo : sbc #8 : sta digit_dst+sm_lo \\ C=0->1
	RTS
}

.start_main_game
;{
	lda #HI(btm_addr) : jsr cls+2 : jsr draw_label_SCORE1HI2
	ldy #6 { .lp : lda text,y : sta score_1_units+8,y : lda text+6,y : sta score_1_units+16,y : dey : bne lp} \\ add 0s to ends
	tya : jsr add_score : dec attract_mode
.start_new_game
	ldx #&FF : TXS
	lda #0 : sta score : sta score+1 : sta score+2 : sta total_levels : sta current_level : jsr add_score
	lda #2*2 : sta bird_shot_level_max
	lda #2 : sta lives_remaining : ldy #5 {.lp : lda text+18*6*2+1,y : sta ships_addr,y : sta ships_addr+16,y
	lda text+18*6*2+6+1,y : sta ships_addr+8,y : sta ships_addr+24,y : dey : bpl lp}

.start_next_level
{
	jsr setup_level
	ldx current_level : inx : cpx #10 : bne no_wrap : ldx #0 : .no_wrap : stx current_level : inc total_levels
	bne start_here

.play_level

	jsr frame_wait

	jsr clear_with_eors

;	{bit player_dead : bmi no_ship \\ dying
	jsr clear_shielded_ship ;: .no_ship}                         ;; draw players ship

	jsr advance_explosions

;	bit player_dead : bmi no_keys \\ dying
	jsr process_keys : .no_keys

;	lda keys_state : and #&10 : bne start_next_level

	jsr process_player_hit_enemy                     ;; checks if bullet over col2/3, if so, calls hit_swing/hit_stars/hit_boss
	jsr move_bullets                                 ;; move players bullet(s) and then fall through to eor player bullets (0, 1 or 2)

.start_here

	jsr draw_feature \\ moves birds if stars or boss ;; stars, ship etc
	lda #0 : ldy #&3F : .dark : sta stars,y : dey : bpl dark \\ A=0 X=X Y=&FF

	ldy bird_bytes : jsr draw_birds                  ;; draws walkers and diving, sets dirty flags

	jsr setup_eor_diving_birds

;	bit player_dead : bmi just_killed \\ dying
	jsr draw_shielded_ship : .no_ship                         ;; draw players ship

	jsr draw_with_eors

;;	bit lives_left : beq game_over
	\\ check level complete : beq level_complete

	lda player_dead : bmi just_killed
	jsr test_bombs_against_player_ship \\: bcs game_over

	lda bird_count : bpl play_level
	lda diving_bird_first : eor #max_diving_birds*2 : bne play_level

	ldy #max_explosions-1 : {.lp : lda explosions_hi,y : bpl play_level : dey : bpl lp}
	ldy #max_explosions-1 : {.lp : lda big_exp_lhs_hi,y : ora big_exp_rhs_hi,y : bne play_level : dey : bpl lp}
	jmp start_next_level

.just_killed \\ A=&FF

;	ldx #max_explosions-1
;.check_explosions
;	lda explosions_hi,x
;	bpl play_level
;	lda big_exp_lhs_hi,x
;	ora big_exp_rhs_hi,x
;	bne play_level
;	dex
;	bpl check_explosions

	\\ level complete

;;;	jsr eor_bullets

;	ldy #&FF : sty bullet_addr+1 : sty bullet_addr2+1 : iny : sty bullet_byte : sty bullet_byte2
.keep_dying
	jsr draw_with_eors
	jsr frame_wait
	jsr clear_with_eors
	jsr advance_explosions
	dec player_dead : bmi keep_dying
	ldy #max_explosions-1 : {.lp : lda explosions_hi,y : bpl keep_dying : dey : bpl lp}
	ldy #max_explosions-1 : {.lp : lda big_exp_lhs_hi,y : ora big_exp_rhs_hi,y : bne keep_dying : dey : bpl lp}

{.cls
	jsr frame_wait
	lda row_y : asl A : tax : stx local_w+1 : inx : stx bullet_addr+1 : lda #0 : sta local_w : sta bullet_addr : tay
	.cl : sta (local_w),y : sta (bullet_addr),y : iny : bne cl : inx : txa : lsr A : sta row_y : inx : bpl cls}

;	lda player_dead : beq not_dead
	lda attract_mode : bne draw_phoenix
	dec lives_remaining : bmi game_over
	lda lives_remaining : asl A : asl A : asl A : asl A : tay : lda #0 : ldx #13 { .lp : sta ships_addr,y : iny : dex : bpl lp}
	dec current_level : dec total_levels : lda #0 : sta player_dead
.not_dead
	jmp start_next_level

.game_over
	jsr snd_reset
	dec attract_mode
	lda hi_score : cmp score : lda hi_score+1 : sbc score+1 : lda hi_score+2 : sbc score+2 : bcs draw_phoenix
	ldx #2 {.lp lda score,x : sta hi_score,x : dex : bpl lp}
	ldy #7*16-1 {.lp : lda score_1_start,y : sta hiscore_start,y : dey : bpl lp}
;	jmp start_new_game
;.no_new_hi_score
;;.start_attract_mode
;	jmp start_new_game
}
.draw_phoenix
{
	bytes     = local_b
	index     = local_w
	row_hi    = local_w+1
	src_addr  = bullet_addr
	dst_addr  = bullet_addr2
	advance   = bullet_byte
	bits      = cooldown_timer
	bits_left = lives_remaining
	copy_size = feature_bits

	jsr cls
	lda star_pals_0+1 : sta star_pal : lda star_pals_1+1 : sta star_pal+1 : lda star_pals_4+1 : sta star_pal+2 : lda star_pals_5+1 : sta star_pal+3
	ldy #&40 { .init_stars : jsr rand : lda last_rand : sta stars,y : iny : bne init_stars}
	ldy #&2d { tya : .init_stars : sta stars,y : dey : bpl init_stars} : jsr draw_stars
	lda #HI(scr_addr/2)+4 : sta row_hi : ldx #0 : stx index
.next_index
	lda phoenix_data,x : and #3 : sta bytes : eor phoenix_data,x { bne same : inc row_hi : lda #24 : .same}
	asl A : sta dst_addr : lda row_hi : rol A : sta dst_addr+1 \\ C=0
	inx : lda phoenix_data,x : and #31 : tay : eor phoenix_data,x : lsr A : lsr A : sta advance
	lda diving_data,y : and #&30 : lsr A : ora #7 : sta copy_size
	lda diving_spr,y : and #&F8 : sta src_addr : eor diving_spr,y : adc #HI(sprites) : sta src_addr+1 \\ C=0
.next_byte
	inx : lda phoenix_data,x : sta bits : lda #8 : sta bits_left
.next_bit
	asl bits : bcc gap
	ldy copy_size { .lp : lda (src_addr),y : sta (dst_addr),y : dey : bpl lp}
	ldy #3 {.lp : jsr frame_wait : dey : bne lp}
.gap
	lda advance : clc : adc dst_addr : sta dst_addr {bcc pg : inc dst_addr+1 : .pg}
;	jsr frame_wait
	dec bits_left : bne next_bit
	dec bytes : bne next_byte
	inx : cpx #phoenix_data_end-phoenix_data : bne next_index
.flap_birds
	ldy #223 {.lp : lda birds+&300,y : sta scr_addr+&3090,y : lda birds+&400,y : sta scr_addr+&3290,y : dey : bne lp}
	ldy #100 {.lp : jsr frame_wait : dey : bne lp}
	jmp start_next_level
}
.phoenix_data \\ x &F8 | masks &3, adv &E0 | sprite &1F
{
	EQUB 0 OR 1, 16*8 OR frame_walk_max, %11100000, 24+48 OR 1, 12*8 OR frame_walk_min, %10000000
	EQUB 0 OR 1, 16*8 OR frame_walk_max, %10010000
	EQUB 0 OR 1, 16*8 OR frame_walk_max, %11100000, 24+48 OR 1, 12*8 OR frame_walk_min, %10000000
	EQUB 0 OR 1, 16*8 OR frame_walk_max, %10000000
	EQUB 0 OR 1, 16*8 OR frame_walk_max, %10000010,       24+24 OR 3, 8*8 OR frame_straight_up, %10101110, %10000001, %01010010, 24+120 OR 1, 12*8 OR frame_walk_med   , %10000000
	EQUB 0 OR 1, 16*8 OR frame_walk_max, %10000000,       24+24 OR 3, 8*8 OR frame_straight_up, %10101010, %10001001, %01000000, 24+128 OR 2,  4*8 OR frame_rot_left_up, %10000000, %00000100, 24+196 OR 1, 8*8 OR frame_rot_right_up, %10000000
	EQUB 0 OR 3,  8*8 OR frame_walk_max, %10000000, 0, 1, 24+24 OR 3, 8*8 OR frame_straight_up, %11101010, %10001001, %01000000, 24+ 96 OR 1, 12*8 OR frame_walk_med   , %10000000,            24+132 OR 1, 16*8 OR frame_rot_left_up, %10000000
	EQUB 0 OR 1, 16*8 OR frame_walk_max, %10000000,       24+24 OR 3, 8*8 OR frame_straight_up, %10101010, %10001001, %01000000, 24+136 OR 2,  4*8 OR frame_rot_left_up, %10000000, 1,         24+180 OR 1, 8*8 OR frame_rot_right_up, %10000000
	EQUB 0 OR 1, 16*8 OR frame_walk_max, %10000010,       24+24 OR 3, 8*8 OR frame_straight_up, %10101110, %10001000, %01010010, 24+140 OR 1, 12*8 OR frame_walk_med   , %10000000
}
.phoenix_data_end
PRINT "Phoenix", phoenix_data_end-draw_phoenix

;	SPR 19,0   ;  0 frame_walk_min        
;	SPR 14,5   ;  1 frame_straight_up     
;	SPR 16,5   ;  2 frame_straight_down   
;	SPR  0,5   ;  3 frame_straight_left   
;	SPR  8,5   ;  4 frame_straight_right  
;	SPR  3,5   ;  5 frame_rot_left_up     
;	SPR  5,5   ;  6 frame_rot_right_up    
;	SPR 30,3   ;  7 frame_spark_up        
;	SPR 28,3   ;  8 frame_spark_down      
;	SPR  0,5   ;  9 frame_spark_left      
;	SPR  7,6   ; 10 frame_fly_bck_up_left 
;	SPR 22,6   ; 11 frame_fly_bck_up_right
;	SPR  7,5   ; 12 frame_spark_right     
;	SPR 10,5   ; 13 frame_rot_left_down   
;	SPR 12,5   ; 14 frame_rot_right_down  
;	SPR 10,6   ; 15 frame_right_up        
;	SPR 13,6   ; 16 frame_left_down       
;	SPR 16,6   ; 17 frame_right_down      
;	SPR 19,6   ; 18 frame_left_up         
;	SPR  0,6   ; 19 frame_fly_fwd_up_left 
;	SPR  4,6   ; 20 frame_fly_mid_up_left 
;	SPR 28,6   ; 21 frame_fly_fwd_up_right
;	SPR 25,6   ; 22 frame_fly_mid_up_right
;	SPR 15,0   ; 23 frame_walk_med        
;	SPR 10,0   ; 24 frame_walk_max        


.clear_with_eors
{
	ldx bird_shot_top_height : jsr eor_top_bird_shot ;; eor bullets
	jsr eor_bullets                                  ;; eor player bullets (0, 1 or 2)
	jsr eor_explosions                               ;; clears stationary and spreading explosions

	jsr check_for_player_hit_enemy                   ;; only targets on screen here!

	jsr eor_diving_birds
	RTS
}

.draw_with_eors
{
	jsr eor_bullets
	ldx bird_shot_top_height : jsr eor_top_bird_shot ;; eor bombs
	inc eor_drawing : jsr eor_explosions : dec eor_drawing ;; draw_explosions ;; expanding explosions and stationary ones
	jsr eor_diving_birds
	RTS
}

.test_bombs_against_player_ship
{
	ldx bird_shot_top_count : bmi not_dead
	lda ship_addr+1 : lsr A : lda ship_addr : ror A : and #&FC : sta ship_left+sm_im \\ screen char (offset within this is frame)
.loop
	ldy #HI(ship) : lda bird_shot_top_row,x : eor #1 : beq ship_btm_row : eor #1 EOR 2 : beq ship_top_row
.next
	dex : dex : bpl loop
.not_dead
	RTS

.ship_btm_row : ldy #HI(ship+&100)
.ship_top_row
	lda bird_shot_top_addr+1,x : lsr A : lda bird_shot_top_addr,x : ror A
	sec : .ship_left : sbc #0 : bcc next : cmp #&20 DIV 2 : bcs next
	asl A : and #&38 : ora bird_shot_pix_y : adc ship_src : sta local_w : sty local_w+1
	lda #0 : ldy #3 : .lp : ora (local_w),y : dey : bpl lp
	and bird_shot_top_byte,x : beq next

	lda shield_timer : beq kill_player
;	ldy bird_shot_top_count ; use ,Y to clear last bomb
;	lda bird_shot_top_addr  ,x : sta bird_shot_clear+sm_lo : sta bird_shot_clear+sm_lo+3
;	lda bird_shot_top_addr+1,x : sta bird_shot_clear+sm_hi : clc : adc #2 : and #&3F : ora #&40 : sta bird_shot_clear+sm_hi+3
;	lda #0 : ldy #7 : .bird_shot_clear : sta scr_addr,y : sta scr_addr,y : dey : bpl bird_shot_clear
	txa : tay
.kill_bird_shot
	lda bird_shot_top_byte+2,y : sta bird_shot_top_byte  ,y
	lda bird_shot_top_row +2,y : sta bird_shot_top_row   ,y
	lda bird_shot_top_addr+2,y : sta bird_shot_top_addr  ,y
	lda bird_shot_top_addr+3,y : sta bird_shot_top_addr+1,y
	iny : iny : cpy bird_shot_top_count : bcc kill_bird_shot
	dec bird_shot_top_count : dec bird_shot_top_count : bcs next

;	sty player_dead
;	ldx #ship_abtm-bullet_addr : jsr start_explosion
;	ldx #ship_addr-bullet_addr : jsr start_big_explosion
;.player_explode
;	jsr frame_wait
;	lda player_dead : bne player_explode
;	ldx #&FF : txs : jmp start_next_level
}
.kill_player
{
	sty player_dead
	sty bird_count
	sty bullet_addr+1 : sty bullet_addr2+1 : iny : sty bullet_byte : sty bullet_byte2
	ldx #max_diving_birds*2 : stx diving_bird_first
	ldx #ship_abtm-bullet_addr : jsr start_explosion_silent
	ldx #ship_addr-bullet_addr : jsr start_big_explosion_silent
	lda bullet_addr+1+ship_abtm-bullet_addr : sec : sbc #4 : sta bullet_addr+1+ship_abtm-bullet_addr
	lda bullet_addr+1+ship_addr-bullet_addr : sec : sbc #4 : sta bullet_addr+1+ship_addr-bullet_addr
	ldx #ship_abtm-bullet_addr : jsr start_explosion_silent
	ldx #ship_addr-bullet_addr : jsr start_big_explosion_silent
	lda bullet_addr+1+ship_abtm-bullet_addr : clc : adc #4 : sta bullet_addr+1+ship_abtm-bullet_addr
	lda bullet_addr+1+ship_addr-bullet_addr : clc : adc #4 : sta bullet_addr+1+ship_addr-bullet_addr
	RTS
}

.DIVING_ANIMS

; anim frames ;

frame_walk_min         =  0
frame_straight_up      =  1
frame_straight_down    =  2
frame_straight_left    =  3
frame_straight_right   =  4
frame_rot_left_up      =  5
frame_rot_right_up     =  6
frame_spark_up         =  7
frame_spark_down       =  8  ; no anims end from here down
frame_spark_left       =  9
frame_fly_bck_up_left  = 10
frame_fly_bck_up_right = 11
frame_spark_right      = 12
frame_rot_left_down    = 13
frame_rot_right_down   = 14
frame_right_up         = 15
frame_left_down        = 16
frame_right_down       = 17
frame_left_up          = 18
frame_fly_fwd_up_left  = 19
frame_fly_mid_up_left  = 20
frame_fly_fwd_up_right = 21
frame_fly_mid_up_right = 22
frame_walk_med         = 23
frame_walk_max         = 24

; anim frame address in birds ;

.diving_spr ; indexed by anim frame ;
{
	MACRO SPR x,y
		EQUB x*8+y
	ENDMACRO

	SPR 19,0   ;  0 frame_walk_min        
	SPR 14,5   ;  1 frame_straight_up     
	SPR 16,5   ;  2 frame_straight_down   
	SPR  0,5   ;  3 frame_straight_left   
	SPR  8,5   ;  4 frame_straight_right  
	SPR  3,5   ;  5 frame_rot_left_up     
	SPR  5,5   ;  6 frame_rot_right_up    
	SPR 30,3   ;  7 frame_spark_up        
	SPR 28,3   ;  8 frame_spark_down      
	SPR  0,5   ;  9 frame_spark_left      
	SPR  7,6   ; 10 frame_fly_bck_up_left 
	SPR 22,6   ; 11 frame_fly_bck_up_right
	SPR  7,5   ; 12 frame_spark_right     
	SPR 10,5   ; 13 frame_rot_left_down   
	SPR 12,5   ; 14 frame_rot_right_down  
	SPR 10,6   ; 15 frame_right_up        
	SPR 13,6   ; 16 frame_left_down       
	SPR 16,6   ; 17 frame_right_down      
	SPR 19,6   ; 18 frame_left_up         
	SPR  0,6   ; 19 frame_fly_fwd_up_left 
	SPR  4,6   ; 20 frame_fly_mid_up_left 
	SPR 28,6   ; 21 frame_fly_fwd_up_right
	SPR 25,6   ; 22 frame_fly_mid_up_right
	SPR 15,0   ; 23 frame_walk_med        
	SPR 10,0   ; 24 frame_walk_max        
}

; anim frame size and number of frames to display ;

.diving_data ; indexed by anim frame ;
{
	MACRO SIZ width, height, vsyncs ; b76 --w:2 b3 --v:2 --h:1 \\ 3 spare BITS
		EQUB (width-1) * 16 + (vsyncs-1) * 2 + (height-1)
	ENDMACRO

	SIZ 3 ,1, 2   ;  0 frame_walk_min        
	SIZ 2 ,1, 2   ;  1 frame_straight_up     
	SIZ 2 ,1, 2   ;  2 frame_straight_down   
	SIZ 2 ,1, 2   ;  3 frame_straight_left   
	SIZ 2 ,1, 2   ;  4 frame_straight_right  
	SIZ 2 ,1, 2   ;  5 frame_rot_left_up     
	SIZ 2 ,1, 2   ;  6 frame_rot_right_up    
	SIZ 2 ,2, 2   ;  7 frame_spark_up        
	SIZ 2 ,2, 2   ;  8 frame_spark_down      
	SIZ 3 ,1, 2   ;  9 frame_spark_left      
	SIZ 3 ,2, 4   ; 10 frame_fly_bck_up_left 
	SIZ 3 ,2, 4   ; 11 frame_fly_bck_up_right
	SIZ 3 ,1, 2   ; 12 frame_spark_right     
	SIZ 2 ,1, 2   ; 13 frame_rot_left_down   
	SIZ 2 ,1, 2   ; 14 frame_rot_right_down  
	SIZ 3 ,2, 2   ; 15 frame_right_up        
	SIZ 3 ,2, 2   ; 16 frame_left_down       
	SIZ 3 ,2, 2   ; 17 frame_right_down      
	SIZ 3 ,2, 2   ; 18 frame_left_up         
	SIZ 4 ,2, 4   ; 19 frame_fly_fwd_up_left 
	SIZ 3 ,2, 4   ; 20 frame_fly_mid_up_left 
	SIZ 4 ,2, 4   ; 21 frame_fly_fwd_up_right
	SIZ 3 ,2, 4   ; 22 frame_fly_mid_up_right
	SIZ 3 ,1, 2   ; 23 frame_walk_med        
	SIZ 4 ,1, 2   ; 24 frame_walk_max        
}

; which block of anims can come after an anim ending with this frame ;

.choose_anim ; [frame_xxx DIVING ANIMS] ; anim_choices + offset to first choice : 5, choice count : 3
{
	MACRO CHOICE start, count
		EQUB start * 8 + count
	ENDMACRO

	CHOICE (from_walk_min         - anim_choices), (from_straight_up      - from_walk_min        ) ; from frame_walk_min (start diving)
	CHOICE (from_straight_up      - anim_choices), (from_straight_down    - from_straight_up     ) ; from frame_straight_up     
	CHOICE (from_straight_down    - anim_choices), (from_straight_right   - from_straight_down   ) ; from frame_straight_down   
	CHOICE (from_straight_right   - anim_choices), (from_straight_left    - from_straight_right  ) ; from frame_straight_left   
	CHOICE (from_straight_left    - anim_choices), (from_fly_rot_left_up  - from_straight_left   ) ; from frame_straight_right  
	CHOICE (from_fly_rot_left_up  - anim_choices), (anim_choices_end      - from_fly_rot_left_up ) ; from frame_rot_left_up 
	CHOICE (from_fly_rot_right_up - anim_choices), (anim_choices_end      - from_fly_rot_right_up) ; from frame_rot_right_up
	CHOICE (from_spark_up         - anim_choices), (anim_choices_end      - from_spark_up        ) ; from frame_spark_up        
}

; details of choices indexed from choose_anim ;

.anim_choices ; []=[] anim_constraints + offset below indexed by choose_anim \\ SPART BIT

.from_walk_min
	EQUB (anim_fast_dive           - diving_anims)
.from_straight_up
	EQUB (anim_roll_left_to_dive   - diving_anims)
	EQUB (anim_roll_right_to_dive  - diving_anims)
	EQUB (anim_up_to_left          - diving_anims)
	EQUB (anim_up_to_right         - diving_anims)
	EQUB (anim_walk_to_left		   - diving_anims)
	EQUB (anim_walk_to_right	   - diving_anims)
.from_straight_down
	EQUB (anim_zig_zag_down_left   - diving_anims)
	EQUB (anim_zig_zag_down_right  - diving_anims)
	EQUB (anim_down_to_right_roll  - diving_anims)
	EQUB (anim_down_to_left_roll   - diving_anims)
	EQUB (anim_down_to_up          - diving_anims)
.from_straight_right
	EQUB (anim_right_roll          - diving_anims)
	EQUB (anim_right_to_spark_up   - diving_anims)
	EQUB (anim_right_to_dive       - diving_anims)
.from_straight_left
	EQUB (anim_left_roll           - diving_anims)
	EQUB (anim_left_to_spark_up    - diving_anims)
	EQUB (anim_left_to_dive        - diving_anims)
.from_fly_rot_left_up
.from_fly_rot_right_up
	EQUB (anim_flap_up_left_to_up  - diving_anims)
	EQUB (anim_flap_up_right_to_up - diving_anims)
.from_spark_up
	EQUB (anim_flap_up_left        - diving_anims)
	EQUB (anim_flap_up_right       - diving_anims)
.anim_choices_end
	EQUB (diving_anims_end - diving_anims) \\ end frame (1 off end)

space_above = 1
space_below = 2
space_right = 4
space_left  = 8

diving_up    = 1
diving_down  = 0
diving_level = 0

; constraints for anim choice based on position on screen ;

.anim_constraints \\ allow left/right if moving to straight up/down ; probably [same as anim_choices]
{
MACRO DDATA spaces, mv_up \\ could change space to major space, minor space
	EQUB mv_up * &80 + spaces
ENDMACRO
	
;.from_walk_min                                       ; .. from_straight_down (first diving anim from walk)
	DDATA  space_below                , diving_down   ; 8d   anim_fast_dive         
;.from_straight_up                                    ; .. from_straight_down
	DDATA (space_below OR space_left ), diving_down   ; 5ld  anim_roll_left_to_dive 
	DDATA (space_below OR space_right), diving_down   ; 5rd  anim_roll_right_to_dive
	DDATA (space_above OR space_left ), diving_up     ; 2l2u anim_up_to_left        
	DDATA (space_above OR space_right), diving_up     ; 2r2u anim_up_to_right       
	DDATA  space_left                 , diving_level  ; 2l   anim_walk_to_left		
	DDATA  space_right                , diving_level  ; 2r   anim_walk_to_right	   
;.from_straight_down                                  ; .. from_straight_right   \\ add non-down option
	DDATA (space_below OR space_left ), diving_down   ; 4l2d anim_zig_zag_down_left 
	DDATA (space_below OR space_right), diving_down   ; 4r2d anim_zig_zag_down_right
	DDATA (space_below OR space_right), diving_down   ; rd   anim_down_to_right_roll
	DDATA (space_below OR space_left ), diving_down   ; ld   anim_down_to_left_roll 
	DDATA 0                           , diving_down   ; 2d   anim_down_to_up
;.from_straight_right                                 ; .. from_straight_left    \\ add non-right option
	DDATA  space_right                , diving_level  ; 8r   anim_right_roll      
	DDATA  space_above                , diving_up     ; 3r2u anim_right_to_spark_up   
	DDATA (space_right OR space_below), diving_down   ; end of roll right to dive
;.from_straight_left                                  ; .. from_fly_bck_up_left  \\ add non-left option
	DDATA  space_left                 , diving_level  ; 8l   anim_left_roll         
	DDATA  space_above                , diving_up     ; 3l2u anim_left_to_spark_up    
	DDATA (space_left OR space_below ), diving_down   ; end of roll left to dive
;.from_fly_rot_left_up                                ; ...                      \\ add non-up option to from_spark_up (included in this)
;.from_fly_rot_right_up                               ; ...                      \\ add non-up option to from_spark_up (included in this)
	DDATA 0                           , diving_up     ; u    anim_flap_up_left_to_up
	DDATA 0                           , diving_up     ; u    anim_flap_up_right_to_up
;.from_spark_up                                       ; ...                      \\ add non-up option
	DDATA  space_above                , diving_up     ; 4l2u anim_flap_up_left      
	DDATA  space_above                , diving_up     ; 4r2u anim_flap_up_right     
}

diving_R_ = 0
diving__u = 1 : diving__d = 1
diving_r_ = 2
diving_ru = 3 : diving_rd = 3
diving___ = 4
diving_lu = 5 : diving_ld = 5
diving_l_ = 6
diving_Lu = 7 ; spare but mv_Ld \\ b7 0:r, 1:l b5 0:- 1:^v

.diving_move_x : EQUB 16,0,8,8,0,&F8,&F8,&F0
\\ up down on all odd indices, use diving_data to choose

; the frames and movements that make up a frame ;

.diving_anims

MACRO FRAME spr, dir
	EQUB dir * 32 + spr \\ 8 combos, so 2 8 byte lookups
ENDMACRO
	
.anim_fast_dive                ; from straight_down - TODO maybe shorten / change to down spark down
	FRAME frame_spark_down      , diving___
	FRAME frame_rot_left_down   , diving__d
	FRAME frame_straight_left   , diving__d
	FRAME frame_rot_left_up     , diving__d
	FRAME frame_straight_up     , diving__d
	FRAME frame_rot_right_up    , diving__d
	FRAME frame_straight_right  , diving__d
	FRAME frame_rot_right_down  , diving__d
	FRAME frame_straight_down   , diving__d

.anim_roll_left_to_dive        ; from straight_up
	FRAME frame_rot_left_up     , diving_l_
	FRAME frame_straight_left   , diving_l_
	FRAME frame_spark_left      , diving_l_
	FRAME frame_straight_left   , diving_l_
	FRAME frame_left_down       , diving_l_
	FRAME frame_straight_down   , diving__d

.anim_roll_right_to_dive       ; from straight_up
	FRAME frame_rot_right_up    , diving_r_
	FRAME frame_straight_right  , diving_r_
	FRAME frame_spark_right     , diving___
	FRAME frame_straight_right  , diving_R_
	FRAME frame_right_down      , diving___
	FRAME frame_straight_down   , diving_rd

.anim_up_to_left               ; from straight_up
	FRAME frame_spark_up        , diving__u
	FRAME frame_straight_up     , diving___
	FRAME frame_left_up         , diving_lu
	FRAME frame_straight_left   , diving_l_

.anim_up_to_right              ; from straight_up
	FRAME frame_spark_up        , diving__u
	FRAME frame_straight_up     , diving___
	FRAME frame_right_up        , diving__u
	FRAME frame_straight_right  , diving_R_

.anim_walk_to_left             ; from straight_up ; 4 vsyncs
;	FRAME frame_walk_min        , diving___
	FRAME frame_walk_med        , diving_l_
	FRAME frame_walk_max        , diving_l_
	FRAME frame_walk_med        , diving___
;	FRAME frame_walk_min        , diving___
	FRAME frame_straight_up     , diving___

.anim_walk_to_right            ; from straight_up ; 4 vsyncs
;	FRAME frame_walk_min        , diving___
	FRAME frame_walk_med        , diving___
	FRAME frame_walk_max        , diving___
	FRAME frame_walk_med        , diving_r_
;	FRAME frame_walk_min        , diving_r_
	FRAME frame_straight_up     , diving_r_

.anim_zig_zag_down_left        ; from straight_down
	FRAME frame_spark_down      , diving_l_
	FRAME frame_straight_down   , diving_ld
	FRAME frame_spark_down      , diving_l_
	FRAME frame_straight_down   , diving_ld

.anim_zig_zag_down_right       ; from straight_down
	FRAME frame_spark_down      , diving_r_
	FRAME frame_straight_down   , diving_rd
	FRAME frame_spark_down      , diving_r_
	FRAME frame_straight_down   , diving_rd

.anim_down_to_right_roll       ; from straight_down
	FRAME frame_right_down      , diving___
	FRAME frame_straight_right  , diving_rd

.anim_down_to_left_roll        ; from straight_down
	FRAME frame_left_down       , diving_l_
	FRAME frame_straight_left   , diving__d

.anim_down_to_up               ; from straight_down
	FRAME frame_left_down       , diving___
	FRAME frame_straight_left   , diving__d
	FRAME frame_left_up         , diving___
	FRAME frame_straight_up     , diving__d

.anim_right_roll               ; from straight_right
	FRAME frame_rot_right_down  , diving_r_
	FRAME frame_straight_down   , diving_r_
	FRAME frame_rot_left_down   , diving_r_
	FRAME frame_straight_left   , diving_r_
	FRAME frame_rot_left_up     , diving_r_
	FRAME frame_straight_up     , diving_r_
	FRAME frame_rot_right_up    , diving_r_
	FRAME frame_straight_right  , diving_r_

.anim_right_to_spark_up        ; from straight_right
	FRAME frame_spark_right     , diving___
	FRAME frame_straight_right  , diving_R_
	FRAME frame_right_up        , diving__u
	FRAME frame_straight_up     , diving_r_
	FRAME frame_spark_up        , diving__u

.anim_right_to_dive            ; from straight right
	FRAME frame_right_down      , diving___
	FRAME frame_straight_down   , diving_rd

.anim_left_roll                ; from straight_left
	FRAME frame_rot_left_down   , diving_l_
	FRAME frame_straight_down   , diving_l_
	FRAME frame_rot_right_down  , diving_l_
	FRAME frame_straight_right  , diving_l_
	FRAME frame_rot_right_up    , diving_l_
	FRAME frame_straight_up     , diving_l_
	FRAME frame_rot_left_up     , diving_l_
	FRAME frame_straight_left   , diving_l_

.anim_left_to_spark_up         ; from straight_left
	FRAME frame_spark_left      , diving_l_
	FRAME frame_straight_left   , diving_l_
	FRAME frame_left_up         , diving_lu
	FRAME frame_straight_up     , diving___
	FRAME frame_spark_up        , diving__u

.anim_left_to_dive             ; from straight_left
	FRAME frame_left_down       , diving_l_
	FRAME frame_straight_down   , diving__d

.anim_flap_up_left_to_up       ; from rot_left_up or rot_right_up
	FRAME frame_straight_up     , diving___
	FRAME frame_spark_up        , diving__u
	FRAME frame_straight_up     , diving___

.anim_flap_up_right_to_up      ; from rot_left_up or rot_right_up
	FRAME frame_straight_up     , diving___
	FRAME frame_spark_up        , diving__u
	FRAME frame_straight_up     , diving___

	\\ TODO, rework these to end in rot_XXX
.anim_flap_up_left             ; from spark_up \\ or fly_bck_up_left or fly_bck_up_right \\ TODO sort as l/r don't align
	FRAME frame_rot_left_up     , diving___
	FRAME frame_fly_fwd_up_left , diving_Lu
	FRAME frame_fly_mid_up_left , diving___
	FRAME frame_fly_bck_up_left , diving_lu
	FRAME frame_rot_left_up     , diving_l_

.anim_flap_up_right            ; from spark_up \\ or fly_bck_up_left or fly_bck_up_right \\ TODO sort as l/r don't align
	FRAME frame_rot_right_up    , diving___
	FRAME frame_fly_fwd_up_right, diving__u
	FRAME frame_fly_mid_up_right, diving_r_
	FRAME frame_fly_bck_up_right, diving_ru
	FRAME frame_rot_right_up    , diving_R_

.diving_anims_end

.div_bytes_tall   SKIP 1 \\ max_diving_birds ; %wwww111h (width-1) (height-1)
.div_vsyncs_left  SKIP max_diving_birds*2-1 ; how many vsyncs before next frame ; %000000vv (vsyncs-1)
.div_vert_direct  SKIP 1 \\ max_diving_birds ; wether vertical movement is up or down
.div_frame_end    SKIP max_diving_birds*2-1 ; one frame off end of frames

.DIVING_ANIMS_END

;; SOUND ;;

.snd_reset
{
;;	lda #&FF : sta SysViaDDRA \\ when sound selected, write val as per SN76489 data byte format
	ldx #4 : .set_no_vol : lda init_volume,x : jsr snd_write_A : dex : bpl set_no_vol
\\	ldx #3 : .set_no_vol : lda default_volume,x : jsr snd_write_A : dex : bpl set_no_vol
	RTS
}

LAT_HI = %00000000
FRQ_LO = %10000000
VOLUME = %10011111

CHAN_0 = %00000000 \\ wlk-exp sway-exp shield
CHAN_1 = %00100000 \\ diving
CHAN_2 = %01000000 \\ siren alarm
CHAN_3 = %01100000 \\ shot die

.snd_update
{
;;	lda #&FF : sta SysViaDDRA \\ when sound selected, write val as per SN76489 data byte format

;	lda shot_vol : bmi no_shot : dec shot_vol
;	eor #(VOLUME OR CHAN_3) : jsr snd_write_A
;	dec shot_tk2_dec : bne no_shot
;	lda #(CHAN_2 OR FRQ_LO) : jsr snd_write_A
;	dec shot_freq : lda shot_freq : sta shot_tk2_dec : jsr snd_write_A \\ LAT_HI
;.no_shot

	lda shot_tim : bmi no_shot : lda #15 : dec shot_tim : bmi at_full
	eor shot_vol : beq at_full : inc shot_vol : .at_full : ora #(CHAN_3 OR VOLUME EOR 15) : jsr snd_write_A
.no_shot

	lda wound_tim : bmi no_wound : beq wound_done
	ora #(CHAN_1 OR FRQ_LO OR (30 MOD 16)) : jsr snd_write_A : lda #(LAT_HI OR (30 DIV 16)) : jsr snd_write_A
	lda wound_tim : cmp #8 : bcc wound_done : lda #15 : .wound_done : eor #(CHAN_1 OR VOLUME) : jsr snd_write_A
	dec wound_tim
.no_wound

	lda player_dead : bpl not_dead : lsr A : lsr A : lsr A : and #&0F : beq dead_enough : dec player_dead
	.dead_enough : eor #(CHAN_3 OR VOLUME) : jsr snd_write_A
.not_dead

	ldy wlk_exp_idx : bmi no_wlk_exp : lda #(VOLUME OR CHAN_0) : dey : sty wlk_exp_idx : bmi stop_wlk_exp
	lda wlk_exp_frq,y : and #%1111 : ora #(FRQ_LO OR CHAN_0) : jsr snd_write_A
	lda wlk_exp_frq,y : jsr snd_write_A_16th
	tya : ora #%1100 : eor #(VOLUME OR CHAN_0)
.stop_wlk_exp
	jsr snd_write_A
.no_wlk_exp

;	lda wlk_exp_vol : bmi no_wlk_exp : eor #8 : sta wlk_exp_vol : dec wlk_exp_vol : eor #(VOLUME OR CHAN_0) : jsr snd_write_A
;	and #8 : bne no_wlk_exp
;	lda #(CHAN_0 OR FRQ_LO) : jsr snd_write_A
;;	lda wlk_exp_frq : eor #(16 EOR 7) : sta wlk_exp_frq : jsr snd_write_A
;	lda wlk_exp_frq : eor #(32 EOR 14) : sta wlk_exp_frq : jsr snd_write_A
;.no_wlk_exp

;	lda swy_exp_vol : bmi no_swy_exp : dec swy_exp_vol : eor #(VOLUME OR CHAN_0) : jsr snd_write_A
;	and #3 : tax : lda #(CHAN_0 OR FRQ_LO) : jsr snd_write_A
;	lda swy_exp_frq,x : jsr snd_write_A
;.no_swy_exp

	lda swy_exp_vol : bmi no_swy_exp : and #3 : tax : lda #(VOLUME OR CHAN_0 EOR 15)
	dec swy_exp_vol : bpl cont_swy_exp : lda #(VOLUME OR CHAN_0) : .cont_swy_exp : jsr snd_write_A
	lda #(CHAN_0 OR FRQ_LO) : jsr snd_write_A : lda swy_exp_frq,x : jsr snd_write_A
.no_swy_exp

	lda shield_timer : beq no_shield
	lda shield_timer : lsr A { beq ok : lda #15-2 : .ok : eor #(VOLUME OR CHAN_0) : jsr snd_write_A }
	lda #(CHAN_0 OR FRQ_LO OR &0F) : jsr snd_write_A
	lda shield_timer : and #3*2 : eor #3*2 : sec : rol A : asl A : jsr snd_write_A
.no_shield

	lda siren_frq : beq no_siren
	and #%1111 : ora #(CHAN_2 OR FRQ_LO) : jsr snd_write_A
	lda siren_frq : jsr snd_write_A_16th
	dec siren_frq : bmi no_siren
	jsr rand : ora #&80 : sta siren_frq
.no_siren

	lda diving_tim : beq no_diving
	lda #(VOLUME OR CHAN_1) : dec diving_tim : beq stop_diving
	lda diving_tim : and #3 : bne no_diving : lda diving_tim : and #4 : beq div_rand
	lda diving_frq : eor #8 : bpl nee_nar
.div_rand
	jsr rand : and #%00001111 : ora #%01100000
.nee_nar
	sta diving_frq : and #%1111 : ora #(FRQ_LO OR CHAN_1) : jsr snd_write_A
	lda diving_frq : lsr A : lsr A : lsr A : lsr A
.stop_diving
	jsr snd_write_A
.no_diving

	lda alarm_num : beq no_alarm
	lda alarm_tim : inc alarm_tim : bit alarm_tim : bpl cont_alarm
	lda #39 : sta alarm_tim : dec alarm_num : bne cont_wibble
	lda #(CHAN_2 OR VOLUME) : bne stop \\ allways
.cont_alarm
	bvs climb
.cont_wibble
	and #3 : tax : lda alarm_frq,x
.climb
	pha : and #%1111 : ora #(CHAN_2 OR FRQ_LO) : jsr snd_write_A
	pla : lsr A : lsr A : lsr A : lsr A
.stop
	jsr snd_write_A
.no_alarm

;	RTS
;}
;.update_tune
;{
	ldy tune_index   : beq done_plus_1-1
	dec tune_timer   : beq tune_next_note
	bit tune_sustain : bmi done_plus_1-1
	lda tune_timer   : lsr A : ora tune_timer : lsr A : bcs done_plus_1-1
	lda tune_vol     : beq done_plus_1-1
	sbc #0
	\\ jsr tune_set_volumes
}
.tune_set_volumes
{
	sta tune_vol                                                                      : eor #(CHAN_2 OR VOLUME) : jsr snd_write_A
;	                                                     lda tune_vol : lsr A         : eor #(CHAN_1 OR VOLUME) : jsr snd_write_A               \\ TODO check for fly sfx
;	lda wlk_exp_vol : ora swy_exp_vol : bmi not_tune_0 : lda tune_vol : lsr A : lsr A : eor #(CHAN_0 OR VOLUME) : jsr snd_write_A : .not_tune_0
	RTS
}
.done_plus_1

.start_tune \\ Y=fur_elise-tunes_data or spanish_romance-tunes_data
{
	lda tunes_data,y : sta tune_cadence
\\	RTS
}
.tune_next_note \\ Y=note \\ CHAN 0:explode 1:fly-up 2: 3:shoot \\ TUNE 2:primary 1:secondary 0:terciary
{
	lda tune_cadence : sta tune_timer
	iny : sty tune_index
	lda tunes_data,y : beq stop          \\ dsvviiii divisor-b8 sustain volume00 divisor-index
	sta tune_sustain : and #%1111 : tax
	lda notes_2,x : asl A : and #%1111 : ora #(CHAN_2 OR FRQ_LO) : jsr snd_write_A               \\ CHAN_2  lo
    lda notes_2,x : asl tune_sustain : ror A : lsr A : lsr A     : jsr snd_write_A               \\ latched hi
	\\ TODO check for fly sfx											                 
;	lda notes_1,x : asl A : and #%1111 : ora #(CHAN_1 OR FRQ_LO) : jsr snd_write_A               \\ CHAN_1  lo  \\ TODO check for fly sfx
;	lda notes_1,x : lsr A : lsr A : lsr A                        : jsr snd_write_A : .not_tune_1 \\ latched hi
;	lda wlk_exp_vol : ora swy_exp_vol : bmi not_tune_0 
;	lda notes_0,x : and #%1111 : ora #(CHAN_0 OR FRQ_LO) : jsr snd_write_A               \\ CHAN_0  lo
;	lda notes_0,x : lsr A : lsr A : lsr A : lsr A        : jsr snd_write_A : .not_tune_0 \\ latched hi
	lda tunes_data,y : lsr A : lsr A : and #%1100 : bpl tune_set_volumes \\ always
	RTS
.stop
	sta tune_index
	beq tune_set_volumes \\ allways
}

.swy_exp_frq
;	EQUB 8, 28, 40, 62
;	EQUB 8*2, 28*2, 40*2, 62*2
	EQUB 8/2, 28/2, 40/2, 62/2

.alarm_frq
	EQUB 21, 28, 42, 28

.wlk_exp_frq
;	EQUB &B0, &90, &7C, &94, &90, &73, &64, &75, &6E 
	EQUB &6E, &75, &64, &73, &90, &94, &7C, &90, &B0
.wlk_exp_frq_end

;.wlk_exp_frq
;	EQUB 14.75, 18, 21, 17.5, 18, 22.5, 26, 22.25, 23.5

.notes_2	: EQUB 80, 84, 89, 95, 100, 106, 119, 127, 134, 142, 150, 159, 190, 239, 253, (284 MOD 256)
;.notes_1	: EQUB 53, 56, 59, 63,  67,  71,  79,  85,  89,  95, 100, 106, 127, 159, 169, 189
;.notes_0	: EQUB 35, 37, 39, 42,  45,  47,  53,  57,  59,  63,  67,  71,  85, 106, 113, 126

.tunes_data

MACRO NOTE b8, vol, decay, index
	EQUB b8 * 128 + ((decay EOR 1) * 64 + vol * 4 + index)
ENDMACRO

.fur_elise
{
	\\ b8, vol, decay, Index

	EQUB 16 \\ frames per note

	NOTE 0, 12, 1,  3
	NOTE 0,  8, 1,  4
	NOTE 0,  8, 1,  3
	NOTE 0,  8, 1,  4
	NOTE 0,  8, 1,  3
	NOTE 0,  8, 1,  7
	NOTE 0,  8, 1,  5
	NOTE 0,  8, 1,  6
	NOTE 0,  8, 1,  9
	NOTE 0,  4, 0,  9
	NOTE 1,  8, 1, 15
	NOTE 0,  8, 1, 13
	NOTE 0,  8, 1, 12
	NOTE 0,  8, 1,  9
	NOTE 0,  8, 1,  7
	NOTE 0,  4, 0,  7
	NOTE 0,  8, 1, 14
	NOTE 0,  8, 1, 12
	NOTE 0,  8, 1, 10
	NOTE 0,  8, 1,  7
	NOTE 0,  8, 1,  6
	NOTE 0,  4, 0,  6
	NOTE 0,  8, 1, 12
	NOTE 0,  4, 1, 12
	NOTE 0,  8, 1,  3
	NOTE 0,  8, 1,  4
	NOTE 0,  8, 1,  3
	NOTE 0,  8, 1,  4
	NOTE 0,  8, 1,  3
	NOTE 0,  8, 1,  7
	NOTE 0,  8, 1,  5
	NOTE 0,  8, 1,  6
	NOTE 0,  8, 1,  9
	NOTE 0,  4, 0,  9
	NOTE 1,  8, 1, 15
	NOTE 0,  8, 1, 13
	NOTE 0,  8, 1, 12
	NOTE 0,  8, 1,  9
	NOTE 0,  8, 1,  7
	NOTE 0,  4, 0,  7
	NOTE 0,  8, 1, 14
	NOTE 0,  8, 1,  7
	NOTE 0,  8, 1,  6
	NOTE 0,  8, 1,  7
	NOTE 0,  8, 1,  9
	NOTE 0,  4, 0,  9
	NOTE 0,  8, 1, 12
	NOTE 0,  8, 1,  7
	NOTE 0,  8, 1,  6
	NOTE 0, 12, 1,  5
	NOTE 0, 12, 1,  3
	NOTE 0,  8, 0,  3
	NOTE 0,  8, 1,  3
	NOTE 0, 12, 1,  3
	NOTE 0, 12, 1,  2
	NOTE 0, 12, 1,  3
	NOTE 0, 12, 1,  5
	NOTE 0,  8, 0,  5
	NOTE 0,  8, 1,  5
	NOTE 0, 12, 1,  5
	NOTE 0, 12, 1,  3
	NOTE 0, 12, 1,  5
	NOTE 0, 12, 1,  6
	NOTE 0,  8, 0,  6
	NOTE 0,  8, 1,  6
	NOTE 0, 12, 1,  6
	NOTE 0, 12, 1,  5
	NOTE 0, 12, 1,  6
	NOTE 0, 12, 1,  7
	NOTE 0,  8, 0,  7
	NOTE 0,  8, 1,  7
	NOTE 0,  4, 1,  7

	EQUB 0
}
.fur_elise_end \\, length,, divider,, volume

.spanish_romance
{
	\\ b8, vol, decay, Index

	EQUB 20 \\ frames per note

	NOTE 0, 12, 1,  5
	NOTE 0, 12, 1,  5
	NOTE 0, 12, 1,  5
	NOTE 0, 12, 1,  5
	NOTE 0, 12, 1,  6
	NOTE 0, 12, 1,  8
	NOTE 0, 12, 1,  8
	NOTE 0, 12, 1,  9
	NOTE 0, 12, 1, 11
	NOTE 0, 12, 1, 11
	NOTE 0, 12, 1,  8
	NOTE 0, 12, 1,  5
	NOTE 0, 12, 1,  0
	NOTE 0, 12, 1,  0
	NOTE 0, 12, 1,  0
	NOTE 0, 12, 1,  0
	NOTE 0, 12, 1,  2
	NOTE 0, 12, 1,  4
	NOTE 0, 12, 1,  4
	NOTE 0, 12, 1,  5
	NOTE 0, 12, 1,  6
	NOTE 0, 12, 1,  6
	NOTE 0, 12, 1,  5
	NOTE 0, 12, 1,  4
	NOTE 0, 12, 1,  5
	NOTE 0, 12, 1,  4
	NOTE 0, 12, 1,  5
	NOTE 0, 12, 1,  1
	NOTE 0, 12, 1,  4
	NOTE 0, 12, 1,  5
	NOTE 0, 12, 1,  5
	NOTE 0, 12, 1,  6
	NOTE 0, 12, 1,  8
	NOTE 0, 12, 1,  8
	NOTE 0, 12, 1,  9
	NOTE 0, 12, 1, 11
	NOTE 0, 12, 1,  9
	NOTE 0, 12, 1,  9
	NOTE 0, 12, 1,  9
	NOTE 0, 12, 1,  9
	NOTE 0, 12, 1,  6
	NOTE 0, 12, 1,  8
	NOTE 0, 12, 1, 11
	NOTE 0, 12, 1,  8
	NOTE 0, 12, 1,  5
	NOTE 0,  8, 1, 11

	EQUB 0
}
.spanish_romance_end \\ length, divider, volume

.play_walk_explode
{
	lda #wlk_exp_frq_end - wlk_exp_frq : sta wlk_exp_idx
	RTS
}

.play_sway_explode
{
	lda #4*6-1 : sta swy_exp_vol
	RTS
}

.play_siren
{
	jsr rand : ora #&80 : sta siren_frq
	lda #(CHAN_2 OR VOLUME EOR 10) : jsr snd_write_A
	RTS
}

.play_shot
{
	lda #10 : sta shot_vol : sta shot_tim
	RTS
}

.play_wound
{
	lda #15 : sta wound_tim
	RTS
}

.play_alarm
{
	lda #(CHAN_2 OR VOLUME EOR 10) : jsr snd_write_A
	lda #39 : sta alarm_tim : lda #6 : sta alarm_num
	RTS
}

.play_diving
{
	lda #(CHAN_1 OR VOLUME EOR 10) : jsr snd_write_A
	lda #16 : sta diving_tim
	RTS
}

.snd_write_A_16th
{
	lsr A : lsr A : lsr A : lsr A
}
.snd_write_A \\ A is written to sound slow data bus : C=C Z=0 N=0 A=8 X=X Y=Y
{
	SEI
	sta SysViaRegA            \\ sample says SysViaRegH but OS uses no handshake \\ handshake regA
	lda #0+0 : sta SysViaRegB \\ enable sound for 8us
	PHA : PLA : PHA : PLA     \\ 3+4+3+4 + 2(lda #) = 16 clocks = 8us
	lda #0+8 : sta SysViaRegB \\ disable sound
	CLI
	RTS
}

.end_of_code

CLEAR btm_addr,&7C00
ORG end_of_code
GUARD &7C00

.MAIN
{
	jsr stop_events

	ldx #end_of_ZP-1 : lda #0 : .zero_ZP : sta 0,x : dex : bne zero_ZP
	ldx #max_explosions-1 : lda #&80 : .bullet_off : sta explosions_hi,x : dex : bpl bullet_off

	ldx #crtc_end-crtc_setup-1 : {.set_crtc : lda crtc_setup,X : stx CrtcReg : sta CrtcVal : dex : bpl set_crtc}
	ldx #4+0 : stx SysViaRegB \\ these two set the 
	ldx #5+0 : stx SysViaRegB \\ screen size to 16K
	lda #VideoUlaMode_1NoCrsrFlash0 : sta VideoULAVideoControlRegister        \\ no crsr, M1, non-flash

	lda #Pal4Col0 OR PaletteBlack : jsr set_palette_colour
	lda #Pal4Col1 OR PaletteBlack : ldx #3 : .lp : sta star_pal,x : dex : bpl lp : sta ship_pal : jsr set_palette_colour
	lda #Pal4Col2 OR PaletteBlack : sta PaletteCol2 : jsr set_palette_colour
	lda #Pal4Col3 OR PaletteBlack : sta PaletteCol3 : jsr set_palette_colour

	jsr read_4_keys \\ leaves DDRA ready for sound
	jsr snd_reset

    SEI
    
    LDA #64 : sta SysViaACR                 ; Set T1 free-run mode
	lda #&FF : STA SysViaT1CL ; STA SysViaT1CH ; Write high and latch low - 3+ frames should be enough to get to a vsync to reset it before it fires

	lda #0 : sta frame_done : sta frame_next : sta score : sta score+1 : sta score+2 : sta hi_score : sta hi_score+1 : sta hi_score+2

	lda #&80 OR SysIntVSync OR SysIntT1 : sta SysViaIER \\ enable

    CLI

	jsr relocate_sprites \\ black red green yellow blue purple cyan white

	ldy #0
.gen_masks
	tya : sta local_b : lsr A : lsr A : lsr A : lsr A : ora local_b : sta local_b
	asl A : asl A : asl A : asl A : ora local_b : eor #&FF : sta masks,y : iny : bne gen_masks

	jmp start_main_game
}

\\.crtc_setup : EQUB 127, 64, 90, &28, 38, 0, 32, vsync_row, &C0, 7, &67, 8, HI(scr_addr), LO(scr_addr) : .crtc_end
.crtc_setup : EQUB 127, 64, 90, &28, 38, 0, 32, 35, CrtcR8_M06_Game, 7, &20, 8, HI(scr_addr/8), LO(scr_addr/8) : .crtc_end

;; OS1.2 MO.1 r10=&67 r9=7 r8=1 r7=&23 r6=&20 r5=0 r4=&26 r3=&28 r2=&62 r1=&50 r0=&7f
;;            &FE21=&a0 &b0 &e0 &f0 &84... &26... &07...
;;            r12=6 r13=0 cls 

rti_opcode = &40

.stop_events
{
	IRQV1 = &204 \\ the primary interrupt vector

	SEI
		lda #rti_opcode : sta &D00 \\ copy RTI to &D00 to stop NMIs doing anything
		lda #&7F : sta SysViaIER : sta SysViaIFR \\ disable and clear all interrupts
		           sta UsrViaIER : sta UsrViaIFR \\ disable and clear all interrupts
		lda #4   : sta SysViaPCR  \\ vsync \\ CA1 negative-active-edge CA2 input-positive-active-edge CB1 negative-active-edge CB2 input-nagative-active-edge
		lda #0   : sta SysViaACR  \\ none  \\ PA latch-disable PB latch-disable SRC disabled T2 timed-interrupt T1 interrupt-t1-loaded PB7 disabled
		lda #15  : sta SysViaDDRB \\ enable write to addressable latch (b0-2 addr, b3 data) and read joystick buttons (b5,b6) and speech (b6 ready, b7 interrupt)
		lda #0+8 : sta SysViaRegB \\ write "disable" sound
		lda #3+8 : sta SysViaRegB \\ write "disable" keyboard
		lda #<irq_handler : sta IRQV1
		lda #>irq_handler : sta IRQV1+1
	CLI
	RTS
}

align 256 : .ld_start
align 256 : .ld_birds     : INCLUDE "sprites\birds.equb"     \\ 8 pages
align 256 : .ld_boss      : INCLUDE "sprites\boss.equb"      \\ 2 pages
align 256 : .ld_rti       : EQUB rti_opcode : .ld_text : INCLUDE "sprites\text.equb" \\ 0=' ', others offset by 1 (!end_of_text - JSR)
align 256 : .ld_ship      : INCLUDE "sprites\ship.equb"      \\ 2 pages
align 256 : .ld_explosion : INCLUDE "sprites\explosion.equb" \\ 2 pages
align 256 : .ld_shielded  : INCLUDE "sprites\shield_small.equb" \\ 1 pages
align 256                 : INCLUDE "sprites\shield_large.equb" \\ 1 pages
align 256 : .ld_end
align 256 : .ld_stars     : SKIP 256

;; SOUND ;;

	; SN76489 data byte format
	; %1110-wnn latched noise (channel 3) w=white noise (otherwise periodic), nn: 0=hi, 1=med, 2=lo, 3=freq from channel %10
	; %1cc0pppp latched channel (%00-%10) period (low bits)
	; %1cc1aaaa latched channel (0-3) atenuation (%0000=loudest..%1111=silent)
	; if latched 1110---- %0----nnn noise (channel 3)
	; else                %0-pppppp period (high bits)
	; See SMS Power! for details http://www.smspower.org/Development/SN76489?sid=ae16503f2fb18070f3f40f2af56807f1

.relocate_sprites
{
	ldx #0
.lp
	FOR p,0,ld_end-ld_start-1,256
		lda ld_start+p,x : sta sprites+p,x
	NEXT
	inx : bne lp
	RTS
}

PRINT "end_of_ZP",~end_of_ZP
PRINT "birds    ",~birds       , "+",~(boss            -birds       )
;PRINT "boss     ",~boss        , "+",~(text            -boss   -1   )
;PRINT "text     ",~text        , "+",~(ship            -text        )
;PRINT "ship     ",~ship        , "+",~(explosion       -ship        )
;PRINT "explosion",~explosion   , "+",~(stars           -explosion   )
;PRINT "stars    ",~stars       , "+",~(sprites_end     -text        )
;PRINT "DIVING   ",~DIVING_ANIMS, "+",~(DIVING_ANIMS_END-DIVING_ANIMS), " (diving)",~diving_anims, "+",~(diving_anims_end-diving_anims), " (choices)",~anim_choices, "+",~(anim_choices_end-anim_choices)
;PRINT "draw_diving_birds",~draw_diving_birds

.END

PRINT "GAME",~BEGIN, "..", ~MAIN, "..", ~END, "+",~(END-BEGIN), "=",btm_addr-end_of_code
SAVE "GAME", BEGIN, END, MAIN

; Shield
;
;	wait 200@60 (166@50) after off b4 reuse
;	shield lasts 1 second (50@50)
;	fire after 48/60 (40@50)
;	
;	shield
;	8f large
;	4f small
;	4f off
;	
;	ship
;	8f green
;	8f red


;	ldx top,y        ;4 top bits
;	lda top1,x       ;4 page of count of bits in top1
;	sta btm_pg+sm_hi ;4 
;	                 ; maybe same for top2..top6
;	ldx btm,y        ;4 btm bits
;.btm_pg
;	lda btm1,x       ;4 page of count of bits in btm1 + top1 (btm1)
;	sta mid_pg+sm_hi ;4
;	ldx mid,y        ;4 mid bits
;.mid_pg
;	lda mid1,x       ;4 
;	sta bit1         ;3 to be ored later
;	; ...
;	ora bit1         ;3
;
;;	38 x 128x128    8 pages
;
;	clc              ;2
;	ldx top,y        ;4 top bits
;	lda top1,x       ;4 page of count of bits in top1
;	ldx btm,y        ;4 btm bits
;	adc btm1,x       ;4 page of count of bits in btm1 + top1 (btm1)
;	sta mid_pg+sm_hi ;4
;	ldx mid,y        ;4 mid bits
;.mid_pg
;	lda mid1,x       ;4 
;	sta bit1         ;3 to be ored later
;	; ...
;	ora bit1         ;3
;
;;	36 x 128x128    7 pages




; LDA #143:LDX #12:LDY #255:JSR OSBYTE :\ Claim NMIs
; LDA #140:JSR OSBYTE :\ Select TAPE
; LDA #3:STA &258:STA &287 :\ *FX200,3 - clear memory on Break, *FX247,3 - disable BIV
; LDA #&40:STA &D00 :\ NMI=null
; SEI :\ Disable IRQs
; \
; \ The following is really belt-and-braces stuff, SEI should be sufficient
; LDA &FFB7:STA &FD:LDA &FFB8:STA &FE :\ (&FD)=>default vector table
; LDY #6:LDA (&FD),Y:STA &204 :\ Set IRQ1V to default IRQ2V -> LDA &FC,RTI
; INY:LDA (&FD),Y:STA &205



