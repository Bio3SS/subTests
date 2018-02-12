use strict;

my ($test, $ver, $ft) = split /[.]/, $ARGV[0];
print "Version,$ver,,,,\n";
print "Question:,A,B,C,D,E\n";

while(<>){
	chomp;
	my ($q, @a) = split;
	my $row = [0, 0, 0, 0, 0];

	foreach (@a){
		my $a = ord($_) - ord('A');
		$row->[$a] = 1;
	}

	print "$q,";
	print join ",", @{$row};
	print "\n";
}
