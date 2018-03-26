//
//  AVRecorderDelegate.swift
//  Pacific
//
//  Created by Minh Nguyen on 9/7/16.
//  Copyright © 2017 Langtutheky. All rights reserved.
//

import AVFoundation
import UIKit

@objc
protocol AVRecorderDelegate 
{
    @objc optional func recorder(_ recorder: AVRecorder, enableDevice isEnabled: Bool, type: AVCaptureDevice.DeviceType, position: AVCaptureDevice.Position)
    @objc optional func recorder(_ recorder: AVRecorder, didCapturePhotoWithData data: Data, orientation: String?, error: Error?)
    @objc optional func recorder(_ recorder: AVRecorder, didStartOnDemandRecordingWithSegment segment: AVSegment)
    @objc optional func recorder(_ recorder: AVRecorder, didFinishOnDemandRecordingWithSegment segment: AVSegment)
    @objc optional func recorder(_ recorder: AVRecorder, didStartLiveRecordingWithSegment segment: AVSegment)
    @objc optional func recorder(_ recorder: AVRecorder, didOutputLiveSegment segment: AVSegment)
    @objc optional func recorder(_ recorder: AVRecorder, didFinishLiveRecordingWithSegment segment: AVSegment)
    @objc optional func recorderDidStopBeforeRecording(_ recorder: AVRecorder)
    @objc optional func liveSegmentDuration(_ recorder: AVRecorder) -> Int
    @objc optional func recorder(_ recorder: AVRecorder, pathForLiveSegmentIndex index: Int) -> String
}
