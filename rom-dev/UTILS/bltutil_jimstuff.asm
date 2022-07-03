
CheckBlitterPresent 	EQU jimSetDEV_blitter
CheckPaulaPresent 	EQU jimSetDEV_paula

CheckBlitterPresentBrk
		jsr	CheckBlitterPresent
		bcs	brkBlitterNotPresent
		rts
brkBlitterNotPresent
		M_ERROR
		FCB	$FF, "Blitter not present",0

brkEitherNotPresent
		M_ERROR
		FCB	$FF, "Blitter/Paula not present",0

CheckEitherPresentBrk
		jsr	jimSetDEV_either
		bcs	brkEitherNotPresent
		rts

; set jim device no and paging registers to scratch space at 00 FD00-FDFF
; returns CS if not present
;jimSetSCR:	pha
;		jsr	jimSetDEV
;		bcs	@s
;		lda	#<JIM_SCRATCH
;		sta	fred_JIM_PAGE_LO
;		lda	#>JIM_SCRATCH
;		sta	fred_JIM_PAGE_HI
;@s:		pla
;		rts

; set jim device no, return CS if not present
jimSetDEV_paula
		pshs	A		
		lda	#JIM_DEVNO_HOG1MPAULA
		bra	jimSetDEV_A
jimSetDEV_blitter
		pshs	A
		lda	#JIM_DEVNO_BLITTER
jimSetDEV_A
		sta	zp_mos_jimdevsave		; set to our device
		sta	fred_JIM_DEVNO
		eora	fred_JIM_DEVNO
		CLC
		inca					; return CS if not our device present
		beq	1F
		SEC
1		puls	A,PC

jimSetDEV_either
		jsr	jimSetDEV_blitter
		bcs	jimSetDEV_paula
		rts


; This will return with the stack containing the following:
		; 	SP+2		previously selected device
		;	SP+1		old JIM paging register HI
		;	SP+0		old JIM paging register LO

		; all register _and flags_ are preserved
jimSetDEV_either_stack_old

		; reserve stack space for new data
		; and push working regs
		; not DP,X are used for space
		pshs X,DP,D,CC

		; stack contents

		;	SP+6..7		Ret address
		;	SP+3..5		spare
		;	SP+2		B
		;	SP+1		A
		;	SP+0		CC


		; move return address
		ldd	6,S
		std	3,S

		; stack contents

		;	SP+5..7		spare
		;	SP+3..4		Ret address
		;	SP+2		B
		;	SP+1		A
		;	SP+0		CC

		; retrieve and save old JIM pointers
		lda	zp_mos_jimdevsave
		sta	7,S
		jsr	jimSetDEV_either
		ldd	fred_JIM_PAGE_HI
		sta	5,S

		;	SP+7		JIM devno
		;	SP+5		JIM paging HI, LO
		;	SP+3..4		Ret address
		;	SP+2		B
		;	SP+1		A
		;	SP+0		CC

		puls	PC,D,CC


; this will restore the stack and device
jimUnStackDev

		pshs	D,CC

		; stack now contains

		;	SP+7		OLD DEV NO
		;	SP+6		JIM_PAGE_LO
		;	SP+5		JIM_PAGE_HI
		;	SP+4		retL
		;	SP+3		retH
		;	SP+2		saved B
		;	SP+1		saved A
		;	SP+0		saved CC

		jsr	jimSetDEV_either		; make sure our dev is still selected

		; restore device registers
		ldd	5,S
		std	fred_JIM_PAGE_HI
		lda	7,S
		sta	zp_mos_jimdevsave
		sta	fred_JIM_DEVNO

		; move return address
		ldd	3,S
		std	6,S


		;	SP+7		RetL
		;	SP+6		RetH
		;	SP+5		spare
		;	SP+4		spare
		;	SP+3		spare
		;	SP+2		saved B
		;	SP+1		saved A
		;	SP+0		saved CC


		; restore D,CC
		puls	D,CC


		; fix up stack 
		leas	3,S
		rts

	

