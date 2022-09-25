#!/bin/perl

my $bem=0;

while (@ARGV[0] =~ /^-/) {
	my $swi = shift;
	if ($swi eq '-bem') {
		$bem=1;
	} else {
		die "Unrecognized switch '$swi'";
	}
}

while (<>) {
	my $l = $_;
	chomp $l;

	if ($l =~ /^([0-9A-F]{1,4})\s{2}(.*)/i)
	{
		my $addr=$1;
		$l = $2;
		$l =~ s/^.{16}//i;

		$l =~ s/^([0-9A-F]{2})+\s//i;

		if ($l =~ /^([A-Z_][0-9A-Z_]*)(\s+|$)/i) {
			if ($bem) {
				print "symbol $1=$addr\n";
			} else {
				print "DEF $1 $addr\n";				
			}
		}
	}
}