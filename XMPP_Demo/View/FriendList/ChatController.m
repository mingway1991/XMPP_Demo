//
//  ChatController.m
//  XMPP_Demo
//
//  Created by 石茗伟 on 16/2/26.
//  Copyright © 2016年 mingway. All rights reserved.
//

#import "ChatController.h"
#import "ChatBottomView.h"

@interface ChatController () <ChatBottomViewDelegate>
{
    CGFloat _bottomViewOriginY;
}
@property (nonatomic, strong) ChatBottomView *bottomView;
@property (nonatomic, strong) UIView *resignFirstResponderView;

@end

@implementation ChatController

#pragma mark -
#pragma mark life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    _bottomViewOriginY = -100;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (_bottomViewOriginY < 0) {
        _bottomViewOriginY = CGRectGetHeight(self.view.bounds) - 50;
        [self bottomView];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark -
#pragma mark Keyboard
- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    self.resignFirstResponderView.hidden = NO;
    CGRect rect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval dur;
    [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&dur];
    
    [self.resignFirstResponderView setFrame:CGRectMake(0, 0, self.bottomView.frame.size.width, _bottomViewOriginY - rect.size.height)];
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:dur animations:^{
        [weakSelf.bottomView setFrame:CGRectMake(0, _bottomViewOriginY - rect.size.height, weakSelf.bottomView.frame.size.width, weakSelf.bottomView.frame.size.height)];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.resignFirstResponderView.hidden = YES;
    
    NSTimeInterval dur;
    [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&dur];
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:dur animations:^{
        [weakSelf.bottomView setFrame:CGRectMake(0, _bottomViewOriginY, weakSelf.bottomView.frame.size.width, weakSelf.bottomView.frame.size.height)];
    }];
}

#pragma mark -
#pragma mark Getters
- (ChatBottomView *)bottomView
{
    if (!_bottomView) {
        
        _bottomView = [[[NSBundle mainBundle] loadNibNamed:@"ChatBottomView" owner:nil options:nil] firstObject];
        _bottomView.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - 50, CGRectGetWidth(self.view.bounds), 50);
        _bottomView.delegate = self;
        [self.view addSubview:_bottomView];
    }
    return _bottomView;
}

- (UIView *)resignFirstResponderView
{
    if (!_resignFirstResponderView) {
        
        _resignFirstResponderView = [[UIView alloc] init];
        _resignFirstResponderView.userInteractionEnabled = YES;
        _resignFirstResponderView.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.bottomView action:@selector(resignFirstResponder)];
        [_resignFirstResponderView addGestureRecognizer:tap];
        
        [self.view addSubview:_resignFirstResponderView];
    }
    return _resignFirstResponderView;
}

#pragma mark -
#pragma mark Private Methoeds

#pragma mark -
#pragma mark ChatBottomViewDelegate
- (void)didClickSendButtonWithMessage:(NSString *)message
{
    _bottomViewOriginY = self.view.bounds.size.height - 50;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.bottomView.frame = CGRectMake(0, _bottomViewOriginY, weakSelf.view.bounds.size.width, 50);
    }];
    NSLog(@"发送文本：%@", message);
}

- (void)bottomViewChangedHeight:(CGFloat)height
{
    CGFloat finalHeight = height + 16;
    if (finalHeight < 50) {
        finalHeight = 50;
    }else if (finalHeight > 120) {
        finalHeight = 120;
    }
    _bottomViewOriginY = self.view.bounds.size.height - finalHeight;
    CGFloat originalHeight = self.bottomView.frame.size.height;
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.1 animations:^{
        [weakSelf.bottomView setFrame:CGRectMake(0, weakSelf.bottomView.frame.origin.y + originalHeight - finalHeight, weakSelf.view.bounds.size.width, finalHeight)];
    }];
}

@end
