		; TTL  TSC 6809 FLEX
		; NAM  FLEX
		; OPT  PAG
	******************************
	*
	* FLEX VER 3.01
	*
	******************************

STACK		EQU	$C07F
BUFFER		EQU	$C080				; line input buffer
LSTBLK		EQU	$C0A0				; last ram offset
ENDBUF		EQU	$C0FF				; end of line buffer
CNGTSK		EQU	$C700				; change active task
		; SPC  1
		ORG	$C838
ERRFCB		RMB	8				; error report fcb

	*SYSTEM FILE CONTROL BLOCK
		ORG	$C840
SYSFCB		FCB	0,0,0,0
FCBNAM		FCC	"STARTUP"
		FCB	0
		FCC	"TXT"
		; SPC  1
		ORG	$CA00
INIT		BRA	INIT1
DVECT		RTS				;  vector to date prompt
	*DVECT JSR GDATE
		RTS
LASTM		FDB	LSTBLK				; set default end of ram

INIT1		LDA	#$39				; close path to get here
		STA	JMPINT
		LDX	MEMEND
		LEAX	$A1,X
		STX	LASTM				; set last usable ram
		JSR	[INTACA]				; initalize ACIA
		LDX	INVEC				; set vectors in jump table
		STX	INCH+1
		STX	INCH2+1
		LDX	OUTVEC
		STX	OUTCH+1
		STX	OUTCH2+1
		LDX	STAVEC
		STX	STAT+1
		LDX	#$00A0				; start of memory + $A0
		LDB	#$B9
INIT01		LDA	,X				; save memory
		STB	,X				; test for RAM
		NOP
		CMPB	,X
		BNE	INIT02				; not ram?
		STA	,X				; restore memory
		LEAX	$0400,X				; move up 1K
		CMPX	LASTM				; end of user RAM?
		BNE	INIT01				; test some more
INIT02		LEAX	$FF5F,X				; move to last good block
		STX	MEMEND
		LDX	#WARMS
		STX	ESCRET				; set ESCAPE RETURN
		LDX	#FLEX9
		JSR	PRINT				; print heading
		JSR	CRLF1
		BSR	DVECT				; get date
		JSR	CRLF1
		LDX	#SYSFCB				; point to fcb
		LDA	#$01
		STA	,X				; open for read
		JSR	FMCALL
		BEQ	STRTUP				; no error?
		LDA	$01,X				; get error number
		JSR	LDERR				; report it
		JMP	WARM				; return to flex
STRTUP		LDX	#BUFFER
STAR02		STX	BUFPTR				; set up input buffer
		LDX	#SYSFCB
		JSR	FMCALL				; get character from file
		BEQ	STAR03				; no error?
		PSHS	Y,X
		JMP	ERROR3				; back to flex
STAR03		LDX	BUFPTR
		STA	,X+				; put char. in line buffer
		CMPA	#$0D				; end of line?
		BNE	STAR02				; get next character
		LDX	#SYSFCB
		JSR	LDCLOS				; close file
		LDX	#BUFFER
		STX	BUFPTR				; reset line buffer
		LDX	#WARM
		STX	CMDRTN				; set return address
		JMP	CMND1				; do command
		; SPC  1
GDATE		LDX	#DATEQ				; prompt for date
		JSR	PRINT
		JSR	FILBUF				; get date
		BSR	EVALNU				; evaluate number
		BCS	GDATE				; bad number?
		STA	MONTH				; OK so store it
		BSR	EVALNU
		BCS	GDATE
		STA	DAY
		BSR	EVALNU
		BCS	GDATE
		STA	YEAR
		RTS
EVALNU		JSR	GETDEC				; get decimal number
		BCS	EVAL02				; any good?
		LDA	OFFSET+1				; get lsb of number
		TSTB				;  test number of digits
		BEQ	EVAL01				; nothing input?
		ANDCC	#$FE				; clear carry
		RTS
EVAL01		ORCC	#$01				; set carry
EVAL02		RTS
		; SPC  1
FLEX9		FCC	"6809				; FLEX V3.01"
		FCB	$04
DATEQ		FCC	"DATE				; (MM,DD,YY)? "
		FCB	$04
		; PAG 
		ORG	$CC00
	*TTYSET parameters
TTYBS		FCB	$08				; BACK SPACE
TTYDEL		FCB	$18				; LINE DELETE
TTYEOL		FCB	$3A				; END OF LINE
TTYDP		FCB	00				; DEPTH
TTYWD		FCB	00				; WIDTH
TTYNUL		FCB	$04				; NULL COUNT
TTYTAB		FCB	00				; TAB CHARACTER
TTYBE		FCB	00				; BACK SPACE ECHO
TTYEJ		FCB	00				; PAGE EJECT
TTYPS		FCB	00				; PAUSE FLAG
TTYESC		FCB	$1B				; ESCAPE
		; SPC  1
	*SYSTEM STORAGE
