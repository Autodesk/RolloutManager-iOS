//
//  ADRolloutManager.m
//  AD360Helpers-iOS
//
//  Created by Itai Shayovitz on 26/09/2016.
//  Copyright © 2016 Autodesk. All rights reserved.
//

#import "ADRolloutManager.h"
#import "ADRolloutManagerDrawInstance.h"

NSString* const FORMAT_FOR_EXPERIMENT_NUMBER_KEY = @"%@_ExperimentNumberKey"; // Support old versions

NSString* const FORMAT_FOR_SAVED_RESULT_PER_EXPERIMENT = @"%@_ExperimentResult";
NSString* const FORMAT_FOR_SAVED_RANDOM_PER_EXPERIMENT = @"%@_ExperimentRandomNumber";

NSString* const EXPERIMENT_DICTIONARY_STRUCTURE_VARIANTS = @"Variants";
NSString* const EXPERIMENT_DICTIONARY_STRUCTURE_SETTINGS = @"Settings";

@interface ADRolloutManager ()

@property (nonatomic, strong) NSUserDefaults* userDefaults;
@property (nonatomic, strong) NSDictionary* confDictionary;
@property (nonatomic, strong) NSMutableDictionary* experimentsAndTotalSumDictionary;
@property (nonatomic, strong) NSString* userPreferedLanguage;
@property (nonatomic, strong) NSLocale* userCurrentLocale;
@end

@implementation ADRolloutManager

- (void)setupWithConfiguration:(NSDictionary*)confDictionary
{
    [self setupWithConfiguration:confDictionary
                    userDefaults:[NSUserDefaults standardUserDefaults]
            userPreferedLanguage:[[NSLocale preferredLanguages] objectAtIndex:0]
               userCurrentLocale:[NSLocale currentLocale]];
}

- (void)setupWithConfiguration:(NSDictionary*)confDictionary
                  userDefaults:(NSUserDefaults*) userDefaults
          userPreferedLanguage:(NSString*) preferedLanguage
             userCurrentLocale:(NSLocale*) userLocale
{
    self.confDictionary = confDictionary;
    self.userDefaults = userDefaults;
    self.experimentsAndTotalSumDictionary = nil;
    self.userPreferedLanguage = [preferedLanguage componentsSeparatedByString:@"-"][0]; // Removing the "-" part of the language. For instance: "en-UK" will become "en"
    self.userCurrentLocale = userLocale;
    
    // Summarize all variants out of all experiments
    [self summarizeExperimentsTotalWeights:self.confDictionary];
}

- (void) summarizeExperimentsTotalWeights:(NSDictionary*)experimentsDictionary
{
    self.experimentsAndTotalSumDictionary = [NSMutableDictionary new];
    
    for (NSString* currExperimentId in experimentsDictionary.allKeys)
    {
        // Get the experiment variants
        NSDictionary* experimentVariants = [[self.confDictionary objectForKey:currExperimentId] objectForKey:EXPERIMENT_DICTIONARY_STRUCTURE_VARIANTS];
        
        if (experimentVariants != nil)
        {
            NSInteger sum = 0;
            
            for (NSString* currentKey in experimentVariants)
            {
                NSNumber* currentValue = [experimentVariants objectForKey:currentKey];
                
                sum += currentValue.integerValue;
            }
            
            [self.experimentsAndTotalSumDictionary setObject:[NSNumber numberWithInteger:sum] forKey:currExperimentId];
        }
    }
}

- (NSString*)variantByExperimentId:(NSString*)experimentId defaultResult:(NSString*)defaultResult
{
    return [self variantByExperimentId:experimentId defaultResult:defaultResult customConditions:nil];
}

