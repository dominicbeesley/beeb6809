#!/bin/perl

use strict;

my $do6309=0;
my $target=0;

while (@ARGV[0] =~ /^-/) {
	my $sw = shift;
	if ($sw eq '--help' || $sw eq '-?') {
		usage(*stdout);
		exit 0;
	} elsif ($sw eq '-3' || $sw eq '--6309') {
		$do6309 = 1;
	} elsif ($sw eq '-B' || $sw eq '--bbc') {
		$target = 1;
	} elsif ($sw eq '-A' || $sw eq '--asm') {
		$target = 2;
	} else {
		usage(*stderr);
		die "Bad command line option \"$sw\"";
	}
}

if (!$target) {
	usage(*stderr);
	die "Must specify target";
}

if (scalar @ARGV != 2) {
	usage(*stderr);
	die "Incorrect number of arguments";
}


sub usage($) {
	my ($fh) = @_;

	print $fh "mkasmtest.pl [options] <in> <out>

Options:
	-3|--6309	include 6309 only instructions
	-B|--bbc	generate BBC BASIC assembler
	-A|--asm	generate XRoar assembler

";
}

my ($fnin, $fnout) = @ARGV;


open (my $fhin, "<", $fnin) or die "Cannot open $fnin for input : $!";
open (my $fhout, ">", $fnout) or die "Cannot open $fnout for output : $!";

my @instr=();

while (<$fhin>) {
	my $l = $_;
	$l =~ s/[\r\n\s]+$//;

	if ($l =~ /^#/) {
		#comment!
	} elsif ($l =~ /^(\w+\*?)(\s+((\w\w)(\s*,\s*\w\w)*)?)?/) {
		my ($op,$smodes) = ($1,$3);

		my @modes = split(/\s*,\s*/, $smodes);

		push @instr, {
			op => $op,
			modes => \@modes
		};
	} else {
		$l =~ /^\s*$/ or die "Syntax error";
	}
}

my @regs = qw/D X Y U S PC A B CC DP/;

my @skregs = qw/PC @ Y X DP B A CC/;

my $first;
my $bbc_ct;


if ($target == 1) {
	#BBC

	print $fhout "DP%=0:DP2%=&FF:DP3%=12:EX%=&1234:EX2%=&ABCD\n";
	print $fhout "P%=&4000:[OPT";
	print $fhout $do6309?"&13":"3";
	print $fhout "\n";


	for my $op (@instr) {
		my @modes = @{$op->{modes}};
		my $mne = $op->{op};
		$first = 1;
		$bbc_ct = 0;
		if (!scalar @modes) {
			bbc("$mne");
		} else {
			for my $m (@modes) {

				if ($m eq "dp") {
					bbc("$mne<&AA");
					bbc("$mne<&55");
					bbc("$mne DP%");
				} elsif ($m eq "ex") {
					bbc("$mne&AA55");
					bbc("$mne&55AA");
					bbc("$mne EX%");
					bbc("$mne>&AA55");
					bbc("$mne>&55AA");
					bbc("$mne EX2%");
				} elsif ($m eq "im") {
					bbc("$mne#&66");
					bbc("$mne#DP%");
				} elsif ($m eq "ix") {
					bbc_ix_z($mne);
					bbc_ix_r_o($mne,"X",-1);
					bbc_ix_r_o($mne,"Y",1);
					bbc_ix_r_o($mne,"U",-16);
					bbc_ix_r_o($mne,"S",16);
					bbc_ix_r_o($mne,"X",-99);
					bbc_ix_r_o($mne,"Y",99);
					bbc_ix_r_o($mne,"U",-1600);
					bbc_ix_r_o($mne,"S",1600);
					bbc_ix_r_o($mne,"U","-DP3%");
					bbc_ix_r_o($mne,"S","DP3%");
					bbc_ix_r_o($mne,"S","A");
					bbc_ix_r_o($mne,"U","B");
					bbc_ix_r_o($mne,"X","D");
					bbc_ix_r_o($mne,"Y","d");
					bbc("$mne ,X+");
					bbc("$mne ,Y++");
					bbc("$mne [,U++]");
					bbc("$mne ,-X");
					bbc("$mne ,--Y");
					bbc("$mne [,--U]");
					bbc("$mne-&55,PCR");
					bbc("$mne &AA,PCR");
					bbc("$mne-DP3%,PCR");
					bbc("${mne}DP3%,PCR");
					bbc("$mne-EX%,PCR");
					bbc("${mne}EX%,PCR");
					bbc("$mne\[&AAA]");
					bbc("$mne\[EX%]");
				} elsif ($m eq "re") {
					bbc("$mne P%-10");
					bbc("$mne P%+10");
					bbc("L$mne P%-1000");
					bbc("L$mne P%+1000");					
				} elsif ($m eq "rr") {
					for my $r1 (@regs) {
						for my $r2 (@regs) {
							bbc("$mne$r1,$r2");
						}
					}
				} elsif ($m eq "sk") {
					bbc_sk($mne,0x01);
					bbc_sk($mne,0x02);
					bbc_sk($mne,0x04);
					bbc_sk($mne,0x08);
					bbc_sk($mne,0x10);
					bbc_sk($mne,0x20);
					bbc_sk($mne,0x40);
					bbc_sk($mne,0x80);
					bbc_sk($mne,0xFF);
					bbc_sk($mne,0x12);
					bbc_sk($mne,0x34);
					bbc_sk($mne,0x76);
					bbc_sk($mne,0x67);
				} else {
					die "Unimplemented mode $m in $op";
				}
			}
		}
		print $fhout "\n";
	}
}

sub bbc_sk($$) {
	my ($mne, $bits) = @_;
	my $m = 1;
	my $i = 0;
	my @regs = ();
	while ($m < 0x100) {
		if ($m & $bits) {
			my $x = @skregs[$i];
			if ($x eq '@') {
				if ($mne =~ /\w+S$/) {
					$x = 'U';
				} else {
					$x = 'S';
				}
			}

			push @regs, $x;			
		}
		$m = $m << 1;
		$i++;
	}


	bbc($mne . join(",",@regs));
}


sub bbc_ix_z($) {
	my ($mne) = @_;
	bbc_ix_z_r($mne, "S");
	bbc_ix_z_r($mne, "U");
	bbc_ix_z_r($mne, "X");
	bbc_ix_z_r($mne, "Y");
}

sub bbc_ix_z_r($$) {
	my ($mne, $r) = @_;
	bbc("$mne,$r");
	bbc("${mne}0,$r");
	bbc("${mne} 0,$r");
	bbc("$mne\[,$r]");
	bbc("${mne}\[0,$r]");
	bbc("${mne} [0,$r]");
}

sub bbc_ix_r_o($$) {
	my ($mne, $r,$o) = @_;
	bbc("${mne}$o,$r");
	bbc("${mne}\[$o,$r]");
}


sub bbc($) {
	my ($i) = @_;
	if ($bbc_ct + length($i) + 1 > 200) {
		$bbc_ct = 0;
		print $fhout "\n";
		$first = 1;
	} else {
		$bbc_ct += length($i) + 1;
		print $fhout $first?"":":";
		$first = 0;
	}
	print $fhout $i;
}