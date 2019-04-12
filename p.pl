#!/usr/bin/perl 

use WWW::Wikipedia;
my $wiki = WWW::Wikipedia->new();
$wiki->clean_html(1);


print "Angel's Jeopardy Application\n";


while(($line = <>) ne "exit\n")
{
	chomp($line);
	#print "$line\n";
	@question = split/\s+/, $line;

	#foreach $word(@question)
	#{
	#	print "$word\n";
	#}

	if ($question[0] eq "What") {
		# body...
		#print "what\n";
		WhatStatement($line);
	}
	elsif ($question[0] eq "When") {
		#print "when\n";
	}
	elsif ($question[0] eq "Where") {
		#print "where\n";

	}
	elsif ($question[0] eq "Who")
	{
		#print "who\n";
		WhatStatement($line);
	}
	else
	{
		print "Sorry, I cannot answer this question.\n";
	}
}

sub WhatStatement{
	my $sentence = @_;

	if($_[0]=~/\bWhat is (a|the) \b/)
	{
		#print "$&\n";
		my $lookUp = $';
		$lookUp=~s/\?/ /;
		my $result = $wiki->search($lookUp);
		if ( $result->text() ) { 
    		my $result2= $result->text();
    		
    		open (DST, ">Wikitext.txt");
    		print DST "$result2\n";
    		close DST;

    		my @para = split/\n\n/, $result2;


            $size = @para;
            open (DST, ">White.txt");
              #  print DST "$size";
            foreach $q(@para){
                $q =~s/^\s+//;
                print DST "Array: $q\n";
            }
            close DST;



            #foreach $q(@para){
            #    print "$q\n";
            #}



            open (DST, ">Chartext.txt");
         
            

    		my $array_size = @para;
    		#print "size : $array_size\n";
    		for $i(0..$array_size -1)
    		{
    			$stringOfPara = $para[$i];
    			

    			$firstChar = substr($stringOfPara, 0, 1);
    			print DST "char : $firstChar\n";
                print DST "String : $stringOfPara\n";

    			if($firstChar eq "*" | $firstChar eq "|" | $firstChar eq "" | $firstChar eq "{" | $firstChar eq "}" | $firstChar eq "\s" | $firstChar eq " " | $firstChar eq "\n")
    			{
    				$para[$i] = "N";
                    print DST "N found right here ---------------\n"
    			}
                print DST "\n";
                print DST "\n";
                print DST "\n";
    		}
            close DST;

            #foreach $q(@para){
             #   print "$q\n";
            #}



    		my @correctParagraphs;
    		foreach $newPar(@para)
    		{
    			if($newPar ne "N")
    			{
    				
    				#print "ParaWithout N to be put to correct: \n";
    				#$newPar =~s/^\s+//;
    				

    				push(@correctParagraphs, $newPar);
    			}
    		}


    		$result4;
    	   foreach $par(@correctParagraphs)
    		{
    			$result4 = $result4 . ' '. $par;
    		}

    		$array_size = @correctParagraphs;

    		my $result4 = join ('', @correctParagraphs[0..$array_size -1]);

    		my @wikiResultSentences = split/\./, $result4;

    		#print "here\n";

    		#foreach $sent(@wikiResultSentences)
    		#{
    		#	print "$sent\n";
    		#	print "\n";
    		#	print "\n";
    		#	print "\n";
    		#}

    		print "$wikiResultSentences[0]\n";
    		


		}		
		else
		{
			print "Could not find the answer\n";
		}



	}
}