- (NSString*)variantByExperimentId:(NSString*) experimentId defaultResult:(NSString*)deafultResult customConditions:(BOOL (^)())customConditionsBlock
{
    NSString* result = nil;
    
    NSDictionary* experimentVariants = [[self.confDictionary objectForKey:experimentId] objectForKey:EXPERIMENT_DICTIONARY_STRUCTURE_VARIANTS];
    
    if (!experimentVariants || (customConditionsBlock && !customConditionsBlock()))
    {
        [self removeExperimentDrawIfExisted:experimentId];
        
        // Experiment doesn't exist
        result = deafultResult;
    }
    else if (![self deviceLanguageIsSupportedForExperiment:experimentId] ||
             ![self userCountryIsSupportedForExperiment:experimentId])
    {
        // Experiment doesn't support the device language
        result = deafultResult;
    }
    else
    {
        ADRolloutManagerDrawInstance* savedDraw = [self getExperimentDrawIfExisted:experimentId];
        
        if (savedDraw.chosenVariant && [self isExperimentSticky:experimentId])
        {
            result = savedDraw.chosenVariant;
        }
        else
        {
            float experienceUserGeneratedPercentage;
            
            if (savedDraw.randomNumber)
            {
                // Use a saved number
                experienceUserGeneratedPercentage = savedDraw.randomNumber.floatValue;
            }
            else
            {
                // Generate a random number for the user
                experienceUserGeneratedPercentage = ((arc4random() % 1000000) + 1) / 1000000.0;
            }
            
            float sum = 0;
            
            // Getting the chosen variant
            for (NSString* currExperimentVariant in experimentVariants)
            {
                float currentPercentage = ((NSNumber*)experimentVariants[currExperimentVariant]).floatValue / ((NSNumber*)self.experimentsAndTotalSumDictionary[experimentId]).floatValue;
                
                sum += currentPercentage;
                
                if (experienceUserGeneratedPercentage <= sum)
                {
                    ADRolloutManagerDrawInstance* newDraw = [ADRolloutManagerDrawInstance new];
                    newDraw.chosenVariant = [NSString stringWithFormat:@"%@_%@", experimentId, currExperimentVariant];
                    newDraw.randomNumber = @(experienceUserGeneratedPercentage);
                    
                    // Save current raffle for next time
                    [self saveDrawToPersistentStore:newDraw experimentId:experimentId];
                    
                    result = newDraw.chosenVariant;
                    break;
                }
            }
        }
    }
    
    return result;
}

- (BOOL) isExperimentSticky:(NSString*)experimentId
{
    NSDictionary* experimentsettings = [[self.confDictionary objectForKey:experimentId] objectForKey:EXPERIMENT_DICTIONARY_STRUCTURE_SETTINGS];
    
    NSNumber* isSticky = [experimentsettings objectForKey:@"is_sticky"];
    
    BOOL returnValue = NO;
    
    if (isSticky)
    {
        returnValue = isSticky.boolValue;
    }
    
    return returnValue;
}

- (BOOL) userCountryIsSupportedForExperiment:(NSString*)experimentId
{
    NSString *countryCode = [self.userCurrentLocale objectForKey:NSLocaleCountryCode]; // According to https://en.wikipedia.org/wiki/ISO_3166-1
    
    return [self isExperimentSupported:experimentId settingsKey:@"supported_countries" currentValue:countryCode];
}

- (BOOL) deviceLanguageIsSupportedForExperiment:(NSString*)experimentId
{
    // According to https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
    
    return [self isExperimentSupported:experimentId settingsKey:@"supported_languages" currentValue:self.userPreferedLanguage];
}

- (BOOL) isExperimentSupported:(NSString*)experimentId settingsKey:(NSString*)settingsSectionKey currentValue:(NSString*)currentValue
{
    NSDictionary* experimentsettings = [[self.confDictionary objectForKey:experimentId] objectForKey:EXPERIMENT_DICTIONARY_STRUCTURE_SETTINGS];
    
    NSString* experimentSupportedValues = [[experimentsettings objectForKey:settingsSectionKey] lowercaseString];
    
    // Supporting all values by default when the specific settings doesn't exist
    BOOL returnValue = YES;
    
    if (experimentSupportedValues)
    {
        // Checking if current value existed in the settings section values
        NSArray* experimentSupportedValuesArray = [experimentSupportedValues componentsSeparatedByString:@","];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF = %@", [currentValue lowercaseString]];
        NSArray *results = [experimentSupportedValuesArray filteredArrayUsingPredicate:predicate];
        
        returnValue = (results.count > 0);
    }
    
    return returnValue;
}

