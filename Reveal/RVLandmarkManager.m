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

#define kLandmarkJSONSource @"http://localhost/~nwatts/reveal-editor/landmarks.php"

#define DEG2RAD(angle) ((angle) / 180.0 * M_PI)

@interface RVLandmarkManager ()
@property (strong, nonatomic) NSMutableDictionary* landmark_cache;
@end

@implementation RVLandmarkManager

@synthesize visible_distance = _visible_distance;
@synthesize landmark_cache = _landmark_cache;

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

- (void)didFetchLandmarkData:(NSDictionary*)landmark_data
{
  NSLog(@"%@", landmark_data);
}

/* Asynchronously fetch landmark data from the JSON source specified in kLandmarkJSONSource
 * Display an alert if there is an error retrieving or parsing the data
 * If no error, call didFetchLandmarkData with retrieved data
 */
- (void)updateLandmarkCache
{
  [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kLandmarkJSONSource]] 
                                     queue:[[[NSOperationQueue alloc] init] autorelease]
                         completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                           if ( ! error ) {
                             NSDictionary* landmark_json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                             if ( ! error ) {
                               [self didFetchLandmarkData:landmark_json];
                             } else {
                               UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
                               [alert show];
                             }
                           } else {
                             UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
                             [alert show];
                           }
                         }];
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
  } else if ( haversineDistance(current_location, last_update_location) > self.visible_distance * kVisibleDistanceUpdateFraction ) {
    [self updateLandmarkCache];
    last_update_location = current_location;
  }
}

@end
