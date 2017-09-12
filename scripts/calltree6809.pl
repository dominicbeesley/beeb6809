#!/bin/perl


my %skipops;
my %branchalwaysops;
my %branchcond;
my %branchsub;

@skipops{ map uc, ("EQU", "FCB", "FDB", "TODO", "TODODEADEND", "SWI", "RTS")} = ();
@branchalwaysops{ map uc, ("BRA", "LBRA", "JMP")} = ();
@branchcond{ map uc, ("BCC", "BCS", "BEQ", "BGE", "BGT", "BHI", "BHS", "BLE", "BLO", "BLS", "BLT", "BMI", "BNE", "BPL", "BVC", "BVS", "LBCC", "LBCS", "LBEQ", "LBGE", "LBGT", "LBHI", "LBHS", "LBLE", "LBLO", "LBLS", "LBLT", "LBMI", "LBNE", "LBPL", "LBVC", "LBVS")} = ();
@branchsub{ map uc, ("JSR", "BSR", "LBSR")} = ();

my $ignorelast=0;
my %addr2lab=();
my %lab2addr=();

my $last_addr_val = -1;

my %addrprevs;


sub getotheraddr {
	my ($op, $mac, $addr) = @_;

	my $sk = 0;
	while ($mac =~ /^(10|11)(.*)/)
	{
		$mac = $2;
		$sk = $sk + 1;
	}

	if ($op =~ /^J/) {
		return $sk + hex(substr($mac, 2, 4))
	} elsif ($op =~ /^LB/) {
		my $a = hex (substr($mac, 2, 4));
		if ($a & 0x8000)
		{
			$a = $a - 0x10000;
		}
		return $sk + ($a + $addr + 3) & 0xFFFF;
	} elsif ($op =~ /^B/) {
		my $a = hex (substr($mac, 2, 2));
		if ($a & 0x80)
		{
			$a = $a - 0x100;
		}
		return $sk + ($a + $addr + 2) & 0xFFFF;
	}
}

sub anysubs {
	foreach my $x (@_) {
		if ($x->{"t"} eq "s") {
			return 1;
		}
	}
	return 0;
}

sub showTree {
	my ($lbl) = @_;

	my %visited=();



	local *showSubTree = sub {
		my ($addr, $indent) = @_;

		if (!exists $visited{$addr}) {

			my @prevads = @{ $addrprevs{$addr} };
			my @labs = @{ $addr2lab{$addr} };

			if (scalar @labs) {
				print ' ' x $indent;

				foreach my $l (@labs) {
					print "$l ";
				}

				printf "%04X\n", $addr;

#				print ' ' x $indent;
#				print '   ===';
#				foreach my $pa (@{ $addrprevs{$addr} }) {
#					printf "%04x ", $pa->{a};
#				}
#				print "\n";
			} 


			$visited{$addr}=1;
			foreach my $pa (@prevads) {
				my $indent2 = $indent;
				if ($pa->{"t"} eq "s")
				{
					$indent2 = $indent + 2;;
				}
				showSubTree($pa->{"a"}, $indent2);
			}
		}
	};

	my $addr = $lab2addr{$lbl};

	if ($addr) 
	{
		printf "%s (%04X)\n", $lbl, $addr;
	} else {
		print "label \"$lbl\" not found\n";
	}

	showSubTree($addr, 1)
}


while (<>) {
	$l = $_;
	chomp $l;

	$l =~ s/\n//g;


	$l =~ s/^([^\*;]+)(.*)/\1/;


	if ($l =~ /^
		([0-9A-F]{4})
		\s{2}
		(.{14})
		(\s{2}|[0-9A-F]{2}([0-9A-F]{2})+\s)
		([a-z][a-z0-9_]*)?
		([0-9]?
		\s+
		([A-Z]*))?/ix)
	{
		my $addr_h = $1, $mac = $2, $label = $5, $op = uc($7);
		my $addr_i = hex($1);

		if ($label) {
			push @{ $addr2lab{$addr_i} }, $label;
			$lab2addr{$label} = $addr_i;
		}

		if (!exists $skipops{$op} || $l =~ /\bPULS[,ABCDXY\s]+PC/) {
#			print "$addr_h => $label => $op\n";

			if (!$ignorelast && $last_addr_val > 0) {
				push @{ $addrprevs{$addr_i} }, { a=> $last_addr_val, t => "e" };
			}

			$ignorelast=0;
			if (exists $branchcond{$op}) {				
				my $other_addr = getotheraddr($op, $mac, $addr_i);
				push @{ $addrprevs{$other_addr} }, { a => $addr_i, t => "b"};
			} elsif (exists $branchalwaysops{$op}) {				
				my $other_addr = getotheraddr($op, $mac, $addr_i);
				push @{ $addrprevs{$other_addr} }, { a => $addr_i, t => "b"};
				$ignorelast=1;
			} elsif (exists $branchsub{$op}) {				
				my $other_addr = getotheraddr($op, $mac, $addr_i);
				push @{ $addrprevs{$other_addr} }, { a => $addr_i, t => "s"};
			} else {
#				print ":::$op\n";
			}
		} else {
			$ignorelast = 1;
		}

		$last_addr_val = $addr_i;
	}

}

#foreach my $i (keys %lab2addr) {
#	print "--|$i|\n";
#}

showTree("evalAtY");
