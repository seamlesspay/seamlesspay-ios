/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "SingleLineCardForm.h"

@interface DetailViewController : UIViewController <WKNavigationDelegate>

@property(strong, nonatomic) NSString *detailItem;
@property(strong, nonatomic) NSString *contentHTML;
@property(strong, nonatomic) WKWebView *webView;
@property(nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property(nonatomic, strong) SingleLineCardForm *singleLineCardFormView;
@property(nonatomic, weak) UITextField *amountTextField;

- (void)displayAlertWithTitle:(NSString *)title
                      message:(NSString *)message
                  restartDemo:(BOOL)restartDemo;

@end
