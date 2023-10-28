/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SceneDelegate.h"
#import "DetailViewController.h"

@interface SceneDelegate () <UIWindowSceneDelegate,
UISplitViewControllerDelegate>

@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene
willConnectToSession:(UISceneSession *)session
      options:(UISceneConnectionOptions *)connectionOptions {
  UISplitViewController *splitViewController =
  (UISplitViewController *)self.window.rootViewController;
  UINavigationController *navigationController =
  splitViewController.viewControllers.lastObject;
  navigationController.topViewController.navigationItem.leftBarButtonItem =
  splitViewController.displayModeButtonItem;
  navigationController.topViewController.navigationItem
    .leftItemsSupplementBackButton = YES;
  splitViewController.delegate = self;
}

#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)splitViewController
collapseSecondaryViewController:(UIViewController *)secondaryViewController
  ontoPrimaryViewController:(UIViewController *)primaryViewController {
  if ([secondaryViewController isKindOfClass:[UINavigationController class]] &&
      [[(UINavigationController *)secondaryViewController topViewController]
       isKindOfClass:[DetailViewController class]] &&
      ([(DetailViewController *)[(UINavigationController *)
                                 secondaryViewController topViewController] detailItem] == nil)) {
    // Return YES to indicate that we have handled the collapse by doing
    // nothing; the secondary controller will be discarded.
    return YES;
  } else {
    return NO;
  }
}

@end
