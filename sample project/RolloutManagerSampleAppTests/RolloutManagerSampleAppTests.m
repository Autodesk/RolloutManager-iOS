//
//  RolloutManagerSampleAppTests.m
//  RolloutManagerSampleAppTests
//
//  Created by Asaf Shveki on 13/11/2016.
//  Copyright © 2016 Autodesk. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "ADRolloutManager.h"

@interface RolloutManagerSampleAppTests : XCTestCase

@property (nonatomic, strong) NSUserDefaults* tempUserDefaults;

@end

@implementation RolloutManagerSampleAppTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    [super tearDown];
}

- (void)testVariantByExperimentId_oneVariantIsOff_shouldReturnActiveExperiment {
    
    // Arrange
    ADRolloutManager* tempRolloutManager = [ADRolloutManager new];
    
    NSDictionary* currentData = @{@"Exp01":@{@"Settings":@{@"is_sticky":@(NO)},
                                             @"Variants":@{@"Opt01":@(0),
                                                           @"Opt02":@(1)}}};

    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    OCMStub([mockUserDefaults objectForKey:[OCMArg any]]).andReturn(nil);

    // Act
    [tempRolloutManager setupWithConfiguration:currentData userDefaults:mockUserDefaults userPreferedLanguage:@"en" userCurrentLocale:[NSLocale currentLocale]];
    NSString* returnValue = [tempRolloutManager variantByExperimentId:@"Exp01" defaultResult:@"Exp01_Opt01" customConditions:nil];
    
    // Assert
    XCTAssertTrue([returnValue isEqualToString:@"Exp01_Opt02"]);
}

- (void)testVariantByExperimentId_manyExperimentsExisted_shouldReturnActiveExperiment {
    
    // Arrange
    ADRolloutManager* tempRolloutManager = [ADRolloutManager new];
    
    NSDictionary* currentData = @{@"Exp01":@{@"Settings":@{@"is_sticky":@(NO)},
                                             @"Variants":@{@"Opt01":@(0),
                                                           @"Opt02":@(1)}},
                                  @"Exp02":@{@"Settings":@{@"is_sticky":@(NO)},
                                             @"Variants":@{@"Opt01":@(0),
                                                           @"Opt02":@(1)}}};
    
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    OCMStub([mockUserDefaults objectForKey:[OCMArg any]]).andReturn(nil);
    
    // Act
    [tempRolloutManager setupWithConfiguration:currentData userDefaults:mockUserDefaults  userPreferedLanguage:@"en" userCurrentLocale:[NSLocale currentLocale]];
    NSString* returnValue = [tempRolloutManager variantByExperimentId:@"Exp02" defaultResult:@"Exp01_Opt01" customConditions:nil];
    
    // Assert
    XCTAssertTrue([returnValue isEqualToString:@"Exp02_Opt02"]);
}

- (void)testVariantByExperimentId_noExperiment_shouldReturnDefaultValue {
    
    // Arrange
    ADRolloutManager* tempRolloutManager = [ADRolloutManager new];
    
    NSDictionary* currentData = @{@"Exp01":@{@"Settings":@{@"is_sticky":@(NO)},
                                             @"Variants":@{@"Opt01":@(1),
                                                           @"Opt02":@(0)}}};
    
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    OCMStub([mockUserDefaults objectForKey:[OCMArg any]]).andReturn(nil);
    
    // Act
    [tempRolloutManager setupWithConfiguration:currentData userDefaults:mockUserDefaults userPreferedLanguage:@"en" userCurrentLocale:[NSLocale currentLocale]];
    NSString* returnValue = [tempRolloutManager variantByExperimentId:@"Exp02" defaultResult:@"Exp01_Opt01" customConditions:nil];
    
    // Assert
    XCTAssertTrue([returnValue isEqualToString:@"Exp01_Opt01"]);
}

