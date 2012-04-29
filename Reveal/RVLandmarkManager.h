//
//  RVLandmarkManager.h
//  Reveal
//
//  Created by Nick Watts on 4/12/12.
//

#import <Foundation/Foundation.h>
#import "RVCameraView.h"

@interface RVLandmarkManager : NSObject
@property NSInteger visible_distance;
@property (strong, nonatomic) RVCameraView* camera_view;
@end
