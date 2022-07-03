

; The allocation table is a single page of 64 entries each entry is
;	+0	16bit	PageNum
;	+2	16bit	Flags | Number of pages
;		Flags are in top two bits of Number of pages
;	$80	Entry is used
;	$40	Entry is a free "hole" in the map

HEAPFLAG_FREE	EQU	$40
HEAPFLAG_INUSE	EQU	$80


heap_init	jsr	jimSetDEV_either		; either Blitter or Paula don't care which here
		bcc	1F
		rts
1		jsr	jimPageWorkspace

		lda	zp_mos_jimdevsave		; detect Blitter or Paula
		cmpa	#JIM_DEVNO_HOG1MPAULA
		beq	1F
		cmpa	#JIM_DEVNO_BLITTER
		beq	2F
		rts

1		ldd	#PAGE_RAM_TOP_PAULA
		bra	3F
2		ldd	#PAGE_RAM_TOP_BLITTER
3		std	JIM+SCRATCH_HEAPTOP
		ldd	#$0100				; set lower limit at 64k
		std	JIM+SCRATCH_HEAPLIM
		bra	heap_clear_int

heap_clear
		jsr	jimSetDEV_either			; either Blitter or Paula don't care which here
		bcc	1F
		rts
1		jsr	jimPageWorkspace
heap_clear_int
		ldd	JIM+SCRATCH_HEAPTOP

		; check to see if limit is > HEAPLIM
		cmpd	JIM+SCRATCH_HEAPLIM
		bls	heap_no_space
		
		subb	#1
		sbca	#0

		std	JIM+SCRATCH_HEAPBOT		; set heap limit at top of RAM-1 (reserve one page for block map)

		; clear the heap map
		jsr	jimPageAllocTable
		ldx	#JIM
		ldb	#0
		
1		clr	,X+
		decb
		bne	1B

		rts

heap_no_space

		std	JIM+SCRATCH_HEAPBOT		; set heap limit at top of RAM
		rts

jimPageAllocTable						; TODO return error if no alloc table!
		std	,--S
		jsr	jimPageWorkspace
		ldd	JIM+SCRATCH_HEAPTOP
		subb	#1
		sbca	#0
		std	fred_JIM_PAGE_HI
		puls	D,PC

heap_OSWORD_bltutil	
	;	+0	params len
	;	+1	params ret len
	;	+2	op number < $10 == get rom #
		pshs	D,X,Y,U
		ldy	zp_mos_OSBW_Y
		lda	2,Y				; get rom/call no
		cmpa	#$10			
		lblt	oswordGetRomBase
		cmpa	#OSWORD_OP_ALLOC
		lbeq	oswordAlloc
		cmpa	#OSWORD_OP_FREE
		beq	oswordFree
		puls	D,X,Y,U,PC

oswordFree	jsr	jimSetDEV_either
		bcs	4F
1		jsr	jimPageAllocTable

		ldx	#JIM				
1		lda	2,X				; is block allocated;
		bpl	2F
		bita	#HEAPFLAG_FREE			; is it already freed
		bne	2F
		ldd	3,Y				; address to free in OSWORD block	
		exg	A,B				; endianness			
		cmpd	0,X
		beq	3F
2		leax	4,X
		cmpx	JIM+$100
		bne	1B
4		puls	D,X,Y,U,PC

3		lda	2,X				; mark block as free
		ora	#HEAPFLAG_FREE
		sta	2,X

heap_coalesceX
		; try to either join the current block with other neighbouring blocks, or if at
		; tbe bottom of the heap return the space to the user area

heap_col_again

		; get end address of current block
		ldd	2,X
		anda	#$3F				; mask out flags
		addd	0,X
		std	,--S

		; check to see if there are any blocks immediately after and join to that
		ldy	#JIM
heap_col_lp	lda	2,Y
		anda	#$C0
		cmpa	#$C0
		bne	heap_col_empty			; not a free block, ignore

		ldd	0,Y
		cmpd	0,S				; compare block X's start with Y's end (on stack)
		bne	heap_col_snab

		; this block Y is immediately above us coalesce with it 
		ldd	2,Y
		anda	#$3F
		std	2,Y				; mark as empty and keep length for calc below
		ldd	2,X
		anda	#$3F
		addd	2,Y
		ora	#HEAPFLAG_FREE|HEAPFLAG_INUSE
		std	2,X	
		bra	heap_col_next

