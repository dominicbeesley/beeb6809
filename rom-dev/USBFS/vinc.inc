

;	                _______
;                        |     |
;                 +------|     |------+
;                 |      J1   J2      | 	
;        Vcc     -+ 5v0     1     3v3 +-	NC
;                 |                   | 	
;        NC      -+ IO5     2    PRG# +-	Vcc
;                 |                   | 	
;        NC      -+ IO6     3    RST# +-	nRESET (note conditioned as noise was causing issues)
;                 |                   | 	
;        NC      -+ U1P     4    IO25 +-	NC
;                 |                   | 	
;        NC      -+ U1M     5    IO24 +-	NC
;                 |                   | 	
;        D0      -+ IO12    6    IO23 +-	#WR
;                 |                   | 	
;        GND     -+ GND     7     GND +-	GND
;                 |                   | 	
;        D1      -+ IO13    8    IO22 +-	#RD
;                 |                   | 	
;        D2      -+ IO14    9    IO21 +-	#TXE
;                 |                   | 	
;        D3      -+ IO15    10   IO20 +-	#RXF
;                 |                   | 	
;        D4      -+ IO16    11   IO19 +-	D7
;                 |                   | 	
;        D5      -+ IO17    12   IO18 +-	D6
;                 |                   | 	
;                 +-------------------+
;
;
;


VINC_CMD_SCS	EQU	$10
VINC_CMD_ECS	EQU	$11
VINC_CMD_IPA	EQU	$90
VINC_CMD_IPH	EQU	$91
VINC_CMD_FWV	EQU	$13
VINC_CMD_E_U	EQU	'E'
VINC_CMD_E_L	EQU	'e'

*** VDAP ***
VINC_CMD_DIR	EQU	$01
VINC_CMD_CD	EQU	$02
VINC_CMD_RD	EQU	$04
VINC_CMD_DLD	EQU	$05
VINC_CMD_MKD	EQU	$06
VINC_CMD_DLF	EQU	$07
VINC_CMD_WRF	EQU	$08
VINC_CMD_OPW	EQU	$09
VINC_CMD_CLF	EQU	$0A
VINC_CMD_RDF	EQU	$0B
VINC_CMD_REN	EQU	$0C
VINC_CMD_OPR	EQU	$0E
VINC_CMD_SEK	EQU	$28
VINC_CMD_FS	EQU	$12
VINC_CMD_FSE	EQU	$93
VINC_CMD_IDD	EQU	$0F
VINC_CMD_IDDE	EQU	$94
VINC_CMD_DSN	EQU	$2D
VINC_CMD_DVL	EQU	$2E
VINC_CMD_DIRT	EQU	$2F
