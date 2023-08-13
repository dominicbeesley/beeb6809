;	OS Entry points

GSINIT					EQU	$FFC2
GSREAD					EQU	$FFC5
OSRDCH_NV				EQU	$FFC8
OSWRCH_NV				EQU	$FFCB
OSFIND					EQU	$FFCE
OSGBPB					EQU	$FFD1
OSBPUT					EQU	$FFD4
OSBGET					EQU	$FFD7
OSARGS					EQU	$FFDA
OSFILE					EQU	$FFDD
OSRDCH					EQU	$FFE0
OSASCI					EQU	$FFE3
OSNEWL					EQU	$FFE7
OSWRCR					EQU	$FFEC
OSWRCH					EQU	$FFEE
OSWORD					EQU	$FFF1
OSBYTE					EQU	$FFF4
OSCLI					EQU	$FFF7
OSROMSEL				EQU	$FFFA
OSCHAINVEC				EQU	$FFFD

PRSTRING				EQU	$FF9B
CLICOM					EQU	$FFB9
ERRJMP					EQU	$FFBC
OSINIT					EQU	$FFBF
SCANHEX					EQU	$FFA1
OSQUIT					EQU	$FFA7
PRHEX					EQU	$FFAA
PR2HEX					EQU	$FFAD
USERINT					EQU	$FFB0
PRTEXT					EQU	$FFB3

OSRDRM					EQU	$FF98	!!! Different to Beeb !!!
OSEVEN					EQU	$FF9E	!!! Different to Beeb !!!
RAWVDU					EQU	$FFA3	!!! Different to Beeb !!!

DEBUGPRINTNEWL				EQU	$FF8C
DEBUGPRINTHEX				EQU	$FF8F
DEBUGPRINTA				EQU	$FF92
DEBUGPRINTX				EQU	$FF95

;	OS Constants
OSFILE_LOAD				EQU $FF
OSFILE_SAVE				EQU $00
OSFILE_CAT				EQU $05
OSFILE_OFS_FILENAME			EQU $00
OSFILE_OFS_LOAD				EQU $02
OSFILE_OFS_EXEC				EQU $06
OSFILE_OFS_LEN				EQU $0A
OSFILE_OFS_START			EQU $0A
OSFILE_OFS_ATTR				EQU $0E
OSFILE_OFS_END				EQU $0E

OSFIND_CLOSE				EQU $00
OSFIND_OPENIN				EQU $40
OSFIND_OPENOUT				EQU $80
OSFIND_OPENUP				EQU $C0

OSWORD_SOUND				EQU $07
OSWORD_ENVELOPE				EQU $08

OSARGS_cmdtail				EQU $01
OSARGS_EXT				EQU $02


OSGBPB_WRITE_PTR			EQU	$00
OSGBPB_WRITE_NOPTR			EQU	$02
OSGBPB_READ_PTR				EQU	$03
OSGBPB_READ_NOPTR			EQU	$04
OSGBPB_READ_TITLE			EQU	$05
OSGBPB_READ_DIR				EQU	$06
OSGBPB_READ_LIB				EQU	$07
OSGBPB_GET_DIRENT			EQU	$08


SERVICE_0_NOP				EQU	$0
SERVICE_1_ABSWKSP_REQ			EQU	$1
SERVICE_2_RELWKSP_REQ			EQU	$2
SERVICE_3_AUTOBOOT			EQU	$3
SERVICE_4_UKCMD				EQU	$4
SERVICE_5_UKINT				EQU	$5
SERVICE_6_BRK				EQU	$6
SERVICE_7_UKOSBYTE			EQU	$7
SERVICE_7_UKOSWORD			EQU	$8
SERVICE_9_HELP				EQU	$9
SERVICE_A_ABSWKSP_CLAIM			EQU	$A
SERVICE_B_NMI_RELEASE			EQU	$B
SERVICE_C_NMI_CLAIM			EQU	$C
SERVICE_D_ROMFS_INIT			EQU	$D
SERVICE_E_ROMFS_GETB			EQU	$E
SERVICE_F_FSVEC_CLAIMED			EQU	$F
SERVICE_10_SPOOL_CLOSE			EQU	$10
SERVICE_11_FONT_BANG			EQU	$11
SERVICE_12_INITFS			EQU	$12
SERVICE_13_SERIAL_CHAR			EQU	$13
SERVICE_14_PRINT_CHAR			EQU	$14
SERVICE_15_100Hz			EQU	$15
SERVICE_25_FSINFO			EQU	$25

