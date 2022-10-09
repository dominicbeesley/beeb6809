#!/usr/bin/perl

use strict;

my $git=`git rev-parse --short HEAD`;
chop $git;
if ( $? != 0) {
	$git=undef;	
}

my $dat=`date`;
chop $dat;
if ($? != 0) {
	$dat=undef;
}

my $free=0;
while(<>) {
	if (/DEF\s*__FREESPACE\s*([0-9A-F]+)/i) {
		$free=hex($1);
		last;
	}
}

my $m="";
if ($free > 32768) {
	$free = 65536-$free;
	$m="-";


	printf STDERR "\n\n\tWARNING: this basic is $free bytes too large\n\n";
}

printf "%s%d\t%s%04X\t%s\t%s\n", $m, $free, $m, $free, $dat, $git;
