#!/bin/perl

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
			print "DEF $1 $addr\n";
		}
	}
}