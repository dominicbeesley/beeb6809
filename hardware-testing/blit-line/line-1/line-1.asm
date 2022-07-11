		include "../../../includes/hardware.inc"
		include "../../../includes/common.inc"
		include "../../../includes/oslib.inc"
		include "../../../includes/mosrom.inc"


		ORG	$2000


		lda	#12
		jsr	OSWRCH

		; enable device and set page
		lda 	#$D1
		sta 	zp_mos_jimdevsave
		sta 	fred_JIM_DEVNO

		ldx 	#jim_page_DMAC
		stx 	fred_JIM_PAGE_HI


		; line drawing test
		;============================
		; set start point address
		lda	#$FF
		sta	jim_DMAC_ADDR_C
		sta	jim_DMAC_ADDR_D
		ldx	#$5600
		stx	jim_DMAC_ADDR_C+1
		stx	jim_DMAC_ADDR_D+1
		ldx	#640
		stx	jim_DMAC_STRIDE_C
		stx	jim_DMAC_STRIDE_D

		; set start point pixel mask and colour
		lda	#$0F
		sta	jim_DMAC_DATA_B			; colour 1bpp white
		lda	#$11				; 8bpp left middle pixel
		sta	jim_DMAC_DATA_A
		; set major length
		ldx	#100
		stx	jim_DMAC_WIDTH			; 16 bits!
		; set slope
		ldd	#30				; major length
		std	jim_DMAC_ADDR_B+1
		lsra
		rorb
		std	jim_DMAC_ADDR_A+1			; initial error accumulator value
		ldd	#10
		std	jim_DMAC_STRIDE_A

		;set func gen to be plot B masked by A
		lda	#$CA				; B masked by A
		sta	jim_DMAC_FUNCGEN

		; set bltcon 0
		lda	#BLITCON_EXEC_C + BLITCON_EXEC_D
		sta	jim_DMAC_BLITCON
		; set bltcon 1 - right/down
		lda	#BLITCON_ACT_ACT + BLITCON_ACT_CELL + BLITCON_ACT_LINE
		sta	jim_DMAC_BLITCON

		nop
		nop
		nop
		nop



		SWI