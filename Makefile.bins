# Makefile for cleaning subfolders

SUBDIRS = beebroms mods roms69

.PHONY: clean

clean:
	@echo "Cleaning subdirectories..."
	@for dir in $(SUBDIRS); do \
		if [ -d $$dir ]; then \
			rm -rf $$dir/*; \
			echo "Cleaned $$dir"; \
		else \
			echo "Directory $$dir does not exist, skipping."; \
		fi \
	done
