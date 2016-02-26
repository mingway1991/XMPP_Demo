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
#import <XMPPRoster.h>
#import <XMPPRosterCoreDataStorage.h>

#define kDOMAIN_NAME        @"mingway-mba.local"
#define kRESOURCE           @"iPhone"
#define kHOST_NAME          @"127.0.0.1"

@interface XMPPManager () <XMPPStreamDelegate, XMPPRosterDelegate>

@property (nonatomic, strong) XMPPStream *stream;
@property (nonatomic, strong) XMPPReconnect *reconnect;
@property (nonatomic, strong) XMPPRoster *roster;
@property (nonatomic, strong) XMPPRosterCoreDataStorage *rosterCoreDataStorage;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *generateID;

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
    }
    return self;
}

#pragma mark -
#pragma mark Getters
- (XMPPRosterCoreDataStorage *)rosterCoreDataStorage
{
    if (_rosterCoreDataStorage == nil) {
        _rosterCoreDataStorage = [[XMPPRosterCoreDataStorage alloc] init];
    }
    return _rosterCoreDataStorage;
}

- (XMPPRoster *)roster
{
    if (_roster == nil) {
        _roster = [[XMPPRoster alloc] initWithRosterStorage:self.rosterCoreDataStorage];
        [_roster addDelegate:self delegateQueue:dispatch_get_main_queue()];
        _roster.autoFetchRoster = YES;
        _roster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    }
    return _roster;
}

- (XMPPStream *)stream
{
    if (_stream == nil) {
        _stream = [[XMPPStream alloc] init];
        [_stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _stream;
}

- (XMPPReconnect *)reconnect
{
    if (_reconnect == nil) {
        _reconnect = [[XMPPReconnect alloc] init];
        [_reconnect setAutoReconnect:YES];
    }
    return _reconnect;
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

- (void)disconnect
{
    if ([self.stream isConnected]) {
        [self.stream disconnect];
    }
}

- (void)getFriendList
{
    NSLog(@"获取好友列表");
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    XMPPJID *myJID = self.stream.myJID;
    [iq addAttributeWithName:@"from" stringValue:myJID.description];
    [iq addAttributeWithName:@"to" stringValue:myJID.domain];
    [iq addAttributeWithName:@"id" stringValue:[self generateID]];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addChild:query];
    [self.stream sendElement:iq];
}

- (void)sendFriendRequestWithUsername:(NSString *)username
{
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@/%@", self.username, kDOMAIN_NAME, kRESOURCE]];
    [self.roster subscribePresenceToUser:jid];
}

- (void)removeFriendWithUsername:(NSString *)username
{
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@/%@", self.username, kDOMAIN_NAME, kRESOURCE]];
    [self.roster removeUser:jid];
}

#pragma mark -
#pragma mark Private Methods
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

- (NSString *)generateID
{
    return [NSString stringWithFormat:@"%@", @((random()/1000 + 1000))];
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
    [self getFriendList];
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

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    NSLog(@"获取到好友列表");
    if ([@"result" isEqualToString:iq.type]) {
        NSXMLElement *query = iq.childElement;
        if ([@"query" isEqualToString:query.name]) {
            NSMutableArray *friends = [NSMutableArray array];
            NSArray *items = [query children];
            for (NSXMLElement *item in items) {
                NSString *jid = [item attributeStringValueForName:@"jid"];
                XMPPJID *xmppJID = [XMPPJID jidWithString:jid];
                [friends addObject:xmppJID];
            }
            self.friendList = friends;
        }
    }
    return YES;
}

- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    NSLog(@"接收到添加好友请求");
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    NSLog(@"收到上线通知");
}

@end
