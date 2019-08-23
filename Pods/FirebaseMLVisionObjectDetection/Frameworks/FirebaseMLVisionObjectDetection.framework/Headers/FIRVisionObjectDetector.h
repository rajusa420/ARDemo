#import <Foundation/Foundation.h>

@class FIRVisionObject;
@class FIRVisionImage;

NS_ASSUME_NONNULL_BEGIN

/**
 * A block containing an array of objects detected or `nil` if there was an error.
 *
 * @param objects Array of objects detected in the image or `nil` if there was an error.
 * @param error The error or `nil`.
 */
typedef void (^FIRVisionObjectDetectionCallback)(NSArray<FIRVisionObject *> *_Nullable objects,
                                                 NSError *_Nullable error)
    NS_SWIFT_NAME(VisionObjectDetectionCallback);

/** An object detector and tracker that detects objects in an image and supports tracking them. */
NS_SWIFT_NAME(VisionObjectDetector)
@interface FIRVisionObjectDetector : NSObject

/** Unavailable. Use `Vision` factory methods. */
- (instancetype)init NS_UNAVAILABLE;

/**
 * Processes the given image for object detection and tracking. The detection is performed
 * asynchronously and calls back the completion handler with the detected object results or error
 * on the main thread.
 *
 * @param image The vision image to use for detecting and tracking objects.
 * @param completion Handler to call back on the main thread with objects detected or error.
 */
- (void)processImage:(FIRVisionImage *)image
          completion:(FIRVisionObjectDetectionCallback)completion
    NS_SWIFT_NAME(process(_:completion:));

/**
 * Returns detected objects in the given image or `nil` if there was an error. The detection is
 * performed synchronously on the calling thread.
 *
 * @discussion It is advised to call this method off the main thread to avoid blocking the UI. As a
 *     result, an `NSException` is raised if this method is called on the main thread.
 * @param image The vision image to use for detecting objects.
 * @param error An optional error parameter populated when there is an error during detection.
 * @return Array of objects detected in the given image or `nil` if there was an error.
 */
- (nullable NSArray<FIRVisionObject *> *)resultsInImage:(FIRVisionImage *)image
                                                  error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
