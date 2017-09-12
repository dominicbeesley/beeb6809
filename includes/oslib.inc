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
OSFILE_OFS_FILENAME			EQU $00
OSFILE_OFS_LOAD				EQU $02
OSFILE_OFS_EXEC				EQU $06
OSFILE_OFS_LEN				EQU $0A
OSFILE_OFS_START			EQU $0A
OSFILE_OFS_ATTR				EQU $0E
OSFILE_OFS_END				EQU $0E

OSWORD_SOUND				EQU $07
OSWORD_ENVELOPE				EQU $08


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

FSCV_6_NewFS				EQU	$06

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
IND1V					EQU	$0230	; Spare
IND2V					EQU	$0232	; Spare
IND3V					EQU	$0234	; Spare

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
EXTVEC_ENTER_IND1V			EQU	$FF48	; Spare
EXTVEC_ENTER_IND2V			EQU	$FF4B	; Spare
EXTVEC_ENTER_IND3V			EQU	$FF4E	; Spare

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
EXT_IND1V				EQU	$0DE7	; Spare
EXT_IND2V				EQU	$0DEA	; Spare
EXT_IND3V				EQU	$0DED	; Spare
