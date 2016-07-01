

#import <UIKit/UIKit.h>
#import "BarcodeScanViewController.h"

@class CustomView;

@protocol CustomViewDelegate
@required
-(void)didCloseWindow:(NSString*)barcode;
@end


@interface CustomView : UIView <BarcodeScanViewControllerDelegate>
@property (nonatomic, assign) id  delegate;
@end
