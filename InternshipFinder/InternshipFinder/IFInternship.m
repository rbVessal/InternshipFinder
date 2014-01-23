//
//  IFInternshipFinder.m
//  InternshipFinder
//
//  Created by Rebecca Vessal on 12/23/13.
//  Copyright (c) 2013 Rebecca Vessal. All rights reserved.
//

#import "IFInternship.h"

NSString *const kIFInternshipTitle = @"Title";
NSString *const kIFInternshipCompany = @"Company";
NSString *const kIFInternshipUrl = @"Url";
NSString *const kIFInternshipLocation = @"Location";
NSString *const kIFInternshipBriefDescription = @"Brief Description";

@implementation IFInternship

#pragma mark - NSCoder Protocols
- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.title forKey:kIFInternshipTitle];
    [coder encodeObject:self.company forKey:kIFInternshipCompany];
    [coder encodeObject:self.url forKey:kIFInternshipUrl];
    [coder encodeObject:self.location forKey:kIFInternshipLocation];
    [coder encodeObject:self.briefDescription forKey:kIFInternshipBriefDescription];
    
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        _title = [aDecoder decodeObjectForKey:kIFInternshipTitle];
        _company = [aDecoder decodeObjectForKey:kIFInternshipCompany];
        _url = [aDecoder decodeObjectForKey:kIFInternshipUrl];
        _location = [aDecoder decodeObjectForKey:kIFInternshipLocation];
        _briefDescription = [aDecoder decodeObjectForKey:kIFInternshipBriefDescription];
    }
    return self;
}

@end
