
TARGETS=
TARGETS_EXTRA=	mon-noice-6309-chipkit.bin \
		mon-noice-6309-chipkit-ovr.ovr \
		mon-noice-6309-beeb.bin \
		mon-noice-6309-beeb-ovr.ovr \
		mon-noice-6809-beeb.bin \
		mon-noice-6809-beeb-ovr.ovr \
		mon-noice-my-6309-beeb.bin \
		mon-noice-my-6309-beeb-ovr.ovr \
		mon-noice-my-6809-beeb.bin \
		mon-noice-my-6809-beeb-ovr.ovr \
		mon-noice-6309-beeb-flex-ovr.ovr \
		mon-noice-6309-beeb-debug.ovr
CLEAN_EXTRA=	mon-noice-6309-chipkit.bin \
		mon-noice-6309-chipkit-ovr.ovr \
		mon-noice-6309-beeb.bin \
		mon-noice-6309-beeb-ovr.ovr \
		mon-noice-6809-beeb.bin \
		mon-noice-6809-beeb-ovr.ovr \
		mon-noice-my-6309-beeb.bin \
		mon-noice-my-6309-beeb-ovr.ovr \
		mon-noice-my-6809-beeb.bin \
		mon-noice-my-6809-beeb-ovr.ovr \
		mon-noice-6309-chipkit.lst \
		mon-noice-6309-chipkit-ovr.lst \
		mon-noice-6309-beeb.lst \
		mon-noice-6309-beeb-ovr.lst \
		mon-noice-6809-beeb.lst \
		mon-noice-6809-beeb-ovr.lst \
		mon-noice-my-6309-beeb.lst \
		mon-noice-my-6309-beeb-ovr.lst \
		mon-noice-my-6809-beeb.lst \
		mon-noice-my-6809-beeb-ovr.lst \
		mon-noice-6309-beeb-flex-ovr.ovr \
		mon-noice-6309-beeb-flex-ovr.lst \
		mon-noice-6309-beeb-debug.ovr \
		mon-noice-6309-beeb-debug.lst
include		../../../Makefile.defs


DEPS=../../../includes/hardware.inc ../../../includes/common.inc ../../../includes/mosrom.inc ../../../includes/noice.inc 

#-sa is the stand alone debugger ROM image
#-ovr is the overlay to be included in the NOICE hole in the MOS rom


mon-noice-6309-chipkit.bin:	mon-noice-6x09.asm $(DEPS)
			$(AS) -v -3 --define DO_ROMLATCH=1 --define NOICE_RAM_START=0xA00 --define CPU_6309=1 --define MACH_CHIPKIT=1 --define STANDALONE=1 -o $@ -l $(basename $@).lst $<

mon-noice-6309-chipkit-ovr.ovr:	mon-noice-6x09.asm $(DEPS)
			$(AS) -v -3 --define DO_ROMLATCH=1 --define NOICE_RAM_START=0xA00 --define CPU_6309=1 --define MACH_CHIPKIT=1 --define STANDALONE=0 -o $@ -l $(basename $@).lst $<

mon-noice-6309-beeb.bin:	mon-noice-6x09.asm $(DEPS)
			$(AS) -v -3 --define DO_ROMLATCH=1 --define NOICE_RAM_START=0xA00 --define CPU_6309=1 --define MACH_BEEB=1 --define STANDALONE=1 -o $@ -l $(basename $@).lst $<

mon-noice-6309-beeb-ovr.ovr:	mon-noice-6x09.asm $(DEPS)
			$(AS) -v -3 --define DO_ROMLATCH=1 --define NOICE_RAM_START=0xA00 --define CPU_6309=1 --define MACH_BEEB=1 --define STANDALONE=0 -o $@ -l $(basename $@).lst $<

mon-noice-6809-beeb.bin:	mon-noice-6x09.asm $(DEPS)
			$(AS) -v --define DO_ROMLATCH=1 --define NOICE_RAM_START=0xA00 --define CPU_6809=1 --define MACH_BEEB=1 --define STANDALONE=1 -o $@ -l $(basename $@).lst $<

mon-noice-6809-beeb-ovr.ovr:	mon-noice-6x09.asm $(DEPS)
			$(AS) -v --define DO_ROMLATCH=1 --define NOICE_RAM_START=0xA00 --define CPU_6809=1 --define MACH_BEEB=1 --define STANDALONE=0 -o $@ -l $(basename $@).lst $<

mon-noice-6309-beeb-flex-ovr.ovr:	mon-noice-6x09.asm $(DEPS)
			$(AS) -v -3 --define DO_ROMLATCH=0 --define NOICE_RAM_START=0xE000 --define CPU_6309=1 --define MACH_BEEB=1 --define STANDALONE=0 -o $@ -l $(basename $@).lst $<

mon-noice-6309-beeb-debug.ovr: mon-noice-6x09.asm $(DEPS)
	$(AS) -v -3 \
	--define DO_ROMLATCH=1 \
	--define NOICE_DEBUG_MEMMAP=1 \
	--define NOICE_RAM_START=0xC000 \
	--define NOICE_CODE_BASE=0xF100 \
	--define NOICE_CODE_BASE_PUT=0xB100 \
	--define NOICE_CODE_LEN=0x500 \
	--define NOICE_DEBUG_CODE_BOUNCE=0x100 \
	--define CPU_6309=1 \
	--define MACH_BEEB=1 \
	--define STANDALONE=0  \
	-o $@ -l $(basename $@).lst $<



mon-noice-my-6309-beeb.bin:	mon-noice-6x09.asm $(DEPS)
			$(AS) -v -3 --define NOICE_MY=1 --define NOICE_RAM_START=0xA00 --define DO_ROMLATCH=1 --define CPU_6309=1 --define MACH_BEEB=1 --define STANDALONE=1 -o $@ -l $(basename $@).lst $<

mon-noice-my-6309-beeb-ovr.ovr:	mon-noice-6x09.asm $(DEPS)
			$(AS) -v -3 --define NOICE_MY=1 --define NOICE_RAM_START=0xA00 --define DO_ROMLATCH=1 --define CPU_6309=1 --define MACH_BEEB=1 --define STANDALONE=0 -o $@ -l $(basename $@).lst $<

mon-noice-my-6809-beeb.bin:	mon-noice-6x09.asm $(DEPS)
			$(AS) -v --define NOICE_MY=1 --define NOICE_RAM_START=0xA00 --define DO_ROMLATCH=1 --define CPU_6809=1 --define MACH_BEEB=1 --define STANDALONE=1 -o $@ -l $(basename $@).lst $<

mon-noice-my-6809-beeb-ovr.ovr:	mon-noice-6x09.asm $(DEPS)
			$(AS) -v --define NOICE_MY=1 --define NOICE_RAM_START=0xA00 --define DO_ROMLATCH=1 --define CPU_6809=1 --define MACH_BEEB=1 --define STANDALONE=0 -o $@ -l $(basename $@).lst $<

