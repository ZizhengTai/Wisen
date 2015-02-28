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

@interface MessageTableViewController()

@property (nonatomic, weak) id<SINClient> userClient;
@property (nonatomic, weak) NSArray *messages;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@end

@implementation MessageTableViewController

- (NSArray *)messages
{
    return [MessageManager sharedManager].allMessages[self.recipientUID];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

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

@end
