//
//  ImageBufferHelpers.swift
//  ARDemo
//
//  Created by Raj Sathi on 8/23/19.
//  Copyright © 2019 Raj. All rights reserved.
//

import Foundation
import AVFoundation

public class ImageBufferHelpers {
    public static func getCMSampleBuffer(buffer pixelBuffer: CVPixelBuffer) -> CMSampleBuffer? {
        var sampleTimingInfo: CMSampleTimingInfo = CMSampleTimingInfo()
        sampleTimingInfo.presentationTimeStamp = CMTime.zero
        sampleTimingInfo.duration = CMTime.invalid
        sampleTimingInfo.decodeTimeStamp = CMTime.invalid
        
        var formatDesc: CMFormatDescription? = nil
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer, formatDescriptionOut: &formatDesc)
        guard formatDesc != nil else {
            return nil
        }
        
        var sampleBuffer: CMSampleBuffer? = nil
        CMSampleBufferCreateReadyWithImageBuffer(allocator: kCFAllocatorDefault,
                                                 imageBuffer: pixelBuffer,
                                                 formatDescription: formatDesc!,
                                                 sampleTiming: &sampleTimingInfo,
                                                 sampleBufferOut: &sampleBuffer);
        
        return sampleBuffer
    }
}
