.PHONY:		all

all: all_chipkit all_beeb all_sbc09

all_chipkit:
	$(MAKE) -C noice/noice all_chipkit
	$(MAKE) -C beeb6809-mos all_chipkit
	$(MAKE) -C beebMOSloader-noice all_chipkit

all_beeb:
	$(MAKE) -C noice/noice all_beeb
	$(MAKE) -C beeb6809-mos all_beeb
	$(MAKE) -C beebMOSloader-noice all_beeb

all_sbc09:
	$(MAKE) -C beeb6809-mos all_sbc09
	
clean:
	$(MAKE) -C noice/noice clean
	$(MAKE) -C beeb6809-mos clean
	$(MAKE) -C beebMOSloader-noice clean
	