//
//  RVLandmark.h
//  Reveal
//
//  Created by Nick Watts on 4/29/12.
//

#import <Foundation/Foundation.h>
#import "RVLocationManager.h"
#import "RVLandmarkView.h"

@interface RVLandmark : NSObject

@property (assign, readonly) NSInteger uid;
@property (copy, nonatomic) NSString* name;
@property (copy, nonatomic) NSString* type;
@property (strong) RVLandmarkView* view;

- (id)initFromJSON:(NSDictionary*)data withId:(NSInteger)uid;

- (CGRect)boundingBoxFromLocation:(RVLocationManager*)location;

- (CLLocationCoordinate2D)centerPoint;

@end
