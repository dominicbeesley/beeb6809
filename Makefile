.PHONY:		all

all: all_beeb all_chipkit all_flex all_matchbox hardware-overview.html
	$(MAKE) -C other-tests all

hardware-overview.html:	hardware-overview.md
	./scripts/Markdown-Master/Markdown.pl <$< >$@

all_chipkit:
	# NOTE: MOS/UTILS needs noice to be reinstated for chipkit somehow 
	# taken out to make room in MOS and moved into UTIL for beeb but
	# utils rom doesn't work yet for CHIPKIT
	$(MAKE) -C mos all_chipkit
	$(MAKE) -C rom-dev all_chipkit
	$(MAKE) -C chipkitmk1-tests all_chipkit
	$(MAKE) -C games all_chipkit
	$(MAKE) -C demos all_chipkit
	$(MAKE) -C ssds all_chipkit
	cat 	CHIPKIT/mos/beeb6809-mos/mosrom.bin \
		CHIPKIT/rom-dev/BBCBASIC/6809bas.bin \
		CHIPKIT/rom-dev/USBFS/USBFS.bin \
		>CHIPKIT/ROMIMAGE.BIN	

all_beeb:
	$(MAKE) -C mos all_beeb
	$(MAKE) -C rom-dev all_beeb
	$(MAKE) -C games all_beeb
	$(MAKE) -C demos all_chipkit
	$(MAKE) -C ssds_beeb all_beeb
	$(MAKE) -C hardware-testing all_beeb
	$(MAKE) -C flex-port all_beeb
	
all_matchbox:
	$(MAKE) -C rom-dev all_matchbox

all_flex:
	$(MAKE) -C rom-dev all_flex
	$(MAKE) -C flex-port all_flex

clean:
	$(MAKE) -C rom-dev clean
	$(MAKE) -C mos clean
	$(MAKE) -C chipkitmk1-tests clean
	$(MAKE) -C games clean
	$(MAKE) -C demos clean
	$(MAKE) -C ssds clean
	$(MAKE) -C other-tests all
	-rm ROMIMAGE.BIN	
	