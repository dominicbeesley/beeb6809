#!/bin/perl

use strict;
use FreezeThaw qw(cmpStr freeze);
use Switch;

my $FLAGS_PRE 		= 0x11;
my $FLAGS_PRE_10 	= 0x10;
my $FLAGS_PRE_11 	= 0x11;
my $FLAGS_6309 		= 0x20;
my $FLAGS_EXTRA0 	= 0x40;
my $FLAGS_BOTH		= 0x08;
my $FLAGS_ALWAYS	= 0x80;				# used as end of string marker - doesn't appear in suffix strings
my $FLAGS_16B		= 0x02;				# an register width

#these flags are only used in suffix set to indicate extra bytes
my $FLAGS_SUF_ANY	= 0x0C;
my $FLAGS_SUF_OP	= 0x04;				# an extra op byte follows
my $FLAGS_SUF_MODE	= 0x08;				# an extra mode byte follows

my $ASS_CLSTBL_SIZE	= 0x04;
my $ASS_CLSTBL_OF_IXMAX = 0x00;
my $ASS_CLSTBL_OF_FLAGS = 0x01;
my $ASS_CLSTBL_OF_SUFS  = 0x02;
my $ASS_CLSTBL_OF_MODES = 0x03;

my $ASS_OPTBL_SIZE	= 0x03;
my $ASS_OPTBL_OF_MNE	= 0x00;
my $ASS_OPTBL_OF_OP	= 0x02;


my $MEMPB_SZ16	= 0x40;				# indirect flag
my $MEMPB_SZ8	= 0x20;				# indirect flag
my $MEMPB_IND	= 0x10;				# indirect flag
my $MEMPB_EXT	= 0x08;				# immediate
my $MEMPB_DP	= 0x02;				# immediate
my $MEMPB_IX	= 0x04;				# immediate
my $MEMPB_IMM	= 0x01;				# immediate


my $opt_6309 = 0;

while (@ARGV[0] =~ /^--/) {
	my $opt=shift;
	if ($opt eq "--6309") {
		$opt_6309 = 1;
	} else {
		die "unrecognized option $opt";
	}
}

my $asspre;
if ($opt_6309) {
	$asspre = "6309";
} else {
	$asspre = "6809";
}

scalar @ARGV == 3 or die "Incorrect number of parameters";

my $fn_in=shift;
my $fn_rpt=shift;
my $fn_asm=shift;


-e $fn_in or die "$fn_in doesn't exist";


open(my $fh_in, "<", "$fn_in") or die "$! \"$fn_in\"";
open(my $fh_rpt, ">", "$fn_rpt") or die "$! \"$fn_rpt\"";
open(my $fh_asm, ">", "$fn_asm") or die "$! \"$fn_asm\"";

my @opcodes=();
my @opcodes10=();
my @opcodes11=();

my %class=();

## translate i.e. ADD => ADDR
my %regregops = (
		0x89=>0x31,
		0x84=>0x34,
		0x88=>0x36,
		0x8A=>0x35,
		0x82=>0x33,
		0x8B=>0x30,
		0x81=>0x37,
		0x80=>0x32
	);

## translate i.e. AND => ANDCC
my %CC_ops = (
		0x84=>0x1C,
		0x8A=>0x1A
	);


# when both=1 then a suffix and a mode is required when both=0 then a suffix OR a mode is required

my %classdefs = (
	'A'	=>	{ sufs => '', 				modes => '~' },
	'A1'	=>	{ sufs => 'SYNC', 			modes => '~',		both => 1	},
	'A2'	=>	{ sufs => 'SEXW',			modes => '~',		both => 1	},
	'B'	=>	{ sufs => 'ADC AB*D R',			modes => '# dp ix ex',	both => 1	},
	'B2'	=>	{ sufs => 'ADC AB*D R CC',		modes => '# dp ix ex',	both => 1	},
	'C'	=>	{ sufs => 'ADD ABD*EFW R',		modes => '# dp ix ex',	both => 1 	},
	'D'	=>	{ sufs => '', 				modes => 'dp ix ex',	both => 0,	3 => 1},
	'E'	=>	{ sufs => 'CWAI',			modes => '#',		both => 1	},
	'G'	=>	{ sufs => 'ABD MD', 			modes => '# dp ix ex',	both => 1	},
	'H'	=>	{ sufs => 'ABD*EFW', 			modes => 'dp ix ex',	both => 0	},
	'I'	=>	{ sufs => 'CMP ABDSUXY*EFW R', 		modes => '# dp ix ex', 	both => 1	},
	'J'	=>	{ sufs => 'DQ', 			modes => '# dp ix ex',	both => 1,	3 => 1},
	'K'	=>	{ sufs => '', 				modes => 'r,r'},
	'L'	=>	{ sufs => '', 				modes => 'dp ix ex'},
	'M'	=>	{ sufs => '', 				modes => 'ST dp ix ex'},
	'N'	=>	{ sufs => 'LD ABDSUXY*EFWQ BT MD',	modes => '# dp ix ex', 	both => 1	},
	'P'	=>	{ sufs => 'SUXY', 			modes => 'ix',		both => 1	},
	'Q'	=>	{ sufs => 'AB*DW', 			modes => 'dp ix ex',	both => 0	},
	'R'	=>	{ sufs => 'MULD', 			modes => '~',		both => 1	},
	'S'	=>	{ sufs => 'SU', 			modes => 'W',		both => 1	},
	'T'	=>	{ sufs => 'ST ABDSUXY*EFWQ BT',		modes => 'ST dp ix ex', both => 1	},
	'U'	=>	{ sufs => '', 				modes => 'rel'},
	'F'	=>	{ sufs => 'AB*D', 			modes => 'dp ix ex',	both => 0	},
	'W'	=>	{ sufs => '', 				modes => 'rr.n,qq.k',	both => 1,	3 => 1},
	'W1'	=>	{ sufs => 'BAND',			modes => 'rr.n,qq.k',	both => 1,	3 => 1},
	'W2'	=>	{ sufs => 'BIAND',			modes => 'rr.n,qq.k',	both => 1,	3 => 1},
	'W3'	=>	{ sufs => 'BIOR', 			modes => 'rr.n,qq.k',	both => 1,	3 => 1},
	'W4'	=>	{ sufs => 'BEOR', 			modes => 'rr.n,qq.k',	both => 1,	3 => 1},
	'W5'	=>	{ sufs => 'BIEOR', 			modes => 'rr.n,qq.k',	both => 1,	3 => 1},
	'X'	=>	{ sufs => '', 				modes => 'tfm',				3 => 1},
	'Y'	=>	{ sufs => '23', 			modes => '~',		both => 1	},
	'Z'	=>	{ sufs => 'SUB ABD*EFW R',		modes => '# dp ix ex',	both => 1	},
	'DIR'	=>	{ sufs => '',				modes => '~'}
);

