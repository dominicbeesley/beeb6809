.PHONY:		all

all: all_flex all_beeb


all_flex:
	flex-srcs/getsyms/makeem.sh
	$(MAKE) -C first-boot all_flex

all_beeb:
	$(MAKE) -C flex-mini-mos all_beeb
	$(MAKE) -C beeb-tools all_beeb
	
clean:
	$(MAKE) -C flex-mini-mos clean
	$(MAKE) -C beeb-tools clean
	