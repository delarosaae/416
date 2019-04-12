#!/usr/bin/perl 

@array;
$array[0] = '    Hello';
print "$array[0]\n";

#$array[0] = ~s/^\s+//;
#print "$array[0]\n";


$letter = $array[0];
print "$letter\n";
$letter=~s/^\s+//;
print "$letter\n";

$array[0] = $letter;
print "$array[0]\n";