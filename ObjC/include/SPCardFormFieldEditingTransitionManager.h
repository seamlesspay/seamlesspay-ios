/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */


typedef NS_ENUM(NSInteger, SPFieldEditingTransitionCallSite) {
  SPFieldEditingTransitionCallSiteShouldBegin,
  SPFieldEditingTransitionCallSiteShouldEnd,
  SPFieldEditingTransitionCallSiteDidBegin,
  SPFieldEditingTransitionCallSiteDidEnd,
};

@interface SPCardFormFieldEditingTransitionManager : NSObject

- (void)resetSubviewEditingTransitionState;
- (BOOL)getAndUpdateStateFromCall:(SPFieldEditingTransitionCallSite)sendingMethod;

@end