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
        [RACObserve([XMPPManager shared], friendList) subscribeNext:^(NSArray *friends) {
            @strongify(self);
            self.friends = friends;
            self.getFriendListBlock();
        }];
    }
    return self;
}

#pragma mark -
#pragma mark Private Methods

@end
