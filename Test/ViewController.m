
#import "ViewController.h"
#import "CustomView.h"

@interface ViewController () <CustomViewDelegate> {
    CustomView * cv;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor greenColor];
    
    cv = [[CustomView alloc] initWithFrame:self.view.frame];
    cv.delegate = self;
    [self.view addSubview:cv];
    
}

-(void)didCloseWindow:(NSString*)barcode {
    NSLog(@"DidCloseWindow(): %@", barcode);
    [cv removeFromSuperview];
    cv = nil;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
