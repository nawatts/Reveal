//
//  RVLandmark.m
//  Reveal
//
//  Created by Nick Watts on 4/29/12.
//

#import "RVLandmark.h"

@interface RVLandmark()

@property (assign, nonatomic) CLLocationCoordinate2D* nodes;
@property (assign, nonatomic) NSUInteger num_nodes;

@property (assign, nonatomic) double elevation;
@property (assign, nonatomic) double height;

@end

@implementation RVLandmark

@synthesize name = _name;
@synthesize type = _type;

@synthesize nodes = _nodes;
@synthesize num_nodes = _num_nodes;

@synthesize elevation = _elevation;
@synthesize height = _height;

- (void)dealloc
{
  if ( _nodes != NULL ) {
    free(_nodes);
  }
  [super dealloc];
}

- (id)initFromJSON:(NSDictionary *)data
{
  self = [super init];
  if ( self ) {
    _name = [data objectForKey:@"name"];
    _type = [data objectForKey:@"type"];
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
  }
  return self;
}

- (CGRect)boundingBoxFromLocation:(RVLocationManager *)location
{
  return CGRectMake(0,0,0,0);
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