- (void)testVariantByExperimentId_oldValueExistedAndAllocationHasntChanged_shouldReturnOldValue {
    
    // Arrange
    ADRolloutManager* tempRolloutManager = [ADRolloutManager new];
    
    NSDictionary* currentData = @{@"Exp01":@{@"Settings":@{@"is_sticky":@(NO)},
                                             @"Variants":@{@"Opt01":@(1),
                                                           @"Opt02":@(0)}}};

    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    OCMStub([mockUserDefaults objectForKey:@"Exp01_ExperimentRandomNumber"]).andReturn(@(0.44));
    OCMStub([mockUserDefaults objectForKey:@"Exp01_ExperimentResult"]).andReturn(@"Exp01_Opt01");
    OCMStub([mockUserDefaults dictionaryRepresentation]).andReturn((@{@"Exp01_ExperimentResult":@"", @"Exp01_ExperimentRandomNumber":@""}));
    
    // Act
    [tempRolloutManager setupWithConfiguration:currentData userDefaults:mockUserDefaults userPreferedLanguage:@"en" userCurrentLocale:[NSLocale currentLocale]];
    NSString* returnValue = [tempRolloutManager variantByExperimentId:@"Exp01" defaultResult:@"Exp01_Opt01" customConditions:nil];
    
    // Assert
    XCTAssertTrue([returnValue isEqualToString:@"Exp01_Opt01"]);
}

- (void)testVariantByExperimentId_oldValueExistedButAllocationHasChanged_shouldReturnOtherValue {
    
    // Arrange
    ADRolloutManager* tempRolloutManager = [ADRolloutManager new];
    
    NSDictionary* currentData = @{@"Exp01":@{@"Settings":@{@"is_sticky":@(NO)},
                                             @"Variants":@{@"Opt01":@(0),
                                                           @"Opt02":@(1)}}};
    
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    OCMStub([mockUserDefaults objectForKey:@"Exp01_ExperimentRandomNumber"]).andReturn(@(0.44));
    OCMStub([mockUserDefaults objectForKey:@"Exp01_ExperimentResult"]).andReturn(@"Exp01_Opt01");
    OCMStub([mockUserDefaults dictionaryRepresentation]).andReturn((@{@"Exp01_ExperimentResult":@"", @"Exp01_ExperimentRandomNumber":@""}));
    
    // Act
    [tempRolloutManager setupWithConfiguration:currentData userDefaults:mockUserDefaults userPreferedLanguage:@"en" userCurrentLocale:[NSLocale currentLocale]];
    NSString* returnValue = [tempRolloutManager variantByExperimentId:@"Exp01" defaultResult:@"Exp01_Opt01" customConditions:nil];
    
    // Assert
    XCTAssertTrue([returnValue isEqualToString:@"Exp01_Opt02"]);
}

- (void)testVariantByExperimentId_oldValueExistedAndAllocationHasntChangedButSticky_shouldReturnOldValue {
    
    // Arrange
    ADRolloutManager* tempRolloutManager = [ADRolloutManager new];
    
    NSDictionary* currentData = @{@"Exp01":@{@"Settings":@{@"is_sticky":@(YES)},
                                             @"Variants":@{@"Opt01":@(1),
                                                           @"Opt02":@(0)}}};
    
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    OCMStub([mockUserDefaults objectForKey:@"Exp01_ExperimentRandomNumber"]).andReturn(@(0.44));
    OCMStub([mockUserDefaults objectForKey:@"Exp01_ExperimentResult"]).andReturn(@"Exp01_Opt01");
    OCMStub([mockUserDefaults dictionaryRepresentation]).andReturn((@{@"Exp01_ExperimentResult":@"", @"Exp01_ExperimentRandomNumber":@""}));
    
    // Act
    [tempRolloutManager setupWithConfiguration:currentData userDefaults:mockUserDefaults userPreferedLanguage:@"en" userCurrentLocale:[NSLocale currentLocale]];
    NSString* returnValue = [tempRolloutManager variantByExperimentId:@"Exp01" defaultResult:@"Exp01_Opt01" customConditions:nil];
    
    // Assert
    XCTAssertTrue([returnValue isEqualToString:@"Exp01_Opt01"]);
}

- (void)testVariantByExperimentId_oldValueExistedButAllocationHasChangedAndSticky_shouldReturnOldValue {
    
    // Arrange
    ADRolloutManager* tempRolloutManager = [ADRolloutManager new];
    
    NSDictionary* currentData = @{@"Exp01":@{@"Settings":@{@"is_sticky":@(YES)},
                                             @"Variants":@{@"Opt01":@(0),
                                                           @"Opt02":@(1)}}};
    
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    OCMStub([mockUserDefaults objectForKey:@"Exp01_ExperimentRandomNumber"]).andReturn(@(0.44));
    OCMStub([mockUserDefaults objectForKey:@"Exp01_ExperimentResult"]).andReturn(@"Exp01_Opt01");
    OCMStub([mockUserDefaults dictionaryRepresentation]).andReturn((@{@"Exp01_ExperimentResult":@"", @"Exp01_ExperimentRandomNumber":@""}));
    
    // Act
    [tempRolloutManager setupWithConfiguration:currentData userDefaults:mockUserDefaults userPreferedLanguage:@"en" userCurrentLocale:[NSLocale currentLocale]];
    NSString* returnValue = [tempRolloutManager variantByExperimentId:@"Exp01" defaultResult:@"Exp01_Opt01" customConditions:nil];
    
    // Assert
    XCTAssertTrue([returnValue isEqualToString:@"Exp01_Opt01"]);
}

