//
//  MessageTableViewController.m
//  Wisen
//
//  Created by Yihe Li on 2/28/15.
//  Copyright (c) 2015 self. All rights reserved.
//

#import "MessageTableViewController.h"
#import <Sinch/Sinch.h>
#import "MessageTableViewCell.h"

NSString const *Cell = @"IncomingMessageCell";

@interface MessageTableViewController()

@property (nonatomic, weak) id<SINClient> userClient;
@property (nonatomic, weak) NSArray *messages;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (nonatomic, strong) NSString *profileImageURL;

@end

@implementation MessageTableViewController

- (NSArray *)messages
{
    return [MessageManager sharedManager].allMessages[[MessageManager getSinchIDFromUID:self.recipientUID]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.userClient = [MessageManager sharedManager].client;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self registerForKeyboardNotifications];
    __weak MessageTableViewController *weakSelf = self;
    [MessageManager sharedManager].reloadUI = ^ {
        MessageTableViewController *innerSelf = weakSelf;
        [innerSelf.tableView reloadData];
        [innerSelf scrollToBottom];
    };
    UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(confirmTouched)];
    self.navigationItem.rightBarButtonItem = right;
    
    [[UserManager sharedManager] getBasicInfoForUserWithUID: self.recipientUID  block:^(NSDictionary *userInfo) {
        NSLog(@"User info: %@", userInfo);
        NSString *displayName = userInfo[@"displayName"];
        self.profileImageURL = userInfo[@"profileImageURL"];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
        label.text = displayName;
        label.font = [UIFont fontWithName:@"GillSans" size:24];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        self.navigationItem.titleView = label;
        [self.view setNeedsDisplay];
    }];
    self.tableView.estimatedRowHeight = 90;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardChange:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardChange:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)handleKeyboardChange:(NSNotification *)note
{
    NSTimeInterval duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGRect frame = [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationOptions options = curve << 16;
    if ([note.name isEqualToString:UIKeyboardWillShowNotification]) {
        self.bottomConstraint.constant  =  CGRectGetHeight(frame);
    } else {
        self.bottomConstraint.constant =  0 ;
    }
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *entry = [self.messages objectAtIndex:[indexPath row]];
    
    id<SINMessage> message = entry[0];
    MessageTableViewCell *cell = [self dequeOrLoadMessageTableViewCell:[entry[1] intValue]];
    
    cell.message.text = message.text;
    cell.nameLabel.text = message.senderId;
    return cell;
}

- (MessageTableViewCell *)dequeOrLoadMessageTableViewCell:(MessageDirection)direction {
    
    NSString *identifier =
    [NSString stringWithFormat:@"%@MessageCell", (Incoming == direction) ? @"Incoming" : @"Outgoing"];
    
    
    MessageTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil] firstObject];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        [cell.avatarImageView fetchImage:(Outgoing == direction) ? [UserManager sharedManager].user.profileImageURL : self.profileImageURL];
    }
    return cell;
}

- (void)scrollToBottom {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.messages.count - 1)inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (IBAction)sendTouched:(UIButton *)sender {
    if (self.textField.text.length != 0)
        [[MessageManager sharedManager] sendMessage:self.textField.text to:self.recipientUID];
    self.textField.text = @"";
}

- (void)confirmTouched {
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"ConfirmationScene"] animated:YES];
}

#pragma mark - Calculate Height

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return [self heightForBasicCellAtIndexPath:indexPath];
    return 90;
}
//
//- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
//    static MessageTableViewCell *sizingCell = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:Cell];
//    });
//    
//    return [self calculateHeightForConfiguredSizingCell:sizingCell];
//}
//
//- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
//    [sizingCell setNeedsLayout];
//    [sizingCell layoutIfNeeded];
//    
//    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
//    return size.height + 1.0f; // Add 1.0f for the cell separator height
//}

@end
