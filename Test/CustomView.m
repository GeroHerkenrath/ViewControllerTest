
#import "CustomView.h"

@implementation CustomView {
    UILabel * lblBarcode;
    NSString * thisBarcode;
}

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor yellowColor];
        
        lblBarcode = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height/2,frame.size.width, 35)];
        lblBarcode.text = @"Not scanned";
        lblBarcode.font = [UIFont systemFontOfSize:16];
        lblBarcode.textColor = [UIColor blackColor];
        lblBarcode.textAlignment = NSTextAlignmentCenter;
        [lblBarcode setBackgroundColor:[UIColor greenColor]];
        
        [self addSubview:lblBarcode];
        
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
            [self.delegate didCloseWindow:thisBarcode];
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
    UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

#pragma mark - Get Barcode Deletgate
- (void) passedBarcode:(NSString *)barcode Type:(NSString*)type {
    
    NSLog(@"Passed Bardcode: %@ of Type: %@", barcode, type);
    
    thisBarcode = barcode;
    lblBarcode.text = thisBarcode;
    
    
}



@end