SYSDRV		FCB	00
WRKDRV		FCB	00
DRVTYP		FCB	00
MONTH		FCB	00
DAY		FCB	00
YEAR		FCB	00
LSTTRM		FCB	00
USRCMD		FDB	0
BUFPTR		FDB	$C080
ESCRET		FDB	0
CURCHR		FCB	00
LSTCHR		FCB	00
CURLIN		FCB	00
OFFSET		FDB	00
TRNSFR		FCB	00
ADDRES		FDB	00
ERRTYP		FCB	00
IOFLAG		FCB	00
OUTSW		FCB	00
INSW		FCB	00
FOADDR		FDB	0
FIADDR		FDB	0
CMDFLG		FCB	00
CURCOL		FCB	00
		FCB	00
MEMEND		FDB	$BFFF
ERRVEC		FDB	0
FIECHO		FCB	$01
		FCB	00
CURTSK		FDB	TASK0
CPUTYP		FCB	04
MODE		FCB	00
		FCB	00
		FCB	00
		FCB	00
		FCB	00
		FCB	00
		FCB	00
		FCB	00
		FCB	00
XLOAD		FDB	0
XTEMP2		FDB	0,0
CMDRTN		FDB	0
CMDSTK		FDB	0
XTEMP1		FDB	0
UPCASE		FCB	$60
FIRDIG		FCB	0
CHRCNT		FCB	0
GETFLG		FCB	0
DIGCNT		FCB	0
		; PAG 
PROMPT		FCC	"+++"
		FCB	$04
QPROMT		FCC	"???"
		FCB	$04
WHAT		FCC	"WHAT?"
		FCB	$04
CANT		FCC	"CAN'T				; TRANSFER"
		FCB	$04
NOFIND		FCC	"NOT				; FOUND"
		FCB	$04
ERRMSG		FCC	"DISK				; ERROR #"
		FCB	$04
NOTRDY		FCC	"DRIVES				; NOT READY"
		FCB	$04
		; SPC  1
CMDTBL		FCC	"GET"
		FCB	00
		FDB	GET
		FCC	"MON"
		FCB	00
		FDB	MON
		FCB	00
		; SPC  1
	*BINARY TO DECIMAL TABLE
DECTBL		FDB	$2710
		FDB	$03E8
		FDB	$0064
		FDB	$000A
		; SPC  1
	*LINE PRINTER DRIVERS
		ORG	$CCC0
LPINIT		RTS
		; SPC  1
		ORG	$CCD8
LPCHK		RTS
		; SPC  1
		ORG	$CCE4
LPOUT		RTS
		; SPC  1
	*SPOOLING STATUS TABLE
		ORG	$CCF8
TASK0		FCB	$01,00				; TASK 0 STATUS
		FDB	00				; TASK 0 STACK TEMP
TASK1		FCB	00,00				; TASK 1 STATUS
		FDB	00				; TASK 1 STACK TEMP
		; PAG 
	*SYSTEM CALL JUMP TABLE
COLDS		JMP	COLD
WARMS		JMP	WARM
RENTER		JMP	RENTR
INCH		JMP	INPUT1
INCH2		JMP	INPUT1
OUTCH		JMP	OUTP1
OUTCH2		JMP	OUTP1
GETCHR		JMP	GETCH1
PUTCHR		JMP	PUTCH1
INBUFF		JMP	FILBUF
PSTRNG		JMP	PRINT
CLASS		JMP	CLASS1
PCRLF		JMP	CRLF1
NXTCH		JMP	NXTCH1
RSTRIO		JMP	RSTIO1
GETFIL		JMP	GFILE
LOAD		JMP	LOAD1
SETEXT		JMP	EXTSET
ADDBX		JMP	ADDBX1
OUTDEC		JMP	ODECM
OUTHEX		JMP	OUT2H
RPTERR		JMP	ERROR
GETHEX		JMP	GHEX
OUTADR		JMP	OUT4HX
INDEC		JMP	GETDEC
DOCMD		JMP	DOCMND
STAT		JMP	STATUS
		JMP	DUMRTS
		JMP	DUMRTS
		; PAG 
	*FLEX COLD START
COLD		LDS	#STACK
COLD01		CLR	LSTTRM
		JSR	FMSINT				; initalize file manager
		CLR	CMDFLG
		JSR	JMPINT				; get date and startup
		; SPC  1
	*WARM START
WARM		LDS	#STACK
		JSR	WINIT				; warm initalize disk drivers
		LDX	#WARMS
		STX	ESCRET				; set escape return
		LDX	#CNGTSK				; set up spooling
		STX	[SWIVEC]
		LDX	IHANDL
		STX	[IRQVEC]
		LDX	#TASK0				; set to foreground mode
		STX	CURTSK
		CLR	MODE
		CLR	GETFLG
		BSR	RSTIO1				; restore I/O
		LDA	LSTTRM				; end of line?
		CMPA	TTYEOL
		BNE	WARM01
		INC	BUFPTR+1				; bump past last char
		BRA	RENTR				; try for next command

