	;TODO: SBC09 - machine type?
	;TODO: CHIPKIT - machine type?
mos_MACHINE_TYPE_BYTE			EQU $63

* Address of MOS ROM base
MOSROMBASE				EQU $C000
MOSSTRINGS				EQU $F500

* default direct page for MOS ROM
MOSROMSYS_DP				EQU $0

* OSENTRIESLOC - this is the area that contains the OS call JSRs
* to mimic the published BBC MOS API
OSENTRIESLOC				EQU $FFB6

JGH_OSENTRIESLOC			EQU OSENTRIESLOC-3*10

DOM_DEBUG_ENTRIES			EQU JGH_OSENTRIESLOC-3*4

* BOUNCELOC - an area of "bounces" where the indirected jumps and
* jsrs are stored - these need an extra instruction byte to 6502
* so must indirect through here
BOUNCELOC				EQU JGH_OSENTRIESLOC-4*11



FSCV_CODE_OSCLI_UK			EQU $03


zp_lang					EQU $0000
zp_eco					EQU $0090
zp_nmi					EQU $00A0
L00A9					EQU $00A9
zp_fs_s					EQU $00B0
zp_fs_w					EQU $00C0
zp_vdu_status				EQU $00D0	; VDU Status as read by OSBYTE &75
zp_vdu_grpixmask			EQU $00D1	; Graphics pixel mask
zp_vdu_txtcolourOR			EQU $00D2	; Text colour OR mask
zp_vdu_txtcolourEOR			EQU $00D3	; Text colour EOR mask
zp_vdu_gracolourOR			EQU $00D4	; Graphics colour OR mask
zp_vdu_gracolourEOR			EQU $00D5	; Graphics colour EOR mask
zp_vdu_gra_char_cell			EQU $00D6	; Graphics character cell
zp_vdu_top_scanline			EQU $00D8	; Top scan line
zp_vdu_wksp				EQU $00DA	; Temporary workspace
;;;;removed !zp_rom_mul			EQU $00E0	; BBC, Electron: Row multiplication
zp_cfs_w				EQU $00E2
zp_opt_val				EQU $00E3	; DB? check
zp_mos_GSREAD_quoteflag			EQU $00E4	; GSREAD quote flag
zp_mos_GSREAD_characc			EQU $00E5	; GSREAD character accumulator
zp_mos_OS_wksp				EQU $00E6	; General OS workspace
zp_mos_autorep_countdown		EQU $00E7	; Auto repeat countdown timer
zp_mos_input_buf			EQU $00E8	; Input buffer pointer for OSWORD 0
zp_mos_rs423timeout			EQU $00EA	; RS423 timeout counter, unused if no RS423
zp_mos_cfs_critical			EQU $00EB	; CFS/RFS 'critical' flag
zp_mos_keynumlast			EQU $00EC	; Internal key number (last)
zp_mos_keynumfirst			EQU $00ED	; Internal key number (first)
zp_mos_jimdevsave			EQU $00EE	; Internal key number of character to be ignored by OSBYTE &79, also the 1MHz bus paging register
zp_mos_OSBW_A				EQU $00EF	; OSBYTE/OSWORD A reg value
	***** NOTE: zp_mos_OSBW_Y&X swapped for endiannedss
zp_mos_OSWORD_X				EQU $00F0
zp_mos_OSBW_Y				EQU $00F0	; OSBYTE/OSWORD Y reg value
zp_mos_OSBW_X				EQU $00F1	; OSBYTE/OSWORD X reg value

zp_mos_txtptr				EQU $00F2	; OS Text pointer (eg star commands and filenames)
zp_mos_curROM				EQU $00F4	; Currently selected ROM
zp_mos_curPHROM				EQU $00F5	; Current PHROM or RFS ROM number or OSRDSC/OSWRSC number
zp_mos_genPTR				EQU $00F6	; PHROM/RFSROM/OSRDSC/OSWRSC pointer
zp_mos_X				EQU $00F8	; BBC, Electron: Unused, Master: Soft key expansion pointer
zp_mos_OS_wksp2				EQU $00FA	; General OS workspace, used by buffer access code in interrupts
zp_mos_INT_A				EQU $00FC	; Interrupt Temp A reg store
zp_mos_error_ptr			EQU $00FD	; Error message pointer, initially set to language version string
zp_mos_ESC_flag				EQU $00FF	; Escape flag (bit 7)

