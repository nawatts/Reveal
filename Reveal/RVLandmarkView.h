//
//  RVLandmarkView.h
//  Reveal
//
//  Created by Nick Watts on 4/29/12.
//

#import <UIKit/UIKit.h>

@class RVLandmark;

@interface RVLandmarkView : UILabel

- (id)initWithLandmark:(RVLandmark*)landmark;

- (void)setPosition:(CGPoint)position;

@end
