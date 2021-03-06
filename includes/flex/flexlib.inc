*
*   FLEX SYSTEM DEFINED ENTRY POINTS AND EQUATES
*

LINBUF     EQU     $C080               LINE BUFFER
CMDADR     EQU     $C100               UTILITY COMMAND SPACE (1.5 K)
CMDEND     EQU     $C700               UTILITY COMMAND SPACE END
SYSFCB     EQU     $C840               SYSTEM FCB ADDRESS
*
*   GLOBAL VALUES SPECIFIED BY TTYSET AND ASN
*
BSPCHR     EQU     $CC00               BACKSPACE CHARACTER
DELCHR     EQU     $CC01               DELETE CHARACTER
EOLCHR     EQU     $CC02               END OF LINE CHARACTER
DEPTH      EQU     $CC03               DEPTH COUNT
WIDTH      EQU     $CC04               WIDTH COUNT
NULLS      EQU     $CC05               NULL COUNT
TABCHR     EQU     $CC06               TAB CHARACTER
BSECHR     EQU     $CC07               BACKSPACE ECHO CHARACTER
PAUSE      EQU     $CC09               PAUSE CONTROL BYTE
ESCCHR     EQU     $CC0A               ESCAPE CHARACTER
S_DRN      EQU     $CC0B               SYSTEM DRIVE NUMBER
W_DRN      EQU     $CC0C               WORKING DRIVE NUMBER
*
*   FLEX SYSTEM GLOBAL VARIABLES
*
SYSFLG     EQU     $CC0D               USE SYSTEM DRIVE FLAG
SYSDATE    EQU     $CC0E               DATE REGISTERS
LSTTRM     EQU     $CC11               LAST TERMINATOR CHARACTER
CBUFPT     EQU     $CC14               LINE BUFFER POINTER
ESCRET     EQU     $CC16               ESCAPE RETURN REGISTER
CURCHR     EQU     $CC18               CURRENT NXTCH CHARACTER
PREVCH     EQU     $CC19               PREVIOUS NXTCH CHARACTER
CURLCT     EQU     $CC1A               CURRENT LINE COUNT
LOADAO     EQU     $CC1B               LOADER ADDRESS OFFSET DATA
XFRFLG     EQU     $CC1D               TRANSFER ADDRESS FLAG
XFRADR     EQU     $CC1E               TRANSFER ADDRESS OF LOADED FILE
OUTSWT     EQU     $CC22               OUTPUT SWITCH
INSWT      EQU     $CC23               INPUT SWITCH
DOCMDF     EQU     $CC28               DOCMD ENTRY FLAG
CURCOL     EQU     $CC29               CURRENT OUTPUT COLUMN
MEMEND     EQU     $CC2B               END OF MEMORY ADDRESS
ECHOFLAG   EQU	   $CC2F	       DB: ECHO FLAG
FMSBUSY    EQU     $CC30               FLEX ALREADY BUSY FLAG
CPUTYPE    EQU     $CC33               CPU TYPE FLAG
RETADR     EQU     $CC43               DOCMD RETURN ADDRESS
ULCFLAG    EQU     $CC49               UPPER/LOWER CASE MAP FLAG
PROMPT     EQU     $CC4E               POINTER TO PROMPT STRING
*
*   CPU TYPE FLAG BIT DEFINITIONS
*
CPU_2MHZ   EQU     %10000000           1 => 2 MHz CPU CLOCK RATE
CPU_SLOW   EQU     %01000000           1 => MEMORY STRETCH ACTIVE
CPU_50HZ   EQU     %00100000           1 => 50 Hz POWER LINE FREQUENCY
CPU_RAMF   EQU     %00010000           1 => CPU RAM IS AVAILABLE
CPU_RTCK   EQU     %00001000           1 => 6819 REAL TIME CLOCK AVAILABLE
CPU_IOBX   EQU     %00000100           1 => I/O SET UP LIKE OLD BOX
CPU_TIME   EQU     %00000010           1 => 6840 TIMER AVAILABLE
CPU_XMEM   EQU     %00000001           1 => EXTENDED MEMORY IS USED
*
*   PRINTER DRIVER INTERFACE ADDRESSES
*
PT_RAP     EQU     $CC35               PRINTER RESERVED AREA POINTER
PT_LEN     EQU     $CC37               PRINTER RESERVED AREA LENGTH
PT_DEV     EQU     $CC39               PRINTER DEVICE ADDRESS
PINIT      EQU     $CCC0               PRINTER INITIALIZE VECTOR
PTERM      EQU     $CCD0               PRINTER CLOSE VECTOR
PCHK       EQU     $CCD8               PRINTER READY CHECK VECTOR
POUT       EQU     $CCE4               PRINTER CHARACTER OUTPUT ROUTINE
PRCFLG     EQU     $CCFC               ACTIVE SPOOLING PROCESS FLAG
*
*   FLEX SYSTEM DEFINED ENTRY VECTORS
*
COLDS      EQU     $CD00               FLEX COLD START ADDRESS
WARMS      EQU     $CD03               FLEX WARM START ADDRESS
RENTER     EQU     $CD06               RE-ENTER FLEX PROCESSING
INCH       EQU     $CD09               INPUT CHARACTER (LOW LEVEL)
OUTCH      EQU     $CD0F               OUTPUT CHARACTER (LOW LEVEL)
GETCHR     EQU     $CD15               INPUT CHARACTER ROUTINE
PUTCHR     EQU     $CD18               OUTPUT CHARACTER ROUTINE
INBUFF     EQU     $CD1B               INPUT LINE BUFFER
PSTRNG     EQU     $CD1E               PRINT STRING
CLASS      EQU     $CD21               CLASSIFY CHARACTER
PCRLF      EQU     $CD24               PRINT CR/LF SEQUENCE
NXTCH      EQU     $CD27               GET NEXT CHARACTER FROM INPUT BUFFER
GETFIL     EQU     $CD2D               SCAN FILE SPEC ADDRESS
LOAD       EQU     $CD30               LOAD FILE ENTRY POINT
SETEXT     EQU     $CD33               SET UP FILE EXTENSION
OUTDEC     EQU     $CD39               OUTPUT DECIMAL NUMBER
OUTHEX     EQU     $CD3C               OUTPUT HEXADECIMAL NUMBER
RPTERR     EQU     $CD3F               I/O ERROR ABORT ROUTINE
GETHEX     EQU     $CD42               GET HEXIDECIMAL SPECIFICATION
OUTADR     EQU     $CD45               OUTPUT HEXADECIMAL ADDRESS
INDEC      EQU     $CD48               GET DECIMAL NUMBER
DOCMD      EQU     $CD4B               DOCMD ENTRY ADDRESS
STATUS     EQU     $CD4E               CHECK TERMINAL INPUT STATUS
*
*   LOW LEVEL TERMINAL AND INTERRUPT CONTROL ADDRESSES
*
INTAP      EQU     $D3DE               VECTOR FOR INPUT TAP ROUTINE
DUMMY      EQU     $D3E0               DUMMY RTS INSTRUCTION USED BY RM
SETIRQ     EQU     $D3E1               SET IRQ PROCESS VECTOR
CLRIRQ     EQU     $D3E3               CLEAR IRQ PROCESS VECTOR
TINCH      EQU     $D3E5               LOW-LEVEL TERM INPUT WITHOUT ECHO
T_OFF      EQU     $D3ED               TIMER OFF ROUTINE ADDRESS
T_ON       EQU     $D3EF               TIMER ON ROUTINE ADDRESS
T_INIT     EQU     $D3F1               TIMER INITIALIZE ROUTINE ADDRESS
TINIT      EQU     $D3F5               LOW-LEVEL TERMINAL INITIALIZE
TCHECK     EQU     $D3F7               LOW-LEVEL TERMINAL CHECK ADDRESS
TOUTCH     EQU     $D3F9               LOW-LEVEL TERMINAL OUTPUT ADDRESS
TINCHE     EQU     $D3FB               LOW-LEVEL TERMINAL INPUT WITH ECHO
*
*   FILE MANAGEMENT SYSTEM ENTRY POINTS
*
FMSCLS     EQU     $D403               CLOSE UP ALL FILES ENTRY
FMS        EQU     $D406               FILE MANAGER EXEC CALL
FCBASE     EQU     $D409               FILE CONTROL BLOCK BASE
VERIFY     EQU     $D435               FMS VERIFY FLAG
SURTAB     EQU     $D436               FMS SURNAME TABLE