WARM01		TST	CMDFLG				; docommd active?
		LBNE	CMDXIT				; then exit that way
		JSR	FMSCLS				; close all files
		BNE	COLD01				; go back to start
		LDX	#PROMPT				; prompt for line
		JSR	PRINT
		BSR	FILBUF				; accept input
		; SPC  1
RENTR		JSR	SKIPSP				; skip past leading space
		CMPA	#$0D				; empty line?
		BEQ	WARM01
RENTR1		LDX	#SYSFCB				; point to system fcb
		INC	DRVTYP				; use system drive
		JSR	GFILE				; get file name in fcb
		BCS	WHAT1				; bad name?
		LDX	#CMDTBL
		BSR	SEARCH				; is it local command?
		BEQ	RUN				; then do it
		LDX	USRCMD
		BEQ	LOOK				; no user table?
		BSR	SEARCH				; look in user table
		BNE	LOOK				; must be on disk
RUN		JMP	[$01,X]				; execute command
LOOK		JSR	LOADGO				; load it from disk
WHAT1		LDX	#WHAT				; point to what message
		LDA	#$15				; error #21
PERROR		STA	ERRTYP				; save error number
WHAT2		JSR	PRINT				; print error message
WHAT3		CLR	LSTTRM				; force end of line
		JMP	WARM				; back to go
		; SPC  1
	*RESTORE I\O VECTORS
RSTIO1		LDX	OUTCH2+1				; restore i\o vectors
		STX	OUTCH+1
		LDX	INCH2+1
		STX	INCH+1
		CLR	INSW				; force input from term
		CLR	OUTSW				; force output to term
		CLR	IOFLAG				; make standard i\o
		CLR	FIADDR				; turn off file i\o
		CLR	FOADDR
DUMRTS		RTS
		; SPC  1
	*SEARCH COMMAND TABLE
SEARCH		LDY	#FCBNAM				; point to name
SRCH1		LDA	,Y+				; get char from name
		CMPA	#$5F				; lower case?
		BLS	SRCH2
		SUBA	#$20				; convert to upper
SRCH2		CMPA	,X+				; match char in table?
		BNE	SRCH3
		TST	,X				; end of entry in table?
		BNE	SRCH1
		TST	,Y				; end of name?
		BEQ	SREND
SRCH3		TST	,X+				; end of entry?
		BNE	SRCH3				; look for end
		LEAX	$02,X				; skip past address
		TST	,X				; end of table?
		BNE	SEARCH				; then look again
		ANDCC	#$FB				; set not found
SREND		RTS
		; SPC  1
	*FILL INPUT BUFFER
FILBUF		LDX	#BUFFER				; point to buffer
		STX	BUFPTR				; save pointer
FILL1		JSR	GETCH1				; input character
		CMPA	TTYDEL				; is it line delete?
		BEQ	FILLDL
		CMPA	TTYBS				; is it backspace?
		BEQ	FILLBS
		CMPA	#$0D				; end of input?
		BEQ	FILLCR
		CMPA	#$0A				; is it line feed?
		BEQ	FILLF
		CMPA	#$1F				; discard all control codes
		BLS	FILL1
FILL2		CMPX	#ENDBUF				; buffer overflow?
		BEQ	FILL1				; then discard
FILLCR		STA	,X+				; save in buffer
		CMPA	#$0D				; end of line?
		BNE	FILL1
		RTS				;  bye!
FILLDL		LDX	#QPROMT				; print question marks
		BSR	PRINT
		BRA	FILBUF				; start over
FILLBS		CMPX	#BUFFER				; buffer empty?
		BEQ	FILLDL				; then can't backup
		LEAX	-$01,X				; backup once
		LDA	TTYBE				; check for backspace echo
		CMPA	#$08				; same as bs?
		BNE	BKSPC1				; no then send it
		LDA	#$20				; delete last on screen
		JSR	PUTCH4
		LDA	TTYBE				; and backup again
BKSPC1		JSR	PUTCH4				; send to terminal
		BRA	FILL1				; go for more
FILLF		LDA	#$0D				; new line on crt
		JSR	PUTCH1
		LDA	#$20				; but not in buffer
		BRA	FILL2
		; SPC  1
	*PRINT STRING
PRINT		BSR	CRLF1				; do new line
PRNT1		LDA	,X				; get character to print
		CMPA	#$04				; end of string?
		BEQ	CRLF4				; then exit
		JSR	PUTCH1				; send to crt
		LEAX	$01,X				; point to next
		BRA	PRNT1				; print next
		; SPC  1
	*TEST KEYBOARD FOR ESCAPE