my %modedefs2 = (
	'~' => {
		name => "IMPLIED", 	code => 0x00
	},
	'ix' => {
		name => "INDEXONLY", 	code => 								$MEMPB_IX
	},
	'# dp ix ex' => {
		name => "ANY1",		code =>                           $MEMPB_IND | $MEMPB_EXT | $MEMPB_DP | $MEMPB_IX | $MEMPB_IMM
	},
	'dp ix ex' => {
		name => "MEM1",		code => 	     $MEMPB_SZ8 | $MEMPB_IND | $MEMPB_EXT | $MEMPB_DP | $MEMPB_IX
	},
	'ST dp ix ex' => {
		name => "MEM2",		code => $MEMPB_SZ16                          | $MEMPB_EXT | $MEMPB_DP | $MEMPB_IX | $MEMPB_IMM
	},
	'rel' => {
		name => "REL",		code => 0x80
	},
	'#' => {
		name => "IMMEDONLY", 	code => 0x81	
	},
	'r,r' => {
		name => "REGREG", 	code => 0x82
	},
	'W' => {
		name => "W",		code => 0x83
	},
	'rr.n,qq.k' => {
		name => "BITBIT", 	code => 0x84
	},
	'tfm' => {
		name => "TFM",		code => 0x85
	},
);

my %modedefs = (	
	'~' => [
		{	mode => '~'}
	],
	'#' => [
		{	mode => '#'}
	],
	'ix' => [
		{	mode => 'ix'}
	],
	'r,r' => [
		{	mode => 'r,r'}
	],
	'rr.n,qq.k' => [
		{	mode => 'rr.n,qq.k'}
	],
	'# dp ix ex' => [
		{	mode => '#',			op => 0x00},
		{	mode => 'dp',			op => 0x10},
		{	mode => 'ix',			op => 0x20},
		{	mode => 'ex',			op => 0x30}
	],
	'dp ix ex' => [
		{	mode => 'dp',			op => 0x00},
		{	mode => 'ix',			op => 0x60},
		{	mode => 'ex',			op => 0x70}
	],
	'ST dp ix ex' => [
		{	mode => 'dp',			op => 0x00},
		{	mode => 'ix',			op => 0x10},
		{	mode => 'ex',			op => 0x20}
	],
	'tfm' => [
		{	mode => 'r+,r+',		op => 0x00},
		{	mode => 'r-,r-',		op => 0x01},
		{	mode => 'r+,r',			op => 0x02},
		{	mode => 'r,r+',			op => 0x03}
	],
	'W' => [
		{	mode => 'st',			op => 0x00},
		{	mode => 'W,st',pre => 0x10,	op => 0x04,	3 => '1'}		# "uppercase," mode means treat as 2nd suffix
	],
	'rel' => [
		{	mode => 'rel',},
		{	mode => 'Lrel'}								# special case!
	]
);

