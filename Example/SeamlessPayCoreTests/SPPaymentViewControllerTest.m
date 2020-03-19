//
//  SPPaymentViewControllerTest.m
//  SeamlessPayCoreTests
//
//

#import <XCTest/XCTest.h>

#import "../../SeamlessPayCore/Classes/SPPaymentViewController.h"

@interface SPPaymentViewControllerTest : XCTestCase

@end

@implementation SPPaymentViewControllerTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testInit {
    SPPaymentViewController *pk = [[SPPaymentViewController alloc] initWithNibName:nil bundle:nil];
    XCTAssert(pk);
}

@end
