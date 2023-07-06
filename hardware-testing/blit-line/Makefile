.PHONY:		all

SUBDIRSWIMAKE:=$(shell for a in $$(find -mindepth 1 -type d); do if [ -e $$a/Makefile ]; then echo $$a; fi; done;)


all: all_beeb

all_beeb:
	$(foreach a,$(SUBDIRSWIMAKE), $(MAKE) -C $(a) all_beeb;)
clean:
	$(foreach a,$(SUBDIRSWIMAKE), $(MAKE) -C $(a) clean;)