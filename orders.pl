use strict;
use 5.10.0;

my @questions;

foreach my $fn (@ARGV){
	my $q=0;
	open(my $fh, "<", $fn)  ;
	while(<$fh>){
		next unless /^[0-9]/;
		chomp;
		$q++;
		push @{$questions[$q]}, $_;
	}
}

for (my $q=1; $q<@questions; $q++){
	print "$q\t";
	say join "\t", @{$questions[$q]};
}
