//
//  IFMasterViewController.h
//  InternshipFinder
//
//  Created by Rebecca Vessal on 10/2/13.
//  Copyright (c) 2013 Rebecca Vessal. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IFDetailViewController;

@interface IFMasterViewController : UITableViewController

@property (strong, nonatomic) IFDetailViewController *detailViewController;

@end