FSCV_6_NewFS				EQU	$06

	IF NOT MACH_MATCHBOX
; All vectors are now extended, except MB
; OS Vectors

USERV					EQU	$0200	; User vector, called by *LINE, *CODE, OSWORD >=&E0
BRKV					EQU	$0202	; The BRK vector
IRQ1V					EQU	$0204	; Main interrupt vector
IRQ2V					EQU	$0206	; Secondary interrupt vector
CLIV					EQU	$0208	; Command Line Interpreter vector
BYTEV					EQU	$020A	; OSBYTE (*FX) calls
WORDV					EQU	$020C	; OSWORD calls
WRCHV					EQU	$020E	; Send character to current output stream
RDCHV					EQU	$0210	; Wait for a character from current input stream
FILEV					EQU	$0212	; Operate on a whole file, eg loading/saving/delete/etc
ARGSV					EQU	$0214	; Read/Write arguments on an open file
BGETV					EQU	$0216	; Read a byte from an open file
BPUTV					EQU	$0218	; Write a byte to an open file
GBPBV					EQU	$021A	; Read/Write block of data from/to open file or device
FINDV					EQU	$021C	; Open or close a file
FSCV					EQU	$021E	; Various filing system control calls
EVNTV					EQU	$0220	; Event handler
UPTV					EQU	$0222	; User Print vector
NETV					EQU	$0224	; Network Print vector
VDUV					EQU	$0226	; Unrecognised VDU commands
KEYV					EQU	$0228	; Read the keyboard
INSV					EQU	$022A	; Insert characters into a buffer
REMV					EQU	$022C	; Remove characters from a buffer
CNPV					EQU	$022E	; Count or Purge a buffer
;;IND1V					EQU	$0230	; Spare 
SWI9V					EQU	$0230	; SWI instruction vector - do not use except for debugging
ILOPV					EQU	$0232	; Illegal operation vector
NMI9V					EQU	$0234	; NMI vector - do not use except for debugging

	ENDIF
; OS Extended Vectors Marker addresses

EXTVEC_ENTER_USERV			EQU	$FF00	; User vector, called by *LINE, *CODE, OSWORD >=&E0
EXTVEC_ENTER_BRKV			EQU	$FF03	; The BRK vector
EXTVEC_ENTER_IRQ1V			EQU	$FF06	; Main interrupt vector
EXTVEC_ENTER_IRQ2V			EQU	$FF09	; Secondary interrupt vector
EXTVEC_ENTER_CLIV			EQU	$FF0C	; Command Line Interpreter vector
EXTVEC_ENTER_BYTEV			EQU	$FF0F	; OSBYTE (*FX) calls
EXTVEC_ENTER_WORDV			EQU	$FF12	; OSWORD calls
EXTVEC_ENTER_WRCHV			EQU	$FF15	; Send character to current output stream
EXTVEC_ENTER_RDCHV			EQU	$FF18	; Wait for a character from current input stream
EXTVEC_ENTER_FILEV			EQU	$FF1B	; Operate on a whole file, eg loading/saving/delete/etc
EXTVEC_ENTER_ARGSV			EQU	$FF1E	; Read/Write arguments on an open file
EXTVEC_ENTER_BGETV			EQU	$FF21	; Read a byte from an open file
EXTVEC_ENTER_BPUTV			EQU	$FF24	; Write a byte to an open file
EXTVEC_ENTER_GBPBV			EQU	$FF27	; Read/Write block of data from/to open file or device
EXTVEC_ENTER_FINDV			EQU	$FF2A	; Open or close a file
EXTVEC_ENTER_FSCV			EQU	$FF2D	; Various filing system control calls
EXTVEC_ENTER_EVNTV			EQU	$FF30	; Event handler
EXTVEC_ENTER_UPTV			EQU	$FF33	; User Print vector
EXTVEC_ENTER_NETV			EQU	$FF36	; Network Print vector
EXTVEC_ENTER_VDUV			EQU	$FF39	; Unrecognised VDU commands
EXTVEC_ENTER_KEYV			EQU	$FF3C	; Read the keyboard
EXTVEC_ENTER_INSV			EQU	$FF3F	; Insert characters into a buffer
EXTVEC_ENTER_REMV			EQU	$FF42	; Remove characters from a buffer
EXTVEC_ENTER_CNPV			EQU	$FF45	; Count or Purge a buffer
EXTVEC_ENTER_SWI9V			EQU	$FF48	; Spare
EXTVEC_ENTER_ILOPV			EQU	$FF4B	; Spare
EXTVEC_ENTER_NMI9V			EQU	$FF4E	; Spare
OSEXITVEC				EQU	$FF51
OSCALLVEC				EQU	$FF54

