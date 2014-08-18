//
//  ARImageViewPopoverController.m
//
//  Created by Adrian Russell on 01/08/2013.
//  Copyright (c) 2014 Adrian Russell. All rights reserved.
//
//  This software is provided 'as-is', without any express or implied
//  warranty. In no event will the authors be held liable for any damages
//  arising from the use of this software. Permission is granted to anyone to
//  use this software for any purpose, including commercial applications, and to
//  alter it and redistribute it freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source
//     distribution.
//

#import "ARImageViewPopoverController.h"

CGSize CGSizeClamp(CGSize min, CGSize max, CGSize size) __attribute__((const));
CGSize CGSizeClamp(CGSize min, CGSize max, CGSize size)
{
    CGFloat width  = MIN(MAX(min.width,  size.width),  max.width);
    CGFloat height = MIN(MAX(min.height, size.height), max.height);
    return CGSizeMake(width, height);
}



CGSize maxSizeForImages(NSArray *images) __attribute__ ((const));
CGSize maxSizeForImages(NSArray *images)
{
    CGSize maxSize = CGSizeZero;
    for (UIImage *image in images) {
        CGSize imageSize = image.size;
        maxSize.width  = MAX(imageSize.width,  maxSize.width);
        maxSize.height = MAX(imageSize.height, maxSize.height);
    }
    return maxSize;
}

CGFloat ratioForSize(CGSize aSize) __attribute__ ((const));
CGFloat ratioForSize(CGSize aSize)
{
    return (aSize.height / aSize.width);
}

void ratioExtremesForImages(NSArray *images, CGFloat *minRatio, CGFloat *maxRatio);
void ratioExtremesForImages(NSArray *images, CGFloat *minRatio, CGFloat *maxRatio)
{
    if (!images.count) {
        return;
    }
    UIImage *image = [images firstObject];
    
    CGFloat min = ratioForSize(image.size);
    CGFloat max = min;
    for (NSUInteger i = 1; i < images.count; i++) {
        image = images[i];
        
        CGFloat ratio = ratioForSize(image.size);
        if (ratio > max) max = ratio;
        if (ratio < min) min = ratio;
    }
    
    if (minRatio) *minRatio = min;
    if (maxRatio) *maxRatio = max;
}

CGSize squareResize(CGSize max, CGSize size)  __attribute__ ((const));
CGSize squareResize(CGSize max, CGSize size)
{
    
    if (size.width == 0 || size.height == 0) {
        return max;
    }
    
    CGFloat sizeRatio = (size.width / size.height);
    if (sizeRatio > 1.0) {
        CGSize s;
        s.width  = max.width;
        s.height = (max.width / size.width) * size.height;
        return s;
    } else {
        CGSize s;
        s.height = max.height;
        s.width  = (max.height / size.height) * size.width;
        return s;
    }
}


//CGSize resize(CGSize space, CGSize shape)
//{
//    
//    
//    if (shape.width > space.width && shape.height > space.height) {
//        
//    }
//    
//    
//    BOOL fitsVertically = ( (shape.height / space.height) < (shape.width / space.width) ) ? YES : NO;
//    
//    CGFloat pixelScale = (fitsVertically) ? (shape.height / space.height) : (shape.width / space.width);
//    
//    CGSize newSize = CGSizeMake(space.width * pixelScale, space.height * pixelScale);
//    
//    return newSize;
//}
//
//CGSize CGRatioPreservingClamp(CGSize min, CGSize max, CGSize size)
//{
//    if (size.width > max.width && size.height > max.height) {
//        CGFloat maxRatio  = (max.width  / max.height);
//        CGFloat sizeRatio = (size.width / size.height);
//    }
//}




#define MIN_SIZE CGSizeMake(50.0, 50.0)
#define MAX_SIZE CGSizeMake(600.0, 600.0)

#pragma mark - Class Extension

@interface ARImageViewPopoverController () <UIScrollViewDelegate>
@property (nonatomic) UIScrollView  *scrollView;    // the scroll view that will contain the images in image views.
@property (nonatomic) UIPageControl *pageControl;   // the page control.
@property (nonatomic) NSArray       *images;        // to add setter for this property.
@end


#pragma mark - Class Implementation

@implementation ARImageViewPopoverController

#pragma mark - Initialisers

- (instancetype)initWithImage:(UIImage *)image
{
    // create an array contaning the input image and then call the array initialiser method.
    NSArray *images = (image) ? @[image] : @[];
    return [self initWithImages:images];
}

- (instancetype)initWithImages:(NSArray *)images
{
    // create view controller to go into the popover.
    UIViewController* popoverContent = [[UIViewController alloc] init];
    
    // add a button to content view controller that will appear on nvagiation bar that will close the popover when pressed.
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(closePressed:)];
    [popoverContent.navigationItem setRightBarButtonItem:closeButton animated:NO];
    
    // the content view controller is embedded in a navigation controller so we can use the navigation bar as a title bar.
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:popoverContent];
    
    // initialise the popover with the navigation controller.
    if (self = [super initWithContentViewController:navigationController]) {
        
        // set the array of images.
        self.images = images;
    
        // create the content view for the images, or one if there are no images.
        UIView *contentView = (images.count) ? [self setupImages] : [self setupNoImage];
        
        // set the view controller view to the content view.
        popoverContent.view = contentView;
        
        // by default hide the title bar.
        // This is done before we set the popover content size is set so that the content size isn't resized and to small by the height of the navigation bar.
        self.showTitleBar = NO;
        
        // set popover content size to the size of the view.
        [self setPopoverContentSize:contentView.frame.size animated:NO];
        
        // if there is only a single image then hide the page control by default.
        if (images.count == 1) {
            self.showPageControl = NO;
        }
    }
    return self;
}

