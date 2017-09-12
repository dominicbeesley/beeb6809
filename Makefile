.PHONY:		all

all:
	$(MAKE) -C mos all
	$(MAKE) -C rom-dev all
	$(MAKE) -C beeb6809-tests all
	$(MAKE) -C games all
	$(MAKE) -C ssds all
	cat mos/beeb6809-mos/mosrom-noice.bin rom-dev/BBCBASIC/6809bas.bin rom-dev/USBFS/USBFS.bin >ROMIMAGE.BIN	

clean:
	$(MAKE) -C rom-dev clean
	$(MAKE) -C mos clean
	$(MAKE) -C beeb6809-tests clean
	$(MAKE) -C games clean
	$(MAKE) -C ssds all
	-rm ROMIMAGE.BIN	
	