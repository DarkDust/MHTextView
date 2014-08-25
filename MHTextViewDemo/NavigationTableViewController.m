//
//  NavigationTableViewController.m
//  MHTextViewDemo
//
//  Created by Marc Haisenko on 09.08.14.
//  Copyright (c) 2014 Marc Haisenko. All rights reserved.
//

#import "NavigationTableViewController.h"



@implementation NavigationTableViewController
{
    NSIndexPath *_selectedIndexPath;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self performSegueWithIdentifier:@"BasicDemo" sender:self];
    _selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView selectRowAtIndexPath:_selectedIndexPath
                                animated:NO
                          scrollPosition:UITableViewScrollPositionNone];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NavigationCell" forIndexPath:indexPath];

    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Basic demo";
            break;
            
        case 1:
            cell.textLabel.text = @"AutoLayout demo";
            break;

            
        case 2:
            cell.textLabel.text = @"Custom layout demo";
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedIndexPath = indexPath;
    
    switch (indexPath.row) {
        case 0:
            [self performSegueWithIdentifier:@"BasicDemo" sender:self];
            break;
            
        case 1:
            [self performSegueWithIdentifier:@"AutoLayoutDemo" sender:self];
            break;
            
        case 2:
            [self performSegueWithIdentifier:@"CustomLayoutDemo" sender:self];
            break;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