heap_col_snab	; check to see if this block is below X
		ldd	2,Y
		anda	#$3F
		addd	0,Y
		cmpd	0,X
		bne	heap_col_snbel


		; it is below block at X, extend at Y and mark X free
		ldd	2,X
		anda	#$3F				; mark current as unused and make length
		std	2,X				
		ldd	2,Y
		anda	#$3F
		addd	2,X
		ora	#HEAPFLAG_FREE|HEAPFLAG_INUSE
		std	2,Y
		tfr	Y,X				; Y becomes current block
heap_col_next
heap_col_snbel
heap_col_empty	leay	4,Y
		cmpy	#JIM+$100
		blo	heap_col_lp

		leas	2,S				; discard block end from stack, we need to recalc it anyway...it may have changed above?

		; check to see if current block is at the bottom of the heap
		ldd	0,X
		jsr	jimPageWorkspace
		cmpd	JIM+SCRATCH_HEAPBOT
		bne	1F

		; it is at the bottom, get the length and add to the bottom pointer and exit
		jsr	jimPageAllocTable
		ldd	2,X
		anda	#$3F
		sta	2,X			; mark as empty

		jsr	jimPageWorkspace

		addd	JIM+SCRATCH_HEAPBOT
		std	JIM+SCRATCH_HEAPBOT
1		puls	D,X,Y,U,PC


ALLOC_ERR_NOBLIT	EQU 0
ALLOC_ERR_BADREQ  EQU 3
ALLOC_ERR_OUTOFM  EQU 1
ALLOC_ERR_SLOTS   EQU 2

		;	+3..4	number of pages requested
		; returns
		;	+3..4	page number allocated or $FFFF for fail
oswordAlloc

		jsr	jimSetDEV_either
		bcc	1F
		lda	#ALLOC_ERR_NOBLIT
		lbra	alloc_fail

1		; check for 0 length
		ldd	3,Y					
		beq	1F
		bpl	2F
1		lda	#ALLOC_ERR_BADREQ
		lbra	alloc_fail

2		jsr	PushAcc					; save ZP accumulator

		; search for a free slot
		; in the allocation table
		jsr	jimPageAllocTable
		ldx	#JIM
1		tst	2,X
		bpl	alloc_fnd1
		leax	4,X
		cmpx	#JIM+$100
		blo	1B

		lda	#ALLOC_ERR_SLOTS
		lbra	alloc_fail3		

alloc_fnd1	; X = destination block for our new alloc all being well

		; search for a free block that is large enough 
		ldu	#$FFFF
		stu	zp_trans_acc				; this is our block number matched
		stu	zp_trans_acc+2				; size of matched block
		ldu	#JIM
alloc_fblp	ldd	2,U					; check free
		cmpa	#$C0
		blo	alloc_fbsk				; should be >$C0 if both free and inuse set
		anda	#$3F
		std	,--S					; save
		ldd	3,Y
		exg	A,B					; endianness
		cmpd	,S					; compare with req'd size
		puls	D					; get back size of this block without affecting flags
		bne	alloc_notp				
		tfr	U,X					; perfect fit, use this
		lda	2,X
		anda	#~HEAPFLAG_FREE
		sta	2,X
		bra	alloc_fnd2

alloc_notp	bhi	alloc_fbsk				; too small

		; now check if there's already a match if the matched is smaller
		cmpd	zp_trans_acc+2
		bhs	alloc_fbsk
		std	zp_trans_acc+2
		stu	zp_trans_acc


alloc_fbsk	leau	4,U
		cmpu	#JIM+$100
		bne	alloc_fblp

		ldu	zp_trans_acc				; get back found slot
		cmpu	#$FFFF
		beq	alloc_extend				; none found!


		; we now need to grab space from this slot
		; move start on by requested length
		ldd	3,Y
		exg	A,B
		std	zp_trans_acc

		ldd	0,U
		std	,--S
		addd	zp_trans_acc
		std	0,U

		ldd	2,U
		subd	zp_trans_acc
		std	2,U

		ldd	,S++
		bra	alloc_fnd

