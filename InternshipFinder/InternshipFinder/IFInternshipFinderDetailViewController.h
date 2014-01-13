//
//  IFDetailViewController.h
//  InternshipFinder
//
//  Created by Rebecca Vessal on 12/23/13.
//  Copyright (c) 2013 Rebecca Vessal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IFDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSURLRequest *urlRequest;

@end
