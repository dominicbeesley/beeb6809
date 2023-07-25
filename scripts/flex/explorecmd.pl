#!/bin/perl
use Switch;

$inf=@ARGV[0];

print STDERR $inf;

open(my $fh_in,"<:raw",$inf) or die "cannot open input file $inf";

my $last_addr = 0;
my $first_in_run = 1;
my $run_addr = 0;
my $run_len = 0;

while (read $fh_in, $code, 1) {
	(my $code_num) = unpack("C", $code);
	switch ($code_num) {
		case 0	{
			#print "0 skipped\n";
			}
		case 2	{
			read($fh_in, my $header, 3) == 3 or die "Error reading type 2 header at " . hex(tell($fh_in));
			(my $addr, my $len) = unpack("n C", $header);
			printf "TYPE 02, 0x%04.04x, 0x%02x\n", $addr, $len;
			read($fh_in, my $buf, $len)== $len or die "Error reading type 2 data at " . hex(tell($fh_in));

			}
		case 0x16 {
			read($fh_in, my $header, 2) == 2 or die "Error reading type 16 header at " . hex(tell($fh_in));
			(my $addr) = unpack("n", $header);
			printf "TYPE 16, 0x%04.04x\n", $addr;			
		}
		else	{
			printf "UNKNOWN TYPE %02.02x at %x\n", $code_num, tell($fh_in);
		}
	}
}

