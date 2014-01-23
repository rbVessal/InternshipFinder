//
//  IFInternshipFinder.h
//  InternshipFinder
//
//  Created by Rebecca Vessal on 12/23/13.
//  Copyright (c) 2013 Rebecca Vessal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IFInternship : NSObject <NSCoding>

extern NSString *const kIFInternshipTitle;
extern NSString *const kIFInternshipCompany;
extern NSString *const kIFInternshipUrl;
extern NSString *const kIFInternshipLocation;
extern NSString *const kIFInternshipBriefDescription;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *company;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *briefDescription;

@end
