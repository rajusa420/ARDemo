#import <Foundation/Foundation.h>


#import <MLKitObjectDetectionCommon/MLKCommonObjectDetectorOptions.h>

NS_ASSUME_NONNULL_BEGIN

/** Labels of objects detected by the detector. */
typedef NSString *MLKDetectedObjectLabel NS_TYPED_ENUM NS_SWIFT_NAME(DetectedObjectLabel);
/** The fashion good object label. */
extern MLKDetectedObjectLabel const MLKDetectedObjectLabelFashionGood;
/** The home good object label. */
extern MLKDetectedObjectLabel const MLKDetectedObjectLabelHomeGood;
/** The food object label. */
extern MLKDetectedObjectLabel const MLKDetectedObjectLabelFood;
/** The place object label. */
extern MLKDetectedObjectLabel const MLKDetectedObjectLabelPlace;
/** The plant object label. */
extern MLKDetectedObjectLabel const MLKDetectedObjectLabelPlant;

/** Label indices of objects detected by the detector. */
typedef NSInteger MLKDetectedObjectLabelIndex NS_TYPED_ENUM NS_SWIFT_NAME(DetectedObjectLabelIndex);
/** The fashion good object label. */
static const MLKDetectedObjectLabelIndex MLKDetectedObjectLabelIndexFashionGood = 0;
/** The home good object label. */
static const MLKDetectedObjectLabelIndex MLKDetectedObjectLabelIndexHomeGood = 1;
/** The food object label. */
static const MLKDetectedObjectLabelIndex MLKDetectedObjectLabelIndexFood = 2;
/** The place object label. */
static const MLKDetectedObjectLabelIndex MLKDetectedObjectLabelIndexPlace = 3;
/** The plant object label. */
static const MLKDetectedObjectLabelIndex MLKDetectedObjectLabelIndexPlant = 4;

/** Configurations for an object detector. */
NS_SWIFT_NAME(ObjectDetectorOptions)
@interface MLKObjectDetectorOptions : MLKCommonObjectDetectorOptions

/** Initializes an `ObjectDetectorOptions` instance with the default values. */
- (instancetype)init NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