stack					EQU $0100
STACKTOP				EQU $0200

sysvar_OSVARADDR			EQU $0236	; fx166/7 &A6/7 Address of OS variables
sysvar_ROMPTRTAB			EQU $0238	; fx168/9 &A8/9 Address of ROM pointer table
sysvar_ROMINFOTAB			EQU $023A	; fx170/1 &AA/B Address of ROM info table
sysvar_KEYB_ADDRTRANS			EQU $023C	; fx172/3 &AC/D Address of key translation table
sysvar_ADDRVDUVARS			EQU $023E	; fx174/5 &AE/F Address of VDU variables
sysvar_CFSTOCTR				EQU $0240	; fx176	  &B0	CFS timeout counter, decremented every frame flyback
sysvar_CURINSTREAM			EQU $0241	; fx177	  &B1	Currently selected input stream set with FX2
sysvar_KEYB_SEMAPHORE			EQU $0242	; fx178	  &B2	BBC, Master: Keyboard semaphore
sysvar_PRI_OSHWM			EQU $0243	; fx179	  &B3	Primary OSHWM
sysvar_CUR_OSHWM			EQU $0244	; fx180	  &B4	Current OSHWM
sysvar_RS423_MODE			EQU $0245	; fx181	  &B5	RS423 mode
sysvar_EXPLODESTATUS			EQU $0246	; fx182	  &B6	BBC, Electron: Character definition explosion status
sysvar_CFSRFS_SWITCH			EQU $0247	; fx183	  &B7	CFS/RFS switch
sysvar_VIDPROC_CTL_COPY			EQU $0248	; fx184	  &B8	BBC, Master: RAM copy of VIDPROC control register
sysvar_VIDPROC_PAL_COPY			EQU $0249	; fx185	  &B9	BBC, Master: RAM copy of VIDPROC palette register
sysvar_ROMNO_ATBREAK			EQU $024A	; fx186	  &BA	ROM active last BRK
sysvar_ROMNO_BASIC			EQU $024B	; fx187	  &BB	BASIC ROM number
sysvar_ADC_CUR				EQU $024C	; fx188	  &BC	Current ADC Channel
sysvar_ADC_MAX				EQU $024D	; fx189	  &BD	Maximum ADC Channel number
sysvar_ADC_ACCURACY			EQU $024E	; fx190	  &BE	ADC conversion type/accuracy
sysvar_RS423_USEFLAG			EQU $024F	; fx191	  &BF	RS423 use flag
sysvar_RS423_CTL_COPY			EQU $0250	; fx192	  &C0	RAM copy of RS423 control register
sysvar_FLASH_CTDOWN			EQU $0251	; fx193	  &C1	Flashing colour countdown timer
sysvar_FLASH_SPACE_PERIOD		EQU $0252	; fx194	  &C2	Flashing colour space period count set by FX9
sysvar_FLASH_MARK_PERIOD		EQU $0253	; fx195	  &C3	Flashing colour mark period count set by FX10
sysvar_KEYB_AUTOREP_DELAY		EQU $0254	; fx196	  &C4	Keyboard auto-repeat delay set by FX11
sysvar_KEYB_AUTOREP_PERIOD		EQU $0255	; fx197	  &C5	Keyboard auto-repeat period set by FX12
sysvar_EXEC_FILE			EQU $0256	; fx198	  &C6	*EXEC file
sysvar_SPOOL_FILE			EQU $0257	; fx199	  &C7	*SPOOL file handle
sysvar_BREAK_EFFECT			EQU $0258	; fx200	  &C8	ESCAPE, BREAK effect
sysvar_KEYB_DISABLE			EQU $0259	; fx201	  &C9	Keyboard disable
sysvar_KEYB_STATUS			EQU $025A	; fx202	  &CA	Keyboard status byte
							;Bit 7  =1 shift enabled   
							;Bit 6  =1 control pressed 
							;bit 5  =0 shift lock      
							;Bit 4  =0 Caps lock       
							;Bit 3  =1 shift pressed   

