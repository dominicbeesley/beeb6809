#!/bin/perl

use strict;

my $bem=0;
my $rompre=-1;

while (@ARGV[0] =~ /^-/) {
	my $swi = shift;
	if ($swi eq '-bem') {
		$bem=1;
	} elsif ($swi eq -rom) {
		$rompre = hex(shift);
	} else {
		die "Unrecognized switch '$swi'";
	}
}

while (<>) {
	my $l = $_;
	chomp $l;

	if ($l =~ /^([0-9A-F]{1,4})\s{2}(.*)/i)
	{
		my $addr=hex($1);
		$l = $2;
		$l =~ s/^.{16}//i;

		$l =~ s/^([0-9A-F]{2})+\s//i;

		my $naddr;
		if ($rompre>=0 && $addr >=0x8000 && $addr <= 0xBFFF) {
			$naddr = sprintf("%X:%04X",$rompre,$addr);
		} else {
			$naddr = sprintf("%04X",$addr);
		}

		if ($l =~ /^([A-Z_][0-9A-Z_]*)(\s+|$)/i) {
			if ($bem) {
				print "symbol $1=$naddr\n";
			} else {
				print "DEF $1 $naddr\n";				
			}
		}
	}
}