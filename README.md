# Rollout Manager
RolloutManager is a component intended to help you roll out your features inside your app by defining variants and allocating odds for each of them.

The component includes many features like stickiness and default values for your convenience.

#### Support
- Built for iOS 8
- Tested on iOS 10.1

## Installation
#### Cocoapods
In your podfile put this line:
```
pod 'RolloutManager' 
```

## Usage

#### Configuration
```
ADRolloutManager* rolloutManagerInstance = [ADRolloutManager new];
[rolloutManagerInstance setupWithConfiguration:<configuration_dictionary>];
```

#### Usage
```
NSString* chosenVariant = [rolloutManagerInstance variantByExperimentId:@"experiment_01"
                           defaultResult:@"experiment_01_variant_02"];
```
or
```
NSString* chosenVariant = [rolloutManagerInstance variantByExperimentId:@"experiment_01"
                           defaultResult:@"experiment_01_variant_02"
                           customConditions:nil];
```

#### Configuration Dictionary Structure
The structure of the configuration dictionary that is consumed by the Rollout Manager consists of sub-dictionaries:

1. The experiment level, here we define the experiment ids (experiment names)
1. The experiment options:
   1. Settings, at this moment the Rollout Manager supports three options:
      1. is_sticky - receives a YES\NO option.
      1. supported_countries - receives a string of country codes separated by a comma (https://en.wikipedia.org/wiki/ISO_3166-1)
      1. supported_languages - receives a string of languages separated by a comma  (https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)
   1. Variants, a dictionary of the variants names and their weights.

**How does the Rollout Manager calculate it weights?**

*Answer: Every experiment has variants with weights, the algorithm summarizes the weights and for each variant divide it's own weight with the summary of the experiment's weights. This defines the odds for the specific variant.*

```
// A configuration dictionary example
NSDictionary* configuration = @{@"experiment_01":@{@"Settings":@{@"is_sticky":@(YES),
                                                                 @"supported_countries":@"US,IL",
                                                                 @"supported_languages":@"en,he"},
                                                   @"Variants":@{@"variant_01":@(70),
                                                                 @"variant_02":@(30)}},
                                @"experiment_02":@{@"Settings":@{@"is_sticky":@(NO),
                                                                 @"supported_languages":@"en,he"}},
                                                   @"Variants":@{@"variant_01":@(0),
                                                                 @"variant_02":@(100)}}};
```

**The recommended way to create the dictionary is by using a local \ remote plist object!**


## Features Explanation

#### The Features
1. Feature Rollout – distribute a feature to a specific percentage of users.
For instance, you may release a feature only to 10% of the users, then change it to 40% and then to 100%.
 
2. Multiple variants support – you may roll out multiple features and set their allocation as well
For instance, you can decide to release 3 different features to your users and decide what percentage of the users will get each of them.
 
3. Stickiness support – once a user got an experiment we can configure that he will get the same variant permanently until we delete the experiment.
For instance, in case a user got the Variant A, he will keep getting it even if we change the allocation later.
 
4. Remote control – our Rollout Manager is controllable from a configuration file who is located on our S3 server.
An example of usage – you may change the allocation of the variants you have set even after the app has been submitted to the store.
 
5. Remote filtering - it is possible to remotely control on which users will get an experiment.
For instance, you may decide that you want the variants to be rolled only for english speakers from Canada.

6. Custom conditioning - any developer can add his own conditions for an experiment
For example, if you want to check your user's permission level as a condition to get a value from an experiment.

#### Edge Cases
- Changing the allocation while the experiment is marked as sticky will not effect the users who already received the experiment, only new users.
- Changing the allocation while the experiment is marked as non-sticky might change the current variants for users.
- Changing from sticky experiment to a non-sticky will cancel the stickiness, a user that got a variant in the past might get a different variant after the change.
- Changing from non-sticky experiment to a sticky experiment will just make the current users who got a variant to remain sticky even if we change the variant allocation
- Deleting an experiment from S3 will force the default value for the occurrences of the experiment in the code
- A user that has eliminated from the experiment due to a remote filter will receive the default value you indicate in the code.
- When removing an existing variant from an experiment, although the experiment stated as sticky, we will draw the user again to a different variant. 


## Contributing
See [Contributing](./Contributing.md) page.


## Contact
[Asaf Shveki](https://github.com/shvekiasaf)


## Good Luck!
Let the AutoCAD Mobile team know if you need any further explanation :innocent:. 

And of course, submit issues if you have any idea for improvements.

