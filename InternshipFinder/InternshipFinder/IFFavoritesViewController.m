//
//  IFFavoritesViewController.m
//  InternshipFinder
//
//  Created by Rebecca Vessal on 1/22/14.
//  Copyright (c) 2014 Rebecca Vessal. All rights reserved.
//

#import "IFFavoritesViewController.h"

@interface IFFavoritesViewController ()
{
    //Private instance variable
    NSMutableDictionary *_savedInternships;
}

@end

@implementation IFFavoritesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _savedInternships = [[NSUserDefaults standardUserDefaults]objectForKey:@"Saved Internships"];
}

#pragma mark - TableView Protocols
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUMBER_OF_INTERNSHIPS_SITES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
        {
            return[[_savedInternships objectForKey:@"InternMatch"]count];
        }
        case 1:
        {
            return[[_savedInternships objectForKey:@"LinkedIn"]count];
        }
            
        default:
        {
            return 1;
        }
    }
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
            NSMutableArray *internships = [_savedInternships objectForKey:@"InternMatch"];
            NSData *internshipData = [internships objectAtIndex:indexPath.row];
            IFInternship *internship = [NSKeyedUnarchiver unarchiveObjectWithData:internshipData];
            cell.titleLabel.text = internship.title;
            cell.companyNameLabel.text = internship.company;
            cell.locationLabel.text = internship.location;
            cell.briefDescriptionLabel.text = internship.briefDescription;
            break;
        }
        case 1:
        {
            NSMutableArray *internships = [_savedInternships objectForKey:@"LinkedIn"];
            NSData *internshipData = [internships objectAtIndex:indexPath.row];
            IFInternship *internship = [NSKeyedUnarchiver unarchiveObjectWithData:internshipData];
            cell.titleLabel.text = internship.title;
            cell.companyNameLabel.text = internship.company;
            cell.locationLabel.text = internship.location;
            cell.briefDescriptionLabel.text = internship.briefDescription;
            break;
        }
        default:
        {
            return cell;
        }
    }
    return cell;
}

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
                NSMutableArray *internships = [_savedInternships objectForKey:@"InternMatch"];
                NSData *internshipData = [internships objectAtIndex:indexPath.row];
                IFInternship *internship = [NSKeyedUnarchiver unarchiveObjectWithData:internshipData];
                [[segue destinationViewController]setUrlRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:internship.url]]];
                break;
            }
            case 1:
            {
                NSMutableArray *internships = [_savedInternships objectForKey:@"LinkedIn"];
                NSData *internshipData = [internships objectAtIndex:indexPath.row];
                IFInternship *internship = [NSKeyedUnarchiver unarchiveObjectWithData:internshipData];
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
