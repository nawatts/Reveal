//
//  RVMainView.h
//  Reveal
//
//  Created by Nick Watts on 3/29/12.
//

#import <UIKit/UIKit.h>
#import <Mapkit/Mapkit.h>
#import "RVCameraView.h"

@interface RVMainView : UIView <MKMapViewDelegate>

@property (strong, nonatomic) UISegmentedControl* compass_display;
@property (strong, nonatomic) MKMapView* map_display;
@property (strong, nonatomic) RVCameraView* camera_display;

@end
