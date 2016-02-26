//
//  FriendListController.m
//  XMPP_Demo
//
//  Created by 石茗伟 on 16/2/26.
//  Copyright © 2016年 mingway. All rights reserved.
//

#import "FriendListController.h"
#import "FriendListViewModel.h"
#import <ReactiveCocoa.h>

@interface FriendListController ()

@property (nonatomic, strong) FriendListViewModel *viewModel;

@end

@implementation FriendListController

#pragma mark -
#pragma mark life cycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self viewModel];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addNavigationBarButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Getters
- (FriendListViewModel *)viewModel
{
    if (_viewModel == nil) {
        @weakify(self);
        _viewModel = [[FriendListViewModel alloc] init];
        [_viewModel setGetFriendListBlock:^{
            @strongify(self);
            [self updateUI];
        }];
    }
    return _viewModel;
}

#pragma mark -
#pragma mark Private Methods
- (void)updateUI
{
    NSLog(@"刷新好友列表显示");
}

- (void)addNavigationBarButton
{
    UIBarButtonItem *addFriendBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(toAddFriend)];
    self.navigationItem.rightBarButtonItem = addFriendBarButton;
}

- (void)toAddFriend
{
    [self performSegueWithIdentifier:@"toAddFriendSegue" sender:nil];
}

@end
