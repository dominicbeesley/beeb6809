#!/bin/perl

# state = 0 waiting for blank lines or start of block, 1..8, in block, 9 waiting for end -----------
my $state = 0;


while(<>) {
	chomp;
	$l = $_;
	$l =~ s/\s$//;

	if ($state == 0 && $l =~ /^[a-zA-Z0-9_]+$/)
	{
		print "$l\n";
	} 
	elsif ($state == 0 && !$l)
	{
		print "\n";
	}
	elsif ($state == 0 && $l =~ /^----------$/) 
	{
		print "\t\tFCB\t";
		$state = 1;
	} 
	elsif ($state >=1 && $state <=8) 
	{
		$l =~ /^\s*\|([X\.]{8})\|\s*$/ or die "Bad bitmap line $l";

		my $bits=$1;
		if ($state > 1)
		{
			print ",";
		}

		my $byte=0;
		for (my $i=0; $i < 8; $i++) {
			$byte = $byte << 1;
			if (substr($bits, $i, 1) eq "X")
			{
				$byte = $byte | 1;
			}
		}

		printf "\$%02.02X", $byte;

		$state = $state + 1
	} 
	elsif ($state == 9) 
	{
		$l =~ /----------/ or die "expecting ---------- got $l";
		print "\n";
		$state = 0;
	} 
	else 
	{
		die "state=$state unexpected $l";
	}
}