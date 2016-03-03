//
//  FriendListViewModel.m
//  XMPP_Demo
//
//  Created by 石茗伟 on 16/2/26.
//  Copyright © 2016年 mingway. All rights reserved.
//

#import "FriendListViewModel.h"
#import "XMPPManager.h"
#import <ReactiveCocoa.h>

@implementation FriendListViewModel

#pragma mark -
#pragma mark Init
- (instancetype)init
{
    self = [super init];
    if (self) {
        @weakify(self);
        [RACObserve([XMPPManager shared], friendList) subscribeNext:^(id x) {
            @strongify(self);
            self.friends = [XMPPManager shared].friendList;
            if (self.getFriendListBlock != nil) {
                self.getFriendListBlock();
            }
        }];
    }
    return self;
}

#pragma mark -
#pragma mark Public Methods
- (void)refreshFriendList
{
    [[XMPPManager shared] getFriendList];
}

@end
