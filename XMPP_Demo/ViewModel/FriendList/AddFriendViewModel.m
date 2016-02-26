//
//  AddFriendViewModel.m
//  XMPP_Demo
//
//  Created by 石茗伟 on 16/2/26.
//  Copyright © 2016年 mingway. All rights reserved.
//

#import "AddFriendViewModel.h"
#import "XMPPManager.h"

@implementation AddFriendViewModel

#pragma mark -
#pragma mark Public Methods
- (void)addFriendWithUsername:(NSString *)username
{
    [[XMPPManager shared] sendFriendRequestWithUsername:username];
}

@end
