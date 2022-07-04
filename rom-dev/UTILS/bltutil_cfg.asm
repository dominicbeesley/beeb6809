; NOTE: sheila BLT_MK2_CFG0/1 registers are deprecated - now in JIM page FC 008x
sheila_BLT_API0_CFG0			EQU $FE3E
sheila_BLT_API0_CFG1			EQU $FE3F


;=============================================================================
; Version / Configuration access functions
;=============================================================================
; Currently supports API level 0 and 1. 0 is deprecated and may be removed
; at any time
; all the cfgXXX routines expect:
; - device is setup and zp_mos_jimdevsave contains the correct device number
; - we can freely change FCFD/E (jim page)

;-----------------------------------------------------------------------------
; cfgGetRomMap
;-----------------------------------------------------------------------------
; Returns current ROM map number in A or Cy=1 if no ROMS (i.e. Paula) [always 0 or 1]
; Also returns Ov=1, Cy=1 id MEMI inhibit jumper fitted
; A is 0 if CS set
cfgGetRomMap
		jsr	cfgGetAPILevel
		andcc	#~CC_V
		bcs	cfgGetRomMap_retCs
		beq	cfgGetRomMap_API0

		lda	JIM+jim_offs_VERSION_Board_level
		cmpa	#3		; check for >= Mk.3 assume Mk.1 and Mk.2 same config
		blt	cfgGetRomMap_mk2

		; mk.3 switches
		; assume future boards have same config options as mk.3
		lda	JIM+jim_offs_VERSION_cfg_bits+0
		anda	#BLT_MK3_CFG0_MEMI
		beq	cfgGetRomMap_retOvCs			; if 0 (jumper fitted) return Cs,Ov
		lda	JIM+jim_offs_VERSION_cfg_bits+0
		anda	#BLT_MK3_CFG0_T65			; isolate T65 jumper setting
		pshs	A					; save
		lda	JIM+jim_offs_VERSION_cfg_bits+0
		anda	#BLT_MK3_CFG0_SWROMX			; get SWROMX bit
		bne	cfgGetRomMap_skswromx			; if SWROMX not fitted jump
		puls	A
		eora	#BLT_MK3_CFG0_T65			; toggle T65 bit
		jmp	cfgGetRomMap_sk3


cfgGetRomMap_mk2; Mk.2 detect
		lda	JIM+jim_offs_VERSION_cfg_bits+1
		anda	#BLT_MK2_CFG1_MEMI
		beq	cfgGetRomMap_retOvCs			; if 0 (jumper fitted) return Cs,Ov
		lda	JIM+jim_offs_VERSION_cfg_bits+0
		anda	#BLT_MK2_CFG0_T65			; isolate T65 jumper setting
		pshs	A					; save
		lda	JIM+jim_offs_VERSION_cfg_bits+0	
		anda	#BLT_MK2_CFG0_SWROMX			; get SWROMX bit
		bne	cfgGetRomMap_skswromx			; if SWROMX not fitted jump
		puls	A
		jmp	cfgGetRomMap_sk2			; toggle T65 bit



cfgGetRomMap_API0
		lda	sheila_BLT_API0_CFG0
		anda	#BLT_MK2_CFG0_T65
		pshs	A
		lda	sheila_BLT_API0_CFG0
		anda	#BLT_MK2_CFG0_SWROMX
		beq	cfgGetRomMap_skswromx
		puls	A
cfgGetRomMap_sk2
		eora	#BLT_MK2_CFG0_T65
		pshs	A
cfgGetRomMap_skswromx
		lda	,S+
cfgGetRomMap_sk3
		beq	cfgGetRomMap_ok
		lda	#1
cfgGetRomMap_ok
		CLC
cfgGetRomMap_ret
		rts
cfgGetRomMap_retOvCs
		ORCC	#CC_V
cfgGetRomMap_retCs
		clra
		SEC
		rts


cfgPrintVersionBoot
		jsr	cfgGetAPILevel
		bcs	cPVB_ret
		pshs 	A			; save API level

		ldx	#str_Dossy
		jsr	PrintX
		lda	#' '
		ldb	vduvar_MODE
		cmpb	#7
		bne	cPVB_nm71
		lda	#130		
