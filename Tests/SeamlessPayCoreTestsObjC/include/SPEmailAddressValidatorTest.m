//
//  SPEmailAddressValidatorTest.m
//  SeamlessPayCoreTests
//
//  Created by Oleksiy Shortov on 3/9/20.
//  Copyright © 2020 info@seamlesspay.com. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "../../SeamlessPayCoreObjC/include/SPEmailAddressValidator.h"


@interface SPEmailAddressValidatorTest : XCTestCase

@end

@implementation SPEmailAddressValidatorTest

- (void)testValidEmails {
  NSArray *validEmails = @[
    @"test@test.com",
    @"test+thing@test.com.nz",
    @"a@b.c",
    @"A@b.c",
  ];
  for (NSString *email in validEmails) {
    XCTAssert([SPEmailAddressValidator stringIsValidEmailAddress:email]);
  }
}

- (void)testInvalidEmails {
  NSArray *invalidEmails = @[
    @"",
    @"google.com",
    @"asdf",
    @"asdg@c"
  ];
  for (NSString *email in invalidEmails) {
    XCTAssertFalse([SPEmailAddressValidator stringIsValidEmailAddress:email]);
  }
}
@end
