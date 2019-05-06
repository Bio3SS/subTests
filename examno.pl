use strict;

my $v = shift @ARGV;

$v = "Version $v" if $v<5;
$v = "DEFERRED" if $v==5;

while(<>){
	s/VVV/$v/g;
	print;
}
