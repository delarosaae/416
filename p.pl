#!/usr/bin/perl 

no warnings;
#I was getting warnings about wide characters 

#first we will create a wikipedia isntance so that we can use WIkipedia
use WWW::Wikipedia;
my $wiki = WWW::Wikipedia->new();

$wiki->clean_html(1);   #this will get rid of most of the html text like "</>""


my $file = $ARGV[0];
#print "Name of file :      $file\n";
#open (DST, ">>logfile.txt");
open (DST, ">>$file");


# Our message that the reader will see, along with a small overview of what our Application does and how to end it
print "Angel's Jeopardy Application. Please enter exit when finished.\n";

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
        print DST "Search Was executed: $lookUp\n\n\n";
		my $result = $wiki->search($lookUp);  #will search wikipedia , and we use my so that if we ask another question, the first question will not be saved globally
		if ( $result->text() ) {              #if we do have a result continue
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


    	    $result4;
    	    foreach $par(@correctParagraphs)       #will add the correct paragraphs into one long string variable by concating the paragraphs
    		{
    			$result4 = $result4 . ' '. $par;
    		}

    		$array_size = @correctParagraphs;

    		my $result4 = join ('', @correctParagraphs[0..$array_size -1]);   

    		my @wikiResultSentences = split/\.\s/, $result4;      #since most of the answers that we need are at the top of the first paragraph, we will get that paragraph/sentence that describes what we looked up

    		print "$wikiResultSentences[0].\n";
            print DST "Answer: $wikiResultSentences[0].\n";

		}	      
		else
		{
			print "Could not find the answer\n";
		}
	}


    #repeat of the top code but this time if the question is phrased differently if we have someone that wants to look up a definition of a word
    elsif($_[0]=~/\b^(What|what) does (.+)+ mean\b/)         
    {
        print DST "Search Was executed: $lookUp\n\n\n";
        my $lookUp = $2; #gets whats in the middle of does and mean, so whatever (.+)+ equals 
        $lookUp=~s/\?/ /; 
        my $result = $wiki->search($lookUp);  
        if ( $result->text() ) {              
            my $result2= $result->text(); 
            print DST "Wiki Result: \n";
            print DST "$result2\n\n\n";    
            my @para = split/\n\n/, $result2; #split the text by spaces between paragraphs 
            $size = @para;         
            foreach $q(@para){          
                $q =~s/^\s+//;      
                $q =~s/(.)*\]//;        
                $q =~s/^\s+//;
            }
            my $array_size = @para;      
            for $i(0..$array_size -1)     
            {
                $stringOfPara = $para[$i]; 
                $firstChar = substr($stringOfPara, 0, 1);
                $lastChar = substr($stringOfPara, -1, 1);
                if($firstChar eq "*" | $firstChar eq "|" | $firstChar eq "" | $firstChar eq "{" | $firstChar eq "}" | $firstChar eq "\s" | $firstChar eq " " | $firstChar eq "\n" | $lastChar eq "]" | $lastChar eq "}")
                {
                    $para[$i] = "N"; 
                }
             }
            my @correctParagraphs;   
            foreach $newPar(@para)
            {
                if($newPar ne "N")   {
                    push(@correctParagraphs, $newPar);
                }
            }
            $result4;
            foreach $par(@correctParagraphs)  {
                $result4 = $result4 . ' '. $par;
            }
            $array_size = @correctParagraphs;
            my $result4 = join ('', @correctParagraphs[0..$array_size -1]);   
            my @wikiResultSentences = split/\.\s/, $result4;      
            print "$wikiResultSentences[0].\n";
            print DST "Answer: $wikiResultSentences[0].\n";
        }   
    }
    else
    {
        print "Sorry, please rephrase the quesiton.\n";
    }
}

sub WhoStatement
{
    my $sentence = @_;
    #the following are based on the most commmon search patterns for questions asked on google that start with who
    if($_[0]=~/\b^(Who|who) (is|made|created|invented|purchased|wrote|painted|won|sings|played|is the leader of|was|is the|was the|owns) \b/)          
    {
        print DST "Search Was executed: $lookUp\n\n\n";
        my $lookUp = $'; #gets whats in the middle of does and mean, so whatever (.+)+ equals 
        $lookUp=~s/\?/ /; 
        my $result = $wiki->search($lookUp);  
        if ( $result->text() ) {              
            my $result2= $result->text();    
            print DST "Wiki Result: \n";
            print DST "$result2\n\n\n"; 
            my @para = split/\n\n/, $result2; #split the text by spaces between paragraphs 
            $size = @para;         
            foreach $q(@para){          
                $q =~s/^\s+//;      
                $q =~s/(.)*\]//;        
                $q =~s/^\s+//;
            }
            my $array_size = @para;      
            for $i(0..$array_size -1)     
            {
                $stringOfPara = $para[$i]; 
                $firstChar = substr($stringOfPara, 0, 1);
                $lastChar = substr($stringOfPara, -1, 1);
                if($firstChar eq "*" | $firstChar eq "|" | $firstChar eq "" | $firstChar eq "{" | $firstChar eq "}" | $firstChar eq "\s" | $firstChar eq " " | $firstChar eq "\n" | $lastChar eq "]" | $lastChar eq "}")
                {
                    $para[$i] = "N"; 
                }
             }
            my @correctParagraphs;   
            foreach $newPar(@para)
            {
                if($newPar ne "N")   {
                    push(@correctParagraphs, $newPar);
                }
            }
            $result4;
            foreach $par(@correctParagraphs)  {
                $result4 = $result4 . ' '. $par;
            }
            $array_size = @correctParagraphs;
            my $result4 = join ('', @correctParagraphs[0..$array_size -1]);   
            my @wikiResultSentences = split/\.\s/, $result4;      
            print "$wikiResultSentences[0].\n";
            print DST "Answer: $wikiResultSentences[0].\n";
        }   
    }
    else
    {
        print "Sorry, please rephrase the quesiton.\n";
    }
}




