;;;; TODO: call insv/remv direct rather than through OSBYTE for OSWORD_7
;;;
;;;
;;;TIMER1VAL	:= 10000-2	; value for 100Hz
;;;
;;;		; TODO at boot look in sound's workspace and decide whether on / off / samples from there
;;;		; - will require heap to persist over breaks - user option
;;;
sound_boot	rts
;;;sound_boot:	jsr	jimSetDEV_either		; either Blitter or Paula don't care which here
;;;		bcc	@ok1
;;;		rts
;;;@ok1:		jsr	jimPageSoundWorkspace
;;;		lda	#0
;;;		sta	JIM+SNDWKSP_SOUNDFLAGS
;;;
;;;		; clear sample table
;;;		jsr	jimPageSamTbl
;;;		ldx	#0
;;;		lda	#$FF
;;;@l:		sta	JIM,X
;;;		inx
;;;		bne	@l
;;;		rts	
;;;
;;;
cmdSound		rts
;;;cmdSound:	; initialize user via timer 1 in free run, with interrupts
;;;		; mask out interrupts to get an unknown interrupt service call
;;;		jsr	CheckEitherPresentBrk
;;;		jsr	jimPageSoundWorkspace
;;;
;;;		lda	JIM+SNDWKSP_SOUNDFLAGS
;;;		bpl	@notalready
;;;		jmp	@already
;;;@notalready:	lda	#SCR_FLAG_SND_EN
;;;		sta	JIM+SNDWKSP_SOUNDFLAGS
;;;
;;;
;;;		; initialise hardware
;;;		jsr	jimPageChipset
;;;		lda	#$FF
;;;		sta	jim_DMAC_SND_MA_VOL
;;;		sta	jim_DMAC_SND_SEL
;;;		ldx	jim_DMAC_SND_SEL
;;;		inx
;;;@sch1:		txa
;;;		pha					; number of channels or 0 if read FF
;;;
;;;		; silence all channels
;;;@ls1:		dex
;;;		stx	jim_DMAC_SND_SEL
;;;		lda	#0
;;;		sta	jim_DMAC_SND_DATA
;;;		sta	jim_DMAC_SND_VOL
;;;		sta	jim_DMAC_SND_STATUS
;;;		cpx	#0
;;;		bne	@ls1
;;;
;;;
;;;
;;;		pla
;;;		ldx	#<str_SOUND_start
;;;		ldy	#>str_SOUND_start
;;;		jsr	PrintMsgXYThenHexNyb
;;;
;;;		; initialise sound variables
;;;		jsr	jimPageSoundWorkspace
;;;
;;;		; first set up buffers all with FF
;;;		lda	#$FF
;;;		ldx	#SND_NUM_CHANS-1
;;;@l1:		sta	JIM+SNDWKSP_BUF_BUSY_0,X
;;;		dex
;;;		bpl	@l1
;;;		lda	#SND_BUF_LEN-1
;;;		ldx	#(SND_NUM_CHANS*2)-1
;;;@l2:		sta	JIM+SNDWKSP_BUF_OUT_0,X
;;;		dex
;;;		bpl	@l2
;;;
;;;		; zero all rest of SOUND vars
;;;		ldx	#SNDWKSP_VAR_END-SNDWKSP_VAR_START
;;;		lda	#0
;;;@l3:		sta	JIM+SNDWKSP_VAR_START-1,X
;;;		dex
;;;		bne	@l3
;;;
;;;
;;;
;;;		; capture INSV, REMV, CNPV
;;;		; first a sanity check - if any of these are already extended vectors refuse to continue
;;;		ldx	#$FF
;;;		cmp	BYTEV+1
;;;		beq	@brkExtInUse	
;;;		cmp	INSV+1
;;;		beq	@brkExtInUse
;;;		cmp	REMV+1
;;;		beq	@brkExtInUse
;;;		cmp	CNPV+1
;;;		bne	@ExtNotInUse
;;;@brkExtInUse:	M_ERROR
;;;		.byte	$FF
;;;		.byte	"Extended vectors busy",0
;;;
;;;@EXTVECS:	.word	EXTVEC_ENTER_INSV
;;;		.word	EXTVEC_ENTER_REMV
;;;		.word	EXTVEC_ENTER_CNPV
;;;		.word	EXTVEC_ENTER_BYTEV
;;;@MINE:		.word	SOUND_INSV
;;;		.word	SOUND_REMV
;;;		.word	SOUND_CNPV
;;;		.word	SOUND_BYTEV
;;;@NORMVECS:	.word	INSV
;;;		.word	REMV
;;;		.word	CNPV
;;;		.word	BYTEV
;;;@EXTPTRS:	.word	EXT_INSV
;;;		.word	EXT_REMV
;;;		.word	EXT_CNPV
;;;		.word	EXT_BYTEV
;;;
;;;@NUM_VECS:=	4
;;;
;;;
;;;@ExtNotInUse:	
;;;		php
;;;		sei
;;;
;;;		; save old vectors
;;;		ldx	#(@NUM_VECS-1)*2
;;;		ldy	#0
;;;@vsl:		
;;;		; get address of normal vector into zp_tmp_ptr
;;;		lda	@NORMVECS,X
;;;		sta	zp_tmp_ptr
;;;		lda	@NORMVECS+1,X
;;;		sta	zp_tmp_ptr+1
;;;
;;;		; get old contents and put in our save pointer
;;;		lda	(zp_tmp_ptr),Y
;;;		sta	JIM+SNDWKSP_OLDINSV,X
;;;		iny
;;;		lda	(zp_tmp_ptr),Y
;;;		sta	JIM+SNDWKSP_OLDINSV+1,X
;;;
;;;		lda	@EXTVECS+1,X			; and point to extended vectors
;;;		sta	(zp_tmp_ptr),Y
;;;		dey
;;;		lda	@EXTVECS+0,X			
;;;		sta	(zp_tmp_ptr),Y
;;;
;;;		;get address of extended vector pointer in zp_tmp_ptr
;;;		lda	@EXTPTRS,X
;;;		sta	zp_tmp_ptr
;;;		lda	@EXTPTRS+1,X
;;;		sta	zp_tmp_ptr+1
;;;
;;;		;point at our routine and rom
;;;		lda	@MINE,X
;;;		sta	(zp_tmp_ptr),Y
;;;		iny
;;;		lda	@MINE+1,X
;;;		sta	(zp_tmp_ptr),Y
;;;		iny
;;;		lda	zp_mos_curROM
;;;		sta	(zp_tmp_ptr),Y
;;;
;;;		dey
;;;		dey
;;;		dex
;;;		dex	
;;;		bpl	@vsl
;;;
;;;
;;;		; set ACR for continuous T1 interrupts
;;;		lda	sheila_USRVIA_acr
;;;		and	#VIA_ACR_T1_MASK
;;;		ora	#VIA_ACR_T1_CONT
;;;		sta	sheila_USRVIA_acr		
;;;
;;;		; set T0 period
;;;		lda	#<TIMER1VAL
;;;		sta	sheila_USRVIA_t1ll
;;;		lda	#>TIMER1VAL
;;;		sta	sheila_USRVIA_t1ch
;;;
;;;		; clear pending IRQ
;;;		lda	#VIA_IFR_BIT_T1+VIA_IFR_BIT_ANY
;;;		sta	sheila_USRVIA_ifr
;;;		; enable interrupt
;;;
;;;		sta	sheila_USRVIA_ier
;;;
;;;		plp
;;;@already:	rts
;;;
;;;
;;;brkSoundNotEn:	M_ERROR
;;;		.byte	$FF
;;;		.byte	"Sound not enabled", 0
;;;
;;;brkEmpty:	M_ERROR
;;;		.byte	$FF
;;;		.byte	"Empty",0
;;;
;;;brkTooBig:	M_ERROR
;;;		.byte	$FF
;;;		.byte	"Too big",0
;;;
;;;brkFileNotFound:
;;;		M_ERROR
;;;		.byte	ERR_FILE_NOT_FOUND
;;;		.byte	"File not found",0
;;;
;;;SLSCR_FNPTR	:= 	SNDWKDP_SCRATCH8+0
;;;SLSCR_REPL	:=	SNDWKDP_SCRATCH8+2
;;;SLSCR_HANDLE	:=	SNDWKDP_SCRATCH8+4
;;;SLSCR_NUM	:=	SNDWKDP_SCRATCH8+5
;;;SLSCR_HASREPL	:=	SNDWKDP_SCRATCH8+6
;;;SLSCR_NEGREP	:=	SNDWKDP_SCRATCH8+7
;;;
;;;
cmdSoundSamLoad	rts
;;;cmdSoundSamLoad:
;;;		; load a simple into chip ram allocated from the heap
;;;		jsr	CheckEitherPresentBrk
;;;		jsr	jimPageSoundWorkspace		; page in scratch space bottom
;;;
;;;		lda	JIM+SNDWKSP_SOUNDFLAGS
;;;		bpl	brkSoundNotEn
;;;
;;;
;;;@bp:		jsr	SkipSpacesPTR
;;;		cmp	#$D
;;;		bne	@s1
;;;		beq	@badcmd				; no filename!
;;;@s1:		clc
;;;		tya
;;;		adc	zp_mos_txtptr
;;;		sta	JIM+SLSCR_FNPTR			; store pointer to filename for OSFILE later
;;;		lda	zp_mos_txtptr + 1
;;;		adc	#0
;;;		sta	JIM+SLSCR_FNPTR+1		; store pointer to filename for OSFILE later
;;;		dey
;;;@lp1:		iny
;;;		lda	(zp_mos_txtptr),Y		
;;;		cmp	#' '
;;;		bcc	@badcmd
;;;		bne	@lp1
;;;		beq	@s3
;;;
;;;@badcmd:	jmp	brkBadCommand		
;;;
;;;@s3:
;;;;		don't terminate - it will kill a bbc basic program!
;;;;		lda	#$D
;;;;		sta	(zp_mos_txtptr),Y		; overwrite ' ' with $D to terminate filename
;;;		iny		
;;;
;;;		jsr	ParseHex
;;;		bcs	@badcmd
;;;		lda	zp_trans_acc
;;;		beq	@badcmd
;;;		sec
;;;		sbc	#1				; rebase to 0..31
;;;		pha
;;;		and	#$E0
;;;		bne	@badcmd
;;;		pla
;;;		and	#$1F				; max samples
;;;		asl	A
;;;		asl	A
;;;		asl	A
;;;		sta	JIM+SLSCR_NUM			; sam no * 8
;;;
;;;		jsr	SkipSpacesPTR
;;;		cmp	#' '
;;;		php
;;;
;;;		jsr	zeroAcc
;;;		lda	#0
;;;		sta	JIM+SLSCR_HASREPL
;;;		plp
;;;		bcc	@s2
;;;
;;;		lda	(zp_mos_txtptr),Y
;;;		eor	#'-'
;;;		sta	JIM+SLSCR_NEGREP		; if negative repeat offset is subtracted from length
;;;		bne	@snom
;;;		iny
;;;@snom:		jsr	ParseHex
;;;		bcs	@badcmd
;;;		dec	JIM+SLSCR_HASREPL
;;;@s2:		; store in scratch
;;;		lda	JIM+SLSCR_NEGREP
;;;		lda	zp_trans_acc
;;;		sta	JIM+SLSCR_REPL
;;;		lda	zp_trans_acc+1
;;;		sta	JIM+SLSCR_REPL+1
;;;
;;;		; check to see if there's already a sample with this number and if there is free it
;;;		lda	JIM+SLSCR_NUM
;;;		tax
;;;		pha
;;;		jsr	jimPageSamTbl
;;;		ldy	JIM+SAMTBLOFFS_BASE+1,X		; check for empty
;;;		bmi	@nosamthere
;;;		lda	JIM+SAMTBLOFFS_BASE,X
;;;		tax
;;;		lda	#OSWORD_OP_FREE
;;;		jsr	allocfreexy
;;;		pla
;;;		pha
;;;		tax
;;;		lda	#$FF
;;;		sta	JIM+SAMTBLOFFS_BASE+1,X		; mark empty in case we blob later
;;;@nosamthere:	pla
;;;		jsr	jimPageSoundWorkspace
;;;
;;;		; attempt to open the file
;;;		ldx	JIM+SLSCR_FNPTR
;;;		ldy	JIM+SLSCR_FNPTR+1
;;;		lda	#OSFIND_OPENIN
;;;		jsr	OSFIND
;;;		ora	#$00
;;;		bne	@s5
;;;@brkfilenotfound:jmp	brkFileNotFound
;;;@s5:
;;;
;;;		sta	JIM+SLSCR_HANDLE
;;;
;;;		; get file extent
;;;		tay
;;;		lda	#OSARGS_EXT
;;;		ldx	#zp_trans_acc
;;;		jsr	OSARGS
;;;
;;;		; zp_trans_acc should now contain file size
;;;		; check for 0
;;;		jsr	isAcc0
;;;		bne	@skemp
;;;@brkempty:	jmp	brkEmpty
;;;@skemp:
;;;		; store length and repl
;;;		ldx	JIM+SLSCR_NUM
;;;
;;;		; subtract REPL from LEN if - was specified
;;;		lda	JIM+SLSCR_NEGREP
;;;		bne	@snomin
;;;		bit	JIM+SLSCR_HASREPL
;;;		bpl	@snomin
;;;		sec
;;;		lda	zp_trans_acc
;;;		sbc	JIM+SLSCR_REPL
;;;		sta	JIM+SLSCR_REPL
;;;		lda	zp_trans_acc+1
;;;		sbc	JIM+SLSCR_REPL+1
;;;		sta	JIM+SLSCR_REPL+1
;;;
;;;
;;;@snomin:	lda	JIM+SLSCR_REPL
;;;		ldy	JIM+SLSCR_REPL+1
;;;		rol	JIM+SLSCR_HASREPL
;;;		; store sample base in sample table
;;;		jsr	jimPageSamTbl
;;;		ror	JIM+SAMTBLOFFS_FLAGS,X
;;;		sta	JIM+SAMTBLOFFS_REPL,X
;;;		tya
;;;		sta	JIM+SAMTBLOFFS_REPL+1,X
;;;		lda	zp_trans_acc
;;;		sta	JIM+SAMTBLOFFS_LEN,X	
;;;		lda	zp_trans_acc+1
;;;		sta	JIM+SAMTBLOFFS_LEN+1,X
;;;		jsr	jimPageSoundWorkspace
;;;
;;;		; round to a number of pages
;;;		lda	zp_trans_acc
;;;		beq	@sround
;;;		inc	zp_trans_acc+1
;;;		bne	@sround
;;;		inc	zp_trans_acc+2
;;;		bne	@sround
;;;		inc	zp_trans_acc+3
;;;@sround:	
;;;		; check for huge file
;;;		lda	zp_trans_acc+3
;;;		ora	zp_trans_acc+2
;;;		bne	@brktoobig
;;;
;;;		; stash file handle for later
;;;		lda	JIM+SLSCR_HANDLE
;;;		sta	zp_trans_acc+3
;;;
;;;		; alloc on heap
;;;		; make room on stack for OSWORD
;;;
;;;		lda	#OSWORD_OP_ALLOC
;;;		ldx	zp_trans_acc+1
;;;		ldy	#0
;;;		jsr	allocfreexy
;;;		inx
;;;		bne	@bb2
;;;		iny	
;;;		beq	@brktoobig
;;;		dey
;;;@bb2:		dex
;;;		txa
;;;
;;;		ldx	JIM+SLSCR_NUM
;;;		; store sample base in sample table
;;;		jsr	jimPageSamTbl
;;;		sta	JIM+SAMTBLOFFS_BASE,X
;;;		pha
;;;		tya
;;;		sta	JIM+SAMTBLOFFS_BASE+1,X
;;;		pla
;;;
;;;		; now load the file 
;;;		sty	fred_JIM_PAGE_HI
;;;		sta	fred_JIM_PAGE_LO
;;;;;		; TODO: use OSGBPB if proves too slow but where to put buffer? Wait for Hazel?
;;;;;		ldx	#0
;;;;;		ldy	zp_trans_acc+3
;;;;;@here:
;;;;;@loadlp:	jsr	OSBGET
;;;;;		bcs	@eof
;;;;;		sta	JIM,X
;;;;;		inx
;;;;;		bne	@loadlp
;;;
;;;		
;;;@loadlp:	; make GBPB block on stack
;;;		ldx	#12
;;;@mkblklp:	lda	@loadgbpbblock-1,X
;;;		pha
;;;		dex
;;;		bne	@mkblklp
;;;		lda	zp_trans_acc+3
;;;		pha				; handle
;;;		tsx
;;;		inx
;;;		ldy	#1			; point at block on stack
;;;		lda	#OSGBPB_READ_NOPTR
;;;		jsr	OSGBPB
;;;
;;;		; unstack and get number of bytes xfered
;;;		tsx
;;;		lda	$106,X
;;;		ora	$107,X
;;;		sta	$10D,X
;;;		txa
;;;		clc
;;;		adc	#12
;;;		tax
;;;		txs
;;;
;;;		pla
;;;		bne	@eof
;;;
;;;		lda	#'.'
;;;		jsr	OSWRCH
;;;		inc	fred_JIM_PAGE_LO
;;;		bne	@loadlp
;;;		inc	fred_JIM_PAGE_HI
;;;		bne	@loadlp
;;;
;;;@eof:		jsr	@closef
;;;		jsr	OSNEWL
;;;		rts
;;;
;;;@loadgbpbblock:	.dword	$FFFFFD00	; JIM
;;;		.dword	$00000100	; count
;;;
;;;
;;;@closef:	jsr	jimPageSoundWorkspace
;;;		ldy	JIM+SLSCR_HANDLE
;;;		lda	#OSFIND_CLOSE
;;;		jmp	OSFIND
;;;
;;;@brktoobig:	jsr	@closef
;;;		jmp	brkTooBig
;;;
;;;		; on entry A = &10 or &11 for Alloc/Free, XY contains length or base
;;;		; returns in X/Y
;;;allocfreexy:	
;;;		pha
;;;		tya
;;;		pha
;;;		txa
;;;		pha
;;;
;;;		; make room on stack for OSWORD
;;;
;;;		ldx	#5
;;;		txa
;;;		jsr	StackAllocX
;;;
;;;		sta	$100,X			; # bytes in
;;;		sta	$101,X			; # bytes out
;;;		lda	$105,X			; X on stack above our alloc
;;;		sta	$103,X
;;;		lda	$106,X			; Y on stack above our alloc
;;;		sta	$104,X
;;;		lda	$107,X			; A on stack above our alloc
;;;		sta	$102,X
;;;		txa
;;;		pha				; save X we'll need it back		
;;;		ldy	#$01			; it's on the stack
;;;		lda	#OSWORD_BLTUTIL
;;;		jsr	OSWORD
;;;		pla
;;;		tax
;;;		lda	$104,X
;;;		sta	$106,X
;;;		lda	$103,X
;;;		sta	$105,X
;;;		jsr	StackFree
;;;		pla	
;;;		tax
;;;		pla
;;;		tay
;;;		pla
;;;		rts
;;;
;;;
;;;
;;;; Process sound osword
;;;; Channel parameter is of the normal MOS form, except with &4000 added
;;;; Volume high byte contains a sample #
;;;; TODO: there's some juggling of X to convert between buffer number and internal number
;;;;       move buffers so that they're all > &14 from start of JIM to allow coded in -$14 without
;;;;	page boundary crossing nonsense
;;;
;;;OSWORD_SOUND_BASE := $40
;;;OSWORD_SOUND_MASK := $E0
;;;
;;;
;;;_LE8C9:		lda	(zp_mos_OSBW_X),Y		; get byte
;;;		and	#$1F				; mask out $40 for paula select
;;;		cmp	#$10				; is it greater than 15, if so set carry
;;;		and	#$07				; and 7 to clear bits 3-7		(8 channels!)
;;;		iny					; increment Y
;;;		rts					; and exit
;;;
;;;
sound_OSWORD_SOUND
		rts
