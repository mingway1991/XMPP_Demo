//
//  BaseTabBarController.m
//  XMPP_Demo
//
//  Created by 石茗伟 on 16/2/25.
//  Copyright © 2016年 mingway. All rights reserved.
//

#import "BaseTabBarController.h"

@interface BaseTabBarController ()

@end

@implementation BaseTabBarController

#pragma mark -
#pragma mark life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self performSelectorOnMainThread:@selector(presentLoginController) withObject:nil waitUntilDone:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Private Methods
- (void)presentLoginController
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *nav = [sb instantiateViewControllerWithIdentifier:@"LoginNav"];
    [self presentViewController:nav animated:YES completion:NULL];
}

@end
