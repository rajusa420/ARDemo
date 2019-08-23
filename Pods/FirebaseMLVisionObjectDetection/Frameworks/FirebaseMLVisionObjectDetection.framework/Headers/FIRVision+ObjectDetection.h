

#import <FirebaseMLVision/FirebaseMLVision.h>



@class FIRVisionObjectDetector;
@class FIRVisionObjectDetectorOptions;

NS_ASSUME_NONNULL_BEGIN

/** A category of `Vision` that contains APIs for object detection and tracking. */
@interface FIRVision (ObjectDetection)

/**
 * Returns an instance of `VisionObjectDetector` with the given options.
 *
 * @param options Options for configuring the object detector.
 * @return An object detector configured with the given options.
 */
- (FIRVisionObjectDetector *)objectDetectorWithOptions:(FIRVisionObjectDetectorOptions *)options
    NS_SWIFT_NAME(objectDetector(options:));

/**
 * Returns an instance of `VisionObjectDetector` with default options.
 *
 * @return An object detector configured with default options.
 */
- (FIRVisionObjectDetector *)objectDetector;

@end

NS_ASSUME_NONNULL_END
