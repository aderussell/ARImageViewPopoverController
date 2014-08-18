//
//  ARViewController.m
//  ARImageViewPopoverController-Demo
//
//  Created by Adrian Russell on 11/08/2014.
//  Copyright (c) 2014 Adrian Russell. All rights reserved.
//

#import "ARViewController.h"
#import "ARImageViewPopoverController.h"

@interface ARViewController ()
@property ARImageViewPopoverController *popover;
@end

@implementation ARViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showNoImagePopover:(id)sender
{
    ARImageViewPopoverController *popover = [[ARImageViewPopoverController alloc] initWithImage:nil];
    [popover presentPopoverFromRect:[sender frame]
                             inView:[sender superview]
           permittedArrowDirections:UIPopoverArrowDirectionAny
                           animated:YES];
    self.popover = popover;
}



- (IBAction)showSingleImagePopover:(id)sender
{
    UIImage *image = [UIImage imageNamed:@"demo image.jpg"];
    
    ARImageViewPopoverController *popover = [[ARImageViewPopoverController alloc] initWithImage:image];
    //popover.showTitleBar = YES;
    popover.title = @"Hello there";
    popover.modal = YES;
    [popover presentPopoverFromRect:[sender frame]
                             inView:[sender superview]
           permittedArrowDirections:UIPopoverArrowDirectionAny
                           animated:YES];
    self.popover = popover;
}

- (IBAction)showMultipleImagePopover:(id)sender
{
    UIImage *image  = [UIImage imageNamed:@"demo image.jpg"];
    UIImage *image2 = [UIImage imageNamed:@"demo image 2.jpg"];
    UIImage *image3 = [UIImage imageNamed:@"demo image 3.jpg"];
    NSArray *images = @[image, image2, image3];
    
    ARImageViewPopoverController *popover = [[ARImageViewPopoverController alloc] initWithImages:images];
    //popover.showTitleBar = YES;
    //popover.showPageControl = NO;
    [popover presentPopoverFromRect:[sender frame]
                             inView:[sender superview]
           permittedArrowDirections:UIPopoverArrowDirectionAny
                           animated:YES];
    self.popover = popover;
    
    //self.popover.currentImageIndex = 2;
}

@end