ESCTST		JSR	STAT				; character ready?
		BEQ	CRLF5				; branch if not
		JSR	[INCHNE]				; input w\o echo
		CMPA	TTYESC				; is it escape?
		BNE	CRLF5				; branch if not
ESCTS1		CLR	CURLIN				; clear line count
ESCTS2		JSR	[INCHNE]				; look for character
		CMPA	TTYESC				; is it escape?
		BEQ	CRLF5				; then resume output
		CMPA	#$0D				; is it return?
		BNE	ESCTS2				; loop if not
		CLR	LSTTRM				; force end of line
		JMP	[ESCRET]				; and exit
		; SPC  1
	*CARRAGE RETURN LINE FEED
CRLF1		TST	IOFLAG				; special i\o?
		BNE	EJECT1				; then ignore ttyset
		BSR	ESCTST				; test for escape
		LDA	TTYDP				; get page size
		BEQ	EJECT1				; no page format?
		CMPA	CURLIN				; end of page?
		BHI	NEWLIN				; no then crlf
		CLR	CURLIN				; set to first line
		TST	TTYPS				; pause?
		BEQ	CRLF2				; branch if not
		BSR	ESCTS1				; wait for escape
CRLF2		PSHS	B
		LDB	TTYEJ				; get eject count
		BEQ	CRLF3				; no eject?
EJECT		BSR	EJECT1				; do 1 crlf
		DECB				;  all done?
		BNE	EJECT				; branch if not
CRLF3		PULS	B
NEWLIN		INC	CURLIN				; bump line count
EJECT1		LDA	#$0D				; return
		BSR	PUTCH1				; print it
		LDA	#$0A				; line feed
		BSR	PUTCH1				; print it
		PSHS	B
		LDB	TTYNUL				; get null count
		BEQ	NONULL				; any nulls?
NULLS		CLRA
		BSR	PUTCH1				; print null
		DECB
		BNE	NULLS				; loop if more
NONULL		PULS	B
CRLF4		ANDCC	#$FE
CRLF5		RTS
		; SPC  1
	*INPUT ONE CHARACTER
GETCH1		TST	INSW				; test input flag
		BNE	GETCH3				; use standard input
		TST	FIADDR				; file input?
		BEQ	GETCH2				; use vectored input
		BSR	INPFIL				; input from file
		TST	FIECHO				; echo enabled?
		BEQ	GETCH4				; branch if not
		TST	FOADDR				; output to file?
		BEQ	GETCH4				; dont echo if not
		BSR	PUTCH4				; echo to output
		BRA	GETCH4
GETCH2		JSR	INCH				; vectored input
		BRA	GETCH4
GETCH3		JSR	INCH2				; standard input
GETCH4		CLR	CURLIN				; clear line count
		RTS
		; SPC  1
INPFIL		STX	XTEMP1				; save x
		LDX	FIADDR				; input fcb address
		BRA	INFIL1
OUTFL1		STX	XTEMP1				; save x
		LDX	FOADDR				; output fcb address
INFIL1		JSR	FMCALL				; call file manager
		BNE	OCLOSE				; close on error
		LDX	XTEMP1				; restore x
		RTS
OCLOSE		CLR	FOADDR				; clear output fcb
		JSR	ERROR				; report falure
		JMP	WARMS				; close files on return
		; SPC  1
	*OUTPUT ONE CHARACTER
PUTCH1		TST	IOFLAG				; special i\o?
		BNE	PUTCH4				; then dont honor ttyset
		CMPA	#$1F				; is it ctrl character
		BHI	PUTCH2
		CLR	CURCOL				; clear column count
		BRA	PUTCH4				; output character
PUTCH2		INC	CURCOL				; bump column count
		PSHS	A				; save character
		LDA	TTYWD				; get line width
		BEQ	PUTCH3				; no legnth defined?
		CMPA	CURCOL				; are we at last col.
		BCC	PUTCH3				; branch if not
		JSR	CRLF1				; send new line
		INC	CURCOL				; bump column count
PUTCH3		PULS	A				; recover character
PUTCH4		PSHS	A				; save it
		TST	OUTSW				; use standard output?
		BNE	PUTCH6				; branch if so
		TST	FOADDR				; file out active?
		BEQ	PUTCH5				; branch if not
		BSR	OUTFL1				; out to file
		BRA	PUTCH7				; exit
PUTCH5		TST	FIADDR				; file input active?
		BNE	PUTCH7				; exit if so
		JSR	OUTCH				; use vectored output
		BRA	PUTCH7				; exit
PUTCH6		JSR	OUTCH2				; standard output
PUTCH7		PULS	A
		RTS				;  exit
		; SPC  1
	*OUTPUT DECIMAL NUMBER
ODECM		CLR	FIRDIG				; clear first digit flag
		STB	TRNSFR				; save leading zero flag
		LDA	#$04				; set digit count
		STA	DIGCNT
		LDD	,X				; get number to print
		LDX	#DECTBL				; point to conversion table
