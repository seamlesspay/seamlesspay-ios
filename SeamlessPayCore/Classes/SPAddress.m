/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPAddress.h"

#import <Contacts/Contacts.h>

#import "NSDictionary+Extras.h"
#import "SPCardValidator.h"
#import "SPEmailAddressValidator.h"
#import "SPFormEncoder.h"
#import "SPPaymentMethodAddress.h"
#import "SPPaymentMethodBillingDetails.h"
#import "SPPhoneNumberValidator.h"
#import "SPPostalCodeValidator.h"

NSString *stringIfHasContentsElseNil(NSString *string);

SPContactField const SPContactFieldPostalAddress = @"SPContactFieldPostalAddress";
SPContactField const SPContactFieldEmailAddress = @"SPContactFieldEmailAddress";
SPContactField const SPContactFieldPhoneNumber = @"SPContactFieldPhoneNumber";
SPContactField const SPContactFieldName = @"SPContactFieldName";

@interface SPAddress ()

@property(nonatomic, readwrite, nonnull, copy) NSDictionary *allResponseFields;
@property(nonatomic, readwrite, nullable, copy) NSString *givenName;
@property(nonatomic, readwrite, nullable, copy) NSString *familyName;

@end

@implementation SPAddress
//@synthesize additionalAPIParameters;

+ (NSDictionary *)shippingInfoForChargeWithAddress: (nullable SPAddress *)address
                                    shippingMethod: (nullable PKShippingMethod *)method {
  if (!address) {
    return nil;
  }
  NSMutableDictionary *params = [NSMutableDictionary new];
  params[@"name"] = address.name;
  params[@"phone"] = address.phone;
  params[@"carrier"] = method.label;
  // Re-use SPFormEncoder
  params[@"address"] = [SPFormEncoder dictionaryForObject:address];
  return [params copy];
}

- (NSString *)sanitizedPhoneStringFromCNPhoneNumber:
    (CNPhoneNumber *)phoneNumber {
  NSString *phone = phoneNumber.stringValue;
  if (phone) {
    phone = [SPCardValidator sanitizedNumericStringForString:phone];
  }

  return stringIfHasContentsElseNil(phone);
}

- (instancetype)initWithPaymentMethodBillingDetails:
    (SPPaymentMethodBillingDetails *)billingDetails {
  self = [super init];
  if (self) {
    _name = [billingDetails.name copy];
    _phone = [billingDetails.phone copy];
    _email = [billingDetails.email copy];
    SPPaymentMethodAddress *pmAddress = billingDetails.address;
    _line1 = [pmAddress.line1 copy];
    _line2 = [pmAddress.line2 copy];
    _city = [pmAddress.city copy];
    _state = [pmAddress.state copy];
    _postalCode = [pmAddress.postalCode copy];
    _country = [pmAddress.country copy];
  }
  return self;
}

- (instancetype)initWithline1:(NSString *)line1
                        line2:(NSString *)line2
                         city:(NSString *)city
                      country:(NSString *)country
                        state:(NSString *)state
                   postalCode:(NSString *)postalCode {
  self = [super init];
  if (self) {
    _line1 = [line1 copy];
    _line2 = [line2 copy];
    _city = [city copy];
    _state = [state copy];
    _postalCode = [postalCode copy];
    _country = [country copy];
  }
  return self;
}

- (instancetype)initWithCNContact:(CNContact *)contact {
  self = [super init];
  if (self) {
    _givenName = stringIfHasContentsElseNil(contact.givenName);
    _familyName = stringIfHasContentsElseNil(contact.familyName);
    _name = stringIfHasContentsElseNil(
      [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName]
    );
    _email = stringIfHasContentsElseNil([contact.emailAddresses firstObject].value);
    _phone = [self sanitizedPhoneStringFromCNPhoneNumber:contact.phoneNumbers.firstObject.value];
    [self setAddressFromCNPostalAddress:contact.postalAddresses.firstObject.value];
  }
  return self;
}

