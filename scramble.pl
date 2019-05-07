use strict;

my $version = shift(@ARGV);
srand($version);
my $vnames = "12345678";
my $V = substr($vnames, $version-1, 1);
$V = "version $V" unless $V==5;
$V = "DEFERRED" if $V==5;
print "PRE \\renewcommand{\\testver}{$V}\n\n";

undef $/;
my $mc = <>;

my @f = split /-{30,}/, $mc;
my $f0 = shift @f;

# Randomize MC sections delimited by -------------------
for (my $i = @f; --$i; ){
	my $j = int rand ($i+1);
	next if $i == $j;
	@f[$i,$j] = @f[$j,$i];
}

unshift @f, $f0;

print join "\n", @f;