;------------------------------------------------------------------------------
; NEW JIM API routines
;------------------------------------------------------------------------------
	; on all ROM entry points the current device number held at 
	; zp_mos_jimdevsave &EE needs to be saved and our device number set
	; in zp_mos_jimdevsave and fred_jim_DEVNO to enable the JIM memory
	; interface used for ramdiscs and scratch space

	; This routine will install a phoney return address on the stack it should
	; be called at service call / event handler entry point and will rearrange
	; the stack such that an RTS from the caller routine will call jimReleaseDev
	; before returning to the service routine caller


	; NEW: June 2022: Now stores the stack pointer at 1FF and saves previous 1FF
	; contents on the stack, this allows us to put the device back as it should
	; be no matter what state the stack has got to - used in the M_ERROR macro
	; to restore the device

;TODO: assumes stack is at $100-$1FF!

jimClaimDev
		; stack contents
		; SP + 2..3	service return
		; SP + 0..1	caller return

		leas	-7,S				; make room on stack
		pshs	D,CC				; save registers


		; stack contents
		; SP + 12..13	service return
		; SP + 10..11	caller return
		; SP + 3..9	spare
		; SP + 2	caller B save
		; SP + 1	caller A save
		; SP + 0	caller CC


		; move caller return 
		ldd	10,S
		std	3,S
		; and install phoney return
		ldd	#jimReleaseDev
		std	5,S

		; stack contents
		; SP + 12..13	service return
		; SP + 7..11	spare
		; SP + 5..6	Release fn address
		; SP + 3..4	caller return
		; SP + 2	caller B save
		; SP + 1	caller A save
		; SP + 0	caller CC

		; save jim regs and page in our device

		lda	zp_mos_jimdevsave
		sta	7,S
		jsr	jimSetDEV_either		; page in Blitter/Paula
		ldd	fred_JIM_PAGE_HI
		std	8,S

		ldd	$1FE
		std	10,S
		sts	$1FE

		; stack contents

		; SP + 12..13	service return
		; SP + 10..11	old $1FE..$1FF contents
		; SP + 8..9	jim page
		; SP + 7	Saved devno
		; SP + 5..6	Release fn address
		; SP + 3..4	caller return
		; SP + 2	caller B save
		; SP + 1	caller A save
		; SP + 0	caller CC

		puls	CC,D,PC

		; this version of release dev doesn't return to the original caller
		; instead it restores the device from the stack (and repairs 1FE)
		; but leaves everything on the stack and returns
jimReleaseDev_err
		pshs	D,U,CC

		ldu	$1FE		; set user stack up at old sys stack location
		ldd	10,U
		std	$1FE

		jsr	jimSetDEV_either
		ldd	8,U
		std	fred_JIM_PAGE_HI

		lda	7,U
		sta	zp_mos_jimdevsave		; set to saved caller's dev no
		sta	fred_JIM_DEVNO

		puls	D,U,CC,PC


jimReleaseDev		
		pshs	CC,D

		; SP + 6..7	service return
		; SP + 6..7	old $1FE contents
		; SP + 4..5	jim page
		; SP + 3	saved devno
		; SP + 2	saved B
		; SP + 1	saved A
		; SP + 0	saved CC

		ldd	6,S
		std	$1FE

		jsr	jimSetDEV_either
		ldd	4,S
		std	fred_JIM_PAGE_HI

		lda	3,S
		sta	zp_mos_jimdevsave		; set to saved caller's dev no
		sta	fred_JIM_DEVNO

		puls	CC,D
		leas	5,S
		rts


; check if Paula or Blitter selected and return CS=1 if not
; preserves all registers except flags
jimCheckEitherSelected
		pshs	A
		lda	zp_mos_jimdevsave
		cmpa	#JIM_DEVNO_BLITTER
		beq	1F
		cmpa	#JIM_DEVNO_HOG1MPAULA
		beq	1F
		SEC
		puls	A,PC
1		CLC
		puls	A,PC


jimPageWorkspace
		pshs	D
		ldd	#PAGE_ROMSCRATCH
		std	fred_JIM_PAGE_HI
		puls	D,PC

jimPageChipset
		pshs	D
		ldd	#jim_page_DMAC
		std	fred_JIM_PAGE_HI
		puls	D,PC

jimPageSamTbl	pshs	D
		ldd	#PAGE_SAMPLETBL
		std	fred_JIM_PAGE_HI
		puls	D,PC

jimPageSoundWorkspace
		pshs	D
		ldd	#PAGE_SOUNDWKSP
		std	fred_JIM_PAGE_HI
		puls	D,PC

jimPageVersion
		pshs	D
		ldd	#jim_page_VERSION
		std	fred_JIM_PAGE_HI
		puls	D,PC