alloc_extend
		jsr	jimPageWorkspace

		ldd	3,Y
		exg	A,B					; endianness
		std	,--S

		ldd	JIM+SCRATCH_HEAPBOT
		subd 	,S++
		bmi	1F					; gone negative


		cmpd	JIM+SCRATCH_HEAPLIM			; out of room!
		bhs	2F
1		lda	#ALLOC_ERR_OUTOFM
		bra	alloc_fail3
2		std	JIM+SCRATCH_HEAPBOT			; move bottom

		; >= limit store as new bottom and return
		; stack the result and then try and find a slot
		jsr	jimPageAllocTable 

alloc_fnd
		std	0,X					; return value
		ldd	3,Y
		exg	A,B					; endianness
		anda	#$3F
		ora	#HEAPFLAG_INUSE
		std	2,X

alloc_fnd2	; X points at alloc table entry already filled in
		ldd	0,X
		exg	A,B					; endianness
		std	3,Y

		jsr	PopAcc
		puls	D,X,Y,U,PC

alloc_fail3	jsr	PopAcc
alloc_fail	clrb
		decb
		std	3,Y

		puls	D,X,Y,U,PC


oswordGetRomBase

	;	+2	rom #
	;	+3	roms flags
	;		(see SRLOAD)
	; returns
	;	+2	flags
	;	+3..4	page number (little-endian!)
		clrb
		jsr	cfgGetRomMap			; check for mem inhibit TODO: mege with getcurset below?
		bvc	osw_grb_notmemi
		ldb	#OSWORD_BLTUTIL_RET_MEMI
		lda	3,Y
		bita	#OSWORD_BLTUTIL_FLAG_IGNOREMEMI	; get flags
		beq	osw_grb_sys
osw_grb_notmemi	;work out which map
		lda	3,Y				; get flags
		bpl	osw_grb_sk1

		; get current set into 
		rola
		rola				; get the alternate bit into bit 0
		rola				; get the 
		sta	,-S
		jsr	cfgGetRomMap
		bcc	1F			
		bra	osw_grb_sk1		; return 0 is no onboard roms
		leas	1,S
		bra	osw_grb_sk1
1		eora	,S+

osw_grb_sk1
		; at this point A[0] is map1
		rorb
		rora					; get map1 flag into bit 0 of B
		rolb
		clr	,-S				; make room on stack for 
		lda	2,Y				; get rom #
	IF MACH_ELK
		eora	#$0C				; bodge address bases
	ELSE
		bitb	#CC_C
		bne	osw_grb_nohole			; hole in Elk for both maps
	ENDIF
		cmpa	#4
		blo	osw_grb_nohole
		cmpa	#8
		blo	osw_grb_sys2
		; calculate offset of rom in area
osw_grb_nohole	sta	,-S
		rora
		rora
		anda 	#OSWORD_BLTUTIL_RET_FLASH		;$80
		sta	,-S
		orb	,S+				; ORB with A
		lda	,S+				; get back index
		anda	#$0E
		lsra
		ror	0,S
		lsra
		ror	0,S
		lsra
		ror	0,S
		adda	#$7E		
		sta	4,Y
		lda	,S+
		sta	3,Y
		; check if rom/ram
		ror	2,Y				; NOTE destroys 2,X! rom number
							; odd/even rom #
		lda	4,Y
		bcc	1F
		; add $20 to rom/ram address high
		adda	#$20
1		bitb	#1				; if map1 subtract 2
		beq	1F
		suba	#2
1		sta	4,Y
		bra	osw_grb_retB



osw_grb_sys2	leas	1,S
osw_grb_sys	; either memi or SYS
		lda	#$FF
		sta	4,Y
		lda	#$80
		sta	3,Y
		orb	#OSWORD_BLTUTIL_RET_SYS

