//
//  IFInternshipFinder.h
//  InternshipFinder
//
//  Created by Rebecca Vessal on 12/23/13.
//  Copyright (c) 2013 Rebecca Vessal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IFInternship : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *company;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *briefDescription;
@property (nonatomic, strong) NSString *fullDescription;

@end
