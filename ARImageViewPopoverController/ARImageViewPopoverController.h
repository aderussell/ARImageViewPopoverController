//
//  ARImageViewPopoverController.h
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

@import UIKit;

/** There are no images in the image view popover. */
enum {ARImageViewNoImage = -1};

/**
 This class provides a popover controller that can display an array of images.
 You should not attempt to change the popoverContentSize after it has been created as that will mess with the layout of the contents.
 */
@interface ARImageViewPopoverController : UIPopoverController

/**
 Creates an returns a popover controller that contains the input image.
 @param image The image to show.
 @return A popover controller that displays the input image.
 */
- (instancetype)initWithImage:(UIImage *)image;

/**
 Creates an returns a popover controller that contains the input images.
 @param images The images to display.
 @return A popover controller that displays the input images.
 */
- (instancetype)initWithImages:(NSArray *)images;


/** The images being displayed in the popover. */
@property (readonly) NSArray *images;

/** The title to be displayed in the title bar. The default is an empty string. */
@property (nonatomic) NSString *title;

/** the index of the image being currently displayed. If there is no images then `ARImageViewNoImage` is returned. */
@property (nonatomic) NSInteger currentImageIndex;

/** Whether, or not, the pade control is displayed below the images. By default this is `NO` if there is 0 or 1 images and `YES if more. */
@property (nonatomic, getter=isShowingPageControl) BOOL showPageControl;

/** whether, or not, the title bar will be shown in the popover. The default is `NO`. */
@property (nonatomic, getter=isShowingTitleBar) BOOL showTitleBar;

/** If the popover is treated as modal. If `YES` then the popover can not be dismissed by clicking outside it. The default is `NO`.
 @discussion Setting this to `YES` then the title bar will be shown to allow access to the close button. */
@property (nonatomic, getter = isModal) BOOL modal;



/** @name Customising Appearance */

@property (nonatomic) UIColor *titleBarTintColor;

@property (nonatomic) UIColor *pageIndicatorTintColor;

@property (nonatomic) UIColor *currentPageIndicatorTintColor;

@end
