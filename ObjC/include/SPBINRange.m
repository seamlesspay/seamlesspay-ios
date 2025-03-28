/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPBINRange.h"
#import "NSString+Extras.h"

@interface SPBINRange ()

@property(nonatomic) NSUInteger length;
@property(nonatomic) NSString *qRangeLow;
@property(nonatomic) NSString *qRangeHigh;
@property(nonatomic) SPCardBrand brand;

@end

@implementation SPBINRange

// MARK: - Public interface
+ (instancetype)definedBINRangeForNumber:(NSString *)number {
  NSArray *validRanges = [SPBINRange definedBINRangesForNumber:number];
  return [validRanges firstObject];
}


+ (NSArray<SPBINRange *> *)binRangesForBrand:(SPCardBrand)brand {
  return [[self allRanges] filteredArrayUsingPredicate: [NSPredicate predicateWithBlock:^BOOL(SPBINRange *range, __unused NSDictionary *bindings) {
    return range.brand == brand;
  }]];
}

+ (BOOL)isPotentialBINRangesExistForNumber:(NSString *)number {
  return [[self potentialBINRangesForNumber:number] count] > 0;
}

// MARK: - Private
+ (NSArray<SPBINRange *> *)allRanges {
  
  static NSArray<SPBINRange *> *SPBINRangeAllRanges;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSArray *ranges = @[      
      // Visa
      @[ @"4", @"4", @16, @(SPCardBrandVisa) ],
      
      // Mastercard
      @[ @"51", @"55", @16, @(SPCardBrandMasterCard) ],
      @[ @"2221", @"2720", @16, @(SPCardBrandMasterCard) ],
      
      // American Express
      @[ @"34", @"34", @15, @(SPCardBrandAmex) ],
      @[ @"37", @"37", @15, @(SPCardBrandAmex) ],
      
      // Discover
      @[ @"6011", @"6011", @16, @(SPCardBrandDiscover) ],
      @[ @"622126", @"622925", @16, @(SPCardBrandDiscover) ],
      @[ @"644", @"649", @16, @(SPCardBrandDiscover) ],
      @[ @"65", @"65", @16, @(SPCardBrandDiscover) ],
      
      // Diners Club
      @[ @"300", @"305", @14, @(SPCardBrandDinersClub) ],
      @[ @"36", @"36", @14, @(SPCardBrandDinersClub) ],
      @[ @"38", @"39", @14, @(SPCardBrandDinersClub) ],
      @[ @"309", @"309", @16, @(SPCardBrandDinersClub) ],
      
      // JCB
      @[ @"3528", @"3589", @16, @(SPCardBrandJCB) ],
      
      // UnionPay
      @[ @"62", @"62", @16, @(SPCardBrandUnionPay) ],
    ];
    
    NSMutableArray *binRanges = [NSMutableArray array];
    for (NSArray *range in ranges) {
      SPBINRange *binRange = [self.class new];
      binRange.qRangeLow = range[0];
      binRange.qRangeHigh = range[1];
      binRange.length = [range[2] unsignedIntegerValue];
      binRange.brand = [range[3] integerValue];
      [binRanges addObject:binRange];
    }
    SPBINRangeAllRanges = [binRanges copy];
  });
  return SPBINRangeAllRanges;
}

// Strict matching: only return YES if the input fully matches the BIN/IIN range.
- (BOOL)isStrictMatchForNumber:(NSString *)number {
  if (number.length < self.qRangeLow.length) {
    return NO;
  }

  NSString *prefix = [number substringToIndex:self.qRangeLow.length];

  NSComparisonResult lowerBoundComparison = [prefix compare:self.qRangeLow];
  NSComparisonResult upperBoundComparison = [prefix compare:self.qRangeHigh];

  return (lowerBoundComparison != NSOrderedAscending &&
          upperBoundComparison != NSOrderedDescending);
}

// Progressive matching: return YES if the input could still possibly match the BIN/IIN range.
- (BOOL)isPotentialMatchForNumber:(NSString *)number {
  NSUInteger matchLength = MIN(number.length, self.qRangeLow.length);

  NSString *prefix = [number substringToIndex:matchLength];
  NSString *lowPrefix = [self.qRangeLow substringToIndex:matchLength];
  NSString *highPrefix = [self.qRangeHigh substringToIndex:matchLength];

  NSComparisonResult lowerBoundComparison = [prefix compare:lowPrefix];
  NSComparisonResult upperBoundComparison = [prefix compare:highPrefix];

  return (lowerBoundComparison != NSOrderedAscending &&
          upperBoundComparison != NSOrderedDescending);
}


+ (NSArray<SPBINRange *> *)definedBINRangesForNumber:(NSString *)number {
  return [[self allRanges] filteredArrayUsingPredicate: [NSPredicate predicateWithBlock:^BOOL(SPBINRange *range, __unused NSDictionary *bindings) {
    return [range isStrictMatchForNumber:number];
  }]];
}



+ (NSArray<SPBINRange *> *)potentialBINRangesForNumber:(NSString *)number {
  return [[self allRanges] filteredArrayUsingPredicate: [NSPredicate predicateWithBlock:^BOOL(SPBINRange *range, __unused NSDictionary *bindings) {
    return [range isPotentialMatchForNumber:number];
  }]];
}

@end
