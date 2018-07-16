#!/bin/perl

my $mne = "EQU|ORG|RMB|FCB|FCC|FDB|ADCA|ADCB|ADDA|ADDB|ADDD|ANDA|ANDB|ANDCC|ASL|ASR|BITA|BITB|CLR|CMPA|CMPB|CMPD|CMPS|CMPU|CMPX|CMPY|COM|DEC|EORA|EORB|EXG|INC|JMP|JSR|LDA|LDB|LDD|LDS|LDU|LDX|LDY|LEAS|LEAU|LEAX|LEAY|LSL|NEG|ORA|ORB|ORCC|PSHS|PSHU|PULS|PULU|ROL|ROR|SBCA|SBCB|STA|STB|STD|STS|STU|STX|STY|SUBA|SUBB|SUBD|TFR|BCC|BCS|BEQ|BGE|BGT|BHI|BHS|BLE|BLO|BLS|BLT|BMI|BNE|BPL|BRA|BRN|BSR|BVC|BVS|TST|LBCC|LBCS|LBEQ|LBGE|LBGT|LBHI|LBHS|LBLE|LBLO|LBLS|LBLT|LBMI|LBNE|LBPL|LBRA|LBRN|LBSR|LBVC|LBVS";

my $mne_1 = "ABX|ASLA|ASLB|ASRA|ASRB|CLRA|CLRB|COMA|COMB|CWAI|DAA|DECA|DECB|INCA|INCB|LSRA|MUL|NEGA|NEGB|NOP|ROLA|ROLB|RORA|RORB|SEX|RTI|RTS|SWI|SWI2|SWI3|SYNC|TSTA|TSTB|SEI|CLI";

my $mne_ig = "PAG|SPC|TTL|NAM|OPT";


while (<>) {
	chomp;

	s/[\r\n]+$//;

	if (/^\s*END\b/) {
		last;
	} elsif (/^((?!($mne_1|$mne)\ )(\w*)\ +)?($mne_ig)(\ +(.*))?$/)	{
		my $lbl = "$3", $op = "$4", $cmts = "$5";
		print "$lbl\t\t; $op $cmts\n";
	} elsif (/^((?!($mne_1|$mne)\ )(\w*)\ +)?($mne)(\ ('[^']+'|[^ \n]+)(\ +(.*))?)?$/) {
		my $lbl = "$3", $op = "$4", $args = "$6", $cmts = "$8";
		print "$lbl\t\t$op";
		if ($args ne '')
		{
			print "\t$args";
		}
		if ($cmts ne '')
		{
			print "\t\t\t\t; $cmts";
		}
		print "\n";
	} elsif (/^((?!($mne_1|$mne)\ )(\w*)\ +)?($mne_1)(\ +(.*))?$/) {
		my $lbl = "$3", $op = "$4", $cmts = "$5";
		print "$lbl\t\t$op";
		if ($cmts ne '')
		{
			print "\t\t\t\t; $cmts";
		}
		print "\n";
	} elsif (/(^Page|6809 FLEX Adapt)/) {
		##nowt
	} elsif (/^\s*(\*.*)/) {
		print "\t$1\n";
	} elsif (/^\s*$/) {
		print "\n";
	} else {
		print "error ;;;; !!!! ;;;; $_\n";
	}

}