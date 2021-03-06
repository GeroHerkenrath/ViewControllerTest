
#import "CustomView.h"

@interface CustomView ()

@property (nonatomic, strong) UILabel * lblBarcode;
@property (nonatomic, strong) NSString * thisBarcode;

@end

@implementation CustomView

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor yellowColor];
        
        self.lblBarcode = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height/2,frame.size.width, 35)];
        self.lblBarcode.text = @"Not scanned";
        self.lblBarcode.font = [UIFont systemFontOfSize:16];
        self.lblBarcode.textColor = [UIColor blackColor];
        self.lblBarcode.textAlignment = NSTextAlignmentCenter;
        [self.lblBarcode setBackgroundColor:[UIColor greenColor]];
        
        [self addSubview:self.lblBarcode];
        
        UIButton * btnScan = [[UIButton alloc] initWithFrame:CGRectMake(0, frame.size.height/2 + 35 ,frame.size.width, 35)];
        [btnScan setTitle:@"SCAN" forState:UIControlStateNormal];
        [btnScan.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
        [btnScan setBackgroundColor:[UIColor blueColor]];
        [btnScan setTag:1];
        [btnScan addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnScan];

        
        UIButton * btnDone = [[UIButton alloc] initWithFrame:CGRectMake(0, frame.size.height/2 + 70,frame.size.width, 35)];
        [btnDone setTitle:@"DONE" forState:UIControlStateNormal];
        [btnDone.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
        [btnDone setBackgroundColor:[UIColor blueColor]];
        [btnDone setTag:2];
        [btnDone addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnDone];
        
    }
    return self;
}

-(void) buttonPressed:(id)sender {
    UIButton *btn = (UIButton*)sender;
    
    switch (btn.tag) {
        case 2:
            [self.delegate didCloseWindow:self.thisBarcode];
            break;
        case 1:
            [self startScan];
            break;
        default:
            break;
    }
    
}

- (void) startScan {
    
    BarcodeScanViewController * bsvc = [[BarcodeScanViewController alloc] init];
    bsvc.delegate = self;
    
    UIViewController *currentTopVC = [self currentTopViewController];
	
    [currentTopVC presentViewController:bsvc animated:YES completion:nil];
    
}
- (UIViewController *)currentTopViewController {
    UIViewController *topVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
	
	// ouch... don't do that, use the keyWindow's rootVC instead or set the VC via a property...
	// there's a bunch of things that can go wrong when you just "iterate" over viewcontrollers.
	// "presentedViewController" isn't the correct property anyways (it would be presentingViewController)
//    while (topVC.presentedViewController) {
//        topVC = topVC.presentedViewController;
//    }
    return topVC;
}

#pragma mark - Get Barcode Deletgate
- (void) passedBarcode:(NSString *)barcode Type:(NSString*)type {
    
    NSLog(@"Passed Bardcode: %@ of Type: %@", barcode, type);
    
    self.thisBarcode = barcode;
    self.lblBarcode.text = self.thisBarcode;
    
    
}



@end
