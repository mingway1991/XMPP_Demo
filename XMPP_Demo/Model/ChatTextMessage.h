//
//  ChatTextMessage.h
//  XMPP_Demo
//
//  Created by 石茗伟 on 16/3/3.
//  Copyright © 2016年 mingway. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatTextMessage : NSObject

@property (nonatomic, strong) NSString *otherUser;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, assign) BOOL isSender;

@end