cPVB_nm71	jsr	OSWRCH

		lda	zp_mos_jimdevsave
		cmpa	#JIM_DEVNO_HOG1MPAULA
		bne	cPVB_skP

		ldx	#str_Paula
		jsr	PrintX			; Print banner and Exit
		CLC
		puls	A,PC			; Discard API and exit

cPVB_skP	ldx	#str_Blitter
		jsr	PrintX

		tst	0,S			; get back API
		beq	cPVB_skAPI0_1
		jsr	PrintSpc
		ldb	#2			; Board
		jsr	cfgPrintStringB

cPVB_skAPI0_1	jsr	OSNEWL

		jsr	printCPU

		; show ROM Map
		jsr	cfgGetRomMap
		bcs	cPVB_nomap		; Error, skip
		pshs	A
		ldx	#str_map
		jsr	PrintX
		puls	A
		adda	#'0'
		jsr	OSWRCH
		
cPVB_nomap
		jsr	OSNEWL

		clrb				; either full string for API 0 or 
		jsr	cfgPrintStringB
		puls	A			; Get back API level
		beq	cPVB_API0
		jsr	PrintSpc
		ldB	#1
		jmp     cfgPrintStringB		; build time
cPVB_API0	CLC
cPVB_ret	rts

;-----------------------------------------------------------------------------
; cfgGetAPILevel
;-----------------------------------------------------------------------------
; Returns API level in A
; on exit the current JIM page will be pointing to the VERSION info page
; returns CS if Blitter not present/selected (by testing zp_mos_jimdevsave)
; Z flag is set if API=0
cfgGetAPILevel
		jsr	jimSetDEV_either
		bcs	1F
		jsr	jimPageVersion
		lda	JIM+jim_offs_VERSION_API_level
1		rts

;;; ;-----------------------------------------------------------------------------
;;; ; cfgGetAPILevelExt
;;; ;-----------------------------------------------------------------------------
;;; ; Returns current board type, API level and sub level in A,X,Y
;;; ; on exit the current JIM page will be pointing to the VERSION info page
;;; ; returns CS if Blitter not present/selected (by testing zp_mos_jimdevsave)
;;; ; Z flag is set if API=0
;;; cfgGetAPILevelExt:
;;; 		jsr	jimCheckEitherSelected
;;; 		bcs	@ret
;;; 		jsr	jimPageVersion
;;; 		lda	JIM+jim_offs_VERSION_API_level
;;; 		beq	@API0
;;; 		ldx	JIM+jim_offs_VERSION_Board_level
;;; 		ldy	JIM+jim_offs_VERSION_API_sublevel
;;; 		ora	#0
;;; 		clc
;;; 		rts
;;; 
;;; @API0:		lda	#0
;;; 		tax
;;; 		tay
;;; 		; API 0 doesn't specify board type/level so always return Mk.2 as board level
;;; 		lda	zp_mos_jimdevsave
;;; 		cmp	#JIM_DEVNO_HOG1MPAULA
;;; 		bne	@notp
;;; 		inx
;;; 		inx
;;; @notp:		tya		; return A=0
;;; 		clc
;;; @ret:		rts
		
;-----------------------------------------------------------------------------
; cfgGetStringB
;-----------------------------------------------------------------------------
; Returns version string component in X, on entry B contains the index of the string
; on exit X contains a pointer to the string, A contains the first character of the string
; Z flag is set if string is empty
; if Cy=1 then there is an error and there is no string
; The string may be empty if the index is past the end of all strings

cfgGetStringB	ldx	#JIM
		tstb
		beq	CGGSB_ok1
		jsr	cfgGetAPILevel
		bcs	CGGSB_ret
		beq	CGGSB_ok1
CGGSB_lp		
1		lda	,X+
		beq	CGGSB_sk1
		cmpx	#JIM+$80
		blt	1B
		; past end of strings, point at 0
		ldx	#CGGSB_a_zero
		CLC
		rts
CGGSB_a_zero	FCB	0
CGGSB_sk1	decb
		bne	CGGSB_lp
CGGSB_ok1	lda	,X
		CLC
CGGSB_ret	rts

;-----------------------------------------------------------------------------
; cfgPrintStringB
;-----------------------------------------------------------------------------
; Prints the version string component, on entry B contains the index of the string
cfgPrintStringB
		jsr	cfgGetStringB
		jmp	PrintX


