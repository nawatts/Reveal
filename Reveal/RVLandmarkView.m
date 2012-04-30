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
  self = [super init];
  if ( self ) {
    self.text = landmark.name;
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