//-----------------------------------------------------------------------------------------//
#pragma mark - Setup views

/**
 Create and return the view (a UILabel) that will be shown if the popover is to be shown with no image.
 @return The no images view.
 */
- (UIView *)setupNoImage
{
    // create label that says there is no image centered.
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 150.0)];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"No Image";
    label.textAlignment = NSTextAlignmentCenter;
    
    // if the device is running ios& or later then use black text as the popover controller is white
    // else use white text becuase the popover controller will be dark blue.
    label.textColor = (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) ? [UIColor blackColor] : [UIColor whiteColor];
    
    return label;
}

/**
 Creates and returns a UIView that contains a scroll view to display the images and a page control to show the current index of image.
 @return The view containing the scroll view for the images.
 */
- (UIView *)setupImages
{
    CGSize maxSize = maxSizeForImages(self.images);
    maxSize = CGSizeClamp(MIN_SIZE, maxSize, maxSize);
    maxSize = squareResize(MAX_SIZE, maxSize);
    CGRect imageRect = CGRectMake(0.0, 0.0, maxSize.width, maxSize.height);
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:imageRect];
    
    scrollView.contentSize = CGSizeMake(maxSize.width * self.images.count, maxSize.height);
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.delegate = self;
    self.scrollView = scrollView;
    
    // add the images to the scroll view in image views.
    for (NSUInteger i = 0; i < self.images.count; i++) {
        CGRect imageViewFrame = CGRectMake(i * maxSize.width, 0.0, maxSize.width, maxSize.height);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
        imageView.image = self.images[i];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [scrollView addSubview:imageView];
    }
    
    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0, scrollView.frame.size.height, scrollView.frame.size.width, 20.0)];
    pageControl.numberOfPages = self.images.count;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        pageControl.pageIndicatorTintColor = [UIColor grayColor];
        pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
    }
    self.pageControl = pageControl;
    
    
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectUnion(scrollView.frame, pageControl.frame)];
    [mainView addSubview:scrollView];
    [mainView addSubview:pageControl];
    
    return mainView;
}



//-----------------------------------------------------------------------------------------//
#pragma mark - UIScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // work out which page scrollview is on and set pagecontrol
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}


//-----------------------------------------------------------------------------------------//
#pragma mark - Setters & Getters

- (NSString *)title
{
    UINavigationController *navi = (UINavigationController *)self.contentViewController;
    UIViewController *vc = [navi topViewController];
    return vc.title;
}

- (void)setTitle:(NSString *)title
{
    UINavigationController *navi = (UINavigationController *)self.contentViewController;
    UIViewController *vc = [navi topViewController];
    vc.title = title;
}

//-----------

- (BOOL)isShowingTitleBar
{
    UINavigationController *navigationController = (UINavigationController *)self.contentViewController;
    return !(navigationController.navigationBarHidden);
}

- (void)setShowTitleBar:(BOOL)showTitleBar
{
    if (showTitleBar != self.isShowingTitleBar) {
        UINavigationController *navigationController = (UINavigationController *)self.contentViewController;
        CGSize currentContentSize = self.popoverContentSize;
        if (showTitleBar) {
            currentContentSize.height += navigationController.navigationBar.frame.size.height;
        } else {
            currentContentSize.height -= navigationController.navigationBar.frame.size.height;
        }
        navigationController.navigationBarHidden = !showTitleBar;
    }
}

//-----------

- (BOOL)isShowingPageControl
{
    return !(self.pageControl.isHidden);
}

- (void)setShowPageControl:(BOOL)showPageControl
{
    if (showPageControl != self.isShowingPageControl) {
        CGSize currentContentSize = self.popoverContentSize;
        if (showPageControl) {
            currentContentSize.height += self.pageControl.frame.size.height;
        } else {
            currentContentSize.height -= self.pageControl.frame.size.height;
        }
        self.popoverContentSize = currentContentSize;
        self.pageControl.hidden = !showPageControl;
    }
}

//-----------

- (NSInteger)currentImageIndex
{
    return (self.images.count) ? self.pageControl.currentPage : ARImageViewNoImage;
}

- (void)setCurrentImageIndex:(NSInteger)currentImageIndex
{
    // if the new page is invalid then return and do nothing.
    if (currentImageIndex < 0 || currentImageIndex >= self.pageControl.numberOfPages) {
        return;
    }
    
    // calculate the scroll content position for the image and animate to the position.
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * currentImageIndex;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
}

//-----------

- (UIColor *)currentPageIndicatorTintColor
{
    return self.pageControl.currentPageIndicatorTintColor;
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor
{
    self.pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor;
}

//-----------

- (UIColor *)pageIndicatorTintColor
{
    return self.pageControl.pageIndicatorTintColor;
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor
{
    self.pageControl.pageIndicatorTintColor = pageIndicatorTintColor;
}

//-----------

- (BOOL)isModal
{
    return self.contentViewController.isModalInPopover;
}

- (void)setModal:(BOOL)modal
{
    self.contentViewController.modalInPopover = modal;
    if (modal) {
        self.showTitleBar = YES;
    }
}


//-----------------------------------------------------------------------------------------//
#pragma mark - Control actions

/**
 Dismisses the popover with an animation. This is called by the title bar button.
 @param sender The object that called the method.
 */
- (void)closePressed:(id)sender
{
    [self dismissPopoverAnimated:YES];
}


@end
