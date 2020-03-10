//
//  SPPaymentCardTextFieldTest.m
//  SeamlessPayCoreTests
//


#import <XCTest/XCTest.h>

@import SeamlessPayCore;


@interface SPPaymentCardTextField (Testing)
@property (nonatomic, readwrite, weak) UIImageView *brandImageView;
@property (nonatomic, readwrite, weak) SPFormTextField *numberField;
@property (nonatomic, readwrite, weak) SPFormTextField *expirationField;
@property (nonatomic, readwrite, weak) SPFormTextField *cvcField;
@property (nonatomic, readwrite, weak) SPFormTextField *postalCodeField;
@property (nonatomic, readonly, weak) SPFormTextField *currentFirstResponderField;
@property (nonatomic, readwrite, strong) SPPaymentCardTextFieldViewModel *viewModel;
@property (nonatomic, copy) NSNumber *focusedTextFieldForLayout;
+ (UIImage *)cvcImageForCardBrand:(SPCardBrand)cardBrand;
+ (UIImage *)brandImageForCardBrand:(SPCardBrand)cardBrand;
@end

/**
 Class that implements SPPaymentCardTextFieldDelegate and uses a block for each delegate method.
 */
@interface PaymentCardTextFieldBlockDelegate: NSObject <SPPaymentCardTextFieldDelegate>
@property (nonatomic, strong, nullable) void (^didChange)(SPPaymentCardTextField *);
@property (nonatomic, strong, nullable) void (^willEndEditingForReturn)(SPPaymentCardTextField *);
@property (nonatomic, strong, nullable) void (^didEndEditing)(SPPaymentCardTextField *);
// add more properties for other delegate methods as this test needs them
@end
@implementation PaymentCardTextFieldBlockDelegate
- (void)paymentCardTextFieldDidChange:(SPPaymentCardTextField *)textField {
    if (self.didChange) {
        self.didChange(textField);
    }
}
- (void)paymentCardTextFieldWillEndEditingForReturn:(SPPaymentCardTextField *)textField {
    if (self.willEndEditingForReturn) {
        self.willEndEditingForReturn(textField);
    }
}
- (void)paymentCardTextFieldDidEndEditing:(SPPaymentCardTextField *)textField {
    if (self.didEndEditing) {
        self.didEndEditing(textField);
    }
}
@end



@interface SPPaymentCardTextFieldTest : XCTestCase

@end

@implementation SPPaymentCardTextFieldTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testIntrinsicContentSize {
    SPPaymentCardTextField *textField = [SPPaymentCardTextField new];
    
    UIFont *iOS8SystemFont = [UIFont fontWithName:@"HelveticaNeue" size:18];
    textField.font = iOS8SystemFont;
    XCTAssertEqualWithAccuracy(textField.intrinsicContentSize.height, 44, 0.1);
    XCTAssertEqualWithAccuracy(textField.intrinsicContentSize.width, 167, 0.1);

    UIFont *iOS9SystemFont = [UIFont systemFontOfSize:18];;
    textField.font = iOS9SystemFont;
    XCTAssertEqualWithAccuracy(textField.intrinsicContentSize.height, 44, 0.1);
    XCTAssertEqualWithAccuracy(textField.intrinsicContentSize.width, 182, 0.1);

    textField.font = [UIFont fontWithName:@"Avenir" size:44];
    XCTAssertEqualWithAccuracy(textField.intrinsicContentSize.height, 62, 0.1);
    XCTAssertEqualWithAccuracy(textField.intrinsicContentSize.width, 311, 0.1);
}

- (void)testSetCard_numberUnknown {
    SPPaymentCardTextField *sut = [SPPaymentCardTextField new];
    NSString *number = @"1";
    sut.numberField.text = number;
    XCTAssertEqualObjects(sut.numberField.text, number);
    XCTAssertEqual(sut.expirationField.text.length, (NSUInteger)0);
    XCTAssertEqual(sut.cvcField.text.length, (NSUInteger)0);
    XCTAssertNil(sut.currentFirstResponderField);
}

