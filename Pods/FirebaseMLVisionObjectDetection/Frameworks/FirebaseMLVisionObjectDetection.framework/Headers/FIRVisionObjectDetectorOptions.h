#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @enum VisionObjectDetectorMode
 * Object detector modes.
 */
typedef NS_ENUM(NSInteger, FIRVisionObjectDetectorMode) {
  /** In single image mode, the results are returned when both tracker and detector are finished. */
  FIRVisionObjectDetectorModeSingleImage,
  /**
   * In stream mode, tracker and detector run in parallel. The results are returned when tracker
   * processing is finished. Detection may still be in progress at that time.
   */
  FIRVisionObjectDetectorModeStream,
} NS_SWIFT_NAME(VisionObjectDetectorMode);

/** Configurations for an object detector. */
NS_SWIFT_NAME(VisionObjectDetectorOptions)
@interface FIRVisionObjectDetectorOptions : NSObject

/** Indicates whether the object classification feature is enabled. The default value is `NO`. */
@property(nonatomic) BOOL shouldEnableClassification;

/**
 * Indicates whether all detected objects in the image or frame should be returned by the detector.
 * If set to `NO`, the detector returns only the most prominent object detected. The default value
 * is `NO`.
 */
@property(nonatomic) BOOL shouldEnableMultipleObjects;

/** The mode for the object detector. The default value is `VisionObjectDetectorMode.stream`. */
@property(nonatomic) FIRVisionObjectDetectorMode detectorMode;

/** Initializes a `VisionObjectDetectorOptions` instance with the default values. */
- (instancetype)init NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
