//
//  MessageTableViewController.m
//  Wisen
//
//  Created by Yihe Li on 2/28/15.
//  Copyright (c) 2015 self. All rights reserved.
//

#import <Sinch/Sinch.h>
#import "MessageTableViewController.h"
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
@property (nonatomic, strong) MessagePipe *pipe;

@end

@implementation MessageTableViewController

- (NSArray *)messages
{
    return [MessageManager sharedManager].allMessages[[MessageManager getSinchIDFromUID:self.recipientUID]];
}

- (MessagePipe *)pipe
{
    if (!_pipe) {
        _pipe = [[MessagePipe alloc] initWithSelfUID:[UserManager sharedManager].user.uid otherUID:self.recipientUID];
    }
    return _pipe;
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
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(confirmTouchedByHand)];
    self.navigationItem.rightBarButtonItem = right;
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTouched)];
    self.navigationItem.leftBarButtonItem = left;
    
    [[UserManager sharedManager] getBasicInfoForUserWithUID: self.recipientUID  block:^(NSDictionary *userInfo) {
        NSString *displayName = userInfo[@"displayName"];
        self.profileImageURL = userInfo[@"profileImageURL"];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
        label.text = displayName;
        label.font = [UIFont fontWithName:@"Futura-Medium" size:24];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        self.navigationItem.titleView = label;
        [self.view setNeedsDisplay];
    }];
    self.tableView.estimatedRowHeight = 90;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestCanceled:) name:@"kRequestCanceledNotification" object:nil];
    
    [self.pipe observeWithBlock:^(NSDictionary *msg) {
        if ([msg[@"done"] boolValue]) {
            [self confirmTouched];
        }
    }];
}

- (void)cancelTouched {
    NSString *text = [NSString stringWithFormat:@"You will probably never meet %@ again...", ((UILabel *)self.navigationItem.titleView).text];
    AMSmoothAlertView *alert = [[AMSmoothAlertView alloc] initDropAlertWithTitle:@"Alas!" andText:text andCancelButton:YES forAlertType:AlertInfo withCompletionHandler:^(AMSmoothAlertView *alertView, UIButton *button) {
        if (button == alertView.defaultButton) {
            User *user = [UserManager sharedManager].user;
            [user removeObserverWithRequestID:user.currentRequest.requestID];
            [user updateStatus:RequestStatusCanceled forRequestWithID:user.currentRequest.requestID];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
    [alert show];
}

- (void)requestCanceled:(NSNotification *)note {
    NSLog(@"Canceled");
    NSString *text = [NSString stringWithFormat:@"It seems %@ has quited the conversation...", ((UILabel *)self.navigationItem.titleView).text];
    AMSmoothAlertView *alert = [[AMSmoothAlertView alloc] initDropAlertWithTitle:@"Alas!" andText:text andCancelButton:NO forAlertType:AlertFailure withCompletionHandler:^(AMSmoothAlertView *alertView, UIButton *button) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    [alert show];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[MessageManager sharedManager] reset];
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
        self.bottomConstraint.constant = CGRectGetHeight(frame);
    } else {
        self.bottomConstraint.constant = 0 ;
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
    
    NSString *identifier = [NSString stringWithFormat:@"%@MessageCell", Incoming == direction ? @"Incoming" : @"Outgoing"];
    
    
    MessageTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil] firstObject];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        [cell.avatarImageView fetchImage:Outgoing == direction ? [UserManager sharedManager].user.profileImageURL : self.profileImageURL];
    }
    return cell;
}

- (void)scrollToBottom {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.messages.count - 1)inSection:0];
    if (indexPath.row >= [self.tableView numberOfRowsInSection:0]) {
        return;
    }
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (IBAction)sendTouched:(UIButton *)sender {
    if (self.textField.text.length != 0)
        [[MessageManager sharedManager] sendMessage:self.textField.text to:self.recipientUID];
    self.textField.text = @"";
}

- (void)confirmTouchedByHand {
    [self.pipe send:@{@"done": @1}];
    [self confirmTouched];
}

- (void)confirmTouched {
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"ConfirmationScene"] animated:YES];
}

#pragma mark - Calculate Height

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return [self heightForBasicCellAtIndexPath:indexPath];
    return 90;
}

- (void)dealloc {
    NSLog(@"Dealloc called");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Scroll View Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.textField resignFirstResponder];
}

@end
