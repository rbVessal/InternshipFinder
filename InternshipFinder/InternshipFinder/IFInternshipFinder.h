//
//  IFInternshipFinder.h
//  InternshipFinder
//
//  Created by Rebecca Vessal on 1/10/14.
//  Copyright (c) 2014 Rebecca Vessal. All rights reserved.
//

#import <Foundation/Foundation.h> 
#import "TFHpple.h" //3rd party library for HTML parsing
#import <dispatch/dispatch.h> //To use Grand Centeral Dispatch (GCD)
#import "IFInternship.h" //Model class for internships

#define NUMBER_OF_INTERNSHIP_WEBSITES 2

@protocol InternshipFinderDelegate <NSObject>

@required
-(void)updateTableViewWithInternshipResults;
@end

@interface IFInternshipFinder : NSObject

//Attributes
@property (nonatomic, strong) NSString *internshipType;
@property (nonatomic, strong) NSString *internshipCityLocation;
@property (nonatomic, strong) NSString *internshipStateLocation;
@property (nonatomic, strong) NSMutableDictionary *internshipDictionary;
@property (nonatomic, weak) id <InternshipFinderDelegate> delegate;

//Methods
-(void)clearOldInternships;
-(void)createURLStrings;
-(void)startSearch;

@end
