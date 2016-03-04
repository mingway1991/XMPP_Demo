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
#import <XMPPvCardCoreDataStorage.h>
#import <XMPPCapabilitiesCoreDataStorage.h>
#import <XMPPCapabilities.h>

#define kDOMAIN_NAME        @"mingway-mba.local"
#define kRESOURCE           @"iPhone"
//#define kHOST_NAME          @"127.0.0.1"
#define kHOST_NAME          @"169.254.89.148"

@interface XMPPManager () <XMPPStreamDelegate, XMPPRosterDelegate>

@property (nonatomic, strong) XMPPStream *stream;
@property (nonatomic, strong) XMPPReconnect *reconnect;
@property (nonatomic, strong) XMPPRoster *roster;
@property (nonatomic, strong) XMPPRosterCoreDataStorage *rosterCoreDataStorage;
@property (nonatomic, strong) XMPPvCardCoreDataStorage *vcardCoreDataStorage;
@property (nonatomic, strong) XMPPvCardTempModule *vcardTempModule;
@property (nonatomic, strong) XMPPCapabilitiesCoreDataStorage *capabilitiesCoreDataStorage;
@property (nonatomic, strong) XMPPCapabilities *capabilities;
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
        [self.reconnect activate:self.stream];
        [self.roster activate:self.stream];
        [self.vcardTempModule activate:self.stream];
        [self.capabilities activate:self.stream];
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

- (XMPPvCardCoreDataStorage *)vcardCoreDataStorage
{
    if (_vcardCoreDataStorage == nil) {
        _vcardCoreDataStorage = [XMPPvCardCoreDataStorage sharedInstance];
    }
    return _vcardCoreDataStorage;
}

- (XMPPvCardTempModule *)vcardTempModule
{
    if (_vcardTempModule == nil) {
        _vcardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:self.vcardCoreDataStorage];
    }
    return _vcardTempModule;
}

- (XMPPCapabilitiesCoreDataStorage *)capabilitiesCoreDataStorage
{
    if (_capabilitiesCoreDataStorage == nil) {
        _capabilitiesCoreDataStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    }
    return _capabilitiesCoreDataStorage;
}

- (XMPPCapabilities *)capabilities
{
    if (_capabilities == nil) {
        _capabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:self.capabilitiesCoreDataStorage];
        _capabilities.autoFetchHashedCapabilities = YES;
        _capabilities.autoFetchNonHashedCapabilities = NO;
    }
    return _capabilities;
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
    [self goOffline];
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
    [iq addAttributeWithName:@"to" stringValue:myJID.description];
    [iq addAttributeWithName:@"id" stringValue:[self generateID]];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addChild:query];
    [self.stream sendElement:iq];
//    [self.roster fetchRoster];
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

- (void)sendToUser:(NSString *)user textMessage:(NSString *)messageStr
{
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:messageStr];
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    NSString *to = [NSString stringWithFormat:@"%@@%@", user, kDOMAIN_NAME];
    [message addAttributeWithName:@"to" stringValue:to];
    [message addChild:body];
    [self.stream sendElement:message];
}

#pragma mark -
#pragma mark Private Methods
- (void)goOnline
{
    self.isOnline = YES;
    XMPPPresence *p = [XMPPPresence presenceWithType:@"available"];
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
    if (_generateID == nil) {
        _generateID = [NSString stringWithFormat:@"%@", @((random()/1000 + 1000))];
    }
    return _generateID;
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
    NSLog(@"%@", iq.description);
    if ([iq.type isEqualToString:@"error"]) {
        NSLog(@"获取好友列表出错");
    }else if ([@"result" isEqualToString:iq.type]) {
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
    _generateID = nil;
    return YES;
}

- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    NSLog(@"收到好友请求");
    NSString * presenceType = [presence type];
    NSLog(@"presenceType = %@",presenceType);
    XMPPJID * fromJid = presence.from;
    if ([presenceType isEqualToString:@"subscribe"]) {
        //是订阅请求  直接通过
        [self.roster acceptPresenceSubscriptionRequestFrom:fromJid andAddToRoster:YES];
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    NSLog(@"获取好友状态");
    NSString *presenceType = [presence type];
    NSString *presenceFromUser = [[presence from] user];
    if (![presenceFromUser isEqualToString:[[sender myJID] user]]) {
        if ([presenceType isEqualToString:@"available"]) {
            //
        } else if ([presenceType isEqualToString:@"unavailable"]) {
            //
        }
    }
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error
{
    NSLog(@"发送添加好友请求失败 错误：%@", error.localizedDescription);
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error
{
    NSLog(@"发送消息失败");
}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(DDXMLElement *)item
{
    NSString *subscription = [item attributeStringValueForName:@"subscription"];
    NSLog(@"%@",subscription);
    if ([subscription isEqualToString:@"both"]) {
        NSLog(@"双方成为好友！");
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSString *messageBody = [[message elementForName:@"body"] stringValue];
    NSString *messageActive = [[message elementForName:@"active"] stringValue];
    NSString *messageInactive = [[message elementForName:@"inactive"] stringValue];
    
    if (messageBody != nil) {
        NSString *from = [[message attributeForName:@"from"] stringValue];
        NSString *to = [[message attributeForName:@"to"] stringValue];
        NSString *type = [[message attributeForName:@"type"] stringValue];
        NSLog(@"来新消息了\n from:%@\n to:%@\n type:%@\n body:%@", from, to, type, messageBody);
        NSString *fromUser = [[from componentsSeparatedByString:@"@"] firstObject];
        
        if ([self.delegate respondsToSelector:@selector(didReceiveMessage:fromUser:)]) {
            [self.delegate didReceiveMessage:messageBody fromUser:fromUser];
        }
        
    }else if (messageActive != nil) {
        NSLog(@"正在输入");
    }else if (messageInactive != nil) {
        NSLog(@"结束输入");
    }
}

- (void)xmppStream:(XMPPStream *)sender didSendIQ:(XMPPIQ *)iq
{
    
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    NSLog(@"已经发送消息");
}

- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender
{
    NSLog(@"获取完好友列表");
}

- (void)fetchvCardTempForJID:(XMPPJID *)jid;
{
    NSLog(@"获取某人名片");
}

@end