my %sufdefs = (

	'BAND'	=> [
		{	suf => 'D'}
	],
	'BIAND'	=> [
		{	suf => 'ND'}
	],
	'BIOR'	=> [
		{	suf => 'R'}
	],
	'BEOR'	=> [
		{	suf => 'R'}
	],
	'BIEOR'	=> [
		{	suf => 'OR'}
	],
	'CWAI' => [
		{	suf => 'I'}
	],
	'SYNC' => [
		{	suf => 'C'}
	],
	'MULD' => [
		{	suf => 'D',	pre => 0x11,	op => 0x8F-0x3D,16 => 1,	3 => 1,		mode => '# dp ix ex'},
		{	suf => ''}
	],
	'ADC AB*D R CC' => [
		{	suf => 'CC',									mode => '#',	opmap => \%CC_ops, opmap_name=>"CC"},
		{	suf => 'R',	pre => 0x10,					3 => 1,		mode => 'r,r',	opmap => \%regregops, opmap_name=>"REGREG"},
		{	suf => 'A'},
		{	suf => 'B',			op => 0x40},
		{	suf => 'D',	pre => 0x10,			16 => 1,	3 => 1}
	],
	'ADC AB*D R' => [
		{	suf => 'R',	pre => 0x10,					3 => 1,		mode => 'r,r',	opmap => \%regregops, opmap_name=>"REGREG"},
		{	suf => 'A'},
		{	suf => 'B',			op => 0x40},
		{	suf => 'D',	pre => 0x10,			16 => 1,	3 => 1}
	],
	'AB*D' => [
		{	suf => 'A',			op => 0x40},
		{	suf => 'B',			op => 0x50},
		{	suf => 'D',	pre => 0x10,	op => 0x40,	16 => 1,	3 => 1}
	],
	'ABD MD' => [
		{	suf => 'MD',	pre => 0x11,	op => 0x3C-0x85,		3 => 1,		mode => '#'},
		{	suf => 'A'},
		{	suf => 'B',			op => 0x40},
		{	suf => 'D',	pre => 0x10,			16 => 1}
	],
	'SUB ABD*EFW R' => [
		{	suf => 'D',			op => 0x03,	16 => 1},
		{	suf => 'A'},
		{	suf => 'B',			op => 0x40},
		{	suf => 'E',	pre => 0x11,					3 => 1},
		{	suf => 'F',	pre => 0x11,	op => 0x40,			3 => 1},
		{	suf => 'W',	pre => 0x10,			16 => 1,	3 => 1},
		{	suf => 'R',	pre => 0x10,					3 => 1,		mode => 'r,r',	opmap => \%regregops, opmap_name=>"REGREG"}
	],
	'ABD*EFW' => [
		{	suf => 'A',			op => 0x40},
		{	suf => 'B',			op => 0x50},
		{	suf => 'D',	pre => 0x10,	op => 0x40,	16 => 1},
		{	suf => 'E',	pre => 0x11,	op => 0x40,			3 => 1},
		{	suf => 'F',	pre => 0x11,	op => 0x50,			3 => 1},
		{	suf => 'W',	pre => 0x10,	op => 0x50,	16 => 1,	3 => 1},
	],
	'LD ABDSUXY*EFWQ BT MD' => [
		{	suf => 'MD',	pre => 0x11,	op => 0x3C-0x85,		3 => 1,		mode => '#'},
		{	suf => 'Q',		pre => 0x10,	op => 0xCD-0x86,		3 => 1},
		{	suf => 'BT',	pre => 0x11,	op => 0x36-0x86,		3 => 1,		mode => 'rr.n,qq.k'},
		{	suf => 'A'},
		{	suf => 'B',			op => 0x40},
		{	suf => 'D',			op => 0x46,	16 => 1},
		{	suf => 'E',	pre => 0x11,					3 => 1},
		{	suf => 'F',	pre => 0x11,	op => 0x40,			3 => 1},
		{	suf => 'W',	pre => 0x10,			16 => 1,	3 => 1},
		{	suf => 'S',	pre => 0x10,	op => 0x48,	16 => 1},
		{	suf => 'U',			op => 0x48,	16 => 1},
		{	suf => 'X',			op => 0x08,	16 => 1},
		{	suf => 'Y',	pre => 0x10,	op => 0x08,	16 => 1},
	],
	'ST ABDSUXY*EFWQ BT' => [
		{	suf => 'Q',	pre => 0x10,	op => 0x46,			3 => 1},
		{	suf => 'BT',	pre => 0x11,	op => 0x37-0x97,		3 => 1,		mode => 'rr.n,qq.k'},
		{	suf => 'A'},
		{	suf => 'B',			op => 0x40},
		{	suf => 'D',			op => 0x46,	16 => 1},
		{	suf => 'E',	pre => 0x11,					3 => 1},
		{	suf => 'F',	pre => 0x11,	op => 0x40,			3 => 1},
		{	suf => 'W',	pre => 0x10,			16 => 1,	3 => 1},
		{	suf => 'S',	pre => 0x10,	op => 0x48,	16 => 1},
		{	suf => 'U',			op => 0x48,	16 => 1},
		{	suf => 'X',			op => 0x08,	16 => 1},
		{	suf => 'Y',	pre => 0x10,	op => 0x08,	16 => 1},
	],
	'CMP ABDSUXY*EFW R' => [
		{	suf => 'S',	pre => 0x11,	op => 0x0B,	16 => 1},
		{	suf => 'U',	pre => 0x11,	op => 0x02,	16 => 1},
		{	suf => 'X',			op => 0x0B,	16 => 1},
		{	suf => 'Y',	pre => 0x10,	op => 0x0B,	16 => 1},
		{	suf => 'D',	pre => 0x10,	op => 0x02,	16 => 1},
		{	suf => 'A'},
		{	suf => 'B',			op => 0x40},
		{	suf => 'E',	pre => 0x11,					3 => 1},
		{	suf => 'F',	pre => 0x11,	op => 0x40,			3 => 1},
		{	suf => 'W',	pre => 0x10,			16 => 1,	3 => 1},
		{	suf => 'R',	pre => 0x10,					3 => 1,		mode => 'r,r',	opmap => \%regregops, opmap_name=>"REGREG"},

	],
	'ADD ABD*EFW R' => [
		{	suf => 'D',			op => 0x38,	16 => 1},
		{	suf => 'A'},
		{	suf => 'B',			op => 0x40},
		{	suf => 'E',	pre => 0x11,					3 => 1},
		{	suf => 'F',	pre => 0x11,	op => 0x40,			3 => 1},
		{	suf => 'W',	pre => 0x10,			16 => 1,	3 => 1},
		{	suf => 'R',	pre => 0x10,					3 => 1,		mode => 'r,r',	opmap => \%regregops, opmap_name=>"REGREG"}
	],	
	'SUXY' => [
		{	suf => 'S',			op => 0x02,	16 => 1},
		{	suf => 'U',			op => 0x03,	16 => 1},
		{	suf => 'X',			op => 0x00,	16 => 1},
		{	suf => 'Y',			op => 0x01,	16 => 1},
	],
	'SU' => [
		{	suf => 'S',			op => 0x00,	16 => 1},
		{	suf => 'U',			op => 0x02,	16 => 1}
	],
	'AB*DW' => [
		{	suf => 'A',			op => 0x40},
		{	suf => 'B',			op => 0x50},
		{	suf => 'D',	pre => 0x10,	op => 0x40,	16 => 1,	3 => 1},
		{	suf => 'W',	pre => 0x10,	op => 0x50,	16 => 1,	3 => 1}
	],
	'DQ' => [
		{	suf => 'D',	pre => 0x11,    op => 0x00,			3 => 1},			# NOTE 8 bit mem 
		{	suf => 'Q',	pre => 0x11,    op => 0x01,	16 => 1,	3 => 1}		
	],
	'23' => [
		{	suf => '2',	pre => 0x10},
		{	suf => '3',	pre => 0x11},
		{	suf => ''}
	],
	'SEXW'  => [
		{	suf => 'W',			op => -0x09,			3 => 1},
		{	suf => ''},
	]
);