sub WhenStatement
{
    my $sentence = @_;
    if($_[0]=~/\b^(When|when) is \b/)         
    {
        print DST "Search Was executed: $lookUp\n\n\n";
        my $lookUp = $'; #gets whats in the middle of does and mean, so whatever (.+)+ equals 
        $lookUp=~s/\?/ /; 
        my $result = $wiki->search($lookUp);  
        if ( $result->text() ) {              
            my $result2= $result->text();   
            print DST "Wiki Result: \n";
            print DST "$result2\n\n\n";  
            my @para = split/\n\n/, $result2; #split the text by spaces between paragraphs 
            $size = @para;         
            foreach $q(@para){          
                $q =~s/^\s+//;      
                $q =~s/(.)*\]//;        
                $q =~s/^\s+//;
            }
            my $array_size = @para;      
            for $i(0..$array_size -1)     
            {
                $stringOfPara = $para[$i]; 
                $firstChar = substr($stringOfPara, 0, 1);
                $lastChar = substr($stringOfPara, -1, 1);
                if($firstChar eq "*" | $firstChar eq "|" | $firstChar eq "" | $firstChar eq "{" | $firstChar eq "}" | $firstChar eq "\s" | $firstChar eq " " | $firstChar eq "\n" | $lastChar eq "]" | $lastChar eq "}")
                {
                    $para[$i] = "N"; 
                }
             }
            my @correctParagraphs;   
            foreach $newPar(@para)
            {
                if($newPar ne "N")   {
                    push(@correctParagraphs, $newPar);
                }
            }
            $result4;
            foreach $par(@correctParagraphs)  {
                $result4 = $result4 . ' '. $par;
            }
            $array_size = @correctParagraphs;
            my $result4 = join ('', @correctParagraphs[0..$array_size -1]);   
            my @wikiResultSentences = split/\.\s/, $result4;      
            print "$wikiResultSentences[0].\n";
            print DST "Answer: $wikiResultSentences[0].\n";
        }   
    }
    else
    {
        print "Sorry, please rephrase the quesiton.\n";
    }
}





sub WhereStatement
{
    my $sentence = @_;
    if($_[0]=~/\b^(Where|where) is \b/)         
    {
        print DST "Search Was executed: $lookUp\n\n\n";
        my $lookUp = $'; #gets whats in the middle of does and mean, so whatever (.+)+ equals 
        $lookUp=~s/\?/ /; 
        my $result = $wiki->search($lookUp);  
        if ( $result->text() ) {              
            my $result2= $result->text();   
            print DST "Wiki Result: \n";
            print DST "$result2\n\n\n";  
            my @para = split/\n\n/, $result2; #split the text by spaces between paragraphs 
            $size = @para;         
            foreach $q(@para){          
                $q =~s/^\s+//;      
                $q =~s/(.)*\]//;        
                $q =~s/^\s+//;
            }
            my $array_size = @para;      
            for $i(0..$array_size -1)     
            {
                $stringOfPara = $para[$i]; 
                $firstChar = substr($stringOfPara, 0, 1);
                $lastChar = substr($stringOfPara, -1, 1);
                if($firstChar eq "*" | $firstChar eq "|" | $firstChar eq "" | $firstChar eq "{" | $firstChar eq "}" | $firstChar eq "\s" | $firstChar eq " " | $firstChar eq "\n" | $lastChar eq "]" | $lastChar eq "}")
                {
                    $para[$i] = "N"; 
                }
             }
            my @correctParagraphs;   
            foreach $newPar(@para)
            {
                if($newPar ne "N")   {
                    push(@correctParagraphs, $newPar);
                }
            }
            $result4;
            foreach $par(@correctParagraphs)  {
                $result4 = $result4 . ' '. $par;
            }
            $array_size = @correctParagraphs;
            my $result4 = join ('', @correctParagraphs[0..$array_size -1]);   
            my @wikiResultSentences = split/\.\s/, $result4;      
            print "$wikiResultSentences[0].\n";
            print DST "Answer: $wikiResultSentences[0].\n";
        }   
    }
    else
    {
        print "Sorry, please rephrase the quesiton.\n";
    }
}