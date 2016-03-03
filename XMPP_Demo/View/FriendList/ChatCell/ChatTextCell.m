//
//  ChatTextCell.m
//  XMPP_Demo
//
//  Created by 石茗伟 on 16/3/3.
//  Copyright © 2016年 mingway. All rights reserved.
//

#import "ChatTextCell.h"
#import "ChatTextMessage.h"

@interface ChatTextCell ()

@property (nonatomic, strong) UIImageView *bubbleImageView;
@property (nonatomic, strong) UITextView *contentTextView;

@end

@implementation ChatTextCell

- (void)awakeFromNib
{
    [self addSubview:self.bubbleImageView];
    [self addSubview:self.contentTextView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)configWithModel:(ChatTextMessage *)model
{
    NSString *content = model.content;
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat textViewMaxWidth = screenWidth - 50 - 16 - 50;
    CGSize size = [content boundingRectWithSize:CGSizeMake(textViewMaxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]} context:nil].size;

    if (model.isSender) {
        
        [self.contentTextView setFrame:CGRectMake(screenWidth - 20 - (size.width + 16), 15, size.width + 16, size.height + 16)];
        [self.bubbleImageView setFrame:CGRectMake(screenWidth - 5 - (size.width + 16 + 20), 5, size.width + 16 + 20, size.height + 16 + 20)];
        self.bubbleImageView.image = [[UIImage imageNamed:@"bubbleSelf"] stretchableImageWithLeftCapWidth:20 topCapHeight:10];
        self.contentTextView.text = content;
        
    }else {
        [self.contentTextView setFrame:CGRectMake(25, 15, size.width + 16, size.height + 16)];
        [self.bubbleImageView setFrame:CGRectMake(5, 5, size.width + 16 + 20, size.height + 16 + 20)];
        self.bubbleImageView.image = [[UIImage imageNamed:@"bubble"] stretchableImageWithLeftCapWidth:20 topCapHeight:10];
        self.contentTextView.text = content;
    }
}

#pragma mark -
#pragma mark Getters
- (UIImageView *)bubbleImageView
{
    if (!_bubbleImageView) {
        _bubbleImageView = [[UIImageView alloc] init];
    }
    return _bubbleImageView;
}

- (UITextView *)contentTextView
{
    if (!_contentTextView) {
        _contentTextView = [[UITextView alloc] init];
        _contentTextView.font = [UIFont systemFontOfSize:14];
        _contentTextView.editable = NO;
        _contentTextView.backgroundColor = [UIColor clearColor];
        _contentTextView.scrollEnabled = NO;
    }
    return _contentTextView;
}

@end
