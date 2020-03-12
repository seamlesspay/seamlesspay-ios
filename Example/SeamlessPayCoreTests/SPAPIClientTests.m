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
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    NSString *SECRET_API_KEY = [[NSProcessInfo processInfo] environment][@"SECRET_API_KEY"];
    NSString *PUBLIC_API_KEY = [[NSProcessInfo processInfo] environment][@"PUBLIC_API_KEY"];
    
    [[SPAPIClient getSharedInstance] setSecretKey: SECRET_API_KEY
                                   publishableKey: PUBLIC_API_KEY
                                          sandbox: YES];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testSharedInstance {
    XCTAssertTrue([SPAPIClient getSharedInstance] != nil);
}

- (void)testListCharges {
    
    XCTestExpectation *documentExpectation = [self expectationWithDescription:@"testListCharges"];
    
    [[SPAPIClient getSharedInstance]
     listChargesWithParams:@{}
     success:^(NSDictionary *dict) {
        XCTAssert(YES);
        [documentExpectation fulfill];
    }
     failure:^(SPError *error) {
        NSString *errMessage = [error.localizedDescription componentsSeparatedByString:@"\n"][1];
        XCTAssertTrue([errMessage isEqualToString:@"Message=Access denied using publishable API key authentication"]);
        [documentExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}


- (void)testCreateChargeWithToken {
    
    XCTestExpectation *documentExpectation = [self expectationWithDescription:@"testCreateChargeWithToken"];
    
    [[SPAPIClient getSharedInstance]
     createChargeWithToken:@"tok_visa"
     cvv:@"123"
     capture: YES
     currency:nil
     amount:@"1.0"
     taxAmount:nil
     taxExempt: NO
     tip:nil
     surchargeFeeAmount:nil
     scheduleIndicator:nil
     description:@"test charge"
     order:nil
     orderId:nil
     poNumber:nil
     metadata:nil
     descriptor:nil
     txnEnv:nil
     achType:nil
     credentialIndicator:nil
     transactionInitiation:nil
     idempotencyKey:nil
     needSendReceipt: NO
     success:^(SPCharge *charge) {
        
        XCTAssertTrue([charge.status isEqualToString:@"CAPTURED"]);
        XCTAssertTrue([charge.cardBrand isEqualToString:@"Visa"]);
        XCTAssertTrue([charge.amount isEqualToString:@"1.00"]);
          
        [documentExpectation fulfill];
    }
     failure:^(SPError *error) {
        NSLog(@"%@", [error localizedDescription]);
        [documentExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testCreatePaymentMethodWithType {
    
    XCTestExpectation *documentExpectation = [self expectationWithDescription:@"testCreatePaymentMethodWithType"];
    
    [[SPAPIClient getSharedInstance]
     createPaymentMethodWithType:@"CREDIT_CARD"
     account:@"4242424242424242"
     expDate:@"02/30"
     cvv:@"123"
     accountType:nil
     routing:nil
     pin:nil
     address:nil
     address2:nil
     city:nil
     country:nil
     state:nil
     zip:@"12345"
     company:nil
     email:nil
     phone:nil
     name:@"test token"
     nickname:nil
     verification : TRUE
     success:^(SPPaymentMethod *paymentMethod) {
        
        XCTAssertTrue(paymentMethod.token != nil);
        XCTAssertTrue([paymentMethod.cardBrand isEqualToString:@"Visa"]);
        
        [documentExpectation fulfill];
    }
     failure:^(SPError *error) {
        
        NSLog(@"%@", [error localizedDescription]);
        [documentExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}



//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
