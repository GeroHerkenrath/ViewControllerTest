#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class BarcodeScanViewController;

@protocol BarcodeScanViewControllerDelegate <NSObject>
@required
- (void) passedBarcode : (NSString*) barcode Type:(NSString*)type;
@end


@interface BarcodeScanViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>
@property (weak, nonatomic) id <BarcodeScanViewControllerDelegate> delegate;

@end
