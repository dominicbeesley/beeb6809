* Address of MOS ROM base
MOSROMBASE				EQU $E100	; leave room for noice scratch space at E000
MOSSTRINGS				EQU $F4A0
MOSROMSYS_DP				EQU $E400
STACKTOP				EQU $E500
MOSCODEBASE				EQU $E600
sysvars_start				EQU $E580
vduvars_start				EQU $E500
oswksp_start				EQU $E590

mos_MACHINE_TYPE_BYTE			EQU $63

vduvar_GRA_WINDOW			EQU vduvars_start + $00
vduvar_GRA_WINDOW_LEFT			EQU vduvars_start + $00	; Current graphics window left column in pixels
vduvar_GRA_WINDOW_BOTTOM		EQU vduvars_start + $02	; Current graphics window bottom row in pixels
vduvar_GRA_WINDOW_RIGHT			EQU vduvars_start + $04	; Current graphics window right column in pixels
vduvar_GRA_WINDOW_TOP			EQU vduvars_start + $06	; Current graphics window top row in pixels
vduvar_TXT_WINDOW_LEFT			EQU vduvars_start + $08	; Current text window left hand column
vduvar_TXT_WINDOW_BOTTOM		EQU vduvars_start + $09	; Current text window bottom row
vduvar_TXT_WINDOW_RIGHT			EQU vduvars_start + $0A	; Current text window right hand column
vduvar_TXT_WINDOW_TOP			EQU vduvars_start + $0B	; Current text window top column
vduvar_GRA_ORG_EXT			EQU vduvars_start + $0C	; Current graphics origin in external coordinates
vduvar_GRA_CUR_EXT			EQU vduvars_start + $10	; Current graphics cursor in external coordinates
vduvar_GRA_CUR_INT_OLD			EQU vduvars_start + $14	; Old graphics cursor in external coordinates
vduvar_TXT_CUR_X			EQU vduvars_start + $18	; Current text cursor X
vduvar_TXT_CUR_Y			EQU vduvars_start + $19	; Current text cursor Y
vduvar_GRA_CUR_CELL_LINE		EQU vduvars_start + $1A	; Line within current graphics cell of graphics cursor
vdvvar_VDU_Q_START			EQU vduvars_start + $1B	
vduvar_VDU_Q_END			EQU vduvars_start + $24	; end of VDU Q (well 1 after!)
vduvar_GRA_CUR_INT			EQU vduvars_start + $24	; Current graphics cursor in internal coordinates
vduvar_TEMP_8				EQU vduvars_start + $28	; Bitmap read from screen by OSBYTE 135, various coordinate routines
vduvar_GRA_WKSP				EQU vduvars_start + $30	; Graphics workspace
vduvar_6845_CURSOR_ADDR			EQU vduvars_start + $4A	; Text cursor address for 6845
vduvar_TXT_WINDOW_WIDTH_BYTES		EQU vduvars_start + $4C	; Text window width in bytes
vduvar_SCREEN_BOTTOM_HIGH		EQU vduvars_start + $4E	; High byte of bottom of screen memory
vduvar_BYTES_PER_CHAR			EQU vduvars_start + $4F	; Bytes per character for current mode
vduvar_6845_SCREEN_START		EQU vduvars_start + $50	; Screen display start address for 6845
vduvar_BYTES_PER_ROW			EQU vduvars_start + $52	; Bytes per screen row
vduvar_SCREEN_SIZE_HIGH			EQU vduvars_start + $54	; Screen memory size high byte
vduvar_MODE				EQU vduvars_start + $55	; Current screen mode
vduvar_MODE_SIZE			EQU vduvars_start + $56	; Memory map type: 0 - 20K, 1 - 16K, 2 - 10K, 3 - 8K, 4 - 1K
vduvar_TXT_FORE				EQU vduvars_start + $57	; Foreground text colour
vduvar_TXT_BACK				EQU vduvars_start + $58	; Background text colour
vduvar_GRA_FORE				EQU vduvars_start + $59	; Foreground graphics colour
vduvar_GRA_BACK				EQU vduvars_start + $5A	; Background graphics colour
vduvar_GRA_PLOT_FORE			EQU vduvars_start + $5B	; Foreground plot mode
vduvar_GRA_PLOT_BACK			EQU vduvars_start + $5C	; Background plot mode
vduvar_VDU_VEC_JMP			EQU vduvars_start + $5D	; General VDU jump vector
vduvar_CUR_START_PREV			EQU vduvars_start + $5F	; Cursor start register previous setting
vduvar_COL_COUNT_MINUS1			EQU vduvars_start + $60	; Number logical colours -1
vduvar_PIXELS_PER_BYTE_MINUS1		EQU vduvars_start + $61	; Pixels per byte -1 (zero if text only mode)
vduvar_LEFTMOST_PIX_MASK		EQU vduvars_start + $62	; Leftmost pixel colour mask
vduvar_RIGHTMOST_PIX_MASK		EQU vduvars_start + $63	; Rightmost pixel colour mask
vduvar_TEXT_IN_CUR_X			EQU vduvars_start + $64	; Text input cursor X
vduvar_TEXT_IN_CUR_Y			EQU vduvars_start + $65	; Text input cursor Y
vduvar_MO7_CUR_CHAR			EQU vduvars_start + $66	; Teletext output cursor character
vduvar_EXPLODE_FLAGS			EQU vduvars_start + $67	; Font explosion flags, b1=224-255 in RAM, b7=32-63 in RAM
vduvar_FONT_LOC32_63			EQU vduvars_start + $68	; Font location, characters 32-63
vduvar_FONT_LOC64_95			EQU vduvars_start + $69	; Font location, characters 64-95 
vduvar_FONT_LOC96_127			EQU vduvars_start + $6A	; Font location, characters 96-127
vduvar_FONT_LOC128_159			EQU vduvars_start + $6B	; Font location, characters 128-159
vduvar_FONT_LOC160_191			EQU vduvars_start + $6C	; Font location, characters 160-191
vduvar_FONT_LOC192_223			EQU vduvars_start + $6D	; Font location, characters 192-223
vduvar_FONT_LOC224_255			EQU vduvars_start + $6E	; Font location, characters 224-255
vduvar_PALLETTE				EQU vduvars_start + $6F	; Palette for colours 0 to 15

sysvar_VDU_Q_LEN			EQU	sysvars_start + 0
sysvar_SCREENLINES_SINCE_PAGE		EQU	sysvars_start + 1
sysvar_VIDPROC_PAL_COPY			EQU	sysvars_start + 2


oswksp_VDU_VERTADJ			EQU oswksp_start + $00	; VDU vertical adjust, *TV first parameter
oswksp_VDU_INTERLACE			EQU oswksp_start + $01	; Interlace toggle flag, *TV second parameter
