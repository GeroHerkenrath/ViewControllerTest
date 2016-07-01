

#import <UIKit/UIKit.h>
#import "BarcodeScanViewController.h"

@class CustomView;

@protocol CustomViewDelegate
@required
-(void)didCloseWindow:(NSString*)barcode;
@end


@interface CustomView : UIView <BarcodeScanViewControllerDelegate>

// here I added the protocol, so assignments are checked.
@property (nonatomic, weak) id<CustomViewDelegate>  delegate;
@end
