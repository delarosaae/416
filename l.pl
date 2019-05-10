#!/usr/bin/perl 

%seen = ();
@politArray = ("R", "R", "D", "I", "I", "R", "G", "A", "G", "G", "G");

foreach $politician(@politArray)
{
	$seen{$politician}++;
}

@getTopThree;
$i = 0;

#$totalKeys = keys (%seen);
#$positionToStart = ($totalKeys - 3) + 1;
print "total hash keys: $totalKeys\n";
 my $i = 0;
foreach $party (sort {$seen{$b} <=> $seen{$a}} keys %seen)
{

	print "Party: $party ";
	print "#reps: $seen{$party}\n";

	if($i < 3)
	{
		push(@getTopThree, $party);
		$i++;
	}

}


foreach $top(@getTopThree)
{
	print "$top\n";
}
