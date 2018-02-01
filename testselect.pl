use strict;

my $version = shift(@ARGV);

$version--;

my $num = "[\\w\\\\]*[.]?[\\w\\\\]*";

while(<>){
	## Split 5 ways first (in case there's an extra, like for the final)
	while (my($head, $choice, $tail) = (m|(.*?)($num/$num/$num/$num/$num)(.*)|s)){
		my @choice=(split m|[/]|, $choice);
		$choice="$choice[$version]";
		$_ = "$head$choice$tail";
	}

	## Now split 4 ways
	while (my($head, $choice, $tail) = (m|(.*?)($num/$num/$num/$num)(.*)|s)){
		my @choice=(split m|[/]|, $choice);
		$choice="$choice[$version]";
		$_ = "$head$choice$tail";
	}
	print;
}

