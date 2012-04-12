//
//  RVLandmarkManager.m
//  Reveal
//
//  Created by Nick Watts on 4/12/12.
//

#import "RVLandmarkManager.h"
#import "RVLocationManager.h"

#define kDefaultVisibleDistance 1000
#define kVisibleDistanceUpdateFraction 0.25

#define DEG2RAD(angle) ((angle) / 180.0 * M_PI)

@interface RVLandmarkManager ()

@end

@implementation RVLandmarkManager

@synthesize visible_distance = _visible_distance;

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LocationUpdated" object:nil];
  [super dealloc];
}

- (id)init
{
  self = [super init];
  if (self) {
    self.visible_distance = kDefaultVisibleDistance;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateLocation:) name:@"LocationUpdated" object:nil];
  }
  return self;
}

double distance(CLLocationCoordinate2D c1, CLLocationCoordinate2D c2)
{
  // http://www.movable-type.co.uk/scripts/latlong.html
  int earth_radius = 6371000; // meters
  double d_lat = DEG2RAD(c2.latitude - c1.latitude);
  double d_lng = DEG2RAD(c2.longitude - c1.longitude);
  double lat1 = DEG2RAD(c1.latitude);
  double lat2 = DEG2RAD(c2.latitude);
  
  double a = sin(d_lat/2) * sin(d_lat/2) + sin(d_lng/2) * sin(d_lng/2) * cos(lat1) * cos(lat2);
  double c = 2 * atan2(sqrt(a), sqrt(1-a));
  return c * earth_radius;
}

- (void)updateLandmarkCache
{
  NSLog(@"Update Landmarks");
}

#pragma mark - Notification Observers

- (void)didUpdateLocation:(NSNotification*)notification
{
  static BOOL initialized = NO;
  static CLLocationCoordinate2D last_update_location;
  
  CLLocationCoordinate2D current_location = ((RVLocationManager*) notification.object).current_location;
  
  // Only update landmarks on the first location update or if the device has moved a certain distance since the last update
  if ( initialized == NO ) {
    last_update_location = current_location;
    [self updateLandmarkCache];
    initialized = YES;
  } else if ( distance(current_location, last_update_location) > self.visible_distance * kVisibleDistanceUpdateFraction ) {
    [self updateLandmarkCache];
    last_update_location = current_location;
  }
}

@end