FCBLEN     EQU     256+64              FILE CONTROL BLOCK LENGTH
*
*   DISK DRIVER ENTRY POINTS
*
DREAD      EQU     $DE00               READ SECTOR ROUTINE
DWRITE     EQU     $DE03               WRITE SECTOR ROUTINE
DVERFY     EQU     $DE06               VERIFY ROUTINE
DREST      EQU     $DE09               DRIVE RESTORE ROUTINE
DRIVE      EQU     $DE0C               DRIVE SELECT ROUTINE
DCHECK     EQU     $DE0F               CHECK DRIVE READY
DQUICK     EQU     $DE12               QUICK CHECK DRIVE READY
DCOLDS     EQU     $DE15               COLD START INITIALIZER
DWARMS     EQU     $DE18               WARM START INITIALIZER
DSEEK      EQU     $DE1B               DRIVE SEEK-TO-SECTOR ROUTINE

SETEXT_BIN     		EQU	0
SETEXT_TXT     		EQU	1
SETEXT_CMD     		EQU	2
SETEXT_BAS     		EQU	3
SETEXT_SYS     		EQU	4
SETEXT_BAK     		EQU	5
SETEXT_SCR     		EQU	6
SETEXT_DAT     		EQU	7
SETEXT_BAC     		EQU	8
SETEXT_DIR     		EQU	9
SETEXT_PRT     		EQU	10
SETEXT_OUT		EQU	11

FMS_RDWR		EQU	0
FMS_OPENRD		EQU	1
FMS_OPENWR		EQU	2
FMS_CLOSE		EQU	4

FCBOFFS_ERR		EQU	1
FCBOFFS_COMPRESS	EQU	59

FMS_ERR_EOF		EQU	8

           END
