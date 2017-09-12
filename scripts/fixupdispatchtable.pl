#!/bin/perl



my @lines;

while (my $l = <>) {
	chomp $l;
	$l =~ s/\r//;
	$l =~ s/\n//;
	push @lines, $l;
}

my $intab;
my %fixuplabels;
my %otherlabels;
my %tokFlags;
my %tokNames;

#pass 1 - get token flags
$intab = 0;
foreach my $l (@lines) {
	if ($l =~ /^tblTOKENS:?/) {
		$intab=1;
	} elsif ($intab) {
		if ($l =~ /^;/) {
			$intab=0;				
		} elsif ($l =~ /\s+FCB\s+\"([A-Z]+)\$?\(?\s?\",\s*\$([A-F0-9]{2}),\s*\$([A-F0-9]{2})/i) {
			my $name = $1, $tok = $2, $flags = $3;
			$tokNames{$tok} = $name;
			$tokFlags{$tok} = $flags;
		} else {
			die "unexpected line in table $l"
		}
	} 
}


#pass 2 - get all function names
$intab = 0;
foreach my $l (@lines) {
	if ($l =~ /^tblCmdDispatch:?/) {
		$intab=1;
	} elsif ($intab) {
		if ($l =~ /^;/) {
			$intab=0;			
		} elsif ($l =~ /\s+FDB\s+([A-Z][A-Z0-9_]*)\s+;\s+\$([0-9A-F]{2})\s+\-\s+([^\s]+)/i) {
			my $lbl = $1, $tok = $2, $bbcfn = $3;
			my $name2 = $tokNames{$tok};
			if ($name2)
			{
				$bbcfn = $name2;
			}

			if ($lbl =~ /^L[0-9A-F]{4}/) {
				my $flags = $tokFlags{$tok};
				my $varAssign = $tok =~ /(CF|D0|D1|D2|D3)/;

				if ($varAssign) {
					$bbcfn = "varSet$bbcfn";				
				} else {
					$bbcfn = "fn$bbcfn";
				}

				$flags || die "Cannot find flags for token $tok";
				$fixuplabels{$lbl} = "$bbcfn";
			} else {
				$otherlabels{$lbl} = "$bbcfn";
			}
		} else {
			die "unexpected line in table $l"
		}
	} 
}

sub replab {
	my ($lbl) = @_;
	my $newLbl = $fixuplabels{$lbl};
	if ($newLbl)
	{
		return $newLbl;
	} else {
		return $lbl;
	}
}

#sub repltkn {
#	my ($t) = @_;
#	my $tknlbl = $tokNames{substr($t,1)};
#	if ($tknlbl) {
#		return "#tkn$tknlbl";
#	} else {
#		return "#$t"
#	}
#}

my %tokAlready;
#pass look for missing tknXXX defs
foreach my $l (@lines) {
	if ($l =~ /^tkn([A-Z]+)\s+EQU\s+\$([0-9A-F]{2})\s*$/i) {
		my $lbl = $1, $tok= $2;
		$tokAlready{$tok} = $lbl;
		$tokNames{$tok} = $lbl;
	}
}

#pass - change LXXXX type proc labels keep old name as comment
my $i = 0;

while ($i < scalar @lines) {
	my $l = @lines[$i];
	if ($l =~ /^;?(L[0-9A-F]{4}):?(\s+(.*))?/)
	{
		my $lbl = $1, $rest = $3;
		my $newLbl = $fixuplabels{$lbl};
		#print STDERR "$lbl - $newLbl\n";
		if ($newLbl) {
			splice @lines, $i, 0, "$newLbl\t\t\t; $lbl!\n";
			$i++;
			splice @lines, $i, 0, "\t\t\tTODO_CMD \"$newLbl\"";
			$i++;
			$l = "\t\t\t$rest";
		}
	} elsif ($l =~ /^;?([0-9A-Z][0-9A-Z_]*):?(\s+(.*))?/i) {
		my $lbl = $1, $rest = $3;
		if ($otherlabels{$lbl}) {
			splice @lines, $i, 0, "$lbl\n";
			$i++;
			splice @lines, $i, 0, "\t\t\tTODO_CMD \"$lbl\"";
			$i++;
			$l = "\t\t\t$rest";			
		}
	}

	$l =~ s/(L[0-9A-F]{4})/replab($1)/ge;

#	$l =~ s/#(\$[0-9A-F]{2})(?![0-9A-F])/repltkn($1)/ge;

	@lines[$i++] = $l;
}


#output updated lines
foreach my $l (@lines) {
	print "$l\n";
}

foreach my $t (sort keys %tokNames) {
	my $n = $tokNames{$t};
	if (!$tokAlready{$t}) {
		print "tkn$n\t\t\tEQU \$$t\n";
	}
}