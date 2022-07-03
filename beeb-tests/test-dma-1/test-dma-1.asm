		

		include "../../includes/oslib.inc"
		include "../../includes/common.inc"
		include "../../includes/hardware.inc"


		org	$2000



main
		; enable Blitter
		lda	#JIM_DEVNO_BLITTER
		sta	fred_JIM_DEVNO
		ldx	#jim_page_DMAC
		stx	fred_JIM_PAGE_HI


		; top of mo.0 screen to chipram
		lda	#$FF
		sta	jim_DMAC_DMA_SRC_ADDR
		ldx	#$3000
		stx	jim_DMAC_DMA_SRC_ADDR+1
		lda	#$01
		sta	jim_DMAC_DMA_DEST_ADDR
		ldx	#0
		stx	jim_DMAC_DMA_DEST_ADDR+1
		ldx	#$1000
		stx	jim_DMAC_DMA_COUNT
		lda	#DMACTL_ACT|DMACTL_HALT|DMACTL_STEP_DEST_UP|DMACTL_STEP_SRC_UP
		sta	jim_DMAC_DMA_CTL



		; chip ram to mode 0 screen bottom
		lda	#$01
		sta	jim_DMAC_DMA_SRC_ADDR
		ldx	#$0000
		stx	jim_DMAC_DMA_SRC_ADDR+1
		lda	#$FF
		sta	jim_DMAC_DMA_DEST_ADDR
		ldx	#$6000
		stx	jim_DMAC_DMA_DEST_ADDR+1
		ldx	#$1000
		stx	jim_DMAC_DMA_COUNT
		lda	#DMACTL_ACT|DMACTL_HALT|DMACTL_STEP_DEST_UP|DMACTL_STEP_SRC_UP
		sta	jim_DMAC_DMA_CTL


		swi



