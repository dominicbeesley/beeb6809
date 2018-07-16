#!/bin/perl

use strict;

my $tokcount = 0;
my $tokhict = 0;
my $tokloct = 0;

my @tokencodes = ();

my $state = 0;	# state 0 = waiting for --LOBYTES, 1 processing hibyts, 2 processing low bytes

while (<>) {

	chop;
	chomp;
	s/[\r\n]$//;

	if ($state == 0) {
		if (/^\-\-LOBYTES/) {
			$state = 1;
			print STDERR "STATE 1\n";
		} 
	} elsif ($state == 1) {
		if (/^\s*;?\s*\.byte\s*\$([0-9A-F]{2})/) {
			@tokencodes[$tokhict++] = hex($1);	
		} elsif (/^--HIBYTES/) {
			$state = 2;
			print STDERR "STATE 2\n";
		}
	} elsif ($state == 2) {
		if (/^\s*;?\s*\.byte\s*\$([0-9A-F]{2})/) {
			@tokencodes[$tokloct++] |= hex($1)<<8;	
		} 
	}

}

$tokhict == $tokloct or die "mismatched number of lo/hi token bytes";

$tokcount = $tokhict;

for (my $j=0; $j < 2; $j++) {
for (my $i=0; $i < $tokcount; $i++) {
	my ($a,$b,$c);
	my $t = @tokencodes[$i];
	$a = 0x40 | (($t >> 10) & 0x1F);
	$b = 0x40 | (($t >> 5) & 0x1F);
	$c = 0x40 | (($t >> 0) & 0x1F);

	my $tok = chr($a) . chr($b) . chr($c);

	print "\t\tASMOP_" . (($j==0)?"LO":"HI") . "\t\'$tok\'\n";
}
	print "\n\n";

}

print "ASM_TOKEN_COUNT\tEQU\t$tokcount\n";