- (void)testVariantByExperimentId_oldValueExistedVariantHasRemovedAndSticky_shouldReturnDifferentValue {
    
    // Arrange
    ADRolloutManager* firstRolloutManager = [ADRolloutManager new];
    ADRolloutManager* secondRolloutManager = [ADRolloutManager new];
    
    NSDictionary* firstData = @{@"Exp01":@{@"Settings":@{@"is_sticky":@(YES)},
                                           @"Variants":@{@"Opt01":@(1),
                                                         @"Opt02":@(0),
                                                         @"Opt03":@(0)}}};
    
    NSDictionary* secondData = @{@"Exp01":@{@"Settings":@{@"is_sticky":@(YES)},
                                            @"Variants":@{@"Opt02":@(1),
                                                          @"Opt03":@(0)}}};
    
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    OCMStub([mockUserDefaults objectForKey:@"Exp01_ExperimentRandomNumber"]).andReturn(@(0.44));
    OCMStub([mockUserDefaults objectForKey:@"Exp01_ExperimentResult"]).andReturn(@"Exp01_Opt01");
    OCMStub([mockUserDefaults dictionaryRepresentation]).andReturn((@{@"Exp01_ExperimentResult":@"", @"Exp01_ExperimentRandomNumber":@""}));
    
    // Act
    [firstRolloutManager setupWithConfiguration:firstData userDefaults:mockUserDefaults userPreferedLanguage:@"en" userCurrentLocale:[NSLocale currentLocale]];
    NSString* returnValue1 = [firstRolloutManager variantByExperimentId:@"Exp01" defaultResult:@"Exp01_Opt01" customConditions:nil];
    
    [secondRolloutManager setupWithConfiguration:secondData userDefaults:mockUserDefaults userPreferedLanguage:@"en" userCurrentLocale:[NSLocale currentLocale]];
    NSString* returnValue2 = [secondRolloutManager variantByExperimentId:@"Exp01" defaultResult:@"Exp01_Opt01" customConditions:nil];
    
    
    // Assert
    XCTAssertTrue([returnValue1 isEqualToString:@"Exp01_Opt01"]);
    XCTAssertTrue([returnValue2 isEqualToString:@"Exp01_Opt02"]);
}

- (void)testVariantByExperimentId_configWithNilchecks_shouldReturnDefaultValue {
    
    // Arrange
    ADRolloutManager* tempRolloutManager = [ADRolloutManager new];
    
    // Act
    [tempRolloutManager setupWithConfiguration:nil userDefaults:nil userPreferedLanguage:nil userCurrentLocale:nil];
    NSString* returnValue = [tempRolloutManager variantByExperimentId:@"Exp01" defaultResult:@"Exp01_Opt01" customConditions:nil];
    
    // Assert
    XCTAssertTrue([returnValue isEqualToString:@"Exp01_Opt01"]);
}

- (void)testVariantByExperimentId_nilExperimentID_shouldReturnDefaultValue {
    
    // Arrange
    ADRolloutManager* tempRolloutManager = [ADRolloutManager new];
    
    // Act
    [tempRolloutManager setupWithConfiguration:nil userDefaults:nil userPreferedLanguage:nil userCurrentLocale:nil];
    NSString* returnValue = [tempRolloutManager variantByExperimentId:nil defaultResult:@"Exp01_Opt01" customConditions:nil];
    
    // Assert
    XCTAssertTrue([returnValue isEqualToString:@"Exp01_Opt01"]);
}