ODECM1		BSR	ODECM2				; convert one digit
		LEAX	$02,X				; point to next entry
		DEC	DIGCNT				; last digit?
		BNE	ODECM1				; branch if not
		TFR	B,A				; move remainder to a
		BRA	OUTHR				; print it and exit
		; SPC  1
ODECM2		CLR	CHRCNT				; initalize to zero
ODECM3		CMPD	,X				; is number less than
		BCS	ODECM4				; number in table
		SUBD	,X				; subtract once
		INC	CHRCNT				; increment count
		BRA	ODECM3				; test again
ODECM4		PSHS	A				; save number msb
		LDA	CHRCNT				; get digit
		BNE	ODECM5				; output if not zero
		TST	FIRDIG				; has any digit been printed?
		BNE	ODECM5				; print if so
		TST	TRNSFR				; test print zeros flag
		BEQ	DECRTN				; if clear skip zeros
		LDA	#$20				; output a space
		BSR	OUTIT
		BRA	DECRTN
ODECM5		INC	FIRDIG				; mark digit printed
		BSR	OUTHR				; output it
DECRTN		PULS	PC,A
		; SPC  1
	*OUTPUT 4 HEX DIGITS
OUT4HX		BSR	OUT2H				; output 2 hex
		LEAX	$01,X				; point to next
OUT2H		LDA	,X				; get hex digit
		BSR	OUTHL				; print left half
		LDA	,X				; get digit
		BRA	OUTHR				; print right half and return
		; SPC  1
OUTHL		LSRA				;  move left 4 places
		LSRA
		LSRA
		LSRA
OUTHR		ANDA	#$0F				; mask off 4 lsb
		ADDA	#$30				; add ascii bias
		CMPA	#$39				; is it greater than 9?
		BLS	OUTIT				; print if not
		ADDA	#$07				; offset to ascii "A"
OUTIT		JMP	PUTCH1				; print it
		; SPC  1
	*CLASSIFY CHARACTER TYPE
CLASS1		CMPA	#$30				; check for number
		BCS	CLASS2
		CMPA	#$39
		BLS	CLASS3
		CMPA	#$41				; check for upper case
		BCS	CLASS2
		CMPA	#$5A
		BLS	CLASS3
		CMPA	#$61				; check for lower case
		BCS	CLASS2
		CMPA	#$7A
		BLS	CLASS3
CLASS2		ORCC	#$01				; mark as not alpha-numeric
		STA	LSTTRM				; set last terminator
		RTS
CLASS3		ANDCC	#$FE				; mark as alpha-numeric
		RTS
		; SPC  1
	*GET NEXT BUFFER CHARACTER
NXTCH1		PSHS	X				; save x
		LDX	BUFPTR				; point to next character
		LDA	CURCHR				; move current to last
		STA	LSTCHR
NXTCH2		LDA	,X+				; get next
		STA	CURCHR				; make current
		CMPA	#$0D				; is it eol?
		BEQ	NXTCH3
		CMPA	TTYEOL				; is it ttyset eol?
		BEQ	NXTCH3
		STX	BUFPTR				; save pointer
		CMPA	#$20				; is it space?
		BNE	NXTCH3
		CMPA	,X				; is next a space?
		BEQ	NXTCH2				; skip spaces
NXTCH3		BSR	CLASS1				; classify character
		PULS	PC,X				; exit
		; SPC  1
	*GET FILE NAME
GFILE		LDA	#$15				; preset error number
		STA	$01,X				; put in fcb
		LDA	#$FF				; force bad drive number
		STA	$03,X				; save in fcb
		CLR	$04,X				; clear name
		CLR	$0C,X				; clear extention
		JSR	SKIPSP				; skip leading spaces
		LDA	#$08				; set name size
		STA	CHRCNT
		BSR	PARSE				; parse number
		BCS	GFILE3				; bad name?
		BNE	GFILE1				; end of name in buffer?
		BSR	PARSE				; parse name
		BCS	GFILE3				; bad name?
		BNE	GFILE1				; end of name in buffer
		CMPX	XTEMP2				; any thing in name?
		BEQ	BADNAM				; no then error
		BSR	PARSE				; parse extention
		BLS	BADNAM				; extention bad?
GFILE1		LDX	XTEMP2				; point to fcb
		TST	$04,X				; name in place
		BEQ	BADNAM
		TST	$03,X				; valid drive number?
		BPL	GFILE2
		TST	DRVTYP				; use sys or work?
		BEQ	WRKSET				; if zero use work drive
		LDA	SYSDRV				; get system drive number
		BRA	DRVSET
WRKSET		LDA	WRKDRV				; get work drive number
DRVSET		STA	$03,X				; store in fcb
GFILE2		CLR	DRVTYP				; force use of work drive
GFILE3		LDX	XTEMP2				; recover x
		RTS				;  exit
		; SPC  1
