//
//  XMPPManager.h
//  XMPP_Demo
//
//  Created by 石茗伟 on 16/2/25.
//  Copyright © 2016年 mingway. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMPPManager : NSObject

@property (nonatomic, assign) BOOL isOnline;
@property (nonatomic, strong) NSArray *friendList;

+ (instancetype)shared;
- (BOOL)connectWithUserName:(NSString *)username
                   password:(NSString *)password;
- (void)disconnect;
- (void)getFriendList;
- (void)sendFriendRequestWithUsername:(NSString *)username;
- (void)removeFriendWithUsername:(NSString *)username;

@end
