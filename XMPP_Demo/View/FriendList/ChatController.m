//
//  ChatController.m
//  XMPP_Demo
//
//  Created by 石茗伟 on 16/2/26.
//  Copyright © 2016年 mingway. All rights reserved.
//

#import "ChatController.h"
#import "ChatBottomView.h"
#import "ChatTextMessage.h"
#import "ChatCell/ChatTextCell.h"
#import <XMPPFramework.h>
#import "XMPPManager.h"

@interface ChatController () <ChatBottomViewDelegate, UITableViewDataSource, UITableViewDelegate, XMPPManagerDelegate>
{
    CGFloat _bottomViewOriginY;
    NSArray *_messages;
}
@property (nonatomic, strong) UITableView *chatBubbleTableView;
@property (nonatomic, strong) ChatBottomView *bottomView;
@property (nonatomic, strong) NSNumber *tableViewHeight;

@end

@implementation ChatController

#pragma mark -
#pragma mark life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = self.others.user;
    _messages = @[];
    _bottomViewOriginY = -100;
    [[XMPPManager shared] setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [[XMPPManager shared] setDelegate:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (_bottomViewOriginY < 0) {
        _bottomViewOriginY = CGRectGetHeight(self.view.bounds) - 50;
        self.tableViewHeight = @(_bottomViewOriginY);
        [self chatBubbleTableView];
        [self bottomView];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self addObserver:self forKeyPath:@"tableViewHeight" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self removeObserver:self forKeyPath:@"tableViewHeight"];
}

#pragma mark -
#pragma mark Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"tableViewHeight"]) {
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.2 animations:^{
            [weakSelf.chatBubbleTableView setFrame:CGRectMake(0, 0, weakSelf.view.bounds.size.width, [self.tableViewHeight floatValue])];
        }];
    }
}

#pragma mark -
#pragma mark Keyboard
- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    CGRect rect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval dur;
    [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&dur];
    
    self.tableViewHeight = @(_bottomViewOriginY - rect.size.height);
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:dur animations:^{
        [weakSelf.bottomView setFrame:CGRectMake(0, _bottomViewOriginY - rect.size.height, weakSelf.bottomView.frame.size.width, weakSelf.bottomView.frame.size.height)];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSTimeInterval dur;
    [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&dur];
    
    self.tableViewHeight = @(_bottomViewOriginY);
    
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

- (UITableView *)chatBubbleTableView
{
    if (!_chatBubbleTableView) {
        _chatBubbleTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, _bottomViewOriginY) style:UITableViewStylePlain];
        _chatBubbleTableView.delegate = self;
        _chatBubbleTableView.dataSource = self;
        _chatBubbleTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_chatBubbleTableView];
        _chatBubbleTableView.backgroundColor = [UIColor clearColor];
        [self registerNibForTableView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.bottomView action:@selector(resignFirstResponder)];
        [_chatBubbleTableView addGestureRecognizer:tap];
    }
    return _chatBubbleTableView;
}

#pragma mark -
#pragma mark Private Methoeds
- (void)registerNibForTableView
{
    [self.chatBubbleTableView registerNib:[UINib nibWithNibName:@"ChatTextCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"textCell"];
}

- (void)scrollToBottomWithAnimation:(BOOL)animation
{
    NSUInteger sectionCount = [self.chatBubbleTableView numberOfSections];
    if (sectionCount) {
        
        NSUInteger rowCount = [self.chatBubbleTableView numberOfRowsInSection:0];
        if (rowCount) {
            
            NSUInteger ii[2] = {0, rowCount - 1};
            NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:ii length:2];
            [self.chatBubbleTableView scrollToRowAtIndexPath:indexPath
                        atScrollPosition:UITableViewScrollPositionBottom animated:animation];
        }
    }
}

- (void)resetHeightForBottomView
{
    CGFloat originalHeight = self.bottomView.frame.size.height;
    CGRect newFrame = CGRectMake(0, self.bottomView.frame.origin.y + originalHeight - 50, self.bottomView.frame.size.width, 50);
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.bottomView.frame = newFrame;
    }];
}

- (void)sendMessage:(NSString *)messageStr
{
    NSLog(@"发送文本：%@", messageStr);
    [[XMPPManager shared] sendToUser:self.others.user textMessage:messageStr];
    
    ChatTextMessage *newMessage = [[ChatTextMessage alloc] init];
    newMessage.otherUser = self.others.user;
    newMessage.content = messageStr;
    newMessage.isSender = YES;
    
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:_messages];
    [newArray addObject:newMessage];
    _messages = newArray;
    
    [self.chatBubbleTableView reloadData];
    [self scrollToBottomWithAnimation:YES];
}

#pragma mark -
#pragma mark ChatBottomViewDelegate
- (void)didClickSendButtonWithMessage:(NSString *)message
{
    [self sendMessage:message];
    [self resetHeightForBottomView];
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
    self.tableViewHeight = @(self.bottomView.frame.origin.y + originalHeight - finalHeight);
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.1 animations:^{
        [weakSelf.bottomView setFrame:CGRectMake(0, weakSelf.bottomView.frame.origin.y + originalHeight - finalHeight, weakSelf.view.bounds.size.width, finalHeight)];
    }];
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *message = _messages[indexPath.row];
    if ([message isKindOfClass:[ChatTextMessage class]]) {
        
        ChatTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textCell"];
        
        ChatTextMessage *textMessage = (ChatTextMessage *)message;
        [cell configWithModel:textMessage];
        
        return cell;
    }
    
    return [[UITableViewCell alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *message = _messages[indexPath.row];
    if ([message isKindOfClass:[ChatTextMessage class]]) {
        
        CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        CGFloat textViewMaxWidth = screenWidth - 50 - 16 - 50;
        ChatTextMessage *textMessage = (ChatTextMessage *)message;
        CGFloat height = [textMessage.content boundingRectWithSize:CGSizeMake(textViewMaxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]} context:nil].size.height + 16;
        return height + 30;
    }
    
    return 0;
}

#pragma mark -
#pragma mark XMPPManagerDelegate
- (void)didReceiveMessage:(NSString *)message fromUser:(NSString *)fromUser
{
    if ([fromUser isEqualToString:self.others.user]) {
        
        ChatTextMessage *newMessage = [[ChatTextMessage alloc] init];
        newMessage.otherUser = fromUser;
        newMessage.content = message;
        newMessage.isSender = NO;
        
        NSMutableArray *newArray = [NSMutableArray arrayWithArray:_messages];
        [newArray addObject:newMessage];
        _messages = newArray;
        
        [self.chatBubbleTableView reloadData];
        [self scrollToBottomWithAnimation:YES];
    }
}

@end
