#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @options VisionObjectCategory
 * Categories of objects returned by the detector.
 */
typedef NS_ENUM(NSInteger, FIRVisionObjectCategory) {
  /** An unknown object category. All objects that are not associated with a category. */
  FIRVisionObjectCategoryUnknown,
  /** The Home Goods object category. */
  FIRVisionObjectCategoryHomeGoods,
  /** The Fashion Goods object category. */
  FIRVisionObjectCategoryFashionGoods,
  /** The Food object category. */
  FIRVisionObjectCategoryFood,
  /** The Places object category. */
  FIRVisionObjectCategoryPlaces,
  /** The Plants object category. */
  FIRVisionObjectCategoryPlants,
} NS_SWIFT_NAME(VisionObjectCategory);

/** An object detected in an image. */
NS_SWIFT_NAME(VisionObject)
@interface FIRVisionObject : NSObject

/**
 * The rectangle that holds the discovered object relative to the detected image in the view's
 * coordinate system.
 */
@property(nonatomic, readonly) CGRect frame;

/**
 * The category of the object returned by the classifier. The property returns `.unknown` if the
 * detector option `shouldEnableClassification` is set to `NO`.
 */
@property(nonatomic, readonly) FIRVisionObjectCategory classificationCategory;

/**
 * The tracking identifier of the vision object. The value is a non-negative `integerValue`. The
 * value is `nil` if no tracking ID was provided.
 */
@property(nonatomic, readonly, nullable) NSNumber *trackingID;

/**
 * The probability confidence for the vision object in range from 0 to 1. The value is a
 * `floatValue`. The value is `nil` if the object is detected, but a valid confidence was not
 * provided.
 */
@property(nonatomic, readonly, nullable) NSNumber *confidence;

/** Unavailable. */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
