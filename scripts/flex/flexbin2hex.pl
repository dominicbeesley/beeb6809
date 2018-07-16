#!/bin/perl

# convert a flex binary file to a hex load file
# default is .S19 format, -I flag selects intel format

binmode(STDIN, ":raw");

my $b_rectype;

my $exec_addr = -1;

my $cksum = 0;

my $format = 0;						#0 for S19, 1 for Intel

while (scalar @ARGV && @ARGV[0] =~ /^-/) {
	my $sw = shift;
	if ($sw eq "-I")
	{
		$format = 1;
	} else {
		die "bad switch \"$sw\"";
	}
}


sub dobyte($) {
	my ($c) = @_;
	$cksum = $cksum + ($c & 0xFF);
	printf "%02X", ($c & 0xFF);
}

while (read(STDIN, $b_rectype, 1) == 1) {
	if (ord($b_rectype) == 0) {
		# do nowt
	} elsif (ord($b_rectype) == 2) {
		# data record
		read(STDIN, my $b_head, 3) == 3 or die "Unexpected EOF reading data header";
		$cksum = 0;
		my ($addr, $len) = unpack("n C", $b_head);
		if ($format == 0) {
			print "S1";
			dobyte($len+3);
			dobyte($addr >> 8);
			dobyte($addr);
		} else {
			print ":";
			dobyte($len);
			dobyte($addr >> 8);
			dobyte($addr);
			dobyte(0x00);
		}

		read(STDIN, my $b_data, $len) == $len or die "Unexpected EOF reading data";
		for my $d (unpack("C*", $b_data)) {
			dobyte($d);
		}

		dobyte(($cksum & 0xFF) ^ 0xFF);
		print "\n";
	} elsif (ord($b_rectype) == 0x16) {
		read(STDIN, my $b_head, 2) == 2 or die "Unexpected EOF reading exec header";
		# exec addr
		$cksum = 0;
		my ($addr) = unpack("n", $b_head);
		print "S9";
		if ($format == 0) {
			dobyte(3);
			dobyte($addr >> 8);
			dobyte($addr);
		} else {
			print ":";
			dobyte(4);
			dobyte(0);
			dobyte(0);
			dobyte(0x04);			
			dobyte(0);
			dobyte(0);
			dobyte($addr >> 8);
			dobyte($addr);
		}
		dobyte(($cksum & 0xFF) ^ 0xFF);
		print "\n";

	} else {
		die sprintf("unknown record type 0x%02X", ord($b_rectype));
	}
}
