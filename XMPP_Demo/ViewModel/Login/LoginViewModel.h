//
//  LoginViewModel.h
//  XMPP_Demo
//
//  Created by 石茗伟 on 16/2/25.
//  Copyright © 2016年 mingway. All rights reserved.
//

#import "BaseViewModel.h"

typedef void(^LoginSuccess)();

@interface LoginViewModel : BaseViewModel

@property (nonatomic, copy) LoginSuccess loginSuccess;

- (void)setLoginSuccess:(LoginSuccess)loginSuccess;
- (void)connetXMPPServerWithUserName:(NSString *)username
                            password:(NSString *)password;

@end