sysvar_RS423_BUF_EXT			EQU $025B	; fx203	  &CB	BBC, Master: Serial input buffer extent
sysvar_RS423_SUPPRESS			EQU $025C	; fx204	  &CC	BBC, Master: Serial input supression flag
sysvar_RS423CASS_SELECT			EQU $025D	; fx205	  &CD	BBC, Master: Serial/cassette selection flag
sysvar_ECO_OSBW_INTERCEPT		EQU $025E	; fx206	  &CE	Econet OSBYTE/OSWORD intercept flag
sysvar_ECO_OSRDCH_INTERCEPT		EQU $025F	; fx207	  &CF	Econet OSRDCH intercept flag
sysvar_ECO_OSWRCH_INTERCEPT		EQU $0260	; fx208	  &D0	Econet OSWRCH intercept flag
sysvar_SPEECH_SUPPRESS			EQU $0261	; fx209	  &D1	Speech suppression status
sysvar_SOUND_SUPPRESS			EQU $0262	; fx210	  &D2	Sound suppression status
sysvar_BELL_CH				EQU $0263	; fx211	  &D3	BELL channel number
sysvar_BELL_ENV				EQU $0264	; fx212	  &D4	BELL envelope number/amplitude
sysvar_BELL_FREQ			EQU $0265	; fx213	  &D5	BELL frequency
sysvar_BELL_DUR				EQU $0266	; fx214	  &D6	BELL duration
sysvar_STARTUP_DISPOPT			EQU $0267	; fx215	  &D7	Startup display and BOOT error options
sysvar_KEYB_SOFTKEY_LENGTH		EQU $0268	; fx216	  &D8	Soft key string length
sysvar_SCREENLINES_SINCE_PAGE		EQU $0269	; fx217	  &D9	Screen lines since last page
sysvar_VDU_Q_LEN			EQU $026A	; fx218	  &DA	256-number of items in VDU queue
sysvar_KEYB_TAB_CHAR			EQU $026B	; fx219	  &DB	BBC, Master: TAB key character
sysvar_KEYB_ESC_CHAR			EQU $026C	; fx220	  &DC	ESCAPE character
sysvar_KEYB_C0CF_INSERT_INT		EQU $026D	; fx221	  &DD	Char &C0-&CF buffer insert interpretation
sysvar_KEYB_D0DF_INSERT_INT		EQU $026E	; fx222	  &DE	Char &D0-&DF buffer insert interpretation
sysvar_KEYB_E0EF_INSERT_INT		EQU $026F	; fx223	  &DF	Char &E0-&EF buffer insert interpretation
sysvar_KEYB_F0FF_INSERT_INT		EQU $0270	; fx224	  &E0	Char &F0-&FF buffer insert interpretation
sysvar_KEYB_808F_INSERT_INT		EQU $0271	; fx225	  &E1	Char &80-&8F buffer insert interpretation (FKey)
sysvar_KEYB_909F_INSERT_INT		EQU $0272	; fx226	  &E2	Char &90-&9F buffer insert interpretation (Sh+FKey)
sysvar_KEYB_A0AF_INSERT_INT		EQU $0273	; fx227	  &E3	Char &A0-&AF buffer insert interpretation (Ct+FKey)
sysvar_KEYB_B0BF_INSERT_INT		EQU $0274	; fx228	  &E4	Char &B0-&BF buffer insert interpretation (Ct+Sh+FKey)
sysvar_KEYB_ESC_ACTION			EQU $0275	; fx229	  &E5	ESCAPE key action
sysvar_KEYB_ESC_EFFECT			EQU $0276	; fx230	  &E6	ESCAPE effects
sysvar_USERVIA_IRQ_MASK_CPY		EQU $0277	; fx231	  &E7	User 6522 VIA IRQ mask
sysvar_ACIA_IRQ_MASK_CPY		EQU $0278	; fx232	  &E8	6850 ACIA IRQ bit mask
sysvar_SYSVIA_IRQ_MASK_CPY		EQU $0279	; fx233	  &E9	System 6522 VIA IRQ mask
sysvar_TUBE_PRESENT			EQU $027A	; fx234	  &EA	Tube presence flag
sysvar_SPEECH_PRESENT			EQU $027B	; fx235	  &EB	Speech processor presence flag
sysvar_OUTSTREAM_DEST			EQU $027C	; fx236	  &EC	Output stream character destination, set with FX3
sysvar_KEY_CURSORSTAT			EQU $027D	; fx237	  &ED	Cursor key status, set with FX4
sysvar_FX238				EQU $027E	; fx238	  &EE	BBC, Electron: unused
sysvar_FX239				EQU $027F	; fx239	  &EF	unused
sysvar_COUNTRY				EQU $0280	; fx240	  &F0	Country code
sysvar_USERFLAG				EQU $0281	; fx241	  &F1	User flag location, set with FX1
sysvar_SERPROC_CTL_CPY			EQU $0282	; fx242	  &F2	BBC, Master: RAM copy of SERPROC control register
sysvar_TIMER_SWITCH			EQU $0283	; fx243	  &F3	Timer switch state
sysvar_KEYB_SOFT_CONSISTANCY		EQU $0284	; fx244	  &F4	Soft key consistancy flag
sysvar_PRINT_DEST			EQU $0285	; fx245	  &F5	Printer destination, set with FX5
sysvar_PRINT_IGNORE			EQU $0286	; fx246	  &F6	Printer ignore character, set with FX6
sysvar_BREAK_VECTOR_JMP			EQU $0287	; fx247	  &F7	Break Intercept Vector JMP
sysvar_BREAK_VECTOR_LOW			EQU $0288	; fx248	  &F8	Break Intercept Vector address low byte
sysvar_BREAK_VECTOR_HIGH		EQU $0289	; fx249	  &F9	Break Intercept Vector address high byte
sysvar_SHADOW1				EQU $028A	; fx250	  &FA	BBC, Electron: unused, unless shadow screen present
sysvar_SHADOW2				EQU $028B	; fx251	  &FB	BBC, Electron: unused, unless shadow screen present
sysvar_CUR_LANG				EQU $028C	; fx252	  &FC	Current language ROM
sysvar_BREAK_LAST_TYPE			EQU $028D	; fx253	  &FD	Last BREAK type
sysvar_RAM_AVAIL			EQU $028E	; fx254	  &FE	BBC: Available RAM
sysvar_STARTUP_OPT			EQU $028F	; fx255	  &FF	Startup options
oswksp_VDU_VERTADJ			EQU $0290	; VDU vertical adjust, *TV first parameter
oswksp_VDU_INTERLACE			EQU $0291	; Interlace toggle flag, *TV second parameter
oswksp_TIME				EQU $0292	; TIME value 1, high byte...low byte
oswksp_TIME2				EQU $0297	; TIME value 2, high byte...low byte
oswksp_OSWORD3_CTDOWN			EQU $029C	; OSWORD 3/4 Countdown interval timer value
oswksp_ROMTYPE_TAB			EQU $02A1	; Paged ROM type table
oswksp_INKEY_CTDOWN			EQU $02B1	; INKEY countdown timer
oswksp_OSWORD0_LINE_LEN			EQU $02B3	; OSWORD 0 maximum line length
oswksp_OSWORD0_MIN_CH			EQU $02B4	; OSWORD 0 minimum character
oswksp_OSWORD0_MAX_CH			EQU $02B5	; OSWORD 0 maximum character
adc_CH1_LOW				EQU $02B6	; Channel 1 ADC value low
adc_CH2_LOW				EQU $02B7	; Channel 2 ADC value low
adc_CH3_LOW				EQU $02B8	; Channel 3 ADC value low
adc_CH4_LOW				EQU $02B9	; Channel 4 ADC value low
adc_CH1_HI				EQU $02BA	; Channel 1 ADC value high
adc_CH2_HI				EQU $02BB	; Channel 2 ADC value high
adc_CH3_HI				EQU $02BC	; Channel 3 ADC value high
adc_CH4_HI				EQU $02BD	; Channel 4 ADC value high
adc_CH_LAST				EQU $02BE	; Last ADC channel converted
mosvar_EVENT_ENABLE			EQU $02BF	; MOS Event enable flags
mosvar_SOFTKEY_PTR			EQU $02C9	; Soft key expansion pointer
mosvar_KEYB_AUTOREPEAT_COUNT		EQU $02CA	; First auto repeat count
mosvar_KEYB_TWOKEY_ROLLOVER		EQU $02CB	; Two key rollover workspace
mosvar_SOUND_SEMAPHORE			EQU $02CE	; Sound semaphore
mosbuf_buf_busy				EQU $02CF	; Buffer busy flags	      
mosbuf_buf_start			EQU $02D8	; Buffer start indexes	      
mosbuf_buf_end				EQU $02E1	; Buffer end indexes	      
cfsrfs_BLK_SIZE				EQU $02EA	; Block size
cfsrfs_BLK_FLAG				EQU $02EC	; Block flag
cfsrfs_LAST_CHA				EQU $02ED	; Last input character
osfile_ctlblk				EQU $02EE	; OSFILE control blocks for *LOAD, *SAVE, *CREATE and *DELETE.
vduvars_start				EQU $0300
vduvar_GRA_WINDOW			EQU $0300				
vduvar_GRA_WINDOW_LEFT			EQU $0300	; Current graphics window left column in pixels
vduvar_GRA_WINDOW_BOTTOM		EQU $0302	; Current graphics window bottom row in pixels
vduvar_GRA_WINDOW_RIGHT			EQU $0304	; Current graphics window right column in pixels
vduvar_GRA_WINDOW_TOP			EQU $0306	; Current graphics window top row in pixels
vduvar_TXT_WINDOW_LEFT			EQU $0308	; Current text window left hand column
vduvar_TXT_WINDOW_BOTTOM		EQU $0309	; Current text window bottom row
vduvar_TXT_WINDOW_RIGHT			EQU $030A	; Current text window right hand column
vduvar_TXT_WINDOW_TOP			EQU $030B	; Current text window top column
vduvar_GRA_ORG_EXT			EQU $030C	; Current graphics origin in external coordinates
vduvar_GRA_CUR_EXT			EQU $0310	; Current graphics cursor in external coordinates
vduvar_GRA_CUR_INT_OLD			EQU $0314	; Old graphics cursor in external coordinates
vduvar_TXT_CUR_X			EQU $0318	; Current text cursor X
vduvar_TXT_CUR_Y			EQU $0319	; Current text cursor Y
vduvar_GRA_CUR_CELL_LINE		EQU $031A	; Line within current graphics cell of graphics cursor
vduvar_VDU_Q_START			EQU $031B
vduvar_VDU_Q_END			EQU $0324	; end of VDU Q (well 1 after!)
vduvar_GRA_CUR_INT			EQU $0324	; Current graphics cursor in internal coordinates
vduvar_TEMP_8				EQU $0328	; Bitmap read from screen by OSBYTE 135, various coordinate routines
vduvar_GRA_WKSP				EQU $0330	; Graphics workspace
vduvar_6845_CURSOR_ADDR			EQU $034A	; Text cursor address for 6845
vduvar_TXT_WINDOW_WIDTH_BYTES		EQU $034C	; Text window width in bytes
vduvar_SCREEN_BOTTOM_HIGH		EQU $034E	; High byte of bottom of screen memory
vduvar_BYTES_PER_CHAR			EQU $034F	; Bytes per character for current mode
vduvar_6845_SCREEN_START		EQU $0350	; Screen display start address for 6845
vduvar_BYTES_PER_ROW			EQU $0352	; Bytes per screen row
vduvar_SCREEN_SIZE_HIGH			EQU $0354	; Screen memory size high byte
vduvar_MODE				EQU $0355	; Current screen mode
vduvar_MODE_SIZE			EQU $0356	; Memory map type: 0 - 20K, 1 - 16K, 2 - 10K, 3 - 8K, 4 - 1K
vduvar_TXT_FORE				EQU $0357	; Foreground text colour
vduvar_TXT_BACK				EQU $0358	; Background text colour
vduvar_GRA_FORE				EQU $0359	; Foreground graphics colour
vduvar_GRA_BACK				EQU $035A	; Background graphics colour
vduvar_GRA_PLOT_FORE			EQU $035B	; Foreground plot mode
vduvar_GRA_PLOT_BACK			EQU $035C	; Background plot mode
vduvar_VDU_VEC_JMP			EQU $035D	; General VDU jump vector
vduvar_CUR_START_PREV			EQU $035F	; Cursor start register previous setting
vduvar_COL_COUNT_MINUS1			EQU $0360	; Number logical colours -1
vduvar_PIXELS_PER_BYTE_MINUS1		EQU $0361	; Pixels per byte -1 (zero if text only mode)
vduvar_LEFTMOST_PIX_MASK		EQU $0362	; Leftmost pixel colour mask
vduvar_RIGHTMOST_PIX_MASK		EQU $0363	; Rightmost pixel colour mask
vduvar_TEXT_IN_CUR_X			EQU $0364	; Text input cursor X
vduvar_TEXT_IN_CUR_Y			EQU $0365	; Text input cursor Y
vduvar_MO7_CUR_CHAR			EQU $0366	; Teletext output cursor character
vduvar_EXPLODE_FLAGS			EQU $0367	; Font explosion flags, b1=224-255 in RAM, b7=32-63 in RAM
vduvar_FONT_LOC32_63			EQU $0368	; Font location, characters 32-63
vduvar_FONT_LOC64_95			EQU $0369	; Font location, characters 64-95 
vduvar_FONT_LOC96_127			EQU $036A	; Font location, characters 96-127
vduvar_FONT_LOC128_159			EQU $036B	; Font location, characters 128-159
vduvar_FONT_LOC160_191			EQU $036C	; Font location, characters 160-191
vduvar_FONT_LOC192_223			EQU $036D	; Font location, characters 192-223
vduvar_FONT_LOC224_255			EQU $036E	; Font location, characters 224-255
vduvar_PALLETTE				EQU $036F	; Palette for colours 0 to 15

