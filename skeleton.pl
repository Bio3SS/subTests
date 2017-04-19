
use strict;
use 5.10.0;

undef $/;
my $inf = <>;
$inf =~ s/ENDMC.*//s;

my $tot=0;
my @f = split /-{30,}/, $inf;
foreach my $f (@f){
	$f =~ s/^/\n/s;
	my @g = ($f =~ /\nQ\b/g);
	my $nQ = 1 + $#g;
	my @qlist = (($tot+1)..($tot+$nQ));
	map {s/$/\n/} @qlist;
	$f = join "", @qlist;
	$tot += $nQ
}
print join "\n-------------------------------------------------\n\n",
	@f;

