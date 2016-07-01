
#import "BarcodeScanViewController.h"

@interface BarcodeScanViewController ()
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) UIButton *btnFlashlight;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property (nonatomic) BOOL isReading, torchIsOn;
@property (nonatomic) NSString * scannedBarcode;
- (IBAction)buttonPressed:(id)sender;

@end

@implementation BarcodeScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Scan";
    _torchIsOn = false;
    
    _captureSession = nil;
    _isReading = NO;



}

- (void) viewDidLayoutSubviews {
    [self startReading];
    
    _btnFlashlight = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _btnFlashlight.tag = 1;
    [_btnFlashlight setTitle:@"Flashlight" forState:UIControlStateNormal];
    _btnFlashlight.frame = CGRectMake(25, 60, 95, 30);
    [_btnFlashlight respondsToSelector:@selector(buttonPressed:)];
    [self.view addSubview:_btnFlashlight];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated{
    _isReading = NO;
    _torchIsOn = false;
    [self turnTorchOn:_torchIsOn];
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
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
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
            [self.navigationController popViewControllerAnimated:YES];
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