printHardCPU	SEC
		bra	printCPU2

printCPU	CLC
printCPU2	pshs	CC
		jsr	cfgGetAPILevel
		beq	pc2_API0
		lda	JIM+jim_offs_VERSION_Board_level
		cmpa	#3		; check for >= Mk.3 assume Mk.1 and Mk.2 same config
		blt	pc2_mk2

		;mk3 look up
		;first check T65
		puls	CC
		bcs	pc2_mk3hard
		lda	JIM+jim_offs_VERSION_cfg_bits+0
		anda	#BLT_MK3_CFG0_T65
		beq	pc2_T65
pc2_mk3hard	lda	JIM+jim_offs_VERSION_cfg_bits+1
		anda	#$FE
		ldb	#cputbl_mk3_len-2
		ldx	#cputbl_mk3
pc2_lp3		cmpa	B,X
		beq	pc2_skmk3_fnd
		decb
		decb
		bpl	pc2_lp3
		lda	#'?'
		jmp	OSWRCH
pc2_skmk3_fnd	incb
		ldb	B,X
		jmp	pc2_printCPUB

		; get config bits as TTTT0SSS from 


pc2_mk2		ldb	JIM+jim_offs_VERSION_cfg_bits
		eorb	#$FF				; invert
		jmp	pc2_printCPU2_mk2

pc2_API0	ldb	sheila_BLT_API0_CFG0		; get inverted cpu and T65 bits

pc2_printCPU2_mk2
		puls	CC
		bcs	pc2_printHardCPU_mk2
		bitb	#BLT_MK2_CFG0_T65
		beq	pc2_printHardCPU_mk2
pc2_T65		ldb	#cpu_tbl_T65-cputbl_mk2
		bra	pc2_printCPUB
pc2_printHardCPU_mk2
		andb	#$0E			; get cpu type
		aslb
		

pc2_printCPUB	ldy	#cputbl_mk2
		leay	B,Y
		ldx	,Y++
		jsr	PrintX
		jsr	PrintSpc
		ldd	,Y
		bita	#$F0
		beq	1F
		jsr	PrintHexA
		bra	3F
1		jsr	PrintHexNybA
3		tstb
		beq	2F
		lda	#'.'
		jsr	PrintA
		tfr	B,A
		lsra
		lsra
		lsra
		lsra
		jsr	PrintHexNybA	
		tfr	B,A
		anda	#$0F
		beq	2F
		jsr	PrintHexNybA	
2		ldx	#str_cpu_MHz
		jmp	PrintX

brk_NoBlitter	M_ERROR
		FCB	$FF, "No Blitter", 0

;------------------------------------------------------------------------------
; *BLINFO : cmdInfo
;------------------------------------------------------------------------------



cmdInfo_API0	jsr	PrintImmed
		FCB   	13, "Build info   : ",0
		ldb	#0
		jsr	cfgPrintStringB
		jsr	PrintImmed
		FCB	13, "mk.2 bootbits: ",0
		lda	sheila_BLT_API0_CFG1
		jsr	PrintHexA
		lda	sheila_BLT_API0_CFG0
		jsr	PrintHexA
		jmp	cmdInfo_API0_mem

cmdInfo		jsr	cfgGetAPILevel
		bcs	brk_NoBlitter

CI_ok1		sta	,-S
		lda	zp_mos_jimdevsave
		cmpa	#JIM_DEVNO_HOG1MPAULA
		bne	CI_Blit
		lda	,S+
		jsr	PrintImmed
		FCB	"Paula",0
		jmp	CI_justChipRAM


CI_Blit		jsr	PrintImmed
		FCB	"Hard CPU     : ",0
		jsr	printHardCPU
		jsr	PrintImmed
		FCB	13,"Active CPU   : ",0
		jsr	printCPU

		lda 	,S+			;API level
		lbeq	cmdInfo_API0

CI_cmdInfo_API1	; print ver strings
		ldy	#tbl_bld
CI_verlp	ldb	1,Y			; get index
		jsr	cfgGetStringB
		beq	CI_sknov
		jsr	PrintNL
		jsr	cfgBldTblPrintY
		jsr	PrintX
