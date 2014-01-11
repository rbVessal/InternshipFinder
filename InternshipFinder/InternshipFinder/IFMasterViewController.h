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

@class IFDetailViewController;

@interface IFMasterViewController : UITableViewController <UISearchBarDelegate>


@property (strong, nonatomic) IFDetailViewController *detailViewController;

@property (weak, nonatomic) IBOutlet UITextField *internshipTypeTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITextField *stateTextField;

@property (strong, nonatomic) UIActivityIndicatorView *uiActivityIndicatorView;


-(IBAction)searchInternships:(id)sender;

@end