- (void)testSettingTextUpdatesViewModelText {
    SPPaymentCardTextField *sut = [SPPaymentCardTextField new];
    sut.numberField.text = @"4242424242424242";
    XCTAssertEqualObjects(sut.viewModel.cardNumber, sut.numberField.text);

    sut.cvcField.text = @"123";
    XCTAssertEqualObjects(sut.viewModel.cvc, sut.cvcField.text);

    sut.expirationField.text = @"10/99";
    XCTAssertEqualObjects(sut.viewModel.rawExpiration, sut.expirationField.text);
    XCTAssertEqualObjects(sut.viewModel.expirationMonth, @"10");
    XCTAssertEqualObjects(sut.viewModel.expirationYear, @"99");
}

@end

@interface STPPaymentCardTextFieldUITests : XCTestCase
@property (nonatomic) UIWindow *window;
@property (nonatomic) SPPaymentCardTextField *sut;
@end

@implementation STPPaymentCardTextFieldUITests

- (void)setUp {
    [super setUp];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    SPPaymentCardTextField *textField = [[SPPaymentCardTextField alloc] initWithFrame:self.window.bounds];
    textField.postalCodeEntryEnabled = YES;
    [self.window addSubview:textField];
    XCTAssertTrue([textField.numberField canBecomeFirstResponder], @"text field cannot become first responder");
    self.sut = textField;
}

#pragma mark - UI Tests

- (void)testSetCard_allFields_whileEditingNumber {
    XCTAssertTrue([self.sut.numberField becomeFirstResponder], @"text field is not first responder");
    NSString *number = @"4242424242424242";
    NSString *cvc = @"123";
    self.sut.postalCodeField.text = @"90210";
    self.sut.numberField.text = number;
    self.sut.expirationField.text = @"10/99";
    self.sut.cvcField.text = cvc;

    XCTAssertEqualObjects(self.sut.numberField.text, number);
    XCTAssertEqualObjects(self.sut.expirationField.text, @"10/99");
    XCTAssertEqualObjects(self.sut.cvcField.text, cvc);
    XCTAssertEqualObjects(self.sut.postalCode, @"90210");
    XCTAssertFalse([self.sut.numberField isFirstResponder], @"after `setCardParams:`, if all fields are valid, should resign firstResponder");
    XCTAssertTrue(self.sut.isValid);
}

- (void)testBecomeFirstResponder {
    self.sut.postalCodeEntryEnabled = NO;
    XCTAssertTrue([self.sut canBecomeFirstResponder]);
    XCTAssertTrue([self.sut becomeFirstResponder]);
    XCTAssertTrue(self.sut.isFirstResponder);

    XCTAssertEqual(self.sut.numberField, self.sut.currentFirstResponderField);

    [self.sut becomeFirstResponder];
    XCTAssertEqual(self.sut.numberField, self.sut.currentFirstResponderField,
                   @"Repeated calls to becomeFirstResponder should not change the firstResponder");

    self.sut.numberField.text = @"4242" "4242" "4242" "4242";

    XCTAssertEqual(self.sut.expirationField, self.sut.currentFirstResponderField,
                   @"Once numberField is valid, firstResponder should move to the next field (expiration)");

    XCTAssertTrue([self.sut.cvcField becomeFirstResponder]);
    XCTAssertEqual(self.sut.cvcField, self.sut.currentFirstResponderField,
                   @"We don't block other fields from becoming firstResponder");

    XCTAssertTrue([self.sut becomeFirstResponder]);
    XCTAssertEqual(self.sut.cvcField, self.sut.currentFirstResponderField,
                   @"Calling becomeFirstResponder does not change the currentFirstResponder");

    self.sut.expirationField.text = @"10/99";
    self.sut.cvcField.text = @"123";

    XCTAssertTrue(self.sut.isValid);
    [self.sut resignFirstResponder];
    XCTAssertTrue([self.sut canBecomeFirstResponder]);
    XCTAssertTrue([self.sut becomeFirstResponder]);

    XCTAssertEqual(self.sut.cvcField, self.sut.currentFirstResponderField,
                   @"When all fields are valid, the last one should be the preferred firstResponder");

    self.sut.postalCodeEntryEnabled = YES;
    XCTAssertFalse(self.sut.isValid);

    [self.sut resignFirstResponder];
    XCTAssertTrue([self.sut becomeFirstResponder]);
    XCTAssertEqual(self.sut.postalCodeField, self.sut.currentFirstResponderField,
                   @"When postalCodeEntryEnabled=YES, it should become firstResponder after other fields are valid");

    self.sut.expirationField.text = @"";
    [self.sut resignFirstResponder];
    XCTAssertTrue([self.sut becomeFirstResponder]);
    XCTAssertEqual(self.sut.expirationField, self.sut.currentFirstResponderField,
                   @"Moves firstResponder back to expiration, because it's not valid anymore");

    self.sut.expirationField.text = @"10/99";
    self.sut.postalCodeField.text = @"90210";

    XCTAssertTrue(self.sut.isValid);
    [self.sut resignFirstResponder];
    XCTAssertTrue([self.sut becomeFirstResponder]);
    XCTAssertEqual(self.sut.postalCodeField, self.sut.currentFirstResponderField,
                   @"When all fields are valid, the last one should be the preferred firstResponder");
}


