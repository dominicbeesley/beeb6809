#!/bin/perl

$minaddr=0xFFFFFF;

while (<>) {
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
		die "Unrecognized SREC line $l";
	}
}

printf "%04X\n", $minaddr;