- (void)testVariantByExperimentId_deviceLanguageIsInList_shouldReturnFirstOption {
    
    // Arrange
    ADRolloutManager* tempRolloutManager = [ADRolloutManager new];
    
    NSDictionary* currentData = @{@"Exp01":@{@"Settings":@{@"is_sticky":@(NO),
                                                           @"supported_languages":@"En,hr,he"},
                                             @"Variants":@{@"Opt01":@(100),
                                                           @"Opt02":@(0)}}};
    
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    OCMStub([mockUserDefaults objectForKey:[OCMArg any]]).andReturn(nil);
    
    // Act
    [tempRolloutManager setupWithConfiguration:currentData userDefaults:mockUserDefaults userPreferedLanguage:@"en" userCurrentLocale:[NSLocale currentLocale]];
    NSString* returnValue = [tempRolloutManager variantByExperimentId:@"Exp01" defaultResult:@"Exp01_Opt08" customConditions:nil];
    
    // Assert
    XCTAssertTrue([returnValue isEqualToString:@"Exp01_Opt01"]);
}

- (void)testVariantByExperimentId_deviceLanguageWithSignIsInList_shouldReturnFirstOption {
    
    // Arrange
    ADRolloutManager* tempRolloutManager = [ADRolloutManager new];
    
    NSDictionary* currentData = @{@"Exp01":@{@"Settings":@{@"is_sticky":@(NO),
                                                           @"supported_languages":@"En,hr,he,en"},
                                             @"Variants":@{@"Opt01":@(100),
                                                           @"Opt02":@(0)}}};
    
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    OCMStub([mockUserDefaults objectForKey:[OCMArg any]]).andReturn(nil);
    
    // Act
    [tempRolloutManager setupWithConfiguration:currentData userDefaults:mockUserDefaults userPreferedLanguage:@"en-UK" userCurrentLocale:[NSLocale currentLocale]];
    NSString* returnValue = [tempRolloutManager variantByExperimentId:@"Exp01" defaultResult:@"Exp01_Opt08" customConditions:nil];
    
    // Assert
    XCTAssertTrue([returnValue isEqualToString:@"Exp01_Opt01"]);
}

- (void)testVariantByExperimentId_deviceLanguageIsNotInList_shouldReturnDefaultValue {
    
    // Arrange
    ADRolloutManager* tempRolloutManager = [ADRolloutManager new];
    
    NSDictionary* currentData = @{@"Exp01":@{@"Settings":@{@"is_sticky":@(NO),
                                                           @"supported_languages":@"hr,he"},
                                             @"Variants":@{@"Opt01":@(100),
                                                           @"Opt02":@(0)}}};
    
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    OCMStub([mockUserDefaults objectForKey:[OCMArg any]]).andReturn(nil);
    
    // Act
    [tempRolloutManager setupWithConfiguration:currentData userDefaults:mockUserDefaults userPreferedLanguage:@"en" userCurrentLocale:[NSLocale currentLocale]];
    NSString* returnValue = [tempRolloutManager variantByExperimentId:@"Exp01" defaultResult:@"Exp01_Opt08" customConditions:nil];
    
    // Assert
    XCTAssertTrue([returnValue isEqualToString:@"Exp01_Opt08"]);
}

- (void)testVariantByExperimentId_supportedLanguagesConfigurationDoesNotExist_shouldReturnOption1 {
    
    // Arrange
    ADRolloutManager* tempRolloutManager = [ADRolloutManager new];
    
    NSDictionary* currentData = @{@"Exp01":@{@"Settings":@{@"is_sticky":@(NO)},
                                             @"Variants":@{@"Opt01":@(100),
                                                           @"Opt02":@(0)}}};
    
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    OCMStub([mockUserDefaults objectForKey:[OCMArg any]]).andReturn(nil);
    
    // Act
    [tempRolloutManager setupWithConfiguration:currentData userDefaults:mockUserDefaults userPreferedLanguage:@"en" userCurrentLocale:[NSLocale currentLocale]];
    NSString* returnValue = [tempRolloutManager variantByExperimentId:@"Exp01" defaultResult:@"Exp01_Opt08" customConditions:nil];
    
    // Assert
    XCTAssertTrue([returnValue isEqualToString:@"Exp01_Opt01"]);
}