#this is used to order sufdefs when calculating subsets
my @sufdeforder = (
	"LD ABDSUXY*EFWQ BT MD",
	"ST ABDSUXY*EFWQ BT",
	"ADC AB*D R CC",
	"ADC AB*D R",
	"ABD MD",
	"BAND",
	"BIEOR",
	"BEOR",
	"SEXW",
	"MULD",
	"SUXY",
	"AB*DW",
	"BIAND",
	"23",
	"DQ",
	"CWAI",
	"ADD ABD*EFW R",
	"SYNC",
	"ABD*EFW",
	"CMP ABDSUXY*EFW R",
	"AB*D",
	"BIOR",
	"SUB ABD*EFW R",
	"SU",
);

sub is_suf_same($$) {
	my ($sa,$sb) = @_;

	return cmpStr($a,$b);

}

sub begins_with
{
    return substr($_[0], 0, length($_[1])) eq $_[1];
}

sub printop {
	my ($op, $suf, $mode, $pre, $code, $b6309) = @_;

	my @ops;


	my $tblent;

	my $mne = $op->{mne};

	my $pren = $op->{pre} + $pre;
	my $opn = $op->{opcode} + $code;

	if ($mode =~ /^Lrel$/) {
		$mne = "L$mne";

		if ($opn == 0x20)
		{
			$opn = 0x16;
		} elsif ($opn == 0x8D) {
			$opn = 0x17;
		} else {
			$pren = 0x10;
		}

		$mode = 'rel16';
	} 


	if ($op->{pre} + $pre) {
		push @ops, sprintf "%02X", $op->{pre} + $pre;
	}
	push @ops, sprintf "%02X", $opn;

	my $opcodes_str = join ' ', @ops;

	if ($mode =~ /^([A-Z]),(.*)/) {
		# mode is uppercase, promote to op-suffix
		my $suf2 = $1;
		$mode = $2;
		printf $fh_rpt "%s%s%s\t%s%s\t%s\n", $mne, $suf, $suf2, $mode, (length $mode <8)?"\t":"", $opcodes_str, ($b6309||$op->{6309})?"*":"";
		$tblent = {
			mne => $mne . $suf . $suf2,
			mode => $mode,
			6309 => $b6309||$op->{6309}
		};
	} else {
		printf $fh_rpt "%s%s\t%s\t%s%s\t%s\n", $mne, $suf, $mode, (length $mode <8)?"\t":"", $opcodes_str, ($b6309||$op->{6309})?"*":"";
		$tblent = {
			mne => $mne . $suf,
			mode => $mode,
			6309 => $b6309||$op->{6309}
		};
	}


	if ($pren == 0x00) {
		@opcodes[$opn] = $tblent;
	} elsif ($pren == 0x10) {		
		@opcodes10[$opn] = $tblent;
	} elsif ($pren == 0x11) {		
		@opcodes11[$opn] = $tblent;
	}
}

sub printoptableent {
	my ($ix, $pre, @tbl) = @_;


	my ($mnem, $flags, $mode);
	if (@tbl[$ix]) {
		$mnem = @tbl[$ix]->{mne};
		$mode = @tbl[$ix]->{mode};
		$flags = (@tbl[$ix]->{6309})?"*":"";
	}

	if ($mnem) {
		return sprintf "| %02.02s%02.02X | %5.5s | %9.9s | %4.4s |", $pre, $ix, $mnem, $mode, $flags;
	} else {
		return sprintf "| %02.02s%02.02X |                          |", $pre, $ix;
	}
}

sub printoptable {
	my ($pre, @tbl) = @_;


	for (my $x=0; $x<256; $x+=0x40) {
		#print header row
		print $fh_rpt "\n\n";
		print $fh_rpt "+------+-------+-----------+------+      +------+-------+-----------+------+\n";
		print $fh_rpt "|   op |  mnem |      mode | 6309 |      |   op |  mnem |      mode | 6309 |\n";
		print $fh_rpt "+------+-------+-----------+------+      +------+-------+-----------+------+\n";

		for (my $y=0; $y < 0x20; $y++) {
		
			print $fh_rpt printoptableent($x+$y, $pre, @tbl);
			print $fh_rpt "      ";
			print $fh_rpt printoptableent($x+$y+0x20, $pre, @tbl);
			print $fh_rpt "\n";
			print $fh_rpt "+------+-------+-----------+------+      +------+-------+-----------+------+\n";	
		}
	}
}

