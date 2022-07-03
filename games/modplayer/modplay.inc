MODULE_BASE		EQU $3C00
MODULE_SONG		EQU MODULE_BASE + $80
MODULE_PATTERNS		EQU MODULE_BASE + $100
LOAD_BLOCK_SIZE 	EQU $10				; pages!
MAX_SAMPLE_DEFS 	EQU 32
SONG_DATA_LEN		EQU 128
PATTERN_LEN		EQU 1024
MODULE_CPAGE		EQU $0100			; page in chipram to store mod - avoid bottom 64K



HDR_SONG_SAMPLES	EQU 20
HDR_SONG_LEN_OFFS	EQU 950
HDR_SONG_DATA_OFFS	EQU 952
HDR_PATT_DATA_OFFS	EQU 1084


FLAGS_key_pause		EQU $40					; when set key_pause playing
FLAGS_EXEC		EQU $20					; set by event driven player to indicate it has run


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
cha_var_peak		equ 21
cha_vars_size		equ 22


MOD_TITLE_LEN		EQU 20


s_saminfo_len		EQU 0			; 2	; note order of these important as copied from sample info table
s_saminfo_roff		EQU 2			; 2
s_saminfo_addr_b	EQU 4			; 3	; low 4 bits are bank # top 4 bits are finetune
s_saminfo_addr		EQU 5			; 3
s_saminfo_repfl		EQU 7			; 1	>$80 for repeat (low 6 bits are sample vol)
s_saminfo_sizeof	EQU 8

		; original sample layout in chip mem / mod file
s_modsaminfo_name	EQU 0			; .res	22
s_modsaminfo_len	EQU 22			; .word
s_modsaminfo_fine	EQU 24			; .byte
s_modsaminfo_vol	EQU 25			; .byte
s_modsaminfo_repoffs	EQU 26			; .word
s_modsaminfo_replen	EQU 28			; .word
s_modsaminfo_sizeof	EQU 30
