//
//  RVMainViewController.h
//  Reveal
//
//  Created by Nick Watts on 3/28/12.
//

#import <UIKit/UIKit.h>
#import <Mapkit/Mapkit.h>
#import "RVLandmarkManager.h"

@interface RVMainViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) RVLandmarkManager* landmark_manager;

@end