CI_sknov	leay	2,Y
		cmpy	#tbl_bld_end
		blt	CI_verlp

		jsr	PrintImmed
		FCB	13,"Boot config #: ",0
		ldb	#4
		ldx	#JIM+jim_offs_VERSION_cfg_bits+4
CI_bblp		lda	,-X
		jsr	PrintHexA
		decb
		bne	CI_bblp

		jsr	PrintImmed
		FCB	13,"Boot jumpers : ",0

		ldy	#tbl_boot_cfg_mk2
		lda	JIM+jim_offs_VERSION_Board_level
		cmpa	#3
		blt	CI_mk2
		ldy	#tbl_boot_cfg_mk3
CI_mk2		ldx	#1				; mark first pass for comma
CI_flaglp	tst	0,Y				; check for 0
		beq	CI_flags_done
		lda	1,Y
		anda	JIM+jim_offs_VERSION_cfg_bits
		bne	CI_flags_next
		lda	2,Y
		anda	JIM+jim_offs_VERSION_cfg_bits+1
		bne	CI_flags_next
		jsr	commaSpcIfFirst 
		jsr	cfgBldTblPrintY2
CI_flags_next	leay	3,Y
		bra	CI_flaglp
CI_flags_done	


		jsr	PrintImmed
		FCB	13,"Host System  : ",0

		ldb	JIM+jim_offs_VERSION_cfg_bits		; get MK.3 host in bit 2..0 inverted
		lda	JIM+jim_offs_VERSION_Board_level
		cmpa	#3
		bge	CI_mk2_2
		ldb	JIM+jim_offs_VERSION_cfg_bits+1		; get MK.2 host in bit 13..11 inverted
		lsrb
		lsrb
		lsrb
CI_mk2_2	andb	#7
		eorb	#7
		cmpb	#5
		blt	CI_sk_uk
		ldb	#4					; unknown string
CI_sk_uk	ldy 	#tbl_hosts
		leay	B,Y
		jsr	cfgBldTblPrintY2
		; capabilities

		jsr	PrintImmed
		FCB	13,"Capabilities : ",0

		ldy	#tbl_capbits
		ldx	#1
		lda	JIM+jim_offs_VERSION_cap_bits+0
CI_caplp	cmpy	#tbl_capbits+8
		bne	CI_skcap0
		lda	JIM+jim_offs_VERSION_cap_bits+1
CI_skcap0	rora
		bcc	CI_capnext
		jsr	commaSpcIfFirst 
		jsr	cfgBldTblPrintY2
CI_capnext	leay	1,Y
		cmpy	#tbl_capbits+16
		bne	CI_caplp

cmdInfo_API0_mem
		; get BB RAM size (assume starts at bank 60 and is at most 20 banks long)		

		ldx	#$6000
		ldy	#$0000
		jsr	cfgMemCheckAlias
		bcc	CI_justChipRAM
		bne	CI_BBRAM_test

		; print combined
		jsr	PrintImmed
		FCB	13, "Chip/BB RAM  : ",0
		jmp	CI_noBB


CI_BBRAM_test	; X already set to $6000
		ldy	#$8000
		jsr	cfgMemSize
		jsr	zeroAcc
		sta	zp_trans_acc+1

		jsr	PrintImmed
		FCB	13, "BB RAM       : ",0

		jsr	PrintSizeK

CI_justChipRAM
		jsr	PrintImmed
		FCB	13, "Chip RAM     : ",0


CI_noBB
CI_BBChipram	ldx	#$0000
		ldy	#$6000
		jsr	cfgMemSize
		jsr	zeroAcc
		sta	zp_trans_acc+1
		jsr	PrintSizeK
		jmp	PrintNL


;======================= end of *BLINFO

;-----------------------------------------------------------------------------
; cfgMemSize
;-----------------------------------------------------------------------------
; on Entry X is base bank, Y is limit
; A contains # of banks at exit
		; TODO: when move this to boot use other zp variables?
cfgMemSize	pshs	B,CC
		orcc	#CC_I|CC_F
		stx	zp_trans_tmp		; base
		sty	zp_trans_tmp+2		; limit
		tfr	X,Y			; check until memory at base aliases with X
		leax	$100,X
1		jsr	cfgMemCheckAlias
		bcc	2F
		beq	2F
		leax	$100,X
		cmpx	zp_trans_tmp+2
		blt	1B
