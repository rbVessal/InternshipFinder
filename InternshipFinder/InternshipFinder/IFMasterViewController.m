//
//  IFMasterViewController.m
//  InternshipFinder
//
//  Created by Rebecca Vessal on 12/23/13.
//  Copyright (c) 2013 Rebecca Vessal. All rights reserved.
//

#import "IFMasterViewController.h"

#import "IFDetailViewController.h"

@interface IFMasterViewController ()
{
    //Private instance variables
    NSMutableArray *_objects;
    NSString *_internshipType;
    NSString *_internshipCityLocation;
    NSString *_internshipStateLocation;
    NSString *_searchType;//optional if you want to search for both full-time and internships
    dispatch_queue_t _backgroundQueue;
    UIActivityIndicatorView *_uiActivityIndicatorView;
    
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
    //Replace spaces with '+' signs for query
    _internshipType = [_internshipType stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    _internshipCityLocation = [_internshipCityLocation stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    _internshipStateLocation = [_internshipStateLocation stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
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

//Load in the internships based on the user's input
-(void)loadInternships
{
    //Download the internship page and get the raw data from it
    //Use NSURLConnection to make this async and cache the data
    //Add %% to escape the %
    //see: http://stackoverflow.com/questions/739682/how-to-add-percent-sign-to-nsstring
    NSURL *internshipsURL = [NSURL URLWithString:[NSString stringWithFormat: @"http://www.internmatch.com/search/internships?&&&count=10&location=%@%%2C+%@&page=1&q=%@&sort=relevance", _internshipCityLocation, _internshipStateLocation, _internshipType]];
    
    NSURLRequest *internshipURLRequest = [NSURLRequest requestWithURL:internshipsURL];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    [NSURLConnection sendAsynchronousRequest:internshipURLRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *erro){
        //Create the Hpple parser to use for HTML parsing with the raw data from the internship page
        TFHpple *internshipsParser = [TFHpple hppleWithHTMLData:data];
        
        //Ask for the information you seek with the query string
        //The information will come back as nodes
        //Use union operator to get nodes at different levels
        //see: http://stackoverflow.com/questions/11040469/xpath-how-to-select-multiple-nodes-in-different-levels
        NSString *internshipsXpathQueryString = @"//ul[@class = 'internships']/li/div[@class = 'card internship linkable']/div[@class = 'title']/a | //ul[@class = 'internships']/li/div[@class = 'card internship linkable']/div[@class = 'highlights']/div[@class = 'organization'] | //ul[@class = 'internships']/li/div[@class = 'card internship linkable']/div[@class = 'highlights']/div[@class = 'organization']/a/span";
        NSArray *internshipsNodes = [internshipsParser searchWithXPathQuery:internshipsXpathQueryString];
        
        
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
        
        //Update the objects array that the table view uses as data
        //for the cells
        _objects = newInternships;
        
        [_uiActivityIndicatorView stopAnimating];
        //Refresh the tableview with new data
        [self.tableView reloadData];


    }];
    
    
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
    [self.view addSubview:_uiActivityIndicatorView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    //Note:  In storyboards, the resusable cell is never nil, so no need to check for this
    IFInternship *internship = [_objects objectAtIndex:indexPath.row];
    cell.textLabel.text = internship.title;
    cell.detailTextLabel.text = internship.company;

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
        [_objects removeObjectAtIndex:indexPath.row];
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
        NSDate *object = _objects[indexPath.row];
        self.detailViewController.detailItem = object;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

@end
