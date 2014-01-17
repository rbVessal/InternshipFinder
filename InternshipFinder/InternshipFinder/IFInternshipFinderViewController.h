//
//  IFMasterViewController.h
//  InternshipFinder
//
//  Created by Rebecca Vessal on 12/23/13.
//  Copyright (c) 2013 Rebecca Vessal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFInternshipFinder.h"
#import "IFInternship.h"
#import "IFInternshipCell.h"

@class IFDetailViewController;

@interface IFMasterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, InternshipFinderDelegate>


@property (strong, nonatomic) IFDetailViewController *detailViewController;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *internshipTypeTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITextField *stateTextField;
@property (weak, nonatomic) IBOutlet UITabBar *tabbar;


-(IBAction)searchInternships:(id)sender;

@end
