#!/bin/perl

# TODO: add modes:
#	- im16
#	- im32


use strict;

my $do6309=0;
my $target=0;
my $save;
my $chain;

while (@ARGV[0] =~ /^-/) {
	my $sw = shift;
	if ($sw eq '--help' || $sw eq '-?') {
		usage(*stdout);
		exit 0;
	} elsif ($sw eq '-3' || $sw eq '--6309') {
		$do6309 = 1;
	} elsif ($sw eq '-B' || $sw eq '--emit') {
		$target = 1;
	} elsif ($sw eq '-A' || $sw eq '--asm') {
		$target = 2;
	} elsif ($sw eq '-S' || $sw eq '--save') {
		$save = shift;
	} elsif ($sw eq '-C' || $sw eq '--chain') {
		$chain = shift;
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
	-B|--emit	generate emit BASIC assembler
	-A|--asm	generate XRoar assembler
	-S|--save	filename to save at end of BBC assembly
";
}

my @regs;

if ($do6309) {
	@regs = qw/D X Y U S PC A B CC DP V 0 W E F/;
} else {
	@regs = qw/D X Y U S PC A B CC DP/;
}

my @skregs = qw/PC @ Y X DP B A CC/;

my @tfmregs = qw/D X Y U S/;

my $first;
my $bbc_ct;

my $cmt = ($target==1)?"\\ ":"* ";

my $hexpre = ($target == 1)?"&":"\$";

my ($fnin, $fnout) = @ARGV;


open (my $fhin, "<", $fnin) or die "Cannot open $fnin for input : $!";
open (my $fhout, ">", $fnout) or die "Cannot open $fnout for output : $!";

my @instr=();

while (<$fhin>) {
	my $l = $_;
	$l =~ s/[\r\n\s]+$//;
	$l =~ s/#.*//;

	if ($l =~ /^(\w+\*?%?)(\s+((\w\w)(\s*,\s*\w\w)*)?)?\s*$/) {
		my ($op,$smodes) = ($1,$3);

		my @modes = split(/\s*,\s*/, $smodes);

		my @op2 = ();

		if ($op =~ /^(\w+)%$/) {
			# special for AIM# etc
			$op = $1;
			push @op2, "$op #${hexpre}AA,";
			push @op2, "$op #${hexpre}55,";
			push @op2, "$op #C_DP,";
		} else {
			push @op2, $op;
		}

		for my $op3 (@op2) {
			push @instr, {
				op => $op3,
				modes => \@modes
			};
		}
	} else {
		$l =~ /^\s*$/ or die "Syntax error: $l";
	}
}


if ($target == 1) {
	#emit
	print $fhout "IFTOP>&5000:PRINT \"TOO BIG\":STOP\n";
	print $fhout "HIMEM=&5000\n";
	print $fhout "C_DP=0:C_DP2=&FF:C_DP3=12:C_EX=&1234:C_EX2=&ABCD\n";
	print $fhout "P%=&5000:[OPT";
	print $fhout $do6309?"&13":"3";
	print $fhout "\n";
} else {
	print $fhout "\t\tORG \$5000\n";
	print $fhout "C_DP\tEQU\t0\n";
	print $fhout "C_DP2\tEQU\t\$FF\n";
	print $fhout "C_DP3\tEQU\t12\n";
	print $fhout "C_EX\tEQU\t\$1234\n";
	print $fhout "C_EX2\tEQU\t\$ABCD\n";
}


for my $op (@instr) {
	my @modes = @{$op->{modes}};
	my $mne = $op->{op};
	$first = 1;
	$bbc_ct = 0;
	if (!scalar @modes) {
		emit($mne);
	} else {
		for my $m (@modes) {

			if ($m eq "dp") {
				emit($mne,"<&AA");
				emit($mne,"<&55");
				emit($mne,"C_DP");
			} elsif ($m eq "ex") {
				emit($mne,"&AA55");
				emit($mne,"&55AA");
				emit($mne,"C_EX");
				emit($mne,">&AA55");
				emit($mne,">&55AA");
				emit($mne,"C_EX2");
			} elsif ($m eq "im") {
				emit($mne,"#&66");
				emit($mne,"#C_DP");
			} elsif ($m eq "ix") {
				emit_ix_z($mne);
				emit_ix_r_o($mne,"X",-1);
				emit_ix_r_o($mne,"Y",1);
				emit_ix_r_o($mne,"U",-16);
				emit_ix_r_o($mne,"S",16);
				emit_ix_r_o($mne,"X",-99);
				emit_ix_r_o($mne,"Y",99);
				emit_ix_r_o($mne,"U",-1600);
				emit_ix_r_o($mne,"S",1600);
				emit_ix_r_o($mne,"U","-C_DP3");
				emit_ix_r_o($mne,"S","C_DP3");
				emit_ix_r_o($mne,"S","A");
				emit_ix_r_o($mne,"U","B");
				emit_ix_r_o($mne,"X","D");
				emit_ix_r_o($mne,"Y","d");
				emit($mne,",X+");
				emit($mne,",Y++");
				emit($mne,"[,U++]");
				emit($mne,",-X");
				emit($mne,",--Y");
				emit($mne,"[,--U]");
				emit($mne,"-&55,PCR");
				emit($mne,"&AA,PCR");
				emit($mne,"-C_DP3,PCR");
				emit($mne,"C_DP3,PCR");
				emit($mne,"-C_EX,PCR");
				emit($mne,"C_EX,PCR");
				emit($mne,"\[&AAA]");
				emit($mne,"\[C_EX]");
				emit($mne,"A,X");
				emit($mne,"B,Y");
				emit($mne,"D,U");
				emit($mne,"\[A,S]");
				emit($mne,"\[B,X]");
				emit($mne,"\[D,U]");
#				if ($do6309) {
#					emit($mne,"E,X");
#					emit($mne,"F,Y");
#					emit($mne,"W,U");
#					emit($mne,"\[E,S]");
#					emit($mne,"\[F,X]");
#					emit($mne,"\[W,U]");
#				}
			} elsif ($m eq "re") {
				emit($mne,"*-10");
				emit($mne,"*+10");
				emit("L$mne","*-1000");
				emit("L$mne","*+1000");					
			} elsif ($m eq "rr") {
				for my $r1 (@regs) {
					for my $r2 (@regs) {
						emit($mne,"$r1,$r2");
					}
				}
			} elsif ($m eq "sk") {
				emit_sk($mne,0x01);
				emit_sk($mne,0x02);
				emit_sk($mne,0x04);
				emit_sk($mne,0x08);
				emit_sk($mne,0x10);
				emit_sk($mne,0x20);
				emit_sk($mne,0x40);
				emit_sk($mne,0x80);
				emit_sk($mne,0xFF);
				emit_sk($mne,0x12);
				emit_sk($mne,0x34);
				emit_sk($mne,0x76);
				emit_sk($mne,0x67);
			} elsif ($m eq "tt") {
				for my $r1 (@tfmregs) {
					for my $r2 (@tfmregs) {
						emit($mne,"$r1+,$r2+");
						emit($mne,"$r1-,$r2-");
						emit($mne,"$r1+,$r2");
						emit($mne,"$r1,$r2+");
					}
				}
			} elsif ($m eq "bb") {
				printf fhout "$cmt skipped mode bb";				
			} else {
				die "Unimplemented mode $m in $op";
			}
		}
	}
	print $fhout "\n";
}


if ($target == 1) {
	print $fhout "\]\n";
	if ($save) {
		print $fhout "OSCLI(\"SAVE $save 5000+\"+STR\$~(P%-&5000))\n";
	}
	if ($chain) {
		print $fhout "CHAIN\"$chain\"\n";
	}
}

sub emit_sk($$) {
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


	emit($mne,join(",",@regs));
}


sub emit_ix_z($) {
	my ($mne) = @_;
	emit_ix_z_r($mne, "S");
	emit_ix_z_r($mne, "U");
	emit_ix_z_r($mne, "X");
	emit_ix_z_r($mne, "Y");
}

sub emit_ix_z_r($$) {
	my ($mne, $r) = @_;
	emit($mne,",$r");
	emit($mne,"0,$r");
	emit($mne,"[,$r]");
	emit($mne,"\[0,$r]");
	emit($mne,"[0,$r]");
}

sub emit_ix_r_o($$) {
	my ($mne, $r,$o) = @_;
	emit($mne,"$o,$r");
	emit($mne,"\[$o,$r]");
}


sub emit($$) {
	my ($i,$o) = @_;
	if ($target == 1) {
		$o =~ s/\*/P%/g;
		my $l = length($i) + ($o?1+length($o):0) + 1;
		if ($bbc_ct + $l > 200) {
			$bbc_ct = 0;
			print $fhout "\n";
		} else {
			$bbc_ct += $l;
			print $fhout $first?"":":";
			$first = 0;
		}
		if ($o) {
			print $fhout "$i $o";
		} else {
			print $fhout "$i";
		}
	} else {
		$o =~ s/&/\$/g;
		if ($o) {
			print $fhout "\t\t$i\t$o\n";
		} else {
			print $fhout "\t\t$i\n";
		}
	}

}