PARSE		BSR	NXTCH1				; get next character
		BCS	BADNAM				; not alpha-numeric?
		CMPA	#$39				; is it a number?
		BHI	PARSEA				; parse name if not
		LDX	XTEMP2				; point to fcb
		TST	$03,X				; drive already set?
		BPL	BADNAM				; error if so
		ANDA	#$03				; mask to valid drive number
		STA	$03,X				; set drive number
		JSR	NXTCH1				; get next character
		BCC	BADNAM				; should be "."
PARSE1		CMPA	#$2E				; is it "."?
		ANDCC	#$FE
		RTS
		; SPC  1
PARSEA		LDB	CHRCNT				; get character count
		BMI	BADNAM				; oops!
		PSHS	B				; save count
		SUBB	#$05				; set up for extention
		STB	CHRCNT
		PULS	B				; recover count
PARS1		CMPA	UPCASE				; is char. lower case?
		BCS	PARS2				; branch if not lower case
		SUBA	#$20				; map lower to upper
PARS2		STA	$04,X				; save in fcb
		LEAX	$01,X				; point to next
		DECB				;  dec character count
		JSR	NXTCH1				; get next char
		BCC	PARS3				; is it alpha-numeric?
		CMPA	#$2D				; is it "-"?
		BEQ	PARS3
		CMPA	#$5F				; is it "_"?
		BNE	CLRNAM				; clear rest of name if not
PARS3		TSTB				;  last character?
		BNE	PARS1				; loop if not
BADNAM		ORCC	#$01				; set error flag
		RTS
CLRNAM		TSTB
		BEQ	PARSE1				; end of name?
		CLR	$04,X				; clear it
		LEAX	$01,X				; point to next
		DECB				;  dec count
		BRA	CLRNAM				; loop
		; SPC  1
SKIPSP		STX	XTEMP2				; save x
		LDX	BUFPTR				; point to line buffer
SKIP1		LDA	,X				; get next character
		CMPA	#$20				; is it a space?
		BNE	SKIP2				; exit if not
		LEAX	$01,X				; point to next
		BRA	SKIP1				; keep checking
SKIP2		STX	BUFPTR				; save new buffer pointer
		LDX	XTEMP2				; restore x
		RTS				;  exit
		; SPC  1
	*SET EXTENTION
EXTSET		PSHS	Y,X				; save registers
		LDB	$0C,X				; test current extention
		BNE	EXSET2				; allready set?
		LDY	#EXTTBL				; point to extention table
		CMPA	#$0B				; out of range?
		BHI	EXSET2
		LDB	#$03				; bytes per extention
		MUL
		LEAY	B,Y				; point to string
		LDB	#$03				; bytes to move
EXSET1		LDA	,Y+				; get character
		STA	$0C,X				; save in fcb
		LEAX	$01,X				; point to next
		DECB				;  dec byte count
		BNE	EXSET1				; move another if not done
EXSET2		PULS	PC,Y,X				; exit
		; SPC  1
EXTTBL		FCC	"BINTXTCMDBASSYSBAKSCR"
		FCC	"DATBACDIRPRTOUT"
		; SPC  1
	*GET HEX NUMBER
GHEX		JSR	CLROFF				; clear result
GHEX1		JSR	NXTCH1				; get next char.
		BCS	RESULT				; done?
		BSR	ISHEX				; check for hex
		BCS	GTERM				; find next terminator
		PSHS	B				; save count
		LDB	#$04				; get shift count
GHEX2		ASL	OFFSET+1				; shift result left
		ROL	OFFSET
		DECB				;  dec shift count
		BNE	GHEX2				; done shifting?
		PULS	B				; restore digit count
		ADDA	OFFSET+1				; add char to result
		STA	OFFSET+1
		INCB				;  bump count
		BRA	GHEX1				; loop for more
		; SPC  1
GTERM		JSR	NXTCH1				; loop for next term.
		BCC	GTERM
		RTS				;  exit
		; SPC  1
RESULT		LDX	OFFSET				; get result
		ANDCC	#$FE				; clear errors
		RTS
		; SPC  1
ISHEX		SUBA	#$47				; check for >F
		BPL	NOTHEX
		ADDA	#$06
		BPL	ISHEX1				; is <F and >9
		ADDA	#$07				; correct for ascii gap
		BPL	NOTHEX				; error not hex
ISHEX1		ADDA	#$0A				; add for final result
		BMI	NOTHEX				; error not hex
		ANDCC	#$FE
		RTS
NOTHEX		ORCC	#$01				; set error flag
		RTS
		; SPC  1
	*GET DECIMAL NUMBER
