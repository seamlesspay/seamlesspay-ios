/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import "SPCardFormFieldEditingTransitionManager.h"

@implementation SPCardFormFieldEditingTransitionManager {

  /**
   These bits lets us track beginEditing and endEditing for payment text field
   as a whole (instead of on a per-subview basis).

   DO NOT read this values directly. Use the return value from
   `getAndUpdateStateFromCall:` which updates them all
   and returns you the correct current state for the method you are in.

   The state transitons in the should/did begin/end editing callbacks for all
   our subfields. If we get a shouldEnd AND a shouldBegin before getting either's
   matching didEnd/didBegin, then we are transitioning focus between our subviews
   (and so we ourselves should not consider us to have begun or ended editing).

   But if we get a should and did called on their own without a matching opposite
   pair (shouldBegin/didBegin or shouldEnd/didEnd) then we are transitioning
   into/out of our subviews from/to outside of ourselves
   */

  BOOL _isMidSubviewEditingTransitionInternal;
  BOOL _receivedUnmatchedShouldBeginEditing;
  BOOL _receivedUnmatchedShouldEndEditing;
}

- (BOOL)getAndUpdateStateFromCall:(SPFieldEditingTransitionCallSite)sendingMethod {

  BOOL stateToReturn;
  switch (sendingMethod) {
    case SPFieldEditingTransitionCallSiteShouldBegin:
      _receivedUnmatchedShouldBeginEditing = YES;
      if (_receivedUnmatchedShouldEndEditing) {
        _isMidSubviewEditingTransitionInternal = YES;
      }
      stateToReturn = _isMidSubviewEditingTransitionInternal;
      break;
    case SPFieldEditingTransitionCallSiteShouldEnd:
      _receivedUnmatchedShouldEndEditing = YES;
      if (_receivedUnmatchedShouldBeginEditing) {
        _isMidSubviewEditingTransitionInternal = YES;
      }
      stateToReturn = _isMidSubviewEditingTransitionInternal;
      break;
    case SPFieldEditingTransitionCallSiteDidBegin:
      stateToReturn = _isMidSubviewEditingTransitionInternal;
      _receivedUnmatchedShouldBeginEditing = NO;

      if (_receivedUnmatchedShouldEndEditing == NO) {
        _isMidSubviewEditingTransitionInternal = NO;
      }
      break;
    case SPFieldEditingTransitionCallSiteDidEnd:
      stateToReturn = _isMidSubviewEditingTransitionInternal;
      _receivedUnmatchedShouldEndEditing = NO;

      if (_receivedUnmatchedShouldBeginEditing == NO) {
        _isMidSubviewEditingTransitionInternal = NO;
      }
      break;
  }

  return stateToReturn;
}

- (void)resetSubviewEditingTransitionState {
  _isMidSubviewEditingTransitionInternal = NO;
  _receivedUnmatchedShouldBeginEditing = NO;
  _receivedUnmatchedShouldEndEditing = NO;
}

@end