- (void)testShouldReturnCyclesThroughFields {
    PaymentCardTextFieldBlockDelegate *delegate = [PaymentCardTextFieldBlockDelegate new];
    delegate.willEndEditingForReturn = ^(__unused SPPaymentCardTextField *textField) {
        XCTFail(@"Did not expect editing to end in this test");
    };
    self.sut.delegate = delegate;

    [self.sut becomeFirstResponder];
    XCTAssertTrue(self.sut.numberField.isFirstResponder);

    XCTAssertFalse([self.sut.numberField.delegate textFieldShouldReturn:self.sut.numberField], @"shouldReturn = NO");
    XCTAssertTrue(self.sut.expirationField.isFirstResponder, @"with side effect to move 1st responder to next field");

    XCTAssertFalse([self.sut.expirationField.delegate textFieldShouldReturn:self.sut.expirationField], @"shouldReturn = NO");
    XCTAssertTrue(self.sut.cvcField.isFirstResponder, @"with side effect to move 1st responder to next field");

    XCTAssertFalse([self.sut.cvcField.delegate textFieldShouldReturn:self.sut.cvcField], @"shouldReturn = NO");
    XCTAssertTrue(self.sut.postalCodeField.isFirstResponder, @"with side effect to move 1st responder to next field");

    XCTAssertFalse([self.sut.postalCodeField.delegate textFieldShouldReturn:self.sut.postalCodeField], @"shouldReturn = NO");
    XCTAssertTrue(self.sut.numberField.isFirstResponder, @"with side effect to move 1st responder from last field to first invalid field");
}

- (void)testShouldReturnCyclesThroughFieldsWithoutPostal {
    PaymentCardTextFieldBlockDelegate *delegate = [PaymentCardTextFieldBlockDelegate new];
    delegate.willEndEditingForReturn = ^(__unused SPPaymentCardTextField *textField) {
        XCTFail(@"Did not expect editing to end in this test");
    };
    self.sut.delegate = delegate;
    self.sut.postalCodeEntryEnabled = NO;

    [self.sut becomeFirstResponder];
    XCTAssertTrue(self.sut.numberField.isFirstResponder);

    XCTAssertFalse([self.sut.numberField.delegate textFieldShouldReturn:self.sut.numberField], @"shouldReturn = NO");
    XCTAssertTrue(self.sut.expirationField.isFirstResponder, @"with side effect to move 1st responder to next field");

    XCTAssertFalse([self.sut.expirationField.delegate textFieldShouldReturn:self.sut.expirationField], @"shouldReturn = NO");
    XCTAssertTrue(self.sut.cvcField.isFirstResponder, @"with side effect to move 1st responder to next field");

    XCTAssertFalse([self.sut.cvcField.delegate textFieldShouldReturn:self.sut.cvcField], @"shouldReturn = NO");
    XCTAssertTrue(self.sut.numberField.isFirstResponder, @"with side effect to move 1st responder from last field to first invalid field");
}


@end
