//
//  IFInternshipFinder.m
//  InternshipFinder
//
//  Created by Rebecca Vessal on 1/10/14.
//  Copyright (c) 2014 Rebecca Vessal. All rights reserved.
//

#import "IFInternshipFinder.h"

@implementation IFInternshipFinder
{
    //Private instance variables
    dispatch_queue_t _backgroundQueue;
    NSMutableDictionary *_internshipURLDictionary;
}

//Overide init to initialize the class's instance variables
-(id)init
{
    //Call the super constructor which is NSObject's constructor
    self = [super init];
    //Initialize the instance variables
    _backgroundQueue = dispatch_queue_create("background", NULL);
    _internshipDictionary = [[NSMutableDictionary alloc]init];
    _internshipURLDictionary = [[NSMutableDictionary alloc]initWithCapacity:NUMBER_OF_INTERNSHIP_WEBSITES];
    
    return self;
}

//Clear out the previous internship search results
-(void)clearOldInternships
{
    [_internshipDictionary removeAllObjects];
    [_internshipURLDictionary removeAllObjects];
}

//Convenience method for replacing characters in the user's input
-(void)replaceCharacterWithCharacterInInternshipString:(NSString*)firstCharacter withSecondCharacter:(NSString*)secondCharacter
{
    _internshipType = [_internshipType stringByReplacingOccurrencesOfString:firstCharacter withString:secondCharacter];
    _internshipCityLocation = [_internshipCityLocation stringByReplacingOccurrencesOfString:firstCharacter withString:secondCharacter];
    _internshipStateLocation = [_internshipStateLocation stringByReplacingOccurrencesOfString:firstCharacter withString:secondCharacter];
}

//Create URL strings based on the user's input for the different internship host websites
-(void)createURLStrings
{
    //Replace spaces with '+' signs for query for internmatch.com
    [self replaceCharacterWithCharacterInInternshipString:@" " withSecondCharacter:@"+"];
    
    //Download the internship page and get the raw data from it
    //Use NSURLConnection to make this async and cache the data
    //Add %% to escape the %
    //see: http://stackoverflow.com/questions/739682/how-to-add-percent-sign-to-nsstring
    NSURL *internMatchInternshipsURL = [NSURL URLWithString:[NSString stringWithFormat: @"http://www.internmatch.com/search/internships?&&&count=10&filters%%5Blisting_type%%5D=Internship&location=%@%%2C+%@&page=1&q=%@&sort=relevance", _internshipCityLocation, _internshipStateLocation, _internshipType]];
    [_internshipURLDictionary setObject: internMatchInternshipsURL forKey:@"InternMatch"];
    
    //Replace '+' with '-' signs for query for linkedin.com
    [self replaceCharacterWithCharacterInInternshipString:@"+" withSecondCharacter:@"-"];
    NSURL *linkedinInternshipsURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.linkedin.com/job/q-%@-intern-%@-jobs", _internshipType, _internshipCityLocation]];
    
    [_internshipURLDictionary setObject:linkedinInternshipsURL forKey:@"LinkedIn"];
}

-(void)startSearch
{
    //Do the search asynchronously on the background thread using Grand central
    //dispatch so that the user can still interact with the UI which is on the main thread
    dispatch_async(_backgroundQueue, ^(void)
   {
       //Load in the results
       [self loadInternships];
   });

}

//Create InternMatch internships based on the html parsing of the InternMatch site
-(NSMutableArray*)createInternMatchInternships:(NSArray*)internshipsNodes
{
    NSMutableArray *newInternships = [[NSMutableArray alloc]init];
    
    //Create an internship object to hold the information
    //needed to be displayed in the tableview cell
    //The information can be found in the hpple element nodes
    //The internship nodes are ordered according to the structure of the tree
    //For example, it will find the a tag with title and url, then the organization div tag with most
    //likely the company name, and then the span tag if there is one.  The span tag will have the
    //company name that was not found in the organization div tag
    int companyCounter = 0;
    for(TFHppleElement *element in internshipsNodes)
    {
        
        //Check to make sure the content is not nil, this is a known bug with hpple parser
        if([[element firstChild] content] != nil && [element objectForKey:@"href"] != nil)
        {
            IFInternship *internship = [[IFInternship alloc]init];
            internship.title = [[element firstChild] content];
            internship.url = [NSString stringWithFormat:@"http://www.internmatch.com/%@",[element objectForKey:@"href"]];
            [newInternships addObject:internship];
        }
        else if([[element objectForKey:@"class"] isEqualToString: @"organization"])
        {
            IFInternship *internship = [newInternships objectAtIndex:companyCounter];
            internship.company = [[element firstChild]content];
            internship.company = [internship.company stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            companyCounter++;
        }
        else if([[element objectForKey:@"class"] isEqualToString:@"text"])
        {
            //for internmatch.com any company name for an internship that has a link embedded
            //in it is a span tag and also has a /n for the organization div tag
            //so we need to decrement the counter to get the right internship
            companyCounter--;
            IFInternship *internship = [newInternships objectAtIndex:companyCounter];
            internship.company = [[element firstChild]content];
            companyCounter++;
        }
        else if([[element objectForKey:@"class"] isEqualToString:@"briefDescription"])
        {
            companyCounter--;
            IFInternship *internship = [newInternships objectAtIndex:companyCounter];
            internship.briefDescription = [[element firstChild]content];
            //Remove word wrapping in the brief description if there is any
            internship.briefDescription = [internship.briefDescription stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            internship.briefDescription = [internship.briefDescription stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            companyCounter++;
        }
        else
        {
            companyCounter--;
            IFInternship *internship = [newInternships objectAtIndex:companyCounter];
            internship.location = [[element firstChild]content];
            companyCounter++;
        }
    }
    return newInternships;
    
}

//Create LinkedIn internships based on the html parsing of the LinkedIn site
-(NSMutableArray*)createLinkedInInternships:(NSArray*)internshipsNodes
{
    NSMutableArray *newInternships = [[NSMutableArray alloc]init];
    int companyCounter = 0;
    for(TFHppleElement *element in internshipsNodes)
    {
        if([[element objectForKey:@"class"] isEqualToString:@"title"])
        {
            IFInternship *internship = [[IFInternship alloc]init];
            internship.title = [[element firstChild] content];
            internship.url = [element objectForKey:@"href"];
            [newInternships addObject:internship];
        }
        else if([[element objectForKey:@"class"] isEqualToString:@"company"])
        {
            IFInternship *internship = [newInternships objectAtIndex:companyCounter];
            internship.company = [[element firstChild]content];
            companyCounter++;
        }
        else if([[element objectForKey:@"itemprop"] isEqualToString:@"addressLocality"])
        {
            companyCounter--;
            IFInternship *internship = [newInternships objectAtIndex:companyCounter];
            internship.location = [[element firstChild]content];
            companyCounter++;
        }
        else
        {
            companyCounter--;
            IFInternship *internship = [newInternships objectAtIndex:companyCounter];
            internship.briefDescription = [[element firstChild]content];
            companyCounter++;
        }
    }
    return newInternships;
}

//Load in the internships based on the user's input
-(void)loadInternships
{
    for(id internshipPostHost in [_internshipURLDictionary allKeys])
    {
        NSURL *internshipPostHostURL = [_internshipURLDictionary objectForKey:internshipPostHost];
        NSURLRequest *internshipURLRequest = [NSURLRequest requestWithURL:internshipPostHostURL];
        NSOperationQueue *queue = [[NSOperationQueue alloc]init];
        
        [NSURLConnection sendAsynchronousRequest:internshipURLRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             //Create the Hpple parser to use for HTML parsing with the raw data from the internship page
             TFHpple *internshipsParser = [TFHpple hppleWithHTMLData:data];
             
             //Ask for the information you seek with the query string
             //The information will come back as nodes
             //Use union operator to get nodes at different levels
             //see: http://stackoverflow.com/questions/11040469/xpath-how-to-select-multiple-nodes-in-different-levels
             
             NSString *internshipsXpathQueryString;
             NSMutableArray *newInternships;
             if([internshipPostHost isEqualToString:@"InternMatch"])
             {
                 internshipsXpathQueryString = @"//ul[@class = 'internships']/li/div[@class = 'card internship linkable']/div[@class = 'title']/a | //ul[@class = 'internships']/li/div[@class = 'card internship linkable']/div[@class = 'highlights']/div[@class = 'organization'] | //ul[@class = 'internships']/li/div[@class = 'card internship linkable']/div[@class = 'highlights']/div[@class = 'organization']/a/span | //div[@class = 'details']/span[1] | //div[@class = 'briefDescription']";
                 
                 NSArray *internshipsNodes = [internshipsParser searchWithXPathQuery:internshipsXpathQueryString];
                 
                 newInternships = [self createInternMatchInternships:internshipsNodes];
                 [_internshipDictionary setObject:newInternships forKey:@"InternMatch"];
                 
             }
             else
             {
                 
                 internshipsXpathQueryString = @"//div[@class = 'content']/h3/a | //div[@class = 'content']/div[@itemprop = 'hiringOrganization']/a | //div[@class = 'content']/div[@class = 'details']/span[@itemprop = 'jobLocation']/span[@itemprop = 'address']/span[@itemprop = 'addressLocality'] | //div[@class = 'content']/dl[@class = 'snippet']/dd/p[@itemprop = 'description']";
                 
                 NSArray *internshipsNodes = [internshipsParser searchWithXPathQuery:internshipsXpathQueryString];
                 
                 newInternships = [self createLinkedInInternships:internshipsNodes];
                 [_internshipDictionary setObject:newInternships forKey:@"LinkedIn"];
                 
                 
             }
             //Switch back to main queue to update the UI
             //see: http://www.raywenderlich.com/31166/25-ios-app-performance-tips-tricks#mainthread
             if([_internshipDictionary allKeys].count == NUMBER_OF_INTERNSHIP_WEBSITES)
             {
                 dispatch_async(dispatch_get_main_queue(), ^(void)
                {
                    
                    [self.delegate updateTableViewWithInternshipResults];
                    
                });
             }
             
             
         }];
        
    }
}


@end
