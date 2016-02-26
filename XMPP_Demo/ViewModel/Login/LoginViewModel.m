//
//  LoginViewModel.m
//  XMPP_Demo
//
//  Created by 石茗伟 on 16/2/25.
//  Copyright © 2016年 mingway. All rights reserved.
//

#import "LoginViewModel.h"
#import "XMPPManager.h"
#import <ReactiveCocoa.h>

@implementation LoginViewModel

#pragma mark -
#pragma mark Init
- (instancetype)init
{
    self = [super init];
    if (self) {
        @weakify(self);
        [RACObserve([XMPPManager shared], isOnline)
         subscribeNext:^(id x){
             @strongify(self);
             NSLog(@"%s isOnline: %@", __FUNCTION__, x);
             if ([x boolValue]) {
                 self.loginSuccess();
             }
         }];
    }
    return self;
}

#pragma mark -
#pragma mark Public Methods
- (void)connetXMPPServerWithUserName:(NSString *)username
                            password:(NSString *)password
{
    [[XMPPManager shared] connectWithUserName:username password:password];
}

@end
