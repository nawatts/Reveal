//
//  RVLandmarkView.m
//  Reveal
//
//  Created by Nick Watts on 4/29/12.
//

#import "RVLandmarkView.h"
#import "RVLandmark.h"

@implementation RVLandmarkView

- (id)initWithLandmark:(RVLandmark*)landmark
{
  self = [super initWithItems:[NSArray arrayWithObject:landmark.name]];
  if ( self ) {
    self.userInteractionEnabled = NO;
    self.segmentedControlStyle = UISegmentedControlStyleBar;
    self.tintColor = [UIColor blackColor];
  }
  return self;
}

/* Center view on position
 */
- (void)setPosition:(CGPoint)position
{
  [self sizeToFit];
  [self setFrame:CGRectMake(position.x - self.frame.size.width / 2, position.y - self.frame.size.height / 2, self.frame.size.width, self.frame.size.height)];
}

@end