sub OpXlate {
	my (%hash) = @_;

	printf $fh_asm "\t\tfcb\t\$%02.02X\t; size\n", scalar keys %hash;
	printf $fh_asm "\t\t;    org  new\n";
	foreach my $k (sort keys %hash) {
		printf $fh_asm "\t\tfcb\t\$%02.02X, \$%02.02X\n", $k, $hash{$k};
	}
}


my $cur_class="";

my @allmnems=();

while (<$fh_in>) {
	chomp;
	s/[\r\n]+$//;

	if (/^\s*#/) {
		#comment - ignore
	} elsif (/^\s*!!OPCLASS=(\w+)!!\s*$/) {
		$cur_class=$1;
	} elsif (/^\s*$/) {
		#blank line
	} elsif ($cur_class ne '' && /^\s*([\*!]*)([A-Z]{2,3}|SWI2|SWI3)\s*=\s*((10|11)\s+)?([0-9A-F]{2})\s*$/) {
		my $flags = $1;
		my $pre = hex($4);
		my $mne = $2;
		my $opcode = hex($5);
		my $op={ class => $cur_class, pre => $pre, mne => $mne, opcode => $opcode };
		push @{$class{$cur_class}}, $op;
		push @allmnems, $mne;
	} else {
		die "Unrecognized line $_";
	}

}

#check to ensure no clashes in mnemonics
for (my $i=0; $i < scalar @allmnems; $i++) {
	for (my $j=0; $j < scalar @allmnems; $j++) {
		if ($i != $j) {
			if (begins_with(@allmnems[$i], @allmnems[$j])) {
				die "Class between mnemonics @allmnems[$i], @allmnems[$j]";
			}
		}
	}
}

# track which suffixes and modesets are actually in used
my %activesufs = ();	
my %activemodes = ();


foreach my $ck (sort keys %class) {
	my $c = $class{$ck};
	my $cd = $classdefs{$ck} or die "no class def $ck";
	my $sufs = $cd->{sufs};
	my $modes = $cd->{modes};
	my $both = $cd->{both};
	my @sufdef=();
	my @modedef=();

	if ($sufs) {
		@sufdef = @{ $sufdefs{$sufs} } or die "no sufdef \"$sufs\"";
	}

	@modedef = @{ $modedefs{$modes} } or die "no modedef \"$modes\"";

	if (($ck ne "DIR") && ($opt_6309 || !($cd->{3}))) {
		# no directives!

		$activemodes{$modes} = 1;
		if ($sufs) {
			$activesufs{$sufs} = 1;
		}

		print $fh_rpt "############### $ck ###################\n";

		foreach my $op (@{$c}) {
			if (@sufdef && $both) {
				foreach my $r (@sufdef) {
					my @lclmodedef=@modedef;

					
					my $over_mode = $r->{mode};
					if ($over_mode) {

						@lclmodedef = @{ $modedefs{ $over_mode } } or die "no modedef \"$over_mode\"";
					}

					my $opmap_delta=0;


					my %opmap = ();
					if (exists $r->{opmap})
					{
						%opmap = %{ $r->{opmap} };
					}
					if (%opmap && $opmap{$op->{opcode}}) {
						$opmap_delta = $opmap{$op->{opcode}} - $op->{opcode};
					}

					foreach my $m (@lclmodedef) {
						printop $op, $r->{suf}, $m->{mode}, $r->{pre} + $m->{pre}, $r->{op} + $m->{op} + $opmap_delta, $r->{3} | $m->{3} | $cd->{3};
					}

					
				}
			} elsif (@sufdef && (scalar @modedef > 1)) {
				foreach my $r (@sufdef) {
					printop $op, $r->{suf}, '~', $r->{pre}, $r->{op}, $r->{3} | $cd->{3};
				}
				foreach my $m (@modedef) {
					printop $op, '', $m->{mode}, $m->{pre}, $m->{op}, $m->{3} | $cd->{3};
				}

			} else {
				foreach my $m (@modedef) {
					printop $op, '', $m->{mode}, $m->{pre}, $m->{op}, $m->{3} | $cd->{3};
				}
			}
		}
	}
}

printoptable "", @opcodes;
printoptable "10", @opcodes10;
printoptable "11", @opcodes11;

# MAKE "PARSE TABLE"

print $fh_asm "\n\n*********************************************************\n* P A R S E   T A B L E\n*********************************************************\n\n";

print $fh_asm "assParseTbl\n";

my $allbits = 0;


my $ix = 0;

foreach my $ck (sort keys %class) {
	my $c = $class{$ck};
	my $cd = $classdefs{$ck} or die "no class def $ck";
	my $sufs = $cd->{sufs};
	my $modes = $cd->{modes};
	my $both = $cd->{both};
	my @sufdef=();
	my @modedef=();

	if ($sufs) {
		@sufdef = @{ $sufdefs{$sufs} } or die "no sufdef \"$sufs\"";
	}

	if ($modes) {
		@modedef = @{ $modedefs{$modes} } or die "no modedef \"$modes\"";
	}



	if ($opt_6309 || !$cd->{3}) {
		print $fh_asm "\n\t********** $ck **********\n";
		print $fh_asm "assParseTbl_$ck\n";

		foreach my $op (@{$c}) {
			my $mne = $op->{mne};

			my $mnebits = 0;
			my $flagbits = 0;
			foreach my $c (split //, $mne) {
				$mnebits = $mnebits << 5;
				$mnebits |= ord($c) & 0x1F;
			}

			$allbits |= $mnebits;

			my @flags=();

			if ($op->{pre} == 0x10) {
				$flagbits |= $FLAGS_PRE_10;
				push @flags, "PRE_10";
			} elsif ($op->{pre} == 0x11) {
				$flagbits |= $FLAGS_PRE_11;
				push @flags, "PRE_11";
			}

			if ($cd->{3}) {
				$flagbits |= $FLAGS_6309;
				push @flags, "6309";
			}

			printf $fh_asm "assParseTbl_%s\n", $mne;
			printf $fh_asm "assParseTbl_%s_IX\tEQU\t\$%02.02X\n", $mne, $ix;
			printf $fh_asm "\t\tFDB\t\$%04.04X\t\t; [%02.02X] - %s\n", $mnebits, $ix, $mne;
			printf $fh_asm "\t\tFCB\t\$%02.02X\t\t; base op\n", $op->{opcode};

			$ix++;
		}
	}
}
print $fh_asm "\nassParseTbl_END\tFCB\t\$FF\t; end of table marker\n\n";


