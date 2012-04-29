//
//  RVLandmark.h
//  Reveal
//
//  Created by Nick Watts on 4/29/12.
//

#import <Foundation/Foundation.h>
#import "RVLocationManager.h"

@interface RVLandmark : NSObject

@property (copy, readonly) NSString* name;
@property (copy, readonly) NSString* type;

- (id)initFromJSON:(NSDictionary*)data;

- (CGRect)boundingBoxFromLocation:(RVLocationManager*)location;

- (CLLocationCoordinate2D)centerPoint;

@end
