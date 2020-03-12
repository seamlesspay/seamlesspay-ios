//
//  SPEmailAddressValidatorTest.m
//  SeamlessPayCoreTests
//
//  Created by Oleksiy Shortov on 3/9/20.
//  Copyright © 2020 info@seamlesspay.com. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "../../SeamlessPayCore/Classes/SPEmailAddressValidator.h"


@interface SPEmailAddressValidatorTest : XCTestCase

@end

@implementation SPEmailAddressValidatorTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

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
