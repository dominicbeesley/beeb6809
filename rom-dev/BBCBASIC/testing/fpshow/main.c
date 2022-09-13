#include <math.h>
#include <stdlib.h>
#include <stdio.h>

void usage(const char *msg) {
	if (msg)
		fprintf(stderr, msg);
	fprintf(stderr, "fpshow <EXP> <MANT>\nAs printed by PRINT ~?(TOP+3);" "; ~!(TOP+4) i.e. mantissa is backwards!");
}

int main(int argc, char **argv) {

	if (argc != 3) {
		usage("Wrong number of parameters");
		return 2;
	}

	int exp = strtol(argv[1],NULL,16) & 0xFF;
	long mantr = strtol(argv[2],NULL,16) & 0xFFFFFFFF;

	long mant = 	0x80000000L |
			((mantr & 0xFF000000L) >> 24) |
			((mantr & 0xFF0000L) >> 8) |
			((mantr & 0xFF00L) << 8) |
			((mantr & 0x7FL) << 24);

	int signl = mantr & 0x80;

	long double ret = mant;

	while (exp > 0x80) {
		ret = ret * 2;
		exp--;
	}
	while (exp < 0x80) {
		ret = ret / 2.0;
		exp++;
	}

	ret = ret / 0x100000000;

	if (signl)
		ret = -ret;

	printf("%02X%08X => %.20Lf", exp, mant, ret);

	return 0;
}