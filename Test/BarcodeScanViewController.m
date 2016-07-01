
#import "BarcodeScanViewController.h"

@interface BarcodeScanViewController ()
@property (strong, nonatomic) UIView *previewView;
@property (strong, nonatomic) UIButton *btnCancel;
//@property (weak, nonatomic) UIButton *btnFlashlight;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property (nonatomic) BOOL isReading, torchIsOn;
@property (nonatomic) NSString * scannedBarcode;
- (IBAction)buttonPressed:(id)sender; // doesn't need to be an action if not used from a xib, but it works for now

@end

@implementation BarcodeScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Scan";
    _torchIsOn = false;
    
    _captureSession = nil;
    _isReading = NO;
	
	// this makes the bsvc's view not cover the entire screen.
	// note that "behind" the view is nothing once it is fully presented. view's don't really "stack"
	// There are other ways to achieve a popover effect which require work. there's also a hack I can show you
	// creating an image of the "previous" view and display that behind your view. looks exactly like
	// a popover then, though you gotta be careful with transition animations.
	CGRect myFrame = self.view.frame;
	myFrame.size.height /= 2.0;
	myFrame.origin.y += myFrame.size.height / 2.0;
	self.view.frame = myFrame;

	// the bsvc actually expects you to set these via outlets. since you programmatically instantiate it
	// I changed them from outlets to properties and created them here
	self.previewView = [[UIView alloc] initWithFrame:self.view.frame];
	[self.view addSubview:self.previewView];
	self.btnCancel = [[UIButton alloc] initWithFrame:self.view.frame]; // too large, but just an example
	[self.btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
	[self.btnCancel setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
	[self.btnCancel addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:self.btnCancel];
}

// do this here. I left out the flashlight button since it isn't set up anyways.
-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self startReading];
}

// don't do that here everytime...
//- (void) viewDidLayoutSubviews {
//    [self startReading];
//    
//    _btnFlashlight = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    _btnFlashlight.tag = 1;
//    [_btnFlashlight setTitle:@"Flashlight" forState:UIControlStateNormal];
//    _btnFlashlight.frame = CGRectMake(25, 60, 95, 30);
//    [_btnFlashlight respondsToSelector:@selector(buttonPressed:)];
//    [self.view addSubview:_btnFlashlight];
//    
//    
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// better here
-(void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
//    _isReading = NO;
//    _torchIsOn = false;
//    [self turnTorchOn:_torchIsOn];
    [self stopReading];
}




#pragma mark Flashlight
- (void) turnTorchOn: (bool) on {
    // check if flashlight available
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                //torchIsOn = YES; //define as a variable/property if you need to know status
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                //torchIsOn = NO;
            }
            [device unlockForConfiguration];
        }
    }
}



#pragma mark - IBAction method implementation

- (void)startStopReading:(id)sender {
    
    if (!_isReading) {
        // This is the case where the app should read a QR code when the start button is tapped.
        [self startReading];
    }
    else{
        // In this case the app is currently reading a QR code and it should stop doing so.
        [self stopReading];
    }
    
    // Set to the flag the exact opposite value of the one that currently has.
    _isReading = !_isReading;
}

#pragma mark - DELEGATE METHOD

- (void) returnToDetails : (NSString*) barcode Type:(NSString*)type{
    NSLog(@"Return to Delegate");
    [self.delegate passedBarcode:barcode Type:type];
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - Private method implementation

- (BOOL)startReading {
    NSError *error;
    
    // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
    // as the media type parameter.
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Get an instance of the AVCaptureDeviceInput class using the previous device object.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        // If any error occurs, simply log the description of it and don't continue any more.
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    // Initialize the captureSession object.
    _captureSession = [[AVCaptureSession alloc] init];
    // Set the input device on the capture session.
    [_captureSession addInput:input];
    
    
    // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    // Create a new serial dispatch queue.
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    NSArray * validCodes = @[AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeQRCode];
    [captureMetadataOutput setMetadataObjectTypes:validCodes];
    
    // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_previewView.layer.bounds];
    [_previewView.layer addSublayer:_videoPreviewLayer];
    
    
    // Start video capture.
    [_captureSession startRunning];
    
    return YES;
}

- (void)stopReading {
    // Stop video capture and make the capture session object nil.
    [_captureSession stopRunning];
    _captureSession = nil;
    
    // Remove the video preview layer from the viewPreview view's layer.
    [_videoPreviewLayer removeFromSuperlayer];
    
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate method implementation

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    NSLog(@"Capture output");
    
    // Check if the metadataObjects array is not nil and it contains at least one object.
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        // Get the metadata object.
        
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        
        NSLog(@"AVmetadatmachineReableCodeOBject : %@", metadataObj);
       
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(addQRCodeToDetail:) withObject:[metadataObj stringValue] waitUntilDone:YES];
            
            _isReading = NO;
        }
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeCode39Code]) {
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(addVINToDetail:) withObject:[metadataObj stringValue] waitUntilDone:YES];
            
            _isReading = NO;
        }
        
        
        
    }
}
-(void)addVINToDetail:(NSString*)result{
    NSLog(@"VIN RESULT: %@",result);
    [self returnToDetails:result Type:@"VIN"];
}

-(void)addQRCodeToDetail:(NSString*)result{
    NSLog(@"QR RESULT: %@",result);
    NSError * error;
    NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dicResults = [NSJSONSerialization JSONObjectWithData:data  options:kNilOptions error:&error];
    [self returnToDetails:[dicResults  objectForKey:@"value"] Type:@"QR"];
    
}

- (IBAction)buttonPressed:(id)sender {
    UIButton * btn = (UIButton*)sender;
    switch (btn.tag) {
        case 0:
            NSLog(@"Cancel pressed");
			// I changed this so the button actually closes the view.
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case 1:
            NSLog(@"Flashlight pressed");
            _torchIsOn = !_torchIsOn;
            [self turnTorchOn:_torchIsOn];
            break;
        default:
            break;
    }
    
    
}
@end
