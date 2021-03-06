//
//  IFMasterViewController.m
//  InternshipFinder
//
//  Created by Rebecca Vessal on 12/23/13.
//  Copyright (c) 2013 Rebecca Vessal. All rights reserved.
//

#import "IFInternshipFinderViewController.h"


@interface IFInternshipFinderViewController ()
{
    //Private instance variables
    IFInternshipFinder *_internshipFinder;
    IFInternshipFinderDetailViewController *_detailViewController;
    UIActivityIndicatorView *_uiActivityIndicatorView;
}
@end

@implementation IFInternshipFinderViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _detailViewController = (IFInternshipFinderDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
   
    //Initialize the spinner
    _uiActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _uiActivityIndicatorView.hidesWhenStopped = YES;
    _uiActivityIndicatorView.hidden = YES;
    //_uiActivityIndicatorView.color = [UIColor blackColor];
    [_uiActivityIndicatorView setCenter:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)];
    [self.view addSubview:_uiActivityIndicatorView];
    
    //Initialize the internship finder
    _internshipFinder = [[IFInternshipFinder alloc]init];
    //Set the delegate relationship between view controller and model
    //to update the table view with the new internship results
    _internshipFinder.delegate = self;
    
}

#pragma mark - IBActions (Buttons)

//Search for internships based on the user's input
-(IBAction)searchInternships:(id)sender
{
    //Dismiss the keyboard
    [self.internshipTypeTextField resignFirstResponder];
    [self.cityTextField resignFirstResponder];
    [self.stateTextField resignFirstResponder];
    //Grab the user's input for the internship search
    _internshipFinder.internshipType = self.internshipTypeTextField.text;
    _internshipFinder.internshipCityLocation = self.cityTextField.text;
    _internshipFinder.internshipStateLocation = self.stateTextField.text;
    [_internshipFinder clearOldInternships];
    [_internshipFinder createURLStrings];
    
    _uiActivityIndicatorView.hidden = NO;
    [_uiActivityIndicatorView startAnimating];
    
    //Start the search and load in the internships results in the tableview
    [_internshipFinder startSearch];
}

