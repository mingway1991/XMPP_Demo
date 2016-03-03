//
//  FriendListController.m
//  XMPP_Demo
//
//  Created by 石茗伟 on 16/2/26.
//  Copyright © 2016年 mingway. All rights reserved.
//

#import "FriendListController.h"
#import "FriendListViewModel.h"
#import <ReactiveCocoa.h>
#import <XMPPFramework.h>
#import "ChatController.h"

@interface FriendListController () <UITableViewDataSource, UITableViewDelegate>
{
    NSInteger _selectedIndex;
}
@property (nonatomic, strong) FriendListViewModel *viewModel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FriendListController

#pragma mark -
#pragma mark life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addNavigationBarButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.viewModel refreshFriendList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Getters
- (FriendListViewModel *)viewModel
{
    if (_viewModel == nil) {
        @weakify(self);
        _viewModel = [[FriendListViewModel alloc] init];
        [_viewModel setGetFriendListBlock:^{
            @strongify(self);
            [self updateUI];
        }];
    }
    return _viewModel;
}

#pragma mark -
#pragma mark Private Methods
- (void)updateUI
{
    NSLog(@"刷新好友列表显示");
    [self.tableView reloadData];
}

- (void)addNavigationBarButton
{
    UIBarButtonItem *addFriendBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(toAddFriend)];
    self.navigationItem.rightBarButtonItem = addFriendBarButton;
}

- (void)toAddFriend
{
    [self performSegueWithIdentifier:@"toAddFriendSegue" sender:nil];
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _viewModel.friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    XMPPJID *jid = self.viewModel.friends[indexPath.row];
    cell.textLabel.text = jid.user;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedIndex = indexPath.row;
    [self performSegueWithIdentifier:@"toChatSegue" sender:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toChatSegue"]) {
        ChatController *destinationController = segue.destinationViewController;
        destinationController.others = self.viewModel.friends[_selectedIndex];
    }
}

@end
