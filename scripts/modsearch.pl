#!/bin/perl

use List::Util qw( max );
use Fcntl qw(:seek);

my $filename = shift;

open(IN, "<raw:", $filename) || die "Cannot open $filename";

seek IN, 950, SEEK_SET;

my $bytes;

read(IN, $bytes, 134) == 134 || die "Read past EOF";

my $songlen, $songlen2, @song, @MK;

($songlen, $songlen2, @song[0 .. 127], @MK[0 .. 3]) = unpack("C C C[128] C[4]", $bytes);

my $patmax = max @song[0 .. ($songlen - 1)];

my %eff;

for (my $i = 0; $i <= $patmax; $i++) {
	for (my $j = 0; $j <= 0x3F; $j++) {
		for (my $c = 0; $c < 4; $c++) {
			read(IN, $note, 4) == 4 || die "Read past EOF in note $i $j $c";
			my (@note) = unpack("C*", $note);
			$eff{@note[2] & 0x0F}++;
		}
	}
}


print "$filename";
for (my $i = 0; $i < 16; $i++) {
	print ",$eff{$i}";
}
print "\n";