print $fh_asm "\n\n\n*********************************************************\n* S U F F I X    S E T S   T A B L E\n*********************************************************\n\n";


#check all items in %activesufs are in @sufdefs
for my $k (keys %activesufs)
{
	grep { @sufdeforder[$_] eq $k} 0..$#sufdeforder or die "Missing $k from @sufdeforder";
}

my %sufdef_ixs = ();
my %sufdef_item_ixs = ();
my %sufdef_item_lists = ();
my @sufdef_items;


#make an indexed set of unique suffix defs
#first get them all into suffix order
my %sufs_items_by_suf = ();
foreach my $sd (keys %activesufs) {
	my @sufdefculled = map { ($opt_6309 || !($_->{3}))?$_:() } @{ $sufdefs{$sd} };
	foreach my $sdi (@sufdefculled) {
		my $suf = $sdi->{suf};
		my $sdi_key = freeze $sdi;
		my $x = $sufs_items_by_suf{$suf};
		if ($x) {
			$x->{$sdi_key} = $sdi;
		} else {
			$x={
				$sdi_key => $sdi
			};
			$sufs_items_by_suf{$sdi->{suf}} = $x;
		}
	}
}

my $ix = 1;
foreach my $suf (sort keys %sufs_items_by_suf) {
	my %x = %{ $sufs_items_by_suf{$suf} };
	foreach my $k (sort keys %x) {
		print "--------- $ix $suf [$k] -------------\n";
		my $sdi = $x{$k};
		@sufdef_items[$ix] = $sdi;
		$sufdef_item_ixs{$k} = $ix++;
	}
}


my $sdiix = 1;

print $fh_asm "assSuffSetsTbl\n";

my @existlists = ();

