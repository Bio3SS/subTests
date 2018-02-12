use strict;
$/ = "";
my $count=0;
my $ques = 0;
my $sq;

my $let = "ABCDEFGHIJKLMNOPQRSTUV";
my @ans;

while(<>){
	chomp;
	last if /ENDMC/;
	s/[\s-]*$//;
	$count++;

	$sq = substr($let, $count-1, 1);

	if (/^Q\s/){
		$ques++;
		$count=0;
		$ans[$ques] = [];
	}

	push @{$ans[$ques]}, $_  if s/^KEY\s+//;

	push @{$ans[$ques]}, $sq if /^STAR\s/;
	push @{$ans[$ques]}, $sq if /^[*]\s/;
}

for (my $i=1;$i<=$ques;$i++){
	print "$i ";
	die ("No answers (i=$i)") if @{$ans[$i]}==0;
	print join " ", @{$ans[$i]};
	print "\n";
}
