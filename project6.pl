#!/usr/bin/perl 

no warnings;
#I was getting warnings about wide characters 

#first we will create a wikipedia isntance so that we can use WIkipedia
use WWW::Wikipedia;
my $wiki = WWW::Wikipedia->new();
$wiki->clean_html(1);   #this will get rid of most of the html text like "</>""




#use wordnet for getting synonyms 
use WordNet::QueryData;
my $wn = WordNet::QueryData->new;


#use wordnet for getting similarity score to add to synonyms
use WordNet::Similarity::lesk;
my $qd = WordNet::QueryData->new();
my $wnsim = WordNet::Similarity::lesk->new($qd);




my $file = $ARGV[0];
#print "Name of file :      $file\n";
#open (DST, ">>logfile.txt");
open (DST, ">>$file");


# Our message that the reader will see, along with a small overview of what our Application does and how to end it
print "Angel de la Rosa Jeopardy Application. Ask me any quesiton that begins with either Who, What, When, or Where, and I will try to answer it as best as I can.\n";
print "Please enter exit when finished.\n\n";

#checks to see if the user entered exit or asked a question
#if it is a question it will continue, others it will stop the program
while(($line = <STDIN>) ne "exit\n")         #will get the user input and place the user input into a variable called $line
{                                       
	chomp($line); #will get rid of whitespace
	#print "$line\n";
	@question = split/\s+/, $line;     #will split up the question so that I can get the first word which will 
                                       #let us know whether it is a what, when, where, or who question
    print DST "User Question: $line\n";
    print DST "\n\n\n";

    #if it is a what question call the WhatStatement method and send the question using the $line variable
	if ($question[0] eq "What" | $question[0] eq "what") {     #checks the first word of the user inputs question, do the same for the rest of elsif
		#print "what\n";
		WhatStatement($line);
	}
    #if it is a when question call the WhenStatement method and send the question using the $line variable
	elsif ($question[0] eq "When" | $question[0] eq "when") {
		#print "when\n";
        WhenStatement($line);
	}
    #if it is a where question call the WhereStatement method and send the question using the $line variable
	elsif ($question[0] eq "Where" | $question[0] eq "where") {
		#print "where\n";
        WhereStatement($line);
	}
    #if it is a who question call the WhoStatement method and send the question using the $line variable
	elsif ($question[0] eq "Who" | $question[0] eq "who")
	{
		#print "who\n";
		WhoStatement($line);
	}
    #if it is not of those 4 questions, let the user know that we cannot answer that question. 
	else
	{
		print "Sorry, I cannot answer this question.\n";
	}

    print "\n";
    print DST "------------------------------------------------------\n\n\n";
}

close DST;
close print "Thank you! Goodbye.\n";


