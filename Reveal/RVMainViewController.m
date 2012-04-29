//
//  RVMainViewController.m
//  Reveal
//
//  Created by Nick Watts on 3/28/12.
//

#import "RVMainViewController.h"
#import "RVMainView.h"

@interface RVMainViewController ()

@end

@implementation RVMainViewController

@synthesize landmark_manager = _landmark_manager;

- (void)dealloc
{
  [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.view = [[[RVMainView alloc] init] autorelease];
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated
{
  self.landmark_manager.camera_view = ((RVMainView*) self.view).camera_display;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{

}

@end
