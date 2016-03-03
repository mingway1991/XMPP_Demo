//
//  FriendListViewModel.h
//  XMPP_Demo
//
//  Created by 石茗伟 on 16/2/26.
//  Copyright © 2016年 mingway. All rights reserved.
//

#import "BaseViewModel.h"

typedef void(^GetFriendListSuccess)();

@interface FriendListViewModel : BaseViewModel

@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, copy) GetFriendListSuccess getFriendListBlock;

- (void)setGetFriendListBlock:(GetFriendListSuccess)getFriendListBlock;
- (void)refreshFriendList;

@end
