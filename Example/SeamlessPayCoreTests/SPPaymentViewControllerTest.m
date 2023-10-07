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

- (void)testInit {
  SPPaymentViewController *pk = [[SPPaymentViewController alloc] initWithNibName:nil bundle:nil];
  XCTAssert(pk);
}

@end