foreach my $sd (@sufdeforder) {
	if (exists $activesufs{$sd}) {

		my @sufs = @{ $sufdefs{$sd} };

		my @curlist = ();

		foreach my $sdi (@sufs) {

			if ($opt_6309 || !($sdi->{3})) {
				my $sdi_key = freeze $sdi;
				my $sdi_ix = $sufdef_item_ixs{$sdi_key};
				$sdi_ix or die "cannot find suf_item_ixs entry for \"$sdi->{suf}\" in $sd [" . $sdi_key . "]";
				push @curlist, $sdi_ix;
			}
		}
		if (scalar @curlist) {
			@curlist[$#curlist] += 0x80;
		}
		else {
			die "unexpected empty suffix set $sd";
		}

		print "$sd => @curlist\n";


		if (scalar @curlist > 1) {

			my $sufstartix = $sdiix;
			my $sufskip = 0;

			# see if this list will fit as a tail of another pre-existing list
			my $found = 0;
FOUND_TAIL:
			foreach my $exl (@existlists) {
				my $ex_ix = $exl->{ix};
				my @ex_lst = @{ $exl->{lst} };

				for (my $j = 0; $j < scalar @curlist - 1; $j++) {
					for (my $i = 0; $i < scalar @ex_lst - 1; $i++) {
						if (@curlist[$j .. $#curlist] ~~ @ex_lst[$i .. $#ex_lst]) {
							print "here $i,$j || @curlist == @ex_lst\n";

							$found = 1;
							$sufstartix = $ex_ix + $i;
							$sufskip = $j;
							last FOUND_TAIL;
						}
					}
				}
			}

			my $hereix = $sufstartix;

			if (!$found) {
				printf $fh_asm "\t\t* SUFLIST [%02.02X] - %s\n", $sdiix, $sd;
				printf $fh_asm "\t\t* " . join(" ", (map { $sufdef_items[$_ & 0x7F]->{suf} } @curlist)) . "\n";
				print $fh_asm "\t\tFCB\t";
				print $fh_asm join(",", (map { sprintf("\$%02.02X", $_) } @curlist));
				print $fh_asm "\n";
				push @existlists, { ix => $sdiix, lst => \@curlist};
				$hereix = $sdiix;
				$sdiix += scalar @curlist;
			} elsif ($sufskip != 0) {
				printf $fh_asm "\t\t* SUFLIST [%02.02X] - %s\n", $sdiix, $sd;
				printf $fh_asm "\t\t* " . join(" ", (map { $sufdef_items[$_ & 0x7F]->{suf} } @curlist[0 .. $sufskip - 1])) . "\n";
				print $fh_asm "\t\tFCB\t";
				print $fh_asm join(",", (map { sprintf("\$%02.02X", $_) } @curlist[0 .. $sufskip - 1]));
				printf $fh_asm ",\$FF,\$%02.02X", $sufstartix;
				print $fh_asm "\n";
				push @existlists, { ix => $sdiix, lst => \@curlist};
				$hereix = $sdiix;
				$sdiix += $sufskip + 2;				
			}

			$hereix > 0x7f && die "X $hereix";


			$sufdef_ixs{$sd} = $hereix;


		} else {
			$sufdef_ixs{$sd} = @curlist[0];
		}
	}
}

print $fh_asm "\n\n\n*********************************************************\n* S U F F I X    I T E M   T A B L E\n*********************************************************\n\n";

print $fh_asm "assSuffItemTbl\n";

my $ix = 1;

print "££££££ " . scalar @sufdef_items . "\n";

for (my $ix = 1; $ix < scalar @sufdef_items; $ix++) {
	my $sdi = @sufdef_items[$ix];
	printf $fh_asm "\t\t* SUFITEM [%02.02X] - %s\n", $ix, $sdi->{suf};
	
	if ($sdi->{suf}) {
		printf $fh_asm "\t\tFCB\t";

		my $fst=1;
		for my $c (split //, $sdi->{suf})
		{
			if ($fst) {
				$fst = 0;
			} else {
				print $fh_asm ",";
			}
			printf $fh_asm "\$%02.02X", ord($c) & 0xDF		# convert to "upper case" - numbers get mangled
		}

		printf $fh_asm "\t; \"%s\"\n", $sdi->{suf};
	} else {
		printf $fh_asm "\t\t\t\t; no suff\n";
	}

	my $flags = $FLAGS_ALWAYS;
	my @flags_str = ();
	my $md2=0;

	if ($sdi->{pre}) {
		$flags |= $sdi->{pre};
		push @flags_str, sprintf "%02.02X", $sdi->{pre};
	}
	if ($sdi->{3}) {
		$flags |= $FLAGS_6309;
		push @flags_str, "6309";
	}
	if ($sdi->{16}) {
		$flags |= $FLAGS_16B;
		push @flags_str, "#16";
	}
	if ($sdi->{op}) {
		$flags |= $FLAGS_SUF_OP;		
		push @flags_str, "SUF-OP";
	}
	if ($sdi->{mode}) {
		$flags |= $FLAGS_SUF_MODE;		
		$md2 = $modedefs2{$sdi->{mode}};
		$md2 or die "No modedefs2 for \"$sdi->{mode}\"";
		push @flags_str, "SUF-MODE";
	}
	if ($sdi->{opmap}) {
		$flags |= $FLAGS_EXTRA0;		
		push @flags_str, "EXTRA0-OPMAP";

	}

	if ($sdi->{opmap_name}) {
		printf $fh_asm "ASS_REGS_%s_IX\tEQU\t\$%02.02X\n", $sdi->{opmap_name}, $ix;
	}

	printf $fh_asm "\t\tFCB\t\$%02.02X\t; FLAGS - %s\n", $flags, join(' ', @flags_str);
	if ($sdi->{op}) {
		printf $fh_asm "\t\tFCB\t\$%02.02X\t; OP\n", $sdi->{op} & 0xFF;
	}
	if ($md2) {
		printf $fh_asm "\t\tFCB\t\$%02.02X\t; MODE %s\n", $md2->{code}, $sdi->{mode};
	}
}


print $fh_asm "\n\n*********************************************************\n* C L A S S   T A B L E\n*********************************************************\n\n";

my $ix = 0;
my $i = 0;
print $fh_asm "assClassTbl\n";

foreach my $ck (sort keys %class) {
	my $c = $class{$ck};
	my $cd = $classdefs{$ck} or die "no class def $ck";
	my $sufs = $cd->{sufs};
	my $modes = $cd->{modes};
	my $both = $cd->{both};
	my @sufdef=();
	my @modedef=();

	my $md2 = $modedefs2{$modes};

	$md2 or die "No modedefs2 entry for \"$modes\"";

	if ($opt_6309 || !$cd->{3}) {

		$ix+=scalar @{ $c };

		# only output for main-line classes not sub-classes
		printf $fh_asm "assClass_%s_ix\tequ\t\$%02.02X\t; class #", $ck, $i;
		print $fh_asm "assClassTbl_$ck\n";
		printf $fh_asm "\t\tFCB\t\$%02.02X\t; max index\n", $ix;
		printf $fh_asm "\t\tFCB\t\$%02.02X\t; flags\n", $FLAGS_ALWAYS + $cd->{3} * $FLAGS_6309 + $cd->{both} * $FLAGS_BOTH;	
		my $sdix=0;
		if ($cd->{sufs})
		{
			$sdix = $sufdef_ixs{$cd->{sufs}};
		}
		printf $fh_asm "\t\tFCB\t\$%02.02X\t; suffix set\n", $sdix;

		printf $fh_asm "\t\tFCB\t\$%02.02X\t; mode set\n", $md2->{code};

		$i++;	
	}
}
print $fh_asm "assClassTbl_END\n\n\n";



print $fh_asm "\n\n*********************************************************\n* M O D E    T A B L E \n*********************************************************\n\n";

print $fh_asm "assModeTbl\n";
print $fh_asm ";\t\t    MODE   OP FLAGS\n";

foreach my $ms (sort keys %activemodes) {
	print $fh_asm ";$ms\n";
	my $md2 = $modedefs2{$ms};
	my @md = @{ $modedefs{$ms} };

	$md2 and @md or die "Missing mode set set for \"$ms\"";

	if ($md2->{code} && $md2->{code} < 0x80) {
		foreach my $mdi (@md) {
			my $modeitem_flag;
			my $modelbl = $mdi->{mode};
			switch ($modelbl) {
				case "#" {
					$modeitem_flag = $MEMPB_IMM;
				}
				case "dp" {
					$modeitem_flag = $MEMPB_DP;					
				}
				case "ix" {
					$modeitem_flag = $MEMPB_IX;					
				}
				case "ex" {
					$modeitem_flag = $MEMPB_EXT;					
				}
				else {
					die "unrecognized mode \"$modelbl\"";
				}
			}

			my $op = $mdi->{op};
			my $flags = $mdi->{pre} | ($mdi->{3})?$FLAGS_6309:0;

			if ($op || $flags) {
				printf $fh_asm "\t\tfcb\t\$%02.02X, \$%02.02X, \$%02.02X\t; %s [%s]\n", ($md2->{code} & 0x70) + ($modeitem_flag), $op, $flags, $ms, $mdi->{mode};
			}
		}
	}
}

print $fh_asm "\t\tFCB 0; EOT\n\n\n";

foreach my $ms (sort keys %modedefs2) {
	printf $fh_asm "ASS_MODESET_%s\tequ\t\$%02.02X\n", $modedefs2{$ms}->{name}, $modedefs2{$ms}->{code};
}

if ($opt_6309) {
	print $fh_asm "\n\n*********************************************************\n* R E G     R E G    O P S\n*********************************************************\n\n";

	print $fh_asm "assXlateRegReg\n";

	OpXlate %regregops;
}

print $fh_asm "\n\n*********************************************************\n* C C    O P S\n*********************************************************\n\n";

print $fh_asm "assXlateCC\n";

OpXlate %CC_ops;



printf $fh_asm "ASS_MNE_BITS\tequ\t\$%08.08X\t; bits used in mnemonics\n", $allbits;
printf $fh_asm "ASS_BITS_PRE\tequ\t\$%02.02X\t; bits set indicate prefix\n", $FLAGS_PRE;
printf $fh_asm "ASS_BITS_PRE_10\tequ\t\$%02.02X\t; prefix = \$10\n", $FLAGS_PRE_10;
printf $fh_asm "ASS_BITS_PRE_11\tequ\t\$%02.02X\t; prefix = \$10\n", $FLAGS_PRE_11;
if ($opt_6309) {
	printf $fh_asm "ASS_BITS_6309\tequ\t\$%02.02X\t; 6309 only\n", $FLAGS_6309;
}
printf $fh_asm "ASS_BITS_EXTRA0\tequ\t\$%02.02X\t; EXTRA0 only\n", $FLAGS_EXTRA0;
printf $fh_asm "ASS_BITS_BOTH\tequ\t\$%02.02X\t; BOTH suffix and mode required\n", $FLAGS_BOTH;
printf $fh_asm "ASS_BITS_16B\tequ\t\$%02.02X\t; immediate values 16 bits\n", $FLAGS_16B;

print $fh_asm "\n";
printf $fh_asm "FLAGS_SUF_ANY\tequ\t\$%02.02X\t; suffix specific bits\n", $FLAGS_SUF_ANY;
printf $fh_asm "FLAGS_SUF_OP\tequ\t\$%02.02X\t; suffix followed by OP code delta\n", $FLAGS_SUF_OP;
printf $fh_asm "FLAGS_SUF_MODE\tequ\t\$%02.02X\t; suffix followed by mode override\n", $FLAGS_SUF_MODE;

print $fh_asm "\n";
printf $fh_asm "ASS_CLSTBL_SIZE\tequ\t\$%02.02X\t; class table entry size\n", $ASS_CLSTBL_SIZE;
printf $fh_asm "ASS_CLSTBL_OF_IXMAX\tequ\t\$%02.02X\t; offset ixmax\n", $ASS_CLSTBL_OF_IXMAX;
printf $fh_asm "ASS_CLSTBL_OF_FLAGS\tequ\t\$%02.02X\t; offset flags\n", $ASS_CLSTBL_OF_FLAGS;
printf $fh_asm "ASS_CLSTBL_OF_SUFS\tequ\t\$%02.02X\t; offset suffix set\n", $ASS_CLSTBL_OF_SUFS;
printf $fh_asm "ASS_CLSTBL_OF_MODES\tequ\t\$%02.02X\t; offset suffix set\n", $ASS_CLSTBL_OF_MODES;

print $fh_asm "\n";
printf $fh_asm "ASS_OPTBL_SIZE\tequ\t\$%02.02X\t; opcode/mne table entry size\n", $ASS_OPTBL_SIZE;
printf $fh_asm "ASS_OPTBL_OF_MNE\tequ\t\$%02.02X\t; offset mne hash (2)\n", $ASS_OPTBL_OF_MNE;
printf $fh_asm "ASS_OPTBL_OF_OP\tequ\t\$%02.02X\t; offset base opcode\n", $ASS_OPTBL_OF_OP;

print $fh_asm "\n";
printf $fh_asm "ASS_MEMPB_IND\tequ\t\$%02.02X\t;IX,INDIRECT FLAG\n", $MEMPB_IND;
printf $fh_asm "ASS_MEMPB_SZ8\tequ\t\$%02.02X\t;IX,FORCE 8\n", $MEMPB_SZ8;
printf $fh_asm "ASS_MEMPB_SZ16\tequ\t\$%02.02X\t;IX,FORCE 16\n", $MEMPB_SZ16;
printf $fh_asm "ASS_MEMPB_IMM\tequ\t\$%02.02X\t;IMMEDIATE\n", $MEMPB_IMM;
printf $fh_asm "ASS_MEMPB_DP\tequ\t\$%02.02X\t;DIRECT PAGE\n", $MEMPB_DP;
printf $fh_asm "ASS_MEMPB_IX\tequ\t\$%02.02X\t;INDEX/INDIRECT\n", $MEMPB_IX;
printf $fh_asm "ASS_MEMPB_EXT\tequ\t\$%02.02X\t;EXTENDED\n", $MEMPB_EXT;
