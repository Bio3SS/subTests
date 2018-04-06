use strict;

my $v = shift @ARGV;

while(<>){
	s/VVV/$v/g;
	print;
}