EXT_USERV				EQU	$0D9F	; User vector, called by *LINE, *CODE, OSWORD >=&E0
EXT_BRKV				EQU	$0DA2	; The BRK vector
EXT_IRQ1V				EQU	$0DA5	; Main interrupt vector
EXT_IRQ2V				EQU	$0DA8	; Secondary interrupt vector
EXT_CLIV				EQU	$0DAB	; Command Line Interpreter vector
EXT_BYTEV				EQU	$0DAE	; OSBYTE (*FX) calls
EXT_WORDV				EQU	$0DB1	; OSWORD calls
EXT_WRCHV				EQU	$0DB4	; Send character to current output stream
EXT_RDCHV				EQU	$0DB7	; Wait for a character from current input stream
EXT_FILEV				EQU	$0DBA	; Operate on a whole file, eg loading/saving/delete/etc
EXT_ARGSV				EQU	$0DBD	; Read/Write arguments on an open file
EXT_BGETV				EQU	$0DC0	; Read a byte from an open file
EXT_BPUTV				EQU	$0DC3	; Write a byte to an open file
EXT_GBPBV				EQU	$0DC6	; Read/Write block of data from/to open file or device
EXT_FINDV				EQU	$0DC9	; Open or close a file
EXT_FSCV				EQU	$0DCC	; Various filing system control calls
EXT_EVNTV				EQU	$0DCF	; Event handler
EXT_UPTV				EQU	$0DD2	; User Print vector
EXT_NETV				EQU	$0DD5	; Network Print vector
EXT_VDUV				EQU	$0DD8	; Unrecognised VDU commands
EXT_KEYV				EQU	$0DDB	; Read the keyboard
EXT_INSV				EQU	$0DDE	; Insert characters into a buffer
EXT_REMV				EQU	$0DE1	; Remove characters from a buffer
EXT_CNPV				EQU	$0DE4	; Count or Purge a buffer
EXT_SWI9V				EQU	$0DE7	; SWI instruction vector - do not use except for debugging
EXT_ILOPV				EQU	$0DEA	; Illegal operation vector
EXT_NMI9V				EQU	$0DED	; NMI vector - do not use except for debugging

OSBYTE_13_ENABLE_EVENT			EQU	13
OSBYTE_14_ENABLE_EVENT			EQU	14
OSBYTE_108_WRITE_SHADOW_STATE		EQU	108
OSBYTE_119_CLOSE_SPOOL_AND_EXEC		EQU	119
OSBYTE_126_ESCAPE_ACK			EQU	126
OSBYTE_129_INKEY			EQU	129
OSBYTE_142_SERVICE_CALL			EQU	143
OSBYTE_156_SERIAL_STATE			EQU	156
OSBYTE_160_READ_VDU_VARIABLE		EQU	160
OSBYTE_168_READ_ROM_POINTER_TABLE	EQU	168
OSBYTE_171_ROMTAB			EQU	170
OSBYTE_232_VAR_IRQ_MASK_SERIAL		EQU	232
OSBYTE_234_VAR_TUBE			EQU	234
OSBYTE_253_VAR_LAST_RESET		EQU	253

