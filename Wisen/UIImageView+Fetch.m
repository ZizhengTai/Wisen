//
//  UIImageView+Fetch.m
//  
//
//  Created by Yihe Li on 2/27/15.
//
//

#import "UIImageView+Fetch.h"


@implementation UIImageView (Fetch)

- (void)fetchImage:(NSString *)URLString
{
    [self fetchImage:URLString placeholder:nil completion:nil];
}

- (void)fetchImage:(NSString *)URLString completion:(void (^)())block
{
    [self fetchImage:URLString placeholder:nil completion:block];
}

- (void)fetchImage:(NSString *)URLString placeholder:(NSString *)placeholderName completion:(void (^)())block
{
    self.contentMode = UIViewContentModeScaleAspectFill;
    [self sd_setImageWithURL:[NSURL URLWithString:URLString]
            placeholderImage:(placeholderName ? [UIImage imageNamed:placeholderName] : nil)
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                       if (block) {
                           block();
                       }
                       if (cacheType != SDImageCacheTypeMemory) {
                           self.alpha = 0;
                           [UIView animateWithDuration:0.25 animations:^{
                               self.alpha = 1;
                           }];
                       }
                   }];
}

@end