2		tfr	X,D
		subd	zp_trans_tmp		; A contains number of banks
		puls	B,CC

;-----------------------------------------------------------------------------
; cfgMemCheckAlias
;-----------------------------------------------------------------------------
; checks if the memory at bank in X is aliased at bank in Y
; performs a write to bank X
; corrupts Y
; returns CS and Z flags set memory is aliased
;         CS and Z flags clear if not aliased
;         CC if no writeable memory
; corrupts A 
cfgMemCheckAlias
		std	,--S				; this will get destroyed later
		ldd	fred_JIM_PAGE_HI
		std	,--S
		stx	fred_JIM_PAGE_HI
		lda	JIM
		sta	,-S				; save original JIM:X contents

		; stack:
		;	+3..4	original D
		;	+1..2	original PAGE
		;	+0	JIM:X

		lda	#$55
		sta	JIM			; JIM:X = 55
		sty	fred_JIM_PAGE_HI
		ldb	JIM+1			; force databus to something else
		cmpa	JIM			; cmp JIM:Y
		bne	CMCA_notsame
		stx	fred_JIM_PAGE_HI
		lda	#$AA
		sta	JIM			; JIM:X = AA
		sty	fred_JIM_PAGE_HI
		ldb	JIM+1			; force databus to something else
		cmpa	JIM			; cmp JIM:Y
		bne	CMCA_notsame
		SEC
		bra	CMCA_ex

CMCA_notsame	stx	fred_JIM_PAGE_HI
		cmpa	JIM
		beq	CMCA_ok_noalias
		CLC
		bra	CMCA_ex			; no writeable

CMCA_ok_noalias
		SEC
		lda	#1			; cause Z flag off
CMCA_ex		pshs	CC

		; stack:
		;	+4..5	original D
		;	+2..3	original PAGE
		;	+1	JIM:X
		;	+0	CC

		stx	fred_JIM_PAGE_HI
		lda	1,S			; orig mem value
		sta	JIM
		ldd	2,S	
		std	fred_JIM_PAGE_HI	; reset JIM pointer
		ldd	4,S
		puls	CC
		leas	5,S
		rts



cfgBldTblPrintY2
		pshs	D,X
		clra
		ldb	0,Y
		addb	#str_bld_base & $FF
		adca	#str_bld_base >> 8
		tfr	D,X
		jsr	PrintX
		puls	D,X,PC

cfgBldTblPrintY
		jsr	cfgBldTblPrintY2
		jsr	PrintImmed
		FCB	" : ",0		
		rts


commaSpcIfFirst
		pshs	A
		leax	-1,X
		beq	1F
		jsr	PrintCommaSpace		
1		puls	A,PC


tbl_bld		FCB	str_bld_bran - str_bld_base, 3
		FCB	str_bld_ver - str_bld_base, 0
		FCB	str_bld_date - str_bld_base, 1
		FCB	str_bld_name - str_bld_base, 2
tbl_bld_end
	; NOTE: big-endian defs here reverse of 6502 ROM
tbl_boot_cfg_mk2
		FCB	str_bld_T65-str_bld_base
		FDB	$0100
		FCB	str_bld_swromx-str_bld_base
		FDB	$1000
		FCB	str_bld_mosram-str_bld_base
		FDB	$2000
		FCB	str_bld_memi-str_bld_base
		FDB	$0001
		FCB	0
tbl_boot_cfg_mk3
		FCB	str_bld_T65-str_bld_base
		FDB	$0800
		FCB	str_bld_swromx-str_bld_base
		FDB	$1000
		FCB	str_bld_mosram-str_bld_base
		FDB	$2000
		FCB	str_bld_memi-str_bld_base
		FDB	$4000
		FCB	0
tbl_hosts	FCB	str_sys_B-str_bld_base
		FCB	str_sys_Elk-str_bld_base
		FCB	str_sys_BPlus-str_bld_base
		FCB	str_sys_M128-str_bld_base
		FCB	str_sys_UK-str_bld_base