//Save the internship on which the button was pressed on
-(IBAction)saveInternship:(id)sender
{
    //Get the array of previously saved internships from user defaults
    //Note:Immutable objects are returned by NSUserDefaults so we need to make a mutable copy
    //to add more internships to the array
    NSMutableDictionary *previouslySavedInternships = [[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"Saved Internships"] mutableCopy];
    if(previouslySavedInternships == nil)
    {
        previouslySavedInternships = [[NSMutableDictionary alloc]init];
        NSMutableArray *savedInternMatchInternshipsArray = [[NSMutableArray alloc]init];
        [previouslySavedInternships setObject:savedInternMatchInternshipsArray forKey:@"InternMatch"];
        NSMutableArray *savedLinkedInInternshipsArray = [[NSMutableArray alloc]init];
        [previouslySavedInternships setObject:savedLinkedInInternshipsArray forKey:@"LinkedIn"];
    }
    else
    {
        NSMutableArray *savedInternMatchInternshipArrayCopy = [[previouslySavedInternships objectForKey:@"InternMatch"] mutableCopy];
        [previouslySavedInternships setObject:savedInternMatchInternshipArrayCopy forKey:@"InternMatch"];
        NSMutableArray *savedLinkedInInternshipArrayCopy = [[previouslySavedInternships objectForKey:@"LinkedIn"] mutableCopy];
        [previouslySavedInternships setObject:savedLinkedInInternshipArrayCopy forKey:@"LinkedIn"];

    }
    
    //Use the button pressed on to pinpoint which is the current cell's indexpath
    //to use to find which internship the user wants to save
    UIButton *saveButton = (UIButton*)sender;
    CGRect convertedRectangle = [saveButton convertRect:saveButton.bounds toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: convertedRectangle.origin];
    switch (indexPath.section)
    {
        case 0:
        {
            NSMutableArray *internships = [_internshipFinder.internshipDictionary objectForKey:@"InternMatch"];
            IFInternship *internship = [internships objectAtIndex:indexPath.row];
            NSData *internshipData = [NSKeyedArchiver archivedDataWithRootObject:internship];
            [[previouslySavedInternships objectForKey:@"InternMatch"] addObject:internshipData];
            break;
        }
        case 1:
        {
            NSMutableArray *internships = [_internshipFinder.internshipDictionary objectForKey:@"LinkedIn"];
            IFInternship *internship = [internships objectAtIndex:indexPath.row];
            NSData *internshipData = [NSKeyedArchiver archivedDataWithRootObject:internship];
            [[previouslySavedInternships objectForKey:@"LinkedIn"] addObject:internshipData];
        }
        default:
        {
            break;
        }
    }
    //Save the internship
    [[NSUserDefaults standardUserDefaults]setObject:previouslySavedInternships forKey:@"Saved Internships"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

#pragma mark - Internship Finder Protocol
//Update the table view with the new internships created from the HMTL parsing
-(void)updateTableViewWithInternshipResults
{
    [_uiActivityIndicatorView stopAnimating];
    [self.tableView reloadData];
}

#pragma mark - Table View Protocols

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUMBER_OF_INTERNSHIP_WEBSITES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
        {
            return [[_internshipFinder.internshipDictionary objectForKey:@"InternMatch"] count];
            break;
        }
        case 1:
        {
            return [[_internshipFinder.internshipDictionary objectForKey:@"LinkedIn"] count];
            break;
        }
        default:
        {
            return 0;
        }
    };
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch(section)
    {
        case 0:
        {
            return @"InternMatch";
        }
        case 1:
        {
            return @"LinkedIn";
        }
        default:
        {
            return @"";
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView*)view;
    switch (section)
    {
        case 0:
        {
            header.contentView.backgroundColor = [UIColor colorWithRed:82.0/255.0 green:64.0/255.0 blue:58.0/255.0 alpha:1.0];
            header.textLabel.textColor = [UIColor whiteColor];
            break;
        }
        case 1:
        {
            header.contentView.backgroundColor = [UIColor colorWithRed:37.0/255.0 green:114.0/255.0 blue:176.0/255.0 alpha:1.0];
            header.textLabel.textColor = [UIColor whiteColor];
            break;
        }
        default:
        {
            break;
        }
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IFInternshipCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InternshipCell"];
    //Note:  In storyboards, the resusable cell is never nil, so no need to check for this
    switch (indexPath.section)
    {
        case 0:
        {
            NSMutableArray *internships = [_internshipFinder.internshipDictionary objectForKey:@"InternMatch"];
            IFInternship *internship = [internships objectAtIndex:indexPath.row];
            cell.titleLabel.text = internship.title;
            cell.companyNameLabel.text = internship.company;
            cell.locationLabel.text = internship.location;
            cell.briefDescriptionLabel.text = internship.briefDescription;
            break;
        }
        case 1:
        {
            NSMutableArray *internships = [_internshipFinder.internshipDictionary objectForKey:@"LinkedIn"];
            IFInternship *internship = [internships objectAtIndex:indexPath.row];
            cell.titleLabel.text = internship.title;
            cell.companyNameLabel.text = internship.company;
            cell.locationLabel.text = internship.location;
            cell.briefDescriptionLabel.text = internship.briefDescription;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        //Open the link to the internship positing based on which internship is selected
        switch (indexPath.section)
        {
            case 0:
            {
                NSMutableArray *internships = [_internshipFinder.internshipDictionary objectForKey:@"InternMatch"];
                IFInternship *internship = [internships objectAtIndex:indexPath.row];
                [[segue destinationViewController]setUrlRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:internship.url]]];
                break;
            }
            case 1:
            {
                NSMutableArray *internships = [_internshipFinder.internshipDictionary objectForKey:@"LinkedIn"];
                IFInternship *internship = [internships objectAtIndex:indexPath.row];
                [[segue destinationViewController]setUrlRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:internship.url]]];
            }
            default:
            {
                break;
            }
        }

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
