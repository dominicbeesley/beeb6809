TARGETS_BEEB=	test-dma-1.hex test-dma-1.noi
include		../../Makefile.defs

ASFLAGS=-3 -v

$(BEEBOUT)/test-dma-1.noi:	$(BEEBOUT)/test-dma-1.hex $(BEEBOUT)/test-dma-1.sym
	echo "LOAD $$(cygpath -w "$(BEEBOUT)/test-dma-1.hex")" >$(BEEBOUT)/test-dma-1.noi
	cat $(BEEBOUT)/test-dma-1.sym >>$(BEEBOUT)/test-dma-1.noi
	echo "R PC main" >>$(BEEBOUT)/test-dma-1.noi
	echo "U main" >>$(BEEBOUT)/test-dma-1.noi