- (instancetype)initWithPKContact:(PKContact *)contact {
  self = [super init];
  if (self) {
    NSPersonNameComponents *nameComponents = contact.name;
    if (nameComponents) {
      _givenName = stringIfHasContentsElseNil(nameComponents.givenName);
      _familyName = stringIfHasContentsElseNil(nameComponents.familyName);
      _name = stringIfHasContentsElseNil([NSPersonNameComponentsFormatter
          localizedStringFromPersonNameComponents:nameComponents
                                            style:NSPersonNameComponentsFormatterStyleDefault
                                          options:(NSPersonNameComponentsFormatterOptions)0]);
    }
    _email = stringIfHasContentsElseNil(contact.emailAddress);
    _phone = [self sanitizedPhoneStringFromCNPhoneNumber:contact.phoneNumber];
    [self setAddressFromCNPostalAddress:contact.postalAddress];
  }
  return self;
}

- (void)setAddressFromCNPostalAddress:(CNPostalAddress *)address {
  if (address) {
    _line1 = stringIfHasContentsElseNil(address.street);
    _city = stringIfHasContentsElseNil(address.city);
    _state = stringIfHasContentsElseNil(address.state);
    _postalCode = stringIfHasContentsElseNil(address.postalCode);
    _country = stringIfHasContentsElseNil(address.ISOCountryCode.uppercaseString);
  }
}

- (PKContact *)PKContactValue {
  PKContact *contact = [PKContact new];
  NSPersonNameComponents *name = [NSPersonNameComponents new];

  name.givenName = [self firstName];
  name.familyName = [self lastName];

  contact.name = name;
  contact.emailAddress = self.email;

  CNMutablePostalAddress *address = [CNMutablePostalAddress new];

  address.street = [self street];
  address.city = self.city;
  address.state = self.state;
  address.postalCode = self.postalCode;
  address.country = self.country;
  contact.postalAddress = address;
  contact.phoneNumber = [CNPhoneNumber phoneNumberWithStringValue:self.phone];

  return contact;
}

- (NSString *)firstName {
  if (self.givenName) {
    return self.givenName;
  } else {
    NSArray<NSString *> *components = [self.name componentsSeparatedByString:@" "];
    return [components firstObject];
  }
}

