TARGETS_BEEB=	test-native-problem-1.hex test-native-problem-1.noi
include		../../Makefile.defs

ASFLAGS=-3 -v

$(BEEBOUT)/test-native-problem-1.noi:	$(BEEBOUT)/test-native-problem-1.hex $(BEEBOUT)/test-native-problem-1.sym
	echo "LOAD $(shell $(WINPATH) "$(BEEBOUT)/test-native-problem-1.hex")" >$(BEEBOUT)/test-native-problem-1.noi
	cat $(BEEBOUT)/test-native-problem-1.sym >>$(BEEBOUT)/test-native-problem-1.noi
	echo "R PC main" >>$(BEEBOUT)/test-native-problem-1.noi
	echo "U main" >>$(BEEBOUT)/test-native-problem-1.noi