/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "CardFormViewModel+FieldConfigs.h"

@implementation CardFormViewModel (FieldConfig)

// MARK: - Postal Code

// Implement postalCodeDisplayed
- (BOOL)postalCodeDisplayed {
    return self.postalCodeDisplayConfig != DisplayConfigurationNone;
}

// Implement postalCodeRequired
- (BOOL)postalCodeRequired {
    return self.postalCodeDisplayConfig == DisplayConfigurationRequired;
}

// MARK: - CVC

// Implement cvcDisplayed
- (BOOL)cvcDisplayed {
    return self.cvcDisplayConfig != DisplayConfigurationNone;
}

// Implement cvcRequired
- (BOOL)cvcRequired {
    return self.cvcDisplayConfig == DisplayConfigurationRequired;
}

@end
