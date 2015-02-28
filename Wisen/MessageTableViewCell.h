//
//  MessageTableViewCell.h
//  
//
//  Created by Yihe Li on 2/28/15.
//
//

#import <UIKit/UIKit.h>

@interface MessageTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *message;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
