//
//  ChatController.h
//  XMPP_Demo
//
//  Created by 石茗伟 on 16/2/26.
//  Copyright © 2016年 mingway. All rights reserved.
//

#import "BaseViewController.h"

@class XMPPJID;
@interface ChatController : BaseViewController

@property (nonatomic, strong) XMPPJID *others;

@end
