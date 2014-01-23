//
//  IFFavoritesViewController.m
//  InternshipFinder
//
//  Created by Rebecca Vessal on 1/22/14.
//  Copyright (c) 2014 Rebecca Vessal. All rights reserved.
//

#import "IFFavoritesViewController.h"

@interface IFFavoritesViewController ()

@end

@implementation IFFavoritesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

#pragma mark - TableView Protocols
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
