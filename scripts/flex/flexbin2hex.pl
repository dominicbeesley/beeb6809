#!/bin/perl

# -----------------------------------------------------------------------------
# Copyright (c) 2022 Dominic Beesley https://github.com/dominicbeesley
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# ----------------------------------------------------------------------

use strict;

# convert a flex binary file to a hex load file
# default is .S19 format, -I flag selects intel format
# records may be rewritten / amalgamated
# any exec block will be at the end
# records will be output in destination order
# if there are multiple exec blocks the last encountered will be used

binmode(STDIN, ":raw");

my $MAXRECLEN = 64;

my $b_rectype;

my $exec_addr = -1;

my $cksum = 0;


my $format = 0;
my $FMT_S19 = 0;
my $FMT_IHX = 1;
my $FMT_BIN = 2;
my $bin_end_addr = -1;
my $bin_start_addr = -1;
my $fh_o = *STDOUT;

my @used = (0) x 0x10000;
my @mem = (chr(0xFF)) x 0x10000;

while (scalar @ARGV && @ARGV[0] =~ /^-/) {
	my $sw = shift;
	if ($sw =~ /^--?(\?|help)/) {
		usage();
		exit 0;
	} elsif ($sw eq "-S") {
		$format = 0
	} elsif ($sw eq "-B") {
		$format = 2;
	} elsif ($sw eq "-I") {
		$format = 1;
	} elsif ($sw eq "-o") {
		my $fn = shift;
		$fn or usage("missing filename");
		open($fh_o, ">", $fn) or usage("Cannot open \"$fn\" for output: $!");
	} elsif ($sw eq "--start") {
		$bin_start_addr = checkaddr(shift, "start");	
	} elsif ($sw eq "--end") {
		$bin_end_addr = checkaddr(shift, "start");	
	} elsif ($sw eq "--default") {
		@mem = (chr(checkaddr(shift, "default"))) x 0x10000;	
	} else {
		usage("bad switch \"$sw\"");
	}
}

sub checkaddr($$) {
	my ($a, $n) = @_;

	if (!defined $a || $a =~ /^\s*$/ || $a < 0 || $a > 65536) {
		usage("Bad $n address specified");
	}

	return hex($a);
}

sub usage($) {
	my ($msg) = @_;

	my $fh = *STDIN;
	if ($msg)
	{
		$fh = *STDERR;
	}

	print $fh "USAGE: flexbin2hex.pl [options] [files...]\n
\n
Read a flex \"binary\" records file and decode to hex/true flat binary\n
\n
\n
OPTIONS:
	-S	output in S19 format (default)\n
	-I	output in Intel Hex format\n
	-B	output in Binary format\n
	--start <hex addr> start address for binary output\n
	--end <hex addr> end address for binary output\n
	--default <hex> default byte value for binary\n
	-o <filename> write output to file (default is STDIN)

If no input files are specified then STDIN is read. If multiple
files are read then any overlap will be overwritten in order.
";	
	$msg and die $msg;
}


sub dobyte($) {
	my ($c) = @_;
	$cksum = $cksum + ($c & 0xFF);
	printf $fh_o "%02X", ($c & 0xFF);
}

sub process_file($) {
	my ($fh_i) = @_;

	while (read($fh_i, $b_rectype, 1) == 1) {
		if (ord($b_rectype) == 0) {
			# do nowt
		} elsif (ord($b_rectype) == 2) {
			# data record
			read($fh_i, my $b_head, 3) == 3 or die "Unexpected EOF reading data header";
			my ($addr, $len) = unpack("n C", $b_head);

			read($fh_i, my $b_data, $len) == $len or die "Unexpected EOF reading data";

			splice(@used, $addr, $len, (1) x $len);
			splice(@mem, $addr, $len, unpack("C*", $b_data));

			if ($bin_start_addr == -1 || $addr < $bin_start_addr) {
				$bin_start_addr = $addr;
			}

			if ($bin_end_addr == -1 || $addr + $len - 1 > $bin_end_addr) {
				$bin_end_addr = $addr + $len - 1;
			}


		} elsif (ord($b_rectype) == 0x16) {
			read($fh_i, my $b_head, 2) == 2 or die "Unexpected EOF reading exec header";
			# exec addr
			$exec_addr = unpack("n", $b_head);

		} else {
			die sprintf("unknown record type 0x%02X", ord($b_rectype));
		}
	}
}

if (scalar @ARGV == 0) {
	process_file(*STDIN);
} else {
	foreach my $fn (@ARGV) {
		open(my $fh_i, "<:raw", $fn) or die "Cannot open \"$fn\" for input : $!";
		process_file($fh_i);
		close($fh_i);
	}
}

if ($format == $FMT_BIN) {
	binmode($fh_o);

	if ($bin_end_addr != -1 && $bin_end_addr != -1) {
		print $fh_o pack("C*", @mem);
	}
} else {

	my $i = 0;
	while ($i < 65536) {
		if (!@used[$i]) {
			$i++;
		} else {

			my $l = 1;
			while ($i+$l < 65535 && $l < $MAXRECLEN && @used[$i+$l]) {
				$l++;
			}

			$cksum = 0;

			if ($format == $FMT_S19) {
				print $fh_o "S1";

				dobyte($l+3);
				dobyte($i >> 8);
				dobyte($i);
			} else {
				print $fh_o ":";
				dobyte($l);
				dobyte($i >> 8);
				dobyte($i);
				dobyte(0x00);
			}

			foreach my $d (@mem[$i..$i+$l-1]) {
				dobyte($d);
			}

			dobyte(($cksum & 0xFF) ^ 0xFF);
			print $fh_o "\n";


			$i+= $l;
		}
	}


	if ($exec_addr >= 0) {

		print $fh_o "S9";
		if ($format == $FMT_S19) {
			dobyte(3);
			dobyte($exec_addr >> 8);
			dobyte($exec_addr);
		} else {
			print $fh_o ":";
			dobyte(4);
			dobyte(0);
			dobyte(0);
			dobyte(0x04);			
			dobyte(0);
			dobyte(0);
			dobyte($exec_addr >> 8);
			dobyte($exec_addr);
		}
		dobyte(($cksum & 0xFF) ^ 0xFF);
		print $fh_o "\n";
	}

}