osw_grb_retB
		stb	,-S				; bit 0 of flags on stack		
		jsr	cfgGetRomMap
		bcs	osw_grb_forceCur			; memi set
		eora	,S+
		anda	#1				; bit 0 is now set if not curren
		bne	2F
osw_grb_forceCur	orb	#OSWORD_BLTUTIL_RET_ISCUR		; set "current" 
2		stb	2,Y
		puls	D,X,Y,U,PC

cmdHeapInfo	jsr	CheckEitherPresentBrk
		jsr	jimPageWorkspace		; page in scratch space bottom

		clr	JIM+SCRATCH_TMP+0
		jsr	SkipSpacesX
		jsr	ToUpper
		cmpa	#'V'				; verbose flag
		bne	1F
		dec	JIM+SCRATCH_TMP+0
1		ldx	#str_HINFT
		jsr	PrintX

		ldx	JIM+SCRATCH_HEAPTOP
		jsr	PrintHexX
		clra
		jsr	PrintHexA

		jsr	OSNEWL

		ldx	#str_HINFB
		jsr	PrintX

		ldx	JIM+SCRATCH_HEAPBOT
		jsr	PrintHexX
		clra
		jsr	PrintHexA

		jsr	OSNEWL

		ldx	#str_HINFL
		jsr	PrintX

		ldx	JIM+SCRATCH_HEAPLIM
		jsr	PrintHexX
		clra
		jsr	PrintHexA

		jsr	OSNEWL

		ldx	#str_HINFFree
		jsr	PrintX

		; print free space in bytes	 
		ldd	JIM+SCRATCH_HEAPBOT
		subd	JIM+SCRATCH_HEAPLIM
		std	zp_trans_acc+1
		clr	zp_trans_acc+0
		clr	zp_trans_acc+3

		; go through alloc table and include any blocks in there

		jsr	jimPageAllocTable
		ldx	#JIM
1		ldd	2,X
		bpl	2F		; in use?
		bita	#HEAPFLAG_FREE
		bne	2F
		anda	#$3F
		addd	zp_trans_acc+1
		std	zp_trans_acc+1
2		leax	4,X
		cmpx	#JIM+$100
		bne	1B

		jsr	jimPageWorkspace

		jsr	PrintBytesAndK


		ldx	#str_HINFMax
		jsr	PrintX

		; find largest allocation block free
		; first try below heap

		ldd	JIM+SCRATCH_HEAPBOT	
		subd	JIM+SCRATCH_HEAPLIM
		std	zp_trans_acc+1


		; scan alloc table for any larger ones
		jsr	jimPageAllocTable
		ldx	#JIM

1		ldd	2,X
		bpl	2F		; in use?
		bita	#HEAPFLAG_FREE
		bne	2F
		anda	#$3F
		cmpd	zp_trans_acc+1
		blo	2F
		std	zp_trans_acc+1
2		leax	4,X
		cmpx	#JIM+$100
		bne	1B

		jsr	jimPageWorkspace

		jsr	PrintBytesAndK

		lda	JIM+SCRATCH_TMP+0
		bpl	blhinf_exit				; not verbose

		; display allocation table entries
		ldy	#JIM
		jsr	jimPageAllocTable
1		ldd	2,Y
		bpl	3F				; not in use

		anda	#$40				; check if "free"
		pshs	CC

		tfr	Y,D
		tfr	B,A
		jsr	PrintHexA
		jsr	PrintSpc

		ldx	0,Y				; base address
		jsr	PrintHexX

		jsr	PrintSpc

		ldd	2,Y
		anda	#$3F
		tfr	D,X
		jsr	PrintHexX


		puls	CC
		beq	2F

		ldx	#str_free
		jsr	PrintX
2		jsr	OSNEWL
3		leay	4,Y
		cmpy	#JIM+$100
		bne	1B
blhinf_exit	rts

str_HINFT	FCB "Heap Top	      ",131,'&',0
str_HINFB	FCB "Heap Bottom    ",131,'&',0
str_HINFL	FCB "Heap Low Limit ",131,'&',0
str_HINFFree	FCB "Total free     ",131,0
str_HINFMax	FCB "Largest free   ",131,0
str_free		FCB " (free)",0