- (NSString *)lastName {
  if (self.familyName) {
    return self.familyName;
  } else {
    NSArray<NSString *> *components = [self.name componentsSeparatedByString:@" "];
    NSString *firstName = [components firstObject];
    NSString *lastName = [self.name stringByReplacingOccurrencesOfString:firstName withString:@""];
    lastName = [lastName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([lastName length] == 0) {
      lastName = nil;
    }
    return lastName;
  }
}

- (NSString *)street {
  NSString *street = nil;
  if (self.line1 != nil) {
    street = [@"" stringByAppendingString:self.line1];
  }
  if (self.line2 != nil) {
    street = [@[ street ?: @"", self.line2 ] componentsJoinedByString:@" "];
  }
  return street;
}

- (BOOL)containsRequiredFields:(SPBillingAddressFields)requiredFields {
  BOOL containsFields = YES;
  switch (requiredFields) {
  case SPBillingAddressFieldsNone:
    return YES;
  case SPBillingAddressFieldsZip:
    return ([SPPostalCodeValidator
      validationStateForPostalCode:self.postalCode
                       countryCode:self.country] == SPCardValidationStateValid);
  case SPBillingAddressFieldsFull:
    return [self hasValidPostalAddress];
  case SPBillingAddressFieldsName:
    return self.name.length > 0;
  }
  return containsFields;
}

- (BOOL)containsContentForBillingAddressFields:(SPBillingAddressFields)desiredFields {
  switch (desiredFields) {
  case SPBillingAddressFieldsNone:
    return NO;
  case SPBillingAddressFieldsZip:
    return self.postalCode.length > 0;
  case SPBillingAddressFieldsFull:
    return [self hasPartialPostalAddress];
  case SPBillingAddressFieldsName:
    return self.name.length > 0;
  }

  return NO;
}

- (BOOL)containsRequiredShippingAddressFields:(NSSet<SPContactField> *)requiredFields {
  BOOL containsFields = YES;

  if ([requiredFields containsObject:SPContactFieldName]) {
    containsFields = containsFields && [self.name length] > 0;
  }
  if ([requiredFields containsObject:SPContactFieldEmailAddress]) {
    containsFields = containsFields &&
      [SPEmailAddressValidator stringIsValidEmailAddress:self.email];
  }
  if ([requiredFields containsObject:SPContactFieldPhoneNumber]) {
    containsFields = containsFields &&
      [SPPhoneNumberValidator stringIsValidPhoneNumber:self.phone forCountryCode:self.country];
  }
  if ([requiredFields containsObject:SPContactFieldPostalAddress]) {
    containsFields = containsFields && [self hasValidPostalAddress];
  }
  return containsFields;
}

- (BOOL)containsContentForShippingAddressFields:(NSSet<SPContactField> *)desiredFields {
  return (
    ([desiredFields containsObject:SPContactFieldName] && self.name.length > 0) ||
    ([desiredFields containsObject:SPContactFieldEmailAddress] && self.email.length > 0) ||
    ([desiredFields containsObject:SPContactFieldPhoneNumber] && self.phone.length > 0) ||
    ([desiredFields containsObject:SPContactFieldPostalAddress] && [self hasPartialPostalAddress])
  );
}

- (BOOL)hasValidPostalAddress {
  return (
    self.line1.length > 0 &&
    self.city.length > 0 &&
    self.country.length > 0 &&
    (self.state.length > 0 || ![self.country isEqualToString:@"US"]) &&
    ([SPPostalCodeValidator validationStateForPostalCode:self.postalCode countryCode:self.country] == SPCardValidationStateValid)
  );
}

/**
 Does this SPAddress contain any data in the postal address fields?

 If they are all empty or nil, returns NO. Even a single character in a
 single field will return YES.
 */
- (BOOL)hasPartialPostalAddress {
  return (
    self.line1.length > 0 || self.line2.length > 0 ||
    self.city.length > 0 || self.country.length > 0 ||
    self.state.length > 0 || self.postalCode.length > 0
  );
}

#pragma mark SPFormEncodable

+ (nullable NSString *)rootObjectName {
  return nil;
}

+ (NSDictionary *)propertyNamesToFormFieldNamesMapping {
  // Paralleling `decodedObjectFromAPIResponse:`, *only* the 6 address fields
  // are encoded If this changes,
  // shippingInfoForChargeWithAddress:shippingMethod: might break
  return @{
    NSStringFromSelector(@selector(line1)) : @"line1",
    NSStringFromSelector(@selector(line2)) : @"line2",
    NSStringFromSelector(@selector(city)) : @"city",
    NSStringFromSelector(@selector(state)) : @"state",
    NSStringFromSelector(@selector(postalCode)) : @"postal_code",
    NSStringFromSelector(@selector(country)) : @"country",
  };
}

#pragma mark NSCopying

- (id)copyWithZone:(__unused NSZone *)zone {
  SPAddress *copyAddress = [self.class new];

  // Name might be stored as full name in _name, or split between given/family
  // name access ivars directly and explicitly copy the instances.
  copyAddress->_name = [self->_name copy];
  copyAddress->_givenName = [self->_givenName copy];
  copyAddress->_familyName = [self->_familyName copy];

  copyAddress.line1 = self.line1;
  copyAddress.line2 = self.line2;
  copyAddress.city = self.city;
  copyAddress.state = self.state;
  copyAddress.postalCode = self.postalCode;
  copyAddress.country = self.country;

  copyAddress.phone = self.phone;
  copyAddress.email = self.email;

  copyAddress.allResponseFields = self.allResponseFields;

  return copyAddress;
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *params = [ @{
      @"line1" : _line1  ?: @"",
      @"line2" : _line2 ?: @"",
      @"city" : _city ?: @"",
      @"country" : _country ?: @"",
      @"state" : _state ?: @"",
      @"postalCode" : _postalCode ?: @"",
    } mutableCopy];
    
    NSArray *keysForNullValues = [params allKeysForObject:@""];
    keysForNullValues = [keysForNullValues arrayByAddingObjectsFromArray: [params allKeysForObject:[NSNull null]]];
    [params removeObjectsForKeys:keysForNullValues];
    
    return [params count] !=0 ? params : nil;
}

@end

#pragma mark -

NSString *stringIfHasContentsElseNil(NSString *string) {
  if (string.length > 0) {
    return string;
  } else {
    return nil;
  }
}
