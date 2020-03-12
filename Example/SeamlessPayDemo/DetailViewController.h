/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface DetailViewController : UIViewController <WKNavigationDelegate>

@property(strong, nonatomic) NSString *detailItem;
@property(strong, nonatomic) NSString *contentHTML;
@property(strong, nonatomic) WKWebView *webView;

@end