- (void)testVariantByExperimentId_userCountryIsInList_shouldReturnFirstOption {
    
    // Arrange
    ADRolloutManager* tempRolloutManager = [ADRolloutManager new];
    
    NSDictionary* currentData = @{@"Exp01":@{@"Settings":@{@"is_sticky":@(NO),
                                                           @"supported_countries":@"us,il,sp"},
                                             @"Variants":@{@"Opt01":@(100),
                                                           @"Opt02":@(0)}}};
    
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    OCMStub([mockUserDefaults objectForKey:[OCMArg any]]).andReturn(nil);
    
    id mockNSLocale = OCMClassMock([NSLocale class]);
    OCMStub([mockNSLocale objectForKey:NSLocaleCountryCode]).andReturn(@"IL");
    
    // Act
    [tempRolloutManager setupWithConfiguration:currentData userDefaults:mockUserDefaults userPreferedLanguage:@"en" userCurrentLocale:mockNSLocale];
    NSString* returnValue = [tempRolloutManager variantByExperimentId:@"Exp01" defaultResult:@"Exp01_Opt08" customConditions:nil];
    
    // Assert
    XCTAssertTrue([returnValue isEqualToString:@"Exp01_Opt01"]);
}

- (void)testVariantByExperimentId_userCountryIsNotInList_shouldReturnDefaultValue {
    
    // Arrange
    ADRolloutManager* tempRolloutManager = [ADRolloutManager new];
    
    NSDictionary* currentData = @{@"Exp01":@{@"Settings":@{@"is_sticky":@(NO),
                                                           @"supported_countries":@"de,po"},
                                             @"Variants":@{@"Opt01":@(100),
                                                           @"Opt02":@(0)}}};
    
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    OCMStub([mockUserDefaults objectForKey:[OCMArg any]]).andReturn(nil);
    
    id mockNSLocale = OCMClassMock([NSLocale class]);
    OCMStub([mockNSLocale objectForKey:NSLocaleCountryCode]).andReturn(@"IL");
    
    // Act
    [tempRolloutManager setupWithConfiguration:currentData userDefaults:mockUserDefaults userPreferedLanguage:@"en" userCurrentLocale:mockNSLocale];
    NSString* returnValue = [tempRolloutManager variantByExperimentId:@"Exp01" defaultResult:@"Exp01_Opt08" customConditions:nil];
    
    // Assert
    XCTAssertTrue([returnValue isEqualToString:@"Exp01_Opt08"]);
}

- (void)testVariantByExperimentId_supportedCountriesConfigurationDoesNotExist_shouldReturnOption1 {
    
    // Arrange
    ADRolloutManager* tempRolloutManager = [ADRolloutManager new];
    
    NSDictionary* currentData = @{@"Exp01":@{@"Settings":@{@"is_sticky":@(NO)},
                                             @"Variants":@{@"Opt01":@(100),
                                                           @"Opt02":@(0)}}};
    
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    OCMStub([mockUserDefaults objectForKey:[OCMArg any]]).andReturn(nil);
    
    id mockNSLocale = OCMClassMock([NSLocale class]);
    OCMStub([mockNSLocale objectForKey:NSLocaleCountryCode]).andReturn(@"IL");
    
    // Act
    [tempRolloutManager setupWithConfiguration:currentData userDefaults:mockUserDefaults userPreferedLanguage:@"en" userCurrentLocale:mockNSLocale];
    NSString* returnValue = [tempRolloutManager variantByExperimentId:@"Exp01" defaultResult:@"Exp01_Opt08" customConditions:nil];
    
    // Assert
    XCTAssertTrue([returnValue isEqualToString:@"Exp01_Opt01"]);
}

- (void)testRemoveExperimentDrawIfExisted_experimentExisted_shouldRemoveExperiment {
    
    // Arrange
    ADRolloutManager* tempRolloutManager = [ADRolloutManager new];
    
    NSDictionary* currentData = @{@"Exp01":@{@"Settings":@{@"is_sticky":@(YES)},
                                             @"Variants":@{@"Opt01":@(0),
                                                           @"Opt02":@(100)}}};
    
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    OCMStub([mockUserDefaults objectForKey:@"Exp01_ExperimentRandomNumber"]).andReturn(@(0.44));
    OCMStub([mockUserDefaults objectForKey:@"Exp01_ExperimentResult"]).andReturn(@"Exp01_Opt01");
    OCMStub([mockUserDefaults dictionaryRepresentation]).andReturn((@{@"Exp01_ExperimentResult":@"", @"Exp01_ExperimentRandomNumber":@""}));
    
    id mockNSLocale = OCMClassMock([NSLocale class]);
    OCMStub([mockNSLocale objectForKey:NSLocaleCountryCode]).andReturn(@"IL");
    
    // Act
    [tempRolloutManager setupWithConfiguration:currentData userDefaults:mockUserDefaults userPreferedLanguage:@"en" userCurrentLocale:[NSLocale currentLocale]];
    NSString* returnValue = [tempRolloutManager variantByExperimentId:@"Exp01" defaultResult:@"Exp01_Opt08" customConditions:nil];
    [tempRolloutManager removeExperimentDrawIfExisted:@"Exp01"];
    
    // Assert
    XCTAssertTrue([returnValue isEqualToString:@"Exp01_Opt01"]);
    OCMVerify([mockUserDefaults removeObjectForKey:@"Exp01_ExperimentResult"]);
}

