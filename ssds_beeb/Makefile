SUBDIRS=$(shell for a in $$(find -mindepth 1 -type d); do if [ -e $$a/include.lst ]; then echo $$a; fi; done;)
TARGETS_EXTRA_BEEB=$(addsuffix .ssd, $(addprefix $(BEEBOUT)/, $(notdir $(SUBDIRS))))
CLEAN_EXTRA+=$(TARGETS_EXTRA_BEEB)

include		../Makefile.defs 

$(BEEBOUT)/%.ssd: 
	../scripts/buildssd.sh --dest $@ $(notdir $(basename $@))