GETDEC		JSR	CLROFF				; clear result
GDEC1		JSR	NXTCH1				; get next char.
		BCS	RESULT				; oops not numeric
		CMPA	#$39				; is it a number
		BHI	GTERM				; oops not numeric
		ANDA	#$0F				; mask to 4 lsb
		PSHS	B				; save count
		PSHS	A				; save current number
		LDD	OFFSET				; get result
		ASLB				;  multiply X10
		ROLA
		ASLB
		ROLA
		ASLB
		ROLA
		ADDD	OFFSET
		ADDD	OFFSET
		ADDB	,S+				; add current to result
		ADCA	#00				; propagate carry
		STD	OFFSET				; save as result
		PULS	B				; restore count
		INCB
		BRA	GDEC1				; loop for more
		; SPC  1
	*LOAD FILE
LOAD1		CLR	TRNSFR				; clear address flag
LOAD1A		BSR	LDBYTE				; get byte from file
		CMPA	#$02				; is it start of record?
		BEQ	LOAD2
		CMPA	#$16				; is it transfer record?
		BNE	LOAD1A				; LOOP IF NOT
		BSR	LDBYTE				; get address MSB
		STA	ADDRES				; save it
		BSR	LDBYTE				; get address LSB
		STA	ADDRES+1				; save it
		LDA	#$01				; set transfer flag
		STA	TRNSFR
		BRA	LOAD1A				; load some more
LOAD2		BSR	LDBYTE				; get load address MSB
		TFR	A,B				; save it
		BSR	LDBYTE				; get load address LSB
		EXG	A,B				; correct order
		ADDD	OFFSET				; add in load offset
		STD	XLOAD				; save load address
		BSR	LDBYTE				; get byte count
		TFR	A,B				; save it
		TSTA				;  count=0?
		BEQ	LOAD1A				; then get next record
LOAD3		BSR	LDBYTE				; get data byte
		LDX	XLOAD				; get pointer
		STA	,X+				; save byte in ram
		STX	XLOAD				; store pointer
		DECB				;  dec byte count
		BNE	LOAD3				; record done?
		BRA	LOAD1A				; loop for more records
		; SPC  1
LDBYTE		LDX	#SYSFCB				; point to fcb
		JSR	FMCALL				; call file manager
		BEQ	ERLD1				; no error?
		LDA	$01,X				; get error number
		CMPA	#$08				; is it end of file?
		BNE	LDERR				; then its fatal
		LEAS	$02,S				; clean up stack
LDCLOS		LDA	#$04				; close file
		STA	,X				; put in fcb
		JSR	FMCALL				; call fms
		BNE	LERXIT				; another error?
ERLD1		ANDCC	#$FE				; clear error
		RTS				;  exit
		; SPC  1
LDERR		STA	ERRTYP				; save error number
		CMPA	#$04				; is it file not found
		BNE	LERXIT				; report error
		ORCC	#$01				; set error flag
		RTS				;  exit
LERXIT		BSR	ERROR				; report error
		JMP	WHAT3				; return to main loop
		; SPC  1
	*GET BINARY FILE
GET		LDA	#00				; binary file type
		BSR	OPENRD				; open for read
		BCS	GETERR				; open error?
		BSR	CLROFF				; clear load offset
		INC	GETFLG				; mark use of loader
		BSR	LOAD1				; load file
		BRA	GET				; get next file
		; SPC  1
CLROFF		CLRA				;  clear load offset
		CLRB
		STD	OFFSET
		RTS
		; SPC  1
GETERR		LDB	GETFLG				; is it first use of get
		LBEQ	WHAT1				; then print what
		JMP	WARMS				; else goto flex
		; SPC  1
LOADGO		LDA	#$02				; set command file
		BSR	OPNRD1				; open file
		BSR	CLROFF				; clear offset
		JSR	LOAD1				; load file
		LDB	TRNSFR				; transfer address valid?
		BEQ	ADRERR				; branch if not
		JMP	[ADDRES]				; go to it
ADRERR		LDX	#CANT				; cant transfer
		LDA	#$81
		JMP	PERROR				; print error message
		; SPC  1
OPENRD		PSHS	A				; save a
		LDX	#SYSFCB				; point to sys fcb
		JSR	GFILE				; get file name
		PULS	A				; recover ext type
		BCS	ERSPEC				; bad name?
OPNRD1		LDX	#SYSFCB
		JSR	EXTSET				; set extention
		LDX	#SYSFCB
		LDA	#$01				; open for read
		STA	,X
		JSR	LDBYTE				; call fms
		LBCS	ERROR9				; error?
		LDA	#$FF				; set to binary type
		STA	$3B,X				; put in fcb
		RTS
		; SPC  1
ERSPEC		LDA	LSTTRM				; check last terminator
		CMPA	#$0D				; is it return
		BEQ	ERSPC2				; then exit
		CMPA	TTYEOL				; is it tty eol
		LBNE	WHAT1				; abort rest of line if not
ERSPC2		ORCC	#$01				; set error flag
		RTS
		; SPC  1
	*REPORT ERROR