;;;		ldy	#1
;;;		lda	(zp_mos_OSBW_X),Y	; get channel #hi byte check for our allocation
;;;		and	#OSWORD_SOUND_MASK
;;;		cmp	#OSWORD_SOUND_BASE
;;;		beq	@sk1
;;;@out:		jmp	ServiceOut
;;;@sk1:		
;;;		jsr	jimSetDEV_either
;;;		bcs	@out
;;;		; check BLSOUND is enabled
;;;		jsr	jimPageSoundWorkspace
;;;		bit	JIM+SNDWKSP_SOUNDFLAGS
;;;		bpl	@out
;;;
;;;		dey					; Point back to channel low byte
;;;		jsr	_LE8C9				; Get Channel 0-7, and Cy if >=&10 for Flush (note: 8chan)
;;;		php
;;;		clc
;;;		adc	#SND_BUFFER_NUMBER_0		; Convert to buffer number $14-1C
;;;		tax
;;;		plp					; TODO: not sure why this is needed interrupts somewhere?		
;;;		bcc	_BE848				; If not Flush, skip past
;;;		jsr	_LE1AE				; Flush buffer
;;;		ldy	#$01				; Point back to channel high byte
;;;
;;;_BE848:		jsr	_LE8C9				; Get Sync 0-7, and Cy if >=&10 for Hold (note: 8channels)
;;;		sta	zp_mos_OS_wksp2			; Save Sync in &FA
;;;		php					; Stack flags
;;;		ldy	#$06				
;;;		lda	(zp_mos_OSBW_X),Y		; Get Duration byte
;;;		pha					; and stack it
;;;		ldy	#$04				
;;;		lda	(zp_mos_OSBW_X),Y		; Get pitch byte
;;;		pha					; and stack it
;;;		ldy	#$02				; 
;;;		lda	(zp_mos_OSBW_X),Y		; Get amplitude/envelope byte
;;;		rol					; Move Hold into bit 0
;;;
;;;		; AAAA AAAH
;;;
;;;		sec					; set carry
;;;		sbc	#$02				; subract 2
;;;		; aaaa aaaH
;;;		asl					; multiply by 8
;;;		asl	
;;;		asl					; DB: note for 8 channels the amplitude is shifted left
;;;							; 1 more place so the env/not env flag is in carry
;;;							; which will live in bit 7 of the sample number (extra)
;;;							; byte
;;;		; aaaa H---				; 
;;;		ora	zp_mos_OS_wksp2			; add S byte (0-7)
;;;		; aaaa HSSS
;;;
;;;		sta	zp_mos_OS_wksp2			; DB: save the amp/env/hold/sync byte
;;;		php					; stack envelope flag
;;;
;;;		; DB: new extra byte for sample # and envelope flag
;;;		iny
;;;		lda	(zp_mos_OSBW_X),Y		; Get amplitude/high byte
;;;		; to maintain compatibility if the high byte is 0 or $FF then "default" sample #1
;;;		beq	@defsam
;;;		cmp	#$FF
;;;		bne	@notdefsam
;;;@defsam:	lda	JIM+SNDWKSP_DEF_SAM-SND_BUFFER_NUMBER_0,X
;;;		bmi	@sam
;;;		lda	#$01
;;;@notdefsam:	sec
;;;		sbc	#1				; convert to 0 based number
;;;@sam:		and	#31		
;;;		asl	A
;;;		plp
;;;		ror	A				; get envelope flag into top bit
;;;@notamp:	pha
;;;		lda	zp_mos_OS_wksp2
;;;
;;;
;;;		jsr	_BUFFER_SAVE			; Insert into buffer
;;;		bcc	_BE887				; Buffer not full, jump to insert the rest
;;;_BE869:		pla					; DB: extra pull
;;;		pla					; Drop stacked pitch
;;;		pla					; Drop stacked duration
;;;		plp					; Restore flags
;;;		jmp	ServiceOutA0
;;;
;;;_BE887:		sec					; Set carry
;;;		ror	JIM+SNDWKSP_QUEUE_OCC-SND_BUFFER_NUMBER_0,X		
;;;							; Set bit 7 of channel flags to indicate it's active
;;;
;;;_BE8A4:		pla					; sample # and env flag
;;;		jsr	_INSV				; Insert 
;;;		pla					; Get word number high byte or pitch back
;;;		jsr	_INSV				; Insert 
;;;		pla					; Get word number low byte or duration back
;;;		jsr	_INSV				; Insert 
;;;		plp					; Restore flags
;;;		jmp	ServiceOutA0			; and return
;;;
;;;
;;;
;;;_INSV:		jmp	(INSV)
;;;
;;;
;;;		; flush sound buffer X
;;;_LE1AE:		pha					; save A
;;;		php					; save flags
;;;		sei					; set interrupts
;;;
;;;_BE1BB:		sec					; set carry
;;;		ror	JIM+SNDWKSP_BUF_BUSY_0-SND_BUFFER_NUMBER_0,X	
;;;							; rotate buffer flag to show buffer empty
;;;		bit	_BD9B7				; set V
;;;_BE73E:		jsr	__CNPV				; CNPV with V set to purge buffer
;;;		plp					; restore flags
;;;		pla					; restore A
;;;		rts
;;;
;;;__CNPV:		jmp	(CNPV)
;;;
;;;_BD9B7:		.byte 	$FF
;;;_LE73B:			
;;;
;;;;********** enter byte in buffer, wait and flash lights if full **********
;;;
;;;_BUFFER_SAVE:		sei					; prevent interrupts
;;;			jsr	_INSV				; enter a byte in buffer X
;;;			bcc	@_buffer_save_done		; if successful exit
;;;			jsr	@SET_LEDS_TEST_ESCAPE		; else switch on both keyboard lights
;;;			php					; push p
;;;			pha					; push A
;;;			jsr	_SET_LEDS			; switch off unselected LEDs
;;;			pla					; get back A
;;;			plp					; and flags
;;;			bmi	@_buffer_save_done		; if return is -ve Escape pressed so exit
;;;			cli					; else allow interrupts
;;;			bcs	_BUFFER_SAVE			; if byte didn't enter buffer go and try it again
;;;@_buffer_save_done:	rts					; then return
;;;
;;;@SET_LEDS_TEST_ESCAPE:	;;bcc	_BE9F5				; if carry clear
;;;			ldy	#$07				; switch on shift lock light
;;;			sty	sheila_SYSVIA_orb		; 
;;;			dey					; Y=6
;;;			sty	sheila_SYSVIA_orb		; switch on Caps lock light
;;;			bit	zp_mos_ESC_flag			; set minus flag if bit 7 of &00FF is set indicating
;;;			rts					; that ESCAPE condition exists, then return
;;;
;;;;**********: Turn on Keyboard indicators *******************************
;;;_SET_LEDS:		;;php					; save flags
;;;			lda	sysvar_KEYB_STATUS		; read keyboard status;
;;;								; Bit 7	 =1 shift enabled
;;;								; Bit 6	 =1 control pressed
;;;								; bit 5	 =0 shift lock
;;;								; Bit 4	 =0 Caps lock
;;;								; Bit 3	 =1 shift pressed
;;;			lsr					; shift Caps bit into bit 3
;;;			and	#$18				; mask out all but 4 and 3
;;;			ora	#$06				; returns 6 if caps lock OFF &E if on
;;;			sta	sheila_SYSVIA_orb		; turn on or off caps light if required
;;;			lsr					; bring shift bit into bit 3
;;;			ora	#$07				; 
;;;			sta	sheila_SYSVIA_orb		; turn on or off shift	lock light
;;;			jsr	_LF12E				; set keyboard counter
;;;			;;pla					; get back flags
;;;			rts					; return
;;;
;;;;*************Enable counter scan of keyboard columns *******************
;;;				; called from &EEFD, &F129
;;;
;;;_LF12E:			lda	#$0b				; select auto scan of keyboard
;;;			sta	sheila_SYSVIA_orb		; tell VIA
;;;			txa					; Get A into X
;;;			rts					; and return
;;;
;;;
;;;
;;;
;;;
;;;; sound clock speed 3.547672
;;;
;;;
;;;; This code adapted from MOS disassembly found at https://github.com/raybellis/mos120
;;;
;;;; trashes Y, requires sound workspace to be paged in
;;;
;;;;	oct = P / 48		; octave number
;;;;	sem = (P/4) % 12	; semitone within octave
;;;;	eig = P % 		; eigth within semitone
;;;;	
;;;;	LO = pitchtable1[sem]
;;;;	HI = pitchtable2[sem] % 4
;;;;	X = pitchtable2[sem] >> 4
;;;;	WHILE eig > 0
;;;;		[HI,LO] -= X
;;;;		eig--
;;;;	WEND
;;;;	WHILE oct > 0
;;;;		[HI,LO] /= 2
;;;;		oct--
;;;;	WEND
;;;;	
;;;
;;;
;;;pitch2period:
;;;_BED16:			pha					; 
;;;			and	#$03				; 
;;;			sta	JIM+SNDWKSP_WS_0		; lose eigth tone surplus
;;;			lda	#$00				; 
;;;			sta	JIM+SNDWKSP_FREQ_LO		; 
;;;			pla					; get back A
;;;			lsr					; divide by 48
;;;			lsr					; 
;;;_BED24:			cmp	#$0c				; 
;;;			bcc	_BED2F				; 
;;;			inc	JIM+SNDWKSP_FREQ_LO		; store result
;;;			sbc	#$0c				; with remainder in A
;;;			bne	_BED24				; 
;;;								; at this point 83D defines the Octave
;;;								; A the semitone within the octave
;;;_BED2F:			tay					; Y=A
;;;			lda	JIM+SNDWKSP_FREQ_LO		; get octave number into A
;;;			pha					; push it
;;;			lda	_SOUND_PITCH_TABLE_1,Y		; get byte from look up table
;;;			sta	JIM+SNDWKSP_FREQ_LO		; store it
;;;			lda	_SOUND_PITCH_TABLE_2,Y		; get byte from second table
;;;			pha					; push it
;;;			and	#$07				; keep two LS bits only
;;;			sta	JIM+SNDWKSP_FREQ_HI		; save them
;;;			pla					; pull second table byte
;;;			lsr					; push hi nybble into lo nybble
;;;			lsr					; 
;;;			lsr					; 
;;;			sta	JIM+SNDWKSP_WS_3		; store it
;;;			lda	JIM+SNDWKSP_FREQ_LO		; lo byte from table lookup in TABLE_1
;;;			ldy	JIM+SNDWKSP_WS_0		; adjust for surplus eighth tones
;;;			beq	_BED5F				; 
;;;_BED53:			sec					; 
;;;			sbc	JIM+SNDWKSP_WS_3		; 
;;;			bcs	_BED5C				; 
;;;			dec	JIM+SNDWKSP_FREQ_HI		; 
;;;_BED5C:			dey					; 
;;;			bne	_BED53				; 
;;;_BED5F:			sta	JIM+SNDWKSP_FREQ_LO		; 
;;;			pla					; 
;;;			tay					; 
;;;			beq	_BED6F				; 
;;;_BED66:			lsr	JIM+SNDWKSP_FREQ_HI		; 
;;;			ror	JIM+SNDWKSP_FREQ_LO		; 
;;;			dey					; 
;;;			bne	_BED66				; 
;;;_BED6F:			
;;;	; TODO: the following is for the channel de-tune - not sure I want that
;;;;			lda	JIM+SNDWKSP_FREQ_LO		; 
;;;;			clc					; 
;;;;			adc	_LC43D,X			; 
;;;;			sta	JIM+SNDWKSP_FREQ_LO		; 
;;;;			bcc	_BED7E				; 
;;;;			inc	JIM+SNDWKSP_FREQ_HI		; 
;;;			rts
;;;
;;;
;;;
;;;; Generated by pitchtable.pl, assumptions:
;;;; PAULA_FREQ=3547672
;;;; SAMPLE_LEN=32
;;;; SAMPLE_RATE=8372 (middle C) [8377.02951593861]
;;;; note these tables are packed differently to the MOS with 3 bits for HI and 5 for 8th adjust
;;;
;;;_SOUND_PITCH_TABLE_1:                           .byte $81
;;;                        .byte $4F
;;;                        .byte $1F
;;;                        .byte $F3
;;;                        .byte $C8
;;;                        .byte $A0
;;;                        .byte $7A
;;;                        .byte $57
;;;                        .byte $35
;;;                        .byte $15
;;;                        .byte $F7
;;;                        .byte $DB
;;;_SOUND_PITCH_TABLE_2:                           .byte $63
;;;                        .byte $63
;;;                        .byte $5B
;;;                        .byte $52
;;;                        .byte $52
;;;                        .byte $4A
;;;                        .byte $42
;;;                        .byte $42
;;;                        .byte $42
;;;                        .byte $3A
;;;                        .byte $39
;;;                        .byte $31
;;;
;;;; TODO: uses $100 - not sure this is safe?
;;;
;;;SOUND_INSV:
;;;		jsr	jimSetDEV_either_stack_old
;;;		php
;;;		pha
;;;		jsr	jimPageSoundWorkspace
;;;		lda	JIM+SNDWKSP_OLDINSV
;;;		sta	$100
;;;		lda	JIM+SNDWKSP_OLDINSV+1
;;;		sta	$101
;;;		pla
;;;		plp
;;;
;;;;*************************************************************************
;;;;*									 *
;;;;*	 INSBV insert character in buffer vector default entry point	 *
;;;;*									 *
;;;;*************************************************************************
;;;;on entry X is buffer number, A is character to be written
;;;; adapted from MOS, need to avoid page boundary crossing indexed reads/writes as that would tickle page FC
;;;; instead indexes are all positive instead of in the MOS the indexes increase toward 0
;;;
;;;			php					; save flags
;;;			sei					; bar interrupts
;;;			pha					; save A
;;;			txa
;;;			pha					; DB:save X
;;;			sec	
;;;			sbc	#SND_BUFFER_NUMBER_0		; get buffer base number and subtract
;;;			tax
;;;			cmp	#SND_NUM_CHANS
;;;			bcs	@exitpasson
;;;@here:
;;;			ldy	JIM+SNDWKSP_BUF_IN_0,X		; get buffer input pointer
;;;			iny					; increment Y
;;;			cpy	#SND_BUF_LEN
;;;			bne	@_BE4BF
;;;			ldy	#0				; get default buffer start
;;;@_BE4BF:		tya					; put it in A
;;;			cmp	JIM+SNDWKSP_BUF_OUT_0,X		; compare it with input pointer
;;;			beq	@_BE4D4				; if equal buffer is full so E4D4
;;;			ldy	JIM+SNDWKSP_BUF_IN_0,X		; else get buffer end in Y
;;;			sta	JIM+SNDWKSP_BUF_IN_0,X		; and set it from A
;;;			jsr	_GET_BUFFER_ADDRESS		; and point &FA/B at it
;;;			pla
;;;			tax					; get back un mangled X
;;;			pla					; get back byte
;;;			sta	(zp_mos_OS_wksp2),Y		; store it in buffer
;;;			plp					; pull flags
;;;			clc					; clear carry for success
;;;@unstackrts:		jsr	jimUnStackDev			; unstack device and exit
;;;			rts					; DB: NOTE do not remove this the jimUnStackDev does funky shit with the stack
;;;
;;;@_BE4D4:		
;;;
;;;;***** return with carry set *********************************************
;;;@exit_sec:
;;;			pla
;;;			tax					; DB: restore X
;;;			pla					; restore A
;;;@_BE4E0:		plp					; restore flags
;;;			sec					; set carry
;;;			bcs	@unstackrts
;;;
;;;@exitpasson:		pla
;;;			tax
;;;			pla
;;;			plp
;;;			jsr	jimUnStackDev
;;;			jmp	($100)
;;;
;;;
;;;
;;;;*******: get nominal buffer addresses in &FA/B **************************
;;;
;;;; X is 0..7
;;;
;;;_GET_BUFFER_ADDRESS:	php
;;;			lda	#<PAGE_SOUNDBUFFERS
;;;			sta	fred_JIM_PAGE_LO
;;;			lda	#>PAGE_SOUNDBUFFERS
;;;			sta	fred_JIM_PAGE_HI
;;;			txa					; buffer address is JIM+20*X
;;;			; need to multiply by 21
;;;			clc
;;;			sta 	zp_mos_OS_wksp2+1
;;;			asl	A
;;;			asl	A		
;;;			sta	zp_mos_OS_wksp2
;;;			asl	A
;;;			asl	A
;;;			adc	zp_mos_OS_wksp2
;;;		.if SNDBUF_BUF_0<>0
;;;			adc	#SNDWKSP_BUF_0
;;;		.endif
;;;			adc	zp_mos_OS_wksp2+1		; get back *1
;;;			sta	zp_mos_OS_wksp2
;;;			lda	#>JIM
;;;			sta	zp_mos_OS_wksp2+1
;;;			plp
;;;			rts					; exit
;;;
;;;
;;;SOUND_REMV:
;;;		jsr	jimSetDEV_either_stack_old
;;;		php
;;;		pha
;;;		jsr	jimPageSoundWorkspace
;;;		lda	JIM+SNDWKSP_OLDREMV
;;;		sta	$100
;;;		lda	JIM+SNDWKSP_OLDREMV+1
;;;		sta	$101
;;;		pla
;;;		plp
;;;
;;;
;;;
;;;;*************************************************************************
;;;;*									 *
;;;;*	 REMV buffer remove vector default entry point			 *
;;;;*									 *
;;;;*************************************************************************
;;;;on entry X = buffer number
;;;;on exit if buffer is empty C=1, Y is preserved else C=0
;;;
;;;_REMVB:			php					; push flags
;;;			sei					; bar interrupts
;;;
;;;			pha					; return value
;;;			txa
;;;			pha					; DB:save X
;;;			php					; DB: extra push to save overflow round sbc
;;;			sec	
;;;			sbc	#SND_BUFFER_NUMBER_0		; get buffer base number and subtract
;;;			tax
;;;			cmp	#SND_NUM_CHANS
;;;			bcs	@exitpasson
;;;			plp
;;;
;;;			jsr	REMV_internal			
;;;			bcs	@exit_sec
;;;
;;;			stx	zp_mos_OS_wksp2			; TODO: DB this is convoluted - have a think
;;;			tsx
;;;			sta	$102,X
;;;			ldx	zp_mos_OS_wksp2			; DB: note we need to stack A for return faff
;;;
;;;			pla
;;;			tax
;;;			pla					; get back result
;;;			tay					; copy to Y
;;;			plp
;;;			clc					; clear carry to indicate success
;;;@unstackrts:		jsr	jimUnStackDev			; unstack device and exit
;;;			rts					; DB: NOTE do not remove this the jimUnStackDev does funky shit with the stack
;;;
;;;
;;;@exit_sec:		pla
;;;			tax
;;;			pla
;;;			plp
;;;			sec
;;;			bcs	@unstackrts
;;;
;;;@exitpasson:
;;;			plp					; unstack V
;;;			pla
;;;			tax
;;;			pla
;;;			plp					; unstack I
;;;
;;;			jsr	jimUnStackDev
;;;			jmp	($100)
;;;
;;;
;;;
;;;; check for empty buffer
;;;REMV_internal_SEV:
;;;			bit	_BD9B7				; set V
;;;			bvs	REMV_internal
;;;REMV_internal_CLV:
;;;			clv
;;;REMV_internal:
;;;			lda	JIM+SNDWKSP_BUF_OUT_0,X		; get output pointer for buffer X
;;;			cmp	JIM+SNDWKSP_BUF_IN_0,X		; compare to input pointer
;;;			bne	@s1				; if equal buffer is empty so E4E0 to exit
;;;			sec
;;;			rts
;;;@s1:			tay					; else Y=A
;;;			jsr	_GET_BUFFER_ADDRESS		; and get buffer pointer into FA/B
;;;			lda	(zp_mos_OS_wksp2),Y		; read byte from buffer
;;;
;;;;; DB: fixed as per MOS 2.x, returns the next char instead of pointer
;;;;;			bvc	@noty
;;;;;			tya					; return pointer instead of byte!
;;;;;@noty:
;;;
;;;			pha					; save returned byte
;;;			jsr	jimPageSoundWorkspace
;;;			bvs	@retV				; if V is set (on input) exit with CARRY clear
;;;								; Osbyte 152 has been done
;;;								; else must be osbyte 145 so save byte
;;;
;;;
;;;			iny					; increment Y
;;;			tya					; A=Y
;;;			cpy	#SND_BUF_LEN
;;;			bne	@_BE47E				; if end of buffer not reached  E47E
;;;
;;;			lda	#0
;;;
;;;@_BE47E:		
;;;			sta	JIM+SNDWKSP_BUF_OUT_0,X		; set buffer output pointer
;;;
;;;			cmp	JIM+SNDWKSP_BUF_IN_0,X		; else for output buffers compare with buffer start
;;;			bne	@_BE48F				; if not the same buffer is not empty so E48F
;;;
;;;
;;;			ldy	#$00				; buffer is empty so Y=0
;;;			jsr	OSEVEN				; and enter EVENT routine to signal EVENT 0 buffer
;;;								; becoming empty
;;;
;;;@_BE48F:
;;;@retV:			pla
;;;			clc
;;;			rts
;;;
;;;
;;;
;;;
;;;
;;;SOUND_CNPV:
;;;		jsr	jimSetDEV_either_stack_old
;;;		php
;;;		pha
;;;		jsr	jimPageSoundWorkspace
;;;		lda	JIM+SNDWKSP_OLDCNPV
;;;		sta	$100
;;;		lda	JIM+SNDWKSP_OLDCNPV+1
;;;		sta	$101
;;;		pla
;;;		plp
;;;
;;;
;;;;*************************************************************************
;;;;*									 *
;;;;*	 COUNT PURGE VECTOR	 DEFAULT ENTRY				 *
;;;;*									 *
;;;;*************************************************************************
;;;;on entry if V set clear buffer
;;;;	  if C set get space left
;;;;	  else get bytes used
;;;
;;;			
;;;
;;;
;;;
;;;_CNPV:			php
;;;			sei
;;;			pha					; return value
;;;			txa
;;;			pha					; DB:save X
;;;			php					; DB: extra push to save overflow round sbc
;;;			sec	
;;;			sbc	#SND_BUFFER_NUMBER_0		; get buffer base number and subtract
;;;			tax
;;;			cmp	#SND_NUM_CHANS
;;;			bcs	@exitpasson
;;;			plp
;;;
;;;			bvc	@_BE1DA				; if bit 6 is set then E1DA
;;;			lda	JIM+SNDWKSP_BUF_OUT_0,X		; else start of buffer=end of buffer
;;;			sta	JIM+SNDWKSP_BUF_IN_0,X		; 
;;;			bvs	@ret				; and exit
;;;
;;;@_BE1DA:		php					; push flags
;;;			sec					; set carry
;;;			lda	JIM+SNDWKSP_BUF_IN_0,X		; get end of buffer
;;;			sbc	JIM+SNDWKSP_BUF_OUT_0,X		; subtract start of buffer
;;;			bcs	@_BE1EA				; if carry caused E1EA
;;;								; 
;;;			adc	#SND_BUF_LEN			; add buffer length
;;;@_BE1EA:		plp					; pull flags
;;;			bcc	@_BE1F3				; if carry clear E1F3 to exit
;;;			eor	#$FF
;;;			clc					; clear carry
;;;			adc	#SND_BUF_LEN			; adc to get bytes used
;;;@_BE1F3:		ldy	#$00				; Y=0
;;;			tax					; X=A
;;;			pla					; DB: stack buggery to get X out
;;;			txa
;;;			pha
;;;
;;;@ret:			pla
;;;			tax
;;;			pla
;;;			plp					; get back flags
;;;			jsr	jimUnStackDev
;;;			rts					; and exit
;;;
;;;@exitpasson:
;;;		plp
;;;		pla
;;;		tax
;;;		pla
;;;		plp
;;;		jsr	jimUnStackDev
;;;		jmp	($100)
;;;
;;;
;;;
;;;;*************************************************************************
;;;;*									 *
;;;;*	 PROCESS SOUND INTERRUPT					 *
;;;;*									 *
;;;;*************************************************************************
;;;
;;;
;;;		.import _SOUND_IRQ
;;;
sound_irq	rts
;;;		jsr	jimPageSoundWorkspace
;;;		lda	JIM+SNDWKSP_SOUNDFLAGS
;;;		bmi	@s1
;;;		jmp	ServiceOut
;;;@s1:
;;;		jsr	_SOUND_IRQ	
;;;
;;;		; clear pending IRQ
;;;		lda	#VIA_IFR_BIT_T1+VIA_IFR_BIT_ANY
;;;		sta	sheila_USRVIA_ifr
;;;		jmp	ServiceOutA0
;;;
;;;
cmdSoundSamMap	rts
;;;cmdSoundSamMap:	jsr	jimPageSoundWorkspace
;;;
;;;		lda	JIM+SNDWKSP_SOUNDFLAGS
;;;		bpl	@brkSoundNotEn
;;;
;;;		jsr	SkipSpacesPTR
;;;		cmp	#$D
;;;		bne	@sk1
;;;		; no parameters - list samples mappings
;;;		
;;;		ldx	#<str_SAM_MAP_HDR
;;;		ldy	#>str_SAM_MAP_HDR
;;;		jsr	PrintXY
;;;
;;;		ldx	#0
;;;@lp:		txa
;;;		jsr	PrintHexA
;;;		lda	#' '
;;;		ldy	#6
;;;@lp2:		jsr	OSASCI
;;;		dey
;;;		bne	@lp2
;;;		lda	JIM+SNDWKSP_DEF_SAM,X
;;;		bpl	@dash
;;;		and	#$1F
;;;		clc
;;;		adc	#1		
;;;		jsr	PrintHexA
;;;		tay
;;;		jsr	jimPageSamTbl
;;;		lda	JIM+SAMTBLOFFS_BASE+1,Y
;;;		bpl	@oks
;;;		lda	#'!'
;;;@dash2:		jsr	OSWRCH
;;;@oks:		jsr	jimPageSoundWorkspace
;;;		jsr	OSNEWL
;;;		inx
;;;		cpx	#SND_NUM_CHANS
;;;		bne	@lp
;;;		rts
;;;@dash:		lda	#'-'		
;;;		bne	@dash2
;;;
;;;@brkSoundNotEn:	jmp	brkSoundNotEn
;;;
;;;@sk1:		jsr	ParseHex
;;;		bcs	brkBadCommand2
;;;		lda	zp_trans_acc
;;;		cmp	#SND_NUM_CHANS
;;;		bcs	brkBadCommand2
;;;		tax				; X now contains channel #
;;;		jsr	ParseHex
;;;		bcs	brkBadCommand2
;;;		lda	zp_trans_acc
;;;		beq	brkBadCommand2
;;;		cmp	#33
;;;		bcs	brkBadCommand2
;;;		sbc	#0
;;;		ora	#$80			; mark in use
;;;		sta	JIM+SNDWKSP_DEF_SAM,X		
;;;		rts
;;;brkBadCommand2:	jmp	brkBadCommand
;;;
;;;
cmdSoundSamClear	rts
;;;cmdSoundSamClear:
;;;		jsr	SkipSpacesPTR
;;;		cmp	#'*'
;;;		beq	@skclearall
;;;		jsr	ParseHex
;;;		bcs	brkBadCommand2
;;;		ldx	zp_trans_acc+0
;;;		jmp	@clrone
;;;		rts
;;;@skclearall:	ldx	#32
;;;@lp:		jsr	@clrone
;;;		dex
;;;		bne	@lp
;;;
;;;@clrone:	txa
;;;		pha
;;;		dex
;;;		txa
;;;		and	#$E0
;;;		bne	@skip
;;;		txa
;;;		asl	A
;;;		asl	A
;;;		asl	A
;;;		tax
;;;		jsr	jimPageSamTbl
;;;		lda	JIM+SAMTBLOFFS_BASE+1,X
;;;		bmi	@skip
;;;
;;;		pha
;;;		lda	#$FF
;;;		sta	JIM+SAMTBLOFFS_BASE+1,X		; mark sample freed
;;;		lda	JIM+SAMTBLOFFS_BASE,X
;;;		pha
;;;		lda	#OSWORD_OP_FREE
;;;		pha
;;;		lda	#0
;;;		pha
;;;		lda	#5
;;;		tsx
;;;		pha
;;;		ldy	#1			; pass parameters from stack, call Heap free
;;;		lda	#OSWORD_BLTUTIL
;;;		jsr	OSWORD
;;;		pla
;;;		pla
;;;		pla
;;;		pla
;;;		pla
;;;
;;;@skip:		pla
;;;		tax
;;;		rts
;;;
;;;
;;;
;;;		.SEGMENT "RODATA"
;;;
;;;str_SAM_MAP_HDR:	.byte	"Channel Sample#",13
;;;			.byte	"---------------",13,0
;;;str_SOUND_start:	.byte	"Paula sound started, channels: ",0
;;;
;;;
;;;
;;;SOUND_BYTEV:
;;;
;;;		pha
;;;		pha
;;;		php
;;;
;;;		jsr	jimSetDEV_either_stack_old
;;;
;;;		; stack contains
;;;		;	+5..6		spare return address
;;;		;	+4		P
;;;		; 	+3		previously selected device
;;;		;	+2		old JIM paging register LO
;;;		;	+1		old JIM paging register LO
;;;
;;;		jsr	jimPageSoundWorkspace
;;;
;;;		pha
;;;		txa
;;;		pha
;;;
;;;		; stack contains
;;;		;	+7..8		spare return address
;;;		;	+6		P
;;;		; 	+5		previously selected device
;;;		;	+4		old JIM paging register LO
;;;		;	+3		old JIM paging register LO
;;;		;	+2		A
;;;		;	+1		X
;;;
;;;		; make a return address that will jump to old vector
;;;
;;;		tsx
;;;		lda	JIM+SNDWKSP_OLDBYTEV
;;;		sta	$107,X
;;;		lda	JIM+SNDWKSP_OLDBYTEV+1
;;;		sta	$108,X
;;;
;;;		pla
;;;		tax
;;;		pla
;;;		pha
;;;
;;;		; stack contains
;;;		;	+5..6		old BYTEV-1
;;;		; 	+4		previously selected device
;;;		;	+3		old JIM paging register LO
;;;		;	+2		old JIM paging register LO
;;;		;	+1		A
;;;
;;;		cmp	#OSBYTE_126_ESCAPE_ACK
;;;		beq	@osbyte_ackesc
;;;		cmp	#OSBYTE_15_FLUSH_INPUT
;;;		beq	@flushall
;;;		cmp	#OSBYTE_21_FLUSH_BUFFER
;;;		beq	@flushone
;;;
;;;@exitpasson:
;;;		pla
;;;		jsr	jimUnStackDev
;;;		rti					; return to address we pushed above (don't jmp to jimunstackdev!)
;;;		
;;;
;;;@osbyte_ackesc:	bit	zp_mos_ESC_flag			; if bit 7 not set there is no ESCAPE condition
;;;		bpl	@exitpasson			; so E673
;;;		lda	sysvar_KEYB_ESC_EFFECT		; else get ESCAPE Action, if this is 0
;;;							; Clear ESCAPE
;;;							; close EXEC files
;;;							; purge all buffers
;;;							; reset VDU paging counter
;;;		bne	@exitpasson			; else do none of the above
;;;		beq	@doflushall
;;;@flushall:	txa
;;;		bne	@exitpasson
;;;@doflushall:	txa
;;;		pha
;;;		lda	#OSBYTE_21_FLUSH_BUFFER
;;;		ldx	#SND_BUFFER_NUMBER_0
;;;@lp1:
;;;		cli
;;;		sei
;;;		jsr	OSBYTE
;;;		inx
;;;		cpx	#SND_BUFFER_NUMBER_0+SND_NUM_CHANS
;;;		bcc	@lp1
;;;
;;;		pla
;;;		tax
;;;		jmp	@exitpasson
;;;
;;;@flushone:	cpx	#SND_BUFFER_NUMBER_0
;;;		bcc	@exitpasson
;;;		cpx	#SND_BUFFER_NUMBER_0+SND_NUM_CHANS
;;;		bcs	@exitpasson
;;;
;;;		tya
;;;		pha
;;;		txa
;;;		pha
;;;
;;;		sec
;;;		sbc	#SND_BUFFER_NUMBER_0
;;;		tax
;;;		jsr	_LECA2				; silence channel X
;;;
;;;		sec
;;;		ror	JIM+SNDWKSP_BUF_BUSY_0,X	; mark as not busy
;;;
;;;		pla
;;;		pha
;;;		tax					; get back original X
;;;
;;;		bit	@v				; set V
;;;		jsr	__CNPV
;;;
;;;		pla
;;;		tax
;;;		pla
;;;		tay
;;;		jmp	@exitpasson
;;;
;;;@v:		.byte $40
;;;