- (void) saveDrawToPersistentStore:(ADRolloutManagerDrawInstance*)raffleInstance experimentId:(NSString*)experimentId
{
    NSString* resultKeyFormat = [NSString stringWithFormat:FORMAT_FOR_SAVED_RESULT_PER_EXPERIMENT, experimentId];
    NSString* randomNumberKeyFormat = [NSString stringWithFormat:FORMAT_FOR_SAVED_RANDOM_PER_EXPERIMENT, experimentId];
    
    if ((![[self.userDefaults dictionaryRepresentation].allKeys containsObject:randomNumberKeyFormat]) &&
        (![[self.userDefaults dictionaryRepresentation].allKeys containsObject:resultKeyFormat]))
    {
        [self.userDefaults setObject:raffleInstance.chosenVariant forKey:resultKeyFormat];
        [self.userDefaults setObject:raffleInstance.randomNumber forKey:randomNumberKeyFormat];
        [self.userDefaults synchronize];
        
        NSLog(@"Rollout Manager Information: A result has been saved to persistent store for the %@ experiment", experimentId);
    }
}

- (ADRolloutManagerDrawInstance*) getExperimentDrawIfExisted:(NSString*)experimentId
{
    // Support old versions
    // ====================
    // In the old versions we used to save the number under a different key, but we didn't save the actual result.
    // This code should be removed once we remove the experiments: feature_default_draw_tool, feature_first_screen_file_manager, feature_grid
    NSString* oldNumberKey = [NSString stringWithFormat:FORMAT_FOR_EXPERIMENT_NUMBER_KEY, experimentId];
    if ([self.userDefaults objectForKey:oldNumberKey])
    {
        // Retrieve the saved random number from the persistent store
        ADRolloutManagerDrawInstance* savedDraw = [ADRolloutManagerDrawInstance new];
        savedDraw.chosenVariant = nil;
        NSInteger tempint = [self.userDefaults integerForKey:oldNumberKey];
        savedDraw.randomNumber = @(tempint / 100.0);
        
        [self.userDefaults removeObjectForKey:oldNumberKey];
        [self.userDefaults synchronize];
        
        return savedDraw;
    }
    
    // Support the current version
    NSString* resultKeyFormat = [NSString stringWithFormat:FORMAT_FOR_SAVED_RESULT_PER_EXPERIMENT, experimentId];
    NSString* randomNumberKeyFormat = [NSString stringWithFormat:FORMAT_FOR_SAVED_RANDOM_PER_EXPERIMENT, experimentId];
    
    if ((![[self.userDefaults dictionaryRepresentation].allKeys containsObject:randomNumberKeyFormat]) &&
        (![[self.userDefaults dictionaryRepresentation].allKeys containsObject:resultKeyFormat]))
    {
        // No result were found
        return nil;
    }
    else
    {
        // Retrieve the saved result from the persistent store
        ADRolloutManagerDrawInstance* savedDraw = [ADRolloutManagerDrawInstance new];
        savedDraw.chosenVariant = [self.userDefaults objectForKey:resultKeyFormat];
        savedDraw.randomNumber = [self.userDefaults objectForKey:randomNumberKeyFormat];
        
        // Check if the variant still existed in the variants list
        NSDictionary* experimentVariants = [[self.confDictionary objectForKey:experimentId] objectForKey:EXPERIMENT_DICTIONARY_STRUCTURE_VARIANTS];
        NSString* variantNameWithoutExperimentName = [savedDraw.chosenVariant stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@_",experimentId] withString:@""];
        if (![experimentVariants objectForKey:variantNameWithoutExperimentName])
        {
            savedDraw.chosenVariant = nil;
        }
        
        return savedDraw;
    }
}

- (void) removeExperimentDrawIfExisted:(NSString*)experimentId
{
    NSString* resultKeyFormat = [NSString stringWithFormat:FORMAT_FOR_SAVED_RESULT_PER_EXPERIMENT, experimentId];
    NSString* randomNumberKeyFormat = [NSString stringWithFormat:FORMAT_FOR_SAVED_RANDOM_PER_EXPERIMENT, experimentId];
    
    if (([[self.userDefaults dictionaryRepresentation].allKeys containsObject:resultKeyFormat]) ||
        ([[self.userDefaults dictionaryRepresentation].allKeys containsObject:randomNumberKeyFormat]))
    {
        // Remove the saved result from the persistent store
        [self.userDefaults removeObjectForKey:resultKeyFormat];
        [self.userDefaults removeObjectForKey:randomNumberKeyFormat];
        [self.userDefaults synchronize];
    }
}

@end