tbl_capbits	FCB	str_cap_CS - str_bld_base
		FCB	str_cap_DMA - str_bld_base
		FCB	str_Blitter - str_bld_base
		FCB	str_cap_AERIS - str_bld_base
		FCB	str_cap_I2C - str_bld_base
		FCB	str_cap_SND - str_bld_base
		FCB	str_cap_HDMI - str_bld_base		
		FCB	str_bld_T65 - str_bld_base
		FCB	str_cpu_65c02 - str_bld_base
		FCB	str_cpu_6800 - str_bld_base
		FCB	str_cpu_80188 - str_bld_base
		FCB	str_cpu_65816 - str_bld_base
		FCB	str_cpu_6x09 - str_bld_base
		FCB	str_cpu_z80 - str_bld_base
		FCB	str_cpu_68008 - str_bld_base
		FCB	str_cpu_68000 - str_bld_base

str_bld_base
str_bld_bran	FCB	"Repository  ",0
str_bld_ver	FCB	"Repo. ver   ",0
str_bld_date	FCB	"Build date  ",0
str_bld_name	FCB	"Board name  ",0
str_bld_swromx	FCB	"Swap Roms",0
str_bld_mosram	FCB	"MOSRAM",0
str_bld_memi	FCB	"ROM inhibit",0
str_sys_B	FCB	"Model B",0
str_sys_Elk	FCB	"Electron",0
str_sys_BPlus	FCB	"Model B+",0
str_sys_M128	FCB	"Master 128",0
str_sys_UK	FCB	"Unknown",0
str_cap_CS	FCB   	"Chipset",0
str_cap_DMA	FCB   	"DMA",0
str_Blitter	FCB  	"Blitter", 0 
str_cap_AERIS	FCB   	"Aeris",0
str_cap_I2C	FCB   	"i2c",0
str_cap_SND	FCB   	"Paula sound",0
str_cap_HDMI	FCB   	"HDMI",0
str_bld_T65	FCB	"T65",0
str_cpu_65c02	FCB	"65C02",0
str_cpu_6800	FCB	"6800",0
str_cpu_80188	FCB	"80188",0
str_cpu_65816	FCB	"65816",0
str_cpu_6x09	FCB	"6x09",0
str_cpu_z80	FCB	"z80",0
str_cpu_68008	FCB	"68008",0
str_cpu_68000	FCB	"68000",0


		; these are in the order of bits 3..1 of the config byte
cputbl_mk2		;	name		speed
cpu_tbl_6502A_2		FDB	str_cpu_6502A,	$0200
cpu_tbl_6x09_2		FDB	str_cpu_6x09,	$0200
cpu_tbl_65c02_8		FDB	str_cpu_65c02,	$0800
cpu_tbl_z80_8		FDB	str_cpu_z80,	$0800
			
cpu_tbl_65c02_4		FDB	str_cpu_65c02,	$0400
cpu_tbl_6x09_35		FDB	str_cpu_6x09,	$0350
cpu_tbl_6581_8		FDB	str_cpu_65816,	$0800
cpu_tbl_68008_10	FDB	str_cpu_68008,	$1000

cpu_tbl_T65		FDB	str_cpu_T65,	$1600

cpu_tbl_6800_2		FDB	str_cpu_6800, 	$0200
cpu_tbl_80188_20	FDB	str_cpu_80188,	$2000
cpu_tbl_68000_20	FDB	str_cpu_68000,	$2000


cputbl_mk3		;	bits, tbl offs
			; where bits is high nybl=type bits, low=speed bits
			; i.e. PORTF[3..0] & PORTG[11 downto 9] & '0'
			FCB	$EA, cpu_tbl_65c02_8 - cputbl_mk2
			FCB	$DC, cpu_tbl_65c02_4 - cputbl_mk2
			FCB	$CA, cpu_tbl_6581_8 - cputbl_mk2
			FCB	$7E, cpu_tbl_6x09_2 - cputbl_mk2
			FCB	$74, cpu_tbl_6x09_35 - cputbl_mk2
			FCB	$70, cpu_tbl_6800_2 - cputbl_mk2
			FCB	$40, cpu_tbl_80188_20 - cputbl_mk2
			FCB	$30, cpu_tbl_68000_20 - cputbl_mk2
cputbl_mk3_len EQU *-cputbl_mk3


str_cpu_6502A		FCB	"6502A",0
str_cpu_MHz		FCB	"Mhz",0

str_cpu_T65		FCB	"T65",0

str_Paula		FCB  	"1M Paula", 0 
str_map		FCB	" ROM Map ",0
