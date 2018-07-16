#!/bin/perl

$inf=@ARGV[0];
$ouf=@ARGV[1];

$minaddr=0xFFFFFFFF;

print STDERR $inf;

open(IN,"<",$inf) or die "cannot open input file $inf";

while (<IN>) {
	$l = $_;
	$l =~ s/^\s+//;
	$l =~ s/[\s\r]+$//;

	if ($l =~ /^S1([0-9A-Z]{2})([0-9A-Z]{4})(([0-9A-Z]{2})+)([0-9A-Z]{2})$/)
	{
		my $len = hex($1);
		my $addr = hex($2);
		my $data = $3;

		if ($addr < $minaddr)
		{
			$minaddr = $addr;
		}		

	} elsif ($l) {
		die "Unrecognised SREC line $l";
	}
}

seek IN, 0, 0;

open(OUT,">:raw",$ouf) or die "cannot open output file $ouf";
binmode(OUT);

$lastaddr=$minaddr;

while (<IN>) {
	$l = $_;
	$l =~ s/^\s+//;
	$l =~ s/[\s\r]+$//;

	if ($l =~ /^S1([0-9A-Z]{2})([0-9A-Z]{4})(([0-9A-Z]{2})+)([0-9A-Z]{2})$/)
	{
		my $len = hex($1);
		my $addr = hex($2);
		my $data = $3;

		if ($lastaddr > $addr)
		{
			die "Out of order file $lastaddr > $addr";
		}
		while ($lastaddr < $addr) {
			print OUT chr(0xFF);
			$lastaddr++;
		}
		while ($data =~ /^([0-9A-Z]{2})(.*)$/) {
			my $t = hex($1);
			$data = $2;
			print OUT chr($t);
			$lastaddr++;
		}

	} elsif ($l) {
		die "Unrecognised SREC line $l";
	}
}

if ($minaddr < 0xFFFF0000)
{
	$minaddr = 0xFFFF0000 + $minaddr;
}

printf "%04X\n", "$minaddr";

close IN;
close OUT;