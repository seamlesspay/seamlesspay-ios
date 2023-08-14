//
//  SPAPIClientTests.m
//  SeamlessPayCoreTests
//
//

#import <XCTest/XCTest.h>

#import "../../SeamlessPayCore/Classes/SPAPIClient.h"

@interface SPAPIClientTests : XCTestCase
@end

@implementation SPAPIClientTests

- (void)setUp {
  NSString *SECRET_API_KEY = [[NSProcessInfo processInfo] environment][@"SECRET_API_KEY"];
  NSString *PUBLIC_API_KEY = [[NSProcessInfo processInfo] environment][@"PUBLIC_API_KEY"];

  [[SPAPIClient getSharedInstance] setSecretKey:SECRET_API_KEY
                                 publishableKey:PUBLIC_API_KEY
                                    environment:SPEnvironmentSandbox];
}

- (void)tearDown {
}

- (void)testSharedInstance {
  XCTAssertTrue([SPAPIClient getSharedInstance] != nil);
}

- (void)testListCharges {

  XCTestExpectation *documentExpectation = [self expectationWithDescription:@"testListCharges"];

  [[SPAPIClient getSharedInstance] listChargesWithParams:@{}
                                                 success:^(NSDictionary *dict) {
    XCTAssert(YES);
    [documentExpectation fulfill];
  }
                                                 failure:^(SPError *error) {
    NSLog(@"%@", error.localizedDescription);
    XCTAssert(YES);
    [documentExpectation fulfill];
  }];

  [self waitForExpectationsWithTimeout:10.0 handler:nil];
}


- (void)testCreateChargeWithToken {

  XCTestExpectation *documentExpectation = [self expectationWithDescription:@"testCreateChargeWithToken"];

  [[SPAPIClient getSharedInstance] createChargeWithToken:@"tok_visa"
                                                     cvv:@"123"
                                                 capture:YES
                                                currency:nil
                                                  amount:@"1.0"
                                               taxAmount:nil
                                               taxExempt:NO
                                                     tip:nil
                                      surchargeFeeAmount:nil
                                             description:@"test charge"
                                                   order:nil
                                                 orderId:nil
                                                poNumber:nil
                                                metadata:nil
                                              descriptor:nil
                                               entryType:nil
                                          idempotencyKey:nil
                                                 success:^(SPCharge *charge) {

    XCTAssertTrue([charge.paymentNetwork isEqualToString:@"Visa"]);
    XCTAssertTrue([charge.amount isEqualToString:@"1.00"]);

    [documentExpectation fulfill];
  }
                                                 failure:^(SPError *error) {
    NSLog(@"%@", [error localizedDescription]);
    [documentExpectation fulfill];
  }];

  [self waitForExpectationsWithTimeout:15.0 handler:nil];
}

- (void)testTokenizeWithPaymentType {

  XCTestExpectation *documentExpectation = [self expectationWithDescription:@"testTokenizeWithPaymentType"];

  SPAddress * billingAddress = [[SPAddress alloc] initWithline1:nil
                                                          line2:nil
                                                           city:nil
                                                        country:@"US"
                                                          state:nil
                                                     postalCode:@"12345"];

  [[SPAPIClient getSharedInstance] tokenizeWithPaymentType:SPPaymentTypeCreditCard
                                                   accountNumber:@"4485245870307367"
                                                   expDate:@"12/30"
                                                       cvv:@"123"
                                               accountType:nil
                                                   routing:nil
                                                       pin:nil
                                            billingAddress:billingAddress
                                                      name:@"test token"

                                                   success:^(SPPaymentMethod *paymentMethod) {

    XCTAssertTrue(paymentMethod.token != nil);
    XCTAssertTrue([paymentMethod.paymentNetwork isEqualToString:@"Visa"]);

    [documentExpectation fulfill];
  }
                                                   failure:^(SPError *error) {

    NSLog(@"%@", [error localizedDescription]);
    [documentExpectation fulfill];
  }];

  [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

@end
