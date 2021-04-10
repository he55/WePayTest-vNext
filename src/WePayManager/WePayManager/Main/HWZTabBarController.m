//
//  HWZTabBarController.m
//  WePayManager
//
//  Created by 何伟忠 on 6/3/20.
//  Copyright © 2020 何伟忠. All rights reserved.
//

#import "HWZTabBarController.h"
#import "HWZMessageTableViewController.h"
#import "HWZSettingsTableViewController.h"

@interface HWZTabBarController ()

@end


@implementation HWZTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addMessagesViewController];
    [self addSettingsViewController];
}


- (void)addMessagesViewController {
    HWZMessageTableViewController *messageTableViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"HWZMessageTableViewController"];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:messageTableViewController];
    navigationController.tabBarItem.title = @"收款数据";
    navigationController.tabBarItem.image = [UIImage systemImageNamed:@"square.grid.2x2.fill"];
    
    [self addChildViewController:navigationController];
}


- (void)addSettingsViewController {
    HWZSettingsTableViewController *settingsViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"HWZSettingsTableViewController"];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    navigationController.tabBarItem.title = @"设置";
    navigationController.tabBarItem.image = [UIImage systemImageNamed:@"gear"];
    
    [self addChildViewController:navigationController];
}

@end
