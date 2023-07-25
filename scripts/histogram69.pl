#!/usr/bin/perl

use strict;

# histogram69.pl - run decode 6809 on a dump file and produce a histogram of 
# code frequencies

# operates on a file produced by decode 6809 with the -airy flags

my %addrs=();
my %addrswicycles=();

while (<>) {
	chomp;
	my $l = $_;
	$l =~ s/[\r\n\s\t]*$//;

	if ($l =~ /^([0-9A-F]{4})\s*:[^:]+:\s*(\d)+/) {

		my $a = hex($1);
		my $c = $2;
		$addrs{$a}++;
		$addrswicycles{$a}+=$c;
	} else {
		print "??? $l ???\n";
	}
}

my $n = 10;

print "Top $n addresses:\n";

top(\%addrs, $n);

print "Top $n addresses with cycles:\n";

top(\%addrswicycles, $n);

sub top($$) {

	my ($h,$n) = @_;

	foreach my $addr ((sort { $h->{$b} <=> $h->{$a} } keys %{$h})[0..$n-1]) {
    		printf "%04X %d * %d\n", $addr, $addrs{$addr}, $addrswicycles{$addr}/$addrs{$addr};
	}


}