fsvar_seq_block_gap			EQU $03D1

********************************************************
*           B U F F E R   A D D R E S S E S            *
********************************************************

BUFFER_KEYB_START			EQU $03E0
BUFFER_KEYB_END				EQU $03FF
BUFFER_SERI_START			EQU $0A00
BUFFER_SERI_END				EQU $0AFF
BUFFER_SERO_START			EQU $0900
BUFFER_SERO_END				EQU $09BF
BUFFER_LPT_START			EQU $0880
BUFFER_LPT_END				EQU $08BF
BUFFER_SND0_START			EQU $0840
BUFFER_SND0_END				EQU $084F
BUFFER_SND1_START			EQU $0850
BUFFER_SND1_END				EQU $085F
BUFFER_SND2_START			EQU $0860
BUFFER_SND2_END				EQU $086F
BUFFER_SND3_START			EQU $0870
BUFFER_SND3_END				EQU $087F
BUFFER_SPCH_START			EQU $09C0
BUFFER_SPCH_END				EQU $09FF


BUFFER_PTR_ADDR		MACRO ; 1=START, 2=END
			FDB (\2+1)-$100
			ENDM

BUFFER_ACC_OFF		MACRO ; 1=START, 2=END
			FCB \1-(\2+1)-$100		; i.e. $100 - len!
			ENDM