ERROR		PSHS	Y,X
		LDA	$01,X				; get error number
		STA	ERRTYP				; save it
		BEQ	ERROR4				; no error?
		JSR	RSTIO1				; restore i\o vectors
		LDY	ERRVEC				; alternate error file?
		BNE	ERROR1				; use alternate
		CMPA	#$10				; error=not ready?
		BEQ	ERROR5				; then print it
		LDY	#ERRORS				; point to error file
ERROR1		LDX	#SYSFCB
		TST	$02,X				; file open?
		BEQ	ERROR2				; if open then close it
		LDA	#$04				; close file
		STA	,X
		JSR	FMCALL				; call for close
		BNE	ERROR3				; fatal error?
ERROR2		LDX	#ERRFCB				; point to fake fcb
		LDB	#$0B				; move count
		BSR	ERROR8				; move name into fcb
		LDX	#SYSFCB
		LDA	SYSDRV				; force system drive
		STA	$03,X
		LDA	#$01				; open for read
		STA	,X
		JSR	FMCALL				; call fms
		BNE	ERROR3				; fatal error
		LDA	ERRTYP				; get error number
		DECA				;  start at 0
		ASRA				;  divide X4
		ASRA
		INCA				;  records start at 1
		CLR	$20,X				; clear msb of record
		STA	$21,X				; set lsb
		LDA	#$15				; random read
		STA	,X
		JSR	FMCALL				; get record from file
		BEQ	ERROR6				; no errors on read?
ERROR3		LDX	#ERRMSG				; point to error message
		JSR	PRINT				; print it
		LDX	XTEMP2
		LDA	ERRTYP				; get error number
		STA	$01,X
		CLR	,X
		CLRB				;  turn off leading zeros
		JSR	ODECM				; print decimal number
ERROR4		PULS	PC,Y,X				; exit
ERROR5		LDX	#NOTRDY				; point to not ready message
		JSR	PRINT				; print it
		BRA	ERROR4
		; SPC  1
ERROR6		JSR	CRLF1				; new line
		LDX	#SYSFCB
		LDA	ERRTYP				; get error number
		DECA				;  start at 0
		ANDA	#$03				; mask for errors per record
		LDB	#$3F				; bytes per error msg
		MUL				;  index into sector
		ADDB	#$04				; correct for start of sector
		STB	$22,X				; set read byte index
ERROR7		JSR	FMCALL				; read byte from file
		BNE	ERROR3				; fatal error
		JSR	PUTCH1				; print it
		CMPA	#$0D				; is it end of message?
		BNE	ERROR7				; then read more
		LDA	#$04				; close file
		STA	,X
		JSR	FMCALL				; call fms
		BRA	ERROR4				; exit
		; SPC  1
ERROR8		PSHS	Y,X
		JMP	EXSET1				; do block move
		; SPC  1
ERROR9		LDX	#NOFIND				; point to not found
		JMP	WHAT2				; print it and exit
		; SPC  1
	*CALL DOS AS A SUBROUTINE
DOCMND		PULS	B,A				; get return address
		STD	CMDRTN				; save it
CMND1		STS	CMDSTK				; save stack
		CLR	ERRTYP
		INC	CMDFLG				; mark docmd active
		JMP	RENTR1				; goto flex
CMDXIT		CLR	CMDFLG				; clear docmd flag
		LDS	CMDSTK				; recover stack
		LDB	ERRTYP				; get error if any
		JMP	[CMDRTN]				; exit
		; SPC  1
	*ADD B TO X
ADDBX1		ABX				;  what can i say
		RTS
		; SPC  1
	*EXIT TO MONITOR
MON		TST	TASK1				; spooling active?
		BNE	MON1				; then cant goto mon
		JMP	[MONTOR]
MON1		LDX	#SYSFCB
		LDA	#$1B				; set error number
		STA	$01,X				; put in fcb
		JSR	ERROR				; print error
		JMP	WARM				; back to flex
		; SPC  1
	*FILE NAME OF ERROR FILE
ERRORS		FCC	"ERRORS"
		FCB	00
		FCB	00
		FCC	"SYS"
		; SPC  1
INPUT1		EQU	0
OUTP1		EQU	0
STATUS		EQU	0
		; SPC  1
	*INDIRECT JUMP TABLE
		ORG	$D3E5
INCHNE		RMB	2
IHANDL		RMB	02
SWIVEC		RMB	02
IRQVEC		RMB	08
MONTOR		RMB	02
INTACA		RMB	02
STAVEC		RMB	02
OUTVEC		RMB	02
INVEC		RMB	02
		; SPC  1
JMPINT		JMP	INIT				; goto initalize routine
		; SPC  1
FMSINT		EQU	$D400
FMSCLS		EQU	$D403
FMCALL		EQU	$D406
WINIT		EQU	$DE18
		; SPC  2
