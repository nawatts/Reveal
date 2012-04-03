//
//  RVLocationManager.h
//  Reveal
//
//  Created by Nick Watts on 3/28/12.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface RVLocationManager : NSObject <CLLocationManagerDelegate, UIAccelerometerDelegate>

@property (assign, nonatomic, readonly) CLLocationCoordinate2D current_location;
@property (assign, nonatomic, readonly) CLLocationDirection current_heading;

// Pitch of phone in radians (-PI,PI)
@property (assign, nonatomic, readonly) double current_pitch;

@end
