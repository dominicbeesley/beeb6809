#!/bin/perl
use strict;
use warnings;
use XML::LibXML;

sub Usage {

	while (my $x = shift) {
		print STDERR "$x\n";
	}

	die "
makemaps.pl <in map> <back cuts> <front cuts> <out map bin>\n
		";

}

sub parse_cuts {
	my ($filename) = @_;

	my $dom_cuts = XML::LibXML->new->parse_file($filename);

	my ($de_cuts) = $dom_cuts->documentElement;
	$de_cuts->nodeName eq "cuts" || die "bad root element name ${\$de_cuts->nodeName}";

	# tile sizes
	my $szX = $de_cuts->getAttribute("size-x");
	my $szY = $de_cuts->getAttribute("size-y");

	$szX == 16 || die "bad size-x in cuts";
	$szY == 16 || die "bad size-y in cuts";	


	my $sources = $de_cuts->findnodes("//source");

	$sources->size == 1 || die "Only allowed one source";

	my $source = $sources->get_node(1);

	my $srcSzX = $source->getAttribute("size-x");
	my $srcSzY = $source->getAttribute("size-y");

	my $cols = $srcSzX / $szX;
	my $rows = $srcSzY / $szY;

	$srcSzX > $szX && $srcSzX % $szX == 0 && $srcSzY > $szY && $srcSzY % $szY == 0 || die "source size x/y must be an integer multiple of tile size";

	my @ret;

	#iterate through cuts and make a has of map tile indeces to tile file indeces.

	foreach my $cut ($source->getChildrenByTagName("cut")) {
		my $x = $cut->getAttribute("left-x");
		my $y = $cut->getAttribute("top-y");
		my $tileidx = $cut->getAttribute("index");
		$x % $szX == 0 && $y % $szY == 0 || die "unaligned tile at $x,$y";

		my $idx = 1 + $cols * ($y / $szY) + ($x / $szX);

		@ret[$idx] = {index => $tileidx};
	}

	return (\@ret, $cols, $rows, $szX, $szY);
}

while (scalar @ARGV && $ARGV[0] =~ /^-/) {

	my $sw = shift;

	if ($sw =~ /^-(-?)h/)
	{
		Usage;
	}
	else {
		die "unknown switch $sw";
	}
	
}

if (scalar @ARGV != 4) {
	Usage "Too few arguments"
}

my $fn_inmap=$ARGV[0];
my $fn_backcuts=$ARGV[1];
my $fn_frontcuts=$ARGV[2];
my $fn_out=$ARGV[3];



my $dom_inmap = XML::LibXML->new->parse_file($fn_inmap);

my $layers = $dom_inmap->findnodes("/map/layer");

my $layer_count = $layers->size;

$layer_count == 2 || Usage "Must have exactly 2 layers!";

my $bin='';

for (my $layernum = 1; $layernum <= 2; $layernum++) {
	my ($cuts, $srccols, $srcrows, $srcsizeX, $srcsizeY) = ($layernum==1)?parse_cuts($fn_backcuts):parse_cuts($fn_frontcuts);


	my $layer = $layers->get_node($layernum);

	(	$layer->getAttribute('width') == "32"
	&&  $layer->getAttribute('height') == "32")
		|| Usage "Layer must be 32x32";

	my $data = $layer->findvalue("data");

	# parse map into a 32 rows of 32 cols

	my @lines = split /\n/, $data;
	my $j = 0;
	foreach my $l (@lines) {
		chomp $l;

		if ($l =~ /([0-9]+\(,|$){32}/) {
			my @cols = split /\,/, $l;
			my $i = 0;
			foreach my $ix (@cols) {
				my $b=0x00;
				if ($ix != 0) {
					my $c = $cuts->[$ix];
					if (!$c) {
						my $sr_x = ($ix - 1) % $srccols;
						my $sr_y = int(($ix - 1) / $srccols);
						my $xx = $sr_x * $srcsizeX;
						my $yy = $sr_y * $srcsizeY;
						Usage "Index=$ix (map=($i,$j), src-img=($sr_x, $sr_y) at ($xx, $yy) found in map file, no corresponding tile found in layer $layernum"
					} else {
						$b=$c->{"index"};
					}
				}
				$bin .= chr($b);
				$i++;
			}
			$j++;
		} elsif ($l ne '') {
			Usage("Non-blank line contains bad data $l");
		}
	}

}

open(my $bin_out, '>:raw', $fn_out) or die "Unable to open: $!";
print $bin_out $bin;