//
//  RVMainView.m
//  Reveal
//
//  Created by Nick Watts on 3/29/12.
//

#import <QuartzCore/QuartzCore.h>
#import "RVMainView.h"
#import "RVLocationManager.h"

@implementation RVMainView

@synthesize compass_display = _compass_display;
@synthesize map_display = _map_display;
@synthesize camera_display = _camera_display;

- (void)dealloc
{
  _compass_display = nil;
  _map_display = nil;
  _camera_display = nil;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LocationUpdated" object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HeadingUpdated" object:nil];
  
  [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedLocation:) name:@"LocationUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedHeading:) name:@"HeadingUpdated" object:nil];
    
    self.camera_display = [[RVCameraView alloc] initWithFrame:self.bounds];
    [self addSubview:self.camera_display];
    
    self.compass_display = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"---.-"]];
    [self.compass_display setSegmentedControlStyle:UISegmentedControlStyleBar];
    [self.compass_display setUserInteractionEnabled:NO];
    [self.compass_display setTintColor:[UIColor colorWithRed:0 green:0.79 blue:0.34 alpha:1]];
    [self addSubview:self.compass_display];
    
    // Set up map view
    // The transform is applied to make the Google logo and user location marker smaller
    self.map_display = [[MKMapView alloc] initWithFrame:CGRectMake(0 ,0, 180, 180)];
    self.map_display.transform = CGAffineTransformMakeScale(0.5, 0.5);
    self.map_display.showsUserLocation = YES;
    self.map_display.layer.borderColor = [[UIColor blackColor] CGColor];
    self.map_display.layer.borderWidth = 2.0;
    self.map_display.mapType = MKMapTypeStandard;
    self.map_display.delegate = self;
    [self addSubview:self.map_display];
  }
  return self;
}

- (void)layoutSubviews
{  
  [super layoutSubviews];
  self.map_display.frame = CGRectMake(8,self.bounds.size.height-8-90, 90, 90);
  self.compass_display.frame = CGRectMake(self.bounds.size.width-8-67, self.bounds.size.height-8-30, 67, 30);
}

#pragma mark - Notification Observers

- (void)updatedLocation:(NSNotification*)notification
{
  CLLocationCoordinate2D location = ((RVLocationManager*) notification.object).current_location;  
  // Center map on user's location
  [self.map_display setRegion:MKCoordinateRegionMake(location, MKCoordinateSpanMake(0.002, 0.002)) animated:YES];
}

- (void)updatedHeading:(NSNotification*)notification
{
  CLLocationDirection heading = ((RVLocationManager*) notification.object).current_heading;
  [self.compass_display setTitle:[NSString stringWithFormat:@"%.01lf", heading] forSegmentAtIndex:0];
}

@end
