//
//  LoginViewModel.m
//  XMPP_Demo
//
//  Created by 石茗伟 on 16/2/25.
//  Copyright © 2016年 mingway. All rights reserved.
//

#import "LoginViewModel.h"
#import "XMPPManager.h"

@implementation LoginViewModel

#pragma mark -
#pragma mark Public Methods
- (void)connetXMPPServerWithUserName:(NSString *)username
                            password:(NSString *)password
{
    [[XMPPManager shared] connectWithUserName:username password:password];
}

@end
