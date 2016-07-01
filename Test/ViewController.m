
#import "ViewController.h"
#import "CustomView.h"

// you forgot to adopt your own protocol
@interface ViewController () <CustomViewDelegate>

// I'd advise to use properties over instance variables directly.
@property (nonatomic, strong) CustomView * cv;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor greenColor];
    
    self.cv = [[CustomView alloc] initWithFrame:self.view.frame];
    self.cv.delegate = self;
    [self.view addSubview:self.cv];
    
}

- (BOOL)definesPresentationContext {
	// this makes the view of this VC appear under the presented view during the transition
	return YES;
}

-(void)didCloseWindow:(NSString*)barcode {
    NSLog(@"DidCloseWindow(): %@", barcode);
    [self.cv removeFromSuperview];
    self.cv = nil;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