vduvar_ix_GRA_WINDOW			EQU $00				
vduvar_ix_GRA_WINDOW_LEFT		EQU $00	; Current graphics window left column in pixels
vduvar_ix_GRA_WINDOW_BOTTOM		EQU $02	; Current graphics window bottom row in pixels
vduvar_ix_GRA_WINDOW_RIGHT		EQU $04	; Current graphics window right column in pixels
vduvar_ix_GRA_WINDOW_TOP		EQU $06	; Current graphics window top row in pixels
vduvar_ix_TXT_WINDOW_LEFT		EQU $08	; Current text window left hand column
vduvar_ix_TXT_WINDOW_BOTTOM		EQU $09	; Current text window bottom row
vduvar_ix_TXT_WINDOW_RIGHT		EQU $0A	; Current text window right hand column
vduvar_ix_TXT_WINDOW_TOP		EQU $0B	; Current text window top column
vduvar_ix_GRA_ORG_EXT			EQU $0C	; Current graphics origin in external coordinates
vduvar_ix_GRA_CUR_EXT			EQU $10	; Current graphics cursor in external coordinates
vduvar_ix_GRA_CUR_INT_OLD		EQU $14	; Old graphics cursor in external coordinates
vduvar_ix_TXT_CUR_X			EQU $18	; Current text cursor X
vduvar_ix_TXT_CUR_Y			EQU $19	; Current text cursor Y
vduvar_ix_GRA_CUR_CELL_LINE		EQU $1A	; Line within current graphics cell of graphics cursor
vduvar_ix_VDU_Q_START			EQU $1B
vduvar_ix_VDU_Q_END			EQU $24	; end of VDU Q (well 1 after!)
vduvar_ix_GRA_CUR_INT			EQU $24	; Current graphics cursor in internal coordinates
vduvar_ix_TEMP_8			EQU $28	; Bitmap read from screen by OSBYTE 135, various coordinate routines
vduvar_ix_GRA_WKSP			EQU $30	; Graphics workspace
vduvar_ix_6845_CURSOR_ADDR		EQU $4A	; Text cursor address for 6845
vduvar_ix_TXT_WINDOW_WIDTH_BYTES	EQU $4C	; Text window width in bytes
vduvar_ix_SCREEN_BOTTOM_HIGH		EQU $4E	; High byte of bottom of screen memory
vduvar_ix_BYTES_PER_CHAR		EQU $4F	; Bytes per character for current mode
vduvar_ix_6845_SCREEN_START		EQU $50	; Screen display start address for 6845
vduvar_ix_BYTES_PER_ROW			EQU $52	; Bytes per screen row
vduvar_ix_SCREEN_SIZE_HIGH		EQU $54	; Screen memory size high byte
vduvar_ix_MODE				EQU $55	; Current screen mode
vduvar_ix_MODE_SIZE			EQU $56	; Memory map type: 0 - 20K, 1 - 16K, 2 - 10K, 3 - 8K, 4 - 1K
vduvar_ix_TXT_FORE			EQU $57	; Foreground text colour
vduvar_ix_TXT_BACK			EQU $58	; Background text colour
vduvar_ix_GRA_FORE			EQU $59	; Foreground graphics colour
vduvar_ix_GRA_BACK			EQU $5A	; Background graphics colour
vduvar_ix_GRA_PLOT_FORE			EQU $5B	; Foreground plot mode
vduvar_ix_GRA_PLOT_BACK			EQU $5C	; Background plot mode
vduvar_ix_VDU_VEC_JMP			EQU $5D	; General VDU jump vector
vduvar_ix_CUR_START_PREV		EQU $5F	; Cursor start register previous setting
vduvar_ix_COL_COUNT_MINUS1		EQU $60	; Number logical colours -1
vduvar_ix_PIXELS_PER_BYTE_MINUS1	EQU $61	; Pixels per byte -1 (zero if text only mode)
vduvar_ix_LEFTMOST_PIX_MASK		EQU $62	; Leftmost pixel colour mask
vduvar_ix_RIGHTMOST_PIX_MASK		EQU $63	; Rightmost pixel colour mask
vduvar_ix_TEXT_IN_CUR_X			EQU $64	; Text input cursor X
vduvar_ix_TEXT_IN_CUR_Y			EQU $65	; Text input cursor Y
vduvar_ix_MO7_CUR_CHAR			EQU $66	; Teletext output cursor character
vduvar_ix_EXPLODE_FLAGS			EQU $67	; Font explosion flags, b1=224-255 in RAM, b7=32-63 in RAM
vduvar_ix_FONT_LOC32_63			EQU $68	; Font location, characters 32-63
vduvar_ix_FONT_LOC64_95			EQU $69	; Font location, characters 64-95 
vduvar_ix_FONT_LOC96_127		EQU $6A	; Font location, characters 96-127
vduvar_ix_FONT_LOC128_159		EQU $6B	; Font location, characters 128-159
vduvar_ix_FONT_LOC160_191		EQU $6C	; Font location, characters 160-191
vduvar_ix_FONT_LOC192_223		EQU $6D	; Font location, characters 192-223
vduvar_ix_FONT_LOC224_255		EQU $6E	; Font location, characters 224-255
vduvar_ix_PALLETTE			EQU $6F	; Palette for colours 0 to 15