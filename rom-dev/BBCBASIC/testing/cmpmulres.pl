#!/usr/bin/perl

use strict;
use Math::LongDouble qw(LDtoSTR fabs_LD);


my $arg_fn1 = shift;
my $arg_fn2 = shift;

$arg_fn1 && $arg_fn2 || die "Too few arguments";

scalar @ARGV == 0 || die "Too many arguments";

open (my $fh_1, "<", $arg_fn1) or die "Cannot open $arg_fn1 for input: $!";
open (my $fh_2, "<", $arg_fn2) or die "Cannot open $arg_fn2 for input: $!";

while (!eof($fh_1) && !eof($fh_2)) {

	my $l_1 = get($fh_1);
	my $l_2 = get($fh_2);

	if ($l_1 && $l_2) {

		my ($a1,$b1,$c1) = vals($l_1);
		my ($a2,$b2,$c2) = vals($l_2);
		$a1 or die "Bad format at line $l_1 in file #1";
		$a2 or die "Bad format at line $l_2 in file #2";

		($a1 ne $a2) && die "Mismatched inputs $a1 != $a2";
		($b1 ne $b2) && die "Mismatched inputs $b1 != $b2";

		$c1 ne $c2 && gotone($a1, $b1, $c1, $c2);
	}
}


sub get($) {
	my ($fh) = @_;

	while (<$fh>) {
		my $l = $_;
		$l =~ s/^[\r\n\t\s]*//;
		$l =~ s/[\r\n\t\s]*$//;
		if ($l)
		{
			return $l;
		}
	}

	return undef;
}

sub vals($) {
	my ($l) = @_;

	$l =~ /^([0-9A-F]{1,2}\s+[0-9A-F]+)\s+([0-9A-F]{1,2}\s+[0-9A-F]+)\s+([0-9A-F]{1,2}\s+[0-9A-F]+)$/ or return (undef,undef,undef);

	return ($1,$2,$3);

}

sub gotone($$$$) {
	my ($a,$b,$c1,$c2) = @_;

	print "$a * $b diff $c1 != $c2\n";

	my ($la, $lb, $lc1, $lc2) = (hex2ld($a), hex2ld($b), hex2ld($c1), hex2ld($c2));

	my $lc0 = $la*$lb;

	my $err1 = Math::LongDouble->new(0);
	my $err2 = Math::LongDouble->new(0);
	fabs_LD($err1, $lc1-$lc0);
	fabs_LD($err2, $lc2-$lc0);

	printf "%s * %s = \n", LDtoSTR($la), LDtoSTR($lb);
	printf "   1: %s err = %s\n",LDtoSTR($lc1), LDtoSTR($err1);
	printf "   2: %s err = %s\n",LDtoSTR($lc2), LDtoSTR($err2);
	printf "    : %s\n",LDtoSTR($lc0);
	printf "      %s\n\n", ($err1<$err2)?"1 wins":"2 wins";
}

sub hex2ld($) {
	my ($v) = @_;

	$v =~ /([0-9A-F]{1,2})\s+([0-9A-F]+)/ or die "unex format error in hex2ld : $v";

	my $d_exp = hex($1);
	my $d_mant = hex(join("", reverse ( sprintf("%08X", hex($2)) =~ m/../g ) ));
	my $sgn = $d_mant & 0x80000000;

	my $d1 = Math::LongDouble->new(0x80000000 | $d_mant);
	$d1 = $d1 / Math::LongDouble->new(0x100000000);

	while ($d_exp > 0x80) {
		$d1 = $d1 * 2;
		$d_exp--;
	}
	while ($d_exp < 0x80) {
		$d1 = $d1 / 2;
		$d_exp++;
	}


	if ($sgn) {
		$d1 = -$d1;
	}

	return $d1;
}