//
//  ChatTextCell.h
//  XMPP_Demo
//
//  Created by 石茗伟 on 16/3/3.
//  Copyright © 2016年 mingway. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChatTextMessage;
@interface ChatTextCell : UITableViewCell

- (void)configWithModel:(ChatTextMessage *)model;

@end
