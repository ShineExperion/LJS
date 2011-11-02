//
//  LJSAppDelegate.h
//  Test-LumberjackHTTPLogging
//
//  Created by Joshua Moody on 10/21/11.
//  Copyright (c) 2011 Little Joy Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LjsHttpLogManager.h"

@class LJSViewController;

@interface LJSAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) LJSViewController *viewController;
@property (nonatomic, retain) LjsHttpLogManager *httpLogManager;


@end
