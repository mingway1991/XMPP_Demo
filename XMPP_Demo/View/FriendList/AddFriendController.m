//
//  AddFriendController.m
//  XMPP_Demo
//
//  Created by 石茗伟 on 16/2/26.
//  Copyright © 2016年 mingway. All rights reserved.
//

#import "AddFriendController.h"
#import "AddFriendViewModel.h"
#import <ReactiveCocoa.h>

@interface AddFriendController ()

@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (weak, nonatomic) IBOutlet UIButton *addFriendButton;
@property (nonatomic, strong) AddFriendViewModel *viewModel;

@end

@implementation AddFriendController

#pragma mark -
#pragma mark life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    @weakify(self);
    [self.inputTextField.rac_textSignal subscribeNext:^(NSString *text) {
        NSLog(@"username：%@",text);
    }];
    
    [[self.addFriendButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        NSLog(@"点击添加按钮");
        [self.viewModel addFriendWithUsername:self.inputTextField.text];
    }];
    
    RACSignal *validUsernameSignal =
    [self.inputTextField.rac_textSignal
     map:^id(NSString *text) {
         @strongify(self);
         return @([self isValidUsername:text]);
     }];
    
    RACSignal *addFriendActiveSignal =
    [RACSignal combineLatest:@[validUsernameSignal]
                      reduce:^id(NSNumber*usernameValid){
                          return @([usernameValid boolValue]);
                      }];
    [addFriendActiveSignal subscribeNext:^(NSNumber *addfriendActive){
        @strongify(self);
        self.addFriendButton.enabled =[addfriendActive boolValue];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Getters
- (AddFriendViewModel *)viewModel
{
    if (_viewModel == nil) {
        _viewModel = [[AddFriendViewModel alloc] init];
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

@end
