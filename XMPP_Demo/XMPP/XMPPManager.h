//
//  XMPPManager.h
//  XMPP_Demo
//
//  Created by 石茗伟 on 16/2/25.
//  Copyright © 2016年 mingway. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMPPManager : NSObject

+ (instancetype)shared;
- (BOOL)connectWithUserName:(NSString *)username
                   password:(NSString *)password;

@end
