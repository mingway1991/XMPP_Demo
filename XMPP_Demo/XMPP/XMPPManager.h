//
//  XMPPManager.h
//  XMPP_Demo
//
//  Created by 石茗伟 on 16/2/25.
//  Copyright © 2016年 mingway. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XMPPManagerDelegate <NSObject>

- (void)didReceiveMessage:(NSString *)message fromUser:(NSString *)fromUser;

@end

@interface XMPPManager : NSObject

@property (nonatomic, weak) id<XMPPManagerDelegate> delegate;
@property (nonatomic, assign) BOOL isOnline;
@property (nonatomic, strong) NSArray *friendList;

+ (instancetype)shared;
- (BOOL)connectWithUserName:(NSString *)username
                   password:(NSString *)password;
- (void)disconnect;
- (void)getFriendList;
- (void)sendFriendRequestWithUsername:(NSString *)username;
- (void)removeFriendWithUsername:(NSString *)username;

//发消息
- (void)sendToUser:(NSString *)user textMessage:(NSString *)messageStr;

@end
