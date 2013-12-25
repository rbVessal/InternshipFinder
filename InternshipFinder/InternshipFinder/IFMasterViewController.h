//
//  IFMasterViewController.h
//  InternshipFinder
//
//  Created by Rebecca Vessal on 12/23/13.
//  Copyright (c) 2013 Rebecca Vessal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFHpple.h"
#import "IFInternship.h"

@class IFDetailViewController;

@interface IFMasterViewController : UITableViewController <UISearchBarDelegate>


@property (strong, nonatomic) IFDetailViewController *detailViewController;

@property (weak, nonatomic) IBOutlet UITextField *internshipTypeTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITextField *stateTextField;

-(IBAction)searchInternships:(id)sender;

-(void)loadInternships;

@end