- (void)testRemoveExperimentDrawIfExisted_experimentDoesNotExisted_shouldDoNothing {
    
    // Arrange
    ADRolloutManager* tempRolloutManager = [ADRolloutManager new];
    
    NSDictionary* currentData = @{@"Exp01":@{@"Settings":@{@"is_sticky":@(NO)},
                                             @"Variants":@{@"Opt01":@(100),
                                                           @"Opt02":@(0)}}};
    
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    OCMStub([mockUserDefaults objectForKey:@"Exp01_ExperimentRandomNumber"]).andReturn(@(0.44));
    OCMStub([mockUserDefaults objectForKey:@"Exp01_ExperimentResult"]).andReturn(@"Exp01_Opt01");
    OCMStub([mockUserDefaults dictionaryRepresentation]).andReturn((@{@"Exp08_ExperimentResult":@"", @"Exp08_ExperimentRandomNumber":@""}));
    
    id mockNSLocale = OCMClassMock([NSLocale class]);
    OCMStub([mockNSLocale objectForKey:NSLocaleCountryCode]).andReturn(@"IL");
    
    // Act
    [tempRolloutManager setupWithConfiguration:currentData userDefaults:mockUserDefaults userPreferedLanguage:@"en" userCurrentLocale:[NSLocale currentLocale]];
    NSString* returnValue = [tempRolloutManager variantByExperimentId:@"Exp01" defaultResult:@"Exp01_Opt08" customConditions:nil];
    [tempRolloutManager removeExperimentDrawIfExisted:@"Exp01"];

    // Assert
    XCTAssertTrue([returnValue isEqualToString:@"Exp01_Opt01"]);
}

- (void)testVariantByExperimentId_customeConditionsAreTrue_shouldReturnActiveVariant {
    
    // Arrange
    ADRolloutManager* tempRolloutManager = [ADRolloutManager new];
    
    NSDictionary* currentData = @{@"Exp01":@{@"Settings":@{@"is_sticky":@(NO)},
                                             @"Variants":@{@"Opt01":@(1),
                                                           @"Opt02":@(0)}}};
    
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    OCMStub([mockUserDefaults objectForKey:[OCMArg any]]).andReturn(nil);
    
    // Act
    [tempRolloutManager setupWithConfiguration:currentData userDefaults:mockUserDefaults userPreferedLanguage:@"en" userCurrentLocale:[NSLocale currentLocale]];
    NSString* returnValue = [tempRolloutManager variantByExperimentId:@"Exp01" defaultResult:@"Exp01_Opt09" customConditions:^BOOL{
        return YES;
    }];
    
    // Assert
    XCTAssertTrue([returnValue isEqualToString:@"Exp01_Opt01"]);
}

- (void)testVariantByExperimentId_customeConditionsAreFalse_shouldReturnDefaultValue {
    
    // Arrange
    ADRolloutManager* tempRolloutManager = [ADRolloutManager new];
    
    NSDictionary* currentData = @{@"Exp01":@{@"Settings":@{@"is_sticky":@(NO)},
                                             @"Variants":@{@"Opt01":@(1),
                                                           @"Opt02":@(0)}}};
    
    id mockUserDefaults = OCMClassMock([NSUserDefaults class]);
    OCMStub([mockUserDefaults objectForKey:[OCMArg any]]).andReturn(nil);
    
    // Act
    [tempRolloutManager setupWithConfiguration:currentData userDefaults:mockUserDefaults userPreferedLanguage:@"en" userCurrentLocale:[NSLocale currentLocale]];
    NSString* returnValue = [tempRolloutManager variantByExperimentId:@"Exp01" defaultResult:@"Exp01_Opt09" customConditions:^BOOL{
        return NO;
    }];
    
    // Assert
    XCTAssertTrue([returnValue isEqualToString:@"Exp01_Opt09"]);
}

@end
