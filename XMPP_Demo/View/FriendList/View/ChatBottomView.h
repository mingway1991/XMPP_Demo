//
//  ChatBottomView.h
//  XMPP_Demo
//
//  Created by 石茗伟 on 16/3/3.
//  Copyright © 2016年 mingway. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChatBottomViewDelegate <NSObject>

- (void)didClickSendButtonWithMessage:(NSString *)message;
- (void)bottomViewChangedHeight:(CGFloat)height;

@end

@interface ChatBottomView : UIView

@property (nonatomic, weak) id<ChatBottomViewDelegate> delegate;
- (void)resignFirstResponder;

@end
