//
//  LoginViewModel.h
//  XMPP_Demo
//
//  Created by 石茗伟 on 16/2/25.
//  Copyright © 2016年 mingway. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginViewModel : NSObject

- (void)connetXMPPServerWithUserName:(NSString *)username
                            password:(NSString *)password;

@end
