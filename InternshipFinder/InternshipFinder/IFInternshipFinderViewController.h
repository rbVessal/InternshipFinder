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
#import "IFInternshipFinderDetailViewController.h"

@interface IFInternshipFinderViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, InternshipFinderDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *internshipTypeTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITextField *stateTextField;
@property (weak, nonatomic) IBOutlet UITabBar *tabbar;


-(IBAction)searchInternships:(id)sender;
-(IBAction)saveInternship:(id)sender;

@end
