.PHONY:		all

all: all_beeb all_chipkit all_flex all_matchbox

all_chipkit:
	$(MAKE) -C mos all_chipkit
	$(MAKE) -C rom-dev all_chipkit
	$(MAKE) -C beeb6809-tests all_chipkit
	$(MAKE) -C games all_chipkit
	$(MAKE) -C demos all_chipkit
	$(MAKE) -C ssds all_chipkit
	cat 	CHIPKIT/mos/beeb6809-mos/mosrom-noice.bin \
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
	$(MAKE) -C beeb6809-tests clean
	$(MAKE) -C games clean
	$(MAKE) -C demos clean
	$(MAKE) -C ssds clean
	$(MAKE) -C hostfsdirs clean
	-rm ROMIMAGE.BIN	
	