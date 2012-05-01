//
//  RVLandmark.m
//  Reveal
//
//  Created by Nick Watts on 4/29/12.
//

#import "RVLandmark.h"

#define RAD2DEG(angle) ((angle) / M_PI * 180.0)

@interface RVLandmark()

@property (assign, nonatomic) CLLocationCoordinate2D* nodes;
@property (assign, nonatomic) NSUInteger num_nodes;

@property (assign, nonatomic) double elevation;
@property (assign, nonatomic) double height;

@end

@implementation RVLandmark

@synthesize uid = _uid;
@synthesize name = _name;
@synthesize type = _type;
@synthesize view = _view;

@synthesize nodes = _nodes;
@synthesize num_nodes = _num_nodes;

@synthesize elevation = _elevation;
@synthesize height = _height;

- (void)dealloc
{
  if ( _nodes != NULL ) {
    free(_nodes);
  }
  [_view release];
  [super dealloc];
}

- (id)initFromJSON:(NSDictionary *)data withId:(NSInteger)uid;
{
  self = [super init];
  if ( self ) {
    _uid = uid;
    self.name = [data objectForKey:@"name"];
    self.type = [data objectForKey:@"type"];
    self.elevation = ((NSNumber*) [data objectForKey:@"ele"]).doubleValue;
    self.height = ((NSNumber*) [data objectForKey:@"hgt"]).doubleValue;
    
    NSArray* nodes_data = [data objectForKey:@"nds"];
    _nodes = (CLLocationCoordinate2D*) malloc(nodes_data.count * sizeof(CLLocationCoordinate2D));
    if ( _nodes == NULL ) {
      NSLog(@"MALLOC FAILED!!");
    } else {
      self.num_nodes = nodes_data.count;
      int i = 0;
      for ( NSDictionary* node_data in nodes_data ) {
        double lat = ((NSNumber*) [node_data objectForKey:@"lat"]).doubleValue;
        double lng = ((NSNumber*) [node_data objectForKey:@"lng"]).doubleValue;
        _nodes[i] = CLLocationCoordinate2DMake(lat, lng);
        i++;
      }
    }
    
    self.view = [[[RVLandmarkView alloc] initWithLandmark:self] autorelease];
  }
  return self;
}

- (CLLocationDirection)headingFromPoint:(CLLocationCoordinate2D)point1 toPoint:(CLLocationCoordinate2D)point2
{  
  double heading = RAD2DEG(atan2(point2.longitude - point1.longitude, point2.latitude - point1.latitude));
  if ( heading < 0 ) {
    heading += 360;
  }
  return heading;
}

- (CGRect)boundingBoxFromLocation:(RVLocationManager *)location fov:(double)fov view:(RVCameraView *)view
{
  BOOL visible = NO;
  
  CLLocationDirection min_heading = 360;
  CLLocationDirection max_heading = -360;
  for ( int i = 0; i < self.num_nodes; i++ ) {
    CLLocationDirection heading_to_node = [self headingFromPoint:location.current_location toPoint:self.nodes[i]];
    CLLocationDirection relative_heading = heading_to_node - location.current_heading;
    
    // Map to [-180, 180]
    if ( relative_heading > 180 ) {
      relative_heading -= 360;
    } else if ( relative_heading < -180 ) {
      relative_heading += 360;
    }
    
    // Building is only visible if some part of it is in front of you
    if ( abs(relative_heading) < 90 ) {
      visible = YES;
    }
    
    min_heading = MIN(min_heading, relative_heading);
    max_heading = MAX(max_heading, relative_heading);
  }
  
  double scale = view.bounds.size.width / fov;
  
  CGRect bounding_box = CGRectMake(min_heading * scale, 0, (max_heading - min_heading) * scale, 0);
  
  // Problem caused when a building is directly behind you.  The min heading will be far to the left and the max
  // heading far to the right, making it appear that the building spans the entire view, when in fact it isn't 
  // visible at all
  if ( ! visible && min_heading < 0 && max_heading > 0 ) {
    if ( abs(min_heading) < abs(max_heading) ) {
      bounding_box.size.width = (360 - abs(min_heading) - abs(max_heading)) * scale;
      bounding_box.origin.x = min_heading * scale - bounding_box.size.width;
    } else {
      bounding_box.size.width = (360 - abs(min_heading) - abs(max_heading)) * scale;
      bounding_box.origin.x = max_heading * scale;
    }
  }
  
  bounding_box.origin.x += view.bounds.size.width / 2;
  
  return bounding_box;
}

/* Calculate average of all nodes
 */
- (CLLocationCoordinate2D)centerPoint
{
  double lat_sum = 0, lng_sum = 0;
  for ( int i = 0; i < self.num_nodes; i++ ) {
    lat_sum += _nodes[i].latitude;
    lng_sum += _nodes[i].longitude;
  }
  
  return CLLocationCoordinate2DMake(lat_sum / self.num_nodes, lng_sum / self.num_nodes);
}

@end
