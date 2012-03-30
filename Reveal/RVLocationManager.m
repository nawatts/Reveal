//
//  RVLocationManager.m
//  Reveal
//
//  Created by Nick Watts on 3/28/12.
//

#import <CoreLocation/CoreLocation.h>
#import "RVLocationManager.h"

@interface RVLocationManager()
@property (strong, nonatomic) CLLocationManager* location_manager;
@end

@implementation RVLocationManager

@synthesize location_manager = _location_manager;
@synthesize current_location = _current_location;
@synthesize current_heading = _current_heading;

- (void)dealloc
{
  [_location_manager stopUpdatingLocation];
  [_location_manager stopUpdatingHeading];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
  _location_manager = nil;
  [super dealloc];
}

- (id)init
{
  self = [super init];
  if ( self ) {
    self.location_manager = [[CLLocationManager alloc] init];
    self.location_manager.delegate = self;
    
    self.location_manager.headingFilter = 1.0;
    self.location_manager.desiredAccuracy = kCLLocationAccuracyBest;
    self.location_manager.distanceFilter = 5.0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [self.location_manager startUpdatingLocation];
    [self.location_manager startUpdatingHeading];
  }
  
  return self;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
  NSLog(@"RVLocationManager : Moved to %lf, %lf", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
  _current_location = newLocation.coordinate;
  [[NSNotificationCenter defaultCenter] postNotificationName:@"LocationUpdated" object:self];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
  // Prefer true heading
  // If it's not available, fall back to magnetic heading
  // If neither is available, don't post an update
  if ( newHeading.trueHeading >= 0 ) {
    _current_heading = newHeading.trueHeading;
    NSLog(@"RVLocationManager : Pointed at %.02lf (+-%.01lf)", newHeading.trueHeading, newHeading.headingAccuracy);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HeadingUpdated" object:self];
  } else if ( newHeading.headingAccuracy >= 0 ) {
    _current_heading = newHeading.magneticHeading;
    NSLog(@"RVLocationManager : Pointed at %.02lf (+-%.01lf)", newHeading.magneticHeading, newHeading.headingAccuracy);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HeadingUpdated" object:self];
  }
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
  return YES;
}
     
#pragma mark - Device orientation change observer

- (void)deviceOrientationDidChange:(NSNotification*)notification
{
  self.location_manager.headingOrientation = ((UIDevice*) notification.object).orientation;
}

@end
