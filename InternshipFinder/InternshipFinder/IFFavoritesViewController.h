//
//  IFFavoritesViewController.h
//  InternshipFinder
//
//  Created by Rebecca Vessal on 1/22/14.
//  Copyright (c) 2014 Rebecca Vessal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFInternship.h"
#import "IFInternshipCell.h"
#import "IFInternshipFinderDetailViewController.h"

#define NUMBER_OF_INTERNSHIPS_SITES 2

@interface IFFavoritesViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
