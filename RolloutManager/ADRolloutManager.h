//
//  ADRolloutManager.h
//  AD360Helpers-iOS
//
//  Created by Itai Shayovitz on 26/09/2016.
//  Copyright © 2016 Autodesk. All rights reserved.
//
#ifndef AD_ROLLOUT_MANAGER_H
#define AD_ROLLOUT_MANAGER_H

#import <Foundation/Foundation.h>

@interface ADRolloutManager : NSObject

- (void)setupWithConfiguration:(NSDictionary*)confDictionary;

- (void)setupWithConfiguration:(NSDictionary*)confDictionary
                  userDefaults:(NSUserDefaults*) userDefaults
          userPreferedLanguage:(NSString*)preferedLanguage
             userCurrentLocale:(NSLocale*)userLocale;

/**
 *  @brief      Return a random variant for requested feature, according to configured percents
 *  @discussion The user will be allocated a variant only if the feature is active. Otherwise the `defaultResult` will be returned
 *  @param experimentId The id as it's appear in the configuration dictionary
 *  @param defaultResult The default result in case the experiment conditions aren't met:
 *  * Experiment doesn't exist
 *  * custom conditions are met
 *  * remote conditions (filtering) are met
 *  @return Variant name concatinated to experiment name
 */
- (NSString*)variantByExperimentId:(NSString*)experimentId defaultResult:(NSString*)defaultResult;


/**
 *  @brief      Return a random variant for requested feature, according to configured percents
 *  @discussion The user will be allocated a variant only if the feature is active. Otherwise the `defaultResult` will be returned
 *  @param experimentId The id as it's appear in the configuration dictionary
 *  @param defaultResult The default result in case the experiment conditions aren't met:
 *  * Experiment doesn't exist
 *  * custom conditions are met
 *  * remote conditions (filtering) are met
 *  @param customConditionsBlock Custom conditions block you may use to enter limits for getting into the experiment
 *  @return Variant name concatinated to experiment name
 */
- (NSString*)variantByExperimentId:(NSString*)experimentId defaultResult:(NSString*)defaultResult customConditions:(BOOL (^)())customConditionsBlock;

- (void)removeExperimentDrawIfExisted:(NSString*)experimentId;

@end

#endif
