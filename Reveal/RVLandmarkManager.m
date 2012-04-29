//
//  RVLandmarkManager.m
//  Reveal
//
//  Created by Nick Watts on 4/12/12.
//

#import "RVLandmarkManager.h"
#import "RVLocationManager.h"
#import "RVLandmark.h"

#define kDefaultVisibleDistance 200
#define kVisibleDistanceUpdateFraction 0.25

#define kLandmarkJSONSource @"http://localhost/~nwatts/reveal-editor/landmarks.php"

#define DEG2RAD(angle) ((angle) / 180.0 * M_PI)

@interface RVLandmarkManager ()
@property (strong, nonatomic) NSMutableDictionary* landmark_cache;
@property (assign, nonatomic) CLLocationCoordinate2D last_update_location;
@end

@implementation RVLandmarkManager

@synthesize visible_distance = _visible_distance;
@synthesize landmark_cache = _landmark_cache;
@synthesize last_update_location = _last_update_location;

@synthesize camera_view = _camera_view;

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LocationUpdated" object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HeadingUpdated" object:nil];
  [super dealloc];
}

- (id)init
{
  self = [super init];
  if (self) {
    self.visible_distance = kDefaultVisibleDistance;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateLocation:) name:@"LocationUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateHeading:) name:@"HeadingUpdated" object:nil];
  }
  return self;
}

double haversineDistance(CLLocationCoordinate2D c1, CLLocationCoordinate2D c2)
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

#pragma mark - Update landmarks methods

- (void)didFetchLandmarkData:(NSDictionary*)landmark_data atLocation:(CLLocationCoordinate2D)location
{
  NSLog(@"Fetched landmark data");
  
  // Remove landmarks that are no longer within range
  for ( NSNumber* key in [self.landmark_cache allKeys] ) {
    RVLandmark* landmark = [self.landmark_cache objectForKey:key];
    if ( haversineDistance(location, landmark.centerPoint) > self.visible_distance ) {
      [self.landmark_cache removeObjectForKey:key];
    }
  }
  
  // Add landmarks from fetched data
  for ( NSNumber* key in [landmark_data allKeys] ) {
    RVLandmark* new_landmark = [[RVLandmark alloc] initFromJSON:[landmark_data objectForKey:key]];
    [self.landmark_cache setObject:new_landmark forKey:key];
    [new_landmark release];
  }
}

- (void)updateLandmarksWithLocation:(RVLocationManager*)location forView:(RVCameraView*)view
{
  NSLog(@"Update landmarks");
}

- (void)showError:(NSError*)error
{
  UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:[@"Failed to update landmarks\n" stringByAppendingString:error.localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
  [alert show];
}

/* Asynchronously fetch landmark data from the JSON source specified in kLandmarkJSONSource
 * Display an alert if there is an error retrieving or parsing the data
 * If no error, call didFetchLandmarkData with retrieved data
 */
- (void)updateLandmarkCache:(CLLocationCoordinate2D)location
{
  NSString *query = [NSString stringWithFormat:@"?lat=%lf&lng=%lf&d=%d&exclude=%@", location.latitude, location.longitude, self.visible_distance, [[self.landmark_cache allKeys] componentsJoinedByString:@","]];
  NSURL *landmark_url = [NSURL URLWithString:[kLandmarkJSONSource stringByAppendingString:query]];
  [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:landmark_url]
                                     queue:[[[NSOperationQueue alloc] init] autorelease]
                         completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                           if ( ! error ) {
                             NSDictionary* landmark_json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                             if ( ! error ) {
                               [self didFetchLandmarkData:landmark_json atLocation:location];
                             } else {
                               NSLog(@"Error: %@", error.description);
                               dispatch_async(dispatch_get_main_queue(), ^{
                                 [self showError:error];
                               });
                             }
                           } else {
                             NSLog(@"Error: %@", error.description);
                             dispatch_async(dispatch_get_main_queue(), ^{
                               [self showError:error];
                             });
                           }
                         }];
  self.last_update_location = location;
}

#pragma mark - Notification Observers

- (void)didUpdateLocation:(NSNotification*)notification
{
  static BOOL initialized = NO;
  
  CLLocationCoordinate2D current_location = ((RVLocationManager*) notification.object).current_location;
  
  // Only update landmarks on the first location update or if the device has moved a certain distance since the last update
  if ( initialized == NO ) {
    [self updateLandmarkCache:current_location];
    initialized = YES;
  } else if ( haversineDistance(current_location, self.last_update_location) > self.visible_distance * kVisibleDistanceUpdateFraction ) {
    [self updateLandmarkCache:current_location];
  }
}

- (void)didUpdateHeading:(NSNotification*)notification
{
  [self updateLandmarksWithLocation:((RVLocationManager*) notification.object) forView:self.camera_view];
}

@end
