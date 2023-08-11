.PHONY:		all

all: all_beeb all_chipkit all_flex all_sbc09

all_beeb:
	$(MAKE) -C tools all_beeb
	$(MAKE) -C BBCBASIC all_beeb
	$(MAKE) -C USBFS all_beeb
	$(MAKE) -C HOSTFS all_beeb
	$(MAKE) -C UTILS all_beeb

all_chipkit:
	$(MAKE) -C tools all_chipkit
	$(MAKE) -C BBCBASIC all_chipkit
	$(MAKE) -C USBFS all_chipkit
	$(MAKE) -C HOSTFS all_chipkit
	$(MAKE) -C UTILS all_chipkit

all_flex:
	$(MAKE) -C BBCBASIC all_flex

all_sbc09:
	$(MAKE) -C BBCBASIC all_sbc09
	$(MAKE) -C HOSTFS all_sbc09
	$(MAKE) -C UTILS all_sbc09

all_matchbox:
	$(MAKE) -C BBCBASIC all_matchbox
	
clean:
	$(MAKE) -C tools clean
	$(MAKE) -C BBCBASIC clean
	$(MAKE) -C USBFS clean
	$(MAKE) -C HOSTFS clean
	$(MAKE) -C UTILS clean
	
