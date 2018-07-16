#!/bin/perl

while(<>) {
	chomp;
	$l = $_;
	$l =~ s/\s$//;

	if ($l =~ /^[a-zA-Z0-9_]+$/)
	{
		print "$l\n";
	} elsif ($l =~ /\s+FCB\s+(((\$[0-9A-F][0-9A-F]?)(,|$)){8})/) {
		print "----------\n";
		my $bytes=$1;
		while ($bytes) {
			$bytes =~ /\$([0-9A-F]{1,2})(,|$)(.*)/ or die "Bad FCB entry $bytes";
			my $thsb = $1;
			$bytes = $3;

			my $x = hex($thsb);
			print "|";
			for (my $i=0; $i < 8; $i++) {
				if ($x & 0x80) {
					print "X";
				} else {
					print ".";
				}
				$x = $x << 1;
			}
			print "|\n";
		}
		print "----------\n\n";
	}
}