snd_unused1				EQU $800	; Unused
snd_q_occupied				EQU $804	; Sound queue occupancy flag
snd_amplitude				EQU $808	; Current amplitude
snd_amplitude_phase_count		EQU $80C	; Number of amplitude phases processed
snd_abs_pitch				EQU $810	; Absolute pitch value
snd_pitch_phase_count			EQU $814	; Number of pitch phases processed
snd_steps_left				EQU $818	; Number of steps to process
snd_duration_ctr			EQU $81C	; Duration
snd_duration_mul			EQU $820	; Interval multiplier
snd_env_no				EQU $824	; Envelope number/auto repeat parameter
snd_length_left				EQU $828	; Length of remaining note interval
snd_sync_hold_parm			EQU $82C	; Sync hold parameter
snd_chip_pitch				EQU $830	; Sound chip current pitch setting
snd_pitch_deviation			EQU $834	; Pitch deviation
snd_num_chans_sync			EQU $838	; Number of channels required for sync
snd_cur_amp_step			EQU $839	; Current amplitude step
snd_cur_target_amplitude		EQU $83A	; Current target amplitude
snd_num_chans_hold_sync			EQU $83B	; Number of channels on hold for sync

snd_parm_wksp				EQU $83C	; Sound parameter calculation workspace
snd_low_parm				EQU $83D	; Low order frequency parameter as sent to the sound generator
snd_high_parm				EQU $83E	; High order frequency parameter as sent to the sound generator
snd_tempx				EQU $83F

snd_envelope_defs			EQU $8C0

soft_keys_start				EQU $B00
soft_keys_ptrs				EQU soft_keys_start
soft_keys_end_ptr			EQU soft_keys_ptrs+$10
soft_keys_defs				EQU soft_keys_start+$11

vec_nmi					EQU $0D00

swrom_wksp_tab				EQU $0DF0

; REMAPPED HARDWARE VECTOS

HWVEC_DIV0				EQU	$F7F0
HWVEC_SWI3V				EQU	$F7F2
HWVEC_SWI2V				EQU	$F7F4
HWVEC_FIRQV				EQU	$F7F6
HWVEC_IRQV				EQU	$F7F8
HWVEC_SWIV				EQU	$F7FA
HWVEC_NMIV				EQU	$F7FC
HWVEC_RESETV				EQU	$F7FE