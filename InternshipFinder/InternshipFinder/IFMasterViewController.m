//
//  IFMasterViewController.m
//  InternshipFinder
//
//  Created by Rebecca Vessal on 12/23/13.
//  Copyright (c) 2013 Rebecca Vessal. All rights reserved.
//

#import "IFMasterViewController.h"
#import "IFDetailViewController.h"

#define NUMBER_OF_INTERNSHIP_WEBSITES 2

@interface IFMasterViewController ()
{
    //Private instance variables
    NSString *_internshipType;
    NSString *_internshipCityLocation;
    NSString *_internshipStateLocation;
    NSString *_searchType;//optional if you want to search for both full-time and internships
    dispatch_queue_t _backgroundQueue;
    UIActivityIndicatorView *_uiActivityIndicatorView;
    NSMutableDictionary *_internshipURLDictionary;
    NSMutableDictionary *_internshipDictionary;
    
}
@end

@implementation IFMasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.detailViewController = (IFDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    //Initialize the dispatch queue
    _backgroundQueue = dispatch_queue_create("background", NULL);
    //Initialize the spinner
    _uiActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _uiActivityIndicatorView.hidesWhenStopped = YES;
    _uiActivityIndicatorView.hidden = YES;
    //_uiActivityIndicatorView.color = [UIColor blackColor];
    [_uiActivityIndicatorView setCenter:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)];
    
    _internshipDictionary = [[NSMutableDictionary alloc]init];
    _internshipURLDictionary = [[NSMutableDictionary alloc]initWithCapacity:NUMBER_OF_INTERNSHIP_WEBSITES];
    
    [self.view addSubview:_uiActivityIndicatorView];
    
}

//Search for internships based on the user's input
-(IBAction)searchInternships:(id)sender
{
    //Dismiss the keyboard
    [self.internshipTypeTextField resignFirstResponder];
    [self.cityTextField resignFirstResponder];
    [self.stateTextField resignFirstResponder];
    //Grab the user's input for the internship search
    _internshipType = self.internshipTypeTextField.text;
    _internshipCityLocation = self.cityTextField.text;
    _internshipStateLocation = self.stateTextField.text;
    [self clearOldInternships];
    [self createURLStrings];
    
    _uiActivityIndicatorView.hidden = NO;
    [_uiActivityIndicatorView startAnimating];
    
    //Do the search asynchronously on the background thread using Grand central
    //dispatch so that the user can still interact with the UI which is on the main thread
    dispatch_async(_backgroundQueue, ^(void)
    {
        //Load in the results
        [self loadInternships];
        
        
    });
   
}

-(void)clearOldInternships
{
    [_internshipDictionary removeAllObjects];
    [_internshipURLDictionary removeAllObjects];
}

-(void)replaceCharacterWithCharacterInInternshipString:(NSString*)firstCharacter withSecondCharacter:(NSString*)secondCharacter
{
    _internshipType = [_internshipType stringByReplacingOccurrencesOfString:firstCharacter withString:secondCharacter];
    _internshipCityLocation = [_internshipCityLocation stringByReplacingOccurrencesOfString:firstCharacter withString:secondCharacter];
    _internshipStateLocation = [_internshipStateLocation stringByReplacingOccurrencesOfString:firstCharacter withString:secondCharacter];
}

-(void)createURLStrings
{
    //Replace spaces with '+' signs for query for internmatch.com
    [self replaceCharacterWithCharacterInInternshipString:@" " withSecondCharacter:@"+"];
    
    //Download the internship page and get the raw data from it
    //Use NSURLConnection to make this async and cache the data
    //Add %% to escape the %
    //see: http://stackoverflow.com/questions/739682/how-to-add-percent-sign-to-nsstring
    NSURL *internMatchInternshipsURL = [NSURL URLWithString:[NSString stringWithFormat: @"http://www.internmatch.com/search/internships?&&&count=10&location=%@%%2C+%@&page=1&q=%@&sort=relevance", _internshipCityLocation, _internshipStateLocation, _internshipType]];
        [_internshipURLDictionary setObject: internMatchInternshipsURL forKey:@"InternMatch"];
    
    //Replace '+' with '-' signs for query for linkedin.com
    [self replaceCharacterWithCharacterInInternshipString:@"+" withSecondCharacter:@"-"];
    NSURL *linkedinInternshipsURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.linkedin.com/job/q-%@-intern-%@-jobs", _internshipType, _internshipCityLocation]];
    
    [_internshipURLDictionary setObject:linkedinInternshipsURL forKey:@"LinkedIn"];
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
            internship.url = [element objectForKey:@"href"];
            [newInternships addObject:internship];
        }
        else if([[element objectForKey:@"class"] isEqualToString: @"organization"])
        {
            IFInternship *internship = [newInternships objectAtIndex:companyCounter];
            internship.company = [[element firstChild]content];
            internship.company = [internship.company stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            companyCounter++;
        }
        else
        {
            //for internmatch.com any company name for an internship that has a link embedded
            //in it is a span tag and also has a /n for the organization div tag
            //so we need to decrement the counter to get the right internship
            companyCounter--;
            IFInternship *internship = [newInternships objectAtIndex:companyCounter];
            internship.company = [[element firstChild]content];
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
                internshipsXpathQueryString = @"//ul[@class = 'internships']/li/div[@class = 'card internship linkable']/div[@class = 'title']/a | //ul[@class = 'internships']/li/div[@class = 'card internship linkable']/div[@class = 'highlights']/div[@class = 'organization'] | //ul[@class = 'internships']/li/div[@class = 'card internship linkable']/div[@class = 'highlights']/div[@class = 'organization']/a/span";
                
                NSArray *internshipsNodes = [internshipsParser searchWithXPathQuery:internshipsXpathQueryString];
                
                newInternships = [self createInternMatchInternships:internshipsNodes];
                [_internshipDictionary setObject:newInternships forKey:@"InternMatch"];

            }
            else
            {

                internshipsXpathQueryString = @"//div[@class = 'content']/h3/a | //div[@class = 'content']/div[@itemprop = 'hiringOrganization']/a";
                
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
                   [_uiActivityIndicatorView stopAnimating];
                   //Refresh the tableview with new data
                   [self.tableView reloadData];
                   
               });
            }


        }];
    
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUMBER_OF_INTERNSHIP_WEBSITES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch(section)
    {
        case 0:
        {
            return @"InternMatch.com";
        }
        case 1:
        {
            return @"LinkedIn.com";
        }
        default:
        {
            return @"";
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    //Note:  In storyboards, the resusable cell is never nil, so no need to check for this
    switch (indexPath.section)
    {
        case 0:
        {
            NSMutableArray *internships = [_internshipDictionary objectForKey:@"InternMatch"];
            IFInternship *internship = [internships objectAtIndex:indexPath.row];
            cell.textLabel.text = internship.title;
            cell.detailTextLabel.text = internship.company;
            break;
        }
        case 1:
        {
            NSMutableArray *internships = [_internshipDictionary objectForKey:@"LinkedIn"];
            IFInternship *internship = [internships objectAtIndex:indexPath.row];
            cell.textLabel.text = internship.title;
            cell.detailTextLabel.text = internship.company;
            break;
        }
        default:
        {
            return nil;
        }
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        /*NSDate *object = _objects[indexPath.row];
        self.detailViewController.detailItem = object;*/
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        /*NSDate *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];*/
    }
}

@end
