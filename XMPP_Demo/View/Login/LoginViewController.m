//
//  LoginViewController.m
//  XMPP_Demo
//
//  Created by 石茗伟 on 16/2/25.
//  Copyright © 2016年 mingway. All rights reserved.
//

#import "LoginViewController.h"
#import <ReactiveCocoa.h>
#import <XMPPFramework.h>
#import "LoginViewModel.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (nonatomic, strong) LoginViewModel *viewModel;

@end

@implementation LoginViewController

#pragma mark -
#pragma mark life cycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self viewModel];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    @weakify(self);
    [self.usernameTextField.rac_textSignal subscribeNext:^(NSString *text) {
        NSLog(@"username：%@",text);
    }];
    [self.passwordTextField.rac_textSignal subscribeNext:^(NSString *text) {
        NSLog(@"password：%@",text);
    }];
    
    [[self.loginButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        NSLog(@"点击登录按钮");
        [self.viewModel connetXMPPServerWithUserName:self.usernameTextField.text password:self.passwordTextField.text];
    }];
    
    RACSignal *validUsernameSignal =
    [self.usernameTextField.rac_textSignal
     map:^id(NSString *text) {
         @strongify(self);
         return @([self isValidUsername:text]);
     }];
    RACSignal *validPasswordSignal =
    [self.passwordTextField.rac_textSignal
     map:^id(NSString *text) {
         @strongify(self);
         return @([self isValidPassword:text]);
     }];
    
    RACSignal *signUpActiveSignal =
    [RACSignal combineLatest:@[validUsernameSignal, validPasswordSignal]
                      reduce:^id(NSNumber*usernameValid, NSNumber *passwordValid){
                          return @([usernameValid boolValue]&&[passwordValid boolValue]);
                      }];
    [signUpActiveSignal subscribeNext:^(NSNumber*signupActive){
        @strongify(self);
        self.loginButton.enabled =[signupActive boolValue];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Getters
- (LoginViewModel *)viewModel
{
    if (_viewModel == nil) {
        @weakify(self);
        _viewModel = [[LoginViewModel alloc] init];
        [_viewModel setLoginSuccess:^{
            @strongify(self);
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    return _viewModel;
}

#pragma mark -
#pragma mark Private Methods
- (BOOL)isValidUsername:(NSString *)text
{
    if (![text isEqualToString:@""]) {
        return YES;
    }
    return NO;
}

- (BOOL)isValidPassword:(NSString *)text
{
    if (![text isEqualToString:@""]) {
        return YES;
    }
    return NO;
}

@end
