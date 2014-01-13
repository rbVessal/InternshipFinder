//
//  IFInternshipCell.h
//  InternshipFinder
//
//  Created by Rebecca Vessal on 1/12/14.
//  Copyright (c) 2014 Rebecca Vessal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IFInternshipCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *companyNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet UILabel *datePostedLabel;
@property (nonatomic, weak) IBOutlet UILabel *briefDescriptionLabel;

@end