#whenever we have a what question, this function will be called
#there are really only two types of what questions, and they both are for looking up definitions. 
#based on the most the popular what searches on google, The most popular searches begin with the following words:
#"is", "are", "Is a" "is the" "is an" "are a", "are an" "are the", and "does *** mean"
sub WhatStatement{
	my $sentence = @_; #gets the parameters that are sent to it.

	if($_[0]=~/\b(What|what) (is|are)( a| the| an)? \b/)         
	{
		#print "$&\n";
		my $lookUp = $'; #will get the words after what is matched, so for example what are dogs, what are gets matched and $' will be dogs
		$lookUp=~s/\?/ /; #will get rid of the question mark at the end of the sentence 
        $lookUp=~s/\s+$//;
        print DST "Search Was executed: $lookUp\n\n\n";
		my $result = $wiki->search($lookUp);  #will search wikipedia , and we use my so that if we ask another question, the first question will not be saved globally
		if ( $result->text() )
         {              #if we do have a result continue
    		my $result2= $result->text();     #get the wikipedia information and make it into a text and save it to a local variable for the same reason as result
    		print DST "Wiki Result: \n";
            print DST "$result2\n\n\n";

    		#open (DST, ">Wikitext.txt");
    		#print DST "$result2\n";          #just used for testing purposes to look at wiki text
    		#close DST;

    		my @para = split/\n\n/, $result2; #split the text by spaces between paragraphs 


            $size = @para;          #get the size of the array that contains that paragraphs
            #open (DST, ">White.txt");          Used for testing purposes
            #print DST "$size";
            foreach $q(@para){          #for each paragraph we will remove whitespace at the beginning  or remove brackts at the end.
                $q =~s/^\s+//;      
                $q =~s/(.)*\]//;        # a lot of the wikipedia contained a sentence about a picture and would have a bracket at the end, this will get rid of that paragraph since it is just junk
                $q =~s/^\s+//;
            }
         
               

    		my $array_size = @para;       #get the size of the paragraph array, do not know why I have it again, but i will just leave it to not mess anything up, but I'm pretty sure it is redundent 
    		#print "size : $array_size\n";

            #will go through the whole array and remove paragraphs that beginning with any characters in the if statement. This is done because we get a lot of redundent information from the wiki page
    		for $i(0..$array_size -1)     
    		{
    			$stringOfPara = $para[$i];
    			
    			$firstChar = substr($stringOfPara, 0, 1);
                $lastChar = substr($stringOfPara, -1, 1);


    			if($firstChar eq "*" | $firstChar eq "|" | $firstChar eq "" | $firstChar eq "{" | $firstChar eq "}" | $firstChar eq "\s" | $firstChar eq " " | $firstChar eq "\n" | $lastChar eq "]" | $lastChar eq "}")
    			{
    				$para[$i] = "N";  #I made the "N" a sentinal value to use later in the below foreach 
    			}
    		}


    		my @correctParagraphs;    #initilize an array that will hold the correct paragraphs that contain actual information and not html text
    		foreach $newPar(@para)
    		{
    			if($newPar ne "N")   #if an an array element contains the sentinal value, do not add it the correct paragraphs array
    			{
    				#$newPar =~s/^\s+//;
    				push(@correctParagraphs, $newPar);
    			}
    		}


            #foreach $par(@correctParagraphs)       #will add the correct paragraphs into one long string variable by concating the paragraphs
            #{
            #    print "Line: $par\n";
            #}

            my $result4;
           foreach $par(@correctParagraphs)       #will add the correct paragraphs into one long string variable by concating the paragraphs
            {
                $result4 = $result4 . ' '. $par;
            }


            my @correctSentences = split/\.\s/, $result4; #split the text by periods between paragraphs 

            #since the first sentence is usually the best one, and since in our hash table if somehow two senetences are the best, it will not order
            #them by which one came first, but in random order, will explain more letter
            my $firstValue = $correctSentences[0];
            my $firstValueScore = 0;

            my %sentenceScore = ();


            #add a 5 to each one that has the word that we looked up 
            #The stanford entity module did not work, so I acted as if the sentence had the thing that we are looking
            #it would recieve a better score
            #so if we are looking up Who is Gary Clarke Jr, we know that we need a Person, but since Stanford module did nto work
            # I acted as if "Person" was Gary Clarke Jr. 
            foreach $cLine(@correctSentences)      
            {
               # print "Line: $cLine\n\n";
                if($cLine=~m/$lookUp/)
                {
                    $sentenceScore{$cLine} = 5;
                }
                else
                {
                    $sentenceScore{$cLine} = 0;
                }
            }

            if($firstValue=~m/$lookUp/)
            {
                $firstValueScore= 5;
            }


            #add 3 to the score if the sentence has a is,was,pertains
            foreach $cLine(@correctSentences) 
            {
             #   print "Line: $cLine\n\n";
                if($cLine=~m/\sis\s|\swas\s|\spertains\s|\soccurs\s|\sare\s|\swas\s/)
                {
                    $sentenceScore{$cLine} = $sentenceScore{$cLine} + 3;
                }
              
            }

            if($firstValue=~m/\sis\s|\swas\s|\spertains\s|\soccurs\s|\sare\s|\swas\s/)
            {
                $firstValueScore= $firstValueScore + 5;
            }


            #array to put in the synonyms
            my @array;


            #put all the synonyms into the array
            push(@array, $wn->querySense("$lookUp#n#1", "syns"));
            #print "Synset: ", join(", ", $wn->querySense("George Washington#n#1", "syns")), "\n";

            #$size = @array;
            #print "size : $size\n";

            #for each result remove unnecessary characters
            foreach $e(@array)
            {
                #print "$e\n";
                $e =~s/\#(.)*//;
                #print "$e\n";
                $e =~s/_/ /;
                $e =~s/_/ /;
                $e =~s/_/ /;
                $e =~s/_/ /;
                $e =~s/_/ /;

          #      print "$e\n";
            }

            if($lookUp eq $array[0])
            {
                shift @array;
            }

            my $size = @array;
          #  print "size : $size\n";
            foreach $e(@array)
            {               
             #   print "$e\n";
            }


            #for each synonym, look it up in each sentence, if it is in their, give it a score realting to how similar it is
            #using the similiary wordNet module 
            foreach $e(@array)
            {               
                foreach $cLine(@correctSentences)      
                {
                     # print "Line: $cLine\n\n";
                    if($cLine=~m/$e/)
                    {

                        my $Similarscore = $wnsim->getRelatedness("$lookUp#n#1", "$e#n#1");
                  #      print "looing up : $e\n";
                    #    print "before 100 = $Similarscore\n";

                        $Similarscore = $Similarscore /100;
                  #      print "score = $Similarscore\n";
                        $sentenceScore{$cLine} = $sentenceScore{$cLine} + $Similarscore;
                    }
                }
            }   



            foreach $e(@array)
            {               
                if($firstValue=~m/$e/)
                {
                    my $SimilarscoreForFirst = $wnsim->getRelatedness("$lookUp#n#1", "$e#n#1");
                        #print "looing up : $e\n";
                        #print "before 100 = $Similarscore\n";

                        $SimilarscoreForFirst = $Similarscore /100;
                      #  print "score = $Similarscore\n";
                        
                    $firstValueScore= $firstValueScore + $SimilarscoreForFirst;
                }
            }    


            my @getTopThree;
            my @getTopThreeScores;


            #we are getting the top three scores from all of our sentences. 
            my $i = 0;
            foreach $eachScore (sort {$sentenceScore{$b} <=> $sentenceScore{$a}} keys %sentenceScore)
            {

               #print "Sentence: $eachScore \n";
               # print "total score: $sentenceScore{$eachScore}\n";

                if($i < 3)
                {
                    # we are in a sense removing scores that are not applicable since they did not contain our name entity or are too low
                    if($sentenceScore{$eachScore} > 0)
                    {
                         push(@getTopThree, $eachScore);
                         push(@getTopThreeScores, $sentenceScore{$eachScore});
                         $i++;
                    }
                }

            }


            foreach $top(@getTopThree)
            {
            #     print "$top\n";
            }
            foreach $top(@getTopThreeScores)
            {
             #    print "$top\n";
            }


            #so in the rare chance that we have two sentnece that have the same score, we will default to 
            #the first sentence in the paragraph
            if($firstValueScore = $getTopThreeScores[0] && $getTopThree[0] ne $firstValue)
            {
                print "$firstValue\n";
            }
            else
            {
                print "$getTopThree[0]\n";
            }

        }
    }
    else
    {
        print "Sorry, please rephrase the quesiton.\n";
    }   
}