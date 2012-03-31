//
//  RVCameraView.m
//  Reveal
//
//  Created by Nick Watts on 3/30/12.
//

#import "RVCameraView.h"
#import <AVFoundation/AVFoundation.h>

@interface RVCameraView ()

@property (strong, nonatomic) AVCaptureSession* capture_session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer* preview_layer;

@end

@implementation RVCameraView

@synthesize capture_session = _capture_session;
@synthesize preview_layer = _preview_layer;

- (void)dealloc
{
  [_preview_layer release];
  [_capture_session stopRunning];
  [_capture_session release];
  [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    // Initialization code
    self.capture_session = [[AVCaptureSession alloc] init];
    self.capture_session.sessionPreset = AVCaptureSessionPresetMedium;
    
    self.preview_layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.capture_session];
    // Makes the camera preview resize to fill the layer when the phone is rotated between orientations
    [self.preview_layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];

    self.preview_layer.frame = self.bounds;
    [self.layer addSublayer:self.preview_layer];
    
    AVCaptureDevice *video_device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *input_error = nil;
    AVCaptureDeviceInput *video_input = [AVCaptureDeviceInput deviceInputWithDevice:video_device error:&input_error];
    if (video_input && [self.capture_session canAddInput:video_input]) {
      [self.capture_session addInput:video_input];
    }
    else {
      NSLog(@"Error opening camera: %@", input_error);
    }
    
    [self.capture_session startRunning];
  }
  return self;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
  [super layoutSublayersOfLayer:layer];
  self.preview_layer.frame = self.bounds;
  self.preview_layer.orientation = [[UIApplication sharedApplication] statusBarOrientation];
}

@end
