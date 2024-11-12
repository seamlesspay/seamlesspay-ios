import XCTest
@testable import SeamlessPay
@testable import SeamlessPayObjC

class SingleLineCardFormTests_Interface: XCTestCase, CardFormDelegate {
  var cardForm: SingleLineCardForm!

  override func setUp() {
    super.setUp()
    cardForm = SingleLineCardForm()
    cardForm.delegate = self
  }

  override func tearDown() {
    cardForm = nil
    super.tearDown()
  }

  func testInitialState() {
    XCTAssertNotNil(cardForm.brandImage)
    XCTAssertFalse(cardForm.isValid)
    XCTAssertTrue(cardForm.isEnabled)
  }

  func testClear() {
    cardForm.viewModel.cardNumber = "4111111111111111"
    cardForm.viewModel.rawExpiration = "12/25"
    cardForm.viewModel.cvc = "123"
    cardForm.viewModel.postalCode = "1234"

    cardForm.clear()

    XCTAssertEqual(cardForm.viewModel.cardNumber, .none)
    XCTAssertEqual(cardForm.viewModel.rawExpiration, .init())
    XCTAssertEqual(cardForm.viewModel.cvc, .none)
    XCTAssertEqual(cardForm.viewModel.postalCode, .none)
  }

  func testFieldsRectForBounds() {
    let testBounds = CGRect(x: 0, y: 0, width: 300, height: 50)
    let fieldsRect = cardForm.fieldsRect(forBounds: testBounds)
    XCTAssertFalse(fieldsRect.equalTo(CGRect.zero))
    XCTAssertTrue(testBounds.contains(fieldsRect))
  }

  func testEnableDisable() {
    XCTAssertTrue(cardForm.isEnabled)
    cardForm.isEnabled = false
    XCTAssertFalse(cardForm.isEnabled)
    cardForm.isEnabled = true
    XCTAssertTrue(cardForm.isEnabled)
  }

  func testDelegateIsSet() {
    XCTAssertTrue(cardForm.delegate === self)
  }
}
