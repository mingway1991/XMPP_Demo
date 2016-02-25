//
//  XMPPManager.m
//  XMPP_Demo
//
//  Created by 石茗伟 on 16/2/25.
//  Copyright © 2016年 mingway. All rights reserved.
//

#import "XMPPManager.h"
#import <XMPPFramework.h>
#import <XMPPReconnect.h>

#define kDOMAIN_NAME        @"mingway.local"
#define kRESOURCE           @"iPhone"
#define kHOST_NAME          @"127.0.0.1"

@interface XMPPManager ()<XMPPStreamDelegate>

@property (nonatomic, strong) XMPPStream *stream;
@property (nonatomic, strong) XMPPReconnect *reconnect;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, assign) BOOL isOnline;

@end

@implementation XMPPManager

#pragma mark -
#pragma mark Init
+ (instancetype)shared
{
    static XMPPManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self.stream setHostName:kHOST_NAME];
        [self.stream setHostPort:5222];
        self.isOnline = NO;
        self.reconnect = [[XMPPReconnect alloc] init];
        [self.reconnect setAutoReconnect:YES];
    }
    return self;
}

#pragma mark -
#pragma mark Getters
- (XMPPStream *)stream
{
    if (_stream == nil) {
        _stream = [[XMPPStream alloc] init];
        [_stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _stream;
}

#pragma mark-
#pragma mark Public Methods
- (BOOL)connectWithUserName:(NSString *)username
                   password:(NSString *)password
{
    if (username != nil) {
        
        self.username = username;
        self.password = password;
        
        if ([self.stream isConnected]) {
            
            if(!self.isOnline){
                
                NSError *error = nil;
                self.password = password;
                [self.stream setMyJID:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@/%@", username, kDOMAIN_NAME, kRESOURCE]]];
                if (![self.stream authenticateWithPassword:password error:&error]){
                    NSLog(@"无法验证: %@", error);
                }
            }
            return YES;
        }
        
        if (username != nil) {
            [self.stream setMyJID:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@/%@", username, kDOMAIN_NAME, kRESOURCE]]];
            NSError *error = nil;
            [self.stream connectWithTimeout:10 error:&error];
            
            if(error){
                NSLog(@"连接失败：%@",error.localizedDescription);
            }
            
            return YES;
        }else {
            return NO;
        }
    }
    
    return NO;
}

- (void)goOnline
{
    self.isOnline = YES;
    XMPPPresence *p = [XMPPPresence presence];
    [self.stream sendElement:p];
}

- (void)goOffline
{
    self.isOnline = NO;
    XMPPPresence *p = [XMPPPresence presenceWithType:@"unavailable"];
    [self.stream sendElement:p];
}

#pragma mark -
#pragma mark XMPPStreamDelegate
- (void)xmppStreamWillConnect:(XMPPStream *)sender
{
    NSLog(@"将要连接");
}

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    NSLog(@"socket 连接成功");
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"已经连接");
    NSError *error = nil;
    if (![self.stream authenticateWithPassword:self.password error:&error])
    {
        NSLog(@"无法验证: %@", error);
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"验证登录成功");
    [self goOnline];
    ///获取好友列表
    
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    NSLog(@"验证登录失败 错误：%@",[error description]);
    [sender disconnect];
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    if (error) {
        NSLog(@"断开连接 错误：%@", error.localizedDescription);
    }else {
        NSLog(@"断开连接");
    }
    [self goOffline];
}

- (void)xmppStreamWasToldToDisconnect:(XMPPStream *)sender
{
    
}

- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender
{
    NSLog(@"连